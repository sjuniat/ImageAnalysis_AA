## Based off Koehler_areaanalysis_1combinedata_v1.R
## Combine Sox2 and Myo7a histogram data into one organised excel file

## SET for filename:
rundate <- "200317"
parentpath <- "C:/Users/Stephanie/Documents/My Documents/PhD/Koehler/200317/current/Data"

## AUTO ##
library(XLConnect)
library(stringr)
library(dplyr)
library(tidyr)

setwd(paste0(parentpath, "/C1xC2"))

samples.function <- function() {
        wkbks.list <- strsplit(list.files(pattern = '.csv'), "_")
        unique.samples <- c()
        for (i in 1:length(wkbks.list)) {
                unique.samples <- c(unique.samples, paste0(wkbks.list[[i]][2:5], collapse = "_"))
        }
        return(unique(unique.samples))
}

samples <- samples.function()

dat.sm <- c()
for (i in samples) {
        wkbks.list <- list.files(pattern = i)
        naming <- str_split_fixed(i, "_10X", 2)[1, 1]
        wkbk.sm <- wkbks.list[grep("histogram", wkbks.list)]
        wkbk.sm <- read.csv(wkbk.sm, fill = TRUE, header = TRUE, stringsAsFactors = FALSE)
        wkbk.sm$Image <- naming
        wkbk.sm <- wkbk.sm[ , c("Label", "Value", "Count", "Image")]
        dat.sm <- rbind(dat.sm, wkbk.sm) 
}


setwd(parentpath)
comb.sm <- loadWorkbook(filename = paste0("KoehlerC1C2Data_", rundate, ".xlsx"), create = TRUE)
createSheet(comb.sm, name = "AreaData")
writeWorksheet(comb.sm, data = dat.sm, sheet = "AreaData", header = TRUE, rownames = NULL)
saveWorkbook(comb.sm)


