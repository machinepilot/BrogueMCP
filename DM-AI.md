# Dungeon Master AI Guide

The Dungeon Master (DM) AI is a core feature of BrogueMCP, enhancing the classic roguelike experience with dynamic narrative elements powered by local LLM technology.

## Table of Contents

- [Overview](#overview)
- [Narrative Features](#narrative-features)
- [The Memory System](#the-memory-system)
- [Narrator Customization](#narrator-customization)
- [Enabling and Disabling](#enabling-and-disabling)
- [Technical Details](#technical-details)
- [Troubleshooting](#troubleshooting)
- [Extending the System](#extending-the-system)

## Overview

The Dungeon Master AI acts as a storyteller for your adventure, transforming the traditional roguelike experience with rich narrative descriptions. It observes your gameplay and provides contextually relevant, atmospheric descriptions of important events.

The system generates narratives based on:
- Game events (monster encounters, item discoveries, level transitions)
- Your character's history (past encounters and experiences)
- The current game state (environment, health, equipment)
- The customized narrator personality you select

All narrative generation happens locally on your machine using Ollama, providing privacy and offline functionality.

## Narrative Features

### Key Event Narration

The DM AI generates descriptions for five types of significant events:

#### Monster Encounters

When encountering a monster for the first time or meeting a rare creature:

> *"A crimson tinge pulses through the foliage as a pink jelly oozes from the shadows. The glutinous mass quivers with an uncanny sentience, its translucent body revealing half-digested remains of less fortunate dungeon denizens."*

#### Monster Defeats

After defeating a particularly powerful or rare creature:

> *"The ancient dragon's final roar echoes through the chamber as its massive form collapses. Scales that once shimmered with arcane energy now grow dull, and the fearsome creature that terrorized these depths for centuries is no more. Your blade drips with ichor, having written the final chapter in the beast's long history."*

#### Item Discoveries

When finding an important or magical item:

> *"Nestled within the ancient chest, you discover a staff wreathed in dancing electrical currents. The wood seems to hum with barely contained power, tiny arcs of lightning occasionally leaping between your fingers as you carefully examine the artifact. The Staff of Lightning calls to the storm within you."*

#### Level Transitions

Upon entering a new dungeon level:

> *"You descend the crumbling stairway into the fourteenth floor, where the air hangs heavy with the scent of stagnant water. Bioluminescent fungi cling to the walls of this vast cavern, casting an eerie blue glow across the stone floor. The distant sound of dripping water echoes throughout, punctuated occasionally by unsettling skittering noises."*

#### Player Death

A dramatic epitaph when your character dies:

> *"Your journey ends here, on the twenty-third floor, where the poisonous gas of a bloat finally overcame your weakened form. Though you discovered many treasures and vanquished countless foes, the Amulet of Yendor remains unclaimed, awaiting another brave soul. Your final thoughts drift to the sunshine above that you'll never see again."*

### Example Interaction

```
You encounter a pink jelly for the first time.

[DM Narration appears]
"A gelatinous mass oozes from the shadows, its translucent pink body
pulsating with unnatural life. Small bubbles form and pop along its
surface as it senses your presence, revealing a primitive hunger that
has consumed many unwary adventurers before you."

> You attack the pink jelly with your +2 axe of slaying.

[Combat message appears]
"Your axe slices through the pink jelly, dealing 18 damage."
"The pink jelly dies."

[DM Narration appears]
"Your axe cleaves through the jelly with surprising effectiveness, 
its enchanted edge disrupting the creature's cohesion. The amorphous
form shudders violently before collapsing into a harmless puddle of
viscous fluid that seeps between the stones of the dungeon floor."
```

## The Memory System

The DM's memory system allows for a coherent narrative that evolves throughout your adventure:

### Short-term Memory

- Remembers recent events (last 10-20 significant happenings)
- Provides immediate context for new narratives
- Ensures consistency in tone and story elements

### Long-term Memory

- Stores important milestones and significant encounters
- Persists between game sessions
- Enables callbacks to earlier adventures
- Remembers your interaction style and preferences

### Knowledge Bases

The DM maintains and expands specialized knowledge about:

- **Monsters**: Their behaviors, appearances, and your history with them
- **Items**: Properties, significance, and your past experiences
- **Locations**: Recurring environmental features and significant areas
- **Character Arc**: Your personal journey, triumphs, and challenges

### Memory Examples

After encountering multiple jellies:

> *"Another pink jelly emerges, similar to the one you dispatched earlier. You recognize the characteristic bubbling surface and instinctively ready your axe, knowing its enchantment proved effective before."*

When finding a second potion of strength:

> *"You discover another azure potion, its color identical to the strength potion you consumed three levels ago. The familiar scent confirms your suspicion—this will further enhance your physical might."*

## Narrator Customization

Press `N` during gameplay to open the narrator customization interface in your browser.

### Personality Presets

Choose from literary-inspired narrator styles:

- **Gandalf**: Wise, philosophical, with a touch of dry humor
- **Galadriel**: Mystical, ethereal, with a focus on deeper meanings
- **Aragorn**: Direct, brave, focused on honor and combat
- **Custom**: Create your own narrator style

### Adjustable Attributes

Fine-tune the following characteristics:

#### Voice Attributes

- **Wisdom**: From pragmatic to philosophical
- **Formality**: From casual to ceremonial
- **Verbosity**: From concise to elaborate
- **Tone**: From grim to hopeful

#### Thematic Elements

- **Nature References**: How often the narrator uses natural imagery
- **Metaphor Complexity**: From literal to complex figurative language
- **Historical References**: The depth of lore and historical context
- **Cosmic Awareness**: From mundane to cosmic significance

#### Speech Patterns

- **Question Frequency**: How often the narrator poses questions
- **Directive Speech**: How often the narrator offers advice
- **Archaic Language**: Use of older speech patterns
- **Sentence Structure**: Complexity and variety of sentence forms

### Saving and Loading Profiles

- Save your custom narrator settings for future use
- Share narrator profiles with other players
- Export and import profiles via JSON files

## Enabling and Disabling

The DM AI can be toggled according to your preferences:

### During Gameplay

- Press `D` to temporarily disable or enable the DM narration
- Adjust verbosity levels in the settings menu (press `=`)

### From the Main Menu

- Enable/disable DM AI from the Options menu
- Set default verbosity level

### Configuration File

Edit the `.env` file in the `dm-agent` directory:

```
# Set to false to completely disable the DM
DM_ENABLED=true

# Narrative frequency (minimal, standard, verbose)
NARRATIVE_LEVEL=standard

# Events to narrate (all, major, combat, items, environment)
NARRATIVE_EVENTS=all
```

## Technical Details

### How It Works

The DM AI operates through a client-server architecture:

1. **Game Events**: The BrogueMCP client captures significant game events
2. **Event Processing**: Events are sent to the DM Agent server
3. **Context Building**: The server creates a prompt using current event data and memory
4. **Narrative Generation**: Ollama LLM generates appropriate narrative text
5. **Response Display**: The narrative is returned to the game and displayed to the player

### Components

- **MCP Client Integration**: C code hooks into the game to capture events
- **DM Agent Server**: Node.js Express server that handles requests
- **Memory Manager**: Maintains short and long-term memory
- **Narrative Generator**: Creates prompts and processes LLM responses
- **Ollama Interface**: Communicates with the Ollama LLM

### System Requirements

The DM AI has additional requirements beyond the base game:

- Node.js 14+ for the DM Agent server
- Ollama with the llama3 model
- 2GB additional RAM for the LLM
- 1.5GB additional disk space for the model

## Troubleshooting

### Common Issues

#### No Narrative Responses

- **Check**: Is the DM Agent server running? Start it with `cd dm-agent && npm start`
- **Check**: Is Ollama running? Start it with `ollama serve`
- **Check**: Is the llama3 model installed? Install with `ollama pull llama3`
- **Check**: Are you encountering supported event types? Try finding a new monster or item

#### Server Won't Start

- **Check**: Is Node.js installed? Run `node --version` to verify
- **Check**: Are npm packages installed? Run `cd dm-agent && npm install`
- **Check**: Is port 3000 in use? Change the port in the `.env` file if needed

#### Slow Responses

- **Solution**: Reduce `OLLAMA_MAX_TOKENS` in the `.env` file
- **Solution**: Close other resource-intensive applications
- **Solution**: Consider using a lighter model (modify `OLLAMA_MODEL` in `.env`)

#### Disconnection Issues

- **Solution**: Restart the DM Agent server
- **Solution**: Check network connectivity if using a remote Ollama server
- **Solution**: Verify firewall settings aren't blocking local connections

### Logs and Debugging

Check log files for troubleshooting:

- **DM Agent Logs**: `dm-agent/logs/server.log`
- **Memory Bank**: `memory-bank/session_[timestamp].log`
- **Event Logs**: `memory-bank/events_[timestamp].md` (readable narrative history)

## Extending the System

For developers interested in extending the DM AI:

### Adding New Event Types

1. Update `event_hooks.c` in the `src/mcp` directory
2. Add event processing in `server.js` in the `dm-agent/server` directory
3. Create a system prompt in `generator.js` in the `dm-agent/narrative` directory

### Customizing Memory Management

Modify `memory-manager.js` to change how memories are:
- Selected for storage
- Prioritized for retrieval
- Used for context building

### Adding New Narrator Personalities

Edit `narrator-presets.json` in the `dm-agent/public` directory to add new presets.

### Using Different LLM Models

1. Pull a different model with Ollama: `ollama pull mistral`
2. Update the `.env` file to use the new model: `OLLAMA_MODEL=mistral`

For more technical details, see [DM-AI Integration](docs/technical/DM-AI-INTEGRATION.md). 