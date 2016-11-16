## Archive Remote Folder Task

### Details
This task creates a powershell session to your remote server using the provided server admin credentials.  
Then invokes 7z.exe to archive the content of specified folder.  
Usefull for servers without shared folders.  

### Requirements
1. Your remote server must have WinRM enabled and configured.
2. Your remote server must have 7z installed.

### Configuration
```
Remote Machine (required) = The FQDN of the remote machine you want to reach.
Admin Login    (required) = The administrator login account [domain\username] for the remote machine.
Admin Password (required) = The administrator password for the remote machine. I recommend a variable marked as secret.
Source Path    (required) = A local path on the remote server.
Target Path    (required) = A local path on the remote server or a network share where the user has write permissions.
7z Filename    (required) = A file name, with or without extension.
Date Stamp Format         = A file name datetime format.
Retension Days            = The archive folder retension in days.
Exclude Types List        = A comma separated list of wildcard file types to exclude from archive.
```

### Versions
0.3.0  
Exclude file types option added.  
Product image rebranding.  

0.2.8  
Bug Fix: Subfolders where not included in 7z file. 

0.2.7  
Create the target folder path if doesn't exists.    

0.2.6  
Proper disposal of PSSession.  
Try..Catch..Finally on main process.  

0.2.3  
Extension manifest changed.  

0.2.1  
Powershell code cleanup.  
7z.exe existence validation added.  
Target folder retension days (cleanup) added.  

0.1.9  
Initial versión on Visual Studio MarketPlace.  