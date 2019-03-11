library("shiny")
library("dplyr")
library("shinythemes")
library("DT")
library("shinyWidgets")

ui <- fluidPage(
  themeSelector(),
  #theme = shinytheme("cosmo"),
  setBackgroundColor("#e6e6fa"),
  titlePanel("Add title here"),
  sidebarLayout(
    sidebarPanel(
      h3("Controls"),
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
                       h3("Datasets")
      )
    ),
    mainPanel(
      h3("Display"),
      tabsetPanel(
        tabPanel("Question 1", value = 1),
        tabPanel("Question 2", value = 2),
        tabPanel("Question 3", value = 3),
        tabPanel("Question 4", value = 4),
        tabPanel("Data", value = 5,
                 dataTableOutput(outputId = "table"), width = "100%"),
        id = "tabselected"
      )
    )
  )
)
    
