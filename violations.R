library(dplyr)
library(tidyr)
library(ggplot2)

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
#View(df)

num_red <- df %>% 
  select(Violation.Description, Name, Violation.Type) %>% 
  filter(Violation.Type == "RED") %>%
  mutate(code = substr(Violation.Description, 1, 4)) %>%
  group_by(code) %>% 
  count() %>% 
  spread(
    key = code,
    value = n
  ) %>% 
  gather(
    key = code,
    value = num
  )

View(num_red)

red_pie <- ggplot(num_red, aes(x = "", y = num, fill = code))+
  geom_bar(width = 1, stat = "identity") +
  coord_polar("y", start = 0) +
  scale_fill_brewer(palette = "Dark2")
red_pie
