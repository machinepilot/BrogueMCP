# BrogueMCP Cursor Rules System

Welcome to the BrogueMCP Cursor Rules System - your guide to creating high-quality roguelike games! This system provides intelligent guidance as you code, helping you implement common roguelike patterns correctly while avoiding typical pitfalls.

## 1. What is a Cursor Rule?

A Cursor Rule is a special file (with `.mdc` extension) that provides context-aware guidance and code patterns directly in your editor. Think of them as an experienced roguelike developer looking over your shoulder, offering advice specific to what you're working on.

## 2. Why Roguelikes Need Special Rules

Roguelikes have unique challenges that benefit from specialized guidance:

1. **Procedural Generation**: Rules for creating balanced, interesting dungeons
2. **Turn-Based Systems**: Patterns for managing complex turn sequencing
3. **Grid-Based Mechanics**: Efficient approaches to spatial relationships
4. **Entity Management**: Handling hundreds of monsters, items, and features
5. **Memory Efficiency**: Techniques for managing procedural data without leaks

## 3. System Overview

```
┌──────────────────────────────────────────┐
│                README.MDC                │
│          (Master Rule - Always Applied)  │
└───────────────────┬──────────────────────┘
                    │
        ┌───────────┼───────────┬───────────┬───────────┐
        │           │           │           │           │
┌───────▼─────┐ ┌───▼────┐ ┌────▼───┐ ┌─────▼────┐ ┌────▼────┐
│  Code Style │ │  Game  │ │  MCP   │ │  Memory  │ │ Testing │
└─────────────┘ └────────┘ └────────┘ └──────────┘ └─────────┘
        │           │           │           │           │
    ┌───▼───┐   ┌───▼───┐   ┌───▼───┐   ┌───▼────┐  ┌───▼────┐
    │C Style│   │Dungeon│   │Agent  │   │Entity  │  │Proc.   │
    │       │   │Gen.   │   │Integ. │   │Memory  │  │Testing │
    └───────┘   └───────┘   └───────┘   └────────┘  └────────┘
```

## 4. Explain How Rules are Selected and Applied

Break down the automation that selects appropriate rules:

```markdown
## How Rules Are Applied

Rules are automatically applied based on what files you're editing:

1. When you open a `.c` file, C style rules are loaded
2. When working with dungeon generation code, procedural generation rules appear
3. When editing entity code, memory management guidelines are provided

This happens through a combination of:
- **File path matching**: Using glob patterns like `**/dungeon/*.c`
- **Rule priorities**: Higher priority rules (like master rules) apply first
- **Relationships**: Rules can reference related rules that should also apply
```

## 5. Include a Directory Tour with Examples

Guide the reader through the rule directories with concrete examples:

```markdown
## Tour of the Rule System

Let's explore the main rule categories with examples:

### Code Style Rules
Located in `/.cursor/rules/code-style/`, these rules ensure consistent formatting and approaches.

**Example:** When writing a function to move a monster, the C style rule reminds you to:
```c
// Use descriptive variable names
bool move_monster(monster_t *monster, direction_t direction) {
    // Check boundary conditions first
    if (!is_valid_move(monster, direction)) {
        return false;
    }
    
    // Implementation follows...
}
```

### Game Mechanics Rules
Located in `/.cursor/rules/game/`, these rules provide patterns for roguelike features.

**Example:** When generating a dungeon room, the procedural generation rule suggests:
```c
// Generate room features after size and shape are determined
// Add at least one interesting element to each room
room_t *generate_room(int width, int height) {
    room_t *room = allocate_room(width, height);
    
    // Add basic structure first
    generate_room_walls(room);
    
    // Then add features with decreasing importance
    add_room_entrances(room);
    add_room_primary_features(room);  // Major features (altar, fountain)
    add_room_secondary_features(room); // Minor features (torches, debris)
    
    return room;
}
```
```

## 6. Provide a "Getting Started" Guide

Include practical steps for a new developer to start using the system:

```markdown
## Getting Started with the Rules System

1. **Setup**: Make sure your `.cursor` directory is at the root of your project

2. **Writing Code**: Simply open any file, and the applicable rules will automatically load

3. **Finding Guidance**: Look for the "Cursor Rules" panel in your editor to see active rules

4. **Rule Reference**: Browse the full set of rules in the `.cursor/rules/` directory

5. **Try an Example**: Open a dungeon generation file like `src/dungeon/generator.c` and notice how specific roguelike generation patterns are suggested
```

## 7. Include Self-Healing and Extension Sections

Explain the advanced features of the system:

```markdown
## Self-Healing Rules System

The BrogueMCP rules system has a unique self-improving capability:

1. It automatically analyzes code errors and issues
2. It identifies patterns in these problems
3. It generates new rule proposals to address common mistakes
4. After review, these proposals become permanent rules

This means the system gets smarter as your team uses it!

## Extending the Rules

Want to add your own rules? It's easy:

1. Create a new `.mdc` file in the appropriate category folder
2. Include the required metadata (title, glob, priority)
3. Write your guidance with examples
4. Reference related rules

Example template:
```markdown
---
title: "My New Roguelike Rule"
description: "Guidelines for implementing character inventory"
glob: "**/inventory/*.{c,h}"
priority: 650
related: ["../game/entity-management.mdc"]
---

# Inventory Management Guidelines

## Overview
This rule provides patterns for efficiently handling player and monster inventories.

## Implementation
...your guidance here...

## Examples
...code examples here...
```
```

## 8. Finish with a Development Philosophy

Conclude with the "why" behind the system:

```markdown
## The BrogueMCP Development Philosophy

This rules system embodies our approach to roguelike development:

1. **Procedural Excellence**: Creating varied yet balanced procedural content
2. **Memory Efficiency**: Managing complex state without performance issues  
3. **Cross-Platform Compatibility**: Ensuring the game runs everywhere
4. **Maintainable Code**: Making the codebase accessible for future developers

By following these rules, you're contributing to a roguelike that will stand the test of time!

## Questions and Support

If you have questions about the rules system:
1. Check the documentation in each rule file
2. Look at code examples in the codebase
3. Contact the BrogueMCP development team

Happy roguelike development!
```
