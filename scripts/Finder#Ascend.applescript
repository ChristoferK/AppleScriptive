#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: FINDER#ASCEND
# nmxt: .applescript
# pDSC: Takes a selection of files in Finder and moves them up one level in
#       the directory tree.  Files within the home sub-tree will not be moved
#       higher than the home directory.

# plst: -

# rslt: 0 : Files are in the home directory
#      -1 : Finder is not frontmost; OR focused window is not a Finder window
#       - : Files ascend directory
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-03-03
# asmo: 2018-11-04
--------------------------------------------------------------------------------
use Finder : application "Finder"
use scripting additions
--------------------------------------------------------------------------------
property home : Finder's home as alias
property selection : a reference to Finder's selection
--------------------------------------------------------------------------------
# IMPLEMENTATION:
on run
	-- Check Finder is frontmost
	name of the application named (path to frontmost application)
	if the result is not in ["Finder", "Script Editor"] then return -1
	
	set here to the insertion location as alias
	set there to [here, "::"] as text as alias as text
	
	-- Verify appropriate window focus
	if here ≠ (path to desktop folder) then if ¬
		the front Finder window is not ¬
		Finder's front window then ¬
		return -1
	
	-- Don't ascend higher than ~/ or /
	if POSIX path of here is in [home's POSIX path, "/"] then
		beep
		return 0
	end if
	
	
	set fs to the selection as alias list
	-- Exclude files that would overwrite a pre-existing file
	tell Finder to repeat with f in fs
		try
			[there, name of f] as text as alias
			set contents of f to missing value
		end try
	end repeat
	
	
	reveal (move the aliases of fs to there)
	activate Finder
end run
---------------------------------------------------------------------------❮END❯