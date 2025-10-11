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

# Test 1: Yes/No with default
echo "Test 1: Yes/No confirmation with default Y"
confirm=$(controlled_input "Continue? (Y/n)" -m yesno -d Y)
echo "You selected: $confirm"
echo ""

# Test 2: Text with default value hint
echo "Test 2: Text with default value (shows hint, accepts on Enter)"
username=$(controlled_input "Username" -m text -d "admin" -n 3 -x 20)
echo "You entered: $username"
echo ""

# Test 3: Text with prefilled value
echo "Test 3: Text with prefilled buffer (editable)"
edit_name=$(controlled_input "Edit name:" -m text -p "John Doe" -n 3 -x 50)
echo "You entered: $edit_name"
echo ""

echo "=========================================="
echo "All tests completed!"
echo "=========================================="
