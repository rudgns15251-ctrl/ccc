# Step61 — Scripted Mid-Case Incident Interrupt Contract Design

**DESIGN ONLY — 제품 Gameplay / Scene / Resource / State 변경 없음.**

[확정] Mandatory Incident 01은 CASE02 완료 → 순차형 Scripted Incident → CASE03이다. 후속 Mandatory Incident 1~2개는 특정 Case 업무를 중단하고 같은 Case Runtime/이전 업무 위치로 복귀한다. Failure/Resolution/Candidate/Case를 위조하지 않는다. [미정] 실제 사건 내용, Case 번호, Stage, Action, 문구, 선택지, Result는 아직 정하지 않는다.

이 문서는 실제 코드의 현재 동작과 향후 구현 추천을 구분한다. 새 이름/필드/함수는 [추천·미구현]이며 존재하는 API로 취급하지 않는다. 두 progression semantics를 **설계**했으며 Mid-Case Scripted가 실행 가능해졌다는 뜻은 아니다.

## 1. Current Repo Facts

현재 비생성 파일146개, 제품 GDScript49개, Scene15개, authored .tres4개, 제품 경로 파일120개. Main2253행/123함수. 실제 구조는 scripts/data, runtime, read_models, main, views와 scenes/main, scenes/views, resources/cases, resources/campaigns, assets, docs다. project.godot은 Godot4.7/GL Compatibility, Main Scene,1920×1080 viewport/1280×720 window/canvas_items, Autoload0이다. 새 프로젝트가 아니다.

HEAD `6e8f167f699a3a95c91fee8668ae99d03e5d4db9`, branch `master`, upstream `origin/main`, staged0. 이전 Step55~60의 tracked 수정7/untracked19가 남아 있다. 적용 AGENTS.md는 저장소/상위 경로에서 발견하지 않았다. 기존 파일/README/보고서/UID/검증 증거를 보호한다.

| 조사된 사실 | 현재 코드 근거 | 설계에 주는 제약 |
|---|---|---|
| Product TEST_CAMPAIGN_01은 CASE01→CASE02→CASE03만 포함 | resources/campaigns/test_campaign_01.tres, scenes/main/main.tscn | 실제 Mandatory01 entry/content도 아직 제품에 없음 |
| EntryKind는 CASE/SCRIPTED_INCIDENT | scripts/data/campaign_entry_data.gd | Scripted mode/side schedule 필드 없음 |
| ScriptedIncidentData는 content definition | scripts/data/scripted_incident_data.gd | event_id + Incident/Broadcast/Result bundle, execution 위치와 분리 가능 |
| Progress만 sequence cursor/완료 IDs/전환 intent 소유 | scripts/runtime/campaign_progress_state.gd | Case 중단을 cursor 이동으로 모델링하면 안 됨 |
| IncidentSource origin은 CASE/CAMPAIGN_ENTRY뿐 | scripts/runtime/incident_source.gd | side occurrence는 현재 표현하지 못함 |
| Response key는 origin/entry/incident, ACTIVE1/COMPLETED | scripts/runtime/incident_response_state.gd | one-active/once 기반은 재사용 가능 |
| Sequential은 current Case/Runtime=null, Result ack 뒤 advance/dispatch | [main._dispatch_campaign_entry](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/scripts/main/main.gd:2221), [main._advance_response](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/scripts/main/main.gd:1727) | 유지한 채 새로운 return branch 필요 |
| Failure Major는 실제 Failure Resolution/Candidate/credit 요구 | [main._try_start_major_incident](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/scripts/main/main.gd:1633) | Scripted 시작 API로 그대로 호출 불가 |
| 현재 resume Stage는 CCTV/EXPERIMENT/CONTAINMENT뿐 | [main._has_interrupt_context](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/scripts/main/main.gd:1604) | PROFILE 신규 지원과 정확한 transient 복원이 필요 |
| Case 업무 View를 매번 제거/queue_free/재생성 | [main._show_view](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/scripts/main/main.gd:144) | same Runtime/Stage만으로 동일 draft/result/scroll 보장 못함 |
| Step60 fact adapter는 entry 기반 owner 조회 | [queries._response_context](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/scripts/read_models/campaign_fact_queries.gd:267) | side ID를 현 entry API에 넣으면 INVALID_ENTRY_ID |

Step40/42 read/resume, Step54 cleanup, Step58 bounded/sequential, Step59 fact 설계, Step60 구현/보고서를 현재 코드와 대조했다. `.godot/verification/step61/`에 baseline/source inventory/함수 본문을 저장한다. **Step61 새 Godot/gameplay 실행0**. Step60 수치를 새 테스트 성과로 재사용하지 않는다.

## 2. Sequential Scripted Contract

[확정] 사용자 흐름:

```text
CASE02의 실제 accepted handoff
→ Progress CASE02 completed
→ 현재 sequential Scripted entry dispatch
→ Incident → Broadcast 선택/Confirm → Result의 정상 ack
→ Response COMPLETED
→ 해당 Scripted entry completed + sole cursor advance
→ CASE03 새 Runtime / PROFILE dispatch
```

Containment 선택/Confirm만으로 CASE02 completed라고 부르지 않는다. 현재 `_handoff_to_next_case()`는 actual Pending 판정 성공→Research merge→Progress advance→dispatch 순서다. Case02가 SUCCESS여야 Mandatory01이 생긴다는 조건은 두지 않는다. FAILURE라면 기존 Case Failure owner는 그대로 남을 수 있으나 Mandatory01 source와 혼동하지 않는다. 기존 valid handoff 자체가 실패하면 완료를 위조하지 않는다.

[추천] 기존 SCRIPTED_INCIDENT carrier와 Step58 실행 경로를 그대로 사용한다. Sequential 실행 중 Case Runtime이 없다는 기존 계약, once completion, Source Archive List, CONTINUE/Continue Campaign action을 유지한다. 별도 Trigger/scheduler/Failure Candidate를 거치지 않는다. 실제 `.tres` insertion과 Mandatory01 내용은 후속 구현이며 이번 단계 변경0이다.

## 3. Mid-Case Interrupt Contract

[확정] 현재 CASE entry active + same CaseData/Runtime + 업무 Stage → Story checkpoint → Scripted Incident → Broadcast → Result → same Case 업무 복귀. **current CASE completed IDs/cursor는 전 과정에서 변하지 않는다.** new Runtime/reset/Resolution/Candidate/Failure/자동 Research unlock0.

[추천] `SCRIPTED_INTERRUPT` 실행 route를 기존 순차형 route와 분리한다. 기존 `NORMAL_INTERRUPT`의 업무 context/response UI 흐름을 재사용하되 Candidate 시작·완료 코드는 통과하지 않는다. 시작 전 full authored bundle, occurrence target, active CASE/Runtime/View, Stage, terminal/notice/response guard를 검증한다.

