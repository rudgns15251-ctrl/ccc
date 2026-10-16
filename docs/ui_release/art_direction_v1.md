# 출시용 UI 아트 디렉션 v1 — 계기반 강판 (Instrument Steel)

> 2026-10-16 · Claude Code · **[DRAFT 시안 · 승인 대기]**
> 시안 캔버스: https://claude.ai/artifact/SCAxrErPPr9WFetkkh2251 (비공개. 다른 사람이 보려면 캔버스의 Share 메뉴에서 공유해야 함)

## 결정 사항
- **[APPROVED 2026-10-16]** 출시용 UI의 기준 구조는 FACILITY CONTROL입니다(상단 가로 업무 키 4개, 중앙 작업 장치, 하단 기록 도구).
- 아직 F5 Main에는 적용하지 않았습니다. 기본 F5 화면을 실제로 바꾸는 것은 구현 단계에서 별도로 진행합니다.

## 방향 요약
- **화면 역할 = 재질.**
  - 강판: 조작과 탐색(업무 키, 기록 도구, 명령부).
  - CRT: 관찰과 기록(감시 영상, 실험 로그, Research).
  - 종이: 판단의 근거(Profile, 과거 기록, 방송 원고, 사고보고서).
- **색은 재료에서 온 색만 씁니다.**
  - 강판 #3B423B, 음각 #262B26, CRT #0C140E, 인광 #9FD4A3, 용지 #E6DFCC, 잉크 #2A2620, 신호등 호박색 #C9A24B.
  - 경보 적색 #B8432F는 사고, 경고, 송출 화면에서만 씁니다.
- **글꼴(모두 OFL, 게임에 동봉 가능):**
  - IBM Plex Sans KR: UI 본문과 제목.
  - IBM Plex Mono: 계기와 영상 표기.
  - 나눔고딕코딩: 타자 문서.
  - 현재 테마는 시스템 글꼴(맑은 고딕)에 의존합니다. 이 방식은 한국어 Windows가 아닌 환경에서 글꼴이 바뀌고, 출시 빌드에 동봉할 수도 없으므로 교체가 필요합니다.
- **상태 표현:**
  - 현재 업무 키만 호박색으로 켭니다.
  - 잠긴 키는 눌림 그림자가 없습니다.
  - 송출 버튼은 적색에 위험 띠를 더합니다. 초기 포커스는 원고 수정 버튼입니다.
- **개발 표기:** [임시·초안·비정사] 반복 문구를 우측 상단 TEMP BUILD 배지 하나로 통합합니다.

## 시안에 포함한 개선 아이디어
- 격리 비교: 후보 × 측정값 비교표, 플레이어가 연 근거만 옆에 표시.
- Profile: 붙인 사진과 정정(취소선+적색 주석) 및 도장 표현, 쪽 넘김.
- CCTV: 시각 표기를 호박색 Mono로 써서 관찰 기록의 시간축을 강조. 카메라 이름은 내부 ID 대신 사람이 읽는 이름으로.
- 방송: 단계 표시줄, 현장 무전 수신 기록, 송출 후 침묵.

## 출시 품질에 필요한 추가 에셋

| 분류 | 필요 내용 | 조달 방법 제안 | 비용 |
|---|---|---|---|
| 글꼴 | 위 3종 동봉 | Google Fonts(OFL) | 무료 |
| UI 재질 텍스처 | 강판(해머톤), 음각 홈, 나사·각인 라벨, CRT 베젤, 종이(용지·클립·도장) 9-slice 이미지 | 직접 제작(포토 텍스처 → 9-slice) 또는 CC0 텍스처(ambientCG 등) 가공. 시안의 CSS 노이즈는 대체용 | 무료~소액 |
| 아이콘 | 기록 도구, 저장, 경고, 송출 등 20~30개(선형, 각인 스타일) | 직접 제작(SVG) 권장. 통일감이 중요 | 제작 시간 |
| UI 사운드 | 키 누름, 잠김, 스위치, 문서 넘김, 도장, CRT 전환, 송출 확정, 무전 잡음, 경보 등 20~30개 | CC0/상용 SFX 팩 구매 + 녹음. 현재는 CC BY 3개뿐 | 소액 |
| 환경음 | 격리동 환기 험, 형광등 잡음, 원거리 기계음 루프 3~5개 | 상용 팩 또는 직접 녹음 | 소액 |
| 콘텐츠 이미지 | 정식 Case별 Profile 사진, CCTV 정지 프레임(변화 2~3장), 실험 결과, 사고 장면 | 정식 Case 확정 후 제작(가장 큰 비용) | 중~대 |
| 메뉴 화면 | 타이틀, 설정(음량, 해상도, 글자 크기), 일시정지, 크레딧, 저장 슬롯 | 신규 Scene 제작. 현재 **없음** | 코드 |
| 커서 | 기본, 클릭 가능, 대기 | 직접 제작 | 무료 |

