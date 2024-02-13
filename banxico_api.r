
library("siebanxicor")
library(ggplot2)
library(dplyr)
library(lubridate)

setToken("b4f43d25699386841f651eebd171f833274d6ea0f136b54d033e30579ac7c02c")

oneyear <- Sys.Date()-366
tenyear <- Sys.Date()-3660
twoyear <- Sys.Date()-366*2
idSeries <- c("SL11297")
series <- getSeriesData(idSeries)

str(tenyear)
df <- as.data.frame(series) %>%
    dplyr::filter(
        SL11297.date >= twoyear
    ) %>%
    mutate(
        year = year(SL11297.date)
    )

hora_creacion <- as.character(Sys.time())
lastDate<- max(df$SL11297.date)
g <- ggplot(df,aes(x=SL11297.date, y=SL11297.value)) +
    geom_point()+
    geom_line(aes(
        color=as.character(year)
    )) +
    labs(color="Año", y="Salario mínimo real en MXN", x= "Mes y año",
    title= "Salario mínimo real últimos dos años",
    subtitle="El salario es ajustado por la inflación mensual.") +
    scale_x_date(date_breaks = "2 months",date_labels = "%Y-%m") +
    theme(text=element_text(size=20,family = "Times"),
    axis.text.x = element_text(angle = 45, hjust = 1)) +
  annotate("text",x=lastDate, y = min(df$SL11297.value), hjust = 1, vjust = 0, 
           label = paste("Creado el ", Sys.time()), 
           color = "gray", size = 6)


png_name <- paste0("~/linkedin_api/plots/plot_", Sys.Date(),".png")

png(png_name, width=600)
g
dev.off()
