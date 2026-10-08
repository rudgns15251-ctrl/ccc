# Step58 — Scripted Campaign Incident Foundation + Source-Aware Response

2026-10-07. 기존 CAP 프로젝트에 구현한 구조 기반이다. 제품 `TEST_CAMPAIGN_01`은 계속 CASE01→CASE02→CASE03이며, Scripted 이벤트를 제품 Campaign에 추가하지 않았다. 새 동작은 `.godot/verification/step58/`의 in-memory TEST fixture에서 검증했다. 실제 Story/Mandatory/Final/Ending의 구현 완료를 뜻하지 않는다.

## 작업 전 조사와 보호

HEAD `6e8f167f699a3a95c91fee8668ae99d03e5d4db9`, branch `master`, upstream `origin/main`, staged 0. 기존 modified README/Main Scene/Main Script와 Step55~57의 untracked 문서·Campaign·typed Entry 파일이 있었다. 전부 기존 작업으로 취급하고 커밋·stage·push·reset을 하지 않았다.

실제 비생성 파일 135개, 제품 GDScript 45개, Scene 15개, authored `.tres` 4개를 조사했다. `project.godot`, Main Scene/Script, 12개 View, data/runtime/read_models, 기존 Report, Git 상태, source_case_id·Response State·Case cursor 호출을 확인했다. 저장소 및 상위 경로에서 적용 AGENTS.md는 발견하지 않았다.

Main은 2100행/111함수, IncidentResponseState는 58행/8함수였다. 기존 Response는 `(source_case_id, incident_id)` key와 ACTIVE/COMPLETED, 단일 active key, ID만 저장하는 in-memory 구조였다. 기존 `_case_index`는 Main의 저장 cursor였고 `case_sequence`는 CASE 배열이었다.

기준 조사/파일 SHA-256/기존 Step55~57 evidence 1189개 hash를 `baseline.json`에 보관했다. 기존 Campaign/3 Case `.tres`, 모든 Scene/UID/설정과 Step55~57 Report는 byte 보존한다. CampaignData/EntryData/Main의 필요한 확장은 이전 미커밋 작업 위에 적용하고 before→after patch를 별도로 남겼다. README는 원본 435768 byte prefix를 보존한 뒤 이번 보고만 append했다.

## 책임과 변경 파일

| 파일 | 책임 / 변경 이유 |
| --- | --- |
| scripts/data/scripted_incident_data.gd + .uid (신규) | Event definition scope. event_id, IncidentData, Broadcast 배열, Result 배열. 링크/중복 검증 및 읽기 조회. |
| scripts/runtime/incident_source.gd + .uid (신규) | CASE/CAMPAIGN_ENTRY origin과 entry occurrence/definition ID를 표현하는 작은 값 전달 객체. State에는 ID 복사만 저장. |
| scripts/runtime/campaign_progress_state.gd + .uid (신규) | Campaign 단일 cursor, completed entry IDs, source→target 전환 intent와 offer 1회 budget. |
| scripts/data/campaign_entry_data.gd (수정) | CASE/SCRIPTED_INCIDENT enum, typed payload, exactly-one 검증. |
| scripts/data/campaign_data.gd (수정) | 각 kind 검증, entry_id 전역 중복 거절, CASE의 case_id 중복 거절, entry 및 Case→entry 읽기 mapping. |
| scripts/runtime/incident_response_state.gd (수정) | source-aware key와 API, ACTIVE1, confirm/complete once. CASE 읽기 compatibility projection만 유지. |
| scripts/main/main.gd (수정) | validated dispatch, Case-only projection, source resolver, 기존 response/Archive UI orchestration, bounded Case→Scripted, terminal explicit block 및 progression cleanup. |
| scripts/views/flow_view.gd (수정) | Scripted의 Campaign context를 기존 ResponseContext에 표시. fake SOURCE/INTERRUPTED CASE/Resume 없음. |
| scripts/read_models/test_sequence_disposition_snapshot.gd (수정) | CASE-only completed 검사, CAMPAIGN origin을 Case로 오인하지 않음. |
| scripts/read_models/developer_run_disposition_builder.gd (수정) | 기존 Case terminal 경계를 명시. 직접 전달된 non-Case history는 UNSUPPORTED_CAMPAIGN_RESPONSE_HISTORY. |
| README.md (append) | 이번 단계 결과와 Report 링크. |
| docs/step58_scripted_campaign_incident_foundation.md (신규) | 이 보고서와 요청한 222개 답변. |

이번 단계만 비교하면 기존 파일 8개 수정, 7개 추가(신규 GD3/UID3/문서1), 삭제0이다. 누적 Git 상태에 표시되는 Main Scene, Campaign Resource, Step55~57 문서는 이전 단계 변경이며 Step58에서 재수정하지 않았다. 새 `.tres`0, 변경 `.tres`0, Scene 변경0, project.godot 변경0이다. ignored verification 파일은 위 제품 파일 수에 포함하지 않는다.

기존 Main Scene과 Incident/Broadcast/IncidentResult/Archive Scene 및 Node 배치는 그대로이다. 기존 Scene들이 동일 Script와 Signal을 통해 Main으로 요청하고, Main이 현재 source scope를 주입한다. Manager/Autoload/Singleton/EventBus/새 BaseClass/Framework는 추가하지 않았다.

## identity와 source 계약

| ID / 상태 | 의미 |
| --- | --- |
| campaign_id | authored sequence definition ID. Run identity가 아니다. |
| entry_id / source_entry_id | Campaign 내 실행 occurrence의 stable ID. 모든 kind에서 고유. |
| CaseData.case_id / source_definition_id (CASE) | Case definition ID. 현재 반복 Case는 여전히 거절한다. |
| ScriptedIncidentData.event_id / source_definition_id (CAMPAIGN_ENTRY) | Event definition ID. 다른 entry_id가 같은 Event bundle을 참조할 수 있다. |
| incident_id | 해당 source content scope의 Incident ID. Event ID 및 occurrence ID와 구분한다. |
| response key | JSON tuple `[origin_kind, source_entry_id, incident_id]`. definition ID는 confirm/complete binding 검증에도 사용한다. |
| `_active_key` | 동시 ACTIVE1. COMPLETED라도 동일 key를 재시작하지 않는다. |
| confirmed_option_id / incident_result_id | 실제 source의 승인된 option/result 링크. draft는 여기에 저장하지 않는다. |

