;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Kristian's GUIX workstation config
;;; guix system <action> system.scm
;;;
;;; TODO :
;;; fix klm@pal ~ > sudo mkdir -p $XDG_RUNTIME_DIR ; sudo chown klm:users -R /run/user/1000
;;; fix annoying autologin getty mess
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-modules (gnu)
	     (gnu packages shells)
	     (gnu packages bash)
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
             (gnu packages networking)
             (gnu services virtualization)
             (gnu services vpn)
             ((gnu packages gnustep) #:select (windowmaker))
	     ;; ((gnu packages rust-apps) #:select (i3status-rust))
             (guix packages)
             (srfi srfi-1)
             ((guix utils) #:select (substitute-keyword-arguments)))

(use-service-modules networking ssh xorg dbus desktop sddm)

(define kl (keyboard-layout "us" "mac" #:options '("ctrl:nocaps")))

;; (list #~(job '(next-hour '(3 9  15 21))
;;              (lambda ()
;;                (execl (string-append #$libatasmart "/bin/skdump")
;;                       "updatedb"
;;                       "--prunepaths=/tmp /var/tmp /gnu/store"))
;;              "skdump"))

;; (program-file
;;  "whoa-repl.scm"
;;  (with-imported-modules (source-module-closure
;;                          '((guix build utils)))
;;    #~(begin
;;        (use-modules (guix build utils)
;;                     (ice-9 popen)
;;                     (ice-9 regex)
;;                     (ice-9 textual-ports)
;;                     (srfi srfi-2))

;;        (define %min-level 20)

;;        (setenv "LC_ALL" "C")            ;ensure English output
;;        (and-let* ((input-pipe (open-pipe*
;;                                OPEN_READ
;;                                #$ (file-append acpi "/bin/acpi")))
;;                   (output (get-string-all input-pipe))
;;                   (m (string-match "Discharging, ([0-9]+)%" output))
;;                   (level (string->number (match:substring m 1)))
;;                   ((< level %min-level)))
;;          (format #t "warning: Battery level is low (~a%)~%" level)
;;          (invoke #$(file-append beep "/bin/beep") "-r5")))))
;; (execl #~(string-append #$libatasmart "/bin/skdump"))

(operating-system
  (kernel-arguments
   (list "spectre_v2=eibrs,retpoline" ;; mitigate spectre v2 eBPF vulnerability
         ;; https://wiki.archlinux.org/title/Intel_graphics#Crash/freeze_on_low_power_Intel_CPUs
         "intel_idle.max_cstate=1"  ;; CPU power states
         "i915.enable_dc=0"         ;; GPU power management
         "ahci.mobile_lpm_policy=1" ;; SATA power management
         "modprobe.blacklisk=amdgpu,usbmouse,usbkbd"
         "amdgpu.blacklist=1"
         "blacklist=amdgpu,usbmouse,usbkbd"
         "rd.driver.blacklist=amdgpu"
         "radeon.runpm=0"
         "intel_iommu=on"
         ;;%default-kernel-arguments
         ))
  (label (string-append "pal " (package-full-name (operating-system-kernel this-operating-system))))
  (locale "en_US.utf8")
  (timezone "Europe/Oslo")
  (keyboard-layout kl)
  (host-name "pal")

  ;;(groups (cons* (user-group (name "backup"))
  ;;               %base-groups))
  (users (cons* (user-account
                 (name "klm")
                 (comment "John Doe")
                 (group "users")
                 (home-directory "/home/klm")
		 (shell (file-append fish "/bin/fish"))
                 (supplementary-groups
                  '("wheel" "netdev" "audio" "video" "disk" "floppy" "cdrom" "kvm" "input" "dialout")))

                                        ;              (user-account
                                        ;               (name "backup")
                                        ;               (comment "Backup User")
                                        ;               (group "backup")
                                        ;               (home-directory "/")
                                        ;               (shell (file-append bash "/sbin/bash"))
                                        ;               (create-home-directory? #t)
                                        ;               (system? #t)
                                        ;               (supplementary-groups '()))

                %base-user-accounts))

  (sudoers-file (plain-file "sudoers" "\
root ALL=(ALL) ALL
%wheel ALL=NOPASSWD: ALL
"))

  (packages (cons*
             ;; nice to haves
             wget aria2
             smartmontools
             ;; must haves
	     btrfs-progs
             bcachefs-tools
	     file
	     pv
	     tmux
             zstd
             strace
             tcpdump
	     curl
	     git-minimal
             rsync
             lvm2
             man-db
             vulkan-loader vulkan-tools
   	     %base-packages))

  (services
   (cons*

    (service wireguard-service-type
	     (wireguard-configuration
              ;; /etc/wireguard/private.key default
	      (addresses '("10.33.3.1/32"))
              (port 57284)
              (peers
               (list (wireguard-peer
                      (name "karl")
                      (public-key "i3rLxk/sSX02BoYeqKfwcEAxSSDF7uh8EXkz/1ZB2HQ=")
                      (allowed-ips '("10.33.0.0/16"))
                      (endpoint "167.235.141.165:46537")
                      (keep-alive 25))
                     (wireguard-peer
                      (name "kth")
                      (public-key "oo8AwzuqMOX5l0zv8Xs57k8+uv6jP7ErdVQ+W0S0d00=")
                      (allowed-ips '("10.33.3.2/32")))
                     (wireguard-peer
                      (name "alf")
                      (public-key "kxPyVg5+Pw1/vdRxRhMFjAsbaZKGMKgCdh1frGYn3Tk=")
                      (allowed-ips '("10.33.1.0/24")) )
                     (wireguard-peer
                      (name "kon")
                      (public-key "vkP7Bm5BVR1GnieMpfsXNMlsVJVQm3Xq4hD+3GSuTCM=")
                      (allowed-ips '("10.33.11.0/24")) )
                     (wireguard-peer
                      (name "kee")
                      (public-key "abl1S+L9adbzYzCpnhe7wW3x3u/aq4bnF86YA5nT2SY=")
                      (allowed-ips '("10.33.2.0/24")))))))

    ;; goo'ol fashion manual configuration style
    (simple-service
     'nebula shepherd-root-service-type
     (list (shepherd-service
            (documentation "Run nebula on /etc/nebula/config.yml")
            (provision '(nebula))
            (requirement '(networking))
            (start #~(make-forkexec-constructor
                      (list #$(file-append nebula "/bin/nebula")
                            "--config" "/etc/nebula/config.yml")
                      #:log-file "/var/log/nebula.log"))
            (stop #~(make-kill-destructor)))))


    (service xorg-server-service-type
	     (xorg-configuration
              ;; (modules (list xf86-video-ati))
	      (fonts
	       (cons*
	        font-gnu-unifont
	        font-terminus
	        %default-xorg-fonts))
	      (keyboard-layout kl)))

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
                         (invoke/quiet #$ip "link" "set" "enp0s31f6" "master" "br0")
                         (invoke/quiet #$ip "link" "set" "enp0s31f6" "up")))
              ;; I THINK stop is ignored for one-shot ...
              (stop #~(lambda _
                        (display "RUNNNNIIIINNNNNGG\n")
                        (system* #$ip "link" "del" "br0")
                        #f))))))

    ;; <start>:
    ;; ip l add name br0 type bridge
    ;; ip l set br0 up
    ;; ip l set enp0s31f6 master br0
    ;; <stop>:
    ;; ip l del br0

    (service dhcp-client-service-type
             (dhcp-client-configuration
              (interfaces '("br0"))
              (shepherd-requirement '(br0))))

    (service cups-service-type
             (cups-configuration
              (web-interface? #t)
              (extensions (list cups-filters hplip-minimal))))

    (service openssh-service-type
	     (openssh-configuration
	      (openssh openssh-sans-x)
	      (password-authentication? #f)
                                        ;             (extra-content "
                                        ;Match User backup
                                        ;  Force-command internal-sftp
                                        ;  ChrootDirectory /raid/backup/mlm/")

              ))

    (udev-rules-service 'rtl-sdr rtl-sdr)
    (udev-rules-service 'avrdude
                        (udev-rule "90-avrisp2.rules"
                                   (string-append  "SUBSYSTEM==\"usb\", "
                                                   "ATTRS{product}==\"AVRISP mkII\", "
                                                   "ATTRS{idProduct}==\"2104\", "
                                                   "ATTRS{idVendor}==\"03eb\", "
                                                   "MODE=\"0660\", "
                                                   "GROUP=\"dialout\"")))
    (udev-rules-service
     'hdparm ;; 240 + x = 30min * x
     (file->udev-rule
      "69-hdparm.rules"
      (mixed-text-file
       "69-hdparm.rules"
       "ACTION==\"add|change\", KERNEL==\"sd[a-z]\", ATTRS{queue/rotational}==\"1\", RUN+=\""
       hdparm "/sbin/hdparm"
       " -S 251 /dev/%k\"")))

    (service avahi-service-type)
    ;; (udisks-service)
    ;; (service upower-service-type)
    ;; (accountsservice-service)
    (service cups-pk-helper-service-type)
    ;; (service colord-service-type)
    ;; (geoclue-service)
    (service polkit-service-type)
    ;; (elogind-service)
    (service dbus-root-service-type)

    ;; (service ntp-service-type)

    (service x11-socket-directory-service-type)

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

    (simple-service 'add-extra-hosts
                    hosts-service-type
                    (list (host "167.235.141.165" "karl")
                          (host "10.77.4.1" "mth")
                          (host "10.77.3.22" "isa")))

    (modify-services %base-services
      (delete mingetty-service-type)
      (delete agetty-service-type))))


  (name-service-switch %mdns-host-lookup-nss)

  (mapped-devices (list
		   (mapped-device
		    (source "vgf")
		    (targets (list "vgf-nvm"))
		    (type lvm-device-mapping))))

  (file-systems
   (cons* (file-system
            (mount-point "/")
            (device "/dev/vgf/s3")
	    (dependencies mapped-devices)
            (type "btrfs"))

	  (file-system
	    (mount-point "/boot/efi")
	    (device (uuid "428E-396D" 'fat))
	    (type "vfat"))

          (file-system
	    (mount-point "/raid")
	    (mount-may-fail? #t)
	    (device (uuid "e2150870-2635-4a01-bcb2-d27dc48a6d9f" 'btrfs))
            (options "subvol=@bak")
            (create-mount-point? #t)
	    (type "btrfs"))

          (file-system
	    (mount-point "/tull")
	    (mount-may-fail? #t)
	    (device (uuid "cd61f347-ca1a-4dc6-b91c-9d2b8eb50062" 'btrfs))
            (options "subvol=/")
            (create-mount-point? #t)
	    (type "btrfs"))

          %base-file-systems))

  (bootloader
   (bootloader-configuration
    (bootloader grub-efi-bootloader)
    ;; (terminal-outputs '(console serial))
    (targets `("/boot/efi"))
    (keyboard-layout kl))))


;; TODO: TRY THIS OUT
;; (simple-service
;;    'disable-kinesis-wakeup
;;    shepherd-root-service-type
;;    (list
;;     (shepherd-service
;;      (requirement '(file-systems))
;;      (provision '(disable-keyboard-wakeup))
;;      (documentation "echo XHC >/proc/acpi/wakeup, so that my USB Kinesis keyboard doesn't wake up the laptop right after a suspend")
;;      (one-shot? #t)
;;      (start
;;       #~(begin
;;           (use-modules (ice-9 regex))
;;           (use-modules (ice-9 textual-ports))
;;           (lambda _
;;             (when (string-match "XHC\t  S3\t\\*enabled"
;;                                 (call-with-input-file "/proc/acpi/wakeup"
;;                                   get-string-all))
;;               (display "Turning off usb wakeup\n")
;;               (with-output-to-file "/proc/acpi/wakeup"
;;                 (lambda _
;;                   (display "XHC"))))))))))
