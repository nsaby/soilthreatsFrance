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




FodlerAllCovariates = "/home/nsaby/covariates/socloss/"
FodlerDSM = "/home/nsaby/covariates/socloss/covdsm/"


mainDir <- "Output_SOC_France"
if ( !  file.exists(mainDir))  dir.create(mainDir) 

# 0 Initialization -----------------

config_location <- "configSOCserena.yaml"

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
 
# create a folder to gather model outputs
mainDir <- "Output_SOC_France/socact"
if ( !  file.exists(mainDir))  dir.create(mainDir) 

config$covarsDir = FodlerDSM
config$outputDir = "Output_SOC_France/socact"
config$voi = "soc"

need2fit = TRUE
prediction = TRUE
source(file = "ISRICStepsDSM.R")

file.copy("Output_SOC_France/socact/maps/soc/rangerquantreg_0-30_notransform_dorfe_tune/soc_Q0.5_0-30cm.tif",
          paste0(FodlerAllCovariates,"soildsm/socactual.tif"),
          overwrite = T)



## 2 stable SOC actual  ----------

# create a folder in the output folder of the project
mainDir <- "Output_SOC_France/socgreater45yrsoc"
if ( !  file.exists(mainDir))  dir.create(mainDir) 

config$covarsDir = FodlerDSM
config$outputDir = mainDir
config$voi = "socgreater45yrsoc"

need2fit = TRUE
prediction = TRUE

source(file = "ISRICStepsDSM.R")


## 3 SOC actual dyn-------

# (no need to map in fact)

mainDir <- "Output_SOC_France/socless45yrsoc"
if ( !  file.exists(mainDir))  dir.create(mainDir) 


config$covarsDir = FodlerDSM
config$outputDir = mainDir
config$voi = "socless45yrsoc"

need2fit = TRUE
prediction = FALSE
source(file = "ISRICStepsDSM.R")

## 4  SOC futur dyn -----------
# covariate
# change to dyn covariate-ssp1
mainDir <- "Output_SOC_France/socless45yrsocssp1"
if ( !  file.exists(mainDir))  dir.create(mainDir) 



#Clean the covdsm folder and inser the future and stable covariates
CleanFolder(FodlerDSM)


CopyCovariates(FodlerAllCovariates,
               "stable/",
               FodlerDSM)

CopyCovariates(FodlerAllCovariates,
               "dynfutur/lu",
               FodlerDSM)
CopyCovariates(FodlerAllCovariates,
               "dynfutur/clim/ssp1",
               FodlerDSM)


# copy first the output from dsm into  socless45yrsocssp1
# from.dir <- "Output_SOC_France/socless45yrsoc//"
# outDir <- "Output_SOC_France/socless45yrsocssp1/"
# system(paste0("cp -R ",from.dir," ", outDir))
# 


config$outputDir = mainDir
config$voi = "socless45yrsoc"
config$modelFittedFile= "Output_SOC_France/socless45yrsoc/model/socless45yrsoc/model-fitted_rangerquantreg_0-30_notransform_dorfe_tune.RDS"

need2fit = FALSE
prediction = TRUE
source(file = "ISRICStepsDSM.R")

# covariate
# change to dyn covariate-ssp5

mainDir <- "Output_SOC_France/socless45yrsocssp5"
if ( !  file.exists(mainDir))  dir.create(mainDir) 

# copy first the output from dsm into  socless45yrsocssp5
# from.dir <- "Output_SOC_France/socless45yrsoc/model/"
# outDir <- "Output_SOC_France/socless45yrsocssp5/"
# system(paste0("cp -R ",from.dir," ", outDir))


CleanFolder(FodlerDSM)


CopyCovariates(FodlerAllCovariates,
               "stable/",
               FodlerDSM)

CopyCovariates(FodlerAllCovariates,
               "dynfutur/lu",
               FodlerDSM)
CopyCovariates(FodlerAllCovariates,
               "dynfutur/clim/ssp5",
               FodlerDSM)

