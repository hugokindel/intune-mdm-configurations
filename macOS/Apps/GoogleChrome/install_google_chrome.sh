#!/bin/sh
#set -x

# Change these settings based on the app.
download_url="https://example.com/GoogleChrome.pkg" # You need to change this.
appname="google_chrome"
apppath="/Applications/Google Chrome.app"
installation_filename="google_chrome.pkg"

# Checks if is installed and clean up old installation files.
is_installed() {
    if [ -d "$apppath" ]; then
        echo "Is installed."
        exit 0
    fi
}

# Installs.
#
# The installation process goes in four steps:
# - Checks if is already installed.
# - Download of the installation file.
# - Execution of the installation file in silent mode.
# - Checks if was successfully installed.
install() {
    # Checks for previous installations.
    is_installed

    # Moves to the temporary folder.
    tempdir=$(mktemp -d)
    echo "Moving to temporary directory: $tempdir"
    cd "$tempdir"

    # Tries to download the installation file.
    echo "Installation file download in progress: $installation_filename"

    # Downloads the corresponding file depending on system architecture (Intel CPU vs Apple CPU)
    curl -L -s -o "$installation_filename" "$download_url"

    echo "Downloaded installation file."

    # Executes the installation file.
    echo "Installation in progress..."
    installer -pkg "$installation_filename" -target /

    # Removes installation file.
    rm "$installation_filename"

    # Checks that installation was successful.
    is_installed

    # If we reach this line, there was an issue during installation.
    echo "Failed to install: Unknown error!"
    exit 1
}

# Redirect logs
exec 1>> "/var/log/install_$appname.log" 2>&1

echo "############################"
echo "# $appname"
echo "############################"

# Starts the installation process.
install
