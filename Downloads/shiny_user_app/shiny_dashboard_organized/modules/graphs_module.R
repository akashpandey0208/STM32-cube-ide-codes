# ============================================================================
# Graphs Module - Create and display visualizations
# ============================================================================

# UI Function
graphsModuleUI <- function(id, dataset, filtered_df, col_info) {
  ns <- NS(id)
  
  if (is.null(dataset()) || nrow(dataset()) == 0) {
    return(div(class = "page-card", h3("Graphs"), p("No data available. Please upload a dataset.")))
  }
  
  div(
    class = "page-card",
    h3("Graphs"),
    fluidRow(
      column(12,
        div(style = "margin-bottom: 20px; padding: 15px; background: #f8f9fa; border-radius: 5px;",
          radioButtons(
            ns("num_slots"),
            "Number of chart slots:",
            choices = c("1" = 1, "2" = 2, "3" = 3, "4" = 4),
            selected = 2,
            inline = TRUE
          )
        )
      )
    ),
    uiOutput(ns("slots_ui"))
  )
}

# Helper to render a single slot UI
renderSlotUI <- function(ns, slot_num, nums, cats, dates) {
  type_id <- ns(paste0("type_slot", slot_num))
  
  tags$div(
    class = "chart-slot",
    style = "border: 1px solid #ddd; border-radius: 8px; padding: 15px; background: white; box-shadow: 0 2px 4px rgba(0,0,0,0.1);",
    
    div(style = "margin-bottom: 10px;",
      tags$strong(paste0("Chart ", slot_num), style = "font-size: 16px; color: #333;")
    ),
    
    selectInput(
      type_id,
      "Chart type:",
      choices = c("None", "Histogram", "Bar", "Scatter", "Box", "Line"),
      selected = "None"
    ),
    
    # Histogram controls
    conditionalPanel(
      condition = sprintf("input['%s'] == 'Histogram'", type_id),
      selectInput(ns(paste0("hist_var_", slot_num)), "Variable", choices = nums, selected = nums[1]),
      sliderInput(ns(paste0("hist_bins_", slot_num)), "Bins", min = 5, max = 100, value = 30)
    ),
    
    # Bar chart controls
    conditionalPanel(
      condition = sprintf("input['%s'] == 'Bar'", type_id),
      selectInput(ns(paste0("bar_x_", slot_num)), "Category (X)", choices = cats, selected = cats[1]),
      selectInput(ns(paste0("bar_y_", slot_num)), "Value (Y, optional)", choices = c("(count)", nums), selected = "(count)")
    ),
    
    # Scatter plot controls
    conditionalPanel(
      condition = sprintf("input['%s'] == 'Scatter'", type_id),
      selectInput(ns(paste0("x_var_", slot_num)), "X variable", choices = nums, selected = nums[1]),
      selectInput(ns(paste0("y_var_", slot_num)), "Y variable", choices = nums, selected = if(length(nums) > 1) nums[2] else nums[1]),
      sliderInput(ns(paste0("alpha_", slot_num)), "Alpha", min = 0.1, max = 1, value = 0.7)
    ),
    
    # Box plot controls
    conditionalPanel(
      condition = sprintf("input['%s'] == 'Box'", type_id),
      selectInput(ns(paste0("box_y_", slot_num)), "Numeric (Y)", choices = nums, selected = nums[1]),
      selectInput(ns(paste0("box_x_", slot_num)), "Group (optional)", choices = c("(none)", cats), selected = "(none)")
    ),
    
    # Line chart controls
    conditionalPanel(
      condition = sprintf("input['%s'] == 'Line'", type_id),
      selectInput(ns(paste0("line_x_", slot_num)), "X (numeric/date)", choices = c(dates, nums), selected = c(dates, nums)[1]),
      selectInput(ns(paste0("line_y_", slot_num)), "Y (numeric)", choices = nums, selected = nums[1])
    ),
    
    # Plot output
    plotlyOutput(ns(paste0("plot_slot", slot_num)), height = "300px")
  )
}

