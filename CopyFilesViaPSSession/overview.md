## Copy Files via PS Session Task

### Details
This task copies all the files from a specific path using a Powershell Session on a remote server target path.  
Usefull for nontrusted domain or not shared servers.

### Requirements
1. Both ends must have WinRM 5.0.
2. Remote server must have Powershell Remoting enabled.

### Configuration
```
Source Path    (required) = A folder path or share.
Remote Machine (required) = The FQDN of the remote machine you want to reach (or the IP Address).
Admin Login    (required) = The administrator login account [domain\username] for the remote machine.
Admin Password (required) = The administrator password for the remote machine. I recommend a variable marked as secret.
Target Path    (required) = A local path on the remote server.
Exclude Types List        = A comma separated list of wildcard file types to exclude.
```

### Versions
0.1.7
Source Path parameter changed to path picker type.  
Exclude file types option added.  
Product image rebranding.  

0.1.0  
Initial versión on Visual Studio MarketPlace.  