IncidentSource 필드는 값 전달 목적으로 사용하며 물리적으로 immutable 객체를 강제하는 보안 장치는 아니다. Response State가 detached primitive ID 기록을 보관한다. legacy String source API/Case-only key lookup은 제거했다. CASE getter의 source_case_id는 source_definition_id에서 파생한 inspection compatibility 값이며 저장/key 권한을 갖지 않는다. CAMPAIGN record에는 source_case_id를 넣지 않는다.

| route | content / 시작 권한 | 완료 후 |
| --- | --- | --- |
| 기존 CASE Failure | unique Case→Campaign entry mapping. 기존 Resolution/Candidate/D·M/read credit/oldest selector와 normal interrupt. CaseData의 leaf 배열에서 조회. | candidate 정상 완료 제거, interrupted Case의 같은 Runtime/return View로 Resume. |
| SCRIPTED_INCIDENT | validated 현재 Campaign entry가 시작 권한. bundle의 Incident/Broadcast/Result scope 조회. Case/Failure/Resolution/Candidate/D·M/RNG/credit 불필요. | 승인된 Result acknowledgement에서 Response 완료→entry once 완료→다음 entry dispatch. |

전역 leaf registry/fake Case/fake Failure/fake Candidate를 만들지 않는다. Scripted entry의 IncidentData에는 기존 environmental_disturbance 필드가 있을 수 있지만 Scripted 실행은 이를 failure disturbance로 적용하지 않는다. 실제 Story/effects/condition/flags는 없다.

## 진행과 UI / Archive

CampaignProgressState._current_entry_index가 sole authoritative cursor이다. Main._case_index는 현재 CASE의 ordinal getter이며 Scripted 동안 -1이다. case_sequence는 기존 Case lookup/Archive/terminal inspection용 CASE-only projection이다. 두 cursor를 독립 증가시키지 않는다. current_case/case_runtime는 Scripted 동안 null, CASE dispatch에서 새 Runtime을 만든다.

CASE→Scripted는 기존 유효 Confirm/Pending 및 hidden outcome prepare 성공과 Archive merge 뒤에 CASE entry를 한 번 완료한다. product 마지막 Case03의 Outcome0/No next 상태는 자동 완료/Ending으로 바꾸지 않았다. Scripted ack는 현재 View·entry metadata·response source·approved Result·can_complete_current를 확인하고 동기적으로 once 완료한다. 동일 ack 및 queued/deleted old Views는 다음 entry를 다시 진행시키지 못한다.

기존 Response 세 View를 재사용한다. Incident title은 SCRIPTED CAMPAIGN INCIDENT, context는 CAMPAIGN EVENT + event_id(entry_id), Result action은 Continue Campaign이다. interrupted Case/Resume를 꾸미지 않았다.

Scripted Open Source Archive는 현재 발견된 Archive List로 간다. 실제 archived Case detail을 읽고 List로 돌아간 뒤 동일 Scripted 단계로 Back한다. 기존 Case Failure는 기존 Source Case detail 경로를 유지한다. unconfirmed draft는 source origin/entry/definition/incident/broadcast/option tuple로 보관·복원하고, Confirm/Result는 Response State를 그대로 읽는다. 전체 Archive 왕복에서 Pending/Resolution/Candidate/Response/Archive/Hypothesis/counters/RNG/credit/token/opportunity와 cursor/intent/완료목록 불변을 비교했다. Scripted provenance로 미발견 Research를 unlock하지 않는다.

## Case→Scripted bounded arbitration

구현 범위는 Case Confirm 후 Next의 Case→Scripted 경계이다. source entry와 target Scripted entry에 묶인 intent에서 기존 실패 이벤트 offer budget을 최대1회 소비한다. 기존 gate가 OPEN이면 기존 oldest actionable selector를 이용한다. 실제 Major를 Resume하거나 Notice를 Dismiss해도 같은 intent/budget이 남는다. 다음 Next는 budget을 재충전하지 않고 Scripted로 진행한다. gate CLOSED이면 바로 진행한다. draining loop 및 Scripted starvation을 막으며 CASE→CASE의 기존 ordering/pacing 정책을 확장하거나 바꾸지 않는다.

Scripted ACTIVE는 non-interruptible이다. 기존 Candidate는 그대로 보존하고 Scripted dispatch/Archive/진행/ack에 failure RNG/threshold/opportunity/token/credit 변화가 없다. direct old Major/Disturbance 시도도 차단한다. 다음 Case의 새 meaningful read에서 기존 후보를 다시 정상 제시할 수 있다. Story/Final/Ending의 전체 arbitration 구현을 뜻하지 않는다.

## terminal / cleanup 지원 경계

| 상태 | 정책 / 실제 검증 |
| --- | --- |
| 기존 CASE-only terminal | 기존 builder/record/recipient/ownership/receipt/prepare/freeze/cleanup regression 통과. |
| ACTIVE Scripted, voluntary 또는 forced | UNSUPPORTED_ACTIVE_CAMPAIGN_RESPONSE로 명시 block. recipient Record0, proof0, TerminalMode.NONE, source/UI/cursor/freeze mutation0. |
| ACTIVE Scripted cleanup | 검증된 commit 없음→INVALID_PRECONDITION. source reset/종료 위장0. |
| Scripted 완료 후 CASE active | 기존 Case closure 가능. Scripted COMPLETED 기록은 session State에 있지만 Case terminal projection에는 포함하지 않는다. 이를 모든 Scripted terminal history 지원으로 주장하지 않는다. |
| mixed CASE closure 뒤 verified cleanup | progression identity도 receipt/live identity 검증에 포함. 기존 source와 progression completed IDs/intent/cursor reset, CLEANED_NO_RUN, recipient/authored 보존. |
| Scripted Snapshot | UNSUPPORTED_CAMPAIGN_ENTRY / current_case_id 빈값 / runtime_instance_id0 / active_response{}로 안전한 read-only observation. 기존 schema 확장0. |

Scripted terminal 통합은 **INCOMPLETE / NOT IMPLEMENTED**, 안전한 explicit block은 IMPLEMENTED이다. Case terminal builder의 schema/obligation/closure category/경제 등은 확장하지 않았다. Step53 ACTIVE+resolvable/residue Pending의 OPEN P2, Step54 cross-State atomic rollback 불보장 및 frozen retry 제한은 그대로다. 기존 Hypothesis private-key enumeration P3도 남아 있다.

## fresh 검증과 발견·수정

