#!/usr/bin/env bash
source ./colorsense.sh
source ./poweronn.sh

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

echo "TEST 8: Detect hex color"
colorsense detect "#00764d"
echo

echo "TEST 9: Detect named color"
colorsense detect blue
echo

echo "TEST 10: PowerOnn - word present"
poweronn "the quick brown fox" "brown"
echo

echo "TEST 11: PowerOnn - word absent"
poweronn "the quick brown fox" "cat"
echo

echo "TEST 12: PowerOnn - case-insensitive"
poweronn "The Quick Brown Fox" "quick"
echo

echo "TEST 13: PowerOnn with faker text"
ABSENT_TEXT=$(node -e "const { faker } = require('@faker-js/faker'); console.log(faker.word.words(3));")
poweronn "$ABSENT_TEXT" "zzzznotfoundzzzz"
echo
