#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: _LISTS
# nmxt: .applescript
# pDSC: List manipulation handlers
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-08-23
# asmo: 2018-12-06
--------------------------------------------------------------------------------
property name : "_lists"
property id : "chri.sk.applescript._lists"
property version : 1.0
property _array : me
property parent : AppleScript
--------------------------------------------------------------------------------
# HANDLERS & SCRIPT OBJECTS:

# make
#   Generates a list of N objects, which are, by default, the integers from 1
#   to +N in order.  If +x is supplied, the generated list contains +N
#   occurrences of the object +x.  pseudorandomness takes priority over +x, and 
#   will cause the generated list to contain +N random integers no greater in
#   value than +N.
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
# array()
#   A convenience handler that will generate a list of integers from 1 to +N
on array(N)
	make N
end array

# offset
#   Lists the indices of each occurrence of the item +x in list +L
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

# __()
#   Wraps a function inside a script object for use by other handlers in this
#   library, enabling them to complex actions with a nested set of functions
on __(function)
	if the function's class = script ¬
		then return the function
	
	script
		property fn : function
	end script
end __

# iterate (syn. generator)
#   Returns a script object that acts as a generator to obtain the next item
#   in a potentially infinite list of items where each item is generated from
#   the last by repeated application of a function.  
on iterate for N : 0 from y : 1 to max : null given handler:function
	script
		property list : {}
		property length : N
		property item : y
		property index : 0
		property func : function
		
		on x()
			tell my list
				set its end to its last item
				a reference to its last item
			end tell
		end x
		
		to next()
			set index to index + 1
			if index = 1 then return my item
			
			tell __(func) to set my item to ¬
				fn(my item, my index, my list)
		end next
		
		to yield(N)
			local N
			
			repeat N times
				set end of my list to next()
			end repeat
			
			my list
		end yield
		
		on upto(max)
			local max
			
			repeat
				if next() > max then return my list
				set end of my list to my item
			end repeat
		end upto
	end script
	
	tell the result
		if N > 0 then return its yield(N)
		if max ≠ null then return upto(max)
		it
	end tell
end iterate
on generator(fn, y)
	iterate from y given handler:fn
end generator

# mapItems
#   Applies a given handler (function) to each item in a list (+L).  The items
#   of the supplied list are overwritten with their new values.
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

# filterItems
#   Filters a list (+L) to include only those items that pass a given test as
#   defined by a predicate (function).  The original list remains in tact.
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

# foldItems
#   Reduces a list through a specificed handler (function), accumulating the
#   result as it goes, returning the accumulated value.  The original list
#   remains unchanged.
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

# putItems
#   Places a list of items (+x_) into a given list (+L) at index +i, overwriting
#   any and all items that currently exist at the overlapping indices.  If the
#   indices to which the new values are to be written extend beyond the length
#   of the original list, then the list will be extended as necessary.
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

# pushItems
#   Inserts a list of items (+x_) into a given list (+L) at index +i, moving the
#   existing items to its right the appropriate number of places.  The original
#   list is not affected.  The resulting list can be longer than the original
#   if the number of items to be pushed extend beyond the number of items the
#   original list can accommodate.
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

# difference()
#   Returns the difference of two lists, i.e. the items in +A that are not
#   present in +B, A - B.
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

# intersection()
#   Returns the intersection of two lists, i.e. those items in +A that are also
#   in +B.
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

# union()
#   Returns the union of two lists, i.e. merges the items of both lists
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

# unique:
#   Returns every item in a list as a unique entity in a new list, i.e. makes
#   list +L into a pseudoset
on unique:L
	local L
	
	script
		on unique(x, i, L)
			x is not in L
		end unique
	end script
	
	filterItems from L given handler:result's unique
end unique:

# multiply()
#   Multiples two values together.  If the second value, +L, is a list, then
#   every item in that list is multiplied by +x.
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

# add()
#   Adds two values together.  If the second value, +L, is a list, then
#   every item in that list is added to +x.
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

# sum:
#   Returns the sum of a list of numbers
on sum:L
	foldItems from L given handler:add
end sum:


on product:L
	foldItems from L at 1 given handler:multiply
end product:

# max:
#   Returns the maximum value from a list of numbers (or strings)
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

# min:
#   Returns the minimum value from a list of numbers (or strings)
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

# min:
#   Returns the mean value of a list of numbers
on mean:L
	local L
	
	(my sum:L) / (length of L)
end mean:

# swap()
#   Swaps the items at indices +i and +j in a list (+L) with one another
on swap(L, i, j)
	local L, i, j
	
	set [item i of L, item j of L] to [item j, item i] of L
	L
end swap

# sort:
#   Sorts a list of numbers in ascending numerical value.  The original list
#   is overwritten as it is sorted.  This is an inefficient algorithm.
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

# rotate:
#   Rotates a list by one anti-clockwise.  The original list is overwritten.
to rotate:L
	local L
	
	if length of L < 2 then return L
	set x to item 1 of L
	
	script
		to unshift(x, i, L)
			local x, i, L
			
			if i = L's length then return missing value
			item (i + 1) of L
		end unshift
	end script
	
	mapItems from L given handler:result's unshift
	set last item of L to x
	L
end rotate:

# cycle:
#   Like rotate: but preserves the original list, and is therefore much faster
on cycle:L
	local L
	
	(rest of L) & item 1 of L
end cycle:

# flatten:
#   Returns a flattened version a nested list as a one-dimensional list
to flatten:L
	foldItems from L at {} given handler:union
end flatten:
---------------------------------------------------------------------------❮END❯