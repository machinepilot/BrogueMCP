# verify_directories.ps1
# This script verifies that all required directories exist and creates them if they don't.
# Part of the Ages of Arda project's directory creation rules

# Define required directories
$requiredDirs = @(
    "processing/temp",
    "processing/output",
    "processing/logs",
    "processing/epub_content",
    "processing/json_output",
    "processing/schemas",
    "processing/checkpoints",
    "processing/consolidated"
)

# Track results
$existingCount = 0
$createdCount = 0
$failedCount = 0

Write-Host "Verifying required directories..."

# Check and create each directory
foreach ($dir in $requiredDirs) {
    if (Test-Path $dir) {
        Write-Host "[VERIFY] Directory exists: $dir"
        $existingCount++
    } else {
        try {
            New-Item -Path $dir -ItemType Directory -Force | Out-Null
            Write-Host "[CREATE] Created directory: $dir"
            $createdCount++
        } catch {
            Write-Host "[ERROR] Failed to create directory: $dir - $_"
            $failedCount++
        }
    }
}

# Report summary
Write-Host "`nDirectory Verification Summary:"
Write-Host "------------------------------"
Write-Host "Directories already existing: $existingCount"
Write-Host "Directories created: $createdCount"
Write-Host "Directories failed: $failedCount"

# If any directories failed to create, exit with error code
if ($failedCount -gt 0) {
    Write-Host "ERROR: Failed to create some required directories."
    Write-Host "Please check permissions and try again."
    exit 1
}

Write-Host "Directory verification completed successfully."
exit 0 