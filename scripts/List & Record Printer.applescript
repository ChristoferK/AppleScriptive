#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: RECORD & LIST PRINTER
# nmxt: .applescript
# pDSC: Pretty prints a text representation of an AppleScript list or record

# plst: *input : A list or record or a valid string representation of such

# rslt: «ctxt» : Pretty-printed string representation of the input
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-10-20
# asmo: 2018-10-31
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
	if input's class = script then set input to [{{1, 2, {a:3, b:4}, ¬
		"foo"}, {c:{alpha:1, beta:"bar"}, d:"5"}, "6", {7, {8, 9}, 0}}]
	set [input] to the input
	set input to __String_(input)
	
	set output to the text in remapItems(scanString(input))
	(foldItems of output given handler:tabulate) as text
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


to __String:input
	local input
	
	if the input's class ≠ list then
		try
			set s to input as text
		on error E --> "Can’t make %object% into type text."
			set text item delimiters to {"Can’t make ", ¬
				" into type text."}
			set s to text item 2 of E
		end try
	else
		repeat with x in the input
			set x's contents to __String_(x's contents)
		end repeat
		
		set my text item delimiters to ", "
		set s to ["[", the input, "]"] as text
	end if
	
	s
end __String:


to append(x as list)
	local x
	
	set my output to my output & x
end append


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
			set y to (a reference to its item (i - 1))
			set z to (a reference to its item (i + 1))
			
			if x ends with ":" then -- record as list item
				set its item (i + 1) to x & z
				set its item i to null
			end if
			
			if (x contains quote and ¬
				(x does not end with quote or ¬
					x ends with ":\"" or ¬
					x's contents = quote)) or ¬
				x ends with quote and ¬
				z's contents is not in [",", "}", "]"] then
				
				set its item (i + 1) to x & z
				set its item i to null
			end if
		end repeat
		
		its contents
	end tell
end remapItems


to scanString(input)
	local input
	
	set output to {}
	
	NSCharacterSet's characterSetWithCharactersInString:"[]{},\""
	set charSet to the result
	
	tell (NSScanner's scannerWithString:input) to repeat until ¬
		(its atEnd as boolean)
		
		scanUpToCharactersFromSet_intoString_(charSet, reference)
		set [bool, s] to the result
		if bool = true then set output to output & {s as text}
		
		scanCharactersFromSet_intoString_(charSet, reference)
		set [bool, t] to the result
		if bool = true then set output to output & (t as text)'s characters
	end repeat
	
	output
end scanString


on tabulate(N, x)
	local N, x
	
	set text item delimiters to ""
	
	if x is in "[{" then return [N & tab, [N, x, return] as text]
	if x = "," then return [N, [x, return] as text]
	if x is in "]}" then return [rest of N, ¬
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