| 단계 | 변경 가능한 것 | 보존하는 것 |
|---|---|---|
| checkpoint 감지 | 작은 presentation intent(occurrence/entry/checkpoint) | Progress/Case ownership |
| accepted start | Response ACTIVE + transient interrupt context + response UI | same Case/Runtime/업무 State |
| draft/Confirm | View draft, Response approved Option/Result IDs | Case Room/판정/실험/Research/Failure owners |
| Result 정상 ack | actual Response COMPLETED | CASE entry completed/cursor/transition 그대로 |
| Resume | 기존 Stage의 새 View에 UI memento 복원 후 context 해제 | Case/Runtime instance 및 canonical facts 그대로 |

active Case는 Main이 계속 참조하므로 adapter current Runtime을 clear/rebind하지 않는다. `_dispatch_campaign_entry()`는 호출하지 않는다. Interrupt occurrence 완료는 해당 Response COMPLETED에서 유도하며 별도 completed-interrupt truth set/Story flag를 만들지 않는다. ScriptedIncidentData가 현재 단일 Incident definition을 가진다는 범위에서 once 의미가 충분하다.

## 4. Trigger Alternatives

| 후보 | 재현/authoring | 주요 위험 | 평가 |
|---|---|---|---|
| A fixed Stage checkpoint | 대상 entry/Stage만 수정, deterministic | 단순 _show_view 호출 횟수는 Archive/Resume/Recheck 재진입도 포함; render/중복 구분 필요 | [추천] 보조 모델 |
| B authored Action checkpoint | 승인 Action/읽기 확인 후 발생, 정보 노출 위치 통제 | Run 승인과 Result read를 혼동하면 읽기 전에 화면이 교체됨 | [추천] 우선 모델 |
| C N meaningful actions | deterministic count가 가능 | 어떤 행동이 1회인지 새 owner/counter/범용 조건을 요구, Story 위치 간접적 | [추천] 초기 제외 |
| D Random | seed 재현 가능하나 사건 위치 불확정 | Narrative pacing/QA/control 약화, RNG 결합 | [추천] 기본 제외 |
| E real-time timer | elapsed-time 위치 | idle/Archive 체류/창 비활성 영향을 받음 | [추천] 기본 제외 |

[미정] CASE04/EXPERIMENT/첫 Result read는 사용자 설명의 예시다. 현재 CASE04 Resource/Scene/API는 없고 새로 만들지 않았다. 실제 target entry, Stage, action, 조건과 발생 시점은 콘텐츠 결정 후 지정한다.

## 5. Recommended Trigger Model

[추천] 작은 typed authored checkpoint의 **A/B 두 종류만**을 허용한다. 기본은 B. Stage는 stable String ID로 검증하고 data가 Main script를 preload하거나 Main enum 숫자에 종속되게 하지 않는다. 범용 ConditionData/expression/interpreter/EventBus/Timer 없음.

- A: 실제 target 업무 View의 최초 안정적인 presentation checkpoint. setup/add_child/그림 완료 후 safe boundary이며 `_show_view()` 호출 자체를 사용자 읽음으로 간주하지 않는다. Archive Back/Resume/CCTV Recheck는 새 업무 Stage 진입 trigger가 아니다.
- B: 실제 accepted 업무 Action checkpoint. Experiment Result read 후보는 실행 기록+현재 표시된 approved Result+기존 draw receipt+사용자의 읽기 Next가 모두 일치해야 한다. Run signal/선택 클릭/Archive Back/idle는 read가 아니다. 해당 Next로 다음 Stage를 열기 **전에** due 사건을 제시하며 Resume 후 다시 업무 Next를 누르게 한다.

[추천·미구현] schedule carrier 최소 필드는 interrupt_id, target_entry_id, scripted_incident_data, checkpoint_kind, stage_id, action_id(해당 kind만 사용). first qualifying action 등 semantics는 구체적 authored Action 종류로 고정하고 임의 숫자/조건식 parser는 만들지 않는다. 사건 위치를 변경해도 interrupt_id/event_id는 유지한다.

trigger는 Progress/Resolution을 수정하지 않고 Step60 query를 read-only로 사용할 수 있다. Mandatory 발생 자체를 과거 SUCCESS/FAILURE로 취소하는 것이 기본은 아니다. 실제 Fact는 향후 문구/정보/선택/Result 변화의 입력으로 쓸 수 있다. UNKNOWN은 false, ACTIVE_CONFIRMED는 COMPLETED로 해석하지 않는다. INVALID/SOURCE_RELEASED는 잘못된 setup/lifetime이며 random/default branch로 숨기지 않는다. 문구 variation engine/Story evaluator는 이번 단계0이고 다음 foundation에서도 필요 없으면0이다.

## 6. Campaign Cursor / Progress Ownership

[추천] sequence의 sole cursor는 계속 CampaignProgressState 소유다. interruption 중 current entry는 CASE이고 Case ordinal도 그대로다. side event를 `entries`에 끼워 넣은 뒤 cursor를 왕복시키지 않는다. Case completed/next dispatch는 기존 handoff만 수행한다.

기존 Progress `_transition`은 source CASE→target entry handoff의 bounded Failure offer intent다. side interruption의 위치/once/pending을 여기에 저장하지 않는다. 작은 Story presentation intent는 pending UI 업무이며 historical truth/새 progression cursor가 아니다. 이미 있던 transition을 interruption 때문에 clear/rebind/consume하지 않는다. 새 trigger 판정은 handoff commit 전에 수행하고 due가 있으면 cursor 이동을 보류한다. 기존 bound handoff에서 재개된 경우에도 사건이 끝날 때까지 동일 intent와 CASE를 유지해야 한다.

side completion의 authority는 IncidentResponseState. 완료 ID를 별도 Progress 배열에 복제하거나 current Case를 completed로 마킹하지 않는다. 정상 ack 후 **Resume**와 sequential ack 후 **advance**를 다른 branch로 실행한다.

## 7. Authored Data Placement Alternatives

| 방식 | cursor/복귀 | editing/위치 이동 | identity/Save/validation | Main/State 영향 |
|---|---|---|---|---|
| A CASE entry.scripted_interrupts[] | sole cursor 보존 | Case 업무 옆에서 편집 쉬움; 다른 Case로 이동은 배열 소유자 변경 | Campaign 전체 nested ID 검증 필요; relocation 때 ID 유지 가능 | 작은 확장 가능, 모든 Entry kind의 새 필드 유효범위 검증 |
| B CampaignData의 side schedule 배열 | sole cursor 보존 | target_entry_id/Stage/Action만 변경; Story 배치 한곳에서 비교 | Campaign-scoped interrupt ID/target CASE/source chain 검증 간단 | 작은 occurrence Resource와 readonly lookup; 복제 State 불필요 |
| C SCRIPTED_INCIDENT entry에 metadata, sequence 밖 참조 | 일반 entry/side entry의 역할 혼합 | 두 collection의 참조/완료 semantics를 이해해야 함 | get_entry의 "sequence entry" 의미가 모호, 두 carrier간 링크 검증 증가 | dispatch/progress/query 예외 증가 |
| D cursor Scripted로 이동 후 원래 Case로 rewind | sole cursor/monotonic completed 계약 깨짐 | 기존 sequential처럼 보여 실제 resume identity 복잡 | Case completed 오판, runtime recreate/reset, Save ambiguous | [추천] 거절 |