- 라이선스 원칙: 출시에 들어가는 모든 에셋은 CREDITS와 manifest에 기록합니다. 재배포가 제한된 원본은 공개 저장소에 올리지 않습니다(기존 원칙 유지).
- CC BY 에셋(MAUSE, VHS UI Free, Analog Horror SFX)은 출시판에서도 표기만 하면 사용할 수 있습니다. 다만 새 아트 디렉션과 스타일이 다르므로, 계속 쓸 항목을 다시 고릅니다.

## 진행 기록

### 2026-10-16 — 출시용 Theme 1차 (글꼴 동봉 + 재질 StyleBox)
- 글꼴 7개와 OFL 라이선스 3개를 동봉했습니다(사용자 승인 후 Google Fonts 공식 저장소에서 다운로드): `assets/fonts/release/`, [CREDITS](../../assets/fonts/release/CREDITS.md).
- 재질 텍스처 10개를 생성했습니다(프로젝트 자체 제작, 외부 아트 없음): `assets/ui/release/`.
- Theme `resources/ui/release_instrument_steel_theme.tres`는 [`tools/build_release_theme.gd`](../../tools/build_release_theme.gd)로 재생성할 수 있습니다. 기존 temp Theme의 type과 상수를 상속해 덮어쓰는 방식이라 기존 Scene의 `theme_type_variation`이 그대로 동작합니다.
  - 강판: Panel, ChassisPanel, RailPanel.
  - 음각 홈: PanelContainer, SystemPanel.
  - CRT: InstrumentPanel, TranscriptPanel, MonitorBezel.
  - 종이: PaperDocumentPanel.
  - 경보: Warning/EmergencyPanel.
  - 키: Button, NavButton.
  - 호박색: Primary/CurrentNav.
  - 적색: TransmitButton.
  - 체크박스는 표시등 아이콘으로, 스크롤바와 입력칸도 같은 재질로 맞췄습니다.
  - Mono 글꼴에는 한글이 없어서 IBM Plex Sans KR을 fallback으로 지정했습니다.
- **적용 범위:** T04 F6 플레이테스트(`t04_presentation.gd`)에만 적용했습니다. F5, M4.5, M5-A는 기존 Theme을 그대로 씁니다.
- 검증:
  - `verify_project.ps1` PASS.
  - T04, M5-A, M4.5 Scene headless 시작 exit 0.
  - GPU 캡처 2해상도 × 5화면: [screenshots/ui_release_theme](../screenshots/ui_release_theme).
- 알려진 남은 일:
  - 종이 문서 위의 스크롤바가 무겁게 보임 → 종이용 스크롤바 type 필요.
  - 화면 헤더의 내부 ID(CAM_T04_TEXT_OBSERVATION)와 [임시] 표기가 그대로 노출됨 → TEMP 배지 통합 작업에서 처리.
  - 출시 빌드에서는 OFL 텍스트를 `licenses/`에 복사해야 함.

### 2026-10-16 — 나머지 화면 점검 + TEMP 배지 통합
- 점검 방법: 이전 도구가 남긴 로컬 여정 스크립트(`.godot/verification/m5_b/journey.gd`, gitignore 대상)를 그대로 재사용했습니다. ROOM B 경로(경고 → 사고 → 방송 2문항 → 원고 검토 → 송출 확인 모달 → 사고보고서 → 업무 복귀 → Archive)를 GPU 창에서 실행했습니다.
  - 실패한 검사는 `honest_cctv` 1건뿐입니다. CCTV 이미지가 없을 것을 기대하던 옛 검사이고, M5-B.1에서 의도적으로 바뀐 부분입니다.
  - 기존 로컬 캡처는 실행 전에 scratchpad에 백업했습니다.
