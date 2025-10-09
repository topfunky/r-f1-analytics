# AGENTS.md - AI Agent Guidelines for R F1 Analytics Project

## Project Overview
This is an R-based F1 analytics project that uses the `f1dataR` package to fetch Formula 1 data and generate visualizations and statistical analysis.

**Version Control**: Jujutsu (jj) for local development, git for remote operations.

## Project Structure
```
r-f1-analytics/
├── scripts/           # R scripts for data analysis and plotting
├── plots/            # Generated plot outputs (gitignored)
├── data/             # Cached data files (gitignored)
├── .github/          # GitHub Actions workflows
├── AGENTS.md         # This file - AI agent guidelines
└── README.md         # Project documentation
```

## Technology Stack
- **Language**: R (4.3.2+)
- **Key Package**: `f1dataR` - https://scasanova.github.io/f1dataR/
- **Visualization**: ggplot2, plotly
- **Data Manipulation**: dplyr, tidyr
- **Version Control**: Jujutsu (jj) for local development, git for remote

## Development Guidelines

### R Code Style
1. Follow tidyverse style guide for R code
1. Use meaningful variable names (e.g., `driver_standings` not `ds`)
1. Use snake_case for variables and functions
1. Use pipes (`|>`) for readability
1. Prefer tidyverse functions (dplyr, ggplot2) over base R when appropriate
1. Add comments for complex data transformations
1. Include roxygen2-style documentation for functions
1. Keep functions small and focused, less than 40 lines if possible
1. Allow API errors and other remote data access errors to be thrown; do not use `tryCatch`

### Markdown Style
1. Use `1.` for all ordered lists; do not number items sequentially 

### File Naming Conventions
- Scripts: `verb_subject.R` (e.g., `plot_lap_times.R`, `analyze_race_results.R`)
- Plots: `descriptive_name_YYYY-MM-DD.png` (e.g., `verstappen_wins_2024.png`)
- Use snake_case for all file and variable names

### File Organization
- Place analysis scripts in `scripts/`
- Save generated plots to `plots/` (this directory is gitignored)
- Cache data in `data/` (this directory is gitignored)
- Document all package dependencies at top of scripts

### Data Fetching Best Practices
1. Always cache f1dataR API responses to avoid repeated calls
1. Use `f1dataR` package functions appropriately
1. Allow R to throw errors and emit stack traces on failure so that problems can be detected and fixed
1. Document data sources and fetch dates in comments
1. Validate data before visualization
1. Use rate limiting when making API calls 

