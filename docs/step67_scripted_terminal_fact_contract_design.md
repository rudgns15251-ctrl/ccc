# Step67 — Completed Scripted Incident Historical Fact Contract Design

> 개발 이력: 이 문서는 해당 단계 작성 당시의 설계·구현·검증 기록입니다. 현재 구조는 [코드 구조 안내](architecture.md)를 참고하세요. `.godot/verification/` 자료는 Git에 포함되지 않는 로컬 자료이며, 공개 검사 방법은 [검증 안내](verification.md)에 있습니다.

**DESIGN / SOURCE AUDIT ONLY.** 2026-10-11. “현재”는 최신 소스에서 확인한 동작이며 “Step68 제안”은 아직 미구현이다. 제품 GDScript/Scene/Resource/Theme 변경 0, Godot 실행·새 테스트 0. 게임은 단일 Story Campaign이다. 기존 Run 명칭은 개발자 종료 기록의 내부 세션 식별자이며 경제·할당량·정산·상점·로그라이트를 의미하지 않는다.

## 1. Repository Baseline

| 항목 | 작업 시작 상태 |
|---|---|
| HEAD | `19be4ea998d6479f5c46c3527d540ff4a16f2322` |
| branch / upstream | `master` / `origin/main` |
| staged | 0 |
| modified | 6: README, Theme, Main, GameShell, ExperimentView, ResearchLogView |
| untracked | 2: Step66 보고서, Step66.1 보고서 |
| 조사·hash 기준 파일 | Git/.godot 제외 실제 파일 165개 |
| 제품 구성 | GDScript 53개, Scene 17개, Resource .tres 6개 |

실제 project.godot는 Main=`res://scenes/main/main.tscn`, 1920×1080 viewport, 1280×720 기본 창, canvas_items, GL Compatibility다. Autoload 섹션은 없다. Main/Shell/View/runtime/data/read_models/resources를 실제 파일 목록에서 확인했다. 기존 Step66/66.1 변경을 HEAD로 되돌리지 않는다.

`resources/campaigns/test_campaign_01.tres`의 순서는 `TEST_ENTRY_CASE_01 → TEST_ENTRY_CASE_02 → TEMP_ENTRY_MANDATORY_01 → TEST_ENTRY_CASE_03`이다. 이 Resource에는 Side occurrence가 지정되지 않았고 CampaignData.scripted_interrupts의 소스 기본값은 빈 배열이다. 현재 TEMP Mandatory01은 Sequential이다. Side foundation을 authored 제품 Side 사건이 이미 존재한다는 뜻으로 설명하지 않는다.

이번 실제 변경은 보고서 생성 1개와 README 보고서 링크 append 1개뿐이다. 기존 modified 6개는 그대로이며 untracked 보고서는 3개가 된다. baseline/함수 인덱스/최종 hash·Git 자료는 ignored `.godot/verification/step67/`에 보관한다. 기존 검증 자료는 수정하지 않는다.

## 2. Current Owner Inventory

| 정보 | 현재 원본 / 실제 API | 수명·주의 |
|---|---|---|
| Campaign ID, Entry ID·kind·순서 | `scripts/data/campaign_data.gd`, `campaign_entry_data.gd`; get_entry | authored 정의. 발생/완료 증거 자체가 아님 |
| 현재 Entry / 완료 Entry IDs | `scripts/runtime/campaign_progress_state.gd:27,35,61`; get_current_entry_id, get_completed_entry_ids, try_complete_and_advance | 순서 완료 authority. reset에서 clear |
| Sequential occurrence | CampaignEntryData.entry_id; Main _dispatch_campaign_entry (`scripts/main/main.gd:2341`) | Entry 변경 후에도 response record에 ID가 남음 |
| Side occurrence / target | `scripts/data/scripted_interrupt_occurrence_data.gd`; interrupt_id, target_entry_id, get_source:39 | Case cursor와 별개. target CASE는 host이지 사건 source Case가 아님 |
| Scripted definition | `scripts/data/scripted_incident_data.gd`; event_id | source_definition_id로 저장. Resource path/instance ID로 식별하지 않음 |
| Incident/Broadcast/Option/Result 정의 | ScriptedIncidentData의 IncidentData, broadcasts/options/results; get_validation_error:11 | definition별 승인 링크. 완료 status 없음 |
| 발생·확정 선택·승인 Result·Response 완료 | `scripts/runtime/incident_response_state.gd:39,48,56`; try_begin/try_confirm/try_complete | 세 source 공통 canonical owner. get_responses:33은 detached copy |
| Source identity | `scripts/runtime/incident_source.gd:4,25,29,34`; OriginKind, to_dictionary, matches, from_record | origin/occurrence/definition을 함께 검사. legacy alias는 derived |
| Case Failure 판정 | `scripts/runtime/containment_resolution_state.gd`; try_record_resolution | case_id→Room/SUCCESS·FAILURE/Incident. Scripted를 여기에 기록하지 않음 |
| Failure 대기·기회·escalation | `scripts/runtime/failure_event_candidate_state.gd`; try_add_candidate, remove_completed_candidate | source Case definition별 candidate. 완료 후 candidate만 제거 |
| Side exact-resume | Main _interrupt_context, _side_restore_pending, _side_resume_error; _resume_side_work:2462, _restore_side_work:2479 | primitive work state + live Runtime/Case identity. 완료와 복귀는 별개 |
| Live fact read model | `scripts/read_models/campaign_fact_queries.gd` | owner를 조회. 별도 history/cache/StoryFlag authority 아님 |
| Developer 관찰 snapshot | `scripts/read_models/test_sequence_disposition_snapshot.gd` | 읽기 전용 복사. 완료/commit/cleanup authority 아님 |
| Final record / recipient | `scripts/runtime/run_disposition_record.gd`, `run_disposition_state.gd` | 독립 in-memory recipient. public getters는 deep copy |
| Terminal orchestration | Main developer_commit_run_disposition:1149, developer_cleanup_committed_run:1177 | 개발자 명시적 API. 플레이어 Ending/Save 아님 |

