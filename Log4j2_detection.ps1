function log-timestamp($log,$padding){
    Write-Host "[" -ForegroundColor red -NoNewline
    Write-Host "$(get-date -format 'yyyy-MM-dd hh:mm:ss')" -ForegroundColor White -NoNewline
    Write-Host "]`t" -ForegroundColor red -NoNewline
    Write-Host ("{0,$padding}" -f $log) -ForegroundColor White
}

    Add-Type -AssemblyName System.IO.Compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    
    $vuln4j2
    $logFolder          = $env:TEMP
    $log4Filter         = "log4j*.jar"
    $targetManifestFile = "$logFolder\log4j-manifest.txt"

    log-timestamp -padding 10 -log "Searching $log4Filter files"
    
    $jarFiles   = Get-PSDrive | Where-Object { $_.Name.length -eq 1 } | Select-Object -ExpandProperty Root | Get-ChildItem -File -Recurse -Filter $log4Filter -ea 0

    log-timestamp -padding 10 -log "Found $($jarFiles.count) jar files"

    $output = foreach ($jarFile in $jarFiles)
    {
        $vulnerable = $true
        $jndiLookup = $false

        if ($jarFile | foreach {select-string "JndiLookup.class" $_}) 
            { 
            
                $jndiLookup = $true

            } #if ($jarfile)
                        
         $zip = [System.IO.Compression.ZipFile]::OpenRead($jarFile.FullName)
         $zip.Entries | Where-Object { $_.FullName -eq 'META-INF/MANIFEST.MF' } | ForEach-Object {
         [System.IO.Compression.ZipFileExtensions]::ExtractToFile($_, $targetManifestFile, $true)
         $implementationVersion = [version]((Get-Content $targetManifestFile | Where-Object { $_ -like 'Implementation-Version: *' }).ToString().Replace('Implementation-Version: ', ''))
         $modifyDate = (Get-ChildItem $targetManifestFile).LastWriteTime
         
         Remove-Item $targetManifestFile -ErrorAction SilentlyContinue -Force       
         
         } #zipEntries

         
         if ($implementationVersion -lt '2.16.0') {

              $vulnerable = $true
         
            if ($implementationVersion.major -ge 2)
                {
                $vuln4j2 = $true
                }
         } #if implementation version
    

         [PSCustomObject][ordered]@{
                'FilePath'   = $jarFile.FullName
                'Version'    = $implementationVersion
                #'ModifyDate' = $modifyDate 
                'JndiLookup' = $jndiLookup
                'Vulnerable' = $vulnerable
                }
    
    } #foreach jarFiles

    if ($vuln4j2)
    {
        #find java processes
        $java = get-process java*
        if($java)
        {
        log-timestamp -padding 10 -log "$($java.count) instance(s) of java running"
        }

    } else
    {
    log-timestamp -padding 10 -log "no log4j2 vulnerability found"
    }    

$output
