# Updated Data Upload Workflow

## Clear Separation by Tab

### 📊 EDC Tab - Raw Data Upload
**Purpose:** Upload raw clinical data from sites, labs, EDC systems

**Upload Interface Shows:**
- 📤 Upload icon
- "Upload Raw Clinical Data"
- "New Upload" button (primary)
- "Replace Existing" button (secondary)

**Accepts:**
- ✅ CSV files
- ✅ Excel files (.xlsx, .xls)
- ✅ XML files (ODM format)
- ✅ JSON files (ePRO/eCOA)

**Workflow:**
```
1. Click "New Upload"
2. Select project and date
3. Choose CSV/Excel files
4. Upload → Files appear in Explorer
5. Click file → View and convert to SDTM
```

---

### 📋 SDTM Tab - Standardized Data
**Purpose:** View and manage CDISC SDTM datasets

**Upload Interface Shows:**
- 📊 File export icon
- "SDTM Data (Standardized Format)"
- Information bullets:
  - ✓ Click files in Explorer to view/convert from EDC
  - ✓ Export to XPT format (FDA submission)
  - ✓ Upload existing SDTM XPT files if already converted
- "Upload Existing SDTM Files" button (outline style)

**Accepts (for pre-converted files):**
- ✅ XPT files (SAS Transport v5)
- ✅ SAS7BDAT files
- ✅ CSV files (SDTM format)
- ✅ Define.xml

**Primary Workflow (Recommended):**
```
1. Go to EDC tab
2. Click on uploaded raw file
3. In modal → SDTM Preview tab
4. Review auto-mapped variables
5. Click "Apply SDTM Transform"
6. Click "Export as XPT"
7. File automatically appears in SDTM Explorer
```

**Alternative Workflow (External Files):**
```
1. Click "Upload Existing SDTM Files"
2. Select pre-converted XPT files
3. Files appear in SDTM Explorer
```

---

### 📈 ADaM Tab - Analysis-Ready Data
**Purpose:** View and manage ADaM analysis datasets

**Upload Interface Shows:**
- 📈 Chart icon
- "ADaM Data (Analysis-Ready Format)"
- Information bullets:
  - ✓ Click SDTM files in Explorer to create ADaM
  - ✓ Add derivations (BASE, CHG, PCHG)
  - ✓ Upload existing ADaM XPT files if already created
- "Upload Existing ADaM Files" button (outline style)

**Accepts (for pre-converted files):**
- ✅ XPT files (SAS Transport v5)
- ✅ SAS7BDAT files
- ✅ CSV files (ADaM format)

**Primary Workflow (Recommended):**
```
1. Go to SDTM tab
2. Click on SDTM file in Explorer
3. In modal → ADaM Preview tab
4. Select ADaM type (ADSL or BDS)
5. Choose derivations
6. Click "Preview ADaM Structure"
7. Click "Apply ADaM Transform"
8. File automatically appears in ADaM Explorer
```

**Alternative Workflow (External Files):**
```
1. Click "Upload Existing ADaM Files"
2. Select pre-converted ADaM XPT files
3. Files appear in ADaM Explorer
```

---

## Visual Comparison

### Before (Confusing)
```
EDC Tab:   [New Upload] [Replace]  ← Upload raw data
SDTM Tab:  [New Upload] [Replace]  ← Upload what? Already converted?
ADaM Tab:  [New Upload] [Replace]  ← Upload what? Confusing!
```

### After (Clear)
```
EDC Tab:   [📤 Upload Raw Clinical Data]
           [New Upload] [Replace Existing]
           ↓ Primary workflow: Upload → Convert

SDTM Tab:  [📊 SDTM Data (Standardized)]
           ✓ Click files to convert from EDC
           ✓ Export to XPT format
           [Upload Existing SDTM Files] ← Optional
           ↓ View converted files, or upload pre-existing

ADaM Tab:  [📈 ADaM Data (Analysis-Ready)]
           ✓ Click SDTM files to create ADaM
           ✓ Add derivations
           [Upload Existing ADaM Files] ← Optional
           ↓ View analysis datasets
```

---

## Complete Data Flow

