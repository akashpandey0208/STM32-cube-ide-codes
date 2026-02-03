# Clinical Data Formats in the Webapp

## Data Lifecycle Integration

Your webapp's 3-level hierarchy directly maps to the clinical data lifecycle:

```
EDC (Raw Data) → SDTM (Tabulation) → ADaM (Analysis) → FDA Submission
     ↓                ↓                    ↓
  Level 1          Level 1              Level 1
  (File Type)      (File Type)          (File Type)
```

## Supported Formats by Tab

### 1. EDC Tab (Electronic Data Capture)
**Purpose**: Upload raw clinical trial data from EDC systems

**Supported Formats**:
- **CSV/XLSX** - Most common EDC exports
  - Medidata Rave exports
  - Oracle Inform exports
  - REDCap exports
  - OpenClinica exports
- **XML** - ODM (Operational Data Model)
  - CDISC ODM format
  - Clinical trial data exchange
- **JSON** - ePRO/eCOA systems
  - Patient-reported outcomes
  - Electronic clinical outcomes assessments

**Data Sources**:
- Clinicians at trial sites (vital signs, medical history)
- Lab vendors (blood chemistry, biomarkers)
- EDC systems (CRF data)
- Safety databases (adverse events)
- Devices/wearables (activity, steps, heart rate)
- Imaging vendors (scan assessments)

**Typical Files**:
```
adverse_events.csv
demographics.xlsx
vital_signs.csv
laboratory_results.csv
concomitant_meds.csv
```

**NOT FDA Compliant** - These are raw data that need transformation

---

### 2. SDTM Tab (Study Data Tabulation Model)
**Purpose**: Upload standardized datasets ready for regulatory submission

**Supported Formats**:
- **XPT** - SAS Transport v5 (FDA REQUIRED)
  - Standard submission format
  - Cross-platform compatible
- **SAS7BDAT** - SAS dataset format
  - Working files before export
  - Internal processing
- **CSV** - Text representation
  - For validation/review
  - Easy inspection

**CDISC SDTM Domains**:

**General Observation Classes**:
- **DM** - Demographics (subject characteristics)
- **AE** - Adverse Events (what went wrong)
- **CM** - Concomitant Medications (other drugs)
- **MH** - Medical History (prior conditions)

**Findings Observation Classes**:
- **LB** - Laboratory Tests (blood, urine)
- **VS** - Vital Signs (BP, temp, HR)
- **EG** - ECG Data (heart rhythm)
- **MB** - Microbiology (cultures, sensitivity)

**Interventions Observation Classes**:
- **EX** - Exposure (study drug administration)
- **SU** - Substance Use (smoking, alcohol)

**Trial Design Datasets**:
- **TA** - Trial Arms
- **TE** - Trial Elements
- **TV** - Trial Visits
- **TI** - Trial Inclusion/Exclusion

**Typical Files**:
```
dm.xpt         (Demographics)
ae.xpt         (Adverse Events)
lb.xpt         (Lab Tests)
vs.xpt         (Vital Signs)
ex.xpt         (Exposure/Dosing)
cm.xpt         (Concomitant Meds)
mh.xpt         (Medical History)
define.xml     (Metadata)
```

**SDTM Characteristics**:
- One record per observation
- Standardized variable names (USUBJID, --TESTCD, --ORRES)
- ISO 8601 dates (YYYY-MM-DD)
- Controlled terminology from CDISC/NCI
- Traceability to source data

---

### 3. ADaM Tab (Analysis Data Model)
**Purpose**: Upload analysis-ready datasets derived from SDTM

**Supported Formats**:
- **XPT** - SAS Transport v5 (FDA REQUIRED)
- **SAS7BDAT** - SAS working files
- **CSV** - For review/validation

**ADaM Dataset Types**:

**Subject-Level Analysis Dataset (ADSL)**:
- One record per subject
- Demographics + derived variables
- Treatment arms, randomization
- Key dates (first dose, last dose)
- Analysis populations (ITT, PP, Safety)
- Baseline flags

**Basic Data Structure (BDS)**:
- Multiple records per subject
- One record per analysis timepoint
- Used for: ADLB, ADVS, ADEG
- Contains BASE, CHG, PCHG variables

**Occurrence Data Structure (OCCDS)**:
- Multiple records per subject
- One record per event
- Used for: ADAE, ADCM, ADMH

