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
# dynactual : climate and LU for present
# dynfutur : climate and LU for the futur (ssp1 only fo the moment)
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

f <- list.files("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/", 
                include.dirs = F, 
                full.names = T, recursive = T)
# remove the files
file.remove(f)


# copy actual stable, climate and land use

list_of_files <- list.files("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/stable/",
                            full.names = TRUE)
lapply(list_of_files, function(i) {
  file.copy(from = i, to = paste0("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/", basename(i)))
})

list_of_files <- list.files("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/dynactual/",
                            full.names = TRUE)
lapply(list_of_files, function(i) {
  file.copy(from = i, to = paste0("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/", basename(i)))
})

# add soc covariate
file.copy("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/soildsm/socactual.tif", "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/soc.tif")

# create a folder to gather model outputs

mainDir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/da_pond"
if ( !  file.exists(mainDir))  dir.create(mainDir) 

config$covarsDir = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/"
config$outputDir = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/da_pond"
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
f <- list.files("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/", 
                include.dirs = F, 
                full.names = T, recursive = T)
file.remove(f)

# add soc covariate ssp1, stable, bio and climate ssp1 to covdsm folder

file.copy("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/soildsm/soc2050_SSP1.tif", 
          "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/soc.tif",
          overwrite = T)

list_of_files <- list.files("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/stable/",
                            full.names = TRUE)
lapply(list_of_files, function(i) {
  file.copy(from = i, to = paste0("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/", basename(i)))
})

list_of_files <- list.files("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/dynfutur/ssp1/",
                            full.names = TRUE)

lapply(list_of_files, function(i) {

  file.copy(from = i, to = paste0("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/", basename(i)) ,
            overwrite = TRUE
  )
})

config$covarsDir = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/"
config$outputDir = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/da_pond_ssp1/"
config$modelFittedFile= "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/da_pond_ssp1/model/da_pond/model-fitted_rangerquantreg_0-30_notransform_dorfe_notune.RDS"
config$voi = "da_pond"

