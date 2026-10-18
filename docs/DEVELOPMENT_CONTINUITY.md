# CAP — AI 도구 간 지속 개발 로그

> Claude Code 및 향후 Codex 복귀 시 공용 문서. 최신 로컬 코드와 실제 검증이 우선이다.
> **한눈에 보는 현황(2026-10-16): [PROJECT_STATUS.md](PROJECT_STATUS.md)** — Git 상태, 최신 구현, 확정·미정 기획, 남은 문제, 다음 작업.

## 인수인계 기준 — 2026-10-16
- GitHub `main`: `122ffb137edcd007424fbda0d11edabfe41c0052` (직접 확인, M5-A).
- 로컬 **M5-B T04**: 사용자 보고상 구현 완료, `git add/commit/push` 미실행. `scenes/playtests/t04_playtest.tscn` 및 `docs/m5_b_t04_temp_case.md` 확인 필수.
- M5-A 및 FACILITY CONTROL은 F5 기본 UI와 분리된 F6 테스트 시안. T04는 TEMP/DRAFT/NON-CANON.
- 다음 추천: M5-B 작업트리 백업 → F6 사용자 수동 플레이 → 부족한 CCTV Anchor / T04 실험 결과/Incident 이미지 준비 및 기존 Texture 슬롯으로 교체 → 실제 이미지로 UI 가독성 점검. 승인 없이는 정식 Campaign/Ending 편입 금지.

## 작업 기록 (최신이 위)

### 2026-10-18 — D19 / 임시 케이스 1(Case 01) 제작 + 커밋·푸시 (사용자 요청)
- 커밋·푸시: `023590a`(실험 재개, 방송 화면 수정, 애셋 평가, 플레이 가이드). `master:main` 비강제.
- 신규: `tools/build_case_01.gd`(Case 01 Resource 생성기), `resources/cases/temp_case_01.tres`, `resources/campaigns/temp_case01_playtest.tres`(Case 01 → T04 → 테스트 사례 01~03), `scenes/playtests/case01_playtest.tscn`, `tools/case01_temp_composite.ps1` + `assets/temp/case01/generated/` 4장(대상 이미지 없음, 위치 표지만 그린 임시 프레임), `scenes/release/title_case1.tscn`, 내보내기 preset 5 "Windows Case1 Preview"(feature `case1_preview`).
- 수정: `scripts/main/t04_playtest.gd`를 일반화(추적 사례 목록 [Case 01, T04], 지연 결과 공개·상태줄·초기 관찰 문구 사례별). `title_screen.gd`는 게임 장면·캠페인을 export 변수로, `pause_menu.gd`는 case1 빌드에서 case1 타이틀로 복귀. T04 프레젠터의 임시 표기 문구에 Case 01 추가.
- Case 01 규칙: 실험 3개 제시 중 2회(R1 규칙 적용), 후보 순서 방음실·암실·냉각실(정답이 첫째가 아님), 오답은 `failure_without_incident`, 결과는 다음 사례의 관찰 화면에서 보고.
- 검증: 마우스 입력으로 Case 01 완주(정답 암실 → 다음 사례 진입, 결과 공개 확인; 오답 방음실 → 부적합 보고 확인), 한도 2회 후 3번째 실험 실행 불가, verify_project(80), M5-B 경로 1280/1920(각 620, 옛 기준 2종), M4·M4.5·M5-A 경로, `CAP_Case1.exe` 내보내기와 헤드리스·창 실행 종료 코드 0.
- **사고 보고(저장 데이터 삭제):** 테스트 뒤 정리 중 와일드카드 `rm`으로 저장 폴더를 비웠다. 삭제된 것: 기존 M2 저장 `80fd0cf0afadbb783fa008da.json`(TEMP_M2_PLAYTEST, 10-16 생성, 1580B)과, 사용자가 프리뷰 EXE에서 플레이하며 남겼을 수 있는 T04 저장(`5468aa3b…`). 백업이 없어 복구할 수 없다(검증 폴더의 옛 M3/M4 사본은 크기·해시가 달라 같은 파일이 아님). 재발 방지로 메모리에 규칙 기록, 이후 테스트는 백업 후 복원 방식으로만 실행.
- 미검증: 사람의 직접 플레이, 글자 크기 '크게'.
- Git: 미커밋.
- 다음 우선순위 하나: 사용자의 T04·Case 01 플레이 메모.

### 2026-10-18 — D18 / 실험 단계 재개 (사용자 요청, main.gd 변경 승인)
- 규칙: 격리 결정이 기록되기 전에는 남은 실험 기회가 있으면 격리 화면에서 실험 화면으로 돌아와 계속 실험한다. 확정하거나 기회가 0이면 읽기 전용(기존 재열람). CLAUDE.md 불변 계약에 기록.
- 추천 근거: 되돌릴 수 없는 시점은 "계속"이 아니라 **격리 확정**이어야 한다. "계속"은 탐색일 뿐이므로 되돌아와도 정보 누설이나 탈출 패널티가 없다. 실험 결과 공개 경계, 횟수 제한(3회), 지연 결과는 그대로이고, 격리 확정 직전에 "남은 기회가 사라진다"는 안내를 보여 준다.
- 변경(`scripts/main/main.gd`, +16줄): `_can_reopen_experiments()`, `_on_work_navigation_requested`에 두 분기. (1) 격리가 현재 단계이고 실험 키를 누르면 실험을 현재 단계로 되돌림(실험 View 기존 경로를 그대로 써서 실행·해금·사건 기회가 정상 동작, 사건 기회는 case별 키로 중복 집계 안 됨), (2) 실험이 현재 단계일 때 격리 키는 새 읽기 전용 복사본 대신 정상 진행. CCTV 재확인 중에는 적용 안 함.
- 변경(`t04_presentation.gd`): 격리 화면의 안내 문구, 레일 문구("재개 가능 · n회 남음", "격리 이어서 진행"). F6 한정.
- 검증: 마우스 입력으로 건너뛰기 → 실험 재개 → 실행 → 격리 복귀 → 재개 반복, 한도 도달 후 읽기 전용(핸들러 거부 확인), 결정 기록 후 재개 불가, verify_project(80), M5-B 1280/1920(각 620, 옛 기준 2종), M4·M4.5·M5-A 경로 종료 코드 0, 빌드 재생성.
- **옛 기준 3건이 의도대로 실패:** step66/step66_1 navigation·utility 검증의 `review_EXPERIMENT`, `past_experiment_read_only`, `past_experiment_handler_guard`는 "격리 후 실험 화면은 항상 읽기 전용"이라는 이전 규칙을 확인하는 항목이다. 새 규칙에서는 기회가 남은 경우 재개되므로 실패한다. 기회 0 또는 결정 기록 후의 읽기 전용은 별도 확인했다.
- 미검증: 사람의 직접 플레이, 글자 크기 '크게', 여러 사례에 걸친 지연 사건과의 상호작용 전체.
- Git: 미커밋.
- 다음 우선순위 하나: 직접 플레이 메모.

