# Changelog of OcLaunch

## 0.2.x

### v0.2.2
 + Locking tmp file to prevent launching two times the same item (**not tested
   enough**)
 + Messages displayed with bold, underline and colors.
 + Add options:
    + “-v” to set verbosity.
    + “--no-color” to toggle color off
 + Correct bugs:
   + When executing ```oclaunc -r``` more than once, it tries to delete an
     unexisting file and this led to errors.

### v0.2.1
 + Add new command line option:
   + “-c file” allow to read configuration from custom file.
   + “-m n” allow to edit and add (simultaneously) items to launch in rc file.
 + Improve “-l”: now display a “\*” next to current state.
 + Code clean up (Types in records) and code factoring.
 + When all has been launched, the program explain how to reset.
 + Better messages on initialisation.

### v0.2.0
 + Add new command line option.
   + “-r” can now take a number to start from.
   + “-l” list commands of the configuration file with its number.
   + “-a” add the command given on stdin to configuration file.
   + “-d n” remove the nth command from rc file.
   + “-n” display the current state.
 + Improve some messages.
 + Display run commands in title bar of the windows terminal.
 + New tmp file
   + Biniou format instead of JSON
   + Now cached
   + New default name : `/tmp/.oclaunch_trace.dat`
 + Add logo.
 + Clean up some code.
 + Improve utility set given with the repository (developer)

## v0.1.x

### v0.1.3
 + Correct bug (See commit 4d20125a03c6f8735f39a95bb9e68a0476c89d45).

### v0.1.2
 + First public usable version.
   + Create wiki.
   + Use Oasis
 + First version to be distributed with 0install.

## Before
 + Wast and test