[추천] **B**. 현재 1~2개의 후속 사건 규모에서도 flat schedule와 target entry pointer가 적절하다. A도 가능하지만 “나중에 발생 위치를 데이터 수정으로 이동”하는 요구에 B가 더 직접적이다. global event registry나 별도 campaign scheduler framework는 만들지 않는다. typed side-occurrence Resource 하나(이름 후보 `ScriptedInterruptOccurrenceData`, 현재 없음)와 기존 ScriptedIncidentData payload만 권장한다.

[추천] ScriptedIncidentData는 Sequential/Interrupt 공통 content definition으로 재사용한다. execution mode는 **carrier/route에서 유도**한다. 공유 content Resource에 mutable SEQUENTIAL/INTERRUPT 모드를 저장하면 같은 Event definition을 두 방식으로 사용하는 순간 충돌한다. behavioral mode 구분은 필요하지만 데이터마다 redundant execution_mode/return_policy를 중복 저장할 필요는 없다. Stage/Action relocation과 definition content 변경을 분리한다.

후속 validation: nonempty unique interrupt_id, 존재하는 CASE target entry, allowed work Stage/Action 조합, valid Scripted bundle, definition link unique, future kind reject, 반복 Event definition 허용/동일 occurrence 재실행 거절. [추천] sequence entry ID와 interrupt ID도 Campaign 내 전체 occurrence IDs에서 중복을 거절해 authoring 혼동을 줄인다. 같은 checkpoint에 여러 mandatory를 배치하면 implicit array priority로 처리하지 말고 초기 validation에서 거절한다. 향후 배치가 실제로 필요하면 명시 순서를 별도 결정한다.

## 8. Incident Source Identity

현재 source_entry_id는 실제 Campaign sequence entry를 뜻한다. 현재 CAMPAIGN_ENTRY origin과 entry lookup만으로 side event를 표현하면 가짜 entry, ambiguous completion, Source Archive/terminal/query 오류가 발생한다.

[추천·미구현] origin CASE=0/CAMPAIGN_ENTRY=1은 보존하고 **CAMPAIGN_INTERRUPT**를 추가한다. 이 origin의 occurrence는 interrupt_id이고 source_definition_id는 ScriptedIncidentData.event_id다. 이름 `source_occurrence_id`를 canonical source 의미로 일반화한다. event_occurrence_id와 interrupt_id를 동시에 추가하지 않고 authored interrupt_id 하나를 사용한다.

| identity | 의미 | 임시 runtime 값과 구분 |
|---|---|---|
| campaign_id | bound Campaign/session scope | engine instance ID 아님 |
| entry_id | CASE 또는 sequential Scripted의 sequence occurrence | array index 아님 |
| interrupt_id | Campaign side event의 stable occurrence | 실행 횟수 counter 아님 |
| event_id | 공유 Scripted content definition | 같은 event를 여러 occurrence가 사용 가능 |
| incident_id | source bundle 안의 Incident definition | occurrence를 대체하지 않음 |
| interrupted_entry_id | 돌아갈 현재 CASE occurrence | source event identity와 별개 |
| case_id | interrupted CASE definition | fake event source Case로 쓰지 않음 |
| runtime/case instance IDs | live binding/preflight 증명 | future Save 식별자로 저장 금지 |

기존 순차형 source origin을 재해석하거나 기존 ID를 interrupt ID로 재사용하지 않는다. CampaignFactQueries의 현재 entry API는 side ID를 지원하지 않는다. [추천] 후속 occurrence resolver와 명시적인 interrupt Response query surface가 필요하며 현재 `was_entry_completed(interrupt_id)`를 완료 query로 쓰지 않는다. 기존 과거 entry fact query는 유지하고 새 Response resolver에만 side schedule lookup을 추가한다. Research provenance는 Scripted non-Case UNSUPPORTED를 유지한다.

## 9. Response Identity

[추천] canonical semantic key는 `(origin_kind, source_occurrence_id, incident_id)`, definition ID는 binding/content 검증용이다. Response State는 Campaign session 하나에 묶여 있으므로 지금 별도 global Campaign-key store는 불필요하다. future Save 또는 여러 Campaign을 한 store에 합칠 때는 campaign_id도 bound envelope에서 확인해야 한다.

Field/descriptor/lookup **migration 검토는 필요하다**. 기존 CASE/CAMPAIGN_ENTRY에서 occurrence value와 origin numbers를 유지하면 JSON key bytes 자체는 기존 `[origin,entry,incident]`와 같게 보존할 수 있다. 새 CAMPAIGN_INTERRUPT는 새 namespace다. rename만 했다고 전체 call site가 자동으로 안전해지는 것은 아니다.

[추천] 후속 migration은 IncidentSource/from_record/matches, Response `_key`/projection, Main content binding/Archive draft/stale guards, FlowView context, fact resolver, verification을 같이 점검한다. legacy source_entry_id가 필요하면 기존 CASE/SEQUENTIAL에만 derived read alias로 제공한다. canonical 저장과 alias를 두 개의 독립 key authority로 만들지 않는다. dual-field input이 충돌하면 INVALID로 거절하고 definition ID를 occurrence key로 fallback하지 않는다. side origin에 가짜 source_entry_id/source_case_id를 만들어 현재 helper를 속이지 않는다.

Response ACTIVE1, confirm-once, complete-once, duplicate begin reject는 그대로 재사용한다. completed side occurrence는 actual Response status에서 유도한다. 같은 Event/Incident 문자열을 Sequential과 Interrupt에 사용해도 origin/occurrence가 다르면 별개다. 반복 Event는 허용하지만 repeated Case 지원은 여전히0이다. 이 migration은 이번 단계 실행0이며 Save migration도 구현하지 않는다.

## 10. Interrupt Context

현재 Failure context는 interrupted_case_id/return_stage/runtime_instance_id/case_instance_id 네 필드이며 Archive 왕복 중 broadcast_draft를 추가한다. source는 Response State에서 조회한다. interrupted_entry_id나 정확한 업무 UI draft/result/scroll은 현재 저장하지 않는다.

[추천] 재사용할 최소 live context:

