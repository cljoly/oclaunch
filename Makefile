all: atdgen-set atdgen-tmp code

atdgen-set:
	atdgen -t tmp_log.atd
	atdgen -j tmp_log.atd
	
atdgen-tmp:
	atdgen -t settings.atd
	atdgen -j settings.atd


code:
	corebuild -pkg yojson,atdgen oclaunch.byte
