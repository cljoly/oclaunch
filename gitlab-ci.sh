#!/bin/sh

# Give OCaml version as first argument

# Inspired by https://github.com/ocaml/ocaml-ci-scripts

# Use -y with evry opam command
export OPAMYES=true
# Installing opam
opam init --comp="$1"
eval `opam config env`

# Versions
opam --version
opam --git-version
ocaml -version

# ocamlfind is mandatory to build
opam install ocamlfind

# Installing dependancies and testing installation
opam pin add oclaunch-ci .
# Building OcLaunch and running tests
./configure --enable-tests
make test
