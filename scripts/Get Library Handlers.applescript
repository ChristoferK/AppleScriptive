#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: GET LIBRARY HANDLERS
# nmxt: .applescript
# pDSC: Retrieves a list of all handlers defined in the lib files and allows
#       the user to select one or more by name, the full code for which will
#       be pasted into Script Editor (if focused) or copied to the clipboard.

# plst: +funclist* : A list of handler names to bypass manual selection

# rslt: 0 : User cancelled selection
#       1 : Handlers' source code copied to clipboard (notification displayed)
#       2 : Handlers' source code pasted into Script Editor
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-12-05
# asmo: 2018-12-07
--------------------------------------------------------------------------------
property parent : script "load.scpt"
property regex : load script "_regex"
--------------------------------------------------------------------------------
property Finder : application "Finder"
--------------------------------------------------------------------------------
property date : missing value
property contents : missing value
property lf3 : linefeed & linefeed & linefeed
--------------------------------------------------------------------------------
# IMPLEMENTATION:
on run funclist
	if funclist's class = script then set funclist to {}
	
	set OK to "Copy"
	get name of application (path to frontmost application)
	if the result = "Script Editor" then set OK to "Paste"
	
	if [my date, contents] contains missing value ¬
		or willUpdateContents() then init()
	
	if {} = funclist or {missing value} = funclist then
		regex's map(contents, regexPattern for anything, "$2")
		choose from list sort(result) ¬
			with title ["Library Handlers"] ¬
			with prompt ["Select handler:"] ¬
			OK button name OK ¬
			cancel button name ["Cancel"] ¬
			with multiple selections allowed
		set funclist to {} & the result
		if funclist = {false} then return 0
	end if
	
	set funcs to regex's join(funclist, "|")
	set code to regex's match(contents, regexPattern for funcs)
	
	if OK = "Copy" then
		set the clipboard to regex's join(code, lf3)
		display notification ["Handlers copied to clipboard"] ¬
			with title my name
		return 1
	end if
	
	tell application "Script Editor" to tell its front document to ¬
		set its selection's contents to regex's join(code, lf3)
	
	return 2
end run
--------------------------------------------------------------------------------
# HANDLERS & SCRIPT OBJECTS:
on regexPattern for function
	set subpattern to function
	if function = anything then set subpattern to "(\\|?)\\w+(\\3)"
	
	"(?ism)^(on|to) (" & subpattern & ")\\b.*?^end \\2"
end regexPattern

to init()
	log "init"
	set libFiles to getLibFiles() as «class alst»
	set my contents to readFiles(libFiles)
	set my date to the current date
end init

to getLibFiles()
	set fp to POSIX file (path to me) as alias
	set lib to [fp, "::", "lib"] as text as alias
	
	set fs to a reference to («class orig» of ¬
		every «class alia» in Finder's item lib ¬
		whose name starts with "_" and ¬
		name extension = "applescript")
	
	if not (fs exists) then return a reference to ¬
		(every «class docf» in Finder's item lib ¬
			whose name starts with "_" and ¬
			name extension = "applescript")
	
	fs
end getLibFiles

on willUpdateContents()
	script
		property list : modification date of getLibFiles()
	end script
	
	repeat with d in result's list
		if d > my date then return true
	end repeat
	
	false
end willUpdateContents

to readFiles(fs)
	local fs
	
	script |files|
		property list : fs
		property contents : {}
	end script
	
	repeat with f in the list of |files|
		read f as «class ut16»
		set end of contents of |files| to the result
	end repeat
	
	regex's join(contents of |files|, linefeed)
	set my contents to the result
end readFiles

to sort(L)
	local L
	
	script
		use framework "Foundation"
		
		to sort(L, mode)
			local L, mode
			
			((current application's NSArray's ¬
				arrayWithArray:L)'s ¬
				sortedArrayUsingSelector:mode) ¬
				as list
		end sort
	end script
	
	result's sort(L, "caseInsensitiveCompare:")
end sort
---------------------------------------------------------------------------❮END❯