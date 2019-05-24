#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: +CLASS
# nmxt: .applescript
# pDSC: Class manipulation and introspection handlers
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-12-10
# asmo: 2019-05-17
--------------------------------------------------------------------------------
property name : "class"
property id : "chri.sk.applescript.lib:class"
property version : 1.0
property parent: AppleScript
--------------------------------------------------------------------------------
use framework "Foundation"
use scripting additions

property this : a reference to current application
property nil : a reference to missing value
property _1 : a reference to reference

property NSArray : a reference to NSArray of this
property NSDictionary : a reference to NSDictionary of this
property NSExpression : a reference to NSExpression of this
property NSNumber : a reference to NSNumber of this
property NSObject : a reference to NSObject of this
property NSSet : a reference to NSSet of this
property NSString : a reference to NSString of this
property NSURL : a reference to NSURL of this
property NSAEDescriptor : a reference to NSAppleEventDescriptor of this
property NSCoercion : a reference to NSScriptCoercionHandler of this

property instanceMethods : {NSArray:¬
	"arrayWithArray:", NSString:¬
	"stringWithString:", NSDictionary:¬
	"dictionaryWithDictionary:", NSURL:¬
	"fileURLWithPath:", NSObject:¬
	"new", NSSet:"setWithArray:"}

property toString : "UTCreateStringForOSType"
property fromString : "UTGetOSTypeFromString"
--------------------------------------------------------------------------------
# HANDLERS & SCRIPT OBJECTS:

to __NSString__(str)
	(NSString's stringWithString:str)'s ¬
		stringByStandardizingPath()
end __NSString__

to __NSURL__(|URL|)
	if the |URL|'s first character ¬
		is in ["/", "~", "."] ¬
		then return NSURL's ¬
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

to __NSSet__(obj)
	NSSet's setWithArray:__NSArray__(obj)
end __NSSet__

to __any__(obj)
	(__NSArray__([obj]) as list)'s item 1
end __any__

to __NSClass__(obj)
	NSCoercion's sharedCoercionHandler()'s coerceValue:obj toClass:nil
	mainClass for result
end __NSClass__

on domain for object
	local object
	
	if class of object's class = class ¬
		then return AppleScript
	
	this
end domain

to make new _class with data object
	local _class, object
	
	if (domain for _class) = AppleScript then ¬
		return run script "on run {object}
		return the object as " & _class & "
		end run" with parameters {object}
	
	set className to NSStringFromClass(_class) of this
	NSDictionary's dictionaryWithDictionary:instanceMethods
	set method to (result's objectForKey:className) as text
	
	tell NSExpression
		set arg to expressionForConstantValue_(object)
		set target to expressionForConstantValue_(_class)
		(its expressionForFunction:target ¬
			selectorName:method arguments:[arg])'s ¬
			expressionValueWithObject:nil context:nil
	end tell
end make

on classOf(object)
	local object
	
	if (domain for object) = AppleScript ¬
		then return the object's class
	
	NSStringFromClass(object's class) of this as text
end classOf

on mainClass for object
	local object
	
	if (domain for object) = AppleScript ¬
		then return the object's class
	
	set super to the object's superclass()
	if super = missing value then return "NSObject"
	if "NSObject" = classOf(super) then return classOf(object)
	mainClass for super
end mainClass

on OSType(fn, arg as text)
	local fn, arg
	
	run script "ObjC.import('CoreServices');
	            ObjC.unwrap($." & fn & ¬
		"(" & arg's quoted form & ¬
		"));" in "JavaScript"
end OSType
---------------------------------------------------------------------------❮END❯