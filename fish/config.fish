set -x PATH $PATH $HOME/bin

if [ (tty) = '/dev/tty1' ]
	exec startx
end
