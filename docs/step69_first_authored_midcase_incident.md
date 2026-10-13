# Step69 — First Authored Mid-Case Scripted Incident Integration

> 개발 이력: 이 문서는 해당 단계 작성 당시의 설계·구현·검증 기록입니다. 현재 구조는 [코드 구조 안내](architecture.md)를 참고하세요. `.godot/verification/` 자료는 Git에 포함되지 않는 로컬 자료이며, 공개 검사 방법은 [검증 안내](verification.md)에 있습니다.

기존 제품 Campaign에 첫 authored Mid-Case 사건을 연결했다. 게임 코드는 수정하지 않았다. 신규 콘텐츠는 전부 `[TEMP STORY CONTENT]`이며 교체 가능한 시설 장비 이상이다. CASE01 → CASE02 → TEMP Mandatory Incident01 → CASE03 순서와 기존 UI/Runtime/terminal 계약을 유지한다.

## 1. Repository Baseline

작업 전 비생성 파일 167개, 제품 GDScript 53개, Scene 17개, authored `.tres` 6개를 조사했다. 폴더는 `scripts/{data,runtime,read_models,main,ui,views}`, `scenes/{main,ui,views}`, `resources/{cases,campaigns,incidents,ui}`, `assets`, `docs`다.

HEAD `742d8e5fc971a6c7e81ac11bee14cabc4ac14d66`, branch `master`, upstream `origin/main`. 작업 전 staged/unstaged/untracked 변경은 없었다. 이전 Step66~68은 해당 HEAD에 커밋·푸시되어 있었다.

실제 `project.godot` Main은 `res://scenes/main/main.tscn`, 1920×1080 논리 해상도, 1280×720 창 override, `canvas_items`, GL Compatibility다. Autoload는 없다. 설정과 기존 파일을 보존했다. baseline/원본 파일/이전 증거 해시는 `.godot/verification/step69/baseline.json`, `before/`, `old_evidence_hashes.json`에 저장했다.

## 2. Existing Side System Audit

| 실제 파일/API | 기존 책임 / 이번 사용 |
|---|---|
| `scripts/data/campaign_data.gd` — `scripted_interrupts`, `get_interrupt`, `get_interrupt_at_checkpoint`, `get_validation_error` | 평평한 schedule, 전체 시작 전 검증, sequence와 별도 조회 |
| `scripted_interrupt_occurrence_data.gd` | interrupt/host/bundle/kind/stage/action, `get_source()` |
| `scripted_incident_data.gd` | event/Incident/Broadcast/Result Resource 링크 검사 |
| `incident_data.gd` | incident_id, display_name, description, broadcast_id, optional environmental_disturbance |
| `emergency_broadcast_data.gd` | 실제 클래스는 **EmergencyBroadcastData**; broadcast_id/display_name/prompt_text/options |
| `broadcast_option_data.gd`, `incident_result_data.gd` | option_id/display_text/result_id와 result_id/display_name/description |
| `scripts/main/main.gd` — `_side_checkpoint_at`, `_latch_side_checkpoint`, `_present_due_side_after_draw`, `_try_present_side_interrupt` | 실제 Stage 표시/draw 이후 source와 업무 캡처를 검증해 기존 Response 시작 |
| Main — `_bound_side_interrupt`, `_resume_side_work`, `_restore_side_work` | 동일 Case/Runtime/cursor, primitive work memento, layout/draw 후 exact equality 확인 |
| `InterruptedWorkViewState`, `ExperimentView.capture_work_state/restore_work_state/restore_work_result` | canonical 실험 사실과 UI 초안/결과/scroll/focus 분리 |
| `IncidentSource`, `IncidentResponseState` | CAMPAIGN_INTERRUPT=2; occurrence별 begin/confirm/complete-once; ACTIVE 하나 |
| Main `_response_source_capture`, Builder `classify_response_records/project_completed_scripted_responses` | Step68 source 검증, 실제 completed Scripted 역사 행 |

Step67 완료 기록 계약, Step68 구현, Step62 exact resume, Step63 Mandatory, Step66/66.1 navigation/utility와 현재 코드·Resource를 대조했다. 별도 Incident 시스템, State owner, View, API, 이벤트 Framework를 추가하지 않았다.

## 3. Actual Case03 Evidence

`resources/cases/test_case_03.tres`의 실제 제공 정보:

