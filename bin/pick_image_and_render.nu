#!/usr/bin/env nu
# pick_image_and_render.nu
# Interactive script to select and display F1 analytics plots using gum filter and imgcat

# Check if gum is installed
def check_command [cmd: string] {
    if (which $cmd | is-empty) {
        if $cmd == "gum" {
            print $"Error: gum is not installed. Please install it first:"
            print $"  brew install gum"
            print $"  or visit: https://github.com/charmbracelet/gum"
        } else if $cmd == "imgcat" {
            print $"Error: imgcat is not installed. Please install it first:"
            print $"  brew install imgcat"
        }
        exit 1
    }
}

# Check required commands
check_command "gum"
check_command "imgcat"

# Check if plots directory exists and has PNG files
if not ("plots" | path exists) {
    print "Error: plots/ directory does not exist"
    print "Please run some analysis scripts first to generate plots"
    exit 1
}

let png_files = (ls plots/*.png | length)
if $png_files == 0 {
    print "Error: No PNG files found in plots/ directory"
    print "Please run some analysis scripts first to generate plots"
    exit 1
}

# Get list of PNG files and pipe to gum filter
let chosen_img = (ls plots/*.png | get name | str join "\n" | gum filter)

if ($chosen_img | is-empty) {
    print "No image selected"
    exit 0
}

print $"Displaying ($chosen_img)"
imgcat $chosen_img