need2fit = FALSE
prediction = TRUE
source(file = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/ISRICStepsDSM.R")


####2.2 bulk density (da_pond) ssp5---------------

mainDir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/da_pond_ssp5"
if ( !  file.exists(mainDir))  dir.create(mainDir) 

from.dir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/da_pond_actual/model/"
outDir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/da_pond_ssp5/"
system(paste0("cp -R ",from.dir," ", outDir))

# remove former files
f <- list.files("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/", 
                include.dirs = F, 
                full.names = T, recursive = T)
file.remove(f)

# add soc covariate ssp5, stable, bio and climate ssp1 to covdsm folder

file.copy("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/soildsm/soc2050_ssp5.tif", 
          "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/soc.tif",
          overwrite = T)

list_of_files <- list.files("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/stable/",
                            full.names = TRUE)
lapply(list_of_files, function(i) {
  file.copy(from = i, to = paste0("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/", basename(i)))
})

list_of_files <- list.files("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/dynfutur/ssp5/",
                            full.names = TRUE)
lapply(list_of_files, function(i) {
  file.copy(from = i, to = paste0("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/", basename(i)) ,
            overwrite = TRUE
  )
})

config$covarsDir = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/"
config$outputDir = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/da_pond_ssp5/"
config$modelFittedFile= "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/da_pond_ssp5/model/da_pond/model-fitted_rangerquantreg_0-30_notransform_dorfe_notune.RDS"
config$voi = "da_pond"

need2fit = FALSE
prediction = TRUE
source(file = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/ISRICStepsDSM.R")

#Actual bulk density 
actBD = rast("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/da_pond_actual/maps/da_pond/rangerquantreg_0-30_notransform_dorfe_notune/da_pond_Q0.5_0-30cm.tif")/10

####2.3 compaction 1: difference between future ssp1 and present------- 

bulk_density2050_ssp1 = rast("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/da_pond_ssp1/maps/da_pond/rangerquantreg_0-30_notransform_dorfe_notune/da_pond_Q0.5_0-30cm.tif")/10

Compaction2005_2050ssp1 = (bulk_density2050_ssp1 - actBD )

plot(Compaction2005_2050ssp1)

writeRaster(Compaction2005_2050ssp1,"E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Theats_map/Compaction/Compaction_ssp1.tif",
            overwrite = T)

####2.4 compaction 2: difference between future ssp5 and present--------- 

bulk_density2050_ssp5 = rast("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/da_pond_ssp5/maps/da_pond/rangerquantreg_0-30_notransform_dorfe_notune/da_pond_Q0.5_0-30cm.tif")/10

Compaction2005_2050ssp5 = (bulk_density2050_ssp5-actBD)

plot(Compaction2005_2050ssp5)

writeRaster(Compaction2005_2050ssp5,"E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Theats_map/Compaction/Compaction_ssp5.tif",
            overwrite = T)


# SOC loss ---------------

## 1 SOC stock actual --------------

# prepare list of covariates

# remove former files
f <- list.files("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/", 
                include.dirs = F, 
                full.names = T, recursive = T)
file.remove(f)


list_of_files <- list.files("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/stable/",
                            full.names = TRUE)
lapply(list_of_files, function(i) {
  file.copy(from = i, to = paste0("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/", basename(i)))
})

list_of_files <- list.files("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/dynactual/",
                            full.names = TRUE)
lapply(list_of_files, function(i) {
  file.copy(from = i, to = paste0("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/", basename(i)))
})

# add soil depth France
file.copy("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/soildsm/Soil_depth_France.tif", "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/Soil_depth.tif")

# create a folder to gather model outputs
mainDir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/SOC_stock_actual"
if ( !  file.exists(mainDir))  dir.create(mainDir) 

config$covarsDir = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/"
config$outputDir = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/SOC_stock_actual"
config$voi = "SOC_stock_0_30cm"

need2fit = TRUE
prediction = TRUE
source(file = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/ISRICStepsDSM.R")


## 2 Stable SOC stock actual --------------

# create a folder in the output folder of the project
mainDir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/SOC_stock_greater45yr"
if ( !  file.exists(mainDir))  dir.create(mainDir) 

config$covarsDir = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/"
config$outputDir = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/SOC_stock_greater45yr"
config$voi = "SOC_stock_0_30cm_greater45yr"

need2fit = TRUE
prediction = TRUE

source(file = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/ISRICStepsDSM.R")


## 3 SOC stock dynamic actual -------

# (no need to map in fact)

mainDir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/SOC_stock_less45yr"
if ( !  file.exists(mainDir))  dir.create(mainDir) 

config$covarsDir = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/"
config$outputDir = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/SOC_stock_less45yr"
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
f <- list.files("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/", 
                include.dirs = F, 
                full.names = T, recursive = T)
file.remove(f)

#add climate, bio and LU future, soil depth in covdsm folder
list_of_files <- list.files("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/stable/",
                            full.names = TRUE)

lapply(list_of_files, function(i) {
  file.copy(from = i, to = paste0("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/", basename(i)),
            overwrite = TRUE)})

list_of_files <- list.files("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/dynfutur/ssp1/",
                            full.names = TRUE)
lapply(list_of_files, function(i) {
  file.copy(from = i, to = paste0("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/", basename(i)) ,
            overwrite = TRUE)
  
})

# add soil depth France
file.copy("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/soildsm/Soil_depth_France.tif", "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/Soil_depth.tif")


config$outputDir = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/SOC_stock_less45yrssp1/"
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

list_of_files <- list.files("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/dynfutur/ssp5/",
                            full.names = TRUE)
lapply(list_of_files, function(i) {
  file.copy(from = i, to = paste0("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/", basename(i)) ,
            overwrite = TRUE
  )
})

config$outputDir = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/SOC_stock_less45yrssp5/"
config$voi = "SOC_stock_0_30cm_less45yr"

need2fit = FALSE
prediction = TRUE
source(file = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/ISRICStepsDSM.R")

##5 actual stable SOC stock and future projection ----------------

SOC_stock_stable <- rast("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/SOC_stock_greater45yr/maps/SOC_stock_0_30cm_greater45yr/rangerquantreg_0-30_notransform_dorfe_notune/SOC_stock_0_30cm_greater45yr_Q0.5_0-30cm.tif")/10

####5.1 sum actual stable SOC stock and dynamic future projection ssp1------------------

SOC_stock_dyn_ssp1 = rast("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/SOC_stock_less45yrssp1/maps/SOC_stock_0_30cm_less45yr/rangerquantreg_0-30_notransform_dorfe_notune/SOC_stock_0_30cm_less45yr_Q0.5_0-30cm.tif")/10

soc_stock1 = SOC_stock_stable + SOC_stock_dyn_ssp1

plot(soc_stock1)

writeRaster(soc_stock1,"E:/SERENA/WP5_bundles/France/ISRIC_threats_France/SOC_Loss/soc_stock1.tif",
            overwrite = T)

####5.2 sum actual stable carbon and dynamic future projection ssp5------------------

SOC_stock_dyn_ssp5 = rast("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/SOC_stock_less45yrssp5/maps/SOC_stock_0_30cm_less45yr/rangerquantreg_0-30_notransform_dorfe_notune/SOC_stock_0_30cm_less45yr_Q0.5_0-30cm.tif")/10

soc_stock2 = SOC_stock_stable + SOC_stock_dyn_ssp5

plot(soc_stock2)

writeRaster(soc_stock2,"E:/SERENA/WP5_bundles/France/ISRIC_threats_France/SOC_Loss/soc_stock2.tif",
            overwrite = T)

##6 SOC stock loss----------------

SOC_stock_actual <- rast("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/SOC_stock_actual/maps/SOC_stock_0_30cm/rangerquantreg_0-30_notransform_dorfe_notune/SOC_stock_0_30cm_Q0.5_0-30cm.tif")/10

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