| 경로 | 실제 ID / 제공 내용 | 새 사건의 필수 단서 여부 |
|---|---|---|
| Profile | `TEST_CASE03_PROFILE_01`: contrasting floor strips를 따라가며 gaps에서 잠깐 멈춤 | 필수 |
| 최초 CCTV | `TEST_CASE03_CAM_01`: 띠를 따라 이동, gap에서 멈추고 돌아서며 보이는 띠로 복귀; lighting/airflow steady | 필수 |
| Profile Research | `TEST_CASE03_RESEARCH_PROFILE_01` | 정상 표시에서 발견; 재확인용 |
| CCTV Research | `TEST_CASE03_RESEARCH_CCTV_01` | 정상 표시에서 발견; 재확인용 |
| Experiment01/02 | contrast/gap 비교 | 사건 전에 실행하지 않음; 정답 근거로 요구하지 않음 |
| service-air reaction | 조건 관찰용 authored Resource | 새 사건이 적용/발견하지 않으며 정답 근거로 요구하지 않음 |

정상 플레이의 Profile→CCTV→Experiment 첫 진입을 사용했다. Case01/02 optional Experiment도 모두 건너뛴 새 제품 Journey에서 판단 가능했다. Profile은 조명 변화를 비교한 근거가 없으며 최초 CCTV는 일정한 조건의 관찰이다. A는 장기 격리 정답을 증명하는 것이 아니라 **보고된 안내 장비 결함을 해결하고 이미 관찰한 조건을 유지하는 지시**다.

## 4. Selected Checkpoint

기본 후보를 그대로 채택했다. `TEST_ENTRY_CASE_03 / STAGE_PRESENTED(0) / EXPERIMENT / action_id=""`.

실제 `_show_view`가 기존 승인된 Next/첫 Nav 진입으로 Experiment를 setup/bind/add_child하고 연구 표시 receipt를 설정한 뒤 occurrence를 latch한다. 두 process-frame 경계와 native draw를 기다려 `_try_present_side_interrupt`가 처리한다. 실제 Case03 Runtime이 이미 존재하며 Stage progression을 건너뛰지 않는다. 이미 방문한 화면의 순수 review, Archive 복귀, strict resume는 새 Stage checkpoint를 만들지 않는다.

이 위치는 최초 실험 전에 확정적으로 도달한다. 따라서 실제 캡처된 selection/result는 빈 문자열, scroll은 0, focus는 기존 `Margin/Content/Actions/NextButton`, 실험 잔여량은 2/2다. 없는 초안·결과를 만들지 않았다. Mandatory는 CASE02 다음 sequence entry에서 완료된 뒤 CASE03가 시작하므로 동일 Response가 겹치지 않는다. 대체 checkpoint는 필요하지 않았다.

## 5. TEMP Incident Content

| 콘텐츠 항목 | authored 내용 / identity |
|---|---|
| Incident title | `[TEMP STORY CONTENT] ROUTE PROJECTOR RESET` |
| Occurrence ID | `TEMP_INTERRUPT_MIDCASE_01` |
| Definition ID | `TEMP_EVENT_MIDCASE_01` |
| Incident ID | `TEMP_INCIDENT_MIDCASE_01` |
| Target Campaign Entry | `TEST_ENTRY_CASE_03` |
| Checkpoint kind | `STAGE_PRESENTED`=0 |
| Stage/action | `EXPERIMENT` / empty |
| 시설 상황 / 현재 이상 | 안내 projector 반복 reset으로 projected floor strip에 dark gaps 발생 |
| Incident에서 제공하는 관찰 | maintenance panel: task lighting/ventilation stable; continuous passive backup strip 사용 가능 |
| Guaranteed evidence | 실제 Case03 Profile, 최초 CCTV, 위 Incident 본문 |
| Optional evidence | Case03 contrast/gap 실험 및 이전 Case Archive를 요구하지 않음 |
| Broadcast | `TEMP_BROADCAST_MIDCASE_01`: 기존 단일 prompt/dynamic options |
| Prompt 요지 | 관찰된 조건을 유지하며 끊긴 안내 경로의 장비 결함에 대응할 지시 선택; 실험 결과 불필요 |
| Options | A: projector 격리+연속 backup strip; B: 음성 안내만; C: task lighting off; D: ventilation pulse |
| Approved Result per Option | `TEMP_OPTION_MIDCASE_01_A/B/C/D` → 각 `TEMP_RESULT_MIDCASE_01_A/B/C/D` |
| Correct response rationale | A가 gap 원인을 제거하고 실제 관찰의 visual cue/steady 조건을 유지 |
| Wrong response consequences | B는 gap 유지; C는 조건·가시성 변경에도 reset 지속; D는 airflow 변경에도 gap 지속 |
| Resume target | 동일 `TEST_CASE_03` Runtime, 원래 EXPERIMENT 화면, 기존 `RESUME WORK` |

