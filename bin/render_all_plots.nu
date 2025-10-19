#!/usr/bin/env nu
# Render all R plot scripts in the scripts directory

# Color helper functions using ansi
def red [text: string] {
    print $"(ansi red)($text)(ansi reset)"
}

def green [text: string] {
    print $"(ansi green)($text)(ansi reset)"
}

def yellow [text: string] {
    print $"(ansi yellow)($text)(ansi reset)"
}

def blue [text: string] {
    print $"(ansi blue)($text)(ansi reset)"
}

blue "========================================"
blue "F1 Analytics - Rendering All Plots"
blue "========================================"
print ""

# Create plots directory if it doesn't exist
if not ("plots" | path exists) {
    yellow "Creating plots directory..."
    mkdir plots
}

# Create data cache directory if it doesn't exist
if not ("data/cache" | path exists) {
    yellow "Creating data/cache directory..."
    mkdir data/cache
}

# Define script categories
let script_dir = "scripts"

# Utility scripts that should not be run directly
let utility_scripts = [
    "color_utils.R"
    "utils.R"
]

# Data gathering scripts (must run first)
let data_scripts = [
    "_setup_project.R"
    "calculate_driver_points_robust.R"
]

# Analysis scripts (depend on data gathering)
let analysis_scripts = [
    "analyze_driver_points.R"
    "visualize_driver_points.R"
]

# Get all R scripts, excluding utilities and categorized scripts
let all_categorized = ($data_scripts | append $analysis_scripts)
let all_scripts = (ls scripts/*.R | get name | path basename)
let other_scripts = ($all_scripts | where {|script| 
    ($script not-in $utility_scripts) and ($script not-in $all_categorized)
} | sort)

# Count total scripts
let total_scripts = (($data_scripts | length) + ($analysis_scripts | length) + ($other_scripts | length))

if $total_scripts == 0 {
    yellow "No R scripts found in scripts/ directory"
    yellow "Create some R scripts that generate plots!"
    exit 0
}

print $"Found (ansi green)($total_scripts)(ansi reset) R script\(s\) to run"
print $"  - Data gathering: (ansi green)($data_scripts | length)(ansi reset)"
print $"  - Analysis: (ansi green)($analysis_scripts | length)(ansi reset)"
print $"  - Other: (ansi green)($other_scripts | length)(ansi reset)"
print ""

# Track results
mut success_count = 0
mut fail_count = 0
mut failed_scripts = []
mut current = 0

# Function to run a script
def run_script [script_path: string, current: int, total: int] {
    let script_name = ($script_path | path basename)
    
    print $"(ansi blue)[($current)/($total)](ansi reset) Running (ansi green)($script_name)(ansi reset)..."
    
    # Run the R script
    let result = (do { Rscript $script_path } | complete)
    
    if $result.exit_code == 0 {
        print $"(ansi green)✓(ansi reset) ($script_name) completed successfully"
        return {success: true, script: $script_name}
    } else {
        print $"(ansi red)✗(ansi reset) ($script_name) failed"
        if ($result.stderr | str length) > 0 {
            print $result.stderr
        }
        return {success: false, script: $script_name}
    }
}

# Phase 1: Run data gathering scripts
yellow "Phase 1: Data Gathering"
yellow "========================"
for script in $data_scripts {
    let script_path = $"($script_dir)/($script)"
    if ($script_path | path exists) {
        $current = $current + 1
        let result = (run_script $script_path $current $total_scripts)
        if $result.success {
            $success_count = $success_count + 1
        } else {
            $fail_count = $fail_count + 1
            $failed_scripts = ($failed_scripts | append $result.script)
        }
        print ""
    } else {
        yellow $"Warning: Data script ($script) not found, skipping..."
    }
}

# Phase 2: Run analysis scripts
yellow "Phase 2: Analysis"
yellow "================="
for script in $analysis_scripts {
    let script_path = $"($script_dir)/($script)"
    if ($script_path | path exists) {
        $current = $current + 1
        let result = (run_script $script_path $current $total_scripts)
        if $result.success {
            $success_count = $success_count + 1
        } else {
            $fail_count = $fail_count + 1
            $failed_scripts = ($failed_scripts | append $result.script)
        }
        print ""
    } else {
        yellow $"Warning: Analysis script ($script) not found, skipping..."
    }
}

# Phase 3: Run other scripts
if ($other_scripts | length) > 0 {
    yellow "Phase 3: Other Scripts"
    yellow "======================"
    for script in $other_scripts {
        let script_path = $"($script_dir)/($script)"
        $current = $current + 1
        let result = (run_script $script_path $current $total_scripts)
        if $result.success {
            $success_count = $success_count + 1
        } else {
            $fail_count = $fail_count + 1
            $failed_scripts = ($failed_scripts | append $result.script)
        }
        print ""
    }
}

# Summary
blue "========================================"
blue "Summary"
blue "========================================"
print $"Total scripts: ($total_scripts)"
green $"Successful: ($success_count)"
red $"Failed: ($fail_count)"

if $fail_count > 0 {
    print ""
    red "Failed scripts:"
    for failed in $failed_scripts {
        print $"  (ansi red)✗(ansi reset) ($failed)"
    }
    exit 1
} else {
    print ""
    green "All plots generated successfully! 🏎️"
    exit 0
}
