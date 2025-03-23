# PowerShell profile for Cursor
# This file is loaded when PowerShell starts in Cursor

# Add MINGW64 to PATH
$env:Path += ";C:\msys2\mingw64\bin"

# Output confirmation
Write-Host "MINGW64 environment added to PATH"

# Optional: Set up aliases for common commands
Set-Alias -Name make -Value mingw32-make

# Display GCC version as verification
try {
    $gccVersion = & gcc --version
    Write-Host "GCC available: $gccVersion"
} catch {
    Write-Host "GCC not found. Check MINGW64 installation."
} 