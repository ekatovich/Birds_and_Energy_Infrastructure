*Set working directory
clear
cd "${user}\Data"

********************************************************************************
*Import and Clean Species Data
*First, 101-105 counts
import excel "Raw\US-101-105-CBC_Circle_Species_Report_SQL_updated.xlsx", sheet("Sheet1") firstrow

*Basic variable cleaning
rename Abbrev circle
rename Name circle_name 
rename Longitude longitude
rename Latitude latitude
rename Subnational_code state_tmp
gen state = substr(state_tmp, 4, 5)
gen year = substr(Cnt_dt, 1, 4)
destring year, replace 
gen count_date = substr(Cnt_dt, 6, 10)

*gen count_date = date(count_date, "MD")
*format count_date2 %td

drop Country_code Count_yr Cnt_dt state_tmp 
rename TotalSpecies total_species
rename COM_NAME common_name
rename SCI_NAME scientific_name
rename how_many number_seen
drop Editor_comment SORT_CBC 

order circle circle_name latitude longitude state year count_date

*Drop year with missing values
drop if year == 2005

save "Intermediate\Species_2000_to_2004", replace 

********************************************************************************
*Repeat for 106-110 species data 
clear
import excel "Raw\US-106-110-CBC_Circle_Species_Report_SQL_updated.xlsx", sheet("Sheet1") firstrow

*Basic variable cleaning
rename Abbrev circle
rename Name circle_name 
rename Longitude longitude
rename Latitude latitude
rename Subnational_code state_tmp
gen state = substr(state_tmp, 4, 5)
gen year = substr(Cnt_dt, 1, 4)
destring year, replace 
gen count_date = substr(Cnt_dt, 6, 10)

*gen count_date = date(count_date, "MD")
*format count_date2 %td

drop Country_code Count_yr Cnt_dt state_tmp 
rename TotalSpecies total_species
rename COM_NAME common_name
rename SCI_NAME scientific_name
rename how_many number_seen
drop Editor_comment SORT_CBC 

order circle circle_name latitude longitude state year count_date

*Drop year with missing values
drop if year == 2010

save "Intermediate\Species_2005_to_2009", replace 

********************************************************************************
*Repeat for 111-115 species data 
clear
import excel "Raw\US-111-115-CBC_Circle_Species_Report_SQL_updated.xlsx", sheet("Sheet1") firstrow

*Basic variable cleaning
rename Abbrev circle
rename Name circle_name 
rename Longitude longitude
rename Latitude latitude
rename Subnational_code state_tmp
gen state = substr(state_tmp, 4, 5)
gen year = substr(Cnt_dt, 1, 4)
destring year, replace 
gen count_date = substr(Cnt_dt, 6, 10)

*gen count_date = date(count_date, "MD")
*format count_date2 %td

drop Country_code Count_yr Cnt_dt state_tmp 
rename TotalSpecies total_species
rename COM_NAME common_name
rename SCI_NAME scientific_name
rename how_many number_seen
drop Editor_comment SORT_CBC 

order circle circle_name latitude longitude state year count_date

*Drop year with missing values
drop if year == 2015

save "Intermediate\Species_2010_to_2014", replace 

********************************************************************************
*Repeat for 116-119 species data 
clear
import excel "Raw\US-116-119-CBC_Circle_Species_Report_SQL_updated.xlsx", sheet("Sheet1") firstrow

*Basic variable cleaning
rename Abbrev circle
rename Name circle_name 
rename Longitude longitude
rename Latitude latitude
rename Subnational_code state_tmp
gen state = substr(state_tmp, 4, 5)
gen year = substr(Cnt_dt, 1, 4)
destring year, replace 
gen count_date = substr(Cnt_dt, 6, 10)

*gen count_date = date(count_date, "MD")
*format count_date2 %td

drop Country_code Count_yr Cnt_dt state_tmp 
rename TotalSpecies total_species
rename COM_NAME common_name
rename SCI_NAME scientific_name
rename how_many number_seen
drop Editor_comment SORT_CBC 

