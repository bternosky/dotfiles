;;------------------------------------------------------------------------------------------------
;; Show load time in status bar and Messages buffer
;; ------------------------------------------------------------------------------------------------
(defun my/display-startup-time ()
  (message "Emacs loaded in %s with %d garbage collections."
           (format "%.2f seconds"
                   (float-time
                     (time-subtract after-init-time before-init-time)))
           gcs-done))
(add-hook 'emacs-startup-hook #'my/display-startup-time)

;;------------------------------------------------------------------------------------------------
;; General Emacs Configuration
;; ------------------------------------------------------------------------------------------------
(defvar my/default-font-size 110)            ; Default font size, 10*font px size seems to work
(setq inhibit-splash-screen t)               ; Turn off splash screen
(setq inhibit-startup-message t)             ; Turn off start up message
(setq initial-scratch-message nil)           ; no message in scratch buffers
(setq-default fill-column 100)               ; default 100 chars before wrapping
;(scroll-bar-mode -1)                         ; Disable visible scroll bar
(tool-bar-mode -1)                           ; Disable the toolbar
(tooltip-mode -1)                            ; Disable tooltips
(set-fringe-mode 10)                         ; Add 10px white space around the edges
;(menu-bar-mode -1)                           ; Disable the menu bar
(setq visible-bell t)                        ; use flashes instead of beeps for feedback
(global-hl-line-mode 1)                      ; highlight the current line
;(set-face-background 'hl-line "#222")        ; change color of hilight line if desired
(setq-default indent-tabs-mode nil)          ; indent with spaces, not tabs
(setq standard-indent 4)                     ; default to 4 spaces indent
(setq create-lockfiles nil)                  ; Don't create lockfiles
(setq read-process-output-max (* 1024 1024)) ; 1mb -useful for LSP which reads a lot

;; ------------------------------------------------------------------------------------------------
;; Set UTF-8 for all relevant modes
;; ------------------------------------------------------------------------------------------------
(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

;; ------------------------------------------------------------------------------------------------
;; Set Default fonts
;; ------------------------------------------------------------------------------------------------
;; DEFAULT/FIXED should be mono: "Office Code Pro", "Source Code Pro" or "Fira Code"
;; Set default font height using our defvar above for size
(set-face-attribute 'default nil :font "Office code Pro-11" :height my/default-font-size)
;;(set-face-attribute 'default nil :font "Source Code Pro-11" :height my/default-font-size)
;;(set-face-attribute 'default nil :font "Fira Code-11" :height my/default-font-size)

;; Set the specific font to use when emacs uses "fixed-pitch" face
(set-face-attribute 'fixed-pitch nil :font "Office code Pro-11" :height 120)
;;(set-face-attribute 'fixed-pitch nil :font "Source Code Pro-11" :height 120)
;;(set-face-attribute 'fixed-pitch nil :font "Fira Code-11" :height 120)

;; Set the specific font to use when emacs uses "variable pitch" face
(set-face-attribute 'variable-pitch nil :font "Cantarell-12" :height 125 :weight 'regular)

;; ------------------------------------------------------------------------------------------------
;; Enable Line Number mode - on ALL modes except specific modes
;; ------------------------------------------------------------------------------------------------
(require 'display-line-numbers)

(defcustom display-line-numbers-exempt-modes
'(vterm-mode eshell-mode shell-mode term-mode ansi-term-mode org-mode)
  "Major modes on which to disable line numbers."
  :group 'display-line-numbers
  :type 'list
  :version "green")

(defun display-line-numbers--turn-on ()
  "Turn on line numbers except for certain major modes.
Exempt major modes are defined in `display-line-numbers-exempt-modes'."
  (unless (or (minibufferp)
              (member major-mode display-line-numbers-exempt-modes))
    (display-line-numbers-mode)))

(global-display-line-numbers-mode)

;; ------------------------------------------------------------------------------------------------
;; Emacs "package" handling bootstrap
;;   -- This MUST be before any use of "use-package"
;; https://github.com/jwiegley/use-package
;; ------------------------------------------------------------------------------------------------
(require 'package)              ; Use Emacs "package" manager

;; Package sources - order matters (similar to APT sources)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

;; apt update equivalent for "package". Download package lists
;;   NOTE: run  "package-refresh-contents" if you get package install errors
;;         There might be updates not pulled down yet that you need.
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; install use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)              ; load use-package
(setq use-package-always-ensure t)  ; adds ":ensure t" to every use-package invocation
;(setq use-package-verbose t)        ; enable to see load/config

;; ------------------------------------------------------------------------------------------------
;; Package: auto-package-update
;;   -- Automatically update packages
;; https://github.com/rranelli/auto-package-update.el
;; ------------------------------------------------------------------------------------------------
(use-package auto-package-update
  :custom
  (auto-package-update-interval 7)               ; update every 7 days
  (auto-package-update-prompt-before-update t)   ; yes prompt me
  (auto-package-update-hide-results nil)         ; show me what was updated (t for hide)
  :config
  (auto-package-update-maybe)                    ; run interval check (at startup)
  (auto-package-update-at-time "09:00"))         ; prompt me at 9am (cron run to catch in case we don't ever close emacs)

;; ------------------------------------------------------------------------------------------------
;; OPTIONAL: Enable command-log-mode buffer
;;  -- captures Emacs command keys to a buffer so you can see your key presses. Great for demos.
;; To use it:
;;   Enable for ALL buffers   - execute this: META+X global-command-log-mode
;;   Toggle the window on/off - execute this: META+X clm/toggle-command-log-buffer
;; ------------------------------------------------------------------------------------------------
(use-package command-log-mode
  :commands command-log-mode    ; only load when invoked by command
  :ensure t)

;; ------------------------------------------------------------------------------------------------
;; Package: all-the-icons/all-the-icons-dired
;;  -- Icons for use by doom-modeline and lsp-python-ms
;; https://github.com/domtronn/all-the-icons.el
;; https://github.com/jtbm37/all-the-icons-dired
;; ------------------------------------------------------------------------------------------------
;; NOTE: When these packages are installed you must run the following manually to
;;       download the fonts that they use:
;;          M-x all-the-icons-install-fonts
(use-package all-the-icons
  :ensure t)                             ; icon library that doom-modeline uses

(use-package all-the-icons-dired
  :ensure t
  :hook (dired-mode . all-the-icons-dired-mode))

;; ------------------------------------------------------------------------------------------------
;; Modeline adjustments
;; ------------------------------------------------------------------------------------------------
;; add clock
(setq display-time-24hr-format t)             ; clock should be a 24 Hr clock format
(setq display-time-format "%H:%M - %d %b %Y") ; format of clock date/time
(display-time-mode 1)                         ; enable clock for all buffers

; add column number
(column-number-mode)

;; ------------------------------------------------------------------------------------------------
;; Package: doom-modeline
;;   -- Replaces the default bottom frame (modeline) in Emacs. Many many improvements.
;; https://github.com/seagle0128/doom-modeline
;; ------------------------------------------------------------------------------------------------
(use-package doom-modeline
  :ensure t                              ; not really need with setq use-package-always-ensure
  :init (doom-modeline-mode 1)           ; Enable the mode immediately
  :custom ((doom-modeline-height 15)))   ; make the height of the modeline smaller than default

;; ------------------------------------------------------------------------------------------------
;; Package: which-key
;;   -- If you start invoking a command it pops-up a mini-buffer that shows command/completion
;;      options. It saves a lot of typing and is great for discovering command options
;; https://github.com/justbur/emacs-which-key
;; ------------------------------------------------------------------------------------------------
(use-package which-key
  :ensure t
  :defer 0                             ; don't load until startup completes
  :diminish which-key-mode
  :config
  (which-key-mode)                     ; always run mode when loaded
  (setq which-key-idle-delay 0.3))     ; wait for 0.3 secs after typing stops

(use-package swiper
  :ensure t)

(use-package ivy
  :diminish
  :ensure t
  :bind (("C-s" . swiper)                        ; CTRL+S = Use swiper instead of isearch
         :map ivy-minibuffer-map                 ; When in a minibuffer ...
         ("TAB" . ivy-partial-or-done)           ;   TAB = Use selected option or keep trying to complete
         ("C-j" . ivy-next-line)                 ;   CTRL+j = Next line in options
         ("C-k" . ivy-previous-line)             ;   CTRL+k = Prev Line in options
         :map ivy-switch-buffer-map              ; When switching buffers ...
         ("C-k" . ivy-previous-line)             ;   CTRL+k = Prev Line in options
         ("C-d" . ivy-switch-buffer-kill)        ;   CTRL+d = Kill open buffer
         :map ivy-reverse-i-search-map           ; When reverse searching ...
         ("C-k" . ivy-previous-line)             ;   CTRL+k = Previous line in options
         ("C-d" . ivy-reverse-i-search-kill))    ;   CTRL+d = kill open buffer
  :config
  (ivy-mode 1))                                  ; now that mode is loaded. enable it

(use-package counsel
  :ensure t
  :bind (("M-x" . counsel-M-x)                  ; replace M-X (built in M-x) with counsel-M-x
         ("C-x b" . counsel-ibuffer)            ; replace builtin ibuffer with counsel-ibuffer
         :map minibuffer-local-map
         ("C-r" . 'counsel-minibuffer-history)) ; replace CTRL+R in minibuffer with counsel
  :config
  (setq ivy-initial-inputs-alist nil))          ; don't start searches with ^

;; ------------------------------------------------------------------------------------------------
;; Package: ivy-prescient
;;   -- tracks frequent used stuff and puts them first in the options list
;;   -- works with ivy, counsel-find-file etc.
;; https://github.com/raxod502/prescient.el
;; ------------------------------------------------------------------------------------------------
(use-package ivy-prescient
  :after counsel                          ; Load after Counsel
  :ensure t
  :config
  (ivy-prescient-mode 1)                        ; enable immediately
  (prescient-persist-mode 1))                   ; save history between emacs sessions

;; Controlling Other Prescient Behaviors
;;   -- be aware changing variables that start with prescient impact all tools using prescient, not just ivy

;; Prescient will sort equal weighted results by length, which is dumb. Turn it off
(setq prescient-sort-length-enable nil)

;; Prescient changes how coloring appears in candidates as you type.
;; Ivy's coloring is better - turn it back on
(setq ivy-prescient-retain-classic-highlighting t)

;; Candidate matches use filter functions for matching. You can choose how matches are made
;;   Options for prescient-filter-method:
;;     literal    => subquery must be a substring of the candidate
;;                   example: "py mo" matches python-mode
;;     initialism => subquery must match a substring of the initials of a candidate
;;                   example: "ffap" matches find-file-at-point
;;     prefix     => words match the beginning of works found in candidate, in order, separated by actual delims
;;                   example: "f-f-a-p" matches "find-file-at-point" f_f_a_p would fail
;;     anchored   => words are separated by capital letters or symbols at start of new words
;;                   example: "FFAP" matches "find-file-at-point"
;;     fuzzy      => chars of the subquery must match SOME subset, in order, but contiguous not necessary
;;                   example: ffap would find find-file-at-point and also diff-backup
;;     regexp     => can use regexp pattern to match
;;                   example: "^find.*file" matches all commands that start with "find" and has "file"
;;   use of multiple options is allowed. Default is (literal regexp initialism)
;; If you don't like the default, uncomment & change
;;(setq prescient-filter-method '(literal regexp initialism)) ; filter method(s)

;; Prescient uses a history to track frequently used candidates. You can control history size
;;   The default is 100. If this is too little/too many uncomment & change the value
;;(setq prescient-history-length 100)

;; ------------------------------------------------------------------------------------------------
;; Package: ivy-rich
;;  -- adds help text to options in the mini-buffer for various commands
;;    e.g. M-X shows commands in emacs. ivy-rich adds text telling you what they each do
;;  https://github.com/Yevgnen/ivy-rich
;; ------------------------------------------------------------------------------------------------
(use-package ivy-rich
  :ensure t
  :after ivy
  :init
  (ivy-rich-mode 1))                            ; run mode on load

;; ------------------------------------------------------------------------------------------------
;; Package: helpful
;;   -- Replaces Emacs help (CTRL+H) with a better help module
;; https://github.com/Wilfred/helpful
;; ------------------------------------------------------------------------------------------------
(use-package helpful
  :ensure t
  :commands (helpful-callable helpful-variable helpful-function helpful-key)
  :custom                                                           ; set variables for Helpful
  ;; replace counsel-describe-function with helpful-callable
  ;; replace counsel-describe-variable with helpful-callable
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-callable)
  :bind                                                             ; replace builtins with helpful
  ;; When user uses describe-xxx send them to helpful-xxx instead
  ([remap describe-function] . helpful-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . helpful-variable)
  ([remap describe-key] . helpful-key))

;; ------------------------------------------------------------------------------------------------
;; Package: doom-themes
;;   -- Provides many themes (including Dracula "doom-dracula")
;;   -- The themes are built to work better with other modes like Magit better than built-ins
;;   -- use M-X doom-load-theme to test themes out
;;   -- doom-gruvbox is a popular theme
;;   -- could also look at "Peach Melpa" for more themes: https://peach-melpa.org/
;; https://github.com/hlissner/emacs-doom-themes
;; ------------------------------------------------------------------------------------------------
(use-package doom-themes
  :ensure t
  :init (load-theme 'doom-dracula t))                       ; Use doom-dracula theme

;;-------------------------------------------------------------------------------------------------
;; Packages: projectile and counsel-projectile
;;  -- A project interaction add-on (think Visual Code projects)
;; https://github.com/bbatsov/projectile
;; ------------------------------------------------------------------------------------------------
(use-package projectile
  :ensure t
  :diminish projectile-mode                            ; no status bar messages
  :config (projectile-mode)                            ; run when loaded
  :custom ((projectile-completion-system 'ivy))        ; Use ivy for completions
  :bind-keymap
  ;; CTRL+C p -> show list of projectile commands
  ("C-c p" . projectile-command-map)
  :init
  ;; NOTE: Set this to the folder(s) where you keep your Git repos. It expects everything in that
  ;;       folder to be a git repo or other project types (mercurial and other things work too)
  ;; NOTE: using ~/src/git doesn't work for me - I pushed stuff down a level. So I have to list ALL
  ;; subdirectories I want
  (setq projectile-project-search-path '("~/src/"))

  ;; Enable caching for speed
  (setq projectile-enable-caching t)

  ;; when switching project open dired buffer automatically
  (setq projectile-switch-project-action #'projectile-dired))

(use-package counsel-projectile                        ; Use counsel for projectile commands
  :ensure t
  :after projectile
  :config (counsel-projectile-mode))

;; ------------------------------------------------------------------------------------------------
;; Package: magit
;;   - Git on steroids. Simplifies/improves the command line A LOT
;;
;; https://magit.vc/
;; ------------------------------------------------------------------------------------------------
(use-package magit
  :ensure t
  :commands magit-status)

;; ------------------------------------------------------------------------------------------------
;; Package: org-mode and helpers
;; https://orgmode.org/
;; ------------------------------------------------------------------------------------------------
(defun my/org-mode-setup ()            ; Define a set of behaviors for org-mode:
  (org-indent-mode t)                  ;   Enable "indented" view (ie 2nd level indents from 1st)
  (variable-pitch-mode 1)              ;   Enable proportional fonts (text unless in #+begin_src)
  (auto-fill-mode 0)                   ;   Disable automatic line wrapping on space/enter
  (visual-line-mode 1)                 ;   Enable Wrap at window boundary
  (diminish org-indent-mode))          ;   quiet down indent-mode

(defun my/org-font-setup ()            ; Define a set of behaviors for org-fonts in org-mode:
  ;; 1. Replace list hyphen with Unicode dot
  (font-lock-add-keywords 'org-mode
                          '(("^ *\\([-]\\) "
                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

  ;; 2. Set different font size for each heading level. Use a "scalable" font for easier reading
  (dolist (face '((org-level-1 . 1.2)
                  (org-level-2 . 1.1)
                  (org-level-3 . 1.05)
                  (org-level-4 . 1.0)
                  (org-level-5 . 1.1)
                  (org-level-6 . 1.1)
                  (org-level-7 . 1.1)
                  (org-level-8 . 1.1)))
    (set-face-attribute (car face) nil :font "Cantarell" :weight 'regular :height (cdr face)))

  ;; 3. Ensure that anything that should be fixed-pitch in Org files appears that way
  ;;    (since we set to "variable pitch" globally)
  (set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-table nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch)

  ;; 4. Various org tweaks
  ;;       hide-emphasis         => hide bold/italic etc.
  ;;       src-fontigy-natively  => apply font to src blocks
  ;;       fontigy-quote-and...  => apply font to quote/verse blocks
  ;;       src-tab-acts-natively => tab works in src blocks
  ;;       edit-src-content...   => indent code in src blocks 2 spc
  ;;       hide-block-startup    => blocks are collapsed by default
  ;;       src-preserve-indent...=> preserve indent on tangle
  ;;       startup-folded        => or use: overview, showall
  ;;       adapt-indentatikon    => adapt to indent levels in doc
  ;;       cycle-separator...    => if 2+ blanks don't collapse when folding
  (setq org-hide-emphasis-markers t
        org-src-fontify-natively t
        org-fontify-quote-and-verse-blocks t
        org-src-tab-acts-natively t
        org-edit-src-content-indentation 2
        org-hide-block-startup nil
        org-src-preserve-indentation nil
        org-startup-folded 'content
        org-adapt-indentation t)
        org-cycle-separator-lines 2)

(use-package org                                  ; Setup actual org-mode
  :ensure t
  :commands (org-capture org-agenda)              ; load org for these commands even if not using .org file
  :hook (org-mode . my/org-mode-setup)            ; use our function for org-mode behaviors
  :config
  ;; Change "..." on section headers when collapsed to Unicode down arrow
  (setq org-ellipsis " ▾")
  (my/org-font-setup))                            ; use our function for org-mode fonts

(use-package org-bullets                          ; setup new bullet styles
  :after org                                      ; after "org-mode" is loaded
  :ensure t
  :hook (org-mode . org-bullets-mode)             ; add org-bullets-mode to org-mode
  :custom
  ;; replace "*", "**" etc. with bullets:
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

;; org-babel can be used to execute code in Org files with C-c C-c (needed for tangle - writing out to a file)
(with-eval-after-load 'org
  (org-babel-do-load-languages                          ; define languages we can use org-babel on (execute from org block)
      'org-babel-load-languages
      '((emacs-lisp . t)                                  ; Lisp + Python
      (python . t)))

  (push '("conf-unix" . conf-unix) org-src-lang-modes))  ; add unix config files to the languages list

; Add Structured Templates to Org
; NOTE: This requires Emacs 27+
;;   see https://www.youtube.com/watch?v=kkqVTDbfYp4 12:00 minute mark
;;   keybinds for inserting blocks for code
(with-eval-after-load 'org
    ; Required as of Org 9.2
    (require 'org-tempo)
    (add-to-list 'org-structure-template-alist '("sh" . "src sh"))
    (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
    (add-to-list 'org-structure-template-alist '("sc" . "src scheme"))
    (add-to-list 'org-structure-template-alist '("ts" . "src typescript"))
    (add-to-list 'org-structure-template-alist '("py" . "src python"))
    (add-to-list 'org-structure-template-alist '("go" . "src go"))
    (add-to-list 'org-structure-template-alist '("yaml" . "src yaml"))
    (add-to-list 'org-structure-template-alist '("json" . "src json")))

;; Automatically tangle our Emacs.org config file when we save it
;; See: https://github.com/daviwil/emacs-from-scratch/blob/9388cf6ecd9b44c430867a5c3dad5f050fdc0ee1/init.el
;;      for changing this to ALL org files in a directory
(defun my/org-babel-tangle-config ()
  (when (string-equal (buffer-file-name)
                      (expand-file-name "~/Org/Emacs.org"))            ; only execute on ~/Org/Emacs.org
    ;; Dynamic scoping to the rescue
    (let ((org-confirm-babel-evaluate nil))                            ; don't prompt to overwrite
      (org-babel-tangle))))                                            ; tangle out the file(s)

(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'my/org-babel-tangle-config))) ; setup auto-tangle on every org buffer

;; Package: visual-fill-column
(defun my/org-mode-visual-fill ()           ; Define custom behaviors for org-mode-visual-fill
  (setq visual-fill-column-width 100)       ; Wrap lines at 100 characters instead of window edge
  ;;visual-fill-column-center-text t)       ; OPTIONAL: Center text in the window, I didn't like
  (visual-fill-column-mode 1))              ; Enable visual-fill-column mode

(use-package visual-fill-column                ; Use visual-fill-column pkg
  :ensure t
  :hook (org-mode . my/org-mode-visual-fill))  ; use our custom function settings

;; Use Agenda logging when tasks are completed
(setq org-agenda-start-with-log-mode t)   ; enable the log mode
(setq org-log-done 'time)                 ; timestamp completed tasks
(setq org-log-into-drawer t)              ; auto-collapse log entries (visibility)

;; Define Task file(s) for Org Agenda
(setq org-agenda-files
    '("~/Org/Tasks.org"
      "~/Org/Birthdays.org"
      "~/Org/Holidays.org"))

;; Use this to LIMIT the tags that can be used
(setq org-tag-alist
    '((:startgroup)
       ; Put mutually exclusive tags here
       (:endgroup)
       ("email" . ?e)
       ("other" . ?o)
       ("bob" . ?b)
       ("rob" . ?r)
       ("wayne" . ?w)
       ("simon" . ?s)
       ("jon" . ?j)
       ("unassigned" . ?u)
       ("management" . ?M)
       ("mercury" . ?m)
       ("ng" . ?g)
       ("nucleus" . ?n)
       ("pluto" . ?p)
       ("c360" . ?c)))

;; Add Task life cycle keywords and their hotkeys
;; I only have one..but it can be list of lists
;; Left of "|" = active, right of "|" = inactive
(setq org-todo-keywords
  '((sequence "TODO(t)" "OUTSIDEDEP(o)" "URGENT(u)" "WAITFORREPLY(w)" "IMPLEMENTING(i)" "QA(q)" "|" "DONE(d!)")))

;; Set Refile target(s)
(setq org-refile-targets
    '(("~/Org/Archive.org" :maxlevel . 1)
      ("~/Org/Tasks.org" :maxlevel . 1)))

;; Refile doesn't save automatically. Tell Emacs to do so!
(advice-add 'org-refile :after 'org-save-all-org-buffers)

;; Configure custom agenda views
;; the items below here are options after choosing M-x org-agenda
;; "d" for dashboard, "u" for Urgent etc.
(setq org-agenda-custom-commands
  '(("d" "Dashboard"
    ((agenda "" ((org-deadline-warning-days 7)))
     (todo "URGENT"
       ((org-agenda-overriding-header "Urgent Tasks")))
     (tags-todo "agenda/ACTIVE" ((org-agenda-overriding-header "Urgent Projects")))))

   ;; press "u" for JUST urgent tasks
   ("u" "Urgent Tasks"
    ((todo "URGENT"
       ((org-agenda-overriding-header "Urgent Tasks")))))

   ;; press "W" for stuff tagged with work but NOT tagged with email
   ("W" "Work Tasks" tags-todo "+work-email")

   ;; Low-effort next actions
   ("e" tags-todo "+TODO=\"TODO\"+Effort<15&+Effort>0"
    ((org-agenda-overriding-header "Low Effort Tasks")
     (org-agenda-max-todos 20)
     (org-agenda-files org-agenda-files)))

   ("w" "Workflow Status"
    ((todo "TODO"
           ((org-agenda-overriding-header "TODOs")
            (org-agenda-files org-agenda-files)))
     (todo "URGENT"
           ((org-agenda-overriding-header "URGENT")
            (org-agenda-files org-agenda-files)))
     (todo "WAITFORREPLY"
           ((org-agenda-overriding-header "Wait For Replay")
            (org-agenda-todo-list-sublevels nil)
            (org-agenda-files org-agenda-files)))
     (todo "IMPLEMENTING"
           ((org-agenda-overriding-header "Working on it")
            (org-agenda-todo-list-sublevels nil)
            (org-agenda-files org-agenda-files)))
     (todo "DONE"
           ((org-agenda-overriding-header "Completed")
            (org-agenda-files org-agenda-files)))))))

;; Setup org capture templates: AKA Post-its/Journals
;; run M-x org-capture then you get menu provided by this config
;; t = tasks, then you get one option
;;      tt: that writes to Tasks.org in the "New Tasks" section
;;          NOTE: that section must already exist
;; j = journal entries, then you get 2 options:
;;     jj: Normal journal entry
;;     jm: Meeting journal entry
;;       Same prompts, both to Journal.org, append mode, different formats for each
;; w = workflow, then you get one option:
;;     we: Writes to Journal.org again (append), but different prompt than "j"
;; Strings being written out
;; %? = data from capture template
;; %U = timestamp,
;; %a = link to file you were in
;; %i = The region where capture was called from
(setq org-capture-templates
    `(("t" "Tasks")
      ("tt" "Task" entry (file+olp "~/Org/Tasks.org" "New Tasks")
           "* TODO %?\n  %U\n  %a\n  %i" :empty-lines 1)

      ("j" "Journal Entries")
      ("jj" "Journal" entry
           (file+olp+datetree "~/Org/Journal.org")
           "\n* %<%I:%M %p> - Journal :journal:\n\n%?\n\n"
           :clock-in :clock-resume
           :empty-lines 1)
      ("jm" "Meeting" entry
           (file+olp+datetree "~/Org/Journal.org")
           "* %<%I:%M %p> - %a :meetings:\n\n%?\n\n"
           :clock-in :clock-resume
           :empty-lines 1)

      ("w" "Workflows")
      ("we" "Checking Email" entry (file+olp+datetree "~/Org/Journal.org")
           "* Checking Email :email:\n\n%?" :clock-in :clock-resume :empty-lines 1)))

;; Set keybind for running org-capture "C-c j" instead of "M-x org-capture"
;; NOTE: this remaps the org-goto command
(define-key global-map (kbd "C-c j") 'org-capture)

;; ------------------------------------------------------------------------------------------------
;; Package: org-tree-slide
;;   -- Enable Org Presentations with tree-slide
;; https://github.com/takaxp/org-tree-slide
;; ------------------------------------------------------------------------------------------------
(defun my/org-start-presentation ()
  (setq text-scale-mode-amount 1) ; +1 face sizes
  (org-display-inline-images)     ; alternative: org-startup-with-inline-images
  (text-scale-mode 1))            ; enable mode with bigger/smaller font

(defun my/org-end-presentation ()
  (text-scale-mode 0))            ; disable text-scale mode on end presentation

(use-package org-tree-slide
  :ensure t
  :hook ((org-tree-slide-play . my/org-start-presentation)
         (org-tree-slide-stop . my/org-end-presentation))
  :custom
  (org-tree-slide-in-effect t)   ; do sliding transitions
  (org-tree-slide-activate-message "Presentation started!")   ; mini-buffer message on start
  (org-tree-slide-deactivate-message "Presentation started!") ; mini-buffer message on end
  (org-tree-slide-header t)      ; enable/disable (nil) header
  (org-tree-slide-breadcrumbs " // ") ; Set breadcrumb delimiter to: " // "
  (org-image-actual-width nil))  ; do not use actual image size when inlining. Use Attrs instead

;; ------------------------------------------------------------------------------------------------
;; Package: rainbow-delimiters
;;   -- Enable colored delimiters
;;      NOTE: prog-mode is base of ANY language mode (e.g. python-mode).
;;            so this applies to ALL language modes
;; https://github.com/Fanael/rainbow-delimiters
;; ------------------------------------------------------------------------------------------------
(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode))         ; add rainbow-delimiters to ALL prog-modes

;; ------------------------------------------------------------------------------------------------
;; Code folding with built-in hs-minor-mode
;; http://www.gnu.org/software/emacs/manual/html_node/emacs/Hideshow.html
;; ------------------------------------------------------------------------------------------------
;; Define list of modes we'll add hs-minor-mode for code folding
(defvar code-editing-mode-hooks '(c-mode-common-hook
                                  emacs-lisp-mode-hook
                                  lisp-mode-hook
                                  python-mode-hook
                                  typescript-mode-hook
                                  sh-mode-hook))

;; set hooks for those modes
(dolist (mode code-editing-mode-hooks)
  (add-hook mode 'hs-minor-mode))
;; ------------------------------------------------------------------------------------------------

;; ------------------------------------------------------------------------------------------------
;; Package: lsp-mode, lsp-ui and lsp-ivy
;;   -- Language Server Protocol (intellisense/visual code type stuff)
;;   -- requires files be part of a "project" - use projectile-mode
;;
;; LSP page: https://microsoft.github.io/language-server-protocol/
;; https://emacs-lsp.github.io/lsp-mode/
;; https://github.com/emacs-lsp/lsp-ui
;; https://github.com/emacs-lsp/lsp-ivy
;; ------------------------------------------------------------------------------------------------
;; Define a function that will put a file system breadcrumb at top of frame using LSP
(defun my/lsp-mode-setup ()
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  (lsp-headerline-breadcrumb-mode))

(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :hook (lsp-mode . my/lsp-mode-setup)       ; Enable breadcrumb on load
  :init
  (setq lsp-keymap-prefix "C-c l")           ; Use C-c l to get LSP commands
  :config
  (lsp-enable-which-key-integration t))      ; available key help integration

(use-package lsp-ui
  :ensure t
  :hook (lsp-mode . lsp-ui-mode)             ; hook lsp-ui into lsp
  :custom
  (lsp-ui-doc-position 'bottom))             ; put doc pop-up at bottom of frame

;; run M-x lsp-ivy-workspace-symbol to search for a symbol in project
;;     and it has an improved interface
(use-package lsp-ivy
  :ensure t
  :after lsp)

;; ------------------------------------------------------------------------------------------------
;; Package: typescript-mode
;;   -- Mode for Editing Typescript
;;
;; NOTE: Requires installation of a typescript-language-server for use with LSP
;;         See: https://emacs-lsp.github.io/lsp-mode/page/lsp-typescript/
;;         Run: sudo npm i -g typescript-language-server; sudo npm i -g typescript
;;       Requires language server to be running. Emacs should start it. Manual:
;;         Run: typescript-language-server --stdio
;; https://github.com/emacs-typescript/typescript.el
;; ------------------------------------------------------------------------------------------------
(use-package typescript-mode
  :ensure t
  :mode "\\.ts\\'"
  :hook (typescript-mode . lsp-deferred) ; hook it into LSP
  :config
  (setq typescript-indent-level 2))      ; Set tab to 2 spaces (our default is 4 globally)

;; ------------------------------------------------------------------------------------------------
;; Package: lsp-python-ms
;;   -- Adding Python LSP mode
;;      NOTE: there are 3 Python language servers to choose from
;;      It will download on first opening file (use the Microsoft one)
;; Requires Python Language Server
;; https://github.com/emacs-lsp/lsp-python-ms
;; ------------------------------------------------------------------------------------------------
(use-package lsp-python-ms
  :ensure t
  :after lsp
  :init (setq lsp-python-ms-auto-install-server t) ; force install of MS Python server
  :hook (python-mode . (lambda ()                  ; require the MS LSP when using python-mode
                         (require 'lsp-python-ms)
                         (lsp-deferred))))

;; ------------------------------------------------------------------------------------------------
;; Package: treemacs
;;   -- Left side of buffer gives Tree file system navigation like VisualCode (M-x treemacs)
;;      also has a symbol tree option (M-x treemacs-symbols)
;; https://github.com/emacs-lsp/lsp-treemacs
;; ------------------------------------------------------------------------------------------------
(use-package lsp-treemacs
  :ensure t
  :after lsp)                                             ; hook into lsp

;; ------------------------------------------------------------------------------------------------
;; Package: company, company-box and company-prescient
;;   -- Better "completion" options package works within LSP
;;   -- company-box improves the UI of the completions
;;   -- all-the-icons-dired provides icons for company-box
;;      NOTE: requires you run: M-x all-the-icons-install-fonts after installation
;; https://company-mode.github.io/
;; https://github.com/sebastiencs/company-box
;; https://github.com/raxod502/prescient.el
;; ------------------------------------------------------------------------------------------------
(use-package company
  :ensure t
  :after lsp                                              ; load after lsp-mode
  :hook (lsp-mode . company-mode)                         ; hook into LSP
  :bind (:map company-active-map
         ("<tab>" . company-complete-selection))          ; use tab to do complete-selection
        (:map lsp-mode-map
         ("<tab>" . company-indent-or-complete-common))   ; use tab in LSP for indent/complete
  :custom
  (company-minimum-prefix-length 1)                       ; at least 1 char for tab complete
  (company-idle-delay 0.0))                               ; no delay for completions

(use-package company-box
  :ensure t
  :hook (company-mode . company-box-mode))

;; Use company-prescient to track frequently used items and bubble them up the candidate list
(use-package company-prescient
  :after company                                          ; load company first
  :ensure t
  :config
  (company-prescient-mode 1))                             ; load immediately

;; ------------------------------------------------------------------------------------------------
;; Package: js2-mode, prettier-js
;;   -- Javascript support
;; https://github.com/mooz/js2-mode
;; https://prettier.io/
;; ------------------------------------------------------------------------------------------------
;; Setup Javascript files
(defun my/set-js-vars ()
  (setq js-indent-level 2)
  (setq-default tab-width 2))

(use-package js2-mode
  :mode "\\.jsx?\\'"
  :config
  (add-to-list 'magic-mode-alist '("!/usr/bin/env node" . js2-mode)) ;; use js-mode for node
  (setq js2-mode-show-strict-warnings nil) ;; don't use built in syntax checker
  (add-hook 'js2-mode-hook #'my/set-js-vars)
  (add-hook 'json-mode-hook #'my/set-js-vars))

(use-package prettier-js
  :hook ((js2-mode . prettier-js-mode)
        (typescript-mode . prettier-js-mode))
  :config
  (setq prettier-js-show-errors nil))

;; -----------------------------------------------------------------------------------------------
;; Package: yaml-mode
;;   -- YAML support
;; https://github.com/yoshiki/yaml-mode
;; ------------------------------------------------------------------------------------------------
(use-package yaml-mode
  :mode "\\.ya?ml\\'")

;; -----------------------------------------------------------------------------------------------
;; Package: dockerfile-mode
;;   -- Dockerfile support
;; https://github.com/spotify/dockerfile-mode
;; -----------------------------------------------------------------------------------------------
(use-package dockerfile-mode
  :ensure t
  :defer t)

;; ------------------------------------------------------------------------------------------------
;; Package: markdown-mode
;;   - Markdown editing mode
;;
;; https://www.emacswiki.org/emacs/MarkdownMode
;; ------------------------------------------------------------------------------------------------
(use-package markdown-mode
  :ensure t
  :mode (("Readme\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init
  (setq markdown-command "pandoc")
  :config
  ;; Adjust font-faces for various headings
  (defun my/set-markdown-header-font-sizes ()
    (dolist (face '((markdown-header-face-1 . 1.2)
                    (markdown-header-face-2 . 1.1)
                    (markdown-header-face-3 . 1.0)
                    (markdown-header-face-4 . 1.0)
                    (markdown-header-face-5 . 1.0)))
      (set-face-attribute (car face) nil :weight 'normal :height (cdr face))))

  (use-package markdown-toc
    :ensure t
    :bind (:map markdown-mode-command-map
           ("r" . markdown-toc-generate-or-refresh-toc)))

  (defun my/markdown-mode-hook ()
    (my/set-markdown-header-font-sizes))

(add-hook 'markdown-mode-hook 'my/markdown-mode-hook))

;; ------------------------------------------------------------------------------------------------
;; Package: flycheck
;;   -- On the fly syntax checker
;; https://www.flycheck.org/en/latest/
;; ------------------------------------------------------------------------------------------------
(use-package flycheck
  :after lsp
  :ensure t)
(add-hook 'python-mode-hook 'flycheck-mode)              ; add it to python-mode

;; ------------------------------------------------------------------------------------------------
;; Package: pyvenv
;;   -- Make emacs aware of and use Virtual Environments
;;   Run: M-x pyvenv-activate pyvenv-deactivate to use environments.
;;        You'll be prompted to provide: <path to venv_xxx>
;; https://github.com/jorgenschaefer/pyvenv
;; ------------------------------------------------------------------------------------------------
(use-package pyvenv
  :ensure t
  :after python-mode
  :config
  (pyvenv-mode 1))                       ; enable mode immediately

;; ------------------------------------------------------------------------------------------------
;; Package: ethan-wspace
;; Dealing with extraneous whitespace
;; https://github.com/glasserc/ethan-wspace
;; ------------------------------------------------------------------------------------------------
(use-package ethan-wspace
  :ensure t
  :hook ((text-mode . ethan-wspace-mode)
         (prog-mode . ethan-wspace-mode))
  :init (global-ethan-wspace-mode 1))
(setq-default mode-require-final-newline nil)     ; disable warning on start-up

(setq display-buffer-base-action
  '((display-buffer-reuse-window
     display-buffer-reuse-mode-window
     display-buffer-same-window
     display-buffer-in-previous-window)
    . ((mode . (helpful-mode help-mode)))))

;; ------------------------------------------------------------------------------------------------
;; Package: hydra
;;   -- Tie related commands into a family of short key bindings
;; https://github.com/abo-abo/hydra
;; ------------------------------------------------------------------------------------------------
(use-package hydra
  :ensure t
  :defer t)

;; Use F2 + j/k keys for zoom in/out
;; This setups means typing F2 jjkkf is equivalent to zoom in, zoom in, zoom out, zoom out, quit
(defhydra hydra-text-scale (global-map "<f2>")           ; F2 starts sequence
  "scale text"                                           ; binding called "scale text"
  ("j" text-scale-increase "in")                         ; j calls text-scale-increase
  ("k" text-scale-decrease "out")                        ; k calls text-scale-decrease
  ("f" nil "finished" :exit t))                          ; f aborts (any non j/k key will abort)

;; Global Key Bindings
(global-set-key (kbd "M-g") 'goto-line)
(global-set-key (kbd "C-c w") 'ethan-wspace-clean-all-modes)
