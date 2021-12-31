;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Input
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(set-language-environment "Japanese")
(prefer-coding-system 'utf-8)
(set-default 'buffer-filecoding-system 'utf-8)
(use-package! fcitx
  :config
  (setq fcitx-remote-command "fcitx5-remote")
  (fcitx-aggressive-setup)
  ;; Linux なら t が推奨されるものの、fcitx5 には未対応なためここは nil
  (setq fcitx-use-dbus nil))

;; migemo
(use-package! migemo
  :config
  (setq migemo-command "cmigemo")
  (setq migemo-options '("-q" "--emacs" "-i" "\a"))
  (setq migemo-dictionary "/usr/share/migemo/utf-8/migemo-dict")
  (setq migemo-user-dictionary nil)
  (setq migemo-regex-dictionary nil)
  (setq migemo-coding-system 'utf-8-unix)
  (migemo-init))


;; Completion
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package! avy
  :bind
  ("M-g c" . avy-goto-char) ;; doom の keybind 上書き.
  ("M-g g" . avy-goto-line) ;; doom の keybind 上書き.
  ("M-g s". avy-goto-word-1))

;; うまく動かないので封印 doom との相性が悪いのかも.
;; ひとまず migemo したいときは isearch で対応.
;; (use-package! avy-migemo
;;  :after migemo
;;  :bind
;;  ("M-g m m" . avy-migemo-mode)
;;  ("M-g c" . avy-migemo-goto-char-timer) ;; doom の keybind 上書き.
;;  :config
;;  (avy-migemo-mode 1)
;;  (setq avy-timeout-seconds nil))

(use-package! ivy-bibtex
  :after org-ref
  :config
  (setq ivy-re-builders-alist
        '((ivy-bibtex . ivy--regex-ignore-order)
          (t . ivy--regex-plus)))
  (setq
   bibtex-completion-notes-path (file-truename "~/keido/notes/")
   bibtex-completion-bibliography (file-truename "~/keido/references/zotLib.bib")
   bibtex-completion-pdf-field "file"
   bibtex-completion-notes-template-multiple-files
   (concat
    "#+TITLE: ${title}\n"
    "#+ROAM_KEY: cite:${=key=}\n"
    "* TODO Notes\n"
    ":PROPERTIES:\n"
    ":Custom_ID: ${=key=}\n"
    ":NOTER_DOCUMENT: %(orb-process-file-field \"${=key=}\")\n"
    ":AUTHOR: ${author-abbrev}\n"
    ":JOURNAL: ${journaltitle}\n"
    ":DATE: ${date}\n"
    ":YEAR: ${year}\n"
    ":DOI: ${doi}\n"
    ":URL: ${url}\n"
    ":END:\n\n"
    )
   )
  )

(use-package! swiper
  :bind
  ;; ("C-s" . swiper) migemo とうまく連携しないので isearch 置き換えを保留. C-c s s で swiper 起動.
  :config
  (ivy-mode 1))

;; avy-migemo-e.g.swiper だけバクる
;; https://github.com/abo-abo/swiper/issues/2249
;;(after! avy-migemo
;;  (require 'avy-migemo-e.g.swiper))

;; org-roam の completion-at-point が動作しないのはこいつかな...
;; (add-hook! 'org-mode-hook (company-mode -1))
;; company はなにげに使いそうだからな，TAB でのみ補完発動させるか.
(setq company-idle-delay nil)
(global-set-key (kbd "TAB") #'company-indent-or-complete-common)

;; UI
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq doom-font (font-spec :family "Source Han Code JP" :size 12 ))
(setq doom-theme 'doom-molokai)
(doom-themes-org-config)
;; どうもフォントが奇数だと org-table の表示が崩れる.
;; Source Han Code JP だとそもそも org-table の表示が崩れる.
;; terminal だと大丈夫な模様.そもそも Terminal はこの設定ではなくて Terminal Emulator の設定がきく.

(setq display-line-numbers-type t) ; 行番号表示

;; less でのファイル閲覧に操作性を似せる mode.
;; view-mode は emacs 内蔵. C-x C-r で read-only-mode でファイルオープン
;; doom emacs だと C-c t r で read-only-mode が起動する.
(add-hook! view-mode
  (setq view-read-only t)
  (define-key ctl-x-map "\C-q" 'view-mode) ;; assinged C-x C-q.

  ;; less っぼく.
  (define-key view-mode-map (kbd "p") 'view-scroll-line-backward)
  (define-key view-mode-map (kbd "n") 'view-scroll-line-forward)
  ;; default の e でもいいけど，mule 時代に v に bind されてたので, emacs でも v に bind しておく.
  (define-key view-mode-map (kbd "v") 'read-only-mode))

;; deft は Org-roam システムの検索で活躍する
(use-package! deft
  :after org-roam
  :bind
  ("C-c r j" . deft) ;; Doom だと C-c n d にも bind されている.
  :config
  (setq deft-default-extension "org")
  (setq deft-directory org-roam-directory)
  (setq deft-recursive t)
  (setq deft-strip-summary-regexp ":PROPERTIES:\n\\(.+\n\\)+:END:\n")
  (setq deft-use-filename-as-title nil)
  (setq deft-auto-save-interval -1.0) ;; disable auto-save
  (add-to-list 'deft-extensions "tex")
  ;; (setq deft-use-filter-string-for-filename t)
  ;; (setq deft-org-mode-title-prefix t)
  ;;
  ;; deft で org-roam の title を parse するための workaround
  ;; see: https://github.com/jrblevin/deft/issues/75
  (advice-add 'deft-parse-title :override
    (lambda (file contents)
      (if deft-use-filename-as-title
          (deft-base-filename file)
        (let* ((case-fold-search 't)
               (begin (string-match "title: " contents))
               (end-of-begin (match-end 0))
               (end (string-match "\n" contents begin)))
          (if begin
              (substring contents end-of-begin end)
            (format "%s" file)))))))

;; Editor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 英数字と日本語の間にスペースをいれる.
(use-package! pangu-spacing
  :config
  (global-pangu-spacing-mode 1)
  ;; 保存時に自動的にスペースを入れるのを抑止.あくまで入力時にしておく.
  (setq pangu-spacing-real-insert-separtor nil))

;; 記号の前後にスペースを入れる.
(use-package! electric-operator)

;; Emacs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Term
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; Checker
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Tools
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; OS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Org mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; https://github.com/hlissner/doom-emacs/blob/develop/modules/lang/org/README.org
;; https://github.com/tsu-nera/dotfiles/blob/master/.emacs.d/inits/50_org-mode.org

;; スマホとの共有のため, github を clone したものを Dropbox に置いて$HOME に symlink している.
(after! org
  (setq org-directory "~/keido")
  (setq org-default-notes-file "gtd/gtd_projects.org")

  (setq org-return-follows-link t) ;; Enter でリンク先へジャンプ
  (setq org-use-speed-commands t)  ;; bullet にカーソルがあると高速移動
  (setq org-hide-emphasis-markers t) ;; * を消して表示.

  ;; M-RET の挙動の調整
  ;; t だと subtree の最終行に heading を挿入, nil だと current point に挿入
  ;; なお，C-RET だと subtree の最終行に挿入され, C-S-RET だと手前に挿入される.
  (setq org-insert-heading-respect-content nil)

  (setq org-startup-indented t)
  (setq org-indent-mode-turns-on-hiding-stars nil)

  (setq org-startup-folded 'show2levels);; 見出しの階層指定
  (setq org-startup-truncated nil) ;; 長い文は折り返す.

  ;; org-babel のソースをキレイに表示.
  (setq org-src-fontify-natively t)
  (setq org-fontify-whole-heading-line t)

  ;; electric-indent は org-mode で誤作動の可能性があることのこと
  ;; たまにいきなり org-mode の tree 構造が壊れるから，とりあえず設定しておく.
  ;; この設定の効果が以下の記事で gif である.
  ;; https://www.philnewton.net/blog/electric-indent-with-org-mode/
  (add-hook! org-mode (electric-indent-local-mode -1))

  ;; org-agenda
  (setq org-refile-targets '((org-agenda-files :maxlevel . 3)))
  (setq org-agenda-time-leading-zero t) ;; 時間表示が 1 桁の時, 0 をつける
  (setq calendar-holidays nil) ;; 祝日を利用しない.
  (setq org-log-done 'time);; 変更時の終了時刻記録.

  ;; スケジュールやデッドラインアイテムは DONE になっていれば表示する
  (setq org-agenda-skip-deadline-if-done nil)
  (setq org-agenda-skip-scheduled-if-done nil)

  (setq org-agenda-include-inactive-timestamps t) ;; default で logbook を表示
  (setq org-agenda-start-with-log-mode t) ;; ;; default で 時間を表示

  ;; org-agenda speedup tips
  ;; https://orgmode.org/worg/agenda-optimization.html

  ;; 何でもかんでも agenda すると思いので厳選.
  (setq org-agenda-files '("~/keido/notes/gtd/gtd_projects.org"
                           "~/keido/notes/journals/daily"))

  ;; 期間を限定
  (setq org-agenda-span 30)
                                        ; Inhibit the dimming of blocked tasks:
  (setq org-agenda-dim-blocked-tasks nil)
  ;; Inhibit agenda files startup options:
  (setq org-agenda-inhibit-startup nil)
  ;; Disable tag inheritance in agenda:
  (setq org-agenda-use-tag-inheritance nil)

  ;; org-capture
  ;; https://orgmode.org/manual/Capture-templates.html
  (defun my/create-timestamped-org-file (path)
    (expand-file-name (format "%s.org" (format-time-string "%Y%m%d%H%M%S")) path))
  (defun my/create-date-org-file (path)
    (expand-file-name (format "%s.org" (format-time-string "%Y-%m-%d")) path))

  (setq org-capture-templates
        '(("i" "📥Inbox" entry (file "~/keido/inbox/inbox.org") "* %T %?\n")
          ("j" "🤔Journal" plain
           (file+headline (lambda () (my/create-date-org-file "~/keido/notes/journals/daily"))
                          "Journal")
           "%?"
           :empty-lines 1
           :kill-buffer t)
                                        ;         "* %?\nEntered on %U\n %i\n %a")
          ;;        ("d" "Daily Log" entry (function org-journal-find-location)
          ;;                               "* %(format-time-string org-journal-time-format)%i%?")
          ;; ("z" "💡Zettelkasten" entry (file (lambda () (my/create-timestamped-org-file "~/keido/notes/zk"))) "* TITLE%?\n")
          ;; ("z" "💡Zettelkasten" entry (file "~/keido/notes/zk/20210101.org") "* TITLE%?\n")
          ("z" "💡Zettelkasten" plain
           (file+headline (lambda () (my/create-timestamped-org-file "~/keido/notes/zk"))
                          "") "#+TITLE:💡%?\n")
          ("w" "📝Wiki" plain
           (file+headline (lambda () (my/create-timestamped-org-file "~/keido/notes/wiki")) "")
           "#+EXPORT_FILE_NAME: ~/repo/futurismo4/wiki/xxx.rst
#+OPTIONS: toc:t num:nil todo:nil pri:nil ^:nil author:nil *:t prop:nil
#+TITLE:📝%?\n")
          ("P" "Protocol" entry ; key, name, type
           (file+headline +org-capture-notes-file "Inbox") ; target
           "* %^{Title}\nSource: %u, %c\n #+BEGIN_QUOTE\n%i\n#+END_QUOTE\n\n\n%?"
           :prepend t ; properties
           :kill-buffer t)
          ("L" "Protocol Link" entry
           (file+headline +org-capture-notes-file "Inbox")
           "* %? [[%:link][%(transform-square-brackets-to-round-ones \"%:description\")]]\n"
           :prepend t
           :kill-buffer t)
          ))

  ;; org-babel
  ;; 評価でいちいち質問されないように.
  (setq org-confirm-babel-evaluate nil)
  ;; org-babel で 実行した言語を書く. デフォルトでは emacs-lisp だけ.
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((lisp . t)
     (shell . t)))
  )

;; org-mode で timestamp のみを挿入するカスタム関数(hh:mm)
(after! org
  (defun my/insert-timestamp ()
    "Insert time stamp."
    (interactive)
    (insert (format-time-string "%H:%M")))
 (map! :map org-mode-map "C-c C-." #'my/insert-timestamp))

;; +pretty(org-superstar-mode)関連
;;; Titles and Sections
;; hide #+TITLE:
;; (setq org-hidden-keywords '(title))
;; set basic title font
;; (set-face-attribute 'org-level-8 nil :weight 'bold :inherit 'default)
;; Low levels are unimportant => no scaling
;; (set-face-attribute 'org-level-7 nil :inherit 'org-level-8)
;; (set-face-attribute 'org-level-6 nil :inherit 'org-level-8)
;; (set-face-attribute 'org-level-5 nil :inherit 'org-level-8)
;; (set-face-attribute 'org-level-4 nil :inherit 'org-level-8)
;; Top ones get scaled the same as in LaTeX (\large, \Large, \LARGE)
;; (set-face-attribute 'org-level-3 nil :inherit 'org-level-8 :height 1.2) ;\large
;; (set-face-attribute 'org-level-2 nil :inherit 'org-level-8 :height 1.44) ;\Large
;; (set-face-attribute 'org-level-1 nil :inherit 'org-level-8 :height 1.728) ;\LARGE
;; Only use the first 4 styles and do not cycle.
(setq org-cycle-level-faces nil)
(setq org-n-level-faces 4)
;; Document Title, (\huge)
;; (set-face-attribute 'org-document-title nil
;;                    :height 2.074
;;                    :foreground 'unspecified
;;                    :inherit 'org-level-8)

;; (with-eval-after-load 'org-superstar
;;  (set-face-attribute 'org-superstar-item nil :height 1.2)
;;  (set-face-attribute 'org-superstar-header-bullet nil :height 1.2)
;;  (set-face-attribute 'org-superstar-leading nil :height 1.3))
;; Set different bullets, with one getting a terminal fallback.
(setq org-superstar-headline-bullets-list
      '("◉" ("🞛" ?◈) "○" "▷"))
;; (setq org-superstar-special-todo-items t)

;; Stop cycling bullets to emphasize hierarchy of headlines.
(setq org-superstar-cycle-headline-bullets nil)
;; Hide away leading stars on terminal.
;; (setq org-superstar-leading-fallback ?\s)
(setq inhibit-compacting-font-caches t)

;; org-roam
(setq org-roam-directory (file-truename "~/keido/notes"))
(setq org-roam-db-location (file-truename "~/keido/db/org-roam.db"))

(use-package! org-roam
  :after org
  :init
  (setq org-roam-v2-ack t)
  (map!
        :leader
        :prefix ("r" . "org-roam")
        "f" #'org-roam-node-find
        "i" #'org-roam-node-insert
        "l" #'org-roam-buffer-toggle
        "t" #'org-roam-tag-add
        "T" #'org-roam-tag-remove
        "a" #'org-roam-alias-add
        "A" #'org-roam-alias-remove
        "r" #'org-roam-ref-add
        "R" #'org-roam-ref-remove
        "o" #'org-id-get-create
        "s" #'org-roam-db-sync
        "u" #'org-roam-update-org-id-locations
        )
  :custom
  ;; ファイル名を ID にする.
  (org-roam-capture-templates
   '(("d" "default" plain "%?"
      :target (file+head "%<%Y%m%d%H%M%S>.org"
                         "#+title: ${title}\n")
      :unnarrowed t)
     ("z" "zettelkasten" plain "%?"
      :target (file+head "zk/%<%Y%m%d%H%M%S>.org"
                         "#+title: ${title}\n")
      :unnarrowed t)
     ("w" "wiki" plain "%?"
      :target (file+head "wiki/%<%Y%m%d%H%M%S>.org"
                         "#+title: ${title}\n")
      :unnarrowed t)))
  (org-roam-extract-new-file-path "%<%Y%m%d%H%M%S>.org")
  (org-roam-dailies-directory "journals/daily/")
  ;;        :map org-mode-map
  ;;        ("C-M-i"    . completion-at-point)
  ;;        :map org-roam-dailies-map
  ;;        ("Y" . org-roam-dailies-capture-yesterday)
  ;;        ("T" . org-roam-dailies-capture-tomorrow))
  :bind-keymap
  ("C-c r d" . org-roam-dailies-map)
  :config
  (setq org-roam-dailies-capture-templates
        '(("d" "default" item "%?"
           :if-new (file+head+olp "%<%Y-%m-%d>.org" "#+Title: %<%Y-%m-%d>" ("Journal"))
           :unnarrowed t)))

  (setq +org-roam-open-buffer-on-find-file nil)
  (require 'org-roam-dailies) ; Ensure the keymap is available
  (org-roam-db-autosync-mode))


(use-package! websocket
    :after org-roam)
(use-package! org-roam-ui
    :after org-roam ;; or :after org
;;         normally we'd recommend hooking orui after org-roam, but since org-roam does not have
;;         a hookable mode anymore, you're advised to pick something yourself
;;         if you don't care about startup time, use
    ;; :hook (after-init . org-roam-ui-mode)
    :config
    (setq org-roam-ui-sync-theme t
          org-roam-ui-follow t
          org-roam-ui-update-on-save t
          org-roam-ui-open-on-start t))

(use-package! org-roam-timestamps
   :after org-roam
   :config
   (org-roam-timestamps-mode)
   (setq org-roam-timestamps-remember-timestamps nil)
   (setq org-roam-timestamps-remember-timestamps nil))


;; 今どきのアウトライナー的な線を出す.
;; Terminal Mode ではつかえないので一旦無効化する.
;; (require 'org-bars)
;; (add-hook! 'org-mode-hook #'org-bars-mode)

(use-package! ox-hugo
  :after 'ox)

(use-package! ox-rst
  :after 'org)

(after! org
  (defun my/rst-to-sphinx-link-format (text backend info)
    (when (and (org-export-derived-backend-p backend 'rst) (not (search "<http" text)))
      (replace-regexp-in-string "\\(\\.org>`_\\)" ">`" (concat ":doc:" text) nil nil 1)))
  (add-to-list 'org-export-filter-link-functions
               'my/rst-to-sphinx-link-format))

;; 空白が保存時に削除されると bullet 表示がおかしくなる.
;; なお wl-bulter は doom emacs のデフォルトで組み込まれている.
(add-hook! 'org-mode-hook (ws-butler-mode -1))

(use-package! org-ref
    :config
    (setq
         org-ref-completion-library 'org-ref-ivy-cite
         org-ref-get-pdf-filename-function 'org-ref-get-pdf-filename-ivy-bibtex
         org-ref-default-bibliography (list (file-truename "~/keido/references/zotLib.bib"))
         org-ref-bibliography-notes (file-truename "~/keido/notes/bibnotes.org")
         org-ref-note-title-format "* TODO %y - %t\n :PROPERTIES:\n  :Custom_ID: %k\n  :NOTER_DOCUMENT: %F\n :ROAM_KEY: cite:%k\n  :AUTHOR: %9a\n  :JOURNAL: %j\n  :YEAR: %y\n  :VOLUME: %v\n  :PAGES: %p\n  :DOI: %D\n  :URL: %U\n :END:\n\n"
         org-ref-notes-directory (file-truename "~/keido/notes/")
         org-ref-notes-function 'orb-edit-notes
    ))

;; 読書のためのマーカー（仮）
;; あとでちゃんと検討と朝鮮しよう.
;; (setq org-emphasis-alist
;;   '(("*" bold)
;;     ("/" italic)
;;     ("_" underline))
;;     ("=" (:background "red" :foreground "white")) ;; 書き手の主張
;;     ("~" (:background "blue" :foreground "white")) cddddd;; 根拠
;;     ("+" (:background "green" :foreground "black")))) ;; 自分の考え

;; org-clock 関連 使わないのでいったんマスクだが使いこなしたいので消さない.
;; (require 'org-toggl)
;; (setq toggl-auth-token "4b707d3e5bc71cc5f0010ac7ea76185d")
;;(setq org-toggl-inherit-toggl-properties nil)
;; (org-toggl-integration-mode)

(use-package! org-roam-protocol
  :after org-protocol)

(use-package! org-roam-bibtex
  :after org-roam
  :hook (org-roam-mode . org-roam-bibtex-mode)
  :config
  (setq org-roam-bibtex-preformat-keywords
   '("=key=" "title" "url" "file" "author-or-editor" "keywords"))
  (setq orb-templates
        '(("r" "ref" plain (function org-roam-capture--get-point)
           ""
           :file-name "${slug}"
           :head "#+TITLE: ${=key=}: ${title}\n#+ROAM_KEY: ${ref}

- tags ::
- keywords :: ${keywords}

\n* ${title}\n  :PROPERTIES:\n  :Custom_ID: ${=key=}\n  :URL: ${url}\n  :AUTHOR: ${author-or-editor}\n  :NOTER_DOCUMENT: %(orb-process-file-field \"${=key=}\")\n  :NOTER_PAGE: \n  :END:\n\n"

           :unnarrowed t))))

(use-package! org-noter
  :after (:any org pdf-view)
  :config
  (setq
   ;; The WM can handle splits
   org-noter-notes-window-location 'other-frame
   ;; Please stop opening frames
   org-noter-always-create-frame nil
   ;; I want to see the whole file
   org-noter-hide-other nil
   ;; Everything is relative to the main notes file
   org-noter-notes-search-path (list (file-truename "~/keido/notes/"))
   ))

;; Email
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; App
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; twittering-mode
;; この設定がないと認証が失敗した.
;; twittering-oauth-get-access-token: Failed to retrieve a request token
(add-hook! 'twittering-mode-hook
  (setq twittering-allow-insecure-server-cert t))


;; elfeed
(global-set-key (kbd "C-x w") 'elfeed)

(use-package! elfeed
  :config
  (setq elfeed-feeds
        '("https://futurismo.biz")))

;; Config
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; memo:
;; use-package! は:defer, :hook, :commands, or :after が省略されると起動時に load される.
;; after! は package が load されたときに評価される.
;; add-hook! は mode 有効化のとき. setq-hook!は equivalent.
;; どれを使うかの正解はないがすべて use-package!だと起動が遅くなるので
;; 場合によってカスタマイズせよ，とのこと.
;; https://github.com/hlissner/doom-emacs/blob/develop/docs/getting_started.org#configuring-packages
;;
;; doom specific config
;; (setq user-full-name "John Doe"
;;      user-mail-address "john@doe.com")
(setq confirm-kill-emacs nil) ; 終了時の確認はしない.

;; フルスクリーンで Emacs 起動
;; ブラウザと並べて表示することが多くなったのでいったんマスク
;; (add-to-list 'initial-frame-alist '(fullscreen . maximized))
