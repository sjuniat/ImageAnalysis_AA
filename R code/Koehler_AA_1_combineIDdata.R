## Based off Koehler_areaanalysis_1combinedata_v1.R
## Combine image data into one organised excel file

## FIRST COPY REFERENCE TABLE . XLS FILE TO DATA FOLDER
## AND REARRANGE DATA FILES in DATA FOLDER INTO: C1xC2, Phall, imagedata


## SET for filename:
rundate <- "200317"
parentpath <- "C:/Users/Stephanie/Documents/My Documents/PhD/Koehler/200317/current/Data"

## AUTO ##

library(XLConnect)
library(stringr)
library(dplyr)
library(tidyr)

setwd(paste0(parentpath, "/imagedata"))

samples.function <- function() {
        wkbks.list <- strsplit(list.files(pattern = '.csv'), "_")
        unique.samples <- c()
        for (i in 1:length(wkbks.list)) {
                unique.samples <- c(unique.samples, paste0(wkbks.list[[i]][2:5], collapse = "_"))
        }
        return(unique(unique.samples))
}

samples <- samples.function()

dat.id <- c()
for (i in samples) {
        wkbks.list <- list.files(pattern = i)
        naming <- str_split_fixed(i, "_10X", 2)[1, 1]
        wkbk.id <- wkbks.list[grep("imagedata", wkbks.list)]
        wkbk.id <- read.csv(wkbk.id, fill = TRUE, header = TRUE, stringsAsFactors = FALSE)
        df.data <- c(naming, wkbk.id[1, "Width"], wkbk.id[1, "Height"], wkbk.id[2, "Width"], wkbk.id[2, "Height"], wkbk.id[3, "C1min"], wkbk.id[3, "C2min"], wkbk.id[3, "C3min"], str_split_fixed(wkbk.id[4, "Resolution"], " pixels", 2)[1,1])
        dat.id <- cbind(dat.id, df.data)
}

rownames(dat.id) <- c("sample", "original image width", "original image height", "cropped image width", "cropped image height", "Threshold C1 min", "Threshold C2 min", "Threshold C3 min", "Resolution pixels per um")
colnames(dat.id) <- dat.id["sample", ]
dat.id <- t(dat.id)
dat.id <- data.frame(dat.id)

setwd(parentpath)
comb.id <- loadWorkbook(filename = paste0("KoehlerImageData_", rundate, ".xlsx"), create = TRUE)
createSheet(comb.id, name = "ImageData")
writeWorksheet(comb.id, data = dat.id, sheet = "ImageData", header = TRUE, rownames = NULL)
saveWorkbook(comb.id)
