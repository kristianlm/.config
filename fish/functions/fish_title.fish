# terminal window title
function fish_title
        echo $USER@(hostname) '['$PWD']' $argv
end
