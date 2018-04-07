
env:
	ln -s ${PWD}/pam_environment ~/.pam_environment

ssh-agent:
	systemctl --user enable ssh-agent

xinitrc:
	ln -s $PWD/xinitrc ~/.xinitrc
