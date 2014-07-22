all: atdgen code

atdgen:
	atdgen -t settings.atd
	atdgen -j settings.atd

mli:
	corebuild -pkg yojson,atdgen file_com.inferred.mli

code: mli
	corebuild -pkg yojson,atdgen oclaunch.byte
