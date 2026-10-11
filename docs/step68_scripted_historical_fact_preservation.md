# Step68 — Completed Scripted Historical Fact Preservation Implementation

**IMPLEMENTATION / VERIFIED.** 2026-10-11. Step67 권장안 B를 기존 제품 파일 4개에 구현했다. 완료된 Sequential/Mid-Case Scripted Response를 기존 `historical_facts`에 occurrence별 typed 행으로 보존한다. Case Failure 형식, six-field envelope, receipt, 독립 Recipient 소유권, 기존 cleanup 순서는 유지한다. Story Campaign의 메모리 종료 기록 확장이다.

## 1. Repository Baseline

| 항목 | 실제 시작 상태 |
|---|---|
| HEAD | `19be4ea998d6479f5c46c3527d540ff4a16f2322` |
| branch / upstream | `master` / `origin/main` |
| staged | 0 |
| modified | README, Theme, Main, GameShell, ExperimentView, ResearchLogView — 6개 |
| untracked | Step66, Step66.1, Step67 보고서 — 3개 |
| 실제 파일 | Git/.godot 제외 166개; GD 53개, TSCN 17개, TRES 6개 |
| project.godot | Main=`res://scenes/main/main.tscn`, 1920×1080 viewport, 1280×720 창, canvas_items / 기본 keep, GL Compatibility, Autoload 없음 |
| authored Campaign | CASE01 → CASE02 → TEMP Mandatory01 → CASE03; authored side schedule는 비어 있음 |

기존 변경을 HEAD로 되돌리지 않았다. Step67 보고서 및 현재 네 제품 파일, 모든 State/Data/Scene/Resource/UI/Theme를 읽고 실제 getter·호출 경로를 기준으로 구현했다. AGENTS.md는 현재 저장소와 상위 경로 조사에서 발견되지 않았다. 시작 상태는 `.godot/verification/step68/baseline.json`에 SHA-256과 Git 상태로 기록했다.

## 2. Existing Gap Reproduction

제품 수정 전에 configured Main을 instantiate하고 실제 authored CASE01 정상 room, CASE02 정상 room, TEMP Option C 확정 → Result acknowledgement → CASE03 room 확정을 거쳤다. 기존 developer terminal API는 COMMITTED를 반환했다. `IncidentResponseState.get_responses()`에 origin=1/status=COMPLETED인 TEMP 행 1개가 있었지만 recipient의 SCRIPTED_EVENT 행은 0개였다. 223 assertion calls, `gap.json`과 `gap_reproduction.log`에 원본 증거를 보존했다.

제한된 초기 실행의 Windows root certificate store ERROR 1개도 원본 로그에 남아 있다. 게임 assertion은 통과했으며 이후 Godot 검사는 승인된 실행 환경에서 certificate 오류 없이 수행했다. 새 terminal boundary나 실제 Save/Ending을 추가해 재현을 우회하지 않았다.

## 3. Actual Source Owner Audit

| 사실 | 실제 canonical owner / read |
|---|---|
| source origin/occurrence/definition, response status, approved IDs | IncidentResponseState.get_responses; has_response |
| Campaign ID/current/completed prefix | CampaignProgressState 기존 getter 3개 |
| occurrence → definition / target CASE | CampaignData.get_entry / get_interrupt; authored validation |
| Incident → Broadcast → Option → Result | ScriptedIncidentData 및 unique_content read-only lookup |
| Case failure / obligation evidence | 기존 Resolution/Candidate/Case response owner |
| terminal recipient | RunDispositionState의 독립 copied Record + receipt |

원본 IncidentResponseState, CampaignProgressState, IncidentSource, CampaignFactQueries, Resolution/Candidate/Archive/Hypothesis State, Data Resource는 수정하지 않았다. Receiver인 RunDispositionState의 validation만 확장했다. 기존 Response owner의 dictionary key는 공개 `has_response(source, incident)`로 점검한다. private dictionary를 제품 코드에서 열거하거나 새 history owner를 만들지 않는다.

