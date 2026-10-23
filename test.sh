#!/usr/bin/env bash
source ./colorsense.sh
source ./poweronn.sh

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

echo "TEST 1: All Listed Colors"
# Loop sequentially through every item in the color_names array
for chosen in "${color_names[@]}"; do
  # 1. Print the plain-text color label on the left with uniform spacing
  printf "%-12s -> " "[$chosen]"
  
  # 2. Process the stylized token immediately on the right of the label
  colorsense color "$chosen" "nullscape"
  
  # 3. Finish the line cleanly
  echo
done
