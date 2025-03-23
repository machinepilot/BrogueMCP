# Ages of Arda - Self-Healing Rules System
# Error Analysis and Rule Generation Script

# Configuration
$ErrorThreshold = 3  # Minimum occurrences to consider a pattern significant
$LookbackDays = 14   # How far back to analyze errors
$OutputDir = ".cursor/rules/self-healing/proposed-rules"
$ErrorDatabasePath = ".cursor/rules/self-healing/error-database.json"

# Ensure necessary directories exist
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
New-Item -ItemType Directory -Force -Path ".cursor/rules/self-healing/patterns" | Out-Null

# Error database initialization or loading
function Initialize-ErrorDatabase {
    if (Test-Path $ErrorDatabasePath) {
        $database = Get-Content $ErrorDatabasePath -Raw | ConvertFrom-Json
    } else {
        $database = @{
            "errors" = @()
            "patterns" = @()
            "last_update" = (Get-Date).ToString("o")
        }
    }
    return $database
}

# Collect compiler errors
function Get-CompilerErrors {
    param($Since)
    
    Write-Host "Collecting compiler errors since $Since..."
    
    # Scan build logs for errors
    $buildLogs = Get-ChildItem -Path "logs/build-*.log" -ErrorAction SilentlyContinue |
                 Where-Object { $_.LastWriteTime -gt $Since }
    
    $errors = @()
    
    foreach ($log in $buildLogs) {
        $content = Get-Content $log -Raw
        
        # Extract C compiler errors - adjust patterns based on your compiler
        $errorMatches = [regex]::Matches($content, '([^:]+):(\d+):(\d+):\s+(warning|error):\s+(.+?)(?=\n)')
        
        foreach ($match in $errorMatches) {
            $errors += @{
                "file_path" = $match.Groups[1].Value
                "line_number" = [int]$match.Groups[2].Value
                "column" = [int]$match.Groups[3].Value
                "type" = $match.Groups[4].Value
                "message" = $match.Groups[5].Value.Trim()
                "source" = "compiler"
                "timestamp" = (Get-Item $log).LastWriteTime.ToString("o")
                "code_snippet" = Get-CodeSnippet -FilePath $match.Groups[1].Value -LineNumber ([int]$match.Groups[2].Value)
            }
        }
    }
    
    return $errors
}

# Collect static analysis errors
function Get-StaticAnalysisResults {
    param($Since)
    
    Write-Host "Collecting static analysis results since $Since..."
    
    # Look for cppcheck, clang-tidy, or other static analyzer outputs
    $analysisLogs = Get-ChildItem -Path "logs/analysis-*.json" -ErrorAction SilentlyContinue |
                    Where-Object { $_.LastWriteTime -gt $Since }
    
    $errors = @()
    
    foreach ($log in $analysisLogs) {
        $content = Get-Content $log -Raw | ConvertFrom-Json
        
        # Format depends on your static analyzer - adjust accordingly
        foreach ($issue in $content.issues) {
            $errors += @{
                "file_path" = $issue.file_path
                "line_number" = $issue.line
                "column" = $issue.column
                "type" = $issue.severity
                "message" = $issue.message
                "source" = "static_analysis"
                "timestamp" = (Get-Item $log).LastWriteTime.ToString("o")
                "code_snippet" = Get-CodeSnippet -FilePath $issue.file_path -LineNumber $issue.line
            }
        }
    }
    
    return $errors
}

# Collect runtime errors
function Get-RuntimeErrors {
    param($Since)
    
    Write-Host "Collecting runtime errors since $Since..."
    
    # Look for application logs with errors
    $runtimeLogs = Get-ChildItem -Path "logs/runtime-*.log" -ErrorAction SilentlyContinue |
                   Where-Object { $_.LastWriteTime -gt $Since }
    
    $errors = @()
    
    foreach ($log in $runtimeLogs) {
        $content = Get-Content $log -Raw
        
        # Extract error patterns - adjust regex based on your log format
        $errorMatches = [regex]::Matches($content, 'ERROR\s+\[([^\]]+)\]\s+([^:]+):(\d+)\s+-\s+(.+?)(?=\n)')
        
        foreach ($match in $errorMatches) {
            $errors += @{
                "file_path" = $match.Groups[2].Value
                "line_number" = [int]$match.Groups[3].Value
                "type" = "runtime_error"
                "message" = $match.Groups[4].Value.Trim()
                "source" = "runtime"
                "timestamp" = $match.Groups[1].Value
                "code_snippet" = Get-CodeSnippet -FilePath $match.Groups[2].Value -LineNumber ([int]$match.Groups[3].Value)
            }
        }
    }
    
    return $errors
}

