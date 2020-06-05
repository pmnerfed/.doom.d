;; [[file:~/.doom.d/config.org::*Lexical%20bindings][Lexical bindings:1]]
;;; config.el -*- lexical-binding: t; -*-
;; Lexical bindings:1 ends here

;; [[file:~/.doom.d/config.org::*Personal%20Information][Personal Information:1]]
(setq user-full-name "pM"
      user-mail-address "puneet.madaan164@gmail.com")
;; Personal Information:1 ends here

;; [[file:~/.doom.d/config.org::*Personal%20Information][Personal Information:2]]
(setq auth-sources '("~/.authinfo.gpg")
      auth-source-cache-expiry nil) ; default is 7200 (2h)
;; Personal Information:2 ends here

;; [[file:~/.doom.d/config.org::*Simple%20Settings][Simple Settings:1]]
(setq-default
 delete-by-moving-to-trash t                      ; Delete files to trash
 tab-width 4                                      ; Set width for tabs
 uniquify-buffer-name-style 'forward              ; Uniquify buffer names
 window-combination-resize t                      ; take new window space from all other windows (not just current)
 x-stretch-cursor t)                              ; Stretch cursor to the glyph width

(setq undo-limit 80000000                         ; Raise undo-limit to 80Mb
      evil-want-fine-undo t                       ; By default while in insert all changes are one big blob. Be more granular
      auto-save-default t                         ; Nobody likes to loose work, I certainly don't
      inhibit-compacting-font-caches t            ; When there are lots of glyphs, keep them in memory
      truncate-string-ellipsis "…")               ; Unicode ellispis are nicer than "...", and also save /precious/ space

(delete-selection-mode 1)                         ; Replace selection when inserting text
(display-time-mode 1)                             ; Enable time in the mode-line
(display-battery-mode 1)                          ; On laptops it's nice to know how much power you have
(global-subword-mode 1)                           ; Iterate through CamelCase words
;; Simple Settings:1 ends here

