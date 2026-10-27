#!/bin/bash
set -e

# NBA iOS App Runner Script (Auto-detects Physical Device or Simulator)
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"

BUNDLE_ID="com.spearhead.nbaPowerRanking"
CONFIGURATION="Debug"
DERIVED_DATA_PATH="$DIR/build/DerivedData"

SKIP_BUILD=false
FORCE_SIMULATOR=false
CUSTOM_DEVICE=""

# Argument parsing
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --no-build) SKIP_BUILD=true ;;
        --release) CONFIGURATION="Release" ;;
        --simulator) FORCE_SIMULATOR=true ;;
        --device) CUSTOM_DEVICE="$2"; shift ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

echo "=========================================="
echo "🚀 NBA iOS App Runner"
echo "=========================================="

PHYSICAL_DEVICE_ID=""
PHYSICAL_DEVICE_NAME=""

# 1. Check for Connected Physical Device (Unless --simulator is forced)
if [ "$FORCE_SIMULATOR" = false ]; then
    echo "🔍 Checking for connected physical devices..."
    DEV_LINE=$(xcrun devicectl list devices 2>/dev/null | grep -E 'connected[[:space:]]+.*physical' | head -n 1 || true)
    
    if [ -n "$DEV_LINE" ]; then
        PHYSICAL_DEVICE_ID=$(echo "$DEV_LINE" | grep -oE '[0-9A-Fa-f]{8}-[0-9A-Fa-f]{16}|[0-9A-Fa-f]{40}' || true)
        PHYSICAL_DEVICE_NAME=$(echo "$DEV_LINE" | sed -E 's/[[:space:]]{2,}.*//')
        if [ -n "$PHYSICAL_DEVICE_ID" ]; then
            echo "💡 Found connected physical device: $PHYSICAL_DEVICE_NAME ($PHYSICAL_DEVICE_ID)"
        fi
    fi
fi

# ==========================================
# Branch A: Physical Device Execution
# ==========================================
if [ -n "$PHYSICAL_DEVICE_ID" ]; then
    DESTINATION="id=$PHYSICAL_DEVICE_ID"
    PLATFORM_DIR="iphoneos"
    APP_PATH="$DERIVED_DATA_PATH/Build/Products/${CONFIGURATION}-${PLATFORM_DIR}/nba.app"
    
    echo "📱 Target: Physical Device -> $PHYSICAL_DEVICE_NAME ($PHYSICAL_DEVICE_ID)"
    
    # 1. Build
    if [ "$SKIP_BUILD" = false ] || [ ! -d "$APP_PATH" ]; then
        echo "🔨 Building app for physical device..."
        "$DIR/build.sh" "$CONFIGURATION" "$DESTINATION" "$PLATFORM_DIR"
    else
        echo "⏭️ Skipping build as requested (--no-build)"
    fi
    
    if [ ! -d "$APP_PATH" ]; then
        echo "❌ App bundle not found at: $APP_PATH"
        exit 1
    fi
    
    # 2. Install to Physical Device
    echo "📥 Installing app to device ($PHYSICAL_DEVICE_NAME)..."
    xcrun devicectl device install app --device "$PHYSICAL_DEVICE_ID" "$APP_PATH"
    
    # 3. Launch App
    echo "🚀 Launching $BUNDLE_ID on $PHYSICAL_DEVICE_NAME..."
    xcrun devicectl device process launch --device "$PHYSICAL_DEVICE_ID" "$BUNDLE_ID"
    
    echo "=========================================="
    echo "🎉 App launched successfully on physical device!"
    echo "   Device: $PHYSICAL_DEVICE_NAME"
    echo "   Bundle ID: $BUNDLE_ID"
    echo "=========================================="
    exit 0
fi

# ==========================================
# Branch B: Simulator Execution (Fallback)
# ==========================================
DESTINATION="generic/platform=iOS Simulator"
PLATFORM_DIR="iphonesimulator"
APP_PATH="$DERIVED_DATA_PATH/Build/Products/${CONFIGURATION}-${PLATFORM_DIR}/nba.app"

echo "📱 Target: iOS Simulator"

