# Clinical Data Explorer - Visual Guide

## UI Layout

```
┌─────────────────────────────────────────────────────────────────┐
│                     TOPBAR (Clinical Webapp)                     │
│  [Search] [Language ▼] [🔔] [↻] [P]                            │
└─────────────────────────────────────────────────────────────────┘
┌──────────┬──────────────────────────────────────────────────────┐
│ SIDEBAR  │                  MAIN CONTENT AREA                    │
│          │                                                        │
│ [Data]   │  ┌─────────────┬─────────────────────────────────┐  │
│  Table   │  │  EXPLORER   │      UPLOAD PANEL               │  │
│  Graphs  │  │  PANEL      │                                 │  │
│  Reports │  │             │  ┌─────┬─────┬──────┐          │  │
│  Help    │  │  Explorer   │  │ EDC │SDTM │ ADaM │ (Tabs)  │  │
│          │  │             │  └─────┴─────┴──────┘          │  │
│          │  │  📁 Dataset │                                 │  │
│          │  │     View    │  ┌─────────────────────┐       │  │
│          │  │             │  │  ╔═══════════════╗  │       │  │
│          │  │  └─ 🗄 EDC  │  │  ║   ⬆ Upload   ║  │       │  │
│          │  │    └─📁 Pro │  │  ║               ║  │       │  │
│          │  │       └─📅  │  │  ║ [New Upload]  ║  │       │  │
│          │  │          2024│  │  ║ [Replace]     ║  │       │  │
│          │  │          └─📄│  │  ╚═══════════════╝  │       │  │
│          │  │            fi│  └─────────────────────┘       │  │
│          │  │             │                                 │  │
│          │  │  └─ 🗄 SDTM │  ┌─────────┬──────────┐       │  │
│          │  │             │  │  BACK   │   NEXT   │       │  │
│          │  │  └─ 🗄 ADaM │  └─────────┴──────────┘       │  │
│          │  │             │                                 │  │
│          │  │  📊 Graphs  │                                 │  │
│          │  │             │                                 │  │
│          │  └─────────────┴─────────────────────────────────┘  │
│          │                                                      │
└──────────┴──────────────────────────────────────────────────────┘
```

## Tree Structure Hierarchy

```
🗄 EDC (File Type - Level 1)
├─ 📁 STUDY-2024-001 (Project - Level 2)
│  ├─ 📅 2024-01-15 (Date - Level 3)
│  │  ├─ 📄 patients.csv
│  │  ├─ 📄 vitals.csv
│  │  └─ 📄 adverse_events.csv
│  └─ 📅 2024-02-01
│     ├─ 📄 lab_results.csv
│     └─ 📄 demographics.csv
├─ 📁 STUDY-2024-002
│  └─ 📅 2024-01-20
│     └─ 📄 screening.csv
└─ 📁 PILOT-STUDY-X
   └─ 📅 2024-01-10
      └─ 📄 enrollment.csv

🗄 SDTM (File Type - Level 1)
├─ 📁 STUDY-2024-001 (Project - Level 2)
│  ├─ 📅 2024-02-15 (Date - Level 3)
│  │  ├─ 📄 dm.xpt (Demographics)
│  │  ├─ 📄 ae.xpt (Adverse Events)
│  │  ├─ 📄 lb.xpt (Lab Results)
│  │  ├─ 📄 vs.xpt (Vital Signs)
│  │  └─ 📄 define.xml
│  └─ 📅 2024-03-01
│     ├─ 📄 dm_v2.xpt
│     └─ 📄 ae_v2.xpt
└─ 📁 STUDY-2024-002
   └─ 📅 2024-02-20
      ├─ 📄 dm.xpt
      └─ 📄 ex.xpt (Exposure)

🗄 ADaM (File Type - Level 1)
└─ 📁 STUDY-2024-001 (Project - Level 2)
   ├─ 📅 2024-03-15 (Date - Level 3)
   │  ├─ 📄 adsl.xpt (Subject-Level)
   │  ├─ 📄 adae.xpt (Adverse Events Analysis)
   │  ├─ 📄 adlb.xpt (Lab Analysis)
   │  └─ 📄 advs.xpt (Vital Signs Analysis)
   └─ 📅 2024-04-01
      ├─ 📄 adsl_final.xpt
      └─ 📄 adeff.xpt (Efficacy Analysis)
```

## Upload Modal Workflow

```
┌──────────────────────────────────────────────┐
│  Upload Files to EDC                     [×] │
├──────────────────────────────────────────────┤
│                                              │
│  Project Name                                │
│  ┌──────────────────────────────────────┐   │
│  │ Enter project name...                 │   │
│  └──────────────────────────────────────┘   │
│                                              │
│  Or Select Existing Project                  │
│  ┌──────────────────────────────────────┐   │
│  │ -- New Project --              ▼     │   │
│  └──────────────────────────────────────┘   │
│                                              │
│  Date                                        │
│  ┌──────────────────────────────────────┐   │
│  │ 📅 2024-02-03                        │   │
│  └──────────────────────────────────────┘   │
│                                              │
│  Select Files                                │
│  ┌──────────────────────────────────────┐   │
│  │ Choose File(s)     [Browse...]       │   │
│  └──────────────────────────────────────┘   │
│  📄 patients.csv (125 KB)                   │
│  📄 vitals.csv (89 KB)                      │
│                                              │
├──────────────────────────────────────────────┤
│                     [Cancel]  [Upload]       │
└──────────────────────────────────────────────┘
```

