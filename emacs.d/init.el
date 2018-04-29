
;; I don't need the tutorial anymore
(setq inhibit-startup-message t)


;; ==================== packages ====================
(require 'package)
;;(add-to-list 'package-archives '("marmalade" . "https://marmalade-repo.org/packages/") t)
(add-to-list 'package-archives '("melpa" . "https://stable.melpa.org/packages/") t)
(package-initialize)

(defun installed (p)
  (when (not (package-installed-p p))
    (package-install p)))

(installed 'paredit)
(installed 'magit)
(installed 'paredit)
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

(setq mouse-yank-at-point t)
(defalias 'yes-or-no-p 'y-or-n-p)

(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)

(window-numbering-mode) ;; M-1...8
(ivy-mode)
(setq ivy-use-virtual-buffers t)

(setq pop-up-windows nil) ;; don't open new windows

;; now save file visits between emacs restarts
;; see https://www.reddit.com/r/emacs/comments/21a4p9/use_recentf_and_ido_together/ and gthis is
;(setq ido-use-virtual-buffers t)
(setq-default history-length 1000)
(savehist-mode t)

;; dim parenthesis so non-Lispers don't freak out
(require 'paren-face)
(global-paren-face-mode t)

(global-git-gutter-mode)
;;(global-diff-hl-mode)
;;(setq diff-hl-fringe-bmp-function 'diff-hl-fringe-bmp-from-type)

(require 'dired-x) ;; jump to file with C-x C-j

;; backups
(setq
 make-backup-files t
 backup-by-copying t ;; don't clobber symlinks
 backup-directory-alist '(("." . "~/.emacs.d/backup"))
 delete-old-versions t
 kept-new-versions 9
 kept-old-versions 6
 version-control t)

;; ==================== looks ====================

(load-theme 'base16-eighties t)
(set-face-attribute 'default     nil
		    :family "Source Code Pro"
		    :foundry "ADBO"
		    :height 98)
(set-fringe-mode '(4 . 8)) ;; pixels (right . left)

;; dim parenthesis
(set-face-attribute 'parenthesis nil :foreground "#777")

;; highlight matching parens
(show-paren-mode)
(set-face-attribute 'show-paren-match nil
		    :background (face-background 'default)
		    :foreground "#0f0"
		    :weight 'extra-bold)
(set-face-attribute 'show-paren-mismatch nil
		    :background (face-background 'default)
		    :foreground "#f00"
		    :weight 'extra-bold)

;; show lambda as λ etc
(global-prettify-symbols-mode 1)
(defun my-pretty-lambda ()
  (setq prettify-symbols-alist
        '(("lambda" . 955)))) ;; λ

(add-hook 'scheme-mode-hook 'my-pretty-lambda)

;; color compilation buffer too
;; http://stackoverflow.com/questions/3072648
(require 'ansi-color)
(defun my-colorize-compilation-buffer ()
  (when (eq major-mode 'compilation-mode)
    (ansi-color-apply-on-region compilation-filter-start (point-max))))
(add-hook 'compilation-filter-hook 'my-colorize-compilation-buffer)


;; ==================== hooks ====================
(add-hook 'prog-mode-hook 'idle-highlight-mode)

;; enable paredit
(add-hook 'emacs-lisp-mode-hook       (lambda () (paredit-mode +1)))
(add-hook 'lisp-mode-hook             (lambda () (paredit-mode +1)))
(add-hook 'lisp-interaction-mode-hook (lambda () (paredit-mode +1)))
(add-hook 'scheme-mode-hook           (lambda () (paredit-mode +1)))
(add-hook 'clojure-mode-hook          (lambda () (paredit-mode +1)))

;; ==================== global keybindings ====================

(global-set-key (kbd "C-S-n") (lambda () (interactive) (scroll-up  4)))
(global-set-key (kbd "C-S-p") (lambda () (interactive) (scroll-up -4)))
(global-set-key (kbd "C-S-k") 'kill-whole-line)
(global-set-key (kbd "C-c C-o") 'toggle-truncate-lines)

(require 'highlight-symbol)
(global-set-key (kbd "M-N") 'highlight-symbol-next)
(global-set-key (kbd "M-P") 'highlight-symbol-prev)

;; ==================== magit
(global-set-key (kbd "C-c g") 'magit-status)
(setq magit-display-buffer-function 'magit-display-buffer-same-window-except-diff-v1)

(require 'multiple-cursors)
;; (global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C->") 'mc/mark-next-symbol-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-symbol-like-this)
(global-set-key (kbd "C-M->") 'mc/unmark-next-like-this)
(global-set-key (kbd "C-M-<") 'mc/unmark-previous-like-this)

(global-set-key (kbd "s-b") 'recompile)

;; helm-ag
(setq helm-ag-insert-at-point t)
(global-set-key (kbd "M-C-.") 'helm-do-ag-project-root)

;; I open gitk _a lot_
(global-set-key (kbd "C-M-&")
                (lambda () (interactive)
		  (async-shell-command "gitk --all" nil nil)))

;; ==================== major modes ====================

(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
(add-to-list 'auto-mode-alist '("\\.html\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.php\\'" . web-mode))