# Get code snippet for context
function Get-CodeSnippet {
    param(
        [string]$FilePath,
        [int]$LineNumber
    )
    
    if (-not (Test-Path $FilePath)) {
        return "File not found"
    }
    
    try {
        $lines = Get-Content $FilePath -ErrorAction Stop
        $totalLines = $lines.Count
        
        $startLine = [Math]::Max(1, $LineNumber - 2)
        $endLine = [Math]::Min($totalLines, $LineNumber + 2)
        
        $snippet = ""
        for ($i = $startLine; $i -le $endLine; $i++) {
            $prefix = if ($i -eq $LineNumber) { ">> " } else { "   " }
            $snippet += "$prefix$i`: $($lines[$i-1])`n"
        }
        
        return $snippet
    }
    catch {
        return "Error reading file: $_"
    }
}

# Group similar errors
function Group-ErrorsByPattern {
    param($Errors)
    
    Write-Host "Grouping errors by pattern..."
    
    $clusters = @{}
    
    foreach ($error in $Errors) {
        # Create a signature based on error message and type
        # This is a simple approach - more sophisticated methods could be used
        $signatureBase = "$($error.type): $($error.message)"
        $signature = $signatureBase -replace "\d+", "N" # Replace specific numbers with N
        
        if (-not $clusters.ContainsKey($signature)) {
            $clusters[$signature] = @()
        }
        
        $clusters[$signature] += $error
    }
    
    # Convert to array of clusters
    $result = @()
    foreach ($key in $clusters.Keys) {
        $result += @{
            "signature" = $key
            "errors" = $clusters[$key]
            "count" = $clusters[$key].Count
        }
    }
    
    # Sort by frequency
    $result = $result | Sort-Object -Property count -Descending
    
    return $result
}

# Extract pattern from error cluster
function Extract-Pattern {
    param($Cluster)
    
    Write-Host "Extracting pattern from cluster: $($Cluster.signature)"
    
    # Get representative error
    $representativeError = $Cluster.errors[0]
    
    # Extract code context
    $codeContext = $representativeError.code_snippet
    
    # Create pattern object
    $pattern = @{
        "signature" = $Cluster.signature
        "error_type" = $representativeError.type
        "message_pattern" = $representativeError.message -replace "\d+", "N" # Generalize numbers
        "code_pattern" = $codeContext
        "occurrences" = $Cluster.count
        "error_examples" = $Cluster.errors | Select-Object -First 3 # Store a few examples
        "first_seen" = ($Cluster.errors | Sort-Object -Property timestamp | Select-Object -First 1).timestamp
        "last_seen" = ($Cluster.errors | Sort-Object -Property timestamp -Descending | Select-Object -First 1).timestamp
    }
    
    return $pattern
}

