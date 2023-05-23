#!/bin/sh
#set -x

# Slack silent installation script.

download_url_x64="https://slack.com/ssb/download-osx"
download_url_arm64="https://slack.com/ssb/download-osx-silicon"

# Path were the installation file will be stored.
filename="slack.dmg"
appname="slack"
tempdir=$(mktemp -d)
destination_path="$tempdir/$filename"
installation_path="/Applications"

remove_slack_installation_file() {
    if [ -f "$destination_path" ]; then
        rm "$destination_path"
        echo "Removed Slack installation file."
    fi
}

# Checks if Slack is installed and clean up old installation files.
is_slack_installed() {
    # Removes old installation files if there is one.
    remove_slack_installation_file

    if [ -d "$installation_path/Slack.app" ]; then
        echo "Slack is installed."
        exit 0
    fi
}

# Installs Slack.
#
# The installation process goes in four steps:
# - Checks if Slack is already installed.
# - Download of the installation file.
# - Execution of the installation file in silent mode.
# - Checks if Slack was successfully installed.
install_slack() {
    # Checks for previous installations of Slack.
    is_slack_installed

    # Moves to the temporary folder.
    cd "$tempdir"
    echo "tempdir: $tempdir"

    # Tries to download the installation file.
    echo "Slack installation file download in progress..."

    # Downloads the corresponding file depending on system architecture (Intel CPU vs Apple CPU)
    if [[ $(uname -m) == 'arm64' ]]; then
        curl -L -s -o "$filename" "$download_url_arm64"
    else
        curl -L -s -o "$filename" "$download_url_x64"
    fi

    echo "Downloaded Slack installation file."

    # Mounts the installation file (with `-nobrowse` to keep it hidden from Finder).
    volume="$tempdir/$appname"
    hdiutil attach -quiet -nobrowse -mountpoint "$volume" "$destination_path"

    # Checks for mounting errors.
    err=$?
    if [ ${err} -ne 0 ]; then
        echo "Failed to mount Slack installation file: ${err}"
        remove_slack_installation_file
        exit 1
    fi

    echo "Mounted Slack installation file."

    # Executes the installation file.
    echo "Slack installation in progress from volume."
    cp -r "$volume/Slack.app" "/Applications"

    sleep 10

    # Detach the installation file.
    hdiutil detach -quiet "$volume"
    echo "Unmounted Slack installation file."

    # Checks that Slack was successfully installed.
    is_slack_installed

    # If we reach this line, there was an issue during Slack installation.
    echo "Failed to install Slack: Unknown error!"
    exit 1
}

# Redirect logs
exec 1>> "/var/log/install_slack.log" 2>&1

# Starts the installation process.
install_slack
