param (
    [string] $spsiteurl,
    [string] $spweburl,
    [string] $username,
    [string] $doclibname,
    [string] $doclibfolder,
    [string] $tempPath,
    [string] $waitsecs, 
    [string] $createfolders
)

Add-PSSnapin Microsoft.Sharepoint.Powershell -ErrorAction Stop;

function Get-ImpersonatedSPSite ([string] $url, [string] $user)
{
    $user = $user.ToLower();

    $spsite = Get-SPSite -Identity $url -ErrorAction Stop;
    if ($spsite -eq $null) { throw "SharePoint Site Collection '$url' not found."; }

    $spuser = $spsite.RootWeb.AllUsers["i:0#.w|$user"];
    if ($spuser -eq $null) { throw "SharePoint User '$user' not found."; }

    return New-Object Microsoft.Sharepoint.SPSite($url, $spuser.UserToken);
}

Try 
{
    Start-SPAssignment -Global;

    Write-Host "Impersonating on SharePoint Site '$spsiteurl'... " -NoNewline;
    $spsite = Get-ImpersonatedSPSite -url $spsiteurl -user $username;
    Write-Host "OK";

    Write-Host "Opening SharePoint Web '$spweburl'... " -NoNewline;
    $spweb = $spsite.OpenWeb("$spweburl");
    if ($spweb -eq $null) { throw "SharePoint Web '$spweburl' not found."; }
    Write-Host "OK";

    Write-Host "Currently logged in as:" $spweb.CurrentUser.DisplayName;

    Write-Host "Setting SharePoint Document Library to '$doclibname'... " -NoNewline;
    $doclib = [Microsoft.SharePoint.SPDocumentLibrary] $spweb.Lists["$doclibname"];
    if ($doclib -eq $null) { throw "SharePoint Document Library '$doclibname' not found."; }
    Write-Host "OK";

    $folder = $doclib.RootFolder;

    if ($doclibfolder -ne "") 
    {
        Write-Host "Setting SharePoint Folder path to '$doclibfolder'... " -NoNewline;
        $folderpath = $spweb.Url + "/" + $doclib.RootFolder.Url + "/" + $doclibfolder;
        $folder = $doclib.ParentWeb.GetFolder($folderpath);

        if ($folder.Exists -eq $false) 
        { 
            if ([System.Convert]::ToBoolean($createfolders) -eq $true) 
            {
                [boolean] $isfirstlevel = $true;
                foreach ($fld in $doclibfolder.Split('/'))
                {
                    if ($isfirstlevel -eq $true) 
                    {
                        $folder = $doclib.AddItem("", [Microsoft.SharePoint.SPFileSystemObjectType]::Folder, $fld)
                    } else {
                        $folder = $doclib.AddItem($folder.URL, [Microsoft.SharePoint.SPFileSystemObjectType]::Folder, $fld)
                    }
                    
                    $folder.Update();
                    $isfirstlevel = $false;
                }

                $folder = $doclib.ParentWeb.GetFolder($folderpath);
            } else {
                throw "SharePoint Folder path '$doclibfolder' not found and automatic creation is disabled."; 
            }
        }
        Write-Host "OK";
    }

    $spWeb.AllowUnsafeUpdates = $true;

    Get-ChildItem $tempPath | ? { $_.PSIsContainer -eq $false } | ForEach-Object {
        [System.IO.Stream] $filestream = $null;
        Try 
        {
            Write-Host "Uploading file '$_'... " -NoNewline;
            $fileinfo   = ([System.IO.FileInfo](Get-Item $_.FullName));
            $filestream = $fileinfo.OpenRead();
            $folder.Files.Add($folder.Url + "/" + $fileinfo.Name, [System.IO.Stream] $filestream, $true) | Out-Null;
            Start-Sleep -Seconds ([Convert]::ToInt32($waitsecs, 10));
            Write-Host "OK";
        } 
        Catch 
        {
            Write-Host;
            Write-Error $_;
        } 
        Finally 
        {
            $fileStream.Close();
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
    if (Test-Path $tempPath) { Remove-Item $tempPath -Recurse | Out-Null; }

    Stop-SPAssignment -Global;
}