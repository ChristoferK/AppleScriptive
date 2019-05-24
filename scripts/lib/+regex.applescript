#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: +REGEX
# nmxt: .applescript
# pDSC: Regular Expression functions.  Loading this library also loads _text
#       lib.
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-12-05
# asmo: 2019-05-18
--------------------------------------------------------------------------------
property name : "regex"
property id : "chri.sk.applescript.lib:regex"
property version : 1.0
property libload : script "load.scpt"
property parent : libload's load("strings")
--------------------------------------------------------------------------------
use framework "Foundation"

property this : a reference to current application
property nil : a reference to missing value
property _1 : a reference to reference

property NSDataDetector : a reference to NSDataDetector of this
property NSDictionary : a reference to NSDictionary of this
property NSMutableArray : a reference to NSMutableArray of this
property NSPredicate : a reference to NSPredicate of this
property NSRange : a reference to NSRange of this
property NSRegularExpression : a reference to NSRegularExpression of this
property NSSet : a reference to NSSet of this
property NSString : a reference to NSString of this
property NSURL : a reference to NSURL of this

property NSRegExSearch : a reference to 1024
property NSTextCheckingTypeLink : a reference to 32
property UTF8 : a reference to 4
--------------------------------------------------------------------------------
# APPLESCRIPT-OBJC HANDLERS:

to __NSString__(str)
	NSString's stringWithString:str
end __NSString__

to __any__(obj)
	item 1 of ((NSArray's arrayWithObject:obj) as list)
end __any__

# match()
#   Returns a list of regular expression pattern matches within the supplied
#   string.
to match(str as text, re)
	local str, re
	
	set str to __NSString__(str)
	set range to str's rangeOfString:re options:NSRegExSearch
	if range's |length| = 0 then return {}
	set x to NSRange's NSMaxRange(range)
	set s to (str's substringWithRange:range) as text
	{s} & match(str's substringWithRange:{¬
		x, (str's |length|()) - x}, re)
end match

# replace()
#   Replaces all occurrences of substrings matched by the regular expression
#   with the replacement string, +rs, which may include references to sub-
#   patterns within the search pattern.
to replace(str as text, re, t)
	local str, re, t
	
	set str to __NSString__(str's contents)
	(str's stringByReplacingOccurrencesOfString:re ¬
		withString:t options:NSRegExSearch ¬
		range:{0, str's |length|()}) as text
end replace

# map()
#   Returns a list of regular expression pattern matches mapped onto a new
#   template string formatted using references to subpatterns within the search
#   pattern.  The search is case-insensitive.  Other flags are activated from
#   within the regular expression, i.e. (?m), (?s), (?sm), etc.
to map(str as text, re, t)
	local str, re, t
	
	set results to NSMutableArray's array()
	
	tell (NSRegularExpression's regularExpressionWithPattern:re ¬
		options:1 |error|:nil) to repeat with match in ¬
		(its matchesInString:str options:0 range:{0, str's length})
		
		(results's addObject:(its replacementStringForResult:match ¬
			inString:str offset:0 template:t))
	end repeat
	
	results as list
end map

# extractLinks
#   Extracts email address and URLs from the +input, which can be a string
#   or a path to a file whose contents is to be searched
to extractLinks from input as text
	set input to __NSString__(input)
	set predicate to "self BEGINSWITH[c] 'mailto:'"
	
	tell (NSString's stringWithContentsOfURL:(NSURL's ¬
		fileURLWithPath:(input's stringByStandardizingPath())) ¬
		encoding:UTF8 |error|:nil) to if missing value ≠ it ¬
		then set input to it
	
	set matches to NSSet's setWithArray:((NSDataDetector's ¬
		dataDetectorWithTypes:NSTextCheckingTypeLink |error|:nil)'s ¬
		matchesInString:input options:0 range:[0, input's |length|()])
	
	tell (matches's valueForKeyPath:"URL.absoluteString") to set ¬
		results to {emails:filteredSetUsingPredicate_(NSPredicate's ¬
		predicateWithFormat:predicate)'s allObjects() as list ¬
		, URLs:filteredSetUsingPredicate_(NSPredicate's ¬
		predicateWithFormat:("!" & predicate))'s allObjects() as list}
	
	repeat with email in (a reference to emails of results)
		tell the email to set its contents to text 8 thru -1 of it
	end repeat
	
	return the results
end extractLinks
---------------------------------------------------------------------------❮END❯