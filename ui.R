library("shiny")
library("dplyr")
library("shinythemes")
library("DT")
library("shinyWidgets")
source("analysis.R")


ui <- fluidPage(
  #Chooses the theme and sets background color.
  theme = shinytheme("cosmo"),
  setBackgroundColor("#e6e6fa"),
  titlePanel("Add title here"),
  sidebarLayout(
    sidebarPanel(
      h3("Controls"),
      #Only shows the control widgets of the tab selected.
      conditionalPanel(condition="input.tabselected == 1",
                       h3("1st tab selected")
                       ),
      conditionalPanel(
        condition="input.tabselected == 2",
        radioButtons(
          inputId = "feature",
          label = "Compare rating with:",
          choices = c(
            "Mean Inspection Score",
            "Mean Grade"
          ),
          selected = "Mean Inspection Score"
        ),
        sliderInput(
          inputId = "cutoff",
          label = "Rating cutoff for hypothesis testing",
          min = 2,
          max = 4.5,
          value = 3,
          step = 0.5
        )
      ),
      conditionalPanel(condition="input.tabselected == 3",
                       h3("Price tab widgets:"),
                       #Radio buttons:
                       radioButtons("graph_buttons",
                                    "Choose the y axis input:",
                                    c("Inspection score" = "mean_inspection_score", "Grade_score" = "mean_grade")
                       )
      ),
      conditionalPanel(condition="input.tabselected == 4",
                       h3("4th tab selected")
      ),
      conditionalPanel(condition="input.tabselected == 5",
                       h3("Datasets"),
                       radioButtons(
                         "grade",
                         "Grade",
                         c("1"="1","2"="2","3"="3","4"="4", "All"),
                         selected = "1"
                       )
      ),
      conditionalPanel(condition="input.tabselected == 6",
                       h3("6th tab selected")
      )
    ),
    mainPanel(
      h3("Display"),
      tabsetPanel(
        tabPanel("Question 1", value = 1),
        tabPanel(
          "Rating", value = 2,
          h2("Plot"),
          textOutput("plot_intro"),
          plotOutput("hex_plot"),
          h2("Qualitative Analysis"),
          p("Visualization might be deceiving, so let us look at some qualitative analysis:"),
          h3("Rank Correlation"),
          textOutput("rank"),
          textOutput("rank_res"),
          h3("Hypothesis Testing"),
          textOutput("null_hypo"),
          textOutput("a_hypo"),
          textOutput("p_val_res"),
          textOutput("hypo_conclude")
        ),
        tabPanel("Price comparisons", value = 3,
         h3("Relationship of price and inspection grades"),
         p("Do more expensive restaurants break fewer health codes/inspections?"),
         br(),
         p("Logically restaurants with more money would have more money to make the restaurants hygenic.
           This means that more expensive restaurants should break fewer health codes."),
         plotOutput("price_v_grade", width = "100%"),
         textOutput("graph_type"),
         p("The higher the mean inspection score, the more inspection codes a restaurant has broken meaning the worse they have done.
           The yelp API uses $,$$ and $$$ to show low prices restuarants, medium priced restaurants and high priced restaurants.
           The higher the grade, the more inspection codes broken."),
           br(),
           p("By the trend of the graph, you can see that the lowest price has the highest scores of inspection codes.
           This would suggest that the lower prices, the more break more inspection laws and so the cheaper restuarants are less safe 
             -agreeing with the question proposed."),
         br(),
         plotOutput("number_restaurants_v_price", width = "100%"),
         textOutput("range"), 
         p("The answer to the originally proposed question is no. The range of data was the largest for the lowest prices as the maximum inspection score of the entire dataset is the same number.
           This would suggest that the price range of restaurants and the inspection scores of those restaurants are not correlated.
           Rather, it shows that the more restaurants there are the higher the range of inspection rates.
           As there are more cheap restaurants than any other, the range of inspection rates is the highest.
           ")
         ),
          
        tabPanel("Question 4", value = 4,
                 p("Here, we look at the mean inspection score and review count of restaurants"),
                 plotOutput("point_plot"),
                 p("Here is the quantitative analysis."),
                 textOutput("review_count"),
                 p("Now let's test the hypothesis that if restaurants with mean inspection score greater than 238 and those with mean less than 238 have the same average review count"),
                 p("Opposingly though, the other hypothesis will be that if the restaurants with mean inspection score greater then 238 have smaller average review count than those with mean less than 238"),
                 textOutput("ceci_p_val")
                 ),
        #Displays a table in the last two tabs
        tabPanel("Inspection data", value = 5,
                 dataTableOutput(outputId = "table"), width = "100%"),
        tabPanel("Yelp data", value = 6,
                 dataTableOutput(outputId = "table2"), width = "100%"),
        tabPanel("References", value = 7,
                 h3("References:"),
                 a("Inspection dataset -King county open data", 
                   href = "https://data.kingcounty.gov/Health-Wellness/Food-Establishment-Inspection-Data/f29f-zza5"),
                 br(),
                 a("Yelp restaurant dataset", href = "https://www.yelp.com/dataset")),
        id = "tabselected"
      )
    )
  )
)
    
