;;; to be used with guix system <action> system.scm

(use-modules (gnu)
	     (gnu packages shells)
	     (gnu packages ssh)
	     (gnu packages linux)
	     (gnu packages file)
	     (gnu packages pv)
	     (gnu packages rsync)
	     (gnu packages fonts)
	     (gnu packages tmux)
	     (gnu packages version-control)
	     (gnu packages curl)
             (gnu services pm)
             (gnu services desktop)
	     (gnu services avahi)
	     (gnu packages certs)
             ((gnu services cups) #:select (cups-service-type cups-configuration))
             (gnu packages cups)
             (gnu services sound)
             (gnu packages wm)
             (gnu services virtualization)
             ((gnu packages gnustep) #:select (windowmaker))
	     ;; ((gnu packages rust-apps) #:select (i3status-rust))
             (guix packages)
             (srfi srfi-1)
             ((guix utils) #:select (substitute-keyword-arguments)))

(use-service-modules networking ssh xorg dbus desktop sddm)

(define kl (keyboard-layout "us" "mac" #:options '("ctrl:nocaps")))

(operating-system
  (kernel-arguments
   (cons* "spectre_v2=eibrs,retpoline" ;; mitigate spectre v2 eBPF vulnerability
          ;; https://wiki.archlinux.org/title/Intel_graphics#Crash/freeze_on_low_power_Intel_CPUs
          "intel_idle.max_cstate=1" ;; CPU power states
          "i915.enable_dc=0"        ;; GPU power management
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
                  '("wheel" "netdev" "audio" "video" "disk" "floppy" "cdrom" "kvm" "input" "dialout")))
                %base-user-accounts))

  (sudoers-file (plain-file "sudoers" "\
root ALL=(ALL) ALL
%wheel ALL=NOPASSWD: ALL
"))

  (packages (cons*
	     btrfs-progs
	     file
	     pv
	     tmux
	     nss-certs
	     curl
	     git-minimal
             rsync
   	     %base-packages))

  (services
   (cons*

    (service xorg-server-service-type
	     (xorg-configuration
	      (fonts
	       (cons*
	        font-gnu-unifont
	        font-terminus
	        %default-xorg-fonts))
	      (keyboard-layout kl)))

    (service dhcp-client-service-type)

    (service cups-service-type
             (cups-configuration
              (web-interface? #t)
              (extensions (list cups-filters hplip))))

    (service openssh-service-type
	     (openssh-configuration
	      (openssh openssh-sans-x)
	      (password-authentication? #false)))


    (udev-rules-service 'avrdude
       (udev-rule "90-avrisp2.rules"
                  (string-append  "SUBSYSTEM==\"usb\", "
                                  "ATTRS{product}==\"AVRISP mkII\", "
                                  "ATTRS{idProduct}==\"2104\", "
                                  "ATTRS{idVendor}==\"03eb\", "
                                  "MODE=\"0660\", "
                                  "GROUP=\"dialout\"")))

    ;; (service gdm-service-type
    ;;          (gdm-configuration
    ;;           (auto-login-user "klm")
    ;;           (auto-login-session "i3")))

    ;; (modify-services %desktop-services (delete gdm-service-type))

    (service avahi-service-type)
    ;; (udisks-service)
    ;; (service upower-service-type)
    ;; (accountsservice-service)
    (service cups-pk-helper-service-type)
    ;; (service colord-service-type)
    ;; (geoclue-service)
    (service polkit-service-type)
    ;; (elogind-service)
    (dbus-service)

    ;; (service ntp-service-type)

    x11-socket-directory-service

    (service pulseaudio-service-type)
    (service alsa-service-type)

    (service mingetty-service-type (mingetty-configuration (tty "tty1")))
    (service mingetty-service-type (mingetty-configuration (tty "tty2") (auto-login "klm")))
    (service mingetty-service-type (mingetty-configuration (tty "tty3")))
    (service mingetty-service-type (mingetty-configuration (tty "tty4")))
    (service mingetty-service-type (mingetty-configuration (tty "tty5")))
    (service mingetty-service-type (mingetty-configuration (tty "tty6")))
    (service mingetty-service-type (mingetty-configuration (tty "tty7")))
    (service mingetty-service-type (mingetty-configuration (tty "tty8")))
    (service mingetty-service-type (mingetty-configuration (tty "tty9")))
    (service mingetty-service-type (mingetty-configuration (tty "tty0")))

    (modify-services %base-services
      (delete mingetty-service-type))))

  (hosts-file (plain-file "hosts"
                          (string-append
                           (local-host-aliases host-name) "\n"
                           "172.105.68.197 karl\n"
                           "167.235.141.165 furt")))


  (name-service-switch %mdns-host-lookup-nss)

  (mapped-devices (list
		   (mapped-device
		    (source "vgf")
		    (targets (list "vgf-nvm"))
		    (type lvm-device-mapping))))

  (file-systems
   (cons* (file-system
            (mount-point "/")
            (device "/dev/vgf/nvm")
	    (dependencies mapped-devices)
            (type "btrfs"))

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
    (terminal-outputs '(console serial))
    (targets `("/boot/efi"))
    (keyboard-layout kl))))
