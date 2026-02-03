# Data Converter & Viewer User Guide

## Overview
The Clinical Data Converter allows you to view and convert uploaded CSV/Excel files into CDISC-compliant SDTM and ADaM formats.

## How It Works

### Step 1: Upload Files
1. Select file type tab (EDC, SDTM, or ADaM)
2. Click "New Upload"
3. Enter project name and date
4. Select CSV or Excel files
5. Click "Upload"

### Step 2: View & Convert Files
1. **Click on any file** in the Explorer tree
2. A modal dialog opens with 4 tabs:
   - Raw Data
   - SDTM Preview
   - ADaM Preview
   - File Info

## Features by Tab

### 📊 Raw Data Tab
- **View uploaded data** in table format
- **Summary statistics**: Rows × Columns
- **Interactive table**: Sort, search, paginate
- **Export option**: Download as CSV

**What you see:**
- All columns from your original file
- First 10 rows by default (paginated)
- Data exactly as uploaded

---

### 🔄 SDTM Preview Tab

#### Auto-Detection
The system automatically detects SDTM domains based on:
- **Filename** (e.g., "adverse_events.csv" → AE domain)
- **Column names** (e.g., columns with "age", "sex" → DM domain)

#### Supported Domains
| Domain | Description | Key Identifiers |
|--------|-------------|-----------------|
| **DM** | Demographics | subject, age, sex, race |
| **AE** | Adverse Events | adverse, event, severity |
| **LB** | Laboratory | lab, test, result |
| **VS** | Vital Signs | vital, bp, temperature |
| **EX** | Exposure | dose, drug, treatment |
| **CM** | Concomitant Meds | medication, conmed |

#### Variable Mapping Table
Shows suggested mappings:
- **Source Column**: Your original column name
- **CDISC Variable**: Suggested SDTM variable name
- **Match Confidence**: High/Medium/Low

**Example Mapping:**
```
Source Column    → CDISC Variable  → Confidence
subject_id       → USUBJID         → High
adverse_event    → AETERM          → High
start_date       → AESTDTC         → Medium
severity         → AESEV           → High
```

#### Transformed Data Preview
Shows first 50 rows with:
- **STUDYID**: Study identifier (default: "STUDY001")
- **DOMAIN**: Domain code (DM, AE, LB, etc.)
- **USUBJID**: Unique subject ID (auto-generated or mapped)
- **Sequence variable**: AESEQ, LBSEQ, etc.
- All your original columns

#### Actions
- **Apply SDTM Transform**: Converts data to SDTM format
- **Export as XPT**: Downloads as SAS Transport v5 file (FDA format)

---

### 📈 ADaM Preview Tab

#### Requirements
ADaM datasets require SDTM as input. Options:
1. First convert to SDTM
2. Upload file to SDTM tab
3. Then create ADaM

#### ADaM Types

**ADSL (Subject-Level Analysis)**
- One record per subject
- Adds population flags:
  - SAFFL (Safety population)
  - ITTFL (Intent-to-treat)
  - EFFFL (Efficacy population)
- Treatment variables (TRT01P, TRT01A)

**BDS (Basic Data Structure)**
- Multiple records per subject
- Used for: ADLB, ADVS, ADEG
- Adds:
  - **AVAL**: Analysis value
  - **BASE**: Baseline value
  - **CHG**: Change from baseline
  - **PCHG**: Percent change
  - **ABLFL**: Baseline record flag
  - **ANL01FL**: Analysis flag

#### Derivations Available
- ☑ Baseline Values (BASE)
- ☑ Change from Baseline (CHG)
- ☑ Percent Change (PCHG)
- ☑ Analysis Flags (ANL01FL)
- ☑ Population Flags (SAFFL, ITTFL)

#### Actions
- **Preview ADaM Structure**: Shows derived variables
- **Apply ADaM Transform**: Creates ADaM dataset

---

### 📋 File Info Tab

**File Metadata:**
- Filename
- Size (bytes)
- Type (MIME type)
- Upload timestamp
- Number of rows
- Number of columns

**Variable Information Table:**
- Variable name
- Data type (character, numeric, etc.)
- Missing % (percent of NA values)
- Unique values count
- Example value

---

## Complete Workflow Example

### Example: Converting Adverse Events Data

#### 1. Upload Raw EDC Data
```csv
subject, site, ae_description, start_date, severity, related
001, 101, Headache, 2024-01-20, Mild, Yes
002, 101, Nausea, 2024-01-22, Moderate, Possibly
003, 102, Dizziness, 2024-01-25, Severe, No
```

**Upload to:** EDC tab
**Project:** DIABETES-2024-001
**Date:** 2024-01-20

#### 2. View and Convert to SDTM
1. Click on "ae_description.csv" in Explorer
2. System detects: **AE domain** ✓
3. Review mapping:
   ```
   subject       → USUBJID   (High confidence)
   ae_description → AETERM    (High confidence)
   start_date    → AESTDTC   (Medium confidence)
   severity      → AESEV     (High confidence)
   related       → AEREL     (Medium confidence)
   ```
4. Preview shows transformed data:
   ```
   STUDYID | DOMAIN | USUBJID    | AESEQ | AETERM   | AESTDTC    | AESEV    | AEREL
   STUDY001| AE     | STUDY001-001| 1     | Headache | 2024-01-20 | Mild     | Yes
   STUDY001| AE     | STUDY001-002| 2     | Nausea   | 2024-01-22 | Moderate | Possibly
   ```
5. Click "Apply SDTM Transform"
6. Click "Export as XPT"

