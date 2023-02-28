#!/usr/bin/fish

set arg $argv[1]

function toggling 
    test "$arg" = "toggle"
end

function headphones
    pactl list cards | grep '	Active Profile: output:analog-stereo+input:analog-stereo' >/dev/null
end

if toggling
    if headphones
        pactl set-card-profile alsa_card.pci-0000_00_1f.3 output:hdmi-stereo-extra1+input:analog-stereo
    else
        pactl set-card-profile alsa_card.pci-0000_00_1f.3 output:analog-stereo+input:analog-stereo
    end
end

if headphones
    printf "🎧"
else
    printf "🔈"
end
