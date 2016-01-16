#!/bin/sh
# A little script to create tarball, especially for Oasis2Opam

echo "Start"

# If directory doesn't exist, create it
if ! [ -e dist ]; then
    mkdir dist
fi

# If no tag, use commit SHA1
id=`git describe --abbrev=40 --candidates=50 HEAD`
name=OcLaunch_${id}.tgz

echo "Writing in" $name
git archive master --prefix=${name}/ --format=tgz -o dist/${name} -9