# Server Function
graphsModuleServer <- function(id, dataset, filtered_df, col_info) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Render dynamic slots
    output$slots_ui <- renderUI({
      req(dataset())
      n <- as.integer(input$num_slots)
      if (is.na(n) || n < 1) n <- 2
      
      ci <- col_info()
      nums <- ci$numeric
      cats <- ci$categorical
      dates <- ci$date
      all_cols <- ci$all
      
      if (length(nums) == 0) nums <- all_cols
      if (length(cats) == 0) cats <- all_cols
      
      tags$div(
        class = "graphs-grid",
        style = "display: grid; grid-template-columns: repeat(2, 1fr); gap: 20px; margin-top: 20px;",
        lapply(1:n, function(i) renderSlotUI(ns, i, nums, cats, dates))
      )
    })
    
    # Build plot function
    build_plot <- function(df, type, slot) {
      
      if (type == "Histogram") {
        var <- input[[paste0("hist_var_", slot)]]
        bins <- input[[paste0("hist_bins_", slot)]]
        if (is.null(var) || var == "" || !var %in% names(df)) return(NULL)
        
        vec <- df[[var]]
        if (!is.numeric(vec)) {
          vec <- safe_num(vec)
          if (is.null(vec)) return(NULL)
        }
        
        plot_df <- data.frame(x = vec)
        gg <- ggplot(plot_df, aes(x = x)) +
          geom_histogram(bins = bins, fill = "#2b7a90", color = "white") +
          theme_minimal() +
          labs(x = var, y = "Count")
        return(ggplotly(gg))
      }
      
      if (type == "Bar") {
        x <- input[[paste0("bar_x_", slot)]]
        y <- input[[paste0("bar_y_", slot)]]
        if (is.null(x) || x == "" || !x %in% names(df)) return(NULL)
        
        if (!is.null(y) && y != "(count)" && y %in% names(df)) {
          y_vec <- df[[y]]
          if (!is.numeric(y_vec)) {
            y_vec <- safe_num(y_vec)
            if (is.null(y_vec)) return(NULL)
          }
          agg <- aggregate(y_vec, by = list(cat = df[[x]]), FUN = sum, na.rm = TRUE)
          names(agg) <- c("category", "value")
          y_label <- paste0("Sum of ", y)
        } else {
          agg <- as.data.frame(table(df[[x]]))
          names(agg) <- c("category", "value")
          y_label <- "Count"
        }
        
        gg <- ggplot(agg, aes(x = category, y = value)) +
          geom_col(fill = "#2b7a90") +
          theme_minimal() +
          labs(x = x, y = y_label)
        return(ggplotly(gg))
      }
      
      if (type == "Scatter") {
        xvar <- input[[paste0("x_var_", slot)]]
        yvar <- input[[paste0("y_var_", slot)]]
        alpha <- input[[paste0("alpha_", slot)]]
        if (is.null(xvar) || xvar == "" || !xvar %in% names(df)) return(NULL)
        if (is.null(yvar) || yvar == "" || !yvar %in% names(df)) return(NULL)
        
        x_vec <- df[[xvar]]
        y_vec <- df[[yvar]]
        if (!is.numeric(x_vec)) { x_vec <- safe_num(x_vec); if (is.null(x_vec)) return(NULL) }
        if (!is.numeric(y_vec)) { y_vec <- safe_num(y_vec); if (is.null(y_vec)) return(NULL) }
        
        plot_df <- data.frame(x = x_vec, y = y_vec)
        gg <- ggplot(plot_df, aes(x = x, y = y)) +
          geom_point(alpha = alpha, color = "#2b7a90") +
          theme_minimal() +
          labs(x = xvar, y = yvar)
        return(ggplotly(gg))
      }
      
      if (type == "Box") {
        yvar <- input[[paste0("box_y_", slot)]]
        xvar <- input[[paste0("box_x_", slot)]]
        if (is.null(yvar) || yvar == "" || !yvar %in% names(df)) return(NULL)
        
        y_vec <- df[[yvar]]
        if (!is.numeric(y_vec)) { y_vec <- safe_num(y_vec); if (is.null(y_vec)) return(NULL) }
        
        if (!is.null(xvar) && xvar != "(none)" && xvar %in% names(df)) {
          plot_df <- data.frame(x = df[[xvar]], y = y_vec)
          gg <- ggplot(plot_df, aes(x = x, y = y)) +
            geom_boxplot(fill = "#2b7a90", alpha = 0.7) +
            theme_minimal() +
            labs(x = xvar, y = yvar)
        } else {
          plot_df <- data.frame(y = y_vec)
          gg <- ggplot(plot_df, aes(y = y)) +
            geom_boxplot(fill = "#2b7a90", alpha = 0.7) +
            theme_minimal() +
            labs(y = yvar)
        }
        return(ggplotly(gg))
      }
      
      if (type == "Line") {
        xvar <- input[[paste0("line_x_", slot)]]
        yvar <- input[[paste0("line_y_", slot)]]
        if (is.null(xvar) || xvar == "" || !xvar %in% names(df)) return(NULL)
        if (is.null(yvar) || yvar == "" || !yvar %in% names(df)) return(NULL)
        
        x_vec <- df[[xvar]]
        y_vec <- df[[yvar]]
        
        if (!inherits(x_vec, "Date") && !is.numeric(x_vec)) {
          convd <- safe_date(x_vec)
          if (!is.null(convd)) { x_vec <- convd } else { x_vec <- safe_num(x_vec) }
          if (is.null(x_vec)) return(NULL)
        }
        if (!is.numeric(y_vec)) { y_vec <- safe_num(y_vec); if (is.null(y_vec)) return(NULL) }
        
        plot_df <- data.frame(x = x_vec, y = y_vec)
        gg <- ggplot(plot_df, aes(x = x, y = y)) +
          geom_line(color = "#2b7a90", linewidth = 1) +
          theme_minimal() +
          labs(x = xvar, y = yvar)
        return(ggplotly(gg))
      }
      
      return(NULL)
    }
    
    # Render plots for each slot
    lapply(1:4, function(slot) {
      output[[paste0("plot_slot", slot)]] <- renderPlotly({
        req(dataset())
        req(filtered_df())
        df <- filtered_df()
        req(nrow(df) > 0)
        
        type <- input[[paste0("type_slot", slot)]]
        req(type)
        req(type != "None")
        
        tryCatch({
          build_plot(df, type, slot)
        }, error = function(e) {
          NULL
        })
      })
    })
    
  })
}