### 2026-10-18 — D17 / 방송 질문 화면 가시성·헤더 보수 (T04 프레젠터 한정, 사용자 요청)
- 변경(`scripts/presentation/t04_presentation.gd`, +13/−1줄. `main.gd` 무변경): (1) 비상 방송·사건·결과 보고 화면에서 잠겨 있는 작업 키 4개를 숨겨 높이를 돌려줌, (2) 방송 질문의 중복 제목("대응 지시 선택")을 숨기고 간격을 줄임, (3) 헤더 시설 슬롯을 640으로 넓혀 부제를 끝까지 표시("비상 방송 / 중단된 업무: 실험"), (4) 상태줄의 문장 끝 마침표 뒤 구분점(". · ")을 정리.
- 확인: 마침표 "중복"은 실제로는 문장 끝 마침표와 가운데점 구분자가 붙어 보인 것이었다(글자 코드 확인). 이중 마침표 버그가 아니었고 표기만 정리했다.
- 결과: 1280/1920 모두 4개 선택지가 스크롤 없이 보이고, 업무 복귀 후 작업 키와 알림 띠가 다시 나타난다.
- 검증: verify_project(80), M5-B 경로 1280/1920(각 620 확인, 옛 기준 2종만 표시), `CAP_Preview.exe` 재빌드와 헤드리스 실행 종료 코드 0, 사용자 저장 정리 완료.
- 미검증: 글자 크기 '크게' 설정에서의 방송 화면, 사람의 직접 플레이.
- Git: 미커밋.
- 다음 우선순위 하나: 사용자의 직접 플레이 메모.

### 2026-10-18 — D16 / 임시 케이스 1(T04) 플레이 준비 (사용자 요청)
- 확인: 사용자 제공 `임시 케이스1.txt`는 기존 T04 원본 설정이며, 현재 구현은 이 문서 + M5-B.2 승인 변경이다. 새 사례를 만들 필요 없이 이미 타이틀 → T04 흐름으로 플레이 가능. 후속 사례(M2 임시 3개)는 지연 결과의 "다음 업무" 역할이라 유지.
- 빌드: `builds/release_preview/CAP_Preview.exe` 재빌드(통합 화면, 입력 잠금 수정 포함). 이전 빌드는 `CAP_Preview_20261016.exe`로 보관. 헤드리스·창 모드 종료 코드 0. 사용자 저장 정리 완료.
- 가이드: [playtest_guide_temp_case1_v1.md](playtest_guide_temp_case1_v1.md).
- 직접 본 문제(1920 화면): 방송 질문 화면에서 4개 선택지 중 2개만 보이고 나머지는 스크롤 아래에 있다. 상태줄에 마침표 중복("요.."). 헤더 부제가 "중단된 …"으로 잘린다.
- Git: 미커밋(빌드는 Git 제외).
- 다음 우선순위 하나: 사용자의 직접 플레이 메모, 방송 선택지 가시성 수정.

### 2026-10-18 — D15 / Dead Channel 무료 샘플 검증 (사용자 승인 다운로드)
- 받음: `Dead-Channel-Free-Sample-v1.1.zip`(186,686 B)을 `assets/local_only/paid/dead_channel_free_sample/`에 보관(Git 제외, `.gdignore` 추가). 게임에는 연결하지 않았다.
- 라이선스: 상업 사용·표기 불필요, 단독 재배포·추출 가능한 공개 금지, AI 보조 제작 명시. 샘플 한정이며 풀 키트 라이선스는 미확인.
- Godot 4.7.1: import·실행 오류 없음, 슬라이더·연결·리셋·키보드 포커스 동작, 한글은 시스템 대체 글꼴(게임에서는 동봉 글꼴 필요).
- 판단: 풀 키트($15)는 보류. 기록: ui_release/asset_candidates_v1.md 5장, `assets/third_party/PAID_MANIFEST.md`(신규).
- Git: 미커밋(문서 3개: 평가 문서, 매니페스트, 이 로그).
- 다음 우선순위 하나: SFX 전체판·VHS UI 유료판 구매 여부 결정.

### 2026-10-18 — D14 / 애셋 후보 5개 평가 (사용자 제공 링크, Claude Code)
- 산출: [ui_release/asset_candidates_v1.md](ui_release/asset_candidates_v1.md). 구매·다운로드 없이 공개 페이지만 확인. 판단: SFX 전체판 사용 권장, VHS UI 유료판 일부 사용, Dead Channel은 무료 샘플로 시험, Obssidian 보류, eXP-Themes 제외.
- 핵심 주의: 재배포 금지 조건 때문에 구매한 원본은 공개 저장소에 커밋하지 않는다(`assets/local_only/`). AI 보조 제작 표기 확인 필요. 라이선스 전문은 구매 후 확인.
- 코드·애셋 변경 없음.
- Git: 미커밋.
- 다음 우선순위 하나: 사용자의 구매 여부 결정 → 라이선스 전문 확인.