| 필드/의미 | authority / 사용 |
|---|---|
| interrupted_entry_id, interrupted_case_id | current Progress CASE / Case definition과 복귀 시 agreement |
| interrupted_stage | PROFILE/CCTV/EXPERIMENT/CONTAINMENT whitelist, overlay Stage와 별개 |
| runtime_instance_id, case_instance_id | 같은 live objects인지 검사; Main이 actual refs를 계속 보유 |
| bound source occurrence/incident | Response key와 schedule binding, historical facts 복제하지 않음 |
| return policy | route에서 derive: ADVANCE_CAMPAIGN_ENTRY 또는 RESUME_INTERRUPTED_CASE |
| work_view_state | 선택/표시 Result ID/scroll/focus 등 primitive UI memento |
| cctv_review_return_stage | CCTV Recheck라면 업무 Back 목적지까지 보존 |
| source_archive_return_stage + response broadcast draft | response overlay 왕복용 별도 context |

기존 표현 `ADVANCE_CAMPAIGN_ENTRY`를 유지하고, resume 의미는 `RESUME_INTERRUPTED_CASE`로 명확히 구분한다. Stage 전체용 State Machine/Base/Interface hierarchy를 추가하지 않는다. shared context 검증과 작은 per-View capture/restore helpers만 권장한다. 이 helper들은 현재 API가 아니며 다음 단계 구현 항목이다.

Failure-only: actual Resolution/Candidate eligibility, disturbance/major thresholds, source Failure Case lookup, credit 소모, candidate completion 제거, Case-scoped response Research merge. Common: single response, stable source binding, same Runtime/case checks, Archive draft roundtrip, View replacement/stale guard, approved result acknowledgement, UI restore. Scripted side에는 Failure-only 코드를 호출하지 않는다.

## 11. Resume Semantics

[확정] same Case Runtime/same Stage가 필수이며, [추천] 미확정 선택/표시 Result/읽기 위치까지 primitive memento로 복원한다. canonical values는 Runtime/owner에서 다시 읽고 draft는 승인 fact로 변환하지 않는다.

1. 시작 전 완료된 업무 Action의 상태를 기준으로 View draft/Result/scroll/focus와 entry/Case/Runtime identity를 capture한다. old View는 기존처럼 detach+queue_free한다.
2. response 진행/Archive 왕복 동안 Case 업무 identity/owners/environment/history/discovery/remaining count를 유지한다. 자동 실행/추가 연구/Failure opportunity0.
3. Result ack에서 actual bound source/approved result, current CASE entry, same Runtime/Case, resume Stage, 복원 ID 유효성을 **complete 전에** preflight한다. 실패하면 response/context를 유지하고 advance/reset/재판정하지 않는다.
4. 정상 ack에서 actual Response를 once complete하고 같은 업무 Stage의 새 View를 구성해 memento를 signal 없이 restore한다. CASE complete/dispatch0. original input의 후속 Next/Confirm를 자동 재생하지 않는다.
5. 복원 확인 뒤 context/overlay return을 해제한다. same source의 duplicate ack는 State/active View guard로 무시한다. Resume callback에서 다른 사건을 자동 시작하지 않는다.

View를 실제로 park/reattach하는 방식은 draft 보존이 쉽지만 기존 callback이 재활성화되어 stale input을 수락할 위험, hidden Node/process/cleanup 소유권을 늘린다. [추천] **현재의 View recreate 방식 + 작은 명시적 transient capture/restore**. UI Node 강한 참조/범용 memento framework/Save snapshot을 만들지 않는다. 복원 helper는 승인 signal을 emit하지 않으며 checkbox는 pressed-no-signal 방식을 사용한다.

현재 `_show_view(stage,false)`만으로 엄밀한 restoration-only가 되지 않는다: CCTV condition discovery/refresh 경로와 draw receipt 재생성이 별도로 있다. [추천] 후속 구현은 restore가 새 discover/observe/opportunity/read credit가 되지 않도록 검사한다. 이미 실행된 Experiment의 당시 observation IDs는 Runtime execution record에서 읽고 현재 환경으로 재판정하지 않는다. UI draw receipt는 새 View에 다시 bind하되 “새 meaningful Research” token을 부여하지 않는다.

Case/Resource binding 오류는 다른 Case로 fallback하지 않는다. preflight 후 예상치 못한 UI 복원 실패까지 원자적 rollback을 보장한다고 주장하지 않는다. [추천] context를 복원 완료까지 유지하고 다음 업무 입력/새 사건/dispatch를 막는 fail-closed 처리와 검증이 필요하다. 작은 pending-resume UI intent가 필요해도 Response completed truth를 복제하지 않는다.

## 12. Per-Stage Resume Audit

| Stage | 현재 조사 결과 | 후속 Scripted Interrupt 복귀 추천 |
|---|---|---|
| PROFILE | 정적 ProfileData 표시; Major 허용 Stage에 없음 | PROFILE context/guard 지원 추가, 같은 profile 표시/Runtime/발견 membership 유지, 재발견0. 최초 진입/복귀 구분 |
| CCTV | Runtime environment에서 조건 표시; `_cctv_review_return_stage`에 따라 Next/Back이 달라짐 | same observations/active environment 유지, Recheck의 원래 Back 목적지 보존, Resume를 새 CCTV opportunity/discovery로 세지 않음 |
| EXPERIMENT | Runtime 실행 이력/남은 횟수는 유지. 현재 restore는 history[-1]만 재표시하며 결과 scroll=0/selection=-1 | 실제 displayed_result_id(빈 값 포함), unexecuted draft selection, Experiment/Result scroll을 capture. 이력/remaining/당시 observation IDs는 owner에서 재구성. 마지막 실행과 현재 표시를 동일시하지 않음 |
| CONTAINMENT | confirmed Room/lock은 Runtime에서 복원. `_selected_room_index`는 setup/display에서 -1로 reset되어 미확정 draft 소실 | unconfirmed room_id를 UI memento로 보존/restore하되 Pending/Runtime 확정/Confirm signal0. confirmed 값이 있다면 canonical owner가 우선하고 conflict를 거절. Room scroll/focus 보존 |

근거: [containment.setup](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/scripts/views/containment_view.gd:21), [containment._on_room_selected](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/scripts/views/containment_view.gd:93), [experiment.setup](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/scripts/views/experiment_view.gd:43), [experiment.restore_recorded_result](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/scripts/views/experiment_view.gd:142), [experiment.get_displayed_result_id](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/scripts/views/experiment_view.gd:179), [main._restore_interrupted_experiment_result](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/scripts/main/main.gd:1786). Containment에 현재 draft public getter/restore API는 없다. Experiment에도 정확한 unconfirmed selection/scroll의 public memento API는 없다. 미래 API를 존재한다고 가정하지 않는다.

