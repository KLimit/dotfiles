if (!(Get-Process whkd -ErrorAction SilentlyContinue))
{
	write-host "Starting whkd"
    Start-Process whkd -WindowStyle hidden
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
komorebic watch-configuration enable

# workspaces and monitors are zero-indexed, so make sure to account for that
$num_workspaces = 10
$num_monitors = 1

# apply some defaults for all workspaces for all monitors
foreach ($monitor in 0..($num_monitors-1)) {
	komorebic ensure-workspaces $monitor $num_monitors
	foreach ($space in 0..($num_workspaces - 1)) {
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