### 2026-10-17 — D13 / 커밋·푸시 (사용자 요청)
- 커밋 `b42d213`(25개 파일: 스토리 설계 문서, 통합 화면 프로토타입, main.gd 입력 잠금 수정, 릴리스 프리뷰 설정, CLAUDE.md). `master:main`으로 푸시 완료(비강제, `aae16a2..b42d213`). 이전 로컬 커밋 3개(`45b9143`, `3f87c73`, `ea40822`)도 함께 올라갔다.
- 제외(미커밋 유지): README 개인 편집, T04 입력 ZIP·추출 폴더, 설치 안내, 첫 세션 프롬프트, anki_project/, source/, output/, requirements.txt.
- 참고: 푸시된 커밋에는 Tabler 아이콘 전체(약 6,200개, MIT)와 BigSoundBank CC0 원본 WAV(최대 22MB)가 포함돼 있다. 저장소 용량이 커졌다.
- 다음 우선순위 하나: 챕터1 수직 슬라이스(Case 01 데이터화부터).

### 2026-10-17 — D12 / main.gd 근본 수정: 포커스 저장 검사와 복원 실패 시 입력 잠금 해제 (사용자 승인)
- 변경(`scripts/main/main.gd`, +15/−2줄): (1) `_capture_work_navigation`은 저장할 포커스 대상을 `work_focus_path` 메타 대체 탐색까지 거쳐 확인하고, 없거나 숨겨졌거나 포커스 불가이면 보이는 "다음" 버튼 또는 빈 값으로 바꾼다. 새 헬퍼 `_find_work_focus`. (2) `_restore_navigation_screen`의 거부 경로 4곳에서 `_navigation_busy`를 해제한다.
- F6 임시 보정(`m4_5_structural_comparison.gd`)은 중복이라 제거했다. 이 파일은 원래 상태.
- 영향: 프레젠터 레이아웃(F6)에서 화면 이동 후 입력이 잠기던 결함이 F5 경로에서도 막힌다. 일반 경로의 동작은 같다(저장 대상이 보이는 경우 변화 없음).
- 검증: 잠김 재현 시퀀스, 복귀 후 선택 버튼, verify_project(80, 기본 Main 시작), M4·M4.5·M5-A 경로(종료 코드 0), M5-B 경로 1280/1920(각 620 확인, 옛 기준 2종만 표시). 테스트가 만든 사용자 저장 데이터 정리 완료(M2 저장 해시 동일).
- 미검증: F5를 사람이 직접 플레이한 확인. 복원 거부가 실제로 생기는 모든 경로.
- Git: 미커밋. `main.gd`가 변경 파일에 포함된다.
- 다음 우선순위 하나: 사용자의 통합 화면 확인.

### 2026-10-17 — D11 / 버그 수정: 화면 이동 후 모든 버튼이 잠김 (F6 한정, Claude Code)
- 증상(사용자): 실험을 하지 않고 "계속"으로 다음 화면에 가면 어떤 버튼도 반응하지 않음.
- 재현: 실험 건너뛰기 → 격리 화면 → 레일로 다른 화면 방문 → 레일로 격리 화면 복귀 → `navigation focus/state restore rejected` 경고와 함께 `_navigation_busy`가 true로 고정되어 레일·도구·선택이 모두 잠김. 수정 전 프레젠터로도 동일(통합 화면 프로토타입이 원인이 아님).
- 원인: 프레젠터가 컨트롤을 옮기고 원래 경로를 `work_focus_path` 메타로 저장한다. Main의 포커스 저장 검사는 `get_node_or_null`만 써서 옮겨진 숨은 "다음" 버튼을 찾지 못해 보정이 빠지고, 복원 때 보이지 않는 대상이라 실패했다. 실패 경로는 `_navigation_busy`를 풀지 않는다(알려진 부채).
- 수정: `scripts/main/m4_5_structural_comparison.gd`(F6 공통 기반)에 두 override 추가. (1) `_capture_work_navigation`: 현재 보이는 포커스 대상만 유지하고 아니면 보이는 "다음" 버튼 또는 빈 값. (2) `_restore_navigation_screen`: 복원이 거부돼도 입력 잠금을 해제. `main.gd`와 F5는 수정하지 않았다.
- 검증: 잠김 재현 시퀀스 3종 해결, 복귀 후 선택 버튼 동작, 실험 실행 경로, verify_project(80), M5-B 경로 1280(620 확인, 옛 기준 2종만 표시). 저장 데이터 정리 완료.
- 남은 부채: 같은 결함이 `main.gd`에도 있어 승인 후 근본 수정 권장(F5가 프레젠터 레이아웃을 쓰게 될 때 필수).
- Git: 미커밋.
- 다음 우선순위 하나: 사용자의 통합 화면 확인, `main.gd` 근본 수정 승인 여부.

### 2026-10-17 — D10 / 강제 방송 이벤트 #1 초안 (Claude Code)
- 산출: [story/forced_broadcast_event_01_draft_v1.md](story/forced_broadcast_event_01_draft_v1.md). INC_CH2_01(02 격리실 설비 결함으로 탈출), 단일 스크립트, 질문 2개, 3등급 결과, 보고서 예시, 데이터 매핑, 미정 6개.
- 코드·Resource 변경 없음. 모두 [DRAFT]. 피해 수치는 UNKNOWN 유지.
- Git: 미커밋.
- 결정: 이벤트 미정 1~6 처리(문서 11장). 인원 수 비표시, 2문항, 규칙 상기만, 02 결과 공개는 이 사건(임시). 다음 우선순위 하나: 사용자의 T04 F6 통합 화면 확인 결과 반영.

