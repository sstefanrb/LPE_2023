# SCRIPT + STUDENT INFO ---------------------------------------------------
# NOMBRE: STEFAN RAOS BERMÚDEZ
# EXP: 22175018
# TEMA: HANDS_ON_01


# LOADING LIBS ------------------------------------------------------------
install.packages (c("tidyverse", "dplyr", "janitor"))
install.packages("leaflet")
install.packages("openxlsx")
install.packages("readxl")
library("tidyverse","dplyr","janitor", "jsonlite")
library(tidyverse)
library(leaflet)
library("dplyr","janitor")
library(openxlsx)
library(readxl)

# LOADING DATA ------------------------------------------------------------
exp_22175018 <- jsonlite::fromJSON("https://sedeaplicaciones.minetur.gob.es/ServiciosRESTCarburantes/PreciosCarburantes/EstacionesTerrestres/")

data <- readxl::read_excel("codigo.xls")

#Eliminar filas que estan mal

colnames(data) <- data[1, ]
data <- data[-1,]

View(data)

# SHORTCUTS ---------------------------------------------------------------

# limpiar consola = CTRL + l
# %>% pipe operator = SHIFT + CTRL + M
# CTRL + ENTER = ejecutar
# SHIFT + CTRL + R = Indice

# GIT COMMANDS ------------------------------------------------------------

# pwd = current location
# git status = info about a repo
# git commit = Add a comment
# git add . = Add the current dir to the entire repo
# git push -u origin main = send to the remote repo (Github)
# %>% para pasar el flijo entre diferentes códigos que voy a utilizar

# CLI COMMANDS ------------------------------------------------------------

# pwd = shows the current dir
# ls = list terminal 
# mkdir = create a dir
# cd = change dir
# clear = limpiar terminal
# set wd 

# BASIC INSTRUCTIONS ------------------------------------------------------

stefan <- 8 # assigning values


# TIDYVERSE COMMANDS ------------------------------------------------------


# 27 SEPTIEMBRE -----------------------------------------------------------

str(exp_22175018) #get datatype
df <- exp_22175018$ListaEESSPrecio #get readable data
df %>% glimpse()
df %>% janitor::clean_names() %>% glimpse()


# WORKING W PIPE (OPT. MODE) ----------------------------------------------
clean_data <- df %>% janitor::clean_names() %>% glimpse()
cd <- df %>% readr::type_convert(locale = readr::locale(decimal_mark=",")) %>% janitor::clean_names()
cd %>% glimpse()


# DEALING W DATA ----------------------------------------------------------

villa_boa_gas <- cd %>% select(precio_gasoleo_a, rotulo, direccion, localidad) %>% 
  filter(rotulo=="BALLENOIL", localidad == "MADRID") %>% 
  arrange(precio_gasoleo_a) %>% View()
Dgas_max <- cd %>% select(precio_gasoleo_a, rotulo, direccion, provincia) %>% filter(provincia == "MADRID") %>% arrange(precio_gasoleo_a) 

gas_mad_ballenoil <- cd %>% select(precio_gasoleo_a, rotulo, direccion, municipio, provincia, c_p) %>% 
  filter(provincia == "MADRID" & rotulo == "BALLENOIL") %>% 
  arrange(precio_gasoleo_a) %>% View()

gas_mad_1_55 <- cd %>% select(precio_gasoleo_a, rotulo, direccion, municipio, provincia,latitud,longitud_wgs84) %>% 
  filter(provincia == "MADRID" & precio_gasoleo_a < 1.55) %>% 
  arrange(desc(precio_gasoleo_a))

gas_mad_1_55 %>% leaflet() %>% addTiles() %>% 
  addCircleMarkers(lat = ~latitud,lng = ~longitud_wgs84, popup = ~rotulo, label = ~precio_gasoleo_a)

gasoleo_a_1_55 <- clean_data %>% 
  select(precio_gasoleo_a, rotulo, direccion, provincia, latitud, longitud_wgs84, municipio) %>% 
  filter(provincia=="MADRID" || precio_gasoleo_a<1.50) %>% 
  arrange(desc(precio_gasoleo_a)) %>% write.xlsx("gasole_a_1_55.xls")

cd %>%
  select(precio_gasoleo_a, rotulo, direccion, provincia, latitud, longitud_wgs84, municipio) %>%
  filter(localidad == "MADRID" | precio_gasoleo_a < 1.50) %>% 
  arrange(desc(precio_gasoleo_a)) %>%
  write.xlsx("gasole_a_1_50.xlsx")


average_price <- mean(cd$precio_gasoleo_a, na.rm = TRUE)
  View(average_price)

cd <- cd %>%
  mutate(is_low_cost = ifelse(precio_gasoleo_a < average_price, "Low Cost", "Not Low Cost"))

write.xlsx(cd, "LowCost.xlsx")

View(cd)

average_prices_castilla_la_mancha <- cd %>%
  filter(provincia %in% c("ALBACETE", "CIUDAD REAL", "CUENCA", "GUADALAJARA", "TOLEDO")) %>%
  group_by(provincia) %>%
  summarize(avg_price_gasoleo = mean(precio_gasoleo_a, na.rm = TRUE))

average_price_clm <- average_prices_castilla_la_mancha %>%
  summarize(avg_price_clm = mean(avg_price_gasoleo, na.rm = TRUE))

View(average_prices_castilla_la_mancha)
View(average_price_clm)

# Supongamos que tienes una tabla llamada "tabla_comunidad" con las columnas "codigo" y "Comunidad_Autonoma".

# Realiza el inner join y agrega la columna de Comunidad Autónoma a la tabla cd
cd <- merge(cd, data, by.x = "idccaa", by.y = "CODIGO", all.x = TRUE)

# Ahora, cd contiene la columna "Comunidad_Autonoma" agregada.

View(cd)

  

# STORING DATA ------------------------------------------------------------
write.xslx(gas_max, "gas_max.csv")
xlsx::write.xlsx(gas_max, "gas_max.xlsx")

