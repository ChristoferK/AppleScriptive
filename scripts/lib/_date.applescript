#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: _DATE
# nmxt: .applescript
# pDSC: Date and time handlers
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-09-06
# asmo: 2018-12-06
--------------------------------------------------------------------------------
property name : "_date"
property id : "chrisk.applescript._date"
property version : 1.0
property _date : me
property parent : AppleScript
--------------------------------------------------------------------------------
# HANDLERS & SCRIPT OBJECTS:
# make
#   Creates an AppleScript date object set to a date and time specified by the
#   supplied values.  Year (+y), month (+m), and day (+d) are required values, 
#   whereas the time components are optional, and default to midnight.
to make given year:y, month:m, day:d ¬
	, hours:h : 0, minutes:mm : 0, seconds:s : 0
	local y, m, d, h, mm, s
	
	tell (the current date) to set ¬
		[ASdate, year, its month, day, time] to ¬
		[it, y, m, d, h * hours + mm * minutes + s]
	ASdate
end make

# ISOdate
#   Takes an AppleScript date object and returns a record with the date string
#   and time string formatted similar to IS0-8601 representation.
on ISOdate from ASdate as date
	ASdate as «class isot» as string
	return {date string:text 1 thru 10 ¬
		, time string:text 12 thru 19} of the result
	
	-- Alternative method:
	set [y, m, d, t] to [year, month, day, time string] of ASdate
	return [the contents of [y, ¬
		"-", text -1 thru -2 of ("0" & (m as integer)), ¬
		"-", text -1 thru -2 of ("0" & (d as integer))] ¬
		as text, t]
end ISOdate

# now()
#   Unix time in seconds, i.e. the number of seconds transpired since 1970-01-01
on now()
	make given year:1970, month:January, day:1
	((current date) - result) as yards as string
end now

# AppleTimeToASDate()
#   Converts Cocoa time (the number of seconds since 2001-01-01) to an 
#   AppleScript date object
on AppleTimeToASDate(t as number)
	local t
	
	make given year:2001, month:January, day:1
	result + t
end AppleTimeToASDate

# timer()
#   A timer function that, when called once, initiates timing at the point of 
#   execution in the script, and ceases timing when called a second time, 
#   returning the time elapsed in seconds.
on timer()
	global |!now|
	
	script timer
		property duration : 0
		
		on start()
			copy time of (current date) to |!now|
			0
		end start
		
		on finish()
			set duration to (time of (current date)) - |!now|
			set |!now| to null
		end finish
	end script
	
	try
		|!now|
	on error
		return timer's start()
	end try
	
	if the result = null then return timer's start()
	
	tell timer to finish()
	get timer's duration
end timer

--------------------------------------------------------------------------------
# APPLESCRIPT-OBJC HANDLERS:
use framework "Foundation"
use scripting additions

property this : a reference to current application
property NSDate : a reference to NSDate of this

# microtime()
#   Unix time in microseconds
on microtime()
	NSDate's |date|()'s timeIntervalSince1970()
	result * 1000000 as yards as string
end microtime
---------------------------------------------------------------------------❮END❯