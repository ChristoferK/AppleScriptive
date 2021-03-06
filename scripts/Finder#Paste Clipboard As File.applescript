#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: FINDER#PASTE CLIPBOARD AS FILE
# nmxt: .applescript
# pDSC: Pastes the contents of the clipboard as a new file in Finder.  The
#       compatible data types are image data (JPG, PNG) and plain text.

# plst: -

# rslt: «docf»     : Finder file object reference
#       «miscmvis» : File pasted and revealed in Finder
#       «sysobeep» : No valid data type to paste
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-04-17
# asmo: 2019-04-16
--------------------------------------------------------------------------------
property allowedTypes : [¬
	JPEG picture, ¬
	«class PNGf», ¬
	TIFF picture, ¬
	«class utf8», ¬
	«class ut16», ¬
	string]
property name : [¬
	"Pasted on ", a reference to timestamp, ¬
	".", a reference to extension]
--------------------------------------------------------------------------------
# IMPLEMENTATION:
on run
	set extension to "txt"
	set timestamp to the current date
	
	tell intersection(clipboard info, allowedTypes) & null ¬
		to set [cbMainType, cbOtherTypes] to ¬
		[its first item, its rest]
	
	if the cbMainType = null then return beep
	
	if cbMainType is in [«class PNGf», TIFF picture] then
		set cbMainType to JPEG picture
		set extension to "jpg"
	end if
	
	set filename to {name:contents of name as text}
	
	tell application "Finder"
		set f to make new file ¬
			at insertion location as alias ¬
			with properties filename
		
		write (the clipboard as the cbMainType) ¬
			to (f as alias) as the cbMainType
		
		reveal f
	end tell
end run
--------------------------------------------------------------------------------
# HANDLERS & SCRIPT OBJECTS:
on current date
	tell (continue current date) as «class isot» as string to ¬
		set [d, t] to its [text 1 thru 10, text 12 thru -1]
	contents of {d, " at ", [t's word 1, "h", t's word 2, "m"]} as text
end current date


on clipboard info
	tell (continue clipboard info)
		repeat with x in (a reference to it)
			tell x to set its contents ¬
				to its first item
		end repeat
		
		it
	end tell
end clipboard info


on __(function)
	if the function's class = script ¬
		then return the function
	
	script
		property fn : function
	end script
end __


to filterItems from L as list into R as list : null given handler:function
	local L, R
	
	if R = null then set R to {}
	
	script
		property list : L
		property result : R
	end script
	
	tell the result to repeat with x in its list
		if __(function)'s fn(x, its list, its result) ¬
			then set end of its result to x's contents
	end repeat
	
	R
end filterItems


on intersection(A as list, B as list)
	local A, B
	
	script
		on member(M)
			script
				on fn(x)
					x is in M
				end fn
			end script
		end member
	end script
	
	filterItems from A given handler:result's member(B)
end intersection
---------------------------------------------------------------------------❮END❯