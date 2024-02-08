*Master do-file to replicate "Quantifying the Effects of Energy Infrastructure on Bird Populations and Biodiversity,"
*published in Environmental Science and Technology, Vol. 58(1), pp. 323-332 (2024), by Erik Katovich. 
*DOI: https://doi.org/10.1021/acs.est.3c03899

*Last modified date: February 08, 2024

*This replication package requires a combination of Stata and R scripts, 
*to be executed in the order defined in this Master do-file.

*First, install required packages as needed: 
*coefplot gtools grstyle grc1leg2 winsor2 didregress xtpoisson spmatrix spbalance 

*Instructions for installing the csdid2 package may be found here: https://github.com/friosavila/stpackages/tree/main/csdid2

********************************************************************************
*Setup 
version 17             // Set Version number for backward compatibility
set more off            // Disable partitioned output
clear all               // Start with a clean slate
set linesize 80         // Line size limit to make output more readable
macro drop _all         // clear all macros
********************************************************************************

*Define relative file path here:
	global user "C:\Users\katovich\Dropbox\PhD\Research\Birds"

********************************************************************************

***************
*Data Cleaning:
***************

do "Effort_Cleaning.do"

do "Weather_Cleaning.do"

do "Species_Cleaning.do"

do "Wind_Turbines_Cleaning.do"

do "Oil_and_Gas_Cleaning.do"

do "Population_Cleaning.do"

do "Cleaning_BreedingBirdSurvey.do"

*****************************
*Data Processing and Merging:
*****************************

*Pause here and open the following script in R. 
*Define the appropriate file path and execute the script. 
*In R: "Mapping_CBC_Circles_VoronoiTesselations.R"

do "Merge_Circles_Turbines.do"

do "Merge_Circles_ShaleFields.do"

*Pause here and open the following script in R. 
*Define the appropriate file path and execute the script. 
*In R: "Land_Use_Data.R"

do "Merge_Circles_LandUseProportions.do"

***************
*Data Analysis:
***************

do "Analysis_Wind.do"

do "Analysis_Shale.do"

do "Analysis_Population.do"

do "Analysis_ImportantBirdAreas.do"


*********************
*Descriptive Figures:
*********************

do "Descriptive_Figures.do"

do "News_Coverage.do"

