#!/bin/sh
# A little script to create tarball, especially for Oasis2Opam

echo "Start"

# If directory doesn't exist, create it
if ! [[ -e dist ]]; then
    mkdir dist
fi

# If no tag, use commit SHA1
tag=`git tag --points-at HEAD`
id=`git rev-parse --short --verify HEAD`
name=OcLaunch_${tag}-${id}.tgz

echo "Write in" $name
git archive master --prefix=${name}/ --format=tgz -o dist/$name

