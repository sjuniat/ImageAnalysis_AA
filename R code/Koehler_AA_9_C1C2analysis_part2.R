## Get %Sox2 and %Myo7a values (of whole section) from C1C2 data and plot (boxplot and SD plot done)

setwd("C:/Users/Stephanie/Documents/My Documents/PhD/Koehler/200317/current/Data")

wb <- loadWorkbook(list.files(pattern = 'KoehlerC1C2Data'))
if(length(getSheets(wb)) == 1) {
        assign(getSheets(wb), readWorksheet(wb, sheet = getSheets(wb)))
} else { 
        lst <- readWorksheet(wb, sheet = getSheets(wb))
        list2env(lst, envir = .GlobalEnv)
}

dat <- AreaData
colour.order <- "Set1"

## Reshape data so that 0 and 1 are column headings, filled with data from Count column
dat <- spread(dat, Value, Count)
# 1 column = # pixels above threshold, 0 column = # pixels below threshold. 
colnames(dat)[3:4] <- c("Neg", "Pos")

## Calculate percentage area: 
# Pos/(Neg+Pos) * 100%

dat$Percentage <- 100 * dat$Pos/(dat$Neg+dat$Pos)
dat$Label <- gsub("C1xC2", "Double Sox2/Myo7a Positive", dat$Label)
dat$Label <- gsub("C1", "Myo7a Positive", dat$Label)
dat$Label <- gsub("C2", "Sox2 Positive", dat$Label)

## Add conditions column
refwb <- loadWorkbook(filename = "ReferenceTable.xlsx") 
reference <- readWorksheet(refwb, "Sheet1")
reference$code <- paste(gsub(" ", "", tolower(reference$Slide)), reference$Spot)
reference$code <- gsub(" ", "_", reference$code)
reference <- reference[complete.cases(reference) , c("code", "Condition")]

dat$Cond <- reference[match(str_extract(dat$Image,"slide.*_c[0-9]"), reference$code), "Condition"]
cond.order <- c("4ND", "4D", "4.5ND", "4.5D", "24wp-4ND", "24wp-4.5ND")
dat$Cond <- factor(dat$Cond, levels = cond.order)

## save to workbook
createSheet(wb, name = "AreaData.Full")
writeWorksheet(wb, data = dat, sheet = "AreaData.Full", header = TRUE, rownames = NULL)
saveWorkbook(wb)

## Calculate means
colnames(dat)[1] <- "variable"
colnames(dat)[5] <- "value"

means.dat <- aggregate(value ~ Cond+variable, mean, data = dat)
sd.dat <- aggregate(value ~ Cond+variable, sd, data = dat)
colnames(means.dat)[3] <- "Mean"
colnames(sd.dat)[3] <- "SD"
means.dat <- full_join(means.dat, sd.dat)

## Plot
tiff(filename = "C1C2_PercAreaData.tif", width = 16, height = 5, units = 'in', res = 300)
ggplot() +
        geom_boxplot(data = dat, aes(y = value, x = Cond, fill = Cond)) +
        scale_fill_brewer(palette = colour.order) +
        facet_grid(. ~ variable) +
        theme(axis.title.x = element_blank()) +
        ylab("% Area of Section") +
        geom_point(data = means.dat, aes(y = Mean, x = Cond), shape = 23, size = 2, fill = "darkred") +
        geom_text(data = means.dat, aes(x = Cond, label = round(Mean,1), y = Mean + 0.75), size = 3, colour = "darkred") 
dev.off()

tiff(filename = "C1C2PercArea_meanSD.tif", width = 16, height = 5, units = 'in', res = 300)
ggplot(data = means.dat) +
        facet_grid(. ~ variable) +
        geom_point(aes(y = Mean, x = Cond), shape = 23, size = 2, fill = "black") +
        geom_errorbar(aes(x= Cond, ymin = Mean-SD, ymax = Mean+SD), width = 0.1) +
        geom_text(aes(x = Cond, label = round(Mean,1), y = Mean + SD + 2), size = 3, colour = "darkred") +
        theme(axis.title.x = element_blank()) +
        ylab("% Area of Section")
dev.off()

createSheet(wb, name = "Total.MeanwSDs")
writeWorksheet(wb, data = means.dat, sheet = "Total.MeanwSDs", header = TRUE, rownames = NULL)
saveWorkbook(wb)