| 요청된 단계 이름 | 실제 상태 / 정보 수명 |
|---|---|
| NOT STARTED | Response record 없음. authored Entry/Side/definition만 존재. Query의 NOT_STARTED는 projection 문자열 |
| ACTIVE | IncidentResponseState.Status.ACTIVE; source/incident/broadcast 존재, option/result는 빈 문자열 |
| CONFIRMED | 별도 Status enum 아님. 여전히 ACTIVE, confirmed_option_id·incident_result_id 저장. Query phase ACTIVE_CONFIRMED |
| RESULT DISPLAYED | Main Stage.INCIDENT_RESULT 및 IncidentResultView._incident_result_data가 UI evidence. 여전히 ACTIVE. Response record에 result_displayed 없음 |
| COMPLETED | Status.COMPLETED; active key만 clear, _responses의 record 유지. Sequential progress 완료와 Side 복귀는 별도 |
| CLEANED | Response enum이 아닌 Main TerminalMode.CLEANED_NO_RUN. States는 같은 객체에서 reset, history clear. 정의가 남아도 실행 사실은 복구 못 함 |

## 3. Existing Terminal Pipeline

현재 순서는 다음과 같다. 요청에 적힌 Cleanup→Source Release와 다르게 **commit 검증 후 cleanup 내부에서 query source release를 먼저 한다.**

1. Main configure_developer_run_identity (`main.gd:1128`): run_instance_id, 실제 Case의 외부 assignment IDs, sequence·State identity를 한 번 bind.
2. developer_commit_run_disposition (`1149`): Side boundary/ACTIVE Sequential/CLEANED/busy guard.
3. _prepare_and_commit_developer_disposition (`1284`): recipient/context/boundary 확인. 기존 receipt가 있으면 source 재projection equality로 ALREADY_COMMITTED 처리. Pending mutation/RNG보다 앞선다.
4. _developer_source_valid (`1353`): 마지막 실제 Case·Runtime·확정 Room·Pending 또는 Resolution·View identity 확인. _begin_developer_terminal_intent로 freeze.
5. _developer_source_facts (`1379`)·_developer_active_response_facts (`1437`) capture, Builder source_issue로 preflight. voluntary active CASE이면 WAITING_ACTIVE_RESPONSE. eligible Pending만 기존 hidden resolution preparation.
6. **prepared source facts 재capture** → DeveloperRunDispositionBuilder.build (`developer_run_disposition_builder.gd:86`) → RunDispositionRecord.new → source identity/content 재검사 (`main.gd:1337–1344`).
7. RunDispositionState.try_commit (`run_disposition_state.gd:14`) → record+receipt 하나의 publication → Main acknowledgement equality 확인 → COMMITTED_FROZEN.
8. 별도 developer_cleanup_committed_run → _cleanup_verified_source (`1187`): recipient/receipt/boundary/categories/State/sequence/ViewHost preflight.
9. _dispose_auxiliary_ui → CampaignFactQueries.release_sources (`main.gd:1220–1221`) → Views/context 정리 → Response 포함 States reset (`1246–1255`) → emptiness 확인 → CLEANED_NO_RUN.

**Snapshot 구분:** Main.build_test_sequence_disposition_snapshot (`1032`)의 TestSequenceDispositionSnapshot 객체는 commit pipeline의 자동 입력이 아니다. terminal의 capture/snapshot은 prepared _developer_source_facts Dictionary와 이후 Record다. Builder가 Snapshot의 Pending/Candidate classifier를 재사용한다고 관찰 snapshot 전체를 commit하는 것은 아니다.

실제 terminal boundary는 VOLUNTARY_RUN_END/FORCED_RUN_END, 관찰 boundary는 TEST_SEQUENCE_END. Campaign-wide 자동 종료/Story Ending API를 만들거나 있다고 가정하지 않는다.

## 4. Completed Scripted Gap Root Cause

원인은 원본 삭제가 아니라 **Case-only 수집 → Case-only projection → Case-only recipient schema**이다.

| 질문 | 실제 소스 답변 |
|---|---|
| 1. 원본 Owner? | IncidentResponseState._responses. try_complete:56은 status와 active key만 변경하고 history를 erase하지 않는다. get_responses:33으로 source/선택/result 조회 가능 |
| 2. terminal capture 시 읽을 수 있는가? | 정상 Sequential handoff/Side exact resume 후 같은 State가 남는다. Main._dispatch_campaign_entry는 Runtime을 교체하지만 Response State를 reset하지 않는다. capture는 cleanup 전 |
| 3. 제외 함수? | _case_response_records (`main.gd:2334–2338`)가 origin CASE만 수집. _developer_source_facts:1380 및 관찰 snapshot:1058이 호출 |
| 추가 projection guard | TestSequenceDispositionSnapshot.build (`test_sequence_disposition_snapshot.gd:29`)도 non-CASE를 continue. Builder.source_issue:42는 raw non-CASE 입력을 UNSUPPORTED_CAMPAIGN_RESPONSE_HISTORY로 reject하며 후속 Case mapping/Failure evidence도 Case 전용 |
| recipient 제약 | RunDispositionState._entry_issue:104가 모든 entry에 source_case_definition_id/source_case_instance_id 요구. historical domain은 RESOLUTION 또는 EVENT/COMPLETED_RESPONSE_FACT. _validation_issue:63도 Case assignment key 전제 |
| 4. cleanup 전에 소멸? | 정상 경로에서 아니다. Sequential context clear/dispatch, Side context clear/복귀는 completed record를 삭제하지 않는다. 실제 clear는 verified cleanup의 incident_responses.reset (`main.gd:1249`) |
| 5. 두 Scripted 유형의 원인이 같은가? | 완료 후 안전 경계에서는 동일 filter/schema 누락. Side에는 resume pending/due/context라는 별도 blocker도 존재. completion/host identity가 같다는 뜻은 아님 |
| 6. Case Failure와 공유하는 구조? | IncidentResponseState/IncidentSource와 Incident/Broadcast/Option/Result 타입, primitive Record/recipient transport 공유. Failure Resolution/Candidate/Case assignment는 공유하지 않음 |

