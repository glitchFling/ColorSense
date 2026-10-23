#!/usr/bin/env bash
source ./colorsense.sh
source ./poweronn.sh

# Define the comprehensive color list globally
color_names=(
    "crimson" "scarlet" "ruby" "red" "orange" "amber" "gold" "yellow" 
    "lime" "green" "emerald" "teal" "cyan" "skyblue" "azure" "blue" 
    "navy" "indigo" "lavender" "purple" "violet" "magenta" "pink" 
    "rose" "coral" "salmon" "beige" "brown" "bronze" "silver" 
    "white" "ivory" "grey" "charcoal" "black"
)

# Retained for fallback or alternate use
random_color() {
    echo "${color_names[$RANDOM % ${#color_names[@]}]}"
}

faker() { node -e "const { faker } = require('@faker-js/faker'); console.log(faker.$1);"; }
uniqolor() { node -e "const uniqolor = require('uniqolor'); console.log(uniqolor('$1').color);"; }

echo "TEST 1: All Listed Colors with Hex Codes"
# Loop sequentially through every item in the color_names array
for chosen in "${color_names[@]}"; do
  # 1. Fetch the exact Hex code dynamically using your uniqolor setup
  hex_code=$(uniqolor "$chosen")
  
  # 2. Print the formatted markdown-style label on the left with padding
  printf "%-25s -> " "[$chosen]($hex_code)"
  
  # 3. Process the stylized token immediately on the right of the label
  colorsense color "$chosen" "nullscape"
  
  # 4. Finish the line cleanly
  echo
done
