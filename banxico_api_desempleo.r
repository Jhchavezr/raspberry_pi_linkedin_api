
library("siebanxicor")
library(ggplot2)
library(dplyr)
library(lubridate)
library(tidyr)
Sys.setenv(LANG = "es")

setToken("b4f43d25699386841f651eebd171f833274d6ea0f136b54d033e30579ac7c02c")

oneyear <- Sys.Date()-366
tenyear <- Sys.Date()-3660
twoyear <- Sys.Date()-366*2

idSeries <- c("SP30579", "SR17044", "SR17043","SR17042")
# Id Serie	SP30579
# Título serie	Índice Nacional de Precios al consumidor Variación acumulada
# Periodicidad	Mensual # Cifra	Porcentajes
# Unidad	Sin Unidad # URL	https://www.banxico.org.mx/SieAPIRest/service/v1/series/SP30579

# Id Serie	# SR17044
# Título serie	Indicadores Nacionales de Actividad Económica Sector Manufacturero Número de Trabajadores (Mes actual Vs. Mes anterior) 
# Aumentó
# Periodicidad	Mensual # Cifra	Porcentajes
# Unidad	Porcentajes # URL	https://www.banxico.org.mx/SieAPIRest/service/v1/series/SR17044
# Id Serie	# SR17042
# Título serie	Indicadores Nacionales de Actividad Económica Sector Manufacturero Número de Trabajadores (Mes actual Vs. Mes anterior)
# Disminuyó
# Periodicidad	Mensual # Cifra	Porcentajes
# Unidad	Porcentajes # URL	https://www.banxico.org.mx/SieAPIRest/service/v1/series/SR17042

series <- getSeriesData(idSeries,startDate = twoyear,endDate = Sys.Date())

df <- as.data.frame(series) %>%
    dplyr::mutate(
        year = year(SR17044.date),
        month = factor(month(SR17044.date),labels = c("Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"),ordered = T),
        date = as.Date(SR17044.date),
        aumento = SR17044.value,
        disminuyo = SR17042.value,
        sincambio = SR17043.value
    ) %>%
  filter(
    date >= oneyear
  ) %>%
  dplyr::select(
    year,
    date,
    aumento,
    # disminuyo,
    month
    # sincambio
    ) 

  # pivot_longer(names_to="category",cols = c("aumento","disminuyo"),values_to = "porcentaje")
  
df

hora_creacion <- as.character(Sys.time())

lastDate<- max(df$date)
g <- ggplot(df,aes(x=date, 
                   y=aumento
                   )) +
  geom_point(aes(color=as.character(year)))  + 
  geom_line() +
    labs(color="Año", y="% de empresas", x= "Mes",
    title= "Porcentaje de empresas manufactureras que incrementaron su personal",
    subtitle="Fuente: API BANXICO.") +
    scale_x_date(date_breaks = "1 months",date_labels = "%Y-%m") +
    theme(text=element_text(size=20,family = "Times"),
    axis.text.x = element_text(angle = 45, hjust = 1))  +
  annotate("text",x=lastDate, y = 0, hjust = 1, vjust = 0, 
           label = paste("Creado el ", Sys.time()), 
           color = "gray", size = 6)

g
png_name <- paste0("~/linkedin_api/plots/plot_", Sys.Date(),".png")

png(png_name, width=600)
g
dev.off()
