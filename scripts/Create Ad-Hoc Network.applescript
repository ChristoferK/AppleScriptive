#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: CREATE AD-HOC NETWORK
# nmxt: .applescript
# pDSC: (Description)

# plst: +settings* : {SSID:«text», password:«text», channel:«long»}

# rslt: «bool» : Indicates successful creation of ad-hoc network
#       «text» : Error message in the event of failure
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2019-02-14
# asmo: 2019-02-14
# vers: 1.0
--------------------------------------------------------------------------------
use framework "Foundation"
use framework "CoreWLAN"

property this : a reference to current application
property CWWiFiClient : a reference to CWWiFiClient of this
property NSString : a reference to NSString of this

property NSUTF8StringEncoding : a reference to 4
property kCWIBSSModeSecurityWEP104 : a reference to 2
--------------------------------------------------------------------------------
property channels : {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 36, 40, 44, 48}

# USER-DEFINED PROPERTIES
property SSID : "My Network Name"
property pw : "mypassword"
property channel : missing value -- set to a specific channel (optional)
--------------------------------------------------------------------------------
# IMPLEMENTATION:
on run settings
	if class of settings = script or settings = {} then set ¬
		settings to {SSID:SSID, password:pw, channel:channel}
	
	set [SSID, pw, channel] to [SSID, password, channel] of settings
	set ch to channel
	if ch is not in channels then set ch to some item of channels
	
	set defaultInterface to CWWiFiClient's sharedWiFiClient()'s interface()
	
	defaultInterface's startIBSSModeWithSSID:((NSString's ¬
		stringWithString:SSID)'s ¬
		dataUsingEncoding:NSUTF8StringEncoding) ¬
		security:kCWIBSSModeSecurityWEP104 channel:ch password:pw ¬
		|error|:(reference)
	set [success, E] to the result
	if E ≠ missing value then return E's localizedDescription() as text
	success
end run
---------------------------------------------------------------------------❮END❯