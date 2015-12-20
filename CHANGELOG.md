# Changelog of OcLaunch

>Note: XXX Means that the functionality needs test and TODO means that its
>implementation is partial

## 0.3.x

### 0.3.0

 + Fix bug: in special circumstances, it was not possible to write in lock file.
   The program was crashing.
 + Rewrite command line parsing, in a cleaner and safer way. It now handles
   `exit`, would be able to deal with auto completion and display more accurate
   help messages. Though, for backward compatibility reasons, a hack has been
   setted up, allowing to call the program with a number as first argument or
   without any argument. This way, the program tries to launch the corresponding
   command or the next one. The problem is that you can't call it with an
   option. To do this, use the `run` subcommand.
 + Improve list subcommand, now using Textutils library, displaying in an array
 + Improve editing command (explain how to use to add commands, improve
   messages, offer to reedit when nothing was done).
 + Code clean up
 + Add unit tests and clean them up
 + Add licence warning
 + TODO XXX Add basic signal handling (`--signals`), to relaunch when doing
   ctrl-C. See issue #14 for known problems
 + Changed tmp file format, the new one would allow to do more things:
   + Restart edited command (reset number of launch)
   + Support multiple configuration file
   + For the futur : Running infinite, daemon mode...

## 0.2.x

### v0.2.2
 + Major functionality:
    + Allow to install from opam throw opam pin add <pkg> <repo>
    + Allow to set tmp file with environment variable “OC\_TMP”. See #9 and #6
    + Messages displayed with bold, underline and colors.
    + Add options:
       + “-v” to set verbosity.
       + “--no-color” to toggle color off
       + “--edit” is synonym of “--modify” now
 + Minor functionality:
    + Improve resetting: tips, way to roll back
    + Add unit tests, to improve stability
    + Clean help
    + Better display after editing an entry. Ignore empty lines and fix #10
    + Use lazyness to speed up and lead to less error
    + Locking tmp file to prevent launching two times the same item
 + Correct bugs:
   + When executing ```oclaunc -r``` more than once, it tries to delete an
     unexisting file and this led to errors.
   + When some variable like $EDITOR was not set, it was crashing everytime.
     Now, it crashes only if there is no other solution.

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