현재 Main이 먼저 non-CASE를 제거하므로 completed Scripted가 있어도 legacy Case record가 commit되면서 정보가 **조용히 누락될 수 있다**. unsupported guard만 삭제하거나 Case helper를 전체 getter로 바꾸면 unmapped source/Failure evidence/schema 오류를 만든다. filter와 recipient 둘 다 source별로 확장해야 한다.

현재 snapshot의 completed_responses에도 Case만 있다. 누락을 사건 미발생/미확정/미완료로 해석하면 안 된다. 이번 Step에서는 OPEN을 해결하지 않는다.

## 5. Sequential Source Contract

현재 Main._dispatch_campaign_entry (`2341`)는 IncidentSource(CAMPAIGN_ENTRY, entry.entry_id, data.event_id)로 try_begin한다. _bound_scripted_entry (`2312`)는 현재 Scripted Entry, current_case/runtime null, definition validation, response/context agreement를 확인한다.

- occurrence = **CampaignEntryData.entry_id**.
- definition = **ScriptedIncidentData.event_id** = record.source_definition_id.
- incident/broadcast/option/result는 해당 payload scope의 실제 링크.
- 동일 definition Resource를 Entry A/B에서 재사용하면 별도 entry IDs로 사건을 구분한다. CampaignData.get_validation_error:12는 unique Entry ID를 요구하며 Scripted definition 재사용은 금지하지 않는다.
- 역사 lookup은 완료 후 current Entry가 아니라 **record의 occurrence ID로 CampaignData.get_entry**를 사용해야 한다.
- Step68는 COMPLETED record와 Progress completed Entry IDs의 agreement를 검증한다. record만 COMPLETED인 잘못된 source를 자동 완료/수선하지 않는다.

실제 TEMP IDs: occurrence TEMP_ENTRY_MANDATORY_01, definition TEMP_EVENT_MANDATORY_01, incident TEMP_INCIDENT_MANDATORY_01, broadcast TEMP_BROADCAST_MANDATORY_01 (`resources/campaigns/test_campaign_01.tres`, `resources/incidents/temp_mandatory_incident_01.tres`). A/B/C/D 중 실제 확정 option/result만 기록한다. 문서 예시는 이번 Step의 실행 증거가 아니다.

## 6. Mid-Case Source Contract

ScriptedInterruptOccurrenceData.get_source:39는 IncidentSource(CAMPAIGN_INTERRUPT, interrupt_id, scripted_incident_data.event_id)를 반환한다. Main._try_present_side_interrupt:2422가 checkpoint intent/Runtime·Case·View identity를 검증하고 try_begin한다.

- occurrence = **interrupt_id**, Sequential Entry ID가 아님. target_entry_id는 authored host CASE binding이며 occurrence를 대체하지 않는다.
- definition = event_id. Side는 Campaign cursor/completed_entry_ids에 가짜 Entry를 만들지 않는다. source_entry_id alias도 Side record에 없으며 descriptor getter는 빈 값.
- _resume_side_work:2462는 work/CCTV parent validation 후 try_complete, resume pending을 설정한다. _restore_side_work:2479 성공은 context/pending/error를 clear하되 completed response는 유지한다.
- Step68는 CampaignData.get_interrupt(record.source_occurrence_id)로 payload를 lookup하고 definition/incident/broadcast/option/result를 검증한다. host는 existing CASE이며 current 또는 이미 completed Entry로 도달한 대상이어야 한다. **host CASE 완료는 Side 완료의 필요조건이 아니다.**
- resume pending이면 Response가 COMPLETED여도 terminal은 차단한다. 복귀 완료를 새 영구 Owner/가짜 Case completion으로 만들지 않는다.

같은 definition을 Sequential/Side 양쪽에서 써도 origin과 occurrence로 분리한다. Stage/scroll/focus/Runtime instance IDs/restore error는 최소 역사 fact 필드가 아니다.

## 7. Case Failure Separation

실제 정상 Failure 경로: Main._try_resolve_pending_without_handoff:1478 → ContainmentResolutionState.try_record_resolution → FailureEventCandidateState.try_add_candidate → Main._try_start_major_incident:1734 → _case_response_source:2299.

CASE response는 origin CASE, occurrence=**source Case의 실제 Campaign Entry ID**, definition=**source CaseData.case_id**다. interrupted 현재 Case와 과거 source Case는 다를 수 있다. candidate는 source_case_id로 관리하며 완료 시 remove_completed_candidate만 제거한다 (`main.gd:1858–1868`).

기존 terminal EVENT는 source_case_definition_id=Case definition, source_case_instance_id=`context.case_assignments[definition]`, key=`[run_instance_id, assignment, "EVENT", incident_id]` (`developer_run_disposition_builder.gd:82`, `run_disposition_state.gd:63`). **외부 Case assignment와 Campaign Entry occurrence를 같은 ID라고 가정하지 않는다.**

Step68는 Case schema/key/Failure evidence/obligation phase를 유지한다. Scripted에 Case assignment/Failure Resolution/Candidate를 발급하지 않는다. Scripted fact가 Case obligation을 만족시키거나 candidate를 삭제하는 것도 금지한다.

## 8. Completion Semantics

실제 Response status enum은 **ACTIVE / COMPLETED** (`scripts/runtime/incident_response_state.gd:4`). Confirmed/Result displayed를 이미 있는 enum으로 설명하지 않는다.

