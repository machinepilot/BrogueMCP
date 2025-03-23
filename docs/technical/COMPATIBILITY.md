# BrogueMCP Compatibility Layer

This document provides detailed technical information about the BrogueMCP compatibility layer, which ensures the codebase works across different versions of Brogue.

## Table of Contents

- [Overview](#overview)
- [Components](#components)
- [Testing Instructions](#testing-instructions)
- [Implementation Details](#implementation-details)
- [Troubleshooting](#troubleshooting)
- [Verification Procedure](#verification-procedure)
- [Windows Testing](#windows-testing)
- [Release Strategy](#release-strategy)

## Overview

The BrogueMCP compatibility layer addresses API differences between Brogue versions, ensuring that the MCP code can integrate with multiple Brogue variants. This layer:

- Auto-detects Brogue version when possible
- Provides macros and functions to handle API differences
- Defines fallback constants and functions
- Abstracts away structural differences

## Components

### 1. Compatibility Header (`mcp_compat.h`)

The core of the compatibility layer:
- Provides macros and functions to handle API differences
- Auto-detects Brogue version when possible
- Defines fallback constants and functions
- Includes adaptation strategies for different code structures

### 2. Event Hooks (`event_hooks.c`)

The event hook implementation:
- Uses compatibility macros instead of direct field access
- Handles API differences in function signatures
- Properly processes different structure layouts
- Maintains consistent behavior across versions

### 3. Standalone Test (`test_api_compat_standalone.c`)

A self-contained test to verify compatibility:
- Doesn't require Brogue headers
- Verifies compatibility macros work correctly
- Can be compiled for both legacy and current APIs

## Testing Instructions

### Prerequisites

You need to have MSYS2 with MinGW64 installed as described in [BUILDING.md](../../BUILDING.md).

### Option 1: Test Using MSYS2 MinGW64 Shell

1. **Open the MSYS2 MinGW64 shell** (not the regular MSYS2 shell)

2. **Navigate to your BrogueMCP directory**:
   ```bash
   cd /c/working_directory/brogue-project/BrogueMCP
   ```

3. **Apply the compatibility patches**:
   ```bash
   ./apply_compatibility.sh
   ```

4. **Run the standalone test**:
   ```bash
   cd test
   ./build_standalone.sh
   ```

5. **Build the full project with minimal configuration**:
   ```bash
   cd ..
   make clean
   make GRAPHICS=NO TERMINAL=YES bin/brogue.exe
   ```

### Option 2: Apply Patches Manually

If you're having trouble with the scripts:

1. **Copy** `patches/mcp_compat.h` to `src/mcp/mcp_compat.h`

2. **Copy** `patches/event_hooks.c` to `src/mcp/event_hooks.c`

3. **Open MSYS2 MinGW64** and navigate to the BrogueMCP directory

4. **Build the project**:
   ```bash
   make clean
   make GRAPHICS=NO TERMINAL=YES bin/brogue.exe
   ```

## Implementation Details

### Version Detection

The compatibility layer uses a multi-staged detection approach:

```c
// Version detection in mcp_compat.h
#if defined(BROGUE_VERSION)
    // Use the explicitly defined version
#elif defined(BROGUE_MAJOR) && defined(BROGUE_MINOR)
    // Derive from major/minor versions
    #define BROGUE_VERSION ((BROGUE_MAJOR * 100) + BROGUE_MINOR)
#elif defined(BROGUE_1_7_4)
    #define BROGUE_VERSION 174
#else
    // Default to latest version
    #define BROGUE_VERSION 175
#endif
```

### Structure Access Macros

Abstracts away differences in structure layouts:

```c
// Example of structure field access abstraction
#if BROGUE_VERSION <= 174
    #define GET_MONSTER_NAME(monst) ((monst)->info.monsterName)
    #define SET_MONSTER_NAME(monst, name) ((monst)->info.monsterName = (name))
#else
    #define GET_MONSTER_NAME(monst) ((monst)->name)
    #define SET_MONSTER_NAME(monst, name) ((monst)->name = (name))
#endif
```

### Function Signature Adaptation

Handles changes in function parameters:

```c
// Example of function signature adaptation
#if BROGUE_VERSION <= 174
static void dm_monster_defeated(creature *monst, bool isRare) {
    // Implementation for 1.7.4
}
#else
static void dm_monster_defeated(char *monsterName, bool isRare) {
    // Implementation for 1.7.5+
}
#endif
```

## Troubleshooting

### Missing PlatformDefines.h Error

This happens when trying to build the test using the original Brogue headers.

**Solution**: Use the standalone test instead, which doesn't require Brogue headers.

### Missing GCC/Tools

If you get "command not found" errors:

**Solution**:
- Make sure you're using the MSYS2 MinGW64 shell, not regular PowerShell
- Verify MSYS2 installation with: `pacman -Ss gcc`
- If needed, install the compiler: `pacman -S mingw-w64-x86_64-gcc`

### Build Errors

If you encounter build errors:

**Solution**:
1. Check console output for specific errors
2. Look for missing headers or undefined symbols
3. Verify that all compatibility macros are properly defined
4. Try building with `-DBROGUE_1_7_4` or `-DUSE_CURRENT_API` to force a specific mode

## Verification Procedure

To verify successful implementation:

1. **Test Building**:
   - Try building with both Brogue 1.7.4 and 1.7.5 mode
   - Check for any compiler warnings or errors

2. **Test Functionality**:
   - Run the game to test gameplay
   - Verify event generation (monster encounters, item discovery)
   - Check JSON data structure

3. **Test Integration**:
   - Verify MCP client connects to the DM server
   - Confirm events are properly transmitted
   - Check narrative display

## Windows Testing

When testing on Windows using PowerShell, use the included helper script:

```powershell
# Set up environment
.\mingw64-env.ps1

# Build and test compatibility
cd test
.\test-compatibility.ps1
```

This script:
1. Sets up the MinGW64 environment variables
2. Builds the standalone tests
3. Runs verification for both API versions

## Release Strategy

After successful testing:

1. **Create Branch**: For the compatibility changes
2. **Document Changes**: Update README.md with compatibility information
3. **Release Patch**: Create a patch that can be applied to the main codebase
4. **Version Tagging**: Tag the release with supported Brogue versions 