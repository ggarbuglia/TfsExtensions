# Archive Remote Folder Task

## Details
This task creates a powershell session to your remote server using the provided server admin credentials.
Then invokes 7z.exe to archive the content of specified folder.
Usefull for servers without shared folders.

## Requirements
Your remote server must have WinRM enabled and configured.
Your remote server must have 7z installed.

## Configuration
Remote Machine (required) = The FQDN of the remote machine you want to reach.
Admin Login    (required) = The administrator login account [domain\username] for the remote machine.
Admin Password (required) = The administrator password for the remote machine. I recommend a variable marked as secret.
Source Path    (required) = A local path on the remote server.
Target Path    (required) = A local path on the remote server or a network share where the user has write permissions.
7z Filename    (required) = A file name, with or without extension.
Date Stamp Format         = A file name datetime format.
Retension Days            = The archive folder retension in days.

## Versions
0.2.2
Extension manifest changed.

0.2.1
Powershell code cleanup.
7z.exe existence validation added.
Target folder retension days (cleanup) added.

0.1.9 
Initial versión on Visual Studio MarketPlace.

# Run SQL Server Scripts Task

## Details
This task creates a powershell session to your remote SQL Server using the provided server admin credentials.
Then makes a copy of your scripts to a temporal folder on your remote server.
Then invokes SQLPS module cmdlets to run the specified scripts. Scripts are executed ordered by name.
Finally the remote temporal folder is removed.

## Requirements
Your remote server must have WinRM enabled and configured.
Your local server must have the SQLPS Powershell module, and for that follow this steps:

For SQL Server 2012
1. Navigate to https://www.microsoft.com/en-us/download/details.aspx?id=29065
2. Expand the Install Instructions section
3. Download both (x86 and x64) and install in the following order:
    a. Microsoft® System CLR Types for Microsoft® SQL Server® 2012 (SQLSysClrTypes.msi)
    b. Microsoft® SQL Server® 2012 Shared Management Objects (SharedManagementObjects.msi)
    c. Microsoft® Windows PowerShell Extensions for Microsoft® SQL Server® 2012 (PowerShellTools.msi)

## Configuration
Source Folder  (required) = The local folder where you have your script(s).
SQL Server     (required) = The SQL Server name you want to reach.
SQL Instance   (required) = The SQL Server instance name you want to reach.
Admin Login    (required) = The administrator login account [domain\username] for the remote machine.
Admin Password (required) = The administrator password for the remote machine. I recommend a variable marked as secret.
Database       (required) = The database name you want to reach.
Database Username         = Username for the remote database. If blank, then the Admin Login will be used.
Database Password         = Password for the remote database. If blank, then the Admin Password will be used.
Wait (Seconds)            = The time in seconds between each script execution. Some times you need some space between executions to let the engine finish the script.

## Versions
0.1.0 
Initial versión on Visual Studio MarketPlace.