* Load the pop2000 dataset
sysuse pop2000.dta, clear

* Reshape the data for male population
rename maletotal population
gen sex = 1  // 1 for Male
tempfile males
save `males'

* Reshape the data for female population
sysuse pop2000.dta, clear
rename femtotal population
gen sex = 2  // 2 for Female
tempfile females
save `females'

* Combine the reshaped datasets
use `males', clear
append using `females'

* Label the sex variable
label define sexlbl 1 "Male" 2 "Female"
label values sex sexlbl

* Create a variable for negative male population for the pyramid
gen population_neg = -population if sex == 1
replace population_neg = population if sex == 2

* Plot the population pyramid
twoway (bar population_neg agegrp if sex == 1, horizontal base(0)) ///
       (bar population agegrp if sex == 2, horizontal base(0)), ///
       ytitle("Age Group") xtitle("Population Count") ///
       legend(label(1 "Males") label(2 "Females")) ///
       title("Population Pyramid of the Year 2000") ///
       ylabel(1(1)17, valuelabel) xlabel(, format(%10.0gc))
	   

