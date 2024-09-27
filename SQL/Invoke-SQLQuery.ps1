<#
.Synopsis
   Makes SQL query to SQL server
.DESCRIPTION
   Specify SQL query, Database and server to do do a query against SQL database. Uses windows integrated authentication
.EXAMPLE
   Invoke-SQLQuery -Computername db-server -DataBase database -SQLQuery "select *"
#>
function Invoke-SQLQuery
{
    [CmdletBinding()]
    Param
    (
        # Specify Database server name
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [String]
        $Computername,

        # Specify Database  name
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [String]
        $DataBase,

        # Specify T-SQL query to be run
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
       
        $SQLQuery,

        # Specify Database user id
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        [string]
        $UserID,

        # Specify Database user password
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        [string]
        $Password
    )

    Begin
        {
        
       
        } #Begin
    Process
        {
        
        #SQL
        $SqlConnection                  = New-Object System.Data.SqlClient.SqlConnection
        
        if ($UserID -and $password)
        {
            $SqlConnection.ConnectionString = "Server = $Computername; Database = $DataBase; User Id=$UserID; Password=$Password;"
        }
        else
        {
            $SqlConnection.ConnectionString = "Server = $Computername; Database = $DataBase; Integrated Security = True"
        }

        #SQL commands
        $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
        $SqlCmd.CommandText = $SQLQuery
        $SqlCmd.Connection = $SqlConnection
         
        $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
        $SqlAdapter.SelectCommand = $SqlCmd
         
        $DataSet = New-Object System.Data.DataSet
        $SqlAdapter.Fill($DataSet) | out-null
        
        #populate Excel file                               
        foreach ($dataRow in $DataSet.Tables[0])
            { 
            $dataRow    
            } #  foreach ($dataRow in $DataSet.Tables[0])    
        
        
        } #Process
    End
        {

        #Close stuff
        $SqlConnection.Close() 
            
        } #End
}
