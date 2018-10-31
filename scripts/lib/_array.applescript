#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: LISTS
# nmxt: .applescript
# pDSC: List manipulation handlers
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-08-23
# asmo: 2018-10-30
--------------------------------------------------------------------------------
property name : "_array"
property id : "chrisk.applescript._array"
property version : 1.0
property _array : me
property parent : AppleScript
--------------------------------------------------------------------------------
# HANDLERS & SCRIPT OBJECTS:

set L to make 1000
foldItems from L at 0 given handler:add


on add(a, b)
	a + b
end add

on multiply(a, b)
	a * b
end multiply

on double(x)
	2 * x
end double

on even(x)
	x mod 2 = 0
end even


to make N
	script
		property list : {}
	end script
	
	tell the result
		repeat with i from 1 to N
			set end of its list to i
		end repeat
		
		its list
	end tell
end make


on __(function)
	if the function's class = script ¬
		then return the function
	
	script
		property fn : function
	end script
end __


to iterate over L
	local L
	
	script
		property array : L
		
		on nextItem()
			if done() then return
			set [x, array] to [item 1, rest] of array
			
			x
		end nextItem
		
		on done()
			array = {}
		end done
	end script
end iterate


to flatten(L)
	local L
	
	if L = {} then return {}
	if L's class ≠ list then return {L}
	
	script
		property list : L
	end script
	
	tell the result to set [x, x_] to ¬
		[item 1, rest] of its list
	
	flatten(x) & flatten(x_)
end flatten


to mapItems from L as list given handler:function
	local L, function
	
	repeat with x in (a reference to my L)
		tell __(function) to set ¬
			x's contents to fn(x)
	end repeat
	
	L
end mapItems


to filterItems from L as list into R as list : null ¬
	given handler:function
	local L, R
	
	if R = null then set R to {}
	
	script results
		property list : R
	end script
	
	repeat with x in my L
		tell __(function) to if fn(x) ¬
			then copy x's contents to ¬
			end of list of results
	end repeat
	
	R
end filterItems


to foldItems from L as list at |ξ| : 0 given handler:function
	local L, |ξ|, function
	
	(* RECURSIVE METHOD:
	script
		on foldR(|ξ|)
			local |ξ|
			
			if my L = {} then return |ξ|
			
			set [x, my L] to [item 1, rest] of my L
			set y to foldR(|ξ|)
			tell __(function) to set |ξ| to fn(x, y)
			
			|ξ|
		end foldR
	end script
	
	result's foldR(|ξ|)
	*)
	
	repeat with x in my L
		tell __(function) to set |ξ| to fn(x, |ξ|)
	end repeat
end foldItems


to putItems into L as list at i as integer : 0 given list:x_ as list : {}
	local L, i, x_
	
	script
		property list : L
		property y : x_
		property N : L's length
		property index : (i + N + 1) mod (N + 1)
	end script
	
	tell the result
		set i to its index
		if i = 0 then set i to (its N) + 1
		repeat with x in its y
			if i ≤ its N then
				set its list's item i to x's contents
			else
				set end of its list to x's contents
			end if
			
			set i to i + 1
		end repeat
	end tell
	
	L
end putItems


to pushItems onto L as list at i as integer : 0 given list:x_ as list : {}
	local L, i, x_
	
	script
		property list : L
		property y : x_
		property N : L's length
		property index : (i + N + 1) mod (N + 1)
	end script
	
	tell the result
		set i to its index
		if i = 0 then
			set its list to its list & its y
		else if i = 1 then
			set its list to its y & its list
		else
			set its list to ¬
				(its list's items 1 thru (i - 1)) & ¬
				(its y) & ¬
				(its list's items i thru -1)
			
			its list
		end if
	end tell
end pushItems
---------------------------------------------------------------------------❮END❯