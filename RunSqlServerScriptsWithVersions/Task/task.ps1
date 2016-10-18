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

function Get-FileEncoding([string]$path) { 
    [string] $encoding = '';
    [byte[]]$byte = Get-Content -Encoding byte -ReadCount 4 -TotalCount 4 -Path $path;

    if     ($byte[0] -eq 0xef -and $byte[1] -eq 0xbb -and $byte[2] -eq 0xbf) { $encoding = 'UTF8'; }
    elseif ($byte[0] -eq 0xfe -and $byte[1] -eq 0xff) { $encoding = 'Unicode'; }
    elseif ($byte[0] -eq 0 -and $byte[1] -eq 0 -and $byte[2] -eq 0xfe -and $byte[3] -eq 0xff) { $encoding = 'UTF32'; }
    elseif ($byte[0] -eq 0x2b -and $byte[1] -eq 0x2f -and $byte[2] -eq 0x76) { $encoding =  'UTF7'; }
    else { $encoding = 'ASCII'; }

    return $encoding;
}

### Validates that all files on path are encoded with UTF-8 ###
function ValidateEncoding ([string]$path) {
    Get-ChildItem $path | ? { $_.PSIsContainer -eq $false -and $_.Extension -eq ".sql" } | % { 
        if ((Get-FileEncoding -path $_.FullName) -ne 'UTF8') { 
            throw "File $_ is not encoded using UTF-8 with signature. Please save the file again using proper encoding."
        }
    }
}

### Gets a list of the latest scripts to execute ###
function GetListOfScriptsToExecute ([string]$path, [int]$maxid) {
    [boolean] $lastitemfounded = $false;

    $list = New-Object System.Collections.ArrayList;

    $files = Get-ChildItem $path | ? { $_.PSIsContainer -eq $false -and $_.Extension -eq ".sql" } | Sort-Object | % { 
        if ($lastitemfounded -eq $false) {
            if ($_.Name.Contains([string]$maxid) -eq $true) { 
                $lastitemfounded = $true; 
            } else { 
                return; 
            }
        }
        
        [void] $list.Add($_.FullName);
    }

    return $list;
}

Try 
{

    $sourcepath = ValidatePath -type "Source" -path $sourcepath;
    $targetpath = "C:\Temp\SqlTemporalFiles\$dbname";

    ValidateEncoding -path $sourcepath;

    if ($waitseconds -eq '' -or $waitseconds -eq $null) { $waitseconds = '3'; }
    if ($dbusr -eq '' -or $dbusr -eq $null) { $dbusr = $adminusr; }
    if ($dbpwd -eq '' -or $dbpwd -eq $null) { $dbpwd = $adminpwd; }

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
        Get-ChildItem $tempPath | ? { $_.Extension -eq ".sql" } | % { 
            Write-Host "Running '$_' script.";
            Invoke-Sqlcmd -ServerInstance (Get-Item .) -Database $dbname -Username $dbusr -Password $dbpwd -InputFile $_.FullName -ErrorAction Stop -SuppressProviderContextWarning;
            Start-Sleep -Seconds ([Convert]::ToInt32($waitsecs, 10));
        }
    };

    $sb3 = {
        if (Test-Path $tempPath) { Remove-Item $tempPath -Recurse | Out-Null; }
    };

    $sbq = {
        $query = "SELECT ISNULL(MAX(Id), 0) AS MaxId FROM [dbo].[Versions];";
        $drow  = Invoke-Sqlcmd -ServerInstance (Get-Item .) -Database $dbname -Username $dbusr -Password $dbpwd -Query $query -SuppressProviderContextWarning;
        $drow.MaxId;
    }

    [System.Management.Automation.Runspaces.PSSession] $session = $null;

    Write-Host "Creating Secured Credentials.";
    $credential = New-Object System.Management.Automation.PSCredential($adminusr, (ConvertTo-SecureString -String $adminpwd -AsPlainText -Force));

    Write-Host "Opening Powershell remote session on $server.";
    $session = New-PSSession -Name SQL -ComputerName $server -Credential $credential;

    Write-Host "Setting up remote session.";
    Invoke-Command -Session $session -ScriptBlock $sb1 -ArgumentList $server, $instance, $dbname, $dbusr, $dbpwd, $targetpath, $waitseconds -ErrorAction Stop;
    
    Write-Host "Querying Versions table on remote server.";
    $maxid = Invoke-Command -Session $session -ScriptBlock $sbq;

    Write-Host "Copying scripts to remote session.";
    GetListOfScriptsToExecute -path $sourcepath -maxid ($maxid + 1) | % { 
        Copy-Item -Path "$_" -Destination $targetpath -ToSession $session -Force;
    }

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
    if ($session -ne $null -and $session.State.ToString() -ne 'Closed') { $session | Disconnect-PSSession | Remove-PSSession };
}

Write-Host "Leaving script task.ps1";