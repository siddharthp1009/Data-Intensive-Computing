library(shiny)

ui <- pageWithSidebar(
  
  # App title ----
  headerPanel("Twitter Data Analytics"),
  
  # Sidebar panel for inputs ----
  sidebarPanel(
    
    
      selectInput("variable", "Select the Type of Map:", 
                c("CDC Map" = "CDC Map",
                  "Twitter Map" = "Twitter Map",
                  "CDC vs Twitter for Keyword: all" = "CDC vs Twitter for Keyword-all",
                  "CDC vs Twitter for Keyword: #influenza" = "CDC vs Twitter for Keyword-#influenza",
                  "CDC vs Twitter for Keyword: #flu" = "CDC vs Twitter for Keyword-#flu"))
    
    # Input: Checkbox for whether outliers should be included ----
   # checkboxInput("outliers", "Show outliers", TRUE)
    
    
    
    
  ),
  
  # Main panel for displaying outputs ----
  mainPanel(
    
    
    h3(textOutput("disText")),
    imageOutput("preImage")
    
    
   # fluidRow(
  #    splitLayout(cellWidths = c("50%", "50%"),  plotOutput("preImage",width = "100%"),  plotOutput("preImage",width = "100%"))
  #  )
  )
)


# Define server logic to plot various variables against mpg ----
server <- function(input, output) {
  
    
  displayText <- reactive({
    paste(input$variable)
  })
  
  
  output$disText <- renderText({
    displayText()
  })
  
  output$preImage <- renderImage({
    filename <- normalizePath(file.path(dirname(rstudioapi::getSourceEditorContext()$path),
                                        paste(input$variable, '.jpeg', sep='')))
    
    # Return a list containing the filename and alt text
    list(src = filename)
    
  }, deleteFile = FALSE)
  
  
}

shinyApp(ui, server)

