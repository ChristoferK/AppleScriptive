#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: FINDER#NEW TEXT FILE
# nmxt: applescript
# pDSC: Creates a new, blank text file at the current insertion location in
#	Finder.  If an "Untitled Text Document.txt" already exists at that
#	location, a sequential number is appended to the filename. 

# plst: -

# rslt: ÇdocfÈ : Finder's file reference to the newly created text document
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-09-22
# asmo: 2018-10-09
--------------------------------------------------------------------------------
use finder : application "Finder"
--------------------------------------------------------------------------------
property displayed name : "Untitled Text Document"
property name extension : ".txt"
property index : null
property file name : a reference to [displayed name, my index, name extension]
property folder : a reference to insertion location
--------------------------------------------------------------------------------
--IMPLEMENTATION:
finder's (make new file at (contents of my folder as alias) Â
	with properties {name:my newfile(0)'s name as text})
--------------------------------------------------------------------------------
--HANDLERS:
on newfile(i as integer)
	local i
	
	set my index to [space, i]
	if 1 ³ i then set my index to ""
	
	script textfile
		property name : contents of my file name
		property path : contents of [my folder as alias, my name]
		property file : a reference to finder's file (my path as text)
	end script
	
	if the textfile's file exists then return newfile(i + 1)
	textfile
end newfile
----------------------------------------------------------------------------:END