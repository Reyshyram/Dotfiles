#!/bin/bash

# Detect monitor resolution and scale
x_mon=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .width')
y_mon=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .height')
hypr_scale=$(hyprctl -j monitors | jq '.[] | select (.focused == true) | .scale' | sed 's/\.//')

# Calculate width and height based on percentages and monitor resolution
width=$((x_mon * hypr_scale / 100))
height=$((y_mon * hypr_scale / 100))

# Set maximum width and height
max_width=1200
max_height=1000

# Set percentage of screen size for dynamic adjustment
percentage_width=70
percentage_height=70

# Calculate dynamic width and height
dynamic_width=$((width * percentage_width / 100))
dynamic_height=$((height * percentage_height / 100))

# Limit width and height to maximum values
dynamic_width=$(($dynamic_width > $max_width ? $max_width : $dynamic_width))
dynamic_height=$(($dynamic_height > $max_height ? $max_height : $dynamic_height))

# Launch yad with calculated width and height
yad --width=$dynamic_width --height=$dynamic_height \
    --center \
    --title="Keybindings" \
    --no-buttons \
    --list \
    --column=Key: \
    --column=Description: \
    --column=Command: \
    --timeout-indicator=bottom \
"ESC" "Close this Window" "" \
"   =  " "Super key (Windows Key)" "(Super key)" \
"" "" "" \
"   + T" "Terminal" "(kitty)" \
"   + E" "File Browser" "(pcmanfm-qt)" \
"   + F" "Internet Browser" "(firefox)" \
"   + C" "Code Editor" "(vscode)" \
"Ctrl + Shift + Escape" "System Monitor" "(btop)" \
"" "" "" \
"   + A" "Search Applications" "(ulauncher)" \
"   + V" "Clipboard Manager" "(clipse)" \
"   + P" "Color picker" "(hyprpicker)" \
"   + B" "Emoji picker" "(smile)" \
"   + N" "Toggle Notification Area" "(swaync)" \
"   + Backspace" "Logout menu" "(wlogout)" \
"   + L" "Lock Screen" "(hyprlock)" \
"" "" "" \
"Print Screen" "Screenshot of current monitor" "(grimblast)" \
"   + Print Screen" "Screenshot of all monitors" "(grimblast)" \
"Ctrl + Print Screen" "Select the area of the screenshot" "(grimblast)" \
"Alt + Print Screen" "Select the area of the screenshot, frozen screen" "(grimblast)" \
"" "" "" \
"   + Q" "Close Active Window" "(killactive)" \
"   + Return" "Kind of maximize a floating windows" "(resizeactive and center)" \
"   + Ctrl + Return" "Center a window" "(center)" \
"   + Alt +  Return" "Toggle Fullscreen" "(fullscreen)" \
"F11" "Toggle Fullscreen" "(fullscreen)" \
"   + Shift + F" "Pin a Window" "(pin)" \
"   + G" "Toggle group mode" "(togglegroup)" \
"   + Shift + G" "Lock current group" "(lockactivegroup)" \
"   + Alt + Tab" "Switch to the next window of the group" "(changegroupactive)" \
"   + W" "Toggle Floating Mode" "(togglefloating)" \
"   + Shift + W" "Toggle Floating Mode For All Windows" "(allfloat)" \
"" "" "" \
"   + J" "Toggle between blurred and 100% opacity" "(hyprctl)" \
"" "" "" \
"   + K" "Switch keyboard layout" "(hyprctl)" \
"" "" "" \
"Alt + Tab" "Cycle to Next Window" "(cyclenext)" \
"   + Left/Right/Up/Down" "Move Focus in Selected direction" "(movefocus)" \
"" "" "" \
"   + Left Mouse Click" "Move Selected Window" "(movewindow)" \
"   + Shift + Ctrl + Left/Right/Up/Down" "Move Active Window" "(movewindow)" \
"" "" "" \
"   + Right Mouse Click" "Resize Selected Window" "(resizewindow)" \
"   + Shift Left/Right/Up/Down" "Resize Active Window" "(resizeactive)" \
"" "" "" \
"   + 1-0" "Move to Workspace 1-10" "(split-workspace 1-10)" \
"   + Mousewheel" "Cycle Through Workspaces" "(split-workspace r-+1)" \
"   + Ctrl + Left or Right" "Move to Next or Previous Workspace" "(split-workspace r-+1)" \
"   + Ctrl + Down" "Move to First Empty Workspace" "(split-workspace empty)" \
"" "" "" \
"   + Shift + 1-0" "Move Window to Workspace 1-10" "(split-movetoworkspace 1-10)" \
"   + Alt + 1-0" "Move Window to Workspace 1-10 Without Following" "(split-movetoworkspacesilent 1-10)" \
"   + Ctrl + Alt + Left or Right" "Move Window to Next or Previous Workspace" "(split-movetoworkspace r-+1)" \
"   + Ctrl + Alt + Shift + Left or Right" "Move Window to Next or Previous Workspace Silently" "(split-movetoworkspacesilent r-+1)" \
"" "" "" \
"   + S" "Toggle Special Workspace" "(togglespecialworkspace)" \
"   + Shift + S" "Move Active Windows to Special Workspace" "(split-movetoworkspace special)" \
"" "" "" \
"" "Note: You can use this keybind up to four times by using" "" \
"" "ALT, CTRL or SHIFT in the key combination." "" \
"" "Each key combination can only minimize one window" "" \
"   + M" "Minimize window, reuse to unminimize" "(togglespecialworkspace)" \
"" "" "" \
"   + H" "Choose a wallpaper" "(yad)" \
"   + Shift + H" "Choose a random wallpaper" "(script)" \
