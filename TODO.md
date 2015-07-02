# Things to do

## Users idees

 + Add confirmation on delete.
 + Add undo command ?
 + Show help in context
 + Allow to delete a command after a certain number of launch

    **Feel free to add things here (and make a pull request).
    Or send an email to the author !**

## Major issue
 + Make multiple tmp file really working by using checksum for rc file.

## Short term

 + Add command --edit-rc to edit configuration file
 + Add command to exchange item

### Configuration value
 + Allow to run infinitely or say when it is finish
 + Make tmp file emplacement configurable
 + Use two modes, one for easy launch and another more
   complete
    + alway running : be sure that there entry are always running
    + easy : one entry on each call
    + confirm : ask before launching each entry
    + proportionate : launch by percent.
 + Relaunch the terminal detached after (possible -> use $TERM &; it resists to
   program exit)
 + Allow to tag entry and do things according to tags

### Misc
 + Documentation ;-)
 + Handle errors in reading rc file
 + Return error code when necessary
 + Log duration of commands, ignore some return code

## Long term
 + Translate displayed messages.
 + Better command line interface by grouping commands.
 + Use Batteries instead of Core to improve apps size?
