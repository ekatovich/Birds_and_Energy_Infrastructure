# Load required libraries
library(sf)
library(terra)
library(sp)
library(raster)
library(rgeos)
library(lattice)
library(rasterVis)
library(raster)
library(rgdal)
library(reshape2)
library(treemapify)
library(ggplot2)
library(animation)
library(dplyr)
library(rio)
library(geosphere)
library(foreign)
library(viridisLite)
library(viridis)
library(Rfast)
library(ggvoronoi)
library(deldir)
library(dismo)
library(maptools)
library(maps)
library(tmap)
library(FedData)
library(knitr)

# Set your working directory to the folder where the files are located
setwd("C:/Users/katovich/Dropbox/PhD/Research/Birds/Data/Intermediate")

# Import the .csv file with latitude/longitude coordinates
csv_file <- "CBC_Circle_Centroids.csv"
coordinates_data <- read.csv(csv_file)

coordinates_data <- coordinates_data %>% mutate(longitude_plus = longitude + .076)
coordinates_data <- coordinates_data %>% mutate(longitude_minus = longitude - .076)
coordinates_data <- coordinates_data %>% mutate(latitude_plus = latitude + .076)
coordinates_data_twopoints <- coordinates_data %>% mutate(latitude_minus = latitude - .076)

####################################################################
#Loop over all circles in 2006
#Begin loop here 
values_to_loop <- c(49:488, 506:2234)

extraction.dir <- "buffer_rasters"

combined_landcover_results_2006 <- list()

for (current_value in values_to_loop) {
  
  point <- subset(coordinates_data_twopoints, circle_id == current_value)
  
  circle_latlon1 <- point[, c(1, 9, 7)]
  colnames(circle_latlon1)[2] <- "latitude"
  colnames(circle_latlon1)[3] <- "longitude"
  
  circle_latlon2 <- point[, c(1, 10, 8)]
  colnames(circle_latlon2)[2] <- "latitude"
  colnames(circle_latlon2)[3] <- "longitude"
  
  circle_boundaries <- rbind(circle_latlon1, circle_latlon2)
  
  midpoint <- data.frame(latitude = mean(circle_boundaries$latitude), 
                         longitude = mean(circle_boundaries$longitude))
  
  coordinates(circle_boundaries) <- ~longitude + latitude
  proj4string(circle_boundaries) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")
  
  coordinates(midpoint) <- ~longitude + latitude
  proj4string(midpoint) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")
  
  nlcd_raster <- get_nlcd(template = circle_boundaries, 
                          label = current_value, 
                          year = 2006, 
                          extraction.dir = extraction.dir,
                          force.redo = TRUE)
  
  #Try this new section
  # Create a unique file name for each raster
  raster_filename <- paste("nlcd_", current_value, "_raster.tif", sep = "")
  
  # Construct the full file path
  full_filepath <- file.path(extraction.dir, raster_filename)
  
  # Write the raster to the specified file
  writeRaster(nlcd_raster, filename = full_filepath, overwrite = TRUE)
  ##################
  
  midpoint <- spTransform(midpoint, projection(nlcd_raster))
  
  buffer_distance_meters <- 12050
  
  buff_shp <- buffer(midpoint, buffer_distance_meters)
  
  plot(nlcd_raster)
  plot(buff_shp, add = TRUE)
  
  landcover <- extract(nlcd_raster, midpoint, buffer = buffer_distance_meters)
  
  str(landcover)
  
  landcover_proportions <- lapply(landcover, function(x) {
    counts_x <- table(x)
    proportions_x <- prop.table(counts_x)
    sort(proportions_x)
  })
  
  combined_landcover_results_2006 <- c(combined_landcover_results_2006, landcover_proportions)
  }


legend<-pal_nlcd()
legend

#Convert list of lists to data frame 

#First, make all vectors the same length by filling in 0s for missings
max.length <- max(sapply(combined_landcover_results_2006,length))
combined_landcover_results_2006 <- lapply(lapply(combined_landcover_results_2006, unlist), "length<-", max.length)

circle_landuse_proportions_2006 <- do.call(rbind, combined_landcover_results_2006)
colnames(circle_landuse_proportions_2006)[colnames(circle_landuse_proportions_2006) == "11"] <- "open_water"
colnames(circle_landuse_proportions_2006)[colnames(circle_landuse_proportions_2006) == "12"] <- "perennial_ice_snow"
colnames(circle_landuse_proportions_2006)[colnames(circle_landuse_proportions_2006) == "21"] <- "developed_openspace"
colnames(circle_landuse_proportions_2006)[colnames(circle_landuse_proportions_2006) == "22"] <- "developed_lowintensity"
colnames(circle_landuse_proportions_2006)[colnames(circle_landuse_proportions_2006) == "23"] <- "developed_medintensity"
colnames(circle_landuse_proportions_2006)[colnames(circle_landuse_proportions_2006) == "24"] <- "developed_highintensity"
colnames(circle_landuse_proportions_2006)[colnames(circle_landuse_proportions_2006) == "31"] <- "barren_land"
colnames(circle_landuse_proportions_2006)[colnames(circle_landuse_proportions_2006) == "41"] <- "deciduous_forest"
colnames(circle_landuse_proportions_2006)[colnames(circle_landuse_proportions_2006) == "42"] <- "evergreen_forest"
colnames(circle_landuse_proportions_2006)[colnames(circle_landuse_proportions_2006) == "43"] <- "mixed_forest"
colnames(circle_landuse_proportions_2006)[colnames(circle_landuse_proportions_2006) == "51"] <- "dwarf_scrub"
colnames(circle_landuse_proportions_2006)[colnames(circle_landuse_proportions_2006) == "52"] <- "shrub_scrub"
colnames(circle_landuse_proportions_2006)[colnames(circle_landuse_proportions_2006) == "71"] <- "grassland"
colnames(circle_landuse_proportions_2006)[colnames(circle_landuse_proportions_2006) == "72"] <- "sedge"
colnames(circle_landuse_proportions_2006)[colnames(circle_landuse_proportions_2006) == "73"] <- "lichens"
colnames(circle_landuse_proportions_2006)[colnames(circle_landuse_proportions_2006) == "74"] <- "moss"
colnames(circle_landuse_proportions_2006)[colnames(circle_landuse_proportions_2006) == "81"] <- "pasture"
colnames(circle_landuse_proportions_2006)[colnames(circle_landuse_proportions_2006) == "82"] <- "cultivated_crops"
colnames(circle_landuse_proportions_2006)[colnames(circle_landuse_proportions_2006) == "90"] <- "woody_wetlands"
colnames(circle_landuse_proportions_2006)[colnames(circle_landuse_proportions_2006) == "95"] <- "emergent_wetlands"