새 제목/본문/prompt/선택지/Result 제목·설명 모두 `[TEMP STORY CONTENT]` 접두어를 가진다. 기존 Mandatory의 support-control/pump bypass 문제와 원인이 다르다. Case 격리 실패나 creature 탈출을 새 사건의 원인으로 작성하지 않았다.

## 6. Broadcast Fairness

필수 정보는 정상 진입 전에 실제 Profile/CCTV로 표시되고 Incident 본문에서도 정확하게 요약된다. backup strip의 가용성과 장비 fault는 **이번 Incident에서 처음 제공하는 임시 시설 정보**다. 새 CCTV Resource/가짜 이전 관찰/없는 Research를 주장하지 않는다.

A는 projector reset을 멈추고 연속적인 contrasting route를 제공하며 steady lighting/airflow를 유지한다. B/C/D는 각각 필수 관찰로 입증되지 않은 음성/어둠/airflow로 문제를 대체한다. Result는 각 지시가 장비 결함을 해결하지 못한 이유를 설명한다. 새로운 성공/실패 판정, 무작위 벌칙, 점수, Case outcome은 없다. 이 단계에서는 Result 서술에 따른 시설 대응만 보여 주며 환경 Runtime 효과를 만들어 내지 않는다.

## 7. Occurrence Identity

source = `(CAMPAIGN_INTERRUPT=2, TEMP_INTERRUPT_MIDCASE_01, TEMP_EVENT_MIDCASE_01)`. host = `TEST_ENTRY_CASE_03`이지만 사건 source occurrence와 다르다. 실제 active projection에 `source_case_id/source_entry_id`가 없음을 검증했다. Case source alias, fake Case/Failure Candidate/Resolution, 별도 Campaign Entry를 만들지 않았다.

Mandatory source는 `(CAMPAIGN_ENTRY=1, TEMP_ENTRY_MANDATORY_01, TEMP_EVENT_MANDATORY_01)`다. 두 source의 occurrence/definition/incident/broadcast가 모두 별개다.

## 8. Campaign Schedule Integration

`resources/campaigns/test_campaign_01.tres`에 occurrence **sub_resource 1개**와 새 bundle ext_resource를 추가하고 `scripted_interrupts`를 길이 1로 연결했다. occurrence용 기존 Script 참조와 load_steps만 함께 갱신했다.

`entries`의 ID/order/kind/Case/TEMP 참조는 기존과 동일하다. Case01/02/03 및 기존 Mandatory 파일은 byte-for-byte 보존했다. 별도 schedule 파일/관리자나 제품용 두 번째 side occurrence를 만들지 않았다. Resource path 기반 참조가 정상 import되어 추가 Script UID는 필요하지 않았다.

## 9. Actual Product Journey

새 `authored_validation.gd`는 **configured product Main**을 그대로 instantiate한다. 실제 exported Campaign, 기존 Case Resources, 새 schedule/Bundle를 사용한다. RNG seed=0은 기존 Failure 경로를 재현하기 위한 검증 설정이며 새 side trigger는 RNG를 사용하지 않는다. Outcome/Candidate/cursor/Research를 주입하지 않는다.

실제 Godot GUI pointer/keyboard 이벤트로:

CASE01 Profile/CCTV/Experiment skip/Containment → CASE02 같은 정상 진행 → Mandatory Incident/Broadcast A/Result/CONTINUE CAMPAIGN → CASE03 Profile/CCTV → 승인된 Experiment 첫 진입 → 새 Incident → Source Archive 왕복 → Broadcast 선택/모달 Cancel/TRANSMIT → authored Result → RESUME WORK → 동일 Experiment → 실제 Experiment01 실행 → Containment room01 제출.