config$outputDir = "Output_SOC_France/socless45yrsocssp5/"
config$voi = "socless45yrsoc"
config$modelFittedFile= "Output_SOC_France/socless45yrsoc/model/socless45yrsoc/model-fitted_rangerquantreg_0-30_notransform_dorfe_tune.RDS"

need2fit = FALSE
prediction = TRUE
source(file = "ISRICStepsDSM.R")


##  5 sum actual stable carbon and future projection ----------

stable = rast("Output_SOC_France/socgreater45yrsoc/maps/socgreater45yrsoc/rangerquantreg_0-30_notransform_dorfe_tune/socgreater45yrsoc_Q0.5_0-30cm.tif")

#### 5.1 sum actual stable carbon and future projection soc SSP1------------------

futurdyn_ssp1 = rast("Output_SOC_France/socless45yrsocssp1/maps/socless45yrsoc/rangerquantreg_0-30_notransform_dorfe_tune/socless45yrsoc_Q0.5_0-30cm.tif")

soc2050_ssp1 = stable / 10  + futurdyn_ssp1 / 10 
plot(soc2050_ssp1)

writeRaster(soc2050_ssp1,
            paste0(FodlerAllCovariates,"soildsm/soc2050_ssp1.tif"),
            overwrite = T)

#calculate the difference between actual soc and soc under scenario ssp1

soc_actual = rast("Output_SOC_France/socact/maps/soc/rangerquantreg_0-30_notransform_dorfe_tune/soc_Q0.5_0-30cm.tif")/10


SOC_actual_less_ssp1 <- (soc_actual - soc2050_ssp1)/soc_actual

plot(SOC_actual_less_ssp1)


####5.2 sum actual stable carbon and future projection ssp5------------------

futurdyn_ssp5 = rast("Output_SOC_France/socless45yrsocssp5/maps/socless45yrsoc/rangerquantreg_0-30_notransform_dorfe_tune/socless45yrsoc_Q0.5_0-30cm.tif")

soc2050_ssp5 = stable / 10  + futurdyn_ssp5 / 10 

plot(soc2050_ssp5)

writeRaster(soc2050_ssp5,
            paste0(FodlerAllCovariates,"soildsm/soc2050_ssp5.tif"),
            overwrite = T)

#calculate the difference between actual soc and soc under scenario ssp5

SOC_actual_less_ssp5 <- (soc_actual-soc2050_ssp5)/soc_actual

plot(SOC_actual_less_ssp5)



# Compaction ---------------

## 1 Map bulk density (da pond) actual ----

CleanFolder(FodlerDSM)

CopyCovariates(FodlerAllCovariates,
               "stable/",
               FodlerDSM)

# copy covariates  dyn
CopyCovariates(FodlerAllCovariates,
               "dynactual/",
               FodlerDSM)

# add soc covariate
file.copy(
  paste0(FodlerAllCovariates,"soildsm/socactual.tif"),
  paste0(FodlerDSM,"soc.tif")
  )

# create a folder to gather model outputs
mainDir <- "Output_SOC_France/da_pond"
if ( !  file.exists(mainDir))  dir.create(mainDir) 


config$covarsDir = FodlerDSM
config$outputDir = mainDir
config$voi = "da_pond"

need2fit = TRUE
prediction = TRUE
source(file = "ISRICStepsDSM.R")


## 2 map bulk density (da_pond) in the future ---------

####2.1 bulk density (da_pond) ssp1---------------

mainDir <- "Output_SOC_France/da_pond_ssp1"
if ( !  file.exists(mainDir))  dir.create(mainDir) 

CleanFolder(FodlerDSM)

CopyCovariates(FodlerAllCovariates,
               "stable/",
               FodlerDSM)

CopyCovariates(FodlerAllCovariates,
               "dynfutur/lu",
               FodlerDSM)
CopyCovariates(FodlerAllCovariates,
               "dynfutur/clim/ssp1",
               FodlerDSM)

# add soc covariate
file.copy(
  paste0(FodlerAllCovariates,"soildsm/soc2050_ssp1.tif"),
  paste0(FodlerDSM,"soc.tif")
)


