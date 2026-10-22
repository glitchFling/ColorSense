#!/usr/bin/env bash
source ./colorsense.sh
colorsense color red "hello"
echo
colorsense color "#000000" "sup"
echo
colorsense gradient "-red" "--#00764d" "super"
echo
echo "$(colorsense color blue "Kooples") world"
