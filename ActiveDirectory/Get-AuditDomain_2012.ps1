function Get-AuditDomain
{
<#
.Synopsis
   fetch ad domain data
.DESCRIPTION
   fetch Active Directory domain data
.EXAMPLE
   Get-AuditDomain -OutputLocation .\Desktop\ad_rep -Server domain.name
#>
    [CmdletBinding()]
    [Alias("GAD")]
    Param
    (
        # Server or domain to create ad audit report
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Server,

        # Server or domain to create ad audit report
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        $OutputLocation,

        # Server or domain to create ad audit report
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        $ReportGuid=(get-date -format yyyyMMdd),

        # Server or domain to create ad audit report
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=3)]
        $Time=(get-date -Format yyyyMMdd).toString(),

        [Parameter(Mandatory=$false,
                   Position=4)]
        [switch]
        $Recurse    
    )

    Begin
    {
        if (-not $(Test-Path $OutputLocation)) 
        {
        Write-Error "$OutputLocation not available"
        break
        }


        try 
        {
            write-host "$(get-date -format HH:mm:ss): Testing domain $server" -NoNewline
            $ADDomain = Get-ADDomain -Server $server -ErrorAction stop | select DNSroot,DomainMode
            Write-host " [Connected]" -ForegroundColor green
        }
        catch 
        {
            Write-host " [no connection]" -ForegroundColor red
            "`n`"$server`";`"$server`";`"local`";`"completed`"" | Out-File "$outputLocation\$reportGuid`_trust.csv" -Encoding UTF8 -Append
            break
        }
    }
    Process
    {
        
            $ADForest            = Get-ADForest -Server $server | select forestMode,domains,RootDomain,UPNSuffixes
            $ADTrusts            = Get-ADTrust  -Server $server -Filter * | select @{N='Source';E={$ADDomain.DNSroot}},@{N='Partner';E={$_.Name}},Direction,@{N='Completed';E={$false}}
            $ADDomainControllers = Get-ADDomainController -Server $server -Filter * | select hostname,domain,ipv4address,OperatingSystem      
            $IsRootDomain        = if ($ADDomain.DNSroot -eq $ADForest.rootDomain) {$true} else {$false}
            $ADpwdPolicy         = Get-ADDefaultDomainPasswordPolicy -Server $Server
            
            $DomainInfo = [PSCustomObject][Ordered]@{
                'Domain'            = $ADDomain.DNSroot
                'DomainMode'        = $ADDomain.DomainMode
                'IsRootDomain'      = $IsRootDomain
                'ForestRootDomain'  = $ADForest.RootDomain
                'ForestMode'        = $ADForest.forestMode
                'ForestDomains'     = $ADForest.domains -join ', '
                'UPNSuffixes'       = $ADForest.UPNSuffixes -join ', '
                #'Status'           = 'Ok'
                }


            #sites and subnet
                ## Get a list of all domain controllers in the forest
                $DcList = (Get-ADForest -server $server).Domains | ForEach { Get-ADDomainController -Discover -DomainName $_ } | ForEach { 
                        $dctest = $_.name
                        try
                        {
                        Get-ADDomainController -Server $dctest -filter *
                        }
                        catch
                        {
                        write-warning "no connection to $dctest"
                        }
                    }
                
                ## Get all replication subnets from Sites & Services
                $Subnets = Get-ADReplicationSubnet -filter * -Properties * -server $server | Select Name, Site, Location, Description
                
                ## Loop through all subnets and build the list
                $subnetsOut = Foreach ($Subnet in $Subnets) {
                
                    $SiteName = ""
                    If ($Subnet.Site -ne $null) { $SiteName = $Subnet.Site.Split(',')[0].Trim('CN=') }
                
                    $DcInSite = $False
                    If ($DcList.Site -Contains $SiteName) { $DcInSite = $True }
                
                    [PSCustomObject][ordered]@{
                        "Subnet"   = $Subnet.Name
                        "SiteName" = $SiteName
                        "DcInSite" = $DcInSite
                        "SiteLoc"  = $Subnet.Location
                        "SiteDesc" = $Subnet.Description
                    }
                }#foreach
            
            ## Export CSV files
                $DomainInfo                                 | Export-Csv "$outputLocation\$time`_$reportGuid`_$($ADDomain.DNSroot)`_1_DomainInfo.csv" -NoTypeInformation -Encoding UTF8 -Delimiter ';'
                $ADDomainControllers                        | Export-Csv "$outputLocation\$time`_$reportGuid`_$($ADDomain.DNSroot)`_2_DomainControllers.csv" -NoTypeInformation -Encoding UTF8 -Delimiter ';'
                $ADTrusts | select Source,Partner,Direction | Export-Csv "$outputLocation\$time`_$reportGuid`_$($ADDomain.DNSroot)`_3_trust.csv" -NoTypeInformation -Encoding UTF8 -Delimiter ';'
                $subnetsOut | Sort Subnet                   | Export-Csv "$outputLocation\$time`_$reportGuid`_$($ADDomain.DNSroot)`_4_sites_subnets.csv" -NoTypeInformation -Encoding UTF8 -Delimiter ';'
                $ADpwdPolicy                                | Export-Csv "$outputLocation\$time`_$reportGuid`_$($ADDomain.DNSroot)`_5_PasswordPolicy.csv" -NoTypeInformation -Encoding UTF8 -Delimiter ';'

                $ADTrusts                           | Export-Csv "$outputLocation\$reportGuid`_trust.csv" -NoTypeInformation -Encoding UTF8 -Delimiter ';' -Append
                "`"$($ADDomain.DNSroot)`";`"$($ADDomain.DNSroot)`";`"local`";`"completed`"" | Out-File   "$outputLocation\$reportGuid`_trust.csv" -Encoding UTF8 -Append
            
                Get-ChildItem "$outputLocation\$time`_$reportGuid`_$($ADDomain.DNSroot)*" | foreach {
            
                    Get-Content $_ | out-file "$outputLocation\$time`_$reportGuid`_$($ADDomain.DNSroot)`_Combined.csv" -Append -Encoding utf8
                    "" | out-file "$outputLocation\$time`_$reportGuid`_$($ADDomain.DNSroot)`_Combined.csv" -Append -Encoding utf8
            
                }

        if ($Recurse)
        {

        do
        {
            $Server = Import-Csv "$OutputLocation\$ReportGuid`_trust.csv" -Delimiter ';' | group-object partner | where {'completed' -notin $_.group.completed} | 
                            select -first 1 -expand group | select -ExpandProperty Partner | select -first 1

            $DomainsToGo = (Import-Csv "$OutputLocation\$ReportGuid`_trust.csv" -Delimiter ';' | group-object partner | where {'completed' -notin $_.group.completed}).count
            
            write-host "$(get-date -format HH:mm:ss): Domains to go $DomainsToGo"

            if( $server)
            {
                Get-AuditDomain -Server $Server -ReportGuid $ReportGuid -Time $Time -OutputLocation $OutputLocation -Recurse
            } #if ($server)
        
        } while ($Server)

        } #if ($recurse)
    }
    End
    {
    }
}
