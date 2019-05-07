#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: [CLASS]
# nmxt: .applescript
# pDSC: Class manipulation handlers
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-12-10
# asmo: 2019-05-07
--------------------------------------------------------------------------------
property name : "[class]"
property id : "chri.sk.applescript:class"
property version : 1.0
--------------------------------------------------------------------------------
use framework "Foundation"
use scripting additions

property this : a reference to current application
property parent : this
property nil : a reference to missing value
property _1 : a reference to reference

property NSArray : a reference to NSArray of this
property NSDictionary : a reference to NSDictionary of this
property NSObject : a reference to NSObject of this
property NSString : a reference to NSString of this
property NSClassDescription : a reference to NSClassDescription of this
property NSURL : a reference to NSURL of this

property alias : a reference to NSURL
property file : a reference to NSURL
property anything : a reference to NSObject
property list : a reference to NSArray
property record : a reference to NSDictionary
property string : a reference to NSString
property text : a reference to NSString
--------------------------------------------------------------------------------
# HANDLERS & SCRIPT OBJECTS:
to __NSString__(str)
	(NSString's stringWithString:str)'s Â
		stringByStandardizingPath()
end __NSString__

to __NSURL__(|URL|)
	if the |URL|'s first character Â
		is in ["/", "~", "."] Â
		then return NSURL's Â
		fileURLWithPath:__NSString__(|URL|)
	
	NSURL's URLWithString:|URL|
end __NSURL__

to __NSArray__(obj)
	try
		NSArray's arrayWithArray:obj
	on error
		NSArray's arrayWithObject:obj
	end try
end __NSArray__

to __any__(obj)
	(__NSArray__([obj]) as list)'s item 1
end __any__

on domain for object
	local object
	
	if the class of the object's class = class Â
		then return AppleScript
	
	try
		object's isKindOfClass:NSObject
		return this
	end try
	
	nil
end domain

on object(obj)
	script
		property class : class of obj
		property owner : domain for obj
		property data : __any__(obj)
		property description : missing value
	end script
	
	tell the result
		if its owner = current application then
			set its description to the obj's Â
				superclass()'s |description|()
		else
			set its description to its class as text
		end if
	end tell
end object

to make new type with data object
	local type, object
	
	if type's class = class then return Â
		run script "on run {object}
			return object as " & type & "
		end run" with parameters {object}
	
	type's new()
end make

on NSObjectSubclass for nsObj
	local nsObj
	
	if nsObj = NSObject then return "NSObject"
	set chain to {nsObj}
	
	repeat until chain's first item = NSObject's |class|()
		set beginning of chain to chain's Â
			first item's superclass()
	end repeat
	
	NSStringFromClass(item 1 of rest of chain) of this as text
end NSObjectSubclass

on mainClass for nsObj
	local nsObj
	
	set superclass to nsObj's superclass()
	
	
	if [NSObject's |class|(), nil] contains superclass Â
		then return NSStringFromClass(nsObj's |class|()) of this Â
		as text
	
	mainClass for superclass
end mainClass

mainClass for __NSArray__({1, 2, 3, 4})
on kindOf(object)
	local object
	
	if the (domain for the object) = AppleScript then
		tell the object's class to Â
			if class ­ it then Â
				return it
		return the object
	end if
	
	tell (NSStringFromClass(object's |class|()) of this as text) to Â
		if it starts with "_" then
			return NSStringFromClass(NSClassFromString(it)'s Â
				superclass() of this) of this as text
		end if
end kindOf

return kindOf(__NSArray__({1, 2, 3, 4}))
script OSType
	property null : 0
	property type : 1.954115685E+9
	property blah : 1.651269992E+9
	
	property toString : "UTCreateStringForOSType"
	property fromString : "UTGetOSTypeFromString"
	
	to convert(fn, arg)
		local fn, arg
		
		run script "ObjC.import('CoreServices');
		            ObjC.unwrap($." & fn & Â
			"(" & arg's quoted form & Â
			"));" in "JavaScript"
	end convert
	
	to make new OSType as text
		local OSType
		
		set code to convert(fromString, OSType)
		(current application's NSAppleEventDescriptor's Â
			descriptorWithTypeCode:code) as type class
	end make
end script


return NSClassDescription's classDescriptionForClass:(NSArray)

NSArray's arrayWithArray:{1, 2, 3, 4}
current application's NSStringFromClass(class of result)
result as text

|class|(NSArray's arrayWithArray:{1, 2, 3, 4})

[(NSArray's arrayWithArray:{1, 2, 3, 4})] contains specifier