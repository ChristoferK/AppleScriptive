#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: +SSL
# nmxt: .applescript
# pDSC: A library containing cryptographic and encoding functions
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-12-10
# asmo: 2019-05-07
--------------------------------------------------------------------------------
property name : "+SSL"
property id : "chri.sk.applescript:SSL"
property version : 1.0
--------------------------------------------------------------------------------
use framework "Foundation"

property this : a reference to current application
property NSString : a reference to NSString of this
property NSData : a reference to NSData of this
property NSDataBase64Encoding64CharacterLineLength : a reference to 1
property NSDataBase64DecodingIgnoreUnknownCharacters : a reference to 1
property NSUTF8StringEncoding : a reference to 4
--------------------------------------------------------------------------------
# APPLESCRIPT-OBJC HANDLERS:

# base64Decode()
#   Decodes a base-64 string to UTF-8
on base64Decode(s)
	(NSString's alloc()'s initWithData:(NSData's alloc()'s Â
		initWithBase64EncodedString:s options:1) Â
		encoding:(NSUTF8StringEncoding)) as text
end base64Decode

# base64Encode()
#   Encodes a string to base-64
on base64Encode(s)
	(((NSString's stringWithString:s)'s Â
		dataUsingEncoding:(NSUTF8StringEncoding))'s Â
		base64EncodedStringWithOptions:1) as text
end base64Encode

# base64EncodeFromFile:
#   Encodes a file to a base-64 string
on base64EncodeFromFile:fp
	set d to NSData's dataWithContentsOfFile:fp
	(d's base64EncodedStringWithOptions:(NSDataBase64Encoding64CharacterLineLength)) as text
end base64EncodeFromFile: