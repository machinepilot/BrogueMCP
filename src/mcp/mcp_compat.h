/**
 * MCP Compatibility Adapter Layer - Simplified Version
 */

#ifndef MCP_COMPAT_H
#define MCP_COMPAT_H

#include <string.h>

// Define basic field access macros that match your Brogue version
// Based on the errors, we determined your Brogue uses the modern API

// Monster location access
#define MCP_LOC_X(monst) ((monst)->location.x)
#define MCP_LOC_Y(monst) ((monst)->location.y)

// Monster level (using monsterID as a fallback)
#define MCP_MONSTER_LEVEL(monst) ((monst)->info.monsterID)

// Monster rarity (using an existing Brogue flag)
#define MCP_IS_MONSTER_RARE(monst) (((monst)->info.flags & MONST_PREPLACED) ? "true" : "false")

// Item name helper function
static inline void mcp_get_item_name(item *theItem, char *buffer, int bufsize) {
    // Using the itemName function that exists in Brogue
    itemName(theItem, buffer, true, false, NULL);
    buffer[bufsize-1] = '\0'; // Ensure null termination
}

// Item rarity 
#define MCP_IS_ITEM_RARE(item) (((item)->flags & (ITEM_RUNIC | ITEM_NAMED)) ? "true" : "false")

// Turn count (using playerTurnNumber)
#define MCP_TURN_COUNT (rogue.playerTurnNumber)

// Message display function
#define MCP_DISPLAY_MESSAGE(msg) message((msg), 0)

#endif // MCP_COMPAT_H 