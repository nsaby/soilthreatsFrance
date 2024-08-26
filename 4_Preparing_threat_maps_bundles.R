#Soil sealing
library(terra)

#Soil sealing ----------

sealing_2050 <- rast("data/threats_SSP1/SoilSealing.tiff")

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

tiff(file="E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Theats_map/Bundles/SSP5/sealing_rec.tif",width = 2600, height = 1500, res = 300, pointsize = 6)

pdf(file = "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Theats_map/Bundles/SSP5/sealing_rec.pdf", width = 20, height = 15, pointsize = 10)#run this together to export and save image in good resolution
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



writeRaster(SoilSealing_classified, "Output_SOC_France/Bundles/SSP5/sealing_reclass.tif",overwrite=TRUE)

# Compaction ------------

compaction_126<- rast("data/threats_SSP1/Compaction_ssp1.tif")

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

writeRaster(compaction_reclass, "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Theats_map/Bundles/SSP5/compaction_class_SSP5.tif",overwrite=TRUE)


# Soil stockloss ------------

# Soil erosion ----------

erosion_126 <- rast("data/threats_SSP1/erosion_126.tif")

m3rr<-matrix(c(0,1,0,
               1,2,-1,
               2,5,-2,
               5,10,-3,
               10,Inf,-4), ncol=3, byrow=TRUE)


erosion_126_500 <- resample(erosion_126 , 
                            sealing_2050_500)


erosion_126n_reclass<-classify(x=erosion_126_500, 
                               rcl=m3rr, 
                               include.lowest=TRUE)

plot(erosion_126n_reclass)
