#Define the appropriate file path:
setwd("C:/Users/katovich/Dropbox/PhD/Research/Birds")

library(ggplot2)
library(sf)
library(dplyr)
library(rio)
library(geosphere)
library(foreign)
library(reshape)
library(viridis)
library(Rfast)
library(ggvoronoi)
library(deldir)
library(dismo)
library(rgeos)
library(maptools)
library(foreign)
library(maps)
library(raster) 
library(rgdal)
library(sp)
library(tmap)
library(terra)
library(geodata)
library(ggforce)
library(ggnewscale)
`%notin%` <- Negate(`%in%`)

######################################
# Remove plot axis
no_axis <- theme(axis.title=element_blank(),
                 axis.text=element_blank(),
                 axis.ticks=element_blank())
######################################

#Import shapefiles and points
us_states <- st_read("Data/Raw/Shapefiles/US_States/cb_2018_us_state_500k.shp")
us_counties <- st_read("Data/Raw/USA_Counties/USA_Counties.shp")
wind_turbines <- read.csv("Data/Intermediate/Wind_Turbine_Registry_USGS.csv")
shale_fields <- read.csv("Data/Intermediate/ShaleFields_Panel_Rystad.csv")
county_population <- read.csv("Data/Intermediate/Population_Panel_2000_2020.csv", colClasses = c(FIPS = "character"))
important_bird_areas <- st_read("Data/Raw/Important_Bird_Areas_Polygon_Public_View/Important_Bird_Areas_Polygon_Public_View.shp")
breeding_bird_surveys <- read.csv("Data/Raw/North American Breeding Bird Survey/BreedingBirdSurvey_USLower48_RouteLocations.csv")


cbc_circles <- read.csv("Data/Intermediate/CBC_Circle_Centroids.csv")
cbc_circles1 <- cbc_circles[which(cbc_circles$state %in% c("MS")),]
cbc_circles2 <- cbc_circles[which(cbc_circles$state %in% c("NC")),]
cbc_circles3 <- cbc_circles[which(cbc_circles$state %in% c("OK")),]
cbc_circles4 <- cbc_circles[which(cbc_circles$state %in% c("VA")),]
cbc_circles5 <- cbc_circles[which(cbc_circles$state %in% c("WV")),]
cbc_circles6 <- cbc_circles[which(cbc_circles$state %in% c("LA")),]
cbc_circles7 <- cbc_circles[which(cbc_circles$state %in% c("MI")),]
cbc_circles8 <- cbc_circles[which(cbc_circles$state %in% c("MA")),]
cbc_circles9 <- cbc_circles[which(cbc_circles$state %in% c("ID")),]
cbc_circles10 <- cbc_circles[which(cbc_circles$state %in% c("FL")),]
cbc_circles11 <- cbc_circles[which(cbc_circles$state %in% c("NE")),]
cbc_circles12 <- cbc_circles[which(cbc_circles$state %in% c("WA")),]
cbc_circles13 <- cbc_circles[which(cbc_circles$state %in% c("NM")),]
cbc_circles14 <- cbc_circles[which(cbc_circles$state %in% c("SD")),]
cbc_circles15 <- cbc_circles[which(cbc_circles$state %in% c("TX")),]
cbc_circles16 <- cbc_circles[which(cbc_circles$state %in% c("CA")),]
cbc_circles17 <- cbc_circles[which(cbc_circles$state %in% c("AL")),]
cbc_circles18 <- cbc_circles[which(cbc_circles$state %in% c("GA")),]
cbc_circles19 <- cbc_circles[which(cbc_circles$state %in% c("PA")),]
cbc_circles20 <- cbc_circles[which(cbc_circles$state %in% c("MO")),]
cbc_circles21 <- cbc_circles[which(cbc_circles$state %in% c("CO")),]
cbc_circles22 <- cbc_circles[which(cbc_circles$state %in% c("UT")),]
cbc_circles23 <- cbc_circles[which(cbc_circles$state %in% c("TN")),]
cbc_circles24 <- cbc_circles[which(cbc_circles$state %in% c("WY")),]
cbc_circles25 <- cbc_circles[which(cbc_circles$state %in% c("NY")),]
cbc_circles26 <- cbc_circles[which(cbc_circles$state %in% c("KS")),]
cbc_circles27 <- cbc_circles[which(cbc_circles$state %in% c("NV")),]
cbc_circles28 <- cbc_circles[which(cbc_circles$state %in% c("IL")),]
cbc_circles29 <- cbc_circles[which(cbc_circles$state %in% c("VT")),]
cbc_circles30 <- cbc_circles[which(cbc_circles$state %in% c("MT")),]
cbc_circles31 <- cbc_circles[which(cbc_circles$state %in% c("IA")),]
cbc_circles32 <- cbc_circles[which(cbc_circles$state %in% c("SC")),]
cbc_circles33 <- cbc_circles[which(cbc_circles$state %in% c("NH")),]
cbc_circles34 <- cbc_circles[which(cbc_circles$state %in% c("AZ")),]
cbc_circles35 <- cbc_circles[which(cbc_circles$state %in% c("DC")),]
cbc_circles36 <- cbc_circles[which(cbc_circles$state %in% c("NJ")),]
cbc_circles37 <- cbc_circles[which(cbc_circles$state %in% c("MD")),]
cbc_circles38 <- cbc_circles[which(cbc_circles$state %in% c("ME")),]
cbc_circles39 <- cbc_circles[which(cbc_circles$state %in% c("DE")),]
cbc_circles40 <- cbc_circles[which(cbc_circles$state %in% c("RI")),]
cbc_circles41 <- cbc_circles[which(cbc_circles$state %in% c("KY")),]
cbc_circles42 <- cbc_circles[which(cbc_circles$state %in% c("OH")),]
cbc_circles43 <- cbc_circles[which(cbc_circles$state %in% c("WI")),]
cbc_circles44 <- cbc_circles[which(cbc_circles$state %in% c("OR")),]
cbc_circles45 <- cbc_circles[which(cbc_circles$state %in% c("ND")),]
cbc_circles46 <- cbc_circles[which(cbc_circles$state %in% c("AR")),]
cbc_circles47 <- cbc_circles[which(cbc_circles$state %in% c("IN")),]
cbc_circles48 <- cbc_circles[which(cbc_circles$state %in% c("MN")),]
cbc_circles49 <- cbc_circles[which(cbc_circles$state %in% c("CT")),]

