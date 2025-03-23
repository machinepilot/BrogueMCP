#!/bin/bash
# Apply compatibility patch and test build

echo "Creating compatibility layer..."
echo "============================="

# Backup original files if not already backed up
if [ ! -f src/mcp/event_hooks.c.bak ]; then
  echo "Creating backups of original files..."
  cp -f src/mcp/event_hooks.c src/mcp/event_hooks.c.bak
  cp -f src/mcp/event_hooks.h src/mcp/event_hooks.h.bak
fi

# Copy patched files
echo "Applying compatibility patches..."
cp -f patches/mcp_compat.h src/mcp/mcp_compat.h
cp -f patches/event_hooks.c src/mcp/event_hooks.c

echo 
echo "Patches applied!"
echo
echo "To build, run:"
echo "  make clean"
echo "  make GRAPHICS=NO TERMINAL=YES bin/brogue"
echo
echo "To test the standalone compatibility layer:"
echo "  cd test"
echo "  ./build_standalone.sh" 