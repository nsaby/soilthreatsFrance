library(isric.dsm.base)
library(argparser)


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


# create a folder to gather model outputs
mainDir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/socact"
if ( !  file.exists(mainDir))  dir.create(mainDir) 

config$covarsDir = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/"
config$outputDir = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/socact"
config$voi = "soc"

need2fit = TRUE
prediction = TRUE
source(file = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/ISRICStepsDSM.R")

file.copy("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/socact/maps/soc/rangerquantreg_0-30_notransform_dorfe_notune/soc_Q0.5_0-30cm.tif",
          "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/soildsm/socactual.tif",
          overwrite = T)



## 2 stable SOC actual  ----------

# create a folder in the output folder of the project
mainDir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/socgreater45yrsoc"
if ( !  file.exists(mainDir))  dir.create(mainDir) 

config$covarsDir = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/"
config$outputDir = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/socgreater45yrsoc"
config$voi = "socgreater45yrsoc"

need2fit = TRUE
prediction = TRUE

source(file = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/ISRICStepsDSM.R")


## 3 SOC actual dyn-------

# (no need to map in fact)

mainDir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/socless45yrsoc"
if ( !  file.exists(mainDir))  dir.create(mainDir) 


config$covarsDir = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/"
config$outputDir = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/socless45yrsoc"
config$voi = "socless45yrsoc"

need2fit = TRUE
prediction = FALSE
source(file = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/ISRICStepsDSM.R")

## 4  SOC futur dyn -----------
# covariate
# change to dyn covariate-ssp1

mainDir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/socless45yrsoc/ssp1"
if ( !  file.exists(mainDir))  dir.create(mainDir) 


list_of_files <- list.files("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/dynfutur/ssp1/",
                            full.names = TRUE)
lapply(list_of_files, function(i) {
  file.copy(from = i, to = paste0("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/", basename(i)) ,
            overwrite = TRUE
  )
})

need2fit = FALSE
prediction = TRUE
source(file = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/ISRICStepsDSM.R")

# covariate
# change to dyn covariate-ssp5

mainDir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/socless45yrsoc/ssp5"
if ( !  file.exists(mainDir))  dir.create(mainDir) 

list_of_files <- list.files("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/dynfutur/ssp5/",
                            full.names = TRUE)
lapply(list_of_files, function(i) {
  file.copy(from = i, to = paste0("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/", basename(i)) ,
            overwrite = TRUE
  )
})

need2fit = FALSE
prediction = TRUE
source(file = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/ISRICStepsDSM.R")


##  5 sum actual stable carbone and future projection ----------
stable = rast("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/socgreater45yrsoc/maps/socgreater45yrsoc/rangerquantreg_0-30_notransform_dorfe_notune/socgreater45yrsoc_Q0.5_0-30cm.tif")

##sum actual stable carbone and future projection SSP1------------------

futurdyn_ssp1 = rast("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/socless45yrsoc/ssp1/maps/socless45yrsoc/rangerquantreg_0-30_notransform_dorfe_notune/socless45yrsoc_Q0.5_0-30cm.tif")

soc2050_ssp1 = stable / 10  + futurdyn_ssp1 / 10 
plot(soc2050_ssp1)

writeRaster(soc2050_ssp1,"E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/soildsm/soc2050_ssp1.tif",
            overwrite = T)

##sum actual stable carbone and future projection SSP5------------------

futurdyn_ssp5 = rast("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/socless45yrsoc/ssp5/maps/socless45yrsoc/rangerquantreg_0-30_notransform_dorfe_notune/socless45yrsoc_Q0.5_0-30cm.tif")

soc2050_ssp5 = stable / 10  + futurdyn_ssp5 / 10 
plot(soc2050_ssp5)

writeRaster(soc2050_ssp5,"E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/soildsm/soc2050_ssp5.tif",
            overwrite = T)



soc = rast("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/socact/maps/soc/rangerquantreg_0-30_notransform_dorfe_notune/soc_Q0.5_0-30cm.tif")
plot( (soc / 10) - soc2050)



##  5 sum actual stable carbone and future projection of C SSP5----------
library(terra)

stable = rast("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/socgreater45yrsoc/maps/socgreater45yrsoc/rangerquantreg_0-30_notransform_dorfe_notune/socgreater45yrsoc_Q0.5_0-30cm.tif")
futurdyn_SSP5 = rast("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/socless45yrsoc/ssp5/maps/socless45yrsoc/rangerquantreg_0-30_notransform_dorfe_notune/socless45yrsoc_Q0.5_0-30cm.tif")

soc2050_SSP5 = stable / 10  + futurdyn_SSP5/ 10 
plot(soc2050_SSP5)

writeRaster(soc2050_SSP5,"E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/soildsm/soc2050_SSP5.tif",
            overwrite = T)

soc = rast("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/socact/maps/soc/rangerquantreg_0-30_notransform_dorfe_notune/soc_Q0.5_0-30cm.tif")
plot( (soc / 10) - soc2050)


# Map bulk density ---------------


## 1  da actual ----

# copy actual climate and lu

f <- list.files("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/", 
                include.dirs = F, 
                full.names = T, recursive = T)
# remove the files
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

# add soc covariate
file.copy("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/soildsm/socactual.tif", "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/soc.tif")


mainDir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/da_pond"
if ( !  file.exists(mainDir))  dir.create(mainDir) 

config$covarsDir = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/"
config$outputDir = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/da_pond"
config$voi = "da_pond"

need2fit = TRUE
prediction = TRUE
source(file = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/ISRICStepsDSM.R")

# copy first the output from dsm into  da_pon_act

mainDir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/da_pond_actual"
from.dir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/da_pond"
system(paste0("cp -R ",from.dir," ", mainDir))


## 2  map da_pond in the future ---------

# add soc covariate ssp1

file.copy("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/soildsm/soc2050_SSP1.tif", 
          "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/soc.tif",
          overwrite = T)

list_of_files <- list.files("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/dynfutur/ssp1/",
                            full.names = TRUE)
lapply(list_of_files, function(i) {
  file.copy(from = i, to = paste0("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/", basename(i)) ,
            overwrite = TRUE
  )
})


config$covarsDir = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/"
config$outputDir = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/da_pond/ssp1"

need2fit = FALSE
prediction = TRUE
source(file = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/ISRICStepsDSM.R")

# add soc covariate ssp5

file.copy("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/soildsm/soc2050_ssp5.tif", 
          "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/soc.tif",
          overwrite = T)

list_of_files <- list.files("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/dynfutur/ssp5/",
                            full.names = TRUE)
lapply(list_of_files, function(i) {
  file.copy(from = i, to = paste0("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/", basename(i)) ,
            overwrite = TRUE
  )
})


config$modelFittedFile= "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/da_pond/ssp5/model/da_pond/model-fitted_rangerquantreg_0-30_notransform_dorfe_notune.RDS"
config$covarsDir = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/"
config$outputDir = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/da_pond/ssp5"

need2fit = FALSE
prediction = TRUE
source(file = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/ISRICStepsDSM.R")


## compaction change present and ssp1
library(terra)

actBD = rast("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/da_pond_actual/maps/da_pond/rangerquantreg_0-30_notransform_dorfe_notune/da_pond_Q0.5_0-30cm.tif")
bulk_density2050_ssp1 = rast("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/da_pond/ssp1/maps/da_pond/rangerquantreg_0-30_notransform_dorfe_notune/da_pond_Q0.5_0-30cm.tif")

threatCompa250_ssp1 = bulk_density2050_ssp1 / 10  - actBD / 10 
plot(bulk_density2050_ssp1 / 10)

writeRaster(threatCompa250_ssp1,"E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Theats_map/Compaction/Compaction_ssp1.tif",
            overwrite = T)

## compaction change present and ssp5

actBD = rast("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/da_pond_actual/maps/da_pond/rangerquantreg_0-30_notransform_dorfe_notune/da_pond_Q0.5_0-30cm.tif")
bulk_density2050_ssp5 = rast("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/da_pond/ssp5/maps/soc/rangerquantreg_0-30_notransform_dorfe_notune/soc_Q0.5_0-30cm.tif")


threatCompa250_ssp5 = bulk_density2050_ssp5 / 10  - actBD / 10 




writeRaster(threatCompa250_ssp5,"E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Theats_map/Compaction/Compaction_ssp5.tif",
            overwrite = T)





