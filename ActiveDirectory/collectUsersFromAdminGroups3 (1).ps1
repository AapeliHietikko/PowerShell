break
#break if for ensuring F5 full run


# select following functions (rows 8 to 184
# Run selection (F8)

function Get-Object {
    [CmdletBinding()]

    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        $object,
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        $server = "$((Get-ADDomain).dnsRoot)"
    )

    Begin {
        $root = (Get-ADForest -Server $server).rootDomain
    }

    Process {

    $object | ForEach {
            if ($_.ObjectClass -eq 'user') {

            if (-not($_.server)) {Add-Member -InputObject $_ -Name server -Value $server -MemberType NoteProperty -Force}
        
            Get-ADUser -Identity $_.objectGUID -Server $_.server -Properties name, whencreated, whenChanged, accountExpirationDate, description, displayname, lastlogondate, passwordExpired, sidhistory, PasswordLastSet, memberOf, ObjectGUID, PasswordNeverExpires, department, company, co, extensionAttribute14, extensionAttribute7 | ForEach {

                [PSCustomObject][Ordered]@{
                    group = $null
                    distinguishedName = $_.distinguishedName
                    ObjectGUID = $_.ObjectGUID
                    ObjectClass = 'user'
                    samAccountName = $_.samaccountname
                    userPrincipalName = $_.userPrincipalname
                    name = $_.name
                    enabled = $_.enabled
                    displayName = $_.displayName
                    description = $_.description
                    department = $_.department
                    company = $_.company
                    co = $_.co
                    accountExpirationDate = $_.accountExpirationDate
                    lastLogonDate = $_.lastlogondate
                    passwordExpired = $_.passwordExpired
                    passwordLastSet = $_.PasswordLastSet
                    PasswordNeverExpires = $_.PasswordNeverExpires
                    whenCreated = $_.whencreated
                    whenChanged = $_.whenChanged
                    sidHistory = $_.sidHistory
                    extAttr14 = $_.extensionAttribute14
                    extAttr7 = $_.extensionAttribute7
                    memberOf = $_.memberof -join ', '
                } #psCustomObject
            } #forEach
        
        } #if ($_.ObjectClass -eq 'user')

        if ($_.ObjectClass -eq 'group') {
        
            $g2 = $_.objectGUID
            $groupDeterm = Try {
                (Get-ADGroup -Identity $g2 -Server $server -Properties members).members 
            } Catch {
                (Get-ADGroup -Identity $g2 -Server $root -Properties members).members 
            }

            $groupDeterm | ForEach {

                $g = $_
                Try {
                    Get-ADObject -Identity $g -Server $server -ErrorAction Stop | ForEach {Get-Object -object $_ -server $server}
                } Catch {

                    Try {
                    Get-ADObject -Identity $g -Server $root -ErrorAction Stop | ForEach {Get-Object -object $_ -server $root}
                    } Catch {
                    Write-Warning "$($server): $g no connection to root domain: $root"
                    }
                }

                #clv g

            } #forEach 
        } #if ($_.ObjectClass -eq 'group')

        if ($_.objectClass -eq 'foreignSecurityPrincipal') {
        
                [PSCustomObject][Ordered]@{
                    group = $null
                    distinguishedName = $_.distinguishedName
                    ObjectGUID = $_.ObjectGUID
                    ObjectClass = 'foreignSecurityPrincipal'
                    samAccountName = $null
                    userPrincipalName = $null
                    name = $_.name
                    enabled = $null
                    displayName = $null
                    description = $null
                    department = $null
                    company = $null
                    co = $null
                    accountExpirationDate = $null
                    lastLogonDate = $null
                    passwordExpired = $null
                    passwordLastSet = $null
                    PasswordNeverExpires = $null
                    whenCreated = $null
                    whenChanged = $null
                    sidHistory = $null
                    memberOf = $null
                } #psCustomObject

        }


    } #forEach
    } #process

    End {}
}

