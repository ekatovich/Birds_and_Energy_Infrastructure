*Set working directory
clear
cd "${user}"

*Import circle-level land use data 

*****************
local years "2001 2004 2006 2008 2011 2016 2019"
foreach k of local years {
	
	clear 
	import delimited "Data\Intermediate\Circle_LandUse_Proportions_`k'.csv"

	capture drop v16 

		local vars "emergent_wetlands cultivated_crops barren_land open_water shrub_scrub developed_highintensity grassland woody_wetlands developed_medintensity pasture developed_openspace developed_lowintensity mixed_forest evergreen_forest deciduous_forest"
		foreach b of local vars {
		replace `b' = "0" if `b' == "NA"
		destring `b', replace 
}

	gen agricultural_land_share = cultivated_crops
	gen pasture_land_share = pasture
	gen ag_and_past_land_share = cultivated_crops + pasture
	gen developed_share_broad = developed_highintensity + developed_medintensity + developed_openspace + developed_lowintensity
	gen developed_share_narrow = developed_highintensity + developed_medintensity 
	
	keep circle_id agricultural_land_share pasture_land_share ag_and_past_land_share developed_share_broad developed_share_narrow

	gen year = `k'

	save "Data\Intermediate\Circle_LandUse_`k'", replace
}

use "Data\Intermediate\Circle_LandUse_2001", clear 
append using "Data\Intermediate\Circle_LandUse_2004", force
append using "Data\Intermediate\Circle_LandUse_2006", force 
append using "Data\Intermediate\Circle_LandUse_2008", force 
append using "Data\Intermediate\Circle_LandUse_2011", force 
append using "Data\Intermediate\Circle_LandUse_2016", force 
append using "Data\Intermediate\Circle_LandUse_2019", force 

sort circle_id year 
save "Data\Intermediate\Circle_LandUse_Panel", replace 

*********************************************************************************
*Write program to clean and merge CBC panel data with land use 
capture program drop process
program define process 

capture drop agricultural_land_share pasture_land_share ag_and_past_land_share developed_share_broad developed_share_narrow
capture drop ag_land_share past_land_share ag_past_land_share dev_share_broad dev_share_narrow

merge 1:1 circle_id year using "Data\Intermediate\Circle_LandUse_Panel"
keep if _merge != 2
drop _merge 

sort circle_id year 

rename agricultural_land_share ag_land_share
rename pasture_land_share past_land_share
rename ag_and_past_land_share ag_past_land_share
rename developed_share_broad dev_share_broad
rename developed_share_narrow dev_share_narrow

*Fill in missing values 
local land "ag_land_share past_land_share ag_past_land_share dev_share_broad dev_share_narrow"
foreach p of local land {
	*Fill in years around 2001
	bysort circle_id: replace `p' = `p'[_n+1] if year == 2000 & year[_n+1] == 2001
	bysort circle_id: replace `p' = `p'[_n-1] if year == 2002 & year[_n-1] == 2001
	
	*Fill in years around 2004
	bysort circle_id: replace `p' = `p'[_n+1] if year == 2003 & year[_n+1] == 2004
	bysort circle_id: replace `p' = `p'[_n-1] if year == 2005 & year[_n-1] == 2004
	
	*Fill in years around 2006
	bysort circle_id: replace `p' = `p'[_n-1] if year == 2007 & year[_n-1] == 2006
	
	*Fill in years around 2008
	bysort circle_id: replace `p' = `p'[_n-1] if year == 2009 & year[_n-1] == 2008
	
	*Fill in years around 2011
	bysort circle_id: replace `p' = `p'[_n+1] if year == 2010 & year[_n+1] == 2011
	bysort circle_id: replace `p' = `p'[_n-1] if year == 2012 & year[_n-1] == 2011
	bysort circle_id: replace `p' = `p'[_n-2] if year == 2013 & year[_n-2] == 2011
	
	*Fill in years around 2016
	bysort circle_id: replace `p' = `p'[_n+2] if year == 2014 & year[_n+2] == 2016
	bysort circle_id: replace `p' = `p'[_n+1] if year == 2015 & year[_n+1] == 2016
	bysort circle_id: replace `p' = `p'[_n-1] if year == 2017 & year[_n-1] == 2016
	
	*Fill in years around 2019
	bysort circle_id: replace `p' = `p'[_n+1] if year == 2018 & year[_n+1] == 2019
	bysort circle_id: replace `p' = `p'[_n-1] if year == 2020 & year[_n-1] == 2019
	
	bysort circle_id: egen `p'_2000_2003 = mean(`p') if year > 1999 & year < 2004
	bysort circle_id: egen `p'_2003_2006 = mean(`p') if year > 2002 & year < 2007
	bysort circle_id: egen `p'_2006_2008 = mean(`p') if year > 2005 & year < 2009
	bysort circle_id: egen `p'_2008_2011 = mean(`p') if year > 2007 & year < 2012
	bysort circle_id: egen `p'_2011_2016 = mean(`p') if year > 2010 & year < 2017
	bysort circle_id: egen `p'_2016_2020 = mean(`p') if year > 2015 & year < 2021
	
	bysort circle_id: replace `p' = `p'_2000_2003 if `p' == . & (year == 2000 | year == 2001 | year == 2002)
	bysort circle_id: replace `p' = `p'_2003_2006 if `p' == . & (year == 2003 | year == 2004 | year == 2005)
	bysort circle_id: replace `p' = `p'_2006_2008 if `p' == . & (year == 2006 | year == 2007 | year == 2008)
	bysort circle_id: replace `p' = `p'_2008_2011 if `p' == . & (year == 2009 | year == 2010 | year == 2011)
	bysort circle_id: replace `p' = `p'_2011_2016 if `p' == . & (year == 2012 | year == 2013 | year == 2014 | year == 2015 | year == 2016)
	bysort circle_id: replace `p' = `p'_2016_2020 if `p' == . & (year == 2017 | year == 2018 | year == 2019 | year == 2020)
	
	drop `p'_2000_2003 `p'_2003_2006 `p'_2006_2008 `p'_2008_2011 `p'_2011_2016 `p'_2016_2020
}

sort circle_id year

end 


*Execute program on all CBC panel variations 
use "Data\Analysis\CBC_Wind_Combined_Panel.dta", clear 
process 
save "Data\Analysis\CBC_Wind_Combined_Panel.dta", replace  

use "Data\Analysis\CBC_Wind_Combined_Panel_12_5_buffer.dta"
process
save "Data\Analysis\CBC_Wind_Combined_Panel_12_5_buffer.dta", replace  

use "Data\Analysis\CBC_Wind_Combined_Panel_17_5_buffer.dta"
process
save "Data\Analysis\CBC_Wind_Combined_Panel_17_5_buffer.dta", replace  

use "Data\Analysis\CBC_Wind_Combined_Panel_22_5_buffer.dta"
process
save "Data\Analysis\CBC_Wind_Combined_Panel_22_5_buffer.dta", replace  

use "Data\Analysis\CBC_Wind_Combined_Characteristics_Panel.dta"
process
save "Data\Analysis\CBC_Wind_Combined_Characteristics_Panel.dta", replace  

use "Data\Analysis\CBC_Wind_Combined_Characteristics_12_5_Panel.dta"
process
save "Data\Analysis\CBC_Wind_Combined_Characteristics_12_5_Panel.dta", replace  

use "Data\Analysis\CBC_Wind_Combined_Characteristics_17_5_Panel.dta"
process
save "Data\Analysis\CBC_Wind_Combined_Characteristics_17_5_Panel.dta", replace  

use "Data\Analysis\CBC_Wind_Combined_Characteristics_22_5_Panel.dta"
process
save "Data\Analysis\CBC_Wind_Combined_Characteristics_22_5_Panel.dta", replace  

use "Data\Analysis\CBC_Shale_Combined_Panel.dta"
process
save "Data\Analysis\CBC_Shale_Combined_Panel.dta", replace  

use "Data\Analysis\CBC_Shale_Combined_Panel_12_5_buffer.dta"
process
save "Data\Analysis\CBC_Shale_Combined_Panel_12_5_buffer.dta", replace  

use "Data\Analysis\CBC_Shale_Combined_Panel_17_5_buffer.dta"
process
save "Data\Analysis\CBC_Shale_Combined_Panel_17_5_buffer.dta", replace  

use "Data\Analysis\CBC_Shale_Combined_Panel_22_5_buffer.dta"
process
save "Data\Analysis\CBC_Shale_Combined_Panel_22_5_buffer.dta", replace  

use "Data\Analysis\CBC_Shale_Combined_Characteristics_Panel.dta"
process
save "Data\Analysis\CBC_Shale_Combined_Characteristics_Panel.dta", replace  

use "Data\Analysis\CBC_Shale_Combined_Characteristics_12_5_Panel.dta"
process
save "Data\Analysis\CBC_Shale_Combined_Characteristics_12_5_Panel.dta", replace  

use "Data\Analysis\CBC_Shale_Combined_Characteristics_17_5_Panel.dta"
process
save "Data\Analysis\CBC_Shale_Combined_Characteristics_17_5_Panel.dta", replace  

use "Data\Analysis\CBC_Shale_Combined_Characteristics_22_5_Panel.dta"
process
save "Data\Analysis\CBC_Shale_Combined_Characteristics_22_5_Panel.dta", replace  