#Attach circle id numbers 
# Convert matrix/array to a dataframe (replace matrix_array with your actual object)
circle_landuse_proportions_2006_df <- as.data.frame(circle_landuse_proportions_2006)

# Add the 'circle_id' column
circle_landuse_proportions_2006_df <- circle_landuse_proportions_2006_df %>%
  mutate(circle_id = ifelse(row_number() <= 440, 48 + row_number(), 505 + row_number() - 440))

write.csv(circle_landuse_proportions_2006_df, "Circle_LandUse_Proportions_2006.csv", row.names=FALSE)


####################################################################
#Repeat for 2008
#Begin loop here 
values_to_loop <- c(49:488, 506:2234)

extraction.dir <- "buffer_rasters"

combined_landcover_results_2008 <- list()

for (current_value in values_to_loop) {
  
  point <- subset(coordinates_data_twopoints, circle_id == current_value)
  
  circle_latlon1 <- point[, c(1, 9, 7)]
  colnames(circle_latlon1)[2] <- "latitude"
  colnames(circle_latlon1)[3] <- "longitude"
  
  circle_latlon2 <- point[, c(1, 10, 8)]
  colnames(circle_latlon2)[2] <- "latitude"
  colnames(circle_latlon2)[3] <- "longitude"
  
  circle_boundaries <- rbind(circle_latlon1, circle_latlon2)
  
  midpoint <- data.frame(latitude = mean(circle_boundaries$latitude), 
                         longitude = mean(circle_boundaries$longitude))
  
  coordinates(circle_boundaries) <- ~longitude + latitude
  proj4string(circle_boundaries) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")
  
  coordinates(midpoint) <- ~longitude + latitude
  proj4string(midpoint) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")
  
  nlcd_raster <- get_nlcd(template = circle_boundaries, 
                          label = current_value, 
                          year = 2008, 
                          extraction.dir = extraction.dir,
                          force.redo = TRUE)
  
  #Try this new section
  # Create a unique file name for each raster
  raster_filename <- paste("nlcd_", current_value, "_raster.tif", sep = "")
  
  # Construct the full file path
  full_filepath <- file.path(extraction.dir, raster_filename)
  
  # Write the raster to the specified file
  writeRaster(nlcd_raster, filename = full_filepath, overwrite = TRUE)
  ##################
  
  midpoint <- spTransform(midpoint, projection(nlcd_raster))
  
  buffer_distance_meters <- 12050
  
  buff_shp <- buffer(midpoint, buffer_distance_meters)
  
  plot(nlcd_raster)
  plot(buff_shp, add = TRUE)
  
  landcover <- extract(nlcd_raster, midpoint, buffer = buffer_distance_meters)
  
  str(landcover)
  
  landcover_proportions <- lapply(landcover, function(x) {
    counts_x <- table(x)
    proportions_x <- prop.table(counts_x)
    sort(proportions_x)
  })
  
  combined_landcover_results_2008 <- c(combined_landcover_results_2008, landcover_proportions)
}

legend<-pal_nlcd()
legend

#Convert list of lists to data frame 

#First, make all vectors the same length by filling in 0s for missings
max.length <- max(sapply(combined_landcover_results_2008,length))
combined_landcover_results_2008 <- lapply(lapply(combined_landcover_results_2008, unlist), "length<-", max.length)

