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
          fluidRow(
            column(6,
              radioButtons(
                ns("num_slots"),
                "Number of chart slots:",
                choices = c("1" = 1, "2" = 2, "3" = 3, "4" = 4),
                selected = 2,
                inline = TRUE
              )
            ),
            column(6,
              div(style = "padding-top: 25px;",
                actionButton(ns("reset_all"), "Reset All Charts", class = "btn-warning", icon = icon("rotate-right"))
              )
            )
          )
        )
      )
    ),
    uiOutput(ns("slots_container"))
  )
}

# Helper to render a single slot's controls and plot dynamically
renderSlotUI <- function(ns, slot_num, col_info) {
  # Get column choices
  ci <- col_info()
  all_cols <- ci$all
  nums <- ci$numeric
  cats <- ci$categorical
  dates <- ci$date
  
  if (length(nums) == 0) nums <- all_cols
  if (length(cats) == 0) cats <- character(0)
  
  tags$div(
    class = "chart-slot",
    style = "border: 1px solid #ddd; border-radius: 8px; padding: 15px; background: white; box-shadow: 0 2px 4px rgba(0,0,0,0.1);",
    div(style = "display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px;",
      tags$strong(paste0("Chart ", slot_num), style = "font-size: 16px; color: #333;"),
      actionButton(ns(paste0("remove_slot", slot_num)), "Clear", class = "btn-sm btn-danger", style = "padding: 2px 10px;")
    ),
    selectInput(
      ns(paste0("type_slot", slot_num)),
      "Chart type:",
      choices = c("None", "Histogram", "Bar", "Scatter", "Box", "Line"),
      selected = "None"
    ),
    
    # Histogram controls
    conditionalPanel(
      sprintf("input['%s'] == 'Histogram'", ns(paste0("type_slot", slot_num))),
      selectInput(ns(paste0("hist_var_", slot_num)), "Variable", choices = nums, selected = if(length(nums) > 0) nums[1] else NULL),
      sliderInput(ns(paste0("hist_bins_", slot_num)), "Bins", min = 5, max = 100, value = 30)
    ),
    
    # Bar chart controls
    conditionalPanel(
      sprintf("input['%s'] == 'Bar'", ns(paste0("type_slot", slot_num))),
      selectInput(ns(paste0("bar_x_", slot_num)), "Category (X)", choices = if (length(cats) > 0) cats else all_cols, selected = if (length(cats) > 0) cats[1] else if(length(all_cols) > 0) all_cols[1] else NULL),
      selectInput(ns(paste0("bar_y_", slot_num)), "Value (Y, optional)", choices = c('(count)', nums), selected = '(count)')
    ),
    
    # Scatter plot controls
    conditionalPanel(
      sprintf("input['%s'] == 'Scatter'", ns(paste0("type_slot", slot_num))),
      selectInput(ns(paste0("x_var_", slot_num)), "X variable", choices = all_cols, selected = if(length(all_cols) > 0) all_cols[1] else NULL),
      selectInput(ns(paste0("y_var_", slot_num)), "Y variable", choices = all_cols, selected = if(length(all_cols) > 1) all_cols[2] else NULL),
      selectInput(ns(paste0("color_var_", slot_num)), "Color (optional)", choices = c('(none)', if (length(cats) > 0) cats else all_cols), selected = '(none)'),
      sliderInput(ns(paste0("alpha_", slot_num)), "Alpha", min = 0.1, max = 1, value = 0.8)
    ),
    
    # Box plot controls
    conditionalPanel(
      sprintf("input['%s'] == 'Box'", ns(paste0("type_slot", slot_num))),
      selectInput(ns(paste0("box_y_", slot_num)), "Numeric (Y)", choices = nums, selected = if(length(nums) > 0) nums[1] else NULL),
      selectInput(ns(paste0("box_x_", slot_num)), "Group (optional)", choices = c('(none)', if (length(cats) > 0) cats else all_cols), selected = '(none)')
    ),
    
    # Line chart controls
    conditionalPanel(
      sprintf("input['%s'] == 'Line'", ns(paste0("type_slot", slot_num))),
      selectInput(ns(paste0("line_x_", slot_num)), "X (numeric/date)", choices = c(dates, nums), selected = if(length(c(dates, nums)) > 0) c(dates, nums)[1] else NULL),
      selectInput(ns(paste0("line_y_", slot_num)), "Y (numeric)", choices = nums, selected = if(length(nums) > 0) nums[1] else NULL)
    ),
    div(style = "margin-top: 15px; min-height: 300px;",
      plotlyOutput(ns(paste0("plot_slot", slot_num)), height = "300px")
    
    plotlyOutput(ns(paste0("plot_slot", slot_num)), height = "220px")
  )
}

# Server Function
graphsModuleServer <- function(id, dataset, filtered_df, col_info) {
  moduleServer(id, function(input, output, session) {
    
    # Render dynamic slots based on user selection
    output$slots_container <- renderUI({
      num <- as.numeric(input$num_slots)
      if (is.null(num) || is.na(num)) num <- 2
      
      ns <- session$ns
      ci <- col_info()
      
      # Create slots in a 2x2 grid
      slot_list <- lapply(1:num, function(i) {
        renderSlotUI(ns, i, col_info)
      })
      
      # Arrange in 2 columns
      tags$div(
        class = "graphs-grid",
        style = "display: grid; grid-template-columns: repeat(2, 1fr); gap: 20px; margin-top: 20px;",
        slot_list
      )
    })
    
    # Reset all charts
    observeEvent(input$reset_all, {
      for (i in 1:4) {
        updateSelectInput(session, paste0('type_slot', i), selected = 'None')
      }
      showNotification("All charts reset", type = "message")
    })
    
    # Plot building function (inside module to access input)
    build_plot <- function(df, type, slot) {
      if (is.null(type) || type == "None") return(NULL)
      p <- NULL
      
      if (type == "Histogram") {
        var <- input[[paste0('hist_var_', slot)]]
        bins <- input[[paste0('hist_bins_', slot)]]
        if (is.null(var) || var == "" || !(var %in% names(df))) return(NULL)
        
        vec <- df[[var]]
        if (!is.numeric(vec)) {
          conv <- safe_num(vec)
          if (is.null(conv)) {
            showNotification(paste0('Could not coerce ', var, ' to numeric for histogram.'), type = 'error')
            return(NULL)
          }
          df[[var]] <- conv
        }
        gg <- ggplot(df, aes_string(x = var)) + 
          geom_histogram(bins = bins, fill = '#2b7a90', color = 'white') + 
          theme_minimal()
        p <- ggplotly(gg)
        return(p)
        
      } else if (type == "Bar") {
        x <- input[[paste0('bar_x_', slot)]]
        y <- input[[paste0('bar_y_', slot)]]
        if (is.null(x) || x == "" || !(x %in% names(df))) return(NULL)
        
        if (!is.null(y) && y != '(count)' && y %in% names(df)) {
          yvec <- df[[y]]
          if (!is.numeric(yvec)) {
            conv <- safe_num(yvec)
            if (is.null(conv)) {
              showNotification(paste0('Could not coerce ', y, ' to numeric for bar aggregation.'), type = 'error')
              return(NULL)
            }
            df[[y]] <- conv
          }
          agg <- df %>% group_by(.data[[x]]) %>% summarize(value = sum(.data[[y]], na.rm = TRUE))
          gg <- ggplot(agg, aes_string(x = x, y = 'value')) + 
            geom_col(fill = '#2b7a90') + 
            theme_minimal()
          p <- ggplotly(gg)
          return(p)
        } else {
          agg <- df %>% group_by(.data[[x]]) %>% summarize(value = dplyr::n())
          gg <- ggplot(agg, aes_string(x = x, y = 'value')) + 
            geom_col(fill = '#2b7a90') + 
            theme_minimal()
          p <- ggplotly(gg)
          return(p)
        }
        
      } else if (type == "Scatter") {
        x <- input[[paste0('x_var_', slot)]]
        y <- input[[paste0('y_var_', slot)]]
        if (is.null(x) || x == "" || is.null(y) || y == "" || !(x %in% names(df)) || !(y %in% names(df))) return(NULL)
        
        if (!is.numeric(df[[x]])) {
          convx <- safe_num(df[[x]])
          if (!is.null(convx)) df[[x]] <- convx
        }
        if (!is.numeric(df[[y]])) {
          convy <- safe_num(df[[y]])
          if (!is.null(convy)) df[[y]] <- convy
        }
        if (!is.numeric(df[[x]]) || !is.numeric(df[[y]])) {
          showNotification('Scatter requires numeric X and Y (coercion failed).', type = 'error')
          return(NULL)
        }
        gg <- ggplot(df, aes_string(x = x, y = y)) + 
          geom_point(alpha = 0.7) + 
          theme_minimal()
        p <- ggplotly(gg)
        return(p)
        
      } else if (type == "Box") {
        y <- input[[paste0('box_y_', slot)]]
        x <- input[[paste0('box_x_', slot)]]
        if (is.null(y) || y == "" || !(y %in% names(df))) return(NULL)
        
        if (!is.numeric(df[[y]])) {
          convy <- safe_num(df[[y]])
          if (is.null(convy)) {
            showNotification(paste0('Boxplot requires numeric Y; could not coerce ', y), type = 'error')
            return(NULL)
          }
          df[[y]] <- convy
        }
        if (!is.null(x) && x != '(none)' && x %in% names(df)) {
          gg <- ggplot(df, aes_string(x = x, y = y)) + geom_boxplot() + theme_minimal()
        } else {
          gg <- ggplot(df, aes_string(y = y)) + geom_boxplot() + theme_minimal()
        }
        return(p)
        p <- ggplotly(gg)
        
      } else if (type == "Line") {
        x <- input[[paste0('line_x_', slot)]]
        y <- input[[paste0('line_y_', slot)]]
        if (is.null(x) || x == "" || is.null(y) || y == "" || !(x %in% names(df)) || !(y %in% names(df))) return(NULL)
        
        if (!inherits(df[[x]], 'Date')) {
          convd <- safe_date(df[[x]])
          if (!is.null(convd)) df[[x]] <- convd
        }
        if (!is.numeric(df[[y]])) {
          convy <- safe_num(df[[y]])
          if (is.null(convy)) {
            showNotification('Line requires numeric Y (coercion failed).', type = 'error')
            return(NULL)
          }
          df[[y]] <- convy
        }
        if (!inherits(df[[x]], 'Date') && !is.numeric(df[[x]])) {
          showNotification('Line X should be date or numeric (coercion failed).', type = 'error')
          return(NULL)
        }
        gg <- ggplot(df, aes_string(x = x, y = y, group = 1)) + 
          geom_line() + 
          theme_minimal()
        return(p)
      }
      
      return(NULL)
      p
    }
    
    # Update variable choices when dataset changes
    observe({
      ci <- col_info()
      all_cols <- ci$all
      nums <- ci$numeric (all 4 possible slots)
    for (i in 1:4) {
      local({
        slot <- i
        output[[paste0('plot_slot', slot)]] <- renderPlotly({
          # Only render if this slot is visible based on num_slots
          num <- as.numeric(input$num_slots)
          if (is.null(num) || is.na(num)) num <- 2
          req(slot <= num)
          
        # Get current chart type to determine if we should set selected values
        current_type <- input[[paste0("type_slot", i)]]
        
        updateSelectInput(session, paste0("hist_var_", i), choices = nums, 
                         selected = if (!is.null(current_type) && current_type == "Histogram" && length(nums) > 0) nums[1] else character(0))
        updateSliderInput(session, paste0("hist_bins_", i), value = 30)
        updateSelectInput(session, paste0("bar_x_", i), choices = if (length(cats) > 0) cats else all_cols,
                         selected = if (!is.null(current_type) && current_type == "Bar") {if (length(cats) > 0) cats[1] else all_cols[1]} else character(0))
        updateSelectInput(session, paste0("bar_y_", i), choices = c('(count)', nums), selected = '(count)')
        updateSelectInput(session, paste0("x_var_", i), choices = all_cols,
                         selected = if (!is.null(current_type) && current_type == "Scatter" && length(all_cols) > 0) all_cols[1] else character(0))
        updateSelectInput(session, paste0("y_var_", i), choices = all_cols,
                         selected = if (!is.null(current_type) && current_type == "Scatter" && length(all_cols) > 1) all_cols[2] else character(0))
        updateSelectInput(session, paste0("color_var_", i), choices = c('(none)', if (length(cats) > 0) cats else all_cols), selected = '(none)')
        updateSelectInput(session, paste0("box_y_", i), choices = nums,
                         selected = if (!is.null(current_type) && current_type == "Box" && length(nums) > 0) nums[1] else character(0))
        updateSelectInput(session, paste0("box_x_", i), choices = c('(none)', cats), selected = '(none)')
        updateSelectInput(session, paste0("line_x_", i), choices = c(dates, nums),
                         selected = if (!is.null(current_type) && current_type == "Line" && length(c(dates, nums)) > 0) c(dates, nums)[1] else character(0))
        updateSelectInput(session, paste0("line_y_", i), choices = nums,
                         selected = if (!is.null(current_type) && current_type == "Line" && length(nums) > 0) nums[1] else character(0))
      }
    })
    
    # Render plots for each slot
    for (i in 1:4) {
      local({
        slot <- i
        output[[paste0('plot_slot', slot)]] <- renderPlotly({
          req(dataset())
          req(filtered_df())
          df <- filtered_df()
          req(nrow(df) > 0)
          
          type <- input[[paste0('type_slot', slot)]]
          req(!is.null(type), type != "None")
          
          # Add specific requirements based on chart type
          if (type == "Histogram") {
            req(input[[paste0('hist_var_', slot)]])
          } else if (type == "Bar") {
            req(input[[paste0('bar_x_', slot)]])
          } else if (type == "Scatter") {
            req(input[[paste0('x_var_', slot)]], input[[paste0('y_var_', slot)]])
          } else if (type == "Box") {
            req(input[[paste0('box_y_', slot)]])
          } else if (type == "Line") {
            req(input[[paste0('line_x_', slot)]], input[[paste0('line_y_', slot)]])
          }
          
          build_plot(df, type, slot)
        })
      })
    }
    
    # Remove button handlers
    for (i in 1:4) {
      local({
        slot <- i
        observeEvent(input[[paste0('remove_slot', slot)]], {
          updateSelectInput(session, paste0('type_slot', slot), selected = 'None')
          updateSelectInput(session, paste0('hist_var_', slot), selected = '')
          updateSliderInput(session, paste0('hist_bins_', slot), value = 30)
          ci <- col_info()
          updateSelectInput(session, paste0('bar_x_', slot), selected = if (length(ci$categorical) > 0) ci$categorical[1] else ci$all[1])
          updateSelectInput(session, paste0('bar_y_', slot), selected = '(count)')
          updateSelectInput(session, paste0('x_var_', slot), selected = '')
          updateSelectInput(session, paste0('y_var_', slot), selected = '')
          updateSelectInput(session, paste0('color_var_', slot), selected = '(none)')
          updateSelectInput(session, paste0('box_y_', slot), selected = '')
          updateSelectInput(session, paste0('box_x_', slot), selected = '(none)')
          updateSelectInput(session, paste0('line_x_', slot), selected = '')
          updateSelectInput(session, paste0('line_y_', slot), selected = '')
          showNotification(paste('Slot', slot, 'reset'), type = 'message')
        })
      })
    }
    
  })
}

