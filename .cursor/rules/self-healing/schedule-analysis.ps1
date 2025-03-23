# Ages of Arda - Self-Healing Rules System
# Scheduled Task Setup Script

# Configuration
$TaskName = "AgesOfArda-SelfHealing"
$TaskDescription = "Analyze code errors and generate rule proposals for Ages of Arda"
$ScriptPath = Join-Path $PSScriptRoot "error-analyzer.ps1"
$LogPath = Join-Path $PSScriptRoot "logs"

# Ensure log directory exists
New-Item -ItemType Directory -Force -Path $LogPath | Out-Null

# Create a scheduled task that runs weekly
function Register-WeeklyTask {
    # Create action to run the analyzer script
    $action = New-ScheduledTaskAction -Execute "PowerShell.exe" `
        -Argument "-ExecutionPolicy Bypass -File `"$ScriptPath`" -LogPath `"$LogPath`"" `
        -WorkingDirectory $PSScriptRoot

    # Set trigger for weekly execution (Sunday at 1:00 AM)
    $trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 1am

    # Create the task
    $settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopOnIdleEnd -AllowStartIfOnBatteries -RunOnlyIfNetworkAvailable

    # Register the task (will prompt for credentials)
    Register-ScheduledTask -TaskName $TaskName `
        -Action $action `
        -Trigger $trigger `
        -Settings $settings `
        -Description $TaskDescription `
        -RunLevel Highest `
        -Force
}

function Check-TaskExists {
    $task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    return ($task -ne $null)
}

# Main execution
Write-Host "Ages of Arda - Self-Healing System Setup"
Write-Host "----------------------------------------"
Write-Host "This script will set up a weekly scheduled task to analyze code errors"
Write-Host "and generate rule proposals for improving code quality."
Write-Host ""

if (Check-TaskExists) {
    Write-Host "Task '$TaskName' already exists."
    $choice = Read-Host "Do you want to update it? (Y/N)"
    
    if ($choice -eq "Y" -or $choice -eq "y") {
        Write-Host "Updating scheduled task..."
        Register-WeeklyTask
        Write-Host "Task updated successfully!"
    } else {
        Write-Host "No changes made to existing task."
    }
} else {
    Write-Host "Creating new scheduled task..."
    Register-WeeklyTask
    Write-Host "Task created successfully!"
}

# Offer to run the analysis now
Write-Host ""
$runNow = Read-Host "Would you like to run the analysis now? (Y/N)"

if ($runNow -eq "Y" -or $runNow -eq "y") {
    Write-Host "Running analysis script..."
    & $ScriptPath
    Write-Host "Analysis complete!"
} else {
    Write-Host "Task scheduled for next Sunday at 1:00 AM."
}

Write-Host ""
Write-Host "Self-Healing System Setup Complete!"
Write-Host "You can manually run the analysis at any time by executing:"
Write-Host "  $ScriptPath" 