circle_landuse_proportions_2008 <- do.call(rbind, combined_landcover_results_2008)
colnames(circle_landuse_proportions_2008)[colnames(circle_landuse_proportions_2008) == "11"] <- "open_water"
colnames(circle_landuse_proportions_2008)[colnames(circle_landuse_proportions_2008) == "12"] <- "perennial_ice_snow"
colnames(circle_landuse_proportions_2008)[colnames(circle_landuse_proportions_2008) == "21"] <- "developed_openspace"
colnames(circle_landuse_proportions_2008)[colnames(circle_landuse_proportions_2008) == "22"] <- "developed_lowintensity"
colnames(circle_landuse_proportions_2008)[colnames(circle_landuse_proportions_2008) == "23"] <- "developed_medintensity"
colnames(circle_landuse_proportions_2008)[colnames(circle_landuse_proportions_2008) == "24"] <- "developed_highintensity"
colnames(circle_landuse_proportions_2008)[colnames(circle_landuse_proportions_2008) == "31"] <- "barren_land"
colnames(circle_landuse_proportions_2008)[colnames(circle_landuse_proportions_2008) == "41"] <- "deciduous_forest"
colnames(circle_landuse_proportions_2008)[colnames(circle_landuse_proportions_2008) == "42"] <- "evergreen_forest"
colnames(circle_landuse_proportions_2008)[colnames(circle_landuse_proportions_2008) == "43"] <- "mixed_forest"
colnames(circle_landuse_proportions_2008)[colnames(circle_landuse_proportions_2008) == "51"] <- "dwarf_scrub"
colnames(circle_landuse_proportions_2008)[colnames(circle_landuse_proportions_2008) == "52"] <- "shrub_scrub"
colnames(circle_landuse_proportions_2008)[colnames(circle_landuse_proportions_2008) == "71"] <- "grassland"
colnames(circle_landuse_proportions_2008)[colnames(circle_landuse_proportions_2008) == "72"] <- "sedge"
colnames(circle_landuse_proportions_2008)[colnames(circle_landuse_proportions_2008) == "73"] <- "lichens"
colnames(circle_landuse_proportions_2008)[colnames(circle_landuse_proportions_2008) == "74"] <- "moss"
colnames(circle_landuse_proportions_2008)[colnames(circle_landuse_proportions_2008) == "81"] <- "pasture"
colnames(circle_landuse_proportions_2008)[colnames(circle_landuse_proportions_2008) == "82"] <- "cultivated_crops"
colnames(circle_landuse_proportions_2008)[colnames(circle_landuse_proportions_2008) == "90"] <- "woody_wetlands"
colnames(circle_landuse_proportions_2008)[colnames(circle_landuse_proportions_2008) == "95"] <- "emergent_wetlands"

#Attach circle id numbers 
# Convert matrix/array to a dataframe (replace matrix_array with your actual object)
circle_landuse_proportions_2008_df <- as.data.frame(circle_landuse_proportions_2008)

# Add the 'circle_id' column
circle_landuse_proportions_2008_df <- circle_landuse_proportions_2008_df %>%
  mutate(circle_id = ifelse(row_number() <= 440, 48 + row_number(), 505 + row_number() - 440))

write.csv(circle_landuse_proportions_2008_df, "Circle_LandUse_Proportions_2008.csv", row.names=FALSE)


####################################################################
#Repeat for 2011
#Begin loop here 
values_to_loop <- c(49:488, 506:2234)

extraction.dir <- "buffer_rasters_2011"

combined_landcover_results_2011 <- list()

for (current_value in values_to_loop) {
  
  point <- subset(coordinates_data_twopoints, circle_id == current_value)
  
  circle_latlon1 <- point[, c(1, 9, 7)]
  colnames(circle_latlon1)[2] <- "latitude"
  colnames(circle_latlon1)[3] <- "longitude"
  
  circle_latlon2 <- point[, c(1, 10, 8)]
  colnames(circle_latlon2)[2] <- "latitude"
  colnames(circle_latlon2)[3] <- "longitude"
  
  circle_boundaries <- rbind(circle_latlon1, circle_latlon2)
  
  midpoint <- data.frame(latitude = mean(circle_boundaries$latitude), 
                         longitude = mean(circle_boundaries$longitude))
  
  coordinates(circle_boundaries) <- ~longitude + latitude
  proj4string(circle_boundaries) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")
  
  coordinates(midpoint) <- ~longitude + latitude
  proj4string(midpoint) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")
  
  nlcd_raster <- get_nlcd(template = circle_boundaries, 
                          label = current_value, 
                          year = 2011, 
                          extraction.dir = extraction.dir,
                          force.redo = TRUE)
  
  #Try this new section
  # Create a unique file name for each raster
  raster_filename <- paste("nlcd_", current_value, "_2011_raster.tif", sep = "")
  
  # Construct the full file path
  full_filepath <- file.path(extraction.dir, raster_filename)
  
  # Write the raster to the specified file
  writeRaster(nlcd_raster, filename = full_filepath, overwrite = TRUE)
  ##################
  
  midpoint <- spTransform(midpoint, projection(nlcd_raster))
  
  buffer_distance_meters <- 12050
  
  buff_shp <- buffer(midpoint, buffer_distance_meters)
  
  plot(nlcd_raster)
  plot(buff_shp, add = TRUE)
  
  landcover <- extract(nlcd_raster, midpoint, buffer = buffer_distance_meters)
  
  str(landcover)
  
  landcover_proportions <- lapply(landcover, function(x) {
    counts_x <- table(x)
    proportions_x <- prop.table(counts_x)
    sort(proportions_x)
  })
  
  combined_landcover_results_2011 <- c(combined_landcover_results_2011, landcover_proportions)
}

################################################################################
legend<-pal_nlcd()
legend

#Convert list of lists to data frame 

#First, make all vectors the same length by filling in 0s for missings
max.length <- max(sapply(combined_landcover_results_2011,length))
combined_landcover_results_2011 <- lapply(lapply(combined_landcover_results_2011, unlist), "length<-", max.length)

