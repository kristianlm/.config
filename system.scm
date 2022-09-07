(use-modules (gnu)
	     (gnu packages shells)
	     (gnu packages ssh))
(use-service-modules networking ssh
		     ;; xorg desktop
		     )

(operating-system
  (locale "en_US.utf8")
  (timezone "Europe/Oslo")
  (keyboard-layout (keyboard-layout "us" "mac" #:options '("ctrl:nocaps")))
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
%wheel ALL=NOPASSWD: ALL\n"))
  
  (packages
    (append
      (map specification->package
	 `("i3-wm" "i3status"  "st" "dmenu" 
 	   "netcat" "pv" "bat"
 	   "git" "tmux"
           "nss-certs")
      %base-packages))

  (services
   (cons*
    ;;(set-xorg-configuration (xorg-configuration (keyboard-layout keyboard-layout)))
    (service dhcp-client-service-type)
    (service openssh-service-type
	     (openssh-configuration
	      (openssh openssh-sans-x)
	      (password-authentication? #false)))
    %base-services))
  
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

           %base-file-systems))
		   
  (bootloader
    (bootloader-configuration
      (bootloader grub-efi-bootloader)
      (target "/boot/efi")
      (keyboard-layout keyboard-layout))))

