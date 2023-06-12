Import-Module posh-git
# Import-Module Terminal-Icons
import-module get-choice

$PSDefaultParameterValues['*:Encoding'] = "UTF8"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.UTF8Encoding]::new()

# for programs that shipped with autocomplete scripts
foreach ($autocomplete in $env:psmodulepath.split(';' ) | where-object {$_ -match 'autocomplete'}) {
	foreach ($script in gci "$autocomplete\*.ps*") {
		. $script
	}
}

# trying to shave off hundreds of milliseconds here:
# The uncommented stuff is the output of the line directly below:
# oh-my-posh init pwsh --config ~/poshprompt.omp.json | Invoke-Expression
# (@(& 'C:/Users/hlimm/AppData/Local/Programs/oh-my-posh/bin/oh-my-posh.exe' init pwsh --config='C:\Users\hlimm\poshprompt.omp.json' --print) -join "`n") | Invoke-Expression

# git-posh configuration
# $global:GitPromptSettings.WorkingColor.ForegroundColor = [ConsoleColor]::DarkCyan

# trying starship instead of oh-my-posh
function Invoke-Starship-TransientFunction {
	&starship module character
}
# Invoke-expression (&starship init powershell)
Invoke-Expression (& 'C:\Program Files\starship\bin\starship.exe' init powershell --print-full-init | Out-String)
Enable-TransientPrompt

# init zoxide
# (If you choose to use the dump, know that zoxide env variables are used 
# during `zoxide init` rather than at runtime)
# invoke-expression (& {
# 	$hook = if ($psversiontable.psversion.major -lt 6) { 'prompt' } else { 'pwd' }
# 	(zoxide init --cmd cd --hook $hook powershell | out-string)
# })

$backupdir = 'G:\My Drive\misc-backup\'
$HIST = "$HOME\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"
$NVIM = "$HOME\appdata\local\nvim"
$WTERM = "$HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

# powershell likes to default alias some stuff for which I have better progs
if (test-path Alias:mkdir) {Remove-item Alias:mkdir -force}
if (test-path Alias:sort) {Remove-item Alias:sort -force}
if (test-path Alias:diff) {Remove-item Alias:diff -Force}
if (test-path Alias:curl) {Remove-item Alias:curl -Force}
# if (test-path Alias:cat) {remove-item alias:cat -force}
set-alias -name vim -value nvim
Set-Alias -Name which -Value 'where.exe'
set-alias -name vd -value visidata
set-alias -name sponge -value rw
set-alias -name mkdir -value 'mkdir.exe'
set-alias -name wc -value 'cw.exe'
set-alias -name bat -value 'less.exe'
if (test-path Alias:sl) {Remove-item Alias:sl -force}
if (test-path Alias:ls) {Remove-item Alias:ls -force}
function ls {
	ls.exe --color=auto --group-directories-first --width=80 $args
}
function rustapps {
	ls -l -rt --no-group "$home/.cargo/bin/*.exe"
}
function goapps {
	ls -l -rt --no-group "$home/go/bin/*.exe"
}
function canterm {python -m motiv_python_utils.device_interface.can.frontend.canterminal}
function cflashgui {python -m motiv_python_utils.device_interface.can.can_flash_gui}
function mygenact {cls && genact -m botnet -m download -m mkinitcpio -m memdump -m weblog -m ansible -m composer -s"0.5"}
function git-graph {
	git-graph.exe --no-pager --color=always $args | less -r
}
function tv {
	head $args | csview
}
function append-userpath {
	param($dir, [switch]$tmp)
	if ($dir -eq $null) {
		$dir = get-location
	}
	$dir = (get-item $dir).fullname
	$temporarily = if ($tmp) {" (for this session)"} else {""}
	$query = "append $dir to the user PATH$($temporarily)?"
	if (-not (& get-confirmation("append-userpath", $query))) {
		return
	}
	if (-not $tmp){
		$existingpath = [Environment]::GetEnvironmentVariable(
			"Path",
			[EnvironmentVariableTarget]::user
		)
		[Environment]::SetEnvironmentVariable(
			"Path",
			"$existingpath;$dir",
			[EnvironmentVariableTarget]::user
		)
	}
	# also add to current scope so that you don't have to restart the shell
	$env:path += ";$dir"
}
function add-userenv {
	param($key, $item)
	[environment]::SetEnvironmentVariable(
		"$key",
		"$item",
		[environmentvariabletarget]::user
	)
	$envpathlike = "Env:\$key"
	if (test-path $envpathlike) {
		set-item -path $envpathlike -value "$item"
	} else {
		new-item -path "Env:\$key" -value "$item"
	}
}
function get-lastdownload {
	return (gci ~/downloads | sort-object -descending -property LastWriteTime)[0]
}
function overhere {
	$tomove = (get-lastdownload)
	$question = "Move $tomove into current directory?"
	if (get-confirmation('overhere', "$question")) {
		write-host "moving $tomove"
		mv (get-lastdownload) .
	} else {
		write-host "cancelled"
	}
}
function set-env {
	# todo use a dict
	param($language)
	if ($language -eq 'c') {
		& append-userpath -tmp "C:/mingw64/bin"
	} elseif ($language -eq 'pascal') {
		& append-userpath -tmp "C:\FPC\3.2.2\bin\i386-win32\"
	} elseif ($language -eq 'msbuild') {
		& append-userpath -tmp "C:\Program Files\Microsoft Visual Studio\2022\Community\Msbuild\Current\Bin\"
	} elseif ($language -eq 'vcvars') {
		write-host "the vcvars scripts will only work in a cmd shell"
		write-host "Remember, you can use vcvarsall (/help for options)."
	} elseif ($language -eq 'zig') {
		& append-userpath -tmp "C:\zig\zig"
	} else {
		write-host "Currently available dev environments are 'c', 'pascal', 'msbuild', 'vcvars', 'zig'"
	}
}
function start-pythonvenv {
	$found = (fd -eps1 activate)
	if ($found.gettype().name -eq 'String') {
		. $found
	} else {
		echo "Too many activate.ps1 scripts found"
	}
}
function hackitty {
	param ([switch]$uwu)
	$jargon = (jargon)
	if ($uwu) {
		$jargon = (echo $jargon | uwuify)
	}
	
	# echo $jargon | fold -s -w65 | catsay
	echo $jargon | prose -f -w65 2> $null | catsay
}
function ls-extensions {
	ls | rg \.\w*$ -o | py -3 -c "import sys `nfor line in sys.stdin: print(line.lower())" | sed /^\s*$/d | huniq -c | sort

}
function nvim-plugin {
	param($query)
	curl "https://nvim.sh/s/$query"
}
# catsay "Hello Henry!"
# 1/16 chance to get uwuified jargon entry
$rand = (get-random -maximum 16)
if ($rand -eq 1) {
	hackitty -uwu
} else {
	hackitty
}
$runthermaltest = "py -2 .\bpcu_thermal.py  -n 1 .\bpcu-thermal-testlist.json .\bpcu-testdef-config.json"