- Main._confirm_response_option:1811이 source/content 링크를 확인한 뒤 try_confirm한다. State는 option/result를 저장하지만 status는 ACTIVE다.
- Broadcast Next의 _advance_response:1830이 Result View를 표시해도 ACTIVE다.
- Sequential RESULT Next: approved Result View binding + can_complete_current → Response.try_complete → Progress.try_complete_and_advance → 다음 Entry dispatch (`main.gd:1848–1856`).
- Side RESULT Next: _resume_side_work → Response.try_complete → resume pending → exact View restore. Response 완료와 UI 복귀 완료는 분리한다.
- Case Failure RESULT Next: Response.try_complete → matching candidate 제거 → 업무 복귀. 새 Scripted projection이 이를 대신하지 않는다.

**Completion authority는 IncidentResponseState.try_complete**이며 실제 gameplay 호출 승인/Result acknowledgement는 Main이 관리한다. State API 자체는 Result View 표시 여부를 저장하거나 검사하지 않는다. 손상된 승인 링크는 status만 믿고 수락하지 말고 preflight에서 다시 검증한다.

Step68 completed-only 행은 실제 COMPLETED + nonblank linked option/result만 수락한다. Confirm만 된 행/Result 표시만 된 행/NOT_STARTED에는 완료 역사 행을 만들지 않는다. “approved Result”는 선택에 연결된 유효 Result ID이며 정답·SUCCESS·최선 선택이 아니다. TEMP B/C/D도 정상 acknowledgement를 거치면 완료 사건이다. result_displayed/읽은 시간/인간이 읽었는지는 원본 완료 record에 없어 소급 발명하지 않는다. 기존 Case builder도 result_displayed를 UNKNOWN으로 둔다 (`developer_run_disposition_builder.gd:110`).

## 9. Candidate Fact Fields

| 후보 | 실제 존재 / 필요성 | Step68 최소 결정 |
|---|---|---|
| origin_kind | Source/Response. CASE·SEQ·SIDE 분리 | 기존 int enum 1 또는 2만 Scripted 행에 유지 |
| source_occurrence_id | Response. definition 재사용 발생별 구분 | 유지: Sequential entry_id / Side interrupt_id |
| scripted_definition_id | 이 이름의 원본 필드는 없음 | 실제 **source_definition_id** 사용. 값=event_id |
| incident_id | Response + payload.incident_data | 유지. canonical Response key에도 포함 |
| broadcast_id | Response + Incident link | 유지. Option scope 식별 |
| confirmed_option_id | try_confirm가 기록 | 유지. 실제 확정 선택만 |
| result_id | 정의 Resource의 이름. Response는 incident_result_id | 실제 **incident_result_id** 유지 |
| completion_status | 이 이름의 원본 필드 없음. 원본 status는 ACTIVE/COMPLETED | 중복 필드 추가 안 함. row kind + **phase="COMPLETED"**로 Status.COMPLETED를 projection, validator가 고정값 강제 |
| Campaign ID/completed IDs/current Entry | Progress에 존재 | capture/preflight agreement용. 최소 역사 행에 전체 cursor/history 복사하지 않음 |
| target_entry_id/return_stage/resume snapshot | Side authored/live context | 검증 입력만. 가짜 source Case/Entry로 기록하지 않음 |
| UI draft/scroll/focus, RNG, trigger counter, Resource/Node refs, runtime instance ID | 일부 live owner에 존재 | Scripted 역사 행에서 제외 |
| label/body/text, timestamps, score, read receipt | 원본 최소 completed fact에 없음/불필요 | 추가하지 않음. definition 전체를 복제하지 않음 |

**제안 schema 예시 — 아직 미구현.** existing historical_facts에 아래의 discriminator 행을 포함한다. domain/kind는 신규 제안 명칭이다.

```json
{
  "identity_domain": "SCRIPTED_EVENT",
  "entry_kind": "COMPLETED_SCRIPTED_RESPONSE_FACT",
  "origin_kind": 1,
  "source_occurrence_id": "TEMP_ENTRY_MANDATORY_01",
  "source_definition_id": "TEMP_EVENT_MANDATORY_01",
  "incident_id": "TEMP_INCIDENT_MANDATORY_01",
  "phase": "COMPLETED",
  "actual_facts": {
    "broadcast_id": "TEMP_BROADCAST_MANDATORY_01",
    "confirmed_option_id": "TEMP_OPTION_MANDATORY_01_C",
    "incident_result_id": "TEMP_RESULT_MANDATORY_01_C"
  }
}
```

source_case_definition_id/source_case_instance_id/source_entry_id는 넣지 않는다. 새 역사 key는 **`[run_instance_id, "SCRIPTED_EVENT", origin_kind, source_occurrence_id, incident_id]`**다. definition은 key를 갈라 corrupted 동일 occurrence를 두 사건으로 만들지 않고 consistency 검증에 사용한다. 같은 `(origin, occurrence)`의 definition/incident/broadcast 충돌도 reject한다. duplicate는 조용히 dedupe/overwrite하지 않는다.

## 10. Candidate Designs

