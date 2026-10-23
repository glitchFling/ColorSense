#!/usr/bin/env bash
source ./colorsense.sh
source ./poweronn.sh

# Color name Generator
random_color() {
    # All names are lowercase and space-free for stable CLI utility parsing
    local color_names=(
        "crimson" "scarlet" "ruby" "red" "orange" "amber" "gold" "yellow" 
        "lime" "green" "emerald" "teal" "cyan" "skyblue" "azure" "blue" 
        "navy" "indigo" "lavender" "purple" "violet" "magenta" "pink" 
        "rose" "coral" "salmon" "beige" "brown" "bronze" "silver" 
        "white" "ivory" "grey" "charcoal" "black"
    )

    # Select and print a random index from the array safely
    echo "${color_names[$RANDOM % ${#color_names[@]}]}"
}

faker() { node -e "const { faker } = require('@faker-js/faker'); console.log(faker.$1);"; }
uniqolor() { node -e "const uniqolor = require('uniqolor'); console.log(uniqolor('$1').color);"; }

echo "TEST 1: Basic Colors"
for i in {1..5}; do
  # 1. Grab a single random color name and store it
  chosen=$(random_color)
  
  # 2. Print the plain-text color label on the left with uniform spacing
  printf "%-12s -> " "[$chosen]"
  
  # 3. Process the stylized token immediately on the right of the label
  colorsense color "$chosen" "nullscape"
  
  # 4. Finish the line cleanly
  echo
done
