library("shiny")
library("shinythemes")

# Define UI for application that draws a histogram
shinyUI(fluidPage(theme = shinytheme("slate"),
                  
  # Title place holder for project 
  titlePanel("Final Project (Change Title)"),
  
  # Creation of SideBar and Widgets 
  sidebarLayout(
    sidebarPanel(
      radioButtons("parameter.key", "Select Parameter",
                   choices = c("Overview", "Income", "Age", "Ethnicity", "Education")),
      # Slider Inputs to set the parameter that needs to be analysed 
      # parameter = Income, Age, Ethnicity, Education   
      selectInput("parameter.key", "Select Parameter", choices = c("Overview", "Income", "Age", "Ethnicity", "Education"), multiple = FALSE)
      
      ),
    mainPanel(
      textOutput("out.text"),
      plotOutput("base.map", width = "100%", click = "plot_click"),
      plotlyOutput("pie"),
      plotlyOutput("county.age.bar"),
      plotlyOutput("county.race.bar")
      )
    )
  )
)