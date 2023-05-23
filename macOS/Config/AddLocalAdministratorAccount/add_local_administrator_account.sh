#!/bin/sh
#set -x

DOWNLOAD_URL="https://example.com/admin.tar.gz" # You need to change this value.
PKG_NAME="admin.pkg"
ENCRYPTED_PKG_NAME="admin.tar.gz"
# It's considered safe to show the password in clear text as we must have bigger problems if the attacker is capable of accessing the archive and this file.
# Also, the archive does not contain any sensitive data except for a hashed password.
ENCRYPTION_PASSWORD="hello_world" # You need to change this value.

# Redirect logs
#exec 1>> "/var/log/add_account_administror_script.log" 2>&1

# Checks if the user already exists.
if id "admin" &>/dev/null; then
    echo 'User already exists.'
    exit 0
fi

# Move to tmp directory.
cd "/tmp"

# Downloads encrypted archive from AWS S3.
echo "Downloading archive..."
curl -L -s -o "$ENCRYPTED_PKG_NAME" "$DOWNLOAD_URL"

# Decrypt archive and untar archive.
echo "Decrypting and decompressing archive..."
openssl enc -d -md md5 -aes256 -pass "pass:$ENCRYPTION_PASSWORD" -in "$ENCRYPTED_PKG_NAME" | tar xz -C .

# Removes encrypted archive.
echo "Removing encrypted archive..."
rm "$ENCRYPTED_PKG_NAME"

# Installs package file.
echo "Installing local administrator account..."
installer -pkg "$PKG_NAME" -target /

# Removes package file.
echo "Removing package..."
rm "$PKG_NAME"

echo "Local administrator account added with success."
