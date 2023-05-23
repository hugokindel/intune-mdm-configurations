#!/bin/sh

# You need to change those settings!
EXECUTABLE_DEVELOPMENT_TEAM="ABCDEFGHIJ" # You need to change this value.
EXECUTABLE_CODE_SIGN_IDENTITY="Developer ID Application" # You need to change this value.
PKG_CODE_SIGN_IDENTITY="Developer ID Installer" # You need to change this value.
NOTARIZATION_CREDENTIAL_PROFILE="Signing"

EXECUTABLE_ARCHIVE_PATH="/tmp/admin.xcarchive"
EXECUTABLE_PATH="$EXECUTABLE_ARCHIVE_PATH/Products/usr/local/bin/admin"
PKG_NAME="admin.pkg"
PKG_ROOT="pkg"
PKG_SCRIPTS="$PKG_ROOT/scripts"
ENCRYPTED_PKG_NAME="admin.tar.gz"
# It's considered safe to show the password in clear text as we must have bigger problems if the attacker is capable of accessing the archive and this file.
# Also, the archive does not contain any sensitive data except for a hashed password.
ENCRYPTION_PASSWORD="hello_world" # You need to change this value.

# Uses Xcode to build and archive admin to a temporary directory.
echo "Building and archiving admin executable..."
xcodebuild archive -workspace "admin_swift/admin.xcworkspace" -scheme "admin" -archivePath "$EXECUTABLE_ARCHIVE_PATH" CODE_SIGNING_IDENTITY="$EXECUTABLE_CODE_SIGN_IDENTITY" DEVELOPMENT_TEAM="$EXECUTABLE_DEVELOPMENT_TEAM"
if [[ $? != 0 ]]; then
    exit 1
fi

# Copies the built executable to the package's script folder.
cp "$EXECUTABLE_PATH" "$PKG_SCRIPTS"

# Sets the expected permissions on the built executable.
chmod 755 "$PKG_SCRIPTS/admin"

# Removes the temporary directory used for admin.
rm -r "$EXECUTABLE_ARCHIVE_PATH"

# Checks if there is already a package and removes it.
if [[ -f "$PKG_NAME" ]]; then
    rm "$PKG_NAME"
fi

# Creates the installation package for the executable and the user creation script.
echo "Creating package..."
pkgbuild --ownership "recommended" --identifier "fr..admin" --version "1.0" --sign "$PKG_CODE_SIGN_IDENTITY" --root "$PKG_ROOT/payload" --scripts "$PKG_SCRIPTS" "$PKG_NAME"

# Sends the package for notarization.
echo "Sending package for notarization..."
xcrun notarytool submit "$PKG_NAME" --keychain-profile "$NOTARIZATION_CREDENTIAL_PROFILE" --wait

# Adds the notarization staple on the executable.
echo "Stapling package..."
xcrun stapler staple "$PKG_NAME"

# Checks if there is already an encrypted package and removes it.
if [[ -f "$ENCRYPTED_PKG_NAME" ]]; then
    rm "$ENCRYPTED_PKG_NAME"
fi

# Encrypts the archive.
echo "Encrypting package in a tarball..."
tar -czf - "$PKG_NAME" | openssl enc -e -md md5 -aes256 -pass "pass:$ENCRYPTION_PASSWORD" -out "$ENCRYPTED_PKG_NAME"

# Removes the package without encryption.
rm "$PKG_NAME"

# Shows the file in finder.
open -R "$ENCRYPTED_PKG_NAME"
echo "Everything ran with success."

exit 0
