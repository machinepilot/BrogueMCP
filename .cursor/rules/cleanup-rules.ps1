# Cursor Rules Cleanup Script
# This script cleans up duplicate rules files and standardizes frontmatter

# 1. Remove duplicate files from the root directory
$filesToRemove = @(
    ".cursor/rules/memory-bank.mdc",
    ".cursor/rules/multi-agent.mdc",
    ".cursor/rules/html.mdc",
    ".cursor/rules/mcp-server.mdc",
    ".cursor/rules/mcp_server.mdc",
    ".cursor/rules/netlify.mdc"
)

foreach ($file in $filesToRemove) {
    if (Test-Path $file) {
        Write-Host "Removing duplicate file: $file"
        Remove-Item $file -Force
    }
}

# 2. Fix frontmatter in all .mdc files
$directories = @(
    ".cursor/rules/ai",
    ".cursor/rules/code-style",
    ".cursor/rules/game",
    ".cursor/rules/infrastructure",
    ".cursor/rules/mcp",
    ".cursor/rules/activators"
)

foreach ($dir in $directories) {
    $files = Get-ChildItem -Path $dir -Filter "*.mdc" -Recurse
    
    foreach ($file in $files) {
        Write-Host "Processing file: $($file.FullName)"
        
        # Read file content
        $content = Get-Content -Path $file.FullName -Raw
        
        # Check if file has duplicate frontmatter
        if ($content -match "---\s*[\r\n]+.*?[\r\n]+---\s*[\r\n]+---") {
            Write-Host "  Fixing duplicate frontmatter"
            
            # Replace old frontmatter pattern with just the new one
            $newContent = $content -replace "---\s*[\r\n]+description:.*?[\r\n]+globs:.*?[\r\n]+alwaysApply:.*?[\r\n]+---\s*[\r\n]+", ""
            
            # Save the updated content
            Set-Content -Path $file.FullName -Value $newContent
        }
    }
}

Write-Host "Cleanup complete!" 