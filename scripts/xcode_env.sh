#!/bin/bash
# Xcode 경로 자동 감지 (build.sh / run.sh / deploy.sh / capture_screenshots.sh 가 source 해서 사용)
#
# Xcode 를 새 버전으로 교체(예: Xcode-26.2 삭제 → Xcode-27.1 설치)하면 `xcode-select` 활성 경로가
# /Library/Developer/CommandLineTools 로 떨어져 `xcodebuild` 가 "requires Xcode" 오류로 실패한다.
# DEVELOPER_DIR 이 비어 있고 활성 경로가 Xcode 앱이 아니면 /Applications 의 최신 Xcode 를 DEVELOPER_DIR 로 지정한다.
# 영구 설정은 `sudo xcode-select -s /Applications/Xcode-<버전>.app` 로 한다.

if [ -z "$DEVELOPER_DIR" ]; then
  ACTIVE_DEV_DIR=$(xcode-select -p 2>/dev/null || true)
  case "$ACTIVE_DEV_DIR" in
    *.app/Contents/Developer) ;;  # 이미 Xcode 앱을 가리킴
    *)
      LATEST_XCODE=$(ls -d /Applications/Xcode*.app 2>/dev/null | sort -V | tail -n 1)
      if [ -n "$LATEST_XCODE" ]; then
        export DEVELOPER_DIR="$LATEST_XCODE/Contents/Developer"
        echo "ℹ️  xcode-select 활성 경로가 Xcode 가 아니어서 DEVELOPER_DIR=$DEVELOPER_DIR 로 실행합니다."
        echo "    영구 설정: sudo xcode-select -s $LATEST_XCODE"
      else
        echo "❌ /Applications 에서 Xcode 앱을 찾지 못했습니다. Xcode 를 설치하거나 DEVELOPER_DIR 을 지정하세요."
        exit 1
      fi
      ;;
  esac
fi
