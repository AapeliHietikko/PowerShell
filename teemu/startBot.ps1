.\Run-IrcBot.ps1 ropottibotti irc.quakenet.org mc.koppaolut

$runbot = irm "https://raw.githubusercontent.com/alejandro5042/Run-IrcBot/master/Run-IrcBot.ps1"
$apebot    = irm "https://github.com/AapeliH/PowerShell/blob/komia/teemu/SerieBot.ps1"

. $runbot $apebot irc.quakenet.org mc.koppaolut