order circle circle_name latitude longitude state year count_date

*Drop year with missing values
drop if year == 2019

save "Intermediate\Species_2015_to_2018", replace 

********************************************************************************
*Repeat for 120 species data 
clear
import excel "Raw\US-120-CBC_Circle_Species_Report_SQL_updated.xlsx", sheet("Sheet1") firstrow

*Basic variable cleaning
rename Abbrev circle
rename Name circle_name 
rename Longitude longitude
rename Latitude latitude
rename Subnational_code state_tmp
gen state = substr(state_tmp, 4, 5)
gen year = substr(Cnt_dt, 1, 4)
destring year, replace 
gen count_date = substr(Cnt_dt, 6, 10)

*gen count_date = date(count_date, "MD")
*format count_date2 %td

drop Country_code Count_yr Cnt_dt state_tmp 
rename TotalSpecies total_species
rename COM_NAME common_name
rename SCI_NAME scientific_name
rename how_many number_seen
drop Editor_comment SORT_CBC 

order circle circle_name latitude longitude state year count_date

*Drop year with missing values
drop if year == 2020

save "Intermediate\Species_2019", replace 

********************************************************************************
*Repeat for 121 species data 
clear
import excel "Raw\US-121-CBC_Circle_Species_Report_SQL_updated.xlsx", sheet("Sheet1") firstrow

*Basic variable cleaning
rename Abbrev circle
rename Name circle_name 
rename Longitude longitude
rename Latitude latitude
rename Subnational_code state_tmp
gen state = substr(state_tmp, 4, 5)
gen year = substr(Cnt_dt, 1, 4)
destring year, replace 
gen count_date = substr(Cnt_dt, 6, 10)

*gen count_date = date(count_date, "MD")
*format count_date2 %td

drop Country_code Count_yr Cnt_dt state_tmp 
rename TotalSpecies total_species
rename COM_NAME common_name
rename SCI_NAME scientific_name
rename how_many number_seen
drop Editor_comment SORT_CBC 

order circle circle_name latitude longitude state year count_date

*Drop year with missing values
drop if year == 2021

save "Intermediate\Species_2020", replace 

********************************************************************************
*Import species name corrections 
clear
import delimited "Raw\Bird_Name_Corrections_V1.csv", varnames(1) 

save "Intermediate\Bird_Name_Corrections_V1", replace 

********************************************************************************
*Import genus-order crosswalk
clear
import delimited "Raw\bird_genus_order_crosswalk.csv", varnames(1) 

save "Intermediate\bird_genus_order_crosswalk", replace 

********************************************************************************
*Append datasets into full 2000-2020 species panel 
use "Intermediate\Species_2000_to_2004", clear 
append using "Intermediate\Species_2005_to_2009", force 
append using "Intermediate\Species_2010_to_2014", force
append using "Intermediate\Species_2015_to_2018", force
append using "Intermediate\Species_2019", force
append using "Intermediate\Species_2020", force

sort state circle year common_name 

********************************************************************************
*Merge in effort data 
merge m:1 circle year using "Intermediate\Effort_Panel"

*Drop obs that didn't merge? Look into merge problems 
drop if _merge != 3
drop _merge 

********************************************************************************
*Merge in weather data 
merge m:1 circle year using "Intermediate\Weather_Panel"

drop if _merge != 3
drop _merge 

*Generate numeric circle IDs
egen circle_id = group(circle)
order circle_id

replace state = "MN" if state == "mn"
replace state = "WI" if state == "wi"
replace state = "FL" if state == "fl"
replace state = "MA" if state == "ma"

*Keep key variables and export to CSV for mapping 
preserve 

*Check that all circles are balanced across panel 
gen counter = 1
collapse (firstnm) circle circle_name state (mean) counter latitude longitude, by(circle_id year)
collapse (firstnm) circle circle_name state (mean) counter latitude longitude, by(circle_id)
drop counter 
drop if state == "HI" | state == "AK" | state == "PR" | state == "GU"
export delimited using "${user}\Data\Intermediate\CBC_Circle_Centroids.csv", replace

