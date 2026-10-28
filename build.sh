#!/bin/bash
set -e

# NBA iOS App Build Script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"

# Xcode 경로 자동 감지 (xcode-select 가 CommandLineTools 를 가리키는 경우 대비)
source "$DIR/scripts/xcode_env.sh"

CONFIGURATION="${1:-Debug}"
DESTINATION="${2:-generic/platform=iOS Simulator}"
PLATFORM_DIR="${3:-iphonesimulator}"

SCHEME="nba"
PROJECT="nba.xcodeproj"
DERIVED_DATA_PATH="$DIR/build/DerivedData"
BUILD_PRODUCTS_DIR="$DERIVED_DATA_PATH/Build/Products/${CONFIGURATION}-${PLATFORM_DIR}"
APP_PATH="$BUILD_PRODUCTS_DIR/nba.app"

echo "=========================================="
echo "🏀 Building NBA App (${CONFIGURATION} Mode)"
echo "=========================================="
echo "📂 Project:     $PROJECT"
echo "🎯 Scheme:      $SCHEME"
echo "📱 Destination: $DESTINATION"
echo "📦 Output:      $BUILD_PRODUCTS_DIR"
echo "------------------------------------------"

xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -destination "$DESTINATION" \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  build

if [ -d "$APP_PATH" ]; then
  echo "------------------------------------------"
  echo "✅ Build succeeded!"
  echo "📱 App bundle: $APP_PATH"
  echo "👉 You can run it with: ./run.sh"
  echo "=========================================="
else
  echo "❌ Build completed but app bundle was not found at $APP_PATH"
  exit 1
fi
