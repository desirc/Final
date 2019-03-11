library("ggplot2")
library(dplyr)
library(tidyr)
library(leaflet)
library(httr)
library(jsonlite)
library(DT)

source("analysis.R")
server <- function(input,output){
  #Nhat's part 2
  output$hex_plot <- renderPlot({
    hex_plot
  })
  output$rank <- renderText({
    paste(
      "The Spearman rank correlation of mean inspection score and rating on Yelp is:",
      cor
    )
  })
  output$p_val <- renderText({
    paste(
      "The p-value of the hypothesis is:",
      p_val
    )
  })
  #Cecilia's part 4
  output$point_plot <- renderPlot({
    point_plot
  })
  output$review_count <- renderText({
    paste(
      "The Pearson review count correlation of the mean inspection score and review count on Yelp is:",
      ceci_cor
    )
  })
  output$ceci_p_val <- renderText({
    paste(
      "The p-value of the hypothesis is:",
      ceci_p_val
    )
  })
  #data at the end
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
  
  output$table2 <- renderDataTable({
    
  })
  

}