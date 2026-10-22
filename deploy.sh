#!/bin/bash
set -e

# ==============================================================================
# NBA iOS App - App Store Connect 원클릭 자동 배포 스크립트
# ==============================================================================

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"

# 프로젝트 설정
SCHEME="nba"
PROJECT="nba.xcodeproj"
EXPORT_OPTIONS_PLIST="$DIR/ExportOptions.plist"
BUILD_DIR="$DIR/build"
ARCHIVE_PATH="$BUILD_DIR/nba.xcarchive"
IPA_PATH="$BUILD_DIR/nba.ipa"

# App Store Connect API 인증 정보
API_KEY="N8H3XA3PY5"
API_ISSUER="69a6de82-3793-47e3-e053-5b8c7c11a4d1"

# 실행 플래그 기본값
BUMP_VERSION=true
DO_UPLOAD=true
DO_VALIDATE_ONLY=false

# CLI 옵션 파싱
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --no-bump)
            BUMP_VERSION=false
            shift
            ;;
        --validate-only)
            DO_VALIDATE_ONLY=true
            DO_UPLOAD=false
            shift
            ;;
        --skip-upload|--dry-run)
            DO_UPLOAD=false
            shift
            ;;
        -h|--help)
            echo "=================================================================="
            echo "🚀 NBA iOS App Store 배포 스크립트 (deploy.sh)"
            echo "=================================================================="
            echo "사용법: ./deploy.sh [옵션]"
            echo ""
            echo "옵션:"
            echo "  (기본 실행)        빌드 번호 +1 증가 ➔ Release 아카이브 ➔ IPA 추출 ➔ App Store Connect 업로드"
            echo "  --no-bump          빌드 번호(CURRENT_PROJECT_VERSION)를 증가시키지 않고 유지"
            echo "  --validate-only    업로드하지 않고 App Store Connect 유효성 검증만 수행"
            echo "  --skip-upload      IPA 빌드까지만 수행하고 업로드/검증 단계 건너뜀 (로컬 테스트용)"
            echo "  -h, --help         도움말 출력"
            echo "=================================================================="
            exit 0
            ;;
        *)
            echo "❌ 알 수 없는 옵션: $1"
            echo "도움말 확인: ./deploy.sh --help"
            exit 1
            ;;
    esac
done

echo "=================================================================="
echo "🚀 Starting App Store Deployment Pipeline"
echo "=================================================================="
echo "📂 Project:        $PROJECT"
echo "🎯 Scheme:         $SCHEME"
echo "🔑 Key ID:         $API_KEY"
echo "🏢 Issuer ID:       $API_ISSUER"
echo "------------------------------------------------------------------"

# 0. API 키 파일 존재 확인
KEY_PATH="$HOME/.appstoreconnect/private_keys/AuthKey_${API_KEY}.p8"
if [ ! -f "$KEY_PATH" ]; then
    echo "❌ API Key file not found at: $KEY_PATH"
    echo "👉 Please place your AuthKey_${API_KEY}.p8 file into ~/.appstoreconnect/private_keys/"
    exit 1
fi
echo "🔑 Verified API Key: $KEY_PATH"

# 1. 빌드 번호 +1 자동 증가
if [ "$BUMP_VERSION" = true ]; then
    OLD_VERSION=$(agvtool what-version -terse 2>/dev/null || echo "1")
    echo "🔢 Current Build Number: $OLD_VERSION"
    echo "⬆️  Incrementing build number (+1)..."
    agvtool next-version -all > /dev/null
    NEW_VERSION=$(agvtool what-version -terse 2>/dev/null || echo "unknown")
    echo "✅ New Build Number: $NEW_VERSION"
else
    CURRENT_VERSION=$(agvtool what-version -terse 2>/dev/null || echo "1")
    echo "ℹ️  Keeping current build number: $CURRENT_VERSION (--no-bump)"
fi

# 2. 빌드 디렉토리 준비
mkdir -p "$BUILD_DIR"
rm -rf "$ARCHIVE_PATH" "$IPA_PATH"

# 3. Release Archive 생성
echo "------------------------------------------------------------------"
echo "📦 Step 1: Archiving project for Release..."
echo "------------------------------------------------------------------"
xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath "$ARCHIVE_PATH" \
  archive \
  | xcpretty 2>/dev/null || xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath "$ARCHIVE_PATH" \
  archive

if [ ! -d "$ARCHIVE_PATH" ]; then
    echo "❌ Archiving failed! Archive directory not found: $ARCHIVE_PATH"
    exit 1
fi
echo "✅ Archive created at: $ARCHIVE_PATH"

# 4. IPA 추출 (Export Archive)
echo "------------------------------------------------------------------"
echo "📱 Step 2: Exporting IPA for App Store distribution..."
echo "------------------------------------------------------------------"
xcodebuild \
  -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$BUILD_DIR" \
  -exportOptionsPlist "$EXPORT_OPTIONS_PLIST"

# 추출된 ipa 파일 확인 (Scheme 이름 기반 nba.ipa)
if [ ! -f "$IPA_PATH" ]; then
    # 다른 이름으로 추출된 ipa가 있는지 탐색
    FOUND_IPA=$(find "$BUILD_DIR" -maxdepth 1 -name "*.ipa" | head -n 1)
    if [ -n "$FOUND_IPA" ]; then
        IPA_PATH="$FOUND_IPA"
    else
        echo "❌ Export failed! No IPA file found in: $BUILD_DIR"
        exit 1
    fi
fi
echo "✅ IPA created successfully: $IPA_PATH"
ls -lh "$IPA_PATH"

# 5. App Store Connect 유효성 검증 (Validation)
if [ "$DO_UPLOAD" = true ] || [ "$DO_VALIDATE_ONLY" = true ]; then
    echo "------------------------------------------------------------------"
    echo "🔍 Step 3: Validating IPA with App Store Connect..."
    echo "------------------------------------------------------------------"
    xcrun altool \
      --validate-app \
      -f "$IPA_PATH" \
      -t ios \
      --apiKey "$API_KEY" \
      --apiIssuer "$API_ISSUER"
    
    echo "✅ App Store Connect validation passed!"
fi

# 6. App Store Connect 업로드 (Upload)
if [ "$DO_UPLOAD" = true ]; then
    echo "------------------------------------------------------------------"
    echo "🚀 Step 4: Uploading IPA to App Store Connect..."
    echo "------------------------------------------------------------------"
    xcrun altool \
      --upload-app \
      -f "$IPA_PATH" \
      -t ios \
      --apiKey "$API_KEY" \
      --apiIssuer "$API_ISSUER"
    
    echo "=================================================================="
    echo "🎉 SUCCESS: App successfully uploaded to App Store Connect!"
    echo "📱 Build Number:   $(agvtool what-version -terse 2>/dev/null || echo '')"
    echo "🌐 TestFlight:      https://appstoreconnect.apple.com/apps"
    echo "⏱️  Processing:     애플 서버에서 빌드 처리가 완료되면(약 5~15분) TestFlight에 노출됩니다."
    echo "=================================================================="
elif [ "$DO_VALIDATE_ONLY" = true ]; then
    echo "=================================================================="
    echo "✅ Validation complete! (--validate-only: 업로드는 건너뛰었습니다)"
    echo "=================================================================="
else
    echo "=================================================================="
    echo "✅ Build complete! (--skip-upload: IPA가 로컬 $IPA_PATH 에 생성되었습니다)"
    echo "=================================================================="
fi
