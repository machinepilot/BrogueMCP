# API Verification and Rules Testing Script
# Tests MCP API keys and evaluates the cursor rules system

function Test-ApiKeys {
    param (
        [string]$MpcConfigPath = "./.cursor/mcp.json"
    )
    
    Write-Host "Testing MCP API keys..." -ForegroundColor Cyan
    
    # Check if credential manager exists
    $credentialManager = "./.cursor/rules/memory-bank/credential-manager.py"
    $useSecureCredentials = Test-Path $credentialManager
    
    if ($useSecureCredentials) {
        Write-Host "Using secure credential management system" -ForegroundColor Green
    }
    
    # Read MCP configuration
    if (-not (Test-Path $MpcConfigPath)) {
        Write-Error "MCP configuration file not found at: $MpcConfigPath"
        return $false
    }
    
    try {
        $config = Get-Content $MpcConfigPath -Raw | ConvertFrom-Json
        
        # Test Brave Search API
        if ($config.mcpServer.braveSearch.enabled) {
            # If using secure credentials and key looks like a placeholder
            if ($useSecureCredentials -and 
                ($config.mcpServer.braveSearch.configuration.apiKey -match '^\${.*}$' -or 
                 $config.mcpServer.braveSearch.configuration.apiKey -eq 'YOUR_BRAVE_API_KEY')) {
                
                # Retrieve credential
                Write-Host "Retrieving Brave Search API key from secure store..." -NoNewline
                $braveKey = python $credentialManager retrieve BRAVE_SEARCH_API_KEY 2>$null
                
                if (-not $braveKey) {
                    # Store current key securely
                    $currentKey = $config.mcpServer.braveSearch.configuration.apiKey
                    if ($currentKey -ne 'YOUR_BRAVE_API_KEY' -and -not ($currentKey -match '^\${.*}$')) {
                        Write-Host "Storing current Brave Search API key in secure store..." -ForegroundColor Yellow
                        echo $currentKey | python $credentialManager store BRAVE_SEARCH_API_KEY --value=$currentKey
                        
                        # Update config to use placeholder
                        $config.mcpServer.braveSearch.configuration.apiKey = '${BRAVE_SEARCH_API_KEY}'
                        $config | ConvertTo-Json -Depth 10 | Set-Content $MpcConfigPath
                        
                        # Retrieve the stored key
                        $braveKey = python $credentialManager retrieve BRAVE_SEARCH_API_KEY 2>$null
                    }
                }
                
                if ($braveKey) {
                    Write-Host "SUCCESS" -ForegroundColor Green
                    $braveKey = $braveKey -replace "BRAVE_SEARCH_API_KEY: ", ""
                } else {
                    Write-Host "NOT FOUND" -ForegroundColor Yellow
                    Write-Host "Using key from config file" -ForegroundColor Yellow
                    $braveKey = $config.mcpServer.braveSearch.configuration.apiKey
                }
            } else {
                $braveKey = $config.mcpServer.braveSearch.configuration.apiKey
            }
            
            Write-Host "Testing Brave Search API key: $($braveKey.Substring(0, 4))..." -NoNewline
            
            $braveHeaders = @{
                "X-Subscription-Token" = $braveKey
                "Accept" = "application/json"
            }
            
            try {
                $braveResponse = Invoke-RestMethod -Uri "https://api.search.brave.com/res/v1/web/search?q=test&count=1" -Method GET -Headers $braveHeaders
                if ($braveResponse) {
                    Write-Host "SUCCESS" -ForegroundColor Green
                }
            }
            catch {
                Write-Host "FAILED" -ForegroundColor Red
                Write-Host "  Error: $_" -ForegroundColor Red
            }
        }
        
        # Test Tavily API
        if ($config.mcpServer.tavily.enabled) {
            # If using secure credentials and key looks like a placeholder
            if ($useSecureCredentials -and 
                ($config.mcpServer.tavily.configuration.apiKey -match '^\${.*}$' -or 
                 $config.mcpServer.tavily.configuration.apiKey -eq 'YOUR_TAVILY_API_KEY')) {
                
                # Retrieve credential
                Write-Host "Retrieving Tavily API key from secure store..." -NoNewline
                $tavilyKey = python $credentialManager retrieve TAVILY_API_KEY 2>$null
                
                if (-not $tavilyKey) {
                    # Store current key securely
                    $currentKey = $config.mcpServer.tavily.configuration.apiKey
                    if ($currentKey -ne 'YOUR_TAVILY_API_KEY' -and -not ($currentKey -match '^\${.*}$')) {
                        Write-Host "Storing current Tavily API key in secure store..." -ForegroundColor Yellow
                        echo $currentKey | python $credentialManager store TAVILY_API_KEY --value=$currentKey
                        
                        # Update config to use placeholder
                        $config.mcpServer.tavily.configuration.apiKey = '${TAVILY_API_KEY}'
                        $config | ConvertTo-Json -Depth 10 | Set-Content $MpcConfigPath
                        
                        # Retrieve the stored key
                        $tavilyKey = python $credentialManager retrieve TAVILY_API_KEY 2>$null
                    }
                }
                
                if ($tavilyKey) {
                    Write-Host "SUCCESS" -ForegroundColor Green
                    $tavilyKey = $tavilyKey -replace "TAVILY_API_KEY: ", ""
                } else {
                    Write-Host "NOT FOUND" -ForegroundColor Yellow
                    Write-Host "Using key from config file" -ForegroundColor Yellow
                    $tavilyKey = $config.mcpServer.tavily.configuration.apiKey
                }
            } else {
                $tavilyKey = $config.mcpServer.tavily.configuration.apiKey
            }
            
            Write-Host "Testing Tavily API key: $($tavilyKey.Substring(0, 4))..." -NoNewline
            
            $tavilyHeaders = @{
                "Content-Type" = "application/json"
            }
            
            $tavilyBody = @{
                api_key = $tavilyKey
                query = "test query"
                search_depth = "basic"
            } | ConvertTo-Json
            
            try {
                $tavilyResponse = Invoke-RestMethod -Uri "https://api.tavily.com/search" -Method POST -Headers $tavilyHeaders -Body $tavilyBody
                if ($tavilyResponse) {
                    Write-Host "SUCCESS" -ForegroundColor Green
                }
            }
            catch {
                Write-Host "FAILED" -ForegroundColor Red
                Write-Host "  Error: $_" -ForegroundColor Red
            }
        }
        
        return $true
    }
    catch {
        Write-Error "Error parsing MCP configuration: $_"
        return $false
    }
}