### Source Identity Matrix

| origin | occurrence | definition | incident / broadcast | option / result | completion proof |
|---|---|---|---|---|---|
| CASE=0 | 실제 Campaign CASE entry_id | CaseData.case_id | 기존 Case authored scope | 기존 Case response | 기존 Failure resolution + response evidence; legacy key |
| CAMPAIGN_ENTRY=1 | CampaignEntryData.entry_id | ScriptedIncidentData.event_id | 동일 definition의 Incident/Broadcast | 선택 option의 authored result_id | response COMPLETED + Progress completed Entry |
| CAMPAIGN_INTERRUPT=2 | ScriptedInterruptOccurrenceData.interrupt_id | ScriptedIncidentData.event_id | 동일 definition의 Incident/Broadcast | 선택 option의 authored result_id | response COMPLETED + 유효한 reached target CASE; host 완료 불필요 |

## 4. Source Classification

Main의 `_response_source_capture`는 전체 raw getter 결과를 Builder의 `classify_response_records`에 전달한다. 필수 ID/type/enum/status/primitive shape, derived alias 일치, authored CASE binding, typed source 중복을 검사한다. 성공 시 raw count = Case channel + Scripted channel count다. 원본 owner의 typed key 조회도 일치해야 한다.

CASE는 기존 `responses`, non-CASE는 `scripted_responses`로 분리한다. unknown origin, foreign occurrence/definition, 손상된 key, 잘못된 type/extra field는 명시적 `response_source_issue`다. 잘못된 source를 빈 정상 이력으로 해석하지 않는다. 진단이 있으면 후속 Active projector도 실행하지 않아 손상된 raw status의 추가 GDScript 오류를 막는다. `_case_response_records`의 기존 계약은 유지하며 새 terminal/snapshot capture는 검증된 분류를 사용한다.

## 5. Campaign Scope Capture

`campaign_scope={campaign_id,current_entry_id,completed_entry_ids}`는 기존 owner getter에서 그때그때 만든 detached primitive input이다. 누적되는 mutable State가 아니다. Scripted source가 있으면 authored Campaign 검증, ID 일치, completed IDs의 중복 없는 정확한 authored prefix 및 cursor 일치를 검사한다.

Scripted channel이 비어 있는 Case-only 경로는 기존 fixture/API 호환을 유지한다. 그 경우 새 projector가 추가 progress 판정을 부과하지 않는다. 따라서 이 helper는 별도의 범용 Campaign 무결성 검사로 사용하지 않는다. Main은 항상 전체 raw records를 검사하며 classification issue를 별도로 전달한다.

## 6. Sequential Validation

실제 get_entry(occurrence)로 SCRIPTED_INCIDENT kind, payload, event ID, Incident ID, Incident의 Broadcast link, unique Broadcast/Option/Result를 확인한다. COMPLETED라면 completed Entry IDs에 반드시 있어야 한다. ACTIVE라면 아직 완료되지 않은 current Entry여야 한다. 다음 Case cursor만 보고 발생한 사건을 추정하거나 missing completion을 자동 수선하지 않는다.

## 7. Mid-Case Validation

get_interrupt(occurrence)로 interrupt 및 target entry를 찾는다. target은 유효한 CASE payload이고 current 또는 already completed entry여야 한다. event/Incident/Broadcast/approved option→result link 및 response status를 검증한다. 아직 도달하지 않은 host, Scripted kind의 host, unknown interrupt, 잘못된 definition/link는 거부한다.

host CASE가 uncompleted인 상태에서 Side response 완료 및 exact work resume 후 이미 history projection이 가능함을 검증했다. Side의 host ID를 가짜 source Case ID로 저장하지 않는다. resume pending/due/active/retained context는 기존 Main terminal blocker가 먼저 거부한다.

## 8. Completion Semantics

