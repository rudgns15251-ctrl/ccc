# CAP — Codex → Claude Code 상세 인수인계 (2026-10-16)

> 목적: Claude Code가 **같은 Godot 프로젝트**를 중단 없이 이어받되, 구현 사실·사용자 승인·임시 콘텐츠를 혼동하지 않게 하는 것.
>
> **중요:** 이 문서는 사용자 제공 M1~M5-B 개발 보고서, 게임 시스템 기획 자료, 2026-10-16 GitHub `main` 조회를 기반으로 작성했다. Claude가 **사용자의 현재 로컬 작업 트리**와 Godot 실행을 확인하기 전에는 최신 상태 보증서가 아니다. 여기에서 확인되지 않은 기능이나 세계관은 임의로 확정하지 않는다.

## 0. 인수인계 순간 — 코드 위치와 위험

| 범위 | 마지막으로 확인된 상태 | 검증 신뢰 |
| --- | --- | --- |
| GitHub `rudgns15251-ctrl/ccc`, `main` | `122ffb137edcd007424fbda0d11edabfe41c0052` | GitHub 직접 확인, 2026-10-16 |
| M5-A | 위 커밋에 포함: 임시 시각자료·FACILITY CONTROL 관련 개선 | GitHub + 해당 보고서 |
| M5-B T04 | 사용자 보고에 의하면 **로컬 구현 완료, 미스테이징·미커밋·미푸시** | 업로드된 M5-B 보고서; 원격 저장소에는 아직 없음 |
| 실제 Windows 현장 환경 | Godot 4.7.1 Standard, Compatibility; 실행 빌드 `builds/m5_b/CAP_T04_M5B.exe` | 보고서 기재. 로컬 exe 직접 실행은 인수자 확인 필요 |
| 유저 개인 편집 | 별도의 루트 `README.md`, T04 입력 ZIP 및 원본 추출 자료 | 보존해야 할 미커밋 소유물 |

**우선 조치:** 실제 Windows 원본 프로젝트 `C:/Users/newsj/OneDrive/문서/ChatGPT/cap/`(보고서 표기 경로; 실제 위치 재확인)를 **폴더 전체 백업**한다. `.git`/미커밋·untracked/이미지/로컬 사용 허가 자산/필요한 save를 포함한다. GitHub clone만 인계하면 M5-B가 누락된다. 임시 테스트 executable 및 `.godot/verification/`은 gitignored이며, 유지하려면 별도로 보관한다. OneDrive 충돌 복제본/동기화 충돌도 확인한다.

## 1. 제품 목표와 시대감

- 제품: Windows PC용, Godot 4.7.1 / GDScript / **2D 인터페이스 중심** 관찰·실험·격리·추론형 공포게임.
- 시대·시각 콘셉트: 1980년대 말~1990년대 초 소련 말기/러시아 초기 비밀 생체 연구시설. 낡았으나 기능하는 산업 장비, 실사풍 개체·시설 사진, VHS/CRT 감시, 종이 Profile과 전자기록의 대비, 제한된 색상과 검열 기록.
- 장기 플레이타임 목표 약 90~120분은 **계획**일 뿐 현재 빌드의 실측 결과가 아니다.
- 중심 사건: 인간형/이상 개체의 연구 프로필을 읽고, CCTV에서 행동 증거를 수집하고, 제한된 실험으로 가설을 검증한 뒤 안정적인 격리 환경을 선택. 성공·실패가 나중에 드러나고 실제 탈출 후 직원 대피용 방송을 작성하여 사고 결과를 확인. Research 기록이 재사용 가능한 근거가 됨.
- 실시간 3D 이동, 새로운 전투·인벤토리·가상 OS 시스템, 무근거한 경제/로그라이트 상점, 범용 상태기계 등은 현행 프로젝트의 당연한 필수 기능이 아니다. 오래된 후보 기획을 별도 승인 없이 개발하지 않는다.

## 2. 확인된 기술 계약

