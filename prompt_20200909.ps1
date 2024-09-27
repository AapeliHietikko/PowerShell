$MUSI = New-Object -ComObject "Microsoft.Update.SystemInfo"

if($MUSI.RebootRequired) {
    $lastBootTime = gcim win32_operatingsystem | select -ExpandProperty LastBootUpTime
    $bootTimeSpan = New-TimeSpan $lastBootTime (get-date)
    $rebootReq = "$($bootTimeSpan.days) days since reboot"
    }

Else {
    $rebootReq = ""
    }

if (($psISE) -OR ($PSVersionTable.PSEdition -eq 'Core'))
    {
    
    if ($psISE)
        {
        function enter-undergroundmode {
            $psISE.Options.ConsolePaneBackgroundColor     ='#000000'
            $psISE.Options.ConsolePaneTextBackgroundColor ='#000000'
            "[$(get-date -Format yyyymmdd-HHMMss)] Going to underground mode"
            Set-PSReadlineOption -HistorySaveStyle SaveNothing
            }

        function exit-undergroundmode {
            $psISE.Options.ConsolePaneBackgroundColor     ='#FF012456'
            $psISE.Options.ConsolePaneTextBackgroundColor ='#FF012456'
            Set-PSReadlineOption -HistorySaveStyle SaveIncrementally
            "[$(get-date -Format yyyymmdd-HHMMss)] Returning to normal mode"
            }
        }

	$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
	if (($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)))
		{
        $colr="Red"
		$Elevated="$($env:USERNAME)"
        $Host.UI.RawUI.WindowTitle = "Admin $($env:USERNAME) $rebootReq"
		}
	else    {
        $colr="White"
		$Elevated="$($env:USERNAME)"
        $Host.UI.RawUI.WindowTitle = "$($env:USERNAME) $rebootReq"
		}

    function prompt {

        write-host -nonewline -ForegroundColor Red   "["
        write-host -nonewline -ForegroundColor white "$(get-date -format HH:mm:ss)"
        write-host -nonewline -ForegroundColor Red   "]["
        write-host -nonewline -ForegroundColor White "$($executionContext.SessionState.Path.CurrentLocation)$('' * ($nestedPromptLevel + 1))"
        write-host -nonewline -ForegroundColor Red   "]["
        write-host -nonewline -ForegroundColor White "$(((Get-History -Count 1).id + 1).ToString('000'))"
        write-host -nonewline -ForegroundColor Red   "]"
        return " "

        } #prompt
    } #if
else 
    {

	$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
	if (($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)))
		{
		$Elevated="$r$($env:USERNAME)"
        $Host.UI.RawUI.WindowTitle = "Admin $($env:USERNAME) $rebootReq"
		}
	else    {
		$Elevated="$n$($env:USERNAME)"
        $Host.UI.RawUI.WindowTitle = "$($env:USERNAME) $rebootReq"
		}

    function prompt {

        $esc = [char]27
        $r = "$esc[38;2;255;0;0m"
        $y = "$esc[38;2;0;255;255m"
        $n = "$esc[39m"

        "$r[$y$(get-date -format HH:mm:ss)$n$r][$n$($executionContext.SessionState.Path.CurrentLocation)$("$n" * ($nestedPromptLevel + 1))$r][$n$(((Get-History -Count 1).id + 1).ToString('000'))$r] ";
 
        } #prompt
    } #else
         
Set-PSReadlineOption -BellStyle None
