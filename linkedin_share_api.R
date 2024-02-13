library(httr)
library(tidyverse)
library(jsonlite)
library(dplyr)
library(ggplot2)
library(curl)
# Consulta API INEGI
# 702094 Indicador de Personal Ocupado Índice global de personal ocupado de los sectores económicos. Total de los sectores económicos (construcción, industrias manufactureras, comercio al por mayor, comercio al por menor y servicios privados no financieros). Índice (Índice Base 2018 = 100)
url_inegi <- "https://www.inegi.org.mx/app/api/indicadores/desarrolladores/jsonxml/INDICATOR/702094/es/00/false/BISE/2.0/e1f7dd06-09d5-7e19-1a9b-3f9fcf206088?type=json"
response <- GET(url_inegi)
cont <- content(response,"parsed")
response
series <- cont$Series
data <- (series[[1]]$OBSERVATIONS)
length(data)
df <- as.data.frame(matrix(nrow=length(data)))
for (i in 1:length(data)){
  df$date[i] <- data[[i]]$TIME_PERIOD
  df$value_ocup[i] <- data[[i]]$OBS_VALUE
}
head(df)
#702102,Índice global de remuneraciones medias reales de los sectores económicos. Total de los sectores económicos (construcción, industrias manufactureras, comercio al por mayor, comercio al por menor y servicios privados no financieros). Índice (Índice Base 2018 = 100)
url_inegi <- "https://www.inegi.org.mx/app/api/indicadores/desarrolladores/jsonxml/INDICATOR/702102/es/0700/false/BISE/2.0/e1f7dd06-09d5-7e19-1a9b-3f9fcf206088?type=json"
response <- GET(url_inegi)
cont <- content(response,"parsed")
response
series <- cont$Series
data <- (series[[1]]$OBSERVATIONS)
data
df_remu <- as.data.frame(matrix(nrow=length(data)))
for (i in 1:length(data)){
  df_remu$date[i] <- data[[i]]$TIME_PERIOD
  df_remu$value_remun[i] <- data[[i]]$OBS_VALUE
}
head(df_remu)

df_graphs <- full_join(df, df_remu,by = "date") %>%
  select(
    date,
    value_remun,
    value_ocup
  ) %>%
  mutate(
    value_remun = as.numeric(value_remun),
    value_ocup = as.numeric(value_ocup),
    date2 = as.Date(paste(.$date, "01", sep = "/"), format = "%Y/%m/%d")
  ) %>%
  filter(
    date2 >= Sys.Date()-months(16)
  ) %>%
  pivot_longer(cols = c(value_remun,value_ocup),names_to="var", values_to="val")
head(df_graphs)
df_graphs
# 496150,Total (Índice base 2013=100) Banco de Indicadores > Economía y Sectores Productivos > PIB y Cuentas Nacionales > Indicadores macroeconómicos nacionales > Indicador Global de la Actividad Económica
# 539260 Indicadores económicos de coyuntura. Unidad de medida y actualización (UMA). Diario. (Pesos) Banco de Indicadores > Economía y Sectores Productivos > Precios > Unidad de Medida y Actualización (UMA)

## GRAFICA

g <- ggplot(df_graphs, aes(x=date2,
                           y=val,
                           fill=var)) +
  geom_point(color="gray") +
  geom_area(data = subset(df_graphs, var == 'value_remun'), aes(color = var, fill = var), alpha = 0.3) +
  # ylim(min(df_graphs$val),max(df_graphs$val))
  geom_area(data = subset(df_graphs, var == 'value_ocup'), aes(color = var, fill = var), alpha = 0.5) +
# scale_fill_manual()+
  coord_cartesian(ylim = c(min(df_graphs$val), max(df_graphs$val))) +
  # scale_alpha_manual(values= c(1,0.3)) +
  scale_y_continuous(breaks = c(seq(from= min(df_graphs$val),
                                    to =max(df_graphs$val),
                                    length.out = 7
                                    ))) +
  scale_x_date(breaks = "months",date_breaks = "2 months",date_labels = "%Y-%m",name = "Mes y año") +
  labs(title = paste0("Indicadores del mercado laboral mexicano"),
       y="Valor del indicador (base 2018)",
       subtitle = paste0("Última actualización: ", max(df_graphs$date),". Consulta API INEGI el día ", today())) +
  scale_fill_discrete(name="Indicador",
                      labels=c("de Remuneración","de Ocupación")) +
  scale_color_discrete(name="Indicador",
                      labels=c("de Remuneración","de Ocupación")) +
  theme(text = element_text(family="Times New Roman",size = 20),
        plot.subtitle = element_text(size = 16) )

