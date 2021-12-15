function log-timestamp($log,$padding){
    Write-Host "[" -ForegroundColor red -NoNewline
    Write-Host "$(get-date -format 'yyyy-MM-dd hh:mm:ss')" -ForegroundColor White -NoNewline
    Write-Host "]`t" -ForegroundColor red -NoNewline
    Write-Host ("{0,$padding}" -f $log) -ForegroundColor White
}

    Add-Type -AssemblyName System.IO.Compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    
    $skippedFiles       = 0
    $vuln4j2            = $false
    $logFolder          = $env:TEMP
    $log4Filter         = "*.jar"
    $targetManifestFile = "$logFolder\log4j-manifest.txt"

    log-timestamp -padding 10 -log "Searching $log4Filter files"
    
    $jarFiles   = Get-PSDrive | Where-Object { $_.Name.length -eq 1 } | Select-Object -ExpandProperty Root | Get-ChildItem -File -Recurse -Filter $log4Filter -ea 0  | foreach {select-string "log4j" $_} | select -ExpandProperty path | Group-Object | select -ExpandProperty name

    log-timestamp -padding 10 -log "Found $($jarFiles.count) $log4Filter files"

    $output = foreach ($jarFile in $jarFiles)
    {
        $vulnerable = $false
        $jndiLookup = $false

        if ($jarFile | foreach {select-string "JndiLookup.class" $_}) 
            { 
            
                $jndiLookup = $true

            } #if ($jarfile)
                        
         $zip = [System.IO.Compression.ZipFile]::OpenRead($jarFile)
         $zip.Entries | Where-Object { $_.FullName -eq 'META-INF/MANIFEST.MF' } | ForEach-Object {
            [System.IO.Compression.ZipFileExtensions]::ExtractToFile($_, $targetManifestFile, $true)
            try 
            {
            
               $implementationVersion = [version]((Get-Content $targetManifestFile | Where-Object { $_ -like 'Implementation-Version: *' }).ToString().Replace('Implementation-Version: ', ''))
            
            
               $modifyDate = (Get-ChildItem $targetManifestFile).LastWriteTime
               
               Remove-Item $targetManifestFile -ErrorAction SilentlyContinue -Force       
               
              
               if ($implementationVersion -lt '2.16.0') {

                    $vulnerable = $true
               
                  if ($implementationVersion.major -ge 2)
                      {
                      $vuln4j2 = $true
                      }
               } #if implementation version
    

               [PSCustomObject][ordered]@{
                      'FilePath'   = $jarFile
                      'Version'    = $implementationVersion
                      #'ModifyDate' = $modifyDate 
                      'JndiLookup' = $jndiLookup
                      'Vulnerable' = $vulnerable
                      }
            
            } #try
            catch
            {
             $skippedFiles++
             #log-timestamp -padding 10 -log "ImplementationVersion not found in $($jarFile.FullName)"
            } # catch

         } #zipEntries
    
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
log-timestamp -padding 10 -log "skipped files $skippedFiles"
$output
