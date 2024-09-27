$ScriptBlock = {

    param($key, $arg)

    $selectionStart = $null
    $selectionLength = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    if($line[-1] -notmatch '[a-zA-Z0-9]')
    {
        $datChar = switch ($line[-1])
        {
        ')'     {'('}
        '}'     {'{'}
        ']'     {'['}
        default {$line[-1]}
        } #switch

        if ($selectionStart -ne -1)
        {

            [Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, $datChar + $line.SubString($selectionStart, $selectionLength))
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart + $selectionLength + 2)
        
        } # if ($selectionStart -ne -1)
        else
        {
        
            [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $line.Length, $datChar + $line)
            [Microsoft.PowerShell.PSConsoleReadLine]::EndOfLine()
        
        } #else if ($selectionStart -ne -1)

    } # if($line[-1] -notmatch '[a-zA-Z0-9]')
    
    else
    {

        if ($selectionStart -ne -1)
        {

            [Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, '(' + $line.SubString($selectionStart, $selectionLength + ')'))
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart + $selectionLength + 2)
        
        } # if ($selectionStart -ne -1)
        else
        {
        
            [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $line.Length, '(' + $line + ')')
            [Microsoft.PowerShell.PSConsoleReadLine]::EndOfLine()
        
        } #else if ($selectionStart -ne -1)


    } #else if($line[-1] -notmatch '[a-zA-Z0-9]')
} #ScriptBlock

$Splat = @{

    BriefDescription = 'ParenthesizeLine'
    LongDescription  = 'Put parenthesis around the entire line and move the cursor to the end of line.'
    ScriptBlock      = $ScriptBlock

}

Set-PSReadlineKeyHandler -Key 'Ctrl+p' @Splat
