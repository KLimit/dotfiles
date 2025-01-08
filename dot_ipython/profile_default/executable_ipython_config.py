from sys import version_info
PYTHON2 = version_info.major == 2

try:
    from IPython.core import ultratb
    ultratb.VerboseTB._tb_highlight = 'bg:ansiblack'
except:
    pass

c = get_config()

c.InteractiveShellApp.gui = 'qt'
c.InteractiveShellApp.hide_initial_ns = False
c.TerminalIPythonApp.display_banner = False
c.InteractiveShell.debug = False

if not PYTHON2:
    c.TerminalInteractiveShell.auto_match = True

c.TerminalInteractiveShell.debug = False
c.TerminalInteractiveShell.editing_mode = 'emacs'
