#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: LOAD
# nmxt: .applescript
# comt: This is the text version of load.scpt for the purposes of online viewing
# pDSC: Enables loading of non-compiled AppleScripts from a custom location.
#       Also provides top-level handlers and properties to scripts invoking 
#       this as its parent.
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-08-07
# asmo: 2018-11-04
--------------------------------------------------------------------------------
property name : "libload"
property id : "chri.sk.applescript.libload"
property version : 1.0
property libload : me
property parent : AppleScript
--------------------------------------------------------------------------------
property rootdir : "~/Documents/Scripts/AppleScript/scripts"
--------------------------------------------------------------------------------
property this : a reference to current application
property sys : application "System Events"
property Finder : application "Finder"
--------------------------------------------------------------------------------
# HANDLERS & SCRIPT OBJECTS:
to load script s
	local s
	
	script
		property fp : path to (s as text)
		property tmp : "/tmp/load.scpt"
		
		to load()
			if fp = false then return AppleScript
			
			if fp ends with ".scpt" then tell the ¬
				current application to return ¬
				load script fp
			
			set sh to contents of ["osacompile -o ", ¬
				tmp, space, fp's quoted form] as text
			
			do shell script sh
			set s to load script tmp
			# delete sys's file tmp
			s
		end load
	end script
	
	result's load()
end load script
to load(s)
	load script s
end load


on path to sth
	local f
	
	if sth's class is not in [text, alias] then return ¬
		path to POSIX path of (continue path to sth)
	
	set fp to sth as text
	
	-- Default to folder "lib" in root folder if none supplied
	if fp does not contain "/" then set fp to («class posx» ¬
		of item "lib" in sys's item rootdir) & "/" & fp
	
	-- Append .applescript extension if none
	if not (fp ends with ".scpt" or ¬
		fp ends with ".applescript") ¬
		then set fp to fp & ".applescript"
	
	-- If file is an alias to an original, get its source
	set f to a reference to sys's file fp
	# if not (f exists) then return false	
	set f to Finder's file (f as alias)
	tell (f's «class orig») to if exists then set f to it
	
	POSIX path of (f as alias)
end path to
---------------------------------------------------------------------------❮END❯