| 구성 | 현재 설계/경계 | 주요 파일 |
| --- | --- | --- |
| 기본 Scene | F5 = 기존 기본 Campaign. 테스트 전용 Scene은 각자 F6 | `scenes/main/main.tscn`, `scenes/playtests/` |
| Game flow/권위 | Main이 신호·요청 검증과 Stage 변경/실행 승인. View는 표시·임시선택. 별도 전역 Autoload 없음 | `scripts/main/main.gd`, `scripts/views/flow_view.gd`, `scripts/runtime/` |
| 데이터 | `Resource`/`.tres` 기반 Case/Campaign/실험/격리/사건/방송 구성 | `scripts/data/`, `resources/` |
| Research | 실제 Profile/CCTV 열람 및 해당 실험 실행/결과, 지연 판정/Incident 읽기 이후에만 발견. A/R/N 독립 기능 | `scripts/runtime/research_archive_state.gd`, `scripts/views/research_log_view.gd`, 관련 read_models |
| Experiment | 선택→Main 승인→CaseRuntime 실제 실행 기록, 실행 횟수 제한, 실행한 실험만 결과 표시 | `scripts/views/experiment_view.gd`, `scripts/runtime/case_runtime_state.gd` |
| Containment | 제출 Pending, 후속 의미 있는 read boundary에서 공개. 실패 후보와 실제 탈출은 구분 | `scripts/runtime/pending_containment_state.gd`, `containment_resolution_state.gd`, `failure_event_candidate_state.gd` |
| Incidents | `CASE` / `CAMPAIGN_ENTRY` / `CAMPAIGN_INTERRUPT` 출처 구분, 기록 조회·순차 전달·정확한 중단 업무 복원 | `scripts/runtime/incident_source.gd`, `incident_response_state.gd`, `scripts/read_models/` |
| Broadcast | 단일 질문 호환 + 복수 질문/선택 조합, 원고 검토·송출·acknowledgement | `scripts/data/broadcast_question_data.gd`, `broadcast_outcome_data.gd`, `scripts/views/multi_broadcast_view.gd` 등 |
| Save | Campaign 별 독립 1개 수동 슬롯, schema v1와 authored signature 검사, 안전한 화면에서만 저장 | `scripts/persistence/campaign_save_codec.gd`, `campaign_save_store.gd`; `user://campaign_saves/` |
| 기본 UI | 기존 F5 Main 유지. FACILITY CONTROL 구조/Visual Production은 플레이테스트 전용, 최종 채택 전 | `scenes/ui/facility_control/`, `scripts/presentation/`, `scenes/playtests/` |

### 보호해야 할 사용자 관점의 불변 조건

1. Research는 **획득했을 때만** 등록. 누락·중복 등록, 이전 실험 결과의 미리 공개 금지.
2. 잘못된 격리 결정의 결과가 승인 순간 스포일러처럼 표시되면 안 됨. 기존 후속 Case 행동/읽기 경계에서 전달.
3. FAILURE라고 해서 반드시 개체 탈출이 아님. T04 ROOM A는 명시적 비탈출 실패; ROOM B는 실제 탈출; ROOM C만 성공.
4. 직원 **대피/생존 지시**는 탈출이 실제 확인된 이후 방송에서 수행. 단순 시설 제어를 대체하는 질문 금지. 고의든 아니든 방송 완료 뒤 최초 FAILURE는 그대로 남아야 함.
5. 사망/부상 `UNKNOWN` (`-1`)은 명시적으로 확인된 `0`과 다름. 엔딩·사고 총계에서 UNKNOWN을 0으로 해석하지 않음.
6. 방송 미리보기→최종 확인→확정→잠금→사고보고서 acknowledgement→기존 Context/Focus/Scroll 복귀. Archive 왕복도 보존.
7. Save/Load 저장 조건/파일 호환/기존 원본 캠페인 상태 소유를 임의 변경하지 않음.
8. 테스트 Campaign, UI, 외부 애셋과 본편 Source of Truth 구분. 사용자 명시 승인 전에는 F5 기본 변경 금지.

