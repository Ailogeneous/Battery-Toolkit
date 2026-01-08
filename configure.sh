#!/bin/bash

#
# Copyright (C) 2024 Gene. All rights reserved.
#

# Stop on error
set -e

# Find the Xcode project in the parent directory
PROJECT_DIR=$(find .. -maxdepth 1 -type d -name "*.xcodeproj" | head -n 1)
if [ -z "$PROJECT_DIR" ]; then
    echo "Error: No Xcode project found in the parent directory."
    exit 1
fi

PROJECT_FILE_PATH="$PROJECT_DIR/project.pbxproj"
if [ ! -f "$PROJECT_FILE_PATH" ]; then
    echo "Error: project.pbxproj not found in $PROJECT_DIR."
    exit 1
fi

echo "Found Xcode project: $PROJECT_DIR"

# Extract Bundle Identifier and Team ID
BUNDLE_ID=$(grep -o 'PRODUCT_BUNDLE_IDENTIFIER = [^;]*;' "$PROJECT_FILE_PATH" | head -n 1 | sed -e 's/PRODUCT_BUNDLE_IDENTIFIER = //g' -e 's/;//g' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
TEAM_ID=$(grep -o 'DEVELOPMENT_TEAM = [^;]*;' "$PROJECT_FILE_PATH" | head -n 1 | sed -e 's/DEVELOPMENT_TEAM = //g' -e 's/;//g' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')


if [ -z "$BUNDLE_ID" ]; then
    echo "Error: Could not automatically determine Bundle Identifier."
    read -p "Please enter the Bundle Identifier: " BUNDLE_ID
fi

if [ -z "$TEAM_ID" ]; then
    echo "Error: Could not automatically determine Development Team ID."
    read -p "Please enter the Team ID: " TEAM_ID
fi

echo "Using Bundle ID: $BUNDLE_ID"
echo "Using Team ID: $TEAM_ID"

# --- Update Package.swift ---

PACKAGE_SWIFT="Package.swift"
SERVICE_ID="$BUNDLE_ID.BatteryToolkitService"
DAEMON_ID="$BUNDLE_ID.batterytoolkitd"
DAEMON_CONN="$TEAM_ID.$DAEMON_ID"
AUTOSTART_ID="$BUNDLE_ID.BatteryToolkitAutostart"

# Using a temporary file for sed compatibility between macOS and Linux
sed -i.bak \
    -e "s/me.mhaeuser.BatteryToolkit/$BUNDLE_ID/g" \
    -e "s/me.mhaeuser.BatteryToolkitService/$SERVICE_ID/g" \
    -e "s/me.mhaeuser.batterytoolkitd/$DAEMON_ID/g" \
    -e "s/EMH49F8A2Y.me.mhaeuser.batterytoolkitd/$DAEMON_CONN/g" \
    -e "s/me.mhaeuser.BatteryToolkitAutostart/$AUTOSTART_ID/g" \
    -e \"/BT_CODESIGN_CN_/d\" \
    "$PACKAGE_SWIFT"

rm "${PACKAGE_SWIFT}.bak"
echo "Updated $PACKAGE_SWIFT"


# --- Update BTXPCValidation.swift ---

XPC_VALIDATION_FILE="Sources/BTShared/BTXPCValidation.swift"

sed -i.bak \
    -e \"/and certificate leaf\[subject.CN\]/d\" \
    "$XPC_VALIDATION_FILE"

rm "${XPC_VALIDATION_FILE}.bak"
echo "Updated $XPC_VALIDATION_FILE"

echo "Configuration complete."