circle_landuse_proportions_2011 <- do.call(rbind, combined_landcover_results_2011)
colnames(circle_landuse_proportions_2011)[colnames(circle_landuse_proportions_2011) == "11"] <- "open_water"
colnames(circle_landuse_proportions_2011)[colnames(circle_landuse_proportions_2011) == "12"] <- "perennial_ice_snow"
colnames(circle_landuse_proportions_2011)[colnames(circle_landuse_proportions_2011) == "21"] <- "developed_openspace"
colnames(circle_landuse_proportions_2011)[colnames(circle_landuse_proportions_2011) == "22"] <- "developed_lowintensity"
colnames(circle_landuse_proportions_2011)[colnames(circle_landuse_proportions_2011) == "23"] <- "developed_medintensity"
colnames(circle_landuse_proportions_2011)[colnames(circle_landuse_proportions_2011) == "24"] <- "developed_highintensity"
colnames(circle_landuse_proportions_2011)[colnames(circle_landuse_proportions_2011) == "31"] <- "barren_land"
colnames(circle_landuse_proportions_2011)[colnames(circle_landuse_proportions_2011) == "41"] <- "deciduous_forest"
colnames(circle_landuse_proportions_2011)[colnames(circle_landuse_proportions_2011) == "42"] <- "evergreen_forest"
colnames(circle_landuse_proportions_2011)[colnames(circle_landuse_proportions_2011) == "43"] <- "mixed_forest"
colnames(circle_landuse_proportions_2011)[colnames(circle_landuse_proportions_2011) == "51"] <- "dwarf_scrub"
colnames(circle_landuse_proportions_2011)[colnames(circle_landuse_proportions_2011) == "52"] <- "shrub_scrub"
colnames(circle_landuse_proportions_2011)[colnames(circle_landuse_proportions_2011) == "71"] <- "grassland"
colnames(circle_landuse_proportions_2011)[colnames(circle_landuse_proportions_2011) == "72"] <- "sedge"
colnames(circle_landuse_proportions_2011)[colnames(circle_landuse_proportions_2011) == "73"] <- "lichens"
colnames(circle_landuse_proportions_2011)[colnames(circle_landuse_proportions_2011) == "74"] <- "moss"
colnames(circle_landuse_proportions_2011)[colnames(circle_landuse_proportions_2011) == "81"] <- "pasture"
colnames(circle_landuse_proportions_2011)[colnames(circle_landuse_proportions_2011) == "82"] <- "cultivated_crops"
colnames(circle_landuse_proportions_2011)[colnames(circle_landuse_proportions_2011) == "90"] <- "woody_wetlands"
colnames(circle_landuse_proportions_2011)[colnames(circle_landuse_proportions_2011) == "95"] <- "emergent_wetlands"

#Attach circle id numbers 
# Convert matrix/array to a dataframe (replace matrix_array with your actual object)
circle_landuse_proportions_2011_df <- as.data.frame(circle_landuse_proportions_2011)

# Add the 'circle_id' column
circle_landuse_proportions_2011_df <- circle_landuse_proportions_2011_df %>%
  mutate(circle_id = ifelse(row_number() <= 440, 48 + row_number(), 505 + row_number() - 440))

write.csv(circle_landuse_proportions_2011_df, "Circle_LandUse_Proportions_2011.csv", row.names=FALSE)

####################################################################
#Repeat for 2004
#Begin loop here 
values_to_loop <- c(49:488, 506:2234)

extraction.dir <- "buffer_rasters_2004"

combined_landcover_results_2004 <- list()

for (current_value in values_to_loop) {
  
  point <- subset(coordinates_data_twopoints, circle_id == current_value)
  
  circle_latlon1 <- point[, c(1, 9, 7)]
  colnames(circle_latlon1)[2] <- "latitude"
  colnames(circle_latlon1)[3] <- "longitude"
  
  circle_latlon2 <- point[, c(1, 10, 8)]
  colnames(circle_latlon2)[2] <- "latitude"
  colnames(circle_latlon2)[3] <- "longitude"
  
  circle_boundaries <- rbind(circle_latlon1, circle_latlon2)
  
  midpoint <- data.frame(latitude = mean(circle_boundaries$latitude), 
                         longitude = mean(circle_boundaries$longitude))
  
  coordinates(circle_boundaries) <- ~longitude + latitude
  proj4string(circle_boundaries) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")
  
  coordinates(midpoint) <- ~longitude + latitude
  proj4string(midpoint) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")
  
  nlcd_raster <- get_nlcd(template = circle_boundaries, 
                          label = current_value, 
                          year = 2004, 
                          extraction.dir = extraction.dir,
                          force.redo = TRUE)
  
  #Try this new section
  # Create a unique file name for each raster
  raster_filename <- paste("nlcd_", current_value, "_2004_raster.tif", sep = "")
  
  # Construct the full file path
  full_filepath <- file.path(extraction.dir, raster_filename)
  
  # Write the raster to the specified file
  writeRaster(nlcd_raster, filename = full_filepath, overwrite = TRUE)
  ##################
  
  midpoint <- spTransform(midpoint, projection(nlcd_raster))
  
  buffer_distance_meters <- 12050
  
  buff_shp <- buffer(midpoint, buffer_distance_meters)
  
  plot(nlcd_raster)
  plot(buff_shp, add = TRUE)
  
  landcover <- extract(nlcd_raster, midpoint, buffer = buffer_distance_meters)
  
  str(landcover)
  
  landcover_proportions <- lapply(landcover, function(x) {
    counts_x <- table(x)
    proportions_x <- prop.table(counts_x)
    sort(proportions_x)
  })
  
  combined_landcover_results_2004 <- c(combined_landcover_results_2004, landcover_proportions)
}