## 3. 단계별 구현 이력 (확인 자료/구현 사실)

| 단계 | 구현된 기능 / 의미 | 현재 주의 |
| --- | --- | --- |
| Step38~54 등 초기 | Core loop, 제한 실험·Research, 지연 사고 후보, 사건 처리 정책, read boundary/상태 조회·결과 책임 | 과거 step 보고서는 역사기록. 무리한 재설계 금지 |
| Step55~63 | Campaign Data, 작성된 순차 Incident, 출처별 처리, Mid-Case interrupt와 정확한 업무 복귀, TEMP 필수 사건 | `CASE`/`CAMPAIGN_ENTRY`/`CAMPAIGN_INTERRUPT`를 하나로 뭉개지 말 것 |
| Step64~70 | GameShell/Navigation, R/A/N, Historical Facts 보존, Profile 종이 문서, Case03 첫 EXPERIMENT의 TEMP Mid-Case 사건 | F5 기존 캠페인 Case01→Case02→필수사건→Case03 |
| Step71/M1 | Profile 대상사진/과거 관찰/연구자 노트, CCTV 일반·실제 열화상 슬롯, 실행된 실험의 결과 이미지, 격리 후보 비교와 Focus/Scroll 검증 | 실제 열화상 자산 미제공이면 모드 숨김 |
| M2 | 박막낭 `TEMP_M2_CASE_01`: 일관된 Profile/CCTV/실험·정답 격리/오답·지연 환경 이상·실제 사건/방송을 하나의 Vertical Slice로 제작 | 박막낭 TEMP/NON-CANON. `scenes/playtests/m2_playtest.tscn` F6 |
| M3 | 전임자 일기 6 + 주민명단 3 + 원본 교육영상 3 = **목표 12개** Story Record 타입/수집 시스템. TEMP 3개 콘텐츠. Campaign별 수동 Save/Load, checksum/유효성/실제 프로세스 복원 | 12개 정식 내용/발견 위치는 아직 작성·승인 안 됨. 영상 Transcript placeholder는 실제 영상이 아님 |
| M4 | 다중 질문 비상방송, 작성·미리보기·송출, 조합별 피해, 사고보고서 Archive, 단일 질문 호환, Source와 저장 버전 보존 | M4 TEMP 2문항 4결과, `UNKNOWN`과 0 구분. `scenes/playtests/m4_playtest.tscn` |
| M4.5 무료 애셋 | MAUSE, VHS UI Free, Retro Screen FX Lite, Analog Horror SFX Free; 스킨 5종 비교, CCTV 전용 CRT/VHS, 선택형 사운드, 저작권 분리 | 일부 Retro 원본은 `assets/local_only` Git 제외. RELAY 공식 무료 샘플 미확보 |
| M4.5 구조 시안 | `FACILITY CONTROL`: 상단 가로업무 탐색/하단 기록도구, CCTV 약 63% 영상영역, 방송 작성·원고 검토·송출 승인 각기 다른 Control 구조, Profile 종이 문서 유지 | `scenes/playtests/m4_5_structural_comparison.tscn` F6; 최종 F5 미채택 |
| M5-A | 임시 이미지 3개(개체 전신/표준 격리실/CCTV 정지 참고) Resource 연결, Profile/CCTV/Experiment/Containment UI 추가 개선, 기존 M4 임시 콘텐츠에 시각적 통합 | **원본 이미지와 박막낭 문서 외형 불일치**; 시각 테스트 자산이지 최종 증거 아님. `scenes/playtests/m5_a_visual_playtest.tscn` |
| M5-B **로컬 미커밋** | T04 TEMP 완전 독립 Case: Profile Master 1장, CCTV 증거 텍스트, 실험 5개 최대 3회, Research 23개, Archive 3개, 3개 격리 결과, ROOM B 지연 탈출, 2문항 4×4 방송 16결과, 피해 UNKNOWN, 저장·재시작과 복귀 | `scenes/playtests/t04_playtest.tscn` F6, `builds/m5_b/CAP_T04_M5B.exe` 로컬. GitHub에는 미반영(인계 시점) |

