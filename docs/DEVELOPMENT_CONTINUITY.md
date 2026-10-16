# CAP — AI 도구 간 지속 개발 로그

> Claude Code 및 향후 Codex 복귀 시 공용 문서. 최신 로컬 코드와 실제 검증이 우선이다.

## 인수인계 기준 — 2026-10-16
- GitHub `main`: `122ffb137edcd007424fbda0d11edabfe41c0052` (직접 확인, M5-A).
- 로컬 **M5-B T04**: 사용자 보고상 구현 완료, `git add/commit/push` 미실행. `scenes/playtests/t04_playtest.tscn` 및 `docs/m5_b_t04_temp_case.md` 확인 필수.
- M5-A 및 FACILITY CONTROL은 F5 기본 UI와 분리된 F6 테스트 시안. T04는 TEMP/DRAFT/NON-CANON.
- 다음 추천: M5-B 작업트리 백업 → F6 사용자 수동 플레이 → 부족한 CCTV Anchor / T04 실험 결과/Incident 이미지 준비 및 기존 Texture 슬롯으로 교체 → 실제 이미지로 UI 가독성 점검. 승인 없이는 정식 Campaign/Ending 편입 금지.

## 작업 기록 (최신이 위)

### 2026-10-16 — UI-T3 / 사고보고서 종이화 + 내부 ID 노출 정리 (Claude Code)
- 수정:
  - `scripts/presentation/t04_presentation.gd`: 보고서 종이 패널, 종이 스크롤바(보고서와 Profile), 보고서 라벨 접두어 제거.
  - `tools/build_release_theme.gd`: PaperVScrollBar 추가 → Theme 재생성.
  - `scripts/data/cctv_data.gd`: 선택 필드 `camera_label`, `get_display_name()`.
  - `scripts/views/cctv_view.gd`: 표시명 사용, `is_displaying_cctv`도 표시명으로 비교.
  - `resources/cases/temp_t04_case.tres`: `camera_label` 추가, Research 23개 `title`을 한국어로 변경.
- 호환: `camera_label`이 비어 있으면 기존 동작. ID, 해금 규칙, 저장 서명 변경 없음(title과 camera_label은 서명 밖).
- 검증:
  - verify PASS(74 scripts).
  - 로컬 여정 스크립트로 ROOM B 경로를 GPU 1280에서 실행: CCTV Research 발견 정상. 실패는 옛 기대값 `honest_cctv` 1건뿐.
  - T04, M5-A, M4.5, M2 headless 시작 exit 0. 화면 19장: `docs/screenshots/ui_release_theme/`.
- 미검증: 1920 해상도의 보고서와 Archive. F5에서 camera_label 미사용 경로의 GPU 화면(코드상 fallback만 확인).
- Git: 커밋 안 함.
- 다음 우선순위 하나: 남은 UI 문제(헤더 부제 줄바꿈, 선택 Case 글자 크기)를 정리하고, 출시용 Theme을 F5 기본 구조로 옮길지 결정한다.

### 2026-10-16 — UI-T2 / 나머지 화면 점검 + TEMP 배지 통합 (Claude Code)
- 수정:
  - `scripts/presentation/t04_presentation.gd`: TEMP BUILD 배지와 툴팁에 안내문 통합, 표시 전용 [임시] 접두어 제거, Archive 선택 Case 호박색 표시.
  - `tools/build_release_theme.gd`: TempBadgeButton type 추가 → `release_instrument_steel_theme.tres` 재생성.
  - 문서: `docs/ui_release/art_direction_v1.md`, `docs/screenshots/ui_release_theme/`(총 18장).
- 범위: T04 F6 프리뷰에만 적용. F5, M4.5, M5-A는 그대로. 데이터, 판정, 저장 변경 없음.
- 검증:
  - 로컬 여정 스크립트로 ROOM B 경로 전체를 GPU 1280에서 실행했다. 실패는 옛 기대값 `honest_cctv` 1건(M5-B.1에서 의도적으로 바뀐 부분)뿐이다.
  - verify PASS. T04, M5-A, M4.5 headless 시작 exit 0.
- 미검증: 1920 해상도의 방송, 보고서, Archive 화면. 배지 툴팁의 실제 마우스 표시. 사람의 가독성 평가.
- 남은 문제 6개: art_direction_v1.md 참고. 사고보고서 종이화, 헤더 부제 줄바꿈, Research ID 제목, 카메라 ID, 종이 스크롤바, 선택 Case 버튼 글자 크기.
- Git: 커밋 안 함.
- 다음 우선순위 하나: 사고보고서를 종이 문서형으로 바꾸고, 내부 ID 노출(Research 제목, 카메라명)을 정리한다.

