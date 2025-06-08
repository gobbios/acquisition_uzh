xdata <- read.csv("aquisition.csv")
head(xdata)
tail(xdata)

colnames(xdata) <- c("age", "voc_size", "cds", "ads", "tv")
plot(xdata$age, xdata$voc_size, type = "l")
prob <- which(xdata$age > 400 & xdata$voc_size == 0)
xdata$voc_size[prob] <- xdata$voc_size[prob - 1]

# sanity checks
if (any(diff(xdata$voc_size) < 0)) stop()
if (any(diff(xdata$age) < 0)) stop()
if (any(diff(xdata$age) != 1)) stop()

hist(xdata$cds)
sum(xdata$cds == 0) # really???

hist(xdata$ads)
sum(xdata$ads == 0) # really???

hist(xdata$tv)
sum(xdata$tv > 500) # really???

# for now: remove cases and investigate reasons
xdata <- xdata[xdata$cds > 0 & xdata$ads > 0 & xdata$tv < 500, ]
# age more natural in months
xdata$agem <- xdata$age / 365.25 * 12
# and shift to start at age 0
xdata$agem <- xdata$agem - min(xdata$agem)

plot(xdata$agem, xdata$voc_size, type = "l")

mean(diff(xdata$voc_size))
