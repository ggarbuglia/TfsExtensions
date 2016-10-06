# Archive Remote Folder Task

This task creates a powershell session to your remote server using the provided server admin credentials.
Then invokes 7z.exe to archive the content of specified folder.
Usefull for servers without shared folders.

See the [overview](https://github.com/ggarbuglia/TfsExtensions/blob/master/ArchiveRemoteFolder/overview.md) file for more detail.

# Run SQL Server Scripts Task

This task creates a powershell session to your remote SQL Server using the provided server admin credentials.
Then makes a copy of your scripts to a temporal folder on your remote server.
Then invokes SQLPS module cmdlets to run the specified scripts. Scripts are executed ordered by name.
Finally the remote temporal folder is removed.

See the [overview](https://github.com/ggarbuglia/TfsExtensions/blob/master/RunSqlServerScripts/overview.md) file for more detail.
