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
  
  #Shows the inspection dataset on the inspection data tab
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
  
  #Shows the yelp API dataset on the app.
  output$table2 <- renderDataTable({
    df2 <- select(df_merged, Name, 'Mean Inspection Score', 'Mean Grade', 'price', 'review_count', 'rating')
    df2
  })
  
  output$price_v_grade <- renderPlot({
    temp_df_merged <- df_merged
    names(temp_df_merged) <- c("Longitude", "Latitude","mean_inspection_score","mean_grade","X","Name","coordinates.latitude","coordinates.longitude","price","review_count","rating","is_closed")
    #slider_vals <- filter(temp_df_merged, rating < input$slide_key_rating)
    ggplot(data = temp_df_merged,  aes(na.rm = TRUE)) +
      geom_col(mapping = aes(x = price, y = temp_df_merged[,input$graph_buttons], fill = Name)) +
      theme(legend.position = 'none')
  })
  
  output$number_restaurants_v_price <- renderPlot({
    n_cheap_restaurants <- nrow(filter(df_merged, price == "$"))
    n_mid_restaurants <- nrow(filter(df_merged, price == "$$"))
    n_expensive_restuarants <- nrow(filter(df_merged, price == "$$$"))
    price_df <- data.frame(c("$","$$","$$$"),c(n_cheap_restaurants,n_mid_restaurants,n_expensive_restuarants))
    names(price_df) <- c("price","num_restaurants")
    ggplot(data = price_df)+
      geom_col(mapping = aes(x = price, y = num_restaurants), fill = "Red")
  })
  

}