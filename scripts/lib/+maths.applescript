#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: +MATHS
# nmxt: .applescript
# pDSC: Mathematical functions.  Loading this library also loads _lists lib.
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-11-04
# asmo: 2019-05-07
--------------------------------------------------------------------------------
property name : "maths"
property id : "chri.sk.applescript.lib:maths"
property version : 1.0
property libload : script "load.scpt"
property parent : libload's load("arrays")
--------------------------------------------------------------------------------
# HANDLERS & SCRIPT OBJECTS:

# Node::
#   Binary tree representation
script Node
	to make with data d
		script
			property data : d
			property |left| : null
			property |right| : null
		end script
	end make
end script

# Complex::
#   Complex number representation and arithmetic
script Complex
	to make at {x as real, y as real}
		script
			property class : "complex"
			property real : x
			property imaginary : y
			property arg : atan(y / x)
			property R : sqrt(x ^ 2 + y ^ 2)
			
			to add(z)
				local z
				
				set my real to (my real) + (z's real)
				set my imaginary to (my imaginary) + ¬
					(z's imaginary)
				
				update()
			end add
			
			to rotate(theta)
				set arg to arg + theta
				
				update_polar()
			end rotate
			
			to update()
				set arg to atan((my imaginary) / (my real))
				set R to sqrt((my real) ^ 2 + ¬
					(my imaginary) ^ 2)
			end update
			
			to update_polar()
				set my real to cos(arg)
				set my imaginary to sin(arg)
			end update_polar
		end script
	end make
	
	to add(z1, z2)
		local z1, z2
		
		set x to (z1's real) + (z2's real)
		set y to (z1's imaginary) + (z2's imaginary)
		make Complex at {x, y}
	end add
end script

# Fraction::
#   A script object to represent fractions
script Fraction
	to make given numerator:a, denominator:b : 1
		if b = 0 then return false
		
		script
			property class : "fraction"
			property numerator : a
			property denominator : b
			property HCF : its GCD:{numerator, denominator}
			property value : numerator / denominator
			property integer : numerator div denominator
			property fractional : value - (my integer)
			property list : [a reference to numerator, ¬
				a reference to denominator]
			
			to simplify()
				set numerator to numerator / HCF
				set denominator to denominator / HCF
				set HCF to 1
				
				my list
			end simplify
			
			on reciprocal()
				set [numerator, denominator] to ¬
					[denominator, numerator]
				
				update()
				
				my list
			end reciprocal
			
			on continuedFraction()
				continuedFraction for numerator ¬
					over denominator
			end continuedFraction
			
			to add(x)
				local x
				
				set [a, b] to contents of x's list
				
				set my numerator to ¬
					(my numerator) * b + ¬
					(my denominator) * a
				set my denominator to (my denominator) * b
				
				update()
				simplify()
				
				me
			end add
			
			to update()
				set HCF to its GCD:{numerator, denominator}
				set value to numerator / denominator
				set my integer to numerator div denominator
				set fractional to value - (my integer)
				
				me
			end update
		end script
	end make
	
	to multiply(x, y)
		local x, y
		
		set a to (x's numerator) * (y's numerator)
		set b to (x's denominator) * (y's denominator)
		make Fraction given numerator:a, denominator:b
	end multiply
	
	to add(x, y)
		local x, y
		
		set b to its LCM:{x's denominator, y's denominator}
		set a to (b * (x's numerator) / (x's denominator)) + ¬
			(b * (y's numerator) / (y's denominator))
		
		set R to make Fraction given numerator:a, denominator:b
		tell R to simplify()
		R
	end add
end script

# ||()
#   A basic ternary function that evaluates a predicate, +a, to determine which 
#   of two results, +b or +c, it ought to return
on ||(a, b, c)
	local a, b, c
	
	if a then return b
	c
end ||

# GCD:
#   Returns the greatest common divisor of a list of integers
on GCD:L
	local L
	
	script
		property array : L
		
		on GCD(x, y)
			local x, y
			
			repeat
				if x = 0 then return y
				set [x, y] to [y mod x, x]
			end repeat
		end GCD
	end script
	
	tell the result to foldItems from its array ¬
		at item 1 of its array ¬
		given handler:its GCD
end GCD:

# LCM:
#   Returns the lowest common multiple of a list of integers
on LCM:L
	local L
	
	script
		property array : L
		
		on LCM(x, y)
			local x, y
			
			set xy to x * y
			
			repeat
				if x = 0 then return xy / y as integer
				set [x, y] to [y mod x, x]
			end repeat
		end LCM
	end script
	
	tell the result to foldItems from its array ¬
		at item 1 of its array ¬
		given handler:its LCM
end LCM:

# floor()
#   Returns the greatest integer less than or equal to the supplied value
to floor(x)
	local x
	
	x - 0.5 + 1.0E-15 as integer
end floor

# ceil()
#   Returns the lowest integer greater than or equal to the supplied value
on ceil(x)
	local x
	
	floor(x) + 1
end ceil

# sqrt()
#   Returns the positive square root of a number
to sqrt(x)
	local x
	
	x ^ 0.5
end sqrt

# abs()
#   Returns the absolute value of a number
on abs(x)
	local x
	
	if x < 0 then return -x
	x
end abs

# sign()
#   Returns the sign of a number
on sign(x)
	local x
	
	if x < 0 then return -1
	if x > 0 then return 1
	0
end sign

# Roman()
#   Returns a number formatted as Roman numerals
to Roman(N as integer)
	local N
	
	script numerals
		property list : "Ⅰ Ⅳ Ⅴ Ⅸ Ⅹ ⅩⅬ Ⅼ ⅩⅭ Ⅽ ⅭⅮ Ⅾ ⅭⅯ Ⅿ"
		property value : "1 4 5 9 10 40 50 90 100 400 500 900 1000"
		property string : {}
	end script
	
	
	repeat with i from length of words of list of numerals to 1 by -1
		set glyph to item i in the words of list of numerals
		set x to item i in the words of numerals's value
		
		make (N div x) at glyph
		set string of numerals to string of numerals & result
		set N to N mod x
	end repeat
	
	return the string of numerals as linked list as text
end Roman

# hex
#   Converts a decimal number to hexadecimal
to hex from decimal as integer
	local decimal
	
	set hexchars to "0123456789ABCDEF"
	
	set [int, i] to [decimal div 16, decimal mod 16 + 1]
	set hexchar to character i of hexchars
	
	if int = 0 then return hexchar
	(hex from int) & hexchar
end hex

# decimal
#   Converts a number from hexadecimal to decimal
to decimal from hex as text
	local hex
	
	script
		property hexchars : "0123456789ABCDEF"
		
		on fn(power, chars)
			if chars = {} then return 0
			
			set [char] to chars
			set i to offset of char in hexchars
			set x to (i - 1) * power
			
			return x + fn(power * 16, rest of chars)
		end fn
	end script
	
	result's fn(1, reverse of hex's characters)
end decimal

# digitalRoot()
#   Calculates the digital root of a number.  The digital root is the repeated
#   sum of a number's digits.
on digitalRoot(N)
	local N
	
	tell generator(my digitalSum, N) to repeat
		tell next() to if it < 10 then return it
	end repeat
end digitalRoot

# digitalSum()
#   Sums the digits of a number
on digitalSum(x)
	local x
	
	set digits to characters of (x as text)
	sum_(digits)
end digitalSum

# continuedFraction
#   Returns a number represented as a continued fraction
on continuedFraction for a over b : 1
	local a, b
	
	script CF
		on fn(a, b)
			local a, b
			
			if b = 0 then return {}
			
			set c to a div b
			set d to a - (b * c)
			
			{c} & fn(b, d)
		end fn
	end script
	
	tell CF's fn(a, b) to return [item 1, rest] of it
end continuedFraction

# convergentFraction
#   Returns a script object representing the fraction denoted by the supplied
#   continued fraction
on convergentFraction for CF
	script quotient
		on fn(x, |ξ|)
			set [a, b, c, d] to |ξ|
			
			set numerator to a * x + c
			set denominator to b * x + d
			
			[numerator, denominator, a, b]
		end fn
	end script
	
	set [x, y] to foldItems from rest of CF ¬
		at {item 1 of CF, 1, 1, 0} ¬
		given handler:quotient
	
	make Fraction given numerator:x, denominator:y
end convergentFraction

# primes()
#   Efficient and fast prime number generation for primes ≤ +N
to primes(N)
	local N
	
	if N < 2 then return {}
	
	script
		on nextPrime(x, i, L)
			local x, i, L
			
			script primes
				property list : L
			end script
			
			repeat
				set x to x + 2
				repeat with p in the list of primes
					if x mod p = 0 then exit repeat
					if x < p ^ 2 then return x
				end repeat
			end repeat
		end nextPrime
	end script
	
	{2} & (iterate from 3 to N given handler:result's nextPrime)
end primes

# factorise()
#   Factorises an integer into a list of prime factors
to factorise(N as integer)
	local N
	
	script decompose
		on fn(p, |ξ|)
			set y to a reference to item 1 of |ξ|
			repeat
				if y mod p ≠ 0 then return |ξ|
				
				set y's contents to y / p
				set end of |ξ| to p
			end repeat
		end fn
	end script
	
	tell the rest of (foldItems from primes(N / 2) at {N} ¬
		given handler:decompose)
		if {} = it then return N
		it
	end tell
end factorise

# factorial()
#   Calculates the factorial of a number
on factorial(N)
	if N = 0 then return 1
	
	script
		on fn(x, i)
			x * i
		end fn
	end script
	
	tell generator(result's fn, 1) to repeat N times
		next()
	end repeat
end factorial

# e()
#   Returns the value of e
on e()
	script Engel
		on fn(x, i)
			x + 1 / (factorial(i))
		end fn
	end script
	
	tell generator(Engel, 2) to repeat 15 times
		next()
	end repeat
end e

# partialSum
#   Sums the first N terms of a series defined by the handler +NthTerm
on partialSum given handler:NthTerm
	local NthTerm
	
	set [N, u, sum] to [0, 1, 0]
	repeat until abs(u) < 1.0E-15
		set N to N + 1
		
		set u to __(NthTerm)'s fn(N)
		set sum to sum + u
	end repeat
	
	if abs(sum) < 4.9E-15 then set sum to 0.0
	sum
end partialSum

# sin()
#   Calculates the sine of a number
on sin(x)
	local x
	
	set x to x mod (2 * pi)
	
	script sine
		on fn(N)
			(-1) ^ (N + 1) ¬
				* (x ^ (2 * N - 1)) ¬
				/ (factorial(2 * N - 1))
		end fn
	end script
	
	partialSum given handler:sine
end sin

# cos()
#   Calculates the cosine of a number
on cos(x)
	local x
	
	set x to x mod (2 * pi)
	
	script cosine
		on fn(N)
			(-1) ^ (N + 1) ¬
				* (x ^ (2 * N - 2)) ¬
				/ (factorial(2 * N - 2))
		end fn
	end script
	
	partialSum given handler:cosine
end cos

# ln()
#   Calculates the natural logarithm of a number for small +x
on ln(x)
	local x
	
	script logE
		on fn(N)
			(-1) ^ (N + 1) * ((x - 1) ^ N) / N
		end fn
	end script
	
	partialSum given handler:logE
end ln
---------------------------------------------------------------------------❮END❯