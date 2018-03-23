 function set-localadmin {
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
        $Identity
    )


    Invoke-Command -ComputerName $ComputerName -Command {net localgroup Administrators $args[0] /add } -ArgumentList $Identity

} 