[추천] 새 foundation의 Stage별 수용 기준은 동일 entry/Case/Runtime/Stage + executed IDs/remaining + displayed Result/condition observation + current environment + Research membership + confirmed/pending Room + unconfirmed draft + 필요한 scroll/Back 목적지다. Final UI 픽셀 디자인/폰트/효과는 범위 밖이다. 기존 Failure Major의 draft reset을 이번 DESIGN ONLY에서 고치지 않으며, 후속 공통 helper 도입 시 Failure route의 변경 범위와 regression을 명시해야 한다.

## 13. Failure Event Arbitration

현재 Step58 bounded arbitration은 **CASE→sequential Scripted 전환 intent**에서 old Failure presentation offer를 최대1회 소비한 후 다음 업무 Next에 handoff한다. [main._on_advance_requested](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/scripts/main/main.gd:864)가 Progress.bind_transition/consume_failure_offer를 쓴다. Mid-Case 사건은 advance가 없으므로 이 intent/budget을 그대로 쓰면 사건 완료와 Case 완료를 혼동한다. 기존 oldest Failure selector/credit gate를 side event용 priority framework로 바꾸지 않는다.

[추천] 작은 결정적 규칙: **이미 활성화된 응답/notice는 끝까지, 새 checkpoint에서 Story due는 old Failure presentation보다 먼저, Resume 자체는 새 사건 checkpoint가 아님**.

| checkpoint 상황 | 추천 동작 | 금지 |
|---|---|---|
| active Incident/Archive overlay/notice 있음 | 새 Response 시작 금지. 현재 응답 ack 또는 notice Dismiss 유지. 이미 latch된 Story intent는 보존하고 다음 사용자 업무 safe checkpoint에서 실행 | nested/중단된 응답 폐기/자동 resume-chain |
| work View safe, Story due, response/notice 없음 | Scripted start. 같은 checkpoint의 old Major/Disturbance presentation은 보류 | Story를 credit=closed라 취소, old Failure 무한 drain |
| Story 없음 | 기존 Failure credit/oldest selector/Step58 sequential transition 경로 그대로 | 새로운 numeric priority/counter order |
| Scripted Result ack | same work 복원만. 다른 event는 다음 accepted 업무 입력에서 재검토 | ack callback에서 다음 Incident/Notice 자동 시작 |
| Story due이나 source content/context invalid | intent/context를 잃지 않고 명시적 오류, Case dispatch 막음. 자동으로 Case를 넘기거나 fake Failure 만들지 않음 | broken Mandatory를 없었던 사건으로 취급 |
| 같은 checkpoint에 두 Story authored | 초기 schedule validation 실패 | array 순서/numeric priority로 숨긴 중첩 정책 |

Story occurrence가 checkpoint에 latch되면 완료 전에는 해당 업무의 stage advance/Case handoff를 막는다. 기존 Response가 이미 active였다면 그것을 한 번 마치고 next user checkpoint에서 Story를 먼저 시작하므로 active old Failure queue의 반복에 굶지 않는다. 진행이 계속되는 동안 유한 delay이며 idle에 timer로 강제하지 않는다. Story 뒤의 old Failure는 그대로 남고 이후 기존 조건으로 다시 선택된다. 무한 drain loop/queue framework 없음.

**업무 accounting과 event presentation을 구분한다.** accepted Experiment 실행/Containment 진입 등의 기존 opportunity accounting은 기존처럼 정확히1회 기록한다. 같은 Action에서 Story가 due이면 old-event *presentation*만 보류한다. 현재 [main._try_process_failure_event_opportunity](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/scripts/main/main.gd:1411)는 일부 Stage에서 counter advance와 presentation이 묶여 있으므로 후속 최소 hook/분리가 필요하다. Story check를 기존 함수 뒤에 붙이면 이미 notice/major가 표시될 수 있고, 앞에 early-return하면 정상 accounting을 누락할 수 있다. 기존 RNG/threshold/Counter/processed-key 의미를 바꾸지 않는 검증이 필요하다.

[추천] Scripted start/response/Archive/Resume 자체는 Failure counter/opportunity/RNG/Presentation credit를 요구·부여·소모하지 않는다. 기존 accepted 업무 read action이 부여한 token/credit는 그 Action의 정상 결과로서 그대로 보존한다. Story 때문에 별도의 token/credit를 만들거나 current flow의 credit=OPEN이 될 때까지 Mandatory를 무한 지연시키지 않는다. 이 정책은 future side schedule이 있는 checkpoint에만 적용하며 Sequential Step58 정책을 재작성하지 않는다.

## 14. Source Archive

[추천] Scripted Mid-Case의 기본 Source Archive는 **전체 Research Archive List**다. 사건의 source는 Event definition/side occurrence이고 interrupted Case는 업무 위치이므로 SOURCE CASE detail로 강제 연결하지 않는다. current Case의 Research Log를 열거나 Current discoveries를 Archive로 merge하지 않는다. empty Archive도 empty List로 표시할 수 있다.

기존 Sequential List→Detail→List→response 복귀 경로와 Broadcast draft capture/restore를 공통화할 수 있다. 그러나 현재 `_is_scripted_response`/`_bound_scripted_entry`는 순차형 전용이며 [main._on_archive_list_back_requested](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/scripts/main/main.gd:448), [main._on_archive_detail_back_requested](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/scripts/main/main.gd:464), [main._on_source_archive_requested](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/scripts/main/main.gd:1768), [main._restore_response_broadcast_draft](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/scripts/main/main.gd:1620)의 binding은 새 origin/policy에 맞춰 검증해야 한다.

- response origin/occurrence/definition/incident/broadcast/phase가 동일해야 Back 복귀를 수락한다.
- draft option_id는 View UI memento이며 State confirmed_option_id가 아니다. Archive 왕복에서 signal 없이 복원, Confirm 이후 canonical State가 우선하고 lock 유지.
- response_archive_return_stage는 Incident/Broadcast/Result 복귀용, interrupted_work_stage는 Case 복귀용이다. 한 필드로 덮어쓰지 않는다.
- response draft와 Case work draft는 별도의 값이다. Archive Back이 Case Room 선택을 승인하거나 Case work를 먼저 복귀시키면 안 된다.

[추천·선택적 후속] 실제 content가 과거 Case를 명시적으로 대상으로 할 때만 archive_focus_entry_id 같은 authored context를 검토한다. lookup은 실제 Campaign CASE entry→Case definition→기존 archived/discovered 여부다. interrupt source identity를 해당 Case로 바꾸지 않는다. 이미 접근 가능한 past Case만 detail로 이동하고, unavailable/미발견/current Case이면 List로 복귀하며 자동 unlock/merge0. 초기에 필요가 없으면 필드/API도 추가하지 않는다. [미정] 대상 과거 Case와 사건의 관련성.