### 2026-10-16 — UI-T1 / 출시용 Theme 1차: 글꼴 동봉 + 재질 StyleBox (Claude Code)
- 승인:
  - 글꼴 다운로드(사용자 승인): Google Fonts 공식 저장소의 OFL 1.1 글꼴 7개와 라이선스 3개.
  - 시안 방향으로 Theme 구축 시작.
- 추가 파일:
  - `assets/fonts/release/`(ttf 7개, OFL 3개, CREDITS.md).
  - `assets/ui/release/`(생성 텍스처 10개, README).
  - `tools/build_release_theme.gd`(생성기, export 제외 폴더).
  - `resources/ui/release_instrument_steel_theme.tres`.
  - `docs/screenshots/ui_release_theme/` 10장.
- 수정: `scripts/presentation/t04_presentation.gd`(`_make_theme()`이 출시용 Theme을 반환). T04 F6에만 적용. 기존 temp Theme과 F5는 그대로.
- 검증:
  - verify PASS(import, 74 scripts, Main 시작).
  - T04, M5-A, M4.5 headless 시작 exit 0.
  - GPU 캡처(1280×720, 약 1886px)로 한글 글꼴, 재질, 키 상태 표시를 확인.
- 미검증: 방송, 사고보고서, Archive, 모달 화면의 새 Theme 적용 모습. 사람의 가독성 평가.
- 남은 일:
  - 종이 위 스크롤바 전용 스타일.
  - 내부 ID와 [임시] 표기 정리(TEMP 배지).
  - 출시 빌드에 OFL 텍스트 동봉.
- Git: 커밋 안 함.
- 다음 우선순위 하나: 방송, 사고보고서, Archive, 모달까지 새 Theme 적용 상태를 점검하고 TEMP 배지를 통합한다.

### 2026-10-16 — UI-AD1 / 출시용 아트 디렉션 시안 (Claude Code)
- **[APPROVED]** 출시용 UI 기준 구조 = FACILITY CONTROL(사용자 결정). F5 Main에는 아직 적용하지 않음.
- 산출물:
  - 디자인 캔버스 https://claude.ai/artifact/SCAxrErPPr9WFetkkh2251 — 스타일 시트, CCTV, Profile, 격리 비교, 방송 송출(비공개).
  - 요약과 필요 에셋 목록: [docs/ui_release/art_direction_v1.md](ui_release/art_direction_v1.md).
- 코드, Resource, Scene 변경 없음. 캔버스 CCTV 화면에 TEMP 합성 이미지를 사용함(증거 아님 표기 포함).
- 발견: 현재 Theme이 시스템 글꼴(맑은 고딕)에 의존해 출시 빌드에 동봉할 수 없음. 타이틀, 설정, 일시정지, 크레딧 화면도 없음.
- Git: 커밋 안 함.
- 다음 우선순위 하나: 시안 피드백 → 출시용 Theme 구축(글꼴 동봉, 재질 StyleBox).

### 2026-10-16 — M5-B.2 / T04 추론 재조정 (Claude Code)
- 기준: `aae16a2` + 미커밋 M5-B.1·R1. 변경 전 `temp_t04_case.tres` sha256 `3f6587…1514`(scratchpad 백업).
- 승인된 결정(사용자):
  - 초안대로 적용. Q01 정답은 "발밑만 비춤" 안.
  - ROOM C 이름을 "흡음 패널 격리실"로 변경.
  - ROOM B 점검 패널 사전 노출은 넣지 않음.
- 수정 파일:
  - `resources/cases/temp_t04_case.tres`: 텍스트 필드와 방송 options 표시 순서만 변경. CCTV 관찰문, 격리 후보 3개 설명과 ROOM C 표시명, ECHO 안내문, 실험 결과 5개, 방송 선택지 8개, 송출 원고 16개, 사고 결과 16개(description / facility_damage / additional_observation).
  - `scripts/presentation/t04_presentation.gd`: 격리 안내문 "내부 흡음" → "내부 잔향".
  - 문서: `docs/content_drafts/t04/t04_m5b2_revision_draft.md`(적용 기록), `t04_implementation_review.md`(이전 표 표시), `docs/m5_b_t04_temp_case.md`, `docs/screenshots/m5_b2/` 8장.
