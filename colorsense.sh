#!/usr/bin/env bash
# Helper function to convert Hex to RGB
hex_to_rgb() {
    local hex=${1#\#}
    printf "%d;%d;%d" "0x${hex:0:2}" "0x${hex:2:2}" "0x${hex:4:2}"
}
# Helper function to map basic color names to ANSI codes
get_color_code() {
    case "${1,,}" in
        black)   echo "30" ;;
        red)     echo "31" ;;
        green)   echo "32" ;;
        yellow)  echo "33" ;;
        blue)    echo "34" ;;
        magenta) echo "35" ;;
        cyan)    echo "36" ;;
        white)   echo "37" ;;
        *)       echo "" ;;
    esac
}
color_command() {
    local color_val="$1"
    local text="$2"
    local ansi_esc="\e[0m"
    if [[ "$color_val" =~ ^#[0-9a-fA-F]{6}$ ]]; then
        # TrueColor (24-bit)
        local rgb=$(hex_to_rgb "$color_val")
        echo -ne "\e[38;2;${rgb}m${text}\e[0m"
    else
        # Basic ANSI
        local code=$(get_color_code "$color_val")
        if [ -n "$code" ]; then
            echo -ne "\e[${code}m${text}\e[0m"
        else
            echo -ne "$text"
        fi
    fi
}
gradient_command() {
    local start_color="${1#-}"
    local end_color="${2#--}"
    local text="$3"
    local length=${#text}
    if [ $length -le 1 ]; then
        color_command "$start_color" "$text"
        return
    fi
    # Resolve colors to RGB
    local r1=0 g1=0 b1=0
    local r2=0 g2=0 b2=0
    if [[ "$start_color" =~ ^#[0-9a-fA-F]{6}$ ]]; then
        IFS=';' read -r r1 g1 b1 <<< "$(hex_to_rgb "$start_color")"
    else
        case "${start_color,,}" in
            red) r1=255; g1=0; b1=0 ;;
            black) r1=0; g1=0; b1=0 ;;
            *) r1=255; g1=255; b1=255 ;;
        esac
    fi
    if [[ "$end_color" =~ ^#[0-9a-fA-F]{6}$ ]]; then
        IFS=';' read -r r2 g2 b2 <<< "$(hex_to_rgb "$end_color")"
    else
        case "${end_color,,}" in
            red) r2=255; g2=0; b2=0 ;;
            black) r2=0; g2=0; b2=0 ;;
            *) r2=0; g2=0; b2=0 ;;
        esac
    fi
    for ((i=0; i<length; i++)); do
        local char="${text:i:1}"
        # Linear interpolation
        local r=$(( r1 + (r2 - r1) * i / (length - 1) ))
        local g=$(( g1 + (g2 - g1) * i / (length - 1) ))
        local b=$(( b1 + (b2 - b1) * i / (length - 1) ))
        echo -ne "\e[38;2;${r};${g};${b}m${char}"
    done
    echo -ne "\e[0m"
}
detect_command() {
    local color_val="$1"
    if [[ "$color_val" =~ ^#[0-9a-fA-F]{6}$ ]]; then
        local rgb=$(hex_to_rgb "$color_val")
        IFS=';' read -r r g b <<< "$rgb"
        local brightness=$(( (r * 299 + g * 587 + b * 114) / 1000 ))
        local tone="dark"
        if [ "$brightness" -gt 128 ]; then
            tone="light"
        fi
        echo "Detected hex color: $color_val"
        echo "  RGB: $r, $g, $b"
        echo "  Brightness: $brightness/255 ($tone)"
        local nearest_name="unknown"
        local nearest_dist=999999
        local name
        local nr ng nb
        for name in black red green yellow blue magenta cyan white; do
            IFS=';' read -r nr ng nb <<< "$(get_named_rgb "$name")"
            local dist=$(( (r - nr) * (r - nr) + (g - ng) * (g - ng) + (b - nb) * (b - nb) ))
            if [ "$dist" -lt "$nearest_dist" ]; then
                nearest_dist="$dist"
                nearest_name="$name"
            fi
        done
        echo "  Nearest named color: $nearest_name"
        colorsense color "$color_val" "sample"
        echo
    else
        local code=$(get_color_code "$color_val")
        if [ -n "$code" ]; then
            echo "Detected named color: ${color_val,,} (ANSI code $code)"
            local rgb_vals=$(get_named_rgb "${color_val,,}")
            IFS=';' read -r r g b <<< "$rgb_vals"
            echo "  RGB: $r, $g, $b"
            colorsense color "$color_val" "sample"
            echo
        else
            echo "Unknown color: $color_val"
            echo "Supported names: black red green yellow blue magenta cyan white"
            echo "Or use hex format: #RRGGBB"
        fi
    fi
}
get_named_rgb() {
    case "${1,,}" in
        black)   echo "0;0;0" ;;
        red)     echo "255;0;0" ;;
        green)   echo "0;255;0" ;;
        yellow)  echo "255;255;0" ;;
        blue)    echo "0;0;255" ;;
        magenta) echo "255;0;255" ;;
        cyan)    echo "0;255;255" ;;
        white)   echo "255;255;255" ;;
        *)       echo "0;0;0" ;;
    esac
}
ai_command() {
    local prompt="$*"
    if [ -z "$prompt" ]; then
        echo "Usage: colorsense ai <natural language instruction>"
        echo "Examples:"
        echo "  colorsense ai color blue hello"
        echo "  colorsense ai gradient from red to green \"my text\""
        echo "  colorsense ai detect #ff0000"
        echo "  colorsense ai is cat absent from \"the dog sat\""
        return 1
    fi
    local cmd
    cmd=$(node "$(dirname "${BASH_SOURCE[0]}")/ai-sense.mjs" "$prompt" 2>&1)
    if [ $? -ne 0 ]; then
        echo "$cmd"
        return 1
    fi
    eval "$cmd"
}
colorsense() {
    case "$1" in
        color)
            color_command "$2" "$3"
            ;;
        gradient)
            gradient_command "$2" "$3" "$4"
            ;;
        detect)
            detect_command "$2"
            ;;
        ai)
            shift
            ai_command "$@"
            ;;
        *)
            echo "Usage: colorsense color <color> <text> | colorsense gradient <start> <end> <text> | colorsense detect <color> | colorsense ai <prompt>"
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    colorsense "$@"
fi
