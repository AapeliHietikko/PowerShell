function Get-ShodanDB
{
    [CmdletBinding()]
    Param
    (
        # IP or hostname
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string[]]$destination
    )

    Begin
    {
        $baseURL = "https://internetdb.shodan.io"
    } #begin

    Process
    {
        foreach ($d in $destination)
        {
            try 
            {
                $a = [ipaddress]$d
                Invoke-RestMethod -Uri "$baseURL/$d"  | select @{N='destination';E={$d}}, *
            } #try
            catch
            {
                Resolve-DnsName $d | select -expand ipaddress | foreach {
                
                    Invoke-RestMethod -Uri "$baseURL/$_" | select @{N='destination';E={$d}}, *
                    
                } #foreach IPs
            }#catch
        }#foreach destination
    } #process
} #function
