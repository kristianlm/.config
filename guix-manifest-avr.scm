(import (gnu packages gcc)
        (gnu packages avr)
        (gnu packages cross-base)
        (gnu packages flashing-tools)
        (gnu packages python)
        (gnu packages autotools)
        (guix utils)
        (guix memoization)
        (guix gexp)
        (guix packages)
        (guix git-download)
        (guix build-system gnu)
        (guix build-system trivial)
        (prefix (guix licenses) license:))

(define make-avr-binutils
  (mlambda ()
    (package
      (inherit (cross-binutils "avr"))
      (name "avr-binutils"))))

(define* (make-avr-libc/implementation #:key
                                       (xbinutils (cross-binutils "avr"))
                                       (xgcc (cross-gcc "avr"
                                                        #:xbinutils xbinutils)))
  (let ((commit "55e8cac69935657bcd3e4d938750960c757844c3")
        (revision "1")) ;; post-2.1 they say
    (package
      (name "avr-libc")
      (version (git-version "2.1" revision commit))
      (source (origin
                (method git-fetch)
                (uri (git-reference
                      (url "https://github.com/avrdudes/avr-libc")
                      (commit commit)))
                (file-name (git-file-name name version))
                (sha256
                 (base32 "00zgrd8sy7449hycr6429flv2ivddndbjvz0bi62sjalqyy7f3w7"))))
      (build-system gnu-build-system)
      (arguments
       '(#:out-of-source? #t
         #:configure-flags '("--host=avr")
         #:implicit-cross-inputs? #f
         #:phases
         (modify-phases %standard-phases
           (add-after 'unpack 'fix-shebangs
             (lambda _
               (substitute* "devtools/gen-avr-lib-tree.sh"
                 (("#! /bin/sh") (string-append "#!" (which "sh"))))
               (substitute* "devtools/mlib-gen.py"
                 (("#!/usr/bin/env python") (string-append "#!" (which "python3")))))))))

      (native-inputs `(("cross-binutils" ,xbinutils)
                       ("cross-gcc" ,xgcc)
                       ("python" ,python)
                       ("automake" ,automake)
                       ("autoconf" ,autoconf)))
      (home-page "https://www.nongnu.org/avr-libc/")
      (synopsis "The AVR C Library")
      (description
       "AVR Libc is a project whose goal is to provide a high quality C library
for use with GCC on Atmel AVR microcontrollers.")
      (license
       (license:non-copyleft "http://www.nongnu.org/avr-libc/LICENSE.txt")))))

(define* (make-avr-gcc/implementation #:key (xgcc gcc))
  "Return a XGCC-base cross-compiler for the AVR target."
  (let ((xgcc (cross-gcc "avr" #:xgcc xgcc #:xbinutils (make-avr-binutils))))
    (package
      (inherit xgcc)
      (name "avr-gcc")
      (arguments
       (substitute-keyword-arguments (package-arguments xgcc)
         ((#:phases phases)
          #~(modify-phases #$phases
              (add-after 'set-paths 'augment-CPLUS_INCLUDE_PATH
                (lambda* (#:key inputs #:allow-other-keys)
                  (let ((gcc (assoc-ref inputs  "gcc")))
                    ;; Remove the default compiler from CPLUS_INCLUDE_PATH
                    ;; to prevent header conflict with the GCC from
                    ;; native-inputs.
                    (setenv "CPLUS_INCLUDE_PATH"
                            (string-join
                             (delete (string-append gcc "/include/c++")
                                     (string-split (getenv "CPLUS_INCLUDE_PATH")
                                                   #\:))
                             ":"))
                    (format #t
                            "environment variable `CPLUS_INCLUDE_PATH' \
changed to ~a~%"
                            (getenv "CPLUS_INCLUDE_PATH")))))))))
      (native-search-paths
       (list (search-path-specification
              (variable "CROSS_C_INCLUDE_PATH")
              (files '("avr/include")))
             (search-path-specification
              (variable "CROSS_CPLUS_INCLUDE_PATH")
              (files '("avr/include")))
             (search-path-specification
              (variable "CROSS_OBJC_INCLUDE_PATH")
              (files '("avr/include")))
             (search-path-specification
              (variable "CROSS_OBJCPLUS_INCLUDE_PATH")
              (files '("avr/include")))
             (search-path-specification
              (variable "CROSS_LIBRARY_PATH")
              (files '("avr/lib")))))
      (native-inputs
       `(("gcc" ,gcc)
         ,@(package-native-inputs xgcc))))))

;;(make-avr-binutils)
;;(make-avr-libc/implementation #:xgcc (cross-gcc "avr" #:xgcc gcc-13))
;;migrating: (make-avr-gcc/implementation #:xgcc gcc-13)




(cross-gcc "avr"
           #:xgcc gcc-13
           ;;#:xbinutils (make-avr-binutils)
           ;;#:libc (make-avr-libc/implementation #:xgcc (cross-gcc "avr" #:xgcc gcc-13))
           ;;(make-avr-libc/implementation #:xgcc (cross-gcc "avr" #:xgcc gcc))
           )

;;(make-avr-libc/implementation #:xgcc (cross-gcc "avr" #:xgcc gcc-13))