restore 


********************************************************************************
*Categorize species by order
merge m:1 scientific_name using "Intermediate\Bird_Name_Corrections_V1"

replace scientific_name = corrected_scientific_name if _merge == 3
drop _merge corrected_scientific_name

*Extract genus (first word in scientific name)
gen genus = substr(scientific_name, 1, strpos(scientific_name, " ") - 1) 
replace genus = "Emberiza" if scientific_name == "Emberiza"

*Merge in order by genus 
merge m:1 genus using "Intermediate\bird_genus_order_crosswalk"
keep if _merge == 3
drop _merge 

********************************************************************************
*Compute number of species, total population, and population per search hour by CBC circle 
sort circle_id year

gen total_effort_hours = hrs_feeder + hrs_noctural
gen total_effort_counters = num_counters_field + num_counters_feeder

*Manually sum total species, since reported variable has some strangely high values 
*First, collapse to number of unique species 
egen species_id = group(scientific_name)
collapse (firstnm) circle circle_name latitude longitude state common_name Min_temp Max_temp Min_wind Max_wind WindDirection Min_snow Max_snow StillWater MovingWater AMCloud PMCloud Am_rain_cond_Names Pm_rain_cond_Names Am_snow_cond_Names Pm_snow_cond_Names scientific_name genus order (sum) number_seen (mean) total_effort_hours total_effort_counters, by(circle_id year species_id)

*Count number of species seen per circle year 
gen species_counter = 1
bysort circle_id year: egen total_species_manual = sum(species_counter)

*Winsorize to remove extreme outliers in number of birds seen 
winsor2 number_seen, cuts(0 99) by(year) 

*Compute population and number of species by order 
local orders "Accipitriformes Anseriformes Apodiformes Caprimulgiformes Charadriiformes Ciconiiformes Columbiformes Coraciiformes Cuculiformes Falconiformes Galliformes Gaviiformes Gruiformes Passeriformes Pelecaniformes Phaethontiformes Phoenicopteriformes Piciformes Podicipediformes Procellariiformes Psittaciformes Strigiformes Suliformes Trogoniformes"
foreach i of local orders {
	gen `i'_num = 0
	replace `i'_num = number_seen_w if order == "`i'"
	
	gen `i'_species = 0
	replace `i'_species = 1 if order == "`i'"
}

save "Analysis\CBC_SpeciesLevel_Panel", replace 

************************************************
*Collapse to circle-year level 
collapse (firstnm) circle circle_name latitude longitude state Min_temp Max_temp Min_wind Max_wind WindDirection Min_snow Max_snow StillWater MovingWater AMCloud PMCloud Am_rain_cond_Names Pm_rain_cond_Names Am_snow_cond_Names Pm_snow_cond_Names (sum) number_seen number_seen_w Accipitriformes_num Accipitriformes_species Anseriformes_num Anseriformes_species Apodiformes_num Apodiformes_species Caprimulgiformes_num Caprimulgiformes_species Charadriiformes_num Charadriiformes_species Ciconiiformes_num Ciconiiformes_species Columbiformes_num Columbiformes_species Coraciiformes_num Coraciiformes_species Cuculiformes_num Cuculiformes_species Falconiformes_num Falconiformes_species Galliformes_num Galliformes_species Gaviiformes_num Gaviiformes_species Gruiformes_num Gruiformes_species Passeriformes_num Passeriformes_species Pelecaniformes_num Pelecaniformes_species Phaethontiformes_num Phaethontiformes_species Phoenicopteriformes_num Phoenicopteriformes_species Piciformes_num Piciformes_species Podicipediformes_num Podicipediformes_species Procellariiformes_num Procellariiformes_species Psittaciformes_num Psittaciformes_species Strigiformes_num Strigiformes_species Suliformes_num Suliformes_species Trogoniformes_num Trogoniformes_species (mean) total_species_manual total_effort_counters total_effort_hours, by(circle_id year)

