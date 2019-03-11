library("ggplot2")
library(dplyr)
library(tidyr)
library(leaflet)
library(httr)
library(jsonlite)
library(DT)


server <- function(input,output){
  output$table <- renderDataTable({
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
    print(input$grade)
      if((input$grade != "All")) {
        df <- df %>% filter(Grade == input$grade)
      } 
    df <- df %>% select(Name, Grade, Description, Inspection.Result )
    df
    
  })
  

}