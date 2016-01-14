#!/bin/bash

# Script to create 0install archives

# Get and set compilation settings
./configure --disable-debug --disable-docs --disable-profile --disable-tests > BUILD_INFO.txt

# First compile
make

# Copy in distribution directory (if exists)
dist=./dist
if [ ! -d $dist ]; then
  mkdir $dist
fi
# Archive name
name=oclaunch-v$(cat ./VERSION)_$(arch)
final_binairy_name=$dist/$name/oclaunch
cp ./_build/src/oclaunch.native $dist/oclaunch
# Move BUILD_INFO
mv BUILD_INFO.txt ./$dist/

cd $dist
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
