$table = "
<table>
<tr><td>aaa</td><td>crapzzz</td><td>noob1</td></tr>
<tr><td>bbb</td><td>crapzzz</td><td>noob1</td></tr>
<tr><td>ccc</td><td>crapzzz</td><td>noob2</td></tr>
<tr><td>uuu</td><td>crapzzz</td><td>noob2</td></tr>
<tr><td>ddd</td><td>crapzzz</td><td>pro1</td></tr>
<tr><td>ddd</td><td>crapzzz</td><td>pro2</td></tr>
</table>
"

$class='xxx'


foreach ($row in $table.split([Environment]::NewLine)) {

    $grp = $row | Select-String -Pattern "</td><td>.*</td><td>(.*)</td></tr>" -AllMatches
    


    if ($grp) {
        $user = $grp.Matches.groups[1].value
        if ($user -ne $lastUser)
            {
            if($class -eq 'xxx') {$class='yyy'}
            else {$class='xxx'}
            }
   
        $row.Replace('<tr>',"<tr class=$($class)>")
        
        $lastUser = $grp.Matches.groups[1].value
        }
    else
        {
        $row
        }
    }
