;;=============================you-dao package===========================
(require-package 'youdao-dictionary)
;;============================youdao package end=========================



;;============================org-mode configuration========================
(setq org-directory "/mnt/d/myfile/")
(setq org-agenda-files '("/mnt/d/myfile/capture"))
(setq org-default-notes-file (concat org-directory "/mnt/d/myfile/capture/refile.org"))
(setq org-log-done 'time)

;; org agenda configuration
(setq org-agenda-span 'day)
(setq org-agenda-custom-commands
      (quote (("N" "Notes" tags "NOTE"
               ((org-agenda-overriding-header "Notes")
                (org-tags-match-list-sublevels t)))
              (" " "Agenda"
               ((agenda "" nil)
                (tags "REFILE"
                      ((org-agenda-overriding-header "Tasks to Refile")
                       (org-tags-match-list-sublevels nil)))
                (tags-todo "-REFILE-CANCELLED-WAITING-HOLD/!"
                           ((org-agenda-overriding-header (concat "Standalone Tasks"
                                                                  ))
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags "-REFILE/"
                      ((org-agenda-overriding-header "Tasks to Archive")
                       (org-agenda-skip-function 'bh/skip-non-archivable-tasks)
                       (org-tags-match-list-sublevels nil)))
              )
               nil))))

;; org refile设置
(setq org-refile-allow-creating-parent-nodes (quote confirm))
(setq org-refile-targets (quote ((nil :maxlevel . 5)
                                 (org-agenda-files :maxlevel . 5))))
(setq org-refile-use-outline-path t)
(setq org-refile-allow-creating-parent-nodes (quote confirm))


                                        ; Use the current window for indirect buffer display
;; org 归档设置
 (setq org-archive-mark-done nil)
  (setq org-archive-location "%s_archive::* Archived Tasks")
  (defun bh/skip-non-archivable-tasks ()
  "Skip trees that are not available for archiving"
  (save-restriction
    (widen)
    ;; Consider only tasks with done todo headings as archivable candidates
    (let ((next-headline (save-excursion (or (outline-next-heading) (point-max))))
          (subtree-end (save-excursion (org-end-of-subtree t))))
      (if (member (org-get-todo-state) org-todo-keywords-1)
          (if (member (org-get-todo-state) org-done-keywords)
              (let* ((daynr (string-to-number (format-time-string "%d" (current-time))))
                     (a-month-ago (* 60 60 24 (+ daynr 1)))
                     (last-month (format-time-string "%Y-%m-" (time-subtract (current-time) (seconds-to-time a-month-ago))))
                     (this-month (format-time-string "%Y-%m-" (current-time)))
                     (subtree-is-current (save-excursion
                                           (forward-line 1)
                                           (and (< (point) subtree-end)
                                                (re-search-forward (concat last-month "\\|" this-month) subtree-end t)))))
                (if subtree-is-current
                    subtree-end ; Has a date in this month or last month, skip it
                  nil))  ; available to archive
            (or subtree-end (point-max)))
        next-headline))))

;; org cpature模板
(setq org-capture-templates
        '(("t" "Todo")
          ("tt" "Todo" entry
           (file "/mnt/d/myfile/capture/refile.org")
           "* TODO %?\n\n")
          ("th" "Todo here" entry
           (file "/mnt/d/myfile/capture/refile.org")
           "* TODO %?\n  %a\n")
          ("n" "note" entry (file "/mnt/d/myfile/capture/refile.org")
           "* %^{标题} :NOTE:\n  %U\n  %?\n")
          ))
;;=============================================org configuration end==========================================

;;==========================================lsp configuration============================
(require-package 'lsp-mode)
;;{{ lsp-mode configuration
(with-eval-after-load 'lsp-mode
  ;; enable log only for debug
  (setq lsp-log-io nil)
  ;; use `evil-matchit' instead
  (setq lsp-enable-folding nil)
  ;; no real time syntax check
  (setq lsp-diagnostic-package :none)
  ;; handle yasnippet by myself
  (setq lsp-enable-snippet nil)
  ;; use `company-ctags' only.
  ;; Please note `company-lsp' is automatically enabled if it's installed
  (setq lsp-enable-completion-at-point nil)
  ;; turn off for better performance
  (setq lsp-enable-symbol-highlighting nil)
  ;; use find-fine-in-project instead
  (setq lsp-enable-links nil)
  ;; auto restart lsp
  (setq lsp-restart 'auto-restart)
  ;; don't watch 3rd party javascript libraries
  (push "[/\\\\][^/\\\\]*\\.\\(json\\|html\\|jade\\)$" lsp-file-watch-ignored)
  ;; don't ping LSP language server too frequently
  (setq lsp-ui-sideline-enable nil)
  (setq lsp-ui-sideline-show-code-actions nil)
  (setq lsp-ui-sideline-show-hover nil)
  (setq lsp-modeline-code-actions-enable t)
  (setq lsp-eldoc-enable-hover nil)
  (setq lsp-signature-auto-activate nil)
 )
;;=======================================lsp configuration end============================

;; flycheck
;; (require-package 'flycheck)
;; (add-hook 'after-init-hook #'global-flycheck-mode)
;; ;; disable default lazyflymake to use flycheck
;; (setq my-disable-lazyflymake t)

;;===================================go-mode=============================================
(require-package 'go-mode)

(add-hook 'go-mode-hook 'lsp-deferred)

(with-eval-after-load 'go-mode
  (setq gofmt-command "goimports")
  (setq lsp-gopls-use-placeholders t)
  (evil-define-key '(normal visual) go-mode-map (kbd "C-]") 'godef-jump)
  (evil-define-key '(normal visual) go-mode-map (kbd "C-o") 'xref-pop-marker-stack)
  )


;; (add-to-list 'load-path "folder-in-which-go-dlv-files-are-in/") ;; if the files are not already in the load path
;; (require-package 'go-dlv)
;;=================================go-mode configuration end==============================

;;=================================dap-mode configuration================================
(require-package 'dap-mode)
(require 'dap-go)
(dap-go-setup)

(with-eval-after-load 'dap-mode
  (setq dap-auto-configure-features '(sessions locals controls tooltip))
  (custom-set-faces
   '(dap-ui-pending-breakpoint-face ((t (:underline "dim gray"))))
   '(dap-ui-verified-breakpoint-face ((t (:underline "green")))))
  )
;;=================================dap-mode end==========================================

;;================================csharp-mode configuration==============================
(require-package 'csharp-mode)
(require-package 'omnisharp)

(with-eval-after-load 'csharp-mode

  )

(defun my-csharp-mode-hook ()
  ;; enable the stuff you want for C# here
  (electric-pair-mode 1)       ;; Emacs 24
  (electric-pair-local-mode 1) ;; Emacs 25
  )
(add-hook 'csharp-mode-hook 'lsp-deferred)
(add-hook 'csharp-mode-hook 'my-csharp-mode-hook)
;;===============================csharp-mode configuration end==========================

;;;; set gdb multi-windows when open
(setq gdb-many-windows t)

;;emacs theme configuration
(load-theme 'sanityinc-tomorrow-eighties t)

;;===============================verlog-mode configuration==============================
(require 'lsp-verilog)

(with-eval-after-load 'verilog-mode
  (custom-set-variables
   '(lsp-clients-svlangserver-launchConfiguration "/tools/verilator -sv --lint-only -Wall")
   '(lsp-clients-svlangserver-formatCommand "/tools/verible-verilog-format"))
  )

(add-hook 'verilog-mode-hook #'lsp-deferred)
;;==============================verlog-mode configuration end==========================

;;==============================elpy configuration=====================================

(with-eval-after-load 'elpy
  (setq elpy-rpc-virtualenv-path "~/.venv/rpc-venv")
  (let ((venv-dir "~/.emacs.d/elpy/rpc-venv"))
    (if (file-exists-p venv-dir) (pyvenv-activate venv-dir)))
  ;; 运行时让每个python的buffer都用单独的shell,避免共享变量,造成冲突
  (add-hook 'elpy-mode-hook (lambda () (elpy-shell-toggle-dedicated-shell 1)))
  ;; 每个project一个shell
  ;;(add-hook 'elpy-mode-hook (lambda () (elpy-shell-set-local-shell (elpy-project-root))))
  ;; format-code
  (add-hook 'elpy-mode-hook (lambda ()
                            (add-hook 'before-save-hook
                                      'elpy-black-fix-code nil t)))
  (setq elpy-rpc-python-command "python3")
  (setq python-shell-interpreter "python3"
      python-shell-interpreter-args "-i")
  ;;防止无法找到flake8
  (custom-set-variables
 '(flycheck-python-flake8-executable "python3")
 '(flycheck-python-pycompile-executable "python3")
 '(flycheck-python-pylint-executable "python3"))
  )

(defun qrq/newline-at-80 ()
  "在第80列新建一行并缩进, 如果80列在一个词的中间, 则将整个词都放到下一行。"
  (move-to-column 80)
  (pyim-backward-word)
  (newline-and-indent)
  )

(defun qrq/auto-newline ()
  "在当前行每隔80列就调用`qrq/newline-at-80'新建一行并缩进"
  (interactive)
  (end-of-line)
  (while (> (current-column) 80)
    (qrq/newline-at-80)
    (end-of-line)
    )
  )

(defun qrq/add-prefix-at-beginning-of-line (prefix)
  "将该符号插入到该行开头"
  (beginning-of-line)
  (skip-chars-forward " \n\t")
  (insert prefix " ")
  )

(defun qrq/add-prefix-for-multiple-line ()
  "输入向下操作的行数（包括本行）, 为每一行调用`qrq/add-prefix-at-beginning-of-line'"
  (interactive)
  (setq numDownLines (read-number "please enter the number of line:"))
  (setq thePrefix (read-string "please enter the prefix:"))
  (dotimes (i (+ 1 numDownLines))
    (qrq/add-prefix-at-beginning-of-line thePrefix)
    (next-line))
  )

;;===========================================leader key configuration=========================================
(with-eval-after-load 'evil
  (my-space-leader-def
  ;;{{ my org mode setup
  "oa" 'org-agenda
  "oc" 'org-capture
  "os" 'org-save-all-org-buffers
  ;;}}
  "yda" 'youdao-dictionary-search-at-point
  "ydi" 'youdao-dictionary-search-from-input
  ;;{{ my func
  "qnl" 'qrq/auto-newline
  "qap" 'qrq/add-prefix-for-multiple-line
  ;;}}
  )
  )
;;=========================================leader key configuration=========================================