config$covarsDir = FodlerDSM
config$outputDir = mainDir
config$modelFittedFile= "Output_SOC_France/da_pond/model/da_pond/model-fitted_rangerquantreg_0-30_notransform_dorfe_tune.RDS"
config$voi = "da_pond"

need2fit = FALSE
prediction = TRUE
source(file = "ISRICStepsDSM.R")

####2.2 bulk density (da_pond) ssp5---------------

mainDir <- "Output_SOC_France/da_pond_ssp5"
if ( !  file.exists(mainDir))  dir.create(mainDir) 

CleanFolder(FodlerDSM)

CopyCovariates(FodlerAllCovariates,
               "stable/",
               FodlerDSM)

CopyCovariates(FodlerAllCovariates,
               "dynfutur/lu",
               FodlerDSM)
CopyCovariates(FodlerAllCovariates,
               "dynfutur/clim/ssp5",
               FodlerDSM)

# add soc covariate
file.copy(
  paste0(FodlerAllCovariates,"soildsm/soc2050_ssp5.tif"),
  paste0(FodlerDSM,"soc.tif")
)


config$covarsDir = FodlerDSM
config$outputDir = mainDir
config$modelFittedFile= "Output_SOC_France/da_pond/model/da_pond/model-fitted_rangerquantreg_0-30_notransform_dorfe_tune.RDS"
config$voi = "da_pond"

need2fit = FALSE
prediction = TRUE
source(file = "ISRICStepsDSM.R")


####2.3 compaction 1: difference between future ssp1 and present------- 


#Actual bulk density 
actBD = rast("Output_SOC_France/da_pond/maps/da_pond/rangerquantreg_0-30_notransform_dorfe_tune/da_pond_Q0.5_0-30cm.tif")/10

bulk_density2050_ssp1 = rast("Output_SOC_France/da_pond_ssp1/maps/da_pond/rangerquantreg_0-30_notransform_dorfe_tune/da_pond_Q0.5_0-30cm.tif")/10

Compaction2005_2050ssp1 = (bulk_density2050_ssp1 - actBD )

plot(Compaction2005_2050ssp1)

writeRaster(threatCompa250_ssp1,"Theats_map/Compaction/Compaction_ssp1.tif",
            overwrite = T)

####2.4 compaction 2: difference between future ssp5 and present--------- 

bulk_density2050_ssp5 = rast("Output_SOC_France/da_pond_ssp5/maps/da_pond/rangerquantreg_0-30_notransform_dorfe_notune/da_pond_Q0.5_0-30cm.tif")/10

Compaction2005_2050ssp5 = (bulk_density2050_ssp5-actBD)

plot(Compaction2005_2050ssp5)

writeRaster(Compaction2005_2050ssp5,"Theats_map/Compaction/Compaction_ssp5.tif",
            overwrite = T)


# SOC loss ---------------

## 1 SOC stock actual --------------

# prepare list of covariates

CleanFolder(FodlerDSM)

CopyCovariates(FodlerAllCovariates,
               "stable/",
               FodlerDSM)

# copy covariates  dyn
CopyCovariates(FodlerAllCovariates,
               "dynactual/",
               FodlerDSM)

# add soc covariate
file.copy(
  paste0(FodlerAllCovariates,"soildsm/socactual.tif"),
  paste0(FodlerDSM,"soc.tif")
)


# add soil depth France
file.copy("Covariates/soildsm/Soil_depth_France.tif", 
          "Covariates/covdsm/Soil_depth.tif")

# create a folder to gather model outputs
mainDir <- "Output_SOC_France/SOC_stock_actual"
if ( !  file.exists(mainDir))  dir.create(mainDir) 

config$covarsDir = "Covariates/covdsm/"
config$outputDir = "Output_SOC_France/SOC_stock_actual"
config$voi = "SOC_stock_0_30cm_RMQS1"

need2fit = TRUE
prediction = TRUE
source(file = "ISRICStepsDSM.R")












