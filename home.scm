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

(define-public i3status-rust-no-kdeconnect
  (package
    (inherit i3status-rust)
    (name "i3status-rust-no-kdeconnect")
    (arguments
     (substitute-keyword-arguments
         (package-arguments i3status-rust)
       ((#:phases old-phases)
        #~(modify-phases #$old-phases
            (replace 'wrap-i3status
              (lambda* (#:key outputs inputs #:allow-other-keys)
                (let ((out (assoc-ref outputs "out"))
                      (paths (map
                              (lambda (input)
                                (string-append (assoc-ref inputs input) "/bin"))
                              (list "alsa-utils" "coreutils" "curl" "dbus" "ibus"
                                    "iproute" "lm-sensors" "pulseaudio" "openssl"
                                    "setxkbmap" "speedtest-cli" "xdg-utils" "xrandr"
                                    "zlib"))))
                  (wrap-program (string-append out "/bin/i3status-rs")
                    `("PATH" prefix ,paths)))))))))
    (inputs (modify-inputs (package-inputs i3status-rust)
              (delete "kdeconnect")))))

(home-environment

 (packages
  (cons*
   i3status-rust-no-kdeconnect
   (specifications->packages
    (list
     ;; basic
     "file"
     "netcat"
     "pv" ;;               ,-- needed by gitk
     "git-minimal" "tig" "tk"
     "bat"
     "tmux"
     "curl"
     "zstd"
     "the-silver-searcher"
     "recutils"
     "rlwrap"
     "atool"
     "watchexec"
     "ncurses" ;; for tput
     "darkhttpd"
     ;; x
     "sx" "xrandr" "libxft" "xrdb"
     "setxkbmap" "xset"
     "i3-wm" "dmenu" "i3status" "font-awesome"
     "alacritty" ;; "lxterminal"
     "xclip"
     "redshift"
     "font-inconsolata"
     "xdg-utils" ;; <-- xdg-open
     "maim" "slop" ;; screen capture tools
     ;; doc
     "mupdf" "evince"
     "at-spi2-core" ;; <-- stops annoying org.a11y.Bus warnings in GTK apps
     "graphviz"
     ;; media
     "feh" "imv" "sxiv"
     "mpv" "ffmpeg" "sox"
     "inkscape" ;; "solvespace"
     "pulseaudio"
     ;; code
     "libqalculate"
     "the-silver-searcher"
     "cloc"
     "zile"
     "avr-binutils" "make"
     "chicken"
     ;; emacs
     "emacs"
     "emacs-zerodark-theme" "emacs-spacemacs-theme"
     "emacs-paren-face"
     "emacs-all-the-icons"
     "emacs-all-the-icons-completion"
     "emacs-all-the-icons-dired"
     "emacs-spaceline-all-the-icons" "emacs-powerline" "emacs-doom-modeline"
     "emacs-selectrum" "emacs-orderless" ;; "emacs-helm" "emacs-ivy"
     "emacs-ctrlf" "emacs-swiper" ;; i-search alternative
     "emacs-phi-search" ;; testing
     "emacs-git-gutter-fringe"
     "emacs-highlight-symbol"
     ;; "emacs-idle-highlight" ;; switched to highlight-symbol-mode
     "emacs-magit" "emacs-git-link"
     "emacs-multiple-cursors"
     "emacs-ace-window" "emacs-switch-window" "emacs-frames-only-mode" "emacs-window-purpose"
     "emacs-paredit" "emacs-smartparens" "emacs-aggressive-indent"
     "emacs-vterm"
     "emacs-tagedit"
     "emacs-dumb-jump"
     "emacs-fish-mode"
     "emacs-web-mode"
     "emacs-json-mode"
     "emacs-js2-mode"
     "emacs-rec-mode"
     "emacs-protobuf-mode"
     ;; "emacs-geiser" "emacs-geiser-guile"
     ;; files / disk
     "rclone" "restic"
     "parted" "lsof"
     "sqlite"
     ;; system
     "dstat" "htop"
     "qemu" "iperf"
     ;; evil
     "ungoogled-chromium"))))

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
  exec sx
end
"))))))))
