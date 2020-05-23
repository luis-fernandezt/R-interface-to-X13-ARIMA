# Ajuste estacional serie ISUP
# Separata de desestacionalización de series coyunturales de sectores económicos (PDF, 161.86 KB)
download.file("http://www.ine.cl/docs/default-source/ventas-de-supermercados/comites-y-notas-tecnicas/base-promedio-ano-2014-100/separata-de-desestacionalizaci%C3%B3n-de-series-coyunturales-de-sectores-econ%C3%B3micos.pdf?sfvrsn=8c8579f6_4", "Separata-técnica-ajuste-estacional-ISUP.pdf", mode="wb")

# Serie mensual empalmada, desestacionalizada y tendencia - ciclo desde 1991 hasta la fecha (XLS, 106.50 KB)
download.file("http://www.ine.cl/docs/default-source/ventas-de-supermercados/cuadros-estadisticos/base-promedio-a%C3%B1o-2014-100/serie-mensual-empalmada-desestacionalizada-y-tendencia-ciclo-desde-1991-hasta-la-fecha.xls?sfvrsn=a4f5a9d6_26", "serie-mensual-empalmada-desestacionalizada-y-tendencia-ciclo-desde-1991-hasta-la-fecha.xls", mode="wb")

# librerias
library(readxl)
library(seasonal)

# cargar serie de tiempo isup año 
Isup <- read_excel("./Data/serie-mensual-empalmada-desestacionalizada-y-tendencia-ciclo-desde-1991-hasta-la-fecha.xls", 
                   range = "C114:C357")

names(Isup) <- c("Isup")
Isup <- as.data.frame(Isup)
Isup = ts(Isup, start = c(2000,1), frequency = 12) # transformar df en ts

# cargar modelo calendario semana completa
# Elaboración propia, según apartado 3.1.2 Efecto calendario, del "documento-de-trabajo-metodológico-ajuste-estacional-iacm.pdf"
Sem_Fer <- read_excel("./Data/Sem_Fer4.xlsx", range = "B1:C265") # semana 4/3
Sem_Fer <- as.data.frame(Sem_Fer)
Sem_Fer <-  ts(Sem_Fer, start = c(2000,1), frequency = 12)

# Análisis gráfico
plot(Isup)
monthplot(Isup, choice = "seasonal", cex.axis = 0.8)

# Seas modo automático
ajuste <- seas(Isup)
ajuste
summary(ajuste)
fivebestmdl(ajuste)
# arima    bic
# (0 1 2)(0 1 1) -5.403
# (2 1 0)(0 1 1) -5.400 <-  modelo Sarima recomendado
# (1 1 1)(0 1 1) -5.399
# (0 1 1)(0 1 1) -5.390
# (2 1 1)(0 1 1) -5.381

# Ajuste estacional Isup
IsupSeas <- 
  seas(x = Isup, 
       series.span = ",2020.3",
       series.decimals = 5,
       series.precision = 5,
       series.modelspan = "2000.1, 2020.3",
       
       check.print = "all",
       
       spectrum.type = "periodogram",
       spectrum.print = "all",
       spectrum.savelog = "peaks",
       
       transform.function = "log",
       regression.aictest = NULL,
       automdl = NULL,
       
       arima.model = "(2 1 0)(0 1 1)",
       
       regression.variables = c("ao2010.feb", "AO2019.Nov", "AO2020.Mar", "lpyear"),
       regression.savelog = "aictest",
       xreg = Sem_Fer, 
       regression.usertype = "holiday",
       
       identify.diff = c(0, 1),
       identify.sdiff = c(0, 1),
       identify.maxlag = 36,
       identify.print = c("+acfplot", "+pacfplot"),
       
       forecast.maxlead = 12,
       forecast.probability = 0.95,
       forecast.save = c("variances", "fct"),
       
       estimate.exact = "arma",
       estimate.outofsample = "no",
       estimate.savelog = c("aicc", "aic", "bic", "hq", "afc"),
       estimate.save = c("mdl", "est", "rsd"),
       
       x11.mode = "mult",
       x11.seasonalma = "s3x5",
       x11.trendma = 13)

# F2.H:
# The final I/C Ratio from Table D12: 3.77
# The final I/S Ratio from Table D10: 4.89

# I/C
# Si I/C es inferior a 1,0, conviene adoptar una media móvil de Henderson de 9 términos.
# Si I/C se sitúa entre 1,0 y 3,5, se recomienda adoptar una media móvil de Henderson de 13 términos.
# Si I/C es superior 3,5, se recomienda adoptar una media móvil de Henderson de 23 términos.