| 상태 | typed completed history |
|---|---|
| NOT_STARTED | 0 |
| ACTIVE / unconfirmed | 0 |
| ACTIVE / confirmed | 0 |
| Result displayed / ACTIVE | 0 |
| COMPLETED / validated source | occurrence당 1 |
| COMPLETED / invalid source | issue, record 전체 거부 |
| Side COMPLETED / resume pending | projection 가능 여부와 별개로 terminal commit 차단 |

새 Confirmed status는 없다. COMPLETED는 정답을 뜻하지 않는다. 실제 Option A/C 전체 경로를 수행했고 B/D도 canonical Response API + authored link 검사로 검증했다. 오답 결과를 임의 SUCCESS/FAILURE나 점수로 바꾸지 않는다.

## 9. Typed Historical Schema

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

위 값은 실제 C journey 결과다. 제품 코드는 TEMP 문자열을 하드코딩하지 않고 raw canonical Response와 authored lookup에서 읽는다. outer key 정확히 8개, actual_facts 정확히 3개, discriminator/phase 고정, origin은 실제 int 1/2만 허용한다. ID는 nonblank 및 strip_edges 원문 일치로 검증하며 정규화하지 않는다. object/Resource/Node는 기존 primitive Record boundary가 거부한다.

### Historical Schema Matrix

| branch | key / fields | actual facts |
|---|---|---|
| CASE legacy | 기존 Case definition + assignment, RESOLUTION/EVENT domain, 기존 kind/key/optional metadata 유지 | 기존 resolution/response facts 그대로 |
| SEQ Scripted | SCRIPTED_EVENT + origin1 + occurrence + incident; definition은 consistency | broadcast/confirmed option/approved result ID 3개 |
| SIDE Scripted | SCRIPTED_EVENT + origin2 + occurrence + incident; 가짜 Case/entry alias 없음 | 같은 3개 ID |

새 top-level category, Save file, owner, Resource, Singleton은 없다.

## 10. Recipient Key / Duplicate Validation

Scripted typed key는 `[run_instance_id,"SCRIPTED_EVENT",origin_kind,source_occurrence_id,incident_id]`다. occurrence별 `(origin,occurrence)`에 definition/incident/broadcast consistency도 확인한다. definition을 key에 넣어 손상된 같은 occurrence가 분리되는 것을 방지한다. 같은 typed identity의 동일/충돌 행 모두 INVALID이며 silent dedupe/overwrite하지 않는다.

같은 definition을 여러 sequential occurrence에서 사용하거나 Sequential/Side에서 공유하는 것은 허용한다. 각 occurrence의 independent 행을 유지한다. 기존 CASE assignment/domain key 및 definition consistency validation은 그대로다.

## 11. Case Legacy Compatibility

Step68 시작 전 Builder의 anonymous QA copy와 현재 Builder를 동일 Case-only source에 적용해 전체 primitive output equality를 확인했다. 기존 CASE completed EVENT를 포함하는 경우와 Scripted 없는 경우 모두 동일했다. old six-field record를 그대로 recipient에 commit, 같은 receipt, duplicate/conflict, detached getter, 기존 assignment ID를 검증했다.

Case-only legacy caller는 기존 source_issue(facts,mapping), build(context,facts,sequence,boundary) 시그니처로 호출할 수 있다. optional Campaign input은 Scripted 검증에서만 필요하다. 기존 RunDispositionRecord 제품 파일은 수정하지 않았다.

## 12. Builder Pure Projection

`project_completed_scripted_responses(facts,campaign=null)`은 `{issue,rows}`만 반환한다. read-only Campaign Resource와 detached channels/scope를 검증하고 detached primitive rows를 만든다. Resource/Runtime/Response/Progress/Research/RNG mutation을 하지 않는다.

owner fingerprint에는 Progress, Response, Resolution, Candidate, Archive, Hypothesis, Experiment history, RNG identity/seed/state가 포함된다. authored resource tree도 pure 호출 전후 비교한다. 새 Scripted block만 origin/occurrence/incident 순으로 canonical sort하고 기존 Case historical row 순서를 바꾸지 않는다. raw 삽입 순서를 역전시켜도 새 block equality가 유지되었다. 이 순서는 실제 Story 시간 순서라는 뜻이 아니다.