function Get-Admin {
    [CmdletBinding()]

    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        $group,
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        $server = "$((Get-ADDomain).dnsRoot)"
    )

    Begin {
        $root = (Get-ADForest -Server $server).rootDomain
    }

    Process {
    
        Try {
            (Get-ADGroup -Identity $group -Server $server -Properties members -ErrorAction Stop).members | ForEach {
        
            $g = $_
            Try {
                Get-ADObject -Identity $g -Server $server -ErrorAction Stop | select *,@{n='server';e={$server}}
            } Catch {
                Try {
                Get-ADObject -Identity $g -Server $root -ErrorAction Stop | select *,@{n='server';e={$root}}
                } Catch {
                    Write-Warning "$($server): no connection to root domain: $root"
                    }
            }        
        } #forEach
        } Catch {
            (Get-ADGroup -Identity $group -Properties members -Server $root -ErrorAction Stop).members | ForEach {
        
            $g = $_
            Try {
                Get-ADObject -Identity $g -Server $server -ErrorAction Stop | select *,@{n='server';e={$server}}
            } Catch {
                Try {
                Get-ADObject -Identity $g -Server $root -ErrorAction Stop | select *,@{n='server';e={$root}}
                } Catch {
                    Write-Warning "$($server): no connection to root domain: $root"
                    }
            }        
        } #forEach        
        }
    
    } #process

    End {}
}


# type the domain name below

#selected server
$srv = 'domain name'


# run this and it will create the csv files
# select rows 189 to 207
# Run selection (F8)

$adminList = 'Account operators','Administrators','Backup Operators','DnsAdmins','Domain Admins','Enterprise Admins','Enterprise Key Admins','Group Policy Creator Owners','Key Admins','Network Configuration Operators','Schema Admins','Server Operators'
$adminList | ForEach {

    $searchGroup = $_
    $aAdmins = Get-Admin -group $searchGroup -server $srv

    if ($aAdmins) {
        $aAdmins | export-csv -Path "$($HOME)\$($srv)$(get-date -Format yyyyMMdd-hhmmss)-$($searchGroup -replace ' ','')GroupObjects.csv" -Delimiter ';' -NoTypeInformation -Encoding UTF8
        Get-Object -object $aAdmins -server $srv | export-csv -Path "$($HOME)\$($srv)$(get-date -Format yyyyMMdd-hhmmss)-$($searchGroup -replace ' ','')GroupUsers.csv" -Delimiter ';' -NoTypeInformation  -Encoding UTF8
    }
}







# if you want numbers run this

$UserQuery = get-aduser -Filter * -Properties PasswordLastSet, PasswordNeverExpires, PasswordNotRequired, LastLogonDate

[PSCustomObject][Ordered]@{
    UserAccounts = $UserQuery.count
    Enabled = ($UserQuery | where {$_.enabled -eq $true}).count
    Disabled = ($UserQuery | where {$_.enabled -eq $false}).count
    LastLogonDate90d = ($UserQuery | where {$_.lastLogonDate -le $((get-date).AddDays(-90))}).count
    LastLogonDate180d = ($UserQuery | where {$_.lastLogonDate -le $((get-date).AddDays(-180))}).count
    PasswordNeverExpires = ($UserQuery | where {$_.passwordNeverExpires -eq $true}).count
    PasswordExpired = ($UserQuery | where {$_.enabled -eq $false}).count
    PasswordOlderThan2y = ($UserQuery | where {$_.PasswordLastSet -le $((get-date).AddDays(-730))}).count
    PasswordOlderThan1y = ($UserQuery | where {$_.PasswordLastSet -le $((get-date).AddDays(-365))}).count
    PasswordOlderThan180d = ($UserQuery | where {$_.PasswordLastSet -le $((get-date).AddDays(-180))}).count
    PasswordNotRequired =($UserQuery | where {$_.PasswordNotRequired -eq $true}).count
}





