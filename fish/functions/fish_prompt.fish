function fish_prompt
    # color prompt by exit status
    if test $status -le 0
        printf (set_color -o purple)
    else
	printf (set_color -o red)
    end

    printf "$USER@"(prompt_hostname)" "(prompt_pwd)" "
    if set -q GUIX_ENVIRONMENT
        printf "[env] "(set_color normal)
    else
        printf "➤ "(set_color normal)
    end
end
