#!/bin/bash

# Script to create 0install archives

# Get and set compilation settings
./configure --disable-debug --disable-docs --disable-profile --disable-tests > BUILD_INFO.txt

# First compile
make

# Copy in dist
cp ./_build/src/oclaunch.native ./dist/oclaunch
# Move BUILD_INFO
mv BUILD_INFO.txt ./dist/

cd dist
# Archive name
name=oclaunch-v$(cat ../VERSION)
mkdir $name
# Put executable in it
mv oclaunch BUILD_INFO.txt $name

# XXX Debug
tree

# Create archive
tar -cvaf $name.tar.lzma $name
