#!/usr/bin/env bash
source ./colorsense.sh
source ./poweronn.sh

# Color name Generator
random_color() {
    # A comprehensive list of clean, classic color names
    local color_names=(
        "Crimson" "Scarlet" "Ruby" "Red" "Orange" "Amber" "Gold" "Yellow" 
        "Lime" "Green" "Emerald" "Teal" "Cyan" "Sky Blue" "Azure" "Blue" 
        "Navy" "Indigo" "Lavender" "Purple" "Violet" "Magenta" "Pink" 
        "Rose" "Coral" "Salmon" "Beige" "Brown" "Bronze" "Silver" 
        "White" "Ivory" "Grey" "Charcoal" "Black"
    )

    # Select and print a random index from the array
    echo "${color_names[$RANDOM % ${#color_names[@]}]}"
}

faker() { node -e "const { faker } = require('@faker-js/faker'); console.log(faker.$1);"; }
uniqolor() { node -e "const uniqolor = require('uniqolor'); console.log(uniqolor('$1').color);"; }

echo "TEST 1: Basic Colors"
for i in {1..5}; do
  colorsense color "$(random_color)" "nullscape"; echo
done
