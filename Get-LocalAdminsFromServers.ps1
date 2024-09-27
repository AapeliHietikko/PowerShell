function Get-LocalGroupMembers  
{  
    param(  
        [parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]  
        [Alias("Name")]  
        [string]$ComputerName,  
        [string]$GroupName = "Administrators"  
    )  
            
    Process  
    {  
        $ComputerName = $ComputerName.Replace("`$", '')  
        $arr = @()  
        $hostname = (Get-WmiObject -ComputerName $ComputerName -Class Win32_ComputerSystem).Name 
 
        $wmi = Get-WmiObject -ComputerName $ComputerName -Query "SELECT * FROM Win32_GroupUser WHERE GroupComponent=`"Win32_Group.Domain='$Hostname',Name='$GroupName'`""  
  
        if ($wmi -ne $null)  
        {  
            foreach ($item in $wmi)  
            {  
                $data = $item.PartComponent -split "\," 
                $domain = ($data[0] -split "=")[1] 
                $name = ($data[1] -split "=")[1] 
                $arr += ("$domain\$name").Replace("""","") 
                [Array]::Sort($arr) 
            } #End Foreach 
        }  #End If
  
        $hash = @{ComputerName=$ComputerName;Members=$arr}  
        return $hash  
    }  #End Process
        
} #End Function

$ErrorActionPreference = 'SilentlyContinue'
#Initialize Excel
[threading.thread]::CurrentThread.CurrentCulture = 'en-US'

$outputExcel = "h:\Server_Admins.xlsx"

$excel = New-Object -ComObject excel.application
$excel.visible = $true
$workbook = $excel.Workbooks.Add()
$sheet = $workbook.Worksheets.Item(1)
$sheet.name = "Server_LocalAdminsGroup"
$row = 1
$sheet.Cells.Item($row,1) = "Server"


$ou = "OU=Servers,DC=plp,DC=com"
$servers = (get-adcomputer -searchbase $ou -fi * ).name

$PCountTOT = $servers.count

<#
$server = 'met-crm01'
Get-LocalGroupMembers $server 
#>

foreach ($server in $servers) {

        $PCount++
        $PCountPerCent = $PCount / $PcountTOT *100
        Write-Progress -Activity "Running SNMP queries" -status "Server $PCount/$PcountTOT" -percentComplete $PCountPerCent

        $column = 1

        $admins = @()
        $admins = (Get-LocalGroupMembers $server).Members

        if ($admins) {
            $row++
            $sheet.Cells.Item($row,$column) = $server
            
            ForEach ($admin in $admins) {
               $column++
               $sheet.Cells.Item(1,$column) = "Local Admin $column"
               $sheet.Cells.Item($row,$column) = $admin
               } #End Foreach Admin
           
           }#End If Admins

        } #End forEach Servers


$Excel.Rows.Item(1).Font.Bold = $true 
$usedRange = $sheet.UsedRange						
$usedRange.EntireColumn.AutoFit() | Out-Null
$userRange.NumberFormat = "Text"

$workbook.SaveAs($outputExcel)
$excel.Quit()
$ErrorActionPreference = 'Continue'
