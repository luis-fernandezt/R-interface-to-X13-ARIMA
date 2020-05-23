## **¿Las crisis son buenas para la economía?**
Este ejemplo, describe el proceso de desestacionalización del Índice de Ventas de Supermercados (Isup), mediante la metodología X13 ARIMA SEATS del Census Bureau de Estados Unidos; incorporando en el análisis el efecto calendario chileno, aislando eventos de naturaleza no económia como el terremoto del año 2010, el efecto de la crisis social y la llegada del coronavirus; según la metodología que elabora el Instituto Nacional de Estadísticas de Chile. Para más información revizar [Metodología X13 ARIMA SEATS para el efecto calendario](https://www.ine.cl/inicio/documentos-de-trabajo/documento/desestacionalizaci%C3%B3n-del-%C3%ADndice-de-actividad-del-comercio-al-por-menor-(iacm)-metodolog%C3%ADa-x13-arima-seats-para-el-efecto-calendario)

El procesos de ajuste estacional se realiza enteramente en RStudio, instalando el package Seasonal R-interface to X-13ARIMA-SEATS para este efecto, disponible en la web [http://www.seasonal.website/seasonal.html](http://www.seasonal.website/seasonal.html).

## **Principales Resultados**

### **Análisis Gráfico**

#### • **Factores Estacionales Mensuales**

![fig1](https://raw.githubusercontent.com/luis-fernandezt/R-interface-to-X13-ARIMA/master/Out/Seasonal%20Component%2C%20SI%20Ratio.png)


#### • **Test de Presencia de Estacionalidad**

F-tests for seasonality

**Test for the presence of seasonality assuming stability.**

|                |      Sum of Squares      | Degrees of   Freedom | Mean Square | F-value   |
|----------------|:------------------------:|:--------------------:|:-----------:|-----------|
| Between months |             14.209,3932  |          11          |   1.291,76  | 416,974** |
|    Residual    |               715,62473  |          231         | 3,098       |           |
|      Total     |           14.925,01797   |          242         |             |           |

Seasonality present at the 0.1 per cent level.

**Nonparametric Test for the Presence of Seasonality Assuming Stability**

| Kruskal-Wallis   statistic | Degrees of   Freedom | Probability level |
|:--------------------------:|:--------------------:|:-----------------:|
|          165,6180          |          11          |       0.000%      |

Seasonality present at the one percent level.

**Moving Seasonality Test**

|               | Sum of Squares | Degrees of   Freedom | Mean Square | F-value |
|---------------|:--------------:|:--------------------:|:-----------:|---------|
| Between Years |     39,9586    |          19          |    2,103    |  0,825  |
|     Error     |    533,02416   |          209         |   2,55000   |         |

No evidence of moving seasonality at the five percent level.

| COMBINED   TEST FOR THE PRESENCE OF IDENTIFIABLE SEASONALITY |
|--------------------------------------------------------------|
| IDENTIFIABLE SEASONALITY PRESENT                             |

Fuente: Elaboración propia.

#### • **Elección del Efecto Calendario**

Coefficients:

**Regression Model**

|                | Estimate | Std, Error |  z value |       Pr(>\|z\|)       |
|----------------|:--------:|:----------:|:--------:|:----------------------:|
| AO2010,feb     | -0,05183 | 0,01732    | -2,9920  |                0,0028  |
| AO2019,Nov     | -0,11105 | 0,01907    | -5,8230  |                0,0000  |
| AO2020,Mar     | 0,11698  | 0,02125    | 5,5060   |                0,0000  |
| Leap Year      | 0,03586  | 0,00811    | 4,4220   |                0,0000  |
| Lunes-Jueves   | -0,00723 | 0,00055    | -13,2190 |                0,0000  |
| Sábado-Domingo | 0,00964  |            |          |                        |
| Feriados       | 0,01140  | 0,00204    | 5,5920   |                0,0000  |

Fuente: Elaboración propia.

#### • **Elección del modelo SARIMA**

**Modelo ARIMA (0 1 2)(0 1 1)**

| Variable          | Estimate | Std, Error | z value |       Pr(>\|z\|)       |
|-------------------|:--------:|:----------:|:-------:|:----------------------:|
| MA-Nonseasonal-01 | 0,94475  | 0,06239    | 15,1440 |                0,0000  |
| MA-Nonseasonal-02 | -0,28583 | 0,06216    | -4,5980 |                0,0000  |
| MA-Seasonal-12    | 0,69211  | 0,05274    | 13,1230 |                0,0000  |

Fuente: Elaboración propia.

#### • **Serie desestacionalizada y sus componentes**

![fig2](https://raw.githubusercontent.com/luis-fernandezt/R-interface-to-X13-ARIMA/master/Out/Forecast%2C%20Original%20and%20Adjusted%20Series%20of%20Isup.png)


#### • **Prueba de bondad de ajuste**

Monitoring and Quality Assessment Statistics

|  M1 = | 0,259 |
|:-----:|:-----:|
|  M2 = | 0,115 |
|  M3 = | 0,930 |
|  M4 = | 0,790 |
|  M5 = | 0,500 |
|  M6 = | 0,397 |
|  M7 = | 0,107 |
|  M8 = | 0,208 |
|  M9 = | 0,100 |
| M10 = | 0,257 |
| M11 = | 0,237 |

**ACCEPTED** at the level 0,35

Q (without M2) = 0,38 **ACCEPTED**

Fuente: Elaboración propia.

#### **Versión de Rstudio:**

"R version 3.6.3 (2020-02-29)"
