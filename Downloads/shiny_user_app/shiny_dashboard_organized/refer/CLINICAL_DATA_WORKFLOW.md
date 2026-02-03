# Clinical Data Lifecycle - How Your App Supports It

## Visual Data Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    CLINICAL TRIAL DATA SOURCES                   │
├─────────────────────────────────────────────────────────────────┤
│  • Clinicians (Vital Signs)     • EDC Systems (CRF Data)        │
│  • Lab Vendors (Blood Tests)    • Safety DB (Adverse Events)    │
│  • Devices (Wearables)          • Imaging (Scans)               │
└──────────────────────┬──────────────────────────────────────────┘
                       │
                       ↓
    ┌──────────────────────────────────────────────────┐
    │         YOUR APP - EDC TAB (Level 1)             │
    ├──────────────────────────────────────────────────┤
    │  Upload RAW DATA:                                │
    │  ✓ CSV, XLSX (EDC Exports)                       │
    │  ✓ JSON (ePRO/eCOA)                              │
    │  ✓ XML (ODM files)                               │
    │                                                   │
    │  Project: STUDY-2024-001                         │
    │    └─ Date: 2024-01-15                           │
    │        ├─ demographics.csv                       │
    │        ├─ adverse_events.csv                     │
    │        ├─ labs.xlsx                              │
    │        └─ vitals.csv                             │
    └────────────────────┬─────────────────────────────┘
                         │
                         │ Data Cleaning
                         │ Variable Mapping
                         │ CDISC Standards Applied
                         ↓
         ┌──────────────────────────────────────────────────┐
         │       YOUR APP - SDTM TAB (Level 1)              │
         ├──────────────────────────────────────────────────┤
         │  Upload STANDARDIZED DATA:                       │
         │  ✓ XPT Files (FDA Format) ⭐                     │
         │  ✓ SAS7BDAT (Working Files)                      │
         │  ✓ Define.xml (Metadata)                         │
         │                                                   │
         │  SDTM Domains:                                   │
         │  Project: STUDY-2024-001                         │
         │    └─ Date: 2024-02-01                           │
         │        ├─ dm.xpt    (Demographics)               │
         │        ├─ ae.xpt    (Adverse Events)             │
         │        ├─ lb.xpt    (Lab Tests)                  │
         │        ├─ vs.xpt    (Vital Signs)                │
         │        ├─ ex.xpt    (Exposure/Dosing)            │
         │        └─ define.xml (Metadata)                  │
         └────────────────────┬─────────────────────────────┘
                              │
                              │ Statistical Derivations
                              │ Baseline Calculations
                              │ Analysis Flags
                              ↓
              ┌──────────────────────────────────────────────────┐
              │      YOUR APP - ADaM TAB (Level 1)               │
              ├──────────────────────────────────────────────────┤
              │  Upload ANALYSIS-READY DATA:                     │
              │  ✓ XPT Files (FDA Format) ⭐                     │
              │  ✓ Define.xml (Analysis Metadata)                │
              │                                                   │
              │  ADaM Datasets:                                  │
              │  Project: STUDY-2024-001                         │
              │    └─ Date: 2024-02-15                           │
              │        ├─ adsl.xpt  (Subject-Level)              │
              │        ├─ adae.xpt  (AE Analysis)                │
              │        ├─ adlb.xpt  (Lab Analysis)               │
              │        ├─ advs.xpt  (Vital Signs Analysis)       │
              │        └─ define.xml (Analysis Metadata)         │
              └────────────────────┬─────────────────────────────┘
                                   │
                                   ↓
                       ┌───────────────────────────┐
                       │   FDA SUBMISSION READY    │
                       │   (eCTD Format)           │
                       └───────────────────────────┘
```

## 3-Level Hierarchy Explained

```
┌────────────────────────────────────────────────────────────────┐
│  LEVEL 1: FILE TYPE (Clinical Data Lifecycle Stage)           │
├────────────────────────────────────────────────────────────────┤
│                                                                 │
│  📊 EDC      →  Raw data from clinical sites                   │
│                 NOT FDA compliant                               │
│                 Needs transformation                            │
│                                                                 │
│  📋 SDTM     →  Standardized tabulation                        │
│                 FDA submission format                           │
│                 "What happened"                                 │
│                                                                 │
│  📈 ADaM     →  Analysis-ready datasets                        │
│                 FDA submission format                           │
│                 "What to analyze"                               │
│                                                                 │
│  LEVEL 2: PROJECT (Study/Trial Identifier)                    │
│  ├─────────────────────────────────────────────────────────┐  │
│  │  📁 STUDY-2024-001  →  Diabetes Trial                    │  │
│  │  📁 STUDY-2024-002  →  Oncology Trial                    │  │
│  │  📁 STUDY-2024-003  →  Cardiology Trial                  │  │
│  │                                                           │  │
│  │  LEVEL 3: DATE (Version/Submission Date)                 │  │
│  │  └───────────────────────────────────────────────────┐   │  │
│  │      📅 2024-01-15  →  Initial data lock               │   │  │
│  │      📅 2024-02-01  →  After queries resolved         │   │  │
│  │      📅 2024-02-15  →  Final submission version       │   │  │
│  │                                                        │   │  │
│  │      FILES (Individual datasets)                      │   │  │
│  │      ├─ 📄 dm.xpt                                      │   │  │
│  │      ├─ 📄 ae.xpt                                      │   │  │
│  │      ├─ 📄 lb.xpt                                      │   │  │
│  │      └─ 📄 vs.xpt                                      │   │  │
│  └────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Example: Complete Study Workflow

