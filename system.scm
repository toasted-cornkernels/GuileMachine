(use-modules
 (gnu)
 (gnu packages linux)
 (gnu packages haskell-apps)
 (gnu packages audio)
 (gnu packages bash)
 (gnu packages shells)
 (gnu packages lisp)
 (gnu packages wm)
 (gnu packages networking)
 (gnu packages gnome)
 (gnu packages admin)
 (gnu services networking)
 (gnu services sound)
 (nongnu packages linux)
 (toasted-cornkernels services kmonad))

(use-package-modules fonts shells wm)
(use-service-modules cups desktop networking ssh xorg dbus)

(operating-system
 (kernel linux)
 (firmware (list linux-firmware))
 (locale "en_US.utf8")
 (timezone "America/Los_Angeles")
 (keyboard-layout (keyboard-layout "us"))
 (host-name "lisp-machine")

 ;; The list of user accounts ('root' is implicit).
 (users (cons* (user-account
	        (name "jslee")
	        (comment "namudontdie")
	        (group "users")
                (supplementary-groups '("wheel" "netdev" "audio" "video"))
                (shell (file-append zsh "/bin/zsh"))
                (home-directory "/home/jslee"))
	       %base-user-accounts))

 ;; List of packages installed system-wide.
 (packages (append (list (specification->package "nss-certs"))
		   (list zsh bluez bluez-alsa blueman)
		   (list sbcl stumpwm `(,stumpwm "lib") sbcl-stumpwm-ttf-fonts font-dejavu)
                   (list network-manager wpa-supplicant)
                   (list kmonad)
                   %base-packages))

 ;; List of system services.
 ;; network-manager-service-type and wpa-supplicant-service-type
 ;; are already included in %desktop-services;
 ;; to customize them, use (modify-services %desktop-services custom-config).
 (services
   (cons*
    (service openssh-service-type)
    (service cups-service-type)
    (set-xorg-configuration
     (xorg-configuration (keyboard-layout keyboard-layout)))
    (service bluetooth-service-type
	     (bluetooth-configuration (auto-enable? #t)))
    (kmonad-service #:kbd-location "~/.config/kmonad/tutorial.kbd")
    (simple-service 'blueman dbus-root-service-type (list blueman))
    (modify-services %desktop-services
                     (udev-service-type config =>
                                        (udev-configuration (inherit config)
                                                            (rules (cons kmonad (udev-configuration-rules config))))))))
 (bootloader (bootloader-configuration
	      (bootloader grub-efi-bootloader)
	      (targets (list "/boot/efi"))
	      (keyboard-layout keyboard-layout)))
 (swap-devices (list (swap-space
		      (target (uuid
			       "8d228ea7-d6e1-4040-aecd-3663cae265e8")))))

 ;; The list of file systems that get "mounted".  The unique
 ;; file system identifiers there ("UUIDs") can be obtained
 ;; by running 'blkid' in a terminal.
 (file-systems (cons* (file-system
		       (mount-point "/boot/efi")
		       (device (uuid "5975-58B4"
				     'fat32))
		       (type "vfat"))
		      (file-system
		       (mount-point "/")
		       (device (uuid
				"b0523573-ba66-4e7c-992e-dd683c80b1b1"
				'ext4))
		       (type "ext4")) %base-file-systems)))
