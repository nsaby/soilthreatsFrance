
#install.packages("remotes")
#remotes::install_github("rspatial/terra")
#############################reprojection of slope to 100 m using Luisa
library(terra)

##############mask that I will use to crop
France_slope <- rast("E:/SERENA/WP5_bundles/France/data/slope.tif")

France_slope_repro <- project(France_slope, "EPSG:3035" )

France_slope_100m <- terra::resample(France_slope, Luisa_base)#I changed the spatial resolution of france to 100m

#####Terrein covariates
slope_france<- rast("E:/SERENA/WP5_bundles/France/France_harmonized_covariates/Terrain_france/slope.tif")
strm <- rast("E:/SERENA/WP5_bundles/France/France_harmonized_covariates/Terrain_france/srtm.tif")
SRTM_france <-project(strm, slope_france)


#####Soil data
France_sand <- rast("E:/SERENA/WP5_bundles/France/data/sable.15_30.tif")
France_silt <- rast("E:/SERENA/WP5_bundles/France/data/limon.15_30.tif")
France_clay <- rast("E:/SERENA/WP5_bundles/France/data/argile.15_30.tif")

####reproject soil data covariaties to EPSG:3035
France_sand_repro <-project(France_sand, slope_france)
France_silt_repro <-project(France_silt, slope_france)
France_clay_repro <-project(France_clay, slope_france)

###save in folder

writeRaster(SRTM_france ,"E:/SERENA/WP5_bundles/France/France_harmonized_covariates/Terrain_france/SRTM_france.tif")

##############Climatic covariates
reference_raster_path <- "E:/SERENA/WP5_bundles/France/France_harmonized_covariates/LUISA_2012_2050/slope.tif"


####################################

library(terra)
#input directories
#bioclimate_present <- " E:/SERENA/WP5_bundles/WP5_Top_dow/Covariates_wp5/bioclimate_present"
#bioclimate_SSP1 <- " E:/SERENA/WP5_bundles/WP5_Top_dow/Covariates_wp5/bioclimate_SSP1"
#bioclimate_SSP5 <- " E:/SERENA/WP5_bundles/WP5_Top_dow/Covariates_wp5/bioclimate_SSP5"
#climateact <- " E:/SERENA/WP5_bundles/WP5_Top_dow/Covariates_wp5/climateact"
#climateSSP126 <- " E:/SERENA/WP5_bundles/WP5_Top_dow/Covariates_wp5/climateSSP126"

#climateSSP585 <- " E:/SERENA/WP5_bundles/WP5_Top_dow/Covariates_wp5/climateSSP585"

#ouput directory
#bioclimate_present <- "E:/SERENA/WP5_bundles/France/France_harmonized_covariates/Bio_present_france"
#Bio_SSP1_france <- " E:/SERENA/WP5_bundles/France/France_harmonized_covariates/Bio_SSP1_france"
#Bio_SSP5_france <- "E:/SERENA/WP5_bundles/France/France_harmonized_covariates/Bio_SSP5_france "
#climateact_Fr <- " E:/SERENA/WP5_bundles/France/France_harmonized_covariates/climateact_Fr"
#climateSSP126_Fr <- "E:/SERENA/WP5_bundles/France/France_harmonized_covariates/climateSSP126_Fr"

#climateSSP585_Fr <-"E:/SERENA/WP5_bundles/France/France_harmonized_covariates/climateSSP585_Fr"

# Set the directory containing the rasters
input_directory <- "E:/SERENA/WP5_bundles/WP5_Top_dow/Covariates_wp5/climateSSP126"
output_directory <- "E:/SERENA/WP5_bundles/France/France_harmonized_covariates/climateSSP126_Fr"
reference_raster_path <- "E:/SERENA/WP5_bundles/France/France_harmonized_covariates/Terrain_france/slope.tif"

reference_raster <- rast(reference_raster_path)

# Function to reproject and crop
process_raster <- function(raster_path, reference_raster) {
  # Load the raster
  raster <- rast(raster_path)
  
  # Reproject the raster to match the reference raster's CRS
  reprojected_raster <- project(raster, reference_raster)
  
  # Crop the reprojected raster using the reference raster
  cropped_raster <- terra::crop(reprojected_raster, reference_raster)
  
  # Resample the cropped raster to match the resolution of the reference raster
  #resampled_raster <- resample(cropped_raster, reference_raster)
  
  return(cropped_raster)
}

# Get a list of all raster files in the directory
raster_files <- list.files(input_directory, pattern = "\\.tif$", full.names = TRUE)

# Loop through each raster file, process it, and save the output
for (raster_path in raster_files) {
  # Process the raster
  processed_raster <- process_raster(raster_path, reference_raster)
  
  # Define the output path
  output_path <- file.path(output_directory, basename(raster_path))
  
  # Save the processed raster
  writeRaster(processed_raster, output_path, overwrite = TRUE)
  
  cat("Processed and saved:", output_path, "\n")
}

cat("All rasters have been processed, reprojected, cropped, resampled, and saved.\n")

