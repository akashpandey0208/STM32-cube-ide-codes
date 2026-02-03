# ============================================================================
# Table Module - Display and export data tables
# ============================================================================

# UI Function
tableModuleUI <- function(id, dataset, filtered_df) {
  ns <- NS(id)
  
  if (is.null(dataset()) || nrow(dataset()) == 0) {
    return(div(class = "page-card", h3("Table"), p("No data available. Please upload a dataset.")))
  }
  
  div(
    class = "page-card",
    h3("Table"),
    DTOutput(ns("data_table"))
  )
}

# Server Function
tableModuleServer <- function(id, dataset, filtered_df, col_info) {
  moduleServer(id, function(input, output, session) {
    
    # Render data table
    output$data_table <- renderDT({
      req(dataset())
      df2 <- filtered_df()
      cols <- if (!is.null(input$show_cols) && length(input$show_cols) > 0) {
        input$show_cols
      } else {
        names(df2)
      }
      
      datatable(
        df2[, cols, drop = FALSE],
        extensions = c('Buttons'),
        options = list(
          dom = 'Bfrtip',
          buttons = c('copy', 'csv', 'excel'),
          pageLength = 10,
          scrollX = TRUE
        ),
        selection = list(mode = 'multiple', selected = NULL),
        rownames = FALSE
      )
    })
    
    # Download selected rows handler
    output$download_selected <- downloadHandler(
      filename = function() { 
        paste0("selected_rows_", Sys.Date(), ".csv") 
      },
      content = function(file) {
        req(dataset())
        df <- filtered_df()
        selected <- input$data_table_rows_selected
        if (is.null(selected) || length(selected) == 0) {
          write.csv(df, file, row.names = FALSE)
        } else {
          write.csv(df[selected, , drop = FALSE], file, row.names = FALSE)
        }
      }
    )
    
  })
}
