<!--- OASIS_START --->
<!--- DO NOT EDIT (digest: e39b2a56b1c8d15b002c554e90d54359) --->

This is the INSTALL file for the OcLaunch distribution.

This package uses OASIS to generate its build system. See section OASIS for
full information.

Dependencies
============

In order to compile this package, you will need:

* ocaml for all, test tests
* findlib
* core
* textutils
* atdgen
* re2 for executable oclaunch
* alcotest for executable run_test
* oUnit for executable run_test

Installing
==========

1. Uncompress the source archive and go to the root of the package
2. Run 'ocaml setup.ml -configure'
3. Run 'ocaml setup.ml -build'
4. Run 'ocaml setup.ml -install'

Uninstalling
============

1. Go to the root of the package
2. Run 'ocaml setup.ml -uninstall'

OASIS
=====

OASIS is a program that generates a setup.ml file using a simple '_oasis'
configuration file. The generated setup only depends on the standard OCaml
installation: no additional library is required.

<!--- OASIS_STOP --->
