param ($Message, $Bot)

if ($Message.Text -like 'ape series *')
{

    $Title  = ($Message.Text).trimstart('ape series ')
    $search = (([regex]::split($Title, '(S\d\dE\d\d)')[0]).trimEnd('.').trimStart('.').replace('.',' ')).toString()

    $irm = Invoke-RestMethod "https://api.tvmaze.com/search/shows?q=$search"

@"
    name     = $($irm.show.name -join ', ')
    url      = $($irm.show.url -join ', ')
    type     = $($irm.show.type -join ', ')
    language = $($irm.show.language -join ', ')
    genre    = $($irm.show.genres -join ', ')
    status   = $($irm.show.status -join ', ')
"@

}
