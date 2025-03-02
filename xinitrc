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

2k

exec i3
