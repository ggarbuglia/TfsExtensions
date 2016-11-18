## Publish To SharePoint Task

### Details
This task creates a powershell session to your remote SharePoint Server using the provided server admin credentials.  
Then makes a copy of your file(s) to a temporal folder on your remote server.  
Then invokes SharePoint Powershell module cmdlets to upload the file(s) impersonating some user.  
Finally the remote temporal folder is removed.  

### Requirements
1. Your remote server must have WinRM enabled and configured.
2. Your local server must have the Windows Management Framework 5.0 or more.
3. You must setup Credential Security Support Provider (CredSSP) authentication on both servers. 

See the [How to Enable Remote PowerShell for SharePoint 2013](https://github.com/ggarbuglia/TfsExtensions/blob/master/PublishToSharePoint/HowToEnableRemotePowerShellSharePoint2013.txt) file for more detail.  

### Configuration
```
Source Folder     (required) = The local folder where you have your script(s).
SharePoint Server (required) = The FQDN of the SharePoint server you want to reach.
Admin Login       (required) = The administrator login account [domain\username] for the remote machine.
Admin Password    (required) = The administrator password for the remote machine. I recommend a variable marked as secret.
Site Url          (required) = The SharePoint Site Collection Url you want to reach (like 'http://sharepoint').
Web Relative Path (required) = The SharePoint Web relative path you want to reach (like '/web1/web2').
User Account      (required) = The user account [domain\username] to impersonate file upload.
Library Name      (required) = The SharePoint Document Library name.
Folder Path                  = The folder or folder path inside your Document Library (like 'level1/level2').
Auto Create Folder           = If your folder definition does not exists I will create it for you.
Exclude Types List           = A comma separated list of wildcard file types to exclude.
```

### Versions
0.1.7  
Source Folder parameter changed to path picker type.  
Exclude file types option added.  
Product image rebranding.  

0.1.1  
Overview updated.  

0.1.0  
Initial versión on Visual Studio MarketPlace.  