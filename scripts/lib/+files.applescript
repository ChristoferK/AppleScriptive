#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: +FILES
# nmxt: .applescript
# pDSC: File manipulation handlers that specialise in POSIX path handling
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-08-31
# asmo: 2019-05-18
--------------------------------------------------------------------------------
property name : "files"
property id : "chri.sk.applescript.lib:files"
property version : 1.5
property parent: AppleScript
--------------------------------------------------------------------------------
property sys : application "System Events"
property Finder : application "Finder"
--------------------------------------------------------------------------------
# FINDER TAGS:
property unset : 0
property orange : 1
property red : 2
property yellow : 3
property blue : 4
property purple : 5
property green : 6
property grey : 7
--------------------------------------------------------------------------------
# APPLESCRIPT HANDLERS & SCRIPT OBJECTS:

# make
#   Create a new file or folder at the given file +path.  To create a folder,
#   terminate the +path with "/".
to make new fileitem : file at path as text
	if the path exists then return false
	
	tell sys to make new fileitem with properties {name:path}
	alias (path of result)
end make

# __sys__()
#   Create a System Events file reference
on __sys__(fp as text)
	a reference to sys's alias fp
end __sys__

# __alias__()
#   Create an alias object
to __alias__(fp as text)
	#POSIX file («class posx» of __sys__(fp)) as alias
	try
		__sys__(fp) as alias
	on error
		false
	end try
end __alias__

# __finder__()
#   Create a Finder file reference
on __finder__(fp as text)
	Finder's item __alias__(fp)
end __finder__

# exists
#   Determines whether or not a file exists at the specified path
on exists (fp as text)
	__sys__(fp) exists
end exists

# delete
#   Moves the files at the specified paths to the Trash
to delete fs
	repeat with f in fs
		set f's contents to __finder__(f)
	end repeat
	
	delete fs
end delete

# dir()
#   Returns the parent (containing) directory 
on dir(fp as text)
	[__alias__(fp), "::"] as text as alias
	POSIX path of result
end dir

# resolve()
#   Standardises the filepath (expanding tildes, removing double /), and
#   resolves alias links, returning the path to the original file
to resolve(fp as text)
	if not (exists fp) then return false
	set f to __finder__(fp)
	if f's class = «class alia» then tell ¬
		f's «class orig» to if (exists) ¬
		then return resolve(it as alias)
	POSIX path of (f as alias)
end resolve

# classOfFile()
#   Returns the type of file object at the given filepath, e.g. folder, file, 
#   package file, etc.
on classOfFile(fp as text)
	if not (exists fp) then return false
	class of sys's item fp
end classOfFile

# show()
#   Reveals the files at the given filepaths in Finder
to show:fs
	repeat with f in fs
		set f's contents to __finder__(f)
	end repeat
	
	activate Finder
	continue «event miscmvis» fs
end show:
using terms from application "Finder"
	on reveal fs
		show_(fs)
	end reveal
end using terms from

# tag()
#   Tags a file in Finder with a colour
to tag(fp as text, index)
	if not (exists fp) then return false
	set f to __finder__(fp)
	set «class labi» of f to index
	f
end tag
to untag(fp)
	tag(fp, 0)
end untag

# filename()
#   Returns the name of the object at the specified filepath, including any
#   extension
on filename(fp as text)
	if not (exists fp) then return false
	name of __sys__(fp)
end filename

# ext()
#   Returns the file extension of the file at the specified filepath
on ext(fp as text)
	if not (exists fp) then return false
	«class extn» of __sys__(fp)
end ext

# defaultApp
#   Returns the path to the default application used to open the file at +fp
on defaultApp for fp as text
	default application of __sys__(fp) as alias
	return the name of the application named result
end defaultApp

# appicon
#   Returns the application icon for the application used to open the file at
#   the specified filepath
on appIcon for fp as text
	set A to application named (defApp for fp)
	set infoPlist to [path to A, "Contents:Info.plist"] as text
	
	tell application "System Events" to get value of ¬
		property list item "CFBundleIconFile" of ¬
		property list file infoPlist
	set filename to the result
	
	try
		path to resource filename in bundle A
	on error
		try
			path to resource filename & ".icns" in bundle A
		on error
			return false
		end try
	end try
	
	POSIX path of result
end appIcon
--------------------------------------------------------------------------------
# APPLESCRIPT-OBJC HANDLERS:
use framework "AppKit"
use scripting additions

