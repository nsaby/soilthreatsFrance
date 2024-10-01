#Soil sealing
#library(terra)
library(tmap)
library(terra)




compaction_126<- rast("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Theats_map/threats_SSP1/Compaction_ssp1.tif")
SOCloss_126 <- rast("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Theats_map/threats_SSP1/SOC_stock_loss_SSP1.tif")
erosion_126 <- rast("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Theats_map/threats_SSP1/erosion_126.tif")
sealing <- rast("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Theats_map/threats_SSP1/SoilSealing.tiff")
shp <-vect("E:/SERENA/WP5_bundles/France/France_harmonized_covariates/SHP/NUTS3_France.shp")


#Soil sealing ----------

sealing_2050 <- sealing 

sealing_2050_500 <- aggregate(sealing_2050,
                              fact = 5)


#sealing_2050[sealing_2050 > 2] <- NA

m3rr <- matrix(c(-100, -80, 1,
                 -80, 30, 0,
                 30, 100, -1),
               ncol=3, byrow=TRUE)


SoilSealing_classified <- classify(x=sealing_2050_500, rcl=m3rr, include.lowest=TRUE)
plot(SoilSealing_classified)


#colors<- c("#57A347", "#A7D397", "white", "orange","red" )

colors2<- c("red","#A7D397","darkorange" )

tiff(file="E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Theats_map/Bundles/SSP1/sealing_rec.tif",width = 2600, height = 1500, res = 300, pointsize = 6)


