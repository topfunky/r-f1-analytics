# AGENTS.md - AI Agent Guidelines for R F1 Analytics Project

## Project Overview
This is an R-based F1 analytics project that uses the `f1dataR` package to fetch Formula 1 data and generate visualizations and statistical analysis.

## Project Structure
```
r-f1-analytics/
├── scripts/           # R scripts for data analysis and plotting
├── plots/            # Generated plot outputs (gitignored)
├── data/             # Cached data files (gitignored)
├── .github/          # GitHub Actions workflows
└── README.md         # Project documentation
```

## Technology Stack
- **Language**: R (4.3.2+)
- **Key Package**: `f1dataR` - https://scasanova.github.io/f1dataR/
- **Visualization**: ggplot2, plotly
- **Data Manipulation**: dplyr, tidyr
- **Version Control**: Jujutsu (jj) for local development, git for remote

## Development Guidelines

### Code Style
1. Follow tidyverse style guide for R code
2. Use meaningful variable names (e.g., `driver_standings` not `ds`)
3. Comment complex data transformations
4. Use pipes (`%>%` or `|>`) for readability
5. Keep functions small and focused

### File Naming Conventions
- Scripts: `verb_subject.R` (e.g., `plot_lap_times.R`, `analyze_race_results.R`)
- Plots: `descriptive_name_YYYY-MM-DD.png` (e.g., `verstappen_wins_2024.png`)
- Use snake_case for all file and variable names

### Data Fetching Best Practices
1. Always cache data locally to avoid repeated API calls
2. Use `f1dataR` package functions appropriately
3. Handle missing data gracefully
4. Document data sources and fetch dates

### Plot Generation
1. All plots should be saved to `plots/` directory
2. Use consistent theme and color scheme across plots
3. Include proper titles, labels, and legends
4. Export in high resolution (300 dpi minimum)
5. Consider both light and dark theme compatibility

### Script Requirements
1. Each script should be runnable independently
2. Include error handling for data fetching
3. Log progress to console
4. Save outputs with timestamps

### Version Control with Jujutsu (jj)
1. Use `jj` for local development and experimentation
2. Create descriptive change descriptions: `jj describe -m "Add lap time analysis for 2024 season"`
3. Use `jj git push` to push to remote when ready
4. Squash experimental changes before pushing to main

### Testing
1. Verify plots render correctly
2. Test scripts with different seasons/races
3. Handle edge cases (e.g., sprint races, canceled races)
4. Validate data integrity before plotting

## Common Tasks

### Adding a New Analysis
1. Create a new R script in `scripts/`
2. Fetch required data using `f1dataR`
3. Perform analysis/transformation
4. Generate visualization
5. Save plot to `plots/`
6. Update README with new analysis description

### Running All Plots
```bash
./scripts/render_all_plots.sh
```

### Manual Plot Generation
```bash
Rscript scripts/your_plot_script.R
```

## Package Dependencies
Install required packages:
```r
install.packages(c("ggplot2", "dplyr", "tidyr", "lubridate", "scales"))
remotes::install_github("SCasanova/f1dataR")
```

## CI/CD Pipeline
- GitHub Actions automatically builds all plots on push to main
- Plots are deployed to a clean `staging` branch
- Review plots at: `https://github.com/[username]/r-f1-analytics/tree/staging/plots`

## Troubleshooting

### API Rate Limits
If you hit API rate limits:
1. Use cached data when available
2. Add delays between requests
3. Run scripts during off-peak hours

### Package Installation Issues
If f1dataR installation fails:
```r
# Install dependencies first
install.packages(c("httr", "jsonlite", "tibble", "dplyr"))
remotes::install_github("SCasanova/f1dataR", force = TRUE)
```

### Plot Rendering Issues
1. Check that output directory exists
2. Verify system graphics libraries are installed
3. Use `Rscript` instead of interactive R for consistent results

## Resources
- f1dataR Documentation: https://scasanova.github.io/f1dataR/
- F1 API: https://ergast.com/mrd/
- ggplot2 Documentation: https://ggplot2.tidyverse.org/
- Jujutsu VCS: https://github.com/martinvonz/jj

## Agent Behavior Expectations
1. **Be Proactive**: Suggest relevant analyses based on recent F1 events
2. **Explain Decisions**: Comment why certain visualizations or statistics are chosen
3. **Optimize Performance**: Cache data, vectorize operations, use efficient ggplot2 patterns
4. **Maintain Quality**: Generate publication-ready plots with proper styling
5. **Stay Current**: Use latest F1 season data when available
6. **Document Everything**: Add comments, update README, log changes

## Contact & Contribution
This project uses AI agents for development. All changes should be well-documented and tested before committing.
