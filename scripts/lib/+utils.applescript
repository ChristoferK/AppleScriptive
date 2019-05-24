#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: +UTILS
# nmxt: .applescript
# pDSC: System information, interface and utility handlers
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-11-17
# asmo: 2019-05-23
--------------------------------------------------------------------------------
property name : "utils"
property id : "chri.sk.applescript.lib:utils"
property version : 1.5
property parent: AppleScript
--------------------------------------------------------------------------------
use framework "Automator"
use framework "CoreWLAN"
use framework "Foundation"
use framework "JavaScriptCore"
use scripting additions

property parent : script "load.scpt"
property this : a reference to current application
property nil : a reference to missing value
property _1 : a reference to reference

property AMWorkflow : a reference to AMWorkflow of this
property CWWiFiClient : a reference to CWWiFiClient of this
property JSContext : a reference to JSContext of this
property NSArray : a reference to NSArray of this
property NSBundle : a reference to NSBundle of this
property NSDictionary : a reference to NSDictionary of this
property NSPredicate : a reference to NSPredicate of this
property NSString : a reference to NSString of this
property NSURL : a reference to NSURL of this
property NSWorkspace : a reference to NSWorkspace of this

property interface : a reference to CWWiFiClient's sharedWiFiClient's interface
property Workspace : a reference to NSWorkspace's sharedWorkspace

property UTF8 : a reference to 4
property WEP104 : a reference to 2

property WiFiChannels : {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 36, 40, 44, 48}
--------------------------------------------------------------------------------
# HANDLERS & SCRIPT OBJECTS:
# WiFiOn:
#   If +state is a boolean value, then this handler sets the power state of the
#   WiFi interface accordingly: true/yes -> On, false/no -> Off.  Otherwise,
#   the handler retrieves the current power state of the interface.
on WiFiOn:state
	tell the interface()
		if state is not in [true, false, yes, no] ¬
			then return its powerOn() as boolean
		
		its setPower:state |error|:nil
	end tell
	
	WiFiOn_(null)
end WiFiOn:

# WiFiStrengths()
#   Returns a records containing the signal strengths of nearby WiFi networks
#   labelled according to their SSIDs
on WiFiStrengths()
	tell the interface()
		if not (its powerOn() as boolean) then return false
		
		its scanForNetworksWithName:nil |error|:nil
		set networks to the result's allObjects()
	end tell
	set SSIDs to networks's valueForKey:"ssid"
	set RSSIValues to networks's valueForKey:"rssiValue"
	
	NSDictionary's dictionaryWithObjects:RSSIValues forKeys:SSIDs
	result as record
end WiFiStrengths

# joinNetwork
#   Turns on the WiFi interface and attempts to search for visible networks
#   with the specified +ssid, joining the first one that matches
to joinNetwork given name:ssid as text, password:pw as text : missing value
	local ssid, pw
	
	set predicate to "self.ssid == %@"
	set |?| to NSPredicate's predicateWithFormat_(predicate, ssid)
	
	tell the interface()
		its setPower:true |error|:nil
		
		set networks to {}
		tell cachedScanResults() to if it ≠ missing value then ¬
			set networks to filteredSetUsingPredicate_(|?|)
		
		if the number of networks = 0 then set networks to ¬
			(its scanForNetworksWithName:ssid |error|:nil)
		
		set network to (allObjects() in networks)'s firstObject()
		its associateToNetwork:network |password|:pw |error|:_1
		set [success, E] to the result
		if E ≠ missing value then return ¬
			E's localizedDescription() ¬
			as text
		success
	end tell
end joinNetwork

# createAdHocNetwork:
#   creates and joins an ad-hoc local Wi-Fi network using the supplied +ssid,
#   and password (+pw), broadcasting on the specified +channel
to createAdHocNetwork:{name:ssid as text ¬
	, password:pw as text ¬
	, channel:channel as integer}
	local ssid, pw, channel
	
	if channel is not in WiFiChannels then set ¬
		channel to some item of WiFiChannels
	
	interface()'s startIBSSModeWithSSID:((NSString's ¬
		stringWithString:ssid)'s ¬
		dataUsingEncoding:UTF8) ¬
		security:WEP104 channel:channel ¬
		|password|:pw |error|:_1
	set [success, E] to the result
	if E ≠ missing value then return E's localizedDescription() as text
	
	success
end createAdHocNetwork:

