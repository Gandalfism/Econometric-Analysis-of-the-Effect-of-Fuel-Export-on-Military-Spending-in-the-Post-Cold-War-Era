* Econometric Analysis of the Effect of Fuel Export on Military Spending in the Post Cold-War Era
* Contributors : Jackson Buick, Tyler Hawes, Shailin Vaid

* the following is our attempt to combine all data files into one single file format
import delimited "Data\API_BX.KLT.DINV.WD.GD.ZS_DS2_en_csv_v2_4700998\API_BX.KLT.DINV.WD.GD.ZS_DS2_en_csv_v2_4700998.csv", varnames(1) clear
forvalues x=5(1)66{
local y= `x'+1955
rename v`x' fdi`y' 
}
reshape long fdi, i(countryname) j(year)
keep countryname year fdi 
save "fdiWB.dta", replace

import delimited "Data\API_EN.ATM.CO2E.PC_DS2_en_csv_v2_4700403\API_EN.ATM.CO2E.PC_DS2_en_csv_v2_4700403.csv", varnames(1) clear
forvalues x=5(1)66{
local y= `x'+1955
rename v`x' CO2`y' 
}
reshape long CO2, i(countryname) j(year)
keep countryname year CO2 
save "CO2WB.dta", replace

import delimited "Data\API_MS.MIL.XPND.GD.ZS_DS2_en_csv_v2_4700987\API_MS.MIL.XPND.GD.ZS_DS2_en_csv_v2_4700987.csv", varnames(1) clear
forvalues x=5(1)66{
local y= `x'+1955
rename v`x' milex`y' 
}
reshape long milex, i(countryname) j(year)
keep countryname year milex
save "milexWB.dta", replace

import delimited "Data\API_SI.POV.GINI_DS2_en_csv_v2_4701295\API_SI.POV.GINI_DS2_en_csv_v2_4701295.csv", varnames(1) clear
forvalues x=5(1)66{
local y= `x'+1955
rename v`x' gini`y' 
}
reshape long gini, i(countryname) j(year)
keep countryname year gini
save "giniWB.dta", replace

import delimited "Data\API_TX.VAL.FUEL.ZS.UN_DS2_en_csv_v2_4690190\API_TX.VAL.FUEL.ZS.UN_DS2_en_csv_v2_4690190.csv", varnames(1) clear
forvalues x=5(1)66{
local y= `x'+1955
rename v`x' fuel`y' 
}
reshape long fuel, i(countryname) j(year)
keep countryname year fuel
save "fuelWB.dta", replace

use "fdiWB.dta", clear
merge 1:1 countryname year using "CO2WB.dta"
keep if _merge==3
drop _merge
save "finaldata.dta", replace

use "finaldata.dta", clear
merge 1:1 countryname year using "milexWB.dta"
keep if _merge==3
drop _merge
save "finaldata.dta", replace

use "finaldata.dta", clear
merge 1:1 countryname year using "giniWB.dta"
keep if _merge==3
drop _merge
save "finaldata.dta", replace

use "finaldata.dta", clear
merge 1:1 countryname year using "fuelWB.dta"
keep if _merge==3
drop _merge
save "finaldata.dta", replace

