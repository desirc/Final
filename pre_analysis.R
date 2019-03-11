library(dplyr)
library(tidyr)
library(leaflet)
library(httr)
library(jsonlite)
library(data.table)
library(purrr)
library(fuzzyjoin)
library(tools)
library(ggplot2)


source("keys.R")

df <- read.csv(
  "./data/Food_Establishment_Inspection_Data.csv", 
  stringsAsFactors = FALSE,
  row.names=NULL
) %>% drop_na() %>% 
  mutate(
    Inspection.Date = as.Date(Inspection.Date, format = "%m/%d/%Y")
  ) %>% 
  filter(Zip.Code == 98105, Inspection.Date > as.Date("2009-01-01")) %>% 
  mutate(
    Grade = as.numeric(Grade),
    Longitude = as.numeric(Longitude),
    Latitude = as.numeric(Latitude),
    Inspection.Score = as.numeric(Inspection.Score)
  )


df_by_inspection <- df %>% 
  group_by(
    Name, Longitude, Latitude, 
    Inspection_Serial_Num
  ) %>%
  summarize(
    "Inspection Score" = mean(Inspection.Score, na.rm = TRUE),
    "Grade" = mean(Grade)
  ) %>% 
  group_by(Name, Longitude, Latitude) %>% 
  summarise(
    "Mean Inspection Score" = mean(`Inspection Score`, na.rm = TRUE),
    "Mean Grade" = mean(Grade)
  ) %>% 
  as_data_frame()


pal <- colorNumeric(
  palette = c("red", "yellow", "orange", "green"),
  domain = df_by_inspection$Grade
)

leaflet() %>% 
  addProviderTiles("CartoDB") %>% 
  addCircleMarkers(
    data = df_by_inspection,
    lat = ~Latitude, 
    lng = ~Longitude,
    radius = 5,
    color = ~pal(Grade),
    label = ~Name
  )

# BURKE GILMAN BREWING COMPANY -122.28802 47.6615

get_restaurant_info("BURKE GILMAN BREWING COMPANY", -122.28802, 47.6615)


base_uri <- "https://api.yelp.com/v3"
get_restaurant_info <- function(name, long, lat) {
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
  
  # search results sort by match
  df_business <- response_data$businesses
  df_business
  
}

nrow(df_by_inspection)


df_list = list()
ind = 1
for (row in 1:nrow(df_by_inspection)) {
  name <- df_by_inspection[row, 'Name'] %>% pull()
  long <- df_by_inspection[row, 'Longitude'] %>% pull()
  lat <- df_by_inspection[row, 'Latitude'] %>% pull()
  
  df <- get_restaurant_info(name, long, lat)
  if (length(df) != 0) {
    df_list[[ind]] <- df[1, ] %>% 
      jsonlite::flatten() %>% 
      mutate(
        price = ifelse("price" %in% names(.), price, NA)
      ) %>% 
      select(
        name, coordinates.latitude, coordinates.longitude, 
        price, review_count, rating, is_closed
      )
    ind = ind + 1
  }
}

yelp <- bind_rows(df_list)
write.csv(yelp, "./data/yelp.csv")


