set -x PATH $PATH $HOME/bin

# colored manpages
set -xU LESS_TERMCAP_md (printf "\e[00;33m")
set -xU LESS_TERMCAP_me (printf "\e[0m")
set -xU LESS_TERMCAP_se (printf "\e[0m")
set -xU LESS_TERMCAP_so (printf "\e[01;44;33m")
set -xU LESS_TERMCAP_ue (printf "\e[0m")
set -xU LESS_TERMCAP_us (printf "\e[00;32m")

if [ (tty) = '/dev/tty1' ]
	exec startx
end
