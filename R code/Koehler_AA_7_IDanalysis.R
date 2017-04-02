## Plot image data 1) Threshold values

## SET for filename:
rundate <- "200317"
parentpath <- "C:/Users/Stephanie/Documents/My Documents/PhD/Koehler/200317/current/Data"

cond.order <- c("4ND", "4D", "4.5ND", "4.5D", "24wp-4ND", "24wp-4.5ND")
colour.order <- "Set1"


## AUTO #
setwd(parentpath)

## Reference files ##
wb.ph <- loadWorkbook(list.files(pattern = 'KoehlerPhallData'))
wb.id <- loadWorkbook(list.files(pattern = 'KoehlerImageData'))
dat.id <- readWorksheet(wb.id, sheet = "ImageData")
C3origin <- readWorksheet(wb.ph, "C3origin")

refwb <- loadWorkbook(filename = "ReferenceTable.xlsx") 
reference <- readWorksheet(refwb, "Sheet1")
reference$code <- paste(gsub(" ", "", tolower(reference$Slide)), reference$Spot)
reference$code <- gsub(" ", "_", reference$code)
reference <- reference[complete.cases(reference) , c("code", "Condition")]

## Plot threshold values
# Get data
C3min.dat <- C3origin[ , c("Image", "C3min.T")]
C3min.dat <- unique(C3min.dat)

C1min.T <- c()
C2min.T <- c()
for (i in C3min.dat$Image) {
        C1.T <- as.numeric(dat.id[match(i, dat.id$sample), "Threshold.C1.min"])
        C2.T <- as.numeric(dat.id[match(i, dat.id$sample), "Threshold.C2.min"])
        C1min.T <- c(C1min.T, C1.T)
        C2min.T <- c(C2min.T, C2.T)
}
T.dat <- cbind(C3min.dat, C1min.T, C2min.T)

# Prepare data table
T.dat <- gather(T.dat, "variable", "value", C1min.T, C2min.T, C3min.T)
T.dat$Cond <- reference[match(str_extract(T.dat$Image,"slide.*_c[0-9]"), reference$code), "Condition"]
T.dat$Cond <- factor(T.dat$Cond, levels = cond.order)

# Calculate means
means.dat <- aggregate(value ~ Cond+variable, mean, data = T.dat)

# Plot
tiff(filename = "ThresholdVals.tif", width = 16, height = 5, units = 'in', res = 300)
ggplot() +
        geom_boxplot(data = T.dat, aes(y = value, x = Cond, fill = Cond)) +
        scale_fill_brewer(palette = colour.order) +
        facet_grid(. ~ variable) +
        theme(axis.title.x = element_blank()) +
        ylab("Threshold Value (T)") +
        geom_point(data = means.dat, aes(y = value, x = Cond), shape = 23, size = 2, fill = "darkred") +
        geom_text(data = means.dat, aes(x = Cond, label = round(value,1), y = value + 20), size = 3, colour = "darkred") 
dev.off()


