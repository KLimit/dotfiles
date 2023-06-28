function notify{
	param($message)
	write-host "$message"
	if (get-command toastify -erroraction silentlycontinue) {
		toastify send --app-name "komorebi" "$message"
	}
}

foreach ($process in 'whkd', 'yasb') {
	if (!(get-process "$process" -erroraction silentlycontinue)) {
		$message = "Starting $process"
		notify $message
		start-process "$process" -windowstyle hidden
	}
}

write-host "sourcing generated overrides"
. $PSScriptRoot\komorebi.generated.ps1

# Send the ALT key whenever changing focus to force focus changes
komorebic alt-focus-hack enable
# Default to cloaking windows when switching workspaces
komorebic window-hiding-behaviour cloak
# Set cross-monitor move behaviour to insert instead of swap
komorebic cross-monitor-move-behaviour insert
# Enable hot reloading of changes to this file
komorebic watch-configuration disable

# workspaces and monitors are zero-indexed, so make sure to account for that
$num_workspaces = 10
$num_monitors = 1

# apply some defaults for all workspaces for all monitors
foreach ($monitor in 0..($num_monitors-1)) {
	notify "Configuring workspaces for monitor $monitor"
	komorebic ensure-workspaces $monitor $num_workspaces
	foreach ($space in 0..($num_workspaces - 1)) {
		# notify "Configuring workspace $space"
		# Assign layouts to workspaces, possible values: bsp, columns, rows,
		# vertical-stack, horizontal-stack, ultrawide-vertical-stack
		komorebic workspace-layout $monitor $space bsp
		# Set the gaps around the edge of the screen for a workspace
		komorebic workspace-padding $monitor $space 0
		# Set the gaps between the containers for a workspace
		komorebic container-padding $monitor $space 0
	}
}

# You can assign specific apps to named workspaces
# komorebic named-workspace-rule exe "Firefox.exe" III

# Configure the invisible border dimensions
komorebic invisible-borders 7 0 14 7

# Uncomment the next lines if you want a visual border around the active window
# komorebic active-window-border-colour 66 165 245 --window-kind single
# komorebic active-window-border-colour 256 165 66 --window-kind stack
# komorebic active-window-border-colour 255 51 153 --window-kind monocle
# komorebic active-window-border enable

komorebic complete-configuration