- 바뀌지 않은 것: ID, 판정, Research/Archive/Profile/Incident/경고 블록(바이트 동일 검사), 해금 규칙, 피해 UNKNOWN, 사용자 원문.
- 실제 검증:
  - Godot 데이터 점검 전 항목 PASS: 비대상 36블록 동일, Campaign/Broadcast validation, 16개 고유 결과, UNKNOWN 16/16, 정답 위치.
  - `verify_project.ps1` PASS. T04 headless 시작 exit 0.
  - GPU 캡처 2해상도(CCTV, ECHO, COMBINED, 격리).
- 미검증: ROOM B 방송·결과 화면 실물 확인, 사람의 체감 난이도(특히 LIGHT·LOWSTIM·AIR 조합).
- 저장: 방송 텍스트가 T04 signature에 포함되므로 변경 전 T04 세이브는 불러올 수 없다. 적용 시점에 T04 세이브는 없었다.
- 수치(잔향 1.1/2.4/0.4초, 차음 35/35/55dB, 실험 접촉·회복 값)는 게임 비교값이며 TEMP/DRAFT다.
- Git: 커밋 안 함.
- 다음 우선순위 하나: 사용자가 F6에서 T04를 세 경로로 직접 플레이하고 "언제 정답을 알았는지"와 방송 판단의 체감을 피드백한다.

### 2026-10-16 — R1 / 독립 게임 설계 평가 (Claude Code, 코드 수정 없음)
- 산출물: [docs/design_review/2026-10-16_independent_design_review.md](design_review/2026-10-16_independent_design_review.md). 코드·Resource·기획 원문 변경 없음.
- 핵심 판단 [평가]: T04 CCTV 문장과 격리 설명이 정답을 직접 서술하고, 실험이 CCTV를 반복하며, 방송 정답이 형식만으로 드러나고, 결과 16개가 3종 문장으로 수렴함. 지연 결과·사고 뒤 복귀하는 업무가 TEST 자리표시 Case이고, Archive 제목이 내부 ID로 표시됨.
- 추천 다음 묶음(승인 필요): M5-B.2 T04 추론 재조정. CCTV·격리 문구 재배분, 실험 수치와 격리 속성 값, 방송 선택지와 결과 흔적 재작성, Archive 한국어 제목.
- 미검증: 사람 플레이 없음. 플레이타임은 추정. 외부 게임 정보는 리뷰·인터뷰·위키 기반.
- Git: 커밋 안 함.

### 2026-10-16 — M5-B.1 / T04 임시 합성 이미지 제작·연결 (Claude Code)
- 기준 HEAD / 브랜치 / 변경 전 미커밋: `aae16a2` / `master`→`origin/main` / 사용자 README 편집 + 인계 문서·T04 입력 자료(untracked).
- 실행한 작업과 수정 파일:
  - 신규 `tools/t04_temp_composite.ps1`(PowerShell 5.1 + .NET System.Drawing, 고정 시드). 신규 `assets/temp/t04/generated/` PNG 6장과 `.import` 파일. 신규 `docs/screenshots/m5_b1/` 캡처 4장.
  - 수정 `resources/cases/temp_t04_case.tres`: Texture ext_resource 6개 추가, `feed_texture` 1개·`result_texture` 5개 연결, CCTV 관찰문 첫 문장을 "합성 임시 이미지 · 실제 감시 영상 아님"으로 교체. Gameplay 필드 변경 없음. LF 유지.
  - 수정 `scripts/presentation/t04_presentation.gd`: T04 전용 TEMP 합성 안내 문구. 다른 Case는 기존 문구 그대로.
  - 수정 `assets/temp/t04/ASSET_PROVENANCE.md`, `manifest.json`(`generated_composites`), `docs/m5_b_t04_temp_case.md` 한 문단.
- 승인된 결정 / 임시로 남은 결정:
  - 승인: 사용자가 "임시 이미지 제작 및 사용"을 요청.
  - 임시로 남음: 합성본은 TEMP COMPOSITE / NOT EVIDENCE이고 정식 이미지가 오면 같은 슬롯에서 교체한다. 포즈는 Master 그대로이며, 실험별 차이는 조명 처리와 OSD뿐이다.
