## Phalloidin analysis - 3) Intensity data analysis (mean) 4) Intensity data analysis (integrated density) 5) percentage area analysis

## Set
setwd("C:/Users/Stephanie/Documents/My Documents/PhD/Koehler/200317/current/Data")
cond.order <- c("4ND", "4D", "4.5ND", "4.5D", "24wp-4ND", "24wp-4.5ND")
colour.order <- "Set1"

## AUTO ##
library(XLConnect)
library(stringr)
library(dplyr)
library(tidyr)
library(reshape2)
library(ggplot2)

wb <- loadWorkbook(list.files(pattern = 'KoehlerPhallData'))
if(length(getSheets(wb)) == 1) {
        assign(getSheets(wb), readWorksheet(wb, sheet = getSheets(wb)))
} else { 
        lst <- readWorksheet(wb, sheet = getSheets(wb))
        list2env(lst, envir = .GlobalEnv)
}

refwb <- loadWorkbook(filename = "ReferenceTable.xlsx") 
reference <- readWorksheet(refwb, "Sheet1")
reference$code <- paste(gsub(" ", "", tolower(reference$Slide)), reference$Spot)
reference$code <- gsub(" ", "_", reference$code)
reference <- reference[complete.cases(reference) , c("code", "Condition")]

# 3. Mean Intensity of Phalloidin in Myo/Sox/Double -positive regions
# Get data
mi <- IntensityData[ , c("Image", "Label", "Mean.aboveT")]
mi$Cond <- reference[match(str_extract(mi$Image,"slide.*_c[0-9]"), reference$code), "Condition"]
mi$Cond <- factor(mi$Cond, levels = cond.order)

# Prepare data table
mi.dat <- mi
mi.dat$Label <- gsub("bxC3", "", mi.dat$Label)
mi.dat$Label <- gsub("C1C2", "Phalloidin in Double Sox2/Myo7a Positive", mi.dat$Label)
mi.dat$Label <- gsub("C2", "Phalloidin in Sox2", mi.dat$Label)
mi.dat$Label <- gsub("C1", "Phalloidin in Myo7a", mi.dat$Label)

colnames(mi.dat)[2] <- "variable"
colnames(mi.dat)[3] <- "value"

mi.dat$variable <- factor(mi.dat$variable, levels = c("Phalloidin in Myo7a", "Phalloidin in Sox2", "Phalloidin in Double Sox2/Myo7a Positive"))

## Save wide data for stats
mi.wide <- spread(mi.dat, variable, value)
createSheet(wb, name = "MI.wide")
writeWorksheet(wb, data = mi.wide, sheet = "MI.wide", header = TRUE, rownames = NULL)
saveWorkbook(wb)


# Calculate means + SD
means.midat <- aggregate(value ~ Cond+variable, mean, data = mi.dat)
sd.midat <- aggregate(value ~ Cond+variable, sd, data = mi.dat)
colnames(means.midat)[3] <- "Mean"
colnames(sd.midat)[3] <- "SD"
means.midat <- full_join(means.midat, sd.midat)

## Save means + SD to workbook
createSheet(wb, name = "MI.MeanSD")
writeWorksheet(wb, data = means.midat, sheet = "MI.MeanSD", header = TRUE, rownames = NULL)
saveWorkbook(wb)

# Plot
tiff(filename = "Phall_MeanIntensity.tif", width = 16, height = 5, units = 'in', res = 300)
ggplot() +
        geom_boxplot(data = mi.dat, aes(y = value, x = Cond, fill = Cond)) +
        scale_fill_brewer(palette = colour.order) +
        facet_grid(. ~ variable) +
        theme(axis.title.x = element_blank()) +
        ylab("Mean Intensity (above T)") +
        geom_point(data = means.midat, aes(y = Mean, x = Cond), shape = 23, size = 2, fill = "darkred") +
        geom_text(data = means.midat, aes(x = Cond, label = round(Mean,1), y = Mean + 50), size = 3, colour = "darkred") 
dev.off()

# 4. Integrated Intensity of Phalloidin in Myo/Sox/Double -positive regions
# Get Data
intd <- IntensityData[ , c("Image", "Label", "IntDen.aboveT")]
intd$Cond <- reference[match(str_extract(intd$Image,"slide.*_c[0-9]"), reference$code), "Condition"]
intd$Cond <- factor(intd$Cond, levels = cond.order)

# Prepare data table 
int.dat <- intd
int.dat$Label <- gsub("bxC3", "", int.dat$Label)
int.dat$Label <- gsub("C1C2", "Phalloidin in Double Sox2/Myo7a Positive", int.dat$Label)
int.dat$Label <- gsub("C2", "Phalloidin in Sox2", int.dat$Label)
int.dat$Label <- gsub("C1", "Phalloidin in Myo7a", int.dat$Label)

colnames(int.dat)[2] <- "variable"
colnames(int.dat)[3] <- "value"
int.dat$variable <- factor(int.dat$variable, levels = c("Phalloidin in Myo7a", "Phalloidin in Sox2", "Phalloidin in Double Sox2/Myo7a Positive"))

## Save wide data for stats
int.wide <- spread(int.dat, variable, value)
createSheet(wb, name = "IntDen.wide")
writeWorksheet(wb, data = int.wide, sheet = "IntDen.wide", header = TRUE, rownames = NULL)
saveWorkbook(wb)


