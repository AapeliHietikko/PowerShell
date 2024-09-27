$table = "
aaa,noob1,crpazz,tsup,1
bbb,noob1,crpazz,tsup,2
ccc,noob2,crpazz,tsup,1
uuu,noob2,crpazz,tsup,3
ddd,pro01,crpazz,tsup,1
ddd,pro02,crpazz,tsup,5
"
$InputObjects = $table | ConvertFrom-Csv -Header col1,name,col2,tsup,numero
$allUsers = $InputObjects.name | Sort-Object | Get-Unique

$class='xxx'

$htmlPre = @"
<html>
<header></header>
<body>
<h1>shittii</h1>
<table>
"@

$htmlEnd = @"
</body>
</html>
"@

#find headers
$StaticOrderHeaders = "col1","name"
$inputHeaders = $InputObjects | gm | where {$_.membertype -eq 'NoteProperty'} | select -ExpandProperty name | where {$staticOrderHeaders -notcontains $_} 

$htmlTableHeader = "<th> <td>col1</td> <td>name<td></td> "

$htmlTableHeader += foreach ($inputHeader in $inputHeaders) {

    "<td>$inputHeader</td>"

    }

$htmlTableHeader += " </th>"

$htmlTableRows = foreach ($object in $InputObjects) 
{
    if ($object.name -ne $lastUser)
    {
        if($class -eq 'xxx') {$class='yyy'}
        else {$class='xxx'}
    }

    $htmlTableRow = "<tr class=$class> <td>$($object.col1)</td> <td>$($object.name)</td> "   
    $htmlTableRow += foreach ($inputHeader in $inputHeaders){
        
        "<td>$($object.$inputHeader)</td>"
        
        }
    $htmlTableRow += " </tr>"
    $htmlTableRow
    $lastUser = $object.name
         
}

$htmlTableEnd = @"
</table>
"@

$htmlPre
$htmlTableHeader
$htmlTableRows
$htmlTableEnd
$htmlEnd

