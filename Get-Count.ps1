<#
.Synopsis
   Get count of objects.
.DESCRIPTION
   Comman calculates the count of objects returned in variable.
.EXAMPLE
   Get-Count -Object $variable
.EXAMPLE
   $variable | get-count
#>
function Get-Count
{
    [CmdletBinding()]
    [Alias("Count")]
    [OutputType([int])]
    Param
    (
        # Object, can be used from pipe
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Object
    )

    Begin
    {
    $countTable = @()

    }
    Process
    {

        if($PSCmdlet.ParameterSetName -ne "nopipeline")
            {
                #$Object
                $countTable += $object
            }

    }
    End
    {

        if($PSCmdlet.ParameterSetName -eq "nopipeline")
            {
                $output = $object.count
            }
        else
            {
                ($countTable).count
            }

    }
}
