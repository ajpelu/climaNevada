# Load pkgs
library(readxl)
library(tidyverse)
library(here)
library(sf)

# Leer datos espaciales de Subsistema clima 
subclima <- st_read(here::here("./data/estaciones_clima.shp"))


# Estaciones seleccionadas para climaNevada. 
# - filter todas las redes excepto GLORIA (9) 
# - Select solo station_code 

raw <- read_tsv(here::here("./data/cn_stations_raw.tsv")) %>% filter(cli_red_id != 9) 

# Filtrar estaciones subsistema clima 
stations_subclima <- subclima %>% 
  filter(INDICATIVO %in% raw$station_code) %>% 
  dplyr::select(station_code = INDICATIVO)
  
# Read gloria stations 
stations_gloria <- read_csv(here::here("./data/coord_gloria_4326.csv")) %>% 
  st_as_sf(coords = c("X", "Y"), crs = 4326) 
stations_gloria <- stations_gloria %>% 
  dplyr::select(station_code = codigo) %>% 
  st_transform(crs=25830)


stations_cn <- rbind(stations_subclima, stations_gloria) 

# Export 
stations_cn_coord <- cbind(stations_cn, st_coordinates(stations_cn)) %>% 
  st_set_geometry(NULL) %>% 
  mutate(coord_x = round(X), 
         coord_y = round(Y), 
         epsg = 25830) %>% 
  dplyr::select(-X, -Y)


  
# Delimitacion Municipios 
# https://www.juntadeandalucia.es/institutodeestadisticaycartografia/DERA/g17.htm 

muni <- st_read(here::here("./data/da07_cod_postal.shp"))
muni <- st_transform(muni, crs = 25830)


# Get municipio 
stations_cn_munic <- st_intersection(stations_cn, muni) %>% 
  st_set_geometry(NULL) %>% dplyr::select(-COD_POSTAL, -COD_ENT)
  
 
# s <- stations_cn_coord %>% inner_join(stations_cn_munic)
# write_csv(s, here::here("./data/tt.csv"))