| 독립 제품 Journey 변형 | CASE01/02 제출 | Side 선택 | 최종 실행 환경 |
|---|---|---|---|
| `ACTUAL69_R10_A` | 양쪽 올바른 room | A | headless, native1920, native1280; 처음 Experiment는 Nav+Space |
| `ACTUAL69_R10_B` | 양쪽 올바른 room | B | headless |
| `ACTUAL69_R10_C` | 양쪽 올바른 room | C | headless, native1920, native1280 |
| `ACTUAL69_R10_D` | 양쪽 올바른 room | D | headless |
| `ACTUAL69_R00_A` | CASE01 잘못된 room, CASE02 올바름 | A | headless |
| `ACTUAL69_R11_A` | CASE01 올바름, CASE02 잘못된 room | A | headless |
| `ACTUAL69_R01_A` | 양쪽 잘못된 room | A | headless, native1920, native1280 |

7개 독립 제품 Journey 변형을 최종 세 환경에서 13회 실행했다. Native 입력은 Godot viewport에 실제 InputEvent를 전달한 엔진 GUI 입력이며 물리 OS 마우스 조작이라고 주장하지 않는다.

## 10. Correct/Wrong Response Results

| 실제 선택 | authored Result | 대응 결과 |
|---|---|---|
| A | CONTINUOUS BACKUP ROUTE | projector 격리, continuous backup route, steady task lighting/air 유지 |
| B | ANNOUNCEMENT, GAPS REMAIN | 음성 안내가 visual gap 원인을 제거하지 못함; maintenance로 철회 |
| C | VISIBILITY LOST, RESET UNRESOLVED | 초기 steady lighting을 변경해 관찰/점검 가시성을 줄이지만 reset 해결 못함 |
| D | AIRFLOW CHANGED, GAPS REMAIN | 기존 steady airflow를 변경해도 projector gap 해결 못함 |

A/B/C/D 각각 실제 approved option→result link와 Result 본문을 검증했다. A/C는 두 GPU 해상도에서 전체 Result를 확인했다. 모든 Result에 원래 CASE03 업무로 복귀하는 문구가 있고, 기존 UI CTA는 RESUME WORK다. 오답도 실제 응답 완료 사실로 기록되며 fake FAILURE Case 판정을 만들지 않는다.

## 11. Exact Work Resume

Experiment가 표시되고 side due가 존재하는 실제 process_frame에서 업무 상태/owner를 독립 캡처했다. Incident context 및 복귀 후 상태를 그 값과 비교했다. Journey 증거는 다음 Journey에서 clear되는 작업 dictionary와 분리해 deep copy로 저장했다.

| 항목 | 실제 제품 결과 |
|---|---|
| Case/Runtime object identity | 동일 Case03 definition 및 동일 Runtime instance ID |
| canonical Stage/host/cursor/completed IDs | EXPERIMENT / TEST_ENTRY_CASE_03 / 모두 유지 |
| draft / displayed Result | 처음 진입의 실제 빈 값 유지; 새 선택·결과 생성0 |
| execution history / remaining | 빈 실행 history, 2/2; 복귀 후 정상 실행 가능 |
| scroll / focus | 실제 0/0 scroll 및 NextButton 상대 focus path 정확히 복원 |
| Research / Archive / Hypothesis | owner fingerprint 동일; 사건 내용으로 자동 발견0 |
| Pending/Resolution/Candidate/RNG/credit/token/opportunity | Side 시작·응답·Archive·복귀 자체 mutation0 |
| View | 기존 Step62 방식으로 새 Node를 bind/restore; 같은 UI 상태, 동일 Runtime; 주요 View 하나 |

자연스러운 첫 checkpoint에서 비어 있는 draft/result와 scroll0만 주장한다. 비어 있지 않은 draft/recorded result/긴 scroll/focus 복귀는 기존 Side controlled regression 6,231 calls 및 guards 1,211 calls에서 별도 검증했다. 그 fixture를 실제 Case03의 첫 presentation이라고 부르지 않는다.

## 12. Duplicate Trigger Prevention

canonical Response의 `(origin, occurrence, incident)` 존재를 기존 `_side_checkpoint_at`가 확인한다. 사건 완료 후 동일 EXP로 직접 Nav, CCTV review→EXP, normal Archive→Hypothesis→Research direct switch, Drawer 왕복을 수행했다. Response는 Side 1개, ACTIVE0, owner fingerprint 동일이었다.

동일 occurrence 재-begin, 잘못된 checkpoint/unknown lookup, current Result의 잘못된 source metadata, queued Result의 반복 advance/archive, pending 중 developer terminal 요청은 거절됐다. 별도 completed_interrupt_ids 저장소나 trigger flag를 추가하지 않았다.

