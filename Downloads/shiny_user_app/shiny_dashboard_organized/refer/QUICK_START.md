# Quick Start Guide

## Running Your Reorganized App

### Option 1: RStudio (Recommended)
1. Open RStudio
2. Navigate to: `c:\Users\akpandey\Downloads\shiny_user_app\shiny_dashboard_organized`
3. Open `app.R`
4. Click **"Run App"** button in top-right
5. App launches in viewer or browser

### Option 2: R Console
```r
# Set working directory
setwd("c:/Users/akpandey/Downloads/shiny_user_app/shiny_dashboard_organized")

# Run the app
shiny::runApp()
```

### Option 3: Direct from Path
```r
# Run without changing directory
shiny::runApp("c:/Users/akpandey/Downloads/shiny_user_app/shiny_dashboard_organized")
```

## First-Time Setup

### Install Required Packages (if needed)
```r
# Check if packages are installed
required_packages <- c("shiny", "DT", "ggplot2", "plotly", "dplyr")

# Install missing packages
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages)
```

## Making Your First Edit

### Example 1: Change a Menu Label

**File**: `server.R` (line ~50)

**Before**:
```r
menu_item("menu_data", "fa-solid fa-database", "Data", "data")
```

**After**:
```r
menu_item("menu_data", "fa-solid fa-database", "Upload Data", "data")
```

**Result**: Menu shows "Upload Data" instead of "Data"

### Example 2: Change Button Color

**File**: `www/css/style_buttons.css` (line ~10)

**Before**:
```css
background: var(--gray-dark);
```

**After**:
```css
background: #2b7a90;
```

**Result**: Buttons change to teal color

### Example 3: Add a Notification in Data Upload

**File**: `modules/data_module.R` (line ~19)

**After the `dataset(df)` line, add**:
```r
showNotification(
  paste("Loaded", nrow(df), "rows and", ncol(df), "columns"),
  type = "message"
)
```

**Result**: Shows data dimensions when file uploaded

## Common Tasks

### Add a New Helper Function

**File**: `global.R` (add at end)

```r
# Custom data summary function
get_data_summary <- function(df) {
  list(
    rows = nrow(df),
    cols = ncol(df),
    numeric_cols = sum(sapply(df, is.numeric)),
    na_count = sum(is.na(df))
  )
}
```

**Use in any module**:
```r
summary <- get_data_summary(dataset())
```

### Add Custom CSS

**File**: Create `www/css/style_custom.css`

```css
/* My custom styles */
.my-special-card {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 20px;
  border-radius: 10px;
}
```

**Link in**: `ui.R` (in tags$head section)
```r
tags$link(rel = "stylesheet", type = "text/css", href = "css/style_custom.css")
```

## Troubleshooting

### App Won't Start

**Error**: "cannot open file 'modules/data_module.R'"
**Solution**: Make sure working directory is set correctly
```r
getwd()  # Check current directory
setwd("c:/Users/akpandey/Downloads/shiny_user_app/shiny_dashboard_organized")
```

### Module Not Found

**Error**: "object 'dataModuleUI' not found"
**Solution**: Check `app.R` has all source() statements
```r
source("modules/data_module.R")
source("modules/table_module.R")
source("modules/graphs_module.R")
source("modules/reports_module.R")
source("modules/help_module.R")
```

### CSS Not Loading

**Problem**: Styles don't appear
**Solution**: Check file paths in `ui.R`
```r
tags$link(rel = "stylesheet", type = "text/css", href = "css/style_main.css")
# Path is relative to www/ folder
```

### Package Not Found

**Error**: "there is no package called 'xxx'"
**Solution**: Install the package
```r
install.packages("xxx")
```

## Testing Your Changes

### Quick Test Checklist
1. ✅ App launches without errors
2. ✅ Navigate to all 5 tabs
3. ✅ Upload a CSV file
4. ✅ View table
5. ✅ Create a chart
6. ✅ Check browser console (F12) for errors

### Detailed Testing
See `TESTING_CHECKLIST.md` for comprehensive tests

## Understanding the Structure

### Key Principle: Isolation

```
┌─────────────────┐
│  data_module.R  │ ← Edit this for data upload features
└─────────────────┘

┌─────────────────┐
│ table_module.R  │ ← Edit this for table features
└─────────────────┘

┌─────────────────┐
│ graphs_module.R │ ← Edit this for chart features
└─────────────────┘
```

**Rule**: Changes in one module don't affect others!

### File Relationship Diagram

```
app.R
  ├─ Loads → global.R (helpers available to all)
  ├─ Loads → ui.R (displays interface)
  ├─ Loads → server.R (handles logic)
  └─ Loads → modules/*.R (feature modules)
```

## Next Steps

1. **Read the documentation**:
   - Start with `README.md`
   - Check `DEVELOPER_GUIDE.md` for tasks
   - See `ARCHITECTURE.md` for diagrams

2. **Make a simple change**:
   - Edit a module (add a comment)
   - Refresh app and verify

3. **Explore the structure**:
   - Open each module file
   - Read the comments
   - Understand the pattern

4. **Try adding a feature**:
   - Follow module template
   - Test in isolation
   - Integrate with app

## Getting Help

### Documentation Files
- **README.md** - Full overview
- **DEVELOPER_GUIDE.md** - Quick reference
- **ARCHITECTURE.md** - Visual diagrams
- **TESTING_CHECKLIST.md** - Testing guide
- **FILE_STRUCTURE.md** - Complete structure
- **REORGANIZATION_SUMMARY.md** - What changed

### Code Comments
All module files have detailed comments explaining:
- What the module does
- How to use it
- What parameters it accepts

### R Help
```r
# Get help on any function
?shiny::moduleServer
?ggplot2::ggplot
```

## Tips for Success

1. **One module at a time**: Don't try to understand everything at once
2. **Test frequently**: Run the app after each change
3. **Use version control**: Git tracks your changes
4. **Read comments**: They explain the "why"
5. **Start small**: Make tiny changes first
6. **Follow patterns**: New modules should match existing structure

## Performance Tips

### For Large Datasets
```r
# In global.R, add caching
cached_data <- reactiveVal()

# Use in modules
if (is.null(cached_data())) {
  cached_data(expensive_computation())
}
```

### For Complex Charts
```r
# In graphs_module.R
# Use req() to prevent unnecessary rendering
req(dataset(), input$chart_type)
```

## Deployment

### To Share with Team
1. Copy entire `shiny_dashboard_organized/` folder
2. Ensure they have required packages installed
3. They run `shiny::runApp()` from folder

### To Deploy to Server
1. Shiny Server: Copy folder to `/srv/shiny-server/`
2. shinyapps.io: Use `rsconnect::deployApp()`
3. RStudio Connect: Publish button in RStudio

## Backup Strategy

### Before Making Changes
```r
# Create a backup
file.copy(
  from = "modules/graphs_module.R",
  to = "modules/graphs_module.R.backup"
)
```

### Version Control (Git)
```bash
git init
git add .
git commit -m "Initial organized structure"
```

## Summary

You now have:
- ✅ Organized, modular codebase
- ✅ Clear separation of concerns
- ✅ Comprehensive documentation
- ✅ Easy-to-maintain structure
- ✅ Production-ready application

**Your app location**: 
`c:\Users\akpandey\Downloads\shiny_user_app\shiny_dashboard_organized\`

**To run**: 
```r
shiny::runApp("c:/Users/akpandey/Downloads/shiny_user_app/shiny_dashboard_organized")
```

Happy coding! 🚀
