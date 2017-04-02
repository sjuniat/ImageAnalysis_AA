## Based off Koehler_areaanalysis_2maskanalysis_v1.R
## Take C1 x C2, C1 and C2 binary histogram data and carry out % area analysis
## Add ROI size to ImageData workbook


## Set
setwd("C:/Users/Stephanie/Documents/My Documents/PhD/Koehler/200317/current/Data")
cond.order <- c("4ND", "4D", "4.5ND", "4.5D", "24wp-4ND", "24wp-4.5ND")
SMcolour.order <- c("#999999", "#56B4E9")
colour.order <- "Set1"

## make sure Reference Table is in the Data folder


## AUTO ##
library(XLConnect)
library(stringr)
library(dplyr)
library(tidyr)
library(reshape2)
library(ggplot2)

wb <- loadWorkbook(list.files(pattern = 'KoehlerC1C2Data'))
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

## 1. Add size of ROIs to Image Data spreadsheet.
# size of ROI should be less than size of cropped image
ROIsize <- aggregate(Count ~ Image+Label, sum, data = AreaData)
ROIsize <- ROIsize[ , c(1,3)]
ROIsize <- unique(ROIsize)
colnames(ROIsize) <- c("sample", "ROI size (pixels)")

wkbk.id <- loadWorkbook(list.files(pattern = 'KoehlerImageData'))
if(length(getSheets(wkbk.id)) == 1) {
        assign(getSheets(wkbk.id), readWorksheet(wkbk.id, sheet = getSheets(wkbk.id)))
} else {
        lst <- readWorksheet(wkbk.id, sheet = getSheets(wkbk.id))
        list2env(lst, envir = .GlobalEnv)
}

dat.id <- left_join(ImageData, ROIsize, by = "sample")

createSheet(wkbk.id, name = "ImageData_ROIsize")
writeWorksheet(wkbk.id, data = dat.id, sheet = "ImageData_ROIsize", header = TRUE, rownames = NULL)
saveWorkbook(wkbk.id)

## 2. % area analysis
## Add Markers
markerset <- rbind(
        C1 = "Myo7a-GFP",
        C2 = "Sox2",
        C3 = "Phalloidin",
        C4 = "DAPI"
)

AreaData$Markers <- markerset[match(AreaData$Label, rownames(markerset))]
AreaData[is.na(AreaData$Markers), "Markers"] <- AreaData[is.na(AreaData$Markers), "Label"]

## SM divided by total M
PosData <- AreaData[AreaData$Value == 1, ]

C1.data <- PosData[grepl("C1", PosData$Label), ]
C1.arr <- C1.data[ , c("Image", "Markers", "Count")]
C1.arr <- spread(C1.arr, Markers, Count)

C1.arr$Sox2inMyo7a <- 100* C1.arr$C1xC2 / C1.arr$`Myo7a-GFP`
C1.result <- C1.arr[ , c("Image", "Sox2inMyo7a")]

## SM by S
C2.data <- PosData[grepl("C2", PosData$Label), ]
C2.arr <- C2.data[ , c("Image", "Markers", "Count")]
C2.arr <- spread(C2.arr, Markers, Count)

C2.arr$Myo7ainSox2 <- 100* C2.arr$C1xC2 / C2.arr$Sox2
C2.result <- C2.arr[ , c("Image", "Myo7ainSox2")]

## 3. Plot data - S in M and M in s on one plot, faceted
results <- left_join(C1.result, C2.result, by = "Image")
results.long <- melt(results)

dat <- results.long
plotname <- "Percentage of Myo7a+ pixels in Sox2+ and vice versa"
dat$Cond <- reference[match(str_extract(dat$Image,"slide.*_c[0-9]"), reference$code), "Condition"]
dat$Cond <- factor(dat$Cond, levels = cond.order)

means.dat <- aggregate(value ~ Cond+variable, mean, data = dat)
sums.dat <- count(dat, Cond)
sums.dat$n <- sums.dat$n/2

tiff(filename = "C1C2Boxplot_All.tif", width = 8, height = 5, units = 'in', res = 300)
ggplot() +
        geom_boxplot(data = dat, aes(y = value, x = variable, fill = variable)) +
        scale_fill_manual(values = SMcolour.order) +
        facet_grid(. ~ Cond) +
        theme(axis.title.x = element_blank(),
              axis.text.x=element_blank(),
              axis.ticks.x=element_blank()) +
        ylab("%") +
        ggtitle(plotname) +
        theme(plot.title = element_text(hjust = 0.5)) +
        geom_point(data = means.dat, aes(y = value, x = variable), shape = 23, size = 2, fill = "darkred") +
        geom_text(data = means.dat, aes(x = variable, label = round(value,1), y = value + 2.2), size = 3, colour = "darkred") 
dev.off()

## 4. Plot data Sox2 and Myo7a separately
dat2M <- dat[dat$variable == "Sox2inMyo7a", ]
means.dat2M <- aggregate(value ~ Cond, mean, data = dat2M)

tiff(filename = "C1C2Boxplot_Myo7a.tif", width = 8, height = 5, units = 'in', res = 300)
ggplot() +
        geom_boxplot(data = dat2M, aes(y = value, x = Cond, fill = variable)) +
        scale_fill_manual(values = SMcolour.order[2]) +
        ylab("%") +
        ylim(c(0,100)) +
        ggtitle("Sox2 in Myo7a") +
        theme(plot.title = element_text(hjust = 0.5)) +
        geom_point(data = means.dat2M, aes(y = value, x = Cond), shape = 23, size = 2, fill = "darkred") +
        geom_text(data = means.dat2M, aes(x = Cond, label = round(value,1), y = value + 2.2), size = 3, colour = "darkred")
dev.off()

dat2S <- dat[dat$variable == "Myo7ainSox2", ]
means.dat2S <- aggregate(value ~ Cond, mean, data = dat2S)

tiff(filename = "C1C2Boxplot_Sox2.tif", width = 8, height = 5, units = 'in', res = 300)
ggplot() +
        geom_boxplot(data = dat2S, aes(y = value, x = Cond, fill = variable)) +
        scale_fill_manual(values = SMcolour.order[1]) +
        ylab("%") +
        ylim(c(0,100)) +
        ggtitle("Myo7a in Sox2") +
        theme(plot.title = element_text(hjust = 0.5)) +
        geom_point(data = means.dat2S, aes(y = value, x = Cond), shape = 23, size = 2, fill = "darkred") +
        geom_text(data = means.dat2S, aes(x = Cond, label = round(value,1), y = value + 2.2), size = 3, colour = "darkred")
dev.off()

createSheet(wb, name = "PercArea")
createSheet(wb, name = "PercAreaLong")
writeWorksheet(wb, data = results, sheet = "PercArea", header = TRUE, rownames = NULL)
writeWorksheet(wb, data = dat, sheet = "PercAreaLong", header = TRUE, rownames = NULL)
saveWorkbook(wb)
