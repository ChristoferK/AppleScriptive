#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: _ARRAYS
# nmxt: .applescript
# pDSC: List manipulation handlers
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-08-23
# asmo: 2018-11-04
--------------------------------------------------------------------------------
property name : "_array"
property id : "chri.sk.applescript._array"
property version : 1.0
property _array : me
property parent : AppleScript
--------------------------------------------------------------------------------
# HANDLERS & SCRIPT OBJECTS:
to make N at x : missing value given pseudorandomness:random as boolean : false
	local N, x, random
	
	script
		property list : {}
	end script
	
	tell the result
		if random then
			repeat with i from 1 to N
				set end of its list to random number to N
			end repeat
		else if x = missing value then
			repeat with i from 1 to N
				set end of its list to i
			end repeat
		else
			repeat N times
				set end of its list to x
			end repeat
		end if
		
		its list
	end tell
end make
on array(N)
	make N
end array


on offset of x in L
	local x, L
	
	if x is not in L then return {}
	
	script
		on found(x)
			script
				on fn(y, |ξ|, i)
					if y = x then set end of |ξ| to i
					|ξ|
				end fn
			end script
		end found
	end script
	
	foldItems from L at {} given handler:result's found(x)
end offset


on __(function)
	if the function's class = script ¬
		then return the function
	
	script
		property fn : function
	end script
end __


to iterate for N from i : 1 given handler:function
	script
		property array : {i}
		property func : __(function)'s fn
		
		on y()
			tell (a reference to my array)
				set its end to its last item
				a reference to its last item
			end tell
		end y
		
		to fn()
			if array's length = N then return the array
			tell y() to set its contents to my func(it)
			fn()
		end fn
	end script
	
	result's fn()
end iterate


to mapItems from L as list given handler:function
	local L, function
	
	script values
		property array : L
	end script
	
	tell (a reference to the array of values) to ¬
		repeat with i from 1 to its length
			set x to (a reference to its item i)
			set x's contents to my __(function)'s fn(x, i, it)
		end repeat
	
	L
end mapItems


to filterItems from L as list into R as list : null given handler:function
	local L, R
	
	if R = null then set R to {}
	
	script values
		property array : L
		property list : R
	end script
	
	repeat with x in the array of values
		if __(function)'s fn(x, array of values, list of values) ¬
			then set end of list of values to x's contents
	end repeat
	
	R
end filterItems


to foldItems from L at |ξ| : 0 given handler:function
	local L, |ξ|, function
	
	script values
		property list : L
	end script
	
	repeat with i from 1 to length of list of values
		set x to item i in the list of values
		set |ξ| to __(function)'s fn(x, |ξ|, i)
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


on difference(A as list, B as list)
	local A, B
	
	script
		on notMember(M)
			script
				on fn(x)
					x is not in M
				end fn
			end script
		end notMember
	end script
	
	filterItems from A given handler:result's notMember(B)
end difference


on intersection(A as list, B as list)
	local A, B
	
	script
		on member(M)
			script
				on fn(x)
					x is in M
				end fn
			end script
		end member
	end script
	
	filterItems from A given handler:result's member(B)
end intersection


on union(A as list, B as list)
	local A, B
	
	script
		on insert(x, L)
			set end of L to x
			L
		end insert
	end script
	
	foldItems from A at B given handler:result's insert
end union


on unique:L
	local L
	
	script
		on unique(x, _, L)
			x is not in L
		end unique
	end script
	
	filterItems from L given handler:result's unique
end unique:


to multiply(x, L)
	local x, L
	
	set unary to L's class ≠ list
	
	script
		to multiplyBy:x
			script
				on fn(y)
					x * y
				end fn
			end script
		end multiplyBy:
	end script
	
	set R to mapItems from L given handler:result's multiplyBy:x
	if unary then set [R] to R
	R
end multiply


to add(x, L)
	local x, L
	
	set unary to L's class ≠ list
	
	script
		to add:x
			script
				on fn(y)
					x + y
				end fn
			end script
		end add:
	end script
	
	set R to mapItems from L given handler:result's add:x
	if unary then set [R] to R
	R
end add


on sum:L
	foldItems from L given handler:add
end sum:


on product:L
	foldItems from L at 1 given handler:multiply
end product:


on max:L
	local L
	
	script
		on maximum(x, y)
			if x ≥ y then return x
			y
		end maximum
	end script
	
	foldItems from L given handler:result's maximum
end max:


on min:L
	local L
	
	script
		on minimum(x, y)
			if x ≤ y then return x
			y
		end minimum
	end script
	
	foldItems from L at L's first item given handler:result's minimum
end min:


on mean:L
	local L
	
	(my sum:L) / (length of L)
end mean:


on swap(L, i, j)
	local L, i, j
	
	set [item i of L, item j of L] to [item j, item i] of L
	L
end swap


to sort:L
	local L, descending
	
	if L = {} then return {}
	if L's length = 1 then return L
	
	script
		property list : L
	end script
	
	tell the result's list to repeat with j from 1 to its length
		set x_ to items j thru -1 of it
		set [i] to my (offset of (my min:x_) in x_)
		my swap(it, i + j - 1, j)
	end repeat
end sort:


to rotate:L
	local L
	
	if length of L < 2 then return L
	set x to item 1 of L
	
	script
		to shift(x, i, L)
			local x, i, L
			
			if i = L's length then return missing value
			item (i + 1) of L
		end shift
	end script
	
	mapItems from L given handler:result's shift
	set last item of L to x
	L
end rotate:


on cycle:L
	local L
	
	(rest of L) & item 1 of L
end cycle:


to flatten:L
	foldItems from L at {} given handler:union
end flatten:
---------------------------------------------------------------------------❮END❯