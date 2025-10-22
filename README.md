# R F1 Analytics Project 🏎️

A data analysis and visualization project for Formula 1 statistics using R and the [f1dataR](https://scasanova.github.io/f1dataR/) package.

## Project Overview

This project provides tools and scripts for analyzing Formula 1 data, generating insights, and creating publication-quality visualizations. It uses modern R packages and follows best practices for reproducible research.

## Features

- 📊 Automated plot generation from F1 data
- 🔄 GitHub Actions CI/CD pipeline
- 💾 Smart data caching to minimize API calls
- 🎨 Consistent, professional visualizations
- 📝 Comprehensive documentation for AI agents
- 🔧 Development tools and utilities

## Quick Start

### Prerequisites

- R (version 4.3.2 or higher)
- Git
- [Jujutsu (jj)](https://github.com/martinvonz/jj) - recommended for local development
- `air` - R code formatter (optional but recommended)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd r-f1-analytics
   ```

1. **Install R dependencies**
   ```bash
   make install
   # or
   Rscript scripts/setup_project.R
   ```

1. **Generate example plots**
   ```bash
   make plots
   # or
   ./scripts/render_all_plots.sh
   ```

## Project Structure

```
r-f1-analytics/
├── .github/
│   └── workflows/
│       └── build-plots.yml      # CI/CD pipeline
├── scripts/
│   ├── render_all_plots.sh      # Master plotting script
│   ├── setup_project.R          # Dependency installer
│   ├── example_lap_times.R      # Example: Lap time analysis
│   ├── example_standings.R      # Example: Championship standings
│   └── README.md                # Scripts documentation
├── plots/                       # Generated plots (gitignored)
├── data/cache/                  # Cached API data (gitignored)
├── .gitignore                   # Git ignore rules
├── .jjconfig.toml              # Jujutsu configuration
├── .jjignore                    # Jujutsu ignore rules
├── .cursorrules                 # Cursor AI configuration
├── Makefile                     # Build automation
├── AGENTS.md                    # AI agent guidelines
├── BUGBOT.md                    # Bug fix agent instructions
└── README.md                    # This file
```

## Usage

### Available Make Commands

```bash
make help          # Show all available commands
make format        # Format all R files with air
make format-check  # Check formatting without modifying
make plots         # Generate all plots
make clean         # Remove generated files
make install       # Install R dependencies
```

### Running Individual Scripts

```bash
# Run a specific analysis
Rscript scripts/example_lap_times.R

# Run all analyses
./scripts/render_all_plots.sh
```

### Version Control with Jujutsu

For local development, we use [Jujutsu (jj)](https://github.com/martinvonz/jj):

```bash
# Create a new change
jj new -m "Add: new lap time visualization"

# Make your changes, then describe them
jj describe -m "Add lap time distribution analysis for 2024 season"

# Format code before pushing
make format

# Push to remote
jj git push
```

## Development Workflow

### Adding New Analyses

1. Create a new R script in `scripts/`
1. Follow the template structure (see `scripts/README.md`)
1. Make it executable: `chmod +x scripts/your_script.R`
1. Test locally: `Rscript scripts/your_script.R`
1. Format code: `make format`
1. Commit and push

### Code Style

- Follow [tidyverse style guide](https://style.tidyverse.org/)
- Use `air` formatter: `make format`
- Add comments for complex logic
- Use meaningful variable names
- Include error handling

## CI/CD Pipeline

The GitHub Actions workflow automatically:

1. ✅ Checks R code formatting
1. 📦 Installs dependencies
1. 🎨 Generates all plots
1. 🚀 Deploys to `staging` branch

Plots are available on the `staging` branch after each push to `main`.

## Key Technologies

- **[f1dataR](https://scasanova.github.io/f1dataR/)** - F1 data access via Ergast API
- **[ggplot2](https://ggplot2.tidyverse.org/)** - Data visualization
- **[dplyr](https://dplyr.tidyverse.org/)** - Data manipulation
- **[tidyr](https://tidyr.tidyverse.org/)** - Data tidying
- **[Jujutsu](https://github.com/martinvonz/jj)** - Version control system

## Documentation

- **[AGENTS.md](AGENTS.md)** - Comprehensive guidelines for AI development agents
- **[BUGBOT.md](BUGBOT.md)** - Instructions for automated bug fixing and quality checks
- **[scripts/README.md](scripts/README.md)** - Detailed documentation for analysis scripts
- **[.cursorrules](.cursorrules)** - Configuration for Cursor AI assistant

## Contributing

This project uses AI agents for development. When contributing:

1. Read `AGENTS.md` for development guidelines
1. Follow the code style guide
1. Format code with `make format`
1. Test scripts before committing
1. Update documentation as needed

## Data Sources

- **Primary**: [Ergast Developer API](https://ergast.com/mrd/) via f1dataR
- **Caching**: Local caching to minimize API load and improve performance

## Common Tasks

### Install new R package
```r
install.packages("package_name")
# or for GitHub packages
remotes::install_github("user/repo")
```

### Clear cache
```bash
make clean
```

### Debug a script
```bash
Rscript --verbose scripts/your_script.R
```

### Check R syntax
```bash
R CMD check scripts/your_script.R
```

## Troubleshooting

### API Rate Limiting
If you encounter API rate limits:
- Use cached data (automatically handled)
- Add delays between requests
- Run during off-peak hours

### Package Installation Issues
```r
# Update remotes
install.packages("remotes")

# Force reinstall f1dataR
remotes::install_github("SCasanova/f1dataR", force = TRUE)
```

### Plot Rendering Issues
- Ensure `plots/` directory exists
- Check graphics device settings
- Verify sufficient disk space
- Use `type = "cairo"` for PNG exports

## Resources

- [f1dataR Documentation](https://scasanova.github.io/f1dataR/)
- [Ergast F1 API](https://ergast.com/mrd/)
- [ggplot2 Reference](https://ggplot2.tidyverse.org/)
- [Tidyverse Style Guide](https://style.tidyverse.org/)
- [Jujutsu Tutorial](https://github.com/martinvonz/jj/blob/main/docs/tutorial.md)

## License

[Add your license here]

## Contact

[Add contact information]

---

Built with ❤️ and R for Formula 1 data analysis
