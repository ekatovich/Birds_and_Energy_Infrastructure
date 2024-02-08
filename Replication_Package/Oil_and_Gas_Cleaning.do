clear 
cd "${user}\Data"
import delimited "Raw\Oil_and_Gas\US_ShaleWells_Panel.csv"

egen field_id = group(field)

reshape long shale_wells_ prod_kbblpd_, i(field_id) j(year)

replace prod_kbblpd_ = 0 if prod_kbblpd_ == .
rename shale_wells_ shale_wells_num
rename prod_kbblpd_ production_kbblpd

bysort field_id (year) : gen cum_shalewells = sum(shale_wells_num)
bysort field_id: gen new_shale_wells = cum_shalewells - cum_shalewells[_n-1]
replace new_shale_wells = 0 if year == 2000

generate str field_str = field
drop field
rename field_str field 

*Merge in lat/long points 
merge m:1 field using "Raw\Oil_and_Gas\Field_Characteristics_Combined"

drop if _merge != 3
drop _merge 

sort field_id year 
drop country_initials water_depth_m devcost_perbbl breakeven_gas breakeven_oil

*Keep only fields with some shale wells 
bysort field_id: egen max_wells = max(shale_wells_num)
keep if max_wells > 0
drop max_wells 
drop if lat > 50 

save "Intermediate\Shale_Wells_Panel", replace 

*Output data as .csv
export delimited using "${user}\Data\Intermediate\ShaleFields_Panel_Rystad.csv", replace