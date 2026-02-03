# ============================================================================
# Data Module - Handle dataset upload and preview with Explorer
# ============================================================================

# UI Function
dataModuleUI <- function(id, dataset) {
  ns <- NS(id)
  
  div(
    class = "data-explorer-container",
    
    # Left Panel - Explorer
    div(
      class = "explorer-panel",
      div(class = "explorer-header", "Explorer"),
      div(
        class = "explorer-content",
        # Dataset View Section
        div(
          class = "explorer-section",
          div(
            class = "explorer-section-header",
            icon("folder-open"),
            span("Dataset View")
          ),
          div(
            class = "explorer-tree",
            uiOutput(ns("explorer_tree"))
          )
        ),
        # Graphs Section
        div(
          class = "explorer-section",
          div(
            class = "explorer-section-header collapsed",
            icon("chart-bar"),
            span("Graphs")
          )
        )
      )
    ),
    
    # Right Panel - Upload Area
    div(
      class = "upload-panel",
      
      # File Type Tabs
      div(
        class = "file-type-tabs",
        actionButton(ns("tab_edc"), "EDC", class = "file-tab active"),
        actionButton(ns("tab_sdtm"), "SDTM", class = "file-tab"),
        actionButton(ns("tab_adam"), "ADaM", class = "file-tab")
      ),
      
      # Upload Area (dynamic based on file type)
      div(
        class = "upload-area",
        uiOutput(ns("upload_area_content"))
      ),
      
      # Navigation Buttons
      div(
        class = "navigation-buttons",
        actionButton(ns("back_btn"), "BACK", class = "nav-btn-secondary"),
        actionButton(ns("next_btn"), "NEXT", class = "nav-btn-primary")
      ),
      
      # Data Viewer/Converter Modal
      uiOutput(ns("data_viewer_modal"))
    )
  )
}