################################################################################
legend<-pal_nlcd()
legend

#Convert list of lists to data frame 

#First, make all vectors the same length by filling in 0s for missings
max.length <- max(sapply(combined_landcover_results_2004,length))
combined_landcover_results_2004 <- lapply(lapply(combined_landcover_results_2004, unlist), "length<-", max.length)

circle_landuse_proportions_2004 <- do.call(rbind, combined_landcover_results_2004)
colnames(circle_landuse_proportions_2004)[colnames(circle_landuse_proportions_2004) == "11"] <- "open_water"
colnames(circle_landuse_proportions_2004)[colnames(circle_landuse_proportions_2004) == "12"] <- "perennial_ice_snow"
colnames(circle_landuse_proportions_2004)[colnames(circle_landuse_proportions_2004) == "21"] <- "developed_openspace"
colnames(circle_landuse_proportions_2004)[colnames(circle_landuse_proportions_2004) == "22"] <- "developed_lowintensity"
colnames(circle_landuse_proportions_2004)[colnames(circle_landuse_proportions_2004) == "23"] <- "developed_medintensity"
colnames(circle_landuse_proportions_2004)[colnames(circle_landuse_proportions_2004) == "24"] <- "developed_highintensity"
colnames(circle_landuse_proportions_2004)[colnames(circle_landuse_proportions_2004) == "31"] <- "barren_land"
colnames(circle_landuse_proportions_2004)[colnames(circle_landuse_proportions_2004) == "41"] <- "deciduous_forest"
colnames(circle_landuse_proportions_2004)[colnames(circle_landuse_proportions_2004) == "42"] <- "evergreen_forest"
colnames(circle_landuse_proportions_2004)[colnames(circle_landuse_proportions_2004) == "43"] <- "mixed_forest"
colnames(circle_landuse_proportions_2004)[colnames(circle_landuse_proportions_2004) == "51"] <- "dwarf_scrub"
colnames(circle_landuse_proportions_2004)[colnames(circle_landuse_proportions_2004) == "52"] <- "shrub_scrub"
colnames(circle_landuse_proportions_2004)[colnames(circle_landuse_proportions_2004) == "71"] <- "grassland"
colnames(circle_landuse_proportions_2004)[colnames(circle_landuse_proportions_2004) == "72"] <- "sedge"
colnames(circle_landuse_proportions_2004)[colnames(circle_landuse_proportions_2004) == "73"] <- "lichens"
colnames(circle_landuse_proportions_2004)[colnames(circle_landuse_proportions_2004) == "74"] <- "moss"
colnames(circle_landuse_proportions_2004)[colnames(circle_landuse_proportions_2004) == "81"] <- "pasture"
colnames(circle_landuse_proportions_2004)[colnames(circle_landuse_proportions_2004) == "82"] <- "cultivated_crops"
colnames(circle_landuse_proportions_2004)[colnames(circle_landuse_proportions_2004) == "90"] <- "woody_wetlands"
colnames(circle_landuse_proportions_2004)[colnames(circle_landuse_proportions_2004) == "95"] <- "emergent_wetlands"

#Attach circle id numbers 
# Convert matrix/array to a dataframe (replace matrix_array with your actual object)
circle_landuse_proportions_2004_df <- as.data.frame(circle_landuse_proportions_2004)

# Add the 'circle_id' column
circle_landuse_proportions_2004_df <- circle_landuse_proportions_2004_df %>%
  mutate(circle_id = ifelse(row_number() <= 440, 48 + row_number(), 505 + row_number() - 440))

write.csv(circle_landuse_proportions_2004_df, "Circle_LandUse_Proportions_2004.csv", row.names=FALSE)


####################################################################
#Repeat for 2016
#Begin loop here 
values_to_loop <- c(49:488, 506:2234)

extraction.dir <- "buffer_rasters_2016"

combined_landcover_results_2016 <- list()

for (current_value in values_to_loop) {
  
  point <- subset(coordinates_data_twopoints, circle_id == current_value)
  
  circle_latlon1 <- point[, c(1, 9, 7)]
  colnames(circle_latlon1)[2] <- "latitude"
  colnames(circle_latlon1)[3] <- "longitude"
  
  circle_latlon2 <- point[, c(1, 10, 8)]
  colnames(circle_latlon2)[2] <- "latitude"
  colnames(circle_latlon2)[3] <- "longitude"
  
  circle_boundaries <- rbind(circle_latlon1, circle_latlon2)
  
  midpoint <- data.frame(latitude = mean(circle_boundaries$latitude), 
                         longitude = mean(circle_boundaries$longitude))
  
  coordinates(circle_boundaries) <- ~longitude + latitude
  proj4string(circle_boundaries) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")
  
  coordinates(midpoint) <- ~longitude + latitude
  proj4string(midpoint) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")
  
  nlcd_raster <- get_nlcd(template = circle_boundaries, 
                          label = current_value, 
                          year = 2016, 
                          extraction.dir = extraction.dir,
                          force.redo = TRUE)
  
  #Try this new section
  # Create a unique file name for each raster
  raster_filename <- paste("nlcd_", current_value, "_2016_raster.tif", sep = "")
  
  # Construct the full file path
  full_filepath <- file.path(extraction.dir, raster_filename)
  
  # Write the raster to the specified file
  writeRaster(nlcd_raster, filename = full_filepath, overwrite = TRUE)
  ##################
  
  midpoint <- spTransform(midpoint, projection(nlcd_raster))
  
  buffer_distance_meters <- 12050
  
  buff_shp <- buffer(midpoint, buffer_distance_meters)
  
  plot(nlcd_raster)
  plot(buff_shp, add = TRUE)
  
  landcover <- extract(nlcd_raster, midpoint, buffer = buffer_distance_meters)
  
  str(landcover)
  
  landcover_proportions <- lapply(landcover, function(x) {
    counts_x <- table(x)
    proportions_x <- prop.table(counts_x)
    sort(proportions_x)
  })
  
  combined_landcover_results_2016 <- c(combined_landcover_results_2016, landcover_proportions)
}