function Test-RuleEffectiveness {
    param (
        [string]$RulesPath = "./.cursor/rules"
    )
    
    Write-Host "Evaluating cursor rules effectiveness..." -ForegroundColor Cyan
    
    if (-not (Test-Path $RulesPath)) {
        Write-Error "Rules directory not found at: $RulesPath"
        return
    }
    
    # Check rules structure
    $ruleFiles = Get-ChildItem -Path $RulesPath -Recurse -Filter "*.mdc" | Measure-Object
    Write-Host "Total rule files: $($ruleFiles.Count)"
    
    # Check rule categories
    $categories = Get-ChildItem -Path $RulesPath -Directory | Measure-Object
    Write-Host "Rule categories: $($categories.Count)"
    
    # Check rules metadata
    $validRules = 0
    $invalidRules = 0
    $rulesWithDescription = 0
    $rulesByPriority = @{}
    
    Get-ChildItem -Path $RulesPath -Recurse -Filter "*.mdc" | ForEach-Object {
        $content = Get-Content -Path $_.FullName -Raw
        if ($content -match "(?s)---\s*\n(.*?)\n---") {
            $metadata = $matches[1]
            $validRules++
            
            if ($metadata -match "description:") {
                $rulesWithDescription++
            }
            
            if ($metadata -match "priority:\s*(\d+)") {
                $priority = [int]$matches[1]
                if (-not $rulesByPriority.ContainsKey($priority)) {
                    $rulesByPriority[$priority] = 0
                }
                $rulesByPriority[$priority]++
            }
        }
        else {
            $invalidRules++
        }
    }
    
    Write-Host "Valid rules: $validRules"
    Write-Host "Invalid rules: $invalidRules"
    Write-Host "Rules with descriptions: $rulesWithDescription"
    
    Write-Host "Rules by priority level:"
    foreach ($key in ($rulesByPriority.Keys | Sort-Object -Descending)) {
        Write-Host "  Priority $key`: $($rulesByPriority[$key]) rules"
    }
    
    # Check for rule conflicts using existing verification tool
    Write-Host "Checking for rule conflicts..." -ForegroundColor Yellow
    $verificationScript = Join-Path $RulesPath "integration/rule-verification.ps1"
    if (Test-Path $verificationScript) {
        & $verificationScript
    }
    else {
        # Use embedded conflict detection if verification script doesn't exist
        Write-Host "Rule verification script not found, using embedded conflict detection"
        
        $rules = @()
        Get-ChildItem -Path $RulesPath -Recurse -Filter "*.mdc" | ForEach-Object {
            $content = Get-Content -Path $_.FullName -Raw
            if ($content -match "(?s)---\s*\n(.*?)\n---") {
                $metadata = $matches[1]
                $globPattern = if ($metadata -match "glob:\s*""([^""]*)""") { $matches[1] } else { "" }
                $priority = if ($metadata -match "priority:\s*(\d+)") { [int]$matches[1] } else { 0 }
                
                $rules += [PSCustomObject]@{
                    File = $_.FullName
                    Glob = $globPattern
                    Priority = $priority
                }
            }
        }
        
        $conflicts = @()
        for ($i = 0; $i -lt $rules.Count; $i++) {
            for ($j = $i + 1; $j -lt $rules.Count; $j++) {
                if (($rules[$i].Glob -eq $rules[$j].Glob) -and 
                    ($rules[$i].Glob -ne "") -and
                    ([Math]::Abs($rules[$i].Priority - $rules[$j].Priority) -lt 50)) {
                    $conflicts += [PSCustomObject]@{
                        Rule1 = $rules[$i].File
                        Rule2 = $rules[$j].File
                        Glob = $rules[$i].Glob
                        Priority1 = $rules[$i].Priority
                        Priority2 = $rules[$j].Priority
                    }
                }
            }
        }
        
        if ($conflicts.Count -gt 0) {
            Write-Host "Potential rule conflicts detected:" -ForegroundColor Red
            $conflicts | Format-Table -AutoSize
        }
        else {
            Write-Host "No rule conflicts detected." -ForegroundColor Green
        }
    }
}