## 13. Main Preflight Integration

| 실제 pipeline | 변경 전 | Step68 이후 |
|---|---|---|
| developer_commit_run_disposition | Side/ACTIVE guards → busy guard → prepare | 동일 |
| _prepare_and_commit_developer_disposition | recipient/context/receipt → source_valid → capture | 동일; repeated build에 Campaign 전달 |
| _developer_source_facts | Case-only response filter | 모든 raw 분류 + owner key + scope capture |
| _developer_active_response_facts | 기존 Case ACTIVE validation | 정상 classification에서만 동일 실행 |
| Builder.source_issue | Case mapping/failure evidence 검사 | 먼저 capture issue/Scripted pure validation, 이어 기존 Case 검사 |
| Pending prepare | source_issue 후 existing resolution/remove 또는 resolve | 동일, invalid Scripted는 도달 전 거부 |

잘못된 Scripted source로 resolvable final Pending/RNG preparation이 실행되지 않는 controlled Main negative를 확인했다. recipient0, pending 보존, resolution 생성0, gameplay owner/RNG mutation0이다. 기존 terminal freeze/retry UI 정책은 유지한다.

## 14. Prepared Source Recapture

정상 Pending preparation 후 원본 facts를 다시 capture한다. Builder.build는 prepared source에 대해 다시 source_issue/projector를 실행한다. preflight와 prepared의 Scripted channel/scope equality도 검사한다. 이후 기존 live identity 및 prepared vs 마지막 원본 re-read equality를 통과해야 recipient에 전달된다.

별도 PreparedSourceMain QA fixture에서 (1) 유효한 다른 approved response로 교체, (2) 잘못된 prepared option, (3) Campaign scope 변경을 주입했다. 셋 모두 INVALID_SOURCE_STATE, recipient0이었다. 해당 fixture의 정상 Pending→SUCCESS resolution 준비는 기존 허용 mutation이며 projector side effect가 아니다. 그 준비를 atomic rollback했다고 주장하지 않는다.

## 15. Observation Snapshot Extension

기존 `completed_responses`는 Case-only다. additive `completed_scripted_responses`에 Main이 pure helper의 validated rows를 전달한다. Snapshot은 copied observation이며 terminal authority가 아니다. Builder가 Snapshot을 참조하는 기존 의존 관계를 유지하고 Snapshot에 Builder preload를 추가하지 않았다.

invalid source는 boundary_valid=false / INVALID_RESPONSE_SOURCE / scripted_source_issue다. Side due/active/resume pending의 기존 early invalid/unsupported semantics를 유지한다. 새 build는 missing field를 []로 다룰 수 있지만 old snapshot constructor의 field 부재는 그대로 남는다. 구버전 field 부재를 실제 no-Scripted의 확정 증거로 사용하지 않는다.

## 16. Terminal Commit / Receipt

validated builder output → 기존 RunDispositionRecord primitive copy → RunDispositionState.try_commit closed typed schema/key validation → copied record+receipt 한 번 publication → Main record/receipt acknowledgement 순서다.

전체 full-source equality의 repeated commit은 ALREADY_COMMITTED이며 rows를 추가하지 않는다. 다른 유효한 Scripted option/result로 source를 바꾸면 INVALID_SOURCE_STATE(COMMITTED_SOURCE_MISMATCH)이며 기존 recipient/receipt가 보존된다. source를 동일하게 복원한 retry는 다시 ALREADY_COMMITTED다.

이미 Case-only로 commit된 불완전 old record fixture는 같은 ID의 full-source Main commit에서 거부되었다. direct recipient도 CONFLICT다. 사후 append/migration, overwrite, 자동 새 ID, 재플레이 재구성은 없다.

## 17. Cleanup / Source Release

기존 `_cleanup_verified_source` 순서를 유지했다. acknowledged record/receipt 검사 → 7 owner/identity/View/cleanup preflight → auxiliary UI 정리 → `CampaignFactQueries.release_sources()` → work/context detach → State reset(Response 포함) 및 runtime/progress 정리 → emptiness → CLEANED_NO_RUN이다. release는 destructive source resets보다 앞선다.

