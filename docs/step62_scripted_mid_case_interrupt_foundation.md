# Step62 — Scripted Mid-Case Interrupt Foundation + Exact Work Resume

**SCRIPTED MID-CASE INTERRUPT FOUNDATION · CURSOR-PRESERVING SIDE OCCURRENCE · DETERMINISTIC CHECKPOINTS · SAME RUNTIME / STAGE RESUME · TRANSIENT WORK VIEW RESTORE · NO ACTUAL MANDATORY STORY CONTENT · NO ECONOMY / QUOTA / SETTLEMENT**

기존 프로젝트에 구현했다. 제품 TEST_CAMPAIGN_01은 CASE01→CASE02→CASE03 그대로이며 side schedule은 default empty다. 신규 사건은 in-memory TEST fixture에서만 실행했다. stage/commit/push 하지 않았다.

## 1. Repo Baseline

작업 전 실제 비생성 파일147개, 제품 GDScript49개, Scene15개, authored .tres4개, 제품 경로 파일120개. Main2253행/123함수. scripts/data, runtime, read_models, main, views / scenes/main, views / resources/cases, campaigns / assets / docs 구조를 실제 조사했다. project.godot, Scene, View transient/public API, Campaign definitions/Progress, runtime owners, Response source, closure/cleanup, Step60/61 계약을 대조했다. 적용 AGENTS.md 없음.

HEAD `6e8f167f699a3a95c91fee8668ae99d03e5d4db9`, branch `master`, upstream `origin/main`, staged0. 이전 Step55~61 누적 tracked 수정7/untracked20을 보호했다. Git HEAD diff와 이번 baseline diff는 서로 다르다. `.godot/verification/step62/baseline.json`, `before/`, `prior-evidence-hashes.json`에 기준을 저장했다. 이전 verification 파일55,661개를 보호 대상으로 해시했다.

## 2. Implemented Side Occurrence Data

[scripts/data/scripted_interrupt_occurrence_data.gd](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/scripts/data/scripted_interrupt_occurrence_data.gd:1)

`ScriptedInterruptOccurrenceData extends Resource`: interrupt_id, target_entry_id, scripted_incident_data, checkpoint_kind, stage_id, action_id. CampaignData의 `scripted_interrupts: Array[ScriptedInterruptOccurrenceData]`는 flat side schedule이다. `entries`만 sequence authority이며 side는 cursor/완료 entry에 들어가지 않는다. occurrence Resource가 source descriptor를 생성하고 CampaignData가 ID/checkpoint lookup을 제공한다. Manager/새 owner/history/전역 registry 없음.

| ID | authority / 실제 의미 |
|---|---|
| campaign_id | CampaignData/Progress session scope |
| entry_id | entries의 sequence occurrence |
| interrupt_id | side occurrence, Campaign의 entry IDs와 namespace 충돌 거절 |
| case_id | CaseData definition, 기존 unique Case requirement 유지 |
| event_id | ScriptedIncidentData definition, 여러 carriers에서 재사용 가능 |
| incident_id | Incident definition, source key의 마지막 성분 |
| source_occurrence_id | CASE entry / sequential entry / side interrupt ID |
| interrupted_entry_id | 중단된 현재 CASE entry, 사건 source가 아님 |

## 3. Campaign Validation

[scripts/data/campaign_data.gd :: get_validation_error](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/scripts/data/campaign_data.gd:12)

전체 schedule을 Gameplay owner 생성 전에 검증한다. null/blank/duplicate interrupt, sequence ID collision, null/blank/nonexistent/nonCASE target, missing/invalid Scripted bundle, unknown checkpoint kind, unsupported/blank Stage, Stage+Action mismatch, Stage kind의 불필요 Action, Action kind의 blank/unknown Action, duplicate target+checkpoint, Incident/Broadcast/Option/Result broken links를 거절한다. same Event definition 재사용은 허용하되 occurrence ID와 checkpoint는 달라야 한다. invalid 하나라도 있으면 partial startup0: Case/Runtime/Progress/Response/query/View 모두 생성하지 않는다.

20종 invalid startup을 headless/native 각각 실제 Main에서 실행했다. 이때 의도된 `Main: invalid CampaignData` ERROR20개씩은 일반 실행의 오류와 별도 집계했다. 제품 Campaign .tres를 Godot로 다시 serialize하지 않았다.

## 4. Checkpoint Model

[scripts/main/main.gd :: _side_checkpoint_at](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/scripts/main/main.gd:2336) / [scripts/main/main.gd :: _present_due_side_after_draw](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/scripts/main/main.gd:2358)

| kind | Stage | Action | 실제 safe boundary | duplicate / 복귀 |
|---|---|---|---|---|
| STAGE_PRESENTED | PROFILE/CCTV/EXPERIMENT/CONTAINMENT | empty | setup/add_child/binding/discovery/원래 회계 뒤 full process frame 및 native draw 확인 | Response existence로 once, Resume/Back/Recheck는 새 checkpoint0 |
| ACTION_ACCEPTED | EXPERIMENT | EXPERIMENT_RESULT_READ | 실제 Runtime execution + actual displayed Result + 유효 draw receipt + Next acknowledgement | accepted Result ID를 intent에 bind; Resume는 같은 EXP Result, Next 자동 재생0 |

Stage는 stable String이다. Main enum integer를 authored data에 저장하지 않는다. Run만 클릭하거나 그 프레임의 undrawn Next를 호출하면 사건/credit0. 기존 `.show_view(...,false)` ArchiveBack/Recheck/Resume는 Stage entry hook을 통과하지 않는다. 초기 PROFILE는 frame counter가 증가하기 전에 첫 process_frame이 올 수 있어서 두 process-frame 경계 뒤 확인하도록 수정했다.

`_side_due`는 interrupt/target/checkpoint와 View/Case/Runtime/accepted Result ID의 primitive presentation binding만 저장한다. queue/history/completed State가 아니다. notice 동안 intent를 보존하고 notice 종료 후 safe draw에서 재시도한다. 오래된/다른 binding은 시작하지 않고 fail-closed 유지한다. TIME/RANDOM/COUNT/CONDITION/IDLE trigger 없음.

## 5. Campaign Cursor Invariant

시작→Incident→Broadcast→Result→Archive→Resume 전체에서 Progress instance/campaign/current entry/completed IDs/transition이 동일하다. 같은 CaseData와 CaseRuntimeState object를 유지한다. side start/resume에서 dispatch, new Runtime, Case complete, Progress advance, Pending 판정, Research auto merge 호출0. 기존 valid transition을 가진 controlled fixture에서도 binding/budget을 clear/rebind/consume하지 않았다.

| 경로 | origin / source occurrence | current Case / Runtime | Progress | Candidate | return policy | Archive | completion authority |
|---|---|---|---|---|---|---|---|
| CASE Failure Major | CASE=0 / source CASE entry | 중단된 실제 Case / same Runtime | 중단 동안 고정 | 실제 Failure Candidate, 기존 완료 시 제거 | 기존 same work Resume | source Case detail | CASE Response COMPLETED |
| Sequential Scripted | CAMPAIGN_ENTRY=1 / sequential entry | null / null | Result ack 후 해당 entry 완료/advance | 생성0 | ADVANCE_CAMPAIGN_ENTRY | whole List | Response + Progress entry completion |
| Mid-Case Scripted | CAMPAIGN_INTERRUPT=2 / interrupt_id | 현재 Case / same Runtime | cursor/completed/transition 변화0 | 생성/변경/제거0 | RESUME_INTERRUPTED_CASE | whole List | side Response COMPLETED만 |

