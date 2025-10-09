# F1 Driver Points Analysis (Post-2010 Scoring System)

## Overview

This analysis calculates individual driver points using the post-2010 scoring system (25, 18, 15, 12, 10, 8, 6, 4, 2, 1) for Formula 1 seasons 2023-2024. The analysis provides both race-by-race points and cumulative points for each driver.

## Files Generated

### Data Files
- `driver_points_race_by_race.csv` - Race-by-race points for each driver
- `driver_points_cumulative.csv` - Cumulative points progression for each driver
- `driver_points_summary.txt` - Summary statistics

### Visualization Files
- `championship_standings.png` - Championship standings comparison
- `points_progression.png` - Points progression over the season
- `constructor_comparison.png` - Constructor championship points
- `scoring_comparison.png` - Original vs new scoring system comparison
- `points_distribution.png` - Distribution of points awarded

### Scripts
- `calculate_driver_points.R` - Main calculation script
- `calculate_driver_points_robust.R` - Robust version with rate limiting
- `analyze_driver_points.R` - Analysis and summary script
- `visualize_driver_points.R` - Visualization generation script

## Data Summary

### Seasons Analyzed
- **2023**: 22 races, 22 drivers, 440 race entries
- **2024**: 24 races, 24 drivers, 479 race entries

### Key Findings

#### 2023 Season Champions (New Scoring System)
1. **Max Verstappen** (Red Bull) - 521 points (original: 530)
2. **Sergio Pérez** (Red Bull) - 258 points (original: 260)
3. **Lewis Hamilton** (Mercedes) - 213 points (original: 217)

#### 2024 Season Champions (New Scoring System)
1. **Max Verstappen** (Red Bull) - 396 points (original: 399)
2. **Lando Norris** (McLaren) - 338 points (original: 344)
3. **Charles Leclerc** (Ferrari) - 324 points (original: 327)

### Scoring System Impact

The post-2010 scoring system shows minimal differences from the original system:
- Most drivers lost 1-9 points due to the removal of fastest lap bonus points
- The ranking order remains largely unchanged
- Max Verstappen lost the most points (9 in 2023, 3 in 2024) due to fastest lap bonuses

### Constructor Performance

#### 2023 Season
1. **Red Bull** - 779 points (2 drivers)
2. **Mercedes** - 369 points (2 drivers)
3. **Ferrari** - 363 points (2 drivers)

#### 2024 Season
1. **Red Bull** - 533 points (2 drivers)
2. **McLaren** - 603 points (2 drivers)
3. **Ferrari** - 585 points (2 drivers)

## Technical Details

### Scoring System
- **1st place**: 25 points
- **2nd place**: 18 points
- **3rd place**: 15 points
- **4th place**: 12 points
- **5th place**: 10 points
- **6th place**: 8 points
- **7th place**: 6 points
- **8th place**: 4 points
- **9th place**: 2 points
- **10th place**: 1 point

### Data Sources
- **f1dataR package**: Fetches data from Ergast API
- **Caching**: Local caching to minimize API calls
- **Rate limiting**: Implemented to respect API limits

### Data Structure

#### Race-by-Race Points CSV
- `season`: Year
- `round`: Race number
- `driver_id`: Driver identifier
- `driver_name`: Driver full name
- `constructor_id`: Constructor identifier
- `constructor_name`: Constructor name
- `position`: Finishing position
- `original_points`: Original points awarded
- `new_points`: Points under new scoring system
- `status`: Race status (Finished, etc.)

#### Cumulative Points CSV
- All race-by-race columns plus:
- `cumulative_points`: Running total of new points
- `cumulative_original_points`: Running total of original points

## Usage

### Running the Analysis
```bash
# Calculate driver points
Rscript scripts/calculate_driver_points.R

# Analyze the results
Rscript scripts/analyze_driver_points.R

# Generate visualizations
Rscript scripts/visualize_driver_points.R
```

### Extending to More Seasons
To analyze additional seasons, modify the `START_YEAR` and `END_YEAR` variables in the scripts. Note that API rate limiting may require running the robust version with longer delays.

## Limitations

1. **API Rate Limiting**: The f1dataR package is subject to API rate limits, which may prevent processing all seasons in a single run
2. **Data Availability**: Some historical seasons may have incomplete data
3. **Fastest Lap Points**: The analysis removes fastest lap bonus points, which were introduced in 2019

## Future Enhancements

1. **Sprint Race Points**: Include sprint race points in the analysis
2. **Historical Seasons**: Process more historical seasons (2003-2022)
3. **Interactive Visualizations**: Create interactive plots using plotly
4. **Driver Comparisons**: Add head-to-head driver comparisons
5. **Team Analysis**: Expand constructor/team analysis

## Conclusion

The post-2010 scoring system provides a more balanced points distribution while maintaining the competitive nature of Formula 1. The analysis shows that while individual point totals change slightly, the overall championship standings remain largely consistent with the original system.

The data and visualizations provide valuable insights into driver performance and championship progression, making it a useful resource for F1 analysis and research.