cleanup은 projector를 다시 실행하지 않으며 released owner를 읽어 history를 재생성하지 않는다. recipient는 별도 소유권으로 살아 있다. 재cleanup은 ALREADY_CLEANED이며 record/receipt가 같다. source query는 SOURCE_RELEASED, recipient는 complete IDs를 유지한다. getter copy를 변조해도 recipient 내부 기록은 변하지 않았다.

### Terminal Validation Matrix

| 경계 | 확인 결과 |
|---|---|
| preflight | 21 Main invalid source variants; normal Pending preparation 전 reject, owner/RNG0 |
| prepared | invalid source/scope reject + valid changed source consistency reject |
| commit | six-field record, approved Scripted IDs, atomic recipient publication/receipt |
| cleanup | 기존 release/reset/emptiness 순서; 역사 보존 |
| repeat | 동일 source ALREADY_COMMITTED / 동일 cleanup ALREADY_CLEANED; changed/old source 거부 |
| source release | live Query SOURCE_RELEASED; recipient detached facts 유지 |

## 18. Actual TEMP A/C Journeys

configured Main과 실제 product Campaign/Case/TEMP .tres를 사용했다. CASE01 room02 → CASE02 room01 → TEMP Incident → Broadcast A 또는 C → approved Result 화면 → acknowledgement → CASE03 Profile → 기존 room confirm/terminal API였다. case/prototype 데이터를 QA 전용 Campaign으로 교체한 경로와 구분한다.

A는 TEMP_RESULT_MANDATORY_01_A, C는 TEMP_RESULT_MANDATORY_01_C로 보존된다. 마지막 CASE03는 기존대로 Outcome이 없어 unknown unresolved submission으로 남는다. 새 ending/campaign-wide completion을 만들지 않는다. B/D는 기존 Step63 전체 product regression 및 새 canonical API/link 검사에서도 확인했다.

새 전용 journey는 실제 Viewport mouse/key input과 confirmation modal을 사용한다. Native는 실제 Windows OpenGL/RX6800 렌더링이며 headless는 같은 product path의 자동 input 검증이다. 물리적 OS 마우스/키보드로 수동 플레이했다고 주장하지 않는다. editor F5 키를 수동 누르지는 않았으며 configured Main scene을 CLI에서 script override 없이 실행했다.

1920×1080와 1280×720에서 A/C Result, CASE03 Profile, CASE03 terminal containment GPU PNG 각 6개를 확보했다. A1920/C1280 화면을 직접 열어 텍스트/CTA/레이아웃을 확인했다. 기존 Step66.1 native screenshots/validation도 새 namespace에서 재검증했다.

## 19. Side Completion / Resume

controlled Campaign에서 Sequential과 Side가 같은 bundle을 공유하도록 구성했다. Profile-stage Side response 완료 후 같은 Runtime, 동일 work state, cleared resume context, host completed list가 빈 상태임을 확인했다. 이후 정상 sequential completion 및 last CASE boundary에서 origin1/origin2 typed rows 2개를 commit했다.

Side synchronous COMPLETED와 async restore pending 사이에서는 원본 context 유지, recipient0, terminal unsupported 상태를 검증했다. 기존 Step62 regression의 stage/action/scroll/draft/result/failed-restore developer retry와 Step66.1 utility switching도 통과했다. 제품 authored side schedule를 추가하지 않았다.

## 20. Twelve Scenario Matrix

모든 ID는 새 dedicated fixture에서 독립적으로 기록하며 headless + native1920 + native1280 각각 PASS다. 아래 mutation0은 read-only projection/invalid preflight에 대한 표현이다. 정상 Gameplay completion, approved prepare, recipient commit, cleanup의 허용 변화와 구분한다.

