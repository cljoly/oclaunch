#!/bin/sh

# Script used to sign (almost) everything in the dist folder

if [ ! -d dist ]; then
  mkdir dist
fi
cd dist
# File to signed
# MEMO: -e: regexp, -v: not matched
tobe_sig=$(ls | grep -e ".tar" -e ".zip" -v ".sig")

for element in ${tobe_sig}
do
  echo "Signing" ${element}
  gpg --detach-sign ${element}
done

