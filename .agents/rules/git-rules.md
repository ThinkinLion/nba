# Git 커밋 규칙 (Git Commit Rules)

이 프로젝트에서 Git 작업을 수행할 때는 반드시 다음 규칙을 엄격히 준수합니다.

## 1. 커밋 작성자 정보 (Git Author & Committer)
시스템 전역(Global) 설정 대신, 반드시 다음 **GitHub 전용 계정**을 사용합니다:
- **user.name**: `ThinkinLion`
- **user.email**: `spearhead0427@gmail.com`

## 2. 작업 전 검증
커밋을 생성하기 전, 현재 로컬 Git 설정이 올바른지 확인합니다:
```bash
git config --local user.name "ThinkinLion"
git config --local user.email "spearhead0427@gmail.com"
```

## 3. 커밋 메시지 컨벤션
- `feat:` 새로운 기능 추가
- `fix:` 버그 수정
- `docs:` 문서 수정
- `style:` 코드 스타일/포맷 변경 (로직 변경 없음)
- `refactor:` 코드 리팩토링
- `test:` 테스트 코드 추가 및 수정
- `chore:` 빌드 프로세스, 패키지 매니저, 환경 설정 등 기타 작업
