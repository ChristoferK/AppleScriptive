#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: PARSE APPLESCRIPT DICTIONARY (SDEF)
# nmxt: applescript
# pDSC: Parses an .sdef file belonging to a scriptable application whose name
# 	is supplied as input.  A record of AppleScript terminologies for the 
#	application is retrieved, including commands, classes, properties and 
#	elements.

# plst: ％input％ : The name of a scriptable application

# rslt: «list» : A list of AppleScript commands
#	-1     : No .sdef file was found
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-08-04
# asmo: 2018-10-09
--------------------------------------------------------------------------------
property furl : missing value
--------------------------------------------------------------------------------
--IMPLEMENTATION:
on run input
	if input's class = script then set input to ["Finder"]
	set [input] to input
	
	set [furl] to (the path to resource in bundle input) & {null}
	if furl = null then return {-1}
	
	scripting_definition's {commands:contents of command_names ¬
		, |classes|:{|classes|:contents of class_names ¬
		, elements:contents of class_element_types ¬
		, |properties|:contents of class_property_names}}'s ¬
		commands
	
	flatten(result)
end run
--------------------------------------------------------------------------------
--HANDLERS & SCRIPT OBJECTS:
to flatten(L)
	local L
	
	if L = {} then return {}
	if L's class ≠ list then return {L}
	
	script
		property array : L
	end script
	
	tell the result's array to set [x, xN] ¬
		to [first item, rest] of it
	
	flatten(x) & flatten(xN)
end flatten

# hand: PATH TO RESOURCE
# plst: ％A％ : The name of an application
# pDSC: Retrieves file references to any scripting definition files located
#	in the subtree of the application's "Resources" directory.
on path to resource in bundle A
	local A
	
	script appbundle
		property sys : application "System Events"
		property appf : the path to the application named A
		property location : [appf, "Contents:Resources"] as text
		
		script directory
			use framework "Foundation"
			
			property this : a reference to the current application
			property SkipHiddenFiles : a reference to 4
			property NSString : a reference to NSString of this
			property NSURL : a reference to NSURL of this
			--------------------------------------------------------
			property pfmt : "pathExtension IN[c] %@"
			--------------------------------------------------------
			to filterContents at fp by nmxt
				local fp, nmxt
				
				NSURL's URLWithString:((NSString's ¬
					stringWithString:fp)'s ¬
					stringByStandardizingPath())
				set fp to the result
				
				set Predicate to ¬
					(NSPredicate of this)'s ¬
					predicateWithFormat:pfmt ¬
						argumentArray:[nmxt]
				
				set FileManager to the defaultManager() of ¬
					NSFileManager of this
				FileManager's enumeratorAtURL:fp ¬
					includingPropertiesForKeys:{} ¬
					options:SkipHiddenFiles ¬
					errorHandler:(missing value)
				
				filteredArrayUsingPredicate_(Predicate) of ¬
					allObjects() of the result as list
			end filterContents
		end script
	end script
	
	filterContents of (directory in the appbundle) ¬
		at (POSIX path of appbundle's location) ¬
		by "SDEF"
end «event sysorpth»


script scripting_definition
	use application "System Events"
	
	property file : a reference to XML file named (a reference to furl)
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
	property class_element_types : a reference to value of (XML attributes ¬
		of class_elements where its name = "type")
	
	--Class Properties:
	property class_property_names : a reference to value of ¬
		(XML attributes of class_properties where its name = "name")
	
end script
----------------------------------------------------------------------------:END