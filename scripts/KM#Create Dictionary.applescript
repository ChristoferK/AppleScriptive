#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: KM#CREATE DICTIONARY
# nmxt: .applescript
# pDSC: Parses a string and generates a Keyboard Maestro dictionary

# plst: +t : The string to parse

# rslt: -1 : Improperly formatted string
#        1 : Success
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-10-25
# asmo: 2018-11-04
--------------------------------------------------------------------------------
use framework "Foundation"

property this : a reference to current application
property NSRegularExpression : a reference to NSRegularExpression of this
--------------------------------------------------------------------------------
property text item delimiters : linefeed
--------------------------------------------------------------------------------
# IMPLEMENTATION:
# 	"TestDict: [
#		Key 1: Value 1
#		Key 2: Value 2
#	    ...
# 	]"
on run t
	if t's class = script then set t to ["TestDict:[]"]
	set t to t as text
	
	try
		set [dict] to match(t, "(?sm)^([\\w ]+): ?\\[(.*)\\]$", "$1")
	on error E
		return -1
	end try
	set keys to match(t, "(?m)^\\s*([\\w ]+?) ?: ?([\\w ]*)$", "$1")
	set values to match(t, "(?m)^\\s*([\\w ]+?) ?: ?([\\w ]*)$", "$2")
	
	tell application "Keyboard Maestro Engine"
		make new dictionary with properties {name:dict, id:dict}
		
		tell the result to repeat with i from 1 to length of keys
			set [k, v] to [item i of keys, item i of values]
			make new dictionary key with properties ¬
				{name:k, id:dict & ":" & k, value:v}
		end repeat
	end tell
	
	1
end run
--------------------------------------------------------------------------------
# HANDLERS & SCRIPT OBJECTS:
to match(t as text, re, rs)
	local t, re, rs
	
	set RegEx to NSRegularExpression's regularExpressionWithPattern:re ¬
		options:1 |error|:(missing value)
	
	set R to {}
	
	repeat with match in (RegEx's matchesInString:t ¬
		options:0 range:{0, t's length})
		
		set end of R to (RegEx's replacementStringForResult:match ¬
			inString:t offset:0 template:rs) as text
	end repeat
	
	R
end match
---------------------------------------------------------------------------❮END❯