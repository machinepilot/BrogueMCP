# Brogue Dungeon Master AI - Playtest Guide

This guide helps you set up and test the Dungeon Master AI system, providing instructions for both automated and manual testing approaches.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Testing Features](#testing-features)
- [Advanced Testing](#advanced-testing)
- [Providing Feedback](#providing-feedback)
- [Troubleshooting](#troubleshooting)
- [Manual Testing Procedure](#manual-testing-procedure)

## Overview

The Dungeon Master (DM) AI enhances the BrogueMCP gameplay experience by:

1. **Generating atmospheric narratives** for key game events
2. **Maintaining memory** of your encounters and discoveries
3. **Creating a more immersive** dungeon crawling experience

Your feedback as a playtester is crucial for improving this system.

## Prerequisites

- Windows 10/11 with PowerShell (or Linux/macOS with bash)
- [Node.js](https://nodejs.org/) installed (v14 or newer)
- [Ollama](https://ollama.ai) installed with the llama3 model
- BrogueMCP compiled with DM agent integration

## Quick Start

1. **Setup the DM Agent**:
   ```powershell
   cd BrogueMCP\playtest
   .\start-server.ps1
   ```
   
   For Linux/macOS:
   ```bash
   cd BrogueMCP/playtest
   ./start-server.sh
   ```

2. **Run a Gameplay Simulation**:
   ```powershell
   cd BrogueMCP\playtest
   .\simulate-gameplay.ps1
   ```
   
   For Linux/macOS:
   ```bash
   cd BrogueMCP/playtest
   ./simulate-gameplay.sh
   ```

3. **View the Logs**:
   ```powershell
   cd BrogueMCP\playtest
   .\view-logs.ps1
   ```
   
   For Linux/macOS:
   ```bash
   cd BrogueMCP/playtest
   ./view-logs.sh
   ```

## Testing Features

### 1. Narrative Generation

The DM AI generates narratives for five key event types:

#### Monster Encounters
When you meet creatures for the first time or encounter rare monsters.

**Testing**: Explore the dungeon thoroughly to encounter different monster types.

#### Monster Defeats
After you slay a monster, especially rare or powerful ones.

**Testing**: Defeat different monster types, particularly unique or dangerous foes.

#### Item Discoveries
When finding interesting or rare items.

**Testing**: Open vaults, defeat monsters carrying items, and explore thoroughly.

#### Level Transitions
Upon entering new dungeon depths.

**Testing**: Descend to different levels, noting the environmental descriptions.

#### Player Death
A dramatic epitaph for your fallen adventurer.

**Testing**: When you die, observe the quality and relevance of the death narrative.

### 2. Memory System

The DM AI maintains information across your gameplay:

#### Short-term Memory
Recent events that inform new narratives.

**Testing**: Note if narratives reference recent encounters or discoveries.

#### Long-term Memory
Significant events stored persistently.

**Testing**: Play multiple sessions and look for callbacks to previous adventures.

#### Knowledge Bases
Information about creatures and items you've encountered.

**Testing**: Observe how descriptions evolve as you encounter the same entities multiple times.

### 3. Detailed Logs

Logs are recorded in two formats:

#### Raw logs
Technical details in `session_[timestamp].log`

#### Adventure logs
Beautiful, themed narratives in `events_[timestamp].md`

**Testing**: Review both log types to see how technical events translate to narrative text.

## Advanced Testing

### Testing with Different Adventure Paths

Try the different adventure scenarios:

```powershell
.\simulate-gameplay.ps1 -adventure "The Crystal Caverns"
```

Available adventures:
- **The Goblin Caves** (beginner)
- **The Crystal Caverns** (intermediate)
- **The Undead Catacombs** (advanced)

### Custom Events

You can trigger specific events manually:

```powershell
# Monster encounter
.\monster.ps1 -name "ancient dragon" -level 15 -rare $true

# Item discovery
.\item.ps1 -name "Amulet of Yendor" -rare $true

# Level transition
.\level.ps1 -depth 26 -environment "obsidian vault"
```

## Providing Feedback

As a playtester, we'd like your feedback on:

### 1. Narrative Quality
- Are the descriptions atmospheric and enjoyable?
- Do they match the game context appropriately?
- Is the text length appropriate (not too long or short)?

### 2. Integration Feel
- Does the DM feel like a natural part of gameplay?
- Are the narratives well-timed and non-intrusive?
- Does the narrative enhance or detract from gameplay flow?

### 3. Memory System
- Does the system seem to remember past events?
- Are callbacks to previous encounters natural?
- Does the memory provide a coherent story arc?

### 4. Technical Performance
- How responsive is the narrative generation?
- Did you experience any lag or performance issues?
- Were there any crashes or stability problems?

### 5. Bugs and Issues
- Any errors or unexpected behavior?
- Instances where narratives didn't make sense?
- UI problems with how narratives are displayed?

Please record your thoughts in the `FEEDBACK.md` file in the `playtest` directory or submit via GitHub issues.

## Troubleshooting

### Server Not Starting

If the server fails to start:

1. Check that Node.js is installed (`node --version`)
2. Ensure npm packages are installed (`cd BrogueMCP\dm-agent && npm install`)
3. Check for port conflicts on 3001
4. Verify Ollama is running (`ollama serve` in a separate terminal)

### No Narrative Responses

If you're not getting narrative responses:

1. Check server console for errors
2. Ensure the event types have `isRare` or `isFirstEncounter` set to true
3. Verify server is running on port 3001
4. Check Ollama is running and the llama3 model is installed

### Log Viewer Issues

If the log viewer isn't working:

1. Make sure there are log files in `BrogueMCP\playtest\logs`
2. Try opening the HTML files directly from `BrogueMCP\playtest\html`
3. Ensure your browser isn't blocking local file access

## Manual Testing Procedure

If you're unable to run the automated tests or prefer manual testing, you can use this approach:

1. **Start the DM agent server**:
   ```
   cd BrogueMCP/dm-agent
   node server/server.js
   ```

2. **Start Brogue**:
   ```
   cd BrogueMCP/bin
   ./brogue
   ```

3. **Play the game normally, and at key moments, manually trigger events** in a separate terminal:

   ```
   # When encountering a new monster
   curl -X POST http://localhost:3001/api/event -H "Content-Type: application/json" -d "{\"eventType\":\"MONSTER_ENCOUNTERED\",\"eventData\":{\"monsterName\":\"pink jelly\",\"isFirstEncounter\":true,\"locationDesc\":\"dark chamber\"},\"context\":{\"playerLevel\":1}}"
   
   # When finding a new item
   curl -X POST http://localhost:3001/api/event -H "Content-Type: application/json" -d "{\"eventType\":\"ITEM_DISCOVERED\",\"eventData\":{\"itemName\":\"Staff of Lightning\",\"isRare\":true},\"context\":{\"playerLevel\":1}}"
   
   # When entering a new level
   curl -X POST http://localhost:3001/api/event -H "Content-Type: application/json" -d "{\"eventType\":\"NEW_LEVEL\",\"eventData\":{\"depth\":2,\"environmentType\":\"cavern\"},\"context\":{\"playerLevel\":1}}"
   ```

4. **Review the narrative responses** in the server console.

5. **Check memory storage** in the `memory-bank` directory after gameplay.

## Expected Behaviors

During a proper playtest, you should observe:

1. **Contextual Narratives**: AI-generated descriptions that match the game state
2. **Memory Accumulation**: Growing knowledge of encountered entities
3. **Progressive Context**: Later narratives reference earlier encounters
4. **Fallback Reliability**: System functions even if AI is temporarily unavailable

---

Thank you for your help in playtesting the Dungeon Master AI! Your feedback is invaluable in making BrogueMCP's storytelling experience even better. 