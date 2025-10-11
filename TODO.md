# TODO

Refer to https://cran.csail.mit.edu/web/packages/f1dataR/readme/README.html for API details.

Utility functions in f1dataR

```R
get_driver_abbreviation()
get_driver_color()
get_driver_color_map()
get_driver_colour()
get_driver_colour_map()
get_driver_name()
get_driver_style()
get_driver_telemetry()
get_drivers_by_team()
get_session_drivers_and_teams()
get_team_by_driver()
get_team_color()
get_team_colour()
get_team_name()
get_tire_compounds()
```

Data loading functions in f1dataR

```R
load_constructors()
load_drivers(season = "current")
load_circuits(season = "current")
load_pitstops(season = "current", round = "last")
load_quali(season = "current", round = "last")
load_results(season = "current", round = "last")
load_schedule(season =2025)
load_sprint(season = "current", round = "last")
load_standings(season = "current", round = "last", type = c("driver", "constructor"))
```

## Use f1dataR cache capability instead of manual.

```R
options(f1dataR.cache = "path/to/directory")
```

## Plot a track and gears in use

```R
plot_fastest(season = 2022, round = 12, session = "R", driver = "VER", color = "gear")
```
