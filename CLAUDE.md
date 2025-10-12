# input.sh - Claude Code Context

## Project Overview
A robust bash library for controlled user input with validation, cursor control, and multiple input modes. Provides a consistent, user-friendly interface for interactive shell scripts.

## Architecture

### Core Components
- **Main Function**: `controlled_input()` - Public API for input collection
- **Input Loop**: `_input_loop()` - Character-by-character input handling with cursor control
- **Validation**: `_validate_input()` - Mode-specific validation logic
- **Error Display**: `_show_error()` - Animated error messaging with ANSI effects
- **Character Validation**: `_is_valid_char()` - Per-mode character filtering
- **Yes/No Handler**: `_handle_yesno()` - Special handling for confirmation prompts
- **IPv4/IPv6 Validators**: `_validate_ipv4()`, `_validate_ipv6()` - Network address validation

### Input Modes
1. **text** - General text with printable characters
2. **numeric** - Digits only with optional range validation
3. **password** - Masked input with visible characters
4. **yesno** - Single character Y/N confirmation
5. **email** - Email format validation
6. **phone** - US phone number (10 digits)
7. **ipv4** - IPv4 address validation (0-255 per octet)
8. **ipv6** - IPv6 address validation with :: expansion support

### ANSI Features
- **Color Codes**: Red errors, gray hints, default reset
- **Text Effects**: Blinking errors (terminal-dependent)
- **Cursor Control**: Line erasure, cursor positioning

## Code Style

### Formatting Standards (EditorConfig)
- **Indentation**: 2 spaces (no tabs)
- **Line Length**: 84 characters max
- **Line Endings**: LF (Unix-style)
- **Final Newline**: Required
- **Trailing Whitespace**: Trimmed

### Bash Conventions
- **Function Naming**:
  - Public: `controlled_input`
  - Private: `_function_name` (leading underscore)
- **Variable Scope**: Always use `local` for function variables
- **Quoting**: Double quotes for variables, single quotes for literals
- **Return Values**: `echo` for output, `return` for exit codes

### Exit Codes
- `0` - Success (EXIT_SUCCESS)
- `1` - User interrupted with Ctrl+C (EXIT_INTERRUPTED)
- `2` - Invalid parameters (EXIT_INVALID_PARAMS)

## Key Design Patterns

### Terminal State Management
- Save terminal state before raw input mode: `stty -g`
- Restore immediately after: `stty "$old_stty"`
- Ensures clean restoration even on errors

### Error Display Pattern
1. Print error in red with blink effect
2. Move cursor up 2 lines
3. Erase current line
4. Redisplay prompt on same line (no scrolling)

### Cursor Control Pattern
- **Left/Right arrows**: Non-destructive navigation
- **Home/End**: Jump to boundaries
- **Backspace**: Delete with buffer reconstruction
- **Insert**: Character insertion at cursor position with redraw

### Default vs Prefill
- **Default** (`-d`): Shown as gray hint `[value]:`, buffer empty until Enter
- **Prefill** (`-p`): Pre-populated buffer, fully editable from start

## Common Operations

### Adding New Input Mode
1. Add mode to validation in `controlled_input()`
2. Implement character validation in `_is_valid_char()`
3. Add format validation in `_validate_input()`
4. Update documentation in header comments and README.md

### Modifying Error Display
- Edit `_show_error()` function
- Uses `COLOR_RED`, `BLINK`, `COLOR_RESET` constants
- ANSI escape sequences for cursor control

### Changing Validation Logic
- Character-level: `_is_valid_char()`
- Format-level: `_validate_input()`
- Custom errors: Pass via `-e` flag

## Testing Approach

### Manual Testing
- Use `example.sh` for comprehensive feature testing
- Test all 8 input modes
- Verify cursor controls (arrows, Home, End)
- Test validation edge cases
- Verify error display and retry behavior

### Edge Cases to Consider
- Empty input with/without defaults
- Maximum length boundaries
- Numeric range boundaries (min/max values)
- Invalid format patterns
- Cursor movement at boundaries
- Backspace at start/end of buffer
- Insert in middle of buffer

## Development Notes

### Terminal Compatibility
- **ANSI Support Required**: Error colors, cursor control
- **Blink Effect**: Not supported in all terminals (degraded gracefully)
- **stty Required**: For raw input mode
- **Bash 4.0+**: Uses modern bash features

### Performance Considerations
- Character-by-character processing (no buffering)
- Immediate terminal state restoration
- Minimal regex usage in tight loops

### Known Limitations
- Single-line input only
- No tab completion
- No input history
- Phone validation US-format only
- IPv6 validation simplified (basic structure)

## File Structure
```
input.sh/
├── .editorconfig          # Code formatting rules
├── .claude/               # Claude Code settings
├── input.sh               # Main library (exported function)
├── example.sh             # Comprehensive demonstration
├── README.md              # User documentation
├── CLAUDE.md              # This file - development context
└── LICENSE                # MIT License
```

## Recent Changes

### 2025-10-11: UI Enhancements
- Added `.editorconfig` for consistent formatting
- Reformatted entire codebase to 2-space indent, 84 char max
- Added blinking effect to error messages (`BLINK` ANSI constant)
- Updated `_show_error()` to apply red + blink effects
- Updated README.md to document blinking errors with terminal compatibility notes

## Future Considerations
- Multi-line input support
- Tab completion integration
- Input history/recall
- International phone formats
- Float/decimal numeric mode
- Custom validation callbacks
- Color theme customization
