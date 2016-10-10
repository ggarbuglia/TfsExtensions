param (
    [string] $sourcepath,
    [string] $server,
    [string] $instance,
    [string] $adminusr,
    [string] $adminpwd,
    [string] $dbname,
    [string] $dbusr,
    [string] $dbpwd,
    [string] $waitseconds
)

Write-Host "Entering script task.ps1";

Write-Verbose "[sourcepath]  --> [$sourcepath]"  -Verbose;
Write-Verbose "[server]      --> [$server]"      -Verbose;
Write-Verbose "[instance]    --> [$instance]"    -Verbose;
Write-Verbose "[adminusr]    --> [$adminusr]"    -Verbose;
Write-Verbose "[dbname]      --> [$dbname]"      -Verbose;
Write-Verbose "[dbusr]       --> [$dbusr]"       -Verbose;
Write-Verbose "[waitseconds] --> [$waitseconds]" -Verbose;

### Validates all paths ###
function ValidatePath ([string]$type, [string]$path) {
    Write-Host "Validating $type Path variable.";
    if (-not $path.EndsWith("\")) { $path = "$path\"; }
    Write-Host "$type Path is $path.";
    return $path;
}

if ($waitseconds -eq '' -or $waitseconds -eq $null) { $waitseconds = '3'; }
if ($dbusr -eq '' -or $dbusr -eq $null) { $dbusr = $adminusr; }
if ($dbpwd -eq '' -or $dbpwd -eq $null) { $dbpwd = $adminpwd; }

$sourcepath = ValidatePath -type "Source" -path $sourcepath;
$targetpath = "C:\Temp\SqlTemporalFiles\$dbname";

Write-Host "Creating Script Blocks.";
$sb1 = { 
    $server   = $args[0];
    $instance = $args[1];
    $dbname   = $args[2];
    $dbusr    = $args[3];
    $dbpwd    = $args[4];
    $tempPath = $args[5];
    $waitsecs = $args[6];

    if (-not (Test-Path $tempPath)) { New-Item $tempPath -Type Directory | Out-Null; }

    Import-Module SQLPS -DisableNameChecking;

    Set-Location "SQLSERVER:\SQL\$server\$instance";
};

$sb2 = {
    Get-ChildItem $tempPath | ? { $_.Extension -eq ".sql" } | ForEach-Object { 
        Write-Host "Running '$_' script.";
        Invoke-Sqlcmd -ServerInstance (Get-Item .) -Database $dbname -Username $dbusr -Password $dbpwd -InputFile $_.FullName -ErrorAction Stop -SuppressProviderContextWarning;
        Start-Sleep -Seconds ([Convert]::ToInt32($waitsecs, 10));
    }
};

$sb3 = {
    if (Test-Path $tempPath) { Remove-Item $tempPath -Recurse | Out-Null; }
};

[System.Management.Automation.Runspaces.PSSession] $session = $null;

Try 
{
    Write-Host "Creating Secured Credentials.";
    $credential = New-Object System.Management.Automation.PSCredential($adminusr, (ConvertTo-SecureString -String $adminpwd -AsPlainText -Force));

    Write-Host "Opening Powershell remote session on $server.";
    $session = New-PSSession -Name SQL -ComputerName $server -Credential $credential;

    Write-Host "Setting up remote session.";
    Invoke-Command -Session $session -ScriptBlock $sb1 -ArgumentList $server, $instance, $dbname, $dbusr, $dbpwd, $targetpath, $waitseconds;
    
    Write-Host "Copying scripts to remote session.";
    Copy-Item -Path "$sourcepath*.sql" -Destination $targetpath -ToSession $session -Force;

    Write-Host "Running scripts on remote server.";
    Invoke-Command -Session $session -ScriptBlock $sb2;

    Write-Host "Removing scripts from remote server.";
    Invoke-Command -Session $session -ScriptBlock $sb3;
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