**Common ADaM Datasets**:
```
adsl.xpt       (Subject-Level Analysis)
adae.xpt       (Adverse Events Analysis)
adlb.xpt       (Lab Tests Analysis)
advs.xpt       (Vital Signs Analysis)
adtte.xpt      (Time-to-Event)
adeff.xpt      (Efficacy Endpoints)
```

**ADaM Characteristics**:
- Derived variables (BASE, CHG, PCHG)
- Analysis flags (ANL01FL, ANL02FL)
- Parameter-level data
- Baseline identification
- Statistical derivations
- Traceability to SDTM (--SEQ variables)

---

## File Format Details

### CSV (Comma-Separated Values)
**Use Cases**: 
- EDC exports (raw data)
- SDTM review copies
- ADaM validation files

**Advantages**:
- Human-readable
- Easy to inspect
- Universal compatibility
- Version control friendly

**Limitations**:
- Not FDA submission format
- No metadata
- Variable type ambiguity
- Encoding issues

**In Your App**:
- Auto-loads first CSV into dataset
- Available in all three tabs
- Immediate table/graph analysis

---

### XPT (SAS Transport v5)
**Use Cases**: 
- FDA submission (MANDATORY)
- SDTM datasets
- ADaM datasets

**Advantages**:
- FDA required format
- Platform-independent
- Preserves variable attributes
- Includes labels and formats

**Limitations**:
- Variable names limited to 8 characters
- No long variable support
- Binary format (not human-readable)

**Conversion Tools**:
```r
# R - haven package
library(haven)
write_xpt(data, "dm.xpt", version = 5)

# SAS
proc copy in=work out=xptfile;
  select dm;
run;
```

**In Your App**:
- Supported for upload
- SDTM and ADaM tabs
- Requires haven/foreign package for reading

---

### SAS7BDAT (SAS Dataset)
**Use Cases**: 
- Working files during development
- Internal processing
- Before conversion to XPT

**Advantages**:
- Full SAS metadata
- Long variable names
- Compression supported
- Native SAS format

**Limitations**:
- Platform-dependent
- Not FDA submission format
- Proprietary format

**In Your App**:
- Supported for upload
- For working/draft versions
- Requires haven package

---

### XML (Extensible Markup Language)
**Use Cases**: 
- Define.xml (REQUIRED metadata)
- ODM files from EDC
- CDISC standards

**Types**:

**Define.xml** (v2.0 or v2.1):
- Dataset metadata
- Variable definitions
- Codelists
- Analysis derivations
- Computational methods

**ODM (Operational Data Model)**:
- Clinical trial data exchange
- EDC system exports
- Standard data structure

**In Your App**:
- Supported for upload
- EDC tab for ODM
- SDTM/ADaM tabs for Define.xml

---

### XLSX/XLS (Excel)
**Use Cases**: 
- EDC exports
- Raw data collection
- Ad-hoc analyses

**Advantages**:
- Familiar to users
- Multi-sheet support
- Easy editing

**Limitations**:
- Not FDA submission format
- Size limitations
- Formatting issues
- Precision problems

**In Your App**:
- EDC tab primarily
- For initial data collection
- Requires readxl package

---

### JSON (JavaScript Object Notation)
**Use Cases**: 
- ePRO/eCOA systems
- Device/wearable data
- API responses

**Advantages**:
- Nested data structures
- Web-friendly
- Self-describing

**Limitations**:
- Not FDA submission format
- Needs transformation
- Nested complexity

**In Your App**:
- EDC tab for modern systems
- Requires jsonlite package
- Transform to tabular format

---

## Data Transformation Workflow

### Typical Project Flow in Your App

#### Phase 1: Data Collection (EDC Tab)
```
1. Upload raw EDC exports
   Project: STUDY-ABC-001
   Date: 2024-01-15
   Files: demographics.csv, ae.csv, labs.xlsx

2. Quality checks in Table/Graphs modules
3. Data cleaning and validation
```

#### Phase 2: SDTM Creation (SDTM Tab)
```
1. Transform raw data → SDTM format
   - Map variables to CDISC standards
   - Apply controlled terminology
   - Create DOMAIN, USUBJID, --SEQ

2. Upload SDTM datasets
   Project: STUDY-ABC-001
   Date: 2024-02-01
   Files: dm.xpt, ae.xpt, lb.xpt, vs.xpt, define.xml

3. Validate with Pinnacle21
```

