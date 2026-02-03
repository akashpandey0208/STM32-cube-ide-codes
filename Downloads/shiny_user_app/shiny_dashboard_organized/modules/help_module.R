# ============================================================================
# Help Module - Provide documentation and user guidance
# ============================================================================

# UI Function
helpModuleUI <- function(id) {
  ns <- NS(id)
  
  div(
    class = "page-card",
    h3("Help & Documentation"),
    
    tags$h4("Getting Started"),
    p("Welcome to the Clinical Webapp. This application helps you analyze and visualize clinical data."),
    
    tags$h4("Features"),
    tags$ul(
      tags$li(tags$strong("Data:"), " Upload your CSV dataset to begin analysis."),
      tags$li(tags$strong("Table:"), " View and export your data in an interactive table format."),
      tags$li(tags$strong("Graphs:"), " Create up to 4 simultaneous visualizations including histograms, bar charts, scatter plots, box plots, and line charts."),
      tags$li(tags$strong("Reports:"), " Generate comprehensive reports (coming soon)."),
      tags$li(tags$strong("Help:"), " Access documentation and support.")
    ),
    
    tags$h4("Support"),
    p("For additional support or to report issues, please contact your administrator."),
    
    tags$hr(),
    p(tags$em("Version 2.0 - Modular Architecture"))
  )
}

# Server Function
helpModuleServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    # Placeholder for help functionality
    # Can be extended with interactive tutorials, tooltips, etc.
  })
}
