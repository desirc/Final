library("ggplot2")
library(dplyr)
library(tidyr)
library(leaflet)
library(httr)
library(jsonlite)
library(DT)

source("analysis.R")

server <- function(input,output){
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
  
  output$violation_pie <- renderPlot({
    num_codes <- df %>% 
      select(Violation.Description, Name, Violation.Type) %>% 
      filter(Violation.Type == input$violation_type) %>%
      mutate(code = substr(Violation.Description, 1, 4)) %>%
      group_by(code) %>% 
      count() %>% 
      spread(
        key = code,
        value = n
      ) %>% 
      gather(
        key = code,
        value = Number_of_occurences
      )
    pie <- ggplot(num_codes, aes(x = "", y = Number_of_occurences, fill = code))+
      geom_bar(width = 1, stat = "identity", color = "black") +
      coord_polar("y", start = 0) + 
      labs(x = NULL, y = NULL, fill = "Violation Codes",
           title = 
             paste(input$violation_type,"Violations - Number of Occurences"))+
      theme_classic() + theme(axis.line = element_blank(),
                              axis.text = element_blank()
                              )
    pie
  })
    
  output$violation_text <- renderText({
    violation_text <- c("The pie chart above shows which ", input$violation_type, 
                        " violations were the most common in food establishments
                        in King County. The table below shows the meaning of each
                        violation code, as well as the number of occurences.")
    paste(violation_text, collapse = "")
    
  })
  
  output$violation_table <- renderTable({
    code_table <- df %>% 
      select(Violation.Description, Name, Violation.Type) %>% 
      filter(Violation.Type == input$violation_type) %>% 
      group_by(Violation.Description) %>% 
      count() %>% 
      rename("Number of Occurences" = n, 
             "Violation Code/Description" = Violation.Description)
    code_table
  })

}