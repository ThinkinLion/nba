# Power Rank 사용자 성장 계획 (광고 노출 극대화)

작성일: 2026-10-28
대상: Power Rank iOS 앱(com.spearhead.nbaPowerRanking) + NBACrafter 데이터 파이프라인

---

## 0. 결론 요약

광고 수익은 `DAU × 세션/일 × 화면/세션 × 광고 fill × eCPM` 입니다.
이 앱은 **사람을 데려오는 장치(획득)와 다시 부르는 장치(리텐션)가 사실상 하나도 없습니다.**
푸시 알림, 위젯, 딥링크, 리뷰 요청, 다국어, 이벤트 분석, ATT 프롬프트가 전부 없고,
심지어 **데이터 파이프라인이 10/25부터 멈춰 있어 경기 데이터가 10/26에서 정지**해 있습니다.

따라서 순서는 다음과 같습니다.

1. **데이터가 매일 신선하게** (지금 당장, 0순위)
2. **다시 열게 만드는 장치** (푸시 + 위젯) — 스포츠 앱 리텐션의 핵심
3. **찾아오게 만드는 장치** (ASO + 다국어 + 공유 카드/딥링크)
4. **열었을 때 더 많이 보게** (콘텐츠 깊이 + 광고 배치 고도화)

---

## 1. 현재 상태 진단

### 1-1. 제품
| 항목 | 상태 |
|---|---|
| 탭 | Games(스코어·POTN) / Power Ranking(주간·My Teams) / Standings |
| 상세 | 팀 상세, 선수 상세(시즌별 스탯), 경기 리캡, 플레이오프 브래킷 |
| 버전 | 1.0 (build 2) — 2026-27 시즌 리뉴얼 직후, 사실상 신규 론칭 |
| 최소 OS | iOS 17.6+ |
| 디자인 | 다크 테마, 팀 컬러 그라데이션, 글래스모피즘 — 경쟁력 있음 |

**강점**: Player of the Night, 주간 파워랭킹 + My Teams 핀, 팀 컬러 UI는 ESPN·theScore에 없는 차별점.

### 1-2. 성장 인프라 (전부 부재)
| 장치 | 상태 | 영향 |
|---|---|---|
| 푸시 알림 (FCM/APNs) | 없음 | 경기 결과·파워랭킹 발행을 알릴 방법이 없음 → 재방문 전적으로 사용자 기억에 의존 |
| 홈/잠금화면 위젯 | 없음 | 앱을 열지 않아도 보이는 접점 없음 |
| 딥링크/유니버설 링크 | 없음 | 공유 카드가 앱 설치·진입으로 이어지지 않음 |
| 리뷰 요청 (SKStoreReviewController) | 없음 | 별점 수 부족 → 스토어 전환율 저하 |
| 공유 | POTN 카드 이미지만 | 파워랭킹·My Team·선수 카드 공유 없음 |
| 다국어 | en.lproj 하나 | NBA 팬 밀집 시장(필리핀·중국·브라질·프랑스·일본·한국) 미대응 |
| 분석 | 화면 뷰 7개만 | 이벤트(즐겨찾기 추가, 공유, 주차 전환 등) 없음 → 퍼널 측정 불가 |
| ATT 프롬프트 | 없음 (NSUserTrackingUsageDescription 부재) | IDFA 미수집 → iOS eCPM 손실 |
| 광고 단위 | 배너 1종, 단일 adUnitId를 전 화면 공용 | 배치별 eCPM 측정 불가, 네이티브·전면 광고 없음 |

### 1-3. 데이터 파이프라인 (치명)
- crontab 5개 작업이 `NBACrafter/standings.py` 등 **이동 전 경로**를 가리킴 → 10/25 05:00부터 전부 `No such file` 실패
- 결과: `games` 최신 날짜 10/26, 파워랭킹 week-2까지. 스코어 앱에서 데이터 정지는 즉시 이탈 사유
- `crawl_runs` 컬렉션은 있으나 쓰는 코드 없음 → 실패를 알 방법이 없음

### 1-4. 스토어 (ASO)
- 현재 스토어 메타데이터의 앱명이 "NBA Weekly Power Rankings" 중심 — "power rankings"는 검색량이 작은 틈새 키워드
- SKU `NBA_2025_US`로 미국 타깃인데 부제목이 한국어
- "NBA scores", "NBA standings", "NBA stats" 같은 대형 키워드 미공략

### 1-5. 리스크
- 파워랭킹 Overview/Takeaways 본문은 nba.com 편집 콘텐츠를 그대로 수집. 노출이 커질수록 저작권·심사 리스크 상승.
  → 요약·재서술(LLM) 또는 출처 표기 + 분량 제한을 성장 전에 정리 권장.

