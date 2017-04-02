
## Make sure to create these folders in "current" first! "Data", "Grayscale", "FireLUT"

## ADJUST:
parentpath <- "C:/Users/Stephanie/Documents/My Documents/PhD/Koehler/200317/current"
setwd(parentpath)

for (i in list.dirs()) {
        spreadsheets <- list.files(path = i, pattern = "Gray")
        file.copy(from = paste0(i, "/", spreadsheets), to = paste0("./Grayscale/", spreadsheets))
}

for (i in list.dirs()) {
        spreadsheets <- list.files(path = i, pattern = "Fire")
        file.copy(from = paste0(i, "/", spreadsheets), to = paste0("./FireLUT/", spreadsheets))
}

for (i in list.dirs()) {
        spreadsheets <- list.files(path = i, pattern = ".csv")
        file.copy(from = paste0(i, "/", spreadsheets), to = paste0("./Data/", spreadsheets))
}