```
Study: ABC-DIABETES-2024 (Type 2 Diabetes Drug Trial)

┌─────────────────────────────────────────────────────────────┐
│ PHASE 1: Data Collection (EDC Tab)                         │
├─────────────────────────────────────────────────────────────┤
│ Project: ABC-DIABETES-2024                                  │
│   └─ 2024-01-15 (Initial export)                            │
│       ├─ demographics_export.csv      (250 subjects)        │
│       ├─ adverse_events_export.csv    (1,245 events)        │
│       ├─ laboratory_results.xlsx      (15,000 tests)        │
│       ├─ vital_signs.csv              (3,750 measurements)  │
│       ├─ conmed.csv                   (890 medications)     │
│       └─ medical_history.csv          (250 histories)       │
│                                                              │
│ Status: Raw EDC data - requires cleaning and standardization│
└─────────────────────────────────────────────────────────────┘
                          ↓
                   [Data Cleaning]
                   [QC Checks]
                   [CDISC Mapping]
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ PHASE 2: SDTM Creation (SDTM Tab)                          │
├─────────────────────────────────────────────────────────────┤
│ Project: ABC-DIABETES-2024                                  │
│   └─ 2024-02-01 (SDTM v1.0)                                │
│       ├─ dm.xpt      Demographics (250 subjects)            │
│       ├─ ae.xpt      Adverse Events (1,245 events)          │
│       ├─ lb.xpt      Lab Tests (15,000 results)             │
│       ├─ vs.xpt      Vital Signs (3,750 measurements)       │
│       ├─ ex.xpt      Drug Exposure (6,000 doses)            │
│       ├─ cm.xpt      Concomitant Meds (890 medications)     │
│       ├─ mh.xpt      Medical History (250 histories)        │
│       ├─ ds.xpt      Disposition (275 records)              │
│       ├─ sv.xpt      Subject Visits (2,500 visits)          │
│       └─ define.xml  Metadata (all domains)                 │
│                                                              │
│ Validation: Pinnacle21 Community ✓ PASS                     │
└─────────────────────────────────────────────────────────────┘
                          ↓
                 [Statistical Programming]
                 [Baseline Derivations]
                 [Analysis Flags]
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ PHASE 3: ADaM Creation (ADaM Tab)                          │
├─────────────────────────────────────────────────────────────┤
│ Project: ABC-DIABETES-2024                                  │
│   └─ 2024-02-15 (ADaM v1.0)                                │
│       ├─ adsl.xpt    Subject-Level (250 subjects)           │
│       │              • Treatment arms                        │
│       │              • Key dates                             │
│       │              • Analysis populations                  │
│       │              • Baseline characteristics              │
│       │                                                      │
│       ├─ adae.xpt    AE Analysis (1,245 events)             │
│       │              • Treatment-emergent flags              │
│       │              • Severity grades                       │
│       │              • SOC/PT coding                         │
│       │                                                      │
│       ├─ adlb.xpt    Lab Analysis (15,000 results)          │
│       │              • Baseline values                       │
│       │              • Change from baseline                  │
│       │              • % Change from baseline                │
│       │              • Normal range flags                    │
│       │              • Grade/Toxicity flags                  │
│       │                                                      │
│       ├─ advs.xpt    Vital Signs Analysis (3,750 obs)       │
│       │              • Baseline values                       │
│       │              • Change from baseline                  │
│       │                                                      │
│       ├─ adeff.xpt   Efficacy Analysis (2,500 obs)          │
│       │              • HbA1c endpoints                       │
│       │              • Fasting glucose                       │
│       │              • Body weight changes                   │
│       │                                                      │
│       └─ define.xml  Analysis Metadata                      │
│                                                              │
│ Ready for: CSR Tables, Listings, Figures                    │
│ Status: FDA Submission Ready ✓                              │
└─────────────────────────────────────────────────────────────┘
```