## 6. Incident Source Migration

[scripts/runtime/incident_source.gd](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/scripts/runtime/incident_source.gd:1)

CASE0 / CAMPAIGN_ENTRY1은 유지하고 CAMPAIGN_INTERRUPT2를 append했다. internal storage/callback/draft identity는 `source_occurrence_id`로 일반화했다. CASE/SEQ의 기존 occurrence 값은 그대로다. descriptor의 `source_entry_id`는 getter-only derived alias이며 side에서 empty다. State getter의 CASE/SEQ projection에만 read alias를 붙인다. side projection에는 fake entry/source Case field가 없다.

old legacy-only CASE/SEQ dictionary는 from_record에서 canonical descriptor로 정규화한다. canonical+legacy 값 충돌이나 side의 legacy field는 INVALID다. type mismatch도 invalid descriptor로 반환한다. 독립적인 dual stored authority 없음. sequential context도 canonical occurrence로 저장하며 Flow의 기존 sequence 문구는 실제 entry에서 derive한 값만 표시한다.

## 7. Response Identity

[scripts/runtime/incident_response_state.gd :: _key](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/scripts/runtime/incident_response_state.gd:11)

키는 JSON tuple `(origin_kind, source_occurrence_id, incident_id)`다. definition ID는 content binding validation이다. 기존 CASE/SEQ 숫자/값/serialized key bytes를 유지했다. ACTIVE1 / confirm-once / complete-once / duplicate begin reject를 재사용했다. 완료 여부는 해당 full source의 canonical COMPLETED record이며 별도 completed_interrupt_ids 없음.

같은 incident_id에 CASE/SEQ/SIDE가 공존하고, 같은 definition을 side A/side B/sequential entry에서 재사용하는 journey를 검증했다. Response 반환 dictionary 변경은 owner를 바꾸지 않는다. 충돌 alias를 주입한 query fixture도 INVALID이며 NOT_STARTED fallback0이다.

## 8. Interrupt Context

[scripts/main/main.gd :: _try_present_side_interrupt](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/scripts/main/main.gd:2367) / [scripts/main/main.gd :: _bound_side_interrupt](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/scripts/main/main.gd:2391) / [scripts/main/main.gd :: _resume_side_work](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/scripts/main/main.gd:2405)

context: full source origin/occurrence/definition, incident_id, interrupted_entry_id/interrupted_case_id, return_stage, runtime_instance_id/case_instance_id, derived return policy, primitive work_view_state, cctv_review_return_stage. Broadcast draft와 `_source_archive_return_stage`는 response overlay 복귀용으로 분리한다. old work Node/Resource/Callable/Signal을 memento에 보관하지 않는다.

begin preflight: Campaign/schedule/target CASE/source/content, same actual Case/Runtime/View/Stage/draw, terminal NONE, closure busy0, existing response/context/notice0, once check, memento validation. 실패 시 Response/Progress/Case/Runtime/Stage/View/Pending/Resolution/Candidate/Archive/Hypothesis/RNG mutation0을 fingerprint로 확인했다. due binding의 ID/instance/checkpoint/action Result를 바꾼 negative fixture도 통과했다.

complete preflight: active source/definition/incident/broadcast/approved result/View binding, current entry/Case/Runtime identity, checkpoint Stage, return policy, canonical+transient memento, review return, terminal/closure guard. 실패는 ACTIVE/context 유지 + `_side_resume_error` String 진단. 성공은 complete-once→resume_pending→same Stage recreate/canonical bind→Result rehydrate→layout/draw wait→signal-free restore→exact capture equality→context clear 순서다.

UI restore는 cross-object atomic rollback이 아니다. 완성 전 input/handoff/new event/closure를 차단한다. 예상치 못한 View 소실을 실제 fixture로 만들었고 COMPLETED/context를 보존했다. `_restore_side_work()`의 명시적인 developer retry로 같은 completed proof에서 복구했다. player recovery UI는 만들지 않았다. instance IDs는 live proof이며 Save identity가 아니다.

## 9. PROFILE Resume

FlowView common focus capture/restore만 사용한다. 현재 Profile에는 scroll/selection이 없으므로 만들지 않았다. same Profile content/same Runtime/discovery membership 유지. strict work restoration은 displayed discovery hook을 통과하지 않는다. 자연스러운 initial Stage trigger→response→PROFILE exact focus 복귀와 ArchiveBack/once를 검증했다.

## 10. CCTV Resume

CCTV helper는 실제 ConditionObservationScroll/focus만 capture한다. current environment/기본 관찰/condition rows는 same Runtime과 actual authored content에서 bind한다. strict restore는 `_discover_cctv_condition_observations`를 호출하지 않아 discovery/opportunity/credit0이다. 조건 관찰이 실제 존재하고 긴 row로 scroll75를 사용하는 controlled fixture도 headless/native에서 동일해졌다.

CCTV Recheck return Stage는 context에서 보존하며 실제 Back label/destination을 검증했다. 이 fixture는 이미 준비된 Recheck context의 controlled checkpoint injection이다. 제품 Recheck를 새로운 STAGE_PRESENTED trigger로 만들었다는 주장은 하지 않는다.

## 11. EXPERIMENT Resume

[scripts/views/experiment_view.gd :: capture_work_state](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/scripts/views/experiment_view.gd:252)

Runtime executed IDs/remaining/recorded condition IDs가 authority다. View가 unexecuted selection ID, actual displayed Result ID, ExperimentScroll/ResultScroll/focus를 capture한다. runtime history[-1]를 side 복귀 결과로 추정하지 않는다. 이미 두 실험을 실행하고 첫 결과를 표시한 상태, history가 있지만 blank Result인 상태, 새 unexecuted draft 선택 상태를 각각 복원했다. 의미 있는 scroll140/110와 generated selection focus도 검증했다.

기존 execution record의 observation IDs로 `ConditionSnapshot`을 만든다. 현재 환경 조건으로 실험을 다시 실행/재판정하지 않는다. actual authored condition을 가진 Case02 fixture에서도 original condition rows를 복원했다. UI restore 중 Run/실행/Research discovery0. Failure Major 기존 history-last helper는 공통 snapshot 생성 함수만 추출했고 이전 동작을 유지했다.

## 12. CONTAINMENT Resume

[scripts/views/containment_view.gd :: capture_work_state](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/scripts/views/containment_view.gd:169)

unconfirmed selected Room ID/RoomScroll/focus 및 confirmed ID의 read proof를 capture한다. Restore는 set_pressed_no_signal로 같은 draft checkbox를 표시하며 Runtime confirmation/Pending 생성/Confirm callback0이다. Room draft + scroll60 + 선택 focus를 GPU 화면에서도 확인했다.

