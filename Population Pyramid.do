/***************************************************************************
Population Pyramid Analysis Do File

Author: Masud Rahman
Date: 5 July 2024

Description:
This do file creates two versions of population pyramids for the year 2000 
using the pop2000 dataset. The first version displays the population 
percentages, and the second version displays the actual population numbers.

Note:
- The file contains two sections: the first for percentage-based plots and 
the second for plots with actual population numbers.
***************************************************************************/

*--------------------------------------------------------------------------*	   
//# Percentage version
*--------------------------------------------------------------------------*	

* Load the pop2000 dataset
sysuse pop2000.dta, clear

* Reshape the data for male population
preserve
	rename maletotal population
	gen sex = 1  // 1 for Male
	tempfile males
	save `males'
restore

* Reshape the data for female population
preserve
	rename femtotal population
	gen sex = 2  // 2 for Female
	tempfile females
	save `females'
restore

* Combine the reshaped datasets
use `males', clear
append using `females'

* Label the sex variable
label define sexlbl 1 "Male" 2 "Female"
label values sex sexlbl

* Calculate the total population for each sex
egen total_population = total(population), by(sex)

* Calculate the population percentage for each age group within each sex
gen population_pct = (population / total_population) * 100

* Create a variable for negative percentage for the pyramid
gen population_pct_neg = -population_pct if sex == 1
replace population_pct_neg = population_pct if sex == 2

* Identify the unique age groups and store them in a local macro
levelsof agegrp, local(agegroups)


* Generate a variable for absolute value of male population percentage for labels
gen population_pct_males = abs(population_pct_neg)

* Create formatted label variables for the scatter plots
gen str pct_males_label = string(population_pct_males, "%9.1f")
gen str pct_females_label = string(population_pct, "%9.1f")

* Calculate the maximum percentage value
summarize population_pct
local max_pct = ceil(r(max) / 10) * 10

* Generate a list of x-axis labels from 0 to max_pct in increments of 5
local xlabels
forvalues i = 0(5)`max_pct' {
    local xlabels `xlabels' `i'
}

* Generate a list of negative x-axis labels from -max_pct to -5 in increments of 5
local neg_xlabels
forvalues i = -`max_pct'(5)-5 {
    local neg_xlabels `neg_xlabels' `i'
}

* Combine the negative and positive labels, converting negative labels to positive for display
local xlabel_list
foreach label in `neg_xlabels' 0 `xlabels' {
    local abs_label = abs(`label')
    local xlabel_list `xlabel_list' `label' "`abs_label'"
}

* Plot the population pyramid
twoway (bar population_pct_neg agegrp if sex == 1, horizontal base(0) color(`p1')) ///
       (bar population_pct agegrp if sex == 2, horizontal base(0) color(`p2')) ///
       (scatter agegrp population_pct_neg if sex == 1, msymbol(i) mlab(pct_males_label) mlabcolor(gs0) mlabp(9)) ///
       (scatter agegrp population_pct if sex == 2, msymbol(i) mlab(pct_females_label) mlabcolor(gs0) mlabp(3)), ///
       ytitle("Age Group") xtitle("Population Percentage") ///
       legend(label(1 "Males") label(2 "Females")) ///
       title("Population Pyramid for the Year 2000") ///
	   subtitle("in percentages") ///
	   legend(order(1 "Males" 2 "Females")) ///
       ylabel(`agegroups', valuelabel angle(0)) ///
	   xlabel(`xlabel_list', format(%3.1f)) ///
       name("Pyramid_Percentage", replace)


* Clean up
drop total_population population population_pct population_pct_neg


*--------------------------------------------------------------------------*	
//# Absolute numbers version
*--------------------------------------------------------------------------*	

* Load the pop2000 dataset
sysuse pop2000.dta, clear

* Reshape the data for male population
preserve
	rename maletotal population
	gen sex = 1  // 1 for Male
	tempfile males
	save `males'
restore

* Reshape the data for female population
preserve
	rename femtotal population
	gen sex = 2  // 2 for Female
	tempfile females
	save `females'
restore

* Combine the reshaped datasets
use `males', clear
append using `females'

* Label the sex variable
label define sexlbl 1 "Male" 2 "Female"
label values sex sexlbl

* Create a variable for negative population for the pyramid
gen population_neg = -population if sex == 1

* Identify the unique age groups and store them in a local macro
levelsof agegrp, local(agegroups)

* Create formatted label variables for the scatter plots
gen str population_males_label = string(abs(population_neg), "%20.0fc")
gen str population_females_label = string(population, "%20.0fc")

* Calculate the maximum population value
summarize population
local max_population = ceil(r(max) / 10000000) * 10000000

* Generate a list of x-axis labels from 0 to max_population in increments of 10000000
local xlabels
forvalues i = 0(10000000)`max_population' {
    local xlabels `xlabels' `i'
}

* Generate a list of negative x-axis labels from -max_population to -10000000 in increments of 10000000
local neg_xlabels
forvalues i = -`max_population'(10000000)-10000000 {
    local neg_xlabels `neg_xlabels' `i'
}

* Combine the negative and positive labels, converting negative labels to positive for display
local xlabel_list
foreach label in `neg_xlabels' 0 `xlabels' {
    local abs_label = string(abs(`label'), "%20.0fc")
    local xlabel_list `xlabel_list' `label' "`abs_label'"
}

* Plot the population pyramid with scatter labels
twoway (bar population_neg agegrp if sex == 1, horizontal base(0) color(`p1')) ///
       (bar population agegrp if sex == 2, horizontal base(0) color(`p2')) ///
       (scatter agegrp population_neg if sex == 1, msymbol(i) mlab(population_males_label) mlabcolor(gs0) mlabp(9) mlabformat(%20.0fc)) ///
       (scatter agegrp population if sex == 2, msymbol(i) mlab(population_females_label) mlabcolor(gs0) mlabp(3) mlabformat(%20.0fc)), ///
       ytitle("Age Group") xtitle("Population size") ///
       legend(label(1 "Males") label(2 "Females")) ///
       title("Population Pyramid for the Year 2000") ///
       subtitle("in actual population numbers") ///
       legend(order(1 "Males" 2 "Females")) ///
       ylabel(`agegroups', valuelabel angle(0)) ///
       xlabel(`xlabel_list', format(%20.0fc)) ///
       name("Pyramid_Numbers", replace)

* Clean up
drop population population_neg population_males_label population_females_label