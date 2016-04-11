#!/bin/sh

# Inspired by https://github.com/ocaml/ocaml-ci-scripts

# Installing opam
opam init --comp="4.02.2"

eval `opam config env`

opam --version
opam --git-version
ocaml -version

# Building OcLaunch and running tests
./configure --enable-tests
make
./test.native
