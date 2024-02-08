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

do "Replication_Package/Effort_Cleaning.do"

do "Replication_Package/Weather_Cleaning.do"

do "Replication_Package/Species_Cleaning.do"

do "Replication_Package/Wind_Turbines_Cleaning.do"

do "Replication_Package/Oil_and_Gas_Cleaning.do"

do "Replication_Package/Population_Cleaning.do"

do "Replication_Package/Cleaning_BreedingBirdSurvey.do"

*****************************
*Data Processing and Merging:
*****************************

*Pause here and open the following script in R. 
*Define the appropriate file path and execute the script. 
*In R: "Mapping_CBC_Circles_VoronoiTesselations.R"

do "Replication_Package/Merge_Circles_Turbines.do"

do "Replication_Package/Merge_Circles_ShaleFields.do"

*Pause here and open the following script in R. 
*Define the appropriate file path and execute the script. 
*Note: this file takes a long time to run. Pre-processed outputs are available in the Intermediate data folder, 
*and final land-use shares merged with CBC circles are available in the Analysis data folder.
*In R: "Land_Use_Data.R"

do "Replication_Package/Merge_Circles_LandUseProportions.do"

***************
*Data Analysis:
***************

do "Replication_Package/Analysis_Wind.do"

do "Replication_Package/Analysis_Shale.do"

do "Replication_Package/Analysis_Population.do"

do "Replication_Package/Analysis_ImportantBirdAreas.do"


*********************
*Descriptive Figures:
*********************

do "Replication_Package/Descriptive_Figures.do"

do "Replication_Package/News_Coverage.do"