# Calculate means
means.intdat <- aggregate(value ~ Cond+variable, mean, data = int.dat)
sd.intdat <- aggregate(value ~ Cond+variable, sd, data = int.dat)
colnames(means.intdat)[3] <- "Mean"
colnames(sd.intdat)[3] <- "SD"
means.intdat <- full_join(means.intdat, sd.intdat)

createSheet(wb, name = "IntData.MeanSD")
writeWorksheet(wb, data = means.intdat, sheet = "IntData.MeanSD", header = TRUE, rownames = NULL)
saveWorkbook(wb)

# Plot
tiff(filename = "Phall_IntDen.tif", width = 16, height = 5, units = 'in', res = 300)
ggplot() +
        geom_boxplot(data = int.dat, aes(y = value, x = Cond, fill = Cond)) +
        scale_fill_brewer(palette = colour.order) +
        facet_grid(. ~ variable) +
        theme(axis.title.x = element_blank()) +
        ylab("Integrated Density (above T)") +
        geom_point(data = means.intdat, aes(y = Mean, x = Cond), shape = 23, size = 2, fill = "darkred") +
        geom_text(data = means.intdat, aes(x = Cond, label = round(Mean,-4), y = Mean + 1000000), size = 3, colour = "darkred") 
dev.off()

## 5. % area
# Get data
wb2 <- loadWorkbook(list.files(pattern = 'KoehlerC1C2Data'))
C1C2.data <- readWorksheet(wb2, "AreaData")

df <- IntensityData[ , c("Image", "Label", "NumPixels.aboveT")]
df$Label <- gsub("b", "", df$Label)
df$Label <- gsub("xC3", "", df$Label)

# Div = # pixels in binary mask that were positive, ie. for C1, # pixels above threshold in Myo7a channel
Div <- C1C2.data[C1C2.data$Value == 1, ]
Div$Label <- gsub("x", "", Div$Label)
Div <- Div[ , c("Image", "Label", "Count")]

# Combine data
comb <- full_join(df, Div, by = c("Image","Label"))
colnames(comb)[4] <- "Div"

# Calculate % Area; Using C1 as example, C1 mask x C3, apply threshold mathematically (exclude all values below threshold value determined from Moments Threshold), 
# take product and divide by # pixels positive in C1. The same as (binary C1 x binary C3)/binary C1
comb$PercentageArea <- 100*comb$NumPixels.aboveT/comb$Div
comb$Cond <- reference[match(str_extract(comb$Image,"slide.*_c[0-9]"), reference$code), "Condition"]
comb$Cond <- factor(comb$Cond, levels = cond.order)


comb.wide <- comb[, c("Image", "Label", "PercentageArea", "Cond")]
comb.wide$Label <- gsub("C1C2", "Phalloidin in Double Sox2/Myo7a Positive", comb.wide$Label)
comb.wide$Label <- gsub("C2", "Phalloidin in Sox2", comb.wide$Label)
comb.wide$Label <- gsub("C1", "Phalloidin in Myo7a", comb.wide$Label)

colnames(comb.wide)[2] <- "variable"
dat <- comb.wide # for later

comb.wide <- spread(comb.wide, variable, PercentageArea)

# Save to workbook
createSheet(wb, name = "C3PercArea.long")
writeWorksheet(wb, data = comb, sheet = "C3PercArea.long", header = TRUE, rownames = NULL)
saveWorkbook(wb)

createSheet(wb, name = "C3PercArea.wide")
writeWorksheet(wb, data = comb.wide, sheet = "C3PercArea.wide", header = TRUE, rownames = NULL)
saveWorkbook(wb)

# Prepare Data Table
colnames(dat)[3] <- "value"
dat$variable <- factor(dat$variable, levels = c("Phalloidin in Myo7a", "Phalloidin in Sox2", "Phalloidin in Double Sox2/Myo7a Positive"))

# Calculate means
means.dat <- aggregate(value ~ variable+Cond, mean, data = dat)
sd.dat <- aggregate(value ~ Cond+variable, sd, data = dat)
colnames(means.dat)[3] <- "Mean"
colnames(sd.dat)[3] <- "SD"
means.dat <- full_join(means.dat, sd.dat)

## Save to workbook
createSheet(wb, name = "C3PercArea.MeanSD")
writeWorksheet(wb, data = means.dat, sheet = "C3PercArea.MeanSD", header = TRUE, rownames = NULL)
saveWorkbook(wb)

# Plot
plotname <- "Phalloidin as % area"
tiff(filename = "Phall_PercArea.tif", width = 16, height = 5, units = 'in', res = 300)
ggplot() +
        geom_boxplot(data = dat, aes(y = value, x = Cond, fill = Cond)) +
        scale_fill_brewer(palette = colour.order) +
        facet_grid(. ~ variable) +
        theme(axis.title.x = element_blank()) +
        ylab("% Area Phalloidin+ (pixels)") +
        geom_point(data = means.dat, aes(y = Mean, x = Cond), shape = 23, size = 2, fill = "darkred") +
        geom_text(data = means.dat, aes(x = Cond, label = round(Mean,1), y = Mean + 1.5), size = 3, colour = "darkred") 
dev.off()
