# Ages of Arda - Self-Healing Rules Integration Script
# This script helps integrate proposed rules into the main rules system

# Configuration
$ProposedRulesDir = Join-Path $PSScriptRoot "proposed-rules"
$RulesBaseDir = Join-Path $PSScriptRoot ".."

# Check if there are any proposed rules
function Get-ProposedRules {
    $proposals = Get-ChildItem -Path $ProposedRulesDir -Filter "*.mdc" -ErrorAction SilentlyContinue
    return $proposals
}

# Show summary of a rule
function Show-RuleSummary {
    param($Rule)
    
    $summaryPath = "$($Rule.FullName).summary.md"
    if (Test-Path $summaryPath) {
        Write-Host "`n$(Get-Content $summaryPath -Raw)"
    } else {
        # Extract basic info from the rule itself
        $content = Get-Content $Rule.FullName -Raw
        
        # Extract title from frontmatter
        if ($content -match 'title:\s*(.+?)[\r\n]') {
            $title = $matches[1]
        } else {
            $title = $Rule.Name
        }
        
        # Extract glob from frontmatter
        if ($content -match 'glob:\s*"(.+?)"') {
            $glob = $matches[1]
        } else {
            $glob = "**/*.c,**/*.h"
        }
        
        Write-Host "`n# Rule: $title"
        Write-Host "`nFile: $($Rule.Name)"
        Write-Host "Applies to: $glob"
    }
}

# Prompt for category selection
function Get-CategorySelection {
    Write-Host "`nSelect destination category:"
    Write-Host "1. code-style"
    Write-Host "2. game"
    Write-Host "3. ai"
    Write-Host "4. infrastructure"
    Write-Host "5. mcp"
    Write-Host "6. activators"
    Write-Host "7. [New category]"
    
    $selection = Read-Host "Enter selection (1-7)"
    
    switch ($selection) {
        "1" { return "code-style" }
        "2" { return "game" }
        "3" { return "ai" }
        "4" { return "infrastructure" }
        "5" { return "mcp" }
        "6" { return "activators" }
        "7" { 
            $newCategory = Read-Host "Enter new category name"
            if (-not (Test-Path (Join-Path $RulesBaseDir $newCategory))) {
                New-Item -ItemType Directory -Path (Join-Path $RulesBaseDir $newCategory) -Force | Out-Null
            }
            return $newCategory
        }
        default { return "game" }
    }
}

# Integrate a rule
function Integrate-Rule {
    param($Rule)
    
    # Show the rule summary
    Show-RuleSummary -Rule $Rule
    
    # Ask for confirmation
    $confirm = Read-Host "`nIntegrate this rule? (Y/N/E - yes/no/edit)"
    
    if ($confirm -eq "E" -or $confirm -eq "e") {
        # Open the file for editing
        Write-Host "Opening rule for editing..."
        notepad $Rule.FullName
        
        # Ask again after editing
        $confirm = Read-Host "Integrate this rule now? (Y/N)"
    }
    
    if ($confirm -eq "Y" -or $confirm -eq "y") {
        # Get destination category
        $category = Get-CategorySelection
        $destDir = Join-Path $RulesBaseDir $category
        
        # Ensure destination exists
        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        
        # Copy the rule to destination
        $destPath = Join-Path $destDir $Rule.Name
        Copy-Item -Path $Rule.FullName -Destination $destPath -Force
        
        # Ask if we should also update references
        $updateRefs = Read-Host "Update references in README.mdc? (Y/N)"
        
        if ($updateRefs -eq "Y" -or $updateRefs -eq "y") {
            Update-References -Rule $Rule -Category $category
        }
        
        # Verify the rule
        $verifyScript = Join-Path $RulesBaseDir "verify-rules.ps1"
        if (Test-Path $verifyScript) {
            & $verifyScript
        }
        
        # Ask if we should clean up the proposal
        $cleanup = Read-Host "Remove proposal files? (Y/N)"
        
        if ($cleanup -eq "Y" -or $cleanup -eq "y") {
            Remove-Item -Path $Rule.FullName -Force
            
            $summaryPath = "$($Rule.FullName).summary.md"
            if (Test-Path $summaryPath) {
                Remove-Item -Path $summaryPath -Force
            }
        }
        
        Write-Host "Rule integrated successfully!"
    } else {
        Write-Host "Integration skipped."
    }
}

# Update references in README
function Update-References {
    param($Rule, $Category)
    
    $readmePath = Join-Path $RulesBaseDir "README.mdc"
    
    if (Test-Path $readmePath) {
        $content = Get-Content $readmePath -Raw
        
        # Extract title from rule
        $ruleContent = Get-Content $Rule.FullName -Raw
        if ($ruleContent -match 'title:\s*(.+?)[\r\n]') {
            $title = $matches[1]
        } else {
            $title = $Rule.BaseName
        }
        
        # Find the directory structure section
        if ($content -match '```[\r\n]+\.cursor/rules/') {
            # Add the rule to the directory structure
            $dirStructure = $content -match '```[\r\n]+\.cursor/rules/.*?```'
            $newStructure = $dirStructure -replace "└── $Category/", "└── $Category/`n    ├── $($Rule.Name)    # $title"
            $content = $content -replace $dirStructure, $newStructure
            Set-Content -Path $readmePath -Value $content
            
            Write-Host "Updated README.mdc with new rule reference."
        } else {
            Write-Host "Could not find directory structure in README.mdc. No changes made."
        }
    } else {
        Write-Host "README.mdc not found. No changes made."
    }
}

# Main execution
Write-Host "Ages of Arda - Self-Healing Rules Integration"
Write-Host "--------------------------------------------"
Write-Host "This script helps integrate automatically generated rules into your main rules system."

$rules = Get-ProposedRules

if ($rules.Count -eq 0) {
    Write-Host "`nNo proposed rules found in $ProposedRulesDir"
    exit
}

Write-Host "`nFound $($rules.Count) proposed rules:"

for ($i = 0; $i -lt $rules.Count; $i++) {
    Write-Host "$($i + 1). $($rules[$i].Name)"
}

$option = Read-Host "`nSelect rule to integrate (1-$($rules.Count)) or 'all' for all rules"

if ($option -eq "all") {
    foreach ($rule in $rules) {
        Integrate-Rule -Rule $rule
    }
} else {
    $index = [int]$option - 1
    if ($index -ge 0 -and $index -lt $rules.Count) {
        Integrate-Rule -Rule $rules[$index]
    } else {
        Write-Host "Invalid selection. Exiting."
    }
}

Write-Host "`nIntegration process complete!" 