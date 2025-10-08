.PHONY: help format format-check clean plots install renv-install renv-init renv-snapshot renv-restore renv-status renv-update renv-clean

help:
	@echo "Available targets:"
	@echo "  format        - Format all R files using air"
	@echo "  format-check  - Check R file formatting without modifying"
	@echo "  plots         - Generate all plots"
	@echo "  clean         - Remove generated plots and cache"
	@echo "  install       - Install R dependencies (traditional method)"
	@echo ""
	@echo "renv targets (recommended for reproducible environments):"
	@echo "  renv-install  - Install renv package"
	@echo "  renv-init     - Initialize renv in project"
	@echo "  renv-snapshot - Save current package versions to renv.lock"
	@echo "  renv-restore  - Install packages from renv.lock"
	@echo "  renv-status   - Check if packages are in sync with renv.lock"
	@echo "  renv-update   - Update packages to latest versions"
	@echo "  renv-clean    - Remove unused packages from renv cache"

# Format all R source files with air
format:
	@echo "Formatting R files with air..."
	@find . -name "*.R" -not -path "*/renv/*" -not -path "*/.Rproj.user/*" | xargs -I {} air format {}
	@echo "Formatting complete!"

# Check formatting without modifying files
format-check:
	@echo "Checking R file formatting..."
	@find . -name "*.R" -not -path "*/renv/*" -not -path "*/.Rproj.user/*" | xargs -I {} air format --check {}

# Generate all plots
plots:
	@echo "Generating all plots..."
	@./scripts/render_all_plots.sh

# Clean generated files
clean:
	@echo "Cleaning generated files..."
	@rm -rf plots/*.png plots/*.pdf
	@rm -rf data/cache/*.rds
	@rm -rf .f1dataR_cache/
	@echo "Clean complete!"

# Install R dependencies (traditional method)
install:
	@echo "Installing R dependencies from cran4linux RSPM..."
	@Rscript -e "options(repos = c(RSPM = 'https://cran4linux.github.io/rspm/', CRAN = 'https://cloud.r-project.org/')); install.packages(c('remotes', 'ggplot2', 'dplyr', 'tidyr', 'lubridate', 'scales'))"
	@Rscript -e "options(repos = c(RSPM = 'https://cran4linux.github.io/rspm/', CRAN = 'https://cloud.r-project.org/')); remotes::install_github('SCasanova/f1dataR')"
	@echo "Dependencies installed!"

# ==================== renv targets ====================

# Install renv package
renv-install:
	@echo "Installing renv package from cran4linux RSPM..."
	@Rscript -e "options(repos = c(RSPM = 'https://cran4linux.github.io/rspm/', CRAN = 'https://cloud.r-project.org/')); if (!requireNamespace('renv', quietly = TRUE)) install.packages('renv')"
	@echo "renv installed successfully!"

# Initialize renv in the project
renv-init:
	@echo "Initializing renv with cran4linux RSPM repository..."
	@Rscript -e "options(repos = c(RSPM = 'https://cran4linux.github.io/rspm/', CRAN = 'https://cloud.r-project.org/')); renv::init(repos = c(RSPM = 'https://cran4linux.github.io/rspm/', CRAN = 'https://cloud.r-project.org/'))"
	@echo "renv initialized! A private library has been created."
	@echo "Note: Add renv/ and renv.lock to your version control."

# Save current package versions to renv.lock
renv-snapshot:
	@echo "Taking snapshot of current packages..."
	@Rscript -e "renv::snapshot()"
	@echo "Snapshot saved to renv.lock!"
	@echo "Commit renv.lock to preserve this environment state."

# Install packages from renv.lock
renv-restore:
	@echo "Restoring packages from renv.lock using cran4linux RSPM..."
	@Rscript -e "options(repos = c(RSPM = 'https://cran4linux.github.io/rspm/', CRAN = 'https://cloud.r-project.org/')); renv::restore()"
	@echo "Packages restored successfully!"

# Check if packages are in sync with renv.lock
renv-status:
	@echo "Checking renv status..."
	@Rscript -e "renv::status()"

# Update packages to latest versions
renv-update:
	@echo "Updating packages from cran4linux RSPM..."
	@Rscript -e "options(repos = c(RSPM = 'https://cran4linux.github.io/rspm/', CRAN = 'https://cloud.r-project.org/')); renv::update()"
	@echo "Packages updated! Run 'make renv-snapshot' to save changes."

# Remove unused packages from renv cache
renv-clean:
	@echo "Cleaning unused packages..."
	@Rscript -e "renv::clean()"
	@echo "Cleanup complete!"
