#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: FINDER#NEW TEXT FILE
# nmxt: .applescript
# pDSC: Creates a new, blank text file at the current insertion location in
#       Finder.  If an "Untitled Text Document.txt" already exists at that
#       location, a sequential number is appended to the filename. 

# plst: -

# rslt: «docf» : Finder's file reference to the newly created text document
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-09-22
# asmo: 2018-11-04
--------------------------------------------------------------------------------
use Finder : application "Finder"
--------------------------------------------------------------------------------
property displayed name : "Untitled Text Document"
property name extension : ".txt"
property index : missing value
property filename : a reference to [displayed name, my index, name extension]
property location : a reference to insertion location
--------------------------------------------------------------------------------
# IMPLEMENTATION:
Finder's (make new file at (my location as alias) ¬
	with properties {name:newfilename()})
--------------------------------------------------------------------------------
# HANDLERS:
on newfilename()
	script
		on fn(i)
			local i
			
			set my index to [space, i]
			if 1 ≥ i then set my index to ""
			
			script textdocument
				property name : my filename's contents as text
				property path : [my location as text, name]
			end script
			
			set fp to the textdocument's path as text
			if Finder's file fp exists then return fn(i + 1)
			textdocument's name
		end fn
	end script
	
	result's fn(0)
end newfilename
---------------------------------------------------------------------------❮END❯