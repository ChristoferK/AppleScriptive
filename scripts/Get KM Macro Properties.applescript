#!/usr/bin/osascript
--------------------------------------------------------------------------------
###Get KM Macro Properties.applescript
#
#	Retrieves an AppleScript record containing properties of all existing
#	Keyboard Maestro macros.  A record for a specific macro can be sought
#	given a name of the macro and the name of the macro group in which it
#	resides.  From this, the date the macro was last used is retrieved, and
#	converted from Apple's Cocoa time to an AppleScript date object.
#
#  Input:
#	None				-
#
#  Result:
#	⟨record⟩			The property record for the macro
--------------------------------------------------------------------------------
#  Author: CK
#  Date Created: 2018-08-01
#  Date Last Edited: 2018-08-07
--------------------------------------------------------------------------------
KMMacroByName_inGroup_("Empty Trash", "Global Macro Group")
# if the result ≠ false then AppleTimeToASDate(the result's lastused)
--------------------------------------------------------------------------------
###HANDLERS
#
#
on KMMacroByName:macro_name inGroup:macro_group_name
	local macro_group_name, macro_name
	
	script macros
		to getAllMacros()
			tell application "Keyboard Maestro Engine" to ¬
				set macrosXML to getmacros with asstring
			
			tell application "System Events" to ¬
				return the value of (make new ¬
					property list item with properties ¬
					{name:"KMmacros", text:macrosXML})
		end getAllMacros
		
		to searchMacros(L, group, |name|)
			local L, group, |name|
			
			if L = {} then return false
			
			script FindMacro
				property R : item 1 of L
				property Ln : rest of L
				property m : text in [group, |name|]
				property |?| : R's |name| = m's item 1
			end script
			
			tell FindMacro
				if its |?| = true then
					if the rest of its m = {} then ¬
						return its R
					set [L] to its R's lists
					searchMacros(L, null, |name|)
				else
					searchMacros(its Ln, group, |name|)
				end if
			end tell
		end searchMacros
	end script
	
	tell macros to ¬
		searchMacros(getAllMacros() ¬
			, macro_group_name ¬
			, macro_name)
end KMMacroByName:inGroup:


on AppleTimeToASDate(t as number)
	local t
	
	tell (the current date) to set ¬
		[ASdate, year, its month, day, time] to ¬
		[it, 2001, January, 1, 0]
	
	ASdate + t
end AppleTimeToASDate
---------------------------------------------------------------------------❮END❯