gen number_seen_per_counter = number_seen / total_effort_counters
gen number_seen_per_hour = number_seen / total_effort_hours 
gen species_seen_per_counter = total_species_manual / total_effort_counters
gen species_seen_per_hour = total_species_manual / total_effort_hours

gen number_seen_per_counter_w = number_seen_w / total_effort_counters
gen number_seen_per_hour_w = number_seen_w / total_effort_hours 

*Drop missing per hour values 
*drop number_seen_per_hour number_seen_per_hour_w species_seen_per_hour

*Compute simple biodiversity index: number of species in the circle / number of individuals in the circle 
gen biodiversity_index = total_species_manual / number_seen 
gen biodiversity_index_normal = species_seen_per_counter / number_seen_per_counter

gen biodiversity_index_w = total_species_manual / number_seen_w 
gen biodiversity_index_normal_w = species_seen_per_counter / number_seen_per_counter_w

*Compute population and number of species by order 
local orders "Accipitriformes Anseriformes Apodiformes Caprimulgiformes Charadriiformes Ciconiiformes Columbiformes Coraciiformes Cuculiformes Falconiformes Galliformes Gaviiformes Gruiformes Passeriformes Pelecaniformes Phaethontiformes Phoenicopteriformes Piciformes Podicipediformes Procellariiformes Psittaciformes Strigiformes Suliformes Trogoniformes"
foreach i of local orders {
	gen `i'_num_pc = `i'_num / total_effort_counters 
	gen `i'_spec_pc = `i'_species / total_effort_counters
	gen `i'_num_ph = `i'_num / total_effort_hours 
	gen `i'_spec_ph = `i'_species / total_effort_hours
	gen `i'_bio = `i'_spec_pc / `i'_num_pc
	replace `i'_bio = 0 if `i'_bio == .
}

*Drop birds from Alaska or Hawaii
drop if state == "AK" | state == "HI"

sort circle_id year

*Transform variables using inverse hyperbolic sine 
local vars "number_seen number_seen_w number_seen_per_counter number_seen_per_hour number_seen_per_hour_w species_seen_per_counter species_seen_per_hour number_seen_per_counter_w Accipitriformes_num Accipitriformes_species Anseriformes_num Anseriformes_species Charadriiformes_num Charadriiformes_species Columbiformes_num Columbiformes_num_pc Columbiformes_species Columbiformes_spec_pc Columbiformes_num_ph Columbiformes_spec_ph Passeriformes_num Passeriformes_species Pelecaniformes_num Pelecaniformes_species Strigiformes_num Strigiformes_species Falconiformes_num Falconiformes_species Accipitriformes_num_pc Accipitriformes_spec_pc Anseriformes_num_pc Anseriformes_spec_pc Charadriiformes_num_pc Charadriiformes_spec_pc Falconiformes_num_pc Falconiformes_spec_pc Passeriformes_num_pc Passeriformes_spec_pc Passeriformes_bio Pelecaniformes_num_pc Pelecaniformes_spec_pc Strigiformes_spec_pc Strigiformes_num_pc Accipitriformes_num_ph Accipitriformes_spec_ph Anseriformes_num_ph Anseriformes_spec_ph Charadriiformes_num_ph Charadriiformes_spec_ph Falconiformes_num_ph Falconiformes_spec_ph Passeriformes_num_ph Passeriformes_spec_ph Pelecaniformes_num_ph Pelecaniformes_spec_ph Strigiformes_spec_ph Strigiformes_num_ph Piciformes_num Piciformes_num_pc Piciformes_species Piciformes_spec_pc Piciformes_num_ph Piciformes_spec_ph total_species_manual total_effort_counters total_effort_hours"
foreach p of local vars {
	gen i`p' = asinh(`p')
}

save "Analysis\CBC_CircleLevel_Panel", replace 

*********************************************************************************
*Collapse to characteristics level 

*Import, clean, and save bird characteristics data 
import delimited "${user}\Data\Raw\Bird_Characteristics.csv", clear

