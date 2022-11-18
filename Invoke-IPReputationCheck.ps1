function Invoke-IPReputationCheck
{
<#
.Synopsis
   Check IP address reputation from few sources.
.DESCRIPTION
   Function is checking IP reputation from VirusTotal, AbuseIPDB, AlienVault, Shodan.io and Maltiverse. 
   You need to pre make API keys and add them to the script under the comment apiKeys.
   There is not much error handling in this version.
.EXAMPLE
   Invoke-IPReputationCheck -IPaddress 8.8.8.8
.EXAMPLE
   Resolve-DnsName google.com | Invoke-IPReputationCheck
.EXAMPLE
   IPRC 8.8.8.8
#>


    [CmdletBinding()]
    [Alias("IPRC")]

    Param
    (
        # IP address to check
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ipaddress]$IPaddress
    )



function WL {write-host '=========================================='}

#apiKeys
$apiKeyVirusTotal = ''
$apiKeyAbuseIPDB  = ''
$apiKeyAlienVault = ''
$apiKeyShodanIO   = ''
$apiKeyMaltiverse = ''

    
#VirusTotal
$headerVT = @{'x-apikey'=$apiKeyVirusTotal}
$uriVT    = "https://www.virustotal.com/api/v3/ip_addresses/$IPaddress"

#Abuse.ch
$BodyABCH   = @{
                    'query'='search_ioc' 
                    'search_term'=$IPaddress
                   } | ConvertTo-Json
$uriABCH    = "https://threatfox-api.abuse.ch/api/v1/"


#AbuseIPDB
$uriAIPDB    = 'https://api.abuseipdb.com/api/v2/check'
$BodyAIPDB   = @{
                    "ipAddress"="$IPaddress"
                    "maxAgeInDays"="90"
                }

$headerAIPDB = @{
                    'Accept'='application/json'
                    'Key'= $apiKeyAbuseIPDB
                }


#AlienVault
$uriAlien    = "https://otx.alienvault.com/api/v1/indicators/IPv4/$IPaddress/general"
$headerAlien = @{
                'X-OTX-API-KEY'=$apiKeyAlienVault
                }


#Shodan.io
$uriShoda    = "https://api.shodan.io/shodan/host/$IPaddress"
$BodyShoda   = @{
                    "key"="$apiKeyShodanIO"
                }


#Maltiverse
$headerMalti = @{'Authorization'= "Bearer $apiKeyMaltiverse"}
$uriMalti    = "https://api.maltiverse.com/ip/$IPaddress"

WL
try {
    $responseVT = Invoke-RestMethod -Method Get -Headers $headerVT -Uri $uriVT
    write-host "VirusTotal`t`t`t`t" -NoNewline
    Write-Host "Success" -ForegroundColor green
} catch
{
    write-host "VirusTotal`t`t`t`t" -NoNewline
    Write-Host "Failed" -ForegroundColor Red
}
<#try {
    $responseABCH = Invoke-RestMethod -Method Post -Uri $uriABCH -Body $BodyABCH
    write-host "Abuse.ch`t" -NoNewline
    Write-Host "Success" -ForegroundColor green
} catch
{
    write-host "Abuse.ch`t" -NoNewline
    Write-Host "Failed" -ForegroundColor Red
} #>
try {
    $responseAIPDB = Invoke-RestMethod -Method Get -Headers $headerAIPDB -Uri $uriAIPDB -Body $BodyAIPDB -ContentType "application/x-www-form-urlencoded"
    write-host "AbuseIPDB`t`t`t`t" -NoNewline
    Write-Host "Success" -ForegroundColor green
} catch
{
    write-host "AbuseIPDB`t`t`t`t" -NoNewline
    Write-Host "Failed" -ForegroundColor Red
}
try {
$responseAlien = Invoke-RestMethod -Method Get -Headers $headerAlien -Uri $uriAlien
    write-host "AlienVault`t`t`t`t" -NoNewline
    Write-Host "Success" -ForegroundColor green
} catch
{
    write-host "AlienVault`t`t`t`t" -NoNewline
    Write-Host "Failed" -ForegroundColor Red
}
try {
$responseShoda = Invoke-RestMethod -Method Get -Uri $uriShoda -Body $BodyShoda -ContentType "application/x-www-form-urlencoded"
    write-host "Shodan.io`t`t`t`t" -NoNewline
    Write-Host "Success" -ForegroundColor green
} catch
{
    write-host "Shodan.io`t`t`t`t" -NoNewline
    Write-Host "Failed" -ForegroundColor Red
}
try {
$responseMalti = Invoke-RestMethod -Method Get -Headers $headerMalti -Uri $uriMalti
    write-host "Maltiverse`t`t`t`t" -NoNewline
    Write-Host "Success" -ForegroundColor green
} catch
{
    write-host "Maltiverse`t`t`t`t" -NoNewline
    Write-Host "Failed" -ForegroundColor Red
}
WL
Write-Host "
AbuseIPDB  - ISP:`t`t$($responseAIPDB.data.isp)
AbuseIPDB  - Type:`t`t$($responseAIPDB.data.usageType)
AbuseIPDB  - Hostname:`t$($responseAIPDB.data.hostnames)
AbuseIPDB  - Domain:`t$($responseAIPDB.data.domain)
AbuseIPDB  - Country:`t$($responseAIPDB.data.countryCode)
 
VirusTotal - AS owner:`t$($responseVT.data.attributes.as_owner)
VirusTotal - Country:`t$($responseVT.data.attributes.country)
 
Shodan     - ISP:`t`t$($responseShoda.isp)
Shodan     - ORG:`t`t$($responseShoda.org)
Shodan     - HostName:`t$($responseShoda.hostnames)
Shodan     - Country:`t$($responseShoda.country_code)

"
WL
Write-Host "
Shodan: 
-`tLast Update:`t`t$($responseShoda.last_update)
-`tOS:`t`t`t`t`t$($responseShoda.os)
-`tPorts:`t`t`t`t$($responseShoda.ports)
-`tHost:`t`t`t`t$($responseShoda.ip_str)

AbuseIPDB: 
-`tLast Update:`t`t$($responseAIPDB.data.lastReportedAt)
-`tTotal Reports:`t`t$($responseAIPDB.data.totalReports)
-`tConfidence Score:`t$($responseAIPDB.data.abuseConfidenceScore)

VirusTotal:
-`tLast Stats: 
`t`tMalicious:`t`t$($responseVT.data.attributes.last_analysis_stats.malicious)
`t`tSuspicious:`t`t$($responseVT.data.attributes.last_analysis_stats.suspicious)
`t`tHarmless:`t`t$($responseVT.data.attributes.last_analysis_stats.harmless)
`t`tUndetected:`t`t$($responseVT.data.attributes.last_analysis_stats.undetected)

Maltiverse: 
-`tLast Update:`t`t$($responseMalti.modification_time)
-`tClassification:`t`t$($responseMalti.classification)

"
WL
Write-Host "
AlienVault Pulse Names:
$(foreach ($listName in $responseAlien.pulse_info.pulses.name | group |select -expand name){"`n-`t$listName"}
)

"
WL

} # function