### 2026-10-17 — D9 / CCTV·실험 통합 화면 프로토타입 (T04 F6 한정, Claude Code)
- 변경: `scripts/presentation/t04_presentation.gd`(+151줄). Main·F5·다른 View 무변경. 열 순서 `모니터 | 실험 목록 | 텍스트`를 두 단계가 공유. CCTV 단계는 실험 잠금 미리보기, 실험 단계는 모니터가 결과 프레임으로 전환.
- 검증: 1920/1280 화면 캡처, M5-B 경로 두 해상도(620 확인, 실패 2종 옛 기준: honest_cctv, video_dominant), verify_project(80 scripts) 통과. 사용자 저장 데이터 정리 완료(M2 저장 해시 동일).
- 미검증: 깜빡임·효과음 체감, 사람 플레이. 상세: ui_release/cctv_experiment_merge_v1.md 6장.
- Git: 미커밋.
- 다음 우선순위 하나: 사용자가 F6에서 직접 확인 후 안 B(단계 통합) 진행 여부 결정, 또는 강제 방송 이벤트 문서.

### 2026-10-17 — D8 / 변경 R2 + CCTV·실험 통합 UI 설계 + 탐색 구현 설계 (Claude Code)
- 결정: 개선 3·7 채택, 1·2·6·8 보류, 4 중간 공포 연출 채택, 5 하한만. 기록: story/team_story_plan_analysis_v1.md 11장.
- 설계 문서: [ui_release/cctv_experiment_merge_v1.md](ui_release/cctv_experiment_merge_v1.md), [story/exploration_interaction_v1.md](story/exploration_interaction_v1.md).
- 코드 변경 없음. 모두 [DRAFT].
- Git: 미커밋.
- 다음 우선순위 하나: 통합 화면 F6 프로토타입(T04 한정) 또는 강제 방송 이벤트 #1 문서.

### 2026-10-17 — D7 / 변경 R1: 실험 선택 규모 증가 (사용자 요청)
- 규칙: 진행에 따라 제시 실험 수와 선택 횟수가 늘어남(예: 초반 3개 중 2개, 후반 5개 중 3개). 기록: story/team_story_plan_analysis_v1.md 10장.
- 영향: Case 01~03 초안은 "4개 제시, 3회"로 쓰여 수정 필요. 코드 변경 없음.
- Git: 미커밋.

### 2026-10-16 — D6 / Case 03 초안 + 챕터1 종료 연출 (Claude Code)
- 산출: [story/case_03_draft_v1.md](story/case_03_draft_v1.md). 열을 내는 개체(정답 냉각실), 일반 화면 vs 열화상 함정, 챕터1 종료 연출(장부 9/CCTV 10칸), 강제 방송 이벤트 연결, 미정 7개.
- 변경점: PDF의 "03 오답 시 챕터2 방송"은 Case 02 결정 4(단일 스크립트)로 폐기. 03 오답은 `failure_without_incident`.
- 코드·Resource 변경 없음. 모두 [DRAFT]. 열화상 비교 UI는 구현 확인 필요.
- Git: 미커밋.
- 결정: Case 03 미정 1~7 처리(문서 12장). 강제 방송 이벤트 대상 = Case 02의 방. 6번(10칸 재열람)만 보류. 다음 우선순위 하나: 강제 방송 이벤트 #1 문서.

### 2026-10-16 — D5 / Case 02 초안 + 강제 방송 이벤트 위치 (Claude Code)
- 결정: 강제 방송 이벤트는 **챕터2 초반**(Case 03 이후·Case 04 이전). 모든 플레이어가 경험하도록 변형 A(03 오답 탈출)/B(설비 결함) 안을 둠, 원인은 UNDECIDED.
- 산출: [story/case_02_draft_v1.md](story/case_02_draft_v1.md). 소리에 약한 개체(정답 방음실), 프로필 vs 관찰 불일치 학습, 일기 D1 시작, 미정 6개.
- 코드·Resource 변경 없음. 모두 [DRAFT].
- Git: 미커밋.
- 결정: Case 02 미정 1~6 처리(문서 11장). 강제 이벤트 원인은 단일 스크립트(설비 결함)로 통일. 5번(ARCHIVE_02_01)만 보류. 다음 우선순위 하나: Case 03 초안.

### 2026-10-16 — D4 / 프롤로그 초안 (Claude Code)
- 산출: [story/prologue_draft_v1.md](story/prologue_draft_v1.md). 도착, 인수인계 서류 2장, 전임자 책상, 안내 영상 3부, 방송 실습 1회(모의, 기록 영향 없음), 엔진 매핑, 제작 시트, 미정 6개.
- 코드·Resource 변경 없음. 모든 내용 [DRAFT].
- 엔진 격차: 방송 실습은 본 흐름과 분리된 모드가 필요(코드 변경 필요).
- Git: 미커밋.
- 결정: 프롤로그 미정 1~6 처리(문서 8장). 방송 실습 폐기, 강제 이벤트로 대체. 다음 우선순위 하나: 강제 방송 이벤트 위치 결정 + Case 02 초안.

### 2026-10-16 — D3 / Case 01 정식 문서 초안 (Claude Code)
- 산출: [story/case_01_draft_v1.md](story/case_01_draft_v1.md). 빛 민감 개체(정답 암실), 튜토리얼. Profile, CCTV, 실험 4종, 격리 후보 3, 지연 결과, 데이터 매핑, 제작 시트, 미정 7개.
- 코드·Resource 변경 없음. 모든 내용 [DRAFT]. 연도·이름·외형 수위 확정 없음.
- Git: 미커밋.
- 결정: Case 01 미정 1~7 처리(문서 11장). 3번(ID 형식)만 보류. 다음 우선순위 하나: 프롤로그 안내 영상(방송 실습 포함) 초안 또는 Case 02 초안.

