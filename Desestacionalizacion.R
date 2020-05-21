# Ajuste estacional serie ISUP
# Separata de desestacionalización de series coyunturales de sectores económicos (PDF, 161.86 KB)
download.file("http://www.ine.cl/docs/default-source/ventas-de-supermercados/comites-y-notas-tecnicas/base-promedio-ano-2014-100/separata-de-desestacionalizaci%C3%B3n-de-series-coyunturales-de-sectores-econ%C3%B3micos.pdf?sfvrsn=8c8579f6_4", "Separata-técnica-ajuste-estacional-ISUP.pdf", mode="wb")

# Serie mensual empalmada, desestacionalizada y tendencia - ciclo desde 1991 hasta la fecha (XLS, 106.50 KB)
download.file("http://www.ine.cl/docs/default-source/ventas-de-supermercados/cuadros-estadisticos/base-promedio-a%C3%B1o-2014-100/serie-mensual-empalmada-desestacionalizada-y-tendencia-ciclo-desde-1991-hasta-la-fecha.xls?sfvrsn=a4f5a9d6_26", "serie-mensual-empalmada-desestacionalizada-y-tendencia-ciclo-desde-1991-hasta-la-fecha.xls", mode="wb")

# librerias
library(readxl)
library(seasonal)

# cargar serie de tiempo isup
Isup <- read_excel("serie-mensual-empalmada-desestacionalizada-y-tendencia-ciclo-desde-1991-hasta-la-fecha.xls", 
                   range = "C6:C357")

names(Isup) <- c("Isup")
Isup <- as.data.frame(Isup)
Isup = ts(Isup, start = c(1991,1), frequency = 12) # transformar df en ts

# cargar modelo calendario semana completa
# Elaboración propia, según apartado 3.1.2 Efecto calendario, del "documento-de-trabajo-metodológico-ajuste-estacional-iacm.pdf"
Sem_Fer <- read_excel("Sem_Fer.xls", range = "B1:H493")
Sem_Fer <- as.data.frame(Sem_Fer)
Sem_Fer <-  ts(Sem_Fer, start = c(1985,1), frequency = 12)

# Análisis gráfico
plot(Isup)
monthplot(Isup, choice = "seasonal", cex.axis = 0.8)

# Seas modo automático
ajuste <- seas(Isup)
ajuste
summary(ajuste)
fivebestmdl(ajuste)

#  arima    bic
# (2 1 0)(0 1 1) -5.188 <- elegir por recomendacion separata técnica
# (0 1 1)(0 1 1) -5.185
# (0 1 2)(0 1 1) -5.182
# (1 1 1)(0 1 1) -5.180
# (2 1 1)(0 1 1) -5.172

# Ajuste estacional Isup
IsupSeas <- 
  seas(x = Isup, 
       series.span = ",2020.3",
       series.decimals = 5,
       series.precision = 5,
       series.modelspan = "1991.1,2020.3",
       
       check.print = "all",
       
       spectrum.type = "periodogram",
       spectrum.print = "all",
       spectrum.savelog = "peaks",
       
       transform.function = "log",
       regression.aictest = NULL,
       automdl = NULL,
       
       arima.model = "(0 1 1)(1 1 1)",
       
       regression.variables = c("ao2010.feb", "ao2010.mar", "AO2019.Nov", "AO2020.Mar", "lpyear"),
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
# The final I/C Ratio from Table D12: 1.96
# The final I/S Ratio from Table D10: 3.62

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
# Donde xreg1 = Lunes, xreg2 = martes,... xreg6 = sabado, xreg7 = feriado.
IsupSeas
summary(IsupSeas)
fivebestmdl(IsupSeas)

# arima    bic
# (0 1 1)(1 1 1) -4.779 <- este modelo SARIMA se ajusta mejor
# (1 1 1)(1 1 1) -4.774
# (0 1 2)(1 1 1) -4.774
# (2 1 0)(1 1 1) -4.774
# (2 1 1)(1 1 1) -4.760

# todas las salidas en html y vista en Shiny*
out(IsupSeas)
view(IsupSeas) #recomendado

par(mfrow = c(1,1))
# estacional
ts.plot(d10,
        gpars= list(col='darkred'),
        lwd = 1.8)
title("Estacional")

# tendencia-ciclo
ts.plot(d12,
        gpars= list(col='darkblue',
                    lwd = 1.8))
title("Tendencia-ciclo")

# irregular
ts.plot(d13,
        gpars= list(col='orange',
                    lwd = 1.8))
title("Irregular")

# Seasonal Component, SI Ratio
monthplot(IsupSeas, col.base = 1)  
legend("topleft", legend = c("Irregular", "Seasonal", "Seasonal Average"), 
       col = c(4,2,1), lwd = c(1,2,2), lty = 1, bty = "n", cex = 0.6)

#Isup original y ajustado estacionalmente
plot(IsupSeas)
grid() 
legend("topleft", legend = c("Original", "Adjusted"), 
       col = c(1,2), lwd = c(1,2), lty = 1, bty = "n", cex = 0.6)
