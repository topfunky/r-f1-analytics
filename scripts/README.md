# Scripts Directory

This directory contains R scripts for F1 data analysis and visualization.

## Available Scripts

### Setup & Utilities

#### `setup_project.R`
Installs all required R packages and sets up project directories.
```bash
Rscript scripts/setup_project.R
```

#### `render_all_plots.sh`
Bash script that executes all R plotting scripts and generates output files.
```bash
./scripts/render_all_plots.sh
```

### Example Analyses

#### `example_lap_times.R`
Demonstrates lap time analysis for a specific race. Shows how to:
- Fetch and cache race data
- Process lap times
- Create line plots with multiple drivers
- Save high-resolution outputs

```bash
Rscript scripts/example_lap_times.R
```

#### `example_standings.R`
Creates championship standings progression visualization. Shows how to:
- Generate season-long data views
- Track cumulative points
- Create multi-driver comparisons
- Format tables and charts

```bash
Rscript scripts/example_standings.R
```

## Script Structure Template

All analysis scripts should follow this pattern:

```r
#!/usr/bin/env Rscript
# Brief description of what the script does

# 1. Load packages
suppressPackageStartupMessages({
  library(f1dataR)
  library(ggplot2)
  library(dplyr)
})

# 2. Configuration
SEASON <- 2024
CACHE_DIR <- "data/cache"
OUTPUT_DIR <- "plots"

# 3. Helper functions
fetch_with_cache <- function(fetch_func, cache_file, ...) {
  # Implementation
}

# 4. Main function
main <- function() {
  # Analysis logic
  # Plot creation
  # Save outputs
}

# 5. Run
main()
```

## Adding New Scripts

1. Create a new `.R` file in this directory
2. Follow the template structure above
3. Make it executable: `chmod +x scripts/your_script.R`
4. Test it: `Rscript scripts/your_script.R`
5. Format it: `make format`
6. It will automatically be picked up by `render_all_plots.sh`

## Best Practices

### Data Fetching
- Always cache API responses
- Handle errors gracefully
- Check cache before fetching
- Use descriptive cache filenames

### Plotting
- Use consistent themes
- Include proper titles and labels
- Export at 300+ dpi
- Save to `plots/` directory
- Use descriptive output filenames

### Code Quality
- Format with `air` before committing
- Add comments for complex logic
- Use meaningful variable names
- Handle edge cases
- Log progress to console

### Performance
- Vectorize operations when possible
- Use efficient ggplot2 patterns
- Don't load unnecessary data
- Process in chunks if needed

## Dependencies

Core packages required:
- `f1dataR` - F1 data access
- `ggplot2` - Plotting
- `dplyr` - Data manipulation
- `tidyr` - Data tidying
- `lubridate` - Date handling
- `scales` - Scale functions

Install all with:
```bash
make install
# or
Rscript scripts/setup_project.R
```

## Troubleshooting

### Script fails to run
```bash
# Check R syntax
R CMD check scripts/your_script.R

# Run with verbose output
Rscript --verbose scripts/your_script.R
```

### API errors
- Check internet connection
- Verify f1dataR is up to date
- Use cached data as fallback

### Plot rendering issues
- Ensure output directory exists
- Check available disk space
- Verify graphics packages installed

## Integration with CI/CD

Scripts in this directory are automatically:
1. Run by GitHub Actions on push to main
2. Checked for formatting
3. Generated plots deployed to staging branch

Ensure scripts:
- Are non-interactive
- Handle errors appropriately
- Create output directories if needed
- Work in CI environment (no display)

## Resources

- f1dataR documentation: https://scasanova.github.io/f1dataR/
- ggplot2 reference: https://ggplot2.tidyverse.org/
- Tidyverse style guide: https://style.tidyverse.org/
