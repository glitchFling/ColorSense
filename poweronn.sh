#!/usr/bin/env bash
# PowerOnn: an absent word detector
# Usage: poweronn <text> <word>
# Returns 0 if the word IS present, 1 if it is ABSENT.
poweronn() {
    local text="$1"
    local word="$2"
    local word_lower="${word,,}"
    local text_lower="${text,,}"
    if [[ "$text_lower" == *"$word_lower"* ]]; then
        echo "PowerOnn: word \"$word\" IS present in the text."
        return 0
    else
        echo "PowerOnn: word \"$word\" is ABSENT from the text."
        return 1
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [ "$#" -ne 2 ]; then
        echo "Usage: poweronn <text> <word>"
        exit 1
    fi
    poweronn "$1" "$2"
fi
