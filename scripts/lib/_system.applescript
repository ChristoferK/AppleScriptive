#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: _SYSTEM
# nmxt: .applescript
# pDSC: System information, interface and utility handlers
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-11-17
# asmo: 2018-12-12
--------------------------------------------------------------------------------
property name : "_system"
property id : "chri.sk.applescript._system"
property version : 1.0
property _system : me
--------------------------------------------------------------------------------
use framework "CoreWLAN"
use framework "JavaScriptCore"
use scripting additions

property this : a reference to current application
property CWWiFiClient : a reference to CWWiFiClient of this
property JSContext : a reference to JSContext of this
property NSDictionary : a reference to NSDictionary of this
--------------------------------------------------------------------------------
# HANDLERS & SCRIPT OBJECTS:

# CWInterface()
#   Returns the default shared interface for the WiFi client
on CWInterface()
	CWWiFiClient's sharedWiFiClient()'s interface()
end CWInterface

# WiFiOn:
#   If +state is a boolean value, then this handler sets the power state of the
#   WiFi interface accordingly: true/yes -> On, false/no -> Off.  Otherwise,
#   the handler retrieves the current power state of the interface.
on WiFiOn:state
	if state is not in [true, false, yes, no] then ¬
		return CWInterface()'s powerOn()
	
	CWInterface()'s setPower:state |error|:(missing value)
	WiFiOn(null)
end WiFiOn:

# WiFiStrengths()
#   Returns a records containing the signal strengths of nearby WiFi networks
#   labelled according to their SSIDs
on WiFiStrengths()
	set defaultInterface to CWWiFiClient's sharedWiFiClient()'s interface()
	
	if not (defaultInterface's powerOn()) then return false
	
	set networks to allObjects() of (defaultInterface's ¬
		scanForNetworksWithName:(missing value) ¬
			|error|:(missing value))
	
	set SSIDs to networks's valueForKey:"ssid"
	set RSSIValues to networks's valueForKey:"rssiValue"
	
	NSDictionary's dictionaryWithObjects:RSSIValues forKeys:SSIDs
	result as record
end WiFiStrengths

# Openers:
#   Lists the applications registered on the system to open files of the
#   specified uniform type identifier
on Openers:(UTI as text)
	local UTI
	
	run script "
	ObjC.import('CoreServices');

	const contentType = " & quoted form of UTI & "
	ObjC.deepUnwrap(
      	  	$.LSCopyAllRoleHandlersForContentType(
               		contentType,
               		$.kLSRolesAll
          	)
	).map(x=>Application(x).name())" in "JavaScript"
end Openers:

# colour [ syn. colorAt() ]
#   Returns the RGBA colour value of the pixel at coordinates {+x, +y}.
#   Pass either ordinate as null to use the mouse cursor location.  RGB
#   values' ranges are all 0-255; the alpha value range is 0.0-1.0.
on colour at {x, y} : {null, null}
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
#   cursor location if either ordinate is passed null.
to click at {x, y} : {null, null}
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

# sendKeyCode
#   Sends a keyboard event to an application, +A, specified by name (or as an
#   application reference).  Boolean options are available to simulate key
#   modifier buttons, but these currently don't work due to a bug in the
#   API.
to sendKeyCode at key to A as text given shiftkey:shift as boolean : false ¬
	, commandkey:cmd as boolean : false, optionkey:alt as boolean : false
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

# shiftKey()
#   Declare the state of the shift key
on shiftkey(state as boolean)
	
	tell application "System Events" to key up shift
	if state is in [down, true, yes] then tell ¬
		application "System Events" to ¬
		key down shift
end shiftkey

# cmdKey()
#   Declare the state of the command key
on cmdKey(state as boolean)
	tell application "System Events" to key up command
	if state is in [down, true, yes] then tell ¬
		application "System Events" to ¬
		key down command
end cmdKey

# altKey()
#   Declare the state of the option key
on altKey(state as boolean)
	tell application "System Events" to key up option
	if state is in [down, true, yes] then tell ¬
		application "System Events" to ¬
		key down option
end altKey

# ctrlKey()
#   Declare the state of the control key
on ctrlKey(state as boolean)
	tell application "System Events" to key up control
	if state is in [down, true, yes] then tell ¬
		application "System Events" to ¬
		key down control
end ctrlKey
---------------------------------------------------------------------------❮END❯