### M5-B의 실제 구현 차이 — 중요

- `resources/cases/temp_t04_case.tres` (`TEMP_T04_CASE`), `resources/campaigns/temp_t04_playtest.tres` (`TEMP_T04_M5B_PLAYTEST`). Campaign 내부에 T04 뒤 기존 test Case01~03을 이어 붙여 **지연 결과를 다음 업무 중 확인**함.
- `ROOM_T04_LOWSTIM` **성공**; `ROOM_T04_STANDARD` 실패하지만 Candidate/탈출/방송 없음; `ROOM_T04_METALLIC` 실패 뒤 기계 반향→상지의 설비 간섭→잠금 이상→실제 복도 이탈→방송.
- 기존 `monitoring_outcome_data.gd`에 opt-in `failure_without_incident` 경계 보완, `containment_resolution_state.gd`·`main.gd`·`campaign_save_codec.gd` 및 read_models 연결 조정. 기본 다른 Case에서 실패 시 Incident 계약은 여전히 보호.
- 동일 SOURCE의 Research 다건 등록을 `case_data.gd`의 `grouped_research_entries` T04 전용 opt-in으로 처리. `research_entry_data.gd` enum 끝에 `CONTAINMENT_RESULT` 추가(기존 번호 보존). 23개 Research 중 실제 근거/상태에 맞는 것만 공개.
- **미확정 인명 피해**이므로 T04 방송의 **16개 조합 전부 사망/부상 UNKNOWN**. 16개가 다른 정성 결과를 가질 수 있어도 숫자는 임의 확정 금지.
- 실제 보고서는 `docs/m5_b_t04_temp_case.md`, 콘텐츠 검토는 `docs/content_drafts/t04/t04_implementation_review.md` (로컬 전용 가능). 원본 입력 `docs/content_drafts/t04/t04_gameplay_v0_2.txt`, `t04_profile_research_draft.md` 등 수정 금지.
- M5-B 보고서에는 Godot 4.7.1에서 **74개 제품 Script check-only**, 실험 세 가지 선택 **10조합**, 방송 **16조합**, F5/M2/M3/M4/M4.5/M5-A 회귀, 2개 GPU 해상도, 3프로세스 Save/Load 검증이 적혀 있음. Claude의 자체 실행 결과가 아니라 **이전 도구의 보고**로 기재할 것.
- Incident PHASE 1~3은 경고문에서 순차로 제시한 텍스트이며, **실제 시간 기반 애니메이션 3개가 아님**. PHASE 4 실제 Runtime 탈출 사건과 구별.

## 4. T04 콘텐츠 Source of Truth — TEMP/DRAFT