;; [[file:~/.doom.d/config.org::*Full%20Screen][Full Screen:1]]
(if (eq initial-window-system 'x)                 ; if started by emacs command or desktop file
    (toggle-frame-maximized)
  (toggle-frame-fullscreen))
;; Full Screen:1 ends here

;; [[file:~/.doom.d/config.org::*Auto%20customization][Auto customization:1]]
(setq-default custom-file (expand-file-name ".custom.el" doom-private-dir))
(when (file-exists-p custom-file)
  (load custom-file))
;; Auto customization:1 ends here

;; [[file:~/.doom.d/config.org::*Windows][Windows:1]]
(setq evil-vsplit-window-right t
      evil-split-window-below t)
;; Windows:1 ends here

;; [[file:~/.doom.d/config.org::*Windows][Windows:2]]
(defadvice! prompt-for-buffer (&rest _)
  :after '(evil-window-split evil-window-vsplit)
  (+ivy/switch-buffer))
;; Windows:2 ends here

;; [[file:~/.doom.d/config.org::*Windows][Windows:3]]
(setq +ivy-buffer-preview t)
;; Windows:3 ends here

;; [[file:~/.doom.d/config.org::*Windows][Windows:4]]
(map! :map evil-window-map
      "SPC" #'rotate-layout)
;; Windows:4 ends here

;; [[file:~/.doom.d/config.org::*Setup%20Fonts][Setup Fonts:1]]
(setq doom-font (font-spec :family "Ligaturized Antikor Mono" :size 15))
(setq doom-variable-pitch-font "Ligaturized Antikor Text")

(mac-auto-operator-composition-mode)
;; Setup Fonts:1 ends here

;; [[file:~/.doom.d/config.org::*Visual%20Stuff][Visual Stuff:1]]
(setq doom-theme 'doom-vibrant)
;; Visual Stuff:1 ends here

;; [[file:~/.doom.d/config.org::*Visual%20Stuff][Visual Stuff:2]]
;; (custom-set-faces!
;;   '(doom-modeline-buffer-modified :foreground "orange"))
;; Visual Stuff:2 ends here

;; [[file:~/.doom.d/config.org::*Visual%20Stuff][Visual Stuff:3]]
(defun doom-modeline-conditional-buffer-encoding ()
  "We expect the encoding to be LF UTF-8, so only show the modeline when this is not the case"
  (setq-local doom-modeline-buffer-encoding
              (unless (or (eq buffer-file-coding-system 'utf-8-unix)
                          (eq buffer-file-coding-system 'utf-8)))))

(add-hook 'after-change-major-mode-hook #'doom-modeline-conditional-buffer-encoding)
;; Visual Stuff:3 ends here

;; [[file:~/.doom.d/config.org::*Mode-line][Mode-line:1]]
(after! doom-modeline
  (setq doom-modeline-major-mode-color-icon t
        doom-modeline-buffer-state-icon t
        ;; doom-modeline-icon (display-graphic-p)
        doom-modeline-icon t
        doom-modeline-buffer-file-name-style 'relative-from-project
        doom-modeline-bar-width 3
        doom-modeline-version nil

        ))
;; Mode-line:1 ends here

;; [[file:~/.doom.d/config.org::*setup%20anzu%20to%20show%20count%20in%20search][setup anzu to show count in search:1]]
(use-package! anzu
  :after-call isearch-mode
  :config
  (setq anzu-cons-mode-line-p nil
        anzu-minimum-input-length 1
        anzu-search-threshold 250)
  (global-anzu-mode +1)

  (defun +modeline*fix-anzu-count (positions here)
    (cl-loop for (start . end) in positions
             collect t into before
             when (and (>= here start) (<= here end))
             return (length before)
             finally return 0))
  (advice-add #'anzu--where-is-here :override #'+modeline*fix-anzu-count)

  ;; Avoid anzu conflicts across buffers
  (mapc #'make-variable-buffer-local
        '(anzu--total-matched anzu--current-position anzu--state
          anzu--cached-count anzu--cached-positions anzu--last-command
          anzu--last-isearch-string anzu--overflow-p))
  ;; Ensure anzu state is cleared when searches & iedit are done
  (add-hook 'isearch-mode-end-hook #'anzu--reset-status t)
  (add-hook 'doom-escape-hook #'anzu--reset-status t)
  (add-hook 'iedit-mode-end-hook #'anzu--reset-status))


(use-package! evil-anzu
  :when (featurep! :feature evil)
  :after-call (evil-ex-start-search evil-ex-start-word-search))
;; setup anzu to show count in search:1 ends here

;; [[file:~/.doom.d/config.org::*Use%20vim-esque%20relative%20line%20numbers][Use vim-esque relative line numbers:1]]
(setq display-line-numbers-type 'relative)
;; Use vim-esque relative line numbers:1 ends here

;; [[file:~/.doom.d/config.org::*Nicer%20default%20buffer%20names][Nicer default buffer names:1]]
(setq doom-fallback-buffer-name "► Doom"
      +doom-dashboard-name "► Doom")
;; Nicer default buffer names:1 ends here

;; [[file:~/.doom.d/config.org::*Window%20Title][Window Title:1]]
(setq frame-title-format
    '(""
      (:eval
       (if (s-contains-p org-roam-directory (or buffer-file-name ""))
           (replace-regexp-in-string ".*/[0-9]*-?" "🢔 " buffer-file-name)
         "%b"))
      (:eval
       (let ((project-name (projectile-project-name)))
         (unless (string= "-" project-name)
           (format (if (buffer-modified-p)  " ◉ %s" "  ●  %s") project-name))))))
;; Window Title:1 ends here

;; [[file:~/.doom.d/config.org::*Splash%20Screen][Splash Screen:1]]
(defvar fancy-splash-image-template
  (expand-file-name "misc/splash-images/blackhole-lines-template.svg" doom-private-dir)
  "Default template svg used for the splash image, with substitutions from ")
(defvar fancy-splash-image-nil
  (expand-file-name "misc/splash-images/transparent-pixel.png" doom-private-dir)
  "An image to use at minimum size, usually a transparent pixel")

(setq fancy-splash-sizes
  `((:height 500 :min-height 50 :padding (0 . 4) :template ,(expand-file-name "misc/splash-images/blackhole-lines-0.svg" doom-private-dir))
    (:height 440 :min-height 42 :padding (1 . 4) :template ,(expand-file-name "misc/splash-images/blackhole-lines-0.svg" doom-private-dir))
    (:height 400 :min-height 38 :padding (1 . 4) :template ,(expand-file-name "misc/splash-images/blackhole-lines-1.svg" doom-private-dir))
    (:height 350 :min-height 36 :padding (1 . 3) :template ,(expand-file-name "misc/splash-images/blackhole-lines-2.svg" doom-private-dir))
    (:height 300 :min-height 34 :padding (1 . 3) :template ,(expand-file-name "misc/splash-images/blackhole-lines-3.svg" doom-private-dir))
    (:height 250 :min-height 32 :padding (1 . 2) :template ,(expand-file-name "misc/splash-images/blackhole-lines-4.svg" doom-private-dir))
    (:height 200 :min-height 30 :padding (1 . 2) :template ,(expand-file-name "misc/splash-images/blackhole-lines-5.svg" doom-private-dir))
    (:height 100 :min-height 24 :padding (1 . 2) :template ,(expand-file-name "misc/splash-images/emacs-e-template.svg" doom-private-dir))
    (:height 0   :min-height 0  :padding (0 . 0) :file ,fancy-splash-image-nil)))

(defvar fancy-splash-sizes
  `((:height 500 :min-height 50 :padding (0 . 2))
    (:height 440 :min-height 42 :padding (1 . 4))
    (:height 330 :min-height 35 :padding (1 . 3))
    (:height 200 :min-height 30 :padding (1 . 2))
    (:height 0   :min-height 0  :padding (0 . 0) :file ,fancy-splash-image-nil))
  "list of plists with the following properties
  :height the height of the image
  :min-height minimum `frame-height' for image
  :padding `+doom-dashboard-banner-padding' to apply
  :template non-default template file
  :file file to use instead of template")

(defvar fancy-splash-template-colours
  '(("$colour1" . keywords) ("$colour2" . type) ("$colour3" . base5) ("$colour4" . base8))
  "list of colour-replacement alists of the form (\"$placeholder\" . 'theme-colour) which applied the template")

(unless (file-exists-p (expand-file-name "theme-splashes" doom-cache-dir))
  (make-directory (expand-file-name "theme-splashes" doom-cache-dir) t))

(defun fancy-splash-filename (theme-name height)
  (expand-file-name (concat (file-name-as-directory "theme-splashes")
                            (symbol-name doom-theme)
                            "-" (number-to-string height) ".svg")
                    doom-cache-dir))

(defun fancy-splash-clear-cache ()
  "Delete all cached fancy splash images"
  (interactive)
  (delete-directory (expand-file-name "theme-splashes" doom-cache-dir) t)
  (message "Cache cleared!"))

(defun fancy-splash-generate-image (template height)
  "Read TEMPLATE and create an image if HEIGHT with colour substitutions as  ;described by `fancy-splash-template-colours' for the current theme"
    (with-temp-buffer
      (insert-file-contents template)
      (re-search-forward "$height" nil t)
      (replace-match (number-to-string height) nil nil)
      (dolist (substitution fancy-splash-template-colours)
        (beginning-of-buffer)
        (while (re-search-forward (car substitution) nil t)
          (replace-match (doom-color (cdr substitution)) nil nil)))
      (write-region nil nil
                    (fancy-splash-filename (symbol-name doom-theme) height) nil nil)))

(defun fancy-splash-generate-images ()
  "Perform `fancy-splash-generate-image' in bulk"
  (dolist (size fancy-splash-sizes)
    (unless (plist-get size :file)
      (fancy-splash-generate-image (or (plist-get size :file)
                                       (plist-get size :template)
                                       fancy-splash-image-template)
                                   (plist-get size :height)))))

(defun ensure-theme-splash-images-exist (&optional height)
  (unless (file-exists-p (fancy-splash-filename
                          (symbol-name doom-theme)
                          (or height
                              (plist-get (car fancy-splash-sizes) :height))))
    (fancy-splash-generate-images)))

(defun get-appropriate-splash ()
  (let ((height (frame-height)))
    (cl-some (lambda (size) (when (>= height (plist-get size :min-height)) size))
             fancy-splash-sizes)))

(setq fancy-splash-last-size nil)
(setq fancy-splash-last-theme nil)
(defun set-appropriate-splash (&optional frame)
  (let ((appropriate-image (get-appropriate-splash)))
    (unless (and (equal appropriate-image fancy-splash-last-size)
                 (equal doom-theme fancy-splash-last-theme)))
    (unless (plist-get appropriate-image :file)
      (ensure-theme-splash-images-exist (plist-get appropriate-image :height)))
    (setq fancy-splash-image
          (or (plist-get appropriate-image :file)
              (fancy-splash-filename (symbol-name doom-theme) (plist-get appropriate-image :height))))
    (setq +doom-dashboard-banner-padding (plist-get appropriate-image :padding))
    (setq fancy-splash-last-size appropriate-image)
    (setq fancy-splash-last-theme doom-theme)
    (+doom-dashboard-reload)))

(add-hook 'window-size-change-functions #'set-appropriate-splash)
(add-hook 'doom-load-theme-hook #'set-appropriate-splash)
;; Splash Screen:1 ends here

;; [[file:~/.doom.d/config.org::*Fun][Fun:7]]
(use-package! keycast
  :commands keycast-mode
  :config
  (define-minor-mode keycast-mode
    "Show current command and its key binding in the mode line."
    :global t
    (if keycast-mode
        (progn
          (add-hook 'pre-command-hook 'keycast-mode-line-update t)
          (add-to-list 'global-mode-string '("" mode-line-keycast " ")))
      (remove-hook 'pre-command-hook 'keycast-mode-line-update)
      (setq global-mode-string (remove '("" mode-line-keycast " ") global-mode-string))))
  (custom-set-faces!
    '(keycast-command :inherit doom-modeline-debug
                      :height 0.9)
    '(keycast-key :inherit custom-modified
                  :height 1.1
                  :weight bold)))
;; Fun:7 ends here

;; [[file:~/.doom.d/config.org::*Abbrev%20mode][Abbrev mode:1]]
(use-package abbrev
  :init
  (setq-default abbrev-mode t)
  ;; a hook funtion that sets the abbrev-table to org-mode-abbrev-table
  ;; whenever the major mode is a text mode
  (defun tec/set-text-mode-abbrev-table ()
    (if (derived-mode-p 'text-mode)
        (setq local-abbrev-table org-mode-abbrev-table)))
  :commands abbrev-mode
  :hook
  (abbrev-mode . tec/set-text-mode-abbrev-table)
  :config
  (setq abbrev-file-name (expand-file-name "abbrev.el" doom-private-dir))
  (setq save-abbrevs 'silently))
;; Abbrev mode:1 ends here

;; [[file:~/.doom.d/config.org::*Centaur%20Tabs][Centaur Tabs:1]]
(after! centaur-tabs
  ;; (centaur-tabs-mode -1)
  (setq centaur-tabs-height 36
        centaur-tabs-set-icons t
        centaur-tabs-modified-marker "o"
        centaur-tabs-close-button "×"
        centaur-tabs-set-bar 'above)
        centaur-tabs-gray-out-icons 'buffer
  (centaur-tabs-change-fonts "P22 Underground Book" 160))
;; (setq x-underline-at-descent-line t)
;; Centaur Tabs:1 ends here

;; [[file:~/.doom.d/config.org::*Company][Company:1]]
(after! company
  (setq company-idle-delay 0.5
        company-minimum-prefix-length 2)
  (setq company-show-numbers t)
(add-hook 'evil-normal-state-entry-hook #'company-abort)) ;; make aborting less annoying.
;; Company:1 ends here

;; [[file:~/.doom.d/config.org::*Company][Company:2]]
(setq-default history-length 1000)
(setq-default prescient-history-length 1000)
;; Company:2 ends here

;; [[file:~/.doom.d/config.org::*Plain%20Text][Plain Text:1]]
(set-company-backend! '(text-mode
                        markdown-mode
                        gfm-mode)
  '(:seperate company-ispell
              company-files
              company-yasnippet))
;; Plain Text:1 ends here

;; [[file:~/.doom.d/config.org::*ESS][ESS:1]]
(set-company-backend! 'ess-r-mode '(company-R-args company-R-objects company-dabbrev-code :separate))
;; ESS:1 ends here

;; [[file:~/.doom.d/config.org::*Elcord][Elcord:1]]
(setq elcord-use-major-mode-as-main-icon t)
;; Elcord:1 ends here

;; [[file:~/.doom.d/config.org::*%5B%5Bhttps://github.com/zachcurry/emacs-anywhere%5D%5BEmacs%20Anywhere%5D%5D%20configuration][[[https://github.com/zachcurry/emacs-anywhere][Emacs Anywhere]] configuration:1]]
(defun markdown-window-p (window-title)
  "Judges from WINDOW-TITLE whether the current window likes markdown"
  (if (string-match-p (rx (or "Stack Exchange" "Stack Overflow"
                          "Pull Request" "Issue" "Discord"))
                  window-title) t nil))
;; [[https://github.com/zachcurry/emacs-anywhere][Emacs Anywhere]] configuration:1 ends here

;; [[file:~/.doom.d/config.org::*%5B%5Bhttps://github.com/zachcurry/emacs-anywhere%5D%5BEmacs%20Anywhere%5D%5D%20configuration][[[https://github.com/zachcurry/emacs-anywhere][Emacs Anywhere]] configuration:2]]
(defvar emacs-anywhere--active-markdown nil
  "Whether the buffer started off as markdown.
Affects behaviour of `emacs-anywhere--finalise-content'")

(defun emacs-anywhere--finalise-content (&optional _frame)
  (when emacs-anywhere--active-markdown
    (fundamental-mode)
    (goto-char (point-min))
    (insert "#+OPTIONS: toc:nil\n")
    (rename-buffer "*EA Pre Export*")
    (org-export-to-buffer 'gfm ea--buffer-name)
    (kill-buffer "*EA Pre Export*"))
  (gui-select-text (buffer-string)))

(define-minor-mode emacs-anywhere-mode
  "To tweak the current buffer for some emacs-anywhere considerations"
  :init-value nil
  :keymap (list
           ;; Finish edit, but be smart in org mode
           (cons (kbd "C-c C-c") (lambda! (if (and (eq major-mode 'org-mode)
                                                   (org-in-src-block-p))
                                              (org-ctrl-c-ctrl-c)
                                            (delete-frame))))
           ;; Abort edit. emacs-anywhere saves the current edit for next time.
           (cons (kbd "C-c C-k") (lambda! (setq ea-on nil)
                                          (delete-frame))))
  (when emacs-anywhere-mode
    ;; line breaking
    (turn-off-auto-fill)
    (visual-line-mode t)
    ;; DEL/C-SPC to clear (first keystroke only)
    (set-transient-map (let ((keymap (make-sparse-keymap)))
                         (define-key keymap (kbd "DEL")   (lambda! (delete-region (point-min) (point-max))))
                         (define-key keymap (kbd "C-SPC") (lambda! (delete-region (point-min) (point-max))))
                         keymap))
    ;; disable tabs
    (when (bound-and-true-p centaur-tabs-mode)
      (centaur-tabs-local-mode t))))

(defun ea-popup-handler (app-name window-title x y w h)
  (interactive)
  (set-frame-size (selected-frame) 80 12)
  ;; position the frame near the mouse
  (let* ((mousepos (split-string (shell-command-to-string "xdotool getmouselocation | sed -E \"s/ screen:0 window:[^ ]*|x:|y://g\"")))
         (mouse-x (- (string-to-number (nth 0 mousepos)) 100))
         (mouse-y (- (string-to-number (nth 1 mousepos)) 50)))
    (set-frame-position (selected-frame) mouse-x mouse-y))

  (set-frame-name (concat "Quick Edit ∷ " ea-app-name " — "
                          (truncate-string-to-width
                           (string-trim
                            (string-trim-right window-title
                                               (format "-[A-Za-z0-9 ]*%s" ea-app-name))
                            "[\s-]+" "[\s-]+")
                           45 nil nil "…")))
  (message "window-title: %s" window-title)

  (when-let ((selection (gui-get-selection 'PRIMARY)))
    (insert selection))

  (setq emacs-anywhere--active-markdown (markdown-window-p window-title))

  ;; convert buffer to org mode if markdown
  (when emacs-anywhere--active-markdown
    (shell-command-on-region (point-min) (point-max)
                             "pandoc -f markdown -t org" nil t)
    (deactivate-mark) (goto-char (point-max)))

  ;; set major mode
  (org-mode)

  (advice-add 'ea--delete-frame-handler :before #'emacs-anywhere--finalise-content)

  ;; I'll be honest with myself, I /need/ spellcheck
  (flyspell-buffer)

  (evil-insert-state) ; start in insert
  (emacs-anywhere-mode 1))

(add-hook 'ea-popup-hook 'ea-popup-handler)
;; [[https://github.com/zachcurry/emacs-anywhere][Emacs Anywhere]] configuration:2 ends here

;; [[file:~/.doom.d/config.org::*Eros-eval][Eros-eval:1]]
(setq eros-eval-result-prefix "⟹ ")
;; Eros-eval:1 ends here

;; [[file:~/.doom.d/config.org::*EVIL][EVIL:1]]
(after! evil (evil-escape-mode nil))
;; EVIL:1 ends here

;; [[file:~/.doom.d/config.org::*Flyspell][Flyspell:1]]
(after! flyspell (require 'flyspell-lazy) (flyspell-lazy-mode 1))
;; Flyspell:1 ends here

;; [[file:~/.doom.d/config.org::*Info%20colors][Info colors:1]]
(use-package! info-colors
  :commands (info-colors-fontify-node))

(add-hook 'Info-selection-hook 'info-colors-fontify-node)

(add-hook 'Info-mode-hook #'mixed-pitch-mode)
;; Info colors:1 ends here

;; [[file:~/.doom.d/config.org::*Ispell][Ispell:1]]
(setq ispell-dictionary "en-custom")
;; Ispell:1 ends here

;; [[file:~/.doom.d/config.org::*Ispell][Ispell:2]]
(setq ispell-personal-dictionary (expand-file-name ".hunspell_personal" doom-private-dir))
;; Ispell:2 ends here

;; [[file:~/.doom.d/config.org::*Ivy][Ivy:1]]
(setq ivy-read-action-function #'ivy-hydra-read-action)
;; Ivy:1 ends here

;; [[file:~/.doom.d/config.org::*Org%20Chef][Org Chef:1]]
(use-package! org-chef
  :commands (org-chef-insert-recipe org-chef-get-recipe-from-url))
;; Org Chef:1 ends here

;; [[file:~/.doom.d/config.org::*Projectile][Projectile:1]]
(setq projectile-ignored-projects '("~/" "/tmp" "~/.emacs.d/.local/straight/repos/"))
(defun projectile-ignored-project-function (filepath)
  "Return t if FILEPATH is within any of `projectile-ignored-projects'"
  (or (mapcar (lambda (p) (s-starts-with-p p filepath)) projectile-ignored-projects)))
;; Projectile:1 ends here

;; [[file:~/.doom.d/config.org::*Smart%20Parentheses][Smart Parentheses:1]]
(sp-local-pair
     '(org-mode)
     "<<" ">>"
     :actions '(insert))
;; Smart Parentheses:1 ends here

;; [[file:~/.doom.d/config.org::*Spray][Spray:1]]
(setq spray-wpm 500
      spray-height 700)
;; Spray:1 ends here

;; [[file:~/.doom.d/config.org::*Theme%20magic][Theme magic:1]]
(add-hook 'doom-load-theme-hook 'theme-magic-from-emacs)
;; Theme magic:1 ends here

;; [[file:~/.doom.d/config.org::*Which-key][Which-key:1]]
(setq which-key-idle-delay 0.5) ;; I need the help, I really do
;; Which-key:1 ends here

;; [[file:~/.doom.d/config.org::*Which-key][Which-key:2]]
(setq which-key-allow-multiple-replacements t)
(after! which-key
  (pushnew!
   which-key-replacement-alist
   '(("" . "\\`+?evil[-:]?\\(?:a-\\)?\\(.*\\)") . (nil . "◂ \\1"))
   '(("\\`g s" . "\\`evilem--?motion-\\(.*\\)") . (nil . "◃ \\1"))
   ))
;; Which-key:2 ends here

;; [[file:~/.doom.d/config.org::*xkcd][xkcd:1]]
(use-package! xkcd
  :commands (xkcd-get-json xkcd-download xkcd-get
             ;; now for funcs from my extension of this pkg
             +xkcd-find-and-copy +xkcd-find-and-view
             +xkcd-fetch-info +xkcd-select)
  :config
  (add-to-list 'evil-snipe-disabled-modes 'xkcd-mode)
  :general (:states 'normal
            :keymaps 'xkcd-mode-map
            "<right>" #'xkcd-next
            "n"       #'xkcd-next ; evil-ish
            "<left>"  #'xkcd-prev
            "N"       #'xkcd-prev ; evil-ish
            "r"       #'xkcd-rand
            "a"       #'xkcd-rand ; because image-rotate can interfere
            "t"       #'xkcd-alt-text
            "q"       #'xkcd-kill-buffer
            "o"       #'xkcd-open-browser
            "e"       #'xkcd-open-explanation-browser
            ;; extras
            "s"       #'+xkcd-find-and-view
            "/"       #'+xkcd-find-and-view
            "y"       #'+xkcd-copy))
;; xkcd:1 ends here

;; [[file:~/.doom.d/config.org::*xkcd][xkcd:2]]
(after! xkcd
  (require 'emacsql-sqlite)

  (defun +xkcd-select ()
    "Prompt the user for an xkcd using `ivy-read' and `+xkcd-select-format'. Return the xkcd number or nil"
    (let* (prompt-lines
           (-dummy (maphash (lambda (key xkcd-info)
                              (push (+xkcd-select-format xkcd-info) prompt-lines))
                            +xkcd-stored-info))
           (num (ivy-read (format "xkcd (%s): " xkcd-latest) prompt-lines)))
      (if (equal "" num) xkcd-latest
        (string-to-number (replace-regexp-in-string "\\([0-9]+\\).*" "\\1" num)))))

  (defun +xkcd-select-format (xkcd-info)
    "Creates each ivy-read line from an xkcd info plist. Must start with the xkcd number"
    (format "%-4s  %-30s %s"
            (propertize (number-to-string (plist-get xkcd-info :num))
                        'face 'counsel-key-binding)
            (plist-get xkcd-info :title)
            (propertize (plist-get xkcd-info :alt)
                        'face '(variable-pitch font-lock-comment-face))))

  (defun +xkcd-fetch-info (&optional num)
    "Fetch the parsed json info for comic NUM. Fetches latest when omitted or 0"
    (require 'xkcd)
    (when (or (not num) (= num 0))
      (+xkcd-check-latest)
      (setq num xkcd-latest))
    (let ((res (or (gethash num +xkcd-stored-info)
                   (puthash num (+xkcd-db-read num) +xkcd-stored-info))))
      (unless res
        (+xkcd-db-write
         (let* ((url (format "https://xkcd.com/%d/info.0.json" num))
                (json-assoc
                 (if (gethash num +xkcd-stored-info)
                     (gethash num +xkcd-stored-info)
                   (json-read-from-string (xkcd-get-json url num)))))
           json-assoc))
        (setq res (+xkcd-db-read num)))
      res))

  ;; since we've done this, we may as well go one little step further
  (defun +xkcd-find-and-copy ()
    "Prompt for an xkcd using `+xkcd-select' and copy url to clipboard"
    (interactive)
    (+xkcd-copy (+xkcd-select)))

  (defun +xkcd-copy (&optional num)
    "Copy a url to xkcd NUM to the clipboard"
    (interactive "i")
    (let ((num (or num xkcd-cur)))
      (gui-select-text (format "https://xkcd.com/%d" num))
      (message "xkcd.com/%d copied to clipboard" num)))

  (defun +xkcd-find-and-view ()
    "Prompt for an xkcd using `+xkcd-select' and view it"
    (interactive)
    (xkcd-get (+xkcd-select))
    (switch-to-buffer "*xkcd*"))

  (defvar +xkcd-latest-max-age (* 60 60) ; 1 hour
    "Time after which xkcd-latest should be refreshed, in seconds")

  ;; initialise `xkcd-latest' and `+xkcd-stored-info' with latest xkcd
  (add-transient-hook! '+xkcd-select
    (require 'xkcd)
    (+xkcd-fetch-info xkcd-latest)
    (setq +xkcd-stored-info (+xkcd-db-read-all)))

  (add-transient-hook! '+xkcd-fetch-info
    (xkcd-update-latest))

  (defun +xkcd-check-latest ()
    "Use value in `xkcd-cache-latest' as long as it isn't older thabn `+xkcd-latest-max-age'"
    (unless (and (file-exists-p xkcd-cache-latest)
                 (< (- (time-to-seconds (current-time))
                       (time-to-seconds (file-attribute-modification-time (file-attributes xkcd-cache-latest))))
                    +xkcd-latest-max-age))
      (let* ((out (xkcd-get-json "https://xkcd.com/info.0.json" 0))
             (json-assoc (json-read-from-string out))
             (latest (cdr (assoc 'num json-assoc))))
        (when (/= xkcd-latest latest)
          (+xkcd-db-write json-assoc)
          (with-current-buffer (find-file xkcd-cache-latest)
            (setq xkcd-latest latest)
            (erase-buffer)
            (insert (number-to-string latest))
            (save-buffer)
            (kill-buffer (current-buffer)))))
      (shell-command (format "touch %s" xkcd-cache-latest))))

  (defvar +xkcd-stored-info (make-hash-table :test 'eql)
    "Basic info on downloaded xkcds, in the form of a hashtable")

  (defadvice! xkcd-get-json--and-cache (url &optional num)
    "Fetch the Json coming from URL.
If the file NUM.json exists, use it instead.
If NUM is 0, always download from URL.
The return value is a string."
    :override #'xkcd-get-json
    (let* ((file (format "%s%d.json" xkcd-cache-dir num))
           (cached (and (file-exists-p file) (not (eq num 0))))
           (out (with-current-buffer (if cached
                                         (find-file file)
                                       (url-retrieve-synchronously url))
                  (goto-char (point-min))
                  (unless cached (re-search-forward "^$"))
                  (prog1
                      (buffer-substring-no-properties (point) (point-max))
                    (kill-buffer (current-buffer))))))
      (unless (or cached (eq num 0))
        (xkcd-cache-json num out))
      out))

  (defadvice! +xkcd-get (num)
    "Get the xkcd number NUM."
    :override 'xkcd-get
    (interactive "nEnter comic number: ")
    (xkcd-update-latest)
    (get-buffer-create "*xkcd*")
    (switch-to-buffer "*xkcd*")
    (xkcd-mode)
    (let (buffer-read-only)
      (erase-buffer)
      (setq xkcd-cur num)
      (let* ((xkcd-data (+xkcd-fetch-info num))
             (num (plist-get xkcd-data :num))
             (img (plist-get xkcd-data :img))
             (safe-title (plist-get xkcd-data :safe-title))
             (alt (plist-get xkcd-data :alt))
             title file)
        (message "Getting comic...")
        (setq file (xkcd-download img num))
        (setq title (format "%d: %s" num safe-title))
        (insert (propertize title
                            'face 'outline-1))
        (center-line)
        (insert "\n")
        (xkcd-insert-image file num)
        (if (eq xkcd-cur 0)
            (setq xkcd-cur num))
        (setq xkcd-alt alt)
        (message "%s" title))))

  (defconst +xkcd-db--sqlite-available-p
    (with-demoted-errors "+org-xkcd initialization: %S"
      (emacsql-sqlite-ensure-binary)
      t))

  (defvar +xkcd-db--connection (make-hash-table :test #'equal)
    "Database connection to +org-xkcd database.")

  (defun +xkcd-db--get ()
    "Return the sqlite db file."
    (expand-file-name "xkcd.db" xkcd-cache-dir))

  (defun +xkcd-db--get-connection ()
    "Return the database connection, if any."
    (gethash (file-truename xkcd-cache-dir)
             +xkcd-db--connection))

  (defconst +xkcd-db--table-schema
    '((xkcds
       [(num integer :unique :primary-key)
        (year        :not-null)
        (month       :not-null)
        (link        :not-null)
        (news        :not-null)
        (safe_title  :not-null)
        (title       :not-null)
        (transcript  :not-null)
        (alt         :not-null)
        (img         :not-null)])))

  (defun +xkcd-db--init (db)
    "Initialize database DB with the correct schema and user version."
    (emacsql-with-transaction db
      (pcase-dolist (`(,table . ,schema) +xkcd-db--table-schema)
        (emacsql db [:create-table $i1 $S2] table schema))))

  (defun +xkcd-db ()
    "Entrypoint to the +org-xkcd sqlite database.
Initializes and stores the database, and the database connection.
Performs a database upgrade when required."
    (unless (and (+xkcd-db--get-connection)
                 (emacsql-live-p (+xkcd-db--get-connection)))
      (let* ((db-file (+xkcd-db--get))
             (init-db (not (file-exists-p db-file))))
        (make-directory (file-name-directory db-file) t)
        (let ((conn (emacsql-sqlite db-file)))
          (set-process-query-on-exit-flag (emacsql-process conn) nil)
          (puthash (file-truename xkcd-cache-dir)
                   conn
                   +xkcd-db--connection)
          (when init-db
            (+xkcd-db--init conn)))))
    (+xkcd-db--get-connection))

  (defun +xkcd-db-query (sql &rest args)
    "Run SQL query on +org-xkcd database with ARGS.
SQL can be either the emacsql vector representation, or a string."
    (if  (stringp sql)
        (emacsql (+xkcd-db) (apply #'format sql args))
      (apply #'emacsql (+xkcd-db) sql args)))

  (defun +xkcd-db-read (num)
    (when-let ((res
                (car (+xkcd-db-query [:select * :from xkcds
                                      :where (= num $s1)]
                                     num
                                     :limit 1))))
      (+xkcd-db-list-to-plist res)))

  (defun +xkcd-db-read-all ()
    (let ((xkcd-table (make-hash-table :test 'eql :size 4000)))
      (mapcar (lambda (xkcd-info-list)
                (puthash (car xkcd-info-list) (+xkcd-db-list-to-plist xkcd-info-list) xkcd-table))
              (+xkcd-db-query [:select * :from xkcds]))
      xkcd-table))

  (defun +xkcd-db-list-to-plist (xkcd-datalist)
    `(:num ,(nth 0 xkcd-datalist)
      :year ,(nth 1 xkcd-datalist)
      :month ,(nth 2 xkcd-datalist)
      :link ,(nth 3 xkcd-datalist)
      :news ,(nth 4 xkcd-datalist)
      :safe-title ,(nth 5 xkcd-datalist)
      :title ,(nth 6 xkcd-datalist)
      :transcript ,(nth 7 xkcd-datalist)
      :alt ,(nth 8 xkcd-datalist)
      :img ,(nth 9 xkcd-datalist)))

  (defun +xkcd-db-write (data)
    (+xkcd-db-query [:insert-into xkcds
                     :values $v1]
                    (list (vector
                           (cdr (assoc 'num        data))
                           (cdr (assoc 'year       data))
                           (cdr (assoc 'month      data))
                           (cdr (assoc 'link       data))
                           (cdr (assoc 'news       data))
                           (cdr (assoc 'safe_title data))
                           (cdr (assoc 'title      data))
                           (cdr (assoc 'transcript data))
                           (cdr (assoc 'alt        data))
                           (cdr (assoc 'img        data))
                           )))))
;; xkcd:2 ends here

;; [[file:~/.doom.d/config.org::*Tweaking%20defaults][Tweaking defaults:1]]
(setq org-directory "~/.org"                      ; let's put files here
      org-use-property-inheritance t              ; it's convenient to have properties inherited
      org-log-done 'time                          ; having the time a item is done sounds convininet
      org-list-allow-alphabetical t               ; have a. A. a) A) list bullets
      org-export-in-background t                  ; run export processes in external emacs process
      org-catch-invisible-edits 'smart)           ; try not to accidently do weird stuff in invisible regions
;; Tweaking defaults:1 ends here

;; [[file:~/.doom.d/config.org::*Tweaking%20defaults][Tweaking defaults:2]]
(setq org-babel-default-header-args '((:session . "none")
                                      (:results . "replace")
                                      (:exports . "code")
                                      (:cache . "no")
                                      (:noweb . "no")
                                      (:hlines . "no")
                                      (:tangle . "no")
                                      (:comments . "link")))
;; Tweaking defaults:2 ends here

;; [[file:~/.doom.d/config.org::*Org%20buffer%20creation][Org buffer creation:1]]
(evil-define-command evil-buffer-org-new (count file)
  "Creates a new ORG buffer replacing the current window, optionally
   editing a certain FILE"
  :repeat nil
  (interactive "P<f>")
  (if file
      (evil-edit file)
    (let ((buffer (generate-new-buffer "*new org*")))
      (set-window-buffer nil buffer)
      (with-current-buffer buffer
        (org-mode)))))
(map! :leader
  (:prefix "b"
    :desc "New empty ORG buffer" "o" #'evil-buffer-org-new))
;; Org buffer creation:1 ends here

;; [[file:~/.doom.d/config.org::*List%20bullet%20sequence][List bullet sequence:1]]
(setq org-list-demote-modify-bullet '(("+" . "-") ("-" . "+") ("*" . "+")))
;; List bullet sequence:1 ends here

;; [[file:~/.doom.d/config.org::*LSP%20support%20in%20~src~%20blocks][LSP support in ~src~ blocks:1]]
(cl-defmacro lsp-org-babel-enable (lang)
    "Support LANG in org source code block."
    (setq centaur-lsp 'lsp-mode)
    (cl-check-type lang stringp)
    (let* ((edit-pre (intern (format "org-babel-edit-prep:%s" lang)))
           (intern-pre (intern (format "lsp--%s" (symbol-name edit-pre)))))
      `(progn
         (defun ,intern-pre (info)
           (let ((file-name (->> info caddr (alist-get :file))))
             (unless file-name
               (setq file-name (make-temp-file "babel-lsp-")))
             (setq buffer-file-name file-name)
              (lsp-deferred)))
         (put ',intern-pre 'function-documentation
              (format "Enable lsp-mode in the buffer of org source block (%s)."
                      (upcase ,lang)))
         (if (fboundp ',edit-pre)
             (advice-add ',edit-pre :after ',intern-pre)
           (progn
             (defun ,edit-pre (info)
               (,intern-pre info))
             (put ',edit-pre 'function-documentation
                  (format "Prepare local buffer environment for org source block (%s)."
                          (upcase ,lang))))))))
  (defvar org-babel-lang-list
    '("go" "python" "ipython" "bash" "sh"))
  (dolist (lang org-babel-lang-list)
    (eval `(lsp-org-babel-enable ,lang)))
;; LSP support in ~src~ blocks:1 ends here

;; [[file:~/.doom.d/config.org::*View%20exported%20file][View exported file:1]]
(after! org
  (map! :map org-mode-map
        :localleader
        :desc "View exported file" "v" #'org-view-output-file)

  (defun org-view-output-file (&optional org-file-path)
    (interactive)
    "Visit buffer open on the first output file (if any) found, using `org-view-output-file-extensions'"
    (let* ((org-file-path (or org-file-path (buffer-file-name) ""))
           (dir (file-name-directory org-file-path))
           (basename (file-name-base org-file-path))
           (output-file nil))
      (dolist (ext org-view-output-file-extensions)
        (unless output-file
          (when (file-exists-p
                 (concat dir basename "." ext))
                 (setq output-file (concat dir basename "." ext)))))
      (if output-file
        (pop-to-buffer (or (find-buffer-visiting output-file)
                           (find-file-noselect output-file)))
        (message "No exported file found")))))

(defvar org-view-output-file-extensions '("pdf" "md" "rst" "txt" "tex")
  "Search for output files with these extensions, in order, viewing the first that matches")
;; View exported file:1 ends here

;; [[file:~/.doom.d/config.org::*Super%20agenda][Super agenda:1]]
(use-package! org-super-agenda
  :commands (org-super-agenda-mode))
(after! org-agenda
  (org-super-agenda-mode))

(setq org-agenda-skip-scheduled-if-done t
      org-agenda-skip-deadline-if-done t
      org-agenda-include-deadlines t
      org-agenda-block-separator nil
      org-agenda-tags-column 100 ;; from testing this seems to be a good value
      org-agenda-compact-blocks t)

(setq org-agenda-custom-commands
      '(("o" "Overview"
         ((agenda "" ((org-agenda-span 'day)
                      (org-super-agenda-groups
                       '((:name "Today"
                                :time-grid t
                                :date today
                                :todo "TODAY"
                                :scheduled today
                                :order 1)))))
          (alltodo "" ((org-agenda-overriding-header "")
                       (org-super-agenda-groups
                        '((:name "Next to do"
                                 :todo "NEXT"
                                 :order 1)
                          (:name "Important"
                                 :tag "Important"
                                 :priority "A"
                                 :order 6)
                          (:name "Due Today"
                                 :deadline today
                                 :order 2)
                          (:name "Due Soon"
                                 :deadline future
                                 :order 8)
                          (:name "Overdue"
                                 :deadline past
                                 :face error
                                 :order 7)
                          (:name "Mentor"
                                 :tag "@mentor"
                                 :order 10)
                          (:name "Issues"
                                 :tag "Issue"
                                 :order 12)
                          (:name "Emacs"
                                 :tag "@emacs"
                                 :order 13)
                          (:name "Projects"
                                 :tag "Project"
                                 :order 14)
                          (:name "Research"
                                 :tag "Research"
                                 :order 15)
                          (:name "To read"
                                 :tag "Read"
                                 :order 30)
                          (:name "Waiting"
                                 :todo "WAITING"
                                 :order 20)
                          (:name "University"
                                 :tag "uni"
                                 :order 32)
                          (:name "Trivial"
                                 :priority<= "E"
                                 :tag ("Trivial" "Unimportant")
                                 :todo ("SOMEDAY" )
                                 :order 90)
                          (:discard (:tag ("Chore" "Routine" "Daily")))))))))))
;; Super agenda:1 ends here

;; [[file:~/.doom.d/config.org::*Capture][Capture:1]]
(use-package! doct
  :commands (doct))

(after! org-capture
  (defun org-capture-select-template-prettier (&optional keys)
    "Select a capture template, in a prettier way than default
  Lisp programs can force the template by setting KEYS to a string."
    (let ((org-capture-templates
           (or (org-contextualize-keys
                (org-capture-upgrade-templates org-capture-templates)
                org-capture-templates-contexts)
               '(("t" "Task" entry (file+headline "" "Tasks")
                  "* TODO %?\n  %u\n  %a")))))
      (if keys
          (or (assoc keys org-capture-templates)
              (error "No capture template referred to by \"%s\" keys" keys))
        (org-mks org-capture-templates
                 "Select a capture template\n━━━━━━━━━━━━━━━━━━━━━━━━━"
                 "Template key: "
                 `(("q" ,(concat (all-the-icons-octicon "stop" :face 'all-the-icons-red :v-adjust 0.01) "\tAbort")))))))
  (advice-add 'org-capture-select-template :override #'org-capture-select-template-prettier)
  
  (defun org-mks-pretty (table title &optional prompt specials)
    "Select a member of an alist with multiple keys. Prettified.
  
  TABLE is the alist which should contain entries where the car is a string.
  There should be two types of entries.
  
  1. prefix descriptions like (\"a\" \"Description\")
     This indicates that `a' is a prefix key for multi-letter selection, and
     that there are entries following with keys like \"ab\", \"ax\"…
  
  2. Select-able members must have more than two elements, with the first
     being the string of keys that lead to selecting it, and the second a
     short description string of the item.
  
  The command will then make a temporary buffer listing all entries
  that can be selected with a single key, and all the single key
  prefixes.  When you press the key for a single-letter entry, it is selected.
  When you press a prefix key, the commands (and maybe further prefixes)
  under this key will be shown and offered for selection.
  
  TITLE will be placed over the selection in the temporary buffer,
  PROMPT will be used when prompting for a key.  SPECIALS is an
  alist with (\"key\" \"description\") entries.  When one of these
  is selected, only the bare key is returned."
    (save-window-excursion
      (let ((inhibit-quit t)
      (buffer (org-switch-to-buffer-other-window "*Org Select*"))
      (prompt (or prompt "Select: "))
      case-fold-search
      current)
        (unwind-protect
      (catch 'exit
        (while t
          (setq-local evil-normal-state-cursor (list nil))
          (erase-buffer)
          (insert title "\n\n")
          (let ((des-keys nil)
          (allowed-keys '("\C-g"))
          (tab-alternatives '("\s" "\t" "\r"))
          (cursor-type nil))
      ;; Populate allowed keys and descriptions keys
      ;; available with CURRENT selector.
      (let ((re (format "\\`%s\\(.\\)\\'"
            (if current (regexp-quote current) "")))
            (prefix (if current (concat current " ") "")))
        (dolist (entry table)
          (pcase entry
            ;; Description.
            (`(,(and key (pred (string-match re))) ,desc)
             (let ((k (match-string 1 key)))
         (push k des-keys)
         ;; Keys ending in tab, space or RET are equivalent.
         (if (member k tab-alternatives)
             (push "\t" allowed-keys)
           (push k allowed-keys))
         (insert (propertize prefix 'face 'font-lock-comment-face) (propertize k 'face 'bold) (propertize "›" 'face 'font-lock-comment-face) "  " desc "…" "\n")))
            ;; Usable entry.
            (`(,(and key (pred (string-match re))) ,desc . ,_)
             (let ((k (match-string 1 key)))
         (insert (propertize prefix 'face 'font-lock-comment-face) (propertize k 'face 'bold) "   " desc "\n")
         (push k allowed-keys)))
            (_ nil))))
      ;; Insert special entries, if any.
      (when specials
        (insert "─────────────────────────\n")
        (pcase-dolist (`(,key ,description) specials)
          (insert (format "%s   %s\n" (propertize key 'face '(bold all-the-icons-red)) description))
          (push key allowed-keys)))
      ;; Display UI and let user select an entry or
      ;; a sub-level prefix.
      (goto-char (point-min))
      (unless (pos-visible-in-window-p (point-max))
        (org-fit-window-to-buffer))
      (let ((pressed (org--mks-read-key allowed-keys prompt)))
        (setq current (concat current pressed))
        (cond
         ((equal pressed "\C-g") (user-error "Abort"))
         ;; Selection is a prefix: open a new menu.
         ((member pressed des-keys))
         ;; Selection matches an association: return it.
         ((let ((entry (assoc current table)))
            (and entry (throw 'exit entry))))
         ;; Selection matches a special entry: return the
         ;; selection prefix.
         ((assoc current specials) (throw 'exit current))
         (t (error "No entry available")))))))
    (when buffer (kill-buffer buffer))))))
  (advice-add 'org-mks :override #'org-mks-pretty)
  ;; (setq +org-capture-uni-units (split-string (f-read-text "~/.org/.uni-units")))
  (setq +org-capture-recipies  "~/Desktop/TEC/Organisation/recipies.org")

  (defun +doct-icon-declaration-to-icon (declaration)
    "Convert :icon declaration to icon"
    (let ((name (pop declaration))
          (set  (intern (concat "all-the-icons-" (plist-get declaration :set))))
          (face (intern (concat "all-the-icons-" (plist-get declaration :color))))
          (v-adjust (or (plist-get declaration :v-adjust) 0.01)))
      (apply set `(,name :face ,face :v-adjust ,v-adjust))))

  (defun +doct-iconify-capture-templates (groups)
    "Add declaration's :icon to each template group in GROUPS."
    (let ((templates (doct-flatten-lists-in groups)))
      (setq doct-templates (mapcar (lambda (template)
                                     (when-let* ((props (nthcdr (if (= (length template) 4) 2 5) template))
                                                 (spec (plist-get (plist-get props :doct) :icon)))
                                       (setf (nth 1 template) (concat (+doct-icon-declaration-to-icon spec)
                                                                      "\t"
                                                                      (nth 1 template))))
                                     template)
                                   templates))))

  (setq doct-after-conversion-functions '(+doct-iconify-capture-templates))

  (add-transient-hook! 'org-capture-select-template
    (setq org-capture-templates
          (doct `(("Personal todo" :keys "t"
                   :icon ("checklist" :set "octicon" :color "green")
                   :file +org-capture-todo-file
                   :prepend t
                   :headline "Inbox"
                   :type entry
                   :template ("* TODO %?"
                              "%i %a")
                   )
                  ("Personal note" :keys "n"
                   :icon ("sticky-note-o" :set "faicon" :color "green")
                   :file +org-capture-todo-file
                   :prepend t
                   :headline "Inbox"
                   :type entry
                   :template ("* %?"
                              "%i %a")
                   )
                  ;; ("University" :keys "u"
                  ;;  :icon ("graduation-cap" :set "faicon" :color "purple")
                  ;;  :file +org-capture-todo-file
                  ;;  :headline "University"
                  ;;  :unit-prompt ,(format "%%^{Unit|%s}" (string-join +org-capture-uni-units "|"))
                  ;;  :prepend t
                  ;;  :type entry
                  ;;  :children (("Test" :keys "t"
                  ;;              :icon ("timer" :set "material" :color "red")
                  ;;              :template ("* TODO [#C] %{unit-prompt} %? :uni:tests:"
                  ;;                         "SCHEDULED: %^{Test date:}T"
                  ;;                         "%i %a"))
                  ;;             ("Assignment" :keys "a"
                  ;;              :icon ("library_books" :set "material" :color "orange")
                  ;;              :template ("* TODO [#B] %{unit-prompt} %? :uni:assignments:"
                  ;;                         "DEADLINE: %^{Due date:}T"
                  ;;                         "%i %a"))
                  ;;             ("Lecture" :keys "l"
                  ;;              :icon ("keynote" :set "fileicon" :color "orange")
                  ;;              :template ("* TODO [#C] %{unit-prompt} %? :uni:lecture:"
                  ;;                         "%i %a"))
                  ;;             ("Miscellaneous task" :keys "u"
                  ;;              :icon ("list" :set "faicon" :color "yellow")
                  ;;              :template ("* TODO [#D] %{unit-prompt} %? :uni:"
                  ;;                         "%i %a"))))
                  ("Email" :keys "e"
                   :icon ("envelope" :set "faicon" :color "blue")
                   :file +org-capture-todo-file
                   :prepend t
                   :headline "Inbox"
                   :type entry
                   :template ("* TODO %^{type|reply to|contact} %\\3 %? :email:"
                              "Send an email %^{urgancy|soon|ASAP|anon|at some point|eventually} to %^{recipiant}"
                              "about %^{topic}"
                              "%U %i %a"))
                  ("Interesting" :keys "i"
                   :icon ("eye" :set "faicon" :color "lcyan")
                   :file +org-capture-todo-file
                   :prepend t
                   :headline "Interesting"
                   :type entry
                   :template ("* [ ] %{desc}%? :%{i-type}:"
                              "%i %a")
                   :children (("Webpage" :keys "w"
                               :icon ("globe" :set "faicon" :color "green")
                               :desc "%(org-cliplink-capture) "
                               :i-type "read:web"
                               )
                              ("Article" :keys "a"
                               :icon ("file-text" :set "octicon" :color "yellow")
                               :desc ""
                               :i-type "read:reaserch"
                               )
                              ("\tRecipie" :keys "r"
                               :icon ("spoon" :set "faicon" :color "dorange")
                               :file +org-capture-recipies
                               :headline "Unsorted"
                               :template "%(org-chef-get-recipe-from-url)"
                               )
                              ("Information" :keys "i"
                               :icon ("info-circle" :set "faicon" :color "blue")
                               :desc ""
                               :i-type "read:info"
                               )
                              ("Idea" :keys "I"
                               :icon ("bubble_chart" :set "material" :color "silver")
                               :desc ""
                               :i-type "idea"
                               )))
                  ("Tasks" :keys "k"
                   :icon ("inbox" :set "octicon" :color "yellow")
                   :file +org-capture-todo-file
                   :prepend t
                   :headline "Tasks"
                   :type entry
                   :template ("* TODO %? %^G%{extra}"
                              "%i %a")
                   :children (("General Task" :keys "k"
                               :icon ("inbox" :set "octicon" :color "yellow")
                               :extra ""
                               )
                              ("Task with deadline" :keys "d"
                               :icon ("timer" :set "material" :color "orange" :v-adjust -0.1)
                               :extra "\nDEADLINE: %^{Deadline:}t"
                               )
                              ("Scheduled Task" :keys "s"
                               :icon ("calendar" :set "octicon" :color "orange")
                               :extra "\nSCHEDULED: %^{Start time:}t"
                               )
                              ))
                ("Project" :keys "p"
                 :icon ("repo" :set "octicon" :color "silver")
                   :prepend t
                   :type entry
                   :headline "Inbox"
                   :template ("* %{time-or-todo} %?"
                              "%i"
                              "%a")
                   :file ""
                   :custom (:time-or-todo "")
                   :children (("Project-local todo" :keys "t"
                               :icon ("checklist" :set "octicon" :color "green")
                               :time-or-todo "TODO"
                               :file +org-capture-project-todo-file)
                              ("Project-local note" :keys "n"
                               :icon ("sticky-note" :set "faicon" :color "yellow")
                               :time-or-todo "%U"
                               :file +org-capture-project-notes-file)
                              ("Project-local changelog" :keys "c"
                               :icon ("list" :set "faicon" :color "blue")
                               :time-or-todo "%U"
                               :heading "Unreleased"
                               :file +org-capture-project-changelog-file))
                   )
                  ("\tCentralised project templates"
                   :keys "o"
                   :type entry
                   :prepend t
                   :template ("* %{time-or-todo} %?"
                              "%i"
                              "%a")
                   :children (("Project todo"
                               :keys "t"
                               :prepend nil
                               :time-or-todo "TODO"
                               :heading "Tasks"
                               :file +org-capture-central-project-todo-file)
                              ("Project note"
                               :keys "n"
                               :time-or-todo "%U"
                               :heading "Notes"
                               :file +org-capture-central-project-notes-file)
                              ("Project changelog"
                               :keys "c"
                               :time-or-todo "%U"
                               :heading "Unreleased"
                               :file +org-capture-central-project-changelog-file))
                   ))))))
;; Capture:1 ends here

;; [[file:~/.doom.d/config.org::*Capture][Capture:3]]
(setf (alist-get 'height +org-capture-frame-parameters) 15)
      ;; (alist-get 'name +org-capture-frame-parameters) "❖ Capture") ;; ATM hardcoded in other places, so changing breaks stuff
(setq +org-capture-fn
      (lambda ()
        (interactive)
        (set-window-parameter nil 'mode-line-format 'none)
        (org-capture)))
;; Capture:3 ends here

;; [[file:~/.doom.d/config.org::*xkcd][xkcd:1]]
(after! org
  (org-link-set-parameters "xkcd"
                           :image-data-fun #'+org-xkcd-image-fn
                           :follow #'+org-xkcd-open-fn
                           :export #'+org-xkcd-export
                           :complete #'+org-xkcd-complete)

  (defun +org-xkcd-open-fn (link)
    (+org-xkcd-image-fn nil link nil))

  (defun +org-xkcd-image-fn (protocol link description)
    "Get image data for xkcd num LINK"
    (let* ((xkcd-info (+xkcd-fetch-info (string-to-number link)))
           (img (plist-get xkcd-info :img))
           (alt (plist-get xkcd-info :alt)))
      (message alt)
      (+org-image-file-data-fn protocol (xkcd-download img (string-to-number link)) description)))

  (defun +org-xkcd-export (path desc backend _com)
    "Convert xkcd to html/LaTeX form"
    (let* ((xkcd-info (+xkcd-fetch-info (string-to-number path)))
           (img (plist-get xkcd-info :img))
           (alt (plist-get xkcd-info :alt))
           (title (plist-get xkcd-info :title))
           (file (xkcd-download img (string-to-number path))))
      (cond ((org-export-derived-backend-p backend 'html)
             (format "<img src='%s' title=\"%s\" alt='%s'>" img (subst-char-in-string ?\" ?“ alt) title))
            ((org-export-derived-backend-p backend 'latex)
             (format "\\begin{figure}[!htb]
  \\centering
  \\includegraphics[scale=0.4]{%s}
  \\caption*{\\label{xkcd:%s} %s}
\\end{figure}" file path (or desc
                             (format "\\textbf{%s} %s" title alt))))
            (t (format "https://xkcd.com/%s" path)))))

  (defun +org-xkcd-complete (&optional arg)
    "Complete xkcd using `+xkcd-stored-info'"
    (format "xkcd:%d" (+xkcd-select))))
;; xkcd:1 ends here

;; [[file:~/.doom.d/config.org::*YouTube][YouTube:1]]
(after! org
  (org-link-set-parameters "yt" :export #'+org-export-yt)
  (defun +org-export-yt (path desc backend _com)
    (cond ((org-export-derived-backend-p backend 'html)
           (format "<iframe width='440' \
height='335' \
src='https://www.youtube.com/embed/%s' \
frameborder='0' \
allowfullscreen>%s</iframe>" path (or "" desc)))
          ((org-export-derived-backend-p backend 'latex)
           (format "\\href{https://youtu.be/%s}{%s}" path (or desc "youtube")))
          (t (format "https://youtu.be/%s" path)))))
;; YouTube:1 ends here

;; [[file:~/.doom.d/config.org::*Font%20Display][Font Display:1]]
(add-hook! 'org-mode-hook #'+org-pretty-mode #'mixed-pitch-mode)
;; Font Display:1 ends here

;; [[file:~/.doom.d/config.org::*Font%20Display][Font Display:2]]
(setq global-org-pretty-table-mode t)
;; Font Display:2 ends here

;; [[file:~/.doom.d/config.org::*Font%20Display][Font Display:3]]
(custom-set-faces!
  '(outline-1 :weight extra-bold :height 1.25)
  '(outline-2 :weight bold :height 1.15)
  '(outline-3 :weight bold :height 1.12)
  '(outline-4 :weight semi-bold :height 1.09)
  '(outline-5 :weight semi-bold :height 1.06)
  '(outline-6 :weight semi-bold :height 1.03)
  '(outline-8 :weight semi-bold)
  '(outline-9 :weight semi-bold))
;; Font Display:3 ends here

;; [[file:~/.doom.d/config.org::*Symbols][Symbols:1]]
(after! org
  (use-package org-pretty-tags
  :config
   (setq org-pretty-tags-surrogate-strings
         `(("@office"        . ,(all-the-icons-material   "business" :face 'all-the-icons-purple  :v-adjust 0.01))
           ("@home"        . ,(all-the-icons-material "home"       :face 'all-the-icons-silver  :v-adjust 0.01))
           ("knowledge"        . ,(all-the-icons-faicon "puzzle-piece"       :face 'all-the-icons-silver  :v-adjust 0.01))
           ("project" . ,(all-the-icons-material "library_books"  :face 'all-the-icons-orange  :v-adjust 0.01))
           ("notes"       . ,(all-the-icons-material "receipt"          :face 'all-the-icons-lblue     :v-adjust 0.01))
           ("review"       . ,(all-the-icons-material "rate_review"          :face 'all-the-icons-yellow     :v-adjust 0.01))
           ("action"       . ,(all-the-icons-material "person_pin_circle"          :face 'all-the-icons-yellow     :v-adjust 0.01))
           ("lecture"    . ,(all-the-icons-fileicon "keynote"        :face 'all-the-icons-orange  :v-adjust 0.01))
           ("email"      . ,(all-the-icons-faicon   "envelope"       :face 'all-the-icons-blue    :v-adjust 0.01))
           ("read"       . ,(all-the-icons-octicon  "book"           :face 'all-the-icons-lblue   :v-adjust 0.01))
           ("article"    . ,(all-the-icons-octicon  "file-text"      :face 'all-the-icons-yellow  :v-adjust 0.01))
           ("web"        . ,(all-the-icons-faicon   "globe"          :face 'all-the-icons-green   :v-adjust 0.01))
           ("info"       . ,(all-the-icons-faicon   "info-circle"    :face 'all-the-icons-blue    :v-adjust 0.01))
           ("issue"      . ,(all-the-icons-faicon   "bug"            :face 'all-the-icons-red     :v-adjust 0.01))
           ("someday"    . ,(all-the-icons-faicon   "calendar-o"     :face 'all-the-icons-cyan    :v-adjust 0.01))
           ("idea"       . ,(all-the-icons-octicon  "light-bulb"     :face 'all-the-icons-yellow  :v-adjust 0.01))
           ("emacs"      . ,(all-the-icons-fileicon "emacs"          :face 'all-the-icons-lpurple :v-adjust 0.01))))
   (org-pretty-tags-global-mode)))

(after! org-superstar
  (setq org-superstar-headline-bullets-list '("◉" "○" "✸" "✿" "✤" "✜" "◆" "▶")
        ;; org-superstar-headline-bullets-list '("Ⅰ" "Ⅱ" "Ⅲ" "Ⅳ" "Ⅴ" "Ⅵ" "Ⅶ" "Ⅷ" "Ⅸ" "Ⅹ")
        org-superstar-prettify-item-bullets t ))
(after! org
  (setq org-ellipsis " ▾ "
        org-priority-highest ?A
        org-priority-lowest ?E
        org-priority-faces
        '((?A . 'all-the-icons-red)
          (?B . 'all-the-icons-orange)
          (?C . 'all-the-icons-yellow)
          (?D . 'all-the-icons-green)
          (?E . 'all-the-icons-blue))))
;; Symbols:1 ends here

;; [[file:~/.doom.d/config.org::*Symbols][Symbols:2]]
(after! org
  (appendq! +pretty-code-symbols
            `(:checkbox      "☐"
              :pending       "◼"
              :checkedbox    "☑"
              :list_property "∷"
              :results       "🠶"
              :property      "☸"
              :properties    "⚙"
              :end           "∎"
              :options       "⌥"
              :title         "𝙏"
              :author        "𝘼"
              :date          "𝘿"
              :latex_header  "⇥"
              :latex_class   "🄲"
              :begin_quote   "❮"
              :end_quote     "❯"
              :begin_export  "⯮"
              :end_export    "⯬"
              :priority_a   ,(propertize "⚑" 'face 'all-the-icons-red)
              :priority_b   ,(propertize "⬆" 'face 'all-the-icons-orange)
              :priority_c   ,(propertize "■" 'face 'all-the-icons-yellow)
              :priority_d   ,(propertize "⬇" 'face 'all-the-icons-green)
              :priority_e   ,(propertize "❓" 'face 'all-the-icons-blue)
              :em_dash       "—"))
  (set-pretty-symbols! 'org-mode
    :merge t
    :checkbox      "[ ]"
    :pending       "[-]"
    :checkedbox    "[X]"
    :list_property "::"
    :results       "#+RESULTS:"
    :property      "#+PROPERTY:"
    :property      ":PROPERTIES:"
    :end           ":END:"
    :options       "#+OPTIONS:"
    :title         "#+TITLE:"
    :author        "#+AUTHOR:"
    :date          "#+DATE:"
    :latex_class   "#+LATEX_CLASS:"
    :latex_header  "#+LATEX_HEADER:"
    :begin_quote   "#+BEGIN_QUOTE"
    :end_quote     "#+END_QUOTE"
    :begin_export  "#+BEGIN_EXPORT"
    :end_export    "#+END_EXPORT"
    :priority_a    "[#A]"
    :priority_b    "[#B]"
    :priority_c    "[#C]"
    :priority_d    "[#D]"
    :priority_e    "[#E]"
    :em_dash       "---"))
(plist-put +pretty-code-symbols :name "⁍") ; or › could be good?
;; Symbols:2 ends here

;; [[file:~/.doom.d/config.org::*Symbols][Symbols:3]]
(add-hook 'org-mode-hook 'org-fragtog-mode)
;; Symbols:3 ends here

;; [[file:~/.doom.d/config.org::*Exporting%20(general)][Exporting (general):1]]
(after! org (setq org-export-headline-levels 5)) ; I like nesting
;; Exporting (general):1 ends here

;; [[file:~/.doom.d/config.org::*Exporting%20(general)][Exporting (general):2]]
(after! org
  (require 'ox-extra)
  (ox-extras-activate '(ignore-headlines)))
;; Exporting (general):2 ends here

;; [[file:~/.doom.d/config.org::*Custom%20CSS/JS][Custom CSS/JS:2]]
(after! org
(defun my-org-inline-css-hook (exporter)
  "Insert custom inline css to automatically set the
   background of code to whatever theme I'm using's background"
  (when (eq exporter 'html)
    (setq
     org-html-head-extra
     (concat
      (if (s-contains-p "<!––tec/custom-head-start-->" org-html-head-extra)
          (s-replace-regexp "<!––tec\\/custom-head-start-->[^🙜]*<!––tec\\/custom-head-end-->" "" org-html-head-extra)
        org-html-head-extra)
      "<!––tec/custom-head-start-->"
      (format "<style type=\"text/css\">
   :root {
      --theme-bg: %s;
      --theme-bg-alt: %s;
      --theme-base0: %s;
      --theme-base1: %s;
      --theme-base2: %s;
      --theme-base3: %s;
      --theme-base4: %s;
      --theme-base5: %s;
      --theme-base6: %s;
      --theme-base7: %s;
      --theme-base8: %s;
      --theme-fg: %s;
      --theme-fg-alt: %s;
      --theme-grey: %s;
      --theme-red: %s;
      --theme-orange: %s;
      --theme-green: %s;
      --theme-teal: %s;
      --theme-yellow: %s;
      --theme-blue: %s;
      --theme-dark-blue: %s;
      --theme-magenta: %s;
      --theme-violet: %s;
      --theme-cyan: %s;
      --theme-dark-cyan: %s;
   }
</style>"
              (doom-color 'bg)
              (doom-color 'bg-alt)
              (doom-color 'base0)
              (doom-color 'base1)
              (doom-color 'base2)
              (doom-color 'base3)
              (doom-color 'base4)
              (doom-color 'base5)
              (doom-color 'base6)
              (doom-color 'base7)
              (doom-color 'base8)
              (doom-color 'fg)
              (doom-color 'fg-alt)
              (doom-color 'grey)
              (doom-color 'red)
              (doom-color 'orange)
              (doom-color 'green)
              (doom-color 'teal)
              (doom-color 'yellow)
              (doom-color 'blue)
              (doom-color 'dark-blue)
              (doom-color 'magenta)
              (doom-color 'violet)
              (doom-color 'cyan)
              (doom-color 'dark-cyan))
      (if org-msg-currently-exporting ""
      "
<link rel='stylesheet' type='text/css' href='https://fniessen.github.io/org-html-themes/styles/readtheorg/css/htmlize.css'/>
<link rel='stylesheet' type='text/css' href='https://fniessen.github.io/org-html-themes/styles/readtheorg/css/readtheorg.css'/>

<script src='https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js'></script>
<script src='https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/js/bootstrap.min.js'></script>
<script type='text/javascript' src='https://fniessen.github.io/org-html-themes/styles/lib/js/jquery.stickytableheaders.min.js'></script>
<script type='text/javascript' src='https://fniessen.github.io/org-html-themes/styles/readtheorg/js/readtheorg.js'></script>

<style>
 pre.src {
     background-color: var(--theme-bg);
     color: var(--theme-fg);
     scrollbar-color:#bbb6#9992;
     scrollbar-width: thin;
     margin: 0;
     border: none;
 }
 div.org-src-container {
     border-radius: 12px;
     overflow: hidden;
     margin-bottom: 24px;
     margin-top: 1px;
     border: 1px solid#e1e4e5;
 }
 pre.src::before {
     background-color:#6666;
     top: 8px;
     border: none;
     border-radius: 5px;
     line-height: 1;
     border: 2px solid var(--theme-bg);
     opacity: 0;
     transition: opacity 200ms;
 }
 pre.src:hover::before { opacity: 1; }
 pre.src:active::before { opacity: 0; }

 pre.example {
     border-radius: 12px;
     background: var(--theme-bg-alt);
     color: var(--theme-fg);
 }

 code {
     border-radius: 5px;
     background:#e8e8e8;
     font-size: 80%;
 }

 kbd {
     display: inline-block;
     padding: 3px 5px;
     font: 80% SFMono-Regular,Consolas,Liberation Mono,Menlo,monospace;
     line-height: normal;
     line-height: 10px;
     color:#444d56;
     vertical-align: middle;
     background-color:#fafbfc;
     border: 1px solid#d1d5da;
     border-radius: 3px;
     box-shadow: inset 0 -1px 0#d1d5da;
 }

 table {
     max-width: 100%;
     overflow-x: auto;
     display: block;
     border-top: none;
 }

 a:not([aria-hidden='true']) {
     text-decoration: none;
     background-image: linear-gradient(#d8dce9, #d8dce9);
     background-position: 0% 100%;
     background-repeat: no-repeat;
     background-size: 0% 2px;
     transition: background-size .3s;
 }
 \#table-of-contents a {
     background-image: none;
 }
 a:hover:not([aria-hidden='true']),
 a:focus:not([aria-hidden='true']) {
     background-size: 100% 2px;
 }
 a[href^='#'] { font-variant-numeric: oldstyle-nums; }
 a[href^='#']:visited { color:#3091d1; }

 li .checkbox {
     display: inline-block;
     width: 0.9em;
     height: 0.9em;
     border-radius: 3px;
     margin: 3px;
     top: 4px;
     position: relative;
 }
 li.on > .checkbox { background: var(--theme-green); box-shadow: 0 0 2px var(--theme-green); }
 li.trans > .checkbox { background: var(--theme-orange); box-shadow: 0 0 2px var(--theme-orange); }
 li.off > .checkbox { background: var(--theme-red); box-shadow: 0 0 2px var(--theme-red); }
 li.on > .checkbox::after {
     content: '';
     height: 0.45em;
     width: 0.225em;
     -webkit-transform-origin: left top;
     transform-origin: left top;
     transform: scaleX(-1) rotate(135deg);
     border-right: 2.8px solid#fff;
     border-top: 2.8px solid#fff;
     opacity: 0.9;
     left: 0.10em;
     top: 0.45em;
     position: absolute;
 }
 li.trans > .checkbox::after {
     content: '';
     font-weight: bold;
     font-size: 1.6em;
     position: absolute;
     top: 0.23em;
     left: 0.09em;
     width: 0.35em;
     height: 0.12em;
     background:#fff;
     opacity: 0.9;
     border-radius: 0.1em;
 }
 li.off > .checkbox::after {
     content: '✖';
     color:#fff;
     opacity: 0.9;
     position: relative;
     top: -0.40rem;
     left: 0.17em;
     font-size: 0.75em;
 }

 span.timestamp {
     color: #003280;
     background: #647CFF44;
     border-radius: 3px;
     line-height: 1.25;
 }

 \#content img {
     border-radius: 3px;
 }

 \#table-of-contents { overflow-y: auto; }
 blockquote p { margin: 8px 0px 16px 0px; }
 \#postamble .date { color: var(--theme-green); }

 ::-webkit-scrollbar { width: 10px; height: 8px; }
 ::-webkit-scrollbar-track { background:#9992; }
 ::-webkit-scrollbar-thumb { background:#ccc; border-radius: 10px; }
 ::-webkit-scrollbar-thumb:hover { background:#888; }

 /* sometimes this all-important space seems to go missing
 /so let's protect against that. If it's exteranious it's
 /just gobbled anyway. */
 span.section-number-1:after,
 span.section-number-2:after,
 span.section-number-3:after,
 span.section-number-4:after,
 span.section-number-5:after,
 span.section-number-6:after {
     content: ' '
 }

 /* so the bounding box coveres the <a> */
 h1,h2,h3,h4,h5,h6 {
     padding-left: 30px;
     margin-left: -30px;
 }

 h1 > a[aria-hidden='true'],
 h2 > a[aria-hidden='true'],
 h3 > a[aria-hidden='true'],
 h4 > a[aria-hidden='true'],
 h5 > a[aria-hidden='true'],
 h6 > a[aria-hidden='true'] {
     color: #6a737d;
     float: left;
     padding-right: 4px;
     margin-left: -25px;
     position: relative;
     top: 7px;
     line-height: 1;
     font-size: 70%;
     visibility: hidden;
 }

 h1:hover > a[aria-hidden='true'],
 h2:hover > a[aria-hidden='true'],
 h3:hover > a[aria-hidden='true'],
 h4:hover > a[aria-hidden='true'],
 h5:hover > a[aria-hidden='true'],
 h6:hover > a[aria-hidden='true'] {
     visibility: visible;
 }
</style>
")
      "<!––tec/custom-head-end-->"
      ))))

(add-hook 'org-export-before-processing-hook 'my-org-inline-css-hook))
;; Custom CSS/JS:2 ends here

;; [[file:~/.doom.d/config.org::*Make%20verbatim%20different%20to%20code][Make verbatim different to code:1]]
(setq org-html-text-markup-alist
      '((bold . "<b>%s</b>")
        (code . "<code>%s</code>")
        (italic . "<i>%s</i>")
        (strike-through . "<del>%s</del>")
        (underline . "<span class=\"underline\">%s</span>")
        (verbatim . "<kbd>%s</kbd>")))
;; Make verbatim different to code:1 ends here

;; [[file:~/.doom.d/config.org::*Change%20checkbox%20type][Change checkbox type:1]]
(after! org
(appendq! org-html-checkbox-types '((html-span .
	  ((on . "<span class='checkbox'></span>")
	  (off . "<span class='checkbox'></span>")
	  (trans . "<span class='checkbox'></span>")))))
(setq org-html-checkbox-type 'html-span))
;; Change checkbox type:1 ends here

;; [[file:~/.doom.d/config.org::*Header%20anchors][Header anchors:1]]
(after! org
  (defun tec/org-export-html-headline-anchor (text backend info)
    (when (org-export-derived-backend-p backend 'html)
      (unless org-msg-currently-exporting
        (replace-regexp-in-string
         "<h\\([0-9]\\) id=\"\\([a-z0-9-]+\\)\">" ; this is quite restrictive, but due to `org-heading-contraction' I can do this
         "<h\\1 id=\"\\2\">\
 <a class=\"anchor\" aria-hidden=\"true\" href=\"#\\2\">🔗</a>"
         text))))

  (add-to-list 'org-export-filter-headline-functions
               'tec/org-export-html-headline-anchor))
;; Header anchors:1 ends here

;; [[file:~/.doom.d/config.org::*Exporting%20to%20Beamer][Exporting to Beamer:1]]
(setq org-beamer-theme "[progressbar=foot]metropolis")
;; Exporting to Beamer:1 ends here

;; [[file:~/.doom.d/config.org::*Exporting%20to%20Beamer][Exporting to Beamer:2]]

;; Exporting to Beamer:2 ends here

;; [[file:~/.doom.d/config.org::*Exporting%20to%20Beamer][Exporting to Beamer:3]]
(setq org-beamer-frame-level 2)
;; Exporting to Beamer:3 ends here

;; [[file:~/.doom.d/config.org::*Exporting%20to%20GFM][Exporting to GFM:1]]
(eval-after-load "org"
  '(require 'ox-gfm nil t))
;; Exporting to GFM:1 ends here

;; [[file:~/.doom.d/config.org::*Babel][Babel:1]]
(setq org-babel-python-command "python3")
;; Babel:1 ends here

;; [[file:~/.doom.d/config.org::*Babel][Babel:2]]
(defun tec-org-python ()
  (if (eq major-mode 'python-mode)
   (progn (anaconda-mode t)
          (company-mode t)))
  )
(add-hook 'org-src-mode-hook 'tec-org-python)
;; Babel:2 ends here

;; [[file:~/.doom.d/config.org::*ESS][ESS:1]]
(setq ess-eval-visibly 'nowait)
;; ESS:1 ends here

;; [[file:~/.doom.d/config.org::*ESS][ESS:2]]
(setq ess-R-font-lock-keywords '((ess-R-fl-keyword:keywords . t)
 (ess-R-fl-keyword:constants . t)
 (ess-R-fl-keyword:modifiers . t)
 (ess-R-fl-keyword:fun-defs . t)
 (ess-R-fl-keyword:assign-ops . t)
 (ess-R-fl-keyword:%op% . t)
 (ess-fl-keyword:fun-calls . t)
 (ess-fl-keyword:numbers . t)
 (ess-fl-keyword:operators . t)
 (ess-fl-keyword:delimiters . t)
 (ess-fl-keyword:= . t)
 (ess-R-fl-keyword:F&T . t)))
;; ESS:2 ends here

;; [[file:~/.doom.d/config.org::*Python][Python:1]]
(after! lsp-python-ms
  (set-lsp-priority! 'mspyls 1))
;; Python:1 ends here

;; [[file:~/.doom.d/config.org::*Editor%20Visuals][Editor Visuals:1]]
(after! ess-r-mode
  (appendq! +pretty-code-symbols
            '(:assign "⟵"
              :multiply "×"))
  (set-pretty-symbols! 'ess-r-mode
    ;; Functional
    :def "function"
    ;; Types
    :null "NULL"
    :true "TRUE"
    :false "FALSE"
    :int "int"
    :floar "float"
    :bool "bool"
    ;; Flow
    :not "!"
    :and "&&" :or "||"
    :for "for"
    :in "%in%"
    :return "return"
    ;; Other
    :assign "<-"
    :multiply "%*%"))
;; Editor Visuals:1 ends here

;; [[file:~/.doom.d/config.org::*Markdown][Markdown:1]]
(add-hook! (gfm-mode markdown-mode) #'mixed-pitch-mode)
;; Markdown:1 ends here

;; [[file:~/.doom.d/config.org::*Markdown][Markdown:2]]
(add-hook! (gfm-mode markdown-mode) #'visual-line-mode #'turn-off-auto-fill)
;; Markdown:2 ends here

;; [[file:~/.doom.d/config.org::*Markdown][Markdown:3]]
(custom-set-faces!
  '(markdown-header-face-1 :height 1.25 :weight extra-bold :inherit markdown-header-face)
  '(markdown-header-face-2 :height 1.15 :weight bold       :inherit markdown-header-face)
  '(markdown-header-face-3 :height 1.08 :weight bold       :inherit markdown-header-face)
  '(markdown-header-face-4 :height 1.00 :weight bold       :inherit markdown-header-face)
  '(markdown-header-face-5 :height 0.90 :weight bold       :inherit markdown-header-face)
  '(markdown-header-face-6 :height 0.75 :weight extra-bold :inherit markdown-header-face))
;; Markdown:3 ends here

;; [[file:~/.doom.d/config.org::*Zen%20Mode][Zen Mode:1]]
;; (setq writeroom-fullscreen-effect t)
;; Zen Mode:1 ends here

;; [[file:~/.doom.d/config.org::*PDF-Tools][PDF-Tools:1]]
(after! pdf-view
  ;; open pdfs scaled to fit page
  (setq-default pdf-view-display-size 'fit-width)
  ;; (add-hook! 'pdf-view-mode-hook (evil-colemak-basics-mode -1))
  ;; automatically annotate highlights
  (setq pdf-annot-activate-created-annotations t
        pdf-view-resize-factor 1.1)
   ;; faster motion
 (map!
   :map pdf-view-mode-map
   :n "g g"          #'pdf-view-first-page
   :n "G"            #'pdf-view-last-page
   :n "N"            #'pdf-view-next-page-command
   :n "E"            #'pdf-view-previous-page-command
   :n "e"            #'evil-collection-pdf-view-previous-line-or-previous-page
   :n "n"            #'evil-collection-pdf-view-next-line-or-next-page
   :localleader
   (:prefix "o"
    (:prefix "n"
     :desc "Insert" "i" 'org-noter-insert-note
     ))
 ))
;; PDF-Tools:1 ends here

;; [[file:~/.doom.d/config.org::*Setting%20up%20path%20for%20notes][Setting up path for notes:1]]
(setq
   org-directory (concat (getenv "HOME") "/Dropbox/.org/")
   org-notes (concat (getenv "HOME") "/Dropbox/.org/org-notes/")
   org-roam-directory org-notes
   org-brain-path org-notes
   deft-directory org-notes

   org-default-notes-file (expand-file-name "inbox.org" org-directory))
;; Setting up path for notes:1 ends here

;; [[file:~/.doom.d/config.org::*Additional%20paths%20for%20org-noter][Additional paths for org-noter:1]]
(add-to-list 'org-noter-notes-search-path 'org-notes)
(add-to-list 'org-noter-notes-search-path (concat org-notes "/Books"))
;; Additional paths for org-noter:1 ends here

;; [[file:~/.doom.d/config.org::*Setting%20up%20=org-noter=%20with%20=org-brain=][Setting up =org-noter= with =org-brain=:1]]
(defun org-brain-open-org-noter (entry)
    "Open `org-noter' on the ENTRY.
If run interactively, get ENTRY from context."
    (interactive (list (org-brain-entry-at-pt)))
    (org-with-point-at (org-brain-entry-marker entry)
      (org-noter)))
;; Setting up =org-noter= with =org-brain=:1 ends here

;; [[file:~/.doom.d/config.org::*Setting%20up%20=all-the-icons=%20with%20org-brain%20functions][Setting up =all-the-icons= with org-brain functions:1]]
(defun org-brain-insert-resource-icon (link)
  "Insert an icon, based on content of org-mode LINK."
  (insert (format "%s "
                  (cond ((string-prefix-p "brain:" link)
                         (all-the-icons-fileicon "brain"))
                        ((string-prefix-p "info:" link)
                         (all-the-icons-octicon "info"))
                        ((string-prefix-p "help:" link)
                         (all-the-icons-material "help"))
                        ((string-prefix-p "http" link)
                         (all-the-icons-icon-for-url link))
                        (t
                         (all-the-icons-icon-for-file link))))))

  (add-hook 'org-brain-after-resource-button-functions #'org-brain-insert-resource-icon)

(setq org-agenda-category-icon-alist
      `(("computers" ,(list (all-the-icons-material "computer")) nil nil :ascent center)
        ("books" ,(list (all-the-icons-faicon "book")) nil nil :ascent center)))
;; Setting up =all-the-icons= with org-brain functions:1 ends here

;; [[file:~/.doom.d/config.org::*=org-noter=%20specific%20configuration][=org-noter= specific configuration:1]]
(use-package org-noter
  :after (:any org pdf-view)
  :config
  (setq
   ;; The WM can handle splits
   org-noter-notes-window-location 'vertical
   ;; Please stop opening frames
   org-noter-always-create-frame nil
   org-noter-set-doc-split-fraction 0.6
   ;; I want to see the whole file
   org-noter-hide-other nil
   ;; Everything is relative to the main notes file
   ;; org-noter-notes-search-path (list org_notes)
   )
  )
;; =org-noter= specific configuration:1 ends here
