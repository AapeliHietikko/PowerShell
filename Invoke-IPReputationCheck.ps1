function Invoke-IPReputationCheck
{
    [CmdletBinding()]
    [Alias("IPRC")]

    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ipaddress]$IP
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
$uriVT    = "https://www.virustotal.com/api/v3/ip_addresses/$ip"

#Abuse.ch
$BodyABCH   = @{
                    'query'='search_ioc' 
                    'search_term'=$ip
                   } | ConvertTo-Json
$uriABCH    = "https://threatfox-api.abuse.ch/api/v1/"


#AbuseIPDB
$uriAIPDB    = 'https://api.abuseipdb.com/api/v2/check'
$BodyAIPDB   = @{
                    "ipAddress"="$ip"
                    "maxAgeInDays"="90"
                }

$headerAIPDB = @{
                    'Accept'='application/json'
                    'Key'= $apiKeyAbuseIPDB
                }


#AlienVault
$uriAlien    = "https://otx.alienvault.com/api/v1/indicators/IPv4/$ip/general"
$headerAlien = @{
                'X-OTX-API-KEY'=$apiKeyAlienVault
                }


#Shodan.io
$uriShoda    = "https://api.shodan.io/shodan/host/$ip"
$BodyShoda   = @{
                    "key"="$apiKeyShodanIO"
                }


#Maltiverse
$headerMalti = @{'Authorization'= "Bearer $apiKeyMaltiverse"}
$uriMalti    = "https://api.maltiverse.com/ip/$ip"

WL
try {
    $responseVT = Invoke-RestMethod -Method Get -Headers $headerVT -Uri $uriVT
    write-host "VirusTotal`t" -NoNewline
    Write-Host "Success" -ForegroundColor green
} catch
{
    write-host "VirusTotal`t" -NoNewline
    Write-Host "Failed" -ForegroundColor Red
}
try {
    $responseABCH = Invoke-RestMethod -Method Post -Uri $uriABCH -Body $BodyABCH
    write-host "Abuse.ch`t" -NoNewline
    Write-Host "Success" -ForegroundColor green
} catch
{
    write-host "Abuse.ch`t" -NoNewline
    Write-Host "Failed" -ForegroundColor Red
}
try {
    $responseAIPDB = Invoke-RestMethod -Method Get -Headers $headerAIPDB -Uri $uriAIPDB -Body $BodyAIPDB -ContentType "application/x-www-form-urlencoded"
    write-host "AbuseIPDB`t" -NoNewline
    Write-Host "Success" -ForegroundColor green
} catch
{
    write-host "AbuseIPDB`t" -NoNewline
    Write-Host "Failed" -ForegroundColor Red
}
try {
$responseAlien = Invoke-RestMethod -Method Get -Headers $headerAlien -Uri $uriAlien
    write-host "AlienVault`t" -NoNewline
    Write-Host "Success" -ForegroundColor green
} catch
{
    write-host "AlienVault`t" -NoNewline
    Write-Host "Failed" -ForegroundColor Red
}
try {
$responseShoda = Invoke-RestMethod -Method Get -Uri $uriShoda -Body $BodyShoda -ContentType "application/x-www-form-urlencoded"
    write-host "Shodan.io`t" -NoNewline
    Write-Host "Success" -ForegroundColor green
} catch
{
    write-host "Shodan.io`t" -NoNewline
    Write-Host "Failed" -ForegroundColor Red
}
try {
$responseMalti = Invoke-RestMethod -Method Get -Headers $headerMalti -Uri $uriMalti
    write-host "Maltiverse`t" -NoNewline
    Write-Host "Success" -ForegroundColor green
} catch
{
    write-host "Maltiverse`t" -NoNewline
    Write-Host "Failed" -ForegroundColor Red
}
WL
Write-Host "
AbuseIPDB: ISP:       $($responseAIPDB.data.isp)
AbuseIPDB: Type:      $($responseAIPDB.data.usageType)
AbuseIPDB: Hostname:  $($responseAIPDB.data.hostnames)
AbuseIPDB: Domain:    $($responseAIPDB.data.domain)
AbuseIPDB: Country:   $($responseAIPDB.data.countryCode)
 
VirusTotal: AS owner: $($responseVT.data.attributes.as_owner)
VirusTotal: Country:  $($responseVT.data.attributes.country)
 
Shodan: ISP:          $($responseShoda.isp)
Shodan: ORG:          $($responseShoda.org)
Shodan: HostName:     $($responseShoda.hostnames)
Shodan: Country:      $($responseShoda.country_code)
"
WL
Write-Host ""
WL
Write-Host "
Shodan: Last Update: $($responseShoda.last_update)
 -`tOS:`t`t`t$($responseShoda.os)
 -`tPorts:`t`t$($responseShoda.ports)
 -`tHost:`t`t$($responseShoda.ip_str)

AbuseIPDB: $($responseAIPDB.data.lastReportedAt)
-`tTotal Reports:`t`t$($responseAIPDB.data.totalReports)
-`tConfidence Score:`t$($responseAIPDB.data.abuseConfidenceScore)

VirusTotal:
-`tLast Stats: 
`t`tMalicious:  $($responseVT.data.attributes.last_analysis_stats.malicious)
`t`tSuspicious: $($responseVT.data.attributes.last_analysis_stats.suspicious)
`t`tHarmless:   $($responseVT.data.attributes.last_analysis_stats.harmless)
`t`tUndetected: $($responseVT.data.attributes.last_analysis_stats.undetected)

Maltiverse: Last Update: $($responseMalti.modification_time)
-`tClassification:`t$($responseMalti.classification)

"
WL
Write-Host "
AlienVault Pulse Names:
$(foreach ($listName in $responseAlien.pulse_info.pulses.name | group |select -expand name){"`n-`t$listName"}
)
"


} # function
