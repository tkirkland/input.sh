#!/bin/bash
#
# test_input.sh - Test script for controlled_input library
#

# Source the library
source ./input.sh

echo "=========================================="
echo "Controlled Input Library - Test Suite"
echo "=========================================="
echo ""

# Test 1: Basic text input
echo "Test 1: Basic text input (min 3, max 20)"
name=$(controlled_input "Enter your name:" -m text -n 3 -x 20)
echo "You entered: $name"
echo ""

# Test 2: Numeric input
echo "Test 2: Numeric input (1-100)"
age=$(controlled_input "Enter your age:" -m numeric -n 1 -x 3)
echo "You entered: $age"
echo ""

# Test 3: Password input
echo "Test 3: Password input (masked, min 8 chars)"
password=$(controlled_input "Enter password:" -m password -n 8 -x 20)
echo "Password length: ${#password}"
echo ""

# Test 4: Yes/No with default
echo "Test 4: Yes/No confirmation with default Y"
confirm=$(controlled_input "Continue? (Y/n)" -m yesno -d Y)
echo "You selected: $confirm"
echo ""

# Test 5: Email validation
echo "Test 5: Email validation"
email=$(controlled_input "Enter email:" -m email)
echo "You entered: $email"
echo ""

# Test 6: Phone number
echo "Test 6: Phone number (xxx-xxx-xxxx)"
phone=$(controlled_input "Enter phone:" -m phone)
echo "You entered: $phone"
echo ""

# Test 7: IPv4 address
echo "Test 7: IPv4 address"
ipv4=$(controlled_input "Enter IPv4 address:" -m ipv4)
echo "You entered: $ipv4"
echo ""

# Test 8: Default value
echo "Test 8: Text with default value (editable)"
username=$(controlled_input "Username:" -m text -d "admin" -n 3 -x 20)
echo "You entered: $username"
echo ""

# Test 9: Allow empty
echo "Test 9: Optional input (allow empty)"
optional=$(controlled_input "Optional field:" -m text --allow-empty)
if [[ -z "$optional" ]]; then
    echo "You left it empty"
else
    echo "You entered: $optional"
fi
echo ""

# Test 10: Custom error message
echo "Test 10: Numeric with custom error (must be 20-80)"
value=$(controlled_input "Enter value (20-80):" -m numeric -n 2 -x 2 -e "Invalid value! Must be between 20-80. Re-enter.")
echo "You entered: $value"
echo ""

echo "=========================================="
echo "All tests completed!"
echo "=========================================="