#### 3. Upload to SDTM Tab
**File:** ae.xpt
**Project:** DIABETES-2024-001
**Date:** 2024-02-01

#### 4. Create ADaM Dataset
1. Click on "ae.xpt" in SDTM tab
2. Go to "ADaM Preview" tab
3. Select "BDS" structure
4. Check derivations:
   - ☑ Analysis Flags
   - ☑ Treatment-Emergent Flags
5. Click "Preview ADaM Structure"
6. Click "Apply ADaM Transform"

#### 5. Final Output
**ADaM dataset (ADAE)** with:
- All SDTM variables
- ANL01FL = "Y" (analysis flag)
- TRTEMFL (treatment-emergent flag)
- Ready for statistical analysis!

---

## Best Practices

### ✅ DO
1. **Name files descriptively**
   - ✓ demographics.csv
   - ✓ adverse_events.csv
   - ✓ lab_results.xlsx

2. **Use standard column names**
   - ✓ subject, patient, patient_id
   - ✓ age, sex, race
   - ✓ start_date, end_date

3. **Review mappings** before applying transform

4. **Check File Info tab** for data quality issues

5. **Export to XPT** for FDA submissions

### ❌ DON'T
1. **Don't use generic filenames**
   - ✗ data.csv
   - ✗ file1.xlsx
   - ✗ export.csv

2. **Don't mix domains** in one file

3. **Don't skip validation** warnings

---

## Automatic Variable Mapping Rules

### Subject Identifiers
```
Raw Columns                CDISC Variable
subject, subjid, patient → USUBJID
id, patient_id           → SUBJID
```

### Demographics
```
age                      → AGE
sex, gender              → SEX
race, ethnicity          → RACE
```

### Adverse Events
```
ae, adverse, event       → AETERM
start, onset             → AESTDTC
end, stop                → AEENDTC
severity, grade          → AESEV
related, relationship    → AEREL
serious                  → AESER
```

### Laboratory
```
test, test_code          → LBTESTCD
result, value            → LBORRES
unit, units              → LBORRESU
```

### Vital Signs
```
vital, parameter         → VSTESTCD
result, value            → VSORRES
unit                     → VSORRESU
```

---

## Troubleshooting

### Issue: Domain Not Detected
**Problem:** "Could not auto-detect SDTM domain"

**Solutions:**
1. Rename file to include domain code (e.g., "ae_data.csv")
2. Include key columns (e.g., for AE: adverse, severity, date)
3. Manually specify domain (feature coming soon)

### Issue: Mapping Confidence Low
**Problem:** Many "Low" confidence mappings

**Solutions:**
1. Use standard column names
2. Review and edit mappings in table
3. Ensure column names match clinical terms

### Issue: Export XPT Fails
**Problem:** "Error creating XPT file"

**Solutions:**
1. Ensure 'haven' package is installed
2. Check that STUDYID, DOMAIN, USUBJID exist
3. Apply SDTM transform first

### Issue: Can't Read File
**Problem:** "Unsupported file format"

**Supported Formats:**
- ✓ CSV (.csv)
- ✓ Excel (.xlsx, .xls) - requires 'readxl'
- ✓ XPT (.xpt) - requires 'haven'

---

## Keyboard Shortcuts & Tips

### Quick Actions
- **Click file once** → Opens viewer
- **ESC** → Close modal
- **Download buttons** → Save converted data

### Efficiency Tips
1. **Upload multiple files** at once
2. **Use date folders** for version control
3. **Export XPT immediately** after SDTM transform
4. **Check File Info** before converting

---

## What Gets Added in Conversion

### Raw CSV → SDTM
**System adds:**
- STUDYID (default: "STUDY001")
- DOMAIN (detected or specified)
- USUBJID (derived from subject column or auto-generated)
- Sequence variable (AESEQ, LBSEQ, etc.)

**You keep:**
- All original columns
- All original data

### SDTM → ADaM
**System adds (ADSL):**
- SAFFL, ITTFL, EFFFL (population flags)
- TRT01P, TRT01A (treatment variables)

**System adds (BDS):**
- AVAL (analysis value)
- BASE (baseline)
- CHG (change from baseline)
- PCHG (percent change)
- ABLFL (baseline flag)
- ANL01FL (analysis flag)

---

## File Size Limits
- **CSV/Excel**: Up to 100MB
- **Preview**: First 50-100 rows shown
- **Full data**: All rows processed

---

## Required R Packages
```r
shiny      # Core framework
shinyjs    # JavaScript integration
DT         # Data tables
dplyr      # Data manipulation
readxl     # Excel files
haven      # XPT files
```

**Install all:**
```r
source("install_dependencies.R")
```

---

## FDA Submission Notes

### XPT Format Requirements
- ✓ Variable names ≤ 8 characters (auto-truncated)
- ✓ SAS Transport v5 format
- ✓ Platform-independent
- ✓ Includes variable labels

### Required SDTM Variables
- STUDYID
- DOMAIN
- USUBJID
- --SEQ (sequence number)

### Recommended Workflow
1. EDC → Clean CSV
2. CSV → SDTM XPT
3. SDTM → ADaM XPT
4. Package with Define.xml
5. Submit to FDA

---

*For more information, see:*
- [CLINICAL_DATA_FORMATS.md](CLINICAL_DATA_FORMATS.md)
- [CLINICAL_DATA_WORKFLOW.md](CLINICAL_DATA_WORKFLOW.md)
- [DATA_EXPLORER_GUIDE.md](DATA_EXPLORER_GUIDE.md)
