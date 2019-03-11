library("shiny")
library("dplyr")
library("shinythemes")
library("DT")
library("shinyWidgets")


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
        h3("2nd tab selected"),
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
          label = "Rating Cutoff",
          min = 1,
          max = 5,
          value = 3,
          step = 0.5
        )
      ),
      conditionalPanel(condition="input.tabselected == 3",
                       h3("3rd tab selected")
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
          p("Here, we look at the relationship between the rating and other factors (which can be chosen to the left)."),
          plotOutput("hex_plot"),
          h2("Qualitative Analysis"),
          p("Visualization might be deceiving, so let us look at some qualitative analysis:"),
          h3("Rank Correlation"),
          textOutput("rank"),
          textOutput("rank_res"),
          h3("Hypothesis Testin"),
          textOutput("null_hypo"),
          textOutput("a_hypo"),
          textOutput("p_val_res"),
          textOutput("hypo_conclude")
        ),
        tabPanel("Question 3", value = 3),
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
    
