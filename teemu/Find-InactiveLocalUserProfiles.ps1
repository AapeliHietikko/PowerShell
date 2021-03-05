$activeUsers = Get-EventLog System -Source Microsoft-Windows-WinLogon -After (Get-Date).AddDays(-30) |
    select @{N='User';E={(New-Object System.Security.Principal.SecurityIdentifier $_.ReplacementStrings[1]).Translate([System.Security.Principal.NTAccount])}},TimeGenerated |
        Group-Object user | select name,@{N='time';E={$_.group[0].TimeGenerated}}

$localUserPaths = get-wmiobject win32_userprofile -Filter "special='False'" | select @{N='BaseName';E={$_.LocalPath.split('\')[-1]}}

$activeSamids = $activeUsers.name | foreach {
    $_.split('\')[-1]
}
$localUserPaths.basename | foreach {

    #$_
    if (-not ($_ -in $activeSamids)) {

        $_

        }
}
