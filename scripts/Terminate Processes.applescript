#!/usr/bin/osascript
--------------------------------------------------------------------------------
# pnam: TERMINATE PROCESSES
# nmxt: .applescript
# pDSC: Presents a list of running processes for termination

# plst: -

# rslt: Processes terminate
--------------------------------------------------------------------------------
# sown: CK
# ascd: 2018-09-17
# asmo: 2018-10-25
--------------------------------------------------------------------------------
use framework "Foundation"
use scripting additions

property this : a reference to the current application
property NSPredicate : a reference to NSPredicate of this
property NSSortDescriptor : a reference to NSSortDescriptor of this
property NSWorkspace : a reference to NSWorkspace of this
--------------------------------------------------------------------------------
# IMPLEMENTATION:
set A to NSWorkspace's sharedWorkspace()'s runningApplications()'s Â
	sortedArrayUsingDescriptors:[NSSortDescriptor's Â
		sortDescriptorWithKey:("localizedName") Â
			ascending:yes Â
			selector:"caseInsensitiveCompare:"]

tell (choose from list A's localizedName as list Â
	with title "Running Processes" with prompt Â
	"Select processes to kill:" OK button name Â
	"Quit" empty selection allowed false Â
	with multiple selections allowed) to Â
	if it ­ false then repeat with proc in Â
		(A's filteredArrayUsingPredicate:(NSPredicate's Â
			predicateWithFormat:("localizedName IN %@") Â
				argumentArray:[it]))
		
		# proc's terminate()
		proc's forceTerminate()
	end repeat
--------------------------------------------------------------------------:END #