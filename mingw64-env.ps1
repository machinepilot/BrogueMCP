# MINGW64 Environment Setup for Brogue Project
# Run this script before working with the compiler tools

# Add MINGW64 to PATH
$env:Path += ";C:\msys2\mingw64\bin"

# Verify environment
Write-Host "MINGW64 environment loaded"
Write-Host "---------------------------"

# List available compilers
Write-Host "Available tools:"
if (Get-Command gcc -ErrorAction SilentlyContinue) {
    Write-Host "gcc: $(& gcc --version | Select-Object -First 1)"
}
if (Get-Command g++ -ErrorAction SilentlyContinue) {
    Write-Host "g++: $(& g++ --version | Select-Object -First 1)"
}
if (Get-Command make -ErrorAction SilentlyContinue) {
    Write-Host "make: $(& make --version | Select-Object -First 1)"
}

Write-Host "`nEnvironment ready for BrogueMCP development" 