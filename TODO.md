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
 + Use a dedicated module, for user messages. Allow to print in color and to set
   verbosity level (maybe also script output, in JSON format)

### Configuration value
 + Make displaying command before launching configurable
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
 + Display text before and after, maybe in color (For example
   "================================================")

### Misc
 + Documentation ;-)
 + Handle errors in reading rc file
 + Return error code when necessary
 + Add build info in binary for 0install
 + Use color in messages

## Long term
 + Translate displayed messages.
 + Better command line interface by grouping commands.
 + Use Batteries instead of Core to improve apps size?
