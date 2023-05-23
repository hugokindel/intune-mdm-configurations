#!/bin/sh
#set -x

# Bitdefender Endpoint Security Tools (BEST) silent installation script.

# Filename and download URL obtained from the GravityZone.
# The filename contains the company's hash (= the license key).
filename="setup_downloader.dmg"
download_url="https://bitdefender.com/example/$filename" # You need to change this value.

# Path were the installation file will be stored.
appname="bitdefender"
tempdir=$(mktemp -d)
destination_path="$tempdir/$filename"

remove_bitdefender_installation_file() {
    if [ -f "$destination_path" ]; then
        rm "$destination_path"
        echo "Removed Bitdefender installation file."
    fi
}

# Checks if Bitdefender is installed and clean up old installation files.
is_bitdefender_installed() {
    # Removes old installation files if there is one.
    remove_bitdefender_installation_file

    # Bitdefender has a daemon on macOS. If it's running, Bitdefender is installed.
    if [ $(ps aux | grep -v grep | grep -ci BDLDaemon) -gt 0 ]; then
        echo "Bitdefender is installed."
        exit 0
    fi
}

# Installs Bitdefender.
#
# The installation process goes in four steps:
# - Checks if Bitdefender is already installed.
# - Download of the installation file.
# - Execution of the installation file in silent mode.
# - Checks if Bitdefender was successfully installed.
install_bitdefender() {
    # Checks for previous installations of Bitdefender.
    is_bitdefender_installed

    # Moves to the temporary folder.
    cd "$tempdir"
    echo "tempdir: $tempdir"

    # Tries to download the installation file.
    echo "Bitdefender installation file download in progress..."
    curl -s -O "$download_url"
    echo "Downloaded Bitdefender installation file."

    # Mounts the installation file (with `-nobrowse` to keep it hidden from Finder).
    volume="$tempdir/$appname"
    hdiutil attach -quiet -nobrowse -mountpoint "$volume" "$destination_path"

    # Checks for mounting errors.
    err=$?
    if [ ${err} -ne 0 ]; then
        echo "Failed to mount Bitdefender installation file: ${err}"
        remove_bitdefender_installation_file
        exit 1
    fi

    echo "Mounted Bitdefender installation file."

    # Executes the installation file.
    echo "Bitdefender installation in progress from volume."
    $("$volume/SetupDownloader.app/Contents/MacOS/SetupDownloader" --silent > /dev/null 2>&1)

    # Unmounts the installation file.
    hdiutil detach -quiet "$volume"
    echo "Unmounted Bitdefender installation file."

    # Checks that Bitdefender was successfully installed.
    is_bitdefender_installed

    # If we reach this line, there was an issue during Bitdefender installation.
    echo "Failed to install Bitdefender: Unknown error!"
    exit 1
}

# Redirect logs
exec 1>> "/var/log/install_bitdefender.log" 2>&1

# Starts the installation process.
install_bitdefender
