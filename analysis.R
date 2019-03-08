library(dplyr)
library(tidyr)
library(leaflet)
library(httr)
library(jsonlite)

source("keys.R")

df <- read.csv(
  "./data/Food_Establishment_Inspection_Data.csv", 
  stringsAsFactors = FALSE
) %>% drop_na() %>% 
  mutate(
    Inspection.Date = as.Date(Inspection.Date, format = "%m/%d/%Y")
  ) %>% 
  filter(Zip.Code == 98105, Inspection.Date > as.Date("2009-01-01")) %>% 
  mutate(
    Grade = as.numeric(Grade)
  )


df_by_inspection <- df %>% 
  group_by(Name, Longitude, Latitude, Inspection_Serial_Num) %>%
  summarize(
    "Grade" = mean(Grade)
  ) %>% 
  group_by(Name, Longitude, Latitude) %>% 
  summarise("Grade" = mean(Grade)) %>% 
  as_data_frame()

leaflet() %>% 
  addProviderTiles("CartoDB") %>% 
  addCircleMarkers(
    data = df_by_inspection,
    lat = ~Latitude, 
    lng = ~Longitude,
    radius = 0.5,
    color = "red"
  )



get_restaurant_info("CHINA FIRST", -122.3135, 47.65944)

get_restaurant_info <- function(name, long, lat) {
  endpoint <- "/businesses/search"
  endpoint <- "/businesses/search"
  resource_uri <- paste0(base_uri, endpoint)
  query_params <- list(
    term = name,
    latitude = lat,
    longitude = long
  )
  
  response <- GET(
    resource_uri,
    query = query_params,
    add_headers(Authorization = paste("bearer", api_key))
  )
  response_text <- content(response, type = "text")
  response_data <- fromJSON(response_text)
  df_business <- flatten(response_data$businesses)[1, ] # search results sort by match
  
  df_business
}


  