| ID / fixture | expected / actual | owner mutation | result |
|---|---|---|---|
| S01 actual_A/C | 실제 TEMP 완료 + Progress agreement → terminal Scripted1 | projector0; 정상 completion 허용 | PASS ×3환경 |
| S02 confirm/display | ACTIVE confirmed 및 Result displayed는 완료 행0, 기존 terminal block | projection/blocked request0 | PASS ×3 |
| S03 REUSE_SEQ | 공유 definition의 Sequential A/B 독립 rows2 | projection0 | PASS ×3 |
| S04 REUSE_SIDE | Sequential/Side shared definition → origin별 rows2 | projection0 | PASS ×3 |
| S05 REUSE_SIDE | host 미완료 exact resume; 이후 final recipient에 Side 행 | projection0; 정상 restore 허용 | PASS ×3 |
| S06 side_pending | COMPLETED/pending context 유지, terminal reject/recipient0 | request0 | PASS ×3 |
| S07 LEGACY_FAILURE | CASE EVENT 그대로, Scripted0, candidate removal 의미 유지 | projection0 | PASS ×3 |
| S08 LEGACY_EMPTY | Case-only 전체 old/new output equality, six-field legacy recipient | projection0 | PASS ×3 |
| S09 actual_repeat/old | repeated ALREADY_COMMITTED, changed/old record mismatch reject | repeated/negative0 | PASS ×3 |
| S10 actual_cleanup | CLEANED→ALREADY_CLEANED, record/receipt 불변 | 정상 resets만 | PASS ×3 |
| S11 source negatives | invalid identity/link/duplicate/scope 전체 reject | preflight owner/RNG0, recipient0 | PASS ×3 |
| S12 source_release | Query released, detached recipient history 유지 | getter mutation0 | PASS ×3 |

## 21. Schema Negative Tests

| 영역 | 독립 negative ID 수 | 결과 |
|---|---|---|
| closed recipient schema | 42 | required/discriminator/type/phase/IDs/extra/object/fake Case/entry alias 거부 |
| recipient duplicate/consistency | 5 | identical identity 및 conflicting definition/incident/broadcast/option 거부 |
| pure Sequential source | 22 | origin/occurrence/definition/links/status/alias/scope/duplicate 거부 |
| Main preflight | 21 | 위 source와 wrong Entry kind, authored bad result, owner key corruption; prepare 전 거부 |
| Side source | 6 | unknown occurrence, future/non-CASE target, definition, duplicate, bad result mapping 거부 |
| 별도 prepared | 3 | prepared invalid/changed valid response/scope 거부 |

새 전용 fixture의 negative96개는 모든 환경에서 명시적 issue/INVALID와 mutation0를 검사했다. 별도 headless prepared 검사는 source CASE binding4, object/unknown field/non-string key3, old Snapshot absence1 및 NOT_STARTED/ACTIVE/entry completion 의미도 검사했다. negative 수를 assertion 호출 수와 혼동하지 않는다.

## 22. FactQueries Compatibility

CampaignFactQueries는 byte/SHA-256 동일하다. KNOWN/UNKNOWN/INVALID/UNSUPPORTED/SOURCE_RELEASED 의미, active confirmed option/result KNOWN과 completion false, canonical completed true, Side query, release guard를 기존 regression으로 검증했다. Recipient는 live Query의 fallback이나 rebind source가 아니다. historical IDs가 있다고 StoryFlag/Save query를 구현한 것은 아니다.

## 23. Step62~66.1 UI Regression

UI Scene/Theme/Shell/View 코드는 이번 Step에서 수정0이다. Step66/66.1의 기존 미커밋 UI 변경을 그대로 보호했다. Step64 Shell geometry/Modal/Drawer, Step65 pointer/keyboard/focus/scroll, Step66 navigation/Archive source return, Step66.1 R/A/N direct switch/drafts, Side exact resume 및 stale callback 검사를 수행했다. Native Utility Rail은 두 해상도에서 재검사했다.