---

## 2. 실행 계획

### Phase 0 — 이번 주: 데이터 신선도 복구 + 측정 기반 (각 0.5~1일)

**P0-1. crontab 경로를 통합 CLI로 교체** (최우선)
```
# 제안 (python 경로는 venv에 맞게 조정)
0 5,23 * * *  cd /Users/a1100690/Documents/py/NBACrafter/nba && python cli.py standings
30 23 * * *   cd /Users/a1100690/Documents/py/NBACrafter/nba && python cli.py games --headless
0 0 * * *     cd /Users/a1100690/Documents/py/NBACrafter/nba && python cli.py leaders
30 22 * * *   cd /Users/a1100690/Documents/py/NBACrafter/nba && python cli.py team --all --headless
0 22 * * *    cd /Users/a1100690/Documents/py/NBACrafter/nba && python cli.py roster --delta --headless
0 6 * * 2     cd /Users/a1100690/Documents/py/NBACrafter/nba && python cli.py power-ranking --week auto
```
- `games`는 이미 누락 날짜 자동 백필 → 10/27 이후 바로 복구됨
- `roster --delta`로 전날 출전 선수만 갱신(전체 로스터 매일 도는 것보다 빠름)

**P0-2. 크롤 실행 결과를 `crawl_runs`에 기록 + 실패 알림**
- cli.py 각 서브커맨드 종료 시 `{job, startedAt, ok, counts, error}` 저장
- 실패 시 Slack/텔레그램 webhook 1줄. 앱 쪽 Remote Config로 "데이터 지연" 배너 노출 가능

**P0-3. ATT 프롬프트 + UMP 동의 플로우** (이미 UMP 패키지 포함)
- `NSUserTrackingUsageDescription` 추가, 첫 세션 2번째 화면 진입 시 요청
- iOS 광고 eCPM 개선 효과가 가장 큰 1일짜리 작업

**P0-4. 광고 단위 분리 + 이벤트 분석**
- adUnitId를 `games_list / pr_list / pr_detail / team / player / recap`으로 분리 → 배치별 eCPM·CTR 비교
- Analytics 이벤트: `favorite_add`, `share_card`, `week_switch`, `season_switch`, `potn_tap`, `push_optin`
- KPI 대시보드(Firebase): DAU, D1/D7/D30, 세션/DAU, 광고 노출/DAU

**P0-5. 리뷰 요청**
- "긍정 순간" 트리거: 3번째 세션 이상 + 파워랭킹 상세 또는 My Team 핀 완료 직후. 연 3회 제한 준수

### Phase 1 — 2~4주차: 다시 열게 만드는 장치

**P1-1. 푸시 알림 (FCM 토픽 기반, 서버 전송은 크롤러가 담당)**
| 알림 | 트리거 | 토픽 |
|---|---|---|
| My Team 경기 종료 결과 | `games` 크롤 완료 직후 | `team_{teamId}` |
| Player of the Night | 매일 games 크롤 후 | `potn` |
| 주간 파워랭킹 발행 + My Team 순위 변동 | power-ranking 크롤 후 | `power_ranking`, `team_{teamId}` |
| My Team 오늘 경기 있음 (경기 3시간 전) | 일정 데이터 필요 | `team_{teamId}` |
- 온보딩에서 "팀 고르기 → 알림 켜기"를 한 흐름으로. 팀 선택이 곧 토픽 구독
- 스포츠 앱에서 푸시 옵트인 사용자는 D30 리텐션이 비옵트인 대비 2~3배가 일반적

**P1-2. WidgetKit 위젯 (3종부터)**
- Small: My Team 최근 결과 + 순위·전적
- Medium: 컨퍼런스 Top 8 또는 파워랭킹 Top 5 (주차 표기)
- 잠금화면(accessory): My Team 다음 경기 / 어제 결과
- 데이터는 App Group + 백그라운드 리프레시(일 4회), 탭 시 딥링크로 해당 팀 진입

**P1-3. 온보딩 1화면**
- "응원 팀 선택(복수) → 알림 허용" 2스텝. 현재는 My Teams 기능이 묻혀 있음

**P1-4. 개인화의 거점 = Games 탭을 "Today" 홈 피드로 재편 (탭 추가 없음, 사이드 메뉴 없음)**

