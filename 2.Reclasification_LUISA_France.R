# ------------------------------------------------------------------
# Title: Reclassify LULC
# Author: Nicolas Saby and Joao A. Coblinski
# Institution: INRAE
# Date: 06/06/2024

#This script is part of SERENA project from the WP5 task 5.2

#Contact:
# For any questions or further information, please contact me at coblinskijoao@gmail.com

# A considerable amount of effort and expertise went into the development
# of this script (part of a set of them). 
# If you use this script, please credit the author.
# Or consider the author's collaboration in your work. 

# ------------------------------------------------------------------

library(tmap)
library(terra)

#1. uploading the files
luisa_base <-  rast("E:/SERENA/WP5_bundles/France/France_harmonized_covariates/LUISA_2012_2050_france/luisaFranceActual.tiff")
luisa_2050 <- rast("E:/SERENA/WP5_bundles/France/France_harmonized_covariates/LUISA_2012_2050_france/luisaFrance2050.tiff")


#2.harmonize the land use classes for present and future------------------------------------

#2.1 LUISA France 2050  future: 
     #this raster has 0-25 clases, I excluided the 0 class replace it by NA

luisa_2050 <- ifel(luisa_2050 ==0, NA, luisa_2050)## I replaced the cero class by Na IN luisa 2050


#2.2 LUISA France 250 future
    # The LUISA for the present has 46 LU classes that I reclassified into 25 to match the number of clases of the present and the future.   
    # However, LUISA 2050 has 7 LU classes that do not appear in LUISA 2012 so I had to excluide those from both present and future to match the number of classes.
    # create classification matrix to recclasify the LUISA present to match the classes of the LUISA 2050--
reclass_df <- c(1111,1,
                1121,1,
                1122,1,
                1123,1,
                1130,25,
                1210,2,
                1221,21,
                1222,21,
                1230,21,
                1241,21,
                1242,21,
                1245,21,
                1310,21,
                1320,21,
                1330,21,
                1410,25,
                1421,25,
                1422,25,
                2110,3,
                2120,3,
                2130,20,
                2210,8,
                2220,9,
                2230,10,
                2310,5,
                2410,4,
                2420,4,
                2430,4,
                2440,5,
                3110,6,
                3120,6,
                3130,6,
                3210,19,
                3220,17,
                3230,17,
                3240,7,
                3310,22,
                3320,22,
                3330,22,
                3340,7,
                3350,22,
                4000,23,
                5110,24,
                5120,24,
                5210,24,
                5220,24,
                5230,24)


reclass_m <- matrix(reclass_df, ncol=2, byrow=TRUE)

chm_classified_base_Luisa <- terra::classify(luisa_base, reclass_m)
summary(chm_classified_base_Luisa)
hist(chm_classified_base_Luisa)

writeRaster(chm_classified_base_Luisa, "E:/SERENA/WP5_bundles/France/France_harmonized_covariates/LUISA_2012_2050_france/Output/LULC_base_fr_100.tif",
            overwrite=TRUE)

writeRaster(luisa_2050, "E:/SERENA/WP5_bundles/France/France_harmonized_covariates/LUISA_2012_2050_france/Output/luisa_2050_fr_100.tif",
            overwrite=TRUE)


#3 Transform the clasified present and actual into Dummy variables and save each of them in folder

t = freq(luisa_2050)
v =freq(chm_classified_base_Luisa)

for(i in unique(v$value) ) {
  m = chm_classified_base_Luisa == i
  print(i)
  writeRaster(m,
              paste0("E:/SERENA/WP5_bundles/France/France_harmonized_covariates/LUISA_2012_2050_france/Output/luActual/LULC_base_100",i,".tif"),
              overwrite=TRUE)
}

for(i in unique(t$value)) {
  m = luisa_2050 == i
  print(i)
  
  writeRaster(m,
              paste0("E:/SERENA/WP5_bundles/France/France_harmonized_covariates/LUISA_2012_2050_france/Output/lu2050/LULC_2050_100",i,".tif"),
              overwrite=TRUE)
}



#4. Actual 2012 dummy variables change land use names and stack them: final raster with only 18 Land use
library(terra)

listlu <- list.files(path="E:/SERENA/WP5_bundles/France/France_harmonized_covariates/LUISA_2012_2050_france/Output/luActual/", pattern = ".tif$", full.names = TRUE)


