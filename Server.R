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
    temp_df_merged <- df_merged %>% drop_na(price)
    names(temp_df_merged) <- c("Longitude", "Latitude","mean_inspection_score","mean_grade","X","Name","coordinates.latitude","coordinates.longitude","price","review_count","rating","is_closed")
    ggplot(data = temp_df_merged) +
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
  
  output$graph_type <- renderText({
    response <- ifelse(input$graph_buttons == "mean_inspection_score", "mean inspection score.", "mean grade")
    output_response <- paste("Above shows a graph of",response, collapse = "")
  })
  
  output$range <- renderText({
    low_price_only_df <- filter(df_merged, price == "$")
    range_low_price <- max(low_price_only_df[["Mean Inspection Score"]]) - min(low_price_only_df[["Mean Inspection Score"]])
    response <- c("The above bar chart shows the number of restaurants of a certain price.
           Both graphs look very similar, showing that actually the more the number of restaurants, the higher the range of inspection codes broken/grades likely.
           The maximum inspection score was ", range_low_price, ".")
    response <- paste0(response, collapse = "")
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
  output$violation_table <- renderDataTable({
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