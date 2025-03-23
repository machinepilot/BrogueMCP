# Brogue API Changes and Compatibility Notes

This document records the API changes between different versions of Brogue that affect the BrogueMCP integration.

## Structure Field Changes

### Monster (creature) Structure

| Old API | New API | Notes |
|---------|---------|-------|
| `monst->xLoc` | `monst->location.x` | Coordinates now in a substructure |
| `monst->yLoc` | `monst->location.y` | Coordinates now in a substructure |
| `monst->info.level` | No direct equivalent | Use `monst->info.maxHP / 10` as a proxy for monster power |
| `monst->info.flags & MONST_RARE` | `monst->info.flags & MONST_PREPLACED` | Flag for rare monsters changed |

### Item Structure

| Old API | New API | Notes |
|---------|---------|-------|
| `theItem->name` | No direct field access | Use `itemName(theItem, buffer, true, false, NULL)` |
| `theItem->flags & ITEM_RARE` | `theItem->flags & (ITEM_RUNIC \| ITEM_NAMED)` | Flag for rare items changed |

## Function Signature Changes

### Message Function

| Old API | New API | Notes |
|---------|---------|-------|
| `message(char *msg)` | `message(const char *msg, boolean requireAck)` | Added parameter and made string const |

### Global State Access

| Old API | New API | Notes |
|---------|---------|-------|
| `rogue.turnCount` | Not directly exposed | Need to find alternative or use placeholder |

## Implementation Strategy

We've created a compatibility layer in `mcp_compat.h` that handles these differences through macros and inline functions:

```c
// Example macros:
#ifdef BROGUE_CURRENT
    #define MCP_LOC_X(monst) ((monst)->location.x)
#else
    #define MCP_LOC_X(monst) ((monst)->xLoc)
#endif
```

This allows the BrogueMCP code to work with different Brogue API versions by using the compatibility macros instead of direct structure access.

## Building with Different Brogue Versions

To force a specific API version interpretation, define one of these before including the compatibility header:

```c
#define USE_CURRENT_API   // Force modern API interpretation
#define BROGUE_1_7_4      // Force legacy API interpretation
```

If neither is defined, the system will attempt to auto-detect based on the presence of structure definitions.

## Outstanding Issues

1. **Turn Count**: We currently don't have a reliable way to access the game's turn count in newer API versions.
2. **Monster Rarity**: The `MONST_PREPLACED` flag is not an exact match for the old `MONST_RARE` flag.
3. **Function Hooking**: The message function hooking needs a better implementation for full integration.

## Next Steps

1. Examine newer Brogue source to find the correct turn count field
2. Refine monster rarity detection for better compatibility 
3. Implement proper function hooking that works with both API versions 