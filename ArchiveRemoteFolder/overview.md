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
Admin Login (required) = The administrator login account [domain\username] for the remote machine.
Admin Password (required) = The administrator password for the remote machine. I recommend a variable marked as secret.
Source Path (required) = A local path on the remote server.
Target Path (required) = A local path on the remote server or a network share where the user has write permissions.
7z Filename (required) = A file name, with or without extension.
Date Stamp Format = A file name datetime format.
Retension Days = The archive folder retension in days.

## Versions
0.2.1
Powershell code cleanup.
7z.exe existence validation added.
Target folder retension days (cleanup) added.

0.1.9 
Initial versión on Visual Studio MarketPlace.