function fish_prompt
    set mystatus $status

    printf (set_color -o yellow)
    if set -q GUIX_PROFILE
        printf "[$(basename $GUIX_PROFILE)] "
    else if set -q GUIX_ENVIRONMENT
        printf "[env] "
    end

    # color prompt by exit status
    if test $mystatus -le 0
        printf (set_color -o purple)
    else
	printf (set_color -o red)
    end

    printf "$USER@"(prompt_hostname)" "(prompt_pwd)" "
        printf "➤ "(set_color normal)
end
