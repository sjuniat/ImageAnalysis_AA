## Phalloidin data analysis

## SET for filename:
rundate <- "200317"
parentpath <- "C:/Users/Stephanie/Documents/My Documents/PhD/Koehler/200317/current/Data"

setwd(parentpath)

wkbk.id <- loadWorkbook(list.files(pattern = 'KoehlerImageData'))
dat.id <- readWorksheet(wkbk.id, sheet = "ImageData")

setwd(paste0(parentpath, "/Phalloidin"))

## AUTO ##
library(XLConnect)
library(stringr)
library(dplyr)
library(tidyr)

samples.function <- function() {
        wkbks.list <- strsplit(list.files(pattern = '.csv'), "_")
        unique.samples <- c()
        for (i in 1:length(wkbks.list)) {
                unique.samples <- c(unique.samples, paste0(wkbks.list[[i]][2:5], collapse = "_"))
        }
        return(unique(unique.samples))
}

samples <- samples.function()


## Extract values below threshold and values above threshold, calculate integrated density and # pixels and save separately

dat.ph <- c()
dat.ph2 <- c()
for (i in samples) {
        wkbks.list <- list.files(pattern = i)
        naming <- str_split_fixed(i, "_10X", 2)[1, 1]
        wkbk.ph <- wkbks.list[grep("Phall", wkbks.list)]
        wkbk.ph <- read.csv(wkbk.ph, fill = TRUE, header = TRUE, stringsAsFactors = FALSE)
        wkbk.ph$Image <- naming
        wkbk.ph <- wkbk.ph[ , c("Label", "Value", "Count", "Image")]
        dat.ph <- rbind(dat.ph, wkbk.ph)
        
        wkbk.ph$Multiply <- wkbk.ph$Value*wkbk.ph$Count
        
        T <- dat.id[match(naming, dat.id$sample), "Threshold.C3.min"]
        T <- as.numeric(T)
        dat.belowt <- wkbk.ph %>% 
                filter(Value < T)
        dat.abovet <- wkbk.ph %>%
                filter(Value >= T)
        
        IntDen.below <- aggregate(Multiply ~ Label, sum, data = dat.belowt)
        IntDen.above <- aggregate(Multiply ~ Label, sum, data = dat.abovet)
        Count.below <- aggregate(Count ~ Label, sum, data = dat.belowt)
        Count.above <- aggregate(Count ~ Label, sum, data = dat.abovet)
        
        colnames(IntDen.below)[2] <- "IntDen.belowT"
        colnames(IntDen.above)[2] <- "IntDen.aboveT"
        colnames(Count.below)[2] <- "NumPixels.belowT"
        colnames(Count.above)[2] <- "NumPixels.aboveT"
        
        df <- full_join(IntDen.below, Count.below, by = "Label")
        df <- full_join(df, IntDen.above, by = "Label")
        df <- full_join(df, Count.above, by = "Label")
        
        df$Image <- naming
        df$Mean.belowT <- df$IntDen.belowT/df$NumPixels.belowT
        df$Mean.aboveT <- df$IntDen.aboveT/df$NumPixels.aboveT
        
        dat.ph2 <- rbind(dat.ph2, df)
}
dat.ph2 <- dat.ph2[ , c("Image", "Label", "IntDen.belowT", "NumPixels.belowT", "Mean.belowT", "IntDen.aboveT", "NumPixels.aboveT", "Mean.aboveT")]

dat.ph3 <- c()
for (i in samples) {
        wkbks.list <- list.files(pattern = i)
        naming <- str_split_fixed(i, "_10X", 2)[1, 1]
        wkbk.ph <- wkbks.list[grep("C3b", wkbks.list)]
        wkbk.ph <- read.csv(wkbk.ph, fill = TRUE, header = TRUE, stringsAsFactors = FALSE)
        wkbk.ph$Image <- naming
        wkbk.ph <- wkbk.ph[ , c("Label", "Value", "Count", "Image")]
        dat.ph3 <- rbind(dat.ph3, wkbk.ph)
}

dat.ph4 <- c() 
for (i in samples) {
        wkbks.list <- list.files(pattern = i)
        naming <- str_split_fixed(i, "_10X", 2)[1, 1]
        wkbk.ph <- wkbks.list[grep("C3origin", wkbks.list)]
        wkbk.ph <- read.csv(wkbk.ph, fill = TRUE, header = TRUE, stringsAsFactors = FALSE)
        wkbk.ph$Image <- naming
        wkbk.ph <- wkbk.ph[ , c("Label", "Value", "Count", "Image")]
        wkbk.ph$Multiply <- wkbk.ph$Value*wkbk.ph$Count
        
        T <- dat.id[match(naming, dat.id$sample), "Threshold.C3.min"]
        T <- as.numeric(T)
        dat.halft <- wkbk.ph %>%
                filter(Value < 0.5*T) %>%
                filter(Value >= 1)
        dat.250 <- wkbk.ph %>%
                filter(Value < 250) %>%
                filter(Value >= 1)
        
        IntDen.halft <- aggregate(Multiply ~ Label, sum, data = dat.halft)
        Count.halft <- aggregate(Count ~ Label, sum, data = dat.halft)
        IntDen.250 <- aggregate(Multiply ~ Label, sum, data = dat.250)
        Count.250 <- aggregate(Count ~ Label, sum, data = dat.250)
        
        colnames(IntDen.halft)[2] <- "IntDen.belowhalfT"
        colnames(IntDen.250)[2] <- "IntDen.below250"
        colnames(Count.halft)[2] <- "NumPixels.belowhalfT"
        colnames(Count.250)[2] <- "NumPixels.below250"
        
        df <- full_join(IntDen.halft, Count.halft, by = "Label")
        df <- full_join(df, IntDen.250, by = "Label")
        df <- full_join(df, Count.250, by = "Label")
        df$C3min.T <- T
        df$Mean.belowhalfT <- df$IntDen.belowhalfT/df$NumPixels.belowhalfT
        df$Mean.below250 <- df$IntDen.below250/df$NumPixels.below250 
        df$Image <- naming
        dat.ph4 <- rbind(dat.ph4, df)
}
dat.ph4 <- dat.ph4[ , c("Image", "Label", "C3min.T", "IntDen.belowhalfT", "NumPixels.belowhalfT", "Mean.belowhalfT", "IntDen.below250", "NumPixels.below250", "Mean.below250")]

setwd(parentpath)
write.csv(dat.ph, file = paste0("KoehlerC3RawData_ALL_", rundate, ".csv"))

wb <- loadWorkbook(filename = paste0("KoehlerPhallData_", rundate, ".xlsx"), create = TRUE)
createSheet(wb, name = "IntensityData")
writeWorksheet(wb, data = dat.ph2, sheet = "IntensityData", header = TRUE, rownames = NULL)

createSheet(wb, name = "ROIsize")
writeWorksheet(wb, data = dat.ph3, sheet = "ROIsize", header = TRUE, rownames = NULL)

createSheet(wb, name = "C3origin")
writeWorksheet(wb, data = dat.ph4, sheet = "C3origin", header = TRUE, rownames = NULL)
saveWorkbook(wb)