# publicIP() [ syn. externalIP() ]
#   Retrieves the public IPv4 address of your router assigned by the ISP
on publicIP()
	(NSString's stringWithContentsOfURL:(NSURL's ¬
		URLWithString:"https://api.ipify.org/") ¬
		encoding:UTF8 |error|:nil) as text
end publicIP
on externalIP()
	publicIP()
end externalIP

# battery()
#   Battery information
on battery()
	script battery
		use framework "IOKit"
		property parent : this
		
		on info()
			IOPSCopyPowerSourcesInfo() of this
			result as record
		end info
	end script
	
	battery's info()
end battery

# defaultBrowser()
#   Returns the name of the system's default web browser
on defaultBrowser()
	(NSWorkspace's sharedWorkspace()'s ¬
		URLForApplicationToOpenURL:(NSURL's URLWithString:"http:"))'s ¬
		lastPathComponent()'s stringByDeletingPathExtension() as text
end defaultBrowser

# colour [ syn. colorAt() ]
#   Returns the RGBA colour value of the pixel at coordinates {+x, +y}.
#   Pass either ordinate as null to use the mouse cursor location.  RGB
#   values' ranges are all 0-255; the alpha value range is 0.0-1.0.
on colour at {x, y}
	local x, y
	
	if {x, y} contains null then set {x, y} to {"mouseLoc.x", "mouseLoc.y"}
	set coords to [x, ",", space, y] as text
	
	run script "
	ObjC.import('Cocoa');
		
	var mouseLoc = $.NSEvent.mouseLocation;
	var screenH = $.NSScreen.mainScreen.frame.size.height;
	mouseLoc.y = screenH - mouseLoc.y;
		
	var image = $.CGDisplayCreateImageForRect(
			$.CGMainDisplayID(),
			$.CGRectMake(" & coords & ", 1, 1)
	            );
					
	var bitmap = $.NSBitmapImageRep.alloc.initWithCGImage(image);
	$.CGImageRelease(image);
		
	var color = bitmap.colorAtXY(0,0);
	bitmap.release;
		
	var r = Ref(), g = Ref(), b = Ref(), a = Ref();
	color.getRedGreenBlueAlpha(r,g,b,a);
		
	var rgba = [r[0]*255, g[0]*255, b[0]*255, a[0]];
	rgba;" in "JavaScript"
end colour
on colorAt(x, y)
	colour at {x, y}
end colorAt

# mouse
#   Moves the mouse cursor to a new position specified by {+x, +y}, relative to
#   the top-left corner of the screen
on mouse to {x, y}
	local x, y
	
	run script "
	ObjC.import('CoreGraphics');

	$.CGDisplayMoveCursorToPoint(
		$.CGMainDisplayID(), 
		{x:" & x & ", y:" & y & "}
	);" in "JavaScript"
end mouse

# click [ syn. clickAt() ]
#   Issues a mouse click at coordinates {+x, +y}, or at the current mouse 
#   cursor location if either ordinate is passed null
to click at {x, y}
	local x, y
	
	if {x, y} contains null then set {x, y} to {"mouseLoc.x", "mouseLoc.y"}
	
	run script "
	ObjC.import('Cocoa');
	nil=$();
		
	var mouseLoc = $.NSEvent.mouseLocation;
	var screenH = $.NSScreen.mainScreen.frame.size.height;
	mouseLoc.y = screenH - mouseLoc.y;
		
	var coords = {x: " & x & ", y: " & y & "};
		
	var mousedownevent = $.CGEventCreateMouseEvent(nil, 
	                     		$.kCGEventLeftMouseDown,
	                     		coords,
	                     		nil);
							       
	var mouseupevent = $.CGEventCreateMouseEvent(nil, 
	                   		$.kCGEventLeftMouseUp,
	                   		coords,
	                   		nil);
							     
	$.CGEventPost($.kCGHIDEventTap, mousedownevent);
	$.CGEventPost($.kCGHIDEventTap, mouseupevent);
	$.CFRelease(mousedownevent);
	$.CFRelease(mouseupevent);" in "JavaScript"
end click
to clickAt(x, y)
	click at {x, y}
end clickAt

# scrollY()
#   Issues a mousewheel vertical scrolling event with velocity +dx
to scrollY(dx)
	local dx
	
	run script "ObjC.import('CoreGraphics');
	nil=$();

	event = $.CGEventCreateScrollWheelEvent(
                        nil, 
                        $.kCGScrollEventUnitLine,
                        1,
                        " & dx & "
                );
	$.CGEventPost($.kCGHIDEventTap, event);
	$.CFRelease(event)" in "JavaScript"
end scrollY

# sendKeyCode [ see: press: ]
#   Sends a keyboard event to an application, +A, specified by name (or as an
#   application reference).  Boolean options are available to simulate key
#   modifier buttons, but these currently don't work due to a bug in the
#   API.
to sendKeyCode at key to A as text given shift:shift as boolean : false ¬
	, command:cmd as boolean : false, option:alt as boolean : false
	local key, A, shift, cmd, alt
	
	shiftkey(shift)
	cmdKey(cmd)
	altKey(alt)
	
	run script "
	ObjC.import('Cocoa');
	nil=$();
		
	var app = '" & A & "';
	var bundleID = Application(app).id();
	var pid = ObjC.unwrap($.NSRunningApplication
	                       .runningApplicationsWithBundleIdentifier(
	                                bundleID))[0].processIdentifier;
		
	var keydownevent = $.CGEventCreateKeyboardEvent(nil," & key & ",true);
	var keyupevent = $.CGEventCreateKeyboardEvent(nil," & key & ",false);
	
	$.CGEventPostToPid(pid, keydownevent);
	$.CGEventPostToPid(pid, keyupevent);
			
	$.CFRelease(keydownevent);
	$.CFRelease(keyupevent);" in "JavaScript"
	
	shiftkey(up)
	cmdKey(up)
	altKey(up)
end sendKeyCode

# sendChar / sendChars
#   Similar to sendKeyCode but receives text instead of a keycode
to sendChar to (A as text) given character:char as text ¬
	, shift:shift as boolean : false, command:cmd as boolean : false ¬
	, option:alt as boolean : false
	local char, A, shift, cmd, alt
	
	set uchar to (NSString's stringWithString:char)'s uppercaseString()
	read (path to "KEYCODES") as «class utf8» using delimiter linefeed
	set code to (NSArray's arrayWithArray:result)'s indexOfObject:uchar
	
	considering case
		set shift to char = (uchar as text)
	end considering
	
	sendKeyCode at code to A given shift:shift, command:cmd, option:alt
end sendChar
to sendChars to A as text given string:chars as text ¬
	, shift:shift as boolean : false, command:cmd as boolean : false ¬
	, option:alt as boolean : false
	local char, A, shift, cmd, alt
	
	repeat with char in characters of chars
		sendChar to A given character:char ¬
			, shift:shift, command:cmd ¬
			, option:alt
	end repeat
end sendChars

# setModifier:toState:
#   Set the state of a modifier key
to setModifier:(modifier as constant) toState:(state as text)
	tell application "System Events"
		if state is in ["down", "true", "yes"] ¬
			then return (key down modifier)
		key up modifier
	end tell
end setModifier:toState:

using terms from application "System Events"
	# shiftKey()
	#   Declare the state of the shift key
	on shiftkey(state as {text, boolean, constant})
		my setModifier:shift toState:state
	end shiftkey
	
	# cmdKey()
	#   Declare the state of the command key
	on cmdKey(state as {text, boolean, constant})
		my setModifier:command toState:state
	end cmdKey
	
	# altKey()
	#   Declare the state of the option key
	on altKey(state as {text, boolean, constant})
		my setModifier:option toState:state
	end altKey
	
	# ctrlKey()
	#   Declare the state of the control key
	on ctrlKey(state as {text, boolean, constant})
		my setModifier:control toState:state
	end ctrlKey
end using terms from

# define() [ syn. synonyms ]
#   Look up a word in the system's default dictionary or thesaurus
to define(w as text)
	local w
	
	run script "ObjC.import('CoreServices');
	nil = $();
	var word = '" & w & "';
	ObjC.unwrap(
		$.DCSCopyTextDefinition(
			nil, 
			word, 
			$.NSMakeRange(0, word.length)
		));" in "JavaScript"
end define
on synonyms for w
	define(w)
end synonyms

# listFrameworks()
#   Returns a list of all the frameworks containing Objective-C classes
to listFrameworks()
	set allFrameworks to NSBundle's allFrameworks()'s bundlePath's ¬
		lastPathComponent's stringByDeletingPathExtension's ¬
		sortedArrayUsingSelector:"caseInsensitiveCompare:"
	
	set fp to path to [my rootdir, "Data", "/", "FRAMEWORKS"]
	
	(allFrameworks's componentsJoinedByString:linefeed) as text
	write the result to fp as «class utf8»
end listFrameworks
---------------------------------------------------------------------------❮END❯