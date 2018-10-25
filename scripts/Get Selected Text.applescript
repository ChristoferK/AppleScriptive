#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: GET SELECTED TEXT
# nmxt: applescript
# pDSC: Returns the contents of the current text selection.  Does not work for
#	all applications, most notably web browsers.

# plst: -			

# rslt: ÇctxtÈ : The text selection content
#	ÇnullÈ : No selected text found
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-03-29
# asmo: 2018-10-25
--------------------------------------------------------------------------------
use sys : application "System Events"
--------------------------------------------------------------------------------
property process : a reference to (first process whose frontmost = true)
property window : a reference to window 1 of my process
property UI element : a reference to UI elements of my process
--------------------------------------------------------------------------------
# IMPLEMENTATION:
set AX to filteredAttributes for my UI element
if AX contains text then return the text in AX

recurse thru a reference to the UI elements of my window
--------------------------------------------------------------------------------
# HANDLERS:
to recurse thru UIElements
	local UIElements
	
	if not (UIElements exists) then return null
	
	tell the (filteredAttributes for UIElements) to Â
		if it contains text then return its text
	
	recurse thru a reference to UI elements of UIElements
end recurse

on filteredAttributes for UIElements
	local UIElements
	
	tell (a reference to (UIElements whose Â
		name of attributes contains "AXSelectedText" and Â
		value of attribute "AXSelectedText" ­ "" and Â
		class of value of attribute "AXSelectedText" ­ class)) Â
		to if (count) ­ 0 then return {the value of Â
		attribute "AXSelectedText" of Â
		item 1 of its contents, text}
	
	null
end filteredAttributes
--------------------------------------------------------------------------:END #