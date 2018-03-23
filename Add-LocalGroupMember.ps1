 function Add-LocalGroupMember {
        
        <#
        .Synopsis
           Adds user to local group of computer
        .DESCRIPTION
           Invoke net localgroup localGroup identity /add command to remote machine.
           Then output the current members of Administrators group
        .EXAMPLE
           Add-LocalGroupMember -ComputerName localhost -Identity domain\username
        .EXAMPLE
           Add-LocalGroupMember -ComputerName localhost -Identity domain\username -LocalGroup 'Remote Desktop Users'
        .NOTES
           Aapeli Hietikko 23.3.2018
        #>
        
        [CmdletBinding()]

        Param
        (
        # ComputerName
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $ComputerName,

        # Account
        [Parameter(Mandatory=$true,
           ValueFromPipelineByPropertyName=$true,
           Position=1)]
        $Identity,

        # LocalGroup
        [Parameter(Mandatory=$false,
           ValueFromPipelineByPropertyName=$true,
           Position=2)]
        [ValidateSet('Administrators','Power Users','Users','Remote Desktop Users')]
        $LocalGroup='Administrators'

        )


    Invoke-Command -ComputerName $ComputerName -Command {
    
        net localgroup $args[0] $args[1] /add ;
        net localgroup $args[0] 
        
        } -ArgumentList $LocalGroup, $Identity

} 