canonical Runtime/Pending/Resolution이 우선이다. memento confirmed ID 또는 draft가 실제 canonical Room과 충돌하면 `ROOM_SOURCE_CONFLICT`로 complete 전 ACTIVE를 유지한다. 현재 지원된 authored checkpoints에는 정상적으로 Confirm 후 새 Stage에 들어가는 경계가 없으므로 **confirmed 상태를 억지로 새로운 interrupt trigger로 만든 journey는 실행하지 않았다.** validator/restore는 canonical confirmed lock을 따르며 기존 Failure Major confirmed-lock 회귀는 유지했다.

| View | canonical owner | transient capture | restore | signal behavior |
|---|---|---|---|---|
| PROFILE | actual Profile + same Runtime discoveries | relative focus String | 새 Profile bind 후 focus | discovery/advance emit0 |
| CCTV | same Runtime environment, authored rows | condition scroll/focus | rows bind 후 scroll/focus, review Back 보존 | observe/discover/opportunity/credit0 |
| EXPERIMENT | executed IDs/remaining/recorded observation IDs | selection/displayed Result/list/result scroll/focus | recorded Result + no-signal draft + scroll/focus | execute/discover0 |
| CONTAINMENT | Runtime confirmed Room/Pending/Resolution | draft Room/confirmed proof/scroll/focus | source conflict validate + no-signal checkbox | Confirm/Pending 생성0 |

## 13. Failure Accounting / Presentation Arbitration

[scripts/main/main.gd :: _try_process_failure_event_opportunity](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/scripts/main/main.gd:1459) / [scripts/main/main.gd :: _on_advance_requested](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/scripts/main/main.gd:881)

기존 함수에 `present_event` parameter를 추가해 회계는 그대로 실행하고 presentation만 분리했다. processed key/major-first counter 순서/saturation/threshold/RNG/token/credit/oldest ordering 의미를 유지한다. CONT entry의 due Stage occurrence가 있으면 정상 회계를 정확히 한 번 수행한 뒤 old presentation을 보류하고 drawn Story를 먼저 표시한다. EXP Result Next는 기존 read credit/token을 그대로 한 번 부여한 뒤 side를 검사한다. Run opportunity는 원래 경계에서 이미 계산되며 read에 추가 counter를 만들지 않는다.

이미 active Response/notice는 먼저 완료한다. due side는 credit 요구/생성/소비0, RNG draw0, Failure counter 추가0이다. story start/response/Archive/resume의 owner fingerprint가 동일하다. 실제 work action이 만든 원래 회계/credit은 보존한다. Story complete callback은 restore만 하며 old Failure나 다음 Story를 자동 연쇄 시작하지 않는다. 다음 accepted work action에서 기존 oldest actionable Major가 정상 시작한다. 기존 queue/Candidate를 삭제하거나 threshold/reset하지 않아 양방향 starvation을 만들지 않는다. sequential handoff의 bound one-off offer policy도 회귀 통과했다.

## 14. Source Archive

side Incident/Broadcast/Result에서 기본 whole Research Archive List를 사용한다. empty List는 정상이며 current Case를 source라고 위조하거나 Runtime discovery를 merge하지 않는다. 실제 archived member의 Detail→List→same response가 된다. broadcast_draft는 full canonical source+incident+broadcast+option primitive binding이고 approved option은 Response authority다. work memento는 Archive 동안 동일했다. confirmed lock/approved Result도 유지했다. optional archive focus/content feature 없음.

## 15. Stale / Duplicate Guards

`_is_active_view`의 inside_tree/current instance/not queued/notice/busy 검사를 유지했다. side callback은 추가로 full source origin/occurrence/definition/incident/broadcast/approved Result metadata 및 actual interrupted entry/Case/Runtime/context/return policy를 검사한다. same entry만으로 응답을 승인하지 않는다. Confirm 후 view metadata를 현재 approved canonical record로 갱신한다.

retained queued-delete Incident/Broadcast/Result/Archive/old Experiment/Containment의 actual signals를 직접 emit하고 mutation0을 검증했다. foreign response metadata fields를 바꾼 same-entry callback도 거절했다. same occurrence duplicate begin/ack/complete와 consecutive side occurrences/reused definition이 분리된다. relative focus 대상의 동적 생성 노드 이름을 ExperimentN/RoomN/Select로 고정한 이유는 재생성마다 자동 Node 이름이 달라지는 것을 피하기 위해서다. Scene layout을 바꾼 것이 아니다.

## 16. CampaignFactQueries Extension

새 public API는 `was_interrupt_response_completed(interrupt_id,incident_id)`, `get_interrupt_confirmed_option(...)`, `get_interrupt_incident_result(...)`다. schedule→occurrence→bundle→actual source record/approved content link를 읽는다. 기존 entry resolver와 `_resolve_response`를 공유해 validation/phase 로직을 복제하지 않았다. side 결과는 empty entry_id와 명시적 interrupt_id metadata를 갖는다. 기존 typed query value에도 derived empty interrupt_id를 추가했으며 old consumers의 entry fields/availability는 유지한다.

| 상태 | completion | Option/Result |
|---|---|---|
| valid, no Response | KNOWN false / NOT_STARTED | UNKNOWN NOT_STARTED |
| ACTIVE, unconfirmed/draft | KNOWN false / ACTIVE | UNKNOWN NOT_CONFIRMED |
| ACTIVE_CONFIRMED | KNOWN false | KNOWN approved IDs |
| COMPLETED | KNOWN true | KNOWN approved IDs |
| invalid scope/content/alias | INVALID | INVALID |
| cleanup/Main exit | SOURCE_RELEASED | SOURCE_RELEASED |

entry API에 interrupt_id를 넣으면 INVALID_ENTRY_ID다. 별도 completion cache/History/Condition evaluator 없음. Scripted nonCase Research 지원을 추가하지 않았다. sequential entry Research의 기존 UNSUPPORTED를 유지하고 side에는 Research query를 만들지 않았다. query objects는 primitive snapshot이며 반환값/ID를 바꿔도 owner0, 반복 1/10/100 query 읽기도 mutation0이다.

## 17. Terminal / Snapshot Guards

`_side_boundary_status`를 Case-current-valid 처리보다 먼저 사용한다. Snapshot은 early build/return 하므로 Case가 살아 있다는 이유로 unsupported가 덮어써지지 않는다. closure는 recipient/busy/freeze/Pending prepare 전에 반환한다. block 상태에서 recipient attempts0/commit0/terminal NONE/owner0/cleanup0을 검증했다.

| side 상태 | closure | Snapshot |
|---|---|---|
| not due | 기존 final Case precondition만 | 기존 Case observation |
| due-not-started | UNSUPPORTED_DUE_CAMPAIGN_INTERRUPT | 같은 unsupported, boundary_valid false |
| ACTIVE | UNSUPPORTED_ACTIVE_CAMPAIGN_RESPONSE | 같은 unsupported, Case overwrite0 |
| Archive overlay | ACTIVE와 동일 | fake source Case 없이 unsupported |
| Result active | ACTIVE와 동일 | approved IDs가 있어도 unsupported |
| resume-pending | UNSUPPORTED_INTERRUPT_RESUME_PENDING | completed라도 fail-closed |
| normal resumed | 기존 Case-only 범위 가능 | 기존 Case Snapshot |
| cleanup / no-run | 새 closure INVALID_PRECONDITION | 빈 owner/current invalid observation, query released |