################################################################################
legend<-pal_nlcd()
legend

#Convert list of lists to data frame 

#First, make all vectors the same length by filling in 0s for missings
max.length <- max(sapply(combined_landcover_results_2016,length))
combined_landcover_results_2016 <- lapply(lapply(combined_landcover_results_2016, unlist), "length<-", max.length)

circle_landuse_proportions_2016 <- do.call(rbind, combined_landcover_results_2016)
colnames(circle_landuse_proportions_2016)[colnames(circle_landuse_proportions_2016) == "11"] <- "open_water"
colnames(circle_landuse_proportions_2016)[colnames(circle_landuse_proportions_2016) == "12"] <- "perennial_ice_snow"
colnames(circle_landuse_proportions_2016)[colnames(circle_landuse_proportions_2016) == "21"] <- "developed_openspace"
colnames(circle_landuse_proportions_2016)[colnames(circle_landuse_proportions_2016) == "22"] <- "developed_lowintensity"
colnames(circle_landuse_proportions_2016)[colnames(circle_landuse_proportions_2016) == "23"] <- "developed_medintensity"
colnames(circle_landuse_proportions_2016)[colnames(circle_landuse_proportions_2016) == "24"] <- "developed_highintensity"
colnames(circle_landuse_proportions_2016)[colnames(circle_landuse_proportions_2016) == "31"] <- "barren_land"
colnames(circle_landuse_proportions_2016)[colnames(circle_landuse_proportions_2016) == "41"] <- "deciduous_forest"
colnames(circle_landuse_proportions_2016)[colnames(circle_landuse_proportions_2016) == "42"] <- "evergreen_forest"
colnames(circle_landuse_proportions_2016)[colnames(circle_landuse_proportions_2016) == "43"] <- "mixed_forest"
colnames(circle_landuse_proportions_2016)[colnames(circle_landuse_proportions_2016) == "51"] <- "dwarf_scrub"
colnames(circle_landuse_proportions_2016)[colnames(circle_landuse_proportions_2016) == "52"] <- "shrub_scrub"
colnames(circle_landuse_proportions_2016)[colnames(circle_landuse_proportions_2016) == "71"] <- "grassland"
colnames(circle_landuse_proportions_2016)[colnames(circle_landuse_proportions_2016) == "72"] <- "sedge"
colnames(circle_landuse_proportions_2016)[colnames(circle_landuse_proportions_2016) == "73"] <- "lichens"
colnames(circle_landuse_proportions_2016)[colnames(circle_landuse_proportions_2016) == "74"] <- "moss"
colnames(circle_landuse_proportions_2016)[colnames(circle_landuse_proportions_2016) == "81"] <- "pasture"
colnames(circle_landuse_proportions_2016)[colnames(circle_landuse_proportions_2016) == "82"] <- "cultivated_crops"
colnames(circle_landuse_proportions_2016)[colnames(circle_landuse_proportions_2016) == "90"] <- "woody_wetlands"
colnames(circle_landuse_proportions_2016)[colnames(circle_landuse_proportions_2016) == "95"] <- "emergent_wetlands"

#Attach circle id numbers 
# Convert matrix/array to a dataframe (replace matrix_array with your actual object)
circle_landuse_proportions_2016_df <- as.data.frame(circle_landuse_proportions_2016)

# Add the 'circle_id' column
circle_landuse_proportions_2016_df <- circle_landuse_proportions_2016_df %>%
  mutate(circle_id = ifelse(row_number() <= 440, 48 + row_number(), 505 + row_number() - 440))

write.csv(circle_landuse_proportions_2016_df, "Circle_LandUse_Proportions_2016.csv", row.names=FALSE)


####################################################################
#Repeat for 2019
#Begin loop here 
values_to_loop <- c(49:488, 506:2234)

extraction.dir <- "buffer_rasters_2019"

combined_landcover_results_2019 <- list()