### 2026-10-16 — D2 / 팀 스토리 기획안(PDF) 분석 (Claude Code)
- 입력: `캡스톤디자인_스토리_수정.pdf`(2026-10-11 수정본)와 T04 전문. 사용자가 이를 개발 기준으로 지정.
- 산출: [story/team_story_plan_analysis_v1.md](story/team_story_plan_analysis_v1.md). 정합 항목, 충돌 C1~C7, 논리 보완, T04 수정안, 엔진 격차, 개발 순서.
- 코드·CLAUDE.md 변경 없음. 충돌은 사용자 선택 전까지 [UNDECIDED].
- 핵심: Case 1은 PDF의 빛 민감 개체(암실)와 기존 시선 반응안이 충돌. 전임자=10번째 개체, 엔딩 5종, 기록 6/3/3은 기존 구조와 맞음.
- Git: 미커밋.
- 결정: C1~C7 사용자 결정 완료(분석 문서 9장, CLAUDE.md 갱신). 다음 우선순위 하나: Case 01(빛 → 암실) 정식 문서 초안.

### 2026-10-16 — D1 / 출시 범위 · 이야기 방향 · Case 1 결정 (사용자 결정)
- **[APPROVED]** 정식 9 Case + 숨겨진 개체 1을 모두 출시(약 90~120분). 앞서 정한 '1차 4~5 Case·60분'은 이 결정으로 대체됐다.
- **[APPROVED]** 이야기 C. 결합안: 연구원 자리 승계 + 야간 비상방송 책임. 전임자 일지와 직원 명단·방송이 축이다.
- **[APPROVED]** Case 1 = 시선 반응 개체(콘셉트). 외형과 세부는 DRAFT.
- 기록 위치: `CLAUDE.md` 목적 절, `docs/release_roadmap.md`, `docs/story/decision_brief_v1.md`.
- 미정: 전임자의 존재 방식, 결말, Case 2~9와 숨겨진 개체, T04 승격 여부.
- Git: 미커밋.
- 다음 우선순위 하나: 9+1 Campaign 골격(Case 배치, 강제 사건, Story Record 12개 위치, 전임자 공개 순서) 초안과 Case 1 정식 문서 초안.

### 2026-10-16 — R2 / 출시 프리뷰 빌드 + 출시 로드맵 (Claude Code)
- 추가:
  - `export_presets.cfg` preset.4 "Windows Release Preview"(feature `release_preview`). 제외: docs, tools, local_only, output, anki_project, source.
  - `project.godot`에 `run/main_scene.release_preview` 한 줄(타이틀 화면). **기본 `run/main_scene`(F5)은 그대로다.**
- 빌드(Git 제외): `builds/release_preview/CAP_Preview.exe`(138MB, release 템플릿, PCK 포함) + `licenses/`(OFL 3종, Tabler MIT, CC BY 고지, CC0 출처, Godot 라이선스 전문) + README(플레이 메모 질문 포함).
- 확인:
  - 제한된 Retro 셰이더, 원본 소리, 재질, Anki 파일, 문서는 패키지에 없다(바이너리 문자열 검사. manifest JSON의 경로 문자열만 있음).
  - EXE를 headless와 창 모드로 실행해 둘 다 exit 0. verify PASS.
- 문서: [docs/release_roadmap.md](release_roadmap.md). 현재 위치, A~E 단계, 사용자 결정 항목, 위험.
- 판단: 기술과 UI 기반은 충분히 왔다. 출시 가능성을 좌우하는 것은 콘텐츠(정식 Case, 이야기, 엔딩)와 사람의 플레이 검증이다.
- Git: 미커밋.
- 다음 우선순위 하나: 사용자가 `CAP_Preview.exe`를 플레이하고 피드백한다. 이야기 방향과 첫 정식 개체, 1차 출시 규모를 결정한다.

### 2026-10-16 — Git 커밋 3 (사용자 요청)
- 브랜치 `ui-release-theme`에 커밋 `ea40822`(119개 파일: QA 수정, 결과 보고서 패널, CC0 재질, 콘솔 프레임, 소리)를 만들었다. 이후 사용자 요청으로 `master`를 fast-forward해서 `master` = `ea40822`(origin/main보다 3커밋 앞섬)이고, 현재 브랜치는 `master`다. 푸시하지 않았다.
- 제외(미커밋 유지): README 개인 편집, T04 입력 ZIP과 추출 폴더, `설치_안내.md`, `CLAUDE_FIRST_SESSION_PROMPT.txt`, `anki_project/`, `source/`. 추가로 CAP와 무관한 `output/`(Anki 카드 CSV)과 `requirements.txt`도 제외했다.
- 커밋 전에 남아 있던 빈 `.git/index.lock`(18:16 생성, 실행 중인 git 프로세스 없음)을 삭제했다.
- 주의: `output/` 안에 `cards.csv.import`가 생겼다. 프로젝트 폴더 안에 있어서 Godot가 import한 것이다. 이 폴더들을 CAP 밖으로 옮기는 것을 권장한다.

### 2026-10-16 — A5 / 2단계 소리 (Claude Code)
- 다운로드(사용자 승인): BigSoundBank CC0 WAV 26개 → `assets/third_party/release_ui/sfx/bigsoundbank/`(.gdignore). 출처와 해시는 CREDITS.md.
- 신규: `tools/build_release_sfx.gd`(자르기, 페이드, 정규화, 루프) → `assets/ui/release/sfx/` 17개 생성.
- 수정:
  - `scripts/presentation/t04_presentation.gd`: 이벤트음 재생(`play_event`), 화면별 진입음, 경고·송출·결과 보고서 소리, 운영실 루프 2개. 첫 화면 소리를 위해 플레이어 생성 순서를 조정했다.
  - `scripts/release/credits_panel.gd`: BigSoundBank·CC0 재질 표기.
