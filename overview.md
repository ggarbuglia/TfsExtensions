## Archive Remote Folder Task

This task creates a powershell session to your remote server using the provided server admin credentials.  
Then invokes 7z.exe to archive the content of specified folder.  
Usefull for servers without shared folders.  

See the [overview](https://github.com/ggarbuglia/TfsExtensions/blob/master/ArchiveRemoteFolder/overview.md) file for more detail.  

## Run SQL Server Scripts Task

This task creates a powershell session to your remote SQL Server using the provided server admin credentials.  
Then makes a copy of your scripts to a temporal folder on your remote server.  
Then invokes SQLPS module cmdlets to run the specified scripts. Scripts are executed ordered by name.  
Finally the remote temporal folder is removed.  

See the [overview](https://github.com/ggarbuglia/TfsExtensions/blob/master/RunSqlServerScripts/overview.md) file for more detail.  

## Publish To SharePoint Task

This task creates a powershell session to your remote SharePoint Server using the provided server admin credentials.  
Then makes a copy of your file(s) to a temporal folder on your remote server.  
Then invokes SharePoint Powershell module cmdlets to upload the file(s) impersonating some user.  
Finally the remote temporal folder is removed.  

See the [overview](https://github.com/ggarbuglia/TfsExtensions/blob/master/PublishToSharePoint/overview.md) file for more detail.

## Set Assembly Version Task

This task finds all AssemblyInfo files on the given root path and replace the version on them.  
Also, if you use the SharedAssemblyInfo file on the root folder of your solution or elsewhere, you can make version changes there too.  

## Copy Files via PS Session Task

This task copies all the files from a specific path using a Powershell Session on a remote server target path.  
Usefull for nontrusted domain or not shared servers.