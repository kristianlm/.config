;;; to be used in guix home <action> home.scm
(use-modules
  (gnu home)
  (gnu packages)
  (gnu services)
  (gnu services desktop)
  (guix gexp)
  (gnu home services ssh)
  (gnu home services xdg)
  (gnu home services shells))

(home-environment

 (packages
  (specifications->packages
   (list
    ;; basic
    "netcat"
    "pv"
    "git" "tig"
    "bat" 
    "tmux"
    "curl"
    "zstd"
    ;; x
    "xrandr" "libxft" "xrdb"
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
    "emacs" "emacs-zerodark-theme" "emacs-paren-face"
    "emacs-all-the-icons" "emacs-powerline"
    "emacs-selectrum" ;; "emacs-helm" "emacs-ivy"
    "emacs-git-gutter-fringe"
    
    "emacs-magit" "emacs-git-link"
    "emacs-multiple-cursors" 
    "emacs-parinfer-mode"
    "emacs-fish-mode"
    "emacs-web-mode"
    "emacs-json-mode"
    "emacs-js2-mode"
    "emacs-phi-search" ;; try this out
    "emacs-geiser" "emacs-geiser-guile"
    ;; files / disk
    "rclone" "restic"
    "parted" "lsof"
    ;; system
    "dstat" "htop"
    "qemu"
    "ungoogled-chromium")))
 
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
                                    (environment-variables `(("EDITOR" . "mg")
                                                             ("RESTIC_REPOSITORY" . "/raid/restic")
                                                             ;; fix this just for xst somehow
                                                             ("TERM" . "xterm")
                                                             ("LESS_TERMCAP_md" . "(printf \"\\e[00;33m\")")
                                                             ("LESS_TERMCAP_me" . "(printf \"\\e[0m\")")
                                                             ("LESS_TERMCAP_se" . "(printf \"\\e[0m\")")
                                                             ("LESS_TERMCAP_so" . "(printf \"\\e[01;44;33m\")")
                                                             ("LESS_TERMCAP_ue" . "(printf \"\\e[0m\")")
                                                             ("LESS_TERMCAP_us" . "(printf \"\\e[00;32m\")"))))))))