property this : a reference to current application
property nil : a reference to missing value
property _1 : a reference to reference
--Cocoa Class Objects
property AMWorkflow : a reference to AMWorkflow of this
property JSContext : a reference to JSContext of this
property NSArray : a reference to NSArray of this
property NSDictionary : a reference to NSDictionary of this
property NSFileManager : a reference to NSFileManager of this
property NSMetadataItem : a reference to NSMetadataItem of this
property NSMetadataQuery : a reference to NSMetadataQuery of this
property NSMutableArray : a reference to NSMutableArray of this
property NSPasteboard : a reference to NSPasteboard of this
property NSPredicate : a reference to NSPredicate of this
property NSSortDescriptor : a reference to NSSortDescriptor of this
property NSString : a reference to NSString of this
property NSURL : a reference to NSURL of this
property NSWorkspace : a reference to NSWorkspace of this

property FileManager : a reference to NSFileManager's defaultManager
property Pasteboard : a reference to NSPasteboard's generalPasteboard
property Workspace : a reference to NSWorkspace's sharedWorkspace
--Directory Enumeration Constants
property SkipHiddenFiles : a reference to 4
property SkipPackageDescendants : a reference to 2
--NSURL Property Keys
property CreationDateKey : "NSURLCreationDateKey"
property FileSizeKey : "NSURLFileSizeKey"
property IsDirectoryKey : "NSURLIsDirectoryKey"
property ModificationDateKey : "NSURLContentModificationDateKey"
property NameKey : "NSURLNameKey"
property ParentURLKey : "NSURLParentDirectoryURLKey"
property PathKey : "_NSURLPathKey"
--NSMetadataItem Attribute Keys
property kMDPathKey : "kMDItemPath"

