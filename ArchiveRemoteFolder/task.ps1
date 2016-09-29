param (
    [Parameter(Mandatory=$true)][string] $server,
    [Parameter(Mandatory=$true)][string] $adminusr,
    [Parameter(Mandatory=$true)][string] $adminpwd,
    [Parameter(Mandatory=$true)][string] $securevariablename,
    [Parameter(Mandatory=$true)][string] $sourcepath,
    [Parameter(Mandatory=$true)][string] $targetpath,
    [Parameter(Mandatory=$true)][string] $filename,
    [Parameter(Mandatory=$true)][string] $datestampformat
)

Write-Host "Entering task.ps1";

Write-Verbose "Remote Server:      $server";
Write-Verbose "Admin User:         $adminusr";
Write-Verbose "Password Variable:  $securevariablename";
Write-Verbose "Remote Source Path: $sourcepath";
Write-Verbose "Remote Target Path: $targetpath";
Write-Verbose "7z Filename:        $filename";
Write-Verbose "Date Stamp Format:  $datestampformat";

Write-Host "Importing modules Microsoft.TeamFoundation.DistributedTask.Task.*";
Import-Module "Microsoft.TeamFoundation.DistributedTask.Task.Common";
Import-Module "Microsoft.TeamFoundation.DistributedTask.Task.Internal";
Write-Host "Modules imported.";

Write-Host "Validating Source Path variable.";

if (-not $sourcepath.EndsWith("\")) {
    $sourcepath = "$sourcepath\";
}

Write-Host "Source Path is $sourcepath.";
Write-Host "Validating Target Path variable.";

if (-not $targetpath.EndsWith("\")) {
    $targetpath = "$targetpath\";
}

Write-Host "Target Path is $targetpath.";
Write-Host "Validating Filename variable.";

if (-not $filename.EndsWith(".7z")) {
    $filename = "$filename" + "_" + (Get-Date -format $datestampformat) + ".7z";
} else {
    $filename = $filename.Replace(".7z", "") + "_" + (Get-Date -format $datestampformat) + ".7z";
}

Write-Host "Filename is $filename.";

$Source = "$sourcepath*.*"
$7zFile = "$targetpath$filename";

$adminpwd = Get-TaskVariable -Context $distributedTaskContext -Name $securevariablename;

Write-Host "Creating Secured Credentials.";
$Credential = New-Object System.Management.Automation.PSCredential($adminusr, (ConvertTo-SecureString -String $adminpwd -AsPlainText -Force));

Write-Host "Opening Powershel remote session on $server.";
$Session = New-PSSession -ComputerName $server -Credential $Credential;

Write-Host "Invoking 7z executable on remote server.";
Invoke-Command -Session $Session { Set-Alias 7z "$env:ProgramFiles\7-Zip\7z.exe"; 7z a -t7z $args[0] $args[1] } -ArgumentList $7zFile, $Source;

Write-Host "Exiting task.ps1";