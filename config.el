(setq user-full-name (if (getenv "GIT_AUTHOR_NAME")
                         (getenv "GIT_AUTHOR_NAME")
                       "ii friend")
      user-mail-address (if (getenv "GIT_COMMIT_EMAIL")
                            (getenv "GIT_COMMIT_EMAIL")
                          "ii*ii.ii"))

(setq doom-localleader-key ",")

(defun scroll-up-5-lines ()
   "Scroll up 5 lines"
   (interactive)
   (scroll-up 5))

 (defun scroll-down-5-lines ()
   "Scroll down 5 lines"
   (interactive)
   (scroll-down 5))

 (global-set-key (kbd "<mouse-4>") 'scroll-down-5-lines)
 (global-set-key (kbd "<mouse-5>") 'scroll-up-5-lines)

(map!
 :map smartparens-mode-map
 :nv ">" #'sp-forward-slurp-sexp
 :nv "<" #'sp-forward-barf-sexp
 :nv "}" #'sp-backward-barf-sexp
 :nv "{" #'sp-backward-slurp-sexp)

(when (memq window-system '(mac ns x)) (exec-path-from-shell-initialize))

(setq doom-font (font-spec :family "Source Code Pro" :size 10)
      ;; )(font-spec :family "Source Code Pro" :size 8 :weight 'semi-light)
      doom-serif-font (font-spec :family "Source Code Pro" :size 10)
      doom-variable-pitch-font (font-spec :family "Source Code Pro" :size 10)
      doom-unicode-font (font-spec :family "Input Mono Narrow" :size 12)
      doom-big-font (font-spec :family "Source Code Pro" :size 10))

(setq doom-theme 'doom-gruvbox)

(setq standard-indent 2)

(use-package! lsp-ui
:config
          (setq lsp-navigation 'both)
          (setq lsp-ui-doc-enable t)
          (setq lsp-ui-doc-position 'top)
          (setq lsp-ui-doc-alignment 'frame)
          (setq lsp-ui-doc-use-childframe t)
          (setq lsp-ui-doc-use-webkit t)
          (setq lsp-ui-doc-delay 0.2)
          (setq lsp-ui-doc-include-signature nil)
          (setq lsp-ui-sideline-show-symbol t)
          (setq lsp-ui-remap-xref-keybindings t)
          (setq lsp-ui-sideline-enable t)
          (setq lsp-prefer-flymake nil)
          (setq lsp-print-io t))

(setq web-mode-enable-auto-closing t)
(setq-hook! web-mode web-mode-auto-close-style 2)

(when (and (getenv "HUMACS_PROFILE") (not (getenv "GOPATH")))
  (setenv "GOPATH" (concat (getenv "HOME") "/go")))

(define-derived-mode ii-vue-mode web-mode "iiVue"
  "A major mode derived from web-mode, for editing .vue files with LSP support.")
(add-to-list 'auto-mode-alist '("\\.vue\\'" . ii-vue-mode))
(add-hook 'ii-vue-mode-hook #'lsp!)

(setq org-cycle-hook
      ' (org-cycle-hide-archived-subtrees
         org-cycle-show-empty-lines
         org-optimize-window-after-visibility-change))

(defun ek/babel-ansi ()
  (when-let ((beg (org-babel-where-is-src-block-result nil nil)))
    (save-excursion
      (goto-char beg)
      (when (looking-at org-babel-result-regexp)
        (let ((end (org-babel-result-end))
              (ansi-color-context-region nil))
          (ansi-color-apply-on-region beg end))))))
(add-hook 'org-babel-after-execute-hook 'ek/babel-ansi)

(setq org-ellipsis " ▼")
(setq org-superstar-headline-bullets-list '("◉" "○" "◉" "○"))

(after! org
  (setq org-tags-column -80))

(setq org-babel-default-header-args:sql-mode
      '((:results . "replace code")
        (:product . "postgres")
        (:wrap . "SRC example")))

(setq org-babel-default-header-args:go
      '((:results . "replace code")
        (:wrap . "SRC example")))

(after! osc52e
  (osc52-set-cut-function)
  )

(use-package! graphviz-dot-mode)
(use-package! sql)
(use-package! sql-indent)
(use-package! osc52e)
(use-package! iterm)
(use-package! ob-tmate)
(use-package! bigquery-mode)

(require 'ox-gfm)

(setq org-babel-default-header-args
      '((:session . "none")
        (:results . "replace code")
        (:comments . "org")
        (:exports . "both")
        (:eval . "never-export")
        (:tangle . "no")))

(setq org-babel-default-header-args:shell
      '((:results . "output code verbatim replace")
        (:wrap . "example")))

(defun ii-sql-comint-bq (product options &optional buf-name)
  "Create a bq shell in a comint buffer."
  ;; We may have 'options' like database later
  ;; but for the most part, ensure bq command works externally first
  (sql-comint product options buf-name)
  )
(defun ii-sql-bq (&optional buffer)
  "Run bq by Google as an inferior process."
  (interactive "P")
  (sql-product-interactive 'bq buffer)
  )
(after! sql
  (sql-add-product 'bq "Google Big Query"
                   :free-software nil
                   ;; :font-lock 'bqm-font-lock-keywords ; possibly later?
                   ;; :syntax-alist 'bqm-mode-syntax-table ; invalid
                   :prompt-regexp "^[[:alnum:]-]+> "
                   ;; I don't think we have a continuation prompt
                   ;; but org-babel-execute:sql-mode requires it
                   ;; otherwise re-search-forward errors on nil
                   ;; when it requires a string
                   :prompt-cont-regexp "3a83b8c2z93c89889a4c98r2z34"
                   ;; :prompt-length 9 ; can't precalculate this
                   :sqli-program "bq"
                   :sqli-login nil ; probably just need to preauth
                   :sqli-options '("shell" "--quiet" "--format" "pretty")
                   :sqli-comint-func 'ii-sql-comint-bq
                 )
  )

(setq
      ;; user-banners-dir
      ;; doom-dashboard-banner-file "img/kubemacs.png"
      doom-dashboard-banner-dir (concat humacs-spacemacs-directory  (convert-standard-filename "/banners/"))
      doom-dashboard-banner-file "img/kubemacs.png"
      fancy-splash-image (concat doom-dashboard-banner-dir doom-dashboard-banner-file)
      )

(defun ssh-find-agent ()
"Look for a running SSH agent on the host machine, and set it as our SSH_AUTH_SOCK.
This is useful for pushing changes to git repos using your ssh key, or for tramping in an org file to a remote machine.
It assumes you've added an ssh-agent and, if on a remote machine, forwarded it to that machine.
For more info, see: https://www.ssh.com/ssh/agent
This function is INTERACTIVE."
  (interactive)
  (setenv "SSH_AUTH_SOCK" (shell-command-to-string "find /tmp /run/host/tmp/ -type s -regex '.*/ssh-.*/agent..*$' 2> /dev/null | tail -n 1 | tr -d '\n'"))
  (message (getenv "SSH_AUTH_SOCK")))

(defun iso-week-to-time (year week day)
  (pcase-let ((`(,m ,d ,y)
               (calendar-gregorian-from-absolute
                (calendar-iso-to-absolute (list week day year)))))
    (encode-time 0 0 0 d m y)))

(define-skeleton ii-timesheet-skel
  "Prompt the week and year before generating ii timesheet for the user."
  ""
  (text-mode)
  > "#+TITLE: Timesheet: Week " (setq v1 (skeleton-read "Timesheet Week? "))
  ", " (setq v2 (format-time-string "%Y"))
  " (" (getenv "USER") ")" \n
  > "#+AUTHOR: " (getenv "USER") \n
  > " " \n
  > "Please refer to the instructions in ii-timesheet.org as required." \n
  > " " \n
  > "* Week Summary" \n
  > " " _ \n
  > "#+BEGIN: clocktable :scope file :block thisweek :maxlevel 2 :emphasise t :tags t :formula %" \n
  > "#+END" \n
  > " " \n

  > "* " (format-time-string "%B %e, %Y" (iso-week-to-time (string-to-number v2) (string-to-number v1) 1)) \n
  > "** Task X" \n
  > "* " (format-time-string "%B %e, %Y" (iso-week-to-time (string-to-number v2) (string-to-number v1) 2)) \n
  > "** Task X" \n
  > "* " (format-time-string "%B %e, %Y" (iso-week-to-time (string-to-number v2) (string-to-number v1) 3)) \n
  > "** Task X" \n
  > "* " (format-time-string "%B %e, %Y" (iso-week-to-time (string-to-number v2) (string-to-number v1) 4)) \n
  > "** Task X" \n
  > "* " (format-time-string "%B %e, %Y" (iso-week-to-time (string-to-number v2) (string-to-number v1) 5)) \n
  > "** Task X" \n
  > " " \n
  (org-mode)
  (save-buffer))

(defun ii-timesheet ()
  "Create a timesheet buffer and insert skel as defined in ii-timesheet-skel.
   This function is INTERACTIVE."
  (interactive)
  (require 'cal-iso)
  (switch-to-buffer (get-buffer-create "*ii-timesheet*"))
  (ii-timesheet-skel))

(setq inhibit-startup-screen nil
      startup-screen-inhibit-startup-screen nil
      )

;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; DO NOT EDIT THIS FILE DIRECTLY
;; This is a file generated from a literate programing source file located at
;; https://gitlab.com/zzamboni/dot-doom/-/blob/master/doom.org
;; You should make any changes there and regenerate it from Emacs org-mode
;; using org-babel-tangle (C-c C-v t)

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
;; (setq user-full-name "John Doe"
;;      user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;; (setq doom-theme 'doom-one)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
;; (setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
;; (setq display-line-numbers-type t)

;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
