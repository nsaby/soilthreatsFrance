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

#Copy the this ouput to the soildsm to use it in the next soil threats computation
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

# change to dyn covariate-ssp1

mainDir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/socless45yrsocssp1"
if ( !  file.exists(mainDir))  dir.create(mainDir) 

# copy first the output from dsm into  socless45yrsocssp1
from.dir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/socless45yrsoc/model/"
outDir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/socless45yrsocssp1/"
system(paste0("cp -R ",from.dir," ", outDir))

#Clean the covdsm folder and insert the future and stable covariates
f <- list.files("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/", 
                include.dirs = F, 
                full.names = T, recursive = T)
file.remove(f)

#predict socless45yr in ssp1

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

config$outputDir = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/socless45yrsocssp1/"
config$voi = "socless45yrsoc"
#config$modelFittedFile= "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/socless45yrsocssp1/model/socless45yrsoc/model-fitted_rangerquantreg_0-30_notransform_dorfe_notune.RDS"

need2fit = FALSE
prediction = TRUE
source(file = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/ISRICStepsDSM.R")


# predict socless45yr in ssp5

mainDir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/socless45yrsocssp5"
if ( !  file.exists(mainDir))  dir.create(mainDir) 

# copy first the output from dsm into  socless45yrsocssp5
from.dir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/socless45yrsoc/model/"
outDir <- "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/socless45yrsocssp5/"
system(paste0("cp -R ",from.dir," ", outDir))

list_of_files <- list.files("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/dynfutur/ssp5/",
                            full.names = TRUE)
lapply(list_of_files, function(i) {
  file.copy(from = i, to = paste0("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/covdsm/", basename(i)) ,
            overwrite = TRUE
  )
})

config$outputDir = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/socless45yrsocssp5/"
config$voi = "socless45yrsoc"

need2fit = FALSE
prediction = TRUE
source(file = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/ISRICStepsDSM.R")

##  5 Actual stable carbon and future projection ----------
stable = rast("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/socgreater45yrsoc/maps/socgreater45yrsoc/rangerquantreg_0-30_notransform_dorfe_notune/socgreater45yrsoc_Q0.5_0-30cm.tif")/10

####5.1 sum actual stable carbon and future projection ssp1------------------

futurdyn_ssp1 = rast("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/socless45yrsocssp1/maps/socless45yrsoc/rangerquantreg_0-30_notransform_dorfe_notune/socless45yrsoc_Q0.5_0-30cm.tif")/10

soc2050_ssp1 = stable + futurdyn_ssp1

plot(soc2050_ssp1)

writeRaster(soc2050_ssp1,"E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/soildsm/soc2050_ssp1.tif",
            overwrite = T)

####5.2 sum actual stable carbon and future projection ssp5------------------

futurdyn_ssp5 = rast("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Output_SOC_France/socless45yrsocssp5/maps/socless45yrsoc/rangerquantreg_0-30_notransform_dorfe_notune/socless45yrsoc_Q0.5_0-30cm.tif")/10

soc2050_ssp5 = stable + futurdyn_ssp5

plot(soc2050_ssp5)

writeRaster(soc2050_ssp5,"E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Covariates/soildsm/soc2050_ssp5.tif",
            overwrite = T)

#calculate the difference between actual soc and soc under scenario ssp1

SOC_actual_less_ssp1 <- (stable - soc2050_ssp1)/stable

plot(SOC_actual_less_ssp1)


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
config$voi = "SOC_stock_0_30cm_RMQS1"

need2fit = TRUE
prediction = TRUE
source(file = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/ISRICStepsDSM.R")



