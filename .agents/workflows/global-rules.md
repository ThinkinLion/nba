---
description: 글로벌 코딩 규칙 및 컨벤션 (Global Rules)
---

이 작업 공간에서 코드를 작성하거나 수정할 때, AI는 항상 다음 규칙을 준수해야 합니다.

### 1. 언어 및 프레임워크
- 기본적으로 **Swift**를 사용하며, 최신 문법과 가이드라인을 따릅니다.
- UI 구성 시 특별한 이유가 없다면 **SwiftUI**를 최우선으로 사용합니다.

### 2. 아키텍처 (Architecture)
- **MVVM (Model-View-ViewModel)** 패턴을 권장합니다.
- View는 UI 렌더링에만 집중하고, 상태 관리 및 비즈니스 로직은 ViewModel이 담당하도록 명확히 분리합니다.

### 3. 네이밍 컨벤션 (Naming Conventions)
- 변수, 상수, 함수, 프로퍼티: `lowerCamelCase`
- 클래스, 구조체, 열거형, 프로토콜: `UpperCamelCase`
- 이름은 줄임말을 남발하기보다 의도를 명확히 알 수 있도록 서술적으로 작성합니다.

### 4. 안전성과 코드 품질 (Safety & Code Quality)
- 강제 언래핑(`!`)은 최대한 지양하고, `guard let` 또는 `if let`을 이용해 안전하게 옵셔널 값을 처리합니다.
- 하드코딩된 문자열(String)과 매직 넘버는 가급적 배제하고, `Constants`나 열거형(Enum)으로 관리합니다.

### 5. 응답 및 문서 언어
- 주석, 코드 내 설명, 그리고 **실행 계획(Implementation Plan)**을 포함한 모든 작업 내역과 문서화는 **한국어**로 명확하게 작성합니다.
