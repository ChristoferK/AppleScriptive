#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: _TEXT
# nmxt: .applescript
# pDSC: String manipulation handlers.  Loading this library also loads _arrays 
#       lib.
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-08-31
# asmo: 2018-11-07
--------------------------------------------------------------------------------
property name : "_text"
property id : "chri.sk.applescript._text"
property version : 1.0
property _text : me
property libload : script "load.scpt"
property parent : libload's load("_arrays")
--------------------------------------------------------------------------------
property tid : AppleScript's text item delimiters
--------------------------------------------------------------------------------
# HANDLERS & SCRIPT OBJECTS:

# tid:
#   Sets AppleScript's text item delimiters to the supplied value (d).  If this
#   value is {} or 0, the text item delimiters are reset to their previous
#   value.
on tid:(d as list)
	local d
	
	if d = {} or d = {0} then
		set d to tid
	else if d's item 1 = null then
		set N to random number from 0.0 to 1.0
		set d's first item to (1 / pi) * N
	end if
	
	set tid to AppleScript's text item delimiters
	set AppleScript's text item delimiters to d
end tid:

# join()
#   Joins a list of items (t) together using the supplied delimiter (d)
to join(t as list, d as list)
	tid_(d)
	set t to t as text
	tid_(0)
	t
end join

# split()
#   Splits text (t) into a list of items wherever it encounters the supplied
#   delimiter (d)
on split(t as text, d as list)
	tid_(d)
	set t to text items of t
	tid_(0)
	t
end split

# offset
#   Returns the indices of each occurrence of a substring (str) in a given
#   string (txt)
on offset of txt in str
	local txt, str
	
	if txt is not in str then return {}
	
	tid_(txt)
	
	script
		property N : txt's length
		property t : {1 - N} & str's text items
	end script
	
	tell the result
		repeat with i from 2 to (its t's length) - 1
			set item i of its t to (its N) + ¬
				(length of its t's item i) + ¬
				(its t's item (i - 1))
		end repeat
		
		tid_(0)
		
		items 2 thru -2 of its t
	end tell
end offset

# rev()
#   gnirts a sesreveR
on rev(t as text)
	local t
	
	script
		property s : id of t
	end script
	
	character id (reverse of result's s)
end rev

# uppercase()
#   RETURNS THE SUPPLIED STRING FORMATTED IN UPPERCASE 
to uppercase(t as text) -- UPPERCASE OF A STRING
	local t
	
	script capitalise
		property s : id of t
		
		to fn(x)
			if 97 ≤ x and x ≤ 122 then ¬
				return x - 32
			x's contents
		end fn
	end script
	
	mapItems from s of capitalise given handler:capitalise
	character id result
end uppercase

# lowercase()
#   returns the supplied string formatted in lowercase 
to lowercase(t as text) -- lowercase of a string
	local t
	
	script decapitalise
		property s : id of t
		
		to fn(x)
			if 65 ≤ x and x ≤ 90 then ¬
				return x + 32
			x's contents
		end fn
	end script
	
	mapItems from s of decapitalise given handler:decapitalise
	character id result
end lowercase

# titlecase()
#   Returns The Supplied String Formatted In Titlecase 
to titlecase(t as text)
	local t
	
	script titlecase
		property s : id of t
		
		to fn(x, i, L)
			if i = 1 or item (i - 1) of L ¬
				is in [32, 9, 10, 13] then
				if 97 ≤ x and x ≤ 122 then ¬
					return x - 32
			else if 65 ≤ x and x ≤ 90 then
				return x + 32
			end if
			x's contents
		end fn
	end script
	
	mapItems from s of titlecase given handler:titlecase
	character id result
end titlecase
---------------------------------------------------------------------------❮END❯