pdf(file = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Theats_map/Bundles/SSP1/sealing_rec.tif", width = 20, height = 15, pointsize = 10)#run this together to export and save image in good resolution

tm_shape(SoilSealing_classified, raster.downsample = FALSE) +
  tm_raster(
    palette = colors2,
    style = "pretty",
    # breaks = c(-3,-2,-1,0,1,2),
    #labels = c("-2", "-1", "0", "1"), 
    title = "Soil sealing changes", 
  ) +
  tm_compass(position = c("left", "top"), size = 10) +
  tm_legend(legend.outside = TRUE, legend.text.size = 2.5, legend.title.size = 3.0) +
  tm_legend(outside = TRUE, hist.width = 2, hist.height = 0.4) +
  tm_shape(shp) +
  tm_borders(col = "grey30", lwd = 0.5, lty = "solid", alpha = 0.8) +
  tm_scale_bar(
    position = c("left", "bottom"),  # Adjust the position as needed
    size = 1.8,  # Adjust the distance from the scale bar to the map
    color.dark = "black",  # Set the color of the scale bar
    color.light = "white",  # Set the color of the scale bar text
    text.size = 2.8,
    breaks = seq(0, 600, by = 200)  # Adjust the breaks as needed# Set the size of the scale bar text
  )+
  tm_layout(title = "", title.size = 2.8, inner.margins = c(0.02, 0.02, 0.02, 0.02))
dev.off()



writeRaster(SoilSealing_classified, "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Theats_map/Bundles/SSP1/sealing_reclass.tif",overwrite=TRUE)

# Compaction ------------

compaction_126<- rast("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Theats_map/threats_SSP1/Compaction_ssp1.tif")

compaction_126_500 <- resample(compaction_126 ,  sealing_2050_500)

m1<-matrix(c(-1,-.10,1,
             -.10,.10,0,
             .10,.40,-1,
             .40,Inf,-2), 
           ncol=3, byrow=TRUE)


#r2 with reclass
compaction_reclass<-classify(x=compaction_126_500, rcl=m1, include.lowest=TRUE)
summary(compaction_reclass)

colors<- c("red", "orange", "#A7D397", "#57A347")
plot(compaction_reclass)
#plot(compaction_reclass)

tiff(file="E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Theats_map/Bundles/SSP5/compaction_class_plotssp5.tif",width = 2600, height = 1500, res = 300, pointsize = 6)
pdf(file = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Theats_map/Bundles/SSP5/compaction_class_plotssp5.pdf", width = 20, height = 15, pointsize = 10)#run this together to export and save image in good resolution
tm_shape(compaction_reclass, raster.downsample = FALSE) +
  tm_raster(
    palette = colors,
    style = "pretty",
    # breaks = c(-3,-2,-1,0,1,2),
    #labels = c("-2", "-1", "0", "1"), 
    title = "Soil compaction - SSP585", 
  ) +
  tm_legend(legend.outside = TRUE, legend.text.size = 2.5, legend.title.size = 3.0) +
  tm_legend(outside = TRUE, hist.width = 2, hist.height = 0.4) +
  tm_shape(shp) +
  tm_borders(col = "grey30", lwd = 0.5, lty = "solid", alpha = 0.8) +
  tm_scale_bar(
    position = c("left", "bottom"),  # Adjust the position as needed
    size = 1.8,  # Adjust the distance from the scale bar to the map
    color.dark = "black",  # Set the color of the scale bar
    color.light = "white",  # Set the color of the scale bar text
    text.size = 2.8,
    breaks = seq(0, 600, by = 200)  # Adjust the breaks as needed# Set the size of the scale bar text
  ) +
  tm_layout(title = "", title.size = 2.8, inner.margins = c(0.02, 0.02, 0.02, 0.02))

dev.off()

writeRaster(compaction_reclass, "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Theats_map/Bundles/SSP1/compaction_class_SSP1.tif",overwrite=TRUE)


# Soil stockloss ------------
SOCloss_126 <- rast("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Theats_map/threats_SSP1/SOC_stock_loss_SSP1.tif")

SOCloss_126_500 <- resample(SOCloss_126 ,  compaction_126_500)


summary(SOCloss_126_500)
hist(SOCloss_126_500)
#matrix with rules reclass
m2<-matrix(c(-41,-10,-1,
             -10,0,0,
             0,10,0,
             10,Inf,1), ncol=3, byrow=TRUE)

#r2 with reclass
SOCloss_reclass<-classify(x=SOCloss_126_500, rcl=m2, include.lowest=TRUE)
summary(SOCloss_reclass)
plot(SOCloss_reclass)

writeRaster(SOCloss_reclass, "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Theats_map/Bundles/SSP1/SOCloss_reclass_ssp1.tif",overwrite=TRUE)

# Soil erosion ----------

erosion_126 <-  rast("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Theats_map/threats_SSP1/erosion_126.tif")
erosion_126_500 <- resample(erosion_126 , 
                            sealing_2050_500)
m3rr<-matrix(c(0,1,0,
               1,2,-1,
               2,5,-2,
               5,10,-3,
               10,Inf,-4), ncol=3, byrow=TRUE)





erosion_126n_reclass<-classify(x=erosion_126_500, 
                               rcl=m3rr, 
                               include.lowest=TRUE)

plot(erosion_126n_reclass)

writeRaster(erosion_126n_reclass, "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Theats_map/Bundles/SSP1/erosion_reclass_ssp1.tif",overwrite=TRUE)



###SSP5--------------------------------------------------------------------------------


# Compaction ------------
compaction_SSP5<- rast("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Theats_map/Threats_SSP5/Compaction_ssp5.tif")

compaction_126_500 <- resample(compaction_126 ,  sealing_2050_500)

m1<-matrix(c(-1,-.10,1,
             -.10,.10,0,
             .10,.40,-1,
             .40,Inf,-2), 
           ncol=3, byrow=TRUE)


#r2 with reclass
compaction_reclass<-classify(x=compaction_126_500, rcl=m1, include.lowest=TRUE)
summary(compaction_reclass)

plot(compaction_reclass)
#plot(compaction_reclass)


writeRaster(compaction_reclass, "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Theats_map/Bundles/SSP5/compaction_class_SSP5.tif",overwrite=TRUE)


# Soil stockloss ------------
SOCloss_SSP5 <- rast("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Theats_map/Threats_SSP5/SOC_stock_loss_SSP5.tif")

SOCloss_SSP5 <- resample(SOCloss_SSP5  ,  compaction_126_500)


summary(SOCloss_SSP5)
hist(SOCloss_SSP5)
#matrix with rules reclass
m2<-matrix(c(-42,-10,-1,
             -10,0,0,
             0,10,0,
             10,Inf,1), ncol=3, byrow=TRUE)

#r2 with reclass
SOCloss_reclass_SSP5<-classify(x=SOCloss_SSP5, rcl=m2, include.lowest=TRUE)
summary(SOCloss_reclass_SSP5)
plot(SOCloss_reclass_SSP5)

writeRaster(SOCloss_reclass_SSP5, "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Theats_map/Bundles/SSP5/SOCloss_reclass_ssp5.tif",overwrite=TRUE)

# Soil erosion ----------

erosion_SSP5<- rast("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Theats_map/Threats_SSP5/erosion_SSP5.tif")
SOCloss_SSP5 <- resample(SOCloss_SSP5  ,  compaction_126_500)

m3rr<-matrix(c(0,1,0,
               1,2,-1,
               2,5,-2,
               5,10,-3,
               10,Inf,-4), ncol=3, byrow=TRUE)


erosion_reclass_SSP5 <- resample(erosion_SSP5 , 
                            sealing_2050_500)


erosion_ssp5_reclass<-classify(x=erosion_reclass_SSP5, 
                               rcl=m3rr, 
                               include.lowest=TRUE)

plot(erosion_ssp5_reclass)

writeRaster(erosion_ssp5_reclass, "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Theats_map/Bundles/SSP5/erosion_reclass_ssp5.tif",overwrite=TRUE)