```
┌─────────────────────────────────────────────────────────┐
│  EDC TAB - Raw Data Upload                              │
├─────────────────────────────────────────────────────────┤
│  📤 Upload Raw Clinical Data                            │
│  ↓                                                       │
│  [New Upload] → demographics.csv                        │
│  [New Upload] → adverse_events.xlsx                     │
│  [New Upload] → lab_results.csv                         │
└────────────────────┬────────────────────────────────────┘
                     │ Click file in Explorer
                     ↓
            ┌────────────────────┐
            │  Data Viewer Modal │
            │  → SDTM Preview    │
            │  → Apply Transform │
            │  → Export XPT      │
            └────────┬───────────┘
                     │ Automatic save to SDTM
                     ↓
┌─────────────────────────────────────────────────────────┐
│  SDTM TAB - Standardized Data                           │
├─────────────────────────────────────────────────────────┤
│  📊 View converted SDTM files                           │
│  ↓                                                       │
│  ✓ dm.xpt (from demographics.csv)                       │
│  ✓ ae.xpt (from adverse_events.xlsx)                    │
│  ✓ lb.xpt (from lab_results.csv)                        │
│                                                          │
│  [Upload Existing SDTM Files] ← Optional                │
└────────────────────┬────────────────────────────────────┘
                     │ Click SDTM file
                     ↓
            ┌────────────────────┐
            │  Data Viewer Modal │
            │  → ADaM Preview    │
            │  → Add Derivations │
            │  → Apply Transform │
            └────────┬───────────┘
                     │ Automatic save to ADaM
                     ↓
┌─────────────────────────────────────────────────────────┐
│  ADaM TAB - Analysis-Ready Data                         │
├─────────────────────────────────────────────────────────┤
│  📈 View ADaM analysis datasets                         │
│  ↓                                                       │
│  ✓ adsl.xpt (from dm.xpt + derivations)                │
│  ✓ adae.xpt (from ae.xpt + flags)                      │
│  ✓ adlb.xpt (from lb.xpt + baseline)                   │
│                                                          │
│  [Upload Existing ADaM Files] ← Optional                │
└─────────────────────────────────────────────────────────┘
                     │
                     ↓
            Ready for Analysis!
            (Tables, Graphs, Reports)
```

---

## Key Improvements

### ✅ Benefits

1. **Clear Purpose Per Tab**
   - EDC = Upload raw data
   - SDTM = View converted/standardized data
   - ADaM = View analysis datasets

2. **Guided Workflow**
   - Upload indicators show what to do
   - Instructions built into interface
   - Conversion path is obvious

3. **Flexible but Not Confusing**
   - Primary workflow: Convert via modal
   - Optional: Upload pre-existing files
   - Clear labeling prevents confusion

4. **Visual Hierarchy**
   - EDC: Big upload button (primary action)
   - SDTM/ADaM: Info panel + outline button (secondary)

5. **Prevents Errors**
   - Users can't accidentally upload raw data to SDTM tab
   - Clear expectations for each file type
   - Helpful instructions visible

---

## Usage Examples

### New User (Starting from scratch)

**Scenario:** Has raw CSV files from EDC system

**Steps:**
1. Go to EDC tab ✓
2. See big upload button ✓
3. Upload CSV files ✓
4. Click file in Explorer ✓
5. Convert to SDTM in modal ✓
6. SDTM tab now shows converted files ✓
7. Click SDTM file ✓
8. Create ADaM in modal ✓
9. ADaM tab shows analysis datasets ✓

**Result:** Clear, guided workflow from raw to analysis-ready

---

### Experienced User (Has pre-converted files)

**Scenario:** Already has SDTM XPT files from SAS

**Steps:**
1. Go to SDTM tab ✓
2. See info panel with option to upload ✓
3. Click "Upload Existing SDTM Files" ✓
4. Select XPT files ✓
5. Files appear in SDTM Explorer ✓
6. Can now create ADaM from these ✓

**Result:** Flexible workflow supports external files

---

## User Feedback Messages

### EDC Tab
```
"Upload Raw Clinical Data"
Upload CSV or Excel files from EDC systems, labs, or clinical sites
```

### SDTM Tab
```
"SDTM Data (Standardized Format)"
This tab displays CDISC SDTM datasets created from EDC data.

✓ Click files in Explorer to view/convert from EDC
✓ Export to XPT format (FDA submission)
✓ Upload existing SDTM XPT files if already converted
```

### ADaM Tab
```
"ADaM Data (Analysis-Ready Format)"
This tab displays ADaM analysis datasets derived from SDTM.

✓ Click SDTM files in Explorer to create ADaM
✓ Add derivations (BASE, CHG, PCHG)
✓ Upload existing ADaM XPT files if already created
```

---

## Summary

The updated interface now clearly communicates:
- **What each tab is for**
- **What action to take**
- **What file types are expected**
- **How files move between tabs**

This makes the clinical data lifecycle obvious and prevents user confusion! 🎉
