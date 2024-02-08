cd "${user}\Data\Raw\North American Breeding Bird Survey\"

local states "Alabama Arizona Arkansa Califor Colorad Connect Delawar Florida Georgia Idaho Illinoi Indiana Iowa Kansas Kentuck Louisia Maine Marylan Massach Michiga Minneso Mississ Missour Montana NCaroli NDakota Nebrask Nevada NHampsh NJersey NMexico NYork Ohio Oklahom Oregon Pennsyl RhodeIs SCaroli SDakota Tenness Texas Utah Vermont Virgini W_Virgi Washing Wiscons Wyoming"
foreach i of local states {
	
	import delimited "States/`i'/`i'.csv", clear 

	keep if year > 1999
	keep if year < 2021

	*Collapse to route level 
	gen species_counter = 1
	gen number_seen = speciestotal 

	collapse (firstnm) countrynum statenum routedataid rpid (sum) species_counter number_seen, by(route year)

	sort route year
	
	gen state_name = "`i'"

	save "Cleaned_`i'", replace 
}

*Append state files 
use "Cleaned_Alabama", clear 
append using "Cleaned_Arizona", force
append using "Cleaned_Arkansa", force
append using "Cleaned_Califor", force
append using "Cleaned_Colorad", force
append using "Cleaned_Connect", force
append using "Cleaned_Delawar", force
append using "Cleaned_Florida", force
append using "Cleaned_Georgia", force
append using "Cleaned_Idaho", force
append using "Cleaned_Illinoi", force
append using "Cleaned_Indiana", force
append using "Cleaned_Iowa", force
append using "Cleaned_Kansas", force
append using "Cleaned_Kentuck", force
append using "Cleaned_Louisia", force
append using "Cleaned_Maine", force
append using "Cleaned_Marylan", force
append using "Cleaned_Massach", force
append using "Cleaned_Michiga", force
append using "Cleaned_Minneso", force
append using "Cleaned_Mississ", force
append using "Cleaned_Missour", force
append using "Cleaned_Montana", force
append using "Cleaned_NCaroli", force
append using "Cleaned_NDakota", force
append using "Cleaned_Nebrask", force
append using "Cleaned_Nevada", force
append using "Cleaned_NHampsh", force
append using "Cleaned_NJersey", force
append using "Cleaned_NMexico", force
append using "Cleaned_NYork", force
append using "Cleaned_Ohio", force
append using "Cleaned_Oklahom", force
append using "Cleaned_Oregon", force
append using "Cleaned_Pennsyl", force
append using "Cleaned_RhodeIs", force
append using "Cleaned_SCaroli", force
append using "Cleaned_SDakota", force
append using "Cleaned_Tenness", force
append using "Cleaned_Texas", force
append using "Cleaned_Utah", force
append using "Cleaned_Vermont", force
append using "Cleaned_Virgini", force
append using "Cleaned_W_Virgi", force
append using "Cleaned_Washing", force
append using "Cleaned_Wiscons", force
append using "Cleaned_Wyoming", force

sort state_name route year          
tostring route, replace 
tostring statenum, replace 
replace route = "0" + route if length(route) == 1
replace statenum = "0" + statenum if length(statenum) == 1
egen unique_route_id = concat(statenum route)
sort state_name unique_route_id year 

save "BreedingBirdSurvey_2000_2020_USLower48", replace 

******************************************************
*Merge in route information 
import delimited "routes.csv", clear 

keep if countrynum == 840 

tostring statenum, replace 
tostring route, replace 
replace route = "0" + route if length(route) == 1
replace statenum = "0" + statenum if length(statenum) == 1
egen unique_route_id = concat(statenum route)

merge 1:m unique_route_id using "BreedingBirdSurvey_2000_2020_USLower48"
keep if _merge == 3
drop _merge 

sort state_name unique_route_id year 
drop countrynum routedataid
order statenum state_name state_name route routename unique_route_id year latitude longitude active stratum bcr routetypeid routetypedetailid rpid species_counter number_seen

keep if rpid == 101
keep if routetypedetailid == 1

save "BreedingBirdSurvey_USLower48_2000_2020_withRouteInfo", replace 

*Collapse to unique location level 
collapse (firstnm) routename state_name latitude longitude, by(unique_route_id)

export delimited using "BreedingBirdSurvey_USLower48_RouteLocations", replace





