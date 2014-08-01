all: atdgen-rc code

atdgen-rc:
	atdgen -t settings.atd # Types
	atdgen -v settings.atd # Validator
	atdgen -j -j-defaults -j-strict-fields settings.atd # Useful function

code:
	corebuild -pkg yojson,atdgen,core_extended oclaunch.byte
