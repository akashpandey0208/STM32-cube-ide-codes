# Application Architecture Diagram

## High-Level Structure

```
┌─────────────────────────────────────────────────────────────┐
│                         app.R                               │
│                   (Entry Point)                             │
│  • Sources all modules                                      │
│  • Calls shinyApp(ui, server)                              │
└────────────┬───────────────────────────────┬────────────────┘
             │                               │
    ┌────────▼────────┐            ┌────────▼────────┐
    │    global.R     │            │     ui.R        │
    │                 │            │                 │
    │ • Libraries     │            │ • Page layout   │
    │ • Helpers       │            │ • Topbar        │
    │ • Utilities     │            │ • Content area  │
    └─────────────────┘            └─────────────────┘
                                            │
                                   ┌────────▼────────┐
                                   │    server.R     │
                                   │                 │
                                   │ • Navigation    │
                                   │ • State mgmt    │
                                   │ • Module coord  │
                                   └────────┬────────┘
                                            │
           ┌────────────────────────────────┼─────────────────────────────┐
           │                                │                             │
    ┌──────▼──────┐                 ┌──────▼──────┐              ┌───────▼──────┐
    │   Modules   │                 │   Modules   │              │   Modules    │
    │             │                 │             │              │              │
    │ data_module │                 │table_module │              │graphs_module │
    │             │                 │             │              │              │
    └─────────────┘                 └─────────────┘              └──────────────┘
```

## Module Communication Flow

```
User Interaction
      │
      ▼
┌─────────────┐
│  Sidebar    │ ──────► current_tab("data")
│  Menu Click │
└─────────────┘
      │
      ▼
┌─────────────┐
│  server.R   │ ──────► Route to dataModuleUI()
│  Routing    │
└─────────────┘
      │
      ▼
┌─────────────┐
│ data_module │ ──────► Display upload UI
│     UI      │
└─────────────┘
      │
      ▼
┌─────────────┐
│ data_module │ ──────► Process data
│   Server    │         Update dataset()
└─────────────┘
      │
      ▼
Other modules receive updated dataset() automatically
```

## Data Flow

```
                    ┌──────────────┐
                    │  dataset()   │ ◄─── Uploaded by data_module
                    │ (ReactiveVal)│
                    └──────┬───────┘
                           │
           ┌───────────────┼───────────────┐
           │               │               │
    ┌──────▼──────┐ ┌─────▼─────┐  ┌─────▼─────┐
    │   Table     │ │  Graphs   │  │  Reports  │
    │   Module    │ │  Module   │  │   Module  │
    │             │ │           │  │           │
    │ • Display   │ │ • Chart 1 │  │ • Summary │
    │ • Filter    │ │ • Chart 2 │  │ • Export  │
    │ • Export    │ │ • Chart 3 │  │           │
    │             │ │ • Chart 4 │  │           │
    └─────────────┘ └───────────┘  └───────────┘
```

## CSS Organization

```
┌────────────────────────────────────────────────────┐
│                    ui.R                            │
│  Links all CSS files in <head>                    │
└──────────────────┬─────────────────────────────────┘
                   │
     ┌─────────────┼─────────────┬─────────────┐
     │             │             │             │
┌────▼────┐  ┌────▼────┐  ┌────▼────┐  ┌────▼────┐
│ Main    │  │Sidebar  │  │ Topbar  │  │ Buttons │
│         │  │         │  │         │  │         │
│ Layout  │  │ Menu    │  │ Nav Bar │  │ Actions │
│ Cards   │  │ Brand   │  │ Search  │  │ Icons   │
│ Utils   │  │ Links   │  │ Avatar  │  │ Tabs    │
└─────────┘  └─────────┘  └─────────┘  └─────────┘
                                   
                 ┌────▼────┐
                 │ Graphs  │
                 │         │
                 │ Charts  │
                 │ Slots   │
                 │ Upload  │
                 └─────────┘
```

## Module Isolation Principle

```
Each module is INDEPENDENT:

┌──────────────────┐
│  Data Module     │
│                  │  Can modify WITHOUT
│  • Upload logic  │  affecting other modules
│  • Validation    │
└──────────────────┘

┌──────────────────┐
│  Table Module    │
│                  │  Changes here stay
│  • Display       │  contained
│  • Export        │
└──────────────────┘

┌──────────────────┐
│  Graphs Module   │
│                  │  Independent
│  • Visualize     │  visualization logic
│  • 4 slots       │
└──────────────────┘
```

## File Dependencies

```
app.R
 │
 ├─► Loads: global.R
 │           │
 │           └─► Libraries (shiny, DT, ggplot2, plotly, dplyr)
 │           └─► Helper functions
 │
 ├─► Loads: ui.R
 │           │
 │           └─► CSS files (www/css/*.css)
 │           └─► UI structure
 │
 ├─► Loads: server.R
 │           │
 │           └─► Navigation logic
 │           └─► Module coordination
 │
 └─► Loads: modules/*.R
             │
             ├─► data_module.R
             ├─► table_module.R
             ├─► graphs_module.R
             ├─► reports_module.R
             └─► help_module.R
```

## Benefits Visualization

```
OLD STRUCTURE                    NEW STRUCTURE
═══════════════                  ═══════════════

app.R (1000+ lines)              app.R (30 lines)
     │                                │
     └─► Everything mixed         ┌───┴────┬────────┬────────┐
         • Hard to debug          │        │        │        │
         • No isolation       global.R   ui.R   server.R   modules/
         • Complex                │        │        │          │
                              Simple  Clean   Clear    Organized
                                                           │
                                        ┌──────────────────┼──────────┐
                                        │         │        │          │
                                     data_    table_   graphs_   reports_
                                    module   module    module     module
                                        
                                    Each ~150 lines, focused
```

## Scalability

```
ADDING NEW FEATURES:

Old Way:
  Edit massive app.R → Risk breaking everything

New Way:
  1. Create new module file
  2. Add one line to app.R
  3. Add menu item to server.R
  4. Done!
  
  Other modules: UNCHANGED ✓
```

## Maintenance Workflow

```
Bug in Graphs?
     │
     └─► Edit: modules/graphs_module.R
         │
         └─► Test: Only graphs affected
             │
             └─► Deploy: Confidence high!


New CSS for buttons?
     │
     └─► Edit: www/css/style_buttons.css
         │
         └─► Other styles: SAFE ✓
```

This architecture ensures:
- ✅ Easy maintenance
- ✅ Clear separation
- ✅ Parallel development
- ✅ Safe modifications
- ✅ Quick debugging