새 복사본 regression의 이전 completed gap 기대(Side/mixed)는 typed history 포함 기대만 변경했다. controlled cursor fixture는 이전에 cursor만 건너뛰던 상태를 authored completed prefix와 일치하도록 구성하고 해당 기대 목록을 갱신했다. 원본 old tests/evidence는 변경0이다.

## 24. Regression Execution Summary

| 집계 | 결과 |
|---|---|
| 전체 Godot 실행(초기/반복/재현 포함) | 172 |
| 최종 distinct process slots | 88 |
| headless / native GPU slots | 80 / 8 |
| 최종 slot assertion calls(반복 query 포함) | 452494 |
| 독립 새 필수 scenario IDs | 12 |
| 독립 새 source/schema negative IDs | 96 |
| 별도 prepared scenario IDs | 3 |
| 전용 fixture checks: headless / 1920 / 1280 | 1617 / 1617 / 1617 |
| 별도 prepared/Case binding/phase checks | 103 |
| 새 actual authored journey 종류 / 환경별 실행 | 2(A/C) / 3환경 각2 |
| 최종 예상 warning / error | 21 / 0 |
| 새 Step68 warning / error | 0 / 0 |

assertion 호출 수는 독립 시나리오 수가 아니다. 전체 재실행 assertion 합산을 최종 slot 수에 섞지 않았다.

core slot은 fresh editor import1, 제품 GD check-only53, configured Main headless/native2다. 기존 regression은 Snapshot4, Ordering, Research gate, Ownership, Closure/Pending, Active, Cleanup, Campaign, Sequential/bounded, FactQueries, Side/guards, product journeys, keyboard, UI/extra/acceptance/navigation/utility다. terminal/Side/cleanup의 주요 경로는 Native도 재검사했다.

정상 최종 warning21은 controlled regression의 기존 missing-next/content ambiguity 및 Active diagnostics이며 marker/경계별 예상 개수와 대조했다(Closure13, Ordering4, Active headless/native 각각2). 새 Step68 fixture 및 prepared 검사는 warning0/error0이다. negative는 status/issue를 assert하며 예상 push_error를 성공 로그에 숨기지 않는다.

### 초기 실패 / 보존 / 해결

| 초기 기록 | 원인과 조치 | 최종 |
|---|---|---|
| 제한 환경 import/재현 certificate ERROR | 승인된 Godot 실행 환경에서 재검증; 원본 로그 유지 | 이후 certificate0 |
| Closure 초기 실패 | 빈 channel merge의 overwrite 미지정으로 Case response 미반영; merge overwrite=true. 빈 Scripted 경로의 추가 scope 판정은 legacy 호환 유지 | old output/Pending/Closure PASS |
| 새 fixture signature parse | _focus_scan 부모 실제 signature에 맞춤 | PASS |
| 새 negative fixture runtime/resource 오염 | private raw type 변조가 원본 getter에서 오류; 공개 getter controlled fixture로 테스트하고 Main invalid capture 후 Active 검사 차단. external payload copy를 명시해 authored Resource 공유 방지 | source/schema96 PASS |
| S02 reused definition 기대 | 이전 완료 occurrence까지 rows0로 기대한 QA 오류; 현재 ACTIVE occurrence의 row 부재로 수정 | S02 PASS |
| old mixed/Side gap / bounded 기대 | Step68 typed 행 기대와 controlled completed prefix 기대 갱신 | regression PASS |
| prepared fixture 실패/timeout | fingerprint key/type 및 QA phase 삽입 위치 오류 수정; raw failed logs 보존 | prepared103 calls PASS |
| Native1280 시간 초과 | log에 제품 오류 없음; 정확한 외부 원인은 확정하지 않음. 동일 최종 코드 단독 재실행 | full1617 calls PASS |

초기 실패를 최종 정상 횟수에 포함하지 않았다. `.godot/verification/step68/attempts/`에 원본 로그를 보존했다. timeout ledger 누락1개도 해당 raw attempt와 최종 metrics의 별도 목록에 남긴다. 검사 코드는 전부 ignored namespace에 있다.

## 25. Files / Main Impact

