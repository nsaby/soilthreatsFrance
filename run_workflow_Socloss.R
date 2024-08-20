library(isric.dsm.base)
library(argparser)
library(terra)

## Functions to clean folder ------
CleanFolder <- function(FodlerDSM){
  f <- list.files(FodlerDSM , 
                  include.dirs = F, 
                  full.names = T, 
                  recursive = T)
  file.remove(f)
  
}

## Functions to copy covariates ------
CopyCovariates <- function( rep ,
                            covariates,
                            out ){
  
  
  list_of_files <- list.files( paste0(rep,covariates) ,
                               full.names = TRUE)
  
  lapply(list_of_files, function(i) {
    file.copy(from = i,
              to = paste0(out, basename(i)))
  })
  
  
}


FodlerAllCovariates = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/"
FodlerDSM = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/"


mainDir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France"
if ( !  file.exists(mainDir))  dir.create(mainDir) 

# 0 Initialization -----------------

config_location <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/config.yaml"

p <- arg_parser("Run the entire workflow")
p <- add_argument(
  parser = p, arg = "--config_file",
  help = "configuration file location", default = config_location
)
config <- yaml::read_yaml(parse_args(p)$config_file, eval.expr = TRUE)

prof <- read.csv(config$profilesStandardFile)

# The covariate should be stored in different folders
# dynactual : climate bio
# LU_actual: land use luisa actual
# dynfutur : climate and LU for the futur (ssp1 and SSP5)
# stable : covariates that are the same for present and future, eg texture , elevation and slope
# soildsm : output predctions of dsm for soc actual and futur


# SOC --------------------

## 1 SOC actual --------------

# prepare list of covariates

CleanFolder(FodlerDSM)

# copy covariates stable and dyn
CopyCovariates(FodlerAllCovariates,
               "stable/",
               FodlerDSM)

# copy covariates  dyn
CopyCovariates(FodlerAllCovariates,
               "dynactual/",
               FodlerDSM)

CopyCovariates(FodlerAllCovariates,
               "LU_actual",
               FodlerDSM)

# create a folder to gather model outputs
mainDir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/socact"
if ( !  file.exists(mainDir))  dir.create(mainDir) 

config$covarsDir = FodlerDSM
config$outputDir = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/socact"
config$voi = "soc"

