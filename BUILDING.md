# Building BrogueMCP from Source

This guide provides detailed instructions for compiling BrogueMCP from source code. This is recommended for developers who want to contribute to the project or make custom modifications.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Build Options](#build-options)
- [Windows Build Instructions](#windows-build-instructions)
- [macOS Build Instructions](#macos-build-instructions)
- [Linux Build Instructions](#linux-build-instructions)
- [Building the DM Agent](#building-the-dm-agent)
- [IDE Configuration](#ide-configuration)
- [Common Build Issues](#common-build-issues)

## Prerequisites

At minimum, you'll need:

- A C compiler (Clang or GCC)
- Make
- diffutils (cmp)

Additional dependencies vary by platform and build options.

## Build Options

BrogueMCP supports several build options that can be configured in `config.mk` or passed as command-line arguments to make:

| Option | Description | Default |
|--------|-------------|---------|
| `GRAPHICS` | Build with graphical tiles support | `YES` |
| `TERMINAL` | Build with terminal mode support | `NO` |
| `SDL` | Use SDL2 for rendering | `YES` |
| `DEBUG` | Build with debugging symbols | `NO` |
| `MAC_APP` | Build as a macOS app bundle | `NO` |

Example:
```
make GRAPHICS=YES TERMINAL=YES bin/brogue
```

## Windows Build Instructions

### Setting up the Environment

1. **Install MSYS2**: 
   - Download and install from [msys2.org](https://www.msys2.org/)
   - Follow the installation instructions on the MSYS2 website

2. **Install Dependencies**:
   - Open the MSYS2 shell and run:
   ```
   pacman -S make diffutils mingw-w64-x86_64-{gcc,SDL2,SDL2_image}
   ```

3. **Update PATH (Optional)**:
   - To run the compiled game outside of MSYS2, add `C:\msys2\mingw64\bin` to your system PATH
   - See [How to set or change the PATH system variable](https://www.java.com/en/download/help/path.xml)

### Compiling

1. **Get the Source Code**:
   ```
   git clone https://github.com/yourusername/BrogueMCP.git
   cd BrogueMCP
   ```

2. **Build the Game**:
   - Open the **Mingw64** shell (not the regular MSYS2 shell)
   - Navigate to the BrogueMCP directory
   - Run:
   ```
   make bin/brogue.exe
   ```

3. **Run the Game**:
   ```
   cd bin
   ./brogue.exe
   ```

## macOS Build Instructions

### Setting up the Environment

1. **Install Homebrew**:
   ```
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. **Install Dependencies**:
   ```
   brew install sdl2 sdl2_image
   ```

### Compiling

1. **Get the Source Code**:
   ```
   git clone https://github.com/yourusername/BrogueMCP.git
   cd BrogueMCP
   ```

2. **Build the Game**:
   ```
   make bin/brogue
   ```

3. **Run the Game**:
   ```
   ./bin/brogue
   ```

### Building a macOS App Bundle

To create a distributable app bundle:

1. **Clean previous builds** (if necessary):
   ```
   make clean
   ```

2. **Build the App**:
   ```
   make GRAPHICS=YES MAC_APP=YES Brogue.app
   ```

3. **Rename the App**:
   ```
   mv Brogue.app "BrogueMCP.app"
   ```

4. **Bundle Libraries** (for distribution):
   - Install dylibbundler: `brew install dylibbundler`
   - Bundle dependencies:
   ```
   dylibbundler -od -b -x ./BrogueMCP.app/Contents/MacOS/brogue -d ./BrogueMCP.app/Contents/Frameworks/
   ```

## Linux Build Instructions

### Setting up the Environment

1. **Install Dependencies** (Debian/Ubuntu):
   ```
   sudo apt install make gcc diffutils libsdl2-2.0-0 libsdl2-dev libsdl2-image-2.0-0 libsdl2-image-dev
   ```

   For Fedora/RHEL:
   ```
   sudo dnf install make gcc diffutils SDL2-devel SDL2_image-devel
   ```

   For Arch Linux:
   ```
   sudo pacman -S make gcc diffutils sdl2 sdl2_image
   ```

### Compiling

1. **Get the Source Code**:
   ```
   git clone https://github.com/yourusername/BrogueMCP.git
   cd BrogueMCP
   ```

2. **Build the Game**:
   ```
   make bin/brogue
   ```

3. **Run the Game**:
   ```
   ./bin/brogue
   ```

## Building the DM Agent

The Dungeon Master AI agent requires Node.js:

1. **Install Node.js** (v14 or newer)

2. **Install Dependencies**:
   ```
   cd dm-agent
   npm install
   ```

3. **Configure the Agent** (optional):
   ```
   cp .env.sample .env
   # Edit .env with your preferred settings
   ```

## IDE Configuration

### Visual Studio Code

1. **Install Required Extensions**:
   - C/C++ extension
   - Make extension

2. **Configure settings.json**:
   ```json
   {
     "C_Cpp.default.includePath": [
       "${workspaceFolder}/src",
       "${workspaceFolder}/include"
     ],
     "C_Cpp.default.defines": [
       "BROGUE_CUSTOM"
     ]
   }
   ```

### CLion

1. **Import Project**:
   - Open CLion
   - Select "Open" and navigate to the BrogueMCP directory
   - Select the Makefile

2. **Configure Build Targets**:
   - Go to Settings > Build, Execution, Deployment > CMake
   - Add a custom target that invokes `make bin/brogue`

## Common Build Issues

### SDL2 Not Found

**Symptoms**: Compilation fails with "SDL.h not found" or similar errors.

**Solution**: 
- Verify SDL2 and SDL2_image are installed
- On Linux, make sure you have both runtime and development packages
- Check if pkg-config is installed and properly configured

### Missing Libraries at Runtime

**Symptoms**: Game fails to start with "cannot open shared object file" errors.

**Solution**:
- On Windows: Add the MSYS2 mingw64/bin directory to your PATH
- On Linux: Install the runtime libraries (`libsdl2-2.0-0` and `libsdl2-image-2.0-0`)
- On macOS: Use dylibbundler to properly embed libraries in the app bundle

### Compilation Errors with DM Agent Integration

**Symptoms**: Errors related to the MCP integration code.

**Solution**:
- Make sure all MCP dependencies are installed
- Check that the compatibility layer is properly configured
- See [DM-AI-INTEGRATION.md](docs/technical/DM-AI-INTEGRATION.md) for specific troubleshooting

## Further Reading

- [config.mk](config.mk) - Build configuration options
- [INSTALL.md](INSTALL.md) - Installation instructions for pre-built binaries
- [docs/technical/DM-AI-INTEGRATION.md](docs/technical/DM-AI-INTEGRATION.md) - Details on the DM AI integration 