drop if countryname=="Early-demographic dividend" | countryname=="East Asia & Pacific (IDA & IBRD countries)" | countryname=="East Asia & Pacific (excluding high income)" | countryname=="Europe & Central Asia (IDA & IBRD countries)" | countryname=="Europe & Central Asia (excluding high income)" | countryname=="Fragile and conflict affected situations" | countryname=="Heavily indebted poor countries (HIPC)" | countryname=="High income" | countryname=="IBRD only" | countryname=="IDA & IBRD total" | countryname=="IDA blend" | countryname=="IDA only" |countryname=="IDA total" | countryname=="Lao PDR" | countryname=="Late-demographic dividend" | countryname=="Latin America & Caribbean (excluding high income)" | countryname=="Latin America & the Caribbean (IDA & IBRD countries)" | countryname=="Least developed countries: UN classifications" | countryname=="Low and middle income" | countryname=="Low income" | countryname=="Middle East & North Africa (IDA & IBRD countries)" | countryname=="Low income" | countryname=="Middle East & North Africa (excluding high income)" | countryname=="Not classified" | countryname=="OECD members" | countryname=="Other small states" | countryname=="Post-demographic dividend" | countryname=="Pre-demographic dividend" | countryname=="Small states" | countryname=="South Asia (IDA & IBRD)" | countryname=="Sub-Saharan Africa (IDA & IBRD countries)" | countryname=="Sub-Saharan Africa (excluding high income)" | countryname=="Upper middle income" | countryname=="World" | countryname=="Africa Eastern and Southern" | countryname=="Africa Western and Central" | | countryname=="Arab World" | countryname=="Caribbean small states" | countryname=="Central Europe and the Baltics" | countryname=="East Asia & Pacific" | countryname=="Euro area" | countryname=="Europe & Central Asia" | countryname=="European Union" | countryname=="Latin America & Caribbean" | countryname=="Least developed countries: UN classification" | countryname=="Low & middle income" | countryname=="Lower middle income" | countryname=="Middle East & North Africa" | countryname=="Middle income" | countryname=="North America" | countryname=="Pacific island small states" | countryname=="Sub-Saharan Africa" | countryname=="Least developed countries: UN classification" | countryname=="Africa Eastern and Southern" | countryname=="Africa Western and Central" | countryname=="Arab World" | countryname=="Caribbean small states" | countryname=="Central Europe and the Baltics" | countryname=="East Asia & Pacific" | countryname=="Euro area" | countryname=="Europe & Central Asia" | countryname=="European Union" | countryname=="Latin America & Caribbean" | countryname =="Low & middle income" | countryname =="Lower middle income" | countryname =="Middle East & North Africa" |countryname=="Middle income" | countryname=="Pacific island small states" 

* We also decided to drop data before 1991 to restrict the time period which we study
drop if year < 1991
drop if year > 2019

* Now we will run the first regression
regress milex fuel, robust
predict fitted1
twoway scatter milex fuel || line fitted1 fuel, sort
display e(r2_a)

* There were some strong outliers (Kuwait 1991 and Eritrea 1999 had abnormally high military expenditure), so we will code them out and try again
generate milex_no_outliers = (milex + 0.0000000001)
replace milex_no_outliers = . if milex > 40
generate fuel_no_outliers = fuel
replace fuel_no_outliers = . if fuel > 100
regress milex_no_outliers fuel_no_outliers, robust
predict fitted2
twoway scatter milex_no_outliers fuel_no_outliers, title("Military Expenditure (% of GDP)" "vs Fuel Exports (% of Merchandise Exports)" "Linear Regression with Extra Data") ytitle("Military Expenditure (% of GDP)") xtitle("Fuel Exports (% of Merchandise Exports)") legend(off) || line fitted2 fuel_no_outliers, sort
display e(r2_a)

* We also tried removing all values of zero fuel emissions or zero military expenditure here, though that didn't seem to effect the data much, so we did not use these values
generate milex_no_zeroes = milex_no_outliers
replace milex_no_zeroes = . if milex == 0
generate fuel_no_zeroes = fuel_no_outliers
replace fuel_no_zeroes = . if fuel == 0
regress milex_no_zeroes fuel_no_zeroes, robust
predict fitted3
twoway scatter milex_no_zeroes fuel_no_zeroes || line fitted3 fuel_no_zeroes, sort
display e(r2_a)

* Following this, we decided to check the other variables for potential outliers to exclude, starting with CO2 per capita
summarize CO2, detail
regress milex_no_outliers CO2, robust
predict fitted4
twoway scatter milex_no_outliers CO2 || line fitted4 CO2, sort
display e(r2_a)

regress fuel_no_outliers CO2, robust
predict fitted5
twoway scatter fuel_no_outliers CO2 || line fitted5 CO2, sort
display e(r2_a)

* Next we look at foreign direct investment
summarize fdi, detail
regress milex_no_outliers fdi, robust
predict fitted6
twoway scatter milex_no_outliers fdi || line fitted6 fdi, sort
display e(r2_a)

* There were also two microstates yielding useless outlier data overall which were simply excluded from all calculations (Cayman Islands and Liechtenstein)
generate fdi_no_outliers = fdi
replace fdi_no_outliers = . if fdi < -100
replace fdi_no_outliers = . if countryname == "Cayman Islands"
replace fdi_no_outliers = . if countryname == "Liechtenstein"
regress milex_no_outliers fdi_no_outliers, robust
predict fitted7
twoway scatter milex_no_outliers fdi_no_outliers || line fitted7 fdi_no_outliers, sort
display e(r2_a)

regress fuel_no_outliers fdi_no_outliers, robust
predict fitted8
twoway scatter fuel_no_outliers fdi_no_outliers || line fitted8 fdi_no_outliers, sort
display e(r2_a)

