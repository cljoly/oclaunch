#!/bin/sh

# A script to set version number to $1
# Example: ./version_set.sh 0.1

# Current version number
current_version=$(cat ./VERSION)

# New, wanted one
new_version=$1


# Print what will be done
echo "Put" $new_version "instead of" $new_version

# Replace in the 4 files : VERSION, _oasis, src/oclaunch.ml, opam
echo $new_version > VERSION
sed -i -e "s/Version:     .*/Version:     $new_version/" _oasis
sed -i -e "s/\\(let version_number = \"\\).*\\(\";;\\)/\\1$new_version\\2/" src/oclaunch.ml
sed -i -e "s/^version: \".*\"$/version: \"$new_version\"/" opam

# Update oasis
oasis setup

# Display the result
echo "Result"
git diff
