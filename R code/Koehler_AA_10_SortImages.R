## Sort images into conditions

parentpath <- "C:/Users/Stephanie/Documents/My Documents/PhD/Koehler/200317/RawImages/FireLUT"
setwd(parentpath)

## Create destination folders
dir.create(file.path(parentpath, "4D"))
dir.create(file.path(parentpath, "4ND"))
dir.create(file.path(parentpath, "4.5D"))
dir.create(file.path(parentpath, "4.5ND"))
dir.create(file.path(parentpath, "24wp-4ND"))
dir.create(file.path(parentpath, "24wp-4.5ND"))

## Required libraries
library(stringr)
library(XLConnect)

## Load reference table
setwd("../Data")
refwb <- loadWorkbook(filename = "ReferenceTable.xlsx") 
reference <- readWorksheet(refwb, "Sheet1")
reference$code <- paste(gsub(" ", "", tolower(reference$Slide)), reference$Spot)
reference$code <- gsub(" ", "_", reference$code)
reference <- reference[complete.cases(reference) , c("code", "Condition")]

setwd(parentpath)

for (i in list.files(pattern = ".tif")) {
        x <- str_extract(i,"slide.*_c[0-9]")
        cd <- paste0(reference[match(x, reference$code), "Condition"], "/")
        file.copy(from = i, to = paste0("./", cd, i))
}
