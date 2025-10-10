#!/bin/bash

# pick_image_and_render.sh
# Interactive script to select and display F1 analytics plots using gum filter and imgcat

# Check if gum is installed
if ! command -v gum &> /dev/null; then
    echo "Error: gum is not installed. Please install it first:"
    echo "  brew install gum"
    echo "  or visit: https://github.com/charmbracelet/gum"
    exit 1
fi

# Check if imgcat is installed
if ! command -v imgcat &> /dev/null; then
    echo "Error: imgcat is not installed. Please install it first:"
    echo "  brew install imgcat"
    exit 1
fi

# Check if plots directory exists and has PNG files
if [ ! -d "plots" ] || [ -z "$(ls plots/*.png 2>/dev/null)" ]; then
    echo "Error: No PNG files found in plots/ directory"
    echo "Please run some analysis scripts first to generate plots"
    exit 1
fi

# Run the command to filter and display images
chosen_img=$(ls plots/*.png | gum filter)
echo "Displaying ${chosen_img}"
imgcat ${chosen_img}
