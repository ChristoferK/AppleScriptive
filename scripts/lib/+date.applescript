#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: +DATE
# nmxt: .applescript
# pDSC: Date and time handlers
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-09-06
# asmo: 2019-05-10
--------------------------------------------------------------------------------
property name : "date"
property id : "chrisk.applescript.lib:date"
property version : 1.0
property parent: AppleScript
--------------------------------------------------------------------------------
property UnixEpoch : {year:1970, month:January, day:1}
property AppleEpoch : {year:2001, month:January, day:1}
--------------------------------------------------------------------------------
# HANDLERS & SCRIPT OBJECTS:

# make
#   Creates an AppleScript date object set to a date and time specified by the
#   supplied values.  Year (+y), month (+m), and day (+d) are required values, 
#   whereas the time components are optional, and default to midnight.
to make at {year:y, month:m, day:d} ¬
	given time:{hours:h, minutes:mm, seconds:s} ¬
	: {hours:0, minutes:0, seconds:0}
	local y, m, d, h, mm, s
	
	tell (the current date) to set ¬
		[ASdate, year, day, its month, day, time] to ¬
		[it, y, 1, m, d, h * hours + mm * minutes + s]
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

# unixtime()
#   The number of seconds transpired since 1970-01-01
on unixtime()
	((current date) - (make at UnixEpoch)) as yards as text
end unixtime

# appletime()
#   The number of seconds transpired since 2001-01-01
on appletime()
	((current date) - (make at AppleEpoch)) as yards as text
end appletime

# unixtimeToDate()
#   Converts Unix time to an AppleScript date object
on unixtimeToDate(t as number)
	local t
	
	(make at UnixEpoch) + t
end unixtimeToDate

# appletimeToDate()
#   Converts Cocoa time to an AppleScript date object
on appletimeToDate(t as number)
	local t
	
	(make at AppleEpoch) + t
end appletimeToDate

# timer::
#   A timer script object to monitor durations of elapsed time between different
#   points in a script's execution
script timer
	to make at initialTime : 0
		script timer
			property now : initialTime
			property duration : missing value
			property running : false
			property reference : a reference to my [start ¬
				, pause, reset]
			
			on t()
				the (current date)'s time
			end t
			
			to start()
				if running then return false
				set now to now + t()
				set running to true
			end start
			
			to pause()
				if not running then return
				set duration to t() - now
				set now to 0
				set running to false
			end pause
			
			to reset()
				set now to the initialTime
				set duration to missing value
				set running to false
			end reset
			
			to run
				start()
			end run
			
			to idle
				pause()
			end idle
		end script
	end make
end script
--------------------------------------------------------------------------------
# APPLESCRIPT-OBJC HANDLERS:
use framework "Foundation"

property this : a reference to current application
property NSDate : a reference to NSDate of this

# microtime()
#   Unix time in microseconds
on microtime()
	NSDate's |date|()'s timeIntervalSince1970()
	result * 1000000 as yards as text
end microtime
---------------------------------------------------------------------------❮END❯