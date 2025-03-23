# BrogueMCP Dungeon Master AI Integration

This technical document details the integration of the Dungeon Master AI system into BrogueMCP, explaining the architecture, implementation details, and technical considerations.

## Table of Contents

- [System Architecture](#system-architecture)
- [Integration Status](#integration-status)
- [Component Overview](#component-overview)
- [Implementation Details](#implementation-details)
- [Build Integration](#build-integration)
- [Function Hooking](#function-hooking)
- [Communication Protocol](#communication-protocol)
- [Memory Management](#memory-management)
- [Technical Challenges](#technical-challenges)
- [Testing and Verification](#testing-and-verification)
- [Performance Considerations](#performance-considerations)

## System Architecture

The Dungeon Master AI integration follows a client-server architecture:

```
┌─────────────────┐      HTTP/JSON     ┌─────────────────┐      API      ┌─────────────────┐
│                 │                    │                 │               │                 │
│  BrogueMCP      │<=================>│  DM Agent       │<============>│  Ollama LLM     │
│  (C Game)       │    Requests       │  (Node.js)      │  Requests    │  (Local Model)  │
│                 │                    │                 │               │                 │
└─────────────────┘                    └─────────────────┘               └─────────────────┘
     ↑                                       │
     │                                       │
     │                                       ↓
     │                               ┌─────────────────┐
     └───────────────────────────────│  Memory Bank    │
       Read/Write Memories           │  (Persistent)   │
                                     └─────────────────┘
```

The system consists of three main components:

1. **BrogueMCP Game**: The C codebase with integration hooks to capture events
2. **DM Agent Server**: A Node.js Express server that processes events, manages memory, and generates narratives
3. **Ollama LLM**: Local large language model that produces the narrative content

## Integration Status

| Component | Status | Notes |
|-----------|--------|-------|
| DM Agent Server | ✅ Complete | Working with Ollama |
| Memory System | ✅ Complete | Storing events and knowledge |
| Narrative Generation | ✅ Complete | Generating appropriate responses |
| C Integration Code | ✅ Complete | Written and validated |
| Game Build Integration | ✅ Complete | Successfully building with MCP code |
| Event Hooking | ✅ Complete | Capturing and processing events |

## Component Overview

### BrogueMCP Game Integration (C)

Located in `src/mcp/`:
- `mcp_client.c`: HTTP client for communicating with DM server
- `event_hooks.c`: Game event capture and message handling
- `dm_main.c`: Main integration API
- `hooks.c`: Function hooks into the game

### DM Agent Server (Node.js)

Located in `dm-agent/`:
- `server/`: Express server for handling event requests
- `memory/`: Memory management system
- `narrative/`: Narrative generation with LLM
- `ollama/`: Ollama integration
- `public/`: UI for narrator settings

### Memory Bank

Located in `memory-bank/`:
- Stores persistent memories between sessions
- Maintains knowledge bases about game entities
- Logs events for debugging and playback

## Implementation Details

### C Integration Components

#### MCP Client (`mcp_client.c`)

Handles communication with the DM Agent server:
- Initializes HTTP client with cURL
- Sends JSON event data via POST requests
- Handles responses asynchronously
- Implements error handling and retry logic

```c
// Simplified example
bool mcp_send_event(const char *eventType, json_t *eventData, json_t *context) {
    json_t *requestObj = json_object();
    json_object_set_new(requestObj, "eventType", json_string(eventType));
    json_object_set(requestObj, "eventData", eventData);
    json_object_set(requestObj, "context", context);
    
    char *jsonStr = json_dumps(requestObj, JSON_COMPACT);
    
    // Send async HTTP request
    bool success = send_http_request("http://localhost:3001/api/event", jsonStr);
    
    free(jsonStr);
    json_decref(requestObj);
    
    return success;
}
```

#### Event Hooks (`event_hooks.c`)

Captures significant game events for narration:
- Monster encounters and defeats
- Item discoveries
- Level transitions
- Player death

```c
// Hook for monster encounters
void dm_monster_encountered(creature *monst) {
    if (!dm_is_initialized() || !monst) return;
    
    json_t *eventData = json_object();
    json_object_set_new(eventData, "monsterName", json_string(monst->info.monsterName));
    json_object_set_new(eventData, "isFirstEncounter", json_boolean(!(monst->bookkeeping.flags & MB_ENCOUNTERED_ALREADY)));
    json_object_set_new(eventData, "locationDesc", json_string(get_environment_description(monst->xLoc, monst->yLoc)));
    
    json_t *context = build_context_object();
    
    mcp_send_event("MONSTER_ENCOUNTERED", eventData, context);
    
    json_decref(eventData);
    json_decref(context);
    
    // Mark as encountered
    monst->bookkeeping.flags |= MB_ENCOUNTERED_ALREADY;
}
```

#### Main Integration API (`dm_main.c`)

Provides the main interface for DM integration:
- Initialization and shutdown
- Configuration management
- Event queue handling
- Response processing

```c
// Initialize the DM system
bool dm_initialize() {
    if (dm_initialized) return true;
    
    // Initialize client
    if (!mcp_client_init()) {
        return false;
    }
    
    // Set up hooks
    install_game_hooks();
    
    dm_initialized = true;
    return true;
}

// Display a narrative message
void dm_display_narrative(const char *text) {
    if (!text || !dm_initialized) return;
    
    // Format for the message window
    char *formattedText = format_narrative_text(text);
    
    // Display in game message window
    displayMessage(formattedText, false);
    
    free(formattedText);
}
```

#### Game Hooks (`hooks.c`)

Installs function hooks to capture events:
- Uses function pointer replacement technique
- Preserves original function behavior
- Adds event capture before or after original function

```c
// Original function pointer
static void (*original_kill_monster)(creature *);

// Enhanced version that captures monster death events
static void enhanced_kill_monster(creature *monst) {
    // Pre-processing
    bool isRare = is_rare_monster(monst);
    char *monsterName = monst->info.monsterName;
    
    // Call original function
    original_kill_monster(monst);
    
    // Post-processing - send event
    if (isRare) {
        dm_monster_defeated(monsterName, isRare);
    }
}

// Install hooks
void install_game_hooks() {
    // Store original function and replace
    original_kill_monster = &killCreature;
    killCreature = enhanced_kill_monster;
    
    // More hook installations...
}
```

## Build Integration

The Dungeon Master AI integration is included in the build system:

### Makefile Modifications

```makefile
# MCP source files
MCP_SOURCES = src/mcp/mcp_client.c src/mcp/event_hooks.c src/mcp/dm_main.c src/mcp/hooks.c

# Add MCP sources to build
SOURCES += $(MCP_SOURCES)

# Additional flags for MCP
CFLAGS += -DENABLE_MCP
LDFLAGS += -lcurl
```

### Conditional Compilation

The integration can be conditionally enabled:

```c
#ifdef ENABLE_MCP
    // Initialize DM system
    dm_initialize();
#endif
```

## Function Hooking

Two approaches were implemented for function hooking:

### 1. Function Pointer Replacement

Used for most hooks:

```c
// Store original function
static void (*original_function)(params) = &game_function;

// Create enhanced version
static void enhanced_function(params) {
    // Pre-processing
    original_function(params);
    // Post-processing
}

// Replace function
void hook_functions() {
    game_function = enhanced_function;
}
```

### 2. Structure Field Modification

Used for certain engine components:

```c
// Replace functions in game engine struct
void hook_engine_functions() {
    gameEngine.displayMessage = enhanced_display_message;
    gameEngine.createMonster = enhanced_create_monster;
}
```

## Communication Protocol

The DM Agent server communicates via HTTP/JSON:

### Event Request Format

```json
{
  "eventType": "MONSTER_ENCOUNTERED",
  "eventData": {
    "monsterName": "pink jelly",
    "isFirstEncounter": true,
    "locationDesc": "dark chamber"
  },
  "context": {
    "playerLevel": 1,
    "depth": 3,
    "playerHealth": 80,
    "environment": "cave"
  }
}
```

### Response Format

```json
{
  "narrative": "A gelatinous mass oozes from the shadows, its translucent pink body pulsating with unnatural life...",
  "success": true,
  "memoryId": "mem_12345"
}
```

## Memory Management

### Memory Lifetime

The integration manages several types of memory:

1. **Request Memory**: Allocated during event processing and freed after response
2. **Game Context**: Captured state information, freed after each request
3. **Response Memory**: Allocated when receiving narratives, freed after display
4. **Persistent Memory**: Stored in memory bank, managed by the DM Agent

### Memory Safety

To prevent leaks, the implementation uses:
- Clear ownership rules for allocated memory
- Careful tracking of json_t references with proper json_decref calls
- Defensive programming with null checks
- Memory pooling for frequently allocated structures

## Technical Challenges

### Cross-Platform Considerations

The integration accounts for platform differences:

#### Windows
- Uses WinSock for networking on Windows
- Handles Windows-specific path separators
- Manages Windows thread priorities

#### Linux/macOS
- Uses POSIX APIs
- Handles file permission differences
- Manages library path distinctions

### Threading Model

The integration carefully handles threading to prevent issues:

- Network requests run in a separate thread
- Response processing uses a thread-safe queue
- Display happens on the main game thread
- Proper synchronization prevents race conditions

### Backward Compatibility

The integration maintains compatibility with legacy code:

- Conditional compilation for different Brogue versions
- Compatibility layer in `mcp_compat.h`
- Feature detection for API differences

## Testing and Verification

### Test Framework

A comprehensive test framework validates the integration:

1. **Unit Tests**: Individual component validation
2. **Integration Tests**: End-to-end testing of event flow
3. **Stress Tests**: Performance under high event volume
4. **Compatibility Tests**: Verification across platforms

### Manual Testing

Manual testing procedures include:

- Simulated events via `test-dm.bat`/`test-dm.sh`
- Playtest sessions with feedback collection
- Memory leak detection with Valgrind

## Performance Considerations

### Optimization Techniques

The integration employs several optimizations:

1. **Event Filtering**: Only significant events generate narratives
2. **Async Communication**: Non-blocking HTTP requests
3. **Response Caching**: Common narratives are cached
4. **Prioritized Processing**: Critical events take precedence
5. **Deferred Memory Cleanup**: Batch memory management for better performance

### Monitoring

Performance monitoring is built in:

- Event processing times are logged
- Response latency is tracked
- Memory usage is monitored

## Future Improvements

Planned enhancements include:

1. **Websocket Communication**: Replace HTTP with WebSockets for reduced overhead
2. **Advanced Memory Management**: More sophisticated memory bank operations
3. **Enhanced Context Building**: More detailed game state capture
4. **Improved Offline Fallbacks**: Better narrative generation without LLM

---

For playtest and user-facing documentation, see [DM-AI.md](../../DM-AI.md) in the main project directory. 