rename order order_v2
rename family family_v2
rename commonname common_name 
drop scientificname

duplicates drop common_name, force 

save "Intermediate\Bird_Characteristics", replace 


use "Analysis\CBC_SpeciesLevel_Panel", clear 

*Merge in characteristics:
merge m:1 common_name using "Intermediate\Bird_Characteristics"
drop if _merge != 3
drop _merge 

gen habitat_type = 0
replace habitat_type = 1 if habitat == "Grassland"
replace habitat_type = 1 if habitat == "Shrubland"
replace habitat_type = 2 if habitat == "Woodland"
replace habitat_type = 3 if habitat == "Wetland"
replace habitat_type = 4 if habitat == "Various"
replace habitat_type = 4 if habitat == "Ocean"

gen urban = 0
replace urban = 1 if urbanaffiliate == "Yes"

gen migration_type = 0
replace migration_type = 1 if migratorystrategy == "Resident"
replace migration_type = 2 if migratorystrategy == "Short"
replace migration_type = 2 if migratorystrategy == "Irruptive"
replace migration_type = 2 if migratorystrategy == "Withdrawal"
replace migration_type = 3 if migratorystrategy == "Moderate"
replace migration_type = 3 if migratorystrategy == "Long"

*Sum number (winsorized) by type 
bysort circle_id year: egen num_tot_tmp = sum(number_seen_w) 
bysort circle_id year: egen num_tot_w = max(num_tot_tmp)
drop num_tot_tmp

bysort circle_id year: egen num_grassland_tmp = sum(number_seen_w) if habitat_type == 1 
bysort circle_id year: egen num_grassland_w = max(num_grassland_tmp)
drop num_grassland_tmp

bysort circle_id year: egen num_woodland_tmp = sum(number_seen_w) if habitat_type == 2
bysort circle_id year: egen num_woodland_w = max(num_woodland_tmp)
drop num_woodland_tmp

bysort circle_id year: egen num_wetland_tmp = sum(number_seen_w) if habitat_type == 3
bysort circle_id year: egen num_wetland_w = max(num_wetland_tmp)
drop num_wetland_tmp

bysort circle_id year: egen num_otherhabitat_tmp = sum(number_seen_w) if habitat_type == 4
bysort circle_id year: egen num_otherhabitat_w = max(num_otherhabitat_tmp)
drop num_otherhabitat_tmp

bysort circle_id year: egen num_urban_tmp = sum(number_seen_w) if urban == 1
bysort circle_id year: egen num_urban_w = max(num_urban_tmp)
drop num_urban_tmp

bysort circle_id year: egen num_nonurban_tmp = sum(number_seen_w) if urban == 0
bysort circle_id year: egen num_nonurban_w = max(num_nonurban_tmp)
drop num_nonurban_tmp

bysort circle_id year: egen num_resident_tmp = sum(number_seen_w) if migration_type == 1
bysort circle_id year: egen num_resident_w = max(num_resident_tmp)
drop num_resident_tmp

bysort circle_id year: egen num_shortmigration_tmp = sum(number_seen_w) if migration_type == 2
bysort circle_id year: egen num_shortmigration_w = max(num_shortmigration_tmp)
drop num_shortmigration_tmp

bysort circle_id year: egen num_longermigration_tmp = sum(number_seen_w) if migration_type == 3
bysort circle_id year: egen num_longermigration_w = max(num_longermigration_tmp)
drop num_longermigration_tmp

*Sum number (NOT winsorized) by type 
bysort circle_id year: egen num_tot_tmp = sum(number_seen) 
bysort circle_id year: egen num_tot = max(num_tot_tmp)
drop num_tot_tmp

bysort circle_id year: egen num_grassland_tmp = sum(number_seen) if habitat_type == 1 
bysort circle_id year: egen num_grassland = max(num_grassland_tmp)
drop num_grassland_tmp

bysort circle_id year: egen num_woodland_tmp = sum(number_seen) if habitat_type == 2
bysort circle_id year: egen num_woodland = max(num_woodland_tmp)
drop num_woodland_tmp

