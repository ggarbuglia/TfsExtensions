param (
    [string] $rootpath,
    [string] $mayornumber,
    [string] $minornumber,
    [string] $buildnumber,
    [string] $revisionnumber,
    [string] $checkforshared
)

Write-Host "Entering script task.ps1";

Write-Verbose "[rootpath]        --> [$rootpath]"       -Verbose;
Write-Verbose "[mayornumber]     --> [$mayornumber]"    -Verbose;
Write-Verbose "[minornumber]     --> [$minornumber]"    -Verbose;
Write-Verbose "[buildnumber]     --> [$buildnumber]"    -Verbose;
Write-Verbose "[revisionnumber]  --> [$revisionnumber]" -Verbose;
Write-Verbose "[checkforshared]  --> [$checkforshared]" -Verbose;

function MatchAndReplaceVersion([System.String]$content, [System.String]$type) { 

    $pattern = '\[assembly: '+ $type +'\("(.*)"\)\]';

    # Search for the pattern
    if ($content -match $pattern) { 

        # When you found the pattern set the new version
        $oldversion = [version]$matches[1];

        if ($mayornumber.TrimEnd() -eq "")    { $mayornumber    = $oldversion.Major.ToString(); }
        if ($minornumber.TrimEnd() -eq "")    { $minornumber    = $oldversion.Minor.ToString(); }
        if ($buildnumber.TrimEnd() -eq "")    { $buildnumber    = $oldversion.Build.ToString(); }
        if ($revisionnumber.TrimEnd() -eq "") { $revisionnumber = $oldversion.Revision.ToString(); }

        # Build the new version pattern
        $newversion = "{0}.{1}.{2}.{3}" -f $mayornumber, $minornumber, $buildnumber, $revisionnumber;

        # Output new line 
        $pattern = '[assembly: '+ $type +'("{0}")]';
        return $pattern -f $newversion;

    } else { 

        # Output line as is
        $content;

    }
}

function MatchAndReplaceInformationalVersion([System.String]$content, [System.String]$type) { 

    $pattern = '\[assembly: AssemblyInformationalVersion\("(.*) '+ $type +'"\)\]';

    # Search for the pattern
    if ($content -match $pattern) { 

        # When you found the pattern set the new version
        $oldversion = [version]$matches[1];

        if ($mayornumber.TrimEnd() -eq "") { $mayornumber = $oldversion.Major.ToString(); }
        if ($minornumber.TrimEnd() -eq "") { $minornumber = $oldversion.Minor.ToString(); }

        # Build the new version pattern
        $newversion = "{0}.{1}" -f $mayornumber, $minornumber;

        # Output new line 
        $pattern = '[assembly: AssemblyInformationalVersion("{0} '+ $type +'")]';
        return $pattern -f $newversion;

    } else { 

        # Output line as is
        $content;

    }
}

Try 
{ 
    if (-not $rootpath.EndsWith("\")) { $rootpath = "$rootpath\"; }

    if ([System.Convert]::ToBoolean($checkforshared) -eq $true) { 
        $filelist = @("AssemblyInfo.cs", "AssemblyInfo.vb", "SharedAssemblyInfo.cs", "SharedAssemblyInfo.vb"); 
    } else { 
        $filelist = @( "AssemblyInfo.cs", "AssemblyInfo.vb" ); 
    }
    
    # For each Assembly Information file...
    foreach ($file in $filelist) 
    { 
        # Get all Assembly Information files recursive and foreach file...
        Get-ChildItem -Path $rootpath -Recurse | where {$_.Name -eq $file} | foreach { 
            
            Write-Host "Processing file $($_.FullName)";

            # Get the content of the file and for each line...
            (Get-Content $_.FullName) | foreach { 

                $chk = MatchAndReplaceVersion -content $_ -type "AssemblyFileVersion"; 
                if ($_ -ne $chk) { return $chk; } 
                
                $chk = MatchAndReplaceVersion -content $_ -type "AssemblyVersion"; 
                if ($_ -ne $chk) { return $chk; } 

                $chk = MatchAndReplaceInformationalVersion -content $_ -type "Beta"; 
                if ($_ -ne $chk) { return $chk; } 

                $chk = MatchAndReplaceInformationalVersion -content $_ -type "Final"; 
                if ($_ -ne $chk) { return $chk; } 

                return "$_";

            } | Set-Content $_.FullName;
        }
    }
}
Catch 
{
    Write-Host;
    Write-Error $_;
}

Write-Host "Leaving script task.ps1";