#haetaan sisäänkirjautuneet käyttäjät edelliseltä 30 päivältä.
#haku tehdään sisäänkirjautumisen perusteella
$activeUsers = Get-EventLog System -Source Microsoft-Windows-WinLogon -After (Get-Date).AddDays(-30) | Group-Object ReplacementStrings


$localUserPaths = Get-WmiObject -class win32_userprofile -Filter "special='False'" | 
    select *,@{N='BaseName';E={$_.LocalPath.split('\')[-1]}},@{N='wmiFilterPath';E={$_.LocalPath.replace('\','\\')}}


#hypätään näiden tunnusten yli
$skipUsers = "defaultuser1","administrator","hieti*"

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

#find Active user SIDs
$activeSIDs = $activeUsers.values | foreach {
    $_[-1]
} # $activeUsers.values | foreach

#deletointi kommentoitu ulos. Poista -Whatif ja # merkki, niin johan lähtee profiilit
$localUserPathsToRemove | foreach {

    if ($_.basename -notin $activeSIDs) {

        Get-WmiObject -class win32_userprofile -Filter "LocalPath='$($_.wmiFilterPath)'" | Remove-WmiObject -WhatIf #-confirm:0 -force

        } # if ($_.basename -notin $activeSIDs)
} # $localUserPathsToRemove | foreach
