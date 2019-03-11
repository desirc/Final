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
        tabPanel("Question 1", value = 1),
        tabPanel("Question 2", value = 2),
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
    