#Create subset of state shapefile data for lower 48 states, and each state individually 
us_lower48_states <- us_states[-which(us_states$STATEFP %in% c("72", "78", "69", "66", "15", "60", "02")),]
state1 <- us_states[which(us_states$STATEFP %in% c("28")),]
state2 <- us_states[which(us_states$STATEFP %in% c("37")),]
state3 <- us_states[which(us_states$STATEFP %in% c("40")),]
state4 <- us_states[which(us_states$STATEFP %in% c("51")),]
state5 <- us_states[which(us_states$STATEFP %in% c("54")),]
state6 <- us_states[which(us_states$STATEFP %in% c("22")),]
state7 <- us_states[which(us_states$STATEFP %in% c("26")),]
state8 <- us_states[which(us_states$STATEFP %in% c("25")),]
state9 <- us_states[which(us_states$STATEFP %in% c("16")),]
state10 <- us_states[which(us_states$STATEFP %in% c("12")),]
state11 <- us_states[which(us_states$STATEFP %in% c("31")),]
state12 <- us_states[which(us_states$STATEFP %in% c("53")),]
state13 <- us_states[which(us_states$STATEFP %in% c("35")),]
state14 <- us_states[which(us_states$STATEFP %in% c("46")),]
state15 <- us_states[which(us_states$STATEFP %in% c("48")),]
state16 <- us_states[which(us_states$STATEFP %in% c("06")),]
state17 <- us_states[which(us_states$STATEFP %in% c("01")),]
state18 <- us_states[which(us_states$STATEFP %in% c("13")),]
state19 <- us_states[which(us_states$STATEFP %in% c("42")),]
state20 <- us_states[which(us_states$STATEFP %in% c("29")),]
state21 <- us_states[which(us_states$STATEFP %in% c("08")),]
state22 <- us_states[which(us_states$STATEFP %in% c("49")),]
state23 <- us_states[which(us_states$STATEFP %in% c("47")),]
state24 <- us_states[which(us_states$STATEFP %in% c("56")),]
state25 <- us_states[which(us_states$STATEFP %in% c("36")),]
state26 <- us_states[which(us_states$STATEFP %in% c("20")),]
state27 <- us_states[which(us_states$STATEFP %in% c("32")),]
state28 <- us_states[which(us_states$STATEFP %in% c("17")),]
state29 <- us_states[which(us_states$STATEFP %in% c("50")),]
state30 <- us_states[which(us_states$STATEFP %in% c("30")),]
state31 <- us_states[which(us_states$STATEFP %in% c("19")),]
state32 <- us_states[which(us_states$STATEFP %in% c("45")),]
state33 <- us_states[which(us_states$STATEFP %in% c("33")),]
state34 <- us_states[which(us_states$STATEFP %in% c("04")),]
state35 <- us_states[which(us_states$STATEFP %in% c("11")),]
state36 <- us_states[which(us_states$STATEFP %in% c("34")),]
state37 <- us_states[which(us_states$STATEFP %in% c("24")),]
state38 <- us_states[which(us_states$STATEFP %in% c("23")),]
state39 <- us_states[which(us_states$STATEFP %in% c("10")),]
state40 <- us_states[which(us_states$STATEFP %in% c("44")),]
state41 <- us_states[which(us_states$STATEFP %in% c("21")),]
state42 <- us_states[which(us_states$STATEFP %in% c("39")),]
state43 <- us_states[which(us_states$STATEFP %in% c("55")),]
state44 <- us_states[which(us_states$STATEFP %in% c("41")),]
state45 <- us_states[which(us_states$STATEFP %in% c("38")),]
state46 <- us_states[which(us_states$STATEFP %in% c("05")),]
state47 <- us_states[which(us_states$STATEFP %in% c("18")),]
state48 <- us_states[which(us_states$STATEFP %in% c("27")),]
state49 <- us_states[which(us_states$STATEFP %in% c("09")),]

#Create subset of important bird habitats for lower 48 states 
important_bird_areas_lower48 <- important_bird_areas[-which(important_bird_areas$STATE %in% c("Puerto Rico", "Alaska", "Hawaii", "Northern Mariana Islands", "Virgin Islands")),]


###########################################################
#Plot CBC circle centroids 
#This creates the voronoi line segments
voronoi <- deldir(cbc_circles$longitude, cbc_circles$latitude)
voronoi1 <- deldir(cbc_circles1$longitude, cbc_circles1$latitude)
voronoi2 <- deldir(cbc_circles2$longitude, cbc_circles2$latitude)
voronoi3 <- deldir(cbc_circles3$longitude, cbc_circles3$latitude)
voronoi4 <- deldir(cbc_circles4$longitude, cbc_circles4$latitude)
voronoi5 <- deldir(cbc_circles5$longitude, cbc_circles5$latitude)
voronoi6 <- deldir(cbc_circles6$longitude, cbc_circles6$latitude)
voronoi7 <- deldir(cbc_circles7$longitude, cbc_circles7$latitude)
voronoi8 <- deldir(cbc_circles8$longitude, cbc_circles8$latitude)
voronoi9 <- deldir(cbc_circles9$longitude, cbc_circles9$latitude)
voronoi10 <- deldir(cbc_circles10$longitude, cbc_circles10$latitude)
voronoi11 <- deldir(cbc_circles11$longitude, cbc_circles11$latitude)
voronoi12 <- deldir(cbc_circles12$longitude, cbc_circles12$latitude)
voronoi13 <- deldir(cbc_circles13$longitude, cbc_circles13$latitude)
voronoi14 <- deldir(cbc_circles14$longitude, cbc_circles14$latitude)
voronoi15 <- deldir(cbc_circles15$longitude, cbc_circles15$latitude)
voronoi16 <- deldir(cbc_circles16$longitude, cbc_circles16$latitude)
voronoi17 <- deldir(cbc_circles17$longitude, cbc_circles17$latitude)
voronoi18 <- deldir(cbc_circles18$longitude, cbc_circles18$latitude)
voronoi19 <- deldir(cbc_circles19$longitude, cbc_circles19$latitude)
voronoi20 <- deldir(cbc_circles20$longitude, cbc_circles20$latitude)
voronoi21 <- deldir(cbc_circles21$longitude, cbc_circles21$latitude)
voronoi22 <- deldir(cbc_circles22$longitude, cbc_circles22$latitude)
voronoi23 <- deldir(cbc_circles23$longitude, cbc_circles23$latitude)
voronoi24 <- deldir(cbc_circles24$longitude, cbc_circles24$latitude)
voronoi25 <- deldir(cbc_circles25$longitude, cbc_circles25$latitude)
voronoi26 <- deldir(cbc_circles26$longitude, cbc_circles26$latitude)
voronoi27 <- deldir(cbc_circles27$longitude, cbc_circles27$latitude)
voronoi28 <- deldir(cbc_circles28$longitude, cbc_circles28$latitude)
voronoi29 <- deldir(cbc_circles29$longitude, cbc_circles29$latitude)
voronoi30 <- deldir(cbc_circles30$longitude, cbc_circles30$latitude)
voronoi31 <- deldir(cbc_circles31$longitude, cbc_circles31$latitude)
voronoi32 <- deldir(cbc_circles32$longitude, cbc_circles32$latitude)
voronoi33 <- deldir(cbc_circles33$longitude, cbc_circles33$latitude)
voronoi34 <- deldir(cbc_circles34$longitude, cbc_circles34$latitude)
voronoi35 <- deldir(cbc_circles35$longitude, cbc_circles35$latitude)
voronoi36 <- deldir(cbc_circles36$longitude, cbc_circles36$latitude)
voronoi37 <- deldir(cbc_circles37$longitude, cbc_circles37$latitude)
voronoi38 <- deldir(cbc_circles38$longitude, cbc_circles38$latitude)
voronoi39 <- deldir(cbc_circles39$longitude, cbc_circles39$latitude)
voronoi40 <- deldir(cbc_circles40$longitude, cbc_circles40$latitude)
voronoi41 <- deldir(cbc_circles41$longitude, cbc_circles41$latitude)
voronoi42 <- deldir(cbc_circles42$longitude, cbc_circles42$latitude)
voronoi43 <- deldir(cbc_circles43$longitude, cbc_circles43$latitude)
voronoi44 <- deldir(cbc_circles44$longitude, cbc_circles44$latitude)
voronoi45 <- deldir(cbc_circles45$longitude, cbc_circles45$latitude)
voronoi46 <- deldir(cbc_circles46$longitude, cbc_circles46$latitude)
voronoi47 <- deldir(cbc_circles47$longitude, cbc_circles47$latitude)
voronoi48 <- deldir(cbc_circles48$longitude, cbc_circles48$latitude)
voronoi49 <- deldir(cbc_circles49$longitude, cbc_circles49$latitude)

