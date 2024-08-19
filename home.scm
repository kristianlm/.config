;;; to be used in guix home <action> home.scm
(use-modules
 (guix gexp)
 (guix utils)
 (guix packages)
 (gnu home)
 (gnu packages)
 (gnu packages rust-apps)
 (gnu services)
 (gnu services desktop)
 (gnu home services ssh)
 (gnu home services xdg)
 (gnu home services shells))

(home-environment
 (packages
  (specifications->packages
   (list
    ;; basic
    "file" "pv" "jq" "zstd"
    "git-minimal" "tig" "tk"  ;; <-- needed by gitk
    "bat"
    "tmux"
    "the-silver-searcher"
    "recutils"
    "rlwrap"
    "atool" "unzip" "p7zip"
    "watchexec"
    "ncurses" ;; for tput
    "tree"
    "man-db"
    "man-pages" ;; <-- linux
    "xxd"
    ;; network
    "netcat"            "socat"
    "curl"
    "iperf" "nmap"
    "darkhttpd"
    "wireguard-tools"
    ;; x
    "sx" "xrandr" "libxft" "xrdb"
    "setxkbmap" "xset"
    "i3-wm" "dmenu" "i3status" "i3status-rust" "rofi" "rofi-calc"
    "alacritty" ;; "lxterminal"
    "xclip"
    "redshift"
    ;; fonts
    "font-inconsolata" "font-fira-mono" "font-fira-code" "font-awesome"
    "font-openmoji"
    "xdg-utils" ;; <-- xdg-open
    "maim" "slop" ;; screen capture tools
    ;; doc
    "mupdf"
    "evince"
    "font-liberation" ;; <-- YEY! fixes rendering for missing embedded fonts!
    ;; "graphviz"
    ;; media
    "feh" "imv" "sxiv" "gnuplot"
    ;;"mpv"
    "ffmpeg" "sox" "graphicsmagick"
    "pulseaudio" "pulsemixer"
    "mpv"
    ;; code
    "libqalculate"
    "cloc"
    "zile"
    "make"
    "chicken"
    ;; emacs
    "emacs"
    "emacs-zerodark-theme" "emacs-spacemacs-theme"
    "emacs-paren-face"
    "emacs-helm-ag"
    "emacs-all-the-icons"
    "emacs-all-the-icons-completion"
    "emacs-all-the-icons-dired"
    "emacs-spaceline-all-the-icons" "emacs-powerline" "emacs-doom-modeline"
    "emacs-vertico" "emacs-orderless" ;; "emacs-helm" "emacs-ivy"
    "emacs-ctrlf" "emacs-swiper" ;; i-search alternative
    "emacs-phi-search" ;; testing
    ;; "emacs-git-gutter-fringe"
    "emacs-highlight-symbol"
    ;; "emacs-idle-highlight" ;; switched to highlight-symbol-mode
    "emacs-magit" "emacs-git-link"
    "emacs-multiple-cursors"
    "emacs-ace-window" "emacs-switch-window" "emacs-frames-only-mode" "emacs-window-purpose"
    "emacs-paredit" ;; "emacs-smartparens" "emacs-aggressive-indent"
    "emacs-vterm"
    ;; "emacs-tagedit"
    "emacs-dumb-jump"
    "emacs-fish-mode"
    "emacs-web-mode"
    "emacs-json-mode"
    "emacs-markdown-mode"
    "emacs-js2-mode"
    "emacs-go-mode"
    "emacs-rec-mode"
    "emacs-protobuf-mode"
    "emacs-gnuplot"
    "emacs-opencl-mode"
    "emacs-glsl-mode"
    "emacs-scad-mode"
    "emacs-clojure-mode" "emacs-cider" ;; "inf-clojure"
    ;; "emacs-geiser" "emacs-geiser-guile"
    ;; files / disk / block
    "rclone" "restic"
    "parted" "lsof"
    "sqlite" "hdparm"
    ;; "smartmontools"
    ;; system
    "dool" "htop"
    "qemu"
    ;; evil
    "ungoogled-chromium")))

 (services
  (list

   ;; (service home-redshift-service-type
   ;;          (home-redshift-configuration
   ;;           (location-provider 'manual)
   ;;           (latitude 60)
   ;;           (longitude 10)))

   (service home-bash-service-type (home-bash-configuration))
   (service home-fish-service-type (home-fish-configuration
                                    (config (list (mixed-text-file
                                                   "fish-config.inc.fish"
                                                   "
set -xU LESS_TERMCAP_md (printf \"\\e[00;33m\")
set -xU LESS_TERMCAP_me (printf \"\\e[0m\")
set -xU LESS_TERMCAP_se (printf \"\\e[0m\")
set -xU LESS_TERMCAP_so (printf \"\\e[01;44;33m\")
set -xU LESS_TERMCAP_ue (printf \"\\e[0m\")


function chicken-guix-hack
  set -gx CHICKEN_INSTALL_PREFIX     /home/klm/tmp/eggs
  set -gx CHICKEN_INSTALL_REPOSITORY /home/klm/tmp/eggs
  set -gx CHICKEN_REPOSITORY_PATH    /home/klm/tmp/eggs /home/klm/.guix-home/profile/var/lib/chicken/11
end

function profile
  set -gx GUIX_PROFILE $argv[1]
  set --prepend fish_function_path /gnu/store/jiql3i7m69kw6mj5x4xay949l0ndzqna-fish-foreign-env-0.20190116/share/fish/functions
  fenv source $GUIX_PROFILE/etc/profile
  set -e fish_function_path[1]
end

# https://github.com/akermu/emacs-libvterm
if [ \"$INSIDE_EMACS\" = 'vterm' ]
    function clear
        vterm_printf \"51;Evterm-clear-scrollback\";
        tput clear;
    end

    function fish_title
        hostname
        echo \":\"
        pwd
    end

    function vterm_prompt_end;
        vterm_printf '51;A'(whoami)'@'(hostname)':'(pwd)
    end
    functions --copy fish_prompt vterm_old_fish_prompt
    function fish_prompt --description 'Write out the prompt; do not replace this. Instead, put this at end of your file.'
        # Remove the trailing newline from the original prompt. This is done
        # using the string builtin from fish, but to make sure any escape codes
        # are correctly interpreted, use %b for printf.
        printf \"%b\" (string join \"\n\" (vterm_old_fish_prompt))
        vterm_prompt_end
    end
end

if [ (tty) = '/dev/tty2' ]
  echo 'Starting X in 4 seconds. C-c to abort ...'
  sleep 4 && exec sx
end
"))))))))
