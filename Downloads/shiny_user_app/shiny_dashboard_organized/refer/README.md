# Clinical Webapp - Organized Modular Structure

## Overview

This is a refactored and organized version of the Clinical Shiny Dashboard. The application has been restructured into a modular architecture for better maintainability, extensibility, and easier collaboration.

## Project Structure

```
shiny_dashboard_organized/
│
├── app.R                    # Main application entry point
├── global.R                 # Libraries, helper functions, global variables
├── ui.R                     # User interface definition
├── server.R                 # Server logic and module coordination
│
├── modules/                 # Modular components (one file per feature)
│   ├── data_module.R       # Data upload and management
│   ├── table_module.R      # Data table display and export
│   ├── graphs_module.R     # Visualization creation (4 chart slots)
│   ├── reports_module.R    # Report generation (placeholder for future)
│   └── help_module.R       # Documentation and help content
│
├── www/                     # Static assets
│   ├── actalent_1.png      # Logo
│   ├── sample.csv          # Sample dataset
│   └── css/                # Organized CSS files
│       ├── style_main.css      # Main layout and general styles
│       ├── style_sidebar.css   # Sidebar navigation styles
│       ├── style_topbar.css    # Top navigation bar styles
│       ├── style_buttons.css   # Button and control styles
│       └── style_graphs.css    # Graph and visualization styles
│
└── projects/               # Project data structure
    ├── ADaM/              # ADaM datasets
    ├── EDC/               # EDC datasets
    └── SDTM/              # SDTM datasets
```

## Key Improvements

### 1. **Modular Architecture**
- **Separation of Concerns**: Each feature (Data, Table, Graphs, Reports, Help) is isolated in its own module file
- **Easy Maintenance**: Changes to one module don't affect others
- **Reusability**: Modules can be easily reused or extended
- **Testing**: Individual modules can be tested independently

### 2. **Organized CSS**
The CSS has been split into logical files:
- `style_main.css`: Core layout, cards, modals, utilities
- `style_sidebar.css`: Sidebar menu and navigation
- `style_topbar.css`: Top navigation bar and controls
- `style_buttons.css`: All button styles and interactions
- `style_graphs.css`: Chart slots, upload areas, visualization styles

### 3. **Clean Code Structure**
- Helper functions centralized in `global.R`
- Clear separation between UI and server logic
- Consistent naming conventions
- Comprehensive documentation

### 4. **Extensibility**
- Easy to add new tabs/modules
- New CSS styles can be added without affecting existing styles
- Module template pattern makes it simple to create new features

## How to Use

### Running the Application

```r
# Simply run the app.R file
shiny::runApp()
```

### Adding a New Module

1. Create a new file in `modules/` (e.g., `my_new_module.R`)
2. Define UI function: `myNewModuleUI <- function(id) { ... }`
3. Define server function: `myNewModuleServer <- function(id) { ... }`
4. Source the module in `app.R`
5. Add menu item in `server.R` sidebar
6. Add routing logic in `server.R` page_ui

### Adding New Styles

1. Choose the appropriate CSS file based on the component type
2. Add your styles using the existing CSS variable system
3. Follow the existing naming conventions

## Module System

Each module follows this pattern:

```r
# UI Function
myModuleUI <- function(id, ...) {
  ns <- NS(id)
  # Return UI elements
}

# Server Function
myModuleServer <- function(id, ...) {
  moduleServer(id, function(input, output, session) {
    # Module logic
  })
}
```

## CSS Variables

The application uses CSS custom properties for consistent theming:

```css
:root {
  --sidebar-bg: #213142;
  --topbar-bg: #213142;
  --accent: #1ea7ff;
  --primary-red: #d1351b;
  --gray-dark: #727477;
  --gray-medium: #606164;
  --gray-light: #8a8c8f;
}
```

## Features

### Data Tab
- Upload CSV datasets
- Automatic data cleaning and validation
- Sample data pre-loaded

### Table Tab
- Interactive data table with search/filter
- Column selection
- Export to CSV/Excel
- Row selection capabilities

### Graphs Tab
- 4 simultaneous chart slots
- Multiple chart types:
  - Histogram
  - Bar Chart
  - Scatter Plot
  - Box Plot
  - Line Chart
- Automatic type detection for columns
- Smart data coercion for visualizations

### Reports Tab
- Placeholder for future report generation features
- Can be extended for PDF/Word export
- Summary statistics
- Custom templates

### Help Tab
- User documentation
- Feature descriptions
- Support information

## Dependencies

- `shiny`: Core framework
- `DT`: Interactive data tables
- `ggplot2`: Visualizations
- `plotly`: Interactive plots
- `dplyr`: Data manipulation

## Benefits of This Structure

1. **Isolation**: Changes to graphs won't affect table functionality
2. **Collaboration**: Multiple developers can work on different modules
3. **Debugging**: Easier to locate and fix issues
4. **Performance**: Modules load only what they need
5. **Documentation**: Each file is self-contained and documented
6. **Version Control**: Smaller files = cleaner git diffs

## Migration Notes

If you're migrating from the old `app.R` structure:
- All functionality is preserved
- UI/UX remains the same
- No changes to user workflow
- Backend is now more maintainable

## Future Enhancements

Potential areas for expansion:
- Add authentication module
- Implement data caching
- Add more chart types
- Build report generation system
- Add data validation rules
- Implement user preferences
- Add database connectivity module

## Support

For questions or issues, refer to the Help tab in the application or contact your administrator.

---

**Version**: 2.0  
**Last Updated**: February 2026  
**Architecture**: Modular Shiny with CSS Organization
