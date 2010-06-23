python-den.el
=============

python-den is a best-of-breed Emacs collection of Python modes and helpers. I
wrote it because I wanted:

* Pervasive virtualenv support
* IPython support (with tab-completion) for every interactive shell
* Debugging without sprinkling *pdb.set_trace() throughout my code
* Autocomplete with Ropemacs, like the Real IDEs have

Requirements
------------

* Ipdb (http://github.com/akrito/ipdb)
* Ropemacs (http://rope.sourceforge.net/ropemacs.html)
* Ido (http://www.cua.dk/ido.el)

Usage
-----

In .emacs.d/init.el:

    (setq python-den-root-dir "/home/alex/.emacs.d/python-den")
    (setq virtualenv-root-dir "~/v/") ;; remember the trailing slash
    (add-to-list 'load-path python-den-root-dir)
    (require 'python-den)
    ;; Use the default virtualenv
    (workon-postactivate "/home/alex/v/ellington")

Todo
----

* Clean up all the sloppiness. I don't really know what the hell I'm doing.
* Stop breaking other comints.
* Maybe use auto-complete.el instead of ido for rope completions.
* Write up how to combine rope and virtualenv in .ropeproject/config.py.

