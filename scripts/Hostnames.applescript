#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: HOSTNAMES
# nmxt: .applescript
# pDSC: Lists hostnames of available devices found on the local network

# plst: -

# rslt: ÇlistÈ : List of IP address/hostname pairs
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-09-05
# asmo: 2018-10-25
--------------------------------------------------------------------------------
property text item delimiters : "."
property IPv4 address : a reference to the IPv4 address of my (system info)
--------------------------------------------------------------------------------
# IMPLEMENTATION:
tell the lan()
	repeat with host in (a reference to its hosts)
		set addr to its subnet & the host as text
		try
			with timeout of 2 seconds
				[addr, hostname at addr]
			end timeout
		on error
			null
		end try
		set the host's contents to the result
	end repeat
	
	every list in its hosts
end tell
--------------------------------------------------------------------------------
# HANDLERS & SCRIPT OBJECTS:
on lan()
	script
		use framework "Foundation"
		use scripting additions
		property this : a reference to current application
		property NSHost : a reference to NSHost of this
		----------------------------------------------------------------
		property subnet : text items 1 thru 3 of my IPv4 address
		property hosts : array(254)
		----------------------------------------------------------------
		on hostname at address
			tell (NSHost's hostWithAddress:address)'s |name|() Â
				to if it ­ missing value Â
				then return it as text
		end hostname
	end script
end lan

on array(N as integer)
	local N
	
	script
		property list : {}
		
		on abs(x)
			if x < 0 then set x to -x
			x
		end abs
		
		on sign(x)
			if x = 0 then return 0
			2 * ((x > 0) as integer) - 1
		end sign
	end script
	
	tell the result
		repeat with i from 1 to abs(N)
			set end of its list to i
		end repeat
		
		if sign(N) = -1 then return Â
			reverse of its list
		its list
	end tell
end array
--------------------------------------------------------------------------:END #