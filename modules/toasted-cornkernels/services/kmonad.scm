(define-module (toasted-cornkernels services kmonad)
  #:use-module (gnu services)
  #:use-module (gnu services shepherd)
  #:use-module (gnu services configuration)
  #:use-module (gnu packages haskell-apps)
  #:use-module (guix records)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (ice-9 match)
  #:export (kmonad-service-type
            kmonad-configuration
            kmonad-shepherd-service
            kmonad-service))

(define-record-type* <kmonad-configuration>
  kmonad-configuration ; constructor (macro) name
  make-kmonad-configuration ; constructor (function) name
  kmonad-configuration? ; characteristic function name
  (kmonad kmonad-configuration-kmonad
          (default kmonad))
  (kbd-location kmonad-configuration-kbd-location)
  (extra-options kmonad-configuration-options strings
                 (default '()))) ; required slot!

(define kmonad-shepherd-service
  (match-lambda
    (($ <kmonad-configuration> kmonad kbd-location extra-options)
     (list (shepherd-service            ; creates <shepherd-service>
            (provision '(kmonad))
            (documentation "Launch KMonad on system startup.")
            (requirement '(user-processes))
            (start #~(make-forkexec-constructor
                      (list #$(file-append kmonad "/bin/kmonad") kbd-location)))
            (stop #~(make-kill-destructor)))))))

(define kmonad-service-type
  (service-type
   (name 'kmonad)
   (extensions
    (list (service-extension shepherd-root-service-type
                             kmonad-shepherd-service)))
   (description "Launch kmonad on startup.")))

(define* (kmonad-service #:key (kmonad kmonad)
                         kbd-location
                         (extra-options '()))
  (service kmonad-service-type
           (kmonad-configuration
            (irssi irssi)
            (kbd-location kbd-location)
            (extra-options extra-options))))
