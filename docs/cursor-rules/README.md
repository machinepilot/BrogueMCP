# BrogueMCP Cursor Rules System

The BrogueMCP Cursor Rules system is a sophisticated framework for maintaining code quality, consistency, and development standards across the project. This AI-powered system provides context-aware guidance specifically tailored for roguelike development, focusing on procedural generation, turn-based mechanics, and MCP agent integration.

## Table of Contents

- [Overview](#overview)
- [Directory Structure](#directory-structure)
- [Key Features](#key-features)
- [Using the Rules System](#using-the-rules-system)
- [MCP Integration](#mcp-integration)
- [Self-Healing System](#self-healing-system)
- [Contributing to the Rules](#contributing-to-the-rules)

## Overview

The Cursor Rules system acts as an intelligent development assistant, providing:

- **Code Standards**: Enforcing consistent C coding patterns specific to roguelike development
- **Procedural Generation Patterns**: Guidance for implementing efficient procedural content
- **Memory Management**: Best practices for handling complex procedural data structures
- **Cross-Platform Support**: Ensuring code works across Windows, macOS, and Linux
- **AI Integration**: Framework for integrating the Dungeon Master agent

The rules are automatically applied by the Cursor editor when working with relevant files, ensuring consistent code quality without manual intervention.

## Directory Structure

```
BrogueMCP/
├── .cursor/               # Cursor rules system
│   ├── rules/             # Rule definitions
│   │   ├── activators/    # Rule activation patterns
│   │   ├── code-style/    # C coding standards
│   │   ├── game/          # Roguelike patterns
│   │   ├── mcp/           # MCP integration
│   │   ├── ai/            # AI behavior
│   │   ├── memory/        # Memory management
│   │   ├── self-healing/  # Automatic improvements
│   │   └── infrastructure/# Cross-platform build
│   └── mcp.json           # MCP server configuration
└── memory-bank/           # Memory storage for agents
```

## Key Features

### C Style Guide

The C style guide enforces roguelike-specific coding standards:

- **Memory Efficiency**: Patterns for managing grid-based data and entities
- **Procedural Structures**: Guidelines for seed-based generation and determinism
- **Turn-Based Logic**: Frameworks for managing state across turn boundaries
- **Cross-Platform Compatibility**: Ensuring code works identically on all platforms

### Roguelike Patterns

The system provides guidance for common roguelike implementation challenges:

- **Procedural Generation**: Algorithms for dungeon layout, item placement, etc.
- **Field of View**: Efficient visibility calculations and fog of war
- **Entity Management**: Handling monsters, items, and environmental features
- **Turn Management**: Coordinating player and monster actions

### MCP Integration

Guidelines for integrating with the Model Context Protocol (MCP):

- **Event Hooks**: How to capture meaningful game events
- **Memory Integration**: Storing and retrieving narrative-relevant information
- **Response Handling**: Displaying AI-generated content within the game UI
- **Configuration Management**: Setting up and maintaining the MCP environment

### Cross-Platform Guidelines

Ensures consistent behavior across:

- **Windows**: Using appropriate APIs and handling Windows-specific issues
- **macOS**: Guidelines for App packaging and macOS conventions
- **Linux**: Ensuring compatibility with various distributions

## Using the Rules System

### In-Editor Experience

When using the Cursor editor, the rules system automatically:

1. **Applies relevant rules** based on the file type and location
2. **Suggests improvements** to match coding standards 
3. **Provides context-aware guidance** for roguelike-specific patterns
4. **Warns about potential issues** specific to procedural content

### Rule Activation

Files are matched to rules using glob patterns in the activators directory:

- C source files load coding standards automatically
- Files in the `src/mcp` directory load MCP integration rules
- Files dealing with procedural generation load relevant algorithms

### Manual Reference

You can also manually reference rules using the `mdc:` protocol in documentation:

```markdown
For procedural room generation, see [Procedural Generation Guidelines](mdc:.cursor/rules/game/procedural-generation.mdc).
```

## MCP Integration

The rules system includes special guidelines for MCP (Model Context Protocol) integration, which powers the Dungeon Master AI:

### Knowledge Integration

Rules for how the codebase should:

- Capture significant game events
- Structure data for the DM agent
- Handle server communication
- Process and display responses

### MCP Server Configuration

The MCP server for BrogueMCP is configured to use ports 8100-8199, allowing multiple projects to run simultaneously without conflicts.

## Self-Healing System

The rules system includes a self-healing component that:

1. **Analyzes code errors** from compilation logs and runtime
2. **Identifies patterns** in recurring issues
3. **Generates rule proposals** to address common problems
4. **Integrates accepted proposals** into the rule system

This creates a continuous improvement cycle, with the rules evolving based on actual development challenges.

### Running the Self-Healing Analysis

You can manually trigger the self-healing analysis:

```powershell
PowerShell -ExecutionPolicy Bypass -File .cursor\rules\self-healing\error-analyzer.ps1
```

## Contributing to the Rules

When adding or modifying rules:

1. **Identify the category** for your rule (code style, game mechanics, etc.)
2. **Create a rule file** using the standard format:
   ```
   ---
   title: "Rule Title"
   description: "Brief description"
   glob: "pattern/to/match/**"
   priority: 500
   related: ["related-rule-1.mdc"]
   ---
   
   # Rule content and guidelines
   ```
3. **Test the rule** by working with relevant files
4. **Update related rules** if necessary
5. **Document the rule** in appropriate README files

For detailed information on rule development, see the [Rules Development Guide](../development/RULES-DEVELOPMENT.md).

## Further Reading

- [Self-Healing System](../technical/SELF-HEALING.md) - Details on the automatic improvement system
- [MCP Integration Guide](../technical/MCP-INTEGRATION.md) - Technical details for MCP integration
- [Roguelike Patterns](../game/ROGUELIKE-PATTERNS.md) - Common implementation patterns for roguelikes 