#Plot unbounded Voronoi tesselations for whole country.
ggplot() +
  geom_sf(data=us_lower48_states) +
  theme_minimal() + no_axis + 
  geom_point(data = cbc_circles, aes(x = longitude, y = latitude), size = .1, 
             shape = 21) + 
  geom_segment(data = voronoi$dirsgs,aes(x = x1, y = y1, xend = x2, yend = y2), size = .1,
               linetype = 1, color= "#FFB958") 


####################################################################
# #Cut off voronoi tessellations of CBC circles at state boundaries, for each state.

states_list <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 
                 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 36, 37, 38, 39, 40, 
                 41, 42, 43, 44, 45, 46, 47, 48, 49)
for(x in 1:length(states_list)){
  cbc_list <- list()
  cbc <- get(paste('cbc_circles', states_list[x], sep=''))
  for(i in 1:nrow(cbc)){
    y <- cbc[i, c('longitude', 'latitude')]
    y <- as.numeric(y)
    y <- st_point(y)
    cbc_list[[i]] <- y
  }

  state <- get(paste('state', states_list[x], sep=''))
  border <- st_sfc(state$geometry)
  point <- st_sfc(cbc_list)
  new_voronoi <- st_collection_extract(st_voronoi(do.call(c, point)) )

  new_voronoi <- st_set_crs(new_voronoi, 4269)
  border <- st_set_crs(border, 4269)
  assign(paste('border', states_list[x], sep=''), border)
  polygon <- st_intersection(new_voronoi, border)
  assign(paste('polygon', states_list[x], sep=''), polygon)
  print(x)
}

#Plot all states
ggplot() +
  geom_sf(data=us_lower48_states, size=1.25) +
  geom_sf(data=border1) +
  geom_sf(data=border2) +
  geom_sf(data=border3) +
  geom_sf(data=border4) +
  geom_sf(data=border5) +
  geom_sf(data=border6) +
  geom_sf(data=border7) +
  geom_sf(data=border8) +
  geom_sf(data=border9) +
  geom_sf(data=border10) +
  geom_sf(data=border11) +
  geom_sf(data=border12) +
  geom_sf(data=border13) +
  geom_sf(data=border14) +
  geom_sf(data=border15) +
  geom_sf(data=border16) +
  geom_sf(data=border17) +
  geom_sf(data=border18) +
  geom_sf(data=border19) +
  geom_sf(data=border20) +
  geom_sf(data=border21) +
  geom_sf(data=border22) +
  geom_sf(data=border23) +
  geom_sf(data=border24) +
  geom_sf(data=border25) +
  geom_sf(data=border26) +
  geom_sf(data=border27) +
  geom_sf(data=border27) +
  geom_sf(data=border29) +
  geom_sf(data=border30) +
  geom_sf(data=border31) +
  geom_sf(data=border32) +
  geom_sf(data=border33) +
  geom_sf(data=border34) +
  geom_sf(data=border36) +
  geom_sf(data=border37) +
  geom_sf(data=border38) +
  geom_sf(data=border39) +
  geom_sf(data=border40) +
  geom_sf(data=border41) +
  geom_sf(data=border42) +
  geom_sf(data=border43) +
  geom_sf(data=border44) +
  geom_sf(data=border45) +
  geom_sf(data=border46) +
  geom_sf(data=border47) +
  geom_sf(data=border48) +
  geom_sf(data=border49) +
  geom_sf(data=polygon1, color= "black", size=.25) +
  geom_sf(data=polygon2, color= "black", size=.25) +
  geom_sf(data=polygon3, color= "black", size=.25) +
  geom_sf(data=polygon4, color= "black", size=.25) +
  geom_sf(data=polygon5, color= "black", size=.25) +
  geom_sf(data=polygon6, color= "black", size=.25) +
  geom_sf(data=polygon7, color= "black", size=.25) +
  geom_sf(data=polygon8, color= "black", size=.25) +
  geom_sf(data=polygon9, color= "black", size=.25) +
  geom_sf(data=polygon10, color= "black", size=.25) +
  geom_sf(data=polygon11, color= "black", size=.25) +
  geom_sf(data=polygon12, color= "black", size=.25) +
  geom_sf(data=polygon13, color= "black", size=.25) +
  geom_sf(data=polygon14, color= "black", size=.25) +
  geom_sf(data=polygon15, color= "black", size=.25) +
  geom_sf(data=polygon16, color= "black", size=.25) +
  geom_sf(data=polygon17, color= "black", size=.25) +
  geom_sf(data=polygon18, color= "black", size=.25) +
  geom_sf(data=polygon19, color= "black", size=.25) +
  geom_sf(data=polygon20, color= "black", size=.25) +
  geom_sf(data=polygon21, color= "black", size=.25) +
  geom_sf(data=polygon22, color= "black", size=.25) +
  geom_sf(data=polygon23, color= "black", size=.25) +
  geom_sf(data=polygon24, color= "black", size=.25) +
  geom_sf(data=polygon25, color= "black", size=.25) +
  geom_sf(data=polygon26, color= "black", size=.25) +
  geom_sf(data=polygon27, color= "black", size=.25) +
  geom_sf(data=polygon28, color= "black", size=.25) +
  geom_sf(data=polygon29, color= "black", size=.25) +
  geom_sf(data=polygon30, color= "black", size=.25) +
  geom_sf(data=polygon31, color= "black", size=.25) +
  geom_sf(data=polygon32, color= "black", size=.25) +
  geom_sf(data=polygon33, color= "black", size=.25) +
  geom_sf(data=polygon34, color= "black", size=.25) +
  geom_sf(data=polygon36, color= "black", size=.25) +
  geom_sf(data=polygon37, color= "black", size=.25) +
  geom_sf(data=polygon38, color= "black", size=.25) +
  geom_sf(data=polygon39, color= "black", size=.25) +
  geom_sf(data=polygon40, color= "black", size=.25) +
  geom_sf(data=polygon41, color= "black", size=.25) +
  geom_sf(data=polygon42, color= "black", size=.25) +
  geom_sf(data=polygon43, color= "black", size=.25) +
  geom_sf(data=polygon44, color= "black", size=.25) +
  geom_sf(data=polygon45, color= "black", size=.25) +
  geom_sf(data=polygon46, color= "black", size=.25) +
  geom_sf(data=polygon47, color= "black", size=.25) +
  geom_sf(data=polygon48, color= "black", size=.25) +
  geom_sf(data=polygon49, color= "black", size=.25) +
  geom_point(data = wind_turbines, aes(x = longitude, y = latitude, colour = year_operational, size = cumulative_capacity_mw), 
              shape = 1, size=1) +
              scale_colour_viridis(direction = -1, option = "D")+
  theme_minimal() + no_axis 


##########################################################################
#Now combine all the state-level voronoi polygons into one big data frame

polygons_combined <- append(polygon1, polygon2)

polygons_list <- c(3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 
                 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 36, 37, 38, 39, 40, 
                 41, 42, 43, 44, 45, 46, 47, 48, 49)
for(x in 1:length(polygons_list)){
  polygon_i <- get(paste('polygon', polygons_list[i], sep=''))
  polygons_combined <- append(polygons_combined, polygon_i)
}