# Extract numbers from file names
file_numbers <- as.numeric(gsub("[^0-9]", "", listlu))
# Order file names based on numbers
ordered_listlu <- listlu[order(file_numbers)]
# Check the ordered list
print(ordered_listlu)

lustack <- rast(ordered_listlu)

names(lustack) <- basename(ordered_listlu)

plot(lustack$LULC_base_1001.tif)

current_names <- names(lustack)
print(current_names)

# Define the new names for the raster layers
new_names <- c("Urban",
               "Industrial", 
               "ArableCrops",
               "MixedCropLivestock",
               "LivestockProduction",
               "Forest",
               "TransitionWoodlandShrub",
               "Vineyards",
               "FruitProduction",
               "OliveProduction",
               "SHVA",
               "NaturalGrassland",
               "RiceProduction",
               "Infrastructure",
               "OtherNature",
               "Wetlands",
               "WaterBodies",
               "UrbanGreenLeisure")  # Adjust based on the number of layers

# Assign the new names to the raster layers
names(lustack) <- new_names

writeRaster(lustack,
            "E:/SERENA/WP5_bundles/France/France_harmonized_covariates/LUISA_2012_2050_france/Output/luActual/LU_Actual_stack_100.tif",
            overwrite=TRUE)

#5. Future 2050  dummy variables change land use names and stack them: final raster with only 18 Land use

listlu_2050 <- list.files(path="E:/SERENA/WP5_bundles/France/France_harmonized_covariates/LUISA_2012_2050_france/Output/lu2050/", pattern = ".tif$", full.names = TRUE)

# Extract numbers from file names
file_numbers <- as.numeric(gsub("[^0-9]", "", listlu_2050))
# Order file names based on numbers
ordered_listlu_2050 <- listlu_2050[order(file_numbers)]
# Check the ordered list
print(ordered_listlu_2050)

lustack_2050 <- rast(ordered_listlu_2050)

names(lustack_2050) <- basename(ordered_listlu_2050)

current_names <- names(lustack_2050)
print(current_names)

# Define the new names for the raster layers
new_names <- c("Urban",
               "Industrial", 
               "ArableCrops",
               "MixedCropLivestock",
               "LivestockProduction",
               "Forest",
               "TransitionWoodlandShrub",
               "Vineyards",
               "FruitProduction",
               "OliveProduction",
               "SHVA",
               "NaturalGrassland",
               "RiceProduction",
               "Infrastructure",
               "OtherNature",
               "Wetlands",
               "WaterBodies",
               "UrbanGreenLeisure")  # Adjust based on the number of layers

# Assign the new names to the raster layers
names(lustack_2050) <- new_names

writeRaster(lustack_2050,
            "E:/SERENA/WP5_bundles/France/France_harmonized_covariates/LUISA_2012_2050_france/Output/lu2050/LU_2050_stack_100.tif",
            overwrite=TRUE)


# 6. CODE TO FIX THE MISTAKE WITH THE LAND USE NAMES
library(terra)

r <- rast("E:/SERENA/WP5_bundles/France/France_harmonized_covariates/LUISA_2012_2050_france/Output/luActual/LU_Actual_stack_100.tif")


names(r) <-c("uUrban","Industrial","Arablecrops","Mixedcroplivestock",
             
             "Livestockproduction","Forest","Transitionwoodlandshrub","Vineyards" ,
             
             "Fruitproduction","Oliveproduction","SHVA","Naturalgrassland",
             
             "Riceproduction","Infrastructure","Othernature","Wetlands",
             
             "Waterbodies","Urbangreenleisure"
             
)



nvxNoms = c("Urban","Industrial","Arablecrops","Mixedcroplivestock",
            
            "Livestockproduction","Forest","Transitionwoodlandshrub","Vineyards" ,
            
            "Fruitproduction","Oliveproduction","SHVA","Naturalgrassland",
            
            "Riceproduction","Infrastructure","Othernature","Wetlands",
            
            "Waterbodies","Urbangreenleisure"
            
)



library(foreach)

i=1

foreach(t = names(r)) %do% {
  
  r1 <- r[[t]]
  
  writeRaster(r1 ,paste0("E:/SERENA/WP5_bundles/France/France_harmonized_covariates/LUISA_2012_2050_france/Output/luActual/Dummy/",nvxNoms[i],".tif"), overwrite = T)
  
  i=i+1
  
}

