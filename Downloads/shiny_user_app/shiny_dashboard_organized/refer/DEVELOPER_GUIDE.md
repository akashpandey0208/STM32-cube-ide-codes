# Developer Quick Reference

## File Organization Quick Guide

### Core Files (Always Edit These)
- **app.R** - Entry point, sources modules
- **global.R** - Libraries, helpers, shared functions
- **ui.R** - Main UI layout structure
- **server.R** - Core server logic, module coordination

### Module Files (Feature-Specific)
- **data_module.R** - Data upload only
- **table_module.R** - Table display only
- **graphs_module.R** - Visualization only
- **reports_module.R** - Reports only
- **help_module.R** - Help content only

### CSS Files (Style-Specific)
- **style_main.css** - Layout, cards, modals, base styles
- **style_sidebar.css** - Left sidebar menu
- **style_topbar.css** - Top navigation bar
- **style_buttons.css** - All button styles
- **style_graphs.css** - Charts and visualizations

## Common Tasks

### Add a New Tab
1. Create `modules/my_tab_module.R`
2. Add to `app.R`: `source("modules/my_tab_module.R")`
3. Add menu item in `server.R` sidebar_ui
4. Add observer in `server.R`: `observeEvent(input$menu_mytab, current_tab("mytab"))`
5. Add routing in `server.R` page_ui: `if (tab == "mytab") return(myTabModuleUI("mytab_module"))`
6. Call server: `myTabModuleServer("mytab_module", ...)`

### Modify Existing Tab
- **Data tab**: Edit `modules/data_module.R` only
- **Table tab**: Edit `modules/table_module.R` only
- **Graphs tab**: Edit `modules/graphs_module.R` only

### Change Styling
- **Sidebar colors**: `www/css/style_sidebar.css`
- **Button appearance**: `www/css/style_buttons.css`
- **Chart layout**: `www/css/style_graphs.css`
- **General layout**: `www/css/style_main.css`

### Add Helper Function
1. Add to `global.R`
2. Available to all modules automatically

### Debugging a Module
1. Check specific module file only
2. Use `browser()` inside module server function
3. Errors are isolated to that module

## Module Template

```r
# modules/example_module.R

# UI Function
exampleModuleUI <- function(id, reactive_data) {
  ns <- NS(id)
  
  div(
    class = "page-card",
    h3("Example Feature"),
    textInput(ns("user_input"), "Enter text:"),
    actionButton(ns("submit"), "Submit"),
    textOutput(ns("result"))
  )
}

# Server Function
exampleModuleServer <- function(id, reactive_data) {
  moduleServer(id, function(input, output, session) {
    
    # Reactive values
    result <- reactiveVal("")
    
    # Observers
    observeEvent(input$submit, {
      result(input$user_input)
    })
    
    # Outputs
    output$result <- renderText({
      paste("You entered:", result())
    })
    
  })
}
```

## CSS Best Practices

### Use CSS Variables
```css
background-color: var(--primary-red);
color: var(--sidebar-bg);
```

### File Selection Guide
- **Positioning/Layout** → style_main.css
- **Navigation menus** → style_sidebar.css or style_topbar.css
- **Interactive controls** → style_buttons.css
- **Data visualization** → style_graphs.css

### Class Naming Convention
- `.page-card` - Full-page content container
- `.chart-slot` - Individual chart container
- `.btn-*` - Button variants
- `.menu-item` - Sidebar menu items
- `.top-*` - Topbar elements

## Don't Cross Boundaries

### ✅ Good Practices
- Data module only handles data upload
- Each CSS file has one purpose
- Helper functions in global.R
- Module-specific logic stays in module

### ❌ Bad Practices
- Don't put graph logic in table module
- Don't mix button styles in graph CSS
- Don't duplicate helper functions
- Don't put UI elements in server.R

## Testing Checklist

Before committing changes:
- [ ] Module works in isolation
- [ ] No cross-module dependencies added
- [ ] CSS changes don't affect other pages
- [ ] Helper functions are in global.R
- [ ] Documentation updated if needed
- [ ] No errors in browser console
- [ ] Responsive design still works

## Performance Tips

1. **Reactive efficiency**: Use `req()` to prevent unnecessary computation
2. **Data caching**: Store processed data in reactiveVal
3. **Lazy loading**: Only load what's needed per module
4. **CSS**: Combine selectors, avoid deep nesting

## Common Pitfalls

1. **Namespace Issues**: Always use `ns()` in module UI
2. **Reactive Dependencies**: Use `isolate()` when needed
3. **Memory Leaks**: Clean up observers with `on.exit()`
4. **CSS Specificity**: Use classes, avoid !important

## Quick Fixes

### Module not appearing?
- Check source() in app.R
- Check routing in server.R page_ui
- Check menu observer exists

### Styles not applying?
- Check file linked in ui.R
- Check CSS variable defined in style_main.css
- Clear browser cache

### Data not updating?
- Check reactive dependencies
- Use `req()` to ensure data exists
- Check if reactiveVal is being set

## Resources

- [Shiny Modules Guide](https://shiny.rstudio.com/articles/modules.html)
- [CSS Variables](https://developer.mozilla.org/en-US/docs/Web/CSS/Using_CSS_custom_properties)
- Project README.md for full documentation