## Variable Transformation Example

### Raw EDC Data (CSV)
```
subject, site, ae_description, start_date, severity, related
001, 101, Headache, 2024-01-20, Mild, Yes
002, 101, Nausea, 2024-01-22, Moderate, Possibly
```

                    ↓ CDISC Mapping ↓

### SDTM Format (AE.xpt)
```
STUDYID | DOMAIN | USUBJID  | AESEQ | AETERM   | AEDECOD  | AESTDTC    | AESEV    | AEREL
ABC-DIA | AE     | 001-101  | 1     | Headache | HEADACHE | 2024-01-20 | MILD     | RELATED
ABC-DIA | AE     | 002-101  | 1     | Nausea   | NAUSEA   | 2024-01-22 | MODERATE | POSSIBLE
```

                    ↓ Analysis Derivation ↓

### ADaM Format (ADAE.xpt)
```
USUBJID  | AESEQ | TRTA   | AEDECOD  | ASTDT      | ASEV     | AREL     | TRTEMFL | AOCCFL
001-101  | 1     | Drug A | HEADACHE | 2024-01-20 | MILD     | RELATED  | Y       | Y
002-101  | 1     | Drug A | NAUSEA   | 2024-01-22 | MODERATE | POSSIBLE | Y       | Y
```

## Key Benefits of Your 3-Level Structure

### ✅ Benefit 1: Lifecycle Stage Separation
- **EDC, SDTM, ADaM tabs** keep data at different maturity levels separate
- Prevents mixing raw and standardized data
- Clear workflow progression

### ✅ Benefit 2: Project Organization
- Multiple studies managed independently
- Easy to find specific trial data
- Supports portfolio management

### ✅ Benefit 3: Version Control
- Date-based organization tracks data evolution
- Compare versions side-by-side
- Audit trail for regulatory inspections

### ✅ Benefit 4: Format Flexibility
- Accepts multiple file types per stage
- Working formats (CSV, SAS7BDAT) during development
- Submission formats (XPT) for final deliverables

### ✅ Benefit 5: Regulatory Compliance
- Structure aligns with eCTD requirements
- Ready for FDA/EMA submissions
- Supports 21 CFR Part 11 compliance

## Who Uses Each Tab

```
┌────────────────────┬──────────────────────┬───────────────────┐
│      EDC TAB       │      SDTM TAB        │     ADaM TAB      │
├────────────────────┼──────────────────────┼───────────────────┤
│ • Data Managers    │ • CDISC Programmers  │ • Statisticians   │
│ • CRAs             │ • Data Managers      │ • Statistical     │
│ • Site Staff       │ • QC Reviewers       │   Programmers     │
│ • QC Teams         │ • Medical Writers    │ • Medical Writers │
│                    │ • Regulatory Affairs │ • Regulatory      │
│                    │                      │   Affairs         │
└────────────────────┴──────────────────────┴───────────────────┘
```

## Real-World Usage Scenarios

### Scenario 1: Initial Data Lock
1. Export raw data from EDC system → **Upload to EDC tab**
2. QC checks in Table/Graphs modules
3. Create SDTM datasets in SAS/R → **Upload to SDTM tab**
4. Pinnacle21 validation
5. Create ADaM datasets → **Upload to ADaM tab**
6. Generate TLFs for CSR

### Scenario 2: Protocol Deviation
1. Query resolution in EDC system
2. Re-export corrected data → **New date in EDC tab**
3. Re-run SDTM programs → **New date in SDTM tab**
4. Re-run ADaM programs → **New date in ADaM tab**
5. Compare versions to assess impact

### Scenario 3: Regulatory Submission
1. Finalize all datasets in ADaM tab
2. Package with Define.xml files
3. Export project structure for eCTD
4. Submit to FDA/EMA

### Scenario 4: Portfolio Management
```
EDC Tab:
  ├─ ONCOLOGY-2024-A
  ├─ DIABETES-2024-B
  ├─ CARDIO-2024-C
  └─ RARE-DISEASE-2024-D

Each project tracked independently through full lifecycle
```

---

## Summary

Your webapp's **3-level hierarchical structure** perfectly aligns with the **clinical data lifecycle**:

1. **Level 1 (File Type)** = Data maturity stage (EDC → SDTM → ADaM)
2. **Level 2 (Project)** = Study/trial identifier
3. **Level 3 (Date)** = Version control / data lock dates

This structure supports the entire journey from **raw clinical data** to **FDA-ready submission packages**, making it a powerful tool for clinical data management teams.