- Sonniss는 봇 확인 때문에 미다운로드(사용자 직접 다운로드 필요).
- 검증:
  - 소리 재생과 루프 지속을 확인했다(GPU 창, 일회용 스크립트).
  - 세 경로 1280, 메뉴 14항목, verify(80), Scene 5개 시작 모두 통과(옛 기대값 1건 제외).
  - 사용자 데이터 정리 완료(M2 저장 해시 동일).
- 발견하고 해결한 문제: headless 실행에서는 재생 중인 스트림이 종료 시 누수로 보고됐다(더미 오디오 드라이버가 재생을 해제하지 않음, 창 실행에서는 누수 없음). headless에서는 소리를 재생하지 않게 해서 검사 출력을 깨끗하게 유지했다.
- Git: 미커밋.
- 다음 우선순위 하나: 사용자가 실제로 들어보고 음량 균형을 피드백한다. 도장 소리 제작.

### 2026-10-16 — A4 / 콘솔 프레임 직접 제작 (Claude Code)
- 수정:
  - `tools/build_release_theme.gd`: `console_frame.png` 생성(CC0 강판 톤 매핑, 베벨, 검은 턱, 모서리 나사), `ConsoleFramePanel` type 추가 → Theme 재생성.
  - `scripts/presentation/t04_presentation.gd`: 셸 뒤에 프레임 패널을 깔고 셸 여백 조정(26/26/24/22). 기존 undo 경로로 제거된다.
- 검증:
  - 탈출 경로 1280과 1920, 큰 글자 세 경로, 메뉴 14항목, verify(80), Scene 5개 모두 통과(옛 기대값 1건 제외).
  - 설정은 '보통'으로 복원, 테스트 저장 정리, M2 저장 해시 동일.
- Git: 미커밋.
- 다음 우선순위 하나: 2단계(무료 소리 선별·가공) 또는 지금까지 변경 커밋.

### 2026-10-16 — A3 / 1단계 CC0 재질 적용 (Claude Code)
- 다운로드(사용자 승인): Poly Haven 2개, ambientCG 4개. 모두 CC0. 색 이미지 6장만 `assets/third_party/release_ui/materials/`(.gdignore)에 넣었고, 출처·라이선스·해시는 `CREDITS.md`에 기록했다.
- 수정: `tools/build_release_theme.gd`가 사진을 톤 매핑해 UI 패널을 생성한다(원본이 없으면 노이즈로 대체). 경보 9-slice 여백 3→6.
  - 재생성된 파일: `assets/ui/release/*_panel.png`, `steel_background.png`, Theme.
- 검증: 세 경로 1280, 메뉴 14항목, verify, Scene 5개 시작 모두 통과(옛 기대값 1건 제외). 테스트 저장 정리 완료, M2 저장 해시 동일.
- 참고: 첫 복사를 PowerShell로 했을 때 파일이 프로젝트에 들어가지 않았다(원인 미확인). Bash로 다시 복사한 뒤 해시를 확인했다.
- Git: 미커밋.
- 다음 우선순위 하나: 2단계(무료 소리 선별·가공) 또는 콘솔 프레임 직접 제작.

### 2026-10-16 — A2 / 장소감 에셋 확보 계획 (Claude Code, 문서만)
- 산출물: [docs/ui_release/asset_acquisition_plan.md](ui_release/asset_acquisition_plan.md).
- 요지:
  - 1단계는 0원: CC0 재질(ambientCG, Poly Haven), 무료 소리(Sonniss GDC 2026, BigSoundBank, Freesound CC0), 콘솔 프레임과 1차 타이틀 직접 제작.
  - 구매는 부족한 소리 팩만(약 0~10만 원).
  - 키 아트는 출시 직전 외주(약 40만~100만 원).
  - 콘텐츠 이미지는 정식 Case 확정 후 산정.
- 비용은 조사 시점의 추정이다. 다운로드, 구매, 외주는 각각 사용자 승인이 필요하다.
- Git: 미커밋.
- 다음 우선순위 하나: 1단계(CC0 재질 → UI 패널 교체)의 다운로드 파일 목록을 제시하고 승인을 받는다.

### 2026-10-16 — QA2 / 지연 결과 패널 + 방송 화면 (Claude Code)
- 신규: `scenes/release/result_notice.tscn`, `scripts/release/result_notice.gd`(종이 보고서형 결과 패널).
- 수정:
  - `scripts/main/t04_playtest.gd`: A/C 결과가 처음 공개될 때만 패널을 요청한다. 판정과 저장 데이터는 변경 없음.
  - `scripts/presentation/t04_presentation.gd`: 패널 연결, Esc와 일시정지 우선순위, 방송 상황 패널 확대, 단계줄 숨김, 상황 패널 접두어 정리.
  - 로컬 QA 스크립트(gitignore 대상) `.godot/verification/m5_b/journey.gd`: 결과 패널 표시와 닫기 검사, 캡처 추가.
- 검증:
  - 세 경로 1280과 탈출 경로 1920 재플레이: 실패는 옛 기대값 1건뿐.
  - 메뉴 14항목, verify(80 scripts), Scene 5개 모두 통과.
  - 사용자 데이터 정리 완료(M2 저장 해시 동일).
- 보고서: `docs/ui_release/qa_pass_1.md`의 "QA 2차" 절.
- Git: 미커밋.
- 다음 우선순위 하나: 장소감을 위한 에셋 확보 계획을 결정한다(재질, 이미지, 소리, 타이틀 아트). 구조와 정보 전달 쪽 주요 문제는 이번 QA 기준으로 해소됐다.

