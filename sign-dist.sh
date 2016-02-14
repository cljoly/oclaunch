#!/bin/sh

# Script used to sign (almost) everything in the dist folder

if [ ! -d dist ]; then
  mkdir dist
fi
cd dist
# File to signed
# MEMO: -e: regexp, -v: not matched
tobe_sig=$(ls | grep -e ".tar" -e ".zip" | grep  -v ".sha256" | grep  -v ".md5" | grep  -v ".sig")

for element in ${tobe_sig}
do
  echo "Calculating checksum" ${element}
  md5sum ${element} > ${element}.md5
  sha256sum ${element} > ${element}.sha256

  echo "Signing" ${element}
  gpg --detach-sign ${element}
done