- 새 Theme에서 정상 확인: 경보 띠, 방송 단계 표시, 선택지 표시등, 종이 원고 모달, 적색 송출 버튼, 사고보고서, Archive.
- 수정(`t04_presentation.gd`, T04 프리뷰 전용):
  - 우측 상단 **TEMP BUILD 배지**를 추가했습니다. 화면마다 붙던 임시 안내문은 배지 툴팁 한 곳에 모읍니다(내용은 유지).
  - 헤더 대상명, 경보 띠, Archive 라벨의 "[임시…]" 접두어를 화면 표시에서만 제거합니다. 데이터와 문서 본문의 [TEMP] 표기는 그대로입니다.
  - Archive에서 선택된 Case 버튼을 비활성 회색 대신 **호박색 현재 상태**로 표시합니다.
- Theme에 `TempBadgeButton` type을 추가했습니다(빌더 재실행).
- 화면: [screenshots/ui_release_theme](../screenshots/ui_release_theme)에서 `b_*` 8장 추가, 업무 화면 갱신.
- 남은 문제(다음 작업 후보):
  1. 사고보고서가 아직 종이 재질이 아니고 본문 글자가 작음 → 보고서 레이아웃을 종이 문서형으로 변경.
  2. 사고나 방송 중 헤더 부제("비상 방송 / 중단된 업무: 실험")가 두 줄로 접힘.
  3. Research 항목 제목이 내부 ID(RL_T04_…)로 노출됨 → 데이터 title 정리 또는 표시 규칙.
  4. 카메라명 내부 ID(CAM_T04_TEXT_OBSERVATION)가 노출됨.
  5. 종이 문서 위 스크롤바가 무거움.
  6. Archive에서 선택된 Case 버튼의 글자 크기가 다른 버튼보다 작음.

### 2026-10-16 — 사고보고서 종이화 + 내부 ID 노출 정리
- **사고보고서**(T04 프리뷰 presenter):
  - 보고서 영역을 `PaperDocumentPanel`로 감쌌습니다(되돌릴 수 있는 레이아웃 기록 사용).
  - 제목은 타자 굵은체, 지시문은 메타 글꼴, 본문은 타자 글꼴로 바꿨습니다.
  - 종이 전용 스크롤바 `PaperVScrollBar`를 추가했고 Profile 문서에도 적용했습니다(이전 남은 문제 5번 해결).
- **카메라명:**
  - `CCTVData`에 선택 필드 `camera_label`과 `get_display_name()`을 추가했습니다. CCTV 화면은 표시명을 쓰고, `camera_id`는 Research 출처 키로 그대로 유지합니다. Research 발견 판정도 같은 표시명으로 비교합니다.
  - 표시명이 비어 있으면 기존처럼 ID를 표시하므로 F5와 다른 Case는 변화가 없습니다.
  - T04 표시명: "CAM T04-01 · 표준 격리실 상부".
- **Research 제목:** T04의 23개 항목 제목을 내부 ID에서 짧은 한국어 제목으로 바꿨습니다(데이터 `title`만. ID, 본문, 해금 규칙은 그대로, 저장 서명 밖). 다른 Case는 원래 사람이 읽는 제목을 쓰고 있었습니다.
- 보고서 제목과 출처 패널의 "[임시…]" 접두어도 화면 표시에서 제거합니다. 보고서 본문의 [TEMP] 줄은 내용이므로 유지합니다.
- 검증:
  - verify PASS. ROOM B 경로를 GPU 1280에서 다시 실행: CCTV 관찰 Research 발견 검사 통과. 실패는 옛 기대값 1건(`honest_cctv`)뿐.
  - T04, M5-A, M4.5, M2 headless 시작 exit 0.
- 남은 문제:
  - 헤더 부제 줄바꿈(2번).
  - 선택 Case 버튼 글자 크기(6번).
  - 보고서 본문 상단의 송출 원고가 작은 메타 글꼴이라 가독성 검토 필요.

## 다음 단계(승인 후)
1. 시안 피드백을 반영합니다(색, 재질, 밀도).
2. Godot Theme을 새로 만듭니다(`resources/ui/` 아래 출시용 Theme. 기존 temp Theme은 보존). 글꼴 동봉, StyleBox 재질 적용.
3. FACILITY CONTROL 화면 단위로 적용합니다: 공통 셸 → CCTV → 실험 → 격리 → 방송 → 사고보고서 → Archive 순서.
4. 메뉴 화면(타이틀, 설정, 일시정지)을 신규로 만듭니다.
5. 공통 연출 묶음을 적용합니다(지연 결과 패널, 경고 단계 공개, 송출 침묵).
