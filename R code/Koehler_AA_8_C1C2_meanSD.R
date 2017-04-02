## Plot C1xC2 data as mean + SD to complement box plots

setwd("C:/Users/Stephanie/Documents/My Documents/PhD/Koehler/200317/current/Data")

wb <- loadWorkbook(list.files(pattern = 'KoehlerC1C2Data'))
if(length(getSheets(wb)) == 1) {
        assign(getSheets(wb), readWorksheet(wb, sheet = getSheets(wb)))
} else { 
        lst <- readWorksheet(wb, sheet = getSheets(wb))
        list2env(lst, envir = .GlobalEnv)
}

dat <- PercAreaLong

means.dat <- aggregate(value ~ Cond+variable, mean, data = dat)
sd.dat <- aggregate(value ~ Cond+variable, sd, data = dat)
colnames(means.dat)[3] <- "Mean"
colnames(sd.dat)[3] <- "SD"
PAL.dat <- full_join(means.dat, sd.dat)

cond.order <- c("4ND", "4D", "4.5ND", "4.5D", "24wp-4ND", "24wp-4.5ND")
PAL.dat$Cond <- factor(PAL.dat$Cond, levels = cond.order)
MinS.sd.dat <- PAL.dat[PAL.dat$variable == "Myo7ainSox2", ] 
SinM.sd.dat <- PAL.dat[PAL.dat$variable == "Sox2inMyo7a", ] 

tiff(filename = "C1C2meanSD_Myo7a.tif", width = 8, height = 5, units = 'in', res = 300)
ggplot(data = MinS.sd.dat) +
        geom_point(aes(y = Mean, x = Cond), shape = 23, size = 2, fill = "black") +
        geom_errorbar(aes(x= Cond, ymin = Mean-SD, ymax = Mean+SD), width = 0.1) +
        geom_text(aes(x = Cond, label = round(Mean,1), y = Mean + SD + 2), size = 3, colour = "darkred") +
        theme(axis.title.x = element_blank()) +
        ylab("Myo7a in Sox2 (%)")
dev.off()

tiff(filename = "C1C2meanSD_Sox2.tif", width = 8, height = 5, units = 'in', res = 300)
ggplot(data = SinM.sd.dat) +
        geom_point(aes(y = Mean, x = Cond), shape = 23, size = 2, fill = "black") +
        geom_errorbar(aes(x= Cond, ymin = Mean-SD, ymax = Mean+SD), width = 0.1) +
        geom_text(aes(x = Cond, label = round(Mean,1), y = Mean + SD + 2), size = 3, colour = "darkred") +
        theme(axis.title.x = element_blank()) +
        ylab("Sox2 in Myo7a (%)")
dev.off()

createSheet(wb, name = "X.MeanwSDs")
writeWorksheet(wb, data = PAL.dat, sheet = "X.MeanwSDs", header = TRUE, rownames = NULL)
saveWorkbook(wb)