# 1. Build
if [ "$SKIP_BUILD" = false ] || [ ! -d "$APP_PATH" ]; then
    echo "🔨 Building app for simulator..."
    "$DIR/build.sh" "$CONFIGURATION" "$DESTINATION" "$PLATFORM_DIR"
else
    echo "⏭️ Skipping build as requested (--no-build)"
fi

if [ ! -d "$APP_PATH" ]; then
    echo "❌ App bundle not found at: $APP_PATH"
    exit 1
fi

# 2. Simulator Detection & Selection
echo "🔍 Selecting target simulator..."

SIM_ID=""
SIM_NAME=""

if [ -n "$CUSTOM_DEVICE" ]; then
    SIM_ID=$(xcrun simctl list devices available | grep -E "$CUSTOM_DEVICE \(" | head -n 1 | sed -E 's/.* \(([0-9A-F\-]+)\) .*/\1/')
    SIM_NAME="$CUSTOM_DEVICE"
fi

if [ -z "$SIM_ID" ]; then
    BOOTED_DEVICE_LINE=$(xcrun simctl list devices | grep -E '\(Booted\)' | head -n 1)
    if [ -n "$BOOTED_DEVICE_LINE" ]; then
        SIM_ID=$(echo "$BOOTED_DEVICE_LINE" | sed -E 's/.* \(([0-9A-F\-]+)\) \(Booted\).*/\1/')
        SIM_NAME=$(echo "$BOOTED_DEVICE_LINE" | sed -E 's/^[[:space:]]+//; s/ \([0-9A-F\-]+\).*//')
        echo "💡 Found running simulator: $SIM_NAME ($SIM_ID)"
    fi
fi

if [ -z "$SIM_ID" ]; then
    PREFERRED_LIST=("iPhone 16 Pro" "iPhone 17 Pro" "iPhone 15 Pro" "iPhone 16" "iPhone 15" "iPhone 14 Pro")
    for pref in "${PREFERRED_LIST[@]}"; do
        FOUND_LINE=$(xcrun simctl list devices available | grep -E "$pref \(" | head -n 1)
        if [ -n "$FOUND_LINE" ]; then
            SIM_ID=$(echo "$FOUND_LINE" | sed -E 's/.* \(([0-9A-F\-]+)\) .*/\1/')
            SIM_NAME="$pref"
            break
        fi
    done
fi

if [ -z "$SIM_ID" ]; then
    FALLBACK_LINE=$(xcrun simctl list devices available | grep -E 'iPhone.* \(' | head -n 1)
    if [ -n "$FALLBACK_LINE" ]; then
        SIM_ID=$(echo "$FALLBACK_LINE" | sed -E 's/.* \(([0-9A-F\-]+)\) .*/\1/')
        SIM_NAME=$(echo "$FALLBACK_LINE" | sed -E 's/^[[:space:]]+//; s/ \([0-9A-F\-]+\).*//')
    else
        echo "❌ No available iOS Simulator found. Please check Xcode Simulator settings."
        exit 1
    fi
fi

echo "📱 Target simulator: $SIM_NAME ($SIM_ID)"

# 3. Boot simulator if needed
DEVICE_STATUS=$(xcrun simctl list devices | grep "$SIM_ID" | grep -o "Booted" || true)
if [ "$DEVICE_STATUS" != "Booted" ]; then
    echo "⚡ Booting simulator..."
    xcrun simctl boot "$SIM_ID"
fi

# 4. Bring Simulator UI to front
open -a Simulator

# 5. Terminate existing app process if running
echo "🔄 Terminating any previous instance of $BUNDLE_ID..."
xcrun simctl terminate "$SIM_ID" "$BUNDLE_ID" 2>/dev/null || true

# 6. Install app bundle
echo "📥 Installing app to simulator..."
xcrun simctl install "$SIM_ID" "$APP_PATH"

# 7. Launch app
echo "🚀 Launching $BUNDLE_ID on $SIM_NAME..."
xcrun simctl launch "$SIM_ID" "$BUNDLE_ID"

echo "=========================================="
echo "🎉 App launched successfully on $SIM_NAME!"
echo "   Bundle ID: $BUNDLE_ID"
echo "=========================================="
