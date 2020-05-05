$table = "
<table>
<tr><td>aaa</td><td>noob1</td><td>crpazz</td></tr>
<tr><td>bbb</td><td>noob1</td><td>crpazz</td></tr>
<tr><td>ccc</td><td>noob2</td><td>crpazz</td></tr>
<tr><td>uuu</td><td>noob2</td><td>crpazz</td></tr>
<tr><td>ddd</td><td>pro01</td><td>crpazz</td></tr>
<tr><td>ddd</td><td>pro02</td><td>crpazz</td></tr>
</table>
"

$allUsers = 'noob1','noob2','pro01','pro02'

$class='xxx'


foreach ($row in $table.split([Environment]::NewLine)) 
{

    $grp = $row | Select-String -Pattern "<tr>.*</tr>"

    if($grp)
    {
        foreach ($user in $allUsers) 
        {
            
            if ($grp -match $user) 
            {
                
                if ($user -ne $lastUser)
                {
                    if($class -eq 'xxx') {$class='yyy'}
                    else {$class='xxx'}
                }
   
            $row.Replace('<tr>',"<tr class=$($class)>")
            }
            
            $lastUser = $user
        }
    }
    else 
    {
        $row
    }
}