- 실제 검증:
  - `verify_project.ps1` 작업 전후 모두 PASS: import, 74 scripts, Main 시작.
  - T04, M5-A, M4.5 구조 Scene을 headless로 시작했고 모두 exit 0, ERROR/WARNING 없음.
  - 실제 GPU 창 1280×720과 약 1886×1061에서 일회용 scratchpad 스크립트로 캡처했다(1920 요청이 화면 크기 때문에 줄어듦). Profile→CCTV→실험(LIGHT, LOWSTIM 선택→실행) 순서. 실행 전 이미지 없음, 실행 후 해당 이미지만 표시, 선택을 바꾸면 이미지도 바뀜.
  - 세이브 영향: `scripts/persistence/`는 texture와 관찰문을 서명에 넣지 않으므로(grep 0건) 기존 T04 세이브와 호환된다. 코드상 판단이다.
- 미검증과 알려진 문제:
  - 실제 저장→재시작→Load 재실행, 사람의 마우스 플레이, 정확한 1920×1080 창은 확인하지 못했다.
  - 720p 실험 화면에서 이미지 하단이 결과 스크롤 안에 들어가 스크롤해야 보인다.
- 애셋 및 라이선스 변경: 외부 자산 없음. 사용자 승인 원본 2장(T04 Master, M5-A 환경)의 파생물이다.
- Git 상태: 커밋·푸시 안 함.
- 다음 우선순위 하나: 사용자가 F6에서 합성본을 보고 크기·톤·사용 여부를 피드백한다. 이어서 A/C 지연 결과 읽기 패널(현재 하단 상태줄 한 줄로만 전달).

### 2026-10-16 — S1 / 인수인계 감사 (Claude Code, 읽기 전용)
- **인계 문서 정정:** M5-B는 미커밋이 아니다. `aae16a2`로 커밋되었고 GitHub `main`도 `aae16a2`다(`git ls-remote`로 확인). 인계 문서의 "main=122ffb1, M5-B 로컬 미커밋"은 오래된 정보다.
- 사용자 README 미커밋 편집: "ㅁ" 한 글자와 다른 프로젝트용 커밋 스크립트가 끼어 있다. M3 보고서대로 로컬에 보존하고 커밋에서 제외한다.
- 추출 폴더 `CAP_M5B_T04__EC_9E_84…/`에 Master PNG와 `.import`가 중복되어 있었다. Godot가 이를 두 번째 리소스로 import했고 export preset(`all_resources`)에도 포함됐다. **사용자 승인으로 빈 `.gdignore`를 추가해 해결했다(2026-10-16).** 폴더 안의 원본 파일은 수정하지 않았다. 추가 후 verify PASS, T04 Scene 시작 exit 0, editor filesystem cache에 해당 폴더 참조 0건.
- Godot 4.7.1 console: `C:\Users\newsj\Downloads\Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64_console.exe`(이름은 exe지만 실제로는 폴더).
- 저장 파일: `%APPDATA%\Godot\app_userdata\CAP\campaign_saves\` 아래 1개(10-16 10:18).
- 코드 확인: Autoload 없음. Main(2995줄)이 상태 소유자들을 직접 보유한다. Save v1, 서명에 texture 없음. M4.5 비교 Scene 2개는 M4 저장 슬롯을 공유한다. Story는 TEMP 6개(M2 3 + M4 3)이고 정식 12개는 0개다.
- 경미한 코드 부채(미수정): `main.gd` `_restore_navigation_screen`이 조기 return하면 `_navigation_busy`가 true로 남는다. `story_collection_state.gd:13-14`에 같은 줄이 중복되어 있다.
- T04 A/C 결과는 후속 CCTV View에 진입할 때 공개되고, 하단 상태줄과 Archive로만 전달된다. UX 개선 후보다.

## 매 작업 시 기록 형식
### YYYY-MM-DD — 작업 ID / 제목
- 기준 HEAD / 브랜치 / 변경 전 미커밋:
- 실행한 작업과 수정 파일:
- 승인된 결정 / 임시·후보로 남은 결정:
- 실제 검증: Godot 버전, 기본 F5, 해당 F6, 두 GPU 해상도, Save/Load 등:
- 미검증과 알려진 문제:
- 애셋 및 라이선스 변경:
- Git 상태(커밋·푸시 여부):
- 다음 우선순위 하나:

## 작업 원칙
- 실제 게임 플레이와 콘텐츠에 직접 도움이 되는 묶음 작업을 진행한다.
- 시스템 확장보다 기존 기능 재사용, Source of Truth 보호, 회귀 방지를 우선한다.
- 사용자에게 사실과 제안을 구분하여 보고한다. 자동 테스트는 사람 플레이 경험의 대체물이 아니다.