**completed Scripted fact의 final RunDisposition recipient projection gap은 OPEN이다.** restored Case03의 정상 final-boundary closure fixture에서도 side Response가 historical_facts에 포함되지 않는 것을 확인했다. recipient schema/Builder/Snapshot class 확장0이며 Main의 side guard만 추가했다. ACTIVE Scripted terminal support/Ending 없음.

## 18. Cleanup

기존 verified recipient/receipt/identity preflight와 Step60 query release-before-destructive-reset 순서를 유지한다. side active/due/resume-pending은 committed boundary로 넘어가지 않는다. 정상 final Case closure 후 cleanup은 due/context/memento/response return/restore flags/error를 clear한다. Campaign authored schedule은 mutation0이다. Main exit도 external query를 release하고 transient side context를 해제한다. deferred 초기 Stage draw 대기 중 Main.free를 해도 callback/source 오류0이었다.

기존 partial reset fixture와 released query/resume retry/ALREADY_CLEANED를 회귀 실행했다. 다중 owner reset은 atomic rollback이 아니며 frozen proof/retry 계약을 유지한다. Save/Load 없음; live instance proof를 persistent ID로 주장하지 않는다.

## 19. Regression

Godot `4.7.1.stable.official.a13da4feb`로 fresh editor import1, 모든 제품 GDScript51개 check-only, configured product Main headless1/native1을 통과했다. 전체 final 성공 **81 unique process / 850,510 assertion calls**. 이 수치는 literal 검사 호출 집계이며 독립 시나리오 수가 아니다. 원래 Step60 query의 필드/반복 루프가 큰 비중을 차지한다. 신규 suite는 **15,032 assertion calls**: foundation6241/6279, guards1211/1217, invalid42/42(headless/native). 124/50/42 등의 named assertion IDs도 독립 gameplay scenario 수로 표현하지 않는다. foundation의 resume 관측15개/guards의 관측3개, schedule invalid20종류, 아래14검증 그룹을 구분한다.

| 그룹 | actual evidence / 검증 |
|---|---|
| A schedule validation | side_invalid; invalid20, no partial startup, repeated definition allowed/product empty |
| B source identity | source canonical/legacy conflict, CASE0/SEQ1/SIDE2 shared incident keys, seq+side repeated Event |
| C Profile | 자연스러운 initial drawn Stage→response→same Profile/Runtime/focus |
| D CCTV | normal Stage + actual environment observation scroll75 + controlled Recheck Back |
| E Experiment | no selection/draft/earlier Result/blank with history/new draft/list+Result scroll/focus/recorded condition |
| F Containment | no selection/Room draft/scroll60/focus + Room conflict complete preflight |
| G Action checkpoint | actual Run→visible Result→undrawn Next reject→read Next→side→same EXP→user Next |
| H arbitration | CONT once accounting, EXP existing read credit, old ready Major retention/postResume next action, active notice due retention |
| I Archive | empty/full List, Detail/List, Incident/Broadcast/Result return, unconfirmed draft/confirmed lock/work state |
| J stale/duplicate | queued-delete signal callbacks, same-entry foreign bindings, once/two side occurrences/transition unchanged |
| K queries | phase IDs/availability, entry misuse/invalid alias, mutation0, released source |
| L terminal/Snapshot | due/ACTIVE/overlay/Result/resume-pending early blocks; actual restore failure/retry; normal final Case scope |
| M cleanup | verified final Case commit/cleanup, external query release, Main exit during deferred draw |
| N existing regression | Step46/47/48/51/52/53/54/55/57/58/60 + actual Major/source Archive journey |

기존 검증: Snapshot4groups, oldest ordering matrix20rows, pacing15scenarios, ownership, closure, active termination, verified cleanup/partial failure, typed Campaign/invalid, mixed/sequential/repeated/bounded, actual Case failure→disturbance→Major→response→same work, typed facts를 새 namespace에서 재실행했다. 모든 최종 logs에서 script/runtime/parse error0, normal warning/error0. 의도된 developer diagnostics는 WARNING19(closure13/active2/ordering4), ERROR70(Campaign invalid13/scripted invalid17/side invalid20×2)로 별도 관리했다.

실행기는 UI Button signal과 실제 Main callbacks를 사용하며 toggle/focus 효과를 함께 재현한다. GPU 렌더는 실제 Windows Godot이다. OS 물리 마우스 클릭/F5 키를 눌렀다고 주장하지 않는다. configured Main을 project run으로 실행했으므로 F5와 같은 Main 설정을 검증했다. layout 변경0이어서 세 해상도 전체 반복을 새로 주장하지 않는다.

초기 실패도 보존했다: inherited ordering/gate fixture가 Runtime를 직접 교체한 뒤 query binding을 갱신하지 않았고 AUDIT_ROOM을 canonical Room으로 넣어 fact validation과 충돌했다. Step62 사본만 실제 binding/Room을 연결했다. 최초 runner 출력 cp949 문제도 UTF8로 수정했다. 첫 side suite에서 초기 PROFILE frame-count 경계의 실제 구현 결함과 fixture의 earlier Major/잘못된 closure boundary/잘못된 terminal category/해제 View fingerprint를 발견했다. 구현은 Stage full-frame wait로 수정했고 fixture는 실제 saturated counter/기존 final boundary/categories 및 null-safe measurement에 맞췄다. `initial-regression/`, `initial-side-1/`, `initial-side-2/`에 실패 로그/fixture를 보존했다. 재실행 final 모두 통과했다.

GPU1280×720에서 Experiment Result→Incident→Broadcast→Result→exact Experiment restore 및 Room draft→Incident→draft Resume를 직접 보았다. neutral CAMPAIGN EVENT/RESUME WORK, same result/count/선택 표시/scroll/focus, 한 View를 확인했다. `.godot/verification/step62/23_side_experiment_result_before_read.png`~`27_side_experiment_exact_resume.png`, `16_side_room_draft_before.png`, `17_side_room_draft_incident.png`, `20_side_room_draft_resumed.png`가 대표 증거다. Result read 전후 focus는 실제 Next acknowledgement로 이동하며 복원 기준은 interrupt 시작 시 capture한 focus다.

## 20. Files / Main Impact

이번 baseline 대비 수정10개(제품9+README), 생성5개(제품4+report), 삭제0이다. 이전 Git 미커밋 변경은 그대로 포함되어 있으므로 HEAD 전체 diff를 Step62 diff로 오인하지 않는다.

| 변경 | 파일 | 목적 |
|---|---|---|
| 생성 | scripts/data/scripted_interrupt_occurrence_data.gd + .uid | typed side authored checkpoint/source descriptor |
| 생성 | scripts/read_models/interrupted_work_view_state.gd + .uid | 실제 four View의 primitive preflight, 새 mutable owner 없음 |
| 생성 | docs/step62_scripted_mid_case_interrupt_foundation.md | 구현/262항목/evidence/known gaps |
| 수정 | scripts/data/campaign_data.gd | flat side field/전체 validation/lookup |
| 수정 | scripts/runtime/incident_source.gd | canonical occurrence/새 origin/derived alias/conflict guard |
| 수정 | scripts/runtime/incident_response_state.gd | canonical key/storage와 detached CASE/SEQ read alias |
| 수정 | scripts/read_models/campaign_fact_queries.gd | explicit side public APIs/common source resolver |
| 수정 | scripts/views/flow_view.gd | neutral side context + 실제 relative focus capture/restore |
| 수정 | scripts/views/cctv_view.gd | 실제 condition scroll/focus |
| 수정 | scripts/views/experiment_view.gd | actual display/draft/scroll/focus; stable generated names |
| 수정 | scripts/views/containment_view.gd | Room draft/scroll/focus/canonical lock; stable names |
| 수정 | scripts/main/main.gd | side due/start/route/context/binding/restore, 회계presentation 분리, early terminal/cleanup hooks |
| append | README.md | Step62 안내, 기존 byte prefix 보존 |

