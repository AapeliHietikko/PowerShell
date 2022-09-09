function Get-RemoteWUAHistory
{
<#
.Synopsis
   Get windows update hotfix data remotely
.DESCRIPTION
   Get windows update hotfix data remotely. This will parse the data from three different methods using get-hotfix and two ways of gwmi.
   Some of the functions are copied from https://www.thewindowsclub.com/check-windows-update-history-using-powershell
.EXAMPLE
   get-RemoteWUAHistory -computername server1
.EXAMPLE
   get-RemoteWUAHistory -computername server1,server2
#>


    [CmdletBinding()]
    Param
    (
        # ComputerName or names
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string[]]
        $ComputerName
    )

    Begin
    {

        $block = {

            function Convert-WuaResultCodeToName
            {
                param(
                    [Parameter(Mandatory=$true)]
                    [int] $ResultCode
                )
            
                $Result = $ResultCode
                switch($ResultCode)
                {
                  0 {
                    $Result = "NotStarted"
                  }
                  1 {
                    $Result = "InProgress"
                  }
                  2 {
                    $Result = "Succeeded"
                  }
                  3 {
                    $Result = "Succeeded With Errors"
                  }
                  4 {
                    $Result = "Failed"
                    }
                  5 {
                    $Result = "Aborted"
                  }
                }
            
                return $Result
            
            } # Convert-WuaResultCodeToName
            
            
            function Get-WuaHistory
            {
                $session = (New-Object -ComObject 'Microsoft.Update.Session')

                $session.QueryHistory("",0,95000) | where {![String]::IsNullOrWhiteSpace($_.title)} | select @{N='Result';E={Convert-WuaResultCodeToName -ResultCode $_.ResultCode}}, 
                            Date, Title, SupportUrl, @{N='Product';E={($_.Categories | where {$_.type -eq 'product'} ).name}}, 
                            @{N='UpdateId';E={$_.UpdateIdentity.UpdateId}}, @{N='RevisionNumber';E={$_.UpdateIdentity.RevisionNumber}}

            } # Get-WuaHistory
            
            $WUAHistroy = Get-WuaHistory | Sort-Object date
            $hotfix     = Get-HotFix | Sort-Object installedOn
            $wmiUpdate  = get-wmiobject -class win32_quickfixengineering
            
            "" | select @{N='WuaHistory';E={$WUAHistroy}}, @{N='Hotfix';E={$hotfix}}, @{N='WmiUpdate';E={$wmiUpdate}}
        } #block

    } #begin
    Process
    {
        #write-host "`nBe patient, this might take some time" -ForegroundColor Yellow
        $wuaData = Invoke-Command -ComputerName $ComputerName -ScriptBlock $block

    } #process

    End
    {

       $wuaData 

    } #End
}

