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
"   =  " "SUPER KEY (Windows Key)" "(SUPER KEY)" \
"" "" "" \
"   + T" "Terminal" "(kitty)" \
"   + E" "File Browser" "(pcmanfm-qt)" \
"   + F" "Internet Browser" "(firefox)" \
"   + C" "Code Editor" "(vscode)" \
"CTRL + SHIFT + ESCAPE" "System Monitor" "(btop)" \
"" "" "" \
"   + A" "Search Applications" "(nwg-drawer)" \
"   + V" "Clipboard Manager" "(cliphist | rofi)" \
"   + P" "Color picker" "(hyprpicker)" \
"   + B" "Emoji picker" "(rofi)" \
"   + N" "Toggle Notification Area" "(swaync)" \
"   + Backspace" "Logout menu" "(wlogout)" \
"   + L" "Lock Screen" "(hyprlock)" \
"" "" "" \
"Print Screen" "Screenshot of all monitors" "(grimblast | swappy)" \
"Alt + Print Screen" "Screenshot of current monitor" "(grimblast | swappy)" \
"   + Print Screen" "Select the area of the screenshot" "(slurp | grimblast | swappy)" \
"Ctrl + Print Screen" "Select the area of the screenshot, frozen screen" "(slurp | grimblast | swappy)" \
"" "" "" \
"   + Q" "Close Active Window" "(killactive)" \
"   + Return" "Kind of maximize a floating windows" "(resizeactive and center)" \
"   + Alt +  Return" "Toggle Fullscreen" "(fullscreen)" \
"F11" "Toggle Fullscreen" "(fullscreen)" \
"   + Shift + F" "Pin a Window" "(pin)" \
"   + G" "Toggle group mode" "(togglegroup)" \
"   + Shift + G" "Lock current group" "(lockactivegroup)" \
"   + Alt + Tab" "Switch to the next window of the group" "(changegroupactive)" \
"   + W" "Toggle Floating Mode" "(togglefloating)" \
"   + Shift + W" "Toggle Floating Mode For All Windows" "(allfloat)" \
"" "" "" \
"Alt + Tab" "Cycle to Next Window" "(cyclenext)" \
"   + Left/Right/Up/Down" "Move Focus in Selected direction" "(movefocus)" \
"" "" "" \
"   + Tab" "Open overview" "(hyprexpo)" \
"" "" "" \
"   + Left Mouse Click" "Move Selected Window" "(movewindow)" \
"   + Ctrl Left/Right/Up/Down" "Move Active Window" "(movewindow)" \
"" "" "" \
"   + Right Mouse Click" "Resize Selected Window" "(resizewindow)" \
"   + Shift Left/Right/Up/Down" "Resize Active Window" "(resizeactive)" \
"" "" "" \
"   + 1-0" "Move to Workspace 1-10" "(workspace 1-10)" \
"   + Mousewheel" "Cycle Through Workspaces" "(workspace r-+1)" \
"   + Ctrl + Left or Right" "Move to Next or Previous Workspace" "(workspace r-+1)" \
"   + Ctrl + Down" "Move to First Empty Workspace" "(workspace empty)" \
"" "" "" \
"   + Shift + 1-0" "Move Window to Workspace 1-10" "(movetoworkspace 1-10)" \
"   + Shift + 1-0" "Move Window to Workspace 1-10" "(movetoworkspace 1-10)" \
"   + Alt + 1-0" "Move Window to Workspace 1-10 Without Following" "(movetoworkspacesilent 1-10)" \
"   + Ctrl + Alt + Left or Right" "Move Window to Next or Previous Workspace" "(movetoworkspace r-+1)" \
"" "" "" \
"   + S" "Toggle Special Workspace" "(togglespecialworkspace)" \
"   + Shift + S" "Move Active Windows to Special Workspace" "(movetoworkspace special)" \
"" "" "" \
"" "Note: You can use this keybind up to four times by using" "" \
"" "ALT, CTRL or SHIFT in the key combination." "" \
"" "Each key combination can only minimize one window" "" \
"   + M" "Minimize window, reuse to unminimize" "(togglespecialworkspace)" \
"" "" "" \
"   + H" "Choose a wallpaper" "(yad)" \
"   + Shift + H" "Choose a random wallpaper" "(script)" \
