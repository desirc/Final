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



yelp <- read.csv("./data/yelp.csv", stringsAsFactors = FALSE) 

colnames(yelp)
colnames(df_by_inspection)

df_merged <- df_by_inspection %>% 
  mutate(
    Name = toTitleCase(tolower(Name))
  ) %>% 
  regex_inner_join(
    yelp,
    by = c(
      Name = "name"
    )
  ) %>% 
  select(-Name) %>%
  rename(Name = name) %>% as.data.frame()

high_score <- df_merged %>% 
  filter(`Mean Inspection Score` > 5) %>% 
  select(rating) %>% pull()

low_score <- df_merged %>% 
  filter(`Mean Inspection Score` <= 5) %>% 
  select(rating) %>% pull()

test_result <- t.test(x = high_score, y = low_score, alternative = "less")
p_val <- test_result$p.value

ggplot(df_merged, aes(`Mean Inspection Score`, rating)) +
  geom_hex()

cor.test(
  x = df_merged$`Mean Inspection Score`,
  y = df_merged$rating,
  method = "spearman"
)$estimate
