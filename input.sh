#!/bin/bash
# shellcheck shell=bash

# input.sh - Controlled Input Library
# A reusable bash library for controlled user input with validation
#
# Usage:
#   source input.sh
#   result=$(controlled_input "prompt" [OPTIONS])
#
# Options:
#   -m, --mode <type>         Input mode: text|numeric|password|yesno|email|phone|ipv4|ipv6
#   -n, --min <num>           Minimum length
#   -x, --max <num>           Maximum length
#   -d, --default <value>     Default value
#   -e, --error-msg <text>    Custom error message
#   --allow-empty             Allow empty input
#

# ANSI Color Codes
readonly COLOR_RESET='\e[0m'
readonly COLOR_RED='\e[31m'
readonly COLOR_GRAY='\e[90m'

# ANSI Cursor Control
readonly CURSOR_SAVE=$'\e[s'
readonly CURSOR_RESTORE=$'\e[u'
readonly CURSOR_HIDE=$'\e[?25l'
readonly CURSOR_SHOW=$'\e[?25h'
readonly ERASE_LINE=$'\e[2K'
readonly ERASE_TO_END=$'\e[K'

# Control Characters
readonly KEY_ENTER=$'\n'
readonly KEY_BACKSPACE=$'\x7f'
readonly KEY_CTRL_C=$'\x03'
readonly KEY_ESC=$'\e'

# Exit Codes
readonly EXIT_SUCCESS=0
readonly EXIT_INTERRUPTED=1
readonly EXIT_INVALID_PARAMS=2

#
# Main controlled_input function
#
controlled_input() {
    # Default parameters
    local prompt=""
    local mode="text"
    local min_length=0
    local max_length=999
    local default_value=""
    local error_msg=""
    local allow_empty=false

    # Parse arguments
    if [[ $# -eq 0 ]]; then
        echo "Error: Prompt required" >&2
        return "$EXIT_INVALID_PARAMS"
    fi

    prompt="$1"
    shift

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -m|--mode)
                mode="$2"
                shift 2
                ;;
            -n|--min)
                min_length="$2"
                shift 2
                ;;
            -x|--max)
                max_length="$2"
                shift 2
                ;;
            -d|--default)
                default_value="$2"
                shift 2
                ;;
            -e|--error-msg)
                error_msg="$2"
                shift 2
                ;;
            --allow-empty)
                allow_empty=true
                shift
                ;;
            *)
                echo "Error: Unknown option: $1" >&2
                return "$EXIT_INVALID_PARAMS"
                ;;
        esac
    done

    # Validate mode
    case "$mode" in
        text|numeric|password|yesno|email|phone|ipv4|ipv6)
            ;;
        *)
            echo "Error: Invalid mode: $mode" >&2
            return "$EXIT_INVALID_PARAMS"
            ;;
    esac

    # Main input loop with validation
    local result=""
    local retry=true
    local had_error=false

    while $retry; do
        # Save terminal state for each attempt
        local old_stty
        old_stty=$(stty -g 2>/dev/null)

        # Setup terminal for raw input
        stty -echo -icanon min 1 time 0 2>/dev/null

        # Get input
        result=$(_input_loop "$prompt" "$mode" "$min_length" "$max_length" "$default_value" "$allow_empty" "$had_error")
        local input_status=$?

        # Restore terminal immediately after input
        stty "$old_stty" 2>/dev/null

        # Check if user interrupted
        if [[ $input_status -eq $EXIT_INTERRUPTED ]]; then
            return "$EXIT_INTERRUPTED"
        fi

        # Validate input
        local validation_error=""
        validation_error=$(_validate_input "$result" "$mode" "$min_length" "$max_length" "$allow_empty")

        if [[ -z "$validation_error" ]]; then
            # Input is valid - clear error if there was one
            if $had_error; then
                # Error is on current line, just clear it
                printf '%s\r' "$ERASE_LINE" >&2
            fi
            retry=false
        else
            # Show error and retry
            local display_error="${error_msg:-$validation_error}"
            _show_error "$display_error"
            had_error=true
        fi
    done

    # Output result
    echo "$result"
    return "$EXIT_SUCCESS"
}