Main은 **2455행/133함수**, +202행/+10함수다. checkpoint lookup은 CampaignData/Occurrence, primitive validation은 작은 static helper, actual capture/restore는 View, query validation은 shared resolver에 둬 Main에 모두 복제하지 않았다. Main은 lifecycle/presentation을 소유한다. 기존 Failure Major의 Room draft/last-history behavior를 새 memento 경로로 바꾸지 않았다.

project.godot, 모든 Scene15개, authored .tres4개, 기존 ScriptedIncidentData/CampaignEntryData/Progress/CaseRuntime/Failure/Pending/Resolution/Archive/Hypothesis, terminal schema/Builder/Snapshot class, 기존 UID와 docs는 이번 baseline에서 byte-identical이다. Godot가 새 script UID2개를 생성했다. UI asset/theme/font/Autoload 추가0. 1920×1080 reference/1280×720 window/canvas_items/GL Compatibility 유지.

final-audit.json과 step62-baseline.diff는 이번 실제 범위를 기록한다. git diff --check exit0, staged0/HEAD/branch/upstream 동일. 기존 .gitattributes에 따른 LF/CRLF Git informational message는 engine warning과 구분한다. stage/commit/push0이다.

## 21. Known Gaps

새 P0/P1 결함은 최종 검증에서 발견하지 않았다. side UI restoration의 atomic rollback은 보장하지 않는다; unexpected failure는 context를 보존하고 explicit developer retry를 요구한다. 이를 새 player recovery 기능으로 확장하지 않았다. completed Scripted final recipient gap은 OPEN P2이며 이번 schema 범위에서 의도적으로 미해결이다. 기존 Step53 P2 `ACTIVE_FORCE_REQUIRES_PREPARED_PENDING`, Step54 multi-owner atomicity 한계, Hypothesis private enumeration P3를 유지한다. per-View focus path는 실제 Scene hierarchy에 의존하는 유지보수 사항(P3)이므로 해당 Scene 변경 시 capture/validation/tests도 함께 갱신해야 한다.

Failure Major는 기존 same Runtime/Stage/confirmed lock을 보장하는 경로이며 exact draft/display memento를 이번에 전면 적용하지 않았다. actual MI01/02/03/Case04~06/final/Ending/Save/StoryFlags/Condition evaluator/repeated Case/Economy/Quota/Settlement는 구현0. Product side schedule은 비어 있다. 이번 기반 구현과 실제 Story 콘텐츠 배치를 구분한다.

## 22. Next Step Recommendation

Step63은 실제 Mandatory Incident 자료가 준비되면 authored carrier/occurrence ID, target CASE entry, stable Stage 또는 EXPERIMENT_RESULT_READ 위치, Incident/Broadcast/Option/Result 문구/approved links를 결정하는 지점에서 시작하기 적합하다. Mandatory01은 sequential carrier, 후속 중단형은 side carrier를 선택하며 return policy를 content에 넣지 않는다. 자료 없이 실제 Story를 창작하거나 terminal gap/Ending/Save까지 자동 구현하지 않는다. completed Scripted terminal projection은 별도 schema/lifetime 결정 단계로 남긴다.

아래 항목은 사용자 요청의 종료 보고 번호1~262에 개별 대응한다. 상세 근거/표/제한은 위22개 섹션과 verification namespace에 있다.

### 요청 항목 1–262 개별 답변

1. **작업 전 Git 상태** — tracked 수정7/untracked20의 Step55~61 누적 변경을 보존했다.

2. **HEAD** — HEAD 6e8f167f699a3a95c91fee8668ae99d03e5d4db9 유지.

3. **branch/upstream** — master / origin/main 유지.

4. **staged** — 작업 전 staged0.

5. **기존 변경 보호** — 147개 baseline byte/hash와 이전 verification55,661개를 보호했다.

6. **Main before lines/functions** — 2253행/123함수.

7. **CampaignData before** — campaign_id/display_name/typed entries만 있었고 side schedule은 없었다.

8. **new occurrence class** — ScriptedInterruptOccurrenceData 추가.

9. **occurrence path** — scripts/data/scripted_interrupt_occurrence_data.gd.

10. **Resource base** — extends Resource, typed authored data.

11. **interrupt_id** — Campaign side occurrence의 stable String ID.

12. **target_entry_id** — 실제 existing CASE entry를 지정하는 String, source ID와 분리.

13. **ScriptedIncidentData link** — 공통 ScriptedIncidentData bundle을 그대로 참조한다.

14. **checkpoint kind** — STAGE_PRESENTED/ACTION_ACCEPTED 두 가지.

15. **stage ID** — PROFILE/CCTV/EXPERIMENT/CONTAINMENT stable String.

16. **action ID** — EXPERIMENT_RESULT_READ 또는 Stage kind의 empty.

17. **sequence entry ID collision** — entries ID와 side ID의 충돌 startup reject.

18. **duplicate interrupt** — duplicate interrupt_id startup reject.

19. **same checkpoint duplicate** — target+kind+stage+action 동일 checkpoint reject.

20. **repeated Event definition** — 서로 다른 occurrence/checkpoint에서 같은 definition 재사용 허용/검증.

21. **product Campaign side entries** — default empty; 제품 CASE01→02→03 유지.

22. **invalid startup** — 전체 validation 후 owner를 만드는 순서, invalid20종 검증.

23. **partial startup** — invalid startup의 Runtime/Progress/Response/query/View 생성0.

24. **checkpoint enum** — Occurrence.CheckpointKind의 두 값만 지원.

25. **supported Stage IDs** — stable String 업무 Stage4개.

26. **supported Action IDs** — 실제 EXPERIMENT_RESULT_READ 한 개만 지원.

27. **timer support** — 미구현0.

28. **random support** — Story random trigger0.

29. **generic condition support** — Condition language/evaluator0.

30. **Stage checkpoint semantics** — setup/add_child/binding 이후 process/draw 확인; 최초 PROFILE full frame 경계 보강.

31. **Action checkpoint semantics** — accepted actual Result read/Next이며 Run button 자체가 아니다.

32. **Experiment result read boundary** — recorded execution+actual displayed Result+draw receipt+사용자 acknowledgement.

33. **pre-read interrupt prevention** — Run/undrawn Next에서 사건/credit0을 실제 검사했다.

34. **Resume automatic Next 여부** — 자동 Next0; 사용자가 다시 원래 진행을 선택한다.

35. **once semantics** — 정상 complete한 side occurrence 재시작0.

36. **completion authority** — full CAMPAIGN_INTERRUPT/interrupt_id/incident_id Response COMPLETED.