for (current_value in values_to_loop) {
  
  point <- subset(coordinates_data_twopoints, circle_id == current_value)
  
  circle_latlon1 <- point[, c(1, 9, 7)]
  colnames(circle_latlon1)[2] <- "latitude"
  colnames(circle_latlon1)[3] <- "longitude"
  
  circle_latlon2 <- point[, c(1, 10, 8)]
  colnames(circle_latlon2)[2] <- "latitude"
  colnames(circle_latlon2)[3] <- "longitude"
  
  circle_boundaries <- rbind(circle_latlon1, circle_latlon2)
  
  midpoint <- data.frame(latitude = mean(circle_boundaries$latitude), 
                         longitude = mean(circle_boundaries$longitude))
  
  coordinates(circle_boundaries) <- ~longitude + latitude
  proj4string(circle_boundaries) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")
  
  coordinates(midpoint) <- ~longitude + latitude
  proj4string(midpoint) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")
  
  nlcd_raster <- get_nlcd(template = circle_boundaries, 
                          label = current_value, 
                          year = 2019, 
                          extraction.dir = extraction.dir,
                          force.redo = TRUE)
  
  #Try this new section
  # Create a unique file name for each raster
  raster_filename <- paste("nlcd_", current_value, "_2019_raster.tif", sep = "")
  
  # Construct the full file path
  full_filepath <- file.path(extraction.dir, raster_filename)
  
  # Write the raster to the specified file
  writeRaster(nlcd_raster, filename = full_filepath, overwrite = TRUE)
  ##################
  
  midpoint <- spTransform(midpoint, projection(nlcd_raster))
  
  buffer_distance_meters <- 12050
  
  buff_shp <- buffer(midpoint, buffer_distance_meters)
  
  plot(nlcd_raster)
  plot(buff_shp, add = TRUE)
  
  landcover <- extract(nlcd_raster, midpoint, buffer = buffer_distance_meters)
  
  str(landcover)
  
  landcover_proportions <- lapply(landcover, function(x) {
    counts_x <- table(x)
    proportions_x <- prop.table(counts_x)
    sort(proportions_x)
  })
  
  combined_landcover_results_2019 <- c(combined_landcover_results_2019, landcover_proportions)
}

################################################################################
legend<-pal_nlcd()
legend

#Convert list of lists to data frame 

#First, make all vectors the same length by filling in 0s for missings
max.length <- max(sapply(combined_landcover_results_2019,length))
combined_landcover_results_2019 <- lapply(lapply(combined_landcover_results_2019, unlist), "length<-", max.length)

circle_landuse_proportions_2019 <- do.call(rbind, combined_landcover_results_2019)
colnames(circle_landuse_proportions_2019)[colnames(circle_landuse_proportions_2019) == "11"] <- "open_water"
colnames(circle_landuse_proportions_2019)[colnames(circle_landuse_proportions_2019) == "12"] <- "perennial_ice_snow"
colnames(circle_landuse_proportions_2019)[colnames(circle_landuse_proportions_2019) == "21"] <- "developed_openspace"
colnames(circle_landuse_proportions_2019)[colnames(circle_landuse_proportions_2019) == "22"] <- "developed_lowintensity"
colnames(circle_landuse_proportions_2019)[colnames(circle_landuse_proportions_2019) == "23"] <- "developed_medintensity"
colnames(circle_landuse_proportions_2019)[colnames(circle_landuse_proportions_2019) == "24"] <- "developed_highintensity"
colnames(circle_landuse_proportions_2019)[colnames(circle_landuse_proportions_2019) == "31"] <- "barren_land"
colnames(circle_landuse_proportions_2019)[colnames(circle_landuse_proportions_2019) == "41"] <- "deciduous_forest"
colnames(circle_landuse_proportions_2019)[colnames(circle_landuse_proportions_2019) == "42"] <- "evergreen_forest"
colnames(circle_landuse_proportions_2019)[colnames(circle_landuse_proportions_2019) == "43"] <- "mixed_forest"
colnames(circle_landuse_proportions_2019)[colnames(circle_landuse_proportions_2019) == "51"] <- "dwarf_scrub"
colnames(circle_landuse_proportions_2019)[colnames(circle_landuse_proportions_2019) == "52"] <- "shrub_scrub"
colnames(circle_landuse_proportions_2019)[colnames(circle_landuse_proportions_2019) == "71"] <- "grassland"
colnames(circle_landuse_proportions_2019)[colnames(circle_landuse_proportions_2019) == "72"] <- "sedge"
colnames(circle_landuse_proportions_2019)[colnames(circle_landuse_proportions_2019) == "73"] <- "lichens"
colnames(circle_landuse_proportions_2019)[colnames(circle_landuse_proportions_2019) == "74"] <- "moss"
colnames(circle_landuse_proportions_2019)[colnames(circle_landuse_proportions_2019) == "81"] <- "pasture"
colnames(circle_landuse_proportions_2019)[colnames(circle_landuse_proportions_2019) == "82"] <- "cultivated_crops"
colnames(circle_landuse_proportions_2019)[colnames(circle_landuse_proportions_2019) == "90"] <- "woody_wetlands"
colnames(circle_landuse_proportions_2019)[colnames(circle_landuse_proportions_2019) == "95"] <- "emergent_wetlands"

#Attach circle id numbers 
# Convert matrix/array to a dataframe (replace matrix_array with your actual object)
circle_landuse_proportions_2019_df <- as.data.frame(circle_landuse_proportions_2019)

# Add the 'circle_id' column
circle_landuse_proportions_2019_df <- circle_landuse_proportions_2019_df %>%
  mutate(circle_id = ifelse(row_number() <= 440, 48 + row_number(), 505 + row_number() - 440))

write.csv(circle_landuse_proportions_2019_df, "Circle_LandUse_Proportions_2019.csv", row.names=FALSE)



####################################################################
#Repeat for 2001
#Begin loop here 
values_to_loop <- c(49:488, 506:2234)

extraction.dir <- "buffer_rasters_2001"

combined_landcover_results_2001 <- list()

