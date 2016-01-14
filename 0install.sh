#!/bin/bash

# Script to create 0install archives

# Get and set compilation settings
./configure --disable-debug --disable-docs --disable-profile --disable-tests > BUILD_INFO.txt

# First compile
make

# Copy in dist
final_binairy_name=./dist/oclaunch
cp ./_build/src/oclaunch.native $final_binairy_name
# Move BUILD_INFO
mv BUILD_INFO.txt ./dist/

cd dist
# Archive name
name=oclaunch-v$(cat ../VERSION)_$(arch)
mkdir $name
# Put executable in it
mv oclaunch BUILD_INFO.txt $name

# XXX Debug
tree

# Create archive
tar -cvaf $name.tar.lzma $name

# Create stripped archive
strip $final_binairy_name
tar -cvaf $name_stripped.tar.lzma $name
