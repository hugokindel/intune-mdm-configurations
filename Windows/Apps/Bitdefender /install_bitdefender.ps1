# Bitdefender Endpoint Security Tools (BEST) silent installation script.

# Filename and download URL obtained from the GravityZone.
# The filename contains the company's hash (= the license key).
$Filename = "setupdownloader.exe" # You need to change this.
$DownloadURL = "https://bitdefender.com/example/$Filename" # You need to change this.

# Path were the installation file will be stored.
$TempFolder = "C:\Windows\Temp"
$DestinationPath = "$TempFolder\$Filename"

# Checks if a Bitdefender installation file exists and removes it.
function Remove-BitdefenderInstallationFile {
    if (Test-Path -LiteralPath $DestinationPath) {
        Remove-Item -LiteralPath $DestinationPath
        Write-Output "Removed Bitdefender installation file."
    }
}

# Checks if Bitdefender is installed and clean up old installation files.
function Assert-BitdefenderInstallationStatus {
    # Removes old installation files if there is one.
    Remove-BitdefenderInstallationFile

    # Searches for a registry value specific to Bitdefender.
    $Installed = Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" | 
    Where-Object { $_.DisplayName -eq "Bitdefender Endpoint Security Tools" }

    # If it exists, Bitdefender is installed.
    if ($Installed) {
        Write-Output "Bitdefender is installed."
        Exit 0
    }
}

# Installs Bitdefender.
#
# The installation process goes in four steps:
# - Checks if Bitdefender is already installed.
# - Download of the installation file.
# - Execution of the installation file in silent mode.
# - Checks if Bitdefender was successfully installed.
function Install-Bitdefender {
    # Checks for previous installations of Bitdefender.
    Assert-BitdefenderInstallationStatus

    # Tries to download the installation file.
    try {
        # Before PowerShell 7.1, Invoke-WebRequests could not handle special characters (e.g. [, ]) in paths.
        # As a workaround in an attempt to support all PowerShell versions, we first download the file with
        # a temporary name and rename it with the wanted name containing special characters later on.
        $TempDownloadPath = "$TempFolder\setupdownloader.exe"
        
        Write-Output "Bitdefender installation file download in progress..."
        Invoke-WebRequest -Uri $DownloadURL -OutFile $TempDownloadPath
        Write-Output "Downloaded Bitdefender installation file."
        
        Rename-Item -Path $TempDownloadPath -NewName $Filename
        Write-Output "Renamed Bitdefender installation file."
    } catch {
        Write-Output "Failed to download Bitdefender installation file:"
        Write-Output $_
        Exit 1
    }

    # Executes the installation file in silent mode.
    Write-Output "Bitdefender installation in progress..."
    Start-Process -FilePath $DestinationPath -ArgumentList "/bdparams /silent silent" -Wait -NoNewWindow

    # Checks that Bitdefender was successfully installed.
    Assert-BitdefenderInstallationStatus

    # If we reach this line, there was an issue during Bitdefender installation.
    Write-Output "Failed to install Bitdefender: Unknown error!"
    Exit 1
}

# Starts the installation process.
Install-Bitdefender