## 15. Stale Callback / Duplicate Guard

현재 [main._is_active_view](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/scripts/main/main.gd:860)는 current View 일치/inside-tree/not-queued/notice 없음/closure-busy 아님을 검사한다. `_accept_view_action()`는 terminal permission와 현재 Campaign entry metadata를 대조한다. Response try_begin/confirm/complete는 one-active/once 규칙이다. 이는 재사용할 수 있지만 side 사건 동안 entry ID가 변하지 않아 **entry metadata만으로 모든 응답 source를 구분할 수 없다**.

[추천] 응답 callback은 active View identity + expected Stage + full source occurrence/definition/incident/broadcast binding + actual approved Result를 검사한다. Main callback은 현재 entry/Case/Runtime/context/policy도 대조한다. stale old Case/Response/Archive View는 새 work View와 다르므로 무시한다. queued-delete 전 retained callback, 같은 entry에서 연속 다른 side source, Archive draft foreign source, old Result ack를 필수 검증한다.

동시 Interrupt guard: terminal NONE, closure/cleanup busy0, no active response, no disturbance notice, work View valid/visible, existing interrupt context 없음, valid current CASE/Runtime, allowed Stage, due source validated, no duplicate/completed occurrence. confirm/resume 중에는 synchronous busy/context guard로 재진입을 막고 State mutation 중 await/event emission을 두지 않는 것을 우선한다. deferred draw checkpoint를 쓰면 await 이후 current View/entry/Runtime/source를 **다시** 검증한다. 단순 boolean "Story active"를 두 번째 authority로 만들지 않는다.

start 전에 capture/definition validation 완료, try_begin 성공 시 context/route를 bind한다. start가 실패하면 기존 Case/Runtime/View/owners를 보존한다. complete 전 resume preflight 실패 시 ACTIVE 유지. 이미 COMPLETED인 occurrence는 같은 Case/Stage 재진입/Recheck/Archive Back/Result double click로 재시작되지 않는다.

## 16. Cleanup / Terminal Boundary

[확정] ACTIVE Scripted terminal block 유지. completed Scripted terminal projection gap 미해결 유지. developer terminal schema/RunDispositionRecord/Builder 확장0, player Ending0.

| 상태 | 현재/후속 경계 추천 |
|---|---|
| Sequential ACTIVE 및 Archive overlay | 현재 UNSUPPORTED_ACTIVE_CAMPAIGN_RESPONSE, source/recipient/terminal mode mutation0 유지 |
| Future Mid-Case ACTIVE 및 그 Archive overlay | [추천] 같은 explicit unsupported early block, current Case가 살아 있다는 이유로 Case-only active termination을 허용하지 않음 |
| Future due-not-started / resume pending | [추천] Case-only terminal preparation unsupported/INVALID_PRECONDITION으로 명시 거절; 대기 중 Mandatory를 버리고 closure하는 완료 계약 없음 |
| 정상 completed side + 업무 복귀 완료 | [추천] 기존 Case-only closure의 범위만 유지. completed Scripted fact가 recipient에서 빠지는 gap은 여전히 OPEN, 지원 완료 주장 금지 |
| COMMITTED_FROZEN / TERMINAL_ERROR_FROZEN / CLEANED_NO_RUN | 새 trigger/start/restore/resume mutation 금지. cleanup 또는 종료 경로만 기존 계약대로 |
| verified cleanup preflight reject | query source live/context 유지; source release0 |
| verified cleanup 실제 시작 / partial reset 실패 | Step60 release-before-reset, SOURCE_RELEASED 유지. transient side intent/work/response/archive context도 clear하고 stale callback 차단 |
| Main tree lifetime 종료 | Step60 exit-tree release 유지, 새 side runtime/context 참조도 해제 |

현재 [main.developer_commit_run_disposition](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/scripts/main/main.gd:1068)는 `_is_scripted_response()`에서 active를 early block한다. future route를 추가하면서 helper를 sequential-only로 남겨두면 side active는 이 guard를 빠져나간다. [main.build_test_sequence_disposition_snapshot](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/scripts/main/main.gd:957)는 scripted flag에서 unsupported를 설정해도 아래 `current_valid` branch가 boundary status를 다시 쓰는 구조다. Sequential은 current Case=null이라 문제가 드러나지 않는다. Case가 살아 있는 side는 **origin-aware unsupported 처리를 우선 확정/early return**해야 한다. 이것은 후속 통합의 P1 위험이며 현재 제품의 side 지원이 존재한다는 뜻이 아니다.

`_developer_source_facts()`와 `_case_response_records()`는 여전히 Case-only다. [main._cleanup_verified_source](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/scripts/main/main.gd:1101)는 실제 verified commit 뒤만 source를 지운다. ACTIVE side를 강제로 CASE route로 disguise하거나 fake source_case_id를 넣어 기존 builder를 통과시키면 안 된다. 새 schema recipient projection은 별도 단계다. Step53 prepared-pending/Step54 multi-owner atomic rollback 한계도 그대로다.

## 17. Save Identity Constraints

[확정] Save/Load 구현0. future 저장 계약을 정할 때 필요한 identity만 열거한다.

| future 필요 정보 | 최소 의미 |
|---|---|
| campaign_id + current_case_entry_id | 어느 Campaign CASE cursor/업무인지 |
| origin + interrupt_id + event_id + incident_id | active side occurrence/definition/link |
| interrupted_entry_id/case_id/stage_id + CCTV review return | 정확한 업무 목적지 |
| actual Response phase + broadcast/confirmed option/approved result IDs | canonical approval와 completion |
| unconfirmed response option 및 work selection/result/scroll | canonical fact와 분리된 transient UI |
| pending checkpoint intent가 있다면 occurrence/checkpoint | 이미 도달했지만 아직 표시하지 못한 업무 경계 |
| same-Case canonical Runtime facts/현재 환경/Research | 현재 기존 owners를 일관되게 복원할 후속 계약 |

engine instance IDs/NodePath object/Resource pointer/Callable/Signal은 persistence identity로 저장하지 않는다. 현재 runtime_instance_id는 live Resume 증명일 뿐 Save 후 재사용할 수 없다. event_id만 저장하면 같은 정의의 sequential/side/반복 occurrence를 구분하지 못한다. current entry ID 하나만 저장하면 side 응답을 해석하지 못한다. completed side membership은 Response에서 유도하는 범위를 유지하고 별도의 Save history truth를 미리 만들지 않는다. data version/migration/정확한 Save schema는 [미정·미구현]이다.

## 18. UI Contract

[추천] 기존 Incident/Broadcast/IncidentResult 및 Archive List/Detail Scenes를 재사용한다. 새 response Scene/Story UI/최종 디자인/애니메이션/효과/폰트0. Main이 validated content/context/action을 주입하고 View는 signal로 요청한다.

