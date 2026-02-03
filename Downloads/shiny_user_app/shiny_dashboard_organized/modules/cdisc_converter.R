# ============================================================================
# Helper Functions for SDTM/ADaM Conversion
# ============================================================================

# Detect SDTM domain from data structure and filename
detect_domain_from_data <- function(data, filename) {
  
  # Extract base name
  base_name <- tolower(tools::file_path_sans_ext(basename(filename)))
  
  # Domain definitions
  domains <- list(
    DM = list(
      name = "DM",
      description = "Demographics - Subject characteristics",
      key_vars = c("subject", "age", "sex", "race", "birth")
    ),
    AE = list(
      name = "AE",
      description = "Adverse Events - Safety events during study",
      key_vars = c("adverse", "event", "ae", "severity", "serious")
    ),
    LB = list(
      name = "LB",
      description = "Laboratory Tests - Blood, urine, chemistry",
      key_vars = c("lab", "test", "result", "chemistry", "hematology")
    ),
    VS = list(
      name = "VS",
      description = "Vital Signs - Blood pressure, temperature, etc.",
      key_vars = c("vital", "bp", "temperature", "pulse", "heart")
    ),
    EX = list(
      name = "EX",
      description = "Exposure - Study drug administration",
      key_vars = c("dose", "drug", "exposure", "treatment", "medication")
    ),
    CM = list(
      name = "CM",
      description = "Concomitant Medications - Other drugs taken",
      key_vars = c("conmed", "medication", "drug", "therapy")
    )
  )
  
  # Check filename first
  for (domain_code in names(domains)) {
    if (grepl(tolower(domain_code), base_name)) {
      return(domains[[domain_code]])
    }
  }
  
  # Check column names
  col_names_lower <- tolower(names(data))
  
  for (domain_code in names(domains)) {
    domain_info <- domains[[domain_code]]
    matches <- sapply(domain_info$key_vars, function(kw) {
      any(grepl(kw, col_names_lower))
    })
    
    if (sum(matches) >= 2) {
      return(domain_info)
    }
  }
  
  return(NULL)
}

