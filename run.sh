#!/bin/bash
set -e

# NBA iOS App Simulator Runner Script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"

BUNDLE_ID="com.spearhead.nbaPowerRanking"
CONFIGURATION="Debug"
DERIVED_DATA_PATH="$DIR/build/DerivedData"
APP_PATH="$DERIVED_DATA_PATH/Build/Products/${CONFIGURATION}-iphonesimulator/nba.app"

SKIP_BUILD=false
CUSTOM_DEVICE=""

# Argument parsing
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --no-build) SKIP_BUILD=true ;;
        --release) CONFIGURATION="Release"; APP_PATH="$DERIVED_DATA_PATH/Build/Products/Release-iphonesimulator/nba.app" ;;
        --device) CUSTOM_DEVICE="$2"; shift ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

echo "=========================================="
echo "🚀 NBA iOS Simulator Runner"
echo "=========================================="

# 1. Build step (incremental build is fast)
if [ "$SKIP_BUILD" = false ] || [ ! -d "$APP_PATH" ]; then
    echo "🔨 Building app before launch..."
    "$DIR/build.sh" "$CONFIGURATION"
else
    echo "⏭️ Skipping build as requested (--no-build)"
fi

if [ ! -d "$APP_PATH" ]; then
    echo "❌ App bundle not found at: $APP_PATH"
    exit 1
fi

# 2. Simulator Detection & Selection
echo "🔍 Selecting target simulator..."

DEVICE_ID=""
DEVICE_NAME=""

if [ -n "$CUSTOM_DEVICE" ]; then
    DEVICE_ID=$(xcrun simctl list devices available | grep -E "$CUSTOM_DEVICE \(" | head -n 1 | sed -E 's/.* \(([0-9A-F\-]+)\) .*/\1/')
    DEVICE_NAME="$CUSTOM_DEVICE"
fi

if [ -z "$DEVICE_ID" ]; then
    # Check if any simulator is already booted
    BOOTED_DEVICE_LINE=$(xcrun simctl list devices | grep -E '\(Booted\)' | head -n 1)
    if [ -n "$BOOTED_DEVICE_LINE" ]; then
        DEVICE_ID=$(echo "$BOOTED_DEVICE_LINE" | sed -E 's/.* \(([0-9A-F\-]+)\) \(Booted\).*/\1/')
        DEVICE_NAME=$(echo "$BOOTED_DEVICE_LINE" | sed -E 's/^[[:space:]]+//; s/ \([0-9A-F\-]+\).*//')
        echo "💡 Found running simulator: $DEVICE_NAME ($DEVICE_ID)"
    fi
fi

if [ -z "$DEVICE_ID" ]; then
    # Find preferred available simulator
    PREFERRED_LIST=("iPhone 16 Pro" "iPhone 17 Pro" "iPhone 15 Pro" "iPhone 16" "iPhone 15" "iPhone 14 Pro")
    for pref in "${PREFERRED_LIST[@]}"; do
        FOUND_LINE=$(xcrun simctl list devices available | grep -E "$pref \(" | head -n 1)
        if [ -n "$FOUND_LINE" ]; then
            DEVICE_ID=$(echo "$FOUND_LINE" | sed -E 's/.* \(([0-9A-F\-]+)\) .*/\1/')
            DEVICE_NAME="$pref"
            break
        fi
    done
fi

if [ -z "$DEVICE_ID" ]; then
    # Fallback: grab first available iPhone
    FALLBACK_LINE=$(xcrun simctl list devices available | grep -E 'iPhone.* \(' | head -n 1)
    if [ -n "$FALLBACK_LINE" ]; then
        DEVICE_ID=$(echo "$FALLBACK_LINE" | sed -E 's/.* \(([0-9A-F\-]+)\) .*/\1/')
        DEVICE_NAME=$(echo "$FALLBACK_LINE" | sed -E 's/^[[:space:]]+//; s/ \([0-9A-F\-]+\).*//')
    else
        echo "❌ No available iOS Simulator found. Please check Xcode Simulator settings."
        exit 1
    fi
fi

echo "📱 Target device: $DEVICE_NAME ($DEVICE_ID)"

# 3. Boot simulator if needed
DEVICE_STATUS=$(xcrun simctl list devices | grep "$DEVICE_ID" | grep -o "Booted" || true)
if [ "$DEVICE_STATUS" != "Booted" ]; then
    echo "⚡ Booting simulator..."
    xcrun simctl boot "$DEVICE_ID"
fi

# 4. Bring Simulator UI to front
open -a Simulator

# 5. Terminate existing app process if running
echo "🔄 Terminating any previous instance of $BUNDLE_ID..."
xcrun simctl terminate "$DEVICE_ID" "$BUNDLE_ID" 2>/dev/null || true

# 6. Install app bundle
echo "📥 Installing app to simulator..."
xcrun simctl install "$DEVICE_ID" "$APP_PATH"

# 7. Launch app
echo "🚀 Launching $BUNDLE_ID..."
xcrun simctl launch "$DEVICE_ID" "$BUNDLE_ID"

echo "=========================================="
echo "🎉 App launched successfully on $DEVICE_NAME!"
echo "   Bundle ID: $BUNDLE_ID"
echo "=========================================="