- 원본 Master 이미지 `assets/temp/t04/t04_master_reference.png`: 좌측 웃는 얼굴(좁은 눈/큰 입), 우측 큰 눈(작은 입), 두 목과 머리/하나의 몸통·골반/네 팔·두 다리/검고 마른 신체/머리 주위 가지형 돌기. 설정상 245~260cm는 독립 계측 미확인.
- Profile: `BR-04-112`, `T04`, 1991.02.██, 연구자 검열 등 작성본 전부 **TEMP 기획 원문**이다. 실제 세계관 날짜 확정 아님.
- 생리·추론: 웃는 머리 음향·진동 우선, 큰 눈 머리 이동광 우선; 단발 자극 반응 ≠ 장기 탈출. 잔향이 누적되면 상지 탐색 증가, 빛+반향 결합시 협응 저하. **저조도+내부 흡음+외부 소음 차단**이 장기 성공 조건. 방음과 흡음은 다른 변수.
- 실험: `ECHO`, `LIGHT`, `COMBINED`, `LOWSTIM`, `AIR` 다섯 개; 3회 제한. LOWSTIM은 임시 방의 소음/조도를 낮추는 실험이지 벽 재질/흡음 성능을 교체하는 실험 아님. 모든 3개 선택 조합(10개)을 플레이 가능하도록 설계.
- 격리: `ROOM A STANDARD`=FAILURE no escape; `ROOM B METALLIC`=FAILURE+BREACH; `ROOM C LOWSTIM`=SUCCESS.
- 탈출: ROOM B의 금속성 반향과 반복 구조물 접촉, 결함 있는 점검 패널·비상 해제 기구가 결합. 개체의 특별한 해킹·포식·고의적 잠금 해제처럼 묘사 금지. **설비 결함 세부는 후보**.
- 방송 Q01/Q02: **직원 대피/생존**, 복수 문항·최종 원고 확인. Q03 고립 직원 구출은 아직 [DRAFT 후보]이며 자동 추가 금지.
- Archive 01(확보), 02(초기 오판), 03(후속 정정)만 연결; 04 과거 인명손실 문구는 사망 확정 아님·사건 동일성 미정, 05 접종/기원 암시는 [DRAFT]로 **미연결**.
- 정식 개체로 채택된 상태 아님. `T04`라는 ID도 사용자 제시 임시 설계이며 공식 9개 배정 여부는 미정.

## 5. 시각 자산·UI 현황과 부족한 것

### 연결된 것
- M5-A: 교체 가능한 개체 Master/환경 Master/CCTV 정지 참고 이미지 총 3개. Resource Texture 참조; 사용자 승인 여부 구분.
- T04: **T04 Master 한 장만 Profile에 연결**. 과거 M5-A 개체/방 이미지는 T04의 실제 사건 증거로 재사용 금지.
- Profile 종이 문서, FACILITY CONTROL GameShell/CCTV/Experiment/Containment/방송 레이아웃, 선택형 VHS/CRT·세 OGG 음향은 테스트 가능.

### T04에서 우선 필요한 것
1. `CCTV Anchor`: 표준 임시 격리실 Master 구조와 카메라 각도를 그대로 유지하면서 T04 Master 형태·두 머리·네 팔의 비율을 유지한 장면.
2. CCTV 관찰 변형: 기본 정지/음향 방향 반응/이동광 추적/복합 자극/안정·불안정화. 같은 Room, 같은 개체여야 함.
3. `ExperimentData.result_texture`에 넣을 **실험 5종(ECHO, LIGHT, COMBINED, LOWSTIM, AIR) 결과 이미지**.
4. ROOM B 점검 패널 접촉/고장/탈출 Incident 장면, 환경 이상·사고 기록에 필요한 그림. 실제 사용하려면 기존 지원 Texture 슬롯을 먼저 확인하고 **필요 최소한** 추가.
5. 선택적: Profile 전용 기록 촬영 사진, ROOM A/B/C 격리실 후보 실제 사진(현 ContainmentData에는 후보별 Texture 필드 없다고 보고), 열화상은 실제 온도 분포 단서와 파일이 있을 때만.
6. 클릭/실험장치/방송/경고 전용 사운드의 품질·음량 조절; 이미지 없이 글리치·가짜 CCTV 텔레메트리만 늘리지 않음.

### UI 향후 결정할 사항
- FACILITY CONTROL은 **사용자가 미채택**. F5 적용 금지. 실제 T04 이미지가 연결된 상태에서 화면 가독성과 정보 비중·720p 스크롤·4:3 여백 평가 후 채택 여부 문의.
- 중복된 StyleBox/효과/단순 색상 바리에이션보다 장면의 이미지와 정보 계층 완성도를 높임. Profile 종이 UI 유지, CCTV만 필름 필터를 선택 적용, 방송은 작성/검토/확정 다르게 유지.
- 공통 Shell과 나머지 Archive/사고·스토리 기록의 디자인은 단계적으로 통일. 테스트 시안 여러 개를 무분별하게 추가하지 않음.