## 13. Failure Incident Coexistence

실제 Case01만/Case02만/둘 다 실패한 제품 제출 경로에서도 새 사건이 발생했다. 둘 다 성공한 경로는 Case Failure Candidate가 필요하지 않았다. 실패 경로에서는 기존 notice/Major 응답을 정상 Dismiss/Resume하고 authored Story 흐름을 이어 간다. 양쪽 실패 native 경로에서는 실제 CASE03에서 기존 Failure notice도 발생했다.

기존 arbitration을 수정하지 않았다: 이미 ACTIVE response/notice는 먼저 처리하고, reached side intent는 safe draw에서 재시도한다. due Story와 준비된 미표시 Failure가 겹치는 checkpoint에서는 기존 Step62 정책대로 정상 회계를 유지한 채 Story 표시를 선택하고 Failure readiness/credit을 보존한다. 완료 Resume는 다음 Failure를 자동 연쇄 표시하지 않는다. 다음 승인 업무 경계의 기존 oldest-actionable/FIFO를 유지한다.

실제 제품 경로는 자연스러운 existing Failure readiness만 사용했다. 동시 준비·ACTIVE 충돌·notice 보류·유효 transition 보존·기존 후보 ordering의 극단 상태는 `regression/side_validation.gd`, `side_guard_validation.gd`, `bounded_validation.gd`의 **controlled fixture**로 검증했다. 검증을 위해 제품 gameplay 정책을 변경하지 않았다.

## 14. Step68 Historical Rows

실제 두 Story 사건을 완료하고 Case03 정상 Containment 제출 뒤 기존 유효 terminal boundary에서 `configure_developer_run_identity`와 `developer_commit_run_disposition("VOLUNTARY_RUN_END", recipient)`를 호출했다. 게임 플레이의 자동 종료 버튼/API를 추가한 것이 아니다.

각 실제 Journey recipient의 `historical_facts`에는 기존 Case 행과 정확히 다음 두 Scripted 행이 있다:

| field | Sequential 행 | Mid-Case 행 |
|---|---|---|
| identity_domain / entry_kind | SCRIPTED_EVENT / COMPLETED_SCRIPTED_RESPONSE_FACT | 동일 |
| origin_kind | 1 (CAMPAIGN_ENTRY) | 2 (CAMPAIGN_INTERRUPT) |
| source_occurrence_id | TEMP_ENTRY_MANDATORY_01 | TEMP_INTERRUPT_MIDCASE_01 |
| source_definition_id | TEMP_EVENT_MANDATORY_01 | TEMP_EVENT_MIDCASE_01 |
| incident_id | TEMP_INCIDENT_MANDATORY_01 | TEMP_INCIDENT_MIDCASE_01 |
| phase | COMPLETED | COMPLETED |
| actual_facts.broadcast_id | TEMP_BROADCAST_MANDATORY_01 | TEMP_BROADCAST_MIDCASE_01 |
| actual_facts.confirmed_option_id | TEMP_OPTION_MANDATORY_01_A | 실제 A/B/C/D option ID |
| actual_facts.incident_result_id | TEMP_RESULT_MANDATORY_01_A | 실제 승인 A/B/C/D result ID |

완료 전 ACTIVE/ACTIVE_CONFIRMED는 Side 역사 행0, completed Sequential 행1이었다. 실제 Result ack로 완료되어야 Side 행이 추가된다. Side 완료만으로 terminal mode가 바뀌지 않는다. commit=COMMITTED, 반복=ALREADY_COMMITTED, cleanup=CLEANED, recipient 내용 불변, 양쪽 live query=SOURCE_RELEASED를 모두 확인했다. Builder/Recipient 코드를 수정하지 않았다.

## 15. Source Archive

Side Incident/Broadcast/Result에서 기존 whole Archive List를 연다. 실제 이전 Case01 Detail 및 발견된 Research를 읽고 A/Esc/BACK으로 같은 Response에 복귀했다. 현재 Case03를 사건 source라고 위조하거나 현재 Runtime Research를 Archive에 자동 merge하지 않는다.

Source Archive의 work Nav/R/N 우회는 기존 guard가 차단한다. Broadcast unconfirmed option과 approved lock, Side work memento 및 owner는 보존됐다. 일반 업무 Archive에서는 Step66.1의 A→N→R 직접 전환이 기존 same held-work 방식으로 동작한다. Source Archive 정책을 바꾸지 않았다.

