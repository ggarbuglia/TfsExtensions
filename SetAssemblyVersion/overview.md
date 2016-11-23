## Set Assembly Version Task

### Details
This task finds all AssemblyInfo.* files on the given root path and replace the version on them.  
Also, if you use the SharedAssemblyInfo.* file on the root folder of your solution or elsewhere, you can make version changes there too. 

### Special Thanks
To [Miguel Ryll](https://www.linkedin.com/in/miguelryll) for the idea. 

### Patterns
```
AssemblyVersion:              [assembly: AssemblyVersion("x.x.x.x")]
AssemblyFileVersion:          [assembly: AssemblyFileVersion("x.x.x.x")]
AssemblyInformationalVersion: [assembly: AssemblyInformationalVersion("x.x aaaaa")]
``` 

### Configuration
```
Source Directory (required) = The build system source folder.
Mayor Number    = The assembly version mayor number. Leave it blank if you want to use current mayor number.
Minor Number    = The assembly version minor number. Leave it blank if you want to use current minor number.
Build Number    = The assembly version build number. Leave it blank if you want to use current build number.
Revision Number = The assembly version revision number. Leave it blank if you want to use current revision number.
Shared File     = Check if you use a SharedAssemblyInfo file in your project.
```

### Versions
0.1.8  
Bug fix. 

0.1.7  
Source Directory parameter changed to path picker type.  
Product image rebranding. 

0.1.0  
Initial versión on Visual Studio MarketPlace.  