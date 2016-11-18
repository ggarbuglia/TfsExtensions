## Run SQL Server Scripts Task

### Details
This task creates a powershell session to your remote SQL Server using the provided server admin credentials.  
Then makes a copy of your scripts to a temporal folder on your remote server.  
Then invokes SQLPS module cmdlets to run the specified scripts. Scripts are executed ordered by name.  
Finally the remote temporal folder is removed.  

### Requirements
Your local server must have the Windows Management Framework 5.0 or more.  
Your remote server must have WinRM enabled and configured.

### Configuration
```
Source Folder  (required) = The local folder where you have your script(s).
SQL Server     (required) = The SQL Server name you want to reach.
SQL Instance   (required) = The SQL Server instance name you want to reach.
Admin Login    (required) = The administrator login account [domain\username] for the remote machine.
Admin Password (required) = The administrator password for the remote machine. I recommend a variable marked as secret.
Database       (required) = The database name you want to reach.
Database Username         = Username for the remote database. If blank, then the Admin Login will be used.
Database Password         = Password for the remote database. If blank, then the Admin Password will be used.
Wait (Seconds)            = The time in seconds between each script execution. Some times you need some space between executions to let the engine finish the script.
```

### Important!!!
In order to avoid Unicode mismatch characters always remember to save your script files with **UTF-8 signed encoding**.  

### Versions
0.1.7  
Source Folder parameter changed to path picker type.  
Product image rebranding. 

0.1.4  
Proper disposal of PSSession.  
Try..Catch..Finally on main process.  

0.1.1  
Extension manifest changed.  

0.1.0  
Initial versión on Visual Studio MarketPlace.  