#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: LIST & RECORD PRINTER
# nmxt: .applescript
# pDSC: Pretty prints a text representation of an AppleScript list or record

# plst: +input : A list or record or a valid string representation of such

# rslt: «ctxt» : Pretty-printed string representation of the input
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-10-20
# asmo: 2018-11-02
--------------------------------------------------------------------------------
use framework "Foundation"
use scripting additions

property this : a reference to current application

property NSString : a reference to NSString of this
property NSScanner : a reference to NSScanner of this
property NSCharacterSet : a reference to NSCharacterSet of this
--------------------------------------------------------------------------------
# IMPLEMENTATION:
on run input
	if input's class = script then set input to [{¬
		{1, 2, {a:3, b:4}, "Hello, \"World!\""}, ¬
		{c:{alpha:1, beta:"foo{bar}"}, d:"5"}, ¬
		"6", {7, {8, 9}, 0} ¬
		}]
	set [input] to the input
	set input to __String_(input)
	
	scanString(input)
	remapItems(result)
	text in the result
	(foldItems of the result given handler:tabulate) as text
end run
--------------------------------------------------------------------------------
# HANDLERS & SCRIPT OBJECTS:

on __(function)
	if function's class = script ¬
		then return function
	
	script
		property fn : function
	end script
end __


to __String:obj
	local obj
	
	try
		{_:obj} as text
	on error E --> "Can’t make %object% into type text."
		set text item delimiters to {"Can’t make ", ¬
			" into type text."}
		text item 2 of E
	end try
	
	result's text 4 thru -2
end __String:


to foldItems of L at |ξ| : {} given handler:function
	local function, |ξ|
	
	script chars
		property list : L
	end script
	
	tell __(function) to repeat with x in ¬
		(a reference to list of chars)
		
		copy fn(|ξ|, contents of x) to ¬
			[|ξ|, contents of x]
	end repeat
	
	L
end foldItems


to remapItems(L)
	local L
	
	script chars
		property list : L
	end script
	
	tell (a reference to the list of chars)
		repeat with i from 2 to (its length) - 1
			set x to (a reference to its item i)
			set y to (a reference to its item (i + 1))
			
			if x ends with ":" then -- record as list item
				set y's contents to x & y
				set x's contents to null
			end if
			
			if (x contains quote and ¬
				(x does not end with quote or ¬
					x ends with ":\"" or ¬
					x's contents = quote)) or ¬
				(x ends with quote and ¬
					y's contents is not in ¬
					[",", "}"]) then
				
				set y's contents to x & y
				set x's contents to null
			end if
		end repeat
		
		its contents
	end tell
end remapItems


to scanString(input)
	local input
	
	set output to {}
	
	NSCharacterSet's characterSetWithCharactersInString:"{},\""
	set charSet to the result
	set Scanner to NSScanner's scannerWithString:input
	
	tell the Scanner to repeat until its atEnd as boolean
		scanUpToCharactersFromSet_intoString_(charSet, reference)
		set [bool, s] to the result
		if bool = true then set output to output & {s as text}
		
		scanCharactersFromSet_intoString_(charSet, reference)
		set [bool, t] to the result
		if bool = true then set output to output & (t as text)'s items
	end repeat
	
	output
end scanString


on tabulate(N, x)
	local N, x
	
	set text item delimiters to ""
	
	if x = "{" then return [N & tab, [N, x, return] as text]
	if x = "," then return [N, [x, return] as text]
	if x = "}" then return [rest of N, ¬
		contents of [return, rest of N, x] as text]
	--else:
	set a to offset of ":" in x
	if a > 0 then set x to the contents of [¬
		text 1 thru a of x, space, ¬
		text (a + 1) thru -1 of x] as text
	if x ends with "{" then return [N & tab, [N, x, return] as text]
	return [N, [N, x] as text]
end tabulate
---------------------------------------------------------------------------❮END❯