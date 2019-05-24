#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: +STRINGS
# nmxt: .applescript
# pDSC: String manipulation handlers.  Loading this library also loads _lists 
#       lib.  For a string replace function, use _regex lib.
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-08-31
# asmo: 2019-05-17
--------------------------------------------------------------------------------
property name : "strings"
property id : "chri.sk.applescript.lib:strings"
property version : 1.5
property libload : script "load.scpt"
property parent : libload's load("arrays")
--------------------------------------------------------------------------------
property lower : "abcdefghijklmnopqrstuvwxyz"
property upper : "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
property whitespace : [tab, space, linefeed, return]
property tids : my text item delimiters
--------------------------------------------------------------------------------
# HANDLERS & SCRIPT OBJECTS:

# __string__()
#   Returns a string representation of an AppleScript object
to __string__(obj)
	if class of obj = text then return obj
	
	try
		set s to {_:obj} as text
	on error E
		my tid:{"Can’t make {_:"}
		set s to text items 2 thru -1 of E as text
		
		my tid:{"} into type text."}
		set s to text items 1 thru -2 of s as text
		
		my tid:{}
	end try
	
	s
end __string__

# __text__() [ syn. concat() ]
#   Joins a list of text items together without any delimiters
to __text__(t as linked list)
	t as text
end __text__
on concat(t)
	__text__(t)
end concat

# __class__()
#   Takes the text name of an AppleScript class and returns the corresponding
#   type class object, or 0 if the input doesn't correspond to an AppleScript
#   class.  Chevron syntax codes can be used as input, e.g. __class__("orig").
on __class__(str as text)
	local str
	
	try
		run script str & " as class"
	on error
		try
			set str to text 1 thru 4 of (str & "   ")
			run script "«class " & str & "» as class"
		on error
			0
		end try
	end try
end __class__

# tid: [ syn. tid() ]
#   Sets AppleScript's text item delimiters to the supplied value.  If this
#   value is {} or 0, the text item delimiters are reset to their previous
#   value.
on tid:(d as list)
	local d
	
	if d = {} or d = {0} then
		set d to tids
	else if d's item 1 = null then
		set N to random number from 0.0 to 1.0E+9
		set d's first item to N / pi
	end if
	
	set tids to my text item delimiters
	set my text item delimiters to d
end tid:
on tid(d)
	tid_(d)
end tid

# join() [ syn. glue() ]
#   Joins a list of items (+L) together using the supplied delimiter (+d)
to join by d as list given list:L as list
	tid(d)
	set t to L as text
	tid(0)
	t
end join
to glue(t, d)
	join by d given list:L
end glue

# split() [ syn. unjoin(), unglue() ]
#   Splits text (+t) into a list of items wherever it encounters the supplied
#   delimiters (+d)
on split at d as list given string:t as text
	tid(d)
	set L to text items of t
	tid(0)
	L
end split
to unjoin(t, d)
	split at d given string:t
end unjoin
to unglue(t, d)
	split at d given string:t
end unglue

# offset
#   Returns the indices of each occurrence of a substring in a given string
on offset of needle in haystack
	local needle, haystack
	
	if the needle is not in the haystack then return {}
	tid(needle)
	
	script
		property N : needle's length
		property t : {1 - N} & haystack's text items
	end script
	
	tell the result
		repeat with i from 2 to (its t's length) - 1
			set x to item i of its t
			set y to item (i - 1) of its t
			set item i of its t to (its N) + (x's length) + y
		end repeat
		
		tid(0)
		
		items 2 thru -2 of its t
	end tell
end offset

# hasPrefix [ syn. startsWith() ]
#   Determines whether a given string starts with any one of a list of 
#   +substrings, returning true or false
on hasPrefix from substrings as list given string:t as text
	local substrings, t
	
	script prefixes
		property list : substrings
	end script
	
	repeat with prefix in the list of prefixes
		if t starts with prefix ¬
			then return true
	end repeat
	
	false
end hasPrefix
on startsWith(t as text, substrings as list)
	local t, substrings
	hasPrefix from substrings given string:t
end startsWith

# rev()
#   gnirts a sesreveR
on rev(t as text)
	local t
	
	__text__(reverse of characters of t)
end rev

# uppercase()
#   RETURNS THE SUPPLIED STRING FORMATTED IN UPPERCASE (A-Z ONLY)
to uppercase(t as text)
	local t
	
	script capitalise
		property chars : characters of t
		
		to fn(x)
			tell (offset of x in lower) to if it ≠ {} ¬
				then return upper's character it
			x's contents
		end fn
	end script
	
	mapItems from chars of capitalise given handler:capitalise
	__text__(result)
end uppercase

# lowercase()
#   returns the supplied string formatted in lowercase (a-z only)
to lowercase(t as text)
	local t
	
	script decapitalise
		property chars : characters of t
		
		to fn(x)
			tell (offset of x in upper) to if it ≠ {} ¬
				then return lower's character it
			x's contents
		end fn
	end script
	
	mapItems from chars of decapitalise given handler:decapitalise
	__text__(result)
end lowercase

# titlecase()
#   Returns The Supplied String Formatted In Titlecase (A-Z Only)
to titlecase(t as text)
	local t
	
	script titlecase
		property chars : characters of t
		
		to fn(x, i, L)
			if i = 1 or item (i - 1) of L ¬
				is in whitespace then ¬
				return uppercase(x)
			
			lowercase(x)
		end fn
	end script
	
	mapItems from chars of titlecase given handler:titlecase
	__text__(result)
end titlecase

# substrings()
#   Returns every substring of a given string
on substrings from t as text
	local t
	
	script
		property chars : characters of t
		property result : {}
		
		to recurse thru s at i : 1 for N : 1
			local i, N, s
			
			if N > length of s then ¬
				return my result
			
			set j to i + N - 1
			
			if j > length of s then
				recurse thru s for N + 1
				return the result
			end if
			
			__text__(items i thru j of s)
			set end of my result to result
			recurse thru s at i + 1 for N
		end recurse
	end script
	
	tell the result to recurse thru its chars
end substrings
on substr(t)
	substrings from t
end substr

# LCS()
#   Returns the longest common substring of two strings
on LCS(|s₀| as text, |t₀| as text)
	local |s₀|, |t₀|
	
	script
		property s : substr(|s₀|)
		property t : substr(|t₀|)
		
		property list : intersection(s, t)
	end script
	
	return the last item of the result's list
end LCS

# anagrams()
#   Lists every permutation of character arrangement for a given string
on anagrams(t as text)
	local t
	
	script
		property s : characters of t
		property result : {}
		
		to permute(i, k)
			local i, k
			
			if i > k then set end of my result to s as text
			
			repeat with j from i to k
				swap(s, i, j)
				permute(i + 1, k)
				swap(s, i, j)
			end repeat
		end permute
	end script
	
	tell the result
		permute(1, length of t)
		unique_(its result)
	end tell
end anagrams
---------------------------------------------------------------------------❮END❯