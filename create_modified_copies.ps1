# Script to create temporary copies of files that need to be modified
$files_to_modify = @(
    ".cursor/rules/readme.mdc",
    ".cursor/rules/purpose.mdc",
    ".cursor/rules/memory/memory-management.mdc",
    ".cursor/rules/memory/knowledge-graph-integration.mdc",
    ".cursor/rules/memory/example-implementation.mdc",
    ".cursor/rules/mcp/tool-usage.mdc",
    ".cursor/rules/mcp/mcp-integration.mdc",
    ".cursor/rules/game/lore-management.mdc",
    ".cursor/rules/game/lore-management-implementation.mdc",
    ".cursor/rules/guides/selfhealing-rules-system.mdc",
    ".cursor/rules/architecture/selfhealing-rules-system.mdc",
    ".cursor/rules/infrastructure/directory_creation.mdc"
)

foreach ($file in $files_to_modify) {
    if (Test-Path $file) {
        $dest = "$file.to_modify"
        Copy-Item -Path $file -Destination $dest
        Write-Host "Created temporary copy: $dest"
        Add-Content -Path "arda_to_brogue_transition.log" -Value "$(Get-Date) - Created temporary copy: $dest"
    } else {
        Write-Host "File not found: $file"
        Add-Content -Path "arda_to_brogue_transition.log" -Value "$(Get-Date) - File not found: $file"
    }
}

# Create necessary directories
$dirs_to_create = @(
    ".cursor/rules/testing"
)

foreach ($dir in $dirs_to_create) {
    if (-Not (Test-Path $dir)) {
        New-Item -Path $dir -ItemType Directory
        Write-Host "Created directory: $dir"
        Add-Content -Path "arda_to_brogue_transition.log" -Value "$(Get-Date) - Created directory: $dir"
    } else {
        Write-Host "Directory already exists: $dir"
    }
}

# Remove Tolkien-specific files
$files_to_remove = @(
    ".cursor/rules/game/angband-variant.mdc",
    ".cursor/rules/game/tolkien-processing.mdc",
    ".cursor/rules/guides/ages-of-arda-documentation-system.mdc",
    ".cursor/rules/guides/ages-of-arda.mdc",
    ".cursor/rules/research/research-protocol.mdc"
)

foreach ($file in $files_to_remove) {
    if (Test-Path $file) {
        Remove-Item -Path $file
        Write-Host "Removed file: $file"
        Add-Content -Path "arda_to_brogue_transition.log" -Value "$(Get-Date) - Removed file: $file"
    } else {
        Write-Host "File not found for removal: $file"
        Add-Content -Path "arda_to_brogue_transition.log" -Value "$(Get-Date) - File not found for removal: $file"
    }
}

Write-Host "Phase 1 Cleanup completed"
Add-Content -Path "arda_to_brogue_transition.log" -Value "$(Get-Date) - Phase 1 Cleanup completed" 