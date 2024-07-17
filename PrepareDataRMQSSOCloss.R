library(sf)
library(dplyr)

# Carbone fraction
setwd("~/ejp")

r <- rast("~/covariates/LU_Actual_stack_100_2.tif")

names(r) <-c("Urban","Industrial","Arablecrops","Mixedcroplivestock",
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
  writeRaster(r1 ,paste0("~/covariates/socloss/",nvxNoms[i],".tif"), overwrite = T)
  i=i+1
}




r <- rast("~/covariates/LU_2050_stack_100.tif")

names(r) <-c("Urban","Industrial","Arablecrops","Mixedcroplivestock",
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
  writeRaster(r1 ,paste0("~/covariates/soclossfutur/",nvxNoms[i],".tif"), overwrite = T)
  i=i+1
}


dem = rast("~/covariates/resampled_inrae_to_isric/srtm.tif")
r1 = rast("~/covariates/socloss/stable/France_clay_100m.tif")
France_sand_repro <-project(dem, r1)

writeRaster(France_sand_repro ,"~/covariates/socloss/stable/srtm.tif", overwrite = T)


file.copy("~/covariates/socloss/slope.tif",
          "~/covariates/soclossfutur//slope.tif")
file.copy("~/covariates/socloss/srtm.tif",
          "~/covariates/soclossfutur//srtm.tif")

file.copy("~/covariates/socloss/France_clay_100m.tif",
          "~/covariates/soclossfutur//France_clay_100m.tif")

file.copy("~/covariates/socloss/France_sand_100m.tif",
          "~/covariates/soclossfutur//France_sand_100m.tif")

file.copy("~/covariates/socloss/France_silt_100m.tif",
          "~/covariates/soclossfutur//France_silt_100m.tif")


# Prepare data da ----------


RMQS_volum_moy_pond <- readRDS("/media/communs_infosol/Projets/SERENA/stageLouis/data/RMQS_volum_moy_pond.rds")

RMQS<-RMQS_volum_moy_pond %>%
  ungroup() %>%
  as.data.frame()  


str(RMQS)


#substr pour enlever l'espace de trop sur le code_dept

RMQS$code_dept <- substr(RMQS$code_dept, 1, 2)


load("/media/communs_infosol/Projets/SERENA/stageLouis/data/Dataset_A.RData")

RMQS_da <- x %>%
  filter(Layer %in% c('1','2')) %>%
  rename(no_horizon = Layer,
         id_campagne = id_campaign) %>%
  mutate_at(c("id_site","no_horizon"),
            as.numeric 
  ) %>%
  select(id_site,no_horizon,id_campagne,BD_wm) %>%
  group_by(id_site,no_horizon,id_campagne) %>%
  summarise(da_pond = mean(BD_wm)) %>%
  ungroup()

saveRDS(RMQS_da, file= "RMQS_da_12.RDS")


# Prepare data stock C 50cm



RMQS_stock_carbone <- readRDS("/media/communs_infosol/Projets/SERENA/stageLouis/data/données_carbone_50cm/stock_change.rds")  %>%
  filter(site_officiel == TRUE,
         !is.na(x_reel)) %>%
  select(id_site, x_reel,y_reel,SOC_stock_0_30cm_RMQS1,SOC_stock_30_50cm_RMQS1   ) 
str(RMQS_stock_carbone)

saveRDS(RMQS_stock_carbone, file= "RMQS_stock_12.RDS")

# Preration des points ------------


nc <- readRDS("data/rmqs.RDS") %>%
  st_transform(crs = 2154)

analyses_rmqs = read.csv2(file = "data/analyses_rmqs_As.csv", header = TRUE) #données RMQS avec tous les facteurs sélectionnés

da <- readRDS(file = "data/RMQS_da_12.RDS") %>%
  group_by(id_site,no_horizon) %>%
  summarise(da_pond = mean(da_pond)  ) %>%
  filter(no_horizon == 1)

stockC  <- readRDS(file = "data/RMQS_stock_12.RDS") 

nc <- analyses_rmqs %>% 
  left_join(stockC %>% 
              select(-x_reel,-y_reel), by = 'id_site') %>% 
  left_join(da , by = 'id_site') 
  

# 3.  preparation according the ISRIC R code rule s###########################

# layers <- nc %>%
#   mutate(x = st_coordinates(nc)[,1],
#          y = st_coordinates(nc)[,2]
#          ) %>%
#   st_drop_geometry()


#rename column
layers <- nc %>% 
  rename(pid = id_site) %>%
  select(pid,x_reel,y_reel,
         carbone_16_5_1, da_pond ,
         SOC_stock_0_30cm_RMQS1,SOC_stock_30_50cm_RMQS1
         ) %>%
  rename( soc = carbone_16_5_1) %>%
  
  mutate(socless45yrsoc = 0.35 * soc ,
         socgreater45yrsoc = 0.75 * soc,
         SOC_stock_0_50cm_RMQS1 = SOC_stock_0_30cm_RMQS1 +  SOC_stock_30_50cm_RMQS1 ,
         SOC_stock_0_50cm_RMQS1_less45yrsoc = 0.35 * SOC_stock_0_30cm_RMQS1 + 0.18 * SOC_stock_30_50cm_RMQS1 ,
         SOC_stock_0_50cm_RMQS1_greater45yrsoc = 0.65 * SOC_stock_0_30cm_RMQS1 + 0.82 * SOC_stock_30_50cm_RMQS1
         )

#add new columns. Note that we have single depth,"pid" and "lyrid" are the same columns
layers$lyrid <- 1 # layers$pid
layers$top <- 0
layers$bottom <- 50

#
head(layers)

#create new table call "profiles" and remove redundant columns 
profiles <- layers
profiles <- profiles[,!names(profiles) %in% c("lyrid", "top", "bottom")]

#
head(profiles)


write.csv(layers, "points/rmqs_socfracSERENA_0_30cm_layers.csv",row.names = F)
write.csv(profiles, "points/rmqs_socfracSERENA_profiles.csv", row.names = F)