| 상태 | 파일 | 이유 |
|---|---|---|
| modified | scripts/main/main.gd | full source/scope capture, owner key, preflight/prepared/repeat integration, observation 연결 |
| modified | scripts/read_models/developer_run_disposition_builder.gd | pure raw classification, Scripted validation/projection, optional Campaign input |
| modified | scripts/runtime/run_disposition_state.gd | closed typed schema, Scripted key/consistency/duplicates |
| modified | scripts/read_models/test_sequence_disposition_snapshot.gd | additive copied Scripted observation field |
| modified | README.md | Step68 결과 append만 |
| created | docs/step68_scripted_historical_fact_preservation.md | 이 보고서 |
| created / ignored | .godot/verification/step68/ | baseline, fixtures, raw attempts, screenshots, audits/metrics |
| deleted | 없음 | 기존 파일 및 증거 삭제0 |

제품 수정은 지정된 네 파일만이다. Source owner API 변경/새 mutable ownership/새 UI flow는 없다. Main의 startup/render/player callback/Case handoff/response acknowledgement/cleanup 순서는 변경하지 않았다. 필요한 capture 및 terminal consistency만 추가했다. Git 전체 diff에는 기존 Step66/66.1 변경이 함께 있으므로 시작 SHA 기준 delta를 `.godot/verification/step68/delta_*.patch`로 따로 기록했다.

SHA-256 보호: baseline166개 중 네 제품 파일+README만 이번 Step 변화이며 나머지161개 동일. project.godot, 모든 Case/Campaign/TEMP Resources, Scene, Theme, original source State/Query/Data/UID 및 Step66/66.1/67 보고서가 포함된다. 기존 verification evidence63,477개 changed0/deleted0. README 시작 byte prefix도 그대로다. 보고서1개 추가 후 총167개다. 최종 `git diff --check` 통과; HEAD/branch/upstream/staged는 그대로이며 stage/commit/push/reset/checkout을 실행하지 않았다.

## 26. Existing OPEN

- Step53 prepared Pending P2: 기존 Forced ACTIVE의 separate prepare 요구를 유지한다.
- Step54 cross-State atomic rollback limitation: 정상 prepare 후 오류의 전 State rollback을 새로 구현하지 않았다.
- Step62 failed restore developer retry: 기존 explicit retry; 플레이어 자동 복구 추가0.
- Hypothesis getter P3: 기존 private key enumeration 경계를 이번 Step에서 바꾸지 않았다.

Completed Scripted terminal projection gap은 실제 typed recipient, 12개 시나리오, A/C authored journey, Side exact resume 및 cleanup/release 검증으로 해결했다. 위 OPEN을 해결했다고 주장하지 않는다.

## 27. Remaining Limitations

Recipient는 현재 process의 메모리 기록이다. Save/Load, Ending, Campaign 최종 완료 화면/API, StoryFlags, 경제/정산, 별도 HistoryManager를 추가하지 않았다. 마지막 entry가 Scripted뿐인 새로운 campaign-wide terminal boundary도 지원하지 않는다. 기존 마지막 actual CASE의 developer boundary가 필요하다.

보존한 것은 발생한 Scripted response의 positive approved ID facts다. 전체 authored text/version/발생 시각/host 완료/negative query proof를 저장하지 않는다. Scripted ACTIVE 강제 종료는 기존 unsupported guard 그대로다. terminal용 canonical sort를 actual Story chronology로 해석하지 않는다. Native timeout의 외부 원인은 확정하지 않았으나 같은 최종 코드로 두 해상도 전체 성공 결과를 확보했다.

## 28. Next Step Recommendation

새 종료 기록을 소비할 read-only 개발자 표시/검사 범위를 별도 정의하는 지점이 적합하다. 실제 Campaign completion/Ending, persisted Save 또는 live Story fact 조건 변경은 각자 계약을 먼저 정한 다음 별도 단계에서 구현한다. 현재 GameShell/Utility/Case workflow와 보존된 원본 State 계약을 출발점으로 삼는다.