polygons_combined <- append(polygon1, polygon2)
polygons_combined <- append(polygons_combined, polygon3)
polygons_combined <- append(polygons_combined, polygon4)
polygons_combined <- append(polygons_combined, polygon5)
polygons_combined <- append(polygons_combined, polygon6)
polygons_combined <- append(polygons_combined, polygon7)
polygons_combined <- append(polygons_combined, polygon8)
polygons_combined <- append(polygons_combined, polygon9)
polygons_combined <- append(polygons_combined, polygon10)
polygons_combined <- append(polygons_combined, polygon11)
polygons_combined <- append(polygons_combined, polygon12)
polygons_combined <- append(polygons_combined, polygon13)
polygons_combined <- append(polygons_combined, polygon14)
polygons_combined <- append(polygons_combined, polygon15)
polygons_combined <- append(polygons_combined, polygon16)
polygons_combined <- append(polygons_combined, polygon17)
polygons_combined <- append(polygons_combined, polygon18)
polygons_combined <- append(polygons_combined, polygon19)
polygons_combined <- append(polygons_combined, polygon20)
polygons_combined <- append(polygons_combined, polygon21)
polygons_combined <- append(polygons_combined, polygon22)
polygons_combined <- append(polygons_combined, polygon23)
polygons_combined <- append(polygons_combined, polygon24)
polygons_combined <- append(polygons_combined, polygon25)
polygons_combined <- append(polygons_combined, polygon26)
polygons_combined <- append(polygons_combined, polygon27)
polygons_combined <- append(polygons_combined, polygon28)
polygons_combined <- append(polygons_combined, polygon29)
polygons_combined <- append(polygons_combined, polygon30)
polygons_combined <- append(polygons_combined, polygon31)
polygons_combined <- append(polygons_combined, polygon32)
polygons_combined <- append(polygons_combined, polygon33)
polygons_combined <- append(polygons_combined, polygon34)
polygons_combined <- append(polygons_combined, polygon36)
polygons_combined <- append(polygons_combined, polygon37)
polygons_combined <- append(polygons_combined, polygon38)
polygons_combined <- append(polygons_combined, polygon39)
polygons_combined <- append(polygons_combined, polygon40)
polygons_combined <- append(polygons_combined, polygon41)
polygons_combined <- append(polygons_combined, polygon42)
polygons_combined <- append(polygons_combined, polygon43)
polygons_combined <- append(polygons_combined, polygon44)
polygons_combined <- append(polygons_combined, polygon45)
polygons_combined <- append(polygons_combined, polygon46)
polygons_combined <- append(polygons_combined, polygon47)
polygons_combined <- append(polygons_combined, polygon48)
polygons_combined <- append(polygons_combined, polygon49)

#Graph with consolidated polygons 
#Plot all states
ggplot() +
  ggtitle("Christmas Bird Count Circle Locations with Voronoi Tesselations") +
  geom_sf(data=us_lower48_states, size=1.25) +
  geom_sf(data=polygons_combined, color= "black", size=.25) +
  geom_point(data = cbc_circles, aes(x = longitude, y = latitude), size = .5, 
             shape = 21) + 
  theme_minimal() + no_axis +
  theme(plot.title = element_text(size=11))

filename = paste("Output/CBC_Circle_Tesselations.png")
ggsave(filename, width = 11, height = 11)
filename = paste("Output/CBC_Circle_Tesselations.pdf")
ggsave(filename, width = 11, height = 11)


#Convert CBC circles to spatial polygon 
#Convert CBC circles into sf object
projcrs1 <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
cbc_circles_forspatial <- cbc_circles
cbc_circles_sf1 <- st_as_sf(x = cbc_circles_forspatial,                         
                            coords = c("longitude", "latitude"),
                            crs = projcrs1)
cbc_circles_sf1 <- st_set_crs(cbc_circles_sf1, 4269)

#Plot buffer
circles_buffer12_5 <- st_buffer(cbc_circles_sf1, 12500)
circles_buffer13_5 <- st_buffer(cbc_circles_sf1, 13500)
circles_buffer14_5 <- st_buffer(cbc_circles_sf1, 14500)
circles_buffer17_5 <- st_buffer(cbc_circles_sf1, 17500)
circles_buffer22_5 <- st_buffer(cbc_circles_sf1, 22500)

#Plot points with buffers 
ggplot() +
  ggtitle("Bird Circles (Center Points with 12.5km Radius)") +
  geom_sf(data=us_lower48_states, size=1.25) +
  #geom_sf(data = circles_buffer22_5, size=1, color = 'red') +
  #geom_sf(data = circles_buffer13_5, size=1, color = 'green') +
  geom_sf(data = circles_buffer12_5, size=.01, color = 'red') +
  geom_point(data = cbc_circles, aes(x = longitude, y = latitude), size = .01, 
             shape = 20) + 
  theme_minimal() + no_axis +
  theme(plot.title = element_text(size=11))

filename = paste("Output/CBC_Circles_24km.png")
ggsave(filename, width = 11, height = 11)
filename = paste("Output/CBC_Circles_24km.pdf")
ggsave(filename, width = 11, height = 11)

#Plot points with buffers and Voronoi Tesselations
ggplot() +
  ggtitle("A. Christmas Bird Count Circles within Voronoi Tesselations") +
  geom_sf(data=us_lower48_states, size=1.25) +
  #geom_sf(data = circles_buffer22_5, size=1, color = 'red') +
  #geom_sf(data = circles_buffer13_5, size=1, color = 'green') +
  geom_sf(data=polygons_combined, color= "black", size=.25) +
  geom_sf(data = circles_buffer12_5, size=.01, color = 'red') +
  geom_point(data = cbc_circles, aes(x = longitude, y = latitude), size = .01, 
             shape = 20) + 
  theme_minimal() + no_axis +
  theme(plot.title = element_text(size=13, face="bold"))

filename = paste("Output/CBC_Circles_24km_plusVoronoi.png")
ggsave(filename, width = 11, height = 11)
filename = paste("Output/CBC_Circles_24km_plusVoronoi.pdf")
ggsave(filename, width = 11, height = 11)

##########################################################
#Join each CBC point with its associated buffer 
#First, convert polygons into spatial polygons dataframe
buffer_12_5_spatial <- as(circles_buffer12_5, 'Spatial')
#Now convert to spatial polygons dataframe 
buffer_12_5_spatial_df <- as(buffer_12_5_spatial, "SpatialPolygonsDataFrame")
#Now convert CBC points to spatial points dataframe 
CBC_points_spatialdf <- SpatialPointsDataFrame(cbc_circles[,c("longitude", "latitude")], cbc_circles[,1:6])

#Convert CBC circles into sf object
projcrs <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
cbc_circles_sf <- st_as_sf(x = cbc_circles,                         
                           coords = c("longitude", "latitude"),
                           crs = projcrs)


#Join CBC sf object with sfc_geometry 
buffer_12_5_new_format <- st_as_sf(circles_buffer12_5)
buffer_12_5_new_format <- st_set_crs(buffer_12_5_new_format, 4269)
cbc_circles_sf <- st_set_crs(cbc_circles_sf, 4269)
CBC_plus_buffer_12_5 <- st_join(buffer_12_5_new_format, cbc_circles_sf)

#Repeat for other buffer distances 
buffer_13_5_spatial <- as(circles_buffer13_5, 'Spatial')
buffer_13_5_spatial_df <- as(buffer_13_5_spatial, "SpatialPolygonsDataFrame")
buffer_13_5_new_format <- st_as_sf(circles_buffer13_5)
buffer_13_5_new_format <- st_set_crs(buffer_13_5_new_format, 4269)
CBC_plus_buffer_13_5 <- st_join(buffer_13_5_new_format, cbc_circles_sf)

