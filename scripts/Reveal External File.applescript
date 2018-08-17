#!/usr/bin/osascript
--------------------------------------------------------------------------------
###Reveal External File.applescript
#
#	Reveals the external script file for the selected Keyboard Maestro 
#	action
#
#  Input:
#	None			Acts upon selection in Keyboard Maestro
#
#  Result:
#	Success			Script file revealed in Finder
#	Error Message		Script error
--------------------------------------------------------------------------------
#  Author: CK
#  Date Created: 2018-03-02
#  Date Last Edited: 2018-08-17
--------------------------------------------------------------------------------
use KM : application "Keyboard Maestro"
use KME : application "Keyboard Maestro Engine"
--------------------------------------------------------------------------------
property text item delimiters : "."
--------------------------------------------------------------------------------
property ExtensionTypes : ["applescript", "scpt", "sh"]
--------------------------------------------------------------------------------
###IMPLEMENTATION
#
#
on run
	set [A] to KM's selection
	set R to plistToAS from A's xml

	try
		get |script file| of R's PlugInParameters
	on error
		try
			get R's |path|
		on error E
			return E
		end try
	end try
	
	set ActionFile to process tokens of the result
	
	if the ActionFile's last text item ¬
		is not in ExtensionTypes ¬
		then return
	
	show_(the ActionFile)
end run
--------------------------------------------------------------------------------
###HANDLERS
#
#
to show:f
	local f
	
	tell application "System Events" to set f to file f as alias
	
	tell application "Finder"
		reveal f
		activate
	end tell
end show:


on plistToAS from input
	script ASObjC
		use framework "Foundation"
		----------------------------------------------------------------
		property this : a reference to current application
		property NSArray : a reference to NSArray of this
		property NSData : a reference to NSData of this
		property NSFileManager : a reference to NSFileManager of this
		property NSPlist : a reference to NSPropertyListSerialization ¬
			of this
		property NSString : a reference to NSString of this
		property NSUTF8StringEncoding : a reference to 4
		----------------------------------------------------------------
		on fileExists at f
			NSFileManager's alloc()'s ¬
				fileExistsAtPath:((NSString's ¬
					stringWithString:f)'s ¬
					stringByStandardizingPath())
		end fileExists
		
		on plistToAS()
			if fileExists at input then
				set x to NSData's dataWithContentsOfFile:input
			else
				set x to (NSString's stringWithString:input)'s ¬
					dataUsingEncoding:NSUTF8StringEncoding
			end if
			
			(NSArray's arrayWithObject:(NSPlist's ¬
				propertyListWithData:x options:0 ¬
					format:(missing value) ¬
					|error|:(missing value))) as list
			
			item 1 of the result
		end plistToAS
	end script
	
	ASObjC's plistToAS()
end plistToAS
---------------------------------------------------------------------------❮END❯