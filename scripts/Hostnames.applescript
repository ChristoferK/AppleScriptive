#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: HOSTNAMES
# nmxt: .applescript
# pDSC: Lists hostnames of available devices found on the local network

# plst: -

# rslt: «list» : List of IP address/hostname pairs
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-09-05
# asmo: 2018-11-04
--------------------------------------------------------------------------------
property text item delimiters : "."
property IPv4 address : a reference to the IPv4 address of my (system info)
--------------------------------------------------------------------------------
# IMPLEMENTATION:
on run
	repeat with host in (a reference to the lan's hosts)
		set addr to the lan's subnet & the host as text
		try
			with timeout of 2 seconds
				[addr, hostname of lan at addr]
			end timeout
		on error
			null
		end try
		set the host's contents to the result
	end repeat
	
	every list in the lan's hosts
end run
--------------------------------------------------------------------------------
# HANDLERS & SCRIPT OBJECTS:
on array(N as integer)
	local N
	
	script
		property list : {}
	end script
	
	tell the result
		repeat with i from 1 to N
			set end of its list to i
		end repeat
		
		its list
	end tell
end array


script lan
	use framework "Foundation"
	use scripting additions
	property this : a reference to current application
	property NSHost : a reference to NSHost of this
	------------------------------------------------------------------------
	property subnet : text items 1 thru 3 of my IPv4 address
	property hosts : array(254)
	------------------------------------------------------------------------
	on hostname at address
		tell (NSHost's hostWithAddress:address)'s ¬
			|name|() to if it ≠ missing value ¬
			then return it as text
	end hostname
end script
---------------------------------------------------------------------------❮END❯