| 실행 방식 | source/context 표시 | Result 마지막 action | 업무/cursor |
|---|---|---|---|
| Sequential Scripted | Campaign Event definition + entry occurrence | CONTINUE / 기존 Continue Campaign | Scripted entry complete→next dispatch |
| Mid-Case Scripted | Campaign Event definition + interrupt occurrence + interrupted Case/업무 Stage | RESUME WORK | 같은 CASE/Runtime/Stage; cursor 그대로 |
| Failure Major | 실제 source Failure Case + interrupted Case/Stage | 기존 Resume action | actual Candidate 처리 후 업무 복귀 |

현재 [flow._display_response_context](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/scripts/views/flow_view.gd:46)는 CAMPAIGN_ENTRY를 Continue로 표시하고 나머지는 Case source 필드를 요구한다. 새 side origin/return-policy 표시 branch가 필요하다. 같은 content definition 사용 여부와 return action은 별개다. event를 MAJOR CONTAINMENT INCIDENT 또는 SOURCE CASE라고 잘못 표시하지 않는다. Context/Last action 외 UI의 역할을 유지한다. 실제 사건 설명/Broadcast/Result 문구는 [미정]이고 이 문서에서 창작하지 않는다.

[추천] 최종 Action은 route-derived return policy를 사용한다. 지금 string `ADVANCE_CAMPAIGN_ENTRY`가 있으므로 sequential 의미를 유지하고 resume policy를 추가할 수 있다. mode/return_policy를 content Resource에 자유 조합으로 expose하지 않아 잘못된 advance/resume 조합을 만들지 않는다.

## 19. Recommended Implementation Scope

[추천] 다음 foundation은 content와 분리해 최소 동작/identity/resume를 검증하는 것이 적합하다. 이번 문서가 제품 변경을 수행했다는 뜻은 아니다.

| 구현 후보 | 최소 책임 | 유지/제외 |
|---|---|---|
| Campaign side occurrence data + lookup/validation | interrupt_id/target CASE/checkpoint/기존 Scripted bundle | sequence entry kinds/sole cursor 유지; fake Case0 |
| source-aware identity extension | new origin/occurrence semantic 및 compatibility migration | CASE/SEQ keys 의미 유지, global registry0 |
| Main checkpoint routing | deterministic due intent/arbitration/start/return branch | Query/Condition framework/Manager/새 GameState0 |
| 작은 업무 transient capture/restore | Profile/CCTV/Experiment/Containment 정확한 업무복귀 | draft 승인0/새 Runtime0/history copy0 |
| response/Archive binding 공통화 | existing UI/Option lock/source draft roundtrip | 새로운 View Scene0 |
| query source resolver 확장 필요 시 | side occurrence Response readonly 조회 | existing entry completion API 유지; Research non-Case UNSUPPORTED |
| terminal guard/Snapshot 차단 | future active side fail-closed | terminal recipient schema/projection gap 해결0 |

Main은 이미2253행/123함수다. generic framework를 더하는 대신 현재 data/runtime/read_models/View 책임을 유지하며 content lookup와 primitive UI restore 책임을 적절한 작은 helper에 두는 것을 추천한다. anticipated 모든 미래 시스템을 미리 구현하지 않는다.

후속 acceptance matrix(이번 단계 실행0):

1. 기존 CASE→sequential→CASE/같은 Event 반복/CASE02 완료→MI01→CASE03 형태는 유지한다. 실제 content 미준비 시 existing TEST bundle의 in-memory fixture로 검증하고 product3CASE authored data는 임의 변경하지 않는다.
2. PROFILE/CCTV(EXP/Containment Recheck 포함)/EXPERIMENT(no execution/result shown/new draft)/CONTAINMENT(unconfirmed+confirmed) 각각 same entry/Case/Runtime/Stage 및 업무 memento 확인.
3. Scripted start→Confirm→Result→Resume 동안 Pending/Resolution/Candidate/Research/Runtime 실행/환경/RNG/기존 credit/token/opportunity를 after-accepted-work baseline과 비교; 변경은 Response 승인/완료와 UI context뿐.
4. 실제 Result read checkpoint에서 정보가 그려진 뒤 사건, Stage/Action relocation, duplicate checkpoint/Case revisit/repeated definition/cross-origin ID collision 확인.
5. Story due + old Major/Disturbance, already active Response/notice, closed credit, bounded continuation, no automatic resume drain, accepted work accounting once 확인.
6. Source Archive empty/list/detail, response draft 복원/confirmed lock, Case draft 불변, stale queued View/foreign source/old ack/double Confirm/resume 검증.
7. active side terminal early unsupported, pending/resume boundary, Snapshot fail-closed, completed terminal gap 유지, cleanup query lifetime 및 Main free/retry 확인.
8. 제품 변경 단계에서 fresh Godot4.7.1 import/check-only/Main headless/native/핵심 Step46~60 regression 실행. 현재 문서의 static audit를 새 gameplay 통과 수치로 부르지 않음.

실제 Story condition evaluator, Mandatory02/03 콘텐츠, StoryFlag/Ending/Save/terminal schema/경제/할당량/정산은 범위 밖이다. occurrence/checkpoint/transient memento는 실행 위치/업무 UI이며 historical truth/Story progression State의 복사본이 아니다.

## 20. Open Story Decisions

| 결정 | 수준 | 현재 결론 |
|---|---|---|
| MI01 위치/방식 | [확정] | CASE02 완료→Sequential→CASE03 |
| 후속1~2개 방식 | [확정] | CASE 중단→Scripted Response→same Case 업무복귀 |
| fake Failure/Case/Candidate/Resolution 없음 | [확정] | 별도의 authored Story occurrence |
| 실제 MI01/02/03 사건 내용/문구/선택/Result | [미정] | 자료 없이 창작/제품 작성0 |
| MI02/03 target CASE/Stage/Action | [미정] | 예시 CASE04 등을 실제 content로 확정하지 않음 |
| default trigger 메커니즘 | [추천] | deterministic A/B, B 우선; Random/Timer 제외 |
| content와 execution placement 분리 | [추천] | 기존 ScriptedIncidentData 공유 + B side schedule |
| occurrence/origin | [추천] | interrupt_id + CAMPAIGN_INTERRUPT + occurrence semantic |
| unconfirmed Room/Experiment draft | [추천] | 작은 transient UI memento로 보존, canonical fact와 분리 |
| event collision 규칙 | [추천] | active 유지/동일 checkpoint Story 먼저/no resume chain |
| 과거 fact로 문구/정보 variation | [추천] | query input 후보, Mandatory 발생 취소는 기본 아님 |
| optional targeted Archive | [미정] | 실제 content 필요하면 검토, 초기에는 List만 |
| completed Scripted terminal projection | [미정·OPEN] | 이번 단계 및 foundation 설계에서 해결하지 않음 |
| exact Save contract | [미정·미구현] | stable IDs 제약만 기록 |