bysort circle_id year: egen num_wetland_tmp = sum(number_seen) if habitat_type == 3
bysort circle_id year: egen num_wetland = max(num_wetland_tmp)
drop num_wetland_tmp

bysort circle_id year: egen num_otherhabitat_tmp = sum(number_seen) if habitat_type == 4
bysort circle_id year: egen num_otherhabitat = max(num_otherhabitat_tmp)
drop num_otherhabitat_tmp

bysort circle_id year: egen num_urban_tmp = sum(number_seen) if urban == 1
bysort circle_id year: egen num_urban = max(num_urban_tmp)
drop num_urban_tmp

bysort circle_id year: egen num_nonurban_tmp = sum(number_seen) if urban == 0
bysort circle_id year: egen num_nonurban = max(num_nonurban_tmp)
drop num_nonurban_tmp

bysort circle_id year: egen num_resident_tmp = sum(number_seen) if migration_type == 1
bysort circle_id year: egen num_resident = max(num_resident_tmp)
drop num_resident_tmp

bysort circle_id year: egen num_shortmigration_tmp = sum(number_seen) if migration_type == 2
bysort circle_id year: egen num_shortmigration = max(num_shortmigration_tmp)
drop num_shortmigration_tmp

bysort circle_id year: egen num_longermigration_tmp = sum(number_seen) if migration_type == 3
bysort circle_id year: egen num_longermigration = max(num_longermigration_tmp)
drop num_longermigration_tmp

*Sum species by type 
bysort circle_id year: egen spec_tot_tmp = sum(species_counter) 
bysort circle_id year: egen spec_tot = max(spec_tot_tmp)
drop spec_tot_tmp

bysort circle_id year: egen spec_grassland_tmp = sum(species_counter) if habitat_type == 1 
bysort circle_id year: egen spec_grassland = max(spec_grassland_tmp)
drop spec_grassland_tmp

bysort circle_id year: egen spec_woodland_tmp = sum(species_counter) if habitat_type == 2
bysort circle_id year: egen spec_woodland = max(spec_woodland_tmp)
drop spec_woodland_tmp

bysort circle_id year: egen spec_wetland_tmp = sum(species_counter) if habitat_type == 3
bysort circle_id year: egen spec_wetland = max(spec_wetland_tmp)
drop spec_wetland_tmp

bysort circle_id year: egen spec_otherhabitat_tmp = sum(species_counter) if habitat_type == 4
bysort circle_id year: egen spec_otherhabitat = max(spec_otherhabitat_tmp)
drop spec_otherhabitat_tmp

bysort circle_id year: egen spec_urban_tmp = sum(species_counter) if urban == 1
bysort circle_id year: egen spec_urban = max(spec_urban_tmp)
drop spec_urban_tmp

bysort circle_id year: egen spec_nonurban_tmp = sum(species_counter) if urban == 0
bysort circle_id year: egen spec_nonurban = max(spec_nonurban_tmp)
drop spec_nonurban_tmp

bysort circle_id year: egen spec_resident_tmp = sum(species_counter) if migration_type == 1
bysort circle_id year: egen spec_resident = max(spec_resident_tmp)
drop spec_resident_tmp

bysort circle_id year: egen spec_shortmigration_tmp = sum(species_counter) if migration_type == 2
bysort circle_id year: egen spec_shortmigration = max(spec_shortmigration_tmp)
drop spec_shortmigration_tmp

bysort circle_id year: egen spec_longermigration_tmp = sum(species_counter) if migration_type == 3
bysort circle_id year: egen spec_longermigration = max(spec_longermigration_tmp)
drop spec_longermigration_tmp

