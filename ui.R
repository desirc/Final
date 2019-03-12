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
                       h3("1st tab selected"),
                       radioButtons(
                         "violation_type",
                         "Violation Type:",
                         c("Red" = "RED", "Blue" = "BLUE"),
                         selected = "RED"
                       )
      ),
      conditionalPanel(condition="input.tabselected == 2",
                       h3("2nd tab selected")
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
        # Brandon Ly's Question 
        tabPanel(
          "Question 1", value = 1,
          p("King County's inspection reporting system includes two types of 
            critical violations; red and blue. Food establishments that receive
            Red critical violations have failed to meet food handling standards
            that could likely lead to food borne illnesses as a result.
            Some of these violations include incorrectly storing food, washing 
            hands, and controlling temperature.
            Blue critical violations have failed to meet mantinence and
            sanitation standards but are not likely the cause of food bourne 
            illness."),
          plotOutput("violation_pie"),
          textOutput("violation_text"),
          tableOutput("violation_table")
                 ),
        
        tabPanel(
          "Question 2", value = 2,
          p("Here, we look at the relationship between the mean inspection score and rating of restaurants"),
          plotOutput("hex_plot"),
          p("There does not seem to be any clear relationship, so we will perform some qualitative analysis."),
          textOutput("rank"),
          p("This suggests a weak negative correlation."),
          p("Next, we will test the hypothesis that restaurants with mean inspection score greater than 5 and those with mean less than 5 have the same average rating"),
          p("The alternative hypothesis will be that the restaurants with mean inspection score greater than 5 have smaller average rating than those with mean less than 5"),
          textOutput("p_val"),
          p("This means that we can confidently reject the null hypothesis in favor of the alternative hypothesis at 0.005 significance level.")
        ),
        tabPanel("Question 3", value = 3),
        tabPanel("Question 4", value = 4),
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
    
