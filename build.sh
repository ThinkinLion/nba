#!/bin/bash
set -e

# NBA iOS App Build Script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"

CONFIGURATION="${1:-Debug}"
SCHEME="nba"
PROJECT="nba.xcodeproj"
DERIVED_DATA_PATH="$DIR/build/DerivedData"
BUILD_PRODUCTS_DIR="$DERIVED_DATA_PATH/Build/Products/${CONFIGURATION}-iphonesimulator"
APP_PATH="$BUILD_PRODUCTS_DIR/nba.app"

echo "=========================================="
echo "🏀 Building NBA App (${CONFIGURATION} Mode)"
echo "=========================================="
echo "📂 Project: $PROJECT"
echo "🎯 Scheme:  $SCHEME"
echo "📦 Output:  $BUILD_PRODUCTS_DIR"
echo "------------------------------------------"

xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -destination 'generic/platform=iOS Simulator' \
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
