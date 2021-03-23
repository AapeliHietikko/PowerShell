$skipUsers = "järjestelmänvalvoja","toinenkayttaja"


$activeUsers = Get-EventLog System -Source Microsoft-Windows-WinLogon -After (Get-Date).AddDays(-30) |
    select @{N='User';E={(New-Object System.Security.Principal.SecurityIdentifier $_.ReplacementStrings[1]).Translate([System.Security.Principal.NTAccount])}},TimeGenerated |
        Group-Object user | select name,@{N='time';E={$_.group[0].TimeGenerated}}


$localUserPaths = Get-WmiObject -class win32_userprofile -Filter "special='False'" | 
    select *,@{N='BaseName';E={$_.LocalPath.split('\')[-1]}},@{N='wmiFilterPath';E={$_.LocalPath.replace('\','\\')}} | 
        where {$_.BaseName -notin $skipUsers}


$activeSamids = $activeUsers.name | foreach {
    $_.split('\')[-1]
}
$localUserPaths | foreach {

    if (-not ($_.basename -in $activeSamids)) {

        Get-WmiObject -class win32_userprofile -Filter "LocalPath='$($_.wmiFilterPath)'" | Remove-WmiObject -WhatIf #-confirm:0 -force

        }
}
