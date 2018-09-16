## APPLESCRIPTIVE

### My Coding Practices
1.  All lines of my code are restricted to a maximum column width of 80.  I make use of continuation characters to split long lines of code over several separate lines.  For me, this aids readability on a wide variety of screens, without the need to scroll horizontally.  I _loathe_ scrolling horizontally.

2.  I use hard tabs of 8 character widths.

3.  I use UTF16-LE text encoding.

4.  I tend to favour short, mono- or dual-character variable names, which I acknowledge aren't transparent and can make interpreting their nature difficult.  However, I try to be consistent with these across scripts, so that **`fp`** will always refer to a filepath, and **`L`** will always refer to a list.  AppleScript's tendency to homogenise variable letter case even across different scopes can make it challenging to differentiate a **`P`** (typically referring to a `process` in _System Events_) if used in the same script as a **`p`** (which, depending on context, either refers to a prime number or an element in a parameter list).  I prioritise uppercase names in these instances, whilst electing to substitute the lowercase name with an alternative.

5.  I utilise _Script Objects_ a lot, even unnecessarily.  _Script Objects_ are AppleScript's watered-down imitation of what other languages refer to as a `class`.  They lack many of the true features of a `class` construct, but do allow chains of inheritance to be used in similar ways.  For me, however, I largely use _Script Objects_ to organise and group blocks of code in a semantically functional way that mirrors how I might have constructed or deconstructed the coding problem in my head, making it easier for me to refactor my code if I need to, and understand what my approach was initially when I later devise an alternative method.

6.  Handler names, conversely to variable names, tend to be descriptive and CamelCase, often with an initial lowercase letter, but not exclusively.  I favour AppleScript's _labelled_ parameters because it provides the only means of specifying optional parameters, but I also make use of _interleaved_ parameter labels, and also plain-and-simple parentheticals.  Quite conveniently, `myFunction:param` is essentially equivalent in AppleScript to `myFunction_(param)`, which provides versatility in syntax when desired.

7.  I LIKE CODE TO LOOK GOOD.  I'm not claiming success in this just yet, but I believe that beautiful code will ultimately end up becoming functional code.  Obviously, we can all construct beautiful code that does absolutely nothing, so this isn't a law in itself, but is, in my view, a good mantra and reminder that aesthetics aid readability, solubility, and consistency.

8.  A corollary of `(7)` is that I might prioritise aesthetics over adherence to any of the non-prime numbered rules stipulated here (including this one).  It can also lead to syntactic inconsistency in how and where I choose to divide two similar lines of code with a continuation character that appear misplaced in one versus the other.  This is rarely an oversight, but a necessary evil in order to achieve a pleasing text alignment.

9.  I rarely prioritise speed, but I do prioritise efficiency, and wasteful code irks me.  Unnecessarily inefficient code irks me.  If a piece of code _will_ run faster if, say, a string is converted into a list of numbers before being operated on, then I will usually elect to do this.  If a script object makes execution more efficient, I will elect to use one.  However, if a piece of code is demonstrably quicker but also has to be a complete mess to preserve its speed, I am unlikely to care that a script runs slower if it ends up looking better.  _Perception is Reality_.

10.  I use AppleScript's `use` function to import an application's dictionary into the script, **if** the script is sufficiently short and primarily utilises one or two applications.  This practice won't be endorsed by many, but I am good at keeping track of terminology clashes, and utilise script objects to help separate functionally-distinct aspects of a single script.  I may also employ occasional use of _chevron syntax_ if it helps avoid using a `tell` statement and minimises command length.  A contrived example I've not actually used would be:
```applescript
property Finder : application "Finder"

«class cfol» named "Applications" of «class sdsk» of Finder
```

11.  In my final code reviews, I will try and perform code refactoring that hopefully makes the script more usable with minimal or zero requirement for edits if employed from within different environments, eg. _Automator_, _Keyboard Maestro_, _Alfred_, _FastScripts_, etc.  This is an ongoing endeavour and not necessarily achievable in all my scripts.  Some scripts may have a prefix like `[KM]` in their filename, which might suggest it only works inside _Keyboard Maestro_.  In fact, the significance of this prefix is to denote a script that operates **upon** _Keyboard Maestro_, but needn't be triggered from within _Keyboard Maestro_ (although it would generally make the most sense to do so).  Given this, one may wonder why my scripts that operate **upon** _Finder_ aren't prefixed with `[Finder]` in their filenames.  The simple answer is "just because", but the slightly extended answer is that prefixes annoy me, but this could change.

12. -

13.  I'm always open to suggestions on ways to do things that I might find more useful or meaningful in the longrun, and I am fairly adaptable in my methods given that I don't code professionally.  Therefore, comments, critiques, and tips are welcome, regardless of your own coding proficiency (I dislike unnecessary restrictions that perceived hierarchies can impose on less experienced individuals, and I apologise if I am ever an instrument of these hierarchies, at which time I hope to be made aware so I can change my habits).