결정 근거
- 사이드 메뉴(햄버거)는 iOS HIG가 권하지 않는 패턴이고 발견성이 낮아 스포츠 앱(theScore, ESPN, NBA 공식)은 모두 "홈 = 개인화 피드 + 우상단 프로필 버튼" 구조를 씀
- 현재 Games 탭은 "어제 결과 스코어보드"라 ESPN보다 느리고 나을 게 없음. 가치는 원시 스코어가 아니라 **큐레이션 + 개인화**에 있어야 함
- 탭은 3개 유지: **Today(홈) / Power Ranking / Standings**. 즐겨찾기·알림 관리는 우상단 프로필 버튼 → 시트. 팀·선수 상세에는 ★ 팔로우 버튼

Today 피드 모듈 (위에서 아래, 각 모듈은 독립 컴포넌트로 순서·노출을 Remote Config로 제어)

| # | 모듈 | 내용 | 데이터 |
|---|---|---|---|
| 1 | 날짜 스트립 + 프로필 | 기존 캘린더 스트립 유지, 우상단 프로필(팀·선수·알림 설정 시트) | - |
| 2 | My Teams | 팀 카드 가로 스크롤: 어제 결과 / 다음 경기 / 전적·시드 / PR 순위 변동. 비어 있으면 "팀 고르기" CTA(=온보딩) | games, standings, powerRankings |
| 3 | Games | My Team 경기를 맨 앞에, 나머지는 컴팩트 카드 | games |
| 4 | Performance of the Night | 유지. 내 선수가 뽑히면 강조 + "시즌 PPG 리그 3위" 맥락 | games, statsLeaders |
| 5 | Movers | 파워랭킹 주간 상승/하락 Top 3, 내 팀 변동 강조 → PR 탭으로 진입 | powerRankings |
| 6 | League Leaders | 카테고리 3~4개를 날마다 로테이션(PPG·REB·허슬·루키 등), 내 선수 위치 표시 | statsLeaders |
| 7 | My Picks (Phase 3) | 오늘 경기 승자 예측, 적중률·연승 | 신규 |
| 8 | Weekly Digest (일요일) | 내 팀·내 선수 주간 요약 카드 → 공유 | 집계 |

- 네이티브 광고는 모듈 3과 5 사이, 6 아래 두 슬롯
- 위젯은 모듈 2·3의 축소판, 푸시 토픽은 프로필 시트의 알림 설정과 1:1 → 푸시·위젯·공유가 모두 Today로 착지
- 저장: `FavoritesManager`(UserDefaults, 팀 코드 Set)를 선수까지 확장. 로그인 없음, 추후 iCloud KV
- 커뮤니티 기능 없음. 글쓰기 없는 투표만 집계 노출

**P1-5. 리그 리더 데이터를 기존 콘텐츠에 녹이기 (StatsView는 레거시, 재사용하지 않고 폐기)**
- `cli.py leaders`가 매일 `statsLeaders.{season}`에 40여 카테고리(PPG·루키·허슬·트래킹·포지션별 등)를 저장하지만, 소비하던 `StatsView`는 3탭 개편 때 진입 경로가 끊긴 레거시. 새 모듈로 대체하고 StatsView·관련 ViewModel 슬롯 코드는 삭제
- 녹이는 위치
  - **선수 상세**: PPG/RPG/APG 카드 옆에 리그 순위 배지("24.5 · 리그 7위"), 카테고리 1위면 리본("PITP 리그 1위")
  - **팀 상세**: "이 팀의 리그 리더" 행 (소속 선수가 Top 10에 든 카테고리)
  - **파워랭킹 Players to Watch 카드**: 리더 순위 배지
  - **Today 피드**: League Leaders 모듈(위 표 6), POTN 맥락(위 표 4)
  - **공유 카드**: "Sengun PITP 리그 1위" 같은 선수 리더 카드 → 획득 채널 재료
- 데이터 준비 (구현 완료, 크롤러 변경 없음): `statsLeaders` 문서는 카테고리 → Top 5 선수 구조라 선수 기준 역인덱스가 없지만, 47 × 5 = 235건뿐이라 앱의 `LeadersStore` 가 문서 하나를 읽어 메모리에서 "선수 → [카테고리·순위·값]" 로 뒤집음. Today·선수 상세·팀 상세·Players to Watch 가 공유하며 Firestore 읽기는 세션당 1회(24h 캐시)
- 보류: "리그 7위" 같은 Top 5 밖 전체 순위는 현재 소스(리더보드 카드)로는 불가. 필요해지면 크롤러가 nba.com/stats/players 전체 표를 긁어 핵심 지표 전체 순위를 선수별 문서(`playerLeaderRanks.{season}/{playerId}`)로 저장하는 별도 작업이 필요

