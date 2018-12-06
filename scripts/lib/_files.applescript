#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: _FILES
# nmxt: .applescript
# pDSC: File manipulation handlers that specialise in POSIX path handling
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-08-31
# asmo: 2018-12-06
--------------------------------------------------------------------------------
property name : "_files"
property id : "chri.sk.applescript._files"
property version : 1.0
property _files : me
--------------------------------------------------------------------------------
property sys : application "System Events"
property Finder : application "Finder"
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
# APPLESCRIPT HANDLERS & SCRIPT OBJECTS:

# make
#   Create a new file or folder at the given file +path.  To create a folder,
#   terminate the +path with "/".
to make at path
	if exists path then return false
	
	set fstype to file
	if path ends with "/" then set fstype to «class cfol»
	
	tell sys to make new fstype with properties {name:path}
	alias (path of result)
end make

# __Sys()
#   Create a System Events file reference
on __Sys(fp as text)
	a reference to sys's alias fp
end __Sys

# __alias()
#   Create an alias
to __alias(fp as text)
	#POSIX file («class posx» of __Sys(fp)) as alias
	__Sys(fp) as alias
end __alias

# __Finder()
#   Create a Finder file reference
on __Finder(fp as text)
	Finder's item __alias(fp)
end __Finder

# exists
#   Determines whether or not a file exists at the specified path
on exists (fp as text)
	__Sys(fp) exists
end exists

# delete
#   Moves the file at the specified path to the Trash
to delete (fp as text)
	if not (exists fp) then return false
	delete __Finder(fp)
end delete

# dir()
#   Returns the parent (containing) directory 
on dir(fp as text)
	[__alias(fp), "::"] as text as alias
	POSIX path of result
end dir

# resolve()
#   Standardises the filepath (expanding tildes, removing double /), and
#   resolves alias links, returning the path to the original file
to resolve(fp as text)
	if not (exists fp) then return false
	set f to __Finder(fp)
	tell (f's «class orig») to if exists then set f to it
	POSIX path of (f as alias)
end resolve

# type()
#   Returns the type of file object at the given filepath, e.g. folder, file, 
#   package file, etc.
on type(fp as text)
	if not (exists fp) then return false
	class of sys's item fp
end type

# show()
#   Reveals the file at the given filepath in Finder
to show(fp as text)
	if not (exists fp) then return false
	set f to __Finder(fp)
	«event miscmvis» f
	activate Finder
	f
end show
using terms from application "Finder"
	on reveal fp
		show(fp)
	end reveal
end using terms from

# tag()
#   Tags a file in Finder with a colour
to tag(fp as text, index)
	if not (exists fp) then return false
	set f to __Finder(fp)
	set «class labi» of f to index
	f
end tag
to untag(fp)
	tag(fp, 0)
end untag

# filename()
#   Returns the name of the object at the specified filepath, including any
#   extension
on filename(fp as text)
	if not (exists fp) then return false
	name of __Sys(fp)
end filename

# ext()
#   Returns the file extension of the file at the specified filepath
on ext(fp as text)
	if not (exists fp) then return false
	«class extn» of __Sys(fp)
end ext
--------------------------------------------------------------------------------
# APPLESCRIPT-OBJC HANDLERS
use framework "AppKit"

property this : a reference to current application
property NSMetadataItem : a reference to NSMetadataItem of this
property NSPasteboard : a reference to NSPasteboard of this
property NSURL : a reference to NSURL of this

# metadata()
#   Returns a record containing the filesystem's metadata for the given
#   reference at the filepath
on metadata(fp)
	set f to __alias(fp)
	set mdItem to NSMetadataItem's alloc()'s initWithURL:f
	tell (mdItem's attributes() as list) to if {} ≠ it then ¬
		return (mdItem's valuesForAttributes:it) as record
	
	{}
end metadata

# cbCopy:
#   Writes the file object references at the specified filepaths to the
#   clipboard
to cbCopy:fs
	local fs
	
	set pb to NSPasteboard's generalPasteboard()
	pb's clearContents()
	
	repeat with f in fs
		try
			__alias(f)
		on error
			null
		end try
		set f's contents to result
	end repeat
	
	pb's writeObjects:(aliases in fs)
end cbCopy:

# cb()
#   Retrieves a list of file object references currently on the clipboard
on cb()
	set pb to NSPasteboard's generalPasteboard()
	(pb's readObjectsForClasses:[NSURL] options:[]) as list
end cb
---------------------------------------------------------------------------❮END❯