### 2026-10-16 — QA1 / UI/UX 직접 플레이 점검 + 수정 (Claude Code)
- 보고서: [docs/ui_release/qa_pass_1.md](ui_release/qa_pass_1.md). T04 세 경로를 끝까지 플레이하고 화면 36장을 비교작 기준으로 검토했다.
- 결론: 부족함의 일부는 에셋 부족(이미지, 재질, 소리, 타이틀 아트) 때문이지만, 발견한 문제 대부분은 에셋과 무관한 설계와 구현 문제였다.
- 수정(`scripts/presentation/t04_presentation.gd`, T04 프리뷰만):
  - 직전 패스의 회귀(Archive와 보고서 정리 꺼짐) 수정.
  - 실험: 실행 버튼 호박색, 목록 설명 숨김(5개 모두 보임), 남은 횟수 표시등.
  - 사고 화면의 빈 이미지 틀 숨김.
  - 승인 확인창 확대.
  - 연구 기록 서랍 확대, 목록·상세 좌우 배치, 뒤 화면 흐림.
  - 환경 경고 뒤 화면 흐림.
- 검증: 세 경로 1280, 탈출 경로 1920, 메뉴 14항목, verify(79), Scene 5개 시작 모두 통과(옛 기대값 1건 제외).
- 사용자 데이터 주의: `journey.gd --mode=all`은 실제 사용자 폴더에 T04 저장을 쓴다. 이번에 남은 테스트 저장(.json과 .bak)은 삭제했고 M2 저장 해시는 그대로다.
- Git: 미커밋.
- 다음 우선순위 하나: 지연 결과 읽기 패널(격리 판정을 사건처럼 전달)과 방송 화면 레이아웃 조정. 장소감용 에셋 확보 방식은 사용자 결정이 필요하다.

### 2026-10-16 — Git 커밋 2 (사용자 요청)
- 브랜치 `ui-release-theme`에 커밋 `3f87c73`(6,548개 파일, 그중 6,464개는 `.gdignore`된 후보 에셋 팩)을 만들었다. 이후 사용자 요청으로 `master`를 fast-forward해서 `master` = `3f87c73`(origin/main보다 2커밋 앞섬)이고, 현재 브랜치는 `master`다. 푸시하지 않았다.
- 제외(미커밋 유지): README 개인 편집, T04 입력 ZIP과 추출 폴더, `설치_안내.md`, `CLAUDE_FIRST_SESSION_PROMPT.txt`.
- **추가로 제외한 파일:** 작업 중(10-16 17:01~17:02) 프로젝트 루트에 생긴 `anki_project/`(Python vendor 패키지, 스크립트)와 `source/`(게임마케팅 강의 PDF 3개). CAP와 무관하고 이 세션이 만든 파일이 아니어서 손대지 않고 커밋에서 뺐다. 위치를 옮길지는 사용자 확인이 필요하다.
- 이 기록 자체는 커밋 이후에 추가한 미커밋 변경이다.

### 2026-10-16 — UI-P4 / 글자 '크게' 점검 + 크레딧 (Claude Code)
- 수정:
  - `scripts/presentation/t04_presentation.gd`: 작업 화면의 시설 조건 블록을 경보 띠에 통합하고, 사고·방송·보고서 화면에서는 경보 띠를 숨김(720p 공간 확보).
  - `scenes/release/title_screen.tscn` + `title_screen.gd`: 크레딧 버튼.
- 신규: `scripts/release/credits_panel.gd`, `scenes/release/credits_panel.tscn`(동봉 자료 표기, Godot 라이선스 전문).
- 검증:
  - '크게'와 '보통' 각각 ROOM B 경로 1280과 1920: 실패는 옛 기대값 `honest_cctv` 1건뿐.
  - 메뉴 흐름 14항목과 크레딧 열기·닫기 PASS. verify PASS(79 scripts). Scene 5개 시작 exit 0.
  - 사용자 데이터 정리: 검사용 T04 저장 삭제, M2 저장 해시 동일, 설정 '보통' 복원.
- 미검증: 사람의 사용성. '작게' 배율.
- Git: 미커밋(UI-P1~P4, A1).
- 다음 우선순위 하나: 방송 화면 레이아웃 비율 조정 → 출시 빌드용 라이선스 파일 동봉 절차 정리 → 커밋 여부 결정.

### 2026-10-16 — UI-P3 / 타이틀 · 설정 · 일시정지 (Claude Code)
- 신규:
  - `scripts/release/`: `release_settings.gd`(class_name ReleaseSettings, ConfigFile 저장, Autoload 아님), `settings_panel.gd`, `title_screen.gd`, `pause_menu.gd`.
  - `scenes/release/`: `settings_panel.tscn`, `title_screen.tscn`, `pause_menu.tscn`.
  - 텍스처 `slider_knob.png`.
- 수정:
  - `scripts/presentation/t04_presentation.gd`: 설정 적용(글자 배율 Theme, 조작음 볼륨, Master 음량), 헤더 메뉴 버튼, Esc 일시정지, 타이틀 이어하기 처리.
  - `tools/build_release_theme.gd`: 슬라이더, 드롭다운, HeaderButton → Theme 재생성.
- 기본 F5와 `project.godot`는 변경하지 않았다. 타이틀은 F6로 실행한다(`scenes/release/title_screen.tscn`).
- 저장: 기존 Main 불러오기 경로를 재사용하고 저장 형식은 그대로다. 설정은 `user://release_settings.cfg`에 별도로 저장된다.
- 검증:
  - 흐름 검사 14항목 PASS(검사용 T04 저장은 삭제, M2 저장 해시 동일 확인, 설정은 기본값 복원).
  - ROOM B 경로 1280과 1920: 실패는 옛 기대값 `honest_cctv` 1건뿐. 헤더 버튼 회귀는 수정했다.
  - verify PASS(78 scripts). Scene 5개 시작 exit 0.
