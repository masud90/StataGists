* ============================================================*
// DATA CLEANING IN STATA: REPLACING, RECODING, AND RESCALING //
* ============================================================*

// This guide is based on a tutorial by John V. Kane, Ph.D. (NYU)
// Original source: https://drive.google.com/file/d/1bBVAHJMDSpDOPiNs_o8noRw8jtIIMTUg/view

* ============================================================*

//# Load Data: auto.dta

sysuse auto.dta, clear

//# Generating variables & Replacing/ Recoding Values

* Generate a new numeric variable that is blank (i.e., missing all values):
set obs 74 // optional, but ensures you generate the right number of values
gen numeric_var = .

* Generate a new *string* (non-numeric) variable that is blank (i.e., missing all values):
gen string_var = ""

** Remember, if you ever make a mistake, simply drop the variable and start over:
drop string_var

* Quickly generate a single dummy variable based upon another variable (categorical or continuous):
gen highprice = price > 5000 // Note that this assigna a 1 to any observation for which price >= 5000, and 0 otherwise. Therefore this will also assign 0 to observations that are missing a value for "price". Thus a safer strategy is to include a condition as follows:
gen highprice2 = price > 5000 if price!=.

* Quickly generate a series of "dummy" (i.e., binary (0/1)) variables based on a categorical variable using "tab" with the "gen( )" option, also known as one-hot encoding:
tab foreign, gen(foreign_dummy)

* Duplicate a variable using clonevar command
** Numeric example:
clonevar foreign2 = foreign // copies variable AND value labels
** String example:
clonevar make2 = make

* Use "replace" and "if" to replace values of an existing variable:
** Example 1: Fill in values based on values of another variable (and then renaming the variable):
replace numeric_var = 0 if mpg<21.2973 // make numeric_var = 0 if mpg is less than the mean (21.2973)
replace numeric_var = 1 if mpg>=21.2973 // make numeric_var = 1 if mpg is greater than or equal to mean

rename numeric_var OverUnderAvgMPG // renaming syntax: rename oldname newname

**Example 2: Generate a variable, based on another variable, for a particular subset of the data:
gen numeric_var_foreign = .
replace numeric_var_foreign = numeric_var if foreign == 1 // here we are making a new variable (numeric_var_foreign). It will be equal to "numeric_var" but ONLY if an observation satisfies the condition that "foreign" is equal to 1.

* Using multiple conditional arguments:
gen numeric_var2a = turn if OverUnderAvgMPG == 1 & foreign == 1 //must satisfy BOTH conditions
gen numeric_var2o = turn if OverUnderAvgMPG == 0 | foreign == 0 //must satisfy AT LEAST ONE condition

** Example 3: Make an observation blank ("missing") based on some identifying variable:
replace numeric_var_foreign = . if make == "Toyota Celica"

** Example 4: Make a categorical variable from different ranges of a continuous one using inrange(x, min, max) option:
gen numeric_var3 = .
replace numeric_var3 = 1 if inrange(trunk, 1, 10) // syntax: inrange(var, min, max)
replace numeric_var3 = 2 if inrange(trunk, 11, 20)
replace numeric_var3 = 3 if inrange(trunk, 21, 25)

** Example 5: Same procedure, but using inlist(x, "name", "name"), which calls values from a string variable:

gen numeric_var4 = 1 if inlist(make, "AMC Concord", "AMC Pacer", "AMC Spirit")
replace numeric_var4 = 2 if inlist(make, "Toyota Celica", "Toyota Corolla", "Toyota Corona")

* Replace values of a string variable:
input str10(string_var2)
"1"
"2"
"Three"
"4"
"5"
end
replace string_var2 = "3" if string_var2 == "Three"

* Make a numerica variable from an existing string variable using encode:
split make2, parse(, " ")
tab make21

encode make21, gen(Make_numeric)
tab Make_numeric
tab Make_numeric, nolabel

* Make a string variable from an existing numeric variable using decode or tostring :

decode Make_numeric, gen(Make_String)
tostring Make_numeric, gen(Make_String2)

* Make a string variable numeric but without generating a new variable (exercise caution!):

destring string_var2, replace // if the values are not all numeric, you can use "force" option but this will delete any non-numeric values/cells

destring string_var2, replace force

* Using recode (often more efficient than using gen/replace, especially with categorical variables that have only a few values)
** Example without "generate" option (will change the values of existing variable):
recode foreign (0=1 "Domestic Cars") (1=0 "Foreign Cars") (9=.)
** Example with "generate" option (doesn't change original variable; instead generates new variable with recoded values):
recode foreign (0=1 "Domestic Cars") (1=0 "Foreign Cars") (9=.), gen(Domestic)

//# Rescaling Variables

* Rescaling a continuous variable to range from 0 to 1 using "returned" ("r( )") results:

sum price // obtain min and max values
gen price_01 = (price-r(min)) / (r(max) - r(min)) // requires previous command

* Reversing a variable's scaling:
** Example with a continuous variable using returned results:
sum weight
gen lightness = -weight + r(min) + r(max) // make var negative then add original min and max. Notice the minus sign in front of "weight"

** Example with a discrete variable using "revrs" (from ssc):
****Upside: retains value labels
****Downside: Always begins at 1 regardless of original starting value
ssc install revrs, replace // install revrs
revrs foreign // will keep value labels but makes lowest value = 1
tab rr_foreign // has value labels

** Example with a discrete variable using "omscore":
****Upside: Starts at original variable's lowest value
****Downside: No value labels

net install dm7, from("http://www.stata.com/stb/stb7") // installs "omscore"
omscore foreign // Will begin at lowest value of variable
tab revforeign // does not have value labels

* Mean-Centering a variable using returned results:
sum headroom
gen headroom_meancentered = headroom-(r(mean))

* Rescaling a variable in standard-deviation units:
** Example using returned results:
sum length
gen length_SDUs = (length - r(mean))/r(sd) //subtracts mean from each value, then divides by the SD

** Example using egen command:
egen length_SDUs2 = std(length)

* Generating a natural log of a variable:
gen price_logged = ln(price)

* Generating a variable raised to a particular power:
gen mpg_squared = mpg^2
gen mpg_cubed = mpg^3

//# BONUS: Useful Label-Related Commands You Might Not Know About:
codebook, compact // see all variables in dataset, their means/min/max and variable labels
labelbook, Make_numeric // see ALL value labels contained within a particular set of value labels
labelbook // see ALL value labels for EVERY set of labels

varmanage // access all variables to manually change variable labels and/ or value labels

* "fre" is a user-written package to view all values of a variable and their labels
ssc install fre, replace
fre foreign