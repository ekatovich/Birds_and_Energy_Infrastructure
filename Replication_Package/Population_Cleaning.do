clear
cd "${user}\Data"

*Source: https://seer.cancer.gov/popdata/popdic.html
*SEER Data Dictionary for U.S. County Population Estimates - SEER Population Data

import delimited "Raw\us.1969_2020.19ages.adjusted\us.1969_2020.19ages.adjusted.txt"

rename v1 string 

gen year = substr(string,1,4)
destring year, replace 

drop if year < 2000

gen state_initials = substr(string,5,2)
gen state_fips = substr(string,7,2)
gen county_fips = substr(string,9,3)
gen state_county_fips = substr(string,7,5)
gen registry = substr(string,12,2)
gen race = substr(string,14,1)
gen origin = substr(string,15,1)
gen sex = substr(string,16,1)
gen age = substr(string,17,2)
gen population = substr(string,19,8)

destring age, replace 
destring population, replace 
drop string 

sort state_initials county_fips year 

*Collapse to total population 
collapse (firstnm) state_initials state_fips registry (sum) population, by(state_county_fips year)

rename state_county_fips FIPS
rename population panel_population

save "Intermediate\US_Counties_Population_Panel_2000_2020", replace 
export delimited using "Intermediate\Population_Panel_2000_2020.csv", replace
