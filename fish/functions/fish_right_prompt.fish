# Defined in - @ line 2
function fish_right_prompt
	if [ "$CMD_DURATION" -ge "1000" ]
        printf "\x1b[33m\x1b[3m"(math "floor($CMD_DURATION / 1000)")"s\x1b[0m"
    end
end