## 6. 본편 콘텐츠와 서사 — 결정 상태

### 운영/기능으로 실재하는 것
- 현재 원본 기본 F5 Campaign은 **Case01→Case02→TEMP 필수 사건→Case03**, Case03 처음 Experiment에서 TEMP Mid-Case Incident. M2/M4/M5-A/M5-B는 별도 테스트 Entry; 게임 전체 본편 완성/Ending이 아님.
- Story Record 데이터 스키마 목표 **일기 6·주민명단 3·원본 교육영상 3**, 현 구현된 M2 자료 3개는 `[TEMP NON-CANON]`. 게임 내 비디오 원본을 확보·실제 검증하지 못함.
- Research 출처, 직원 대피 방송, 지연 결과, Accident Report, Story Archive, Save/Load의 기능 기반은 존재.

### 후보/미정 (구현해 정식으로 확정하지 말 것)
- 공식 Case 총 수/서열/개체 외형과 난이도 곡선, 9개 공식 + 기록 없는 10번째 개체의 최종 존재·역할, 전임자 정체 및 변화, 소련 붕괴 이후 사건의 정확한 날짜와 연구시설 운영, 주변 주민·접종·인체 실험 상세.
- 전임자의 일기·명단·교육영상 12개 실제 원고/발견 위치·인물 연결/해금 조건.
- 강제/중간/마지막 사고의 본편 배치, 사고 뒤 직원 재확보·재배치 규칙, 정확한 직원 인원/피해 규모/시설 피해 산식.
- 봉인 이후 전기·생명 유지·정보 전송, 마지막 비상방송 직원 사망 판정, 명패 이름 작성, 마지막 연구기록 처리와 진엔딩. 관련 아이디어는 **과거 기획 후보**이며 현재 플레이 가능한 결말 아님.
- 1991년 2월처럼 입력된 TEMP 문서 날짜는 반드시 본편 세계관 시작일을 의미하지 않음.
- 옛 시스템 기획서에 등장하는 `GameState` Autoload, 결과 UI, 별도 태그 시스템, 자동 세이브·인벤토리 등은 **제안**이며 최신 실제 코드보다 우선하지 않음.

## 7. 현재까지 발견된 개선점과 위험 (우선순위)

### P0 — 전환 안전과 실제 플레이
- **M5-B 커밋/푸시 미실행:** 먼저 원본 폴더 전체와 untracked를 백업. 원격과 현재 로컬의 차이를 보여준 후 사용자가 Git 커밋 여부 결정. 자동 commit/push 금지.
- **사용자 수동 T04 플레이:** ROOM C 성공·ROOM A 비탈출 실패·ROOM B 탈출→방송→업무 복귀. 연구량·정답 노출·방송 선택의 체감 공정성 기록. 74개 Script/10·16조합 자동 검증은 사람 플레이 경험이 아님.
- **T04 영상·문서 일치:** 현재 Master만 Profile에 있어서 CCTV·실험/사고에 실사 증거 없음. 일관성 확보 전까지 시각적 완성으로 보고하지 않음.
- **ROOM A 후속 UX:** 비탈출 실패 시 플레이어에게 무슨 일이 일어났고 다음은 무엇을 해야 하는지 명확한가? 별도 재격리 절차는 승인되지 않았으므로 임의 발명 금지.
- **GitHub 공개 라이선스:** CC BY/MIT 고지 유지, 유료/제한 원본 공개 저장소에 추가 금지. `/assets/local_only/`, `/builds/`, `/.godot/` Git 제외 확인.