37. **pending due intent** — Main-local primitive _side_due, completion history가 아니다.

38. **queue 여부** — generic queue0; validation상 한 checkpoint에 한 occurrence.

39. **cursor invariant** — same Progress instance/current CASE entry 전 과정 유지.

40. **completed CASE IDs** — side 중 completed CASE IDs 변화0.

41. **transition intent** — 기존 valid transition을 clear/rebind/consume하지 않았다.

42. **ScriptedIncidentData mode field** — ScriptedIncidentData mode field 추가0.

43. **return policy source** — sequential/side carrier에서 ADVANCE/RESUME derive.

44. **CAMPAIGN_INTERRUPT origin** — CAMPAIGN_INTERRUPT=2 추가.

45. **enum compatibility** — CASE0/CAMPAIGN_ENTRY1 numeric 유지.

46. **source_occurrence_id** — canonical source occurrence String으로 internal storage/callback/draft 이행.

47. **source_entry_id compatibility** — CASE/SEQ getter/projection의 derived alias만, side empty/alias field0.

48. **dual authority** — 독립적인 두 저장 authority 없음; 값 충돌 INVALID.

49. **fake source entry** — target CASE entry를 side source_entry로 넣지 않는다.

50. **source definition ID** — side definition=ScriptedIncidentData.event_id.

51. **interrupted entry ID** — interrupted_entry_id는 현재 실제 CASE entry.

52. **Response semantic key** — JSON [origin_kind,source_occurrence_id,incident_id].

53. **definition validation** — definition은 actual bundle binding 검증이며 key 성분 아님.

54. **existing key compatibility** — 기존 숫자/occurrence 값/serialized CASE·SEQ key 유지/검증.

55. **Response ACTIVE1** — 기존 one active Response authority 재사용.

56. **duplicate begin** — 동일 occurrence duplicate begin0.

57. **start preflight** — valid Campaign/target/Case/Runtime/Stage/View/draw/source/memento/terminal/notice/response preflight.

58. **start failure mutation** — invalid source/instance/Stage/busy/context 등의 begin owner/UI/RNG mutation0 fingerprint.

59. **interrupt context** — same live work binding과 detached primitive memento를 Main이 소유.

60. **context fields** — full source+incident, interrupted entry/Case, Stage, instance IDs, policy, work state, review return; overlay return 분리.

61. **old View retention** — old View는 detach/queue_free, parked Node/strong reference0.

62. **generic memento framework** — BaseMemento/Manager/serializer framework0.

63. **Profile capture** — 기존 실제 focus만 capture; scroll/selection 새로 만들지 않았다.

64. **Profile restore** — same Profile/Runtime 바인딩 뒤 focus 복원.

65. **Profile discovery mutation** — strict restoration에서 새 Profile discovery0.

66. **CCTV capture** — actual condition scroll/focus와 Main의 review destination.

67. **CCTV restore** — same current environment/authored rows + captured scroll/focus.

68. **CCTV opportunity mutation** — restore의 CCTV opportunity/discovery/pacing0.

69. **Recheck return** — 기존 Back destination과 label 보존; controlled Recheck context fixture.

70. **Experiment selection capture** — unexecuted selected experiment ID를 직접 capture.

71. **displayed Result capture** — actual get_displayed_result_id를 직접 capture.

72. **Experiment scroll** — ExperimentScroll/ResultScroll 실제 값과 focus capture/restore.

73. **Result restore source** — Runtime의 기록된 execution observation IDs로 condition snapshot.

74. **history[-1] assumption** — side에서 history[-1] 추정0; 첫 결과/후속 실행 history fixture 검증.

75. **environment re-evaluation** — 현재 환경으로 실행 결과 재계산0.

76. **Experiment execution mutation** — restore execution0/remaining 변화0.

77. **Containment draft capture** — unconfirmed selected Room ID/RoomScroll/focus capture.

78. **Containment draft restore** — set_pressed_no_signal로 draft 시각 상태 복원.

79. **confirmed Room authority** — Runtime/Pending/Resolution confirmed source가 authority.

80. **Room conflict** — ROOM_SOURCE_CONFLICT 진단; complete 전 ACTIVE 유지.

81. **Pending mutation** — Room draft restore Pending 생성0.

82. **Room scroll** — actual RoomScroll60/focus 복원 headless/native 확인.

83. **accepted start allowed mutations** — Response ACTIVE/context/response View/due consumption만, gameplay owner0.

84. **Progress preservation** — Progress cursor/completed/transition/instance 불변.

85. **Resolution preservation** — Resolution records 불변.

86. **Pending preservation** — Pending IDs/Room records 불변.

87. **Candidate preservation** — Candidate order/records/threshold/counters/flags 불변.

88. **Archive preservation** — Research Archive membership 불변.

89. **Hypothesis preservation** — Hypothesis records/counters 불변.

90. **Runtime preservation** — same Runtime instance/all recorded facts 불변.

91. **RNG preservation** — Story begin/response/Archive/resume RNG state/draw0.

92. **credit preservation** — Story 자체 pacing credit 생성/소비/요구0.

93. **token preservation** — accepted work token은 원래 의미대로, Story가 변경하지 않는다.

94. **opportunity preservation** — Story 자체 opportunity0, 원래 업무 회계만 유지.

95. **failure accounting separation** — 기존 회계 body는 그대로 실행, present_event parameter로 표시만 제어.

96. **failure presentation separation** — due Stage/accepted Result read는 old presentation 전에 Story 우선.

97. **RNG semantic regression** — 기존 실제 seed-based Major/closure journey 및 source fingerprint 회귀.

98. **threshold regression** — 기존 threshold/counter saturation 유지.

99. **processed key regression** — processed key/dedup 유지, CONT entry 회계 정확히1회.

100. **oldest ordering regression** — Step47 matrix20rows/다음 accepted work oldest Major 통과.

101. **active Response collision** — already active CASE/SEQ/SIDE Response 중 nested begin0.

102. **notice collision** — active notice 동안 due 보존, notice 종료 safe draw 뒤 시작.

103. **Story priority** — 같은 reached checkpoint의 Story first.

104. **old Failure presentation** — 동일 시점 old Failure presentation0, Candidate는 유지.

105. **Resume chain 여부** — complete callback은 exact restore만; event 자동 chain0.

106. **post-Resume old Failure** — 다음 accepted work action에서 기존 oldest Major eligibility 정상.

107. **starvation** — Story가 due일 때 old presentation 보류/old Candidate 삭제0으로 양방향 보존.

108. **Scripted credit** — Story pacing credit 자체 변경0; 경제 credit 없음.

109. **Scripted RNG** — Story RNG draw0.

110. **Scripted opportunity** — Story Failure opportunity 추가0.

111. **accepted work accounting** — 원래 accepted-work 회계는 정상 once; read 추가 counter0.

112. **Source Archive default** — whole Research Archive List, empty도 정상.

113. **fake Case context** — CAMPAIGN EVENT / RESUME WORK, fake SOURCE CASE/FAILURE0.

114. **current Research merge** — Archive 열려고 current discovery merge0.

115. **empty Archive** — empty List roundtrip 정상 검증.

116. **Broadcast draft** — full source-bound unconfirmed Broadcast draft 복원.

