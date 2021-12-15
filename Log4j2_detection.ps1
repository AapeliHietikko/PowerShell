    <#
    based on this one, I think. Got the original code through teams chat
    https://github.com/sp4ir/incidentresponse/blob/main/Get-Log4shellVuln.ps1
    #>
    
    
    Add-Type -AssemblyName System.IO.Compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    
    $vulnerable         = 0
    $logFolder          = $env:TEMP
    $log4Filter         = "log4j*.jar"
    $targetManifestFile = "$logFolder\log4j-manifest.txt"
    
    $jarFiles   = Get-PSDrive | Where-Object { $_.Name.length -eq 1 } | Select-Object -ExpandProperty Root | Get-ChildItem -File -Recurse -Filter $log4Filter -ea 0 | foreach {select-string "JndiLookup.class" $_} | select -ExpandProperty Path | Group-Object | select -expand name
    
    $output = foreach ($jarFile in $jarFiles)
    {
        $zip = [System.IO.Compression.ZipFile]::OpenRead($jarFile)
    
        $zip.Entries | Where-Object { $_.FullName -eq 'META-INF/MANIFEST.MF' } | ForEach-Object {
            [System.IO.Compression.ZipFileExtensions]::ExtractToFile($_, $targetManifestFile, $true)
            $implementationVersion = (Get-Content $targetManifestFile | Where-Object { $_ -like 'Implementation-Version: *' }).ToString()
            $modifyDate = (gci $targetManifestFile).LastWriteTime
    
            Remove-Item $targetManifestFile -ErrorAction SilentlyContinue
    
            $implementationVersion_ = [version]$implementationVersion.Replace('Implementation-Version: ', '')
            if ($implementationVersion_ -lt '2.16.0') {
                [PSCustomObject][ordered]@{
                    'FilePath'   = $jarFile
                    'Version'    = $implementationVersion_
                    'ModifyDate' = $modifyDate 
                    }
                 $vulnerable = 1
            } #if implementation version
    
        } #zipentries
    
    } #foreach jarFiles

    if ($vulnerable)
    {
        #find java processes
        $java = get-process java*
        if($java)
        {
        "$($java.count) instance(s) of java running"
        }
        
        $output
    } else
    {
    "no log4j vulnerability found"
    }
