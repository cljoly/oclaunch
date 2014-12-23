#!/bin/bash

# Script to create 0install archives

# First compile
make

# Copy in dist
cp ./_build/src/oclaunch.native ./dist/oclaunch

cd dist
# Archive name
name=oclaunch-v$(cat ../VERSION)
mkdir $name
# Put executable in it
mv oclaunch $name

# XXX Debug
tree

# Create archive
tar -cvjf $name.tar.bz2 $name
