function log-timestamp($log){
    Write-Host "[" -ForegroundColor red -NoNewline
    Write-Host "$(get-date -format 'yyyy-MM-dd hh:mm:ss')" -ForegroundColor White -NoNewline
    Write-Host "]`t" -ForegroundColor red -NoNewline
    Write-Host $log -ForegroundColor White
}

#initialize environment
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$skippedFiles       = 0
$vuln4j2            = $false
$logFolder          = $env:TEMP
$log4Filter         = "*.jar"
$log4ss             = "log4j\d"
$targetManifestFile = "$logFolder\log4j-manifest.txt"

#find all jar files which contains log4j
log-timestamp -log "Searching $log4Filter files which include $log4ss"
$jarFiles   = Get-PSDrive | Where-Object { $_.Name.length -eq 1 } | Select-Object -ExpandProperty Root | Get-ChildItem -File -Recurse -Filter $log4Filter -ea 0  | foreach {select-string $log4ss $_} | select -ExpandProperty path | Group-Object | select -ExpandProperty name
log-timestamp -log "`tFound $($jarFiles.count)"

#loop through jar files and determine their status
$output = foreach ($jarFile in $jarFiles)
{
    #initialize lookup parameters
    $vulnerable = $false
    $jndiLookup = $false

    #check for jndilookup.class
    if ($jarFile | foreach {select-string "JndiLookup.class" $_}) 
        { 
        
            $jndiLookup = $true

        } #if ($jarfile)
     
     #unzip jar and search for manifest.mf                
     $zip = [System.IO.Compression.ZipFile]::OpenRead($jarFile)
     $zip.Entries | Where-Object { $_.FullName -eq 'META-INF/MANIFEST.MF' } | ForEach-Object {

        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($_, $targetManifestFile, $true)
        
        #find implementation version and determine vulnerability status
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

           #create psobject to output
           [PSCustomObject][ordered]@{
                  'FilePath'   = $jarFile
                  'Version'    = $implementationVersion
                  #'ModifyDate' = $modifyDate 
                  'JndiLookup' = $jndiLookup
                  'Vulnerable' = $vulnerable
                  }
        
        } catch
        {

         #skip files without implementation version
         $skippedFiles++
         #this output can be used to retrieve skipped file names
         #log-timestamp -log "ImplementationVersion not found in $jarFile"
         
        } # catch

     } #zipEntries

} #$output = foreach


##Formatting Output
log-timestamp -log "`tskipped files $skippedFiles"

if ($vuln4j2)
{
    #find java processes
    $java = get-process java*
    if($java)
    {
    log-timestamp -log "$($java.count) instance(s) of java running"
    }

} else
{
    log-timestamp -log "No log4j2 vulnerability found"
}  
      
$output
