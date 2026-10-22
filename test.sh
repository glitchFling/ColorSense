#!/usr/bin/env bash
source ./colorsense.sh

echo "TEST 1: Basic Color"
colorsense color red "nullscape"
echo

echo "TEST 2: Hex Color"
colorsense color "#000000" "sup"
echo

echo "TEST 3: Gradient"
colorsense gradient "-red" "--#00764d" "super"
echo

echo "TEST 4: Inline Color"
echo "$(colorsense color blue "Kooples") world"
echo

echo "TEST 5: uniqolor-generated color for random text"
RANDOM_TEXT=$(node -e "const { faker } = require('@faker-js/faker'); console.log(faker.word.sample());")
UNIQ_COLOR=$(node -e "const uniqolor = require('uniqolor'); console.log(uniqolor('$RANDOM_TEXT').color);")
colorsense color "$UNIQ_COLOR" "$RANDOM_TEXT"
echo

echo "TEST 6: faker-generated hex color on random text"
FAKER_COLOR=$(node -e "const { faker } = require('@faker-js/faker'); console.log(faker.color.rgb());")
FAKER_TEXT=$(node -e "const { faker } = require('@faker-js/faker'); console.log(faker.word.sample());")
colorsense color "$FAKER_COLOR" "$FAKER_TEXT"
echo

echo "TEST 7: Gradient from uniqolor to faker color"
COLOR_A=$(node -e "const uniqolor = require('uniqolor'); console.log(uniqolor('start point').color);")
COLOR_B=$(node -e "const { faker } = require('@faker-js/faker'); console.log(faker.color.rgb());")
GRADIENT_TEXT=$(node -e "const { faker } = require('@faker-js/faker'); console.log(faker.word.words(3));")
colorsense gradient "-$COLOR_A" "--$COLOR_B" "$GRADIENT_TEXT"
echo
