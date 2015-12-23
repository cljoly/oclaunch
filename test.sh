#!/bin/bash

# Some script to test the behavior of the program with custom rc file
# FIXME Better behavior when launched without arguments
OC_TMP=/tmp/v033 ./oclaunch.native $* -v 5 -c ./dev.json