| 항목 | A. Recipient 직접 확장: 별도 top-level Scripted category | B. existing historical_facts에 typed Scripted projection |
|---|---|---|
| 구조 | 새 category로 six-field envelope 확장 | six-field envelope 유지, historical_facts에 SCRIPTED_EVENT branch |
| 제품 변경 파일 | Main / Builder / RunDispositionState / TestSequenceDispositionSnapshot, CATEGORIES·envelope count 변경 | 같은 4파일, 기존 CATEGORIES/envelope 유지 |
| 새 Resource/State | 필요 없음. live history 누적 storage는 금지 | **필요 없음.** typed는 closed field/type/domain validator를 뜻하며 새 DTO class도 요구하지 않음 |
| Owner 중복 | category가 기록뿐이면 없음. live 누적 시 중복 위험 | 기존 Response authority + 종료 detached copy만 |
| source lifetime | preflight/commit 전 capture 필요 | 동일. primitive만 보관해 release 후 독립 |
| cleanup 영향 | CATEGORIES·envelope 호환·category loop 검토 필요 | 기존 category loop·receipt/reset 순서 유지 가능 |
| Sequential/Side | 두 유형 source identity로 지원 | origin/occurrence/domain 분리로 지원 |
| Case Failure | category는 분리되나 전체 envelope 변경 | CASE EVENT schema/key 유지, 새 domain만 추가 |
| 이전 snapshot 호환 | 현재 data.size()==6과 충돌. old envelope 수락 규칙 필요 | old six-field Case-only records 수락 유지. 관찰 snapshot field는 additive |
| 검증 비용 | source validator + category/envelope/cleanup compatibility | source validator + typed row/key + existing historical category 회귀 |
| 단점 | top-level 변경에 비해 이득이 작음 | recipient의 Case identity 전제를 domain별로 분기해야 함. dict 무조건 복사하면 타입 구분이 무의미 |

**B 권장.** 별도 category/version/owner/Resource 없이 existing 역사 category 안에서 타입을 구분한다. Case-required fields를 fake 값으로 채우기, 모든 Runtime/raw Response 무조건 저장, generic Story/Event framework는 배제한다.

## 11. Recommended Minimum Design

Step68 제안 계약:

1. CASE/Scripted source capture를 분리한다. existing facts.responses는 Case-only 유지, 신규 제안 channel **scripted_responses**에 non-CASE 원본 기록을 넣는다. unknown origin/손상된 record도 validator 대상이며 continue로 숨기지 않는다. 전체 get_responses 원본의 빠짐없는 coverage를 요구한다.
   원본 CASE record도 source 분류 시 actual Campaign CASE Entry의 occurrence/definition과 IncidentSource.matches로 identity agreement를 확인한다. 기존 Case row/key/Failure 판정은 바꾸지 않지만, 새 전체 source coverage에서 잘못된 CASE occurrence를 정상 Scripted 부재로 숨기지 않는다. legacy recipient Record 수락과 current raw owner source 검증은 별개다.
2. 순수 projection은 CampaignData를 read-only lookup input으로 받고 Progress의 campaign ID/current Entry/completed IDs만 primitive **campaign_scope**로 capture한다. 새 State/query authority/history 누적 storage 없음.
3. source validation은 **Pending preparation 전** 및 prepared capture 후 모두 수행한다. Campaign/Progress scope, definition validation, exact source, unique Incident→Broadcast→Option→Result, COMPLETED, Sequential completion proof, Side target reached를 검사한다. ACTIVE/invalid source는 reject/freeze, 자동 완료/수선 금지.
4. Builder 내부 pure Scripted helper를 추가한다. 예시 이름 **project_completed_scripted_responses는 제안 API이며 현재 존재하지 않는다.** Case validation은 유지, Scripted가 없으면 empty projection으로 legacy output 불변.
5. typed rows를 existing historical_facts 뒤에 append한다. 새 Scripted block만 `(origin, occurrence, incident)` 순으로 canonical 정렬해 repeat equality를 안정화한다. 발생 시각/Story 시간 순서를 주장하지 않으며 기존 Case row 순서는 변경하지 않는다.
6. recipient는 domain 확인 후 Case 또는 Scripted 필수 필드 branch로 검증한다. Scripted closed schema, int origin, trimmed/nonblank IDs, 정확한 actual_facts 3필드, 고정 kind/phase, duplicate/conflict 검증. 기존 Record가 acyclic primitive 안전성을 처리한다.
7. commit 후 recipient가 독립 소유, getters는 deep copy. 반복 closure/cleanup은 같은 record/receipt 재사용, Runtime/Story/UI를 재생하지 않는다.

현재 source ID validators 일부는 strip-empty 수준이고 recipient _is_id는 trim agreement까지 요구한다. 공백 ID를 자동 정규화해 다른 identity로 만들지 말고 reject한다. authored data를 묵시적으로 수정하지 않는다.

## 12. Recipient / Snapshot Mapping

| source | capture / validation | destination (Step68 제안) |
|---|---|---|
| CASE COMPLETED | 기존 Case records/Failure evidence/Case assignment | 기존 EVENT/COMPLETED_RESPONSE_FACT 그대로 |
| Sequential COMPLETED | CAMPAIGN_ENTRY + authored occurrence/payload + Progress completion | SCRIPTED_EVENT, occurrence=entry_id |
| Side COMPLETED + 정상 복귀 | CAMPAIGN_INTERRUPT + authored interrupt/payload + safe boundary | SCRIPTED_EVENT, occurrence=interrupt_id |
| Scripted ACTIVE/CONFIRMED/Result View only | 기존 terminal blockers + completed-only 검사 | 완료 역사 행 없음. 강제 완료/Scripted obligation 미구현 |
| Side pending/due/context | _side_boundary_status | 기존 unsupported terminal boundary 유지 |

RunDispositionRecord의 primitive copy/equality가 이미 충분하다. 새 Resource/Node refs는 저장하지 않는다. try_commit은 full Record+receipt를 동시에 보관하며 같은 run의 다른 내용은 CONFLICT다. GDScript private 필드가 언어 수준에서 강제되는 것은 아니며 supported APIs의 detached copy 계약이다.

관찰 snapshot은 **completed_responses(Case)를 유지하고 신규 completed_scripted_responses field를 추가**하는 안이다. Builder의 같은 pure validator 결과를 Main이 전달하고 Snapshot은 primitive projection만 복사한다. Snapshot에 Builder preload를 추가하면 현재 Builder→Snapshot 의존과 cycle이 되므로 **Main에서 helper를 호출해 결과만 전달**한다. Side early invalid boundary guard를 유지하고 invalid source를 빈 성공 snapshot으로 숨기지 않는다.

