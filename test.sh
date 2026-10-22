#!/usr/bin/env bash
source ./colorsense.sh
ECHO TEST 1: Basic Color
colorsense color red "nullscape"
echo
colorsense color "#000000" "sup"
echo
colorsense gradient "-red" "--#00764d" "super"
echo
echo "$(colorsense color blue "Kooples") world"