#
# Internal function: Input loop with cursor control
#
_input_loop() {
    local prompt="$1"
    local mode="$2"
    local min_length="$3"
    local max_length="$4"
    local default_value="$5"
    local allow_empty="$6"
    local had_error="$7"

    local buffer=""
    local cursor_pos=0
    local display_default=""

    # Initialize buffer with default value if provided
    if [[ -n "$default_value" ]]; then
        buffer="$default_value"
        cursor_pos=${#buffer}
        display_default=" ${COLOR_GRAY}[${default_value}]${COLOR_RESET}"
    fi

    # Display prompt
    printf "%s%s " "$prompt" "$display_default" >&2

    # Display initial buffer if any
    if [[ -n "$buffer" ]]; then
        if [[ "$mode" == "password" ]]; then
            printf '%*s' "${#buffer}" '' | tr ' ' '*' >&2
        else
            printf '%s' "$buffer" >&2
        fi
    fi

    # Special handling for yesno mode
    if [[ "$mode" == "yesno" ]]; then
        local result
        result=$(_handle_yesno "$default_value")
        printf "\n" >&2
        echo "$result"
        return "$EXIT_SUCCESS"
    fi

    # Main character input loop
    local char=""

    while true; do
        # Read single character (using -n1 instead of -rsn1 for better compatibility)
        if ! IFS= read -r -n1 char; then
            # EOF or error
            continue
        fi

        # Check for Enter key
        if [[ -z "$char" ]]; then
            # Enter pressed (read returns empty string for newline with -n1)
            printf "\n" >&2
            echo "$buffer"
            return $EXIT_SUCCESS
        fi

        # Check for special characters
        case "$char" in
            $'\x7f'|$'\x08')  # Backspace or DEL
                if [[ $cursor_pos -gt 0 ]]; then
                    # Remove character from buffer
                    buffer="${buffer:0:$((cursor_pos-1))}${buffer:$cursor_pos}"
                    ((cursor_pos--))

                    # Move cursor back, erase character, move cursor back again
                    printf '\b \b' >&2

                    # If there are characters after cursor, redraw them
                    if [[ $cursor_pos -lt ${#buffer} ]]; then
                        local rest="${buffer:$cursor_pos}"
                        if [[ "$mode" == "password" ]]; then
                            printf '%*s' "${#rest}" '' | tr ' ' '*' >&2
                        else
                            printf '%s' "$rest" >&2
                        fi
                        printf ' ' >&2  # Erase the extra character
                        # Move cursor back to correct position
                        printf '\e[%dD' "$((${#rest} + 1))" >&2
                    fi
                fi
                ;;

            $'\x03')  # Ctrl+C
                printf "\n" >&2
                return $EXIT_INTERRUPTED
                ;;

            $'\e')  # Escape sequence
                # Read the rest of the escape sequence
                read -r -n2 -t 0.1 seq
                case "$seq" in
                    '[D')  # Left arrow
                        if [[ $cursor_pos -gt 0 ]]; then
                            ((cursor_pos--))
                            printf '\e[D' >&2
                        fi
                        ;;
                    '[C')  # Right arrow
                        if [[ $cursor_pos -lt ${#buffer} ]]; then
                            ((cursor_pos++))
                            printf '\e[C' >&2
                        fi
                        ;;
                    '[H')  # Home key
                        if [[ $cursor_pos -gt 0 ]]; then
                            printf '\e[%dD' "$cursor_pos" >&2
                            cursor_pos=0
                        fi
                        ;;
                    '[F')  # End key
                        if [[ $cursor_pos -lt ${#buffer} ]]; then
                            local move=$((${#buffer} - cursor_pos))
                            printf '\e[%dC' "$move" >&2
                            cursor_pos=${#buffer}
                        fi
                        ;;
                esac
                ;;

            *)  # Regular character
                # Validate and insert character
                if _is_valid_char "$char" "$mode" && [[ ${#buffer} -lt $max_length ]]; then
                    # Insert character at cursor position
                    local before="${buffer:0:$cursor_pos}"
                    local after="${buffer:$cursor_pos}"
                    buffer="${before}${char}${after}"

                    # Echo the character (or * for password)
                    if [[ "$mode" == "password" ]]; then
                        printf '*' >&2
                    else
                        printf '%s' "$char" >&2
                    fi

                    ((cursor_pos++))

                    # If we inserted in the middle, redraw the rest and reposition
                    if [[ -n "$after" ]]; then
                        if [[ "$mode" == "password" ]]; then
                            printf '%*s' "${#after}" '' | tr ' ' '*' >&2
                        else
                            printf '%s' "$after" >&2
                        fi
                        # Move cursor back to correct position
                        printf '\e[%dD' "${#after}" >&2
                    fi
                fi
                ;;
        esac
    done
}

#
# Internal function: Check if character is valid for mode
#
_is_valid_char() {
    local char="$1"
    local mode="$2"

    case "$mode" in
        text)
            [[ "$char" =~ ^[[:print:]]$ ]]  # Allow all printable characters
            ;;
        numeric)
            [[ "$char" =~ ^[0-9]$ ]]
            ;;
        password)
            [[ "$char" =~ ^[[:graph:]]$ ]]  # Allow all visible characters
            ;;
        email)
            [[ "$char" =~ ^[a-zA-Z0-9+.@_-]$ ]]
            ;;
        phone)
            [[ "$char" =~ ^[0-9-]$ ]]
            ;;
        ipv4)
            [[ "$char" =~ ^[0-9.]$ ]]
            ;;
        ipv6)
            [[ "$char" =~ ^[0-9a-fA-F:]$ ]]
            ;;
        *)
            return 1
            ;;
    esac
}

#
# Internal function: Handle yes/no input
#
_handle_yesno() {
    local default_value="$1"
    local char=""

    while true; do
        if ! IFS= read -r -n1 char; then
            continue
        fi

        # Check for Ctrl+C
        if [[ "$char" == $'\x03' ]]; then
            return $EXIT_INTERRUPTED
        fi
        # Check for Enter with default
        if [[ -z "$char" ]] && [[ -n "$default_value" ]]; then
            local default_upper
            default_upper=$(echo "$default_value" | tr '[:lower:]' '[:upper:]')
            printf "%s" "$default_upper" >&2
            echo "$default_upper"
            return "$EXIT_SUCCESS"
        fi

        # Convert to uppercase
        char=$(echo "$char" | tr '[:lower:]' '[:upper:]')

        if [[ "$char" == "Y" ]]; then
            printf "Y" >&2
            echo "Y"
            return $EXIT_SUCCESS
        elif [[ "$char" == "N" ]]; then
            printf "N" >&2
            echo "N"
            return $EXIT_SUCCESS
        fi
    done
}

#
# Internal function: Validate input
#
_validate_input() {
    local input="$1"
    local mode="$2"
    local min_length="$3"
    local max_length="$4"
    local allow_empty="$5"

    # Check empty input
    if [[ -z "$input" ]]; then
        if ! $allow_empty; then
            echo "Input cannot be empty"
            return
        else
            return
        fi
    fi

    # Check length
    if [[ ${#input} -lt $min_length ]]; then
        echo "Input must be at least $min_length characters"
        return
    fi

    if [[ ${#input} -gt $max_length ]]; then
        echo "Input must be at most $max_length characters"
        return
    fi

    # Mode-specific validation
    case "$mode" in
        email)
            if ! [[ "$input" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
                echo "Invalid email format"
                return
            fi
            ;;
        phone)
            # Remove any existing dashes
            local digits="${input//-/}"
            if ! [[ "$digits" =~ ^[0-9]{10}$ ]]; then
                echo "Phone must be 10 digits"
                return
            fi
            ;;
        ipv4)
            if ! _validate_ipv4 "$input"; then
                echo "Invalid IPv4 address"
                return
            fi
            ;;
        ipv6)
            if ! _validate_ipv6 "$input"; then
                echo "Invalid IPv6 address"
                return
            fi
            ;;
        numeric)
            if ! [[ "$input" =~ ^[0-9]+$ ]]; then
                echo "Input must be numeric"
                return
            fi
            ;;
    esac
}

#
# Internal function: Validate IPv4 address
#
_validate_ipv4() {
    local ip="$1"

    if ! [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        return 1
    fi

    IFS='.' read -ra octets <<< "$ip"

    if [[ ${#octets[@]} -ne 4 ]]; then
        return 1
    fi

    for octet in "${octets[@]}"; do
        if [[ $octet -lt 0 ]] || [[ $octet -gt 255 ]]; then
            return 1
        fi
    done

    return 0
}

#
# Internal function: Validate IPv6 address
#
_validate_ipv6() {
    local ip="$1"

    # Basic IPv6 validation (simplified)
    if ! [[ "$ip" =~ ^[0-9a-fA-F:]+$ ]]; then
        return 1
    fi

    # Check for valid structure
    if [[ "$ip" =~ :::+ ]]; then
        return 1
    fi

    # Count colons
    local colon_count
    colon_count=$(echo "$ip" | tr -cd ':' | wc -c)

    if [[ $colon_count -lt 2 ]] || [[ $colon_count -gt 7 ]]; then
        return 1
    fi

    return 0
}

#
# Internal function: Show error message
#
_show_error() {
    local error_msg="$1"

    # Print error in red on current line
    printf "%b%s%b\n" "$COLOR_RED" "$error_msg" "$COLOR_RESET" >&2

    # Brief pause to let user see error
    sleep 0.5

    # Move cursor up 2 lines (error + blank line from enter)
    printf '\e[2A' >&2

    # Erase current line
    printf '%s\r' "$ERASE_LINE" >&2
}

# Export function for use in other scripts
export -f controlled_input