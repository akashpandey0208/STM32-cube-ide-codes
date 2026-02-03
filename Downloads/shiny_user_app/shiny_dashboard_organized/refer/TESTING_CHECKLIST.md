# Testing Checklist

Use this checklist to verify the reorganized application works correctly.

## Initial Setup
- [ ] Navigate to `shiny_dashboard_organized/` folder
- [ ] Open RStudio or R console
- [ ] Set working directory to the organized folder

## Launch Application
- [ ] Run `shiny::runApp()` or `source("app.R")`
- [ ] Application launches without errors
- [ ] No console warnings or errors
- [ ] UI appears correctly

## Navigation Tests
- [ ] Click **Data** menu item - tab changes
- [ ] Click **Table** menu item - tab changes
- [ ] Click **Graphs** menu item - tab changes
- [ ] Click **Reports** menu item - tab changes
- [ ] Click **Help** menu item - tab changes
- [ ] Active menu item shows highlighted style
- [ ] Navigation is smooth without delays

## Data Module Tests
### Data Tab Features
- [ ] Data tab displays upload interface
- [ ] Sample data is pre-loaded (if sample.csv exists)
- [ ] File upload button is visible and clickable
- [ ] Upload a CSV file - success notification appears
- [ ] Uploaded data replaces sample data

## Table Module Tests
### Table Tab Features
- [ ] Switch to Table tab
- [ ] Data table displays correctly
- [ ] All columns are visible
- [ ] Pagination works (if >10 rows)
- [ ] Search box works
- [ ] Column sorting works (click headers)
- [ ] Row selection works (click rows)
- [ ] Copy button works
- [ ] CSV export button works
- [ ] Excel export button works
- [ ] Exported file contains correct data

## Graphs Module Tests
### Graphs Tab Features
- [ ] Switch to Graphs tab
- [ ] All 4 chart slots are visible
- [ ] All 4 chart slots are in 2x2 grid layout

### Slot 1 Tests
- [ ] Select "Histogram" - controls appear
- [ ] Select variable - histogram renders
- [ ] Change bins slider - chart updates
- [ ] Select "Bar" - controls change
- [ ] Bar chart renders correctly
- [ ] Select "Scatter" - controls change
- [ ] Scatter plot renders correctly
- [ ] Select "Box" - controls change
- [ ] Box plot renders correctly
- [ ] Select "Line" - controls change
- [ ] Line chart renders correctly
- [ ] Click "Remove" button - slot resets to "None"

### Slot 2 Tests
- [ ] Repeat tests above for Slot 2
- [ ] Works independently from Slot 1

### Slot 3 Tests
- [ ] Repeat tests above for Slot 3
- [ ] Works independently from other slots

### Slot 4 Tests
- [ ] Repeat tests above for Slot 4
- [ ] Works independently from other slots

### Multiple Slots Simultaneously
- [ ] Set Slot 1 to Histogram
- [ ] Set Slot 2 to Bar chart
- [ ] Set Slot 3 to Scatter plot
- [ ] Set Slot 4 to Box plot
- [ ] All 4 charts display correctly together
- [ ] Changing one doesn't affect others

## Reports Module Tests
- [ ] Switch to Reports tab
- [ ] Placeholder content displays
- [ ] No errors in console

## Help Module Tests
- [ ] Switch to Help tab
- [ ] Help content displays
- [ ] Documentation is readable
- [ ] No errors in console

## Styling Tests
### General Appearance
- [ ] Sidebar displays correctly
- [ ] Logo appears in sidebar
- [ ] Topbar displays correctly
- [ ] Search box visible in topbar
- [ ] Language selector visible
- [ ] Notification icon visible
- [ ] Refresh icon visible
- [ ] User avatar displays ("P")

### Color Scheme
- [ ] Sidebar background is dark blue (#213142)
- [ ] Active menu item is highlighted
- [ ] Buttons have correct colors
- [ ] Charts use appropriate colors
- [ ] Cards have white background
- [ ] Page background is light gray

### Responsive Design
- [ ] Resize browser window to narrow width
- [ ] Layout adapts appropriately
- [ ] Content remains accessible
- [ ] No horizontal scrolling (except in tables)

## Module Isolation Tests
### Modify One Module
- [ ] Open `modules/data_module.R`
- [ ] Add a comment or console.log
- [ ] Save file
- [ ] Refresh app (stop and restart)
- [ ] Data tab shows change
- [ ] Other tabs unchanged (Table, Graphs, etc.)

### Modify One CSS File
- [ ] Open `www/css/style_buttons.css`
- [ ] Change a button color temporarily
- [ ] Refresh browser
- [ ] Button color changed
- [ ] Other styles unchanged (layout, sidebar, etc.)

## Error Handling Tests
- [ ] Upload invalid file (not CSV) - appropriate error
- [ ] Select numeric chart for text column - handles gracefully
- [ ] Remove all data - app doesn't crash
- [ ] Switch tabs rapidly - no errors

## Performance Tests
- [ ] Upload large dataset (>1000 rows) - loads successfully
- [ ] Create 4 complex charts - renders without lag
- [ ] Filter table with many columns - responds quickly
- [ ] Switch between tabs - instant response

## Browser Compatibility (If applicable)
- [ ] Test in Chrome - works correctly
- [ ] Test in Firefox - works correctly
- [ ] Test in Edge - works correctly
- [ ] Test in Safari - works correctly

## Code Quality Checks
### File Organization
- [ ] All module files exist in `modules/` folder
- [ ] All CSS files exist in `www/css/` folder
- [ ] No duplicate code across modules
- [ ] Helper functions in `global.R` only

### Documentation
- [ ] README.md exists and is complete
- [ ] DEVELOPER_GUIDE.md exists
- [ ] ARCHITECTURE.md exists
- [ ] Code comments are clear
- [ ] Function purposes are documented

### Best Practices
- [ ] Each module has UI and Server functions
- [ ] Namespaces used correctly (ns())
- [ ] Reactive dependencies are clear
- [ ] No global state pollution
- [ ] CSS variables used for theming

## Comparison with Original
- [ ] All features from original app are present
- [ ] UI looks identical to original
- [ ] User workflow is unchanged
- [ ] No features removed or broken
- [ ] Performance is same or better

## Final Verification
- [ ] No errors in R console
- [ ] No errors in browser console (F12 Developer Tools)
- [ ] No warnings during startup
- [ ] Application is stable
- [ ] Can use for at least 10 minutes without issues

## Sign-Off
- [ ] All tests passed
- [ ] Ready for development use
- [ ] Ready for production deployment
- [ ] Documentation is sufficient
- [ ] Team members can understand structure

---

## Issues Found

If you find any issues during testing, document them here:

**Issue 1:**
- Description: 
- Module affected: 
- Severity (High/Medium/Low): 
- Steps to reproduce: 

**Issue 2:**
- Description: 
- Module affected: 
- Severity (High/Medium/Low): 
- Steps to reproduce: 

---

## Test Results Summary

**Date Tested**: _______________
**Tested By**: _______________
**Result**: ☐ Pass  ☐ Fail  ☐ Pass with minor issues

**Notes**:


**Recommendation**: ☐ Approved for use  ☐ Needs fixes  ☐ Further testing needed
