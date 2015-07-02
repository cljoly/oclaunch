#!/bin/bash

# Some script to test the behavior of the programe with custom rc file

OC_TMP=/tmp/v033 ./oclaunch.native -v 5 --rc ./dev.json $*
