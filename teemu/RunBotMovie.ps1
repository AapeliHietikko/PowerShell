<#
$Message = "" | select text
$message.text = '!Movies fight.club.1999'
#>

if ($Message.Text -like '!Movies *')
{
    $cmdLen = "!Movie ".length
    $Title  = ($Message.Text).substring($cmdLen,$Message.Text.Length-$cmdLen).trim()
    $leffa  = ([regex]::split($Title, '\d+')[0]).replace('.',' ')
    $pew    = Invoke-RestMethod "http://www.omdbapi.com/?t=$leffa&apikey=b1b5853e"
 
@"
    name     = $($pew.Title)
    year     = $($pew.Year)
    language = $($pew.Language -join ', ')
    genre    = $($pew.Genre -join ', ')
    country  = $($pew.Country -join ', ')
"@
 
}