# I/S
# Si MSR es inferior a 1,5, conviene adoptar una media móvil estacional 3.
# Si MSR se sitúa entre 1,5 y 2,5, se recomienda adoptar una media móvil estacional 3x3.
# Si MSR se sitúa entre 2,5 y 5, se recomienda adoptar una media móvil estacional 3x5.
# Si MSR se sitúa entre 5 y 7, se recomienda adoptar una media móvil estacional 3x9.
# Si MSR es superior a 7, el componente estacional es fijado de acuerdo con el valor promedio de la serie sin tendencia-ciclo.

# resumen ajuste
# Donde xreg1 = lun-juev, xreg2 = feriado.
IsupSeas
summary(IsupSeas)
fivebestmdl(IsupSeas)
out(IsupSeas)
#view(IsupSeas) #recomendado

#calendario 
#Coefficients:         Estimate  Std. Error   z value  Pr(>|z|)    
#  AO2010.feb        -0.0561000  0.0144032  -3.895     9.82e-05 ***
#  AO2019.Nov        -0.1329626  0.0159863  -8.317     2e-16 ***
#  AO2020.Mar         0.1351629  0.0200578   6.739     1.60e-11 ***
#  Leap Year          0.0295496  0.0069396   4.258     2.06e-05 ***
#  xreg1             -0.0037454  0.0006174  -6.066     1.31e-09 ***
#  xreg2              0.0098629  0.0017031   5.791     7.00e-09 ***
#  AR-Nonseasonal-01 -1.0464050  0.0459566 -22.769     2e-16 ***
#  AR-Nonseasonal-02 -0.7161415  0.0456221 -15.697     2e-16 ***
#  MA-Seasonal-12     0.6376575  0.0545975  11.679     2e-16 ***

# OUT
# spectrum series
b1 <-  series(IsupSeas, "series.adjoriginal") #serie original
d10 <- series(IsupSeas, "x11.seasonal") #estacional
d11 <- series(IsupSeas, "x11.seasadj") #ajustada estacionalmente
d12 <- series(IsupSeas, "x11.trend") #tendencia-ciclo
d13 <- series(IsupSeas, "x11.irregular") #irregular
e11 <- series(IsupSeas, "x11.robustsa") #final estacionalmente robusta
fct <- series(IsupSeas, "forecast.forecasts") #forecast
rsd <- series(IsupSeas, "estimate.residuals") #residuos

# residuos
plot(density(rsd))
hist(rsd)
qqnorm(rsd)
acf(rsd)
pacf(rsd)

par(mfrow = c(3,1))
# estacional
ts.plot(d10, gpars= list(col='darkred'), lwd = 1.8) 
title("Estacional")

# tendencia-ciclo
ts.plot(d12, gpars= list(col='darkblue', lwd = 1.8))
title("Tendencia-ciclo")

# irregular
ts.plot(d13, gpars= list(col='orange', lwd = 1.8))
title("Irregular")

par(mfrow = c(1,1))
# Seasonal Component, SI Ratio
monthplot(IsupSeas, col.base = 1)  
legend("topleft", legend = c("Irregular", "Seasonal", "Seasonal Average"), 
       col = c(4,2,1), lwd = c(1,2,2), lty = 1, bty = "n", cex = 0.6)

par(mfrow = c(1,1))
#Isup original ajustado y serie ajustada estacionalmente
plot(IsupSeas)
grid() 
legend("topleft", legend = c("Original", "Adjusted"), 
       col = c(1,2), lwd = c(1,2), lty = 1, bty = "n", cex = 0.6)

# Isup serie original, forecast y ajustada estacionalmente
# *series ajustadas difieren levemente de las oficiales*
isup.2010.ene = ts(tail(Isup,123), start = c(2010,1), frequency = 12) 
d11.2010.ene = ts(tail(d11,123), start = c(2010,1), frequency = 12)

ts.plot(isup.2010.ene, d11.2010.ene, fct,
        gpars= list(col = c(1,2,1,4,4), lwd = c(1,2,2,1,1),
                    xlab="Meses", 
                    ylab="ISUP",
                    lty = c(1,1,1,2,2)))

title("Forecast, Original and Adjusted Series of Isup")
grid()
legend("topleft", legend = c("Original", "Seasonal", "Forecast", "CI 95%"), 
       col = c(1,2,1,4,4), lwd = c(1,2,2,1), lty = c(1,1,1,2,2), bty = "n", cex = 0.8)


