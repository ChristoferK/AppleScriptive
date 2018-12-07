#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: _SYSTEM
# nmxt: .applescript
# pDSC: System information handlers
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-11-17
# asmo: 2018-12-07
--------------------------------------------------------------------------------
property name : "_system"
property id : "chri.sk.applescript._system"
property version : 1.0
property _system : me
--------------------------------------------------------------------------------
property sys : application "System Events"
property Finder : application "Finder"
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

# ApplicationsFor:
#   Lists the applications registered on the system to open files of the
#   specified uniform type identifier
on ApplicationsFor:(UTI as text)
	local UTI
	
	run script "ObjC.import('CoreServices');

		const contentType = " & quoted form of UTI & "
		ObjC.deepUnwrap(
      	  		$.LSCopyAllRoleHandlersForContentType(
                 		contentType,
                 		$.kLSRolesAll
          		)
		).map(x=>Application(x).name())" in "JavaScript"
end ApplicationsFor:

# colour, |color|
#   Returns the RGBA colour value of the pixel at coordinates given by +pixel.
#   Any invalid coordinate reference defaults to the mouse location.  RGB 
#   values ranges are all 0-255; the alpha value range is 0.0-1.0.
on colour at {x, y} : {null, null}
	local x, y
	
	if {x, y} contains null then set {x, y} to {"mouseLoc.x", "mouseLoc.y"}
	set coords to [x, ",", space, y] as text
	
	run script "ObjC.import('Cocoa');
		
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
	
	run script "ObjC.import('CoreGraphics');

		$.CGDisplayMoveCursorToPoint(
			$.CGMainDisplayID(), 
			{x:" & x & ", y:" & y & "}
		);" in "JavaScript"
end mouse

to click at {x, y} : {null, null}
	local x, y
	
	if {x, y} contains null then set {x, y} to {"mouseLoc.x", "mouseLoc.y"}
	
	run script "ObjC.import('Cocoa');
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
---------------------------------------------------------------------------❮END❯