117. **confirmed lock** — canonical approved lock 유지.

118. **Result restore** — same approved Result로 Archive return.

119. **response return context** — response overlay return Stage와 interrupted work Stage 분리.

120. **work draft preservation** — Archive 동안 work memento byte/primitive 값 동일.

121. **final action** — side final button RESUME WORK.

122. **complete preflight** — full source/result/View/current entry/Case/Runtime/Stage/memento/policy/terminal preflight.

123. **preflight failure** — preflight 실패 ACTIVE/context 유지/owner0; String 진단.

124. **complete order** — preflight→complete once→pending→recreate/bind→layout/draw→exact restore verify→clear.

125. **restore failure behavior** — completed를 rollback했다고 주장0; retained context와 explicit developer retry.

126. **fail-closed** — pending 동안 input/handoff/new Incident/closure 차단.

127. **duplicate ack** — duplicate ack의 stale/current source mismatch mutation0.

128. **stale Result ack** — queued-delete old Result ack mutation0.

129. **sequential regression** — Step58 mixed/sequential/repeated/bounded 회귀 통과.

130. **sequential current_case** — sequential에서는 기존 current_case/Runtime=null.

131. **side current_case** — side에서는 active current_case 유지.

132. **same Runtime proof** — runtime_instance_id/case_instance_id 및 full Runtime fingerprint 동일.

133. **dispatch calls** — side start/resume dispatch call0.

134. **new Runtime count** — side start/resume new Runtime0.

135. **Case completion mutation** — side가 Case completion을 만들지 않는다.

136. **Progress advance mutation** — side가 Progress advance를 호출하지 않는다.

137. **Research merge mutation** — side response/Archive/restore Research merge0.

138. **response Scene reuse** — 기존 Incident/Broadcast/IncidentResult Scene 그대로 재사용.

139. **context display** — neutral CAMPAIGN EVENT, 실제 event/occurrence/interrupted work 표시.

140. **final button labels** — side RESUME WORK / sequence Continue Campaign / Failure 기존 Resume.

141. **UI layout** — Scene/layout/theme/font/asset 변경0.

142. **stale View guard** — current View/inside_tree/not queued/notice/busy guard 유지.

143. **full source callback guard** — full source metadata+approved IDs와 same entry/Case/Runtime/context/policy 추가 검증.

144. **queued-delete callback** — 실제 retained queued-delete 노드의 signals를 before-free에 재호출, mutation0.

145. **same entry consecutive source** — same CASE entry에서 side A PROFILE/side B CCTV 두 occurrence 실제 완료.

146. **repeated Event** — same definition을 side2개와 sequential1개에서 재사용 검증.

147. **cross-origin collision** — 같은 incident 문자열의 CASE0/SEQ1/SIDE2 key 공존 unit 검증.

148. **query API names** — was_interrupt_response_completed/get_interrupt_confirmed_option/get_interrupt_incident_result.

149. **query resolver** — entry/interrupt source 선택 후 shared _resolve_response; approved link/phase 공통.

150. **interrupt completion query** — canonical COMPLETED만 KNOWN true.

151. **interrupt Option query** — canonical approved Option ID, draft는 UNKNOWN.

152. **interrupt Result query** — canonical approved Result ID, actual option/result link 검사.

153. **query no-response** — valid not-started completion KNOWN false / ID query UNKNOWN.

154. **query ACTIVE** — ACTIVE false, approved 전 UNKNOWN / phase ACTIVE.

155. **query COMPLETED** — COMPLETED true + approved IDs / phase COMPLETED.

156. **query draft** — unconfirmed draft를 confirmed fact로 읽지 않는다.

157. **query released** — external query가 cleanup/Main.free 뒤 SOURCE_RELEASED.

158. **Scripted Research** — sequential Research UNSUPPORTED 유지; side Research query 추가0.

159. **was_entry_completed misuse** — was_entry_completed(interrupt_id) INVALID_ENTRY_ID.

160. **terminal active block** — active side UNSUPPORTED_ACTIVE_CAMPAIGN_RESPONSE.

161. **active block ordering** — live current CASE 판단 및 recipient/freeze/Pending 준비보다 먼저 side guard.

162. **active block mutation** — recipient attempts/commit0, terminal NONE, owner/RNG/cleanup0.

163. **due closure** — UNSUPPORTED_DUE_CAMPAIGN_INTERRUPT, intent 유지.

164. **resume-pending closure** — UNSUPPORTED_INTERRUPT_RESUME_PENDING, completed라도 restore 전 거절.

165. **Snapshot active** — current Case 존재해도 side unsupported snapshot.

166. **Snapshot overwrite guard** — early return으로 current-valid boundary_status overwrite0.

167. **normal resumed closure** — 복귀 완료 뒤 기존 실제 final Case precondition의 closure만 가능.

168. **completed terminal gap** — completed Scripted final recipient historical fact 누락은 OPEN.

169. **terminal schema change** — RunDisposition/Builder/Snapshot class schema 변경0.

170. **cleanup side context** — verified cleanup에서 due/context/memento/return/restore/error clear.

171. **cleanup query release** — query release는 기존 destructive reset보다 먼저.

172. **partial cleanup** — partial failure는 frozen proof/retry, atomic rollback 미보장 유지.

173. **Main exit** — Main exit external query release와 transient clear; pending draw free도 검증.

174. **Save** — Save/Load0, live instance ID만 사용.

175. **product Story content** — actual Mandatory01/02/03 제품 content0.

176. **test fixture source** — .godot/verification/step62의 in-memory typed Campaign / TEST bundle.

177. **Profile fixture** — 자연스러운 PROFILE Stage start/response/exact focus/same Runtime.

178. **CCTV fixture** — 자연스러운 CCTV와 condition row/scroll75 환경 fixture.

179. **CCTV Recheck fixture** — controlled Recheck context→interrupt→same CCTV→원래 EXP Back; 새 Recheck trigger 아님.

180. **Experiment no-selection fixture** — 자연스러운 EXP Stage no-selection 복귀.

181. **Experiment draft fixture** — actual unexecuted checkbox draft/focus 복원.

182. **Experiment displayed-result fixture** — recorded earlier displayed Result/scroll, blank/history와 new draft를 구분.

183. **Action checkpoint fixture** — Run/undrawn Next0, actual result read Next→side→EXP→manual Next.

184. **Containment draft fixture** — actual Room02 draft/scroll60/focus exact restore; confirm/Pending0.

185. **Containment confirmed fixture** — 현재 supported normal checkpoint에 Confirm 후 새 Stage boundary 없음; 억지 confirmed interrupt journey 미실행. canonical validator/기존 Failure lock 회귀 유지.

186. **Room conflict fixture** — controlled memento confirmed mismatch→ROOM_SOURCE_CONFLICT, ACTIVE 유지.

187. **once fixture** — completed occurrence latch/begin 거절 + ArchiveBack/Recheck/Resume 새 trigger0.

188. **duplicate start fixture** — ACTIVE/COMPLETED 동일 occurrence begin/confirm/complete-once 검증.

189. **active collision fixture** — CASE Major/Sequential/Side active의 nested begin0.

190. **notice collision fixture** — active notice+injected reached due intent→block→normal Dismiss/safe draw→Story.