#Guardando gráfica
png(filename = paste0("plot_",today()),width = 800)
    g
dev.off()


image_path <- file.path(paste0("plot_",today()))
image_path

#Carga de imagen a ameyalimexico.com
library(RCurl)

username <- "quetzal@jorgechavez.ameyalimexico.com"
password <- "Ximena2104"
ftp_server <- "ftp.ameyalimexico.com"
remote_dir <- paste0("/plots/",image_path, ".png")
ftp_connection <-  ftpUpload(what = image_path,
                             to = paste0("ftp://", ftp_server, remote_dir),
                             userpwd = paste(username, ":", password, sep = ""),
                             verbose = TRUE)


url_image <-  paste0("https://jorgechavez.ameyalimexico.com/plots/",image_path,".png")
url_image


# Registro de imagen
library(httr)

headers = c(
  'Content-Type' = 'application/json',
  'Authorization' = 'Bearer AQXIfm_PRzHNVzIXCwtMhwSmDeG6sZNqRcy4AwhpwXiLUvEhxrxjzUQPef50OABAf62n4M9WxPXzAS4uoqkLL_43TdY7hOirL1YSWesVjVvBDb5eSVa0Dxb1OyVcJem64V8vRc7pRGz8bO5hEHOj_qYPG9924Bk0oQWeSyXUF8GCBbu3DvzPYmi3FT1FklrIK85y-9bRA2qGmdhgYr8toQKoX0m4tuF7hliKj0-opJj-9XKUtVthWI-Pd9xzipyX1b0ey9cjWzkW6B6wtQcipTsKBqrmg6lHKWzbPBEmHgOnkNkeDzOu_86Kz1e_zcWMzKDRBZdYJjzEl0MpnwZlSFHKFOB6xw'
)

body = '{
  "registerUploadRequest": {
    "recipes": [
      "urn:li:digitalmediaRecipe:feedshare-image"
    ],
    "owner": "urn:li:person:GwtE0zoxyw",
    "serviceRelationships": [
      {
        "relationshipType": "OWNER",
        "identifier": "urn:li:userGeneratedContent"
      }
    ]
  }
}';

res <- VERB("POST", url = "https://api.linkedin.com/v2/assets?action=registerUpload", body = body, add_headers(headers))

response <- (content(res, 'parsed'))
toJSON(response,pretty = T)
asset <- response$value$asset
asset
uploadurl <- response$value$uploadMechanism$com.linkedin.digitalmedia.uploading.MediaUploadHttpRequest$uploadUrl
uploadurl

####UPLOAD IMAGEN FIRST TRY

# headers = c(
#   'Content-Type' = 'application/octet-stream',
#   'Authorization' = 'Bearer AQXIfm_PRzHNVzIXCwtMhwSmDeG6sZNqRcy4AwhpwXiLUvEhxrxjzUQPef50OABAf62n4M9WxPXzAS4uoqkLL_43TdY7hOirL1YSWesVjVvBDb5eSVa0Dxb1OyVcJem64V8vRc7pRGz8bO5hEHOj_qYPG9924Bk0oQWeSyXUF8GCBbu3DvzPYmi3FT1FklrIK85y-9bRA2qGmdhgYr8toQKoX0m4tuF7hliKj0-opJj-9XKUtVthWI-Pd9xzipyX1b0ey9cjWzkW6B6wtQcipTsKBqrmg6lHKWzbPBEmHgOnkNkeDzOu_86Kz1e_zcWMzKDRBZdYJjzEl0MpnwZlSFHKFOB6xw',
#   'X-RestLi-Protocol-Version' = '2.0.0'
# )
# 
# rawbody <- readBin(image_path, "raw", file.size(image_path))
# 
# res <- VERB("POST", url = "https://api.linkedin.com/mediaUpload/sp/D4E22AQEm_i4fm5W8JA/uploaded-image/0?ca=vector_feedshare&cn=uploads&m=AQI-VWT0sCsTkgAAAY1-nNP5bpwehXR-TL0gDAnxRqa4f-uKMCw5MQR4Pw&app=216311867&sync=0&v=beta&ut=32dJnR-9eaaX81",
#             body = list('image'= rawbody),
#             encode = "multipart",
#             add_headers(headers))
# res

