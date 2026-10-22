#!/usr/bin/env bash
source ./colorsense.sh
source ./poweronn.sh

faker() { node -e "const { faker } = require('@faker-js/faker'); console.log(faker.$1);"; }
uniqolor() { node -e "const uniqolor = require('uniqolor'); console.log(uniqolor('$1').color);"; }

echo "TEST 1: Basic Color"; colorsense color red "nullscape"; echo
echo "TEST 2: Hex Color"; colorsense color "#000000" "sup"; echo
echo "TEST 3: Gradient"; colorsense gradient "-red" "--#00764d" "super"; echo
echo "TEST 4: Inline Color"; echo "$(colorsense color blue "Kooples") world"; echo

echo "TEST 5: uniqolor-generated color for random text"
T=$(faker "word.sample()"); colorsense color "$(uniqolor "$T")" "$T"; echo

echo "TEST 6: faker-generated hex color on random text"
colorsense color "$(faker "color.rgb()")" "$(faker "word.sample()")"; echo

echo "TEST 7: Gradient from uniqolor to faker color"
colorsense gradient "-$(uniqolor 'start point')" "--$(faker "color.rgb()")" "$(faker "word.words(3)")"; echo

echo "TEST 8: Detect hex color"; colorsense detect "#00764d"; echo
echo "TEST 9: Detect named color"; colorsense detect blue; echo
echo "TEST 10: PowerOnn - word present"; poweronn "the quick brown fox" "brown"; echo
echo "TEST 11: PowerOnn - word absent"; poweronn "the quick brown fox" "cat"; echo
echo "TEST 12: PowerOnn - case-insensitive"; poweronn "The Quick Brown Fox" "quick"; echo
echo "TEST 13: PowerOnn with faker text"; poweronn "$(faker "word.words(3)")" "zzzznotfoundzzzz"; echo
