all: atdgen-tmp code

atdgen-tmp:
	atdgen -t settings.atd
	atdgen -j settings.atd

code:
	corebuild -pkg yojson,atdgen,core_extended oclaunch.byte