buffer_14_5_spatial <- as(circles_buffer14_5, 'Spatial')
buffer_14_5_spatial_df <- as(buffer_14_5_spatial, "SpatialPolygonsDataFrame")
buffer_14_5_new_format <- st_as_sf(circles_buffer14_5)
buffer_14_5_new_format <- st_set_crs(buffer_14_5_new_format, 4269)
CBC_plus_buffer_14_5 <- st_join(buffer_14_5_new_format, cbc_circles_sf)

buffer_17_5_spatial <- as(circles_buffer17_5, 'Spatial')
buffer_17_5_spatial_df <- as(buffer_17_5_spatial, "SpatialPolygonsDataFrame")
buffer_17_5_new_format <- st_as_sf(circles_buffer17_5)
buffer_17_5_new_format <- st_set_crs(buffer_17_5_new_format, 4269)
CBC_plus_buffer_17_5 <- st_join(buffer_17_5_new_format, cbc_circles_sf)

buffer_22_5_spatial <- as(circles_buffer22_5, 'Spatial')
buffer_22_5_spatial_df <- as(buffer_22_5_spatial, "SpatialPolygonsDataFrame")
buffer_22_5_new_format <- st_as_sf(circles_buffer22_5)
buffer_22_5_new_format <- st_set_crs(buffer_22_5_new_format, 4269)
CBC_plus_buffer_22_5 <- st_join(buffer_22_5_new_format, cbc_circles_sf)


###################################################
#Plot only turbines 
ggplot() +
  ggtitle("B. Wind Turbine Projects (2000-2020)") +
geom_sf(data=us_lower48_states, size=.25) +
  #geom_sf(data=polygons_combined, color= "black", size=.1, alpha = 0.25) +
  geom_point(data = wind_turbines, aes(x = longitude, y = latitude, size = cumulative_capacity_mw, colour = year_operational), 
             shape = 1, stroke=.1) +
  scale_colour_viridis(direction = 1, option = "D")+
  labs(size="Capacity (MW)", color = "Year Operational")+
  theme_minimal() + no_axis +
  theme(plot.title = element_text(size = 20, face = "bold"),
        legend.title=element_text(size=18), 
        legend.text=element_text(size=16))

filename = paste("Output/WindTurbines.png")
ggsave(filename, width = 11, height = 11)
filename = paste("Output/WindTurbines.pdf")
ggsave(filename, width = 11, height = 11)

###############################################
#Plot only shale wells 
ggplot() +
  ggtitle("A. Shale Oil and Gas Fields (2000-2020)") +
  geom_sf(data=us_lower48_states, size=.25) +
  #geom_sf(data=polygons_combined, color= "black", size=.01, alpha = 0.01) +
  geom_point(data = shale_fields, aes(x = lon, y = lat, colour = year, size = shale_wells_num), 
             shape = 1, stroke=.1) +
  scale_colour_viridis(direction = 1, option = "C")+
  labs(color = "Year Completed", size="Number of Wells")+
  theme_minimal() + no_axis +
theme(plot.title = element_text(size = 20, face = "bold"),
      legend.title=element_text(size=18), 
      legend.text=element_text(size=16))

filename = paste("Output/ShaleWells.png")
ggsave(filename, width = 11, height = 11)
filename = paste("Output/ShaleWells.pdf")
ggsave(filename, width = 11, height = 11)

###############################################
#Plot turbines and shale wells 
ggplot() +
  ggtitle("Expansion of Wind Turbines and Shale Wells  (2000-2020)") +
  geom_sf(data=us_lower48_states, size=.25) +
  #geom_point(data = cbc_circles, aes(x = longitude, y = latitude), size = .001, 
             #shape = 19,color="grey52") + 
  #geom_sf(data=polygons_combined, color= "black", size=.01, alpha = 0.01) +
  geom_point(data = wind_turbines, aes(x = longitude, y = latitude, size = cumulative_capacity_mw, colour = year_operational), 
             shape = 1, stroke=.1) +
  scale_colour_viridis(direction = 1, option = "D")+
  labs(size="Capacity (MW)", color = "Wells: Year Operational")+
  ggnewscale::new_scale_color() +
  geom_point(data = shale_fields, aes(x = lon, y = lat, colour = year, size = shale_wells_num), 
             shape = 1, stroke=.1) +
  scale_colour_viridis(direction = 1, option = "C")+
  labs(color = "Turbines: Year Completed", size="Number of Wells")+
  theme_minimal() + no_axis +
  theme(plot.title = element_text(size = 16),
        legend.title=element_text(size=16), 
        legend.text=element_text(size=15))
#, face = "bold"

##############################################################################
#Now join each CBC point with it's associated spatial polygon
#First, convert polygons into spatial polygons dataframe
polygons_combined_spatial <- as(polygons_combined, 'Spatial')
#Now convert to spatial polygons dataframe 
polygons_combined_spatial_df <- as(polygons_combined_spatial, "SpatialPolygonsDataFrame")
#Now convert CBC points to spatial points dataframe 
CBC_points_spatialdf <- SpatialPointsDataFrame(cbc_circles[,c("longitude", "latitude")], cbc_circles[,1:6])

#Convert CBC circles into sf object
projcrs <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
cbc_circles_sf <- st_as_sf(x = cbc_circles,                         
               coords = c("longitude", "latitude"),
               crs = projcrs)

                      
#Join CBC sf object with sfc_geometry 
polygons_new_format <- st_as_sf(polygons_combined)
polygons_new_format <- st_set_crs(polygons_new_format, 4269)
cbc_circles_sf <- st_set_crs(cbc_circles_sf, 4269)
polygons_plus_CBC <- st_join(polygons_new_format, cbc_circles_sf)


##########################################################################
#Spatial join wind turbines with CBC polygons 
wind_turbines_sf <- st_as_sf(x = wind_turbines,                         
                           coords = c("longitude", "latitude"),
                           crs = projcrs)

wind_turbines_sf <- st_set_crs(wind_turbines_sf, 4269)

polygons_plus_CBC_wind <- st_join(wind_turbines_sf, polygons_plus_CBC, left=F)

polygons_plus_CBC_wind_df <- polygons_plus_CBC_wind
polygons_plus_CBC_wind_df$geometry <- NULL
polygons_plus_CBC_wind_df <- as.data.frame(polygons_plus_CBC_wind_df)

chars <- c('turbine_state', 'turbine_county', 'turbine_model', 'period', 'circle', 'circle_name',
           'state')
for(i in chars){
  polygons_plus_CBC_wind_df[, i] <- as.character(polygons_plus_CBC_wind_df[,i])
  polygons_plus_CBC_wind_df[which(polygons_plus_CBC_wind_df[,i]==""), i] <- "NA"
}


write.dta(polygons_plus_CBC_wind_df, file = "Data/Intermediate/CBC_circles_wind.dta")

#######
#Repeat this process for buffer zones around points 
#First, 12.5 buffer 
CBC_buffer_12_5_plus_wind <- st_join(wind_turbines_sf, CBC_plus_buffer_12_5, left=F)

CBC_buffer_12_5_plus_wind_df <- CBC_buffer_12_5_plus_wind
CBC_buffer_12_5_plus_wind_df$geometry <- NULL
CBC_buffer_12_5_plus_wind_df <- as.data.frame(CBC_buffer_12_5_plus_wind_df)

chars <- c('turbine_state', 'turbine_county', 'turbine_model', 'period', 'circle.x', 'circle_name.x',
           'state.x', 'circle.y', 'circle_name.y','state.y')
for(i in chars){
  CBC_buffer_12_5_plus_wind_df[, i] <- as.character(CBC_buffer_12_5_plus_wind_df[,i])
  CBC_buffer_12_5_plus_wind_df[which(CBC_buffer_12_5_plus_wind_df[,i]==""), i] <- "NA"
}