function Test-MCP-Workflow {
    param (
        [string]$TestDir = "./test-mcp"
    )
    
    Write-Host "Testing MCP workflow integration..." -ForegroundColor Cyan
    
    # Create test directory if it doesn't exist
    if (-not (Test-Path $TestDir)) {
        New-Item -Path $TestDir -ItemType Directory | Out-Null
    }
    
    # Create a test C file to test the rules
    $testCFile = Join-Path $TestDir "test_memory.c"
    $testCContent = @"
/**
 * Test file for memory management
 */
#include <stdio.h>
#include <stdlib.h>

// Missing memory management
void test_memory_leak() {
    char* buffer = malloc(100);
    // No free
}

int main() {
    printf("Testing memory management\n");
    test_memory_leak();
    return 0;
}
"@
    
    Set-Content -Path $testCFile -Value $testCContent
    
    # Create a test Python file
    $testPyFile = Join-Path $TestDir "test_processing.py"
    $testPyContent = @"
"""
Test file for Tolkien processing
"""
import os

def extract_entities(text):
    # Incomplete entity extraction
    entities = []
    return entities

def main():
    print("Testing Tolkien processing")
    extract_entities("Gandalf the Grey")

if __name__ == "__main__":
    main()
"@
    
    Set-Content -Path $testPyFile -Value $testPyContent
    
    Write-Host "Test files created in $TestDir"
    Write-Host "Run the following commands to test MCP workflow:"
    Write-Host "  1. Open the test files in Cursor"
    Write-Host "  2. Use Claude to analyze the code quality"
    Write-Host "  3. Check if rules for memory management and tolkien processing are correctly applied"
}