local vars "num_tot_w num_grassland_w num_woodland_w num_wetland_w num_otherhabitat_w num_urban_w num_nonurban_w num_resident_w num_shortmigration_w num_longermigration_w num_tot num_grassland num_woodland num_wetland num_otherhabitat num_urban num_nonurban num_resident num_shortmigration num_longermigration spec_tot spec_grassland spec_woodland spec_wetland spec_otherhabitat spec_urban spec_nonurban spec_resident spec_shortmigration spec_longermigration"
foreach j of local vars {
	gen `j'_pc = `j' / total_effort_counters
	gen `j'_ph = `j' / total_effort_hours 
}

*Collapse to habitat type 
collapse (firstnm) circle circle_name latitude longitude state Min_temp Max_temp Min_wind Max_wind WindDirection Min_snow Max_snow StillWater MovingWater AMCloud PMCloud Am_rain_cond_Names Pm_rain_cond_Names Am_snow_cond_Names Pm_snow_cond_Names (mean) num_tot_w num_grassland_w num_woodland_w num_wetland_w num_otherhabitat_w num_urban_w num_nonurban_w num_resident_w num_shortmigration_w num_longermigration_w num_tot num_grassland num_woodland num_wetland num_otherhabitat num_urban num_nonurban num_resident num_shortmigration num_longermigration spec_tot spec_grassland spec_woodland spec_wetland spec_otherhabitat spec_urban spec_nonurban spec_resident spec_shortmigration spec_longermigration num_tot_w_pc num_grassland_w_pc num_woodland_w_pc num_wetland_w_pc num_otherhabitat_w_pc num_urban_w_pc num_nonurban_w_pc num_resident_w_pc num_shortmigration_w_pc num_longermigration_w_pc num_tot_pc num_grassland_pc num_woodland_pc num_wetland_pc num_otherhabitat_pc num_urban_pc num_nonurban_pc num_resident_pc num_shortmigration_pc num_longermigration_pc spec_tot_pc spec_grassland_pc spec_woodland_pc spec_wetland_pc spec_otherhabitat_pc spec_urban_pc spec_nonurban_pc spec_resident_pc spec_shortmigration_pc spec_longermigration_pc num_tot_w_ph num_grassland_w_ph num_woodland_w_ph num_wetland_w_ph num_otherhabitat_w_ph num_urban_w_ph num_nonurban_w_ph num_resident_w_ph num_shortmigration_w_ph num_longermigration_w_ph num_tot_ph num_grassland_ph num_woodland_ph num_wetland_ph num_otherhabitat_ph num_urban_ph num_nonurban_ph num_resident_ph num_shortmigration_ph num_longermigration_ph spec_tot_ph spec_grassland_ph spec_woodland_ph spec_wetland_ph spec_otherhabitat_ph spec_urban_ph spec_nonurban_ph spec_resident_ph spec_shortmigration_ph spec_longermigration_ph total_effort_counters total_effort_hours, by(circle_id year)

*Compute IHS
local vars "num_tot_w num_grassland_w num_woodland_w num_wetland_w num_otherhabitat_w num_urban_w num_nonurban_w num_resident_w num_shortmigration_w num_longermigration_w num_tot num_grassland num_woodland num_wetland num_otherhabitat num_urban num_nonurban num_resident num_shortmigration num_longermigration spec_tot spec_grassland spec_woodland spec_wetland spec_otherhabitat spec_urban spec_nonurban spec_resident spec_shortmigration spec_longermigration num_tot_w_pc num_grassland_w_pc num_woodland_w_pc num_wetland_w_pc num_otherhabitat_w_pc num_urban_w_pc num_nonurban_w_pc num_resident_w_pc num_shortmigration_w_pc num_longermigration_w_pc num_tot_pc num_grassland_pc num_woodland_pc num_wetland_pc num_otherhabitat_pc num_urban_pc num_nonurban_pc num_resident_pc num_shortmigration_pc num_longermigration_pc spec_tot_pc spec_grassland_pc spec_woodland_pc spec_wetland_pc spec_otherhabitat_pc spec_urban_pc spec_nonurban_pc spec_resident_pc spec_shortmigration_pc spec_longermigration_pc num_tot_w_ph num_grassland_w_ph num_woodland_w_ph num_wetland_w_ph num_otherhabitat_w_ph num_urban_w_ph num_nonurban_w_ph num_resident_w_ph num_shortmigration_w_ph num_longermigration_w_ph num_tot_ph num_grassland_ph num_woodland_ph num_wetland_ph num_otherhabitat_ph num_urban_ph num_nonurban_ph num_resident_ph num_shortmigration_ph num_longermigration_ph spec_tot_ph spec_grassland_ph spec_woodland_ph spec_wetland_ph spec_otherhabitat_ph spec_urban_ph spec_nonurban_ph spec_resident_ph spec_shortmigration_ph spec_longermigration_ph total_effort_counters total_effort_hours"
foreach j of local vars {
	gen ihs_`j' = asinh(`j')
}