## 16. UI Compatibility

기존 IncidentView/BroadcastView/IncidentResultView, Archive, Utility Rail, Confirmation Modal만 사용한다. GameShell 및 17 Scene/53 GDScript/Theme/프로젝트 설정을 변경하지 않았다.

1920×1080와 1280×720 각 GPU 19 PNG를 기록했다. 각각 Side A/C/실패 경로의 Incident/Broadcast/Modal/Result/복귀 15개와 Source Archive 기존 경로 4개다. 고정 Shell geometry/CTA bounds/단일 주요 View 검사, 모달 Cancel/Tab/ShiftTab/Enter 및 Source Archive/직접 Utility 입력을 통과했다. 화면을 직접 열어 제목·본문·선택지 4개·모달·Result·RESUME WORK 및 2/2 실험 복귀를 시각 확인했다.

대표 원본: `../.godot/verification/step69/regression/ui_69_ACTUAL69_R10_A_incident_1920.png`, `../.godot/verification/step69/regression/ui_69_ACTUAL69_R10_A_broadcast_1280.png`, `../.godot/verification/step69/regression/ui_69_ACTUAL69_R10_A_modal_1280.png`, `../.godot/verification/step69/regression/ui_69_ACTUAL69_R10_C_result_1280.png`, `../.godot/verification/step69/regression/ui_69_ACTUAL69_R10_A_resumed_1280.png`. PNG/검증 코드/실행 로그는 ignored `.godot/verification/step69/`에만 있다.

## 17. Invalid Resource Tests

새 authored Campaign의 독립 clone에서 8종 validation 거절을 확인했다: blank occurrence, unknown host, non-CASE host, missing definition, invalid option→Result, duplicate occurrence, entry-ID collision, unsupported checkpoint. external bundle도 명시적으로 copy했고 product Resource fingerprint는 동일했다.

실제 제품 ACTIVE에서 동일 occurrence begin/active collision, unknown occurrence/wrong CCTV checkpoint/wrong ACTION checkpoint를 거절했다. actual Result metadata의 origin/occurrence/definition/incident/broadcast/result 6개 필드를 각각 잘못된 값으로 바꾼 callback도 mutation0이었다. resume pending의 repeated/stale Result·Archive 및 terminal 요청도 거절됐다.

추가로 기존 20종 invalid schedule을 별도 Main startup으로 실행해 모든 owner/View partial startup0을 확인했다. 이 controlled 회귀가 출력하는 **예상 ERROR20**은 정상 제품 실행 오류와 분리 집계한다. Invalid target kind/definition/mapping, unexpected source, ACTIVE collision, failed restore/retry, stale callbacks 등 사용자 목록 전체는 새 실제 경로+기존 controlled guards에서 검사했다.

## 18. Regression

회귀 fixture는 Step68 원본을 **Step69 namespace에 복사**했다. 첫 Side가 없던 이전 authored 전제를 가진 fixture에는 baseline Campaign 복제와 legacy Main Scene을 사용했다. 현재 제품 schedule을 제거하지 않았고 기존 증거를 수정하지 않았다. 아래 검사는 그 controlled legacy fixture에 현재 제품 Script/UI를 적용한 회귀다. 위 7개 Journey는 현재 authored 제품 그대로 별도 실행했다.

| 회귀 범위 | 최종 headless assertion calls |
|---|---:|
| Step58 Sequential mixed / bounded handoff | 162 + 174 |
| Step60 Fact Queries / lifetime / read-only repeated reads | 411,594 |
| Step62 Side / exact resume / collision guards | 6,231 + 1,211 |
| Invalid schedule / startup | 42 (예상 ERROR20 별도) |
| Step63 Mandatory 및 기존 Failure 제출 경로 | 1,840 |
| Step64~66 Shell/Nav/Focus/Scroll/Modal | 766 |
| Step66.1 Utility direct switching | 2,170 |
| Step68 historical/schema/source/terminal | 1,617 |
| Cleanup/no-run boundary | 1,130 |
| Active termination / closure | 708 + 460 |

Godot `4.7.1.stable.official.a13da4feb`로 새 cache가 없는 프로젝트 복제의 `--headless --editor --import`, 실제 저장소 editor import, 전체 제품 `.gd` 53개 `--check-only`, configured Main headless/native를 통과했다. Native는 GL Compatibility / AMD Radeon RX 6800이었다.

