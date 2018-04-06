
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
(installed 'railscasts-reloaded-theme)
(installed 'multiple-cursors)
(installed 'window-numbering)
(installed 'highlight-symbol)
(installed 'idle-highlight-mode)
(installed 'markdown-mode)
(installed 'clojure-mode)
(installed 'inf-clojure)
(installed 'helm-ag)
(installed 'fish-mode)

(setq mouse-yank-at-point t)
(defalias 'yes-or-no-p 'y-or-n-p)

(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)

(window-numbering-mode) ;; M-1...8
(ido-mode)

;; now save file visits between emacs restarts
;; see https://www.reddit.com/r/emacs/comments/21a4p9/use_recentf_and_ido_together/
(setq-default history-length 1000)
(savehist-mode t)
(setq ido-use-virtual-buffers t)

;; dim parenthesis so non-Lispers don't freak out
(require 'paren-face)
(global-paren-face-mode t)

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

;; purple is nice because it makes it easy to find
(set-face-attribute 'cursor             nil :background "#FF55FF")
(set-face-attribute 'mode-line          nil :background "#555" :foreground "#DDD")
(set-face-attribute 'mode-line-inactive nil :background "#353535" :foreground "#666")


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
(global-set-key (kbd "C-c C-t") 'toggle-truncate-lines)

(require 'highlight-symbol)
(global-set-key (kbd "M-N") 'highlight-symbol-next)
(global-set-key (kbd "M-P") 'highlight-symbol-prev)

(global-set-key (kbd "C-c g") 'magit-status)

(require 'multiple-cursors)
;; (global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C->") 'mc/mark-next-symbol-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-symbol-like-this)
(global-set-key (kbd "C-M->") 'mc/unmark-next-like-this)
(global-set-key (kbd "C-M-<") 'mc/unmark-previous-like-this)

(setq helm-ag-insert-at-point t)
(global-set-key (kbd "M-C-.") 'helm-do-ag-project-root)


;; ==================== major modes ====================

(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
(add-to-list 'auto-mode-alist '("\\.html\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.php\\'" . web-mode))