write.dta(CBC_buffer_12_5_plus_wind_df, file = "Data/Intermediate/CBC_circles_wind_12_5_buffer.dta")

#Next, 13.5, 17.5, and 22.5 buffers 
CBC_buffer_13_5_plus_wind <- st_join(wind_turbines_sf, CBC_plus_buffer_13_5, left=F)
CBC_buffer_14_5_plus_wind <- st_join(wind_turbines_sf, CBC_plus_buffer_14_5, left=F)
CBC_buffer_17_5_plus_wind <- st_join(wind_turbines_sf, CBC_plus_buffer_17_5, left=F)
CBC_buffer_22_5_plus_wind <- st_join(wind_turbines_sf, CBC_plus_buffer_22_5, left=F)

CBC_buffer_13_5_plus_wind_df <- CBC_buffer_13_5_plus_wind
CBC_buffer_13_5_plus_wind_df$geometry <- NULL
CBC_buffer_13_5_plus_wind_df <- as.data.frame(CBC_buffer_13_5_plus_wind_df)

CBC_buffer_14_5_plus_wind_df <- CBC_buffer_14_5_plus_wind
CBC_buffer_14_5_plus_wind_df$geometry <- NULL
CBC_buffer_14_5_plus_wind_df <- as.data.frame(CBC_buffer_14_5_plus_wind_df)

CBC_buffer_17_5_plus_wind_df <- CBC_buffer_17_5_plus_wind
CBC_buffer_17_5_plus_wind_df$geometry <- NULL
CBC_buffer_17_5_plus_wind_df <- as.data.frame(CBC_buffer_17_5_plus_wind_df)

CBC_buffer_22_5_plus_wind_df <- CBC_buffer_22_5_plus_wind
CBC_buffer_22_5_plus_wind_df$geometry <- NULL
CBC_buffer_22_5_plus_wind_df <- as.data.frame(CBC_buffer_22_5_plus_wind_df)

chars <- c('turbine_state', 'turbine_county', 'turbine_model', 'period', 'circle.x', 'circle_name.x',
           'state.x', 'circle.y', 'circle_name.y','state.y')
for(i in chars){
  CBC_buffer_13_5_plus_wind_df[, i] <- as.character(CBC_buffer_13_5_plus_wind_df[,i])
  CBC_buffer_13_5_plus_wind_df[which(CBC_buffer_13_5_plus_wind_df[,i]==""), i] <- "NA"
  CBC_buffer_14_5_plus_wind_df[, i] <- as.character(CBC_buffer_14_5_plus_wind_df[,i])
  CBC_buffer_14_5_plus_wind_df[which(CBC_buffer_14_5_plus_wind_df[,i]==""), i] <- "NA"
  CBC_buffer_17_5_plus_wind_df[, i] <- as.character(CBC_buffer_17_5_plus_wind_df[,i])
  CBC_buffer_17_5_plus_wind_df[which(CBC_buffer_17_5_plus_wind_df[,i]==""), i] <- "NA"
  CBC_buffer_22_5_plus_wind_df[, i] <- as.character(CBC_buffer_22_5_plus_wind_df[,i])
  CBC_buffer_22_5_plus_wind_df[which(CBC_buffer_22_5_plus_wind_df[,i]==""), i] <- "NA"
}


write.dta(CBC_buffer_13_5_plus_wind_df, file = "Data/Intermediate/CBC_circles_wind_13_5_buffer.dta")
write.dta(CBC_buffer_14_5_plus_wind_df, file = "Data/Intermediate/CBC_circles_wind_14_5_buffer.dta")
write.dta(CBC_buffer_17_5_plus_wind_df, file = "Data/Intermediate/CBC_circles_wind_17_5_buffer.dta")
write.dta(CBC_buffer_22_5_plus_wind_df, file = "Data/Intermediate/CBC_circles_wind_22_5_buffer.dta")

##########################################################################
#Spatial join shale fields with CBC polygons 
shale_fields_sf <- st_as_sf(x = shale_fields,                         
                             coords = c("lon", "lat"),
                             crs = projcrs)

shale_fields_sf <- st_set_crs(shale_fields_sf, 4269)

polygons_plus_CBC_shale <- st_join(shale_fields_sf, polygons_plus_CBC, left=F)

polygons_plus_CBC_shale_df <- polygons_plus_CBC_shale
polygons_plus_CBC_shale_df$geometry <- NULL
polygons_plus_CBC_shale_df <- as.data.frame(polygons_plus_CBC_shale_df)



chars <- c('field', 'deposit_environ', 'circle', 'circle_name',
           'state')
for(i in chars){
  polygons_plus_CBC_shale_df[, i] <- as.character(polygons_plus_CBC_shale_df[,i])
  polygons_plus_CBC_shale_df[which(polygons_plus_CBC_shale_df[,i]==""), i] <- "NA"
}


write.dta(polygons_plus_CBC_shale_df, file = "C:/Users/17637/Dropbox/PhD/Research/Birds/Data/Intermediate/CBC_circles_shale.dta")

#######
#Repeat this process for buffer zones around points 
#First, 12.5 buffer 
CBC_buffer_12_5_plus_shale <- st_join(shale_fields_sf, CBC_plus_buffer_12_5, left=F)

CBC_buffer_12_5_plus_shale_df <- CBC_buffer_12_5_plus_shale
CBC_buffer_12_5_plus_shale_df$geometry <- NULL
CBC_buffer_12_5_plus_shale_df <- as.data.frame(CBC_buffer_12_5_plus_shale_df)

chars <- c('field', 'deposit_environ', 'circle.x', 'circle_name.x',
           'state.x', 'circle.y', 'circle_name.y',
           'state.y')
for(i in chars){
  CBC_buffer_12_5_plus_shale_df[, i] <- as.character(CBC_buffer_12_5_plus_shale_df[,i])
  CBC_buffer_12_5_plus_shale_df[which(CBC_buffer_12_5_plus_shale_df[,i]==""), i] <- "NA"
}


write.dta(CBC_buffer_12_5_plus_shale_df, file = "Data/Intermediate/CBC_circles_shale_12_5_buffer.dta")

#Next, 13.5, 17.5, and 22.5 buffers 
CBC_buffer_13_5_plus_shale <- st_join(shale_fields_sf, CBC_plus_buffer_13_5, left=F)
CBC_buffer_17_5_plus_shale <- st_join(shale_fields_sf, CBC_plus_buffer_17_5, left=F)
CBC_buffer_22_5_plus_shale <- st_join(shale_fields_sf, CBC_plus_buffer_22_5, left=F)

CBC_buffer_13_5_plus_shale_df <- CBC_buffer_13_5_plus_shale
CBC_buffer_13_5_plus_shale_df$geometry <- NULL
CBC_buffer_13_5_plus_shale_df <- as.data.frame(CBC_buffer_13_5_plus_shale_df)

CBC_buffer_17_5_plus_shale_df <- CBC_buffer_17_5_plus_shale
CBC_buffer_17_5_plus_shale_df$geometry <- NULL
CBC_buffer_17_5_plus_shale_df <- as.data.frame(CBC_buffer_17_5_plus_shale_df)

CBC_buffer_22_5_plus_shale_df <- CBC_buffer_22_5_plus_shale
CBC_buffer_22_5_plus_shale_df$geometry <- NULL
CBC_buffer_22_5_plus_shale_df <- as.data.frame(CBC_buffer_22_5_plus_shale_df)

