# ============================================================================
# Data Module - Handle dataset upload and preview
# ============================================================================

# UI Function
dataModuleUI <- function(id, dataset) {
  ns <- NS(id)
  
  div(
    class = "page-card",
    h3("Data"),
    fluidRow(
      column(6, fileInput(ns("file"), "Upload dataset (.csv)", accept = c("text/csv", ".csv")))
    )
  )
}

# Server Function
dataModuleServer <- function(id, dataset) {
  moduleServer(id, function(input, output, session) {
    
    # Handle file upload
    observeEvent(input$file, {
      req(input$file)
      df <- read.csv(input$file$datapath, stringsAsFactors = FALSE)
      df <- sanitize_df(df)
      dataset(df)
      showNotification("Dataset uploaded successfully!", type = "message")
    })
    
  })
}
