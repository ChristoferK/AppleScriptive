#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: _REGEX
# nmxt: .applescript
# pDSC: Regular Expression functions.  Loading this library also loads _text
#       lib.
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-12-05
# asmo: 2018-12-06
--------------------------------------------------------------------------------
property name : "_regex"
property id : "chri.sk.applescript._regex"
property version : 1.0
property _regex : me
property libload : script "load.scpt"
property parent : libload's load("_text")
--------------------------------------------------------------------------------
# APPLESCRIPT-OBJC HANDLERS:
use framework "Foundation"

property this : a reference to current application
property NSString : a reference to NSString of this
property NSRange : a reference to NSRange of this
property NSRegularExpression : a reference to NSRegularExpression of this
property NSRegularExpressionSearch : a reference to 1024

to __NSString(t as text)
	NSString's stringWithString:t
end __NSString


to __any(x)
	(NSArray's arrayWithObject:x) as list
	item 1 of the result
end __any

# match()
#   Returns a list of regular expression pattern matches within the supplied
#   string.
to match(t as text, re)
	local t, re
	
	set t to __NSString(t)
	set range to t's rangeOfString:re options:NSRegularExpressionSearch
	if range's |length| = 0 then return {}
	set x to NSRange's NSMaxRange(range)
	set s to (t's substringWithRange:range) as text
	{s} & match(t's substringWithRange:{x, (t's |length|()) - x}, re)
end match

# replace()
#   Replaces all occurrences of substrings matched by the regular expression
#   with the replacement string, +rs, which may include references to sub-
#   patterns within the search pattern.
to replace(t as text, re, rs)
	local t, re, rs
	
	__NSString(t's contents)'s stringByReplacingOccurrencesOfString:re ¬
		withString:rs options:NSRegularExpressionSearch ¬
		range:{0, t's length}
	
	result as text
end replace

# map()
#   Returns a list of regular expression pattern matches mapped onto a new
#   template string formatted using references to subpatterns within the search
#   pattern.  The search is case-insensitive.  Other flags are activated from
#   within the regular expression, i.e. (?m), (?s), (?sm), etc.
to map(t as text, re, rs)
	local t, re, rs
	
	set rx to NSRegularExpression's regularExpressionWithPattern:re ¬
		options:1 |error|:(missing value)
	
	set R to {}
	
	repeat with match in (rx's matchesInString:t ¬
		options:0 range:{0, t's length})
		
		set end of R to (rx's replacementStringForResult:match ¬
			inString:t offset:0 template:rs) as text
	end repeat
	
	R
end map
---------------------------------------------------------------------------❮END❯