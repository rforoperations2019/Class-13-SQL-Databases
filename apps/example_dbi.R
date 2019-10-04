# DBI Example
# THIS IS AN EXAMPLE APPLICATION IT WILL NOT RUN

library(shiny)
library(DBI)
library(pool)

# You should always store credentials and keys in a file or enviornmental variable and have it ignored in your Git repository
creds <- jsonlite::fromJSON(".creds.json")

# Create the DB Connection
pool <- dbPool(odbc::odbc(), driver = "FreeTDS", server = "IP_or_HOST_ADDRESS", port = 1433, database = "DBName", uid = creds$un, pwd = creds$pw, TDS_Version = "8.0")

# Get some stuff for UI
conn <- poolCheckout(pool)
selections <- sort(dbGetQuery(conn, "SELECT DISTINCT(TYPE) FROM Database.dbo.Things")$TYPE)
poolReturn(conn)

# Define UI for application
ui <- fluidPage(
   
   # Application title
   titlePanel("Database Dashboard"),
   
   # Sidebar 
   sidebarLayout(
      sidebarPanel(
        # Date selection
         sdateRangeInput("dates",
                         "Select Dates",
                         start = Sys.Date()-30,
                         end = Sys.Date()),
         # Something selction
         selectInput("select",
                     "Selections",
                     choices = selections,
                     selected = "Some Type")
      ),
      
      # Show plot
      mainPanel(
         plotOutput("examplePlot")
      )
   )
)

# Define server logic
server <- function(input, output) {
   dataLoad <- reactive({
     # Generate SQL Statement which handles all filtering
     sql <- paste0("SELECT * FROM SOME_DATABASE WHERE DATE_COLUMN BETWEEN '", input$dates[1], "' AND '", input$dates[2], "' AND TYPE = ", input$select)
     # Run SQL Statement
     onn <- poolCheckout(pool)
     data <- dbGetQuery(conn, sql)
     poolReturn(conn)
     
     return(data)
   })
   output$examplePlot <- renderPlot({
     data <- dataLoad()
       
     ggplot(table, aes(x = STATUS, y = count, fill = STATUS)) +
       geom_bar()
   })
   onStop(
     poolClose(pool)
   )
}

# Run the application 
shinyApp(ui = ui, server = server)

