#!/bin/bash

# ==============================================================================
# Apple App Store 필수 2대 규격 (Duo) 스크린샷 자동 캡처 스크립트
#
# 1. 규격 1: 6.7/6.9인치 Super Retina XDR (Dynamic Island 기기)
#    - 권장 디바이스: iPhone 16 Pro Max (1320 x 2868)
#    - 저장 위치: screenshots/iphone_67/
#
# 2. 규격 2: 6.5인치 Super Retina XDR (Notch 기기)
#    - 권장 디바이스: iPhone 11 Pro Max (1242 x 2688)
#    - 저장 위치: screenshots/iphone_65/
# ==============================================================================

set -e

# 색상 정의
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

BUNDLE_ID="com.spearhead.nbaPowerRanking"
APP_PATH="build/derivedData/Build/Products/Debug-iphonesimulator/nba.app"

echo -e "${BLUE}===================================================================${NC}"
echo -e "${BLUE}   🏀 App Store 심사용 2대 규격 (Duo) 스크린샷 자동 캡처 시작   ${NC}"
echo -e "${BLUE}===================================================================${NC}"

# 1. 시뮬레이터 빌드 바이너리 확인 및 필요시 빌드
if [ ! -d "$APP_PATH" ]; then
    echo -e "${YELLOW}>> 시뮬레이터 빌드 바이너리가 없습니다. 빌드를 시작합니다...${NC}"
    xcodebuild -project nba.xcodeproj -scheme nba -configuration Debug \
        -destination "generic/platform=iOS Simulator" \
        -derivedDataPath build/derivedData build -quiet
fi

# 2. 대상 시뮬레이터 UDID 검색 또는 생성
find_or_create_simulator() {
    local device_name="$1"
    local device_type="$2"
    local runtime="$3"

    # 기존 기기 탐색
    local udid
    udid=$(xcrun simctl list devices available | grep "$device_name" | head -n 1 | sed -E 's/.*\(([A-F0-9-]+)\).*/\1/')
    
    if [ -z "$udid" ]; then
        echo -e "${YELLOW}>> '${device_name}' 시뮬레이터를 생성합니다...${NC}"
        udid=$(xcrun simctl create "$device_name" "$device_type" "$runtime")
    fi
    echo "$udid"
}

RUNTIME_18="com.apple.CoreSimulator.SimRuntime.iOS-18-2"

# 6.7/6.9인치 Dynamic Island 기기: iPhone 16 Pro Max
DEVICE_67_UDID=$(find_or_create_simulator "iPhone 16 Pro Max" "com.apple.CoreSimulator.SimDeviceType.iPhone-16-Pro-Max" "$RUNTIME_18")
# 6.5인치 Notch 기기: iPhone 11 Pro Max
DEVICE_65_UDID=$(find_or_create_simulator "iPhone 11 Pro Max (6.5 inch)" "com.apple.CoreSimulator.SimDeviceType.iPhone-11-Pro-Max" "$RUNTIME_18")

echo -e "📱 6.7/6.9인치 타겟 UDID: ${GREEN}$DEVICE_67_UDID${NC}"
echo -e "📱 6.5인치 타겟 UDID:     ${GREEN}$DEVICE_65_UDID${NC}"

# 스크린샷 저장 디렉토리 준비
mkdir -p screenshots/iphone_67 screenshots/iphone_65

capture_device_screenshots() {
    local udid="$1"
    local output_dir="$2"
    local desc="$3"

    echo -e "\n${BLUE}-------------------------------------------------------------------${NC}"
    echo -e "${BLUE}▶ [$desc] 스크린샷 캡처 진행 중... (UDID: $udid)${NC}"
    echo -e "${BLUE}-------------------------------------------------------------------${NC}"

    # 부팅
    xcrun simctl boot "$udid" 2>/dev/null || true
    xcrun simctl bootstatus "$udid" -b

    # 앱 설치
    xcrun simctl install "$udid" "$APP_PATH"

    # 상태바 공식 9:41 AM 및 100% 배터리 설정 (Apple 가이드라인 준수)
    xcrun simctl status_bar "$udid" override --time "9:41" --batteryState charged --batteryLevel 100 --wifiBars 3 --cellularBars 4

    # 1) 파워랭킹 화면 (01_power_ranking.png)
    echo -e "  📸 [1/3] 파워랭킹 화면 캡처 중..."
    xcrun simctl terminate "$udid" "$BUNDLE_ID" 2>/dev/null || true
    xcrun simctl launch "$udid" "$BUNDLE_ID" >/dev/null
    sleep 3
    xcrun simctl io "$udid" screenshot "$output_dir/01_power_ranking.png"

    # 2) 순위표 화면 (02_standings.png)
    echo -e "  📸 [2/3] 순위표 화면 캡처 중..."
    xcrun simctl terminate "$udid" "$BUNDLE_ID" 2>/dev/null || true
    xcrun simctl launch "$udid" "$BUNDLE_ID" -screenshot-standings >/dev/null
    sleep 3
    xcrun simctl io "$udid" screenshot "$output_dir/02_standings.png"

    # 3) 팀 상세 화면 (03_team_detail.png)
    echo -e "  📸 [3/3] 팀 상세 화면 캡처 중..."
    xcrun simctl terminate "$udid" "$BUNDLE_ID" 2>/dev/null || true
    xcrun simctl launch "$udid" "$BUNDLE_ID" -screenshot-team >/dev/null
    sleep 3
    xcrun simctl io "$udid" screenshot "$output_dir/03_team_detail.png"

    # 정리
    xcrun simctl status_bar "$udid" clear
    xcrun simctl terminate "$udid" "$BUNDLE_ID" 2>/dev/null || true

    echo -e "${GREEN}✓ [$desc] 캡처 완료!${NC}"
}

# 캡처 실행
capture_device_screenshots "$DEVICE_67_UDID" "screenshots/iphone_67" "6.7/6.9인치 Dynamic Island"
capture_device_screenshots "$DEVICE_65_UDID" "screenshots/iphone_65" "6.5인치 Notch"

echo -e "\n${BLUE}===================================================================${NC}"
echo -e "${GREEN}✨ 모든 필수 2대 규격 스크린샷 캡처 완료!${NC}"
echo -e "${BLUE}===================================================================${NC}"

echo -e "\n📋 해상도 검증:"
for f in screenshots/iphone_67/*.png screenshots/iphone_65/*.png; do
    dim=$(sips -g pixelWidth -g pixelHeight "$f" 2>/dev/null | awk '/pixel/ {print $2}' | tr '\n' 'x' | sed 's/x$//')
    echo -e "  • $(basename $(dirname "$f"))/$(basename "$f"): ${GREEN}${dim} px${NC}"
done

echo -e "\n✅ 스크린샷 캡처가 성공적으로 종료되었습니다."