#### Phase 3: ADaM Creation (ADaM Tab)
```
1. Derive analysis variables from SDTM
   - Create ADSL (subject-level)
   - Derive baseline values
   - Calculate changes from baseline
   - Flag analysis populations

2. Upload ADaM datasets
   Project: STUDY-ABC-001
   Date: 2024-02-15
   Files: adsl.xpt, adae.xpt, adlb.xpt

3. Generate TLFs (Tables/Listings/Figures)
```

#### Phase 4: FDA Submission Package
```
All data organized by:
- File Type (EDC/SDTM/ADaM)
- Project (Study identifier)
- Date (Version control)

Ready for eCTD submission
```

---

## Variable Naming Standards

### SDTM Variables

**Universal Variables** (all domains):
```
STUDYID    - Study identifier
DOMAIN     - Domain abbreviation (DM, AE, LB)
USUBJID    - Unique subject identifier
--SEQ      - Sequence number
--SPID     - Sponsor-defined identifier
```

**Timing Variables**:
```
--DTC      - Date/Time of Collection (ISO 8601)
--STDTC    - Start Date/Time
--ENDTC    - End Date/Time
--DY       - Study Day
```

**Findings Variables** (LB, VS, EG):
```
--TESTCD   - Test code (short)
--TEST     - Test name (long)
--ORRES    - Original Result
--ORRESU   - Original Units
--STRESC   - Standardized Result (character)
--STRESN   - Standardized Result (numeric)
--STRESU   - Standardized Units
```

**Events Variables** (AE):
```
AETERM     - Reported term
AEDECOD    - Dictionary-coded term (MedDRA)
AESEV      - Severity (MILD/MODERATE/SEVERE)
AESER      - Serious (Y/N)
AEREL      - Relationship to treatment
AEACN      - Action taken
AEOUT      - Outcome
```

### ADaM Variables

**Subject-Level (ADSL)**:
```
USUBJID    - Unique subject ID
SUBJID     - Subject ID
SITEID     - Site ID
AGE        - Age (years)
SEX        - Sex
RACE       - Race
ARM        - Planned treatment
ACTARM     - Actual treatment
TRTSDT     - Treatment start date
TRTEDT     - Treatment end date
SAFFL      - Safety population flag
ITTFL      - Intent-to-treat flag
```

**BDS Structure** (ADLB, ADVS):
```
PARAM      - Parameter name
PARAMCD    - Parameter code
AVAL       - Analysis value
BASE       - Baseline value
CHG        - Change from baseline
PCHG       - Percent change from baseline
ABLFL      - Baseline record flag
ANL01FL    - Analysis flag
AVISITN    - Analysis visit number
AVISIT     - Analysis visit
```

**Occurrence Structure** (ADAE):
```
TRTEMFL    - Treatment-emergent flag
AOCCFL     - First occurrence flag
ASEV       - Analysis severity
AREL       - Analysis relationship
AETOXGR    - Toxicity grade
```

---

## FDA Submission Requirements

### Required Files by Domain

**SDTM Datasets** (XPT format):
- All applicable domains (DM, AE, LB, VS, etc.)
- Define.xml (metadata)
- Reviewer's Guide (PDF)
- SDTM mapping specifications

**ADaM Datasets** (XPT format):
- ADSL (required for all submissions)
- Analysis datasets (ADAE, ADLB, etc.)
- Analysis Define.xml
- Analysis Data Reviewer's Guide (ADRG)

**Additional Files**:
- SAS/R programs (data derivation)
- Protocol (PDF)
- Statistical Analysis Plan (PDF)
- Case Report Forms (PDF)

### Package Structure
```
m5/
├── datasets/
│   ├── study-abc/
│   │   ├── tabulations/     (SDTM)
│   │   │   ├── dm.xpt
│   │   │   ├── ae.xpt
│   │   │   ├── lb.xpt
│   │   │   └── define.xml
│   │   └── analysis/        (ADaM)
│   │       ├── adsl.xpt
│   │       ├── adae.xpt
│   │       ├── adlb.xpt
│   │       └── define.xml
```

---

## Integration with Your Webapp