# Generate solution for a pattern
function Generate-Solution {
    param($Pattern)
    
    Write-Host "Generating solution for pattern: $($Pattern.signature)"
    
    # This would ideally use AI or predefined solution templates
    # For now, we'll create a simple template
    
    $errorType = $Pattern.error_type
    $messagePattern = $Pattern.message_pattern
    
    # Basic solution templates based on error type
    switch -Wildcard ($errorType) {
        "memory*" {
            $solution = @{
                "type" = "memory_management"
                "description" = "Possible memory management issue: $messagePattern"
                "recommendation" = "Ensure proper memory allocation and deallocation. Check for null pointers before dereferencing."
                "code_example" = "// Check for NULL before use`nif (ptr != NULL) {`n    // Use ptr`n}`n`n// Always free memory when done`nfree(ptr);`nptr = NULL;"
            }
        }
        "*unused*" {
            $solution = @{
                "type" = "unused_variable"
                "description" = "Unused variable detected: $messagePattern"
                "recommendation" = "Remove unused variables or mark them with appropriate annotations."
                "code_example" = "// Either use the variable`nint result = calculate();`nif (result > 0) { /* do something */ }`n`n// Or remove it`n// int unused; // <- Remove this"
            }
        }
        "*format*" {
            $solution = @{
                "type" = "format_string"
                "description" = "Format string issue: $messagePattern"
                "recommendation" = "Ensure format specifiers match argument types. Use appropriate format for each data type."
                "code_example" = "// Correct format specifiers`nprintf(`"%d`", integer_value);  // For int`nprintf(`"%s`", string_value);  // For strings`nprintf(`"%f`", float_value);   // For float`nprintf(`"%zu`", size_t_value); // For size_t"
            }
        }
        default {
            $solution = @{
                "type" = "general"
                "description" = "Issue detected: $messagePattern"
                "recommendation" = "Review code for potential issues related to this error pattern."
                "code_example" = "// No specific example available`n// Consult the C language specification or coding standards"
            }
        }
    }
    
    return $solution
}

# Create rule from pattern and solution
function Create-RuleFromPattern {
    param($Pattern, $Solution)
    
    Write-Host "Creating rule from pattern: $($Pattern.signature)"
    
    # Generate a unique ID for the rule
    $ruleId = "AUTO_" + (New-Guid).ToString().Substring(0, 8)
    
    # Determine appropriate category
    $category = Determine-RuleCategory -Pattern $Pattern
    
    # Create rule content
    $ruleContent = @"
---
title: Auto-Generated Rule: $($Solution.type)
glob: "**/*.c,**/*.h"
priority: 400
auto_generated: true
related: ["../code-style/c-style.mdc"]
---
# Auto-Generated Rule: $($Solution.type)

> **Note**: This rule was automatically generated based on recurring error patterns.

## Issue Description

$($Solution.description)

## Problem Pattern

The following code pattern has been identified as problematic:

```c
$($Pattern.code_pattern)
```

## Recommendation

$($Solution.recommendation)

## Correct Implementation Example

```c
$($Solution.code_example)
```

## Error Statistics

- First observed: $($Pattern.first_seen)
- Last observed: $($Pattern.last_seen)
- Occurrences: $($Pattern.occurrences)
- Error type: $($Pattern.error_type)

## Related Errors

$(($Pattern.error_examples | ForEach-Object { "- $_" }) -join "`n")
"@
    
    # Determine filename
    $ruleName = "$($Solution.type)-$ruleId.mdc"
    $rulePath = Join-Path $OutputDir $ruleName
    
    # Save rule file
    Set-Content -Path $rulePath -Value $ruleContent
    
    return @{
        "id" = $ruleId
        "path" = $rulePath
        "category" = $category
        "type" = $Solution.type
    }
}

# Determine appropriate category for a pattern
function Determine-RuleCategory {
    param($Pattern)
    
    $errorType = $Pattern.error_type
    $message = $Pattern.message_pattern
    
    # Simple categorization logic
    switch -Wildcard ($errorType) {
        "*memory*" { return "memory_management" }
        "*leak*" { return "memory_management" }
        "*null*" { return "memory_management" }
        "*format*" { return "code_style" }
        "*style*" { return "code_style" }
        "*warning*" { 
            switch -Wildcard ($message) {
                "*memory*" { return "memory_management" }
                "*style*" { return "code_style" }
                "*unused*" { return "code_style" }
                default { return "general" }
            }
        }
        default { return "general" }
    }
}

# Update database with new errors
function Update-ErrorDatabase {
    param($Database, $NewErrors, $NewPatterns)
    
    Write-Host "Updating error database..."
    
    # Add new errors
    $Database.errors += $NewErrors
    
    # Add new patterns
    foreach ($pattern in $NewPatterns) {
        # Check if pattern already exists
        $existingPattern = $Database.patterns | Where-Object { $_.signature -eq $pattern.signature }
        
        if ($existingPattern) {
            # Update existing pattern
            $existingPattern.occurrences += $pattern.occurrences
            $existingPattern.last_seen = $pattern.last_seen
            $existingPattern.error_examples += $pattern.error_examples | Select-Object -First 3
            $existingPattern.error_examples = $existingPattern.error_examples | Select-Object -First 5
        } else {
            # Add new pattern
            $Database.patterns += $pattern
        }
    }
    
    # Update timestamp
    $Database.last_update = (Get-Date).ToString("o")
    
    # Save database
    $Database | ConvertTo-Json -Depth 10 | Set-Content -Path $ErrorDatabasePath
    
    return $Database
}

# Propose rule integration
function Propose-RuleAddition {
    param($Rule, $TargetCategory)
    
    Write-Host "Proposing rule addition: $($Rule.id) to category $TargetCategory"
    
    # Create summary of proposed rule
    $summary = @"
# Proposed Rule: $($Rule.id)

A new rule has been automatically generated based on error patterns:

- **Rule ID**: $($Rule.id)
- **Type**: $($Rule.type)
- **Category**: $TargetCategory
- **Rule File**: $($Rule.path)

Please review this rule and decide whether to incorporate it into the main rules system.

## Integration Steps

1. Review the rule content for accuracy
2. If approved, move to appropriate category:
   ```
   Move-Item "$($Rule.path)" ".cursor/rules/$TargetCategory/"
   ```
3. Update any related rules to reference this new rule
4. Run the verification script to ensure proper metadata
   ```
   .cursor/rules/verify-rules.ps1
   ```

## Rejection

If this rule is not appropriate, you can delete it:
```
Remove-Item "$($Rule.path)"
```
"@
    
    # Save summary
    $summaryPath = "$($Rule.path).summary.md"
    Set-Content -Path $summaryPath -Value $summary
    
    Write-Host "Rule proposal created at: $summaryPath"
}

# Main analysis function
function Analyze-CodeErrors {
    param($TimeSpan)
    
    Write-Host "Starting code error analysis..."
    
    # 1. Load or initialize database
    $database = Initialize-ErrorDatabase
    
    # 2. Collect errors from multiple sources
    $compilerErrors = Get-CompilerErrors -Since $TimeSpan
    $staticAnalysisErrors = Get-StaticAnalysisResults -Since $TimeSpan
    $runtimeErrors = Get-RuntimeErrors -Since $TimeSpan
    
    # 3. Merge all errors
    $allErrors = $compilerErrors + $staticAnalysisErrors + $runtimeErrors
    Write-Host "Collected $($allErrors.Count) errors"
    
    # 4. Group errors by pattern
    $errorClusters = Group-ErrorsByPattern -Errors $allErrors
    Write-Host "Identified $($errorClusters.Count) error patterns"
    
    # 5. Process significant patterns
    $processedPatterns = @()
    $generatedRules = @()
    
    foreach ($cluster in $errorClusters) {
        if ($cluster.count -ge $ErrorThreshold) {
            Write-Host "Processing cluster with $($cluster.count) occurrences: $($cluster.signature)"
            
            # Extract pattern
            $pattern = Extract-Pattern -Cluster $cluster
            $processedPatterns += $pattern
            
            # Generate solution
            $solution = Generate-Solution -Pattern $pattern
            
            # Create rule
            $rule = Create-RuleFromPattern -Pattern $pattern -Solution $solution
            $generatedRules += $rule
            
            # Propose rule integration
            Propose-RuleAddition -Rule $rule -TargetCategory (Determine-RuleCategory -Pattern $pattern)
        }
    }
    
    # 6. Update database
    Update-ErrorDatabase -Database $database -NewErrors $allErrors -NewPatterns $processedPatterns
    
    Write-Host "Analysis complete. Generated $($generatedRules.Count) rule proposals."
    return $generatedRules
}

# Execute analysis for the configured lookback period
$lookbackDate = (Get-Date).AddDays(-$LookbackDays)
$generatedRules = Analyze-CodeErrors -TimeSpan $lookbackDate

# Report results
Write-Host "Self-healing analysis complete."
Write-Host "Generated $($generatedRules.Count) rule proposals in $OutputDir"
Write-Host "Review these proposals and incorporate them into the rules system as appropriate." 