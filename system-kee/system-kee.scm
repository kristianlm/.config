;; TODO: persist openssh host keys

;;; to be used with guix system <action> system.scm
(use-modules (gnu)
	     (gnu packages shells)
	     (gnu packages bash)
	     (gnu packages backup)
	     (gnu packages vpn)
	     (gnu packages web)
	     (gnu packages networking)
             (gnu packages text-editors)
             (gnu packages sqlite)
             (gnu packages readline)
	     (gnu packages ssh)
	     (gnu packages linux)
	     (gnu packages file)
	     (gnu packages compression)
	     (gnu packages pv)
	     (gnu packages rsync)
	     (gnu packages file-systems)
	     (gnu packages bittorrent)
	     (gnu packages man)
	     (gnu packages fonts)
	     (gnu packages disk)
	     (gnu packages tmux)
	     (gnu packages admin)
             (gnu packages vulkan)
	     (gnu packages version-control)
	     (gnu packages curl)
	     (gnu packages wget)
	     (gnu packages radio)
             ((gnu packages freedesktop) #:select (libatasmart))
             (gnu services pm)
             (gnu services desktop)
	     (gnu services avahi)
             (gnu services shepherd)
	     (gnu packages certs)
             ((gnu services cups) #:select (cups-service-type cups-configuration))
             (gnu packages cups)
             (gnu services sound)
             (gnu packages wm)
             (gnu services virtualization)
             (gnu services vpn)
             ((gnu packages gnustep) #:select (windowmaker))
             (guix packages)
             (srfi srfi-1)
             ((guix utils) #:select (substitute-keyword-arguments)))

(use-service-modules networking ssh xorg dbus desktop sddm)

(define kl (keyboard-layout "us" "mac" #:options '("ctrl:nocaps")))

(operating-system
  (kernel-arguments (append
                     (delete "quiet" %default-kernel-arguments)
                     ;;(list "console=ttyS0")
                     ))
  (label (string-append "kee " (package-full-name (operating-system-kernel this-operating-system))))
  (locale "en_US.utf8")
  (timezone "Europe/Oslo")
  (keyboard-layout kl)
  (host-name "kee")

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
	     file pv man-db atool

             smartmontools hdparm
             btrfs-progs lvm2 
             restic ;; bcachefs-tools <-- no i686 support

             zstd strace
             wireguard-tools 
             wget aria2 curl rsync
             darkhttpd netcat socat tcpdump
             git-minimal tig

             mg dool sqlite fdisk parted
             jq tmux rlwrap             
   	     %base-packages))

  (services
   (cons*
    (service wireguard-service-type
	     (wireguard-configuration
	      (addresses '("10.33.2.1/32"))
              (port 39511)
              (private-key (local-file (string-append (getenv "HOME") "/.config/.wireguard.key")))
              (peers
               (list (wireguard-peer
                      (name "karl")
                      (public-key "i3rLxk/sSX02BoYeqKfwcEAxSSDF7uh8EXkz/1ZB2HQ=")
                      (allowed-ips '("10.33.0.0/16"))
                      (endpoint "167.235.141.165:46537")
                      (keep-alive 25))
                     (wireguard-peer
                      (name "pal")
                      (public-key "l6R7qwHz/ANDU7RyKlhpDwMhEh7OBg8YKCd680UVH3A=")
                      (allowed-ips '("10.33.3.0/24"))
                      (endpoint "193.69.140.177:57284")
                      (keep-alive 25))
                     (wireguard-peer
                      (name "kth")
                      (public-key "oo8AwzuqMOX5l0zv8Xs57k8+uv6jP7ErdVQ+W0S0d00=")
                      (allowed-ips '("10.33.3.2/32")))))))

    (simple-service
     'br0 shepherd-root-service-type
     (let ((ip (file-append iproute "/sbin/ip")))
       (list (shepherd-service
              (documentation "Make a br0 bridge and attach enp0s31f6")
              ;;(one-shot? #t)
              (provision '(br0))
              (requirement '(user-processes))
              (start #~(lambda _
                         (invoke/quiet #$ip "link" "add" "name" "br0" "type" "bridge")
                         (invoke/quiet #$ip "link" "set" "br0" "up")
                         (invoke/quiet #$ip "link" "set" "eth0" "master" "br0")
                         (invoke/quiet #$ip "link" "set" "eth0" "up")))
              (stop #~(lambda _
                        (display "RUNNNNIIIINNNNNGG\n")                        
                        (system* #$ip "link" "del" "br0")
                        #f))))))

    (service dhcp-client-service-type
             (dhcp-client-configuration
              (interfaces '("br0"))
              (shepherd-requirement '(br0))))

    (service openssh-service-type
	     (openssh-configuration
	      (openssh openssh-sans-x)
              (permit-root-login #t)
              (authorized-keys
               `(("root" ,(local-file (string-append (getenv "HOME") "/.ssh/id_ed25519.pub")))))
	      (password-authentication? #f)))

    (udev-rules-service
     'hdparm ;; 240 + x = 30min * x
     (file->udev-rule
      "69-hdparm.rules"
      (mixed-text-file
       "69-hdparm.rules"
       "ACTION==\"add|change\", KERNEL==\"sd[a-z]\", ATTRS{queue/rotational}==\"1\", RUN+=\""
       hdparm "/sbin/hdparm"
       " -S 251 /dev/%k\"")))

    (udev-rules-service
     'eth0 ;; rename to eth0 so NIC name is same on QEMU and HW. need by br0.
     (file->udev-rule
      "10-eth0.rules"
      (mixed-text-file
       "10-eth0.rules"
       "SUBSYSTEM==\"net\", ACTION==\"add\", ATTR{address}==\"00:24:8c:78:c0:a9\", NAME=\"eth0\"")))

    (service avahi-service-type)
    (service polkit-service-type)
    (service dbus-root-service-type)
    (service pulseaudio-service-type)
    (service alsa-service-type)

    (simple-service 'add-extra-hosts
                    hosts-service-type
                    (list (host "167.235.141.165" "karl")
                          (host "193.69.140.177"  "pal")))

    %base-services))


  (name-service-switch %mdns-host-lookup-nss)

  (file-systems
   (cons* (file-system
           (mount-point "/")
           (device "/dev/sda1")
           (type "ext4"))
          
          ;; (file-system
          ;;  (mount-may-fail? #t)
          ;;  (device (uuid "7ef902a1-9a09-499e-831f-6492ee5a2705" 'ext4))
          ;;  (mount-point "/data")
          ;;  (create-mount-point? #t)
          ;;  (type "ext4"))

          %base-file-systems))
  
  ;; (swap-space
  ;;  (target (uuid "7fb6eddf-3afe-4b17-9d59-6d543b5f7302")))

  (bootloader (bootloader-configuration
               (bootloader grub-minimal-bootloader)
               (targets '("/dev/sda"))
               (terminal-outputs '(console serial)))))
