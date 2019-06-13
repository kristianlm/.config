function fish_right_prompt
	if [ "$CMD_DURATION" -ge "1000" ]
            printf (math "floor($CMD_DURATION / 1000)")s
        end
end