## Data Flow Diagram

```
┌─────────────────┐
│  User Clicks    │
│  "New Upload"   │
└────────┬────────┘
         ▼
┌─────────────────┐
│  Modal Opens    │
│  with Form      │
└────────┬────────┘
         ▼
┌─────────────────┐
│  User Selects:  │
│  - Project      │
│  - Date         │
│  - Files        │
└────────┬────────┘
         ▼
┌─────────────────┐
│  Click Upload   │
└────────┬────────┘
         ▼
┌─────────────────────────────────────┐
│  Server Processing:                 │
│  1. Validate inputs                 │
│  2. Create/update data structure    │
│  3. Store file metadata             │
│  4. Load first CSV into dataset     │
│  5. Close modal                     │
│  6. Show success notification       │
└────────┬────────────────────────────┘
         ▼
┌─────────────────┐
│  Explorer Tree  │
│  Re-renders     │
│  with New Files │
└─────────────────┘
```

## Clinical Data Lifecycle

```
┌──────────────────────────────────────────────────────────┐
│                   CLINICAL TRIAL DATA FLOW               │
└──────────────────────────────────────────────────────────┘

1. DATA COLLECTION (EDC)
   ┌─────────────────────────────────────────┐
   │  Hospital/Site → EDC System → Export    │
   │  • Patient forms                        │
   │  • Lab results                          │
   │  • Adverse events                       │
   │  Formats: CSV, XML, Excel               │
   └────────────┬────────────────────────────┘
                ▼
                📥 UPLOAD TO EDC SECTION
                
2. DATA STANDARDIZATION (SDTM)
   ┌─────────────────────────────────────────┐
   │  EDC → SDTM Mapping → Validation        │
   │  • Standardize variable names           │
   │  • Apply CDISC controlled terminology   │
   │  • Create domain datasets               │
   │  Formats: XPT, Define.xml               │
   └────────────┬────────────────────────────┘
                ▼
                📥 UPLOAD TO SDTM SECTION
                
3. ANALYSIS PREPARATION (ADaM)
   ┌─────────────────────────────────────────┐
   │  SDTM → Statistical Derivations → ADaM  │
   │  • Calculate baseline values            │
   │  • Create analysis flags                │
   │  • Derive efficacy endpoints            │
   │  Formats: XPT                           │
   └────────────┬────────────────────────────┘
                ▼
                📥 UPLOAD TO ADAM SECTION
                
4. REGULATORY SUBMISSION
   ┌─────────────────────────────────────────┐
   │  Package Creation → FDA Submission      │
   │  • SDTM datasets (.xpt)                 │
   │  • ADaM datasets (.xpt)                 │
   │  • Define.xml                           │
   │  • Analysis programs                    │
   └─────────────────────────────────────────┘
```

## Color Legend

| Icon | Color | Hex Code | Meaning |
|------|-------|----------|---------|
| 🗄 | Blue | #1ea7ff | File Type (EDC/SDTM/ADaM) |
| 📁 | Orange | #ffa726 | Project/Folder |
| 📅 | Green | #66bb6a | Date |
| 📄 | Gray | #90a4ae | File |

## Interactive States

### Tab States
```
┌────────┬────────┬────────┐
│  EDC   │  SDTM  │  ADaM  │  ← Default (EDC active)
└────────┴────────┴────────┘
  ACTIVE   inactive  inactive
  (Blue)   (Gray)    (Gray)

┌────────┬────────┬────────┐
│  EDC   │  SDTM  │  ADaM  │  ← After clicking SDTM
└────────┴────────┴────────┘
 inactive  ACTIVE   inactive
 (Gray)    (Blue)   (Gray)
```

### Button States
```
Upload Buttons:
┌──────────────┐  ┌────────────────────┐
│  New Upload  │  │ Replace Existing   │
└──────────────┘  └────────────────────┘
   PRIMARY            SECONDARY
   (Solid)            (Outline)

Navigation Buttons:
┌──────────┐  ┌──────────┐
│   BACK   │  │   NEXT   │
└──────────┘  └──────────┘
  ENABLED       DISABLED
  (Outline)     (Gray)
```

### Tree Hover Effects
```
Normal State:
  📁 STUDY-2024-001

Hover State:
  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
  ▓ 📁 STUDY-2024-001 ▓  ← Light blue background
  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
```

## Responsive Breakpoints

```
Desktop (>1200px):
┌───────────────────────────────────────┐
│ Sidebar │ Explorer │  Upload Panel    │
│ (70px)  │ (280px)  │  (Flexible)      │
└───────────────────────────────────────┘

Tablet (768px - 1200px):
┌───────────────────────────────────────┐
│ Sidebar │ Explorer │  Upload Panel    │
│ (70px)  │ (240px)  │  (Flexible)      │
└───────────────────────────────────────┘

Mobile (<768px):
┌──────────────────┐
│  Sidebar (Full)  │
├──────────────────┤
│ Explorer (300px) │
├──────────────────┤
│  Upload Panel    │
│  (Full Width)    │
└──────────────────┘
```

---

**Visual Guide Version**: 1.0
**Created**: February 3, 2026
