# Introduction to Seasonal ####
# seasonal is an easy-to-use and full-featured R-interface to X-13ARIMA-SEATS, 
# the newest seasonal adjustment software developed by the United States Census Bureau. 
# X-13ARIMA-SEATS combines and extends the capabilities of the older X-12ARIMA 
# (developed by the Census Bureau) and TRAMO-SEATS (developed by the Bank of Spain).

# web page: http://www.seasonal.website/seasonal.html  

# Installation ####
install.packages("seasonal")  
install.packages("seasonal", type = "source") 
install.packages("seasonalview")
library(seasonal)

# Getting started ####
m <- seas(AirPassengers) #X13
seas(AirPassengers, x11 = "") #(optional with X11)
final(m)
plot(m)
summary(m)

# Alternatively, all inputs may be entered manually
?seas
seas(x = AirPassengers, 
     regression.variables = c("td1coef", "easter[1]", "ao1951.May"), 
     arima.model = "(0 1 1)(0 1 1)", 
     regression.aictest = NULL,
     outlier = NULL, 
     transform.function = "log")

# The static command returns the manual call of a model
static(m)
static(m, coef = TRUE)  # also fixes the coefficients
inspect(m)
view(m) #easy way to analyze and modify a seasonal adjustment procedure

# Input ####
m <- seas(AirPassengers, regression.variables = c("td", "ao1955.jan"))

# Examples SPC to R ####
# http://www.seasonal.website/examples.html
# Example 1
seas(AirPassengers,
     x11 = "",
     arima.model = "(0 1 1)"
)

# Example 2
seas(AirPassengers,
     x11 = "",
     arima.model = c(0, 1, 1)
)

# Example 3
seas(AirPassengers,
     x11 = "",
     transform.function = "log",
     arima.model = "(2 1 0)(0 1 1)"
)

# Example 4
seas(AirPassengers,
     x11 = "",
     transform.function = "log",
     regression.variables = c("seasonal", "const"),
     arima.model = "(0 1 1)"
)

# Example 5
seas(AirPassengers,
     x11 = "",
     arima.model = "([2] 1 0)"
)

# Example 6
seas(AirPassengers,
     x11 = "",
     transform.function = "log",
     regression.variables = c("const"),
     arima.model = "(0 1 1)12"
)

# Example 7
seas(AirPassengers,
     x11 = "",
     transform.function = "log",
     arima.model = "(0 1 1)(0 1 1)12",
     arima.ma = " , 1.0f"
)

seas(list = list(x = AirPassengers, x11 = "")) #with x11

#Output ####
m <- seas(AirPassengers)
series(m, "forecast.forecasts")
series(m, c("forecast.forecasts", "d1"))

m <- seas(AirPassengers, forecast.save = "forecasts")
series(m, "forecast.forecasts")

m <- seas(AirPassengers)
series(m, "history.saestimates")
series(m, "slidingspans.sfspans")

m <- seas(AirPassengers)
out(m) #the out function shows the content of the main output in the browser *

# Graphs ####

m <- seas(AirPassengers, regression.aictest = c("td", "easter"))
plot(m)
plot(m, trend = TRUE)

monthplot(m)
monthplot(m, choice = "irregular")

pacf(resid(m))
spectrum(diff(resid(m)))
plot(density(resid(m)))
qqnorm(resid(m))

identify(m) #manual  outlier types in the plot

# Inspect (Shiny) ####
install.packages("shiny")
library(shiny)
inspect(m)
view(m)

# Chinese New Year, Indian Diwali and other customized holidays ####

# variables included in seasonal
# iip: Indian industrial production
# cny, diwali, easter: dates of Chinese New Year, Indian Diwali and Easter
?genhol
diwa <- seas(iip, 
             x11 = "",
             xreg = genhol(diwali, start = 0, end = 0, center = "calendar"), 
             regression.usertype = "holiday"
)

view(diwa)

# Production use ####
#Storing calls and batch processing

# two different models for two different time series
m1 <- seas(fdeaths, x11 = "")
m2 <- seas(mdeaths, x11 = "")

l <- list()
l$c1 <- static(m1)  # static call (with automated procedures substituted)
l$c2 <- m2$call     # original call

ll <- lapply(l, eval)

do.call(cbind, lapply(ll, final))
do.call(cbind, lapply(ll, series, "d10"))

#Automated adjustment of multiple series

# collect data 
dta <- list(fdeaths = fdeaths, mdeaths = mdeaths)

# loop over dta
ll <- lapply(dta, function(e) try(seas(e, x11 = "")))

# list failing models
is.err <- sapply(ll, class) == "try-error"
ll[is.err]

# return final series of successful evaluations
do.call(cbind, lapply(ll[!is.err], final))

# a list with 100 time series
largedta <- rep(list(AirPassengers), 100)

library(parallel)  # this is part of a standard R installation

# If you are on Windows or want to use cluster parallelization, use parLapply:

# set up cluster
cl <- makeCluster(detectCores())

# load 'seasonal' for each node
clusterEvalQ(cl, library(seasonal))

# export data to each node
clusterExport(cl, varlist = "largedta")

# run in parallel (2.2s on a 8-core Macbook, vs 9.6s with standard lapply)
parLapply(cl, largedta, function(e) try(seas(e, x11 = "")))

# finally, stop the cluster
stopCluster(cl)

# Import X-13 models and series ####
# importing the orginal X-13 example file
?import.ts
import.spc(system.file("tests", "Testairline.spc", package="seasonal"))

# Examples http://www.seasonal.website/examples.html

# License and Credits
# seasonal is free and open source, licensed under GPL-3. It requires the X -13ARIMA-SEATS software by 
# the U.S. Census Bureau, which is open source and freely available under the terms of its own license.

# seasonal has been originally developed for the use at the Swiss State Secretariat of Economic Affairs. 
# It has been greatly improved over time thanks to suggestions and support from Matthias Bannert, 
# Freya Beamish, Vidur Dhanda, Alain Galli, Ronald Indergand, Preetha Kalambaden, Stefan Leist, James Livsey, 
# Brian Monsell, Pinaki Mukherjee, Bruno Parnisari, and many others. 
# I am especially grateful to Dirk Eddelbuettel for the fantastic work on the x13binary package.

# Please report bugs and suggestions on Github. Thank you!