이전 snapshot/recipient 호환:

- old six-field Case-only Record 수락, Case schema/key/receipt/getter 유지. 정상 Scripted 없는 source output은 동일해야 한다.
- old snapshot은 새 field가 없을 수 있다. structural reader는 empty default를 써도 되지만 **누락을 “사건이 없었다”는 확정 사실로 바꾸면 안 된다.** 기존 bug로 incomplete일 수 있다.
- 이미 commit된 old record에 소급 append/같은 run ID overwrite하지 않는다. 새 full-source projection과 old incomplete record가 다르면 existing equality/receipt authority에 따라 INVALID_SOURCE_STATE/CONFLICT 경로로 남긴다. 자동 migration/새 Run 발급 없음.
- positive completed facts/ID는 release 후 읽을 수 있으나 원문·정의 version·Save persistence·과거 negative query 완전성을 제공하지 않는다.

## 13. Cleanup / Source Lifetime

필요 정보는 preflight/prepared capture에서 원본 Response/Progress + authored definition을 읽어 **recipient commit/acknowledgement까지 보존**한다. reset/free/release를 그 앞으로 옮기지 않는다. cleanup에서 새 source lookup/re-projection을 하지 않는다.

현재 _cleanup_verified_source는 receipt/Record categories/State·sequence·View preflight 후 adapter release→State reset이다. B는 CATEGORIES/envelope를 바꾸지 않아 순서와 emptiness 확인 유지가 가능하다. Response/Progress reset 뒤 recipient는 외부 독립 객체로 남으며 Main은 recipient instance ID와 primitive receipt만 유지한다.

ALREADY_COMMITTED는 동일 record/receipt agreement일 때만, ALREADY_CLEANED는 _cleaned_source_is_empty가 참일 때만이다. wrong receiver/receipt/source identity/partial reset은 reject/frozen explicit retry 유지. typed history 추가가 multi-State atomic rollback을 제공하지 않는다.

_side_boundary_status (`main.gd:2381`): pending→UNSUPPORTED_INTERRUPT_RESUME_PENDING, active Side→UNSUPPORTED_ACTIVE_CAMPAIGN_RESPONSE, due→UNSUPPORTED_DUE_CAMPAIGN_INTERRUPT, retained context→UNSUPPORTED_INTERRUPT_CONTEXT. ACTIVE Sequential은 developer_commit_run_disposition:1155에서 차단한다. 이 guard를 완화하거나 Step53 active CASE forced closure에 Scripted를 포함하지 않는다.

cleanup 후 Main에 CampaignData/case_sequence 정의가 남아도 Response/Progress history는 reset되고 adapter는 release됐다. 정의 존재로 실행·완료를 재구성하지 않는다. _exit_tree:163도 query를 release하며 recipient에 자동 commit하지 않는다.

## 14. CampaignFactQueries Compatibility

실제 existing API (`scripts/read_models/campaign_fact_queries.gd`):

| 대상 | Completion | Option / Result |
|---|---|---|
| CASE / Sequential Entry | was_response_completed(entry_id, incident_id):166 | get_confirmed_option:172, get_incident_result:176 |
| Side occurrence | was_interrupt_response_completed(interrupt_id, incident_id):180 | get_interrupt_confirmed_option:186, get_interrupt_incident_result:190 |
| Campaign order | was_entry_completed(entry_id):126 | Side 완료를 host Entry 완료로 바꾸지 않음 |

_resolve_response:323은 actual source/approved link/status를 검증하는 live query다. Step68에서 terminal/history 조회로 대체하거나 SOURCE_RELEASED 후 recipient fallback을 추가하지 않는다.

| Availability | 현재 의미 / 유지 계약 |
|---|---|
| KNOWN | 유효한 scope의 값. NOT_STARTED/ACTIVE의 completion은 **KNOWN false**, COMPLETED는 true. Confirm 이후 option/result는 **ACTIVE_CONFIRMED에서도 KNOWN**, 완료 증거가 아님 |
| UNKNOWN | identifier NOT_STARTED/NOT_CONFIRMED 등 값 미확정. false/실패/자동 선택으로 치환하지 않음 |
| INVALID | invalid Campaign/Entry/Interrupt/scope, same-key definition mismatch, broken broadcast/approved link/status. 원본 수정 없음 |
| UNSUPPORTED | Scripted research의 SCRIPTED_RESEARCH_UNSUPPORTED 등 지원 밖 질문. terminal UNSUPPORTED_* 문자열과 Query enum은 별개 |
| SOURCE_RELEASED | release_sources 후 query 재호출 결과. reset empty를 KNOWN false로 바꾸지 않고 revive/rebind하지 않음 |

정밀 구분: nonexistent occurrence query는 INVALID_ENTRY_ID/INVALID_INTERRUPT_ID. expected origin+occurrence+incident가 같은 record의 definition/broadcast 오류는 RESPONSE_SOURCE_MISMATCH/INVALID. **다른 origin/occurrence record는 현재 query matching에서 건너뛴다**; valid queried occurrence에 NOT_STARTED가 나올 수 있다. 따라서 KNOWN false로 orphan record 부재를 증명하지 말고 terminal projector는 raw records 전체를 검증한다.

release 후 retained query 객체는 당시 값으로 남을 수 있지만 live authority가 아니다. 새 live query SOURCE_RELEASED를 무시할 근거가 아니다. 종료 후 historical read는 existing RunDispositionState.get_committed_record(run_id)의 detached data를 명시적으로 읽는 책임이다. 새 get_scripted_history/StoryFlag API가 이미 존재한다고 주장하지 않는다.

## 15. Scenario Matrix