to __NSString__(str)
	(NSString's stringWithString:str)'s ¬
		stringByStandardizingPath()
end __NSString__

to __NSURL__(|URL|)
	if (|URL| exists) then return NSURL's ¬
		fileURLWithPath:__NSString__(|URL|)
	
	NSURL's URLWithString:|URL|
end __NSURL__

to __NSArray__(obj)
	try
		NSArray's arrayWithArray:obj
	on error
		NSArray's arrayWithObject:obj
	end try
end __NSArray__

to __any__(obj)
	(__NSArray__([obj]) as list)'s item 1
end __any__

on fileExtensionForType:(UTI as text)
	local UTI
	
	(Workspace()'s preferredFilenameExtensionForType:UTI) as text
end fileExtensionForType:

# bundleIDsForType: [ see apps ]
#   Lists the bundle IDs of apps registered on the system to open files of the
#   specified uniform type identifier.  The convenience function, apps, accepts
#   a uniform type identifier or a file extension.
on bundleIDsForType:(UTI as text)
	local UTI
	
	try
		run script "
		ObjC.import('CoreServices');
		ObjC.deepUnwrap(
		$.LSCopyAllRoleHandlersForContentType(
			" & UTI's quoted form & ",
        		$.kLSRolesAll
        	));" in "JavaScript"
	on error
		missing value
	end try
end bundleIDsForType:
on apps for typeOrExtension as text
	local typeOrExtension
	
	if typeOrExtension contains "." then return ¬
		bundleIDsForType_(typeOrExtension)
	
	repeat with dir in [¬
		"~/Documents", ¬
		"~/Desktop", ¬
		"~/Downloads", ¬
		"~/Pictures"]
		tell (deepDive into dir for typeOrExtension) to if it ≠ {} ¬
			then return (my bundleIDsForType:((my Workspace())'s ¬
			typeOfFile:(its some item) |error|:nil))
	end repeat
end apps

to runWorkflow at fp as text given input:fs as list
	local fp, fs
	
	AMWorkflow's runWorkflowAtURL:__NSURL__(fp) withInput:fs |error|:_1
	set [output, E] to the result
	if E ≠ missing value then return E's localizedDescription() as text
	
	__any__(output)
end runWorkflow

# metadata()
#   Returns a record containing the filesystem's metadata for the given
#   reference at the filepath
on metadata for fp
	set mdItem to NSMetadataItem's alloc()'s initWithURL:__alias__(fp)
	tell (mdItem's attributes() as list) to if {} ≠ it then ¬
		return (mdItem's valuesForAttributes:it) as record
	
	{}
end metadata

# mdQuery
#   Performs a Spotlight metadata +query/search, limiting the search scope to
#   the optionally specified list of +directories.  Returns a list of file paths
#   whose metadata satisfy the query.
on mdQuery at directories as list : {"~/"} given query:query
	local query
	
	repeat with dir in directories
		set dir's contents to __alias__(dir)
	end repeat
	
	tell NSMetadataQuery's new()
		setSearchScopes_(directories)
		setPredicate_(NSPredicate's predicateWithFormat:query)
		
		startQuery()
		
		with timeout of 10 seconds
			repeat while isGathering() as boolean
				delay 0.1
			end repeat
		end timeout
		
		stopQuery()
		
		(results()'s valueForKey:kMDPathKey) as list
	end tell
end mdQuery

# cbSet: [ syn. cbSet() ]
#   Writes the file object references at the specified filepaths to the
#   clipboard
on cbSet:(fs as list)
	local fs
	
	repeat with f in fs
		set f's contents to __alias__(f)
	end repeat
	
	tell the Pasteboard
		clearContents()
		writeObjects_(aliases in fs)
	end tell
end cbSet:
on cbSet(fs)
	cbSet_(fs)
end cbSet

# cbGet()
#   Retrieves a list of file object references currently on the clipboard
on cbGet()
	(Pasteboard's readObjectsForClasses:[NSURL] options:[]) as list
end cbGet

# deepDive
#   Performs a deep enumeration of a directory returning a record of keys that
#   correspond to properties of each file requested/excluded by passing the
#   appropriate boolean parameter
on deepDive into dir for filetypes as text : ("") ¬
	given name:filename as boolean : false ¬
	, path:filepath as boolean : true ¬
	, size:filesize as boolean : false ¬
	, creation date:cdate as boolean : false ¬
	, parent:container as boolean : false ¬
	, folders:directories as boolean : true ¬
	, modification date:mdate as boolean : false
	local dir, filename, filepath, filesize, cdate, container
	local directories, mdate, filetypes
	
	set keys to {IsDirectoryKey}
	if filepath then set end of keys to PathKey
	if filesize then set end of keys to FileSizeKey
	if filename then set end of keys to NameKey
	if container then set end of keys to ParentURLKey
	if cdate then set end of keys to CreationDateKey
	if mdate then set end of keys to ModificationDateKey
	
	set fURLs to NSMutableArray's array()
	
	fURLs's addObjectsFromArray:((FileManager's ¬
		enumeratorAtURL:__NSURL__(dir) ¬
			includingPropertiesForKeys:keys ¬
			options:(SkipHiddenFiles + SkipPackageDescendants) ¬
			errorHandler:nil)'s allObjects())
	
	set predicate to "ANY %@ ==[c] pathExtension"
	if filetypes begins with "!" then set predicate ¬
		to ["!", predicate] as text
	set filetypes to the words of filetypes
	set |?| to NSPredicate's predicateWithFormat_(predicate, filetypes)
	if {} ≠ filetypes then fURLs's filterUsingPredicate:|?|
	
	repeat with f in fURLs
		if directories or (((f's ¬
			resourceValuesForKeys:[IsDirectoryKey] |error|:nil)'s ¬
			valueForKey:IsDirectoryKey) as boolean = false) then
			
			(f's resourceValuesForKeys:(rest of keys) |error|:nil)
			# (fs's addObject:result)
		else
			null
		end if
		set f's contents to the result
	end repeat
	
	fURLs's removeObject:(null)
	if the number of keys > 2 then return fURLs as list
	fURLs's sortUsingDescriptors:[NSSortDescriptor's alloc()'s ¬
		initWithKey:(end of keys) ascending:yes]
	(fURLs's valueForKey:(end of keys)) as list
end deepDive

# filesTagged
#   Performs a Spotlight metadata query to obtain a list of files in the 
#   user domain that have any tags containing the +tag string
on filesTagged by tag given caseMatching:matchCase as boolean : false ¬
	, fuzziness:fuzzy as boolean : true
	local tag, matchCase, fuzzy
	
	set [op, flag] to ["CONTAINS", "[c] "]
	if matchCase then set flag to " "
	if not fuzzy then set op to "=="
	
	set query to ["kMDItemUserTags", space, op, flag, tag's quoted form]
	mdQuery given query:query as text
end filesTagged
---------------------------------------------------------------------------❮END❯