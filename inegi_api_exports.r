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


#Llamado al API consumo nacional e importado indice 2018 variación anual.
url <-paste0("https://www.inegi.org.mx/app/api/indicadores/desarrolladores/jsonxml/INDICATOR/740994,741015/es/0700/false/BIE/2.0/", inegitoken, "?type=json")
respuesta<-GET(url)
cont <- content(respuesta,"parsed")
series <- cont$Series
data <- (series[[1]]$OBSERVATIONS)
data2 <- (series[[2]]$OBSERVATIONS)
length(data)
cont$Series[[2]]$INDICADOR

df <- as.data.frame(matrix(data = c(cont$Series[[1]]$INDICADOR),nrow=length(data)))
for (i in 1:length(data2)){
  df$date[i] <- data2[[i]]$TIME_PERIOD
  df$value_nac[i] <- data[[i]]$OBS_VALUE
  df$V2 <- cont$Series[[2]]$INDICADOR
  df$date2[i] <- data2[[i]]$TIME_PERIOD
  df$value_imp[i] <- data2[[i]]$OBS_VALUE
}
tail(df)
tenyear <- Sys.Date() - 3660/2
df <- df %>%
  mutate(
    date2 = ymd(paste0(date, "/01")),
    value_nac = as.numeric(value_nac),
    value_imp = as.numeric(value_imp)
  ) %>%
  filter(
    date2 >= tenyear
  )


hora_creacion <- as.character(Sys.time())
lastDate <- max(df$date2)

g <- ggplot(df, aes(x = date2)) +
  geom_line(aes(y = value_nac
     #color=as.character(year(date2))
  ),
  color = "blue") +
  geom_line(aes(
    y = value_imp
     #color=as.character(year(date2))
  ), color = "red" ) +
  labs(color="Consumo", y="Índice de consumo (2018 = 100)", x = "Año y mes",
       title= "Incremento del consumo de bienes nacionales e importados",
       subtitle="Fuente: API Banco de Información Económica, INEGI.") +
  scale_x_date(date_breaks = "3 months",date_labels = "%Y-%m") +
  theme(text=element_text(size=16,family = "Times"),
        axis.text.x = element_text(angle = 45, hjust = 1))  +
  scale_y_continuous(n.breaks=15) +
  annotate("text",x=lastDate, y = min(df$value_imp), hjust = 1, vjust = 0, 
           label = paste("Creado el ", Sys.time()), 
           color = "gray", size = 6)
g
png_name <- paste0("~/raspberry_pi_linkedin_api/plots/plot_", Sys.Date(),".png")

CairoPNG(png_name, width=600)
g
dev.off()
