# Clinical Data Explorer - Feature Documentation

## Overview
The Clinical Data Explorer provides a hierarchical file management system specifically designed for clinical trial data in various CDISC formats (EDC, SDTM, ADaM).

## Features

### 3-Level Hierarchical Structure
The explorer organizes clinical data files in a three-level hierarchy:

1. **Level 1: File Type**
   - EDC (Electronic Data Capture)
   - SDTM (Study Data Tabulation Model)
   - ADaM (Analysis Data Model)

2. **Level 2: Project**
   - Create new projects or select existing ones
   - Projects act as containers for related studies/trials
   - Multiple projects can exist under each file type

3. **Level 3: Date**
   - Files are organized by upload date
   - Multiple files can be uploaded for each date
   - Enables version tracking and temporal organization

### User Interface Components

#### Left Panel: Explorer
- **Dataset View**: Displays the hierarchical tree structure of uploaded files
- **Graphs**: Quick access to visualization features (collapsible)
- Tree navigation with icons for file types, projects, dates, and files
- Visual hierarchy with indentation and color coding

#### Right Panel: Upload Area
- **File Type Tabs**: Switch between EDC, SDTM, and ADaM data types
- **Upload Dropzone**: Drag-and-drop or click-to-upload interface
- **New Upload**: Opens modal for structured file upload with project and date selection
- **Replace Existing**: Update existing files in the hierarchy
- **Navigation Buttons**: BACK and NEXT for workflow progression

### Upload Workflow

1. **Select File Type**: Click on EDC, SDTM, or ADaM tab
2. **Initiate Upload**: Click "New Upload" button
3. **Configure Upload**:
   - Enter new project name OR select existing project
   - Select upload date
   - Choose files (supports: CSV, XPT, SAS7BDAT, XML, XLSX, XLS)
4. **Confirm**: Files are organized in the hierarchy
5. **View**: Explorer updates to show new files in tree structure

### Supported File Formats

#### Clinical Data Formats
- **CSV**: Comma-separated values (raw clinical data)
- **XPT**: SAS Transport v5 (FDA submission format)
- **SAS7BDAT**: SAS dataset format
- **XML**: Extensible Markup Language (Define.xml, ODM)
- **XLSX/XLS**: Excel formats (raw EDC exports)

### Data Flow in Clinical Trials

```
Source Data → EDC Systems → Raw CSV/Excel
                           ↓
                    SDTM (Tabulation)
                           ↓
                    ADaM (Analysis)
                           ↓
                    XPT Files (FDA Submission)
```

### Technical Details

#### File Organization
- Files are stored with metadata including:
  - Original filename
  - File path
  - File size
  - MIME type
  - Upload timestamp
  
#### State Management
- Reactive data structure maintains the hierarchy
- Separate storage for each file type (EDC, SDTM, ADaM)
- Project and date levels nested within file types
- Multiple files per date supported

#### Auto-loading
- First uploaded CSV file is automatically loaded into the dataset
- Available for immediate viewing in Table and Graphs modules

### Styling

#### Color Scheme
- File Type icons: Blue (#1ea7ff)
- Project folders: Orange (#ffa726)
- Date folders: Green (#66bb6a)
- Files: Gray (#90a4ae)

#### Active States
- Selected tab: Dark blue (#5a7a99)
- Hover effects on tree items
- Button animations and shadows

### Future Enhancements

#### Planned Features
1. **File Operations**:
   - Delete files/folders
   - Rename projects
   - Move files between dates/projects
   
2. **Validation**:
   - CDISC compliance checking
   - File format validation
   - Data quality checks
   
3. **Metadata**:
   - Define.xml integration
   - Variable-level metadata
   - Study protocol information
   
4. **Export/Import**:
   - Export project structure
   - Bulk upload from folders
   - FDA submission package generation

5. **Collaboration**:
   - Share projects
   - Version control integration
   - Audit trail

### Usage Examples

#### Example 1: Upload EDC Data
1. Select "EDC" tab
2. Click "New Upload"
3. Enter project name: "STUDY-2024-001"
4. Select date: 2024-01-15
5. Choose CSV files from EDC export
6. Click "Upload"

Result: Files appear under EDC > STUDY-2024-001 > 2024-01-15

#### Example 2: Upload SDTM Datasets
1. Select "SDTM" tab
2. Click "New Upload"
3. Select existing project: "STUDY-2024-001"
4. Select date: 2024-02-01
5. Choose XPT files (DM, AE, LB domains)
6. Click "Upload"

Result: SDTM files organized under same project, different date

### Troubleshooting

#### Common Issues

**Files not appearing in explorer**
- Check that upload modal was confirmed
- Verify file format is supported
- Check browser console for errors

**Tab switching not working**
- Ensure shinyjs library is loaded
- Check that CSS classes are applied
- Verify JavaScript is enabled

**Modal not showing**
- Confirm shiny version compatibility
- Check for JavaScript errors
- Verify bootstrap is loaded

### Dependencies

- shiny (>= 1.7.0)
- shinyjs (>= 2.1.0)
- dplyr
- Other standard Shiny dependencies

### Files Modified

1. `modules/data_module.R` - Complete rewrite with explorer functionality
2. `www/css/style_data_explorer.css` - New stylesheet for explorer UI
3. `ui.R` - Added shinyjs and new CSS reference
4. `global.R` - Added shinyjs library
5. `www/css/style_main.css` - Modified content padding for full-height layout

---

*Last Updated: February 3, 2026*
*Version: 2.0.0*
