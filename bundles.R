
#Bundles try in ST classes

library(dendextend)
library(cowplot)
library(Rmixmod)
library(fclust)
library(ClusterR)
library(sp)
library(sf)
library(ggplot2)
library(dplyr)
library(tidyr)
library(tmap)
library(FactoMineR)
library(factoextra)
library("NbClust")
library("RColorBrewer")
library(cluster)


#-----SSP1

erosion_126 <- rast("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Theats_map/Erosion/fr_RUSLE_2050_ssp1.tif")
compaction_126 <-rast("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Theats_map/Compaction/Compaction_ssp1.tif")
SOCloss_126 <- rast("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Theats_map/SOC_loss/soc_stock1_ssp1.tif")
sealing <- rast("E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Theats_map/sealing/SoilSealing.tiff")
shp <- vect("E:/SERENA/WP5_bundles/France/France_harmonized_covariates/SHP/NUTS3_France.shp")


erosion_1<- terra::project(erosion_126, SOCloss_126)
res(erosion_1)
crs(erosion_1)
plot(erosion_126)
summary(erosion_126)

#-----SSP5




#Stack and create dataframe
r126 <- c(erosion_1, compaction_126,SOCloss_126,sealing )
new_names <- c("SoilErosion", "SoilCompaction", "SOCLoss", "Sealing")
names(r126) <- new_names
dataClust_126 <- as.data.frame( r126 )
dataClust_126 <- na.omit(dataClust_126)


##########################################################
# kmeans appraach based on loading of the MCA-------------


tt_126 = dataClust_126
tt_126$SoilErosion = factor(tt_126$SoilErosion, ordered = T)
tt_126$SoilCompaction = factor(tt_126$SoilCompaction, ordered = T)
tt_126$SOCLoss = factor(tt_126$SOCLoss, ordered = T)
tt_126$Sealing = factor(tt_126$Sealing, ordered = T)

res = MCA(X = tt_126 [,1:4],graph = FALSE
)

# Summary of the MCA results
summary(res)


