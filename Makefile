.PHONY: help format format-check clean plots install

help:
	@echo "Available targets:"
	@echo "  format       - Format all R files using air"
	@echo "  format-check - Check R file formatting without modifying"
	@echo "  plots        - Generate all plots"
	@echo "  clean        - Remove generated plots and cache"
	@echo "  install      - Install R dependencies"

# Format all R source files with air
format:
	@echo "Formatting R files with air..."
	@find . -name "*.R" -not -path "*/renv/*" -not -path "*/.Rproj.user/*" | xargs -I {} air {}
	@echo "Formatting complete!"

# Check formatting without modifying files
format-check:
	@echo "Checking R file formatting..."
	@find . -name "*.R" -not -path "*/renv/*" -not -path "*/.Rproj.user/*" | xargs -I {} air --check {}

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

# Install R dependencies
install:
	@echo "Installing R dependencies..."
	@Rscript -e "install.packages(c('remotes', 'ggplot2', 'dplyr', 'tidyr', 'lubridate', 'scales'))"
	@Rscript -e "remotes::install_github('SCasanova/f1dataR')"
	@echo "Dependencies installed!"
