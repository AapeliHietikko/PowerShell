function Get-LDAPUser
{
    [CmdletBinding(DefaultParameterSetName='sAMAccountName')]

    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='sAMAccountName')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $sAMAccountName,

        # Param3 help description
                [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='userPrincipalName')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $userPrincipalName
    )

    Begin
    {
    if ($sAMAccountName)
        {
        $searcher = New-Object System.DirectoryServices.DirectorySearcher("(&(objectCategory=User)(samaccountname=$samaccountname))")
        }
    if ($userPrincipalName)
        {
        $searcher = New-Object System.DirectoryServices.DirectorySearcher("(&(objectCategory=User)(userprincipalname=$userPrincipalName))")
        }

    #Create the default property display set
    $defaultDisplaySet = 'sAMAccountName','givenName','sn','employeeID'
    $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet(‘DefaultDisplayPropertySet’,[string[]]$defaultDisplaySet)
    $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)

    }
    Process
    {

    $results = $searcher.FindAll()
    # enumerate collection
    foreach($result in $results){
        #Get the directory entry for this result/
        [PSCustomObject]$user =  $result.GetDirectoryEntry() |  select *
        $user.PSObject.TypeNames.Insert(0,'User.Information')
        $user | Add-Member MemberSet PSStandardMembers $PSStandardMembers
        $user
        }
    }
    End
    {
    }
}
