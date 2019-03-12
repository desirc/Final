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

hex_plot <- ggplot(df_merged, aes_string('`Mean Inspection Score`', "rating")) +
  geom_hex()
hex_plot


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

##Cecilia's question #4

point_plot <- ggplot(df_merged, aes(`Mean Inspection Score`, review_count)) +
  geom_point()

ceci_high_score <- df_merged %>%
  filter(`Mean Inspection Score` > 5) %>%
  select(review_count) %>% pull()

ceci_low_score <- df_merged %>%
  filter(`Mean Inspection Score` <= 5) %>%
  select(review_count) %>% pull()

ceci_test_result <- t.test(x = ceci_high_score, y = ceci_low_score, alternative = "less")
ceci_p_val <- test_result$p.value

ceci_cor <- cor.test(
  x = df_merged$`Mean Inspection Score`,
  y = df_merged$review_count,
  method = "pearson"
)$estimates
