$data = irm https://plaaplaa.dummy/file.json

$asiakkaat = $data | gm | where {$_.MemberType -like "NoteProperty"}

foreach ($asiakas in $asiakkaat.name) 
{
    # $asiakas = $asiakkaat.name[1]
    $asiakasDatat       = $data | select -ExpandProperty $asiakas 
    $asiakasDataHeaders = $data | select -ExpandProperty $asiakas | gm | where {$_.MemberType -like "NoteProperty"}

    "<li>$asiakas"

    if ($asiakasDatat)
    {
        foreach ($header in $asiakasDataHeaders.name)
        {
        #$header = $asiakasDataHeaders.name[0]
            "  <ul>$header"

            foreach ($row in $($asiakasDatat | select -ExpandProperty $header))
            {
            #$row in $($asiakasDatat | select -ExpandProperty $header)

                "    <li>$row</li>"

            } #foreach ($row in $($asiakasDatat | select -ExpandProperty $header))

            "  </ul>"

        } #foreach ($header in $asiakasDataHeaders.name)
        
    } #if ($asiakasDatat)

    "</li>"
    ""
} #foreach ($asiakas in $asiakkaat.name) 


