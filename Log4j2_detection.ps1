    Add-Type -AssemblyName System.IO.Compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    
    $vulnerable         = 0
    $logFolder          = $env:TEMP
    $log4Filter         = "log4j*.jar"
    $targetManifestFile = "$logFolder\log4j-manifest.txt"
    
    $jarFiles   = Get-PSDrive | Where-Object { $_.Name.length -eq 1 } | Select-Object -ExpandProperty Root | Get-ChildItem -File -Recurse -Filter $log4Filter -ea 0
    $Log4JFiles = $jarFiles | foreach {select-string "JndiLookup.class" $_} | select -ExpandProperty Path | Group-Object | select -expand name
        
    $output = foreach ($jarFile in $Log4JFiles)
    {
        $zip = [System.IO.Compression.ZipFile]::OpenRead($jarFile)
    
        $zip.Entries | Where-Object { $_.FullName -eq 'META-INF/MANIFEST.MF' } | ForEach-Object {
            [System.IO.Compression.ZipFileExtensions]::ExtractToFile($_, $targetManifestFile, $true)
            $implementationVersion = (Get-Content $targetManifestFile | Where-Object { $_ -like 'Implementation-Version: *' }).ToString()
            $modifyDate = (gci $targetManifestFile).LastWriteTime
    
            Remove-Item $targetManifestFile -ErrorAction SilentlyContinue
    
            $implementationVersion_ = [version]$implementationVersion.Replace('Implementation-Version: ', '')

            [PSCustomObject][ordered]@{
                'FilePath'   = $jarFile
                #'Version'    = $implementationVersion_
                #'ModifyDate' = $modifyDate 
                'JndiLookup' = $true
                }
            
            if ($implementationVersion_ -lt '2.16.0') {
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

    } else
    {
    "no log4j vulnerability found"
    }    

$output
#$jarFiles | select @{N='FilePath';e={$_.fullName}}, @{N='Version';e={""}}, @{N='ModifyDate';e={$_.LastWriteTime}}, @{N='JndiLookup';e={$false}}
 $jarFiles | select @{N='FilePath';e={$_.fullName}}, @{N='JndiLookup';e={$false}}
    
