param (
    [string] $sourcepath,
    [string] $server,
    [string] $adminusr,
    [string] $adminpwd,
    [string] $targetpath,
    [string] $excludetypeslist,
    [string] $authenticationmechanism,
    [boolean] $skipcertificatechecks
)

Write-Host "Entering script task.ps1";

Write-Verbose "[sourcepath]       --> [$sourcepath]"       -Verbose;
Write-Verbose "[server]           --> [$server]"           -Verbose;
Write-Verbose "[adminusr]         --> [$adminusr]"         -Verbose;
Write-Verbose "[targetpath]       --> [$targetpath]"       -Verbose;
Write-Verbose "[excludetypeslist] --> [$excludetypeslist]" -Verbose;
Write-Verbose "[authenticationmechanism] --> [$authenticationmechanism]" -Verbose;
Write-Verbose "[skipcertificatechecks] --> [$skipcertificatechecks]" -Verbose;

### Validates all paths ###
function ValidatePath ([string]$type, [string]$path) {
    Write-Host "Validating $type Path variable.";
    if (-not $path.EndsWith("\")) { $path = "$path\"; }
    Write-Host "$type Path is $path.";
    return $path;
}

$sourcepath = ValidatePath -type "Source" -path $sourcepath;
$targetpath = ValidatePath -type "Target" -path $targetpath;

[System.Management.Automation.Runspaces.PSSession] $session = $null;

Try 
{
    Write-Host "Creating Secured Credentials.";
    $credential = New-Object System.Management.Automation.PSCredential($adminusr, (ConvertTo-SecureString -String $adminpwd -AsPlainText -Force));

    if ($skipcertificatechecks -eq $true) { 
        Write-Host "Skipping certificate checks against remote CommonName, Certificate Authoriy and Revocation.";
        $sessionoptions = New-PSsessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck;
    } else {
        $sessionoptions = "";
    }
    
    Write-Host "Opening Powershell remote session on $server.";
    $session = New-PSSession -ComputerName $server -Credential $credential -Authentication $authenticationmechanism -SessionOption $sessionoptions;

    Write-Host "Copying files to remote session.";
    Copy-Item -Path "$sourcepath**" -Destination $targetpath -ToSession $session -Recurse -Force;

    if ($excludetypeslist -ne "") { 
        Write-Host "Removing excluded files from remote session.";
        $excludetypes = $excludetypeslist -split ',';
        foreach ($excludetype in $excludetypes) {
            Invoke-Command -Session $session -ScriptBlock { Get-ChildItem $args[0] -Recurse -Include $args[1] | Remove-Item; } -ArgumentList $targetpath, $excludetype;
        }
    }
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