save "Analysis\CBC_CircleLevel_Panel_Characteristics", replace 




*********************************************
use "Analysis\CBC_CircleLevel_Panel", clear 

*Collapse to 20-year mean values 
collapse (mean) number_seen number_seen_w number_seen_per_counter number_seen_per_hour number_seen_per_hour_w number_seen_per_counter_w Accipitriformes_num Anseriformes_num Apodiformes_num Caprimulgiformes_num Charadriiformes_num Ciconiiformes_num Columbiformes_num Coraciiformes_num Cuculiformes_num Falconiformes_num Galliformes_num Gaviiformes_num Gruiformes_num Passeriformes_num Pelecaniformes_num Phaethontiformes_num Phoenicopteriformes_num Piciformes_num Podicipediformes_num Procellariiformes_num Psittaciformes_num Strigiformes_num Suliformes_num Trogoniformes_num total_species_manual biodiversity_index_normal biodiversity_index_w biodiversity_index_normal_w Accipitriformes_num_pc Anseriformes_num_pc Apodiformes_num_pc Caprimulgiformes_num_pc Charadriiformes_num_pc Ciconiiformes_num_pc Columbiformes_num_pc Coraciiformes_num_pc Cuculiformes_num_pc Falconiformes_num_pc Galliformes_num_pc Gaviiformes_num_pc Gruiformes_num_pc Passeriformes_num_pc Pelecaniformes_num_pc Phaethontiformes_num_pc Phoenicopteriformes_num_pc Piciformes_num_pc Podicipediformes_num_pc Psittaciformes_num_pc Strigiformes_num_pc Suliformes_num_pc Trogoniformes_num_pc, by(circle_id)

*Identify percentile of each circle 
gen group = 1

*Number seen winsorized
by group, sort: egen n_w = count(number_seen_w)
by group: egen i_w = rank(number_seen_w), track
gen pcrank_w = (i_w - 1) / (n_w - 1)
replace pcrank_w = pcrank_w * 100

*Number seen total 
by group, sort: egen n = count(number_seen)
by group: egen i = rank(number_seen), track
gen pcrank_n = (i - 1) / (n - 1)
replace pcrank_n = pcrank_n * 100

*Number of species seen 
by group, sort: egen n_s = count(total_species_manual)
by group: egen i_s = rank(total_species_manual), track
gen pcrank_species = (i_s - 1) / (n_s - 1)
replace pcrank_species = pcrank_species * 100

*Number seen per counter percentiles 
by group, sort: egen n_c = count(number_seen_per_counter)
by group: egen i_c = rank(number_seen_per_counter), track
gen pcrank_c = (i_c - 1) / (n_c - 1)
replace pcrank_c = pcrank_c * 100

*Number seen per hour percentiles 
by group, sort: egen n_h = count(number_seen_per_hour)
by group: egen i_h = rank(number_seen_per_hour), track
gen pcrank_h = (i_h - 1) / (n_h - 1)
replace pcrank_h = pcrank_h * 100

*Winsorize even more 
rename number_seen_per_counter_w number_seen_per_counter_w99
winsor2 number_seen_per_counter, cuts(0 97) 

export delimited using "${user}\Data\Intermediate\CBC_Circles_20YrAvgBirds.csv", replace
