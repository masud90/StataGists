/*============================================================================*/
//# 1.0 Initialize
/*============================================================================*/

//# 1.1 Set up system

*** Native version ***
clear all								// clear previous estimates/ data
set maxvar       32767 , permanently	// maximum allowable no. of variables in STATA/SE. Can be increased further to 120,000 for STATA/MP
set matsize      400   , permanently	// maximum size of matrices in terms of the number of estimated coefficients. Can go up to 11,000 but requires much larger memory consumption
set niceness     5     , permanently	// affects how soon Stata gives back unused segments to the operating system. 5 is 01:00 minute.
set min_memory   0     , permanently
set max_memory   .     , permanently
set segmentsize  32m   , permanently
set more         off   , perm			// output will continue to be displayed
pause            on						// code breaks, useful for debugging
set varabbrev    off					// this helps you avoid mistakes such as accidently referencing the wrong variable
version			 17.0 // Or your current version

*** IETOOLKIT Package Version ***
ieboilstart, versionnumber(17.0) // Replace 17.0 with STATA version number. Only major releases are supported
`r(version)'

//# 1.2 Setting paths for all users

*** For locally synced cloud storage ***
/*Example: Dropbox/ Box/ Google Drive/ OneDrive/ SharePoint etc. */

display "`:environment USERPROFILE'"
local workingdir = "`:environment USERPROFILE'/Dropbox/Project 1/" // Replace Project 1 with folders and sub-folders of your project. Replace dropbox with the locally synced cloud storage option

*** For multiple users on different file systems ***

/* This can be done by defining global macros for each collaborator. 
However, this is unnecessary as long as file structure beyond the
project root folder is same for everyone. Highly recommend always
choosing the locally synced cloud storage option above. */

//# 1.3 Define Folder Structure

global	data 		"`workingdir'/00 Raw Data/"
global	dofile		"`workingdir'/01 Do File/"
global	temp		"`workingdir'/02 Temp Files/"
global	output		"`workingdir'/03 Output/"
global	tables		"`workingdir'/03 Output/01 Tables/"
global	graphs		"`workingdir'/03 Output/02 Graphs/"
global 	logfile		"`workingdir'/04 Log Files/"

*If needed, install the directories used in the process. This code assumes that you already have 00 Raw Data and 01 Do Files folders in the root folder.
confirmdir "`workingdir'\02 Temp Files\"
scalar define n_temp=_rc
confirmdir "`workingdir'\03 Output\"
scalar define n_output=_rc
confirmdir  "`workingdir'\04 Log Files\"
scalar define n_logf=_rc
confirmdir  "`workingdir'\03 Output\01 Tables\"
scalar define n_table=_rc
confirmdir  "`workingdir'\03 Output\02 Graphs\"
scalar define n_graph=_rc
scalar define check=n_temp+n_output+n_logf+n_table+n_graph
di check
if check==0 {
		display "No action needed"
}
else {
	mkdir "${temp}"
	mkdir "${output}"
	mkdir "${logfile}"
	mkdir "${tables}"
	mkdir "${graphs}"
}

//# 1.4 Log activities

// Set Log File
log using "${logfile}[LogFileName].smcl" , replace // Replace LogFileName, you can replace smcl with txt or other file extensions if they fit your purpose.

// Close Log File
capture log close // put this at the end of the last do file