# Suggest variable mapping based on column names
suggest_variable_mapping <- function(data, domain, file_type) {
  
  col_names <- names(data)
  
  # Common mapping patterns
  mapping_patterns <- list(
    # Subject identifiers
    USUBJID = c("subject", "subjid", "usubjid", "patient", "patientid", "subjectid"),
    SUBJID = c("subjid", "subject", "patient", "id"),
    
    # Demographics
    AGE = c("age"),
    AGEU = c("ageunit", "age_unit"),
    SEX = c("sex", "gender"),
    RACE = c("race", "ethnicity"),
    ETHNIC = c("ethnic", "ethnicity"),
    COUNTRY = c("country"),
    
    # Adverse Events
    AETERM = c("ae", "adverse", "event", "term", "description", "aeterm"),
    AEDECOD = c("coded", "decode", "preferred", "pt"),
    AESTDTC = c("start", "onset", "start_date", "startdate"),
    AEENDTC = c("end", "end_date", "stop", "enddate"),
    AESEV = c("severity", "grade", "sev"),
    AEREL = c("related", "relationship", "causality", "rel"),
    AESER = c("serious", "ser"),
    AEOUT = c("outcome", "out"),
    
    # Lab Tests
    LBTESTCD = c("test", "testcd", "test_code", "testcode"),
    LBTEST = c("test_name", "testname"),
    LBORRES = c("result", "value", "orres", "original"),
    LBORRESU = c("unit", "units", "orresu"),
    LBSTRESC = c("std_result", "stresc"),
    LBSTRESN = c("numeric", "stresn"),
    
    # Vital Signs
    VSTESTCD = c("vital", "test", "parameter", "testcd"),
    VSTEST = c("test_name", "vital_sign"),
    VSORRES = c("result", "value", "measurement"),
    VSORRESU = c("unit", "units"),
    
    # Exposure
    EXDOSE = c("dose", "amount"),
    EXDOSU = c("dose_unit", "unit"),
    EXDOSFRQ = c("frequency", "freq", "dosing"),
    EXROUTE = c("route"),
    
    # Dates and visits
    VISIT = c("visit", "visitnum", "visit_name"),
    VISITNUM = c("visitnum", "visit_num", "visitn"),
    VISITDY = c("day", "studyday", "study_day"),
    RFSTDTC = c("reference_start", "ref_start", "first_dose")
  )
  
  # Create mapping dataframe
  suggestions <- data.frame(
    `Source Column` = col_names,
    `CDISC Variable` = rep("Not Mapped", length(col_names)),
    `Match Confidence` = rep("Low", length(col_names)),
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
  
  # Try to match columns
  for (i in seq_along(col_names)) {
    col_lower <- tolower(col_names[i])
    col_clean <- gsub("[._]", "", col_lower)
    
    for (cdisc_var in names(mapping_patterns)) {
      patterns <- mapping_patterns[[cdisc_var]]
      
      for (pattern in patterns) {
        pattern_clean <- gsub("[._]", "", pattern)
        
        if (col_clean == pattern_clean || grepl(pattern_clean, col_lower)) {
          suggestions[i, "CDISC Variable"] <- cdisc_var
          suggestions[i, "Match Confidence"] <- ifelse(
            col_clean == pattern_clean, "High", "Medium"
          )
          break
        }
      }
      
      if (suggestions[i, "CDISC Variable"] != "Not Mapped") break
    }
  }
  
  return(suggestions)
}

# Transform data to SDTM format
transform_to_sdtm <- function(data, domain, study_id = "STUDY001") {
  
  if (is.null(domain)) return(data)
  
  # Start with original data
  sdtm_data <- data
  
  # Add required SDTM variables
  sdtm_data$STUDYID <- study_id
  sdtm_data$DOMAIN <- domain$name
  
  # Try to find or create USUBJID
  subj_cols <- grep("subj|patient|id", names(data), ignore.case = TRUE, value = TRUE)[1]
  if (!is.na(subj_cols) && length(subj_cols) > 0) {
    sdtm_data$USUBJID <- paste0(study_id, "-", as.character(data[[subj_cols]]))
  } else {
    sdtm_data$USUBJID <- paste0(study_id, "-", sprintf("%03d", seq_len(nrow(data))))
  }
  
  # Add sequence number
  seq_var <- paste0(domain$name, "SEQ")
  sdtm_data[[seq_var]] <- seq_len(nrow(data))
  
  # Reorder columns (STUDYID, DOMAIN, USUBJID first)
  required_cols <- c("STUDYID", "DOMAIN", "USUBJID", seq_var)
  other_cols <- setdiff(names(sdtm_data), required_cols)
  
  sdtm_data <- sdtm_data[, c(required_cols, other_cols)]
  
  return(sdtm_data)
}

# Create ADaM dataset from SDTM
create_adam_from_sdtm <- function(sdtm_data, adam_type = "ADSL") {
  
  if (adam_type == "ADSL") {
    # Subject-Level Analysis Dataset
    adam_data <- sdtm_data
    
    # Ensure USUBJID exists
    if (!"USUBJID" %in% names(adam_data)) {
      stop("USUBJID required for ADaM creation")
    }
    
    # Add analysis population flags
    adam_data$SAFFL <- "Y"  # Safety population
    adam_data$ITTFL <- "Y"  # Intent-to-treat population
    adam_data$EFFFL <- "Y"  # Efficacy population
    
    # Add treatment variables (placeholder)
    if (!"TRT01P" %in% names(adam_data)) {
      adam_data$TRT01P <- "Placebo"  # Planned treatment
      adam_data$TRT01A <- "Placebo"  # Actual treatment
    }
    
  } else if (adam_type == "BDS") {
    # Basic Data Structure (for ADLB, ADVS, etc.)
    adam_data <- sdtm_data
    
    # Add analysis value
    result_cols <- grep("ORRES|STRESN|result", names(sdtm_data), ignore.case = TRUE, value = TRUE)
    if (length(result_cols) > 0) {
      adam_data$AVAL <- as.numeric(sdtm_data[[result_cols[1]]])
    }
    
    # Add baseline flag
    adam_data$ABLFL <- ""
    adam_data$ABLFL[1] <- "Y"  # First record as baseline (simplified)
    
    # Calculate baseline value
    if ("AVAL" %in% names(adam_data)) {
      baseline_val <- adam_data$AVAL[adam_data$ABLFL == "Y"][1]
      adam_data$BASE <- baseline_val
      
      # Calculate change from baseline
      adam_data$CHG <- adam_data$AVAL - adam_data$BASE
      
      # Calculate percent change
      adam_data$PCHG <- ifelse(adam_data$BASE != 0, 
                              (adam_data$CHG / adam_data$BASE) * 100, 
                              NA)
    }
    
    # Add analysis flags
    adam_data$ANL01FL <- "Y"
  }
  
  return(adam_data)
}

# Export dataset to XPT format
export_to_xpt <- function(data, filename, path = tempdir()) {
  
  # Check if haven package is available
  if (!requireNamespace("haven", quietly = TRUE)) {
    stop("Package 'haven' is required to create XPT files. Install it with: install.packages('haven')")
  }
  
  # Truncate variable names to 8 characters (SAS v5 limitation)
  if (max(nchar(names(data))) > 8) {
    warning("Variable names truncated to 8 characters for XPT compatibility")
    names(data) <- substr(names(data), 1, 8)
    names(data) <- make.names(names(data), unique = TRUE)
    names(data) <- substr(names(data), 1, 8)
  }
  
  # Create full path
  full_path <- file.path(path, filename)
  
  # Write XPT file
  tryCatch({
    haven::write_xpt(data, full_path, version = 5)
    return(full_path)
  }, error = function(e) {
    stop(paste("Error creating XPT file:", e$message))
  })
}

# Validate SDTM dataset
validate_sdtm <- function(data, domain) {
  
  errors <- character()
  warnings <- character()
  
  # Check required variables
  required_vars <- c("STUDYID", "DOMAIN", "USUBJID")
  
  missing_required <- setdiff(required_vars, names(data))
  if (length(missing_required) > 0) {
    errors <- c(errors, paste("Missing required variable(s):", paste(missing_required, collapse = ", ")))
  }
  
  # Check DOMAIN value
  if ("DOMAIN" %in% names(data)) {
    if (!all(data$DOMAIN == domain$name)) {
      warnings <- c(warnings, "DOMAIN value inconsistent")
    }
  }
  
  # Check USUBJID uniqueness for DM
  if (!is.null(domain) && domain$name == "DM") {
    if ("USUBJID" %in% names(data)) {
      if (any(duplicated(data$USUBJID))) {
        errors <- c(errors, "Duplicate USUBJID values in Demographics domain")
      }
    }
  }
  
  # Check for empty values
  empty_cols <- names(data)[sapply(data, function(x) all(is.na(x) | x == ""))]
  if (length(empty_cols) > 0) {
    warnings <- c(warnings, paste("Empty column(s):", paste(empty_cols, collapse = ", ")))
  }
  
  list(
    valid = length(errors) == 0,
    errors = errors,
    warnings = warnings
  )
}
