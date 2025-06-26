# Desestacionalizaci�n del �ndice de Ventas de Supermercados (ISUP)

Este ejemplo describe el proceso de desestacionalizaci�n del �ndice de Ventas de Supermercados (ISUP), utilizando la metodolog�a **X13-ARIMA-SEATS** del *Census Bureau* de Estados Unidos. El an�lisis incorpora el efecto calendario chileno y permite aislar eventos de naturaleza no econ�mica, como:

- El terremoto de 2010  
- La crisis social de 2019  
- La llegada del COVID-19 en marzo de 2020  

Este trabajo sigue la metodolog�a publicada por el **Instituto Nacional de Estad�sticas de Chile (INE)**.  
Para m�s informaci�n, revisar la metodolog�a en:  
- [Metodolog�a X13-ARIMA-SEATS](https://www.seasonal.website/seasonal.html)
- [Metodología X13 ARIMA SEATS para el efecto calendario](https://www.ine.cl/inicio/documentos-de-trabajo/documento/desestacionalizaci%C3%B3n-del-%C3%ADndice-de-actividad-del-comercio-al-por-menor-(iacm)-metodolog%C3%ADa-x13-arima-seats-para-el-efecto-calendario).

## Implementaci�n en R

El ajuste estacional se realiza �ntegramente en **RStudio**, utilizando el paquete:

```r
# Instalaci�n del paquete
install.packages("seasonal")

# Carga del paquete
library(seasonal)
```
## Principales Resultados
### Factores Estacionales Mensuales
#### 1. An�lisis Gr�fico

![fig1](https://raw.githubusercontent.com/luis-fernandezt/R-interface-to-X13-ARIMA/master/Out/Seasonal%20Component%2C%20SI%20Ratio.png)  
>Fuente: Elaboraci�n propia.

### Test de Presencia de Estacionalidad
#### 1. Test Param�trico: F-Test

**Test for the presence of seasonality assuming stability.**

|                |      Sum of Squares      | Degrees of   Freedom | Mean Square | F-value   |
|----------------|:------------------------:|:--------------------:|:-----------:|-----------|
| Between months |             14.209,3932  |          11          |   1.291,76  | 416,974** |
|    Residual    |               715,62473  |          231         | 3,098       |           |
|      Total     |           14.925,01797   |          242         |             |           |

> **Conclusi�n:** Estacionalidad presente al nivel del **0.1%**

#### 2. Test No Param�trico: Kruskal-Wallis

**Nonparametric Test for the Presence of Seasonality Assuming Stability**

| Kruskal-Wallis   statistic | Degrees of   Freedom | Probability level |
|:--------------------------:|:--------------------:|:-----------------:|
|          165,6180          |          11          |       0.000%      |

> **Conclusi�n:** Estacionalidad presente al nivel del **1%**

#### 3. Test de Estacionalidad M�vil

**Moving Seasonality Test**

|               | Sum of Squares | Degrees of   Freedom | Mean Square | F-value |
|---------------|:--------------:|:--------------------:|:-----------:|---------|
| Between Years |     39,9586    |          19          |    2,103    |  0,825  |
|     Error     |    533,02416   |          209         |    2,550    |         |

> **Conclusi�n:** No hay evidencia de estacionalidad m�vil al nivel del **5%**

#### 4. Test Combinado

| COMBINED   TEST FOR THE PRESENCE OF IDENTIFIABLE SEASONALITY |
|--------------------------------------------------------------|
| IDENTIFIABLE SEASONALITY PRESENT                             |

> **Resultado:** Se detecta **estacionalidad identificable**.

## Efecto Calendario

Modelo de regresi�n estimado con variables de intervenci�n y calendario:

**Regression Model**

|                | Estimate | Std, Error |  z value |       Pr(>\|z\|)       |
|----------------|:--------:|:----------:|:--------:|:----------------------:|
| AO2010.feb     | -0,05183 | 0,01732    | -2,9920  |                0,0028  |
| AO2019.Nov     | -0,11105 | 0,01907    | -5,8230  |                0,0000  |
| AO2020.Mar     | 0,11698  | 0,02125    | 5,5060   |                0,0000  |
| Leap Year      | 0,03586  | 0,00811    | 4,4220   |                0,0000  |
| Lunes-Jueves   | -0,00723 | 0,00055    | -13,2190 |                0,0000  |
| S�bado-Domingo | 0,00964  |            |          |                        |
| Feriados       | 0,01140  | 0,00204    | 5,5920   |                0,0000  |

> **Nota:** Las variables AO (Additive Outlier) representan choques ex�genos por eventos no recurrentes.

## Modelo SARIMA Estimado

Se seleccion� un modelo **ARIMA (0, 1, 2)(0, 1, 1)** con estacionalidad anual.

| Variable          | Estimate | Std, Error | z value |       Pr(>\|z\|)       |
|-------------------|:--------:|:----------:|:-------:|:----------------------:|
| MA-Nonseasonal-01 | 0,94475  | 0,06239    | 15,1440 |                0,0000  |
| MA-Nonseasonal-02 | -0,28583 | 0,06216    | -4,5980 |                0,0000  |
| MA-Seasonal-12    | 0,69211  | 0,05274    | 13,1230 |                0,0000  |

> Fuente: Elaboraci�n propia.

### Serie desestacionalizada y sus componentes

![fig2](https://raw.githubusercontent.com/luis-fernandezt/R-interface-to-X13-ARIMA/master/Out/Forecast%2C%20Original%20and%20Adjusted%20Series%20of%20Isup.png)  
>Fuente: Elaboraci�n propia.

### Prueba de bondad de ajuste

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

**ACCEPTED**�at the level 0,35

Q (without M2) = 0,38�**ACCEPTED**

>Fuente: Elaboraci�n propia.
---

## An�lisis Interpretativo de Resultados

A partir de los resultados de los test y el modelo estimado, se pueden obtener las siguientes conclusiones adicionales:

### 1. Estacionalidad Clara y Estable
Los test F (param�trico) y Kruskal-Wallis (no param�trico) confirman con alta significancia estad�stica que existen diferencias mensuales sistem�ticas en las ventas de supermercados. Esto valida el uso de modelos que corrigen por estacionalidad. El test combinado tambi�n concluye que hay estacionalidad identificable.

### 2. Estacionalidad No M�vil
El test de estacionalidad m�vil no encuentra evidencia de que los patrones estacionales cambien con el tiempo. Esto significa que la estacionalidad puede tratarse como constante a lo largo del per�odo de an�lisis, lo que simplifica la modelaci�n.

### 3. Identificaci�n de Eventos Aislados (Outliers)
El modelo considera adecuadamente eventos no econ�micos como el terremoto de febrero de 2010, la crisis social de noviembre de 2019 y la llegada del COVID-19 en marzo de 2020. Estos eventos generan choques significativos en las ventas, por lo que su inclusi�n mejora la precisi�n del modelo y evita errores de interpretaci�n.

### 4. Influencia del Calendario
Variables como los d�as lunes a jueves, feriados y a�os bisiestos tienen un impacto estad�sticamente significativo en las ventas. Esto demuestra que los efectos del calendario influyen considerablemente en el comportamiento de la serie y deben ser corregidos.

### 5. Modelo ARIMA Estacional Adecuado
El modelo ARIMA (0,1,2)(0,1,1) seleccionado presenta coeficientes altamente significativos, lo que sugiere un buen ajuste a los datos. El modelo incorpora una diferenciaci�n estacional y captura de forma efectiva la din�mica de la serie.

### Conclusi�n General
El an�lisis demuestra que la serie del ISUP presenta estacionalidad clara, efectos calendario relevantes y choques externos puntuales que deben ser corregidos. El uso de la metodolog�a X13-ARIMA-SEATS es t�cnicamente adecuado y permite generar una serie desestacionalizada �til para an�lisis econ�micos, elaboraci�n de proyecciones y toma de decisiones informadas.