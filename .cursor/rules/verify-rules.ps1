# Cursor Rules Verification Script
# This script checks that all rules have proper metadata

$directories = @(
    ".cursor/rules",
    ".cursor/rules/ai",
    ".cursor/rules/code-style",
    ".cursor/rules/game",
    ".cursor/rules/infrastructure",
    ".cursor/rules/mcp",
    ".cursor/rules/activators"
)

$issues = @()

foreach ($dir in $directories) {
    $files = Get-ChildItem -Path $dir -Filter "*.mdc" -Recurse
    
    foreach ($file in $files) {
        Write-Host "Checking file: $($file.FullName)"
        
        # Read file content
        $content = Get-Content -Path $file.FullName -Raw
        
        # Check for required metadata
        $hasFrontmatter = $content -match "---\s*[\r\n]+"
        $hasTitle = $content -match "title:"
        $hasGlob = $content -match "glob:"
        $hasPriority = $content -match "priority:"
        
        # Skip README.mdc in root directory
        if ($file.Name -eq "README.mdc" -and $file.DirectoryName -eq ".cursor\rules") {
            continue
        }
        
        # Record issues
        if (-not $hasFrontmatter) {
            $issues += "Missing frontmatter: $($file.FullName)"
        }
        if (-not $hasTitle) {
            $issues += "Missing title: $($file.FullName)"
        }
        if (-not $hasGlob) {
            $issues += "Missing glob: $($file.FullName)"
        }
        if (-not $hasPriority) {
            $issues += "Missing priority: $($file.FullName)"
        }
    }
}

# Display issues
if ($issues.Count -gt 0) {
    Write-Host "Found $($issues.Count) issues:"
    foreach ($issue in $issues) {
        Write-Host "  - $issue"
    }
} else {
    Write-Host "All rules files have correct metadata!"
}

# Check for related path issues
Write-Host "`nChecking related paths..."
$relatedIssues = @()

foreach ($dir in $directories) {
    $files = Get-ChildItem -Path $dir -Filter "*.mdc" -Recurse
    
    foreach ($file in $files) {
        $content = Get-Content -Path $file.FullName -Raw
        
        # Extract related paths
        if ($content -match 'related:\s*\[(.*?)\]') {
            $relatedSection = $matches[1]
            
            # Extract individual paths
            $relatedPaths = $relatedSection -split ',' | ForEach-Object { $_ -replace '"', '' -replace "'", '' -replace ' ', '' }
            
            foreach ($path in $relatedPaths) {
                if ($path -ne '') {
                    # Construct the absolute path based on file location
                    $basePath = Split-Path -Parent $file.FullName
                    $fullPath = Join-Path $basePath $path
                    $fullPath = [System.IO.Path]::GetFullPath($fullPath)
                    
                    if (-not (Test-Path $fullPath)) {
                        $relatedIssues += "Invalid related path in $($file.Name): $path"
                    }
                }
            }
        }
    }
}

# Display related path issues
if ($relatedIssues.Count -gt 0) {
    Write-Host "Found $($relatedIssues.Count) issues with related paths:"
    foreach ($issue in $relatedIssues) {
        Write-Host "  - $issue"
    }
} else {
    Write-Host "All related paths are valid!"
}

Write-Host "`nVerification complete!" 