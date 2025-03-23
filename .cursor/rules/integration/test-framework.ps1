#!/usr/bin/env pwsh
# Cursor Rules Testing Framework
# Provides automated testing of cursor rules to ensure they function as expected

param (
    [string]$TestDir = "./tests/cursor-rules",
    [switch]$GenerateReport = $true,
    [switch]$Fast = $false
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# ===== Configuration =====
$CONFIG = @{
    ReportPath = "./test-reports/cursor-rules-tests.md"
    TestCaseDir = "$TestDir/test-cases"
    SampleFilesDir = "$TestDir/samples"
    ResultsDir = "$TestDir/results"
    DefaultTimeout = 30 # seconds
}

# ===== Initialization =====
function Initialize-TestEnvironment {
    Write-Host "🔧 Initializing test environment..." -ForegroundColor Cyan

    # Create necessary directories
    $dirs = @(
        $CONFIG.TestCaseDir,
        $CONFIG.SampleFilesDir,
        $CONFIG.ResultsDir,
        (Split-Path -Parent $CONFIG.ReportPath)
    )

    foreach ($dir in $dirs) {
        if (-not (Test-Path $dir)) {
            New-Item -Path $dir -ItemType Directory -Force | Out-Null
            Write-Host "   Created directory: $dir" -ForegroundColor Gray
        }
    }

    # Check for verification script
    $verificationScript = "./.cursor/rules/mcp/api-verification.ps1"
    if (-not (Test-Path $verificationScript)) {
        Write-Error "MCP API verification script not found. Run this test from the project root."
        exit 1
    }
}

# ===== Test Case Execution =====
function Import-TestCases {
    param (
        [string]$TestCaseDir
    )

    if (-not (Test-Path $TestCaseDir)) {
        Write-Error "Test case directory not found: $TestCaseDir"
        return @()
    }

    $testCaseFiles = Get-ChildItem -Path $TestCaseDir -Filter "*.json" -Recurse
    $testCases = @()

    foreach ($file in $testCaseFiles) {
        try {
            $testCase = Get-Content -Path $file.FullName | ConvertFrom-Json
            $testCase | Add-Member -NotePropertyName "SourceFile" -NotePropertyValue $file.FullName
            $testCases += $testCase
        }
        catch {
            Write-Warning "Failed to parse test case from $($file.FullName): $_"
        }
    }

    return $testCases
}

function New-TestSampleFile {
    param (
        [object]$TestCase
    )

    $sampleFilePath = Join-Path $CONFIG.SampleFilesDir $TestCase.sampleFile
    $sampleFileDir = Split-Path -Parent $sampleFilePath
    
    if (-not (Test-Path $sampleFileDir)) {
        New-Item -Path $sampleFileDir -ItemType Directory -Force | Out-Null
    }

    Set-Content -Path $sampleFilePath -Value $TestCase.fileContent
    return $sampleFilePath
}

function Test-CursorRule {
    param (
        [object]$TestCase
    )

    $testId = $TestCase.id
    $testName = $TestCase.name
    $result = [PSCustomObject]@{
        Id = $testId
        Name = $testName
        Status = "Failed"
        ExpectedRules = $TestCase.expectedRules
        DetectedRules = @()
        Duration = 0
        Detail = ""
    }

    try {
        Write-Host "   Running test: $testName" -ForegroundColor Gray
        $startTime = Get-Date

        # Create sample file
        $sampleFilePath = New-TestSampleFile -TestCase $TestCase
        
        # Execute rule detection
        $detectedRules = Detect-ApplicableRules -FilePath $sampleFilePath
        $result.DetectedRules = $detectedRules
        
        # Check if expected rules are applied
        $matchedRules = 0
        foreach ($expectedRule in $TestCase.expectedRules) {
            if ($detectedRules -contains $expectedRule) {
                $matchedRules++
            }
        }
        
        # Check if any unexpected rules are applied
        $unexpectedRules = 0
        foreach ($detectedRule in $detectedRules) {
            if ($TestCase.expectedRules -notcontains $detectedRule) {
                $unexpectedRules++
            }
        }
        
        # Determine test result
        if ($matchedRules -eq $TestCase.expectedRules.Count -and $unexpectedRules -eq 0) {
            $result.Status = "Passed"
        } else {
            $result.Status = "Failed"
            $result.Detail = "Found $matchedRules of $($TestCase.expectedRules.Count) expected rules. Detected $unexpectedRules unexpected rules."
        }
        
        $endTime = Get-Date
        $result.Duration = ($endTime - $startTime).TotalSeconds
    }
    catch {
        $result.Status = "Error"
        $result.Detail = $_.Exception.Message
    }
    
    return $result
}

function Detect-ApplicableRules {
    param (
        [string]$FilePath
    )

    # This is a placeholder implementation. In a real system, you would need to:
    # 1. Parse all rule files to extract their glob patterns and priorities
    # 2. Check if the file path matches each glob pattern
    # 3. Sort matching rules by priority
    # 4. Return the list of applicable rules
    
    $ext = [System.IO.Path]::GetExtension($FilePath)
    $filename = [System.IO.Path]::GetFileName($FilePath)
    $detectedRules = @()
    
    # Read all rule files
    $ruleFiles = Get-ChildItem -Path "./.cursor/rules" -Recurse -Filter "*.mdc"
    
    foreach ($ruleFile in $ruleFiles) {
        $content = Get-Content -Path $ruleFile.FullName -Raw
        if ($content -match "(?s)---\s*\n(.*?)\n---") {
            $metadata = $matches[1]
            
            # Extract glob pattern
            if ($metadata -match "glob:\s*""([^""]*)""") {
                $globPattern = $matches[1]
                
                # Simple glob matching logic (this is simplified - a real implementation would be more comprehensive)
                $isMatch = $false
                
                # Direct extension match
                if ($globPattern -eq "*$ext") {
                    $isMatch = $true
                }
                # Full pattern match for specific extensions
                elseif ($globPattern -match "\*\*\/\*\.\{.*\}") {
                    # Extract extensions from pattern like "**/*.{c,h}"
                    $extPattern = $globPattern -replace ".*\.\{(.*)\}", '$1'
                    $extensions = $extPattern -split ","
                    if ($extensions -contains $ext.TrimStart(".")) {
                        $isMatch = $true
                    }
                }
                # Directory-specific pattern
                elseif ($FilePath -match ($globPattern -replace "\*\*", ".*")) {
                    $isMatch = $true
                }
                
                if ($isMatch) {
                    $rulePath = $ruleFile.FullName.Substring((Get-Location).Path.Length + 1)
                    $detectedRules += $rulePath
                }
            }
        }
    }
    
    return $detectedRules
}

# ===== Reporting =====
function New-TestReport {
    param (
        [object[]]$TestResults,
        [string]$ReportPath
    )

    # Summary metrics
    $totalTests = $TestResults.Count
    $passedTests = ($TestResults | Where-Object { $_.Status -eq "Passed" }).Count
    $failedTests = ($TestResults | Where-Object { $_.Status -eq "Failed" }).Count
    $errorTests = ($TestResults | Where-Object { $_.Status -eq "Error" }).Count
    $passRate = [math]::Round(($passedTests / $totalTests) * 100, 2)
    
    # Create report content
    $reportContent = @"
# Cursor Rules Test Report

Generated on: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## Summary

- **Total Tests**: $totalTests
- **Passed**: $passedTests ($passRate%)
- **Failed**: $failedTests
- **Errors**: $errorTests

## Test Results

| ID | Test Name | Status | Duration (s) | Details |
|----|-----------|--------|--------------|---------|
"@

    foreach ($result in $TestResults) {
        $statusEmoji = switch ($result.Status) {
            "Passed" { "✅" }
            "Failed" { "❌" }
            "Error" { "⚠️" }
            default { "❓" }
        }
        
        $reportContent += "`n| $($result.Id) | $($result.Name) | $statusEmoji $($result.Status) | $([math]::Round($result.Duration, 2)) | $($result.Detail) |"
    }
    
    $reportContent += @"

## Failed Tests Detail

"@

    $failedResults = $TestResults | Where-Object { $_.Status -ne "Passed" }
    if ($failedResults.Count -eq 0) {
        $reportContent += "`nAll tests passed! 🎉"
    } else {
        foreach ($result in $failedResults) {
            $reportContent += @"

### $($result.Id): $($result.Name)

- **Status**: $($result.Status)
- **Expected Rules**: $($result.ExpectedRules -join ", ")
- **Detected Rules**: $($result.DetectedRules -join ", ")
- **Details**: $($result.Detail)

"@
        }
    }
    
    # Write report to file
    $reportDir = Split-Path -Parent $ReportPath
    if (-not (Test-Path $reportDir)) {
        New-Item -Path $reportDir -ItemType Directory -Force | Out-Null
    }
    Set-Content -Path $ReportPath -Value $reportContent
    
    Write-Host "   Report generated: $ReportPath" -ForegroundColor Gray
    
    return $reportContent
}

function Create-SampleTestCases {
    Write-Host "📋 Creating sample test cases..." -ForegroundColor Cyan
    
    # C File Test
    $cTest = @{
        id = "C001"
        name = "C Style Rule Application"
        description = "Tests if C style rules are correctly applied to .c files"
        sampleFile = "test_c_style.c"
        fileContent = @"
#include <stdio.h>
#include <stdlib.h>

int main() {
    printf("Hello, World!\n");
    return 0;
}
"@
        expectedRules = @(
            ".cursor/rules/code-style/c-style.mdc"
        )
    } | ConvertTo-Json -Depth 5
    
    # Python File Test
    $pyTest = @{
        id = "PY001"
        name = "Python Style Rule Application"
        description = "Tests if Python style rules are correctly applied to .py files"
        sampleFile = "test_python_style.py"
        fileContent = @"
def hello_world():
    print("Hello, World!")

if __name__ == "__main__":
    hello_world()
"@
        expectedRules = @(
            ".cursor/rules/code-style/python-style.mdc"
        )
    } | ConvertTo-Json -Depth 5
    
    # Tolkien Processing File Test
    $tolkienTest = @{
        id = "TP001"
        name = "Tolkien Processing Rule Application"
        description = "Tests if Tolkien processing rules are applied to processing Python files"
        sampleFile = "processing/tolkien_extract.py"
        fileContent = @"
def extract_entities(text):
    # Extract Tolkien entities from text
    return []

if __name__ == "__main__":
    text = "Gandalf the Grey walked through Moria."
    entities = extract_entities(text)
    print(entities)
"@
        expectedRules = @(
            ".cursor/rules/code-style/python-style.mdc",
            ".cursor/rules/game/tolkien-processing.mdc"
        )
    } | ConvertTo-Json -Depth 5
    
    # Save sample test cases
    if (-not (Test-Path $CONFIG.TestCaseDir)) {
        New-Item -Path $CONFIG.TestCaseDir -ItemType Directory -Force | Out-Null
    }
    
    Set-Content -Path "$($CONFIG.TestCaseDir)/c_style_test.json" -Value $cTest
    Set-Content -Path "$($CONFIG.TestCaseDir)/python_style_test.json" -Value $pyTest
    Set-Content -Path "$($CONFIG.TestCaseDir)/tolkien_processing_test.json" -Value $tolkienTest
    
    Write-Host "   Created 3 sample test cases in $($CONFIG.TestCaseDir)" -ForegroundColor Gray
}

# ===== Main Execution =====
function Start-TestSuite {
    Write-Host "🧪 Starting Cursor Rules Test Suite" -ForegroundColor Green
    
    # Initialize environment
    Initialize-TestEnvironment
    
    # Generate sample test cases if none exist
    if (-not (Test-Path "$($CONFIG.TestCaseDir)/*.json")) {
        Create-SampleTestCases
    }
    
    # Import test cases
    $testCases = Import-TestCases -TestCaseDir $CONFIG.TestCaseDir
    Write-Host "📝 Found $($testCases.Count) test cases" -ForegroundColor Cyan
    
    if ($testCases.Count -eq 0) {
        Write-Warning "No test cases found. Run with -GenerateSamples to create sample test cases."
        return
    }
    
    # Run test cases
    $testResults = @()
    foreach ($testCase in $testCases) {
        Write-Host "▶️ Running test: $($testCase.id) - $($testCase.name)" -ForegroundColor Yellow
        $result = Test-CursorRule -TestCase $testCase
        $testResults += $result
        
        # Display result
        $statusColor = switch ($result.Status) {
            "Passed" { "Green" }
            "Failed" { "Red" }
            "Error" { "Magenta" }
            default { "Gray" }
        }
        Write-Host "   Result: $($result.Status)" -ForegroundColor $statusColor
        
        if ($result.Status -ne "Passed") {
            Write-Host "   Detail: $($result.Detail)" -ForegroundColor Gray
        }
    }
    
    # Generate report
    if ($GenerateReport) {
        $reportContent = New-TestReport -TestResults $testResults -ReportPath $CONFIG.ReportPath
        Write-Host "📊 Test Report generated at $($CONFIG.ReportPath)" -ForegroundColor Green
    }
    
    # Summary
    $passedCount = ($testResults | Where-Object { $_.Status -eq "Passed" }).Count
    $totalCount = $testResults.Count
    $passRate = [math]::Round(($passedCount / $totalCount) * 100, 2)
    
    Write-Host "✅ Tests passed: $passedCount/$totalCount ($passRate%)" -ForegroundColor $(if ($passRate -eq 100) { "Green" } elseif ($passRate -ge 80) { "Yellow" } else { "Red" })
}

# Execute the test suite
Start-TestSuite 