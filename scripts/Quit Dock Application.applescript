#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: QUIT DOCK APPLICATION
# nmxt: .applescript
# pDSC: When this script is triggered, the application whose dock item is
#	currently underneath the mouse cursor will quit

# plst: -

# rslt: Dock application quits
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-10-10
# asmo: 2018-10-25
--------------------------------------------------------------------------------
use application "System Events"

property Dock : me
property process : application process "Dock"
property list : a reference to list 1 of my process
property item : a reference to (UI element 1 in my list whose selected = true)
--------------------------------------------------------------------------------
# IMPLEMENTATION:
if the Dock's item exists then tell the selectedItem Â
	to if its attribute exists then Â
	if running then quit it
--------------------------------------------------------------------------------
# HANDLERS & SCRIPT OBJECTS:
script selectedItem
	property name : a reference to title of my item
	property AX : "AXIsApplicationRunning"
	property attribute : a reference to attribute AX of my item
	property running : a reference to the value of my attribute
	property application : a reference to the application name
	
	to activate
		activate my application
	end activate
	
	to quit
		quit my application
	end quit
end script
--------------------------------------------------------------------------:END #