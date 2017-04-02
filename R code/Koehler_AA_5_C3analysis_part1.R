## Phalloidin analysis - 1) Check total pixels add up, 2) plot below halfT means, 3) below 250T means

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

## Reference files ##
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

## 1. Check pixel counts match up to C3b
# Get data
IntensityData$TotalPixels <- IntensityData$NumPixels.belowT + IntensityData$NumPixels.aboveT
datacheck <- aggregate(TotalPixels ~ Image, FUN = unique, data = IntensityData)
referencetotal <- aggregate(Count ~ Image, sum, data = ROIsize)
datacheck <- full_join(datacheck, referencetotal, by = "Image")
colnames(datacheck) <- c("Image", "PhallData", "C3b histogram")

# Run check:
FALSE %in% (datacheck$PhallData == datacheck$`C3b histogram`) ## if any mismatches, result will show TRUE. 

# Save data
createSheet(wb, name = "TotalPixels")
writeWorksheet(wb, data = datacheck, sheet = "TotalPixels", header = TRUE, rownames = NULL)
saveWorkbook(wb)

## 2. Calculate mean intensity 1 to half*threshold in C3 (original image)
# Get data
mi.dat <- C3origin[ , c("Image", "Label", "Mean.belowhalfT", "Mean.below250")]
mi.dat$Cond <- reference[match(str_extract(mi.dat$Image,"slide.*_c[0-9]"), reference$code), "Condition"]
mi.dat$Cond <- factor(mi.dat$Cond, levels = cond.order)

dat <- mi.dat[ , c("Image", "Label", "Cond", "Mean.belowhalfT")]

# Prepare data table
colnames(dat)[2] <- "variable"
colnames(dat)[4] <- "value"

# Calculate means
means.dat <- aggregate(value ~ Cond+variable, mean, data = dat)

# Plot
tiff(filename = "C3halfT.tif", width = 8, height = 5, units = 'in', res = 300)
ggplot() +
        geom_boxplot(data = dat, aes(y = value, x = Cond, fill = Cond)) +
        scale_fill_brewer(palette = colour.order) +
        facet_grid(. ~ variable) +
        theme(axis.title.x = element_blank()) +
        ylab("Mean Intensty (1 to half-T)") +
        geom_point(data = means.dat, aes(y = value, x = Cond), shape = 23, size = 2, fill = "darkred") +
        geom_text(data = means.dat, aes(x = Cond, label = round(value,1), y = value + 2.2), size = 3, colour = "darkred") 
dev.off()

## 3. Calculate mean intensity between 1 to 250 in C3 (original image)
# Get data
dat2 <- mi.dat[ , c("Image", "Label", "Cond", "Mean.below250")]

# Prepare data table
colnames(dat2)[2] <- "variable"
colnames(dat2)[4] <- "value"

# Calculate means
means.dat2 <- aggregate(value ~ Cond+variable, mean, data = dat2)

# Plot
tiff(filename = "C3_250.tif", width = 8, height = 5, units = 'in', res = 300)
ggplot() +
        geom_boxplot(data = dat2, aes(y = value, x = Cond, fill = Cond)) +
        scale_fill_brewer(palette = colour.order) +
        facet_grid(. ~ variable) +
        theme(axis.title.x = element_blank()) +
        ylab("Mean Intensty (1 to 250)") +
        geom_point(data = means.dat2, aes(y = value, x = Cond), shape = 23, size = 2, fill = "darkred") +
        geom_text(data = means.dat2, aes(x = Cond, label = round(value,1), y = value + 2.2), size = 3, colour = "darkred") 
dev.off()

## Divide Num pixels by total to get percentages and check variance
dat3 <- C3origin[ , c("Image", "NumPixels.below250", "NumPixels.belowhalfT")]
dat3 <- full_join(dat3, datacheck[ , -3])
colnames(dat3)[4] <- "TotalPixels"
dat3$Perc.below250 <- 100* dat3$NumPixels.below250/dat3$TotalPixels
dat3$Perc.belowhalfT <- 100*dat3$NumPixels.belowhalfT/dat3$TotalPixels

dat3$Cond <- reference[match(str_extract(dat3$Image,"slide.*_c[0-9]"), reference$code), "Condition"]
dat3$Cond <- factor(dat3$Cond, levels = cond.order)

tiff(filename = "C3_250Perc.tif", width = 8, height = 5, units = 'in', res = 300)
ggplot() +
        geom_point(data = dat3, aes(y = Perc.below250, x = Cond)) +
        ylim(c(0,100)) +
        ylab("Percentage of pixels below threshold, Phalloidin (T = 250)") +
        theme(axis.title.x = element_blank())
dev.off()

tiff(filename = "C3_halfTPerc.tif", width = 8, height = 5, units = 'in', res = 300)
ggplot() +
        geom_point(data = dat3, aes(y = Perc.belowhalfT, x = Cond)) +
        ylim(c(0,100)) +
        ylab("Percentage of pixels below threshold, Phalloidin (T = 0.5*T)") +
        theme(axis.title.x = element_blank())
dev.off()