### Phase 2 — 5~8주차: 찾아오게 만드는 장치

**P2-1. ASO 전면 개편**
- 앱명: `Power Rank: NBA Scores & Rankings` (대형 키워드 "scores" 앞쪽 배치)
- 부제목(영문): `Standings, Stats, Power Rankings`
- 키워드 필드 100자: `nba,basketball,scores,standings,stats,power rankings,player,team,schedule,playoffs`
- 스크린샷 첫 장을 "오늘의 스코어 + POTN"으로 (현재 파워랭킹 중심)
- 첫 달 Apple Search Ads 소액 테스트(일 $5~10): "nba power rankings", "nba standings" 정확 매치로 전환율 데이터 확보

**P2-2. 다국어 (UI는 라벨이 적어 비용 낮음)**
- 1차: ko, es-MX, pt-BR, fr, ja, zh-Hans, fil(필리핀은 en 유지, 스토어 메타만 현지화)
- 스토어 메타데이터 현지화가 UI 번역보다 효과가 먼저 나옴 → 메타부터

**P2-3. 공유 카드 + 유니버설 링크**
- 공유 가능 카드: 주간 파워랭킹 Top 10, My Team 순위 변동(▲3), 선수 시즌 스탯, POTN(기존)
- 카드 하단에 앱 이름 + 짧은 링크(`<앱 도메인>/t/{teamId}`) 워터마크
- 유니버설 링크 수신 → 팀/선수/주차로 직접 진입. 링크 랜딩 페이지는 Firebase Hosting 정적 페이지
- 운영 루틴: 매주 파워랭킹 발행일에 r/nba·X에 Top 10 카드 게시(무료 채널)

**P2-4. 웹 SEO 페이지 (저비용 유입)**
- Firestore 데이터로 `/{season}/week-{n}` 정적 페이지 생성(파워랭킹 요약 + 순위표). "nba power rankings week 5" 검색 유입 → 앱 링크
- 저작권 리스크 때문에 본문 원문은 싣지 않고 순위·스탯·한 줄 요약만

### Phase 3 — 9~12주차: 더 오래, 더 많이 보게

**P3-1. 광고 배치 고도화**
- Games 리스트·파워랭킹 리스트에 네이티브 광고(5~6번째 셀) — 배너보다 eCPM 2~4배
- GameRecap 이탈 시 전면 광고, 세션당 1회·첫 세션 제외 캡
- App Open 광고는 리텐션 영향이 커서 D7 안정화 후 A/B
- AdMob 미디에이션 추가(AppLovin, Unity)로 fill·eCPM 경쟁

**P3-2. 콘텐츠 깊이 (세션당 화면 수 ↑)**
- 일정/캘린더 뷰 + "캘린더에 추가"
- 선수 비교(2인), 팀 맞대결(H2H) 카드
- 시즌 후반: 플레이오프 시드 경쟁 / 매직 넘버 / 트레이드 데드라인 특집 배너
- POTN 주간·월간 리더보드(누적) — 고유 콘텐츠 강화

**P3-3. 라이브 스코어 / Live Activities (조건부)**
- 현재 크롤러는 일 1회. 실시간 소스(nba.com cdn JSON) 확보 시 Dynamic Island로 경기 중 접점 확보. 효과는 크지만 인프라 부담이 커서 Phase 1·2 지표 확인 후 결정

**P3-4. Android (장기)**
- TAM 2~3배 확대이나 SwiftUI 코드 재사용 불가. KMP 또는 Flutter 재작성은 Phase 2 이후 트래픽이 검증되면 검토

---

## 3. 목표 지표 (12주)

| 지표 | 현재 | 12주 목표 |
|---|---|---|
| 데이터 지연 | 2일+ (파이프라인 정지) | 경기 종료 후 1시간 내 |
| 푸시 옵트인율 | 0% (기능 없음) | 45%+ |
| D7 리텐션 | 측정 불가 | 20%+ |
| 세션/DAU | 측정 불가 | 2.0+ |
| 광고 노출/DAU | 측정 불가 | 6+ |
| 스토어 평점 수 | - | 100+ |

---

## 4. 바로 다음 액션 (오늘)

1. crontab 5줄을 Phase 0-1 내용으로 교체 → `games` 백필로 10/27~ 복구 확인
2. `crawl_runs` 기록 + 실패 webhook 추가
3. ATT 키 + UMP 동의 플로우 PR
4. 광고 단위 분리 + Analytics 이벤트 PR
5. 푸시 설계(토픽 구조, 전송 주체) 확정 후 Phase 1 착수