**다음 12행은 코드 근거와 Step68 설계 예상값이다. 이번 Step에서 실행한 테스트/PASS 수가 아니다.** terminal 포함은 existing final Case boundary가 충족된 시점의 proposed record를 뜻한다. Scripted 완료만으로 _developer_source_valid의 마지막 Case/확정 Room 조건을 만족하지 않는다.

| # / 상황 | 기록 포함 / 완료 상태 | 중복 정책 | 기존 guard / Step68 validation | 예상 live Query → release 후 |
|---|---|---|---|---|
| 1 실제 TEMP Mandatory01 완료 | Sequential COMPLETED 1행. 현재 코드는 누락. 다음 Case03 final boundary에서 projection 대상 | occurrence별 1행 | Result acknowledgement + Progress completion proof. 자동 terminal/Ending 아님 | 완료 KNOWN true, option/result KNOWN → SOURCE_RELEASED; recipient positive fact 유지 |
| 2 Confirm 후 Result acknowledgement 전 | 완료 행 0. status ACTIVE(confirmed). Result View만 표시해도 동일 | 미완료를 완료 행과 합치지 않음 | ACTIVE Scripted terminal block. try_confirm≠try_complete | 완료 KNOWN false, IDs KNOWN → SOURCE_RELEASED; 이 상태 terminal record 없음 |
| 3 동일 Resource / 서로 다른 Sequential Entries | 실제 완료한 occurrence별 행. 같은 definition이어도 entry IDs로 구분 | A/B 2행 정상, 동일 identity 중복 invalid | unique entry IDs + 각각 Progress proof | 각 Entry별 KNOWN completion/choice → SOURCE_RELEASED |
| 4 동일 정의 Sequential/Side 양쪽 사용 | 각각 완료하면 origin 1/2로 두 행 | definition/incident ID만으로 merge 금지 | authored occurrence 및 payload source agreement | Entry API/Interrupt API 각각 조회 → SOURCE_RELEASED |
| 5 Mid-Case 완료 후 업무 복귀 | Side COMPLETED 1행. host CASE 미완료여도 가능; terminal은 나중 final boundary | interrupt별 1행 | exact restore 성공/context clear/safe boundary | Side 완료 KNOWN true, host Entry 완료는 별도 실제 값 → SOURCE_RELEASED |
| 6 Mid-Case resume pending | 원본은 COMPLETED일 수 있어도 **terminal 불허, recipient 추가 0**. 관찰 snapshot도 early invalid boundary 유지 | retry가 response 재완료/새 행 추가하지 않음 | UNSUPPORTED_INTERRUPT_RESUME_PENDING, completed/context 보존 + explicit restore retry | Side 완료 KNOWN true 가능, resume 성공 증거 아님. release 시 SOURCE_RELEASED |
| 7 실제 Case Failure Major 완료 | 기존 EVENT/COMPLETED_RESPONSE_FACT 유지, Scripted 행 0 | 기존 Case assignment/event key | Failure Resolution/candidate/source/Result acknowledgement | Case response 완료 KNOWN true → SOURCE_RELEASED; Case historic fact 유지 |
| 8 Scripted 없는 Campaign | Scripted 행 0, legacy Case output 동일 | 새 빈 Owner/가짜 발생 없음 | final boundary/Case-only preflight 유지 | 없는 Scripted/Interrupt ID면 INVALID. valid Case incident NOT_STARTED면 완료 KNOWN false → SOURCE_RELEASED |
| 9 terminal 반복 요청 | 같은 data/receipt면 ALREADY_COMMITTED, append 없음 | run publication 1개 | receipt-first/reproject equality; old incomplete record와 다르면 reject | retained source는 live 값, committed copy 독립 → release 후 SOURCE_RELEASED |
| 10 cleanup 재호출 | recipient 역사 동일, live empty | rebuild/recommit/append 0 | receipt+emptiness → ALREADY_CLEANED, 실패 SOURCE_CLEANUP_ERROR | SOURCE_RELEASED; recipient getter는 동일 detached 역사 |
| 11 잘못된 source identity | completed fact로 포함하지 않고 전체 새 commit reject | corrupt/duplicate를 흡수하거나 origin fallback 금지 | wrong occurrence/definition/kind/alias/link/duplicate 검증 | INVALID 또는 unmatched valid query NOT_STARTED 구분은 §14. release 후 SOURCE_RELEASED |
| 12 source release 후 조회 | 이미 commit된 positive facts만 읽음, 원본 보완/추정 금지 | 새 history owner/identity 재발급 없음 | release_sources / CLEANED_NO_RUN 재prepare block | live query 재호출 SOURCE_RELEASED; retained query는 당시 observation, recipient는 별개 |

추가 한계: 마지막 authored Entry가 Scripted이고 current_case/runtime이 null인 완료 상태는 현재 final Case boundary API가 종료하지 못한다. 새 boundary를 신설하지 않는다. 현재 TEMP 뒤에는 Case03이 있어 existing boundary에서 이력 보존을 검증할 수 있다. Campaign completion all-true/Ending을 자동 발명하지 않는다.

## 16. Required Step68 Code Changes

**다음 단계 계획이며 현재 수정하지 않았다.** 최소 제품 변경 파일은 4개다.

| 파일 / 실제 수정 지점 | 좁은 변경 계획 |
|---|---|
| `scripts/main/main.gd` _developer_source_facts / _prepare_and_commit_developer_disposition / build_test_sequence_disposition_snapshot | source channels·primitive Campaign scope capture, pure validator에 read-only CampaignData 전달, before-prepare/after-prepare/repeat equality에 Scripted 포함. 관찰 snapshot에 validated projection 전달. _case_response_records의 CASE channel 역할 유지 |
| `scripts/read_models/developer_run_disposition_builder.gd` source_issue / build | Scripted-only pure source/link/completion helper, before-mutation 검증, typed rows append/canonical block. 기존 Case mapping/candidate/obligation 유지. 추가 Campaign lookup 인수는 Case-only 사본 호환을 위해 default null 허용 가능, Scripted 존재 시 누락 input reject |
| `scripts/runtime/run_disposition_state.gd` _entry_issue / _validation_issue | closed SCRIPTED_EVENT branch, Case와 별도 key/definition consistency/duplicate check. CATEGORIES/6-field envelope/receipt/copy API 유지 |
| `scripts/read_models/test_sequence_disposition_snapshot.gd` build | Case completed_responses와 분리된 additive completed_scripted_responses 복사. invalid boundary 유지. Builder preload로 cycle 만들지 않음 |