- 미검증: 사람의 실제 사용성. 실제 음량 체감. 글자 크기 '크게'일 때 모든 화면의 넘침 여부(설정 화면만 캡처).
- Git: 미커밋(UI-P1·P2·P3, A1 포함).
- 다음 우선순위 하나: 글자 크기 '크게'에서 전체 경로의 넘침을 점검하고, 크레딧 화면을 추가한다(라이선스 표기). 이후 커밋 여부를 결정한다.

### 2026-10-16 — UI-P2 / UI 사운드 + 아이콘 연결 (Claude Code)
- 추가:
  - `assets/ui/release/sfx/` 6개(87 Clickety Clips의 click28/4/63/27/29/23, CC0).
  - `assets/ui/release/icons/` 6개(Tabler notebook/archive/pencil/device-floppy/history/lock, MIT, 흰색·32px로만 변경).
  - 출처 표는 `assets/ui/release/README.md`에 있다.
- 수정:
  - `scripts/presentation/t04_presentation.gd`: 버튼 역할별 클릭음(button_down, 플레이어 4개), 기록 도구 아이콘, 잠긴 키 자물쇠 아이콘, 표시등 색 보존.
  - `tools/build_release_theme.gd`: 버튼 아이콘 색과 간격 → Theme 재생성.
- 범위: T04 F6 프리뷰만.
- 검증:
  - 클릭음 재생 확인(일회용 스크립트).
  - ROOM B 경로 1280과 1920 실행: 실패는 옛 기대값 `honest_cctv` 1건뿐.
  - verify PASS. 4개 Scene 시작 exit 0.
- 미검증: 사람이 귀로 들은 평가. 소리 크기 균형.
- Git: 미커밋(UI-P1과 A1 변경 포함).
- 다음 우선순위 하나: 사용자가 F6에서 소리와 아이콘을 직접 확인한다. 이어서 타이틀, 설정(음량, 글자 크기), 일시정지 화면을 만든다.

### 2026-10-16 — A1 / 출시 UI 후보 에셋 다운로드 (Claude Code, 게임 미연결)
- 사용자 승인으로 4개를 다운로드했다:
  - 87 Clickety Clips (CC0, OpenGameArt).
  - Kenney UI Audio (CC0).
  - Kenney Interface Sounds (CC0).
  - Tabler Icons 3.48.0 (MIT, npm 패키지).
- 위치: `assets/third_party/release_ui/` + `.gdignore`(import와 export 제외). 출처, 버전, 아카이브 SHA-256, 라이선스는 `CREDITS.md`에 기록했다.
- 다운로드 파일은 scratchpad의 개별 폴더에서 압축을 풀어 확인한 뒤 복사했다(오디오, SVG, 라이선스만. `.url` 바로가기는 제외).
- 아직 Scene, Theme, 코드에 연결하지 않았다. 사용할 때 `.gdignore`를 해제하고 게임 내 크레딧에 반영해야 한다.
- Git: 미커밋.
- 다음 우선순위 하나: 기계식 클릭 후보를 골라 UI 사운드를 연결하고, Tabler 아이콘으로 기록 도구와 잠김 상태 아이콘을 적용한다.

### 2026-10-16 — UI-P1 / 출시 품질 패스 1 (Claude Code)
- 기준: master `45b9143` + 미커밋 연속성 로그.
- 수정:
  - `tools/build_release_theme.gd`: 글자 크기와 줄 간격, 종이 여백, 상태 표시등 텍스처 3개, SelectedListButton → Theme과 텍스처 재생성.
  - `scripts/presentation/t04_presentation.gd`: 개발 메뉴 숨김, 업무 키 표시등, 헤더 부제 한 줄, 기록 도구 글자 크기, 페이드 전환, 격리 비교표와 선택 강조, 목록 설명 숨김.
  - `scripts/main/t04_playtest.gd`: 승인 상태 문구 번역 버그 수정.
  - 새 파일: `assets/ui/release/lamp_*.png` 3개.
  - 화면 20장 갱신.
- 범위: T04 F6 프리뷰만. F5와 다른 플레이테스트, 데이터, 저장 변경 없음.
- 검증:
  - ROOM B 전체 경로를 GPU 1280과 1920에서 실행. 실패는 옛 기대값 `honest_cctv` 1건뿐.
  - 진행 중 발견한 회귀(승인 후 다음 버튼이 화면 밖으로 밀림)를 수정한 뒤 재통과.
  - verify PASS. 4개 Scene headless 시작 exit 0.
- 미검증: 사람의 가독성과 플레이 평가. 1920 이외의 화면 비율.
- 남은 일 6개: art_direction_v1.md 참고. 에셋 결정이 필요한 항목은 UI 사운드, 아이콘, 아트 텍스처, 콘솔 프레임.
- Git: 이번 변경은 미커밋.
- 다음 우선순위 하나: 방송 화면 레이아웃 비율을 조정하고 타이틀, 설정, 일시정지 화면을 만든다. 병행해서 UI 사운드와 아이콘 에셋 확보 방식을 사용자와 결정한다.

### 2026-10-16 — Git 커밋 (사용자 요청)
- 새 브랜치 `ui-release-theme`에 커밋 `45b9143`(100개 파일)을 만들었다. 이후 사용자 요청으로 `master`를 fast-forward해서 `master` = `45b9143`(origin/main보다 1커밋 앞섬)이고, 현재 브랜치는 `master`다. 푸시는 하지 않았다.
- 사용자 지시로 제외한 파일(미커밋 유지): README 개인 편집, T04 입력 ZIP과 추출 폴더(그 안의 `.gdignore` 포함), `설치_안내.md`, `CLAUDE_FIRST_SESSION_PROMPT.txt`.
- 이 기록 자체는 커밋 이후에 추가한 미커밋 변경이다.

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