# Categories plot
fviz_mca_var(res, axes = c(1,2), col.var = "cos2", gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"), repel = TRUE)



resampleK = sample(1:nrow(res$ind$coord),1010)
nb <- NbClust(res$ind$coord[resampleK,],
              distance = "euclidean",
              min.nc = 2,
              max.nc = 20,
              method = "kmeans"
)



write.csv(nb$All.index, "E:/SERENA/WP5_bundles/France/ISRIC_threats_France/Theats_map/Bundles/clusterindices126_ST.csv")

#################################################################
NbclustersST = 20
kmeancClust126<- KMeans_rcpp(res$ind$coord , NbclustersST , num_init = 10 )
write.csv(kmeancClust126$centroids,"jacoblnski/Bundles/centroids126_ST.csv")



#####################

#  heatmap

t126 <- cbind.data.frame(coordinates(r126), as.data.frame( r126 ))
t126 <- na.omit(t126)

t126$CLZskmeans <- as.factor(kmeancClust126$clusters)


cust.long <- reshape::melt(t126 %>% select(CLZskmeans,3:6), 
                           id = c( "CLZskmeans"), factorsAsStrings=T)
cust.long.q <- cust.long %>%
  mutate(value = paste(variable, value)) %>%
  group_by(CLZskmeans, variable, value) %>%
  mutate(count = n()) %>%
  distinct(CLZskmeans, variable, value, count)

# calculating the percent of each factor level in the absolute count of cluster members

# Your existing code for data manipulation
cust.long.p <- cust.long.q %>%
  group_by(CLZskmeans, variable) %>%
  mutate(perc = count / sum(count) * 100) %>%
  arrange(CLZskmeans)


# Create the heatmap
heatmap.p <- ggplot(cust.long.p, aes(
  x = CLZskmeans,
  y = factor(value, levels = c("SOCLoss -1", "SOCLoss 0", "SOCLoss 1",
                               "SoilCompaction -2", "SoilCompaction -1", "SoilCompaction 0", "SoilCompaction 1",
                               "SoilErosion -4", "SoilErosion -3", "SoilErosion -2", "SoilErosion -1", "SoilErosion 0",
                               "Sealing -1", "Sealing 0"), ordered = TRUE),
  
  fill = perc
)) +
  geom_tile() +
  geom_text(aes(label = sprintf("%0.1f%%", perc)), vjust = 1.5, size = 1.8) +
  labs(title = "", x = "Bundle", y = NULL) +
  geom_hline(yintercept = 3.5) +
  geom_hline(yintercept = 7.5) +
  geom_hline(yintercept = 12.5) +
  scale_fill_gradient2(name = "Percentage Range", 
                       low = "darkslategray1", mid = "yellow", high = "turquoise4",
                       breaks = c(0, 25, 50, 75, 100),
                       labels = c("0%", "25%", "50%", "75%", "100%")) +
  guides()

heatmap.p


# Define the desired order of cluster IDs (replace with your actual order)

#desired_order <- c(5,7,9,10,13,12,15,4,17,11,1,6,20,16,14,3,8,2,18,19)

desired_order <- c(4,8,5,10,14,3,6,2,7,12,9,18,13,17,1,11,15,20,19,16) # order after comparing with other cc stbundle

# Use factor to reorder the levels of the CLZskmeans variable
cust.long.p <- cust.long.q %>%
  mutate(CLZskmeans = factor(CLZskmeans, levels = desired_order)) %>%
  group_by(CLZskmeans, variable) %>%
  mutate(perc = count / sum(count) * 100) %>%
  arrange(CLZskmeans)

# Create the heatmap
heatmap.p <- ggplot(cust.long.p, aes(
  x = CLZskmeans,
  y = factor(value, levels = c("SOCLoss -1", "SOCLoss 0", "SOCLoss 1",
                               "SoilCompaction -2", "SoilCompaction -1", "SoilCompaction 0", "SoilCompaction 1",
                               "SoilErosion -4", "SoilErosion -3", "SoilErosion -2", "SoilErosion -1", "SoilErosion 0",
                               "Sealing -1", "Sealing 0"), ordered = TRUE),
  
  fill = perc
)) +
  geom_tile() +
  geom_text(aes(label = sprintf("%0.1f%%", perc)), vjust = 1.5, size = 1.8) +
  labs(title = "", x = "Bundle", y = NULL) +
  geom_hline(yintercept = 3.5) +
  geom_hline(yintercept = 7.5) +
  geom_hline(yintercept = 12.5) +
  scale_fill_gradient2(name = "Percentage Range", 
                       low = "darkslategray1", mid = "yellow", high = "turquoise4",
                       breaks = c(0, 25, 50, 75, 100),
                       labels = c("0%", "25%", "50%", "75%", "100%")) +
  guides()

heatmap.p

# Save the plot to a TIFF file
tiff(file="jacoblnski/Bundles/New_figures_ST_paper/ST_bundle_heatplot_126.tif", width = 2600, height = 1500, res = 300, pointsize = 6)
print(heatmap.p)
dev.off()


###################################################################

############################################################################################
#    1- Map  

t126$CLZskmeans <- as.numeric(t126$CLZskmeans)
bundkmens <- raster::rasterFromXYZ(as.matrix(t126[,c(1:2,7)],),
                                   crs = crs(erosion_126))

writeRaster(bundkmens,"jacoblnski/Bundles/NEW_RASTERS_st_PAPER/Bundles_ssp126_ST_raster_FINAL.tif",overwrite=TRUE)

bundkmens <- raster("jacoblnski/Bundles/NEW_RASTERS_st_PAPER/Bundles_ssp126_ST_raster_FINAL.tif")

pal21_126 <- c(
  "#f9a825",
  "#1976D2",
  "#0D47A1",
  "lightgreen",
  "#004D40",
  "#1565C0",
  "#1E88E5",
  "#369D0A",
  "#90CAF9",
  "darkblue",
  "#fdd835",
  "#42A5F5",
  "#E3F2FD",
  "#192fb3",
  "#ffeb3b",
  "#e57373",
  "#f57f17",
  "#BBDEFB",
  "#b71c1c",
  "yellow"
)

# Create the thematic map
map <- tm_shape(bundkmens,raster.downsample = FALSE) +
  tm_raster(palette = pal21_126, style = "cat", title = "") +
  tm_compass(position = c("left", "top"), size = 10) +
  tm_legend(legend.outside = TRUE, legend.text.size = 2.5, legend.title.size = 3.0)+
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
  tm_layout(
    title = "Bundles of Soil threats in 2050 - SSP126",
    title.size = 4.8,
    scale = .8,
    inner.margins = c(0.02, 0.02, 0.02, 0.02),
    legend.position = c("left", "bottom"),
    legend.bg.color = "white",
    legend.bg.alpha = .2,
    legend.frame = "gray50",
    legend.outside = TRUE
  )
# Display the map
map

#tiff(file="~/jacoblnski/Bundles/Bundles_figures/bundle_ST_ssp5.tif",width = 2600, height = 1500, res = 300, pointsize = 6)
pdf(file = "~/jacoblnski/Bundles/Bundles_figures/bundles_colors_teste/bundle_ST_ssp126_new.pdf", width = 20, height = 15, pointsize = 10)#run this together to export and save image in good resolution
map
dev.off()



################################### PLOT BUNDLE WITH SEALING
bundle_ST_2050_SPP1 <- bundkmens
# Crop the raster to the extent of the shapefile
bundle_cropped <- crop(bundle_ST_2050_SPP1, extent(shp))

# Convert NA values to 0
bundle_cropped[is.na(bundle_cropped)] <- 0

sealing_cropped <- crop(sealing, extent(shp))

# Replace values of 1 from sealing_cropped to bundle_cropped
bundle_cropped[sealing_cropped == 1] <- 21
bundle_cropped[bundle_cropped == 0] <- NA
# Display the modified raster
plot(bundle_cropped)

pal21_126 <- c(
  "#f9a825",
  "#1976D2",
  "#0D47A1",
  "lightgreen",
  "#004D40",
  "#1565C0",
  "#1E88E5",
  "#369D0A",
  "#90CAF9",
  "darkblue",
  "#fdd835",
  "#42A5F5",
  "#E3F2FD",
  "#192fb3",
  "#ffeb3b",
  "#e57373",
  "#f57f17",
  "#BBDEFB",
  "#b71c1c",
  "yellow"
)
c(4,8,5,10,14,3,6,2,7,12,9,18,13,17,1,11,15,20,19,16)
colors <- c(
  4"lightgreen",
  8"#369D0A",
  5"#004D40",
  10"darkblue"
  14"#192fb3",
  3"#0D47A1",
  6"#1565C0",
  2"#1976D2",
  7"#1E88E5",
  12"#42A5F5",
  9 "#90CAF9",
  18"#BBDEFB",
  13"#E3F2FD",
  17 "#f57f17",
  1"#f9a825",
  11 "#fdd835",
  15 "#ffeb3b",
  20 "yellow",
  19 "#b71c1c",
  16 "#e57373"
)




tmap_mode("plot")
map <- tm_shape(bundle_cropped,raster.downsample = FALSE) +
  tm_raster(palette = pal21_126, style = "cat", title = "") +
  tm_compass(position = c("left", "top"), size = 10) +
  tm_legend(legend.outside = TRUE, legend.text.size = 2.5, legend.title.size = 3.0)+
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
  tm_layout(
    title = "",
    title.size = 4.8,
    scale = .8,
    inner.margins = c(0.02, 0.02, 0.02, 0.02),
    legend.position = c("left", "bottom"),
    legend.bg.color = "white",
    legend.bg.alpha = .2,
    legend.frame = "gray50",
    legend.outside = TRUE
  )

# Display the map
map


pdf(file = "~/jacoblnski/Bundles/Bundles_figures/bundle_ST_ssp126_SEALING.pdf", width = 20, height = 15, pointsize = 10)#run this together to export and save image in good resolution
map
dev.off()

writeRaster(bundle_cropped,"jacoblnski/Bundles/Bundles_ssp126_ST_raster_FINAL_with_SEALING.tif",overwrite=TRUE)




################################################################################################################


##### Area percentage analysis

# Load required libraries
library(sf)
library(raster)
library(rasterVis)
library(data.table)

# Read the shapefile
shp <- st_read("/media/communs_infosol/Projets/SERENA/SERENA_mask_outputs/4_EU_limit/EU_country_level.shp")

# Read the raster files
# sealing <- raster("~/jacoblnski/soil_sealing/sealing_1_2050_1km.tif")
bundle_ST_2050_SPP1 <- raster("~/jacoblnski/Bundles/NEW_RASTERS_st_PAPER/Bundles_ssp126_ST_raster_FINAL.tif")

# Crop the rasters to the extent of the shapefile
# sealing_cropped <- crop(sealing, extent(shp))
bundle_cropped <- crop(bundle_ST_2050_SPP1, extent(shp))

# # Replace NA values in bundle_cropped with 0
# bundle_cropped[is.na(bundle_cropped)] <- 0
# 
# sealing_cropped[sealing_cropped == 1] <- 21
# # Replace values of 21 from sealing_cropped to bundle_cropped
# bundle_cropped[sealing_cropped == 21] <- 21
# 
# # Replace values of 1 from sealing_cropped to bundle_cropped
# bundle_cropped[bundle_cropped == 0] <- NA

# Calculate the number of pixels in each cluster using data.table
cluster_counts <- as.data.table(table(getValues(bundle_cropped)))

# Rename the columns for clarity
setnames(cluster_counts, c("Bundle", "PixelCount"))

# Calculate the total number of pixels
total_pixels <- sum(cluster_counts$PixelCount)

# Calculate the percentage for each cluster
cluster_counts[, Percentage := (PixelCount / total_pixels) * 100]

# Display the table
print(cluster_counts)

write.csv(cluster_counts,"jacoblnski/Bundles/Percentage_Area_bundle_126.csv")

# Create a bar plot
# ordering the bundles for the barplot
# ordered_clusters <- order.dendrogram(dend)
# reversed_clusters <- rev(ordered_clusters)
desired_order <- c(4,8,5,10,14,3,6,2,7,12,9,18,13,17,1,11,15,20,19,16)
cluster_counts$Bundle <- factor(cluster_counts$Bundle, levels = unique(cluster_counts$Bundle)[desired_order])
cluster_counts$Bundle <- factor(cluster_counts$Bundle, levels = rev(levels(cluster_counts$Bundle)))

#cluster_counts$Bundle <- ifelse(is.na(cluster_counts$Bundle), "21", as.character(cluster_counts$Bundle))



bar <- ggplot(cluster_counts, aes(x = Percentage, y = Bundle, fill = Bundle)) +
  geom_bar(stat = "identity", position = "dodge", color = "black", fill = pal21_126,
           width = 0.95,  # Adjust the width of the bars
           height = 0.7) +
  
  # Customize labels and title
  labs(title = "",
       x = "Percentage",
       y = "") +
  
  # Rotate y-axis labels horizontally
  theme(axis.text.y = element_text(angle = 2, hjust = 0, vjust = 0.5)) +
  
  # Adjust size of x-axis labels
  theme(axis.text.y = element_text(size = 14)) +
  theme(axis.text.x = element_text(size = 14)) +
  
  # Increase left margin
  theme(plot.margin = margin(l = 15)) +
  
  # Add percentage labels to the right of each bar with adjusted position
  geom_text(aes(label = sprintf("%.1f%%", Percentage),
                x = Percentage + 1),
            position = position_dodge(width = 0.5),
            vjust = 0.5,
            hjust = 0.35,# Adjust vjust here
            size = 4)


bar
# Display the plot
tiff(file="~/jacoblnski/Bundles/New_figures_ST_paper/bar_area_bundle_ST_ssp126.tif",width = 2100, height = 2600, res = 300, pointsize = 6)
bar
dev.off()