### P1 — 실제 본편 품질과 콘텐츠
- T04 CCTV Anchor/실험 5개/ROOM B 사고 자산 제작 후 실제 Resource 연결과 영상영역·4:3 비율 보정.
- T04 Archive 01→02→03의 정확한 발견 타이밍, 의도된 오판/정정과 3회 실험 퍼즐의 체감 난이도, 정보량·문서 길이 튜닝.
- FACILITY CONTROL의 720p 글자/버튼·선택형 사운드·VHS 감도 실사용성 판단 후 디자인 채택 여부 결정. 기본 F5 유지.
- 정식 Case 1개를 승인받아 **실제 외형/환경 반응/격리 조건 + Profile/CCTV/실험/사고 + 교체 가능한 사진**의 전체 수직 슬라이스 제작. 사용자 승인 없이 T04를 정식으로 승격시키지 않음.
- 본편 Case가 늘어나면 반복되지 않는 추론 구조·난이도 상승·Incident 페이싱과 기록 재사용을 검토.

### P2 — 본편 확장/스토리·엔딩
- 12개 공식 Story Record 실제 내용, 읽는 순서·해금 위치, 교육 영상(영상 자산 포함), 아날로그 호러 이벤트(검열 사진, 사고 픽토그램 등) 구현은 스토리 승인과 함께.
- 캠페인 90~120분 목표 콘텐츠와 진행 전개, 본편 사건/최종 봉인 및 엔딩, 피해 확인 규칙·분기. 본편 시나리오 승인이 필요.
- 최종 UI·오디오·자막/접근성·창 크기·Windows 배포 패키지·크레딧/저작권·세이브 안정화·수동 플레이 QA.

### 과거 보고서의 기술적 잔여 과제 — 무조건 선행 작업 아님
- `docs/architecture.md`는 역사적으로 `Step53/54/62/70`의 종료 Pending, atomic rollback, 개발 재시도, Hypothesis getter 과제를 언급. 해당 보고서 시점의 사항이므로 **최신 코드에서 재확인 후 실제 사용자 경험을 방해하는 문제만 우선 해결**한다. 하네스 복구 자체가 목표가 되어서는 안 됨.

## 8. 작업 방식: 첫 세션과 그 다음

### 첫 세션(감사/동기화)
1. 프로젝트 루트에서 `.git`/현재 HEAD/`git status`/untracked 파일/로컬 분기를 확인. 백업 존재 여부 확인.
2. `CLAUDE.md`, 이 문서, `docs/DEVELOPMENT_CONTINUITY.md`와 `README.md`, `docs/architecture.md`, `docs/verification.md`, `docs/m5_b_t04_temp_case.md`, 콘텐츠 검토 문서 읽기.
3. 실제 `scripts/main/main.gd`, `Case/OutcomeData`, Runtime·SaveCodec, M5-B Scene/Resource를 점검. 문서와 코드 차이를 구분해 보고.
4. Windows Godot 4.7.1 실행 경로·필수 폴더 확인. 가능하면 기존 `tools/verify_project.ps1`로 기본 smoke 수행; T04/원본 대표 경로 확인.
5. 수정 전 위험/미확정/승인 필요한 설정을 정리. **무단 정식 콘텐츠·별도 경제/스토리/프레임워크 신설하지 말 것**.
6. 사용자에게 현황 + 가장 우선 작업 묶음 1개를 제안. 첫 세션에 일괄 대규모 구현하지 않음.

### 다음 실제 개발 세션(승인 후)
- 후보 작업명: **M5-B.1 T04 Visual Evidence Integration**.
- 목표: 기존 승인된 Master/격리실을 기반으로 사용자 제공 CCTV Anchor·실험 결과/사고 이미지를 기존 Resource에 교체 가능하게 연결하고 **실제 플레이 UI**에서 일치성 확인. 사용자가 자산을 제공하기 전에는 증거 이미지를 가짜로 만들어 검증한 척하지 말 것.
- 자료가 아직 없으면 사용자에게 **이미지 제작 시트**를 구체적으로 전달하고, 코드 준비/Placeholder 정책 점검을 짧게 끝낸 뒤 기다릴 것. 충분히 준비된 다른 실제 Gameplay 범위가 있으면 승인받고 진행.
- 다른 대형 시스템 추가 대신 1개의 콘텐츠 수직 슬라이스를 완성하고 F6 검증, 720p/1080p 캡처, 사용자 플레이 피드백으로 수정.

