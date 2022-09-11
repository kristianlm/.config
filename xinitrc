#!/bin/sh
# symlink me to ~/.xinitrc

xrdb -merge "$HOME/.Xresources"

xset -b # no bell

# keyboard
xset r rate 200 60

# sudo localectl --no-convert set-x11-keymap us "" mac ctrl:nocaps
# setxkbmap us -variant mac -option ctrl:nocaps

# screen
xset s off
xset dpms 5600 5600 5600

# xsetroot -cursor_name left_ptr # change mouse cursor
# xrandr --output HDMI-0 --mode 3840x2160 --rate 59.94
xrandr --output DP-1 --left-of HDMI-1 --auto

exec i3
