#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: ITUNES#DOWNLOAD ALBUM ARTWORK
# nmxt: .applescript
# pDSC: Searches Google and downloads album artwork for the currently selected
#       or currently playing track and the other album tracks in iTunes

# plst: -

# rslt: 1 : Artwork applied to associated iTunes tracks
#       0 : Nothing selected/nothing playing; or multiple tracks selected
#      -1 : Image URL unable to be retrieved or downloaded
#      -2 : Artwork could not be applied to some or all tracks
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2019-05-01
# asmo: 2019-05-02
# vers: 1.0
--------------------------------------------------------------------------------
property js : "unescape(Array.from(document.links, x=>x.href.match(
               /(?:https:\\/\\/www\\.google\\.com\\/imgres\\?imgurl=)([^&]+)/
               )).filter(x=>x!=null).map(x=>x[1]).shift());"
property www : "https://www.google.com/search?tbm=isch" & ¬
	"&tbs=isz:ex,iszw:1000,iszh:1000&q="

tell application "iTunes"
	set myTrack to selection of browser window 1
	if myTrack = {} then
		if player state ≠ playing then return 0
		set myTrack to the current track
	else if myTrack's length = 1 then
		set [myTrack] to myTrack
	else
		return 0
	end if
	
	tell myTrack to set searchTerm to [artist, " - ", album]
	set myTracks to a reference to (every track where ¬
		artist = (myTrack's artist as text) and ¬
		album = (myTrack's album as text))
end tell

set imageURL to null

if the defaultBrowser() = "Safari" then
	tell Safari to searchGoogleImages for the searchTerm
else
	tell Chrome to searchGoogleImages for the searchTerm
end if

set imageURL to the result
set imagePath to downloadArtwork from imageURL
if imagePath = null then return -1
set JPEG to read the imagePath as JPEG picture

try
	tell application "iTunes"
		delete every artwork of myTracks
		repeat with thisTrack in myTracks
			set data of artwork 1 of thisTrack to JPEG
		end repeat
	end tell
	
	1
on error
	-2
end try
--------------------------------------------------------------------------------
# HANDLERS & SCRIPT OBJECTS:
script Chrome
	to searchGoogleImages for term as text
		local term
		
		tell application "Google Chrome" to tell window 1 to tell ¬
			(make new tab with properties {URL:www & term})
			repeat 30 times
				delay 1
				tell (execute javascript js) to if ¬
					"undefined" ≠ it then
					set imageURL to it
					exit repeat
				end if
			end repeat
			close
		end tell
		
		return the imageURL
	end searchGoogleImages
end script

script Safari
	to searchGoogleImages for term as text
		local term
		
		tell application "Safari" to tell window 1 to tell ¬
			(make new tab with properties {URL:www & term})
			repeat 30 times
				delay 1
				tell (do JavaScript js) to if ¬
					"undefined" ≠ it then
					set imageURL to it
					exit repeat
				end if
			end repeat
			close
		end tell
		
		return the imageURL
	end searchGoogleImages
end script

to downloadArtwork from |URL| as text to tmp as text : "/tmp/artwork"
	local |URL|
	
	set cURL to the contents of [¬
		"cURL --url ", |URL|, ¬
		"     --output ", tmp, ¬
		"     --silent"] as text
	
	try
		if |URL| = null then error
		do shell script cURL
	on error
		return null
	end try
	
	tmp
end downloadArtwork

# APPLESCRIPT-OBJC HANDLERS:
use framework "Foundation"

property this : a reference to the current application
property NSWorkspace : a reference to NSWorkspace of this
property NSURL : a reference to NSURL of this

on defaultBrowser()
	set sharedWorkspace to NSWorkspace's sharedWorkspace()
	set www to NSURL's URLWithString:"http:"
	(sharedWorkspace's URLForApplicationToOpenURL:www)'s ¬
		lastPathComponent()'s ¬
		stringByDeletingPathExtension() as text
end defaultBrowser
---------------------------------------------------------------------------❮END❯