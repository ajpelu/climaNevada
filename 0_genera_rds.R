# 0 prepare Data 

library("tidyverse") 

# stations, network and variables
stations <- read_tsv(here::here("./data/cn_stations.tsv"))
net <- read_tsv(here::here("./data/cn_network.tsv"))
variables <- read_tsv(here::here("./data/cn_variables.tsv"))

# Translate variables 
station_variables <- stations %>% 
  dplyr::select(station_code, station_variables_id) %>% 
  mutate(variable_id = str_split(station_variables_id, "/")) %>% 
  unnest(cols = c(variable_id)) %>%
  mutate(variable_id = as.numeric(variable_id)) %>% 
  dplyr::select(-station_variables_id) %>% 
  inner_join(variables) %>% 
  dplyr::select(station_code, variable_code) %>% 
  pivot_wider(id_cols = station_code,
              names_from = variable_code, 
              values_from = variable_code,
              values_fill = NULL) %>% 
  dplyr::select(station_code,
                sort(colnames(.))) %>% 
  unite("variables_code", -c("station_code"), sep = " / ", na.rm = TRUE)

s <- stations %>% 
  inner_join(net, by = c("cn_network_id" = "network_id")) %>% 
  left_join(station_variables, by = "station_code") %>% 
  st_as_sf(coords = c("coord_x", "coord_y"), crs = 25830) %>% 
  st_transform(crs=4326) 

s <- cbind(s, st_coordinates(s)) %>% 
  rename("lng" = "X", "lat" = "Y")

s <- st_set_geometry(s, NULL)
saveRDS(s, file = here::here("./inst/data/cn_stations_full.RDS"))
