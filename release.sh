#!/bin/bash

# Script to realise easily new version

# Set version
./version_set.sh $1

# Record changes
git commit -a -m "Version $(cat ./VERSION)"
git tag -s v$(cat VERSION) -m "Release $(cat VERSION)"

# Cleanup dist directory to put the new archives
rm -r dist/*
# Binary archives
./0install.sh
# Source code
./pkg.sh
