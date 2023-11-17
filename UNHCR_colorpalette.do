******************************************************************************
******************** UNHCR Brand Color Palette for Stata *********************
******************************************************************************
******************************************************************************
* Masud Rahman | rahmmoha@unhcr.org
* April 02, 2023
******************************************************************************

// Load example dataset
sysuse bplong.dta 

// Plot an example graph in default style
graph bar (mean) bp, over(agegrp) over(when) asyvars blabel(bar, format(%3.0f)) ytitle(Mean of blood pressure) title("This graph follows the default Stata style") name(default_style, replace)


// Install dependencies
* ssc install grstyle, replace
* ssc install palettes, replace
* ssc install colrspace, replace

// Set UNHCR color palette with the two following lines
grstyle init
grstyle set color #0072BC #18375F #00B398 #666666 #EF4A60 #FAEB00

// Plot an example graph
graph bar (mean) bp, over(agegrp) over(when) asyvars blabel(bar, format(%3.0f)) ytitle(Mean of blood pressure) title("This graph follows the UNHCR Color Palette") name(unhcr_colors, replace)

// Set background as white for all following plots for a clean look
grstyle color background white

// Plot another example graph
graph bar (mean) bp, over(agegrp) over(when) asyvars blabel(bar, format(%3.0f)) ytitle(Mean of blood pressure) title("This graph follows the UNHCR Color Palette" "with White Background") name(unhcr_colors_clean, replace)

// Resets the style if you want to use default or other schemes
grstyle clear 

// For LaTeX font consistency, please download and install Computer Modern TTF font from https://www.fontsquirrel.com/fonts/computer-modern and then run the following command:
graph set window fontface "CMU Serif Roman"