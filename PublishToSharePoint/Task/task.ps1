param (
    [string] $sourcepath,
    [string] $server,
    [string] $adminusr,
    [string] $adminpwd,
    [string] $spsiteurl,
    [string] $spweburl,
    [string] $username,
    [string] $doclibname,
    [string] $doclibfolder,
    [string] $createfolders
)

Write-Host "Entering script task.ps1";

Write-Verbose "[sourcepath]    --> [$sourcepath]"    -Verbose;
Write-Verbose "[server]        --> [$server]"        -Verbose;
Write-Verbose "[adminusr]      --> [$adminusr]"      -Verbose;
Write-Verbose "[spsiteurl]     --> [$spsiteurl]"     -Verbose;
Write-Verbose "[spweburl]      --> [$spweburl]"      -Verbose;
Write-Verbose "[username]      --> [$username]"      -Verbose;
Write-Verbose "[doclibname]    --> [$doclibname]"    -Verbose;
Write-Verbose "[doclibfolder]  --> [$doclibfolder]"  -Verbose;
Write-Verbose "[createfolders] --> [$createfolders]" -Verbose;

### Validates all paths ###
function ValidatePath ([string]$type, [string]$path) {
    Write-Host "Validating $type Path variable.";
    if (-not $path.EndsWith("\")) { $path = "$path\"; }
    Write-Host "$type Path is $path.";
    return $path;
}

$sourcepath = ValidatePath -type "Source" -path $sourcepath;
$targetpath = "C:\Temp\" + (New-Guid).ToString().ToUpper();

if ($spsiteurl.EndsWith("/")) { 
    $spsiteurl = $spsiteurl.Substring(0, $spsiteurl.Length -1);
}

$spweburl = $spweburl.Replace("$spsiteurl", "");

if (-not $spweburl.StartsWith("/")) { 
    $spweburl = "/$spweburl";
}

if ($doclibfolder.StartsWith("/")) { 
    $doclibfolder = $doclibfolder.Substring(1, $doclibfolder.Length -1); 
}

Write-Host "Creating Script Blocks.";
$sb = { 
    $tempPath = $args[0];

    if (-not (Test-Path $tempPath)) { New-Item $tempPath -Type Directory | Out-Null; }
};

$directory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent;
$uploadps1 = Join-Path $directory "upload.ps1";

[System.Management.Automation.Runspaces.PSSession] $session = $null;

Try 
{
    Write-Host "Creating Secured Credentials.";
    $credential = New-Object System.Management.Automation.PSCredential($adminusr, (ConvertTo-SecureString -String $adminpwd -AsPlainText -Force));

    Write-Host "Opening Powershell remote session on $server.";
    $session = New-PSSession -Name SharePoint -ComputerName $server -Credential $credential -Authentication Credssp;

    Write-Host "Setting up remote session.";
    Invoke-Command -Session $session -ScriptBlock $sb -ArgumentList $targetpath;

    Write-Host "Copying files to remote session.";
    Copy-Item -Path "$sourcepath*.*" -Destination $targetpath -ToSession $session -Force;

    Write-Host "Running upload process on remote session.";
    Invoke-Command -Session $session -FilePath $uploadps1 -ArgumentList $spsiteurl, $spweburl, $username, $doclibname, $doclibfolder, $targetpath, "5", $createfolders;
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