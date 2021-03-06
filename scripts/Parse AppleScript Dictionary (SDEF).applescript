#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: PARSE APPLESCRIPT DICTIONARY (SDEF)
# nmxt: .applescript
# pDSC: Parses an .sdef file belonging to a scriptable application whose name
# 	is supplied as +input.

# plst: +input : The name of a scriptable application

# rslt: «list» : A list of AppleScript commands
#           -1 : No .sdef file was found
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-08-04
# asmo: 2019-04-26
--------------------------------------------------------------------------------
use framework "Appkit"

property this : a reference to the current application
property _0 : a reference to missing value
property _1 : a reference to reference

property NSBundle : a reference to NSBundle of this
--------------------------------------------------------------------------------
# IMPLEMENTATION:
on run input
	if the input's class = script or {} = input ¬
		then set input to ["Finder", null]
	set [input, null] to input
	
	set bundle to NSBundle's bundleWithIdentifier:(id of application input)
	set fURL to (bundle's pathForResource:_0 ofType:"sdef") as text
	if fURL = "missing value" then return -1
	
	sdef's {commands:contents of command_names ¬
		, |classes|:{|classes|:contents of class_names ¬
		, elements:contents of class_element_types ¬
		, |properties|:contents of class_property_names}}'s ¬
		commands
	
	flatten(result)
end run
--------------------------------------------------------------------------------
# HANDLERS & SCRIPT OBJECTS:
to flatten(L)
	local L
	
	if L = {} then return {}
	if L's class ≠ list then return {L}
	
	script stuff
		property list : L
	end script
	
	tell list of stuff to set [x, x_] ¬
		to its [first item, rest]
	
	flatten(x) & flatten(x_)
end flatten

script sdef
	use application "System Events"
	
	property file : a reference to XML file named (a reference to fURL)
	property dictionary : a reference to XML element of my file
	property suites : a reference to every XML element in the dictionary
	
	--Suites:
	property suite_nodes : a reference to every XML element of suites
	property commands : a reference to (suite_nodes whose name = "command")
	property |classes| : a reference to (suite_nodes whose name = "class")
	
	--Commands:
	property command_nodes : a reference to XML elements of commands
	property command_names : a reference to value of (XML attributes of ¬
		commands where its name = "name")
	property parameters : a reference to (command_nodes where its name ¬
		ends with "parameter")
	
	--Classes:
	property class_nodes : a reference to XML elements of |classes|
	property class_names : a reference to value of (XML attributes of ¬
		|classes| where its name = "name")
	property class_elements : a reference to (class_nodes where its name ¬
		= "element")
	property class_properties : a reference to (class_nodes where ¬
		the name of it = "property")
	
	--Class Elements:
	property class_element_types : a reference to value of ¬
		(XML attributes of class_elements where its name = "type")
	
	--Class Properties:
	property class_property_names : a reference to value of ¬
		(XML attributes of class_properties where its name = "name")
end script
---------------------------------------------------------------------------❮END❯