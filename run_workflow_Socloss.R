library(isric.dsm.base)
library(argparser)


# 0 Initialization -----------------

config_location <- "/home/nsaby/ejp/Rcodev2/configSOCserena.yaml"

p <- arg_parser("Run the entire workflow")
p <- add_argument(
     parser = p, arg = "--config_file",
     help = "configuration file location", default = config_location
)
config <- yaml::read_yaml(parse_args(p)$config_file, eval.expr = TRUE)

# prof <- read.csv(config$profilesStandardFile)


# The covariate should be stored in different folders
# dynactual : climate and LU for present
# dynfutur : climate and LU for the futur (ssp1 only fo the moment)
# stable : covariates that are the same for present and future, eg texture , elevation and slope
# soildsm : output predctions of dsm for soc actual and futur


# SOC --------------------

## 1 SOC actual --------------

# prepare list of covariates

# remove former files
f <- list.files("~/covariates/socloss/covdsm/", 
                include.dirs = F, 
                full.names = T, recursive = T)
file.remove(f)


list_of_files <- list.files("~/covariates/socloss/stable/",
                            full.names = TRUE)
lapply(list_of_files, function(i) {
  file.copy(from = i, to = paste0("~/covariates/socloss/covdsm/", basename(i)))
})

list_of_files <- list.files("~/covariates/socloss/dynactual/",
                            full.names = TRUE)
lapply(list_of_files, function(i) {
  file.copy(from = i, to = paste0("~/covariates/socloss/covdsm/", basename(i)))
})


# create a folder to gather model outputs
mainDir <- "~/ejp/outputsocloss/socact"
if ( !  file.exists(mainDir))  dir.create(mainDir) 

config$covarsDir = "/home/nsaby/covariates/socloss/covdsm/"
config$outputDir = "/home/nsaby/ejp/outputsocloss/socact"
config$voi = "soc"

need2fit = TRUE
prediction = TRUE
source(file = "/home/nsaby/ejp/Rcodev2/ISRICStepsDSM.R")

file.copy("outputsocloss/socact/maps/soc/rangerquantreg_0-20_notransform_dorfe_tune/soc_Q0.5_0-20cm.tif",
          "~/covariates/socloss/soildsm/socactual.tif",
          overwrite = T)


## 2 stable SOC actual  ----------

# create a folder in the output folder of the project
mainDir <- "~/ejp/outputsocloss/socgreater45yrsoc"
if ( !  file.exists(mainDir))  dir.create(mainDir) 

config$covarsDir = "/home/nsaby/covariates/socloss/covdsm/"
config$outputDir = "/home/nsaby/ejp/outputsocloss/socgreater45yrsoc"
config$voi = "socgreater45yrsoc"

need2fit = TRUE
prediction = TRUE

source(file = "/home/nsaby/ejp/Rcodev2/ISRICStepsDSM.R")


## 3 SOC actual dyn-------

# (no need to map in fact)

mainDir <- "~/ejp/outputsocloss/socless45yrsoc"
if ( !  file.exists(mainDir))  dir.create(mainDir) 


config$covarsDir = "/home/nsaby/covariates/socloss/covdsm/"
config$outputDir = "/home/nsaby/ejp/outputsocloss/socless45yrsoc"
config$voi = "socless45yrsoc"

need2fit = TRUE
prediction = FALSE
source(file = "/home/nsaby/ejp/Rcodev2/ISRICStepsDSM.R")

## 4  SOC futur dyn -----------

# covariate
# change to dyn covariate

list_of_files <- list.files("~/covariates/socloss/dynfutur//",
                            full.names = TRUE)
lapply(list_of_files, function(i) {
  file.copy(from = i, to = paste0("~/covariates/socloss/covdsm/", basename(i)) ,
            overwrite = TRUE
            )
})

need2fit = FALSE
prediction = TRUE
source(file = "/home/nsaby/ejp/Rcodev2/predictISRIC.R")

##  5 sum actual stable carbone and future projection of C ----------

stable = rast("outputsocloss/socgreater45yrsoc/maps/socgreater45yrsoc/rangerquantreg_0-20_notransform_dorfe_tune/socgreater45yrsoc_Q0.5_0-20cm.tif")
futurdyn = rast("outputsocloss/socless45yrsoc/maps/socless45yrsoc/rangerquantreg_0-20_notransform_dorfe_tune/socless45yrsoc_Q0.5_0-20cm.tif")

soc2050 = stable / 10  + futurdyn / 10 
plot(soc2050)

writeRaster(soc2050,"~/covariates/socloss/soildsm/socfutur.tif",
            overwrite = T)

soc = rast("~/covariates/socloss/soildsm/socactual.tif")
plot( (soc / 10) - soc2050)


# Map bulk density ---------------


## 1  da actual ----

# copy actual climate and lu

f <- list.files("~/covariates/socloss/covdsm/", 
                include.dirs = F, 
                full.names = T, recursive = T)
# remove the files
file.remove(f)

list_of_files <- list.files("~/covariates/socloss/stable/",
                            full.names = TRUE)
lapply(list_of_files, function(i) {
  file.copy(from = i, to = paste0("~/covariates/socloss/covdsm/", basename(i)))
})

list_of_files <- list.files("~/covariates/socloss/dynactual/",
                            full.names = TRUE)
lapply(list_of_files, function(i) {
  file.copy(from = i, to = paste0("~/covariates/socloss/covdsm/", basename(i)))
})

# add soc covariate
file.copy("~/covariates/socloss/soildsm/socactual.tif", "~/covariates/socloss/covdsm/soc.tif")



mainDir <- "~/ejp/outputsocloss/da_pond"
if ( !  file.exists(mainDir))  dir.create(mainDir) 

config$covarsDir = "/home/nsaby/covariates/socloss/covdsm/"
config$outputDir = "/home/nsaby/ejp/outputsocloss/da_pond"
config$voi = "da_pond"

need2fit = TRUE
prediction = TRUE
source(file = "/home/nsaby/ejp/Rcodev2/ISRICStepsDSM.R")

# copy first the output from dsm into  da_pon_act


mainDir <- "~/ejp/outputsocloss/da_pond_actual"
from.dir <- "~/ejp/outputsocloss/da_pond"
system(paste0("cp -R ",from.dir," ", mainDir))


## 2  map da in the future ---------

# add soc covariate future
file.copy("~/covariates/socloss/soildsm/socfutur.tif", 
          "~/covariates/socloss/covdsm/soc.tif",
          overwrite = T)

list_of_files <- list.files("~/covariates/socloss/dynfutur//",
                            full.names = TRUE)
lapply(list_of_files, function(i) {
  file.copy(from = i, to = paste0("~/covariates/socloss/covdsm/", basename(i)) ,
            overwrite = TRUE
  )
})

config$covarsDir = "/home/nsaby/covariates/socloss/covdsm/"
config$outputDir = "/home/nsaby/ejp/outputsocloss/da_pond"

need2fit = FALSE
prediction = TRUE
source(file = "/home/nsaby/ejp/Rcodev2/predictISRIC.R")

## compute the difference (threat) -----------

actBD = rast("outputsocloss/da_pond_actual/maps/da_pond/rangerquantreg_0-20_notransform_dorfe_tune/da_pond_Q0.5_0-20cm.tif")
futurBD = rast("outputsocloss/da_pond/maps/da_pond/rangerquantreg_0-20_notransform_dorfe_tune/da_pond_Q0.5_0-20cm.tif")

threatCompa = futurBD / 10  - actBD / 10 
plot(threatCompa)



