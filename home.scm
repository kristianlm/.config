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
     "pv"
     "git-minimal" "tig"
     "bat"
     "tmux"
     "curl"
     "zstd"
     "the-silver-searcher"
     "recutils"
     ;; x
     "sx" "xrandr" "libxft" "xrdb"
     "setxkbmap" "xset"
     "i3-wm" "dmenu" "i3status" "font-awesome"
     "alacritty" ;; "lxterminal"
     "xclip"
     "redshift"
     "font-inconsolata"
     "xdg-utils" ;; <-- xdg-open
     ;; doc
     "mupdf" "evince"
     "graphviz"
     ;; code
     "libqalculate"
     "the-silver-searcher"
     "cloc"
     "zile"
     ;; emacs
     "emacs"
     "emacs-zerodark-theme" "emacs-spacemacs-theme"
     "emacs-paren-face"
     "emacs-all-the-icons"
     "emacs-all-the-icons-completion"
     "emacs-all-the-icons-dired"
     "emacs-spaceline-all-the-icons" "emacs-powerline" "emacs-doom-modeline"
     "emacs-selectrum" ;; "emacs-helm" "emacs-ivy"
     "emacs-git-gutter-fringe"
     "emacs-highlight-symbol"
     "emacs-idle-highlight"
     "emacs-magit" "emacs-git-link"
     "emacs-multiple-cursors"
     "emacs-paredit" "emacs-smartparens"
     "emacs-tagedit"
     "emacs-fish-mode"
     "emacs-web-mode"
     "emacs-json-mode"
     "emacs-js2-mode"
     "emacs-phi-search" ;; testing
     "emacs-rec-mode"
     "emacs-geiser" "emacs-geiser-guile"
     ;; files / disk
     "rclone" "restic"
     "parted" "lsof"
     ;; system
     "dstat" "htop"
     "qemu"
     "ungoogled-chromium"))))

 (services
  (list

   ;; (service home-redshift-service-type
   ;;          (home-redshift-configuration
   ;;           (location-provider 'manual)
   ;;           (latitude 60)
   ;;           (longitude 10)))

   ;;(service home-xdg-base-directories-service-type)
   ;;(service home-xdg-user-directories-service-type)
   ;;(service home-xdg-mime-applications-service-type)

   (service home-openssh-service-type
            (home-openssh-configuration
             (hosts (list (openssh-host (name "karl")
                                        (host-name "172.105.68.197")
                                        (user "root")
                                        (address-family AF_INET)
                                        (port 21725))))
             (authorized-keys
              (list (plain-file "android_kon.pub" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIihGz367N113w20fv/zXiieSqCNvPvIxEN32S5fadiW droid@kon")))))
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
if [ (tty) = '/dev/tty2' ]
  exec sx
end
"))))))))
