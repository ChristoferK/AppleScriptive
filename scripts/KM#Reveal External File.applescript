#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: KM#REVEAL EXTERNAL FILE
# nmxt: .applescript
# pDSC: Reveals the external script file for the selected Keyboard Maestro 
#       action

# plst: -

# rslt: «bool» : true  = Script file revealed in Finder
#              : false = Keyboard Maestro isn't in focus
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-03-02
# asmo: 2019-06-02
# vers: 2.0
--------------------------------------------------------------------------------
use KM : application "Keyboard Maestro"
use KME : application "Keyboard Maestro Engine"

property missing value : {|path|:"", PlugInParameters:{|script file|:""}}
--------------------------------------------------------------------------------
# IMPLEMENTATION:
if KM is not frontmost then return false

script
	property sys : application "System Events"
	------------------------------------------------------------------------
	property selection : KM's selection
	property action : item 1 of my selection
	property xml : my action's xml
	property record : plist(xml) & my missing value
	property |.scriptfile| : |script file| of my record's PlugInParameters
	property |.path| : my record's |path|
	property path : process tokens |.scriptfile| & |.path|
	property file : path of sys's file path
end script

tell application "Finder"
	reveal the result's file
	activate
end tell

true
--------------------------------------------------------------------------------
# APPLESCRIPT-OBJC HANDLERS:
use framework "Foundation"

property this : a reference to the current application
property nil : a reference to missing value

property NSArray : a reference to NSArray of this
property NSPlist : a reference to NSPropertyListSerialization of this
property NSString : a reference to NSString of this

property UTF8 : a reference to 4
--------------------------------------------------------------------------------
to plist(str as text)
	((NSArray's arrayWithObject:(NSPlist's ¬
		propertyListWithData:((NSString's ¬
			stringWithString:str)'s ¬
			dataUsingEncoding:UTF8) ¬
			options:0 format:nil ¬
			|error|:nil)) as list)'s item 1
end plist
---------------------------------------------------------------------------❮END❯