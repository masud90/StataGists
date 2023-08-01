/*============================================================================
//# MACHINE LEARNING USING STATA - RANDOM FOREST
Masud Rahman | rahmmoha@unhcr.org 
============================================================================*/

//# Load Data
sysuse auto.dta, clear // Load 1978 automobile data

//# Set global variables
global targetvar price
global indvars mpg rep78 headroom trunk weight length turn displacement gear_ratio foreign

//# Preprocess dataset
** Set seed
set seed 2023

** Sort in random order
gen u=uniform()
sort u, stable

** train-test split (80:20)
local obs = `c(N)'
local trainsize = round(`c(N)' * 0.8) // Edit this line to change the ratio
local testsize = `c(N)' - `trainsize'
local teststart = `testsize'+1
di "Total Number of Observations: `c(N)' // Training data size: `trainsize' // Test data size: `testsize'"

** Store train test split assignments in a variable
gen traintest = 0
replace traintest = 1 in `teststart' / `c(N)'
label define traintestlabel 0 "Training data" 1 "Test data"
label values traintest traintestlabel

//# Hyperparameter tuning - Iterations
gen out_of_bag_error1 = .
gen validation_error = .
gen iter1 = .
label var out_of_bag_error1 "Out of Bag Error"
label var iter1 "Iterations"
label var validation_error "Validation Error"

local j = 0
forvalues i = 10(5)50{ // change 50 to a higher number
	local j = `j' + 1
	rforest ${targetvar} ${indvars} if traintest == 0, ///
	type(class) iter(`i') numvars(1)
	replace iter1 = `i' in `j'
	replace out_of_bag_error1 = `e(OOB_Error)' in `j'
	predict p if traintest == 1
	replace validation_error = `e(error_rate)' in `j'
	drop p
}

** Visually validate optimum iterations

scatter out_of_bag_error1 iter1, msize(tiny) || ///
	scatter validation_error iter1, msize(tiny) || ///
	fpfit out_of_bag_error1 iter1, lpattern(dash) || ///
	fpfit validation_error iter1, lpattern(dash) ///
	legend(order(1 "Out of Bag Error" 2 "Validation Error")) ///
	title("Hyperparameter Tuning for Iterations") ///
	name(iter_graph)

//# Hyperparameter tuning - Number of variables randomly selected at each split
gen oob_error = .
gen nvars = .
gen val_error = .
label var oob_error "Out of Bag Error"
label var val_error "Validation Error"
label var nvars "Number of Variables Randomly Selected at Each Split"

local j = 0

forvalues i = 1(1)10{ // Change 10 to max number of variables
	local j = `j' + 1
	rforest ${targetvar} ${indvars} if traintest == 0, ///
	type(class) iter(1000) numvars(`i')
	qui replace nvars = `i' in `j'
	qui replace oob_error = `e(OOB_Error)' in `j'
	predict p if traintest == 1
	qui replace val_error = `e(error_rate)' in `j'
	drop p
}

** Automatically identify the number of variables at the lowest error value
frame put val_error nvars, into(mydata)
frame mydata {
	sort val_error, stable
	local min_val_err = val_error[1]
	local min_nvars = nvars[1]
}
frame drop mydata
gen nvaropt = .
replace nvaropt = 1 if nvars == `min_nvars'
di "Minimum Error: `min_val_err'; Corresponding number of variables: `min_nvars'"

** Visually validate optimum number of variables
scatter oob_error nvars, msize(tiny) || ///
	scatter val_error nvars, msize(tiny) || ///
	scatter val_error nvars if nvaropt == 1, msize(huge) msymbol(x) ///
	legend(order(1 "Out of Bag Error" 2 "Validation Error")) ///
	name(nvars_graph)

//# Final model
rforest ${targetvar} ${indvars} if traintest == 0, ///
	type(class) iter(200) numvars(3) // Edit the iter and numvars values
di e(OOB_Error)
predict p if traintest == 1
di e(error_rate)

//# variable importance plot
matrix importance =e(importance)
svmat importance
gen importid=""

local mynames : rownames importance
local k : word count `mynames'
if `k'>_N {
	set obs `k'
}
forvalues i = 1(1)`k' {
	local aword : word `i' of `mynames'
	local alabel : variable label `aword'
	if ("`alabel'"!="") qui replace importid= "`alabel'" in `i'
	else qui replace importid= "`aword'" in `i'
}
preserve
	gsort -importance1 // sort descending
	graph hbar (mean) importance1 in 1/10, ///
	over(importid,  sort(1) label(labsize(2))) ///
	ytitle("") blabel(bar, format(%3.2f)) ///
	title("Importance plot") ///
	name(importance_graph)
restore 

//# Coefficient Plot
eststo coefest: regress ${target} ${indvars}
coefplot (coefest), sort(,descending) ///
	drop(_cons) xline(0)  levels(95)  ///
	ylabel(, labsize(vsmall)) ///
	note("* Sorted on coefficient values", size(vsmall)) ///
	title("Coefficient plot") ///
	name(coef_graph)