####UPLOAD IMAGE SECOND TRY
# 
# headers = c(
#   'Content-Type' = 'multipart/form-data',
#   'Authorization' = 'Bearer AQXIfm_PRzHNVzIXCwtMhwSmDeG6sZNqRcy4AwhpwXiLUvEhxrxjzUQPef50OABAf62n4M9WxPXzAS4uoqkLL_43TdY7hOirL1YSWesVjVvBDb5eSVa0Dxb1OyVcJem64V8vRc7pRGz8bO5hEHOj_qYPG9924Bk0oQWeSyXUF8GCBbu3DvzPYmi3FT1FklrIK85y-9bRA2qGmdhgYr8toQKoX0m4tuF7hliKj0-opJj-9XKUtVthWI-Pd9xzipyX1b0ey9cjWzkW6B6wtQcipTsKBqrmg6lHKWzbPBEmHgOnkNkeDzOu_86Kz1e_zcWMzKDRBZdYJjzEl0MpnwZlSFHKFOB6xw',
#   'X-RestLi-Protocol-Version' = '2.0.0'
# )
# 
# body <- httr::upload_file(paste0(image_path))
# 
# res <- VERB("POST", url = "https://api.linkedin.com/mediaUpload/sp/D4E22AQEm_i4fm5W8JA/uploaded-image/0?ca=vector_feedshare&cn=uploads&m=AQI-VWT0sCsTkgAAAY1-nNP5bpwehXR-TL0gDAnxRqa4f-uKMCw5MQR4Pw&app=216311867&sync=0&v=beta&ut=32dJnR-9eaaX81",
#             body = list("data" = body),
#             add_headers(headers))
# res

#### Third UPLOAD try 

# header_auth <-  'Authorization: Bearer AQXIfm_PRzHNVzIXCwtMhwSmDeG6sZNqRcy4AwhpwXiLUvEhxrxjzUQPef50OABAf62n4M9WxPXzAS4uoqkLL_43TdY7hOirL1YSWesVjVvBDb5eSVa0Dxb1OyVcJem64V8vRc7pRGz8bO5hEHOj_qYPG9924Bk0oQWeSyXUF8GCBbu3DvzPYmi3FT1FklrIK85y-9bRA2qGmdhgYr8toQKoX0m4tuF7hliKj0-opJj-9XKUtVthWI-Pd9xzipyX1b0ey9cjWzkW6B6wtQcipTsKBqrmg6lHKWzbPBEmHgOnkNkeDzOu_86Kz1e_zcWMzKDRBZdYJjzEl0MpnwZlSFHKFOB6xw'
# header_auth
# uploadurl2 <- paste0("'",uploadurl,"'")
# file <- file.path(getwd(),image_path)
# curl_command <- paste0("curl -i --upload-file ", file,".png", " --header ",header_auth, " ", uploadurl2)
# curl_command
# # Execute the curl command
# system(curl_command)

#Fourth try Upload

headers = c(
  'Content-Type' = 'image/png',
  'Authorization' = 'Bearer AQXIfm_PRzHNVzIXCwtMhwSmDeG6sZNqRcy4AwhpwXiLUvEhxrxjzUQPef50OABAf62n4M9WxPXzAS4uoqkLL_43TdY7hOirL1YSWesVjVvBDb5eSVa0Dxb1OyVcJem64V8vRc7pRGz8bO5hEHOj_qYPG9924Bk0oQWeSyXUF8GCBbu3DvzPYmi3FT1FklrIK85y-9bRA2qGmdhgYr8toQKoX0m4tuF7hliKj0-opJj-9XKUtVthWI-Pd9xzipyX1b0ey9cjWzkW6B6wtQcipTsKBqrmg6lHKWzbPBEmHgOnkNkeDzOu_86Kz1e_zcWMzKDRBZdYJjzEl0MpnwZlSFHKFOB6xw',
  'X-RestLi-Protocol-Version' = '2.0.0',
  'media-type-family' = 'STILLIMAGE'
)

