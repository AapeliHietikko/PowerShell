#   _____                       .__  .__ 
#  /  _  \ _____  ______   ____ |  | |__|
# /  /_\  \\__  \ \____ \_/ __ \|  | |  |
#/    |    \/ __ \|  |_> >  ___/|  |_|  |
#\____|__  (____  /   __/ \___  >____/__|
#        \/     \/|__|        \/         
#     saved the day on date 2020-06-30
#          use at your own risk        
#########################################

<#
create test file if needed
notepad C:\temp\hosts.txt
#>

$hosti = "C:\temp\hosts.txt"
$hosto = "C:\temp\hosts_out.txt"

$hosts = get-content $hosti -Encoding ascii

$output = foreach ($row in $hosts){

    if($row -notlike "#*" -and $row -match "blaa.blaa.bla") {"#$row"}
    else {$row}

} 
$output | Out-File $hosto -Encoding ascii


<#
 Foreach {if ($_ -match '^\s*([^#].*?\d{1,3}.*?oili.*)')
                  {"# " + $matches[1]} else {$_}} |
         Out-File $hosto -enc ascii
#>

cls
Write-Output "input file:`n"
get-content $hosti -Encoding Ascii

Write-Output "`noutput file:`n"
get-content $hosto -Encoding Ascii
