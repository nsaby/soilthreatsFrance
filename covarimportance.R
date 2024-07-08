rf_gsm <- readRDS("outputsocloss/socless45yrsoc/model/socless45yrsoc/model-fitted_rangerquantreg_0-20_notransform_dorfe_tune.RDS")

rf_gsm_var <- as.data.frame(rf_gsm$variable.importance)

library(tibble)
rf_gsm_var <- rownames_to_column(rf_gsm_var, var = "Covariate")
colnames(rf_gsm_var)[2] <- "Importance"

head(rf_gsm_var)

#select top 10 variables
rf_gsm_var10 <-  rf_gsm_var %>% slice_max(rf_gsm_var$Importance, n=20)
head(rf_gsm_var)

ggplot(data = rf_gsm_var10, aes(x = reorder(Covariate , Importance), y = Importance, fill = Importance)) +
  geom_bar(stat = "identity", position = "dodge") +
  coord_flip() +
  ylab("") +
  xlab("") +
  guides(fill = FALSE) +
  scale_fill_gradient(low = "lightgreen", high = "darkgreen") +
  theme(text = element_text(size = 15)) + ggtitle("GSM") 


z