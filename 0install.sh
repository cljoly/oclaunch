#!/bin/bash

# Script to create 0install archives

### parameter variables ###
build_log=BUILD_INFO.txt # Logs included in distributed archive
dbg_log=dbg.log #To debug this script, dropped sometimes

# Get and set compilation settings
./configure --disable-debug --disable-docs --disable-profile --disable-tests > $build_log
# First compile
make

# Copy in distribution directory (if exists)
dist=./dist
if [ ! -d $dist ]; then
  mkdir $dist
fi
# Archive name
name=oclaunch-v$(cat ./VERSION)_$(arch)
final_binary_name=./$name/oclaunch
cp ./_build/src/oclaunch.native $dist/oclaunch
# Move BUILD_INFO
mv $build_log ./$dist/

cd $dist
if [ ! -d $name ]; then
  mkdir $name
fi
# Put executable in it
mv oclaunch $build_log $name

tree > $dbg_log

# Create archive
tar -cvaf $name.tar.lzma $name >> $dbg_log

# Create stripped archive
strip $final_binary_name
tar -cvaf ${name}_stripped.tar.lzma $name >> $dbg_log