chars <- c('field', 'deposit_environ', 'circle.x', 'circle_name.x',
           'state.x', 'circle.y', 'circle_name.y',
           'state.y')
for(i in chars){
  CBC_buffer_13_5_plus_shale_df[, i] <- as.character(CBC_buffer_13_5_plus_shale_df[,i])
  CBC_buffer_13_5_plus_shale_df[which(CBC_buffer_13_5_plus_shale_df[,i]==""), i] <- "NA"
  CBC_buffer_17_5_plus_shale_df[, i] <- as.character(CBC_buffer_17_5_plus_shale_df[,i])
  CBC_buffer_17_5_plus_shale_df[which(CBC_buffer_17_5_plus_shale_df[,i]==""), i] <- "NA"
  CBC_buffer_22_5_plus_shale_df[, i] <- as.character(CBC_buffer_22_5_plus_shale_df[,i])
  CBC_buffer_22_5_plus_shale_df[which(CBC_buffer_22_5_plus_shale_df[,i]==""), i] <- "NA"
}


write.dta(CBC_buffer_13_5_plus_shale_df, file = "Data/Intermediate/CBC_circles_shale_13_5_buffer.dta")
write.dta(CBC_buffer_17_5_plus_shale_df, file = "Data/Intermediate/CBC_circles_shale_17_5_buffer.dta")
write.dta(CBC_buffer_22_5_plus_shale_df, file = "Data/Intermediate/CBC_circles_shale_22_5_buffer.dta")


#############################################################################
#Merge in bird data at circle-year level 
cbc_20yr_birds <- read.csv("Data/Intermediate/CBC_Circles_20YrAvgBirds.csv")

cbc_20yr_birds_circles <- merge(polygons_plus_CBC, cbc_20yr_birds, by = 'circle_id')

#Map bird circles by population number (winsorized)
ggplot() +
  geom_sf(data=us_lower48_states, size=1.25) +
  geom_sf(data=cbc_20yr_birds_circles, aes(fill=number_seen_w), color=NA, size=.15) +
  scale_fill_viridis(option = "viridis") +
  theme_minimal() + no_axis +
  theme(plot.title = element_text(size=11))

#Number seen per counter (winsorized)
ggplot() +
  ggtitle("B. Number of Birds Reported (Winsorized)") +
  geom_sf(data=us_lower48_states, size=1.25) +
  geom_sf(data=cbc_20yr_birds_circles, aes(fill=number_seen_per_counter_w), color=NA, size=.15) +
  scale_fill_viridis(option = "viridis") +
  labs(fill = "Number")+
  theme_minimal() + no_axis +
  theme(plot.title = element_text(size = 20, face = "bold"),
        legend.title=element_text(size=18), 
        legend.text=element_text(size=16))

filename = paste("Output/Number_per_Counter.png")
ggsave(filename, width = 11, height = 11)
filename = paste("Output/Number_per_Counter.pdf")
ggsave(filename, width = 11, height = 11)

#Number seen per counter total
ggplot() +
  geom_sf(data=us_lower48_states, size=1.25) +
  geom_sf(data=cbc_20yr_birds_circles, aes(fill=number_seen_per_counter), color=NA, size=.15) +
  scale_fill_viridis(option = "viridis") +
  theme_minimal() + no_axis +
  theme(plot.title = element_text(size=11))

#Species seen
ggplot() +
  ggtitle("C. Number of Species Reported") +
  geom_sf(data=us_lower48_states, size=1.25) +
  geom_sf(data=cbc_20yr_birds_circles, aes(fill=total_species_manual), color=NA, size=.15) +
  scale_fill_viridis(option = "viridis") +
  labs(fill = "Species")+
  theme_minimal() + no_axis +
  theme(plot.title = element_text(size = 20, face = "bold"),
        legend.title=element_text(size=18), 
        legend.text=element_text(size=16))

filename = paste("Output/Species_Reported.png")
ggsave(filename, width = 11, height = 11)
filename = paste("Output/Species_Reported.pdf")
ggsave(filename, width = 11, height = 11)

##########################################
#Plot Important Bird Areas
ggplot() +
  ggtitle("D. CBC Circle Locations in Relation to Important Bird Areas") +
  geom_sf(data=us_lower48_states, size=1.25) +
  #geom_sf(data=polygons_combined, color= "black", size=.25) +
  geom_sf(data=important_bird_areas_lower48, color="green3", fill="green3") +
  geom_point(data = cbc_circles, aes(x = longitude, y = latitude), size = .5, 
             shape = 21) + 
  #geom_point(data = important_bird_areas_lower48, aes(x = "LONGITUDE", y = "LATITUDE"), size = .5, 
            #shape = 21, color="black") + 
  theme_minimal() + no_axis +
  theme(plot.title = element_text(size = 20, face = "bold"))
     

filename = paste("Output/ImportantBirdAreas.png")
ggsave(filename, width = 11, height = 11)
filename = paste("Output/ImportantBirdAreas.pdf")
ggsave(filename, width = 11, height = 11)

#Convert circle points to spatial points type: 
#CBC_points_spatialdf
test <- apply(gDistance(CBC_points_spatialdf, important_bird_areas_lower48,byid=TRUE),2,min)


#########################################
#Merge US counties with US county population panel
county_population_panel <- merge(us_counties, county_population, by = 'FIPS')
county_pop_panel_simplified <- county_population_panel[c("FIPS", "NAME", "STATE_NAME", "panel_population", "year")]

#Tie each bird circle point to the county polygon it overlaps with, and attach population for each year from that county
#First, convert county polygons into spatial polygons dataframe
#county_spatial <- as(county_pop_panel_simplified, 'Spatial')
#Now convert counties to spatial polygons dataframe 
#county_spatial_df <- as(county_spatial, "SpatialPolygonsDataFrame")

#Join CBC sf object with sfc_geometry 
counties_new_format <- st_as_sf(county_pop_panel_simplified)
counties_new_format <- st_set_crs(counties_new_format, 4269)

#This is the equivalent of wind_turbines_sf: cbc_circles_sf
#This is the equivalent of polygons_plus_CBC: 

sf_use_s2(FALSE)
counties_plus_cbc <- st_join(counties_new_format, cbc_circles_sf)
#counties_plus_cbc <- st_join(cbc_circles_sf, counties_new_format, left=F)

counties_plus_cbc_df <- counties_plus_cbc
counties_plus_cbc_df$geometry <- NULL
counties_plus_cbc_df <- as.data.frame(counties_plus_cbc_df)

write.dta(counties_plus_cbc_df, file = "Data/Intermediate/Circles_with_CountyPopulation.dta")


##############################################################################################
#Determine whether CBC circles lie inside important bird areas
#Prepare circle points 
cbc_circles_transformed <- st_transform(cbc_circles, 4326)

#Prepare important bird areas 
important_areas_corrected <- important_bird_areas_lower48[!is.na(important_bird_areas_lower48$LATITUDE), ]
important_areas_transformed <- st_transform(important_areas_corrected, 4326)

sf_use_s2(FALSE)

circles_within_importantareas <- st_intersects(cbc_circles_transformed, important_areas_transformed)

circles_within_importantareas_df <- data.frame(circles_within_importantareas)

#Merge this dataframe with cbc_circles 
cbc_circles$row.id <- seq.int(nrow(cbc_circles))
cbc_circles_withareas <- merge(cbc_circles, circles_within_importantareas_df, by = 'row.id')

cbc_circles_withareas$geometry <- NULL
write.dta(cbc_circles_withareas, "Data/Intermediate/CBC_Circles_in_ImportantAreas.dta")

