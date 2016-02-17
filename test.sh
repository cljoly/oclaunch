#!/bin/bash

# Some script to test the behavior of the program with custom rc file
OC_TMP=/tmp/v033 OC_RC="./dev.json" OC_VERB=5 ./oclaunch.native $*
