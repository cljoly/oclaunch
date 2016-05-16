#!/bin/bash
# A little script to create tarball, especially for Oasis2Opam
# You may pass source commit as first argument, HEAD is used if omitted.

echo "Start"

# If directory doesn't exist, create it
if ! [ -e dist ]; then
    mkdir dist
fi

# Target commit (TC) i.e. commit from which tarball is created.
if [[ $1 = "" ]]; then
  echo "No argument, using HEAD to create tarball."
  TC=HEAD
else
  TC=$1
fi
TCID=`git rev-parse ${TC}`
echo "Creating tarball from commit ${TCID} ($TC)."

# If no tag, use commit SHA1
id=`git describe --abbrev=10 --candidates=50 ${TCID}`
name=oclaunch_${id}_source # _source emphasis the difference with binary tarballs

echo "Writing in" $name".*"
git archive ${TCID} --prefix=${name}/ --format=zip -o dist/${name}.zip -9
# Creating .xz .gz and .bz2 from tar archive
tar_name=${name}.tar
git archive ${TCID} --prefix=${name}/ --format=tar \
  | tee dist/${tar_name} \
  | gzip -c9 > dist/${tar_name}.gz
cd dist
bzip2 -c9 < ${tar_name} >  ${tar_name}.bz2
xz -c9 < ${tar_name} >  ${tar_name}.xz

# Verification
gzip -t < ${tar_name}.gz
bzip2 -t <  ${tar_name}.bz2
xz -t <  ${tar_name}.xz
