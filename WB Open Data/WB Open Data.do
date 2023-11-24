**# Install WB Open Data package
* ssc install wbopendata

**# All WDI Indicators for a single country

wbopendata, country(chn - China) clear

**# Download all WDI indicators of particular topic

wbopendata, language(en - English) topics(2 - Aid Effectiveness) clear

**# Download specific indicator [SI.POV.NAHC]
wbopendata, language(en - English) indicator(SI.POV.NAHC) clear 

**# Download specific indicator [SI.POV.NAHC] in long format
wbopendata, language(en - English) indicator(SI.POV.NAHC) long clear 

**# Download specific indicator [SI.POV.NAHC] in long format for the latest available year
wbopendata, language(en - English) indicator(SI.POV.NAHC) long clear latest

**# Download specific indicator for specific countries, and report in long
wbopendata, country(ago;bdi;chi;dnk;esp) indicator(sp.pop.0610.fe.un) clear

**# Download specific indicator, for specific countries and year, and report in long format
wbopendata, country(ago;bdi;chi;dnk;esp) indicator(sp.pop.0610.fe.un) year(2000:2010) clear  long

**# Map data (latest, long, specific indicator)
* ssc install spmap

cd "C:\Users\RAHMMOHA\OneDrive - UNHCR\Documents\GitHub\StataGists\WB Open Data"

sysuse world-c, clear
save "world-c_local.dta", replace

wbopendata, language(en - English) indicator(SI.POV.NAHC) long clear latest

local labelvar "`r(varlabel1)'"

sort countrycode

save "wbod_local.dta", replace

qui sysuse world-d, clear

qui merge countrycode using "wbod_local.dta"

qui sum year

local avg = string(`r(mean)',"%16.1f")

spmap  si_pov_nahc using "world-c_local", id(_ID)                                  ///
               clnumber(20) fcolor(Reds2) ocolor(none ..)                           ///
               title("`labelvar'", size(*1.2))         ///
               legstyle(3) legend(ring(1) position(3))                              ///
note("Source: World Development Indicators (latest available year: `avg')")