변경 불필요: IncidentResponseState/IncidentSource/Progress/Data/RunDispositionRecord/CampaignFactQueries의 새 storage/getter, 새 .gd class/Resource, UI/Theme/Scene/Assets, gameplay Confirm/completion/cursor/Side checkpoint/resume semantics. 현재 getters가 충분하다. 4파일 계약으로 가능한지 검토하지 않고 Framework를 확장하지 않는다.

권장 순서: closed schema/key → pure projector/invalid cases → Main before-prepare capture wiring → additive snapshot → recipient/cleanup/lifetime/실제 Campaign regression. 제안 helper/field/domain을 현재 API로 가정하지 않는다.

## 17. Required Regression Tests

이번 Step에서는 **실행하지 않았다**. Step68에서 새 증거 namespace에 작성/실행한다. 과거 결과·fixture·이미지를 덮어쓰지 않는다.

1. §15의 12개 독립 시나리오를 measured fixture ID로 구분. assertion/API call/process/Journey/독립 시나리오 수는 별도 보고. 순수 projector 전후 owner/RNG/progress fingerprint 동일.
2. Godot 4.7.1 전체 parsing/import/configured Main 실행. schema matrix: missing/wrong types/nontrim ID, CASE 위장, wrong kind/phase/extra fields, unknown/duplicate/conflicting source, broken Option→Result, unconfirmed/ACTIVE/bad status, valid repeated definition reuse.
3. authored TEMP A/C 경로를 Main+실제 GUI로 완료→Case03 containment final boundary→개발자 configured commit→cleanup. **기존 누락 재현 뒤** 새 row/receipt 보존 확인. B/D도 Result ID를 임의 SUCCESS로 변환하지 않는 content-link test.
4. controlled Side complete+exact resume→final boundary, pending/failed restore developer retry/due guard, Seq/Side shared definition, reused Seq occurrence A/B. canonical completion과 host completion/resume를 대체하지 않는지 확인.
5. 기존 Case Failure completed 및 active voluntary/forced suite. cross-origin same incident ID가 candidate removal/completed_for/matches_active/obligation를 오염시키지 않는지 검사.
6. repeat commit/ALREADY_COMMITTED/conflict/receipt mismatch/source mutation, old incomplete record reject, cleanup/ALREADY_CLEANED/partial reset frozen retry. getter 복사본 mutation 후 내부 불변, release 후 recipient 유지, canonical Scripted array 순서 안정성.
7. actual Entry/Interrupt query API: NOT_STARTED KNOWN false, unconfirmed UNKNOWN, confirmed-but-active known IDs, COMPLETED true, invalid links/scope, UNSUPPORTED research, released adapter/retained query. historical getter로 adapter revive 금지.
8. Case-only exact output equality, old six-field envelope acceptance, old snapshot missing-field semantics, new additive field. old absence를 known no-Scripted로 단정하지 않음.
9. Step62 exact resume/Step63 order/Step64~65 Modal·Scroll·Drawer trap/Step66 Navigation·A/Esc/BACK/**Step66.1 R/A/N Matrix와 Hypothesis·Experiment·Containment drafts** 회귀. GPU 1920×1080/1280×720과 headless 구분.

검증 완료 전 completed Scripted terminal projection OPEN 해결이라고 기록하지 않는다. 이번 source audit는 Runtime simulation/실제 제품 Journey 통과 증거가 아니다.

## 18. Existing OPEN Issues / Final Preservation

| OPEN | 현재 코드 근거 / 유지 범위 |
|---|---|
| completed Scripted terminal projection | §4 Main filter + Builder/recipient Case-only schema. **이번 Step 종료 시에도 OPEN** |
| Step53 prepared Pending P2 | _prepare_and_commit_developer_disposition (`main.gd:1324–1327`) ACTIVE_FORCE_REQUIRES_PREPARED_PENDING. active CASE/Pending 계약 완화 없음 |
| Step54 cross-State atomic rollback limitation | _cleanup_verified_source:1246–1258 여러 State reset 후 postcondition. 전체 rollback 없음, frozen proof/explicit retry 유지 |
| Step62 failed restore developer retry | _resume_side_work complete 후 비동기 _restore_side_work 실패 가능. completed/context/pending 유지 + developer retry, player recovery 없음 |
| Hypothesis getter P3 | _developer_source_facts:1385–1387, _cleaned_source_is_empty:1273의 private enumeration. detached getter는 있으나 enumeration getter 없음. 이번 범위 밖 |

Step66.1 Navigation, Archive A/Esc/BACK·R/A/N, Drawer/draft/focus/scroll 및 Step62/63를 시작 byte hashes와 대조한다. StoryFlags/Manager/Singleton/EventBus/새 CampaignCursor/Save/Load/Ending/Mandatory02/03/Case/Event/UI/경제 시스템을 추가하지 않는다.

최종 Git: HEAD `19be4ea998d6479f5c46c3527d540ff4a16f2322`, branch master, upstream origin/main, staged 0. 이번 modified README 1 / created 보고서 1 / deleted 0. 전체 modified 6 / untracked 3 (기존 변경 포함). git diff --check 통과. 제품 GDScript/Scene/Resource/Theme/project.godot 및 이전 문서는 시작 hash 동일, README prefix 유지.  Godot 재실행 없음.**