Godot 4.7.1.stable.official.a13da4feb Windows console binary로 fresh editor import, 제품 GD48개 check-only, configured Main headless/native, mixed/반복 Event/bounded/standalone/invalid scripted와 기존 회귀를 실행했다. 최종 채택한 실행 집계는 **73개 프로세스 / 10591 assertions**, 정상 warning0, runtime/script/parse error0이다. 의도적인 invalid/negative fixture의 warning21 및 developer error30(Campaign invalid13+Scripted invalid17)는 별도 집계했다. 개발 중 실패한 fixture pilot 및 이전 단계 실행 수는 최종 집계에서 제외했다.

실제 Case 콘텐츠를 사용하는 A/B Journey와 normal Case Response Source Archive를 headless/native로 다시 실행했다. Step46 Snapshot4그룹, Step47 ordering, Step48 read gate, Step51 ownership, Step52 closure, Step53 active termination, Step54 cleanup, Step55/57 typed Campaign routing 및 invalid startup을 검증했다. 새 mixed journey는 실제 View Button/Signal로 수행한다. native Windows OpenGL Compatibility/AMD Radeon RX6800의 Scripted Incident/Broadcast draft/Result/다음 Case PROFILE GPU PNG 4개를 직접 시각 확인했다. 추가 bounded native Major 화면도 캡처했다. F5 키를 직접 조작하지 않고 동일 run/main_scene 경로를 CLI로 실행했다.

layout/Scene/project settings를 변경하지 않아 전체 3해상도 suite를 재반복하지 않았다. reference1920×1080, window1280×720, canvas_items stretch, GL Compatibility 및 기존 clear color를 byte 보존했다.

- copied ordering stress fixture가 synthetic Case만 추가하고 대응 entry mapping을 만들지 않은 pilot은 새 canonical identity에서 거절됐다. ignored fixture에만 stable synthetic entry mapping을 추가했고 제품 fallback은 넣지 않았다.
- mixed fixture의 ArchiveListView type alias 누락은 fixture에 alias를 명시해 해결했다. 제품 파싱 문제는 아니었다.
- direct old Disturbance 호출이 Scripted ACTIVE/null Runtime에 접근할 여지를 검토해 Runtime/ACTIVE guard를 먼저 적용했다. bounded native/headless와 기존 event 회귀가 통과했다.
- S17~S21은 실제 retained queued View로 callback을 다시 호출해 삭제 전 mutation0을 검증한다. free된 Node에 불법 호출하는 시험으로 대체하지 않았다.

## 상태와 다음 단계

| 분류 | 내용 |
| --- | --- |
| IMPLEMENTED | typed Scripted payload/validation, source-aware State, sole progress cursor, 기존 response UI 재사용, Archive 복귀, once ack, bounded Case→Scripted, explicit terminal block. |
| SUPPORTED | 기존 CASE Failure/Archive/terminal 계약, unique entry IDs에서 동일 Event definition의 반복 occurrence(두 실제 UI 응답 검증). |
| CONTROLLED TEST ONLY | CASE A→Scripted→CASE B, bounded old event와 Scripted-only Campaign. 모두 ignored in-memory fixture. 제품 Campaign의 실제 Story Event 없음. |
| NOT IMPLEMENTED | 실제 Story/Mandatory/Final/Ending/Story flags/conditions/effects, repeated Case, Scripted terminal ownership history, Save/Load, 경제/할당량/정산, 새 Run 시작. |

지원 범위에서 새 P0/P1 blocker를 발견하지 않았다. 알려진 P2/P3 및 Scripted terminal integration gap을 해결 완료로 표시하지 않는다. Step59는 user-authored Event definition/entry ordering 및 Scripted completed history의 terminal 책임을 좁게 정한 뒤 시작하기 적합하다. 실제 콘텐츠 추가에는 entry_id/event_id, Incident 문구, Broadcast 질문/option_id, Result 문구/result_id·link, insertion order와 종료 정책 자료가 필요하다. 소재·조건·Mandatory/Final 의미는 임의로 발명하지 않는다.

## source_case_id /cursor /Response inventory

최초 관련139줄과 최종145줄의 코드·file·line 전수 목록은 ignored `source-inventory-before.json` 및 `source-inventory-after.json`에 보관했다. source_case_id 자체의 총96→79줄은 다음 분류로 처리한다. 남은 source_case_id를 CAMPAIGN key로 사용하지 않는다.

| 파일 | source_case_id before→after | 최종 역할 / 처리 |
| --- | ---: | --- |
| scripts/main/main.gd | 36→30 | Case Candidate/Resolution/Case source Archive/interrupt context/Case terminal은 Case ID 유지. Response API와 content resolver는 descriptor로 이행, Scripted context는 별도 branch. 최종 줄: 95, 463, 1301, 1311, 1314, 1316, 1331, 1332, 1335, 1349, 1479, 1480, 1481, 1483, 1486, 1491, 1495, 1496, 1502, 1516, 1605, 1621, 1625, 1626, 1627, 1629, 1652, 1654, 1739, 1744 |
| scripts/runtime/incident_response_state.gd | 12→1 | 12줄의 Case String key/API를 전부 제거. CASE getter projection1줄만 파생 출력. 최종 줄: 23 |
| scripts/runtime/failure_event_candidate_state.gd | 27→27 | 전부 실제 Case failure 후보용. 파일 변경0, Scripted Candidate 생성0. 최종 줄: 8, 9, 11, 12, 16, 17, 20, 21, 30, 31, 32, 36, 40, 41, 43, 59, 60, 61, 65, 69, 70, 72, 79, 80, 82, 85, 86 |
| scripts/views/flow_view.gd | 2→2 | 기존 CASE context의 SOURCE/INTERRUPTED CASE 표시 유지. 그 전에 CAMPAIGN context branch. 최종 줄: 57, 61 |
| scripts/read_models/test_sequence_disposition_snapshot.gd | 5→5 | 기존 Case Snapshot 분류/참조. non-Case completed skip, Main은 unsupported active observation. 최종 줄: 83, 102, 104, 112, 125 |
| scripts/read_models/developer_run_disposition_builder.gd | 14→14 | Case ownership/obligation schema 유지. direct non-Case history는 explicit unsupported, Main은 CASE records projection. 최종 줄: 32, 39, 47, 52, 63, 64, 65, 69, 70, 75, 110, 116, 120, 133 |

Response/cursor 경계의 주요 최종 함수 위치:

