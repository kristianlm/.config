function fish_prompt
    # color prompt by exit status
    if test $status -le 0
        printf (set_color -o purple)
    else
	printf (set_color -o red)
    end

    printf (date "+%H%M")" $USER@"(prompt_hostname)" "(prompt_pwd)" %s ➤ "(set_color normal)
end
