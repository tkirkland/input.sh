# Controlled Input Library

A robust bash library for controlled user input with validation, cursor control, and multiple input modes.

## Features

- **Multiple input modes**: text, numeric, password, yesno, email, phone, IPv4, IPv6
- **Cursor control**: Left/Right arrows, Home/End keys for non-destructive editing
- **Validation**: Min/max length, format validation, numeric range validation, custom error messages
- **Default values**: Gray hint display with Enter to accept
- **Prefill mode**: Pre-populated editable buffers for modifying existing data
- **Error handling**: Same-line error redisplay, no screen scrolling on retry
- **SIGINT preservation**: Saves and restores parent script's Ctrl+C handler
- **Clean interface**: Returns via stdout, status via exit code

## Installation

```bash
# Source the library in your script
source /path/to/input.sh
```

## Usage

```bash
result=$(controlled_input "prompt" [OPTIONS])
```

### Options

| Short | Long | Description |
|-------|------|-------------|
| `-m` | `--mode` | Input mode: `text`, `numeric`, `password`, `yesno`, `email`, `phone`, `ipv4`, `ipv6` |
| `-n` | `--min` | Minimum character length (all modes except yesno) |
| `-x` | `--max` | Maximum character length (all modes except yesno) |
|      | `--min-value` | Minimum numeric value (numeric mode only, validates actual value) |
|      | `--max-value` | Maximum numeric value (numeric mode only, validates actual value) |
| `-d` | `--default` | Default value shown as gray hint `[value]:` - press Enter on empty input to accept |
| `-p` | `--prefill` | Pre-populate input buffer with editable value (cursor at end) |
| `-e` | `--error-msg` | Custom error message to display on validation failure |
|      | `--allow-empty` | Allow empty input (default: false, not applicable with `-d` or `-p`) |

## Input Modes

### Text Mode
- **Allowed characters**: Alphanumeric, spaces, and `.,_-`
- **Example**: Names, general text input

```bash
name=$(controlled_input "Enter your name:" -m text -n 3 -x 50)
```

### Numeric Mode
- **Allowed characters**: Digits 0-9 only
- **Validation**: Integer values only (no floats)
- **Range validation**: Use `--min-value` and `--max-value` for numeric range constraints
- **Example**: Ages, quantities, IDs

```bash
# Character length constraint
age=$(controlled_input "Enter your age:" -m numeric -n 1 -x 3)

# Numeric range constraint
age=$(controlled_input "Enter your age:" -m numeric --min-value 1 --max-value 120)
```

### Password Mode
- **Allowed characters**: Alphanumeric only
- **Display**: Masked with `*` characters
- **Example**: Password entry

```bash
password=$(controlled_input "Enter password:" -m password -n 8 -x 20)
```

### Yes/No Mode
- **Input**: Single character (Y/y/N/n)
- **Display**: Shows "Yes" or "No" for better readability
- **Default**: Specified via capital letter in prompt
  - `(Y/n)` - default is Y, press Enter to accept
  - `(y/N)` - default is N, press Enter to accept
- **Return**: Uppercase Y or N

```bash
confirm=$(controlled_input "Continue? (Y/n)" -m yesno -d Y)
# Displays "Yes" when accepted, returns "Y"
```

### Email Mode
- **Allowed characters**: Alphanumeric plus `+.-_@`
- **Validation**: Basic email format (user@domain.tld)
- **Example**: Email addresses

```bash
email=$(controlled_input "Enter email:" -m email)
```

### Phone Mode
- **Input**: Digits only (0-9)
- **Validation**: Must be 10 digits
- **Format**: xxx-xxx-xxxx
- **Example**: US phone numbers

```bash
phone=$(controlled_input "Enter phone:" -m phone)
```

### IPv4 Mode
- **Allowed characters**: Digits and dots (0-9.)
- **Validation**: Valid IPv4 format with octets 0-255
- **Example**: 192.168.1.1

```bash
ipv4=$(controlled_input "Enter IPv4 address:" -m ipv4)
```

### IPv6 Mode
- **Allowed characters**: Hex digits and colons (0-9a-fA-F:)
- **Validation**: Valid IPv6 structure
- **Example**: 2001:0db8::1

