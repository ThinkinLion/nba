# NBA (nbaPowerRanking)

NBA 관련 정보를 제공하는 iOS 애플리케이션 프로젝트입니다.

---

## 🛠️ 빌드 및 실행 스크립트 사용법

Xcode GUI를 직접 실행하지 않고도 터미널 CLI 환경에서 빠르게 빌드하고 시뮬레이터에 배포/테스트할 수 있는 쉘 스크립트를 제공합니다.

### 1. 앱 빌드 (`build.sh`)

`xcodebuild`를 사용하여 iOS 시뮬레이터 타겟용 앱 번들(`.app`)을 빌드합니다.

```bash
# 기본 Debug 모드로 빌드
./build.sh

# Release 모드로 빌드
./build.sh Release
```

- **빌드 산출물 위치**: `build/DerivedData/Build/Products/<Configuration>-iphonesimulator/nba.app`

---

### 2. 시뮬레이터 실행 (`run.sh`)

빌드부터 시뮬레이터 부팅, 앱 설치 및 실행까지 원클릭으로 처리합니다.

```bash
# 1) 기본 실행 (최신 코드 자동 증분 빌드 후 시뮬레이터 실행)
./run.sh

# 2) 빌드 건너뛰고 기존 빌드본 즉시 실행
./run.sh --no-build

# 3) Release 빌드로 실행
./run.sh --release

# 4) 특정 시뮬레이터 기기 지정 실행
./run.sh --device "iPhone 16 Pro"
```

#### 주요 동작 흐름
1. **증분 빌드 (Incremental Build)**: 소스코드 변경 사항이 있으면 빠르게 빌드를 수행합니다. (`--no-build` 옵션으로 생략 가능)
2. **시뮬레이터 자동 감지**: 이미 실행 중인(Booted) 시뮬레이터가 있으면 재활용하고, 없으면 사용 가능한 최신 iPhone 시뮬레이터를 자동으로 부팅합니다.
3. **프로세스 갱신**: 기존에 실행 중이던 앱 인스턴스를 안전하게 종료한 뒤 새 빌드를 설치하고 즉시 실행합니다.

---

## 📱 프로젝트 정보
- **Bundle Identifier**: `com.spearhead.nbaPowerRanking`
- **Xcode Scheme**: `nba`
- **최소 지원 타겟**: iOS 17.6+
