# Consistent Gear Colors

## Overview
All gear visualization plots now use a consistent color palette across all tracks and sessions. This ensures that each gear is always represented by the same color, regardless of whether all gears are present in a particular dataset.

## Fixed Gear Color Palette

The following colors are used consistently across all plots:

| Gear | Color | Hex Code |
|------|-------|----------|
| 1    | Blue  | #4477AA  |
| 2    | Red   | #EE6677  |
| 3    | Green | #228833  |
| 4    | Yellow| #CCBB44  |
| 5    | Cyan  | #66CCEE  |
| 6    | Purple| #AA3377  |
| 7    | Gray  | #BBBBBB  |
| 8    | Cream | #EECC66  |

## Key Features

1. **Gear 2 is always red** - Even on tracks like Monza where gear 2 is rarely or never used
1. **Gear 8 is always cream** - Even on street circuits like Monaco where gear 8 is not used
1. **Consistent legend** - All plots show all 8 gears in the legend, maintaining color consistency
1. **High contrast** - Colors are selected from the high contrast palette for better visibility

## Implementation

The fixed color palette is defined in `R/plot_functions.R` as the `GEAR_COLORS` constant:

```r
GEAR_COLORS <- c(
  "1" = "#4477AA", # Blue
  "2" = "#EE6677", # Red
  "3" = "#228833", # Green
  "4" = "#CCBB44", # Yellow
  "5" = "#66CCEE", # Cyan
  "6" = "#AA3377", # Purple
  "7" = "#BBBBBB", # Gray
  "8" = "#EECC66"  # Cream
)
```

The `apply_gear_colors()` helper function automatically applies this palette to any plot colored by gear:

```r
apply_gear_colors <- function(p) {
  p + ggplot2::scale_color_manual(
    values = GEAR_COLORS,
    name = "Gear",
    drop = FALSE,        # Keep all gears in legend
    limits = names(GEAR_COLORS)  # Use all 8 gears
  )
}
```

## Affected Functions

All gear visualization functions now use consistent colors:

- `plot_track_gears()` - Single race track gear plot
- `plot_tracks_patchwork()` - Multiple tracks in patchwork layout
- `plot_tracks_annotated()` - Annotated multi-track layout
- `plot_driver_comparison()` - Side-by-side driver comparison
- `plot_all_tracks_season()` - Faceted season-long view

## Testing

Run the verification script to confirm consistent colors across different track types:

```bash
Rscript scripts/verify_gear_colors.R
```

This generates a comparison plot showing:
- Monaco (low gears 2-5, street circuit)
- Silverstone (mixed gears, traditional circuit)
- Monza (high gears 6-8, high-speed circuit)

All three plots maintain the same color mapping, with gear 2 always red and gear 8 always cream.

## Benefits

1. **Visual Consistency** - Easier to compare gear usage across different tracks
1. **Immediate Recognition** - Drivers and analysts can quickly identify gear usage patterns
1. **Professional Quality** - Consistent color schemes improve presentation quality
1. **Accessibility** - High contrast colors remain visible across different displays

## Notes

- The color scale warning `"Adding another scale for colour, which will replace the existing scale"` is expected behavior, as we're overriding the default f1dataR color scale with our fixed palette
- Colors are chosen from the high contrast palette to ensure good visibility in both light and dark themes
- The `drop = FALSE` parameter ensures all gears appear in the legend even if not used in the data