검증 수는 서로 다른 지표로 보고한다:

- 전체 Godot 직접 실행 **79회**: 초기 fixture 실패 2회와 성공 재실행 포함; 원본 attempt log를 보존했다.
- 최종 독립 process slots **73개 = headless70 + native3**: native는 configured Main1 + 실제 제품 Journey GPU 2해상도다.
- 최종 assertion calls **432,194**: 반복 Fact Query 411,594를 포함하므로 독립 시나리오 개수가 아니다.
- 새 실제 제품 검사 **4,089 calls** = headless2,195 + native1920 947 + native1280 947.
- 새 검사 ID는 **19개 assertion group**이며 독립 제품 Journey 변형은 **7개**다. 3개 주요 Journey를 두 native 환경에서 반복하여 최종 실제 Journey 실행은 **13회**다.
- 새 invalid Resource 변형8, foreign metadata 필드6은 별도 negative 변형이다.
- 최종 정상 제품/새 authored 검증 오류0/경고0. controlled invalid startup 예상 ERROR20, legacy Active/Closure 예상 WARNING15만 별도 있다. parse/GDScript 오류0.

초기 실패는 새 **검증 fixture**에서 기존 signal-only helper가 모달을 자동 승인한다고 가정한 것, 실제 query phase `ACTIVE_CONFIRMED`를 ACTIVE로 기대한 것, typed Broadcast 변수를 Experiment로 재사용한 것이다. clone의 shared array와 Journey 캡처 dictionary도 독립 복사하도록 수정했다. 초기 실패/성공 재검증 원본은 `attempts/`, 집계는 `invocations.jsonl`, `metrics_summary.json`에 보존했다. 제품 결함을 숨기거나 gameplay 정책을 바꿔 통과시킨 것이 아니다.

## 19. Files Changed

| 파일 | 분류 / 수정 이유 |
|---|---|
| `resources/incidents/temp_midcase_incident_01.tres` | 신규: Scripted bundle1, Incident1, Broadcast1, Options4, Results4 |
| `resources/campaigns/test_campaign_01.tres` | 수정: occurrence sub_resource1 및 schedule 연결, Script/Resource 참조/load_steps |
| `README.md` | 수정: 기존 byte prefix를 보존하고 Step69 안내만 append |
| `docs/step69_first_authored_midcase_incident.md` | 신규: 요청한 21섹션/콘텐츠 표/검증 보고 |

기존 modified2 / created2 / deleted0. 기존 167개 중 나머지 **165개 byte-for-byte 동일**, 전체 파일169개다. 기존 verification evidence **64,871개 변경0/삭제0**를 SHA-256으로 확인했다. README 기존 prefix도 동일하다. 새 검증 코드/fixtures/fresh import copy/log/PNG는 ignored `.godot/verification/step69/`에만 작성했다.

최종 `git diff --check` 통과, staged0. HEAD는 작업 전 값과 동일하고 `master`/`origin/main`도 유지한다. git diff의 Campaign 변화는 schedule만이며 `entries` 한 줄과 기존 4 entry sub_resource는 그대로다.

## 20. Known Gaps

Step53 Pending P2, Step54 cross-State atomic rollback, Step62 failed restore developer retry, Hypothesis getter P3는 그대로 OPEN이다. 새 복구 UI/atomic transaction/Save/Load/Ending/경제/정산/최종 콘텐츠를 구현하거나 기존 OPEN을 해결했다고 주장하지 않는다.

이 사건은 임시 authored narrative이며 Result의 maintenance 설명을 실제 lighting/airflow Runtime 변화로 구현하지 않는다. 올바른 장비 지시와 승인 ID를 표시·보존할 뿐 새로운 Case success/failure 판정은 없다. Case03 자체 최종 Outcome은 기존 authored unknown 상태다. terminal은 유효한 기존 developer boundary에서 명시 호출할 때만 기록한다.

## 21. Next Step Recommendation

새 시스템 대신 이 단일 authored Side의 읽기 부담·발생 시점·단서 공정성을 실제 플레이로 감사하기 좋다. 교체할 콘텐츠는 새 bundle 한 파일, 시점/host는 Campaign의 occurrence sub_resource다. 다음 사건을 늘리기 전에 최초 EXP 진입 interrupt가 플레이 흐름에 미치는 영향과 기존 Failure 사건 공존을 확인하는 것을 권장한다. 정식 세계관/자산 확정은 별도 단계로 남긴다.
