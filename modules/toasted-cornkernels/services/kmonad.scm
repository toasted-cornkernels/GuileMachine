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
            kmonad-shepherd-service))


(define-record-type* <kmonad-configuration>
  kmonad-configuration ; constructor (macro) name
  make-kmonad-configuration ; constructor (function) name
  kmonad-configuration? ; characteristic function name
  (kmonad kmonad-configuration-kmonad (default kmonad))
  (kbd-location kmonad-configuration-kbd-location)) ; required slot!

(define (kmonad-shepherd-service config)
  (list (shepherd-service
         (provision '(kmonad))
         (requirement '(user-processes))
         (start #~(make-forkexec-contructor
                   (list #$(file-append kmonad "/bin/kmonad")
                         (kmonad-configuration-kbd-location
                          config))))
         (stop #~(make-kill-destructor)))))


(define kmonad-service-type
  (service-type
   (name 'kmonad)
   (extensions
    ;; TODO: extend activation-service-type
    (list (service-extension shepherd-root-service-type
                             kmonad-shepherd-service)))
   (default-value (kmonad-configuration (kbd-location "~/.config/kmonad/config.kbd")))
   (description "Launch kmonad on startup.")))