추천을 사용자 확정으로 승격하지 않는다. 후속 구현 범위와 실제 Story 자료가 제공되면 위치/메커니즘/단계 범위를 검토한다.

## 21. P0-P3

| 심각도/종류 | 내용 | 근거/후속 요구 |
|---|---|---|
| P0 신규 제품 결함 | 이번 DESIGN ONLY 조사에서 발견0 | 제품 변경/실행0, 과도한 동적 검증 주장0 |
| P1 future integration risk | side를 CASE/SEQUENTIAL origin/cursor로 위장하면 progression/source 손상 | 독립 origin/side occurrence/Case cursor 불변이 구현 전제 |
| P1 future integration risk | current Case가 살아 있는 active side가 terminal/Snapshot guard를 우회 | early unsupported+current_valid overwrite 방지; 현재 side 구현0 |
| P2 현재 재사용 한계 | PROFILE interrupt unsupported; Room draft 소실; Experiment last history 복원이 exact display가 아님 | per-Stage memento/복귀 검증 필요; 기존 제품 코드를 이 단계에서 수정0 |
| P2 현재 경계 | completed Scripted final recipient 누락, Step53 ACTIVE_FORCE_REQUIRES_PREPARED_PENDING, Step54 atomic rollback 미보장 | 기존 OPEN 유지, query/design으로 해결 주장0 |
| P2 future integration risk | accounting/presentation 결합·read frame/duplicate checkpoint를 잘못 처리하면 starvation/중첩/정보 소실 | after-accepted-work snapshot, deterministic rule, no auto drain |
| P3 현재 결합 | Main 크기/route 분기, source_entry_id naming, Hypothesis private enumeration seam | 최소 helper/읽기 alias; 범용 framework/무관 refactor0 |

[추천] 아직 Mid-Case path가 없어 future risk를 현재 재현된 새 gameplay bug라고 표시하지 않는다. 정확한 업무 복귀와 origin/terminal 차단은 foundation 구현 완료의 필수 조건이며 나중에 콘텐츠로 가릴 문제가 아니다.

## 22. Next Step

[추천] **Scripted Mid-Case Interrupt foundation**을 후속 후보로 제안한다. B side schedule, stable occurrence/origin, A/B deterministic checkpoint, 작은 UI memento, same Runtime resume, old Failure arbitration, explicit unsupported terminal/Snapshot, 기존 response UI 재사용을 최소 범위로 검증한다. 실제 target/콘텐츠가 아직 미정이면 제품에 가상 CASE04/새 사건 문구를 넣지 않고 in-memory TEST fixture로 구조만 확인한다. 실제 MI01 콘텐츠 구현은 기존 sequential 계약으로 별도 범위를 정할 수 있다.

이 단계의 결론: Campaign에는 순차형 Scripted와 Mid-Case Scripted Interrupt가 **서로 다른 progression semantics로 정의**되어 있다. 두 방식의 설계는 Failure/Candidate를 위조하지 않고 기존 response UI를 공유한다. 실제 Mid-Case 실행/후속 Mandatory content/Save/Ending/StoryFlag/Scripted terminal gap 해결은 아직 구현됐다고 말할 수 없다.

검증·변경 범위: 제품120개/기존 문서/UID bytes를 보존하고 README만 prefix 보존 후 append, 이 문서1개 생성. Godot 실행0/새 gameplay assertions0. 최종 Git 상태/HEAD/upstream/staged/diff-check와 기존 verification hash audit는 `.godot/verification/step61/final-audit.json`에 기록한다. commit/stage/push0.

## 핵심 질문 20개에 대한 직접 답변

1. **같은 ScriptedIncidentData 사용?** [추천] content definition은 공유 가능. 실행 위치와 return policy는 carrier/route에서 결정한다.
2. **SEQUENTIAL/INTERRUPT mode 구분?** [추천] 행동 의미는 분리한다. 공유 content에 mutable mode 필드는 중복 저장하지 않는다.
3. **stable Mid-Case occurrence?** [추천] Campaign-scoped interrupt_id, origin CAMPAIGN_INTERRUPT, bundle event_id/incident_id 별도.
4. **CampaignEntry.entry_id 그대로 사용?** [추천] 아니오. interrupt는 sequence entry가 아니다. target CASE entry ID는 복귀/binding용.
5. **새 ID 필요?** [추천] interrupt_id 하나. event_occurrence_id를 추가로 만들지 않는다.
6. **일반 sequence entry로 배치?** [추천] 아니오. sequential advancement semantics와 섞이지 않는 side schedule.
7. **cursor 이동 없는 side event가 안전?** [추천] 예. current CASE ownership/Runtime을 유지한다.
8. **sole cursor 보호?** [확정/추천] Case complete/advance0, existing transition untouched, side completion은 Response authority.
9. **Failure context 재사용?** [추천] common binding/Stage/archive/resume는 재사용 가능하지만 exact draft/result와 PROFILE 지원은 추가 필요.
10. **공통/Failure-only?** [추천] UI/source/Runtime/once는 공통, Resolution/Candidate/threshold/credit gating/remove/research merge는 Failure 전용.
11. **현재 origin 충분?** [추천] 부족. side occurrence namespace 추가 필요.
12. **source_entry_id 의미 강함?** 현재 실제 sequence entry 의미. [추천] source_occurrence_id canonical semantic으로 일반화.
13. **source 일반화?** [추천] origin별 CASE/SEQ entry 또는 side interrupt ID, definition ID 별도. legacy alias는 derived read만.
14. **Response key migration?** [추천] field/source resolver migration 필요. 기존 CASE/SEQ origin+ID 값 유지 시 serialized key bytes 보존 가능.
15. **Source Archive?** [추천] List 기본, 실제 콘텐츠가 요구할 때만 past archived Case optional context.
16. **Archive 뒤 draft 유지?** [추천] response identity와 phase 검사 후 View-only option ID 복원, State confirm0; Case work memento도 별도 유지.
17. **Result 뒤 advance 없는 복귀?** [확정/추천] actual Response complete + same entry/Case/Runtime/Stage 검증/restore, dispatch0.
18. **두 Resume 구분?** [추천] origin/route에서 구분. Failure는 Candidate 완료 제거, Scripted는 그 호출0; return UI 정책은 공통.
19. **stale callback 방지?** [추천] current View/queued guard+entry+full response binding+same Runtime+once guard. 새 View recreate 유지.
20. **동시2개 방지?** [추천] ACTIVE1/notice/terminal/context/busy guard, duplicate completed occurrence reject, deterministic single-checkpoint validation.
