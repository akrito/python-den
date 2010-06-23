;; The Python's den
;; A best-of-breed Python setup

;; Require Ropemacs now, so all python procs inherit the rope project
(if (locate-library "pymacs")
    (progn
      (require 'pymacs)
      (setq ropemacs-enable-autoimport t)
      (pymacs-load "ropemacs" "rope-")
      (ac-ropemacs-setup)))

;; Virtualenv
(require 'virtualenv)
(defun workon-postactivate (virtualenv)
  (virtualenv-activate-environment virtualenv)
  (if (functionp 'rope-open-project) (rope-open-project (concat virtualenv "/rope"))))

;; Tab completion from ipython.el (http://ipython.scipy.org/dist/ipython.el)
;; __IPYTHON__ will return the interpreter in both ipython and ipdb. __IP only
;; works for ipython
(setq ipython-completion-command-string "print(';'.join(__IPYTHON__.Completer.all_completions('%s')))\n")
(defun ipython-complete ()
    "Try to complete the python symbol before point. Only knows about the stuff
in the current *Python* session."
    (interactive)
    (let* ((ugly-return nil)
           (sep ";")
           (python-process (or (get-buffer-process (current-buffer))
                                        ;XXX hack for .py buffers
                               (get-process py-which-bufname)))
           ;; XXX currently we go backwards to find the beginning of an
           ;; expression part; a more powerful approach in the future might be
           ;; to let ipython have the complete line, so that context can be used
           ;; to do things like filename completion etc.
           (beg (save-excursion (skip-chars-backward "a-z0-9A-Z_./" (point-at-bol))
                                (point)))
           (end (point))
           (pattern (buffer-substring-no-properties beg end))
           (completions nil)
           (completion-table nil)
           completion
         (comint-preoutput-filter-functions
          (append comint-preoutput-filter-functions
                  '(ansi-color-filter-apply
                    (lambda (string)
                      (setq ugly-return (concat ugly-return string))
                      "")))))
      (process-send-string python-process
                            (format ipython-completion-command-string pattern))
      (accept-process-output python-process)
      (setq completions
            (split-string (substring ugly-return 0 (position ?\n ugly-return)) sep))
      (setq completion-table (loop for str in completions
                                   collect (list str nil)))
      (setq completion (try-completion pattern completion-table))
      (cond ((eq completion t))
            ((null completion)
             (message "Can't find completion for \"%s\"" pattern)
             (ding))
            ((not (string= pattern completion))
             (delete-region beg end)
             (insert completion))
            (t
             (setq completion
                   (ido-completing-read pattern 
                                        (all-completions pattern completion-table)))
             (delete-region beg end)
             (insert completion)))))
;; FIXME This is too aggressive, and overrides <tab> in all comints
(add-hook 'comint-mode-hook 
          '(lambda () 
             (local-set-key (kbd "<tab>") 'ipython-complete)))

;; Pdb
(defun better-pdb ()
  (gud-def gud-break  "break %d/%f:%l"  "\C-b" "Set breakpoint at current line.")
  (gud-def gud-remove "clear %d/%f:%l"  "\C-d" "Remove breakpoint at current line")
  (compilation-shell-minor-mode t)
  (local-set-key (kbd "<tab>") 'ipython-complete)
  (setq overlay-arrow-string "")
  )
(add-hook 'pdb-mode-hook 'better-pdb)

;; Pyflakes
(setq python-check-command "pyflakes")

;; A different run-python, because emacs2.py doesn't work with IPython
(defun run-python (&optional cmd noshow new)
  "Run an inferior Python process, input and output via buffer *Python*.
CMD is the Python command to run.  NOSHOW non-nil means don't show the
buffer automatically.

Normally, if there is a process already running in `python-buffer',
switch to that buffer.  Interactively, a prefix arg allows you to edit
the initial command line (default is `python-command'); `-i' etc. args
will be added to this as appropriate.  A new process is started if:
one isn't running attached to `python-buffer', or interactively the
default `python-command', or argument NEW is non-nil.  See also the
documentation for `python-buffer'.

Runs the hook `inferior-python-mode-hook' \(after the
`comint-mode-hook' is run).  \(Type \\[describe-mode] in the process
buffer for a list of commands.)"
  (interactive (if current-prefix-arg
		   (list (read-string "Run Python: " python-python-command) nil t)
		 (list python-python-command)))
  (unless cmd (setq cmd python-python-command))
  (python-check-version cmd)
  (setq python-python-command cmd)
  ;; Fixme: Consider making `python-buffer' buffer-local as a buffer
  ;; (not a name) in Python buffers from which `run-python' &c is
  ;; invoked.  Would support multiple processes better.
  (when (or new (not (comint-check-proc python-buffer)))
    (with-current-buffer
	(let* ((cmdlist
		(append (python-args-to-list cmd)
			'("-cl" "-i" "-c" "import sys; sys.path.remove('')")))
	       (path (getenv "PYTHONPATH"))
	       (process-environment	; to import emacs.py
		(cons (concat "PYTHONPATH="
			      (if path (concat path ":"))
			      python-den-py-dir)
		      process-environment))
               ;; IPython doesn't work with connection-type nil
	       (process-connection-type t))
	  (apply 'make-comint-in-buffer "Python"
		 (generate-new-buffer "*Python*")
		 (car cmdlist) nil (cdr cmdlist)))
      (setq-default python-buffer (current-buffer))
      (setq python-buffer (current-buffer))
      (accept-process-output (get-buffer-process python-buffer) 5)
      (inferior-python-mode)
      ;; Load function definitions we need.
      ;; Before the preoutput function was used, this was done via -c in
      ;; cmdlist, but that loses the banner and doesn't run the startup
      ;; file.  The code might be inline here, but there's enough that it
      ;; seems worth putting in a separate file, and it's probably cleaner
      ;; to put it in a module.
      ;; Ensure we're at a prompt before doing anything else.
      (python-send-string "import emacs2 as emacs")
      ;; The following line was meant to ensure that we're at a prompt
      ;; before doing anything else.  However, this can cause Emacs to
      ;; hang waiting for a response, if that Python function fails
      ;; (i.e. raises an exception).
      ;; (python-send-receive "print '_emacs_out ()'")
      ))
  (if (derived-mode-p 'python-mode)
      (setq python-buffer (default-value 'python-buffer))) ; buffer-local
  ;; Without this, help output goes into the inferior python buffer if
  ;; the process isn't already running.
  (sit-for 1 t)        ;Should we use accept-process-output instead?  --Stef
  (unless noshow (pop-to-buffer python-buffer t)))

(provide 'python-den)