for (current_value in values_to_loop) {
  
  point <- subset(coordinates_data_twopoints, circle_id == current_value)
  
  circle_latlon1 <- point[, c(1, 9, 7)]
  colnames(circle_latlon1)[2] <- "latitude"
  colnames(circle_latlon1)[3] <- "longitude"
  
  circle_latlon2 <- point[, c(1, 10, 8)]
  colnames(circle_latlon2)[2] <- "latitude"
  colnames(circle_latlon2)[3] <- "longitude"
  
  circle_boundaries <- rbind(circle_latlon1, circle_latlon2)
  
  midpoint <- data.frame(latitude = mean(circle_boundaries$latitude), 
                         longitude = mean(circle_boundaries$longitude))
  
  coordinates(circle_boundaries) <- ~longitude + latitude
  proj4string(circle_boundaries) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")
  
  coordinates(midpoint) <- ~longitude + latitude
  proj4string(midpoint) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")
  
  nlcd_raster <- get_nlcd(template = circle_boundaries, 
                          label = current_value, 
                          year = 2001, 
                          extraction.dir = extraction.dir,
                          force.redo = TRUE)
  
  #Try this new section
  # Create a unique file name for each raster
  raster_filename <- paste("nlcd_", current_value, "_2001_raster.tif", sep = "")
  
  # Construct the full file path
  full_filepath <- file.path(extraction.dir, raster_filename)
  
  # Write the raster to the specified file
  writeRaster(nlcd_raster, filename = full_filepath, overwrite = TRUE)
  ##################
  
  midpoint <- spTransform(midpoint, projection(nlcd_raster))
  
  buffer_distance_meters <- 12050
  
  buff_shp <- buffer(midpoint, buffer_distance_meters)
  
  plot(nlcd_raster)
  plot(buff_shp, add = TRUE)
  
  landcover <- extract(nlcd_raster, midpoint, buffer = buffer_distance_meters)
  
  str(landcover)
  
  landcover_proportions <- lapply(landcover, function(x) {
    counts_x <- table(x)
    proportions_x <- prop.table(counts_x)
    sort(proportions_x)
  })
  
  combined_landcover_results_2001 <- c(combined_landcover_results_2001, landcover_proportions)
}

################################################################################
legend<-pal_nlcd()
legend

#Convert list of lists to data frame 

#First, make all vectors the same length by filling in 0s for missings
max.length <- max(sapply(combined_landcover_results_2001,length))
combined_landcover_results_2001 <- lapply(lapply(combined_landcover_results_2001, unlist), "length<-", max.length)

circle_landuse_proportions_2001 <- do.call(rbind, combined_landcover_results_2001)
colnames(circle_landuse_proportions_2001)[colnames(circle_landuse_proportions_2001) == "11"] <- "open_water"
colnames(circle_landuse_proportions_2001)[colnames(circle_landuse_proportions_2001) == "12"] <- "perennial_ice_snow"
colnames(circle_landuse_proportions_2001)[colnames(circle_landuse_proportions_2001) == "21"] <- "developed_openspace"
colnames(circle_landuse_proportions_2001)[colnames(circle_landuse_proportions_2001) == "22"] <- "developed_lowintensity"
colnames(circle_landuse_proportions_2001)[colnames(circle_landuse_proportions_2001) == "23"] <- "developed_medintensity"
colnames(circle_landuse_proportions_2001)[colnames(circle_landuse_proportions_2001) == "24"] <- "developed_highintensity"
colnames(circle_landuse_proportions_2001)[colnames(circle_landuse_proportions_2001) == "31"] <- "barren_land"
colnames(circle_landuse_proportions_2001)[colnames(circle_landuse_proportions_2001) == "41"] <- "deciduous_forest"
colnames(circle_landuse_proportions_2001)[colnames(circle_landuse_proportions_2001) == "42"] <- "evergreen_forest"
colnames(circle_landuse_proportions_2001)[colnames(circle_landuse_proportions_2001) == "43"] <- "mixed_forest"
colnames(circle_landuse_proportions_2001)[colnames(circle_landuse_proportions_2001) == "51"] <- "dwarf_scrub"
colnames(circle_landuse_proportions_2001)[colnames(circle_landuse_proportions_2001) == "52"] <- "shrub_scrub"
colnames(circle_landuse_proportions_2001)[colnames(circle_landuse_proportions_2001) == "71"] <- "grassland"
colnames(circle_landuse_proportions_2001)[colnames(circle_landuse_proportions_2001) == "72"] <- "sedge"
colnames(circle_landuse_proportions_2001)[colnames(circle_landuse_proportions_2001) == "73"] <- "lichens"
colnames(circle_landuse_proportions_2001)[colnames(circle_landuse_proportions_2001) == "74"] <- "moss"
colnames(circle_landuse_proportions_2001)[colnames(circle_landuse_proportions_2001) == "81"] <- "pasture"
colnames(circle_landuse_proportions_2001)[colnames(circle_landuse_proportions_2001) == "82"] <- "cultivated_crops"
colnames(circle_landuse_proportions_2001)[colnames(circle_landuse_proportions_2001) == "90"] <- "woody_wetlands"
colnames(circle_landuse_proportions_2001)[colnames(circle_landuse_proportions_2001) == "95"] <- "emergent_wetlands"

#Attach circle id numbers 
# Convert matrix/array to a dataframe (replace matrix_array with your actual object)
circle_landuse_proportions_2001_df <- as.data.frame(circle_landuse_proportions_2001)

# Add the 'circle_id' column
circle_landuse_proportions_2001_df <- circle_landuse_proportions_2001_df %>%
  mutate(circle_id = ifelse(row_number() <= 440, 48 + row_number(), 505 + row_number() - 440))

write.csv(circle_landuse_proportions_2001_df, "Circle_LandUse_Proportions_2001.csv", row.names=FALSE)
