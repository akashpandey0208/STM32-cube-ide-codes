# Quick Start Guide - Testing the Data Explorer

## Prerequisites

1. **Install Dependencies**
   ```r
   source("install_dependencies.R")
   ```

2. **Verify Installation**
   - Ensure all packages are installed without errors
   - Key package: `shinyjs` must be available

## Running the App

### Method 1: From RStudio
1. Open `app.R` in RStudio
2. Click "Run App" button in the top-right corner
3. Or run: `shiny::runApp()`

### Method 2: From R Console
```r
setwd("path/to/shiny_dashboard_organized")
shiny::runApp()
```

## Testing the Data Explorer

### Test 1: Basic Navigation
1. ✓ App loads successfully
2. ✓ Click on "Data" in left sidebar
3. ✓ Verify Explorer panel appears on left
4. ✓ Verify Upload panel appears on right
5. ✓ Three tabs visible: EDC, SDTM, ADaM

### Test 2: Tab Switching
1. ✓ Click "EDC" tab (should be active by default - blue)
2. ✓ Click "SDTM" tab (should become blue, EDC gray)
3. ✓ Click "ADaM" tab (should become blue)
4. ✓ Verify smooth transition and active state

### Test 3: File Upload - EDC
1. Click "EDC" tab
2. Click "New Upload" button
3. ✓ Modal dialog appears with title "Upload Files to EDC"
4. Enter project name: "TEST_STUDY_001"
5. Select date: Today's date
6. Choose a CSV file from `www/sample.csv` or your own
7. Click "Upload"
8. ✓ Modal closes
9. ✓ Success notification appears
10. ✓ Explorer tree shows: EDC > TEST_STUDY_001 > [date] > [filename]

### Test 4: Multiple Projects
1. Click "New Upload" again
2. Enter different project name: "TEST_STUDY_002"
3. Select date
4. Upload another file
5. ✓ Explorer shows both projects
6. ✓ Each project is collapsible/expandable

### Test 5: Existing Project Upload
1. Click "New Upload"
2. In "Or Select Existing Project" dropdown, choose "TEST_STUDY_001"
3. Select a different date
4. Upload a file
5. ✓ File appears under same project, different date node

### Test 6: SDTM Data Upload
1. Click "SDTM" tab
2. Click "New Upload"
3. Enter project: "SDTM_STUDY_001"
4. Upload XPT or CSV file
5. ✓ Explorer tree updates with SDTM data
6. ✓ EDC data is still preserved when switching back

### Test 7: ADaM Data Upload
1. Click "ADaM" tab
2. Repeat upload process
3. ✓ ADaM tree structure independent of EDC and SDTM

### Test 8: Explorer Visual Hierarchy
1. ✓ File type icon is blue (database icon)
2. ✓ Project icon is orange (folder icon)
3. ✓ Date icon is green (calendar icon)
4. ✓ File icon is gray (file icon)
5. ✓ Proper indentation for each level
6. ✓ Hover effects work on tree items

### Test 9: Multiple Files per Date
1. Select a project and date with existing files
2. Upload multiple files at once
3. ✓ All files appear under the same date node
4. ✓ Each file is listed individually

### Test 10: Navigation Buttons
1. ✓ "BACK" button visible and styled (outline style)
2. ✓ "NEXT" button visible but disabled (gray)
3. ✓ Hover effects work on BACK button

## Expected Issues & Solutions

### Issue: shinyjs not found
**Solution**: Run `install.packages("shinyjs")`

### Issue: Modal doesn't appear
**Solution**: 
- Check browser console for JavaScript errors
- Verify shinyjs::useShinyjs() is in UI
- Refresh page

### Issue: Tabs don't change color
**Solution**:
- Check that style_data_explorer.css is loaded
- Inspect element to verify classes are applied
- Clear browser cache

### Issue: Tree structure doesn't update
**Solution**:
- Check that files were successfully uploaded
- Verify reactive values are updating
- Check R console for errors

### Issue: Files not loading into dataset
**Solution**:
- Ensure file is CSV format
- Check file encoding (should be UTF-8)
- Verify sanitize_df function in global.R

## Validation Checklist

- [ ] All dependencies installed
- [ ] App runs without errors
- [ ] Explorer panel displays correctly
- [ ] Upload panel displays correctly
- [ ] Tab switching works smoothly
- [ ] Modal appears on "New Upload"
- [ ] Files upload successfully
- [ ] Tree structure updates after upload
- [ ] Multiple file types can be managed
- [ ] Visual hierarchy is clear and intuitive
- [ ] Hover effects and animations work
- [ ] Responsive design (resize window to test)

## Browser Compatibility

Tested on:
- [ ] Chrome (recommended)
- [ ] Firefox
- [ ] Edge
- [ ] Safari

## Performance Notes

- Loading many files (>100) may slow tree rendering
- Large files (>50MB) may take longer to upload
- Consider pagination for future versions

## Next Steps After Testing

1. **Data Integration**
   - Connect uploaded files to Table module
   - Enable file selection from tree
   - Load selected file into analysis

2. **File Management**
   - Implement "Replace Existing" functionality
   - Add delete/rename operations
   - Add file preview

3. **Validation**
   - Add CDISC format validation
   - Check for required variables
   - Display warnings for non-compliant data

4. **Export**
   - Generate submission packages
   - Export project structure
   - Create metadata documentation

---

**Test Date**: ___________
**Tester**: ___________
**Version**: 2.0.0
**Status**: ___________
