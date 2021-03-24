#haetaan sisäänkirjautuneet käyttäjät edelliseltä 30 päivältä.
#haku tehdään sisäänkirjautumisen perusteella
$activeUsers = Get-EventLog System -Source Microsoft-Windows-WinLogon -After (Get-Date).AddDays(-30) |
    select @{N='User';E={(New-Object System.Security.Principal.SecurityIdentifier $_.ReplacementStrings[1]).Translate([System.Security.Principal.NTAccount])}},* |
        Group-Object ReplacementStrings | select *,@{N='time';E={$_.group[0].TimeGenerated}}


$localUserPaths = Get-WmiObject -class win32_userprofile -Filter "special='False'" | 
    select *,@{N='BaseName';E={$_.LocalPath.split('\')[-1]}},@{N='wmiFilterPath';E={$_.LocalPath.replace('\','\\')}}


#hypätään näiden tunnusten yli
$skipUsers = "järjestelmänvalvoja","administrator","hieti*"

$localUserPathsToRemove = foreach ($localUserPath in $localUserPaths)
{
    $skipProfile = $false

    foreach ($skipUser in $skipUsers)
    {
    
        if ($localUserPath.BaseName -like $skipUser) 
        {

        #write-host "skip $($localUserPath.BaseName)"
        $skipProfile = $true
        
        } # if ($localUserPath.BaseName -like $skipUser)
    
    } # foreach ($skipUser in $skipUsers)  

    if ($skipProfile -eq $false)
    {

        #write-host "Add $($localUserPath.BaseName)"
        $localUserPath

    } # if ($skipProfile -eq $false)

} # foreach ($localUserPath in $localUserPaths)

$activeSamids = $activeUsers.name | foreach {
    $_.split('\')[-1]
}

#deletointi kommentoitu ulos. Poista -Whatif ja # merkki, niin johan lähtee profiilit
$localUserPathsToRemove | foreach {

    if (-not ($_.basename -in $activeSamids)) {

        Get-WmiObject -class win32_userprofile -Filter "LocalPath='$($_.wmiFilterPath)'" | Remove-WmiObject -WhatIf #-confirm:0 -force

        }
}
