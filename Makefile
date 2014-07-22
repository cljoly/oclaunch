all: atdgen code

atdgen:
	atdgen -t settings.atd
	atdgen -j settings.atd

code:
	corebuild -pkg yojson,atdgen oclaunch.byte