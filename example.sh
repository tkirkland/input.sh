#!/bin/bash
#
# example.sh - Comprehensive demonstration of controlled_input library features
#

# Source the library
source ./input.sh

echo "=============================================="
echo "Controlled Input Library - Feature Examples"
echo "=============================================="
echo ""
echo "This script demonstrates all input modes and features."
echo "Press Ctrl+C at any prompt to skip to next example."
echo ""

# Test 1: Text mode with length constraints
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Example 1: Text Mode - Basic Input"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Min 3, max 20 characters"
username=$(controlled_input "Username:" -m text -n 3 -x 20)
if [[ $? -eq 0 ]]; then
    echo "✓ You entered: $username"
fi
echo ""

# Test 2: Numeric mode with character length
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Example 2: Numeric Mode - Character Length"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1-3 digits only"
age=$(controlled_input "Age:" -m numeric -n 1 -x 3)
if [[ $? -eq 0 ]]; then
    echo "✓ You entered: $age"
fi
echo ""

# Test 3: Numeric mode with value range
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Example 3: Numeric Mode - Value Range"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Value must be between 1024-65535"
port=$(controlled_input "Port:" -m numeric --min-value 1024 --max-value 65535)
if [[ $? -eq 0 ]]; then
    echo "✓ You entered: $port"
fi
echo ""

# Test 4: Password mode
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Example 4: Password Mode - Masked Input"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Min 8 characters, displayed as asterisks"
password=$(controlled_input "Create password:" -m password -n 8 -x 20)
if [[ $? -eq 0 ]]; then
    echo "✓ Password created (length: ${#password})"
fi
echo ""

# Test 5: Yes/No with default Y
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Example 5: Yes/No Mode - Default Yes"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Press Enter to accept default [Y]"
confirm_y=$(controlled_input "Continue?" -m yesno -d Y)
if [[ $? -eq 0 ]]; then
    echo "✓ You selected: $confirm_y"
fi
echo ""

# Test 6: Yes/No with default N
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Example 6: Yes/No Mode - Default No"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Press Enter to accept default [N]"
confirm_n=$(controlled_input "Delete files?" -m yesno -d N)
if [[ $? -eq 0 ]]; then
    echo "✓ You selected: $confirm_n"
fi
echo ""

# Test 7: Email validation
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Example 7: Email Mode - Format Validation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Must match email format (user@domain.tld)"
email=$(controlled_input "Email address:" -m email)
if [[ $? -eq 0 ]]; then
    echo "✓ You entered: $email"
fi
echo ""

# Test 8: Phone validation
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Example 8: Phone Mode - US Format"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Must be 10 digits (formatted as xxx-xxx-xxxx)"
phone=$(controlled_input "Phone number:" -m phone)
if [[ $? -eq 0 ]]; then
    echo "✓ You entered: $phone"
fi
echo ""

# Test 9: IPv4 validation
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Example 9: IPv4 Mode - Address Validation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Valid IPv4 address (octets 0-255)"
ipv4=$(controlled_input "IPv4 address:" -m ipv4)
if [[ $? -eq 0 ]]; then
    echo "✓ You entered: $ipv4"
fi
echo ""

# Test 10: IPv6 validation
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Example 10: IPv6 Mode - Address Validation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Valid IPv6 address structure"
ipv6=$(controlled_input "IPv6 address:" -m ipv6)
if [[ $? -eq 0 ]]; then
    echo "✓ You entered: $ipv6"
fi
echo ""

# Test 11: Default value hint
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Example 11: Default Value - Hint Mode"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Shows [localhost]: hint, press Enter to accept"
hostname=$(controlled_input "Hostname" -m text -d "localhost" -n 3 -x 50)
if [[ $? -eq 0 ]]; then
    echo "✓ You entered: $hostname"
fi
echo ""

# Test 12: Prefill mode
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Example 12: Prefill Mode - Editable Buffer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Buffer pre-populated, use arrows to edit"
config_path=$(controlled_input "Config path:" -m text -p "/etc/myapp/config.conf" -n 3 -x 100)
if [[ $? -eq 0 ]]; then
    echo "✓ You entered: $config_path"
fi
echo ""

# Test 13: Allow empty input
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Example 13: Optional Input - Allow Empty"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Press Enter without input to skip"
middle_name=$(controlled_input "Middle name (optional):" -m text --allow-empty)
if [[ $? -eq 0 ]]; then
    if [[ -z $middle_name ]]; then
        echo "✓ Skipped (empty)"
    else
        echo "✓ You entered: $middle_name"
    fi
fi
echo ""

# Test 14: Custom error message
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Example 14: Custom Error Message"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Try entering a value outside range to see custom error"
score=$(controlled_input "Score (0-100):" -m numeric --min-value 0 --max-value 100 -e "Invalid score! Must be 0-100.")
if [[ $? -eq 0 ]]; then
    echo "✓ You entered: $score"
fi
echo ""

# Test 15: Cursor control demonstration
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Example 15: Cursor Control - Editing"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Use Left/Right arrows, Home/End keys"
echo "Backspace works anywhere in the buffer"
edit_text=$(controlled_input "Edit this text:" -m text -p "The quick brown fox" -n 3 -x 100)
if [[ $? -eq 0 ]]; then
    echo "✓ You entered: $edit_text"
fi
echo ""

echo "=============================================="
echo "✓ All examples completed!"
echo "=============================================="
echo ""
echo "Key Features Demonstrated:"
echo "  • Multiple input modes (text, numeric, password, yesno, email, phone, IPv4, IPv6)"
echo "  • Character length validation (-n/-x)"
echo "  • Numeric range validation (--min-value/--max-value)"
echo "  • Default values with hint display (-d)"
echo "  • Prefill mode with editable buffer (-p)"
echo "  • Optional empty input (--allow-empty)"
echo "  • Custom error messages (-e)"
echo "  • Cursor control (arrows, Home/End, Backspace)"
echo "  • Visual feedback (colors, masked passwords, Yes/No display)"
echo ""