## 9. 문서/파일 인덱스

### 기본 안내와 코드
- `README.md` — 프로젝트 소개; 원본 F5 중심으로 작성되어 최신 TEMP 시험 목록과 다를 수 있음.
- `docs/README.md` — Step/M 보고서 색인.
- `docs/architecture.md` — 실제 Main / View / State / Resource의 주요 소유권을 설명. 이후 M4/M5 변경과 대조 필요.
- `docs/verification.md`, `tools/verify_project.ps1` — 공개 기본 import/script/Main 검사. 임시 과거 대형 QA 수치는 별도 비공개 `.godot` 검증 기록일 수 있음.

### 최근 구현 보고서(이 순서로)
- `docs/m5_b_t04_temp_case.md` — **가장 최근, 로컬 파일 확인**.
- `docs/content_drafts/t04/t04_implementation_review.md` — T04 출처/설정 충돌 및 임시 구현 정리, 로컬 확인.
- `docs/m5_a_visual_production_slice.md` — 임시 이미지 연결과 UI/선택 사운드.
- `docs/m4_5_structural_ui_redesign.md`, `docs/m4_5_ui_asset_comparison.md` — UI 구조, 무료 에셋 라이선스, 실험 결과.
- `docs/m4_broadcast_incident_consequences.md`, `docs/m3_campaign_records_save_load.md`, `docs/m2_temp_case_vertical_slice.md`, `docs/m1_playable_case_ui_integration.md`.

### T04 사용자 입력 (수정하지 말 것)
- `assets/temp/t04/t04_master_reference.png`
- `docs/content_drafts/t04/t04_gameplay_v0_2.txt`
- `docs/content_drafts/t04/t04_profile_research_draft.md`
- `docs/content_drafts/t04/README.md`

### T04 구현(인계 시점 로컬에만 있을 수 있음)
- `resources/cases/temp_t04_case.tres`
- `resources/campaigns/temp_t04_playtest.tres`
- `scenes/playtests/t04_playtest.tscn`
- `scripts/main/t04_playtest.gd`, `scripts/presentation/t04_presentation.gd`
- `scripts/data/monitoring_outcome_data.gd`, `case_data.gd`, `research_entry_data.gd`
- `scripts/runtime/containment_resolution_state.gd`
- `scripts/main/main.gd`, `scripts/persistence/campaign_save_codec.gd`
- `scripts/read_models/campaign_fact_queries.gd`, 기타 사용된 read_models
- `docs/screenshots/m5_b/` — 보고서상의 캡처, 실제 로컬 파일 확인.

### 이미지·저장·빌드의 로컬 한계
- `.godot/verification/`는 Git 제외된 자동 검증 로컬 자료. 보고서 수치를 독립 재현 가능한 공개 suite로 오인하지 않는다.
- `builds/m5_b/CAP_T04_M5B.exe`와 `builds/m5_b/licenses/`: Git 제외, 로컬 백업 권장.
- `assets/local_only/m4_5/retro_screen_fx_lite/`: 라이선스 제한으로 Git 제외, 없으면 fallback.
- `user://campaign_saves/` 저장 데이터는 Godot 앱 사용자 데이터 폴더에 있으므로 **프로젝트 폴더와 별개**. 실제 save가 필요하다면 경로를 확인해서 별도 백업.

## 10. Codex로 다시 돌아갈 때도 지켜야 할 인계 포맷

Claude 작업 종료 때마다 `docs/DEVELOPMENT_CONTINUITY.md` 기록, 수정 파일과 검증 결과, 재현 절차, 작업 중 보류/미확정 설정, 에셋/라이선스, 마지막 Git HEAD/미커밋 변경, 다음 하나의 목표를 남긴다. Codex 복귀 시에도 이 문서와 최신 저장소 상태를 전달하면 동일한 방식으로 계속 개발 가능하다.
