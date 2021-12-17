<#
crippled version for 2k8r2, which you should not have anymore. ok?
#>

function log-timestamp($log){
    Write-Host "[" -ForegroundColor red -NoNewline
    Write-Host "$(get-date -format 'yyyy-MM-dd hh:mm:ss')" -ForegroundColor White -NoNewline
    Write-Host "]`t" -ForegroundColor red -NoNewline
    Write-Host "[" -ForegroundColor red -NoNewline
    Write-Host $env:COMPUTERNAME -ForegroundColor White -NoNewline
    Write-Host "]`t" -ForegroundColor red -NoNewline
    Write-Host $log -ForegroundColor White
}

#initialize environment

$skippedFiles       = 0
$vuln4j2            = $false
$logFolder          = $env:TEMP
$log4Filter         = "*.jar"
$log4ss             = "log4j\d"
$targetManifestFile = "$logFolder\log4j-manifest.txt"

#find all jar files which contains log4j
log-timestamp -log "Searching $log4Filter files which include $log4ss"
$jarFiles   = Get-PSDrive | Where-Object { $_.Name.length -eq 1 } | Select-Object -ExpandProperty Root | Get-ChildItem -Recurse -Filter $log4Filter -ea 0  | foreach {select-string $log4ss $_} | select -ExpandProperty path | Group-Object | select -ExpandProperty name
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
    "" | select @{N='FilePath';E={$jarFile}}, @{N='Version';E={$null}}, @{N='';E={$jndiLookup}}, @{N='';E={$null}} 

} #$output = foreach


##Formatting Output
log-timestamp -log "`tSkipped $skippedFiles"

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