#####################################
#Map breeding bird survey locations 
ggplot() +
  ggtitle("Breeding Bird Survey Locations") +
  geom_sf(data=us_lower48_states, size=1.25) +
  geom_point(data = breeding_bird_surveys, aes(x = longitude, y = latitude), size = .01, 
             shape = 20) + 
  theme_minimal() + no_axis +
  theme(plot.title = element_text(size=12, face="bold"))

#Convert CBC circles into sf object
projcrs2 <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
breeding_forspatial <- breeding_bird_surveys
breeding_sf1 <- st_as_sf(x = breeding_forspatial,                         
                            coords = c("longitude", "latitude"),
                            crs = projcrs2)
breeding_sf1 <- st_set_crs(breeding_sf1, 4269)

#Plot buffer
breeding_10 <- st_buffer(breeding_sf1, 10000)
breeding_2 <- st_buffer(breeding_sf1, 2000)
breeding_5 <- st_buffer(breeding_sf1, 5000)

#Plot points with buffers 
ggplot() +
  ggtitle("Breeding Bird Survey Zones") +
  geom_sf(data=us_lower48_states, size=1.25) +
  geom_sf(data = breeding_5, size=.01, color = 'red') +
  geom_point(data = breeding_bird_surveys, aes(x = longitude, y = latitude), size = .01, 
             shape = 20) + 
  theme_minimal() + no_axis +
  theme(plot.title = element_text(size=11))

#Join each breeding point with its associated buffer 
#First, convert polygons into spatial polygons dataframe
breeding_10_spatial <- as(breeding_10, 'Spatial')
#Now convert to spatial polygons dataframe 
breeding_10_spatial_df <- as(breeding_10_spatial, "SpatialPolygonsDataFrame")
#Now convert CBC points to spatial points dataframe 
BreedingPoints10_spatialdf <- SpatialPointsDataFrame(breeding_bird_surveys[,c("longitude", "latitude")], breeding_bird_surveys[,1:5])

#Join CBC sf object with sfc_geometry 
breeding_10_new_format <- st_as_sf(breeding_10)
breeding_10_new_format <- st_set_crs(breeding_10_new_format, 4269)
breeding_sf <- st_set_crs(breeding_sf, 4269)
breeding_plusbuffer_10 <- st_join(breeding_10_new_format, breeding_sf)

#First, 10km
breeding_10_pluswind <- st_join(wind_turbines_sf, breeding_plusbuffer_10, left=F)
breeding_10_pluswind_df <- breeding_10_pluswind
breeding_10_pluswind_df$geometry <- NULL
breeding_10_pluswind_df <- as.data.frame(breeding_10_pluswind_df)

chars <- c('turbine_state', 'turbine_county', 'turbine_model', 'period', 'unique_route_id.x', 'routename.x',
           'state_name.x', 'unique_route_id.y', 'routename.y','state_name.y')
for(i in chars){
  breeding_10_pluswind_df[, i] <- as.character(breeding_10_pluswind_df[,i])
  breeding_10_pluswind_df[which(breeding_10_pluswind_df[,i]==""), i] <- "NA"
}


write.dta(breeding_10_pluswind_df, file = "Data/Intermediate/BreedingBirds_10km_Wind.dta")

#Repeat for 5km buffer 
breeding_5_spatial <- as(breeding_5, 'Spatial')
breeding_5_spatial_df <- as(breeding_5_spatial, "SpatialPolygonsDataFrame")
BreedingPoints5_spatialdf <- SpatialPointsDataFrame(breeding_bird_surveys[,c("longitude", "latitude")], breeding_bird_surveys[,1:5])

breeding_5_new_format <- st_as_sf(breeding_5)
breeding_5_new_format <- st_set_crs(breeding_5_new_format, 4269)
breeding_plusbuffer_5 <- st_join(breeding_5_new_format, breeding_sf)

breeding_5_pluswind <- st_join(wind_turbines_sf, breeding_plusbuffer_5, left=F)
breeding_5_pluswind_df <- breeding_5_pluswind
breeding_5_pluswind_df$geometry <- NULL
breeding_5_pluswind_df <- as.data.frame(breeding_5_pluswind_df)

chars <- c('turbine_state', 'turbine_county', 'turbine_model', 'period', 'unique_route_id.x', 'routename.x',
           'state_name.x', 'unique_route_id.y', 'routename.y','state_name.y')
for(i in chars){
  breeding_5_pluswind_df[, i] <- as.character(breeding_5_pluswind_df[,i])
  breeding_5_pluswind_df[which(breeding_5_pluswind_df[,i]==""), i] <- "NA"
}

write.dta(breeding_5_pluswind_df, file = "Data/Intermediate/BreedingBirds_5km_Wind.dta")

###############################################
#Repeat for shale 
breeding_10_spatial <- as(breeding_10, 'Spatial')
breeding_10_spatial_df <- as(breeding_10_spatial, "SpatialPolygonsDataFrame")
BreedingPoints10_spatialdf <- SpatialPointsDataFrame(breeding_bird_surveys[,c("longitude", "latitude")], breeding_bird_surveys[,1:5])

breeding_10_new_format <- st_as_sf(breeding_10)
breeding_10_new_format <- st_set_crs(breeding_10_new_format, 4269)
breeding_plusbuffer_10 <- st_join(breeding_10_new_format, breeding_sf)


breeding_5_spatial <- as(breeding_5, 'Spatial')
breeding_5_spatial_df <- as(breeding_5_spatial, "SpatialPolygonsDataFrame")
BreedingPoints5_spatialdf <- SpatialPointsDataFrame(breeding_bird_surveys[,c("longitude", "latitude")], breeding_bird_surveys[,1:5])

breeding_5_new_format <- st_as_sf(breeding_5)
breeding_5_new_format <- st_set_crs(breeding_5_new_format, 4269)
breeding_plusbuffer_5 <- st_join(breeding_5_new_format, breeding_sf)

#First, 1km
breeding_10_plusshale <- st_join(shale_fields_sf, breeding_plusbuffer_10, left=F)
breeding_10_plusshale_df <- breeding_10_plusshale
breeding_10_plusshale_df$geometry <- NULL
breeding_10_plusshale_df <- as.data.frame(breeding_10_plusshale_df)

chars <- c('field', 'deposit_environ', 'unique_route_id.x', 'routename.x',
           'state_name.x', 'unique_route_id.y', 'routename.y','state_name.y')
for(i in chars){
  breeding_10_plusshale_df[, i] <- as.character(breeding_10_plusshale_df[,i])
  breeding_10_plusshale_df[which(breeding_10_plusshale_df[,i]==""), i] <- "NA"
}


write.dta(breeding_10_plusshale_df, file = "Data/Intermediate/BreedingBirds_10km_Shale.dta")

#Repeat for 5km buffer 
breeding_5_plusshale <- st_join(shale_fields_sf, breeding_plusbuffer_5, left=F)
breeding_5_plusshale_df <- breeding_5_plusshale
breeding_5_plusshale_df$geometry <- NULL
breeding_5_plusshale_df <- as.data.frame(breeding_5_plusshale_df)

chars <- c('field', 'deposit_environ', 'unique_route_id.x', 'routename.x',
           'state_name.x', 'unique_route_id.y', 'routename.y','state_name.y')
for(i in chars){
  breeding_5_plusshale_df[, i] <- as.character(breeding_5_plusshale_df[,i])
  breeding_5_plusshale_df[which(breeding_5_plusshale_df[,i]==""), i] <- "NA"
}

write.dta(breeding_5_plusshale_df, file = "Data/Intermediate/BreedingBirds_5km_Shale.dta")

