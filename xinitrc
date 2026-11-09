#!/bin/sh
# symlink me to ~/.xinitrc

xrdb -merge "$HOME/.Xresources"

xset -b
xset r rate 200 60
xset s off
xset dpms 5600 5600 5600
setxkbmap us -variant mac -option ctrl:nocaps

xrandr --output DP-3 --auto --output HDMI-3 --auto --right-of DP-3 --output DP-1-5 --auto --right-of HDMI-3
exec ssh-agent i3
