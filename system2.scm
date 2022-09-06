;;; to be used with guix system <action> system.scm

(use-modules (gnu)
	     (gnu packages shells)
	     (gnu packages ssh)
             (gnu services pm)
             (gnu services desktop)
             ((gnu services cups) #:select (cups-service-type cups-configuration))
             (gnu packages cups)
             (gnu services sound)
             (gnu packages wm)
             (gnu services virtualization)
             ((gnu packages gnustep) #:select (windowmaker))
	;;             ((gnu packages rust-apps) #:select (i3status-rust))
             (guix packages)
             (srfi srfi-1)
             ((guix utils) #:select (substitute-keyword-arguments)))

(use-service-modules networking ssh xorg dbus desktop sddm)

;; sigh, kdeconnect - it adds like 1700MB and I don't use it
`(define-public i3status-rust-no-kdeconnect
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

(define my-packages
  (map specification->package
       `("file" "netcat"
         "pv" "bat"
         "git" "tmux" "jq"
         "nss-certs")))

(define my-x-packages '())

;;  (map specification->package `("xinit" "xrandr" "stumpwm" "i3-wm" "i3blocks" "xst" "xrdb" "dmenu" "polybar")))

;; (set! my-x-packages (cons* i3status-rust-no-kdeconnect my-x-packages))

(define kl (keyboard-layout "us" "mac" #:options '("ctrl:nocaps")))

(define my-services
  (cons*

   
   (service special-files-service-type 
            `(("/usr/bin/PONGPONG" ,(file-append (canonical-package coreutils) "/bin/env"))
              ("/usr/bin/mystartx" "test123")))

   ;; (extra-special-file "mystartx"
   ;;                     (xorg-start-command
   ;;                      (xorg-configuration
   ;;                       ;; (fonts (cons* font-gnu-unifont
   ;;                       ;;               font-terminus
   ;;                       ;;               font-misc-cyrillic
   ;;                       ;;               %default-xorg-fonts))
   ;;                       (keyboard-layout kl))))


   (service cups-service-type
            (cups-configuration
             (web-interface? #t)
             (extensions (list cups-filters hplip))))
 
   (service openssh-service-type
	    (openssh-configuration
	     (openssh openssh-sans-x)
	     (password-authentication? #false)))

   (service sddm-service-type
            (sddm-configuration
             (auto-login-user "klm")
             (auto-login-session "i3")
             (xorg-configuration (xorg-configuration (keyboard-layout kl)))))

   ;; for `guix build --system=aarch64-linux` etc
   (service qemu-binfmt-service-type
            (qemu-binfmt-configuration
             (platforms (lookup-qemu-platforms "arm" "aarch64"))))
     
   ;;(service dhcp-client-service-type)
   ;;(service polkit-service-type)
   ;;(elogind-service)
   ;;(dbus-service)
   (modify-services %desktop-services
                    (delete gdm-service-type))))

(operating-system
  (kernel-arguments
   (cons* "spectre_v2=eibrs,retpoline" ;; mitigate spectre v2 eBPF vulnerability
          ;; https://wiki.archlinux.org/title/Intel_graphics#Crash/freeze_on_low_power_Intel_CPUs   
          "intel_idle.max_cstate=1"  ;; CPU power states
          "i915.enable_dc=0" ;; GPU power management
          "ahci.mobile_lpm_policy=1" ;; SATA power management
          %default-kernel-arguments))
  (locale "en_US.utf8")
  (timezone "Europe/Oslo")
  (keyboard-layout kl)
  (host-name "pal")

  (users (cons* (user-account
                 (name "klm")
                 (comment "John Doe")
                 (group "users")
                 (home-directory "/home/klm")
		 (shell (file-append fish "/bin/fish"))
                 (supplementary-groups
                  '("wheel" "netdev" "audio" "video" "disk" "floppy" "cdrom" "kvm")))
                %base-user-accounts))
  
  (sudoers-file (plain-file "sudoers" "\
root ALL=(ALL) ALL
%wheel ALL=NOPASSWD: ALL
"))
  
  (packages (append
             my-packages
             my-x-packages
             %base-packages))

  (services (cons* ;; I need this for `herd start cow-store /mnt` to work.
             ;; (service cow-store-service-type 'mooooh!)
             my-services))
  
  
  (mapped-devices (list
		   (mapped-device
		    (source "vg0")
		    (targets (list "vg0-s0"))
		    (type lvm-device-mapping)) ))

  (file-systems
   (cons* (file-system
            (mount-point "/")
            (device "/dev/vg0/s0")
	    (dependencies mapped-devices)
            (type "ext4"))

	  (file-system
	    (mount-point "/boot/efi")
	    (device (uuid "73F7-8562" 'fat))
	    (type "vfat"))

          (file-system
	    (mount-point "/raid")
	    (device (uuid "e2150870-2635-4a01-bcb2-d27dc48a6d9f" 'btrfs))
            (options "subvol=@bak")
            (create-mount-point? #t)
	    (type "btrfs"))         

          %base-file-systems))
		   
  (bootloader
   (bootloader-configuration
    (bootloader grub-efi-bootloader)
    (target `"/boot/efi")
    (keyboard-layout kl)))
 
  ;; allow resolution of '.local' host names with mDNS
  (name-service-switch %mdns-host-lookup-nss))

