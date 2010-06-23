python-den.el
=============

python-den is a best-of-breed Emacs collection of Python modes and helpers. I
wrote it because I wanted:

* Pervasive virtualenv support
* IPython support (with tab-completion) for every interactive shell
* Debugging without sprinkling *pdb.set_trace() throughout my code
* Autocomplete with Ropemacs, like the Real IDEs have

Todo
----

* Clean up all the sloppiness. I don't really know what the hell I'm doing.
* Stop breaking other comints.
* Maybe use auto-complete.el instead of ido for rope completions.
* Write up how to combine rope and virtualenv in .ropeproject/config.py.

Requirements
------------

* Ipdb (http://github.com/akrito/ipdb)
* Ropemacs (http://rope.sourceforge.net/ropemacs.html)
* Ido (http://www.cua.dk/ido.el)