### Current Capabilities ✓
1. **Upload all format types** (CSV, XPT, SAS7BDAT, XML, XLSX, JSON)
2. **Organize by lifecycle stage** (EDC, SDTM, ADaM)
3. **Project-based organization** (multiple studies)
4. **Date-based versioning** (track changes over time)
5. **Auto-load CSV** for immediate analysis

### Recommended Enhancements

#### 1. Format Detection
```r
detect_file_format <- function(filename, file_type_tab) {
  ext <- tools::file_ext(filename)
  
  if (file_type_tab == "EDC") {
    if (ext %in% c("csv", "xlsx", "json", "xml")) return("RAW_DATA")
  } else if (file_type_tab == "SDTM") {
    if (ext == "xpt") return("SDTM_DOMAIN")
    if (filename == "define.xml") return("SDTM_METADATA")
  } else if (file_type_tab == "ADaM") {
    if (ext == "xpt") return("ADAM_DATASET")
    if (filename == "define.xml") return("ADAM_METADATA")
  }
  
  return("UNKNOWN")
}
```

#### 2. CDISC Domain Detection
```r
detect_sdtm_domain <- function(filename) {
  # Extract domain code from filename
  # dm.xpt → DM
  # ae.xpt → AE
  domain <- toupper(tools::file_path_sans_ext(basename(filename)))
  
  sdtm_domains <- c("DM", "AE", "LB", "VS", "EX", "CM", "MH", "EG", 
                    "PE", "DS", "SU", "DA", "EC", "TA", "TE", "TV", "TI")
  
  if (domain %in% sdtm_domains) return(domain)
  return(NULL)
}
```

#### 3. File Validation
```r
validate_clinical_file <- function(file_path, file_type, domain = NULL) {
  errors <- list()
  
  # Check file format
  if (file_type == "SDTM" && !endsWith(file_path, ".xpt")) {
    errors <- c(errors, "SDTM files must be in XPT format for FDA submission")
  }
  
  # Check required variables
  if (!is.null(domain)) {
    required_vars <- get_required_variables(domain)
    # Validate dataset contains required variables
  }
  
  return(list(valid = length(errors) == 0, errors = errors))
}
```

---

## Best Practices

### For EDC Data (Raw)
- ✓ Upload original exports (CSV/XLSX)
- ✓ Keep source documentation
- ✓ Document data collection dates
- ✓ Perform QC checks immediately
- ✗ Don't modify source files

### For SDTM Data
- ✓ Use XPT format for final versions
- ✓ Include Define.xml with every dataset
- ✓ Follow CDISC controlled terminology
- ✓ One domain per file
- ✓ Validate with Pinnacle21

### For ADaM Data
- ✓ Use XPT format for submission
- ✓ Create ADSL first (foundation)
- ✓ Document all derivations
- ✓ Include traceability variables
- ✓ Test with actual TLFs

### Version Control
- Use date-based organization in webapp
- Document changes in README
- Keep audit trail
- Tag submission versions

---

## Tools & Packages Reference

### R Packages
```r
# Reading/Writing XPT
library(haven)        # read_xpt(), write_xpt()
library(foreign)      # read.xport()

# CDISC Standards
library(admiral)      # ADaM derivations
library(metacore)     # Metadata management
library(metatools)    # Metadata utilities

# Data Processing
library(dplyr)        # Data manipulation
library(tidyr)        # Data reshaping
library(lubridate)    # Date handling

# Validation
library(pointblank)   # Data validation
library(validate)     # Rules-based validation
```

### External Tools
- **Pinnacle21 Community** - Free CDISC validator
- **SAS** - Industry standard for clinical programming
- **CDISC Library** - Standard reference
- **OpenCDISC Validator** - Open-source validation

---

## Glossary

**CDISC**: Clinical Data Interchange Standards Consortium
**SDTM**: Study Data Tabulation Model
**ADaM**: Analysis Data Model
**XPT**: SAS Transport v5 format
**Define.xml**: Dataset and variable metadata
**ODM**: Operational Data Model
**eCTD**: Electronic Common Technical Document
**MedDRA**: Medical Dictionary for Regulatory Activities
**WHO Drug**: WHO Drug Dictionary
**USUBJID**: Unique Subject Identifier
**BDS**: Basic Data Structure
**OCCDS**: Occurrence Data Structure

---

*This document describes how clinical data formats integrate with your Shiny webapp's 3-level hierarchical structure.*
