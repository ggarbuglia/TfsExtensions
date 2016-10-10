# Run SQL Server Scripts Task

## Details
This task creates a powershell session to your remote SQL Server using the provided server admin credentials.
Then makes a copy of your scripts to a temporal folder on your remote server. 
Then invokes SQLPS module cmdlets to run the specified scripts. Scripts are executed ordered by name.
Finally the remote temporal folder is removed.

## Requirements
```
Your remote server must have WinRM enabled and configured.
Your local server must have the Windows Management Framework 5.0 or more.
Your local server must have the SQLPS Powershell module, and for that follow this steps:

For SQL Server 2012
1. Navigate to https://www.microsoft.com/en-us/download/details.aspx?id=29065
2. Expand the Install Instructions section
3. Download both (x86 and x64) and install in the following order:
    a. Microsoft® System CLR Types for Microsoft® SQL Server® 2012 (SQLSysClrTypes.msi)
    b. Microsoft® SQL Server® 2012 Shared Management Objects (SharedManagementObjects.msi)
    c. Microsoft® Windows PowerShell Extensions for Microsoft® SQL Server® 2012 (PowerShellTools.msi)
```

## Configuration
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

## Versions
0.1.2
Proper disposal of PSSession.
Try..Catch..Finally on main process.

0.1.1
Extension manifest changed.

0.1.0 
Initial versión on Visual Studio MarketPlace.