# BrogueMCP Compatibility Layer Testing Instructions

This document provides detailed instructions for testing and implementing the BrogueMCP compatibility fixes.

## Project Components

1. **Compatibility Layer** (`mcp_compat.h`)
   - Provides macros and functions to handle API differences
   - Auto-detects Brogue version when possible
   - Defines fallback constants and functions

2. **Fixed Event Hooks** (`event_hooks.c`)
   - Uses compatibility macros instead of direct field access
   - Handles API differences in function signatures
   - Properly processes different structure layouts

3. **Standalone Test** (`test_api_compat_standalone.c`)
   - Self-contained test that doesn't require Brogue headers
   - Verifies compatibility macros work correctly
   - Can be compiled for both legacy and current APIs

## Testing in Windows PowerShell

### Prerequisites
You need to have MSYS2 with MinGW64 installed as described in BUILD.md.

### Option 1: Test Using MSYS2 MinGW64 Shell

1. Open the MSYS2 MinGW64 shell (not the regular MSYS2 shell)
2. Navigate to your BrogueMCP directory:
   ```bash
   cd /c/working_directory/brogue-project/BrogueMCP
   ```
3. Apply the compatibility patches:
   ```bash
   ./apply_compatibility.sh
   ```
4. Run the standalone test:
   ```bash
   cd test
   ./build_standalone.sh
   ```
5. Build the full project with minimal configuration:
   ```bash
   cd ..
   make clean
   make GRAPHICS=NO TERMINAL=YES bin/brogue.exe
   ```

### Option 2: Apply Patches Manually

If you're having trouble with the scripts:

1. Copy `patches/mcp_compat.h` to `src/mcp/mcp_compat.h`
2. Copy `patches/event_hooks.c` to `src/mcp/event_hooks.c`
3. Open MSYS2 MinGW64 and navigate to the BrogueMCP directory
4. Build the project:
   ```bash
   make clean
   make GRAPHICS=NO TERMINAL=YES bin/brogue.exe
   ```

## Troubleshooting

### Missing PlatformDefines.h Error
This happens when trying to build the test using the original Brogue headers.
- Solution: Use the standalone test instead, which doesn't require Brogue headers

### Missing GCC/Tools
If you get "command not found" errors:
- Make sure you're using the MSYS2 MinGW64 shell, not regular PowerShell
- Verify MSYS2 installation with: `pacman -Ss gcc`
- If needed, install the compiler: `pacman -S mingw-w64-x86_64-gcc`

### Build Errors
If you encounter build errors:
1. Check console output for specific errors
2. Look for missing headers or undefined symbols
3. Verify that all compatibility macros are properly defined
4. Try building with `-DBROGUE_1_7_4` or `-DUSE_CURRENT_API` to force a specific mode

## Verifying Success

Your implementation is successful when:

1. The code compiles without errors
2. The game runs without crashing
3. Monster encounters, item discoveries, and other events generate proper JSON data
4. Messages display correctly

## Release Strategy

After successful testing:

1. Create a dedicated branch for these compatibility changes
2. Document the changes thoroughly in README.md
3. Consider releasing as a patch that can be applied to the main codebase 