# Server Function
dataModuleServer <- function(id, dataset) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Reactive values for state management
    rv <- reactiveValues(
      current_file_type = "EDC",  # EDC, SDTM, or ADaM
      data_structure = list(
        EDC = list(),
        SDTM = list(),
        ADaM = list()
      ),
      selected_project = NULL,
      selected_date = NULL,
      selected_file = NULL,
      selected_file_data = NULL,
      show_viewer = FALSE
    )
    
    # Tab switching
    observeEvent(input$tab_edc, {
      rv$current_file_type <- "EDC"
      shinyjs::runjs(sprintf("
        $('#%s').addClass('active').siblings('.file-tab').removeClass('active');
      ", ns("tab_edc")))
    })
    
    observeEvent(input$tab_sdtm, {
      rv$current_file_type <- "SDTM"
      shinyjs::runjs(sprintf("
        $('#%s').addClass('active').siblings('.file-tab').removeClass('active');
      ", ns("tab_sdtm")))
    })
    
    observeEvent(input$tab_adam, {
      rv$current_file_type <- "ADaM"
      shinyjs::runjs(sprintf("
        $('#%s').addClass('active').siblings('.file-tab').removeClass('active');
      ", ns("tab_adam")))
    })
    
    # Dynamic upload area based on file type
    output$upload_area_content <- renderUI({
      file_type <- rv$current_file_type
      
      if (file_type == "EDC") {
        # EDC: Full upload interface for raw data
        div(
          class = "upload-dropzone",
          icon("upload", class = "upload-icon"),
          div(
            class = "upload-message",
            h3("Upload Raw Clinical Data"),
            p("Upload CSV or Excel files from EDC systems, labs, or clinical sites")
          ),
          div(class = "upload-actions",
            actionButton(ns("new_upload"), "New Upload", class = "upload-btn"),
            actionButton(ns("replace_existing"), "Replace Existing", class = "upload-btn-secondary")
          )
        )
      } else if (file_type == "SDTM") {
        # SDTM: Info message + option for pre-converted files
        div(
          class = "info-dropzone",
          icon("file-export", class = "info-icon"),
          div(
            class = "info-message",
            h3("SDTM Data (Standardized Format)"),
            p("This tab displays CDISC SDTM datasets created from EDC data."),
            tags$ul(
              tags$li(icon("check-circle"), " Click files in Explorer to view/convert from EDC"),
              tags$li(icon("check-circle"), " Export to XPT format (FDA submission)"),
              tags$li(icon("check-circle"), " Upload existing SDTM XPT files if already converted")
            )
          ),
          hr(),
          div(
            class = "upload-actions-secondary",
            actionButton(ns("new_upload"), "Upload Existing SDTM Files", 
                        class = "upload-btn-outline",
                        icon = icon("file-import"))
          )
        )
      } else if (file_type == "ADaM") {
        # ADaM: Info message + option for pre-converted files
        div(
          class = "info-dropzone",
          icon("chart-line", class = "info-icon"),
          div(
            class = "info-message",
            h3("ADaM Data (Analysis-Ready Format)"),
            p("This tab displays ADaM analysis datasets derived from SDTM."),
            tags$ul(
              tags$li(icon("check-circle"), " Click SDTM files in Explorer to create ADaM"),
              tags$li(icon("check-circle"), " Add derivations (BASE, CHG, PCHG)"),
              tags$li(icon("check-circle"), " Upload existing ADaM XPT files if already created")
            )
          ),
          hr(),
          div(
            class = "upload-actions-secondary",
            actionButton(ns("new_upload"), "Upload Existing ADaM Files", 
                        class = "upload-btn-outline",
                        icon = icon("file-import"))
          )
        )
      }
    })
    
    # Render Explorer Tree
    output$explorer_tree <- renderUI({
      file_type <- rv$current_file_type
      structure <- rv$data_structure[[file_type]]
      
      if (length(structure) == 0) {
        return(div(class = "explorer-empty", "No data uploaded yet"))
      }
      
      # Build tree structure with clickable files
      tree_items <- lapply(names(structure), function(project) {
        project_data <- structure[[project]]
        
        # Project level
        project_content <- lapply(names(project_data), function(date) {
          date_data <- project_data[[date]]
          
          # Date level - make files clickable
          file_items <- lapply(seq_along(date_data$files), function(i) {
            file_info <- date_data$files[[i]]
            file_id <- paste(file_type, project, date, i, sep = "_")
            
            tags$div(
              class = "tree-item tree-file clickable-file",
              onclick = sprintf(
                "Shiny.setInputValue('%s', {type: '%s', project: '%s', date: '%s', index: %d}, {priority: 'event'})",
                ns("file_clicked"), file_type, project, date, i
              ),
              icon("file"),
              span(file_info$name)
            )
          })
          
          div(
            class = "tree-item tree-date",
            icon("calendar"),
            span(date),
            div(class = "tree-children", file_items)
          )
        })
        
        div(
          class = "tree-item tree-project",
          icon("folder"),
          span(project),
          div(class = "tree-children", project_content)
        )
      })
      
      div(
        class = "tree-root",
        div(
          class = "tree-item tree-filetype",
          icon("database"),
          span(file_type),
          div(class = "tree-children", tree_items)
        )
      )
    })
    
    # New Upload Button - Show modal for project/date selection
    observeEvent(input$new_upload, {
      
      file_type <- rv$current_file_type
      
      # Determine title and accepted formats based on file type
      modal_title <- switch(file_type,
        "EDC" = "Upload Raw Clinical Data",
        "SDTM" = "Upload Existing SDTM Files",
        "ADaM" = "Upload Existing ADaM Files"
      )
      
      accepted_formats <- switch(file_type,
        "EDC" = c("text/csv", ".csv", ".xlsx", ".xls", ".xml", ".json"),
        "SDTM" = c(".xpt", ".sas7bdat", ".csv", ".xml"),
        "ADaM" = c(".xpt", ".sas7bdat", ".csv")
      )
      
      help_text <- switch(file_type,
        "EDC" = "Upload CSV, Excel, or XML files from EDC systems",
        "SDTM" = "Upload XPT or SAS7BDAT files (CDISC SDTM format)",
        "ADaM" = "Upload XPT or SAS7BDAT files (CDISC ADaM format)"
      )
      
      showModal(
        modalDialog(
          title = modal_title,
          size = "m",
          
          div(
            class = "alert alert-info",
            icon("info-circle"),
            " ", help_text
          ),
          
          textInput(ns("project_name"), "Project Name", 
                   placeholder = "Enter project name or select existing"),
          
          selectInput(ns("existing_project"), "Or Select Existing Project",
                     choices = c("-- New Project --", 
                                names(rv$data_structure[[file_type]]))),
          
          dateInput(ns("upload_date"), "Date", value = Sys.Date()),
          
          fileInput(ns("files_to_upload"), "Select Files",
                   multiple = TRUE,
                   accept = accepted_formats),
          
          footer = tagList(
            actionButton(ns("cancel_upload"), "Cancel"),
            actionButton(ns("confirm_upload"), "Upload", class = "btn-primary")
          ),
          easyClose = TRUE
        )
      )
    })
    
    # Cancel Upload
    observeEvent(input$cancel_upload, {
      removeModal()
    })
    
    # Confirm Upload
    observeEvent(input$confirm_upload, {
      req(input$files_to_upload)
      
      # Determine project name
      project <- if (input$existing_project != "-- New Project --") {
        input$existing_project
      } else {
        req(input$project_name)
        input$project_name
      }
      
      date_str <- as.character(input$upload_date)
      file_type <- rv$current_file_type
      
      # Initialize structure if needed
      if (is.null(rv$data_structure[[file_type]][[project]])) {
        rv$data_structure[[file_type]][[project]] <- list()
      }
      
      if (is.null(rv$data_structure[[file_type]][[project]][[date_str]])) {
        rv$data_structure[[file_type]][[project]][[date_str]] <- list(files = list())
      }
      
      # Add files
      for (i in seq_len(nrow(input$files_to_upload))) {
        file_info <- list(
          name = input$files_to_upload$name[i],
          path = input$files_to_upload$datapath[i],
          size = input$files_to_upload$size[i],
          type = input$files_to_upload$type[i],
          uploaded_at = Sys.time()
        )
        
        rv$data_structure[[file_type]][[project]][[date_str]]$files <- 
          c(rv$data_structure[[file_type]][[project]][[date_str]]$files, list(file_info))
        
        # If CSV, load first one into dataset
        if (i == 1 && grepl("\\.csv$", file_info$name, ignore.case = TRUE)) {
          tryCatch({
            df <- read.csv(file_info$path, stringsAsFactors = FALSE)
            df <- sanitize_df(df)
            dataset(df)
          }, error = function(e) {
            showNotification(paste("Error reading CSV:", e$message), type = "error")
          })
        }
      }
      
      showNotification(
        sprintf("Uploaded %d file(s) to %s > %s > %s", 
               nrow(input$files_to_upload), file_type, project, date_str),
        type = "message"
      )
      
      removeModal()
    })
    
    # Handle file click in tree
    observeEvent(input$file_clicked, {
      req(input$file_clicked)
      
      file_type <- input$file_clicked$type
      project <- input$file_clicked$project
      date <- input$file_clicked$date
      index <- input$file_clicked$index
      
      # Get file info
      file_info <- rv$data_structure[[file_type]][[project]][[date]]$files[[index]]
      
      # Load file data
      tryCatch({
        if (grepl("\\.csv$", file_info$name, ignore.case = TRUE)) {
          rv$selected_file_data <- read.csv(file_info$path, stringsAsFactors = FALSE)
        } else if (grepl("\\.xlsx?$", file_info$name, ignore.case = TRUE)) {
          if (requireNamespace("readxl", quietly = TRUE)) {
            rv$selected_file_data <- as.data.frame(readxl::read_excel(file_info$path))
          } else {
            showNotification("Install 'readxl' package to read Excel files", type = "warning")
            return()
          }
        } else if (grepl("\\.xpt$", file_info$name, ignore.case = TRUE)) {
          if (requireNamespace("haven", quietly = TRUE)) {
            rv$selected_file_data <- as.data.frame(haven::read_xpt(file_info$path))
          } else {
            showNotification("Install 'haven' package to read XPT files", type = "warning")
            return()
          }
        } else {
          showNotification("Unsupported file format for viewing", type = "warning")
          return()
        }
        
        rv$selected_file <- file_info
        rv$show_viewer <- TRUE
        
      }, error = function(e) {
        showNotification(paste("Error reading file:", e$message), type = "error")
      })
    })
    
    # Data Viewer/Converter Modal
    observe({
      if (rv$show_viewer && !is.null(rv$selected_file_data)) {
        
        data <- rv$selected_file_data
        file_info <- rv$selected_file
        
        # Detect potential SDTM domain
        domain <- detect_domain_from_data(data, file_info$name)
        
        showModal(
          modalDialog(
            title = sprintf("Data Viewer & Converter - %s", file_info$name),
            size = "xl",
            
            tabsetPanel(
              id = ns("viewer_tabs"),
              
              # Raw Data Tab
              tabPanel(
                "Raw Data",
                br(),
                div(
                  style = "max-height: 400px; overflow-y: auto;",
                  DTOutput(ns("raw_data_table"))
                ),
                hr(),
                div(
                  class = "data-summary",
                  tags$strong("Summary:"),
                  sprintf(" %d rows × %d columns", nrow(data), ncol(data))
                )
              ),
              
              # SDTM Preview Tab
              tabPanel(
                "SDTM Preview",
                br(),
                if (!is.null(domain)) {
                  tagList(
                    div(
                      class = "alert alert-info",
                      icon("info-circle"),
                      tags$strong(sprintf(" Detected Domain: %s", domain$name)),
                      br(),
                      domain$description
                    ),
                    hr(),
                    h4("Variable Mapping"),
                    p("These are suggested mappings. Edit the CDISC Variable column to customize."),
                    div(
                      class = "mapping-container",
                      style = "max-height: 300px; overflow-y: auto;",
                      DTOutput(ns("mapping_table"))
                    ),
                    hr(),
                    h4("Transformed Data Preview (First 50 rows)"),
                    div(
                      style = "max-height: 300px; overflow-y: auto;",
                      DTOutput(ns("sdtm_preview_table"))
                    ),
                    hr(),
                    div(
                      style = "text-align: center;",
                      actionButton(ns("apply_sdtm"), "Apply SDTM Transform", 
                                 class = "btn btn-primary"),
                      actionButton(ns("export_xpt"), "Export as XPT", 
                                 class = "btn btn-success", 
                                 icon = icon("download"))
                    )
                  )
                } else {
                  div(
                    class = "alert alert-warning",
                    icon("exclamation-triangle"),
                    " Could not auto-detect SDTM domain from filename or column names.",
                    br(),
                    "Supported domains: DM (Demographics), AE (Adverse Events), LB (Lab), VS (Vital Signs), EX (Exposure)"
                  )
                }
              ),
              
              # ADaM Preview Tab
              tabPanel(
                "ADaM Preview",
                br(),
                div(
                  class = "alert alert-info",
                  icon("info-circle"),
                  " ADaM datasets are typically derived from SDTM data. ",
                  "First convert your data to SDTM format, then create ADaM."
                ),
                hr(),
                if (rv$current_file_type == "SDTM" || !is.null(domain)) {
                  tagList(
                    h4("Available ADaM Structures"),
                    radioButtons(
                      ns("adam_type"),
                      "Select ADaM dataset type:",
                      choices = c(
                        "ADSL (Subject-Level Analysis)" = "ADSL",
                        "BDS (Basic Data Structure - for ADLB, ADVS)" = "BDS"
                      ),
                      selected = "ADSL"
                    ),
                    checkboxGroupInput(
                      ns("adam_derivations"),
                      "Include derivations:",
                      choices = c(
                        "Baseline Values (BASE)" = "baseline",
                        "Change from Baseline (CHG)" = "change",
                        "Percent Change (PCHG)" = "pct_change",
                        "Analysis Flags (ANL01FL)" = "anl_flags",
                        "Population Flags (SAFFL, ITTFL)" = "pop_flags"
                      ),
                      selected = c("baseline", "anl_flags", "pop_flags")
                    ),
                    hr(),
                    actionButton(ns("preview_adam"), "Preview ADaM Structure", 
                               class = "btn btn-info"),
                    div(
                      id = ns("adam_preview_container"),
                      uiOutput(ns("adam_preview_ui"))
                    )
                  )
                } else {
                  div(
                    class = "alert alert-secondary",
                    "Upload files to SDTM tab first, or convert current file to SDTM format."
                  )
                }
              ),
              
              # Metadata Tab
              tabPanel(
                "File Info",
                br(),
                h4("File Information"),
                tags$table(
                  class = "table table-striped table-bordered",
                  tags$tr(
                    tags$td(tags$strong("Filename:")),
                    tags$td(file_info$name)
                  ),
                  tags$tr(
                    tags$td(tags$strong("Size:")),
                    tags$td(format(file_info$size, big.mark = ","), " bytes")
                  ),
                  tags$tr(
                    tags$td(tags$strong("Type:")),
                    tags$td(file_info$type)
                  ),
                  tags$tr(
                    tags$td(tags$strong("Uploaded:")),
                    tags$td(format(file_info$uploaded_at, "%Y-%m-%d %H:%M:%S"))
                  ),
                  tags$tr(
                    tags$td(tags$strong("Rows:")),
                    tags$td(format(nrow(data), big.mark = ","))
                  ),
                  tags$tr(
                    tags$td(tags$strong("Columns:")),
                    tags$td(ncol(data))
                  )
                ),
                hr(),
                h4("Variable Information"),
                DTOutput(ns("variable_info_table"))
              )
            ),
            
            footer = tagList(
              downloadButton(ns("download_csv"), "Download as CSV", class = "btn-secondary"),
              actionButton(ns("close_viewer"), "Close", class = "btn-default")
            ),
            easyClose = FALSE
          )
        )
      }
    })
    
    # Close viewer
    observeEvent(input$close_viewer, {
      rv$show_viewer <- FALSE
      removeModal()
    })
    
    # Render raw data table
    output$raw_data_table <- renderDT({
      req(rv$selected_file_data)
      datatable(
        rv$selected_file_data,
        options = list(
          pageLength = 10,
          scrollX = TRUE,
          dom = 'ftip'
        ),
        class = 'display compact'
      )
    })
    
    # Render mapping table
    output$mapping_table <- renderDT({
      req(rv$selected_file_data)
      
      data <- rv$selected_file_data
      domain <- detect_domain_from_data(data, rv$selected_file$name)
      suggested <- suggest_variable_mapping(data, domain, rv$current_file_type)
      
      datatable(
        suggested,
        editable = TRUE,
        options = list(
          pageLength = 15,
          scrollY = "250px",
          scrollCollapse = TRUE,
          dom = 't',
          paging = FALSE
        ),
        class = 'display compact'
      )
    })
    
    # Render SDTM preview
    output$sdtm_preview_table <- renderDT({
      req(rv$selected_file_data)
      
      data <- rv$selected_file_data
      domain <- detect_domain_from_data(data, rv$selected_file$name)
      
      if (!is.null(domain)) {
        transformed <- transform_to_sdtm(data, domain)
        
        datatable(
          head(transformed, 50),
          options = list(
            pageLength = 10,
            scrollX = TRUE,
            dom = 'ftip'
          ),
          class = 'display compact'
        )
      }
    })
    
    # Render variable info table
    output$variable_info_table <- renderDT({
      req(rv$selected_file_data)
      
      data <- rv$selected_file_data
      
      var_info <- data.frame(
        Variable = names(data),
        Type = sapply(data, function(x) class(x)[1]),
        `Missing %` = sapply(data, function(x) round(sum(is.na(x)) / length(x) * 100, 1)),
        `Unique Values` = sapply(data, function(x) length(unique(na.omit(x)))),
        `Example Value` = sapply(data, function(x) {
          vals <- head(na.omit(x), 1)
          if (length(vals) > 0) as.character(vals[1]) else "NA"
        }),
        check.names = FALSE,
        stringsAsFactors = FALSE
      )
      
      datatable(
        var_info,
        options = list(
          pageLength = 20,
          dom = 'ftp'
        ),
        rownames = FALSE,
        class = 'display compact'
      )
    })
    
    # Apply SDTM Transform
    observeEvent(input$apply_sdtm, {
      req(rv$selected_file_data)
      
      data <- rv$selected_file_data
      domain <- detect_domain_from_data(data, rv$selected_file$name)
      
      if (!is.null(domain)) {
        transformed <- transform_to_sdtm(data, domain)
        
        # Validate
        validation <- validate_sdtm(transformed, domain)
        
        if (validation$valid) {
          showNotification(
            sprintf("SDTM transformation successful! %s domain with %d records.", 
                   domain$name, nrow(transformed)),
            type = "message",
            duration = 5
          )
          
          # Update the data
          rv$selected_file_data <- transformed
          
          # Optionally load into main dataset
          dataset(transformed)
          
        } else {
          showNotification(
            paste("Validation errors:", paste(validation$errors, collapse = "; ")),
            type = "error",
            duration = 10
          )
        }
      }
    })
    
    # Export to XPT
    output$export_xpt <- downloadHandler(
      filename = function() {
        paste0(tools::file_path_sans_ext(rv$selected_file$name), ".xpt")
      },
      content = function(file) {
        req(rv$selected_file_data)
        
        tryCatch({
          data <- rv$selected_file_data
          domain <- detect_domain_from_data(data, rv$selected_file$name)
          
          # Transform if not already SDTM
          if (!all(c("STUDYID", "DOMAIN", "USUBJID") %in% names(data))) {
            if (!is.null(domain)) {
              data <- transform_to_sdtm(data, domain)
            }
          }
          
          # Export
          temp_path <- export_to_xpt(data, basename(file), dirname(file))
          
          showNotification("XPT file exported successfully!", type = "message")
          
        }, error = function(e) {
          showNotification(paste("Export error:", e$message), type = "error")
        })
      }
    )
    
    # Download CSV
    output$download_csv <- downloadHandler(
      filename = function() {
        paste0(tools::file_path_sans_ext(rv$selected_file$name), "_export.csv")
      },
      content = function(file) {
        write.csv(rv$selected_file_data, file, row.names = FALSE)
      }
    )
    
    # Preview ADaM
    observeEvent(input$preview_adam, {
      req(rv$selected_file_data)
      
      data <- rv$selected_file_data
      adam_type <- input$adam_type
      
      # Create ADaM
      adam_data <- create_adam_from_sdtm(data, adam_type)
      
      output$adam_preview_ui <- renderUI({
        tagList(
          hr(),
          h4(sprintf("ADaM %s Preview", adam_type)),
          div(
            style = "max-height: 300px; overflow-y: auto;",
            renderDT({
              datatable(
                head(adam_data, 50),
                options = list(
                  pageLength = 10,
                  scrollX = TRUE,
                  dom = 'ftip'
                ),
                class = 'display compact'
              )
            })
          ),
          hr(),
          actionButton(ns("apply_adam"), "Apply ADaM Transform", class = "btn btn-primary")
        )
      })
    })
    
    # Apply ADaM Transform
    observeEvent(input$apply_adam, {
      req(rv$selected_file_data)
      
      data <- rv$selected_file_data
      adam_type <- input$adam_type
      
      adam_data <- create_adam_from_sdtm(data, adam_type)
      
      rv$selected_file_data <- adam_data
      dataset(adam_data)
      
      showNotification(
        sprintf("ADaM %s created with %d records!", adam_type, nrow(adam_data)),
        type = "message",
        duration = 5
      )
    })
    
    # Replace Existing - Similar to New Upload but overwrites
    observeEvent(input$replace_existing, {
      showNotification("Select a file in the explorer to replace", type = "warning")
    })
    
  })
}
