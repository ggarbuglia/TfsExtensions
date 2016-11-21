## Internet Information Server Actions Task

### Details
This task performs basic actions on remote IIS, Web Sites or Application Pools like Start, Stop, Restart and Recycle.

### Requirements
1. Remote server must have Powershell Remoting enabled.

### Configuration
```
Remote Machine (required) = The FQDN of the remote machine you want to reach (or the IP Address).
Admin Login    (required) = The administrator login account [domain\username] for the remote machine.
Admin Password (required) = The administrator password for the remote machine. I recommend a variable marked as secret.
Action         (required) = The action to perform on IIS.
Web Site(s)               = The comma separated list of web site(s) name(s) to perform the action.
App Pool(s)               = The comma separated list of application pool(s) name(s) to perform the action.  
```

### Versions
0.1.5  
Bug fixes.  

0.1.0  
Initial versión on Visual Studio MarketPlace.  