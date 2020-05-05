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

$class='xxx'


foreach ($row in $table.split([Environment]::NewLine)) {

    $grp = $row | Select-String -Pattern "<tr><td>.*</td><td>(.*)</td><td>" -AllMatches

    if ($grp) {

        $user = $grp.Matches.groups[1].value
       
        if ($user -ne $lastUser)
            {
            if($class -eq 'xxx') {$class='yyy'}
            else {$class='xxx'}
            }
   
        $row.Replace('<tr>',"<tr class=$($class)>")
        
        $lastUser = $user
        }
    else
        {
        $row
        }
    }
