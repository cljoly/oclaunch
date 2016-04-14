#!/bin/sh

# Give OCaml version as first argument

# Inspired by https://github.com/ocaml/ocaml-ci-scripts

# Use -y with evry opam command
export OPAMYES=true
# Installing opam
opam init --comp="$1"
eval `opam config env`

# Versions
echo "= Versions ="
echo "opam --version"
opam --version
echo "opam --git-version"
opam --git-version
echo "ocaml -version"
ocaml -version
echo "============"

# ocamlfind is mandatory to build
opam install ocamlfind
# XXX Manually install development dependancies, not yet supported (ait opam 1.3)
opam install alcotest oUnit

# Installing dependancies and testing installation
opam pin add oclaunch-ci .
# Building OcLaunch and running tests
./configure --enable-tests
make test