* And finally we consider the gini index of income inequality
summarize gini, detail
regress milex_no_outliers gini, robust
predict fitted9
twoway scatter milex_no_outliers gini || line fitted9 gini, sort
display e(r2_a)

regress fuel_no_outliers gini, robust
predict fitted10
twoway scatter fuel_no_outliers gini || line fitted10 gini, sort
display e(r2_a)

* With all this considered, we decided to create another milex variable, which doesn't include any of the missing data from the control variables, so as to keep the sample size in all regressions stable and consistent, and we did the same for the other variables
generate milex_control_adjusted = milex_no_outliers
replace milex_control_adjusted = . if fuel_no_outliers == .
replace milex_control_adjusted = . if milex_no_outliers == .
replace milex_control_adjusted = . if CO2 == .
replace milex_control_adjusted = . if fdi_no_outliers == .
replace milex_control_adjusted = . if gini == .

generate fuel_control_adjusted = fuel_no_outliers
replace fuel_control_adjusted = . if milex_control_adjusted == .
generate CO2_control_adjusted = CO2
replace CO2_control_adjusted = . if milex_control_adjusted == .
generate fdi_control_adjusted = fdi_no_outliers
replace fdi_control_adjusted = . if milex_control_adjusted == .
generate gini_control_adjusted = gini
replace gini_control_adjusted = . if milex_control_adjusted == .

summarize milex, detail
summarize milex_control_adjusted, detail
summarize fuel, detail
summarize fuel_control_adjusted, detail
summarize CO2, detail
summarize CO2_control_adjusted, detail
summarize fdi, detail
summarize fdi_control_adjusted, detail
summarize gini, detail
summarize gini_control_adjusted, detail

regress milex_control_adjusted fuel_control_adjusted, robust
predict fitted11
twoway scatter milex_control_adjusted fuel_control_adjusted, title("Military Expenditure (% of GDP)" "vs Fuel Exports (% of Merchandise Exports)" "Linear Regression") ytitle("Military Expenditure (% of GDP)") xtitle("Fuel Exports (% of Merchandise Exports)") legend(off) || line fitted11 fuel_control_adjusted, sort
display e(r2_a)

* With that considered, we run our second main regression of military expenditure on fuel exports, an exponential regression
generate fuel_control_adjusted_sq = fuel_control_adjusted*fuel_control_adjusted
regress milex_control_adjusted fuel_control_adjusted fuel_control_adjusted_sq, robust
predict fitted12
twoway scatter milex_control_adjusted fuel_control_adjusted, title("Military Expenditure (% of GDP)" "vs Fuel Exports (% of Merchandise Exports)" "Quadratic Regression") ytitle("Military Expenditure (% of GDP)") xtitle("Fuel Exports (% of Merchandise Exports)") legend(off) || line fitted12 fuel_control_adjusted, sort
display e(r2_a)

* Then we consider a logarithmic regression
generate lnmilex = ln(milex_control_adjusted)
regress lnmilex fuel_control_adjusted, robust
predict fitted13
twoway scatter lnmilex fuel_control_adjusted, title("Natural Log of Military Expenditure (% of GDP)" "vs Fuel Exports (% of Merchandise Exports)" "Logarithmic Regression") ytitle("Natural Log of Military Expenditure (% of GDP)") xtitle("Fuel Exports (% of Merchandise Exports)") legend(off) || line fitted13 fuel_control_adjusted, sort
display e(r2_a)

* Finally, we run a linear regression considering all our control variables
regress milex_control_adjusted fuel_control_adjusted CO2_control_adjusted fdi_control_adjusted gini_control_adjusted, robust
display e(r2_a)

* And also consider panel data by country and by year
egen countrynameid = group(countryname), label lname(countryname)
regress milex_control_adjusted fuel_control_adjusted CO2_control_adjusted fdi_control_adjusted gini_control_adjusted i.countrynameid, cluster(countrynameid)
display e(r2_a)

egen yearid = group(year), label lname(year)
regress milex_control_adjusted fuel_control_adjusted CO2_control_adjusted fdi_control_adjusted gini_control_adjusted i.yearid, cluster(yearid)
display e(r2_a)

regress milex_control_adjusted fuel_control_adjusted CO2_control_adjusted fdi_control_adjusted gini_control_adjusted i.countrynameid i.yearid, cluster(countrynameid)
display e(r2_a)