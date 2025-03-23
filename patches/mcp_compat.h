/**
 * MCP Compatibility Adapter Layer
 * 
 * This file provides macros and functions to handle API differences between
 * Brogue versions. It allows the MCP module to work with both older and
 * newer versions of the Brogue API.
 */

#ifndef MCP_COMPAT_H
#define MCP_COMPAT_H

#include <string.h>

// Detect API version based on structure definitions
#if defined(USE_CURRENT_API)
    #define BROGUE_CURRENT
#elif defined(BROGUE_1_7_4)
    #define BROGUE_LEGACY
#else
    // Auto-detect based on Brogue version
    #include "../brogue/Rogue.h"
    #if BROGUE_MAJOR > 1 || (BROGUE_MAJOR == 1 && BROGUE_MINOR >= 10)
        #define BROGUE_CURRENT
    #else
        #define BROGUE_LEGACY
    #endif
#endif

// Define missing constants
#ifdef BROGUE_CURRENT
    // Define legacy constants that don't exist in current version
    #ifndef MONST_RARE
        #define MONST_RARE MONST_PREPLACED
    #endif
    #ifndef MONST_RARE_MONSTER
        #define MONST_RARE_MONSTER MONST_PREPLACED
    #endif
    #ifndef ITEM_RARE
        #define ITEM_RARE (ITEM_RUNIC | ITEM_NAMED)
    #endif
#else
    // Legacy mode - make sure these are defined
    #ifndef MONST_RARE
        #define MONST_RARE 0x00100000
    #endif
    #ifndef MONST_RARE_MONSTER
        #define MONST_RARE_MONSTER MONST_RARE
    #endif
    #ifndef ITEM_RARE
        #define ITEM_RARE 0x00000400
    #endif
#endif

// Monster location access compatibility
#ifdef BROGUE_CURRENT
    #define MCP_LOC_X(monst) ((monst)->location.x)
    #define MCP_LOC_Y(monst) ((monst)->location.y)
#else
    #define MCP_LOC_X(monst) ((monst)->xLoc)
    #define MCP_LOC_Y(monst) ((monst)->yLoc)
#endif

// Monster level/power compatibility
#ifdef BROGUE_CURRENT
    // In newer versions, there's no direct level value, so we use maxHP or monsterID as a proxy
    #define MCP_MONSTER_LEVEL(monst) ((monst)->info.monsterID)
#else
    #define MCP_MONSTER_LEVEL(monst) ((monst)->info.level)
#endif

// Monster rarity compatibility
#define MCP_IS_MONSTER_RARE(monst) (((monst)->info.flags & MONST_RARE) ? "true" : "false")

// Item name compatibility
#ifdef BROGUE_CURRENT
    static inline void mcp_get_item_name(item *theItem, char *buffer, int bufsize) {
        itemName(theItem, buffer, true, false, NULL);
        buffer[bufsize-1] = '\0'; // Ensure null termination
    }
#else
    static inline void mcp_get_item_name(item *theItem, char *buffer, int bufsize) {
        // Check if the name field exists on the item structure
        #ifdef LEGACY_ITEM_NAME
            strncpy(buffer, theItem->name, bufsize - 1);
        #else
            // Fallback if no direct name field - use a placeholder or other method
            strcpy(buffer, "Unknown Item");
        #endif
        buffer[bufsize-1] = '\0'; // Ensure null termination
    }
#endif

// Item rarity compatibility
#define MCP_IS_ITEM_RARE(item) (((item)->flags & ITEM_RARE) ? "true" : "false")

// Global state access - turn count
#ifdef BROGUE_CURRENT
    // Many newer versions use playerTurnNumber instead of turnCount
    #define MCP_TURN_COUNT (rogue.playerTurnNumber)
#else
    #define MCP_TURN_COUNT (rogue.turnCount)
#endif

// Message function compatibility
#ifdef BROGUE_CURRENT
    // In newer versions, the message function takes a const char* and flags
    #define MCP_DISPLAY_MESSAGE(msg) message((msg), 0)
#else
    #define MCP_DISPLAY_MESSAGE(msg) message((msg))
#endif

#endif // MCP_COMPAT_H 