| 함수 | 위치 / 역할 |
| --- | --- |
| _current_campaign_entry | scripts/main/main.gd:2163 |
| _next_campaign_entry | scripts/main/main.gd:2167 |
| _case_response_source | scripts/main/main.gd:2171 |
| _is_scripted_response | scripts/main/main.gd:2176 |
| _is_response_route | scripts/main/main.gd:2180 |
| _bound_scripted_entry | scripts/main/main.gd:2184 |
| _has_response_context | scripts/main/main.gd:2191 |
| _response_content_scope | scripts/main/main.gd:2195 |
| _case_response_records | scripts/main/main.gd:2202 |
| _dispatch_campaign_entry | scripts/main/main.gd:2209 |
| _accept_view_action | scripts/main/main.gd:1320 |
| _on_advance_requested | scripts/main/main.gd:854 |
| _handoff_to_next_case | scripts/main/main.gd:1003 |
| _advance_response | scripts/main/main.gd:1715 |
| _on_source_archive_requested | scripts/main/main.gd:1756 |
| developer_commit_run_disposition | scripts/main/main.gd:1058 |
| _cleanup_verified_source | scripts/main/main.gd:1091 |

## 제품 코드 변경 크기 / 실제 Scene

Main2100→2239행(+139), 함수111→121(+10); ResponseState58→64행(+6), 함수8→9(+1). 새 Progress State는 70행이며 거대한 Campaign/Event manager가 아니다. Main의 기존 36함수에서 필요한 source/route/cursor/terminal guards를 변경했다.

변경한 기존 Main 함수: `_ready`, `_show_view`, `_on_research_log_requested`, `_on_archive_case_requested`, `_on_archive_list_back_requested`, `_on_archive_detail_back_requested`, `_get_current_incident_data`, `_get_current_emergency_broadcast`, `_get_current_confirmed_broadcast_option`, `_get_current_incident_result`, `_on_broadcast_confirmation_requested`, `_on_advance_requested`, `_has_next_test_case`, `build_test_sequence_disposition_snapshot`, `_handoff_to_next_case`, `developer_commit_run_disposition`, `_cleanup_verified_source`, `_cleaned_source_is_empty`, `_developer_session_state_ids`, `_developer_live_identity`, `_developer_source_facts`, `_accept_view_action`, `_try_process_failure_event_opportunity`, `_grant_event_presentation_credit`, `_try_present_oldest_actionable_event`, `_try_present_candidate_disturbance`, `_response_source_case`, `_response_incident`, `_response_broadcast`, `_response_result`, `_build_response_display_context`, `_restore_response_broadcast_draft`, `_try_start_major_incident`, `_confirm_response_option`, `_advance_response`, `_on_source_archive_requested`.

Main Scene의 실제 Node 구조(변경0):

| Node | type / parent |
| --- | --- |
| Main | Control / root |
| Margin | MarginContainer / . |
| Center | CenterContainer / Margin |
| Content | VBoxContainer / Margin/Center |
| Title | Label / Margin/Center/Content |
| ReferenceSize | Label / Margin/Center/Content |
| WindowSize | Label / Margin/Center/Content |
| Notice | Label / Margin/Center/Content |
| ViewHost | Control / Margin/Center/Content |

## 검증 suite별 최종 집계

| 실행 | 프로세스 | assertions | controlled warnings | controlled errors |
| --- | ---: | ---: | ---: | ---: |
| core | 51 | 0 | 0 | 0 |
| ownership | 1 | 274 | 0 | 0 |
| smoke | 6 | 3404 | 4 | 0 |
| closure | 1 | 460 | 13 | 0 |
| journey | 1 | 745 | 0 | 0 |
| journey_native | 1 | 758 | 0 | 0 |
| active | 1 | 708 | 2 | 0 |
| active_native | 1 | 719 | 2 | 0 |
| cleanup | 1 | 1130 | 0 | 0 |
| cleanup_native | 1 | 1152 | 0 | 0 |
| campaign | 1 | 150 | 0 | 0 |
| campaign_native | 1 | 156 | 0 | 0 |
| campaign_invalid | 1 | 122 | 0 | 13 |
| mixed | 1 | 168 | 0 | 0 |
| mixed_native | 1 | 172 | 0 | 0 |
| mixed_invalid | 1 | 112 | 0 | 17 |
| bounded | 1 | 180 | 0 | 0 |
| bounded_native | 1 | 181 | 0 | 0 |
| 합계 | 73 | 10591 | 21 | 30 |

`certification.json`에는 각 Godot 프로세스·exit·elapsed·정상/의도 진단 수와 각 suite assertions, S01~S35, hash 보존 결과를 기록했다. `*-runs.json`, log/stdout/stderr, native PNG, fixture GD 및 이번 단계 before→after patch가 같은 namespace에 있다. 이 기록들은 gitignored이며 기존 단계 evidence를 덮지 않았다.

## 요청한 최종 보고 222개 항목

