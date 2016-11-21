param (
    [string] $server,
    [string] $adminusr,
    [string] $adminpwd,
    [string] $action,
    [string] $webs,
    [string] $apppools
)

Write-Host "Entering script task.ps1";

Write-Verbose "[server]   --> [$server]"     -Verbose;
Write-Verbose "[adminusr] --> [$adminusr]"   -Verbose;
Write-Verbose "[action]   --> [$action]"     -Verbose;
Write-Verbose "[webs]     --> [$webs]"       -Verbose;
Write-Verbose "[apppools] --> [$apppools]"   -Verbose;

$sb = {
    [string] $action   = $args[0];
    [string] $webs     = $args[1];
    [string] $apppools = $args[2];

    if ($webs.TrimEnd() -eq "" -and $apppools.TrimEnd() -eq "") {
        Write-Warning "No webs or app pools declared. Action will be performed on IIS.";
        switch ($action) {
            "Stop" { 
                Write-Host "Stopping IIS.";
                Get-Service -Name 'W3SVC' | ? {$_.Status -eq "Running"} | Stop-Service;
            }
            "Start" { 
                Write-Host "Starting IIS.";
                Get-Service -Name 'W3SVC' | ? {$_.Status -eq "Stopped"} | Start-Service;
            }
            "Restart" { 
                Write-Host "Restarting IIS.";
                Get-Service -Name 'W3SVC' | Restart-Service;
            }
            Default {}
        }
    } else { 
        Import-Module WebAdministration -ErrorAction SilentlyContinue;

        switch ($action) {
            "Stop" { 
                # When STOP > first Webs then AppPools
                if ($webs.TrimEnd() -ne "") { 
                    foreach ($web in ($webs -split ',')) {
                        Write-Host "Stopping Web Site '$web'.";
                        Stop-Website -Name "$web";
                    }
                }

                if ($apppools.TrimEnd() -ne "") { 
                    foreach ($pool in ($apppools -split ',')) {
                        Write-Host "Stopping App Pool '$pool'.";
                        Stop-WebAppPool -Name "$pool";
                    }
                }
            }
            "Start" { 
                # When START > first AppPools then Webs
                if ($apppools.TrimEnd() -ne "") { 
                    foreach ($pool in ($apppools -split ',')) {
                        Write-Host "Starting App Pool '$pool'.";
                        Start-WebAppPool -Name "$pool"; 
                    }
                }

                if ($webs.TrimEnd() -ne "") { 
                    foreach ($web in ($webs -split ',')) {
                        Write-Host "Starting Web Site '$web'.";
                        Start-Website -Name "$web";
                    }
                }
            }
            "Restart" { 
                if ($webs.TrimEnd() -ne "") { 
                    foreach ($web in ($webs -split ',')) {
                        Write-Host "Stopping Web Site '$web'.";
                        Stop-Website -Name "$web";
                    }
                }

                if ($apppools.TrimEnd() -ne "") { 
                    foreach ($pool in ($apppools -split ',')) {
                        Write-Host "Stopping App Pool '$pool'.";
                        Stop-WebAppPool -Name "$pool";
                    }
                }

                if ($apppools.TrimEnd() -ne "") { 
                    foreach ($pool in ($apppools -split ',')) {
                        Write-Host "Starting App Pool '$pool'.";
                        Start-WebAppPool -Name "$pool"; 
                    }
                }

                if ($webs.TrimEnd() -ne "") { 
                    foreach ($web in ($webs -split ',')) {
                        Write-Host "Starting Web Site '$web'.";
                        Start-Website -Name "$web";
                    }
                }
            }
            Default {}
        }
    }
}

[System.Management.Automation.Runspaces.PSSession] $session = $null;

Try 
{
    Write-Host "Creating Secured Credentials.";
    $credential = New-Object System.Management.Automation.PSCredential($adminusr, (ConvertTo-SecureString -String $adminpwd -AsPlainText -Force));

    Write-Host "Opening Powershell remote session on $server.";
    $session = New-PSSession -ComputerName $server -Credential $credential;

    Write-Host "Executing task on remote session.";
    Invoke-Command -Session $session -ScriptBlock $sb -ArgumentList $action, $webs, $apppools;
}
Catch 
{
    Write-Host;
    Write-Error $_;
}
Finally 
{
    Write-Host "Closing Powershell remote session on $server.";
    if ($session -ne $null) { $session | Disconnect-PSSession | Remove-PSSession };
}

Write-Host "Leaving script task.ps1";