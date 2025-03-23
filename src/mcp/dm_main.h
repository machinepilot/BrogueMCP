/**
 * Dungeon Master Agent Main Functions
 *
 * Provides the main interface for the DM agent integration with Brogue
 */

#ifndef DM_MAIN_H
#define DM_MAIN_H

#include "../brogue/Rogue.h"

// Initialize the DM agent
boolean initialize_dm_agent(void);

// Clean up the DM agent resources
void cleanup_dm_agent(void);

// Handle player keypresses
boolean dm_handle_keypress(int key);

// Called when the player moves
void dm_handle_player_move(short x, short y);

// Called when a monster is seen
void dm_handle_monster_seen(int monsterID, char *monsterName, short x, short y);

// Called when an item is discovered
void dm_handle_item_discovered(int itemID, char *itemName);

#endif /* DM_MAIN_H */ 