```bash
ipv6=$(controlled_input "Enter IPv6 address:" -m ipv6)
```

## Examples

### Basic text input with length constraints
```bash
username=$(controlled_input "Username:" -m text -n 3 -x 20)
```

### Numeric input with range validation
```bash
port=$(controlled_input "Port:" \
    -m numeric --min-value 1024 --max-value 65535 \
    -e "Invalid port! Must be between 1024-65535.")
```

### Password with minimum length
```bash
password=$(controlled_input "Create password:" -m password -n 8)
```

### Optional field (allow empty)
```bash
middle_name=$(controlled_input "Middle name (optional):" \
    -m text --allow-empty)
```

### Default value (shown as hint)
```bash
hostname=$(controlled_input "Hostname:" \
    -m text -d "localhost" -n 3 -x 50)
# Displays: Hostname [localhost]: _
# Press Enter on empty input to accept "localhost"
```

### Prefill mode (editable buffer)
```bash
config=$(controlled_input "Edit config:" \
    -m text -p "/etc/myapp/config.conf" -n 3 -x 100)
# Buffer pre-populated with "/etc/myapp/config.conf"
# User can edit, cursor at end
```

### Yes/No confirmation with default
```bash
if [[ $(controlled_input "Install updates? (Y/n)" -m yesno -d Y) == "Y" ]]; then
    echo "Installing updates..."
fi
```

## Keyboard Controls

- **Left/Right arrows**: Move cursor within input buffer (non-destructive)
- **Home**: Jump to start of input
- **End**: Jump to end of input
- **Backspace**: Delete character before cursor
- **Enter**: Submit input
- **Ctrl+C**: Cancel input (returns empty string with exit code 1)

## Error Handling

### Exit Codes
- `0` - Valid input returned
- `1` - User interrupted (Ctrl+C)
- `2` - Invalid parameters

### Validation Errors
When validation fails:
1. Error message displayed in red on new line
2. Previous input erased
3. Prompt redisplayed on same line
4. User can re-enter without screen scrolling
5. Error cleared when typing begins

## Display Features

### Colors
- **Prompt**: Default terminal color
- **Error**: Red text
- **Default value**: Gray text in brackets with colon `[default]:`
- **Prefill buffer**: Normal terminal color (editable text)

### Error Display Example
```
Enter value (20-80): 85
Invalid value! Must be between 20-80. Re-enter.
Enter value (20-80): _
```
(Screen doesn't scroll, prompt stays on same line)

## Advanced Usage

### SIGINT Handling
The library preserves your parent script's SIGINT (Ctrl+C) handler:

```bash
# Your script's trap
trap 'cleanup_function' SIGINT

# Use controlled_input - it will preserve your trap
name=$(controlled_input "Enter name:" -m text)

# Your trap is restored after input completes
```

### Combining with loops
```bash
while true; do
    value=$(controlled_input "Enter value (1-100):" -m numeric -n 1 -x 3)
    [[ $? -eq 0 ]] && break
    echo "Input cancelled, exiting..."
    exit 1
done
```

### Multiple inputs in sequence
```bash
#!/bin/bash
source input.sh

echo "User Registration"
echo "=================="

name=$(controlled_input "Full name:" -m text -n 3 -x 50)
email=$(controlled_input "Email:" -m email)
age=$(controlled_input "Age:" -m numeric -n 1 -x 3)
password=$(controlled_input "Password:" -m password -n 8)

confirm=$(controlled_input "Create account? (Y/n)" -m yesno -d Y)

if [[ "$confirm" == "Y" ]]; then
    echo "Account created for $name"
fi
```

## Testing

Run the included test script to see all features in action:

```bash
./test_input.sh
```

This will walk through examples of all input modes with various configurations.

## Requirements

- Bash 4.0+
- Terminal with ANSI escape code support
- `stty` command available

## Limitations

- Single-line input only (no multi-line text)
- No tab completion
- No input history/recall
- Phone validation for US format only (xxx-xxx-xxxx)
- IPv6 validation is simplified (basic structure check)

## License

MIT License - Free to use and modify
