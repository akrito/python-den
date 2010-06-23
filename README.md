python-den.el
=============

python-den is a best-of-breed Emacs collection of Python modes and helpers. I
wrote it because I wanted:

* Pervasive virtualenv support
* IPython support (with tab-completion) for every interactive shell
* Debugging without sprinkling `pdb.set_trace()` throughout my code
* Autocomplete with Ropemacs, like the Real IDEs have

Requirements
------------

* Ipdb (http://github.com/akrito/ipdb)
* Ropemacs (http://rope.sourceforge.net/ropemacs.html)
* Virtualenvwrapper (http://www.doughellmann.com/projects/virtualenvwrapper/)

Setup
-----

Add the following to your `$virtualenv/postactivate` script:

    emacsclient -e "(workon-postactivate \"$VIRTUAL_ENV\")">/dev/null
    
`workon-postactivate` expects rope's project directory to be at `$VIRTUAL_ENV/rope/` -- edit `$VIRTUAL_ENV/rope/.ropeproject/config.py` to add the following to `project_opened`:

    from os.path import dirname, join
    activate_this = join(dirname(__file__), '../../bin/activate_this.py')
    execfile(activate_this, dict(__file__=activate_this))

Usage
-----

In `.emacs.d/init.el`:

    ;; Where is python-den checked out?
    (setq python-den-root-dir "/home/alex/.emacs.d/python-den")
    ;; Where are your virtualenvs?
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
* IPython and virtualenv support can possibly be rewritten as a derived mode.
