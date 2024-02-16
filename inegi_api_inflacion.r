library(httr)
library(jsonlite)
library(rjson)
library(ggplot2)
library(tidyr)
library(dplyr)
library("siebanxicor")
library(lubridate)
library(Cairo)

inegitoken <- Sys.getenv("INEGI_TOKEN")


#Llamado al API Inflacion mensual e inflacion mensual acumulada
url <-paste0("https://www.inegi.org.mx/app/api/indicadores/desarrolladores/jsonxml/INDICATOR/628201,628215/es/0700/false/BIE/2.0/", inegitoken, "?type=json")
respuesta<-GET(url)
cont <- content(respuesta,"parsed")
series <- cont$Series
data <- (series[[1]]$OBSERVATIONS)
data2 <- (series[[2]]$OBSERVATIONS)
length(data)
cont$Series[[2]]$INDICADOR
#Tasa de desocupación 444603 / (serie original)
df <- as.data.frame(matrix(data = c(cont$Series[[1]]$INDICADOR),nrow=length(data)))
for (i in 1:length(data2)){
  df$date[i] <- data2[[i]]$TIME_PERIOD
  df$value_inf[i] <- data[[i]]$OBS_VALUE
  df$V2 <- cont$Series[[2]]$INDICADOR
  df$date2[i] <- data2[[i]]$TIME_PERIOD
  df$value_infacu[i] <- data2[[i]]$OBS_VALUE
}
head(df)
oneyear <- Sys.Date() - 366
df <- df %>%
  mutate(
    date2 = ymd(paste0(date, "/01")),
    infacu = as.numeric(value_infacu)
  ) %>%
  filter(
    date2 >= oneyear
  )


hora_creacion <- as.character(Sys.time())
lastDate <- max(df$date2)

g <- ggplot(df, aes(x = date2, y = infacu / 100)) +
  geom_point(aes(
     color=as.character(year(date2))
  )) +
  geom_line(aes(
     color=as.character(year(date2))
  )) +
  labs(color="Año", y="Inflacion mensual acumulada %", x = "Año y mes",
       title= "Inflación mensual acumulada del año en México",
       subtitle="Fuente: API Banco de Información Económica, INEGI.") +
  scale_x_date(date_breaks = "1 months",date_labels = "%Y-%m") +
  theme(text=element_text(size=16,family = "Times"),
        axis.text.x = element_text(angle = 45, hjust = 1))  +
  scale_y_continuous(labels = scales::percent_format(accuracy = .1),  n.breaks=10) +
  annotate("text",x=lastDate, y = min(df$infacu)/100, hjust = 1, vjust = 0, 
           label = paste("Creado el ", Sys.time()), 
           color = "gray", size = 6)

png_name <- paste0("~/raspberry_pi_linkedin_api/plots/plot_", Sys.Date(),".png")

CairoPNG(png_name, width=600)
g
dev.off()