| 번호 | 요청 항목 | 구현 / 검증 / 한계 |
| ---: | --- | --- |
| 1 | 작업 전 Git 상태 | 작업 전 modified3(README/Main Scene/Main Script), untracked Step55~57 문서·Campaign·typed Entry. staged0. 위 보호 절 참조. |
| 2 | HEAD | 6e8f167f699a3a95c91fee8668ae99d03e5d4db9 그대로. |
| 3 | branch/upstream | master / origin/main 그대로. |
| 4 | 기존 Step55~57 보호 | 기존 미커밋 내용을 유지. 이전 문서/Scene/.tres/UID와 verification1189개 SHA-256 동일. 필요한 Campaign/Main 확장만 before patch와 분리. |
| 5 | 기존 Main 크기 | 2100행 /111함수. |
| 6 | 기존 ResponseState 구조 | 58행/8함수. CASE pair key, ACTIVE1, confirm/complete, detached ID 기록. source-aware canonical tuple로 이행. |
| 7 | 기존 source_case_id 사용 inventory | 작업 전 관련139줄(실제 source_case_id96줄), 후145줄(79줄). 아래 inventory 및 before/after JSON 참조. |
| 8 | CampaignEntryData 변경 | entry enum과 typed scripted_incident_data, kind별 exactly-one 검증 추가. |
| 9 | 새 SCRIPTED kind | SCRIPTED_INCIDENT=1. CASE=0 보존. |
| 10 | future kinds 여부 | 추가0. 미지원 enum99는 startup reject. |
| 11 | scripted payload field | @export scripted_incident_data: ScriptedIncidentData. |
| 12 | exactly-one validation | CASE는 CaseData만, SCRIPTED는 ScriptedIncidentData만. 혼합/null 거절. |
| 13 | CASE validation | 기존 case_id 비어 있지 않음 + scripted payload 없어야 함. 중복 Case는 Campaign에서 거절. |
| 14 | SCRIPTED validation | scripted bundle 및 전체 Incident→Broadcast→Option→Result 링크/leaf validation. |
| 15 | CampaignData validation | 전체 Entry 선검증. 오류 index/entry ID 포함. Main이 State/View 생성 전에 중단. |
| 16 | duplicate entry ID | kind 무관 전역 unique entry_id. 동일 Event의 별도 entry_id는 허용. |
| 17 | duplicate Case ID | CASE case_id unique. external clone의 같은 Case ID도 거절. |
| 18 | repeated Case | NOT IMPLEMENTED. 현재 명시적으로 거절 유지. |
| 19 | scripted bundle 이름 | ScriptedIncidentData. |
| 20 | bundle path | scripts/data/scripted_incident_data.gd. |
| 21 | bundle fields | event_id, incident_data, emergency_broadcasts, incident_results. runtime/flag/effect 없음. |
| 22 | event_id | Event definition ID. entry occurrence ID와 별도. |
| 23 | IncidentData reuse | 기존 IncidentData 그대로 재사용. 새 Scripted Incident leaf type 없음. |
| 24 | BroadcastData reuse | 기존 EmergencyBroadcastData와 BroadcastOptionData 재사용. |
| 25 | ResultData reuse | 기존 IncidentResultData 재사용. |
| 26 | link validation | Incident broadcast_id 및 각 Option result_id가 해당 bundle 안의 unique leaf로 연결되어야 함. |
| 27 | duplicate leaf validation | broadcast_id/result_id와 Broadcast 내 option_id의 null/blank/duplicate 거절. S35. |
| 28 | authored mutation | authored property tree before/after 비교 통과. Case/Entry/bundle/leaf Resource mutation0. |
| 29 | actual Story content | NOT IMPLEMENTED. TEST 문구만 ignored fixture에 존재. |
| 30 | product TEST Campaign 변경 여부 | 변경0. .tres SHA-256 동일 /CASE3개. |
| 31 | controlled fixture | .godot/verification/step58 안에서 in-memory Campaign/bundle. 제품 authored TEST Story Resource0. |
| 32 | source origin representation | IncidentSource.OriginKind enum과 detached descriptor IDs. |
| 33 | CASE origin | CASE=0. Case→Campaign entry의 unique mapping. |
| 34 | CAMPAIGN origin | CAMPAIGN_ENTRY=1. 실제 current scripted entry source. |
| 35 | source entry ID | entry_id, occurrence 고유성. Case ID/Event ID 대신 key에 사용. |
| 36 | source definition ID | CASE case_id 또는 CAMPAIGN event_id. confirm/complete/내용 scope 일치 검사. |
| 37 | response occurrence key | JSON tuple [origin_kind, source_entry_id, incident_id]. 구분자 충돌을 피함. |
| 38 | incident ID | 해당 scope IncidentData.incident_id. Response start/confirm/complete binding. |
| 39 | legacy key 제거/호환 | Case-only String API/key 제거. CASE getter에만 source_case_id 파생 projection 유지; legacy key fallback0. |
| 40 | Case Failure migration | 모든 제품 Response API call site가 descriptor/mapping 사용. Snapshot/terminal은 Case-only 경계를 유지. |
| 41 | Response active semantics | 단일 _active_key와 ACTIVE1. 시작 시 detached source IDs 저장. |
| 42 | confirmed option | confirmed_option_id는 승인 성공 때 1회 기록. draft는 View/return context만. |
| 43 | result ID | incident_result_id는 실제 approved Option.result_id. Result View binding 검사. |
| 44 | completed semantics | 승인된 Result ack 뒤 COMPLETED. 같은 key 재시작 거절. |
| 45 | active1 | try_begin에서 active key 존재 시 모든 origin의 추가 시작 거절. |
| 46 | nested response | Scripted ACTIVE 중 old Major/Disturbance 호출 mutation0. case-context 요구 및 ACTIVE guard. |
| 47 | Case content resolver | response.source_definition_id를 unique Case mapping/CaseData로 검증하고 leaf 조회. |
| 48 | Campaign content resolver | 현재 entry, source entry/definition, null Case/Runtime binding 후 bundle 내부 조회. |
| 49 | global registry 여부 | 없음. local authored scope 조회. |
| 50 | fake Case 여부 | 없음. Scripted 동안 current_case null. |
| 51 | fake Failure 여부 | 없음. Scripted dispatch/ack가 resolution을 만들지 않음. |
| 52 | fake Candidate 여부 | 없음. Scripted source로 Failure Candidate 생성/삭제0. |
| 53 | scripted trigger authority | validated Campaign 현재 SCRIPTED entry dispatch. |
| 54 | random trigger | 없음. RNG consume0. |
| 55 | real-time trigger | 없음. Timer/process polling trigger0. |
| 56 | Candidate requirement | 불필요. no-candidate mixed startup 통과. |
| 57 | Resolution requirement | 불필요. Scripted-only Campaign도 실행됨. |
| 58 | D threshold | Scripted에는 사용0. 기존 Case D2~4 정책 유지. |
| 59 | M threshold | Scripted에는 사용0. 기존 Case M1 정책 유지. |
| 60 | pacing credit | Scripted 자체 consume/grant0. bound transition의 old failure offer에만 기존 credit 정책 적용. |
| 61 | CampaignProgressState 여부 | IMPLEMENTED. 작은 RefCounted local State. |
| 62 | progress State path | scripts/runtime/campaign_progress_state.gd. |
| 63 | progress owner | CampaignProgressState가 entry cursor와 completed IDs/intent sole owner. Main은 orchestration. |
| 64 | authoritative cursor | _current_entry_index 하나. 배열/목록 getter는 detached 값 반환. |
| 65 | `_case_index` 역할 | 현재 CASE ordinal getter. Scripted=-1. 저장/증가 대입 제거. |
| 66 | case_sequence 역할 | Case lookup/Archive/terminal용 CASE-only projection. authored sequence 진행 owner 아님. |
| 67 | dual cursor 여부 | 없음. _case_index는 derived. |
| 68 | current CASE dispatch | 현재 CASE payload 주입→새 CaseRuntime→PROFILE. session State는 재사용. |
| 69 | current Scripted dispatch | 현재 SCRIPTED bundle source로 Response 시작→기존 INCIDENT. Case/Runtime 생성0. |
| 70 | current_case during Scripted | null. |
| 71 | Runtime during Scripted | null. |
| 72 | return policy | CASE Failure=RESUME_INTERRUPTED_CASE, Scripted=ADVANCE_CAMPAIGN_ENTRY 의미로 분리. |
| 73 | Failure return | 기존 interrupted Case/동일 Runtime/return stage Resume. |
| 74 | Scripted return | Result acknowledgement→entry once completion→next dispatch. |
| 75 | Incident View reuse | 기존 incident_view.tscn/incident_view.gd 그대로. |
| 76 | Broadcast View reuse | 기존 broadcast_view.tscn/broadcast_view.gd 그대로. |
| 77 | Result View reuse | 기존 incident_result_view.tscn/incident_result_view.gd 그대로. |
| 78 | Scripted labels/context | SCRIPTED CAMPAIGN INCIDENT /CAMPAIGN EVENT + event_id(entry_id)/Continue Campaign. |
| 79 | fake Resume 여부 | 없음. Scripted UI에 Source/Interrupted Case/Resume를 붙이지 않음. |
| 80 | Source Archive Case behavior | 기존 Source Case detail→같은 Response stage 복귀 그대로. |
| 81 | Source Archive Scripted behavior | discovered Archive List→선택된 실제 Case detail→List→같은 Scripted stage. |
| 82 | Archive List | 기존 ArchiveListView 재사용. session의 실제 archived Case만. |
| 83 | Archive detail | 실제 discovered entry만 기존 ArchiveDetailView로 읽음. |
| 84 | Archive Back | source stage/context binding 검사 후 동일 Response로 복귀. stale Back 차단. |
| 85 | draft preservation | origin/entry/definition/incident/broadcast/option tuple draft 보존. S09/S10. |
| 86 | confirmed preservation | State confirmed option/result 유지, Confirm lock 복원. S11. |
| 87 | Result preservation | 동일 approved Result Resource와 Result ID. S12/S13. |
| 88 | Archive mutation | Pending/Resolution/Candidate/Response/Archive/Hypothesis/counters/RNG/credit/token/opportunity/progress mutation0. |
| 89 | stale Incident | S18: 실제 old Incident queued View callback mutation0. |
| 90 | stale Broadcast | S19: 실제 old Broadcast queued View advance/archive/confirm callback mutation0. |
| 91 | stale Result | S17/S20: 실제 old Result queued View duplicate acknowledgement mutation0. |
| 92 | stale Archive | S21: 실제 old Archive List queued View Back callback mutation0. |
| 93 | active View guard | 현재 instance/inside-tree/not-queued/terminal policy/visible View guard. |
| 94 | entry binding guard | campaign_entry_id metadata와 현재 progress entry 일치 + response descriptor matches/bound payload 검증. |
| 95 | Scripted completion ack | approved Result가 실제 View에 표시되고 동일 response/entry일 때만. |
| 96 | exactly once completion | response once complete와 progress.can_complete_current/try_complete_and_advance 동기 실행. |
| 97 | duplicate ack | stale View와 completed entry/key 검사로 duplicate advance0. |
| 98 | completed entry IDs | 단일 State에서 stable IDs 순서대로 보관. getter detached /cleanup reset. |
| 99 | CASE entry completion integration | 유효 next handoff에서 hidden prepare 성공+Archive merge 후 CASE entry 완료1회. |
| 100 | Case result semantics | 기존 Case hidden Outcome/Pending/Failure/Success semantics 유지. Scripted 결과를 Case Success로 변환0. |
| 101 | Case03 behavior | 제품 Case03 Outcome0/confirmed Pending/No next 유지. 자동 End/false verdict0. |
| 102 | Case→Scripted transition | bound transition arbitration 후 CASE 완료→null Case/Runtime→Scripted dispatch. |
| 103 | Scripted→Case transition | Scripted ack→current entry 완료→다음 CASE에 새 Runtime/PROFILE. |
| 104 | bounded transition arbitration | IMPLEMENTED 범위=Case→Scripted 경계. source/target bound intent/offer once. 전역 Story arbitration 아님. |
| 105 | old Major offer | gate OPEN에서 기존 oldest actionable Major 또는 Disturbance 최대1회. Resume/Dismiss 뒤 budget 유지. |
| 106 | gate closed behavior | 즉시 Scripted로 진행. old Candidate/RNG/threshold를 소모하거나 강제하지 않음. |
| 107 | offer budget | max1. 다시 누르기/새 credit/Log 왕복으로 recharge0. |
| 108 | drain 여부 | drain loop0. 추가 ready Candidate가 Scripted 앞에 반복 제시되지 않음. |
| 109 | starvation protection | consumed intent가 source/target에 유지되므로 추가 old event로 Scripted starvation 없음. |
| 110 | Candidate preservation | S23: Scripted 시작~ack 사이 old Candidate 전체 record와 order/threshold counters 동일. next Case fresh read에서 다시 제시 가능. |
| 111 | scripted opportunity count | 0. before/after processed opportunity/candidate counters 동일. |
| 112 | scripted RNG | draw0. RNG.state 동일. |
| 113 | scripted credit | consume/grant0. credit/token 동일. |
| 114 | Research provenance | Case Research provenance 모델 그대로. Scripted는 별도 Research를 unlock하지 않음. |
| 115 | hidden Research | 추가0. Archive에서 discovered IDs만 읽음. |
| 116 | Hypothesis | 가설 내용/id counter mutation0. 기존 UI/State 변경0. |
| 117 | Story flags | NOT IMPLEMENTED. |
| 118 | history store | session IncidentResponseState와 progress.completed_entry_ids만. 별도 Story history store0. |
| 119 | Save | NOT IMPLEMENTED. 파일 저장/Load0. |
| 120 | terminal builder | 기존 Case builder를 유지. Main projection은 CASE만; direct non-Case history input은 명시적 unsupported. |
| 121 | Scripted active closure | 현재 Scripted ACTIVE closure 지원 없음. 명시적 block만 구현. |
| 122 | explicit block status | UNSUPPORTED_ACTIVE_CAMPAIGN_RESPONSE. |
| 123 | terminal freeze mutation | 없음. mode NONE/source/View/cursor/recipient unchanged, freeze/proof 생성0. |
| 124 | Scripted active forced termination | 같은 명시 block. fake aborted Case 또는 FORCED source record0. |
| 125 | Scripted completed closure | 다음 CASE에서 기존 closure 가능. completed Scripted history는 Case terminal record에 포함되지 않는 한계가 있음. |
| 126 | cleanup compatibility | 검증된 mixed CASE receipt 이후 진행 State까지 reset. ACTIVE Scripted는 cleanup INVALID_PRECONDITION. |
| 127 | Snapshot Scripted safety | UNSUPPORTED_CAMPAIGN_ENTRY/current Case 없음/Runtime0/active{}; read-only mutation0. schema 확장0. |
| 128 | product Campaign unchanged | TEST_CAMPAIGN_01 .tres 및 Case01/02/03 .tres hash 동일. |
| 129 | A/B Journey | 실제 authored Case A/B Journey headless/native 모두 재실행 통과. |
| 130 | Failure Incident regression | normal Major→Broadcast→Result→Resume regression 통과. |
| 131 | Case Source Archive regression | 실제 Source Case Archive/draft/confirmation/Result 복귀 회귀 통과. |
| 132 | Step46 regression | Snapshot normal/phases/response/isolation 4그룹 통과. |
| 133 | Step47 regression | oldest actionable ordering suite 통과. synthetic mapping fixture만 canonical entry에 맞춰 갱신. |
| 134 | Step48 regression | meaningful read pacing gate 통과. 기존 credit/token/D/M 정책 보존. |
| 135 | Step51 regression | ownership/receipt/duplicate/conflict/record detached 회귀 통과. |
| 136 | Step52 regression | closure prepare/identity/idempotent commit/source drift/recipient rejection 회귀 통과. |
| 137 | Step53 regression | voluntary active response-only/forced freeze/queued callbacks/retry 회귀 통과. |
| 138 | Step54 regression | verified cleanup/receipt proof/no-run/partial failure retry 회귀 통과. |
| 139 | Step55 regression | data-driven Case sequence/length/reorder/property tree 회귀 통과. |
| 140 | Step57 regression | typed 3 CASE entries, mapping/identity/invalid Campaign13종 회귀 통과. |
| 141 | parser | 제품 GDScript48개 --check-only 통과. |
| 142 | editor import | fresh --editor --quit import 통과. |
| 143 | Main headless | configured run/main_scene --headless --quit-after20 통과. |
| 144 | Main native | configured Main Windows native --quit-after30 통과. F5 키 직접 조작은 안 함. |
| 145 | mixed headless | mixed real signal journey 및 반복 Event/standalone/bounded/invalid 검증 통과. |
| 146 | mixed native | mixed 및 bounded 실제 native UI signal journey 통과. |
| 147 | GPU | 1280×720 native. Scripted Incident/Broadcast draft/Result/next PROFILE 4 PNG 직접 시각 확인. layout byte 보존. |
| 148 | warnings | 정상0. controlled negative fixture warning21 별도. |
| 149 | controlled diagnostics | expected developer error30 = 기존 Campaign invalid13 + Scripted invalid17. 오류 fixture를 정상 로그와 분리. |
| 150 | runtime errors | 최종 runtime/script error0. |
| 151 | parse errors | 최종 parse error0. |
| 152 | process count | 최종 채택한 successful process73개. 개발 pilot/이전 단계 수 제외. |
| 153 | assertion count | 10591 assertions. 아래 suite별 실제 PASS log 집계. |
| 154 | authored preservation | Case/Entry/bundle/leaf property tree 불변 + 제품 .tres byte 동일 + 기존 evidence1189개 hash 동일. |
| 155 | response collision fixture | 같은 entry/incident 문자열의 CASE vs CAMPAIGN origin collision, 같은 Event definition을 별도 entry 두 번 실행 검증. |
| 156 | duplicate response fixture | COMPLETED 동일 key start/complete 중복 거절 및 actual queued Result duplicate callback 검증. |
| 157 | active1 fixture | CASE ACTIVE 중 CAMPAIGN try_begin 및 cross-origin confirm 거절; Scripted ACTIVE old Major 거절. |
| 158 | S01 | PASS: CASE A PROFILE 시작. mixed/invalid/bounded evidence JSON 및 actual signal 검증 참조. |
| 159 | S02 | PASS: 유효 제출 후 Scripted Next 활성. mixed/invalid/bounded evidence JSON 및 actual signal 검증 참조. |
| 160 | S03 | PASS: Scripted dispatch /null Case·Runtime. mixed/invalid/bounded evidence JSON 및 actual signal 검증 참조. |
| 161 | S04 | PASS: entry occurrence와 event definition 정확한 source. mixed/invalid/bounded evidence JSON 및 actual signal 검증 참조. |
| 162 | S05 | PASS: Scripted Candidate0. mixed/invalid/bounded evidence JSON 및 actual signal 검증 참조. |
| 163 | S06 | PASS: 실제 CASE resolution만 존재. mixed/invalid/bounded evidence JSON 및 actual signal 검증 참조. |
| 164 | S07 | PASS: Scripted RNG/credit 변경0. mixed/invalid/bounded evidence JSON 및 actual signal 검증 참조. |
| 165 | S08 | PASS: Incident Next→Broadcast. mixed/invalid/bounded evidence JSON 및 actual signal 검증 참조. |
| 166 | S09 | PASS: Broadcast draft 미확정. mixed/invalid/bounded evidence JSON 및 actual signal 검증 참조. |
| 167 | S10 | PASS: Archive 왕복 draft 복원. mixed/invalid/bounded evidence JSON 및 actual signal 검증 참조. |
| 168 | S11 | PASS: Confirm once/lock. mixed/invalid/bounded evidence JSON 및 actual signal 검증 참조. |
| 169 | S12 | PASS: 승인된 Result/Continue Campaign. mixed/invalid/bounded evidence JSON 및 actual signal 검증 참조. |
| 170 | S13 | PASS: Archive 왕복 Result 보존. mixed/invalid/bounded evidence JSON 및 actual signal 검증 참조. |
| 171 | S14 | PASS: Response COMPLETED. mixed/invalid/bounded evidence JSON 및 actual signal 검증 참조. |
| 172 | S15 | PASS: entry once completion. mixed/invalid/bounded evidence JSON 및 actual signal 검증 참조. |
| 173 | S16 | PASS: CASE B fresh Runtime/PROFILE. mixed/invalid/bounded evidence JSON 및 actual signal 검증 참조. |
| 174 | S17 | PASS: duplicate Result ack mutation0. mixed/invalid/bounded evidence JSON 및 actual signal 검증 참조. |
| 175 | S18 | PASS: retained old Incident callback mutation0. mixed/invalid/bounded evidence JSON 및 actual signal 검증 참조. |
| 176 | S19 | PASS: retained old Broadcast callback mutation0. mixed/invalid/bounded evidence JSON 및 actual signal 검증 참조. |
| 177 | S20 | PASS: retained old Result callback mutation0. mixed/invalid/bounded evidence JSON 및 actual signal 검증 참조. |
| 178 | S21 | PASS: retained old Archive callback mutation0. mixed/invalid/bounded evidence JSON 및 actual signal 검증 참조. |
| 179 | S22 | PASS: authored Resource tree 동일. mixed/invalid/bounded evidence JSON 및 actual signal 검증 참조. |
| 180 | S23 | PASS: old Candidate 보존. mixed/invalid/bounded evidence JSON 및 actual signal 검증 참조. |
| 181 | S24 | PASS: Scripted ACTIVE old Major/Disturbance 중첩 차단. mixed/invalid/bounded evidence JSON 및 actual signal 검증 참조. |
| 182 | S25 | PASS: voluntary/forced closure explicit block. mixed/invalid/bounded evidence JSON 및 actual signal 검증 참조. |
| 183 | S26 | PASS: 무검증 cleanup 차단. mixed/invalid/bounded evidence JSON 및 actual signal 검증 참조. |
| 184 | S27 | PASS: Scripted Snapshot 안전. mixed/invalid/bounded evidence JSON 및 actual signal 검증 참조. |
| 185 | S28 | PASS: invalid bundle startup block. mixed/invalid/bounded evidence JSON 및 actual signal 검증 참조. |
| 186 | S29 | PASS: duplicate entry IDs 거절. mixed/invalid/bounded evidence JSON 및 actual signal 검증 참조. |
| 187 | S30 | PASS: CASE both payloads 거절. mixed/invalid/bounded evidence JSON 및 actual signal 검증 참조. |
| 188 | S31 | PASS: SCRIPTED+Case payload 거절. mixed/invalid/bounded evidence JSON 및 actual signal 검증 참조. |
| 189 | S32 | PASS: SCRIPTED null payload 거절. mixed/invalid/bounded evidence JSON 및 actual signal 검증 참조. |
| 190 | S33 | PASS: broadcast link 오류 거절. mixed/invalid/bounded evidence JSON 및 actual signal 검증 참조. |
| 191 | S34 | PASS: result link 오류 거절. mixed/invalid/bounded evidence JSON 및 actual signal 검증 참조. |
| 192 | S35 | PASS: duplicate leaf IDs 거절. mixed/invalid/bounded evidence JSON 및 actual signal 검증 참조. |
| 193 | Main before lines | 2100. |
| 194 | Main after lines | 2239. delta+139. |
| 195 | Main before functions | 111. |
| 196 | Main after functions | 121. 새 helper10개. 기존 기능별 변경 함수 목록은 아래. |
| 197 | ResponseState before/after lines | 58→64행,8→9함수. 새 _project 및 canonical signatures. 임의 전체 시스템 재작성 없음. |
| 198 | new product files | GD3/UID3/이 Report1=7개. 위 파일 책임 표. |
| 199 | modified product files | GD7+README append1=8개. Main Scene 누적 변경은 Step58 수정0. |
| 200 | new Resource files | Resource class ScriptedIncidentData GD1(+UID), authored .tres0. |
| 201 | modified Resource files | CampaignData/EntryData Resource class 확장. authored .tres0. |
| 202 | modified Scene files | 0. 모든15 Scene bytes 동일. |
| 203 | deleted files | 0. |
| 204 | README | 원본435768 byte prefix SHA-256 보존. Step58 결과만 append. |
| 205 | report | docs/step58_scripted_campaign_incident_foundation.md. |
| 206 | git diff --check | git diff --check exit0. 기존 .gitattributes의 LF/CRLF advisory는 파싱/whitespace error가 아님. |
| 207 | staged | 0. baseline/after --cached 동일 빈값. |
| 208 | commit/push | 하지 않음. HEAD/branch/upstream 그대로. |
| 209 | P0 | 지원 범위에서 새 P0 blocker 발견0. |
| 210 | P1 | 지원 범위에서 새 P1 blocker 발견0. 미구현 terminal/story는 완성으로 표시하지 않음. |
| 211 | P2 | Step53 OPEN P2 및 terminal Scripted history integration gap 남음. 기존 상태 해결 완료 주장0. |
| 212 | P3 | Hypothesis private-key enumeration seam 유지. 큰 Main 책임 증가를 후속 검토하되 이번 scope에 refactor framework 추가0. |
| 213 | Step53 existing P2 | active+resolvable/residue Pending의 OPEN P2 그대로. 관련 negative 회귀 통과. |
| 214 | Step54 cleanup limitation | cross-State exception atomic rollback 보장 없음. silent reset partial cleanup 가능/frozen proof 보존/idempotent explicit retry. 기존 정책 유지. |
| 215 | ordering complete/incomplete | Case→Scripted bounded ordering IMPLEMENTED. 다른 future kind/전체 Story priority 정책은 NOT IMPLEMENTED. |
| 216 | terminal support complete/incomplete | Scripted ACTIVE explicit block IMPLEMENTED. 모든 Scripted terminal history 포함은 INCOMPLETE/NOT IMPLEMENTED. |
| 217 | Scripted foundation status | SCRIPTED CAMPAIGN FOUNDATION IMPLEMENTED, CONTROLLED TEST ONLY. |
| 218 | actual Story status | 실제 Story/Mandatory/Final/Ending NOT IMPLEMENTED. 제품 TEST Campaign Story0. |
| 219 | Step59 readiness | typed source/progress foundation 사용 가능. 실제 콘텐츠/terminal history 책임 결정이 먼저 필요. |
| 220 | required user Story materials | entry_id/event_id/삽입 순서/Incident 문구/Broadcast prompt 및 options/Result 문구 및 links/종료 policy. flags나 Mandatory 의미는 사용자 자료 필요. |
| 221 | final summary | Campaign이 가짜 Case/Failure 없이 Scripted source로 기존 응답 UI를 실행하고, ack 뒤 entry를 한 번 완료해 다음 entry로 간다. 제품 Campaign은 아직 CASE3개. |
| 222 | next recommendation | Step59에서 작은 authored TEST Event 또는 Scripted terminal history ownership 중 하나를 명시적으로 정해 진행. 실제 Story 조건/경제 시스템을 임의로 추가하지 않음. |

## 최종 보존 / Git 확인

Step58 이전135개 중 변경 허용한8개만 이번 변경(README 포함)이며 나머지127개 SHA-256 동일이다. 기존 Step55~57 evidence1189개 SHA-256도 동일이다. 신규 제품 파일7개, deletion0. project/Scenes/.tres byte 동일, README prefix 동일, staged0, HEAD/branch/upstream 동일, git diff --check 성공이다. 누적 Git diff와 이번 단계 baseline 비교를 모두 사용해 이전 변경을 이번 변경으로 오인하지 않았다. commit/push/stage는 하지 않았다.
