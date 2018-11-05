#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: _FILE
# nmxt: .applescript
# pDSC: File manipulation handlers that specialise in POSIX path handling
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-08-31
# asmo: 2018-11-04
--------------------------------------------------------------------------------
property name : "_file"
property id : "chri.sk.applescript._file"
property version : 1.0
property _file : me
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
to make at path
	if exists path then return false
	make sys new file with properties {name:path}
	result as alias
end make


on __sys__(fp as text)
	a reference to sys's item fp
end __sys__


on __alias__(fp as text) -- coercion to alias
	__sys__(fp) as alias
end __alias__


on __finder__(fp as text)
	Finder's item __alias__(fp)
end __finder__


on exists (fp as text)
	__sys__(fp) exists
end exists


to delete (fp as text) -- move to trash
	if not (exists fp) then return false
	delete __finder__(fp)
end delete


on dir(fp as text) -- parent (containing) directory
	[__alias__(fp), "::"] as text as alias
	POSIX path of result
end dir


to resolve(fp as text) -- standardise path & resolve alias links
	if not (exists fp) then return false
	set f to __finder__(fp)
	tell (f's «class orig») to if exists then set f to it
	POSIX path of (f as alias)
end resolve


on type(fp as text) -- file, folder, package file, etc.
	if not (exists fp) then return false
	class of sys's item fp
end type


to show(fp as text) -- reveal in Finder
	if not (exists fp) then return false
	set f to __finder__(fp)
	«event miscmvis» f
	activate Finder
	f
end show
using terms from application "Finder"
	on reveal fp
		show(fp)
	end reveal
end using terms from


to tag(fp as text, index) -- tag a file in Finder with a colour
	if not (exists fp) then return false
	set f to __finder__(fp)
	set «class labi» of f to index
	f
end tag
to untag(fp)
	tag(fp, 0)
end untag


on filename(fp as text) --  filename (with extension)
	if not (exists fp) then return false
	name of __sys__(fp)
end filename


on ext(fp as text) -- file extension
	if not (exists fp) then return false
	«class extn» of __sys__(fp)
end ext
--------------------------------------------------------------------------------
# APPLESCRIPT-OBJC HANDLERS
use framework "AppKit"

property this : a reference to current application
property NSMetadataItem : a reference to NSMetadataItem of this
property NSURL : a reference to NSURL of this
property NSPasteboard : a reference to NSPasteboard of this

on metadata(fp)
	set f to __alias__(fp)
	set mdItem to NSMetadataItem's alloc()'s initWithURL:f
	tell (mdItem's attributes() as list) to if {} ≠ it then ¬
		return (mdItem's valuesForAttributes:it) as record
	
	{}
end metadata


to copyFiles:fs
	local fs
	
	set pb to NSPasteboard's generalPasteboard()
	pb's clearContents()
	
	repeat with f in fs
		try
			__alias__(f)
		on error
			null
		end try
		set f's contents to result
	end repeat
	
	pb's writeObjects:(aliases in fs)
end copyFiles:


on filesFromClipboard()
	set pb to NSPasteboard's generalPasteboard()
	(pb's readObjectsForClasses:[NSURL] options:[]) as list
end filesFromClipboard
---------------------------------------------------------------------------❮END❯