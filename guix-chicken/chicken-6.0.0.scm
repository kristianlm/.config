(use-modules
 (guix packages)
 (guix build-system gnu)
 (guix download)
 ((guix licenses) #:prefix license:)

 (guix gexp)
 (guix build-system)
 (guix utils)
 (guix search-paths)
 (guix monads)
 (guix store)
 (guix git-download)
  ;;(guix build-system chicken)

 (gnu packages c)
 )

;; ================================================================================
;; chicken iteslf

(define-public chicken-6.0.0
  (package
    (name "chicken6")
    (version "6.0.0")
    (source (origin
              (method url-fetch)
              (uri "https://code.call-cc.org/releases/6.0.0/chicken-6.0.0.tar.gz")
              (sha256 ;;"92835552b1b687ad26737e429b5aba36510bf429f8816ec0f6d336c8cb41f443"
                      (base32 "0hzl875whdnkyv06x0gq57s0nl9np9d9nhkyfckav1xnn595b0wj")
                      )))
    (build-system gnu-build-system)
    (arguments
     `(#:modules ((guix build gnu-build-system)
                  (guix build utils)
                  (srfi srfi-1))

       ;; No `configure' script; run "make check" after "make install" as
       ;; prescribed by README.
       #:phases
       (modify-phases %standard-phases
         (replace 'configure
           (lambda* (#:key inputs outputs #:allow-other-keys)
             (let ((out   (assoc-ref outputs "out")))
               (invoke "./configure"
                       (string-append "--prefix=" out)
                       (string-append "--vardir=" out "/var/lib")
                       (string-append "--program-suffix=6")))))
         (delete 'check)
         ;; (add-after 'install 'check
         ;;   (assoc-ref %standard-phases 'check))
         )))

    ;; (native-search-paths
    ;;  (list (search-path-specification
    ;;          (variable "CHICKEN_REPOSITORY_PATH")
    ;;          ;; TODO extract binary version into a module level definition.
    ;;          (files (list "var/lib/chicken/12")))))

    ;; Reference gcc-toolchain lazily to avoid circular module dependency
    ;; problems.
    (propagated-inputs (list (module-ref (resolve-interface
                                          '(gnu packages commencement))
                                         'gcc-toolchain)))
    (home-page "https://www.call-cc.org/")
    (synopsis "R7RS Scheme implementation that compiles native code via C")
    (description
     "CHICKEN is a compiler for the Scheme programming language.  CHICKEN
produces portable and efficient C, supports almost all of the R5RS Scheme
language standard, and includes many enhancements and extensions.")
    (license license:bsd-3)))

(define-public chicken-git
  (let ((commit "3c94817513d9f511802f84decbcb5ee796bc6c19")
        (version "6.0.1")
        (revision "3"))
    (package
      (name "chicken6git")
      (version (git-version version revision commit))
      (source (origin
                (method git-fetch)
                (uri (git-reference
                       (url "git://code.call-cc.org/chicken-core")
                       (commit commit)))
                (file-name (git-file-name name version))
                (sha256
                 (base32
                  "0d1skm1v4kz1wksv9fgqi7k2lgz5kvckwq4jh6prszfx7fjlld7q"))))
      (build-system gnu-build-system)
      (arguments
       `(#:modules ((guix build gnu-build-system)
                    (guix build utils)
                    (srfi srfi-1))

         ;; No `configure' script; run "make check" after "make install" as
         ;; prescribed by README.
         #:phases
         (modify-phases %standard-phases
           (replace 'configure
             (lambda* (#:key inputs outputs #:allow-other-keys)
               (let ((out   (assoc-ref outputs "out"))
                     (chicken    (assoc-ref inputs "chicken6"))
                     ;;(tcc (assoc-ref inputs "tcc"))
                     )
                 (invoke "./configure"
                         ;; (string-append "--c-compiler=" tcc "/bin/tcc")
                         (string-append "--chicken=" chicken "/bin/chicken6")
                         (string-append "--prefix=" out)
                         (string-append "--vardir=" out "/var/lib")
                         (string-append "--program-suffix=6git")))))
           (delete 'check)
           (delete 'validate-runpath) ;; TODO why is this failing with TCC?
           ;; (add-after 'install 'check
           ;;   (assoc-ref %standard-phases 'check))
           )

         #:make-flags (let ((out (assoc-ref %outputs "out")))
                        (list (string-append "DESTDIR=/")))))

      ;; (native-search-paths
      ;;  (list (search-path-specification
      ;;          (variable "CHICKEN_REPOSITORY_PATH")
      ;;          ;; TODO extract binary version into a module level definition.
      ;;          (files (list "var/lib/chicken/12")))))

      ;; Reference gcc-toolchain lazily to avoid circular module dependency
      ;; problems.

      ;; TODO: turn into native-inputs so we don't clobber env with
      ;; build dependencies. note th
      (native-inputs (list
                      chicken-6.0.0))
      (home-page "https://www.call-cc.org/")
      (synopsis "R7RS Scheme implementation that compiles native code via C")
      (description
       "CHICKEN is a compiler for the Scheme programming language.  CHICKEN
produces portable and efficient C, supports almost all of the R5RS Scheme
language standard, and includes many enhancements and extensions.")
      (license license:bsd-3))))


;; ================================================================================
;; chicken build system

(define %chicken-build-system-modules
  ;; Build-side modules imported and used by default.
  `((guix build chicken-build-system)
    (guix build union)
    ,@%default-gnu-imported-modules))

(define (default-chicken)
  ;; Lazily resolve the binding to avoid a circular dependency.
  chicken-6.0.0)

(define* (lower name
                #:key source inputs native-inputs outputs system target
                (chicken (default-chicken))
                #:allow-other-keys
                #:rest arguments)
  "Return a bag for NAME."
  (define private-keywords
    '(#:target #:chicken #:inputs #:native-inputs))

  ;; TODO: cross-compilation support
  (and (not target)
       (bag
         (name name)
         (system system)
         (host-inputs `(,@(if source
                              `(("source" ,source))
                              '())
                        ,@inputs

                        ;; Keep the standard inputs of 'gnu-build-system', since
                        ;; Chicken compiles Scheme by using C as an intermediate
                        ;; language.
                        ,@(standard-packages)))
         (build-inputs `(("chicken" ,chicken)
                         ,@native-inputs))
         (outputs outputs)
         (build chicken-build)
         (arguments (strip-keyword-arguments private-keywords arguments)))))

(define* (chicken-build name inputs
                        #:key
                        source
                        (phases '%standard-phases)
                        (outputs '("out"))
                        (search-paths '())
                        (egg-name "")
                        (unpack-path "")
                        (build-flags ''())
                        (tests? #t)
                        (system (%current-system))
                        (guile #f)
                        (imported-modules %chicken-build-system-modules)
                        (modules '((guix build chicken-build-system)
                                   (guix build union)
                                   (guix build utils))))
  (define builder
    (with-imported-modules imported-modules
      #~(begin
          (use-modules #$@(sexp->gexp modules))
          (chicken-build #:name #$name
                         #:source #+source
                         #:system #$system
                         #:phases #$phases
                         #:outputs #$(outputs->gexp outputs)
                         #:search-paths '#$(sexp->gexp
                                            (map search-path-specification->sexp
                                                 search-paths))
                         #:egg-name #$egg-name
                         #:unpack-path #$unpack-path
                         #:build-flags #$build-flags
                         #:tests? #$tests?
                         #:inputs #$(input-tuples->gexp inputs)))))

  (mlet %store-monad ((guile (package->derivation (or guile (default-guile))
                                                  system #:graft? #f)))
    (gexp->derivation name builder
                      #:system system
                      #:guile-for-build guile)))

(define chicken-build-system
  (build-system
    (name 'chicken)
    (description
     "Build system for Chicken Scheme programs")
    (lower lower)))

;; ==============================

(define-public chicken-test
  (package
    (name "chicken-test")
    (version "1.1")
    (source
     (origin
       (method url-fetch)
       (uri "https://code.call-cc.org/egg-tarballs/6/test/test-1.3.tar.gz")
       (file-name (string-append "chicken-test-" version "-checkout"))
       (sha256
        (base32
         "0wifl5lwijfx555agwrxa4l3pc8hyh79n4knlq9mrbrrq2ydyxf6"))))
    (build-system chicken-build-system)
    (arguments '(#:egg-name "test"))
    (home-page "https://wiki.call-cc.org/eggref/5/test")
    (synopsis "Yet another testing utility")
    (description
     "This package provides a simple testing utility for CHICKEN Scheme.")
    (license license:bsd-3)))

(define-public chicken-srfi-1
  (package
    (name "chicken-compile-file")
    (version "1.3")
    (source (origin
              (method url-fetch)
              (uri "https://code.call-cc.org/egg-tarballs/6/srfi-1/srfi-1-0.5.tar.gz")
              (sha256
               (base32
                "1q4dp2f5wgdwyx1j6v9vx9fscfyx9s7cx7bqpa2safmlc850af8d"))))
    (build-system chicken-build-system)
    (arguments `(#:egg-name "srfi-1"))
    (inputs
     (list chicken-test))
    (home-page "https://wiki.call-cc.org/egg/compile-file")
    (synopsis "Programmatic compiler invocation")
    (description "This egg provides a way to do on-the-fly compilation of
source code and load it into the running process.")
    (license license:bsd-3)))

chicken-6.0.0
chicken-git
