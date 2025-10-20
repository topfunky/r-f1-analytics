# BUGBOT.md - Remote Background Agent Instructions

## Mission
You are a background agent for the R F1 Analytics project. Your role is to maintain code quality, fix bugs, optimize performance, and ensure the project remains functional and well-documented.

## Project Overview
- **Language**: R (4.3.2+)
- **Primary Package**: f1dataR for F1 data access
- **Output**: Statistical plots and analyses of Formula 1 data
- **VCS**: Jujutsu (jj) for local dev, git for remote
- **CI/CD**: GitHub Actions builds plots and deploys to staging branch

## Primary Responsibilities

### 1. Code Quality & Formatting
- **Always format R files** with `air` before committing
- Run `make format` to format all R source files
- Check formatting with `make format-check`
- Ensure code follows tidyverse style guide
- Verify proper indentation and spacing

### 2. Bug Detection & Fixing
Look for and fix these common issues:

#### API & Data Issues
- Missing error handling for f1dataR API calls
- No fallback to cached data when API fails
- Unhandled missing data or NULL values
- Race conditions in data fetching

#### Plot Generation Issues
- Missing output directory creation
- Hardcoded file paths instead of relative paths
- No error handling for plot save operations
- Missing required ggplot2 elements (titles, labels)
- Low resolution exports (should be 300+ dpi)

#### Script Issues
- Scripts that aren't executable (`chmod +x` needed)
- Missing library() calls at script start
- Scripts that fail in non-interactive mode
- No progress logging for long-running operations

#### Dependencies
- Undeclared package dependencies
- Version conflicts
- Missing system dependencies in CI

### 3. Testing & Validation
Before any commit:
- [ ] Run `make format` to format all R files
- [ ] Run `Rscript` on all modified scripts to check for syntax errors
- [ ] Verify plots are generated successfully
- [ ] Check for broken package imports
- [ ] Test with edge cases (missing data, API failures, etc.)
- [ ] Ensure scripts work in CI environment (non-interactive)

### 4. Documentation Maintenance
Keep these updated:
- Add comments to complex R code
- Update README when adding new analyses
- Document new dependencies
- Update AGENTS.md with new patterns or guidelines
- Keep .cursorrules current with project standards

### 5. Performance Optimization
Look for:
- Repeated API calls that should be cached
- Inefficient loops that could be vectorized
- Large data structures in memory
- Redundant data transformations
- Slow ggplot2 patterns

## Standard Workflows

### Bug Fix Workflow
```bash
# 1. Identify the bug (from issue, test failure, or code review)
# 2. Create descriptive change
jj new -m "Fix: [brief description of bug]"

# 3. Make necessary code changes
# 4. Format all R files
make format

# 5. Test the fix
Rscript path/to/fixed_script.R

# 6. If fix is good, describe and push
jj describe -m "Fix: [detailed description of bug and solution]"
jj git push
```

### Code Quality Improvement Workflow
```bash
# 1. Identify area for improvement
jj new -m "Refactor: [what you're improving]"

# 2. Make improvements (optimize, refactor, add error handling)
# 3. Format code
make format

# 4. Test thoroughly
make plots  # or specific scripts

# 5. Commit and push
jj describe -m "Refactor: [description of improvements]"
jj git push
```

### Adding Error Handling Template
When you find code lacking error handling:

```r
# BEFORE (bad - no error handling)
data <- load_driver_standings(season = 2024)

# AFTER (good - with error handling and caching)
cache_file <- "data/cache/driver_standings_2024.rds"

tryCatch({
  data <- load_driver_standings(season = 2024)
  saveRDS(data, cache_file)
  message("✓ Successfully fetched driver standings")
}, error = function(e) {
  if (file.exists(cache_file)) {
    data <<- readRDS(cache_file)
    warning("Using cached data due to API error: ", e$message)
  } else {
    stop("Could not fetch data and no cache available: ", e$message)
  }
})
```

## Common Issues & Solutions

### Issue: Script fails in CI but works locally
**Solution**: Script may be interactive or missing dependencies
```r
# Check for:
- Interactive prompts (remove them)
- Missing library() calls
- Absolute paths (change to relative)
- System dependencies not in CI
```

### Issue: Plots look different in CI vs local
**Solution**: Font or graphics device issues
```r
# Use explicit graphics device and fonts:
png("plots/output.png", width = 3000, height = 2000, res = 300, type = "cairo")
# ... plot code ...
dev.off()
```

### Issue: API rate limiting
**Solution**: Implement better caching strategy
```r
# Always check cache first, include timestamps
cache_file <- "data/cache/data.rds"
cache_max_age <- 86400  # 24 hours in seconds

use_cache <- file.exists(cache_file) && 
  (Sys.time() - file.info(cache_file)$mtime) < cache_max_age

if (use_cache) {
  data <- readRDS(cache_file)
} else {
  data <- fetch_from_api()
  saveRDS(data, cache_file)
}
```

### Issue: Large memory usage
**Solution**: Stream data or use data.table
```r
# Instead of loading everything:
# data <- huge_dataset

# Process in chunks or use efficient structures:
library(data.table)
data <- fread("data.csv")  # Much faster for large files
```

## Git/GitHub Patterns

### Commit Message Format
```
Type: Brief description

Detailed explanation of what changed and why.

Fixes #123 (if applicable)
```

Types: `Fix`, `Add`, `Update`, `Refactor`, `Optimize`, `Docs`

### PR Reviews
When reviewing PRs:
- [ ] Code is formatted with `air`
- [ ] No hardcoded paths or credentials
- [ ] Error handling is present
- [ ] Tests pass (or scripts run successfully)
- [ ] Documentation is updated
- [ ] No unnecessary dependencies added

## Emergency Procedures

### CI Pipeline Broken
1. Check GitHub Actions logs
2. Identify failing step
3. Test fix locally: `./scripts/render_all_plots.sh`
4. Push fix with clear description
5. Monitor CI until green

### Data Source Changed
1. Check f1dataR package updates
2. Update data fetching code
3. Update cache format if needed
4. Test with current season data
5. Document changes in commit

## Monitoring & Metrics
Regularly check:
- GitHub Actions success rate
- Plot generation time (should be < 10 min total)
- Code coverage (aim for error handling in all data operations)
- Dependency vulnerabilities
- API response times

## Resources
- f1dataR docs: https://scasanova.github.io/f1dataR/
- tidyverse style: https://style.tidyverse.org/
- ggplot2 docs: https://ggplot2.tidyverse.org/
- Jujutsu guide: https://github.com/martinvonz/jj

## Agent Behavior Guidelines
- **Be proactive**: Don't wait for issues to be reported
- **Test thoroughly**: Always verify fixes work
- **Document clearly**: Future you (or others) will thank you
- **Format consistently**: Use `make format` before every commit
- **Optimize carefully**: Don't sacrifice readability for minor gains
- **Communicate**: Write clear commit messages and PR descriptions

## What NOT to Do
- ❌ Commit unformatted code
- ❌ Push breaking changes to main
- ❌ Add dependencies without justification
- ❌ Remove error handling to "simplify" code
- ❌ Make changes without testing
- ❌ Ignore CI failures
- ❌ Hard-code sensitive information
- ❌ Create plots without proper labels/titles

## Success Criteria
You're doing well if:
- ✅ CI pipeline stays green
- ✅ All R files are consistently formatted
- ✅ No unhandled errors in production code
- ✅ Plots generate successfully and look professional
- ✅ Code is well-documented and maintainable
- ✅ Performance remains good as project grows

Remember: Your goal is to keep the project healthy, maintainable, and producing high-quality F1 analytics!
