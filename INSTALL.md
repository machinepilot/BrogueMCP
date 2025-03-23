# Installation Guide

This guide provides detailed instructions for installing BrogueMCP and its Dungeon Master AI system on all supported platforms.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Windows Installation](#windows-installation)
- [macOS Installation](#macos-installation)
- [Linux Installation](#linux-installation)
- [Installing Ollama (All Platforms)](#installing-ollama-all-platforms)
- [Configuring the DM Agent](#configuring-the-dm-agent)
- [Troubleshooting](#troubleshooting)

## Prerequisites

To run BrogueMCP with the Dungeon Master AI, you'll need:

- A modern operating system (Windows 10+, macOS 10.14+, or Linux)
- At least 4GB of RAM
- 500MB of free disk space
- [Ollama](https://ollama.ai) for the LLM-powered narratives
- [Node.js](https://nodejs.org/) (v14 or newer) for the DM Agent

## Windows Installation

### Option 1: Pre-built Release (Recommended)

1. **Download the latest release** from the [releases page](https://github.com/yourusername/BrogueMCP/releases)
2. **Extract the ZIP file** to a location of your choice
3. **Install Ollama** (see [Installing Ollama](#installing-ollama-all-platforms))
4. **Install Node.js** from [nodejs.org](https://nodejs.org/)
5. **Set up the DM Agent**:
   ```
   cd path\to\BrogueMCP\dm-agent
   npm install
   ```

### Option 2: Building from Source

If you prefer to build from source, follow these steps:

1. **Install MSYS2** from [msys2.org](https://www.msys2.org/)
2. **Install dependencies**: Open the MSYS2 shell and run:
   ```
   pacman -S make diffutils mingw-w64-x86_64-{gcc,SDL2,SDL2_image}
   ```
3. **Clone the repository**:
   ```
   git clone https://github.com/yourusername/BrogueMCP.git
   cd BrogueMCP
   ```
4. **Build the game**: Open the Mingw64 shell and run:
   ```
   make bin/brogue.exe
   ```
5. **Set up the DM Agent**:
   ```
   cd dm-agent
   npm install
   ```

See [BUILDING.md](BUILDING.md) for more detailed build instructions.

## macOS Installation

### Option 1: Pre-built App (Recommended)

1. **Download the latest release** from the [releases page](https://github.com/yourusername/BrogueMCP/releases)
2. **Mount the DMG** and drag the app to your Applications folder
3. **Install Ollama** (see [Installing Ollama](#installing-ollama-all-platforms))
4. **Install Node.js** from [nodejs.org](https://nodejs.org/)
5. **Set up the DM Agent**:
   ```
   cd /Applications/BrogueMCP.app/Contents/Resources/dm-agent
   npm install
   ```

### Option 2: Building from Source

1. **Install Homebrew** from [brew.sh](https://brew.sh/)
2. **Install dependencies**:
   ```
   brew install sdl2 sdl2_image
   ```
3. **Clone the repository**:
   ```
   git clone https://github.com/yourusername/BrogueMCP.git
   cd BrogueMCP
   ```
4. **Build the game**:
   ```
   make bin/brogue
   ```
5. **Set up the DM Agent**:
   ```
   cd dm-agent
   npm install
   ```

See [BUILDING.md](BUILDING.md) for more detailed build instructions.

## Linux Installation

### Option 1: Pre-built Binary (Recommended)

1. **Download the latest release** from the [releases page](https://github.com/yourusername/BrogueMCP/releases)
2. **Extract the tarball**:
   ```
   tar -xzf BrogueMCP-Linux.tar.gz
   cd BrogueMCP
   ```
3. **Install dependencies**:
   ```
   sudo apt install libsdl2-2.0-0 libsdl2-image-2.0-0
   ```
   (Adjust for your distribution if not using Debian/Ubuntu)
4. **Install Ollama** (see [Installing Ollama](#installing-ollama-all-platforms))
5. **Install Node.js** from [nodejs.org](https://nodejs.org/)
6. **Set up the DM Agent**:
   ```
   cd dm-agent
   npm install
   ```

### Option 2: Building from Source

1. **Install dependencies**:
   ```
   sudo apt install make gcc diffutils libsdl2-2.0-0 libsdl2-dev libsdl2-image-2.0-0 libsdl2-image-dev
   ```
   (Adjust for your distribution if not using Debian/Ubuntu)
2. **Clone the repository**:
   ```
   git clone https://github.com/yourusername/BrogueMCP.git
   cd BrogueMCP
   ```
3. **Build the game**:
   ```
   make bin/brogue
   ```
4. **Set up the DM Agent**:
   ```
   cd dm-agent
   npm install
   ```

See [BUILDING.md](BUILDING.md) for more detailed build instructions.

## Installing Ollama (All Platforms)

The Dungeon Master AI requires Ollama with the llama3 model:

1. **Download and install Ollama** from [ollama.ai](https://ollama.ai)
2. **Pull the llama3 model**:
   ```
   ollama pull llama3
   ```

## Configuring the DM Agent

For a basic setup, no configuration is needed. To customize the DM Agent:

1. **Create a configuration file**:
   ```
   cd path/to/BrogueMCP/dm-agent
   cp .env.sample .env
   ```
2. **Edit the .env file** with your preferred settings:
   ```
   # Server configuration
   PORT=3000
   
   # Ollama configuration
   OLLAMA_URL=http://localhost:11434
   OLLAMA_MODEL=llama3
   OLLAMA_TEMPERATURE=0.7
   OLLAMA_MAX_TOKENS=512
   
   # Memory bank configuration
   MEMORY_BANK_PATH=../memory-bank
   ```

## Running the Game

1. **Start the DM Agent**:
   ```
   cd path/to/BrogueMCP/dm-agent
   npm start
   ```
2. **Launch BrogueMCP**:
   - **Windows**: Run `bin\brogue.exe`
   - **macOS**: Run the app or use `./bin/brogue`
   - **Linux**: Run `./bin/brogue`

## Troubleshooting

### DM Agent Not Starting

- Make sure Node.js is installed and version 14 or higher
- Check that all dependencies are installed with `npm install`
- Verify port 3000 is not in use by another application

### No Narrative Responses

- Ensure Ollama is running (`ollama serve` in a separate terminal)
- Verify the llama3 model is installed (`ollama list`)
- Check the DM Agent console for error messages

### Game Won't Start

- Verify SDL2 libraries are installed
- Check for error messages in the console
- Ensure the game binary has execute permissions on macOS/Linux

### Performance Issues

- Try reducing the OLLAMA_MAX_TOKENS value in the .env file
- Close other resource-intensive applications
- Ensure your system meets the minimum requirements

For more assistance, please check the [documentation](docs/) or reach out to the community through the links in the [README.md](README.md). 