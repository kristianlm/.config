
;; I don't need the tutorial anymore
(setq inhibit-startup-message t)
(setq visible-bell 1) ;; get rid of that annoying sound

;; ==================== packages ====================
;;(require 'package)
;;(add-to-list 'package-archives '("marmalade" . "https://marmalade-repo.org/packages/") t)
;;(add-to-list 'package-archives '("melpa" . "https://stable.melpa.org/packages/") t)
;;(package-initialize)

;; problems installing packages? try M-x package-refresh-contents
(defun installed (p)
  ;;(when (not (package-installed-p p))
  ;;(package-install p))
  t)

(installed 'paredit)
(installed 'magit)
(installed 'web-mode)
(installed 'js2-mode)
(installed 'git-link)
(installed 'paren-face)
(installed 'base16-theme)
(installed 'multiple-cursors)
(installed 'window-numbering)
(installed 'highlight-symbol)
(installed 'idle-highlight-mode)
(installed 'markdown-mode)
(installed 'clojure-mode)
(installed 'inf-clojure)
(installed 'helm-ag)
(installed 'fish-mode)
(installed 'git-gutter)
(installed 'ivy)
(installed 'dockerfile-mode)
(installed 'avy)
(installed 'imenu-anywhere)
(installed 'iedit)
(installed 'orderless)
(installed 'flycheck)
(installed 'zerodark-theme)
(installed 'all-the-icons-dired)
;; (installed 'all-the-icons-completions)
(installed 'selectrum)
(installed 'ace-window)
;; (installed 'smartparens)
;; (package-install 'orderless)


(setq mouse-yank-at-point t)
(defalias 'yes-or-no-p 'y-or-n-p)
(setq pop-up-windows nil) ;; don't open new windows

(recentf-mode 1)
(setq recentf-max-menu-items 64)
(setq recentf-max-saved-items 64)
(global-set-key (kbd "C-x C-r") 'recentf-open-files)

(setq-default history-length 1000)
              
(savehist-mode)

;; backups
(setq 
 make-backup-files t
 backup-by-copying t ;; don't clobber symlinks
 backup-directory-alist '(("." . "~/.emacs.d/backup"))
 delete-old-versions t
 kept-new-versions 9
 kept-old-versions 6
 version-control t)

;; ============================== completion ==============================
(setq completion-styles '(orderless basic)
      completion-category-overrides '((file (styles basic partial-completion))))
(setq completion-ignore-case t)
(setq read-file-name-completion-ignore-case t)
(setq read-buffer-completion-ignore-case t)
(setq selectrum-refine-candidates-function #'orderless-filter)
(setq selectrum-highlight-candidates-function #'orderless-highlight-matches)
(selectrum-mode +1)

(setq custom-file "/home/klm/.emacs.d/custom.el")
(load custom-file)

(zerodark-setup-modeline-format)
;; (window-numbering-mode) ;; M-1...8
;; (ivy-mode)
;; (setq ivy-use-virtual-buffers t) ;; <-- switch-to-buffer with recentf entries

(all-the-icons-dired-mode +1)
(all-the-icons-completion-mode +1)

(global-paren-face-mode t)

(setq geiser-scheme-implementation '(guile))

(global-git-gutter-mode)

;; color compilation buffer too
;; http://stackoverflow.com/questions/3072648
(require 'ansi-color)
(defun my-colorize-compilation-buffer ()
  (when (eq major-mode 'compilation-mode)
    (ansi-color-apply-on-region compilation-filter-start (point-max))))
(add-hook 'compilation-filter-hook 'my-colorize-compilation-buffer)

(add-hook 'prog-mode-hook 'highlight-symbol-mode)
;;(remove-hook 'prog-mode-hook 'idle-highlight-mode)
 
(add-hook 'xref-backend-functions #'dumb-jump-xref-activate)


;; ;;(require 'smartparens-config) ;; smartparens-global-mode doesn't respect local pairs
;; ;;(smartparens-global-strict-mode +1)
;; ;;(sp-use-paredit-bindings)
;; (global-set-key (kbd "C-M-SPC") 'sp-select-next-thing)
;; (global-set-key (kbd "C-S-M-SPC") 'sp-select-previous-thing)
;; (global-set-key (kbd "M-(") (lambda () (interactive) (sp-wrap-with-pair "(")))
;; (global-set-key (kbd "C-c (") (lambda () (interactive) (sp-wrap-with-pair "(")))
;; (global-set-key (kbd "C-c [") (lambda () (interactive) (sp-wrap-with-pair "[")))
;; (global-set-key (kbd "C-c \"") (lambda () (interactive) (sp-wrap-with-pair "\"")))

(global-set-key (kbd "C-c i") 'aggressive-indent-mode)

;; enable paredit

(eval-after-load 'paredit
  '(progn (define-key paredit-mode-map (kbd "\\") 'self-insert-command)))

(add-hook 'emacs-lisp-mode-hook       (lambda () (paredit-mode +1)))
(add-hook 'lisp-mode-hook             (lambda () (paredit-mode +1)))
(add-hook 'lisp-interaction-mode-hook (lambda () (paredit-mode +1)))
(add-hook 'scheme-mode-hook           (lambda () (paredit-mode +1)))
(add-hook 'clojure-mode-hook          (lambda () (paredit-mode +1)))

;; ==================== global keybindings ====================
(require 'ace-window) ;; needed for non-Guix distros it seems
(ace-window-display-mode +1)
(global-set-key (kbd "M-1") (lambda () (interactive) (aw-switch-to-window (nth 0 (aw-window-list)))))
(global-set-key (kbd "M-2") (lambda () (interactive) (aw-switch-to-window (nth 1 (aw-window-list)))))
(global-set-key (kbd "M-3") (lambda () (interactive) (aw-switch-to-window (nth 2 (aw-window-list)))))
(global-set-key (kbd "M-4") (lambda () (interactive) (aw-switch-to-window (nth 3 (aw-window-list)))))
(global-set-key (kbd "M-5") (lambda () (interactive) (aw-switch-to-window (nth 4 (aw-window-list)))))
(global-set-key (kbd "M-6") (lambda () (interactive) (aw-switch-to-window (nth 5 (aw-window-list)))))
(global-set-key (kbd "M-7") (lambda () (interactive) (aw-switch-to-window (nth 6 (aw-window-list)))))


;; (ctrlf-mode +1)
;; (global-set-key (kbd "C-s") 'swiper)
 (global-set-key (kbd "C-s") 'phi-search)
 (global-set-key (kbd "C-r") 'phi-search-backward)
 (global-set-key (kbd "M-%") 'phi-replace-query)

(global-set-key (kbd "C-S-n") (lambda () (interactive) (scroll-up  4)))
(global-set-key (kbd "C-S-p") (lambda () (interactive) (scroll-up -4)))
(global-set-key (kbd "C-S-k") 'kill-whole-line)
(global-set-key (kbd "C-x j") 'toggle-truncate-lines)

;; TODO get this back up and running
;; (require 'highlight-symbol)
(global-set-key (kbd "M-N") 'highlight-symbol-next)
(global-set-key (kbd "M-P") 'highlight-symbol-prev)

;; ==================== magit
(global-set-key (kbd "C-c g") 'magit-status)

;; turn off these default magit bindings because I'm using them for
;; something else.
(define-key magit-mode-map (kbd "M-1") nil)
(define-key magit-mode-map (kbd "M-2") nil)
(define-key magit-mode-map (kbd "M-3") nil)
(define-key magit-mode-map (kbd "M-4") nil)

(setq magit-display-buffer-function 'magit-display-buffer-same-window-except-diff-v1)
;;(setq magit-display-buffer-function 'magit-display-buffer-traditional)
;;(add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh) ;; didn't work


;; (require 'multiple-curso-rs)
;; (global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C->") 'mc/mark-next-symbol-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-symbol-like-this)
(global-set-key (kbd "C-M->") 'mc/unmark-next-like-this)
(global-set-key (kbd "C-M-<") 'mc/mark-next-like-this-symbol) ;; or 'mc/unmark-previous-like-this

(global-set-key (kbd "s-b") 'recompile)

;; helm-ag
(setq helm-ag-insert-at-point 'symbol)
(global-set-key (kbd "M-C-.") 'helm-do-ag-project-root)

;; I open gitk _a lot_
(global-set-key (kbd "C-M-&")
                (lambda () (interactive)
		  (async-shell-command "gitk --all" nil nil)))

(global-set-key (kbd "C-'") 'avy-goto-char-2)

(global-set-key (kbd "C-S-i") 'imenu-anywhere)

;; ==================== major modes ====================

;; *Never* insert tabs, Emacs!
(setq-default indent-tabs-mode nil)

(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
(add-to-list 'auto-mode-alist '("\\.html\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.php\\'" . web-mode))

;; ==== c-mode
(setq c-default-style "linux"
      c-basic-offset 2)


;; ==================== playing with numbers ====================
(defun char->int (str)
  (interactive
   (let ((str (read-string "Foo: " nil 'history:char->int)))
     (list str)))
  (message (mapconcat (lambda (x) (format "%c:0x%0x/%d" x x x)) str "\n")))

(defun int->char (str)
  (interactive
   (let ((str (read-string "int: " nil 'history:int->char)))
     (list str)))
  (message (mapconcat (lambda (x) (format "%c:0x%0x/%d" x x x)) str "\n")))

;; insert-char with ivy doesn't show the actual unicode symbol
(defun my-insert-char ()
  (interactive)
  (let ((completing-read-function 'completing-read-default)))
  (completion-in-region-function 'completion--in-region
    (call-interactively 'insert-char)))
(global-set-key (kbd "C-x 8 RET") 'my-insert-char)

(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'erase-buffer 'disabled nil)

(defun scheme-send-buffer ()
  (interactive)
  (scheme-send-region (point-min) (point-max)))

(add-hook 'scheme-mode-hook
	  '(lambda ()
	     (local-set-key (kbd "M-RET") 'scheme-send-buffer)))

;; ==================== dedicated window toggle ====================
;; useful when I want to overlay an external window over my running
;; emacs. I create a dummy buffer and lay it out just underneath this
;; external window, then dedicate that buffer. now nothing important
;; will popup in my invisible region.
(defun toggle-current-window-dedication ()
  (interactive)
  (let* ((window    (selected-window))
         (dedicated (window-dedicated-p window)))
    (set-window-dedicated-p window (not dedicated))
    (message "Window %sdedicated to %s"
             (if dedicated "no longer " "")
             (buffer-name))))

(global-set-key [pause] 'toggle-current-window-dedication)

;; https://github.com/bhauman/lein-figwheel/wiki/Running-figwheel-with-Emacs-Inferior-Clojure-Interaction-Mode
(defun run-figwheel ()
  (interactive)
  (inf-clojure "clojure -A:dev"))

(add-hook 'clojure-mode-hook #'inf-clojure-minor-mode)
;; (require 'iedit)

;; start server unless in a terminal
(if window-system (server-start))
