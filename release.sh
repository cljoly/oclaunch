#!/bin/bash

# Script to realise easily new version

# Run test, long form
./configure --enable-tests
make test
./test.native

if [ $? -ne 0 ]; then
  echo "Test failed!"
  exit 2
else
  echo "All test passed!"
fi

# Set version
./version_set.sh $1

# Record changes
git commit -a -m "Version $(cat ./VERSION)"
git tag -s v$(cat VERSION) -m "Release version $(cat VERSION)"

# Cleanup dist directory to put the new archives, if exists
if [ -d dist ]; then
  rm -r dist/*
fi
# Binary archives
./0install.sh
# Source code
./pkg.sh

# Signing everything
./sign-dist.sh
