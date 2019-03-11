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
  output$plot_intro <- renderText({
    paste(
      "Here, we look at the relationship between the rating and",
      tolower(input$feature)
    )
  })
  
  output$hex_plot <- renderPlot({
    hex_plot <- ggplot(df_merged, aes_string("rating", paste0("`", input$feature, "`"))) +
      geom_count() +
      labs(
        y = input$feature,
        x = "Rating"
      )
    hex_plot
  })
  
  
  cor <- reactive({
    cor.test(
      x = df_merged %>% select(input$feature) %>% pull() %>% as.numeric(),
      y = df_merged %>% select(rating) %>% pull() %>% as.numeric(),
      method = "spearman"
    )$estimate
  })
  
  output$rank <- renderText({
    x <- paste0("`", input$feature, "`")
    paste(
      "The Spearman rank correlation of",
      tolower(input$feature), 
      "and rating on Yelp is:",
      cor()
    )
  })
  
  output$rank_res <- renderText({
    paste(
      "This suggests a",
      ifelse(abs(cor()) > 0.5, "strong", "weak"),
      ifelse(cor() < 0, "negative", "positive"),
      "correlation."
    )
  })
  
  output$null_hypo <- renderText({
    paste(
      "Next, we will test the hypothesis that restaurants with rating greater than",
      input$cutoff,
      "and those with rating at most", 
      input$cutoff,
      "have the same",
      tolower(input$feature)
    )
  })
  
  output$a_hypo <- renderText({
    paste(
      "The alternative hypothesis will be that the restaurants with rating greater than",
      input$cutoff,
      "and those with rating at most", 
      input$cutoff,
      "have different",
      tolower(input$feature)
    )
  })
  
  p_val <- reactive({
    high_rating <- df_merged %>% 
      filter(rating > input$cutoff) %>% 
      select(input$feature) %>% pull()
    
    low_rating <- df_merged %>% 
      filter(rating <= input$cutoff) %>% 
      select(input$feature) %>% pull()
    
    test_result <- t.test(x = high_rating, y = low_rating)
    test_result$p.value
  })
  
  output$p_val_res <- renderText({
    paste(
      "The p-value of the hypothesis is:",
      p_val()
    )
  })
  
  output$hypo_conclude <- renderText({
    ifelse(
      p_val() < 0.05,
      "This means that we can confidently reject the null hypothesis in favor of the alternative hypothesis at 0.05 significance level",
      "This means that we cannot reject the null hypothesis."
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