### Visualization Standards
1. All plots should be saved to `plots/` directory
1. Use consistent high contrast theme across plots (https://github.com/topfunky/gghighcontrast)
1. Include proper titles, axis labels, and legends
1. Export in high resolution (300+ dpi) and wide aspect ratio (12x6)
1. Use colorblind-friendly palettes
1. Add source attribution for data (e.g., "Data: f1dataR | Ergast API")
1. Consider both light and dark theme compatibility

### Script Requirements
1. Each script should be runnable independently
1. Include error handling for data fetching
1. Log progress to console
1. Save outputs with timestamps
1. Ensure scripts are non-interactive and reproducible (important for CI)

### Version Control with Jujutsu (jj)

#### Commit Messages
- Use descriptive change descriptions
- Format: "Add/Update/Fix: brief description"
- Example: `jj describe -m "Add qualifying pace comparison plot"`

#### Workflow
1. Use `jj` commands for local operations
1. Use atomic `jj commit` to describe a change and create a new empty change
1. Create descriptive change descriptions: `jj describe -m "Add lap time analysis for 2024 season"`
1. Use `jj git push` to push to remote when ready
1. Squash experimental changes before pushing to main
1. Keep main branch clean and tested

### Testing & Validation
1. Verify plots render correctly before committing
1. Test scripts with different seasons/races/drivers
1. Handle edge cases (e.g., sprint races, DSQ, DNS, canceled races)
1. Validate data integrity before plotting
1. Run `scripts/render_all_plots.sh` before major commits

## Common Tasks

### Adding a New Analysis
1. Create a new R script in `scripts/`
1. Fetch required data using `f1dataR`
1. Perform analysis/transformation
1. Generate visualization
1. Save plot to `plots/`
1. Update README with new analysis description

### Running All Plots
```bash
./scripts/render_all_plots.sh
```

### Manual Plot Generation
```bash
Rscript scripts/your_plot_script.R
```

## Package Dependencies

### Core Packages
- ggplot2, dplyr, tidyr, lubridate, scales
- f1dataR (from GitHub: SCasanova/f1dataR)

### Installation
```r
install.packages(c("ggplot2", "dplyr", "tidyr", "lubridate", "scales"))
remotes::install_github("SCasanova/f1dataR")
```

## Code Templates

### Data Fetching Template
```r
# Load required packages
library(f1dataR)
library(dplyr)

# Fetch data without error handling so that errors are raised and can be fixed
data <- load_some_f1_data(season = 2024)
saveRDS(data, "data/cache/cached_data.rds")
```

### Plot Template
```r
library(ggplot2)
library(gghighcontrast)

# Create plot
p <- ggplot(data, aes(x = x, y = y)) +
  geom_point() +
  theme_high_contrast() +
  labs(
    title = "Descriptive Title",
    subtitle = "Additional context",
    x = "X Label",
    y = "Y Label",
    caption = "Data: f1dataR | Ergast API"
  )

# Save plot
ggsave(
  filename = "plots/descriptive_name.png",
  plot = p,
  width = 12,
  height = 6,
  dpi = 300
)
```

## CI/CD Pipeline
- GitHub Actions automatically builds all plots on push to main
- Plots are deployed to a clean `staging` branch
- Review plots at: `https://github.com/[username]/r-f1-analytics/tree/staging/plots`
- Ensure scripts are non-interactive and reproducible
- Include proper error handling for CI environment

## What NOT to Do
- ❌ Don't commit large data files (use .gitignore)
- ❌ Don't make API calls in loops without rate limiting
- ❌ Don't use absolute file paths (use relative paths)
- ❌ Don't push to main without testing scripts

## Troubleshooting

### API Rate Limits
If you hit API rate limits:
1. Use cached data when available
1. Add delays between requests
1. Run scripts during off-peak hours

### Package Installation Issues
If f1dataR installation fails:
```r
# Install dependencies first
install.packages(c("httr", "jsonlite", "tibble", "dplyr"))
remotes::install_github("SCasanova/f1dataR", force = TRUE)
```

### Plot Rendering Issues
1. Check that output directory exists
1. Verify system graphics libraries are installed
1. Use `Rscript` instead of interactive R for consistent results

## AI Agent Behavior Expectations

### Core Principles
1. **Be Proactive**: Suggest relevant analyses based on recent F1 events
1. **Explain Decisions**: Comment why certain visualizations or statistics are chosen
1. **Optimize Performance**: Cache data, vectorize operations, use efficient ggplot2 patterns
1. **Maintain Quality**: Generate publication-ready plots with proper styling
1. **Stay Current**: Use latest F1 season data when available
1. **Document Everything**: Add comments, update README, log changes

### Code Generation
- Suggest analyses based on recent F1 events
- Explain statistical choices and visualization decisions
- Optimize for performance (vectorization, efficient ggplot2)
- Generate publication-ready, well-documented code
- Provide alternatives when multiple approaches exist
- Reference f1dataR documentation when relevant

## Resources
- **f1dataR Documentation**: https://scasanova.github.io/f1dataR/
- **F1 API (Ergast)**: https://ergast.com/mrd/
- **ggplot2 Documentation**: https://ggplot2.tidyverse.org/
- **Tidyverse Style Guide**: https://www.tidyverse.org/
- **Jujutsu VCS**: https://github.com/martinvonz/jj
- **High Contrast Theme**: https://github.com/topfunky/gghighcontrast

## Contact & Contribution
This project uses AI agents for development. All changes should be well-documented and tested before committing.
