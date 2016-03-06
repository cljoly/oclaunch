#!/bin/bash

# Script to create 0install archives

### parameter variables ###
build_log=BUILD_INFO.txt # Logs included in distributed archive
dbg_log=dbg.log #To debug this script, dropped sometimes

echo "========= Building ========="
# Get and set compilation settings
./configure --disable-debug --disable-docs --disable-profile --disable-tests > $build_log
# First compile
make

# Copy in distribution directory (if exists)
dist=./dist
if [ ! -d $dist ]; then
  mkdir $dist
fi
# Archive name, _the bin emphasis the difference with source tarball
id=`git describe --abbrev=40 --candidates=50 HEAD`
name=oclaunch-${id}_$(arch)_bin
final_binary_path=./$name/oclaunch
final_binary_name=oclaunch
cp ./_build/src/oclaunch.native $dist/$final_binary_name
# Move BUILD_INFO
mv $build_log ./$dist/

cd $dist
if [ ! -d $name ]; then
  mkdir $name
fi
# Put executable in it
mv $final_binary_name $build_log $name

tree > $dbg_log

# Create archive, building the two in parallel, to speed up the process
echo "========= Creating base archive ========="
tar_name=${name}.tar
tar -cvaf ${tar_name} $name >> $dbg_log

echo "========= Creating first archive ========="
coproc lzma -f -9 ${tar_name} >> $dbg_log

# Create stripped archive
tar_name_stripped=${name}_stripped.tar
strip $final_binary_path
tar -cvaf ${tar_name_stripped} $name >> $dbg_log
echo "========= Creating second (stripped) archive ========="
coproc lzma -f -9 ${tar_name_stripped} >> $dbg_log

# Wait for the detached compression process  to finish
# (see lines starting with 'coproc')
wait