body <- list(file = httr::upload_file(image_path, type="image/png")
             )

res <- VERB("POST", url = uploadurl,
            body = body,
            encode = "multipart",
            add_headers(headers))
res



# MAKE THE POST with the uploaded image

headers = c(
  'Authorization' = 'Bearer AQXIfm_PRzHNVzIXCwtMhwSmDeG6sZNqRcy4AwhpwXiLUvEhxrxjzUQPef50OABAf62n4M9WxPXzAS4uoqkLL_43TdY7hOirL1YSWesVjVvBDb5eSVa0Dxb1OyVcJem64V8vRc7pRGz8bO5hEHOj_qYPG9924Bk0oQWeSyXUF8GCBbu3DvzPYmi3FT1FklrIK85y-9bRA2qGmdhgYr8toQKoX0m4tuF7hliKj0-opJj-9XKUtVthWI-Pd9xzipyX1b0ey9cjWzkW6B6wtQcipTsKBqrmg6lHKWzbPBEmHgOnkNkeDzOu_86Kz1e_zcWMzKDRBZdYJjzEl0MpnwZlSFHKFOB6xw',
  # 'X-RestLi-Method' = 'create',
  # 'Content-Type' = 'application/json',
  'X-RestLi-Protocol-Version' = '2.0.0'
)

data <- list(
  author = "urn:li:person:GwtE0zoxyw",
  lifecycleState = "PUBLISHED",
  specificContent = list(
    "com.linkedin.ugc.ShareContent" = list(
      shareCommentary = list(
        text = "En esta publicación se cargó la imagen via la API de Linkedin con el paquete HTTR de R, esta fue generada en R con datos de la API del INEGI. #API #R #RStudio #RStudioServer #EC2, #AWS"
      ),
      shareMediaCategory = "IMAGE",
      media = list(
        list(
          status = "READY",
          description = list(
            text = "Indicadores de ocupación y remuneraciones en México"
          ),
          media = asset,
          title = list(
            text = "Información más reciente al día de la publicación"
          )
        )
      )
    )
  ),
  visibility = list(
    "com.linkedin.ugc.MemberNetworkVisibility" = "PUBLIC"
  )
)

json_body <- toJSON(data,auto_unbox = T,pretty = T)

res <- VERB("POST", url = "https://api.linkedin.com/v2/ugcPosts", body = json_body, add_headers(headers),encode = "json")
res_share <- content(res)
res_share
str(res)

#ADDRESS OF COMMENTS
#<iframe src="https://www.linkedin.com/embed/feed/update/urn:li:share:7160813184256253952" height="457" width="504" frameborder="0" allowfullscreen="" title="Embedded post"></iframe>
# 
# # Post in my page via URL
# 
# headers = c(
#   'Authorization' = 'Bearer AQXIfm_PRzHNVzIXCwtMhwSmDeG6sZNqRcy4AwhpwXiLUvEhxrxjzUQPef50OABAf62n4M9WxPXzAS4uoqkLL_43TdY7hOirL1YSWesVjVvBDb5eSVa0Dxb1OyVcJem64V8vRc7pRGz8bO5hEHOj_qYPG9924Bk0oQWeSyXUF8GCBbu3DvzPYmi3FT1FklrIK85y-9bRA2qGmdhgYr8toQKoX0m4tuF7hliKj0-opJj-9XKUtVthWI-Pd9xzipyX1b0ey9cjWzkW6B6wtQcipTsKBqrmg6lHKWzbPBEmHgOnkNkeDzOu_86Kz1e_zcWMzKDRBZdYJjzEl0MpnwZlSFHKFOB6xw',
#   'X-RestLi-Method' = 'create',
#   # 'Content-Type' = 'application/json',
#   'X-RestLi-Protocol-Version' = '2.0.0'
# )
# # Esta gráfica fue generada con consulta de datos a la API del INEGI, utilizando R en una máquina virtual EC2 de Amazon Web Services.
# 
# json_body <- list(
#   author = "urn:li:person:GwtE0zoxyw",
#   lifecycleState = "PUBLISHED",
#   specificContent = list(
#     "com.linkedin.ugc.ShareContent" = list(
#       shareCommentary = list(
#         text = "Esta gráfica fue generada con consulta de datos a la API del INEGI, utilizando R en una máquina virtual EC2 de Amazon Web Services."
#       ),
#       shareMediaCategory = "ARTICLE",
#       media = list(
#         list(
#           status = "READY",
#           description = list(
#             text = "Indicadores del mercado laboral mexicano al día de hoy"
#           ),
#           originalUrl = url_image,
#           title = list(
#             text = "Indicadores de ocupación y remuneraciones"
#           )
#         )
#       )
#     )
#   ),
#   visibility = list(
#     "com.linkedin.ugc.MemberNetworkVisibility" = "PUBLIC"
#   )
# )
# 
# body <- toJSON(json_body,pretty = T,auto_unbox = T)
# body
# res <- VERB("POST", url = "https://api.linkedin.com/v2/ugcPosts", body = body, add_headers(headers),encode = "json")
# response <- content(res)
# response


