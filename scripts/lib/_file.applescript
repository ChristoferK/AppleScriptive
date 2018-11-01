#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: _FILE
# nmxt: .applescript
# pDSC: File manipulation handlers that specialise in POSIX path handling
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-08-31
# asmo: 2018-10-31
--------------------------------------------------------------------------------
property name : "_file"
property id : "chrisk.applescript._file"
property version : 1.0
property _file : me
#property parent : script "load.scpt"
#property _array : load script "_array"
--------------------------------------------------------------------------------
property Finder : application "Finder"
property sys : application "System Events"
--------------------------------------------------------------------------------
# FINDER TAGS:
property unset : 0
property orange : 1
property red : 2
property yellow : 3
property blue : 4
property purple : 5
property green : 6
property grey : 7
--------------------------------------------------------------------------------
# HANDLERS & SCRIPT OBJECTS:
to make at path
	if exists path then return false
	make sys new file with properties {name:path}
	result as alias
end make


on exists fp
	exists (a reference to sys's item fp)
end exists


to delete (fp) -- move to trash
	if not (exists fp) then return false
	delete Finder's item __alias_(fp)
end delete


on __alias:fp -- coercion to alias
	sys's alias fp as alias
end __alias:


on dir(f as text) -- parent (containing) directory
	(POSIX file f as alias as text) & "::" as alias
	POSIX path of result
end dir


to resolve(fp) -- standardise path & resolve alias links
	if not (exists fp) then return false
	set f to Finder's item (sys's alias fp as alias)
	tell (f's «class orig») to if exists then set f to it
	POSIX path of (f as alias)
end resolve


on type(fp) -- file, folder, package file, etc.
	if not (exists fp) then return false
	class of sys's item fp
end type


to show(fp) -- reveal in Finder
	if not (exists fp) then return false
	«event miscmvis» Finder's item __alias_(fp)
	activate Finder
end show
using terms from application "Finder"
	on reveal fp
		show(fp)
	end reveal
end using terms from


to tag(fp, index) -- tag a file in Finder with a colour
	if not (exists fp) then return false
	set «class labi» of Finder's item __alias_(fp) to index
end tag
to untag(fp)
	tag(fp, 0)
end untag


on filename(fp) --  filename (with extension)
	if not (exists fp) then return false
	name of sys's item fp
end filename


on ext(fp) -- file extension
	if not (exists fp) then return false
	«class extn» of sys's item fp
end ext
---------------------------------------------------------------------------❮END❯