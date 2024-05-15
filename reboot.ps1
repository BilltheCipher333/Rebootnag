# Function to determine if a user is logged in
function IsUserLoggedIn {
    $loggedInUsers = quser
    return ($loggedInUsers -match "active")
}

# Function to display a message box using WPF
function ShowMessageBox($message, $title, $buttons) {
    Add-Type -AssemblyName PresentationFramework
    $result = [System.Windows.MessageBox]::Show($message, $title, $buttons)
    return $result
}

# Function to prompt the user for a reboot and handle their response
function PromptForReboot {
    $result = ShowMessageBox "A reboot is required. Do you want to reboot now?" "Reboot Required" "YesNo"
    return ($result -eq "Yes")
}

# Function to log messages to a file
function LogMessage($message) {
    try {
        $logFilePath = "C:\RebootLog.txt"
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Add-Content -Path $logFilePath -Value "$timestamp - $message"
    } catch {
        Write-Host "Error occurred while logging message: $_"
    }
}

# Function to log results to a file
function LogResult($message) {
    LogMessage $message
}

# Check if a reboot is required and handle accordingly
function CheckAndHandleReboot {
    # Log the start of the reboot check
    LogMessage "Starting check for reboot..."

    # Prompt the user for a reboot
    LogMessage "Prompting user for reboot..."
    $result = PromptForReboot

    # Check the user's response
    if ($result) {
        # User chose to reboot
        LogResult "User chose to reboot. Proceeding with reboot..."
        Restart-Computer -Force
        return $false
    } else {
        # User chose to defer reboot, log and return true to continue checking
        LogResult "User chose to defer reboot."
        return $true
    }
}

# Main script logic
if (IsUserLoggedIn) {
    # User is logged in, prompt for reboot if needed
      $RePromptInterval = 60  # in seconds (default: 1 minute)

    $rebootRequired = $true
    while ($rebootRequired) {
        $rebootRequired = CheckAndHandleReboot
        if ($rebootRequired) {
            Start-Sleep -Seconds $RePromptInterval
        }
    }
} else {
    # No user is logged in, reboot the machine
    LogResult "No user is logged in. Rebooting the machine..."
    Restart-Computer -Force
}