need2fit = TRUE
prediction = TRUE
source(file = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/ISRICStepsDSM.R")

file.copy("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/socact/maps/soc/rangerquantreg_0-30_notransform_dorfe_notune/soc_Q0.5_0-30cm.tif",
          paste0(FodlerAllCovariates,"soildsm/socactual.tif"),
          overwrite = T)

## 2 Stable SOC actual  ----------

# create a folder in the output folder of the project
mainDir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/socgreater45yrsoc"
if ( !  file.exists(mainDir))  dir.create(mainDir) 

config$covarsDir = FodlerDSM
config$outputDir = mainDir
config$voi = "socgreater45yrsoc"

need2fit = TRUE
prediction = TRUE

source(file = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/ISRICStepsDSM.R")

## 3 SOC dynamic actual -------

# (no need to map in fact)

mainDir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/socless45yrsoc"
if ( !  file.exists(mainDir))  dir.create(mainDir) 

config$covarsDir = FodlerDSM
config$outputDir = mainDir
config$voi = "socless45yrsoc"

need2fit = TRUE
prediction = FALSE
source(file = "ISRICStepsDSM.R")

## 4  SOC  dynamic prediction -----------

####4.1 Predict SOC dynamic ssp1---------------

mainDir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/socless45yrsocssp1"
if ( !  file.exists(mainDir))  dir.create(mainDir) 

#Clean the covdsm folder and inser the future and stable covariates
CleanFolder(FodlerDSM)


CopyCovariates(FodlerAllCovariates,
               "stable/",
               FodlerDSM)

CopyCovariates(FodlerAllCovariates,
               "dynfutur/LU_2050",
               FodlerDSM)

CopyCovariates(FodlerAllCovariates,
               "dynfutur/ssp1",
               FodlerDSM)


# copy first the output from dsm into  socless45yrsocssp1
from.dir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/socless45yrsoc/model/"
outDir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/socless45yrsocssp1/"
system(paste0("cp -R ",from.dir," ", outDir))


config$outputDir = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/socless45yrsocssp1/"
config$voi = "socless45yrsoc"
config$modelFittedFile= "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/socless45yrsocssp1/model/socless45yrsoc/model-fitted_rangerquantreg_0-30_notransform_dorfe_tune.RDS"

need2fit = FALSE
prediction = TRUE
source(file = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/ISRICStepsDSM.R")

####4.2 Predict SOC dynamic ssp5----------------

mainDir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/socless45yrsocssp5"
if ( !  file.exists(mainDir))  dir.create(mainDir) 

#copy first the output from dsm into  socless45yrsocssp5
from.dir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/socless45yrsoc/model/"
outDir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/socless45yrsocssp5/"
system(paste0("cp -R ",from.dir," ", outDir))


CleanFolder(FodlerDSM)


CopyCovariates(FodlerAllCovariates,
               "stable/",
               FodlerDSM)

CopyCovariates(FodlerAllCovariates,
               "dynfutur/LU_2050",
               FodlerDSM)

CopyCovariates(FodlerAllCovariates,
               "dynfutur/ssp5",
               FodlerDSM)

config$outputDir = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/socless45yrsocssp5/"
config$voi = "socless45yrsoc"
config$modelFittedFile= "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/socless45yrsocssp5/model/socless45yrsoc/model-fitted_rangerquantreg_0-30_notransform_dorfe_tune.RDS"

need2fit = FALSE
prediction = TRUE
source(file = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/ISRICStepsDSM.R")

library(terra)

##  5 Actual stable carbon and future projection ----------
stable = rast("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/socgreater45yrsoc/maps/socgreater45yrsoc/rangerquantreg_0-30_notransform_dorfe_tune/socgreater45yrsoc_Q0.5_0-30cm.tif")/10


####5.1 sum actual stable carbon and dynamic future projection ssp1------------------

futurdyn_ssp1 = rast("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/socless45yrsocssp1/maps/socless45yrsoc/rangerquantreg_0-30_notransform_dorfe_tune/socless45yrsoc_Q0.5_0-30cm.tif")/10

soc2050_ssp1 = stable + futurdyn_ssp1

plot(soc2050_ssp1)

writeRaster(soc2050_ssp1,"E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/soildsm/soc2050_ssp1.tif",
            overwrite = T)

#calculate the difference between actual soc and soc under scenario ssp1

SOC_actual_less_ssp1 <- (stable - soc2050_ssp1)/stable

plot(SOC_actual_less_ssp1)

####5.2 sum actual stable carbon and dynamic future projection ssp5------------------

futurdyn_ssp5 = rast("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/socless45yrsocssp5/maps/socless45yrsoc/rangerquantreg_0-30_notransform_dorfe_tune/socless45yrsoc_Q0.5_0-30cm.tif")/10

soc2050_ssp5 = stable + futurdyn_ssp5

plot(soc2050_ssp5)

writeRaster(soc2050_ssp5,"E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/soildsm/soc2050_ssp5.tif",
            overwrite = T)


#calculate the difference between actual soc and soc under scenario ssp5

SOC_actual_less_ssp5 <- (stable-soc2050_ssp5)/stable

plot(SOC_actual_less_ssp5)



# Compaction ---------------


## 1 Map bulk density (da pond) actual ----

# prepare list of covariates
# copy actual stable, climate, land use and soc actual
CleanFolder(FodlerDSM)


# copy covariates stable and dyn
CopyCovariates(FodlerAllCovariates,
               "stable/",
               FodlerDSM)

# copy covariates  dyn
CopyCovariates(FodlerAllCovariates,
               "dynactual/",
               FodlerDSM)

# copy covariates  dyn
CopyCovariates(FodlerAllCovariates,
               "LU_actual/",
               FodlerDSM)

# add soc covariate
file.copy("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/soildsm/socactual.tif", "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/soc.tif")

# create a folder to gather model outputs

mainDir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/da_pond"
if ( !  file.exists(mainDir))  dir.create(mainDir) 

config$covarsDir = FodlerDSM
config$outputDir = mainDir
config$voi = "da_pond"

need2fit = TRUE
prediction = TRUE
source(file = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/ISRICStepsDSM.R")

# copy first the output from dsm into  da_pon_act
from.dir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/da_pond"
mainDir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/da_pond_actual"
system(paste0("cp -R ",from.dir," ", mainDir))

## 2 map bulk density (da_pond) in the future ---------


####2.1 bulk density (da_pond) ssp1---------------

mainDir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/da_pond_ssp1"
if ( !  file.exists(mainDir))  dir.create(mainDir) 

## copy first the model from da_pond_actual into  da_pond_ssp1
from.dir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/da_pond_actual/model/"
outDir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/da_pond_ssp1/"
system(paste0("cp -R ",from.dir," ", outDir))

# clean the covariates folder to make sure yuo incluide covariates in the future ssp1
CleanFolder(FodlerDSM)

# add soc covariate ssp1, stable, bio and climate ssp1 to covdsm folder

file.copy("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/soildsm/soc2050_SSP1.tif", 
          "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/soc.tif",
          overwrite = T)

CopyCovariates(FodlerAllCovariates,
               "stable/",
               FodlerDSM)

CopyCovariates(FodlerAllCovariates,
               "dynfutur/ssp1",
               FodlerDSM)

CopyCovariates(FodlerAllCovariates,
               "dynfutur/LU_2050",
               FodlerDSM)


config$covarsDir = FodlerDSM
config$outputDir = mainDir
config$modelFittedFile= "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/da_pond_ssp1/model/da_pond/model-fitted_rangerquantreg_0-30_notransform_dorfe_tune.RDS"
config$voi = "da_pond"

need2fit = FALSE
prediction = TRUE
source(file = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/ISRICStepsDSM.R")


####2.2 bulk density (da_pond) ssp5---------------

mainDir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/da_pond_ssp5"
if ( !  file.exists(mainDir))  dir.create(mainDir) 

## copy first the model from da_pond_actual into  da_pond_ssp5
from.dir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/da_pond_actual/model/"
outDir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/da_pond_ssp5/"
system(paste0("cp -R ",from.dir," ", outDir))


# clean the covariates folder to make sure yuo incluide covariates in the future ssp5
CleanFolder(FodlerDSM)

# add soc covariate ssp5, stable, bio and climate ssp1 to covdsm folder
file.copy("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/soildsm/soc2050_ssp5.tif", 
          "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/soc.tif",
          overwrite = T)

CopyCovariates(FodlerAllCovariates,
               "stable/",
               FodlerDSM)

CopyCovariates(FodlerAllCovariates,
               "dynfutur/ssp5",
               FodlerDSM)

CopyCovariates(FodlerAllCovariates,
               "dynfutur/LU_2050",
               FodlerDSM)


config$covarsDir = FodlerDSM
config$outputDir = mainDir
config$modelFittedFile= "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/da_pond_ssp5/model/da_pond/model-fitted_rangerquantreg_0-30_notransform_dorfe_tune.RDS"
config$voi = "da_pond"

need2fit = FALSE
prediction = TRUE
source(file = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/ISRICStepsDSM.R")

#Actual bulk density 
actBD = rast("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/da_pond_actual/maps/da_pond/rangerquantreg_0-30_notransform_dorfe_tune/da_pond_Q0.5_0-30cm.tif")/10

####2.3 compaction 1: difference between future ssp1 and present------- 

bulk_density2050_ssp1 = rast("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/da_pond_ssp1/maps/da_pond/rangerquantreg_0-30_notransform_dorfe_tune/da_pond_Q0.5_0-30cm.tif")/10

Compaction2005_2050ssp1 = (bulk_density2050_ssp1 - actBD )

plot(Compaction2005_2050ssp1)

writeRaster(Compaction2005_2050ssp1,"E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Theats_map/Compaction/Compaction_ssp1.tif",
            overwrite = T)

####2.4 compaction 2: difference between future ssp5 and present--------- 

bulk_density2050_ssp5 = rast("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/da_pond_ssp5/maps/da_pond/rangerquantreg_0-30_notransform_dorfe_tune/da_pond_Q0.5_0-30cm.tif")/10

Compaction2005_2050ssp5 = (bulk_density2050_ssp5-actBD)

plot(Compaction2005_2050ssp5)

writeRaster(Compaction2005_2050ssp5,"E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Theats_map/Compaction/Compaction_ssp5.tif",
            overwrite = T)


# SOC loss ---------------

## 1 SOC stock actual --------------

# prepare list of covariates

# remove former files
CleanFolder(FodlerDSM)

# copy covariates stable and dyn
CopyCovariates(FodlerAllCovariates,
               "stable/",
               FodlerDSM)

# copy covariates  dyn
CopyCovariates(FodlerAllCovariates,
               "dynactual/",
               FodlerDSM)

CopyCovariates(FodlerAllCovariates,
               "LU_actual/",
               FodlerDSM)


# add soil depth France
file.copy("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/soildsm/Soil_depth_France.tif", "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/Soil_depth.tif")

# create a folder to gather model outputs
mainDir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/SOC_stock_actual"
if ( !  file.exists(mainDir))  dir.create(mainDir) 

config$covarsDir = FodlerDSM
config$outputDir = mainDir
config$voi = "SOC_stock_0_30cm"

need2fit = TRUE
prediction = TRUE
source(file = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/ISRICStepsDSM.R")


## 2 Stable SOC stock actual --------------

# create a folder in the output folder of the project
mainDir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/SOC_stock_greater45yr"
if ( !  file.exists(mainDir))  dir.create(mainDir) 

config$covarsDir = FodlerDSM
config$outputDir = mainDir
config$voi = "SOC_stock_0_30cm_greater45yr"

need2fit = TRUE
prediction = TRUE

source(file = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/ISRICStepsDSM.R")


## 3 SOC stock dynamic actual -------

# (no need to map in fact)

mainDir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/SOC_stock_less45yr"
if ( !  file.exists(mainDir))  dir.create(mainDir) 

config$covarsDir = FodlerDSM
config$outputDir = mainDir
config$voi = "SOC_stock_0_30cm_less45yr"

need2fit = TRUE
prediction = FALSE
source(file = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/ISRICStepsDSM.R")

## 4  SOC  dynamic future -----------

####4.1 Predict SOC stock dynamic ssp1  -----------

mainDir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/SOC_stock_less45yrssp1"
if ( !  file.exists(mainDir))  dir.create(mainDir) 

# copy first the output from SOC stock dynamic actual into  socless45yrssp1
from.dir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/SOC_stock_less45yr/model/"
outDir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/SOC_stock_less45yrssp1/"
system(paste0("cp -R ",from.dir," ", outDir))

#Clean the covdsm folder and insert the future and stable covariates
CleanFolder(FodlerDSM)

#add climate, bio and LU future, soil depth in covdsm folder
CopyCovariates(FodlerAllCovariates,
               "stable/",
               FodlerDSM)

CopyCovariates(FodlerAllCovariates,
               "dynfutur/LU_2050/",
               FodlerDSM)

CopyCovariates(FodlerAllCovariates,
               "dynfutur/ssp1/",
               FodlerDSM)

# add soil depth France
file.copy("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/soildsm/Soil_depth_France.tif", "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/Soil_depth.tif")


config$outputDir = mainDir
config$voi = "SOC_stock_0_30cm_less45yr"

need2fit = FALSE
prediction = TRUE
source(file = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/ISRICStepsDSM.R")


####4.2 Predict SOC stock dynamic ssp5-----------

mainDir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/SOC_stock_less45yrssp5"
if ( !  file.exists(mainDir))  dir.create(mainDir) 

# copy first the output from SOC stock dynamic actual into  socless45yrssp1
from.dir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/SOC_stock_less45yr/model/"
outDir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/SOC_stock_less45yrssp5/"
system(paste0("cp -R ",from.dir," ", outDir))

CleanFolder(FodlerDSM)

CopyCovariates(FodlerAllCovariates,
               "stable/",
               FodlerDSM)

CopyCovariates(FodlerAllCovariates,
               "dynfutur/LU_2050",
               FodlerDSM)

CopyCovariates(FodlerAllCovariates,
               "dynfutur/ssp5/",
               FodlerDSM)

# add soil depth France
file.copy("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/soildsm/Soil_depth_France.tif", "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/Soil_depth.tif")

config$outputDir = mainDir
config$voi = "SOC_stock_0_30cm_less45yr"

need2fit = FALSE
prediction = TRUE
source(file = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/ISRICStepsDSM.R")

##5 actual stable SOC stock and future projection ----------------

SOC_stock_stable <- rast("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/SOC_stock_greater45yr/maps/SOC_stock_0_30cm_greater45yr/rangerquantreg_0-30_notransform_dorfe_tune/SOC_stock_0_30cm_greater45yr_Q0.5_0-30cm.tif")/10

####5.1 sum actual stable SOC stock and dynamic future projection ssp1------------------

SOC_stock_dyn_ssp1 = rast("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/SOC_stock_less45yrssp1/maps/SOC_stock_0_30cm_less45yr/rangerquantreg_0-30_notransform_dorfe_tune/SOC_stock_0_30cm_less45yr_Q0.5_0-30cm.tif")/10

soc_stock1 = SOC_stock_stable + SOC_stock_dyn_ssp1

plot(soc_stock1)

writeRaster(soc_stock1,"E:/SERENA/WP5_bundles/France/ISRIC_threats_France/SOC_Loss/soc_stock1.tif",
            overwrite = T)

####5.2 sum actual stable carbon and dynamic future projection ssp5------------------

SOC_stock_dyn_ssp5 = rast("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/SOC_stock_less45yrssp5/maps/SOC_stock_0_30cm_less45yr/rangerquantreg_0-30_notransform_dorfe_tune/SOC_stock_0_30cm_less45yr_Q0.5_0-30cm.tif")/10

soc_stock2 = SOC_stock_stable + SOC_stock_dyn_ssp5

plot(soc_stock2)

writeRaster(soc_stock2,"E:/SERENA/WP5_bundles/France/ISRIC_threats_France/SOC_Loss/soc_stock2.tif",
            overwrite = T)

##6 SOC stock loss----------------

SOC_stock_actual <- rast("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/SOC_stock_actual/maps/SOC_stock_0_30cm/rangerquantreg_0-30_notransform_dorfe_tune/SOC_stock_0_30cm_Q0.5_0-30cm.tif")/10

####6.1 difference between SOC stock ssp1 and SOC stock actual----------------

SOC_stock_loss_1 <- (soc_stock1 - SOC_stock_actual)

plot(SOC_stock_loss_1)

writeRaster(SOC_stock_loss_1,"E:/SERENA/WP5_bundles/France/ISRIC_threats_France/SOC_Loss/SOC_stock_loss_1.tif",
            overwrite = T)

####6.2 difference between SOC stock ssp5 and SOC stock actual----------------
SOC_stock_loss_2 <- (soc_stock2-SOC_stock_actual)

plot(SOC_stock_loss_2)

writeRaster(SOC_stock_loss_2,"E:/SERENA/WP5_bundles/France/ISRIC_threats_France/SOC_Loss/SOC_stock_loss_2.tif",
            overwrite = T)



plot(SOC_stock_actual/10)


# Sealing ---------------
library(terra)

FodlerAllCovariates = "~/covariates/"
##1 Land use LUISA present and future 2050-----------
LU_present<-  rast("~/covariates/luisaFranceActual.tiff")
LU_2050 <- rast("~/covariates/luisaFrance2050.tiff")

NUTS3_France <- vect("~/covariates/socloss/shp/DEPARTEMENT.SHP")
NUTS3_France <- project(NUTS3_France,"epsg:3035")  

##2 reclassify LU maps actual and future --------

# replace the LU classes by the artificialized one of 2050 map

reclassifi__LU_2050 <- matrix(c(0,999,
                         1,1,
                         2,2,
                         3,999,
                         4,999,
                         5,999,
                         6,999,
                         7,999,
                         8,999,
                         9,999,
                         10,999,
                         11,999,
                         12,999,
                         13,999,
                         14,999,
                         15,999,
                         16,999,
                         17,999,
                         18,999,
                         19,999,
                         20,999,
                         21,21,
                         22,999,
                         23,999,
                         24,999,
                         25,25),
                       ncol = 2,
                       byrow = TRUE)


classified_LU2050 <- terra::classify(LU_2050,  reclassifi__LU_2050)

# create classification matrix
reclassifi_LU_present <- matrix(c(2110,999,
                       2120,999,
                       2130,999,
                       2210,999,
                       2220,999,
                       2230,999,
                       2310,999,
                       2410,999,
                       2420,999,
                       2430,999,
                       2440,999,
                       3110,999,
                       3120,999,
                       3130,999,
                       3210,999,
                       3220,999,
                       3230,999,
                       3240,999,
                       3330,999,
                       3340,999,
                       1111,1,
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
                       1310,2,
                       1320,2,
                       1330,1,
                       1410,25,
                       1421,25,
                       1422,1,
                       3310,999,
                       3320,999,
                       3330,999,
                       3340,999,
                       3350,999,
                       4000,999,
                       5110,999,
                       5120,999,
                       5210,999,
                       5220,999,
                       5230,999),
                     ncol = 2,
                     byrow = TRUE)

classified_LU_Present <- terra::classify(LU_present, reclassifi_LU_present)
#luisa_base_clasi <- terra::classify(LU_present, reclassifi_LU_present)

##3 convert NUTS3 vector to raster------------

NUTS3_France$myid <- as.numeric(as.factor(NUTS3_France$CODE_DEPT))


NUTS_RAS <- rasterize(NUTS3_France,
                   LU_present,
                   field="myid")

##4 Combine NUTS3 and land use ----------

# it cannot work before because 100 is too small. /!\

classified_LU_Present_NUTS3 <- (1000 * NUTS_RAS) + classified_LU_Present 

classified_LU2050_NUTS3 <- (1000 * NUTS_RAS) + classified_LU2050


##Question

#Here I am not sure because SEALING was calculated using the "impreviousness raster for statististics" so is not clear for me
#witch raster is that one and if we really need it here. I downdloaded the impreviousness raster  file from https://land.copernicus.eu/en/products/high-resolution-layer-imperviousness/imperviousness-density-2012#download

##5 imperiousness raster----------------

Imperv_2012_Europe <- rast("~/covariates/IMD_2018_010m_03035_V2_0.tif")
Imperv_2012_France <- crop(Imperv_2012_Europe, classified_LU2050_NUTS3, mask=TRUE)

# "254 non classifiable (no satellite image available, or clouds, shadows, or snow "
hist(Imperv_2012_France)
# not needed for France? not sure
Imperv_Fr_2 <- terra::ifel(Imperv_2012_France == 254, 
                           0 ,
                           Imperv_2012_France)

# align the raster to the imperviousness one
classified_LU_Present_NUTS3_1 <- terra::resample(classified_LU_Present_NUTS3, 
                               Imperv_Fr_2,
                           method= "near" )



#  compute the average value of imperviousness per canton 
resNuts3 <- terra::zonal(Imperv_Fr_2,
                         classified_LU_Present_NUTS3_1, 
                         na.rm=TRUE   )


# Extract the code of the canton from the myid column
mask <- 1000 * ( (resNuts3$myid / 1000) - (resNuts3$myid %/% 1000) )
# Correct the imperviousness by 0 for the code 999 which means non sealed area
resNuts3$IMD_2018_010m_03035_V2_0 [ mask> 990] = 0
  

impev_present_France <- terra::classify(classified_LU_Present_NUTS3,
                                 resNuts3[])

impev_2050_France <- terra::classify(classified_LU2050_NUTS3,
                                as.matrix(resNuts3)
                                )
  
plot(impev_present_France )



# soil threat ---------

SoilSealing <- impev_2050_France - impev_present_France

plot(SoilSealing)


writeRaster(SoilSealing,file="Output_SOC_France/SoilSealing.tiff")



# Plan B: I would do it like that by keeping the raw data for present and not 
# approximating the sealing by using the class... but this need to be discussed??

classified_LU_2050_NUTS3_1 <- terra::resample(classified_LU2050_NUTS3, 
                                                 Imperv_Fr_2,
                                                 method= "near" )
impev_2050_France_1 <- terra::classify(classified_LU_2050_NUTS3_1,
                                     as.matrix(resNuts3)
)

SoilSealing_2 <- impev_2050_France_1 - Imperv_Fr_2

plot(SoilSealing_2 )

writeRaster(SoilSealing_2,file="Output_SOC_France/SoilSealing_2.tiff")






