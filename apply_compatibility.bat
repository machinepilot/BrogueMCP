@echo off
REM Apply compatibility patch and test build

echo Creating compatibility layer...
echo =============================

REM Backup original files if not already backed up
if not exist src\mcp\event_hooks.c.bak (
  echo Creating backups of original files...
  copy /Y src\mcp\event_hooks.c src\mcp\event_hooks.c.bak
  copy /Y src\mcp\event_hooks.h src\mcp\event_hooks.h.bak
)

REM Copy patched files
echo Applying compatibility patches...
copy /Y patches\mcp_compat.h src\mcp\mcp_compat.h
copy /Y patches\event_hooks.c src\mcp\event_hooks.c

echo.
echo Patches applied!
echo.
echo To build, run:
echo   make clean GRAPHICS=NO TERMINAL=YES bin/brogue.exe
echo.
echo To test the standalone compatibility layer:
echo   cd test
echo   ./build_standalone.bat
echo. 