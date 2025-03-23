# Cursor initialization script
# This script runs during Cursor startup to verify required directories

Write-Output "Running Ages of Arda initialization checks..."

# Run the directory verification script
$scriptPath = Join-Path $PSScriptRoot "verify_directories.ps1"
if (Test-Path $scriptPath) {
    Write-Output "Verifying required directories..."
    & $scriptPath
    if ($LASTEXITCODE -ne 0) {
        Write-Output "WARNING: Directory verification failed. Some features may not work correctly."
    }
} else {
    Write-Output "ERROR: Directory verification script not found at $scriptPath"
}

# Add other initialization checks here as needed

Write-Output "Initialization checks completed." 