191. **Story-vs-Major fixture** — CONT accepted entry once accounting/Story first; EXP read credit once/old ready Major 보류.

192. **Candidate preservation fixture** — 전체 Candidate records/order/threshold/counters/flags preservation fingerprint.

193. **RNG fixture** — Story start/response/resume RNG fingerprint 동일; 기존 seed journey 회귀.

194. **credit fixture** — accepted work 원래 credit/token 보존, Story 자체 추가/소비0.

195. **cross-origin fixture** — CASE/SEQ/SIDE shared incident collision0 unit.

196. **repeated definition fixture** — shared Scripted bundle의 two side + sequential actual journey.

197. **Archive fixture** — Incident/List/Detail/List/Broadcast/Result actual callbacks roundtrip.

198. **stale Incident fixture** — retained queued Incident advance/archive callback mutation0.

199. **stale Broadcast fixture** — retained queued Broadcast confirm/archive/advance mutation0.

200. **stale Result fixture** — old Result acknowledgement mutation0.

201. **stale Archive fixture** — old Archive List/Back/case request mutation0.

202. **stale old work fixture** — interrupted old Experiment/Containment execution/confirm signals mutation0.

203. **query fixture** — before/ACTIVE/draft/confirmed/COMPLETED/INVALID/released + 반복1/10/100 readonly queries.

204. **query entry misuse fixture** — side ID의 entry query INVALID, explicit interrupt APIs 필요.

205. **terminal active fixture** — actual active side의 voluntary/forced request recipient0/freeze0/owner0.

206. **terminal due fixture** — actual notice due 상태에서 closure explicit unsupported.

207. **terminal resume-pending fixture** — actual completed-but-layout-pending/View loss에서 closure unsupported와 context retention/retry.

208. **Snapshot fixture** — 모든 side block의 snapshot status/false boundary/empty Case active projection 검증.

209. **cleanup fixture** — normal final Case closure→verified cleanup→external query released; partial cleanup 기존 회귀.

210. **Step46 regression** — Step46 Snapshot normal/phases/response/isolation 통과.

211. **Step47 regression** — Step47 oldest actionable matrix20rows 통과.

212. **Step48 regression** — Step48 pacing15scenarios/undrawn/dedup/read semantics 통과.

213. **Step51 regression** — Step51 typed record/ownership/invalid fixtures 회귀 통과.

214. **Step52 regression** — Step52 developer closure/live prepare/idempotency 및 actual journey 통과.

215. **Step53 regression** — Step53 Case Failure active termination 회귀 통과, P2 유지.

216. **Step54 regression** — Step54 verified cleanup/preflight/partial failure/no-run 회귀 통과.

217. **Step55 regression** — Step55 authored Campaign routing 회귀 통과.

218. **Step57 regression** — Step57 typed entries/full validation/CASE order 회귀 통과.

219. **Step58 regression** — Step58 mixed/repeated/standalone/bounded headless/native 통과.

220. **Step60 regression** — Step60 entry/Resolution/Room/Response/Research/readonly/release headless/native 통과.

221. **failure Major regression** — actual Case Failure→Disturbance→Major→Broadcast→Result→same work journey 통과.

222. **source archive regression** — 기존 source Case Archive/option draft/lock/Result journey 회귀 통과.

223. **parser** — 제품 GDScript51개 check-only, parse0.

224. **editor import** — Godot4.7.1 fresh editor import 통과.

225. **product Main headless** — configured 제품3-Case Main headless 실행 통과.

226. **product Main native** — configured Main Windows GPU project run 통과.

227. **side suite headless** — side/invalid/guards 신규 전체 headless3process 통과.

228. **side suite native** — 같은 신규 전체 Windows GPU3process 통과.

229. **GPU smoke** — 1280×720 Exp Result→response→exact Exp / Room draft→response→draft를 PNG로 직접 확인.

230. **warnings** — 최종 normal engine warning0; controlled warnings19는 별도.

231. **controlled diagnostics** — 의도된 developer WARNING19/ERROR70, invalid startup/terminal regression과 일반 실행을 구분.

232. **runtime errors** — 최종 script/runtime error0. 초기 fixture 오류 로그는 보존.

233. **parse errors** — 최종 parse error0.

234. **processes** — 최종 묶음81 unique successful process; 초기 실패/재실행은 별도 보존하며81에 합산하지 않았다.

235. **assertion calls** — 850,510 literal assertion calls, 신규15,032; 대부분 repeated query field checks.

236. **scenario count distinction** — named assertion ID/반복 호출은 독립 scenario 수 아님. 신규14그룹/invalid20종/resume observation18개 구분.

237. **authored preservation** — authored product Campaign/Case/Scene/project bytes 동일; in-memory fixture tree mutation0 검사.

238. **project.godot** — project.godot byte-identical, 해상도/stretch/renderer/Autoload 유지.

239. **Scene files** — 모든 Scene15개 byte-identical.

240. **.tres files** — 제품 .tres4개 byte-identical, no reserialize.

241. **CampaignData schema** — scripted_interrupts typed side field/validation/lookup만 추가.

242. **Main after lines/functions** — 2455행/133함수: +202행/+10함수.

243. **new product files** — 새제품 GD2+UID2; 새 Scene/asset0.

244. **modified product files** — 제품 GD9개 수정, 기존 기능 보존/공통 validation/real View helper에 책임 분리.

245. **new UID** — Godot가 occurrence/helper의 UID2개 생성, 기존 UID 모두 동일.

246. **deleted files** — baseline 파일 삭제0.

247. **README** — Step62 문단 append, 기존 byte prefix 보존.

248. **report** — docs/step62_scripted_mid_case_interrupt_foundation.md,22필수 섹션+262개별 항목.

249. **git diff --check** — git diff --check exit0; informational EOL message는 engine warning과 구분.

250. **staged final** — 최종 staged0.

251. **commit/push** — stage/commit/push0, HEAD/branch/upstream 유지.

252. **new P0** — 최종 검증에서 새 P0 발견0.

253. **new P1** — 최종 검증에서 새 P1 발견0.

254. **new P2** — side restore atomic rollback 미보장/fail-closed developer retry와 completed Scripted terminal gap을 제한으로 명시, player recovery UI0.

255. **new P3** — focus validation의 실제 Scene hierarchy 의존은 유지보수 P3; 앞으로 Scene 변경 시 helper/tests 동반 갱신.

256. **Step53 P2** — ACTIVE_FORCE_REQUIRES_PREPARED_PENDING OPEN P2 유지.

257. **Step54 atomic limitation** — Step54 multi-owner reset atomic rollback 보장0, frozen proof/retry 유지.

258. **completed Scripted terminal gap** — completed side/sequential fact는 final recipient Case-only projection에 계속 누락.

259. **Story content status** — 실제 Story content/Ending/Save/Flags/Economy 구현0; TEST fixtures만.

260. **Step63 readiness** — authoring foundation은 준비됐으나 실제 Mandatory 자료/target/checkpoint 결정이 필요.

261. **required Story material** — occurrence/target entry/Stage 또는 Result-read Action, Incident/Broadcast options/Result approved links와 문구 필요.

262. **final recommendation** — Step63은 자료 기반 authored content 배치에서 시작; terminal gap/schema/Save/Ending은 별도 범위로 결정.