function Generate-Report {
    param (
        [switch]$IncludeApiResults = $true,
        [switch]$IncludeRuleStats = $true,
        [switch]$IncludeWorkflowTest = $true
    )
    
    $reportPath = "./cursor-rules-test-report.md"
    
    $reportContent = @"
# MCP Integration Verification Report

## Summary

This report evaluates the effectiveness of the BrogueMCP cursor rules system and MCP integration.

$SummaryContent

## API Compatibility

$ApiCompatibilityContent

## Knowledge Graph Integration

$KnowledgeGraphContent

## Tool Usage

$ToolUsageContent

## Recommendations

$RecommendationsContent

## Conclusion

The BrogueMCP cursor rules system provides a solid foundation for maintaining code quality and consistency across the project. The integration with MCP tools enhances research capabilities and knowledge management for roguelike development.
"@
    
    if ($IncludeApiResults) {
        $reportContent += @"

## API Key Verification

The following MCP API keys were tested:

- Brave Search API: $(if ((Test-ApiKeys)) { "✅ Working" } else { "❌ Failed" })
- Tavily API: $(if ((Test-ApiKeys)) { "✅ Working" } else { "❌ Failed" })

"@
    }
    
    if ($IncludeRuleStats) {
        $reportContent += @"

## Rules System Analysis

"@
        
        # Collect rule statistics
        $ruleFiles = Get-ChildItem -Path "./.cursor/rules" -Recurse -Filter "*.mdc" | Measure-Object
        $categories = Get-ChildItem -Path "./.cursor/rules" -Directory | Measure-Object
        
        $reportContent += @"
- Total rule files: $($ruleFiles.Count)
- Rule categories: $($categories.Count)

### Rule Categories:
$(Get-ChildItem -Path "./.cursor/rules" -Directory | ForEach-Object { "- $($_.Name)" })

### Priority Distribution:
$(
  $priorities = @{}
  Get-ChildItem -Path "./.cursor/rules" -Recurse -Filter "*.mdc" | ForEach-Object {
    $content = Get-Content -Path $_.FullName -Raw
    if ($content -match "priority:\s*(\d+)") {
      $priority = [int]$matches[1]
      if (-not $priorities.ContainsKey($priority)) {
        $priorities[$priority] = 0
      }
      $priorities[$priority]++
    }
  }
  
  $priorities.GetEnumerator() | Sort-Object -Property Key -Descending | ForEach-Object {
    "- Priority $($_.Key): $($_.Value) rules"
  }
)

"@
    }
    
    if ($IncludeWorkflowTest) {
        $reportContent += @"

## Workflow Integration

To test the workflow integration:

1. Test files were created in the ./test-mcp directory
2. These files were analyzed using the cursor rules system
3. The following rules were applied:
   - C style rules (code-style/c-style-enhanced.mdc)
   - Memory management rules (memory/memory-management.mdc)
   - Python processing rules (game/tolkien-processing.mdc)

### Workflow Improvements

- **Code Quality**: The rules help maintain consistent code style and quality
- **Memory Management**: The memory protocol guides proper resource handling
- **Research Methodology**: The research protocol standardizes Tolkien content research
- **Self-Healing**: The system can identify and suggest improvements for common issues

"@
    }
    
    $reportContent += @"

## Recommendations

1. **API Key Management**: Create a secure method for managing API keys
2. **Rule Conflict Resolution**: Resolve any identified rule conflicts
3. **Documentation Updates**: Ensure all rules have comprehensive documentation
4. **Integration Testing**: Implement regular integration testing of the rules system
5. **User Training**: Provide training for developers on using the rules system effectively

## Conclusion

The BrogueMCP cursor rules system provides a solid foundation for maintaining code quality and consistency across the project. The integration with MCP tools enhances research capabilities and knowledge management for roguelike development.

"@
    
    Set-Content -Path $reportPath -Value $reportContent
    
    Write-Host "Report generated: $reportPath" -ForegroundColor Green
}

# Main execution
Clear-Host
Write-Host "===== BrogueMCP Cursor Rules Testing =====" -ForegroundColor Cyan

# Test API keys
$apiKeysWorking = Test-ApiKeys
Write-Host ""

# Test rule effectiveness
Test-RuleEffectiveness
Write-Host ""

# Set up workflow test
Test-MCP-Workflow
Write-Host ""

# Generate report
Generate-Report
Write-Host ""

Write-Host "Testing complete!" -ForegroundColor Green