# Get my information
# headers = c(
#   'Authorization' = 'Bearer AQXIfm_PRzHNVzIXCwtMhwSmDeG6sZNqRcy4AwhpwXiLUvEhxrxjzUQPef50OABAf62n4M9WxPXzAS4uoqkLL_43TdY7hOirL1YSWesVjVvBDb5eSVa0Dxb1OyVcJem64V8vRc7pRGz8bO5hEHOj_qYPG9924Bk0oQWeSyXUF8GCBbu3DvzPYmi3FT1FklrIK85y-9bRA2qGmdhgYr8toQKoX0m4tuF7hliKj0-opJj-9XKUtVthWI-Pd9xzipyX1b0ey9cjWzkW6B6wtQcipTsKBqrmg6lHKWzbPBEmHgOnkNkeDzOu_86Kz1e_zcWMzKDRBZdYJjzEl0MpnwZlSFHKFOB6xw')
# 
# res <- VERB("GET", url = "https://api.linkedin.com/v2/userinfo", add_headers(headers))
# response <- content(res)
# response
# 
# urn <- response$sub
# urn


#Post in my page
# 
# headers = c(
#   'Authorization' = 'Bearer AQXIfm_PRzHNVzIXCwtMhwSmDeG6sZNqRcy4AwhpwXiLUvEhxrxjzUQPef50OABAf62n4M9WxPXzAS4uoqkLL_43TdY7hOirL1YSWesVjVvBDb5eSVa0Dxb1OyVcJem64V8vRc7pRGz8bO5hEHOj_qYPG9924Bk0oQWeSyXUF8GCBbu3DvzPYmi3FT1FklrIK85y-9bRA2qGmdhgYr8toQKoX0m4tuF7hliKj0-opJj-9XKUtVthWI-Pd9xzipyX1b0ey9cjWzkW6B6wtQcipTsKBqrmg6lHKWzbPBEmHgOnkNkeDzOu_86Kz1e_zcWMzKDRBZdYJjzEl0MpnwZlSFHKFOB6xw',
#   'X-RestLi-Method' = 'create',
#   'Content-Type' = 'application/json',
#   'X-RestLi-Protocol-Version' = '2.0.0'
# )
# 
# body = '{
#   "author": "urn:li:person:GwtE0zoxyw",
#   "lifecycleState": "PUBLISHED",
#   "specificContent": {
#     "com.linkedin.ugc.ShareContent": {
#       "shareCommentary": {
#         "text": "Hello world, primer publicación usando R en EC2 de AWS y la API de Linkedin."
#       },
#       "shareMediaCategory": "NONE"
#     }
#   },
#   "visibility": {
#     "com.linkedin.ugc.MemberNetworkVisibility": "PUBLIC"
#   }
# }';
# 
# res <- VERB("POST", url = "https://api.linkedin.com/v2/ugcPosts", body = body, add_headers(headers))
# response <- content(res)
# response

df <- data.frame(
  date = Sys.time(),
  share = ifelse(!is.null(response$id),response$id,paste0(response$message, " ", response$status)),
  urn = "GwtE0zoxyw",
  nombre = "Jorge"
)

df

write.csv(df, append = T,
          file = "linkedin_share_log.csv")


