

function Create-EventLogReport
{
<#
.Synopsis
   This function will create report out of given event log entries.
.DESCRIPTION
   This function will create report out of given event log entries. It will dig a bit deeper than the default Get-WinEvent, but is based on that command.
   By default it will try to find events 4625 from security log.
.EXAMPLE
   Create-EventLogReport 
.EXAMPLE
   Create-EventLogReport -LogName application -id 5617,4625
#>

    [CmdletBinding()]
    Param
    (
        # EventLog name. Security as default
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [String]
        $LogName='security',

        # Event Log ID's. 4625 as default
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [int[]]
        $ID=4625,

        # output folder name. get-location as default
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        [String]
        $Output = $(Get-Location).Path,

        # output only to console
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=3)]
        [switch]
        $Console

    )

    Begin
    {
        
        #test for Get-WinEvent command. Exit if not found.

        $gcgw = Get-Command Get-WinEvent
        if (-not $gcgw) {

            Write-Warning "No Get-WinEvent command found."
            Exit

        } #if (-not $gcgw)

        #Populate  xml filter
        
        $filterHashTable = @{
            'LogName'  = $LogName
            'ID'= $ID
        }

        #Date
        $date = get-date -Format yyyyMMdd-hhmmss

    }
    Process
    {

        $events = foreach ($event in $(Get-WinEvent -FilterHashtable $filterHashTable)) {
    
            $eventData = $event.ToXml() -as 'xml'
            foreach ($dataEntry in $eventData.event.EventData.data) {
                
                $event | Add-Member -MemberType NoteProperty -Name "MD_$($dataEntry.Name)" -Value $dataEntry.'#text' -Force
            
            } # foreach ($dataEntry in $eventData.event.EventData.data)

            $event

        } # $events

    }
    End
    {
        
        if(-not $console) {

            $events | select MachineName, LogName, Id, TimeCreated, MD_SubjectDomainName, MD_SubjectUserName, MD_IpAddress | 
                export-csv "$Output\$date-EventLogReport.csv" -NTI -Delimiter ';'
            "Report written to $Output\$date-EventLogReport.csv"
        }
        else {
         $events
        }

    }
}
