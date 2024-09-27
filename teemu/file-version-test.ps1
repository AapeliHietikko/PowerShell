$exe = 'C:\temp\PsExec.exe'
$itam = get-item $exe
$haluttuversion = [version]'2.2'

switch ($itam.VersionInfo.FileVersion -ge $haluttuversion) 
{
($_ -gt $haluttuversion) {write-output "on paree"}
($_ -eq $haluttuversion) {write-output "on hyvvee"}
default {write-output "on paska"}
}
