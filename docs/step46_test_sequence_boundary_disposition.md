# Step46 — Test Sequence Boundary Disposition Snapshot

2026-10-05 · Godot 4.7.1 Standard / GDScript / Windows PC / GL Compatibility.

**제품 상태를 변경하지 않고 현재 Test Sequence의 제출·판정·미처리 사건·진행 중 응답·연구 보존 현황을 관찰하는 개발용 계약을 구현했다.** `Main.build_test_sequence_disposition_snapshot()`은 `TestSequenceDispositionSnapshot`을 반환하며 `to_dictionary()`로 분리된 복사본을 읽는다. Snapshot은 closure/settlement/reset/result가 아니며 `TEST_SEQUENCE_END`는 `RUN_END`가 아니다. 기존 마지막 Case03의 Next 비활성화와 Pending 보존 정책을 유지한다.

## 작업 전 저장소 조사와 보호 범위

- HEAD `79955a1` — `Extend three-case prototype and document event pacing policies`.
- branch `master`, upstream `origin/main`; 작업 시작 Git status는 clean, staged 0이다.
- remote `https://github.com/rudgns15251-ctrl/ccc.git`.
- Step43~45는 직전 사용자 요청에 따라 이미 커밋·push되어 있다. 프롬프트의 ‘기존 미커밋 변경’ 대신 실제 커밋된 110개 파일을 baseline으로 보호했다.
- project.godot, 전체 실제 inventory, README, Step43/44/45 문서, Main/Scene, Case01/02/03, 7개 State, View와 Signal, interrupt context, handoff/hidden resolution, candidate/response completion, Archive merge, debug Monitoring, 기존 verification suite를 조사했다. 저장소 및 상위 경로에 적용할 AGENTS.md는 없었다.
- 시작 Scene15, GDScript39, Case3, Autoload0. Main1,563줄/84함수 → 1,616줄/85함수. 새 projection1파일126줄로 content 분류를 분리했다.
- 기존 Case01은 Room02가 TEST SUCCESS이고 Room01/03은 TEST FAILURE다. Case02는 Room01 SUCCESS/Room02 FAILURE다. Case03은 의도적으로 Outcome이 없다. 이름/번호가 같다는 이유로 Case 간 정답 매핑을 추정하지 않았다.
- 기존 UI1920×1080, 초기창1280×720, canvas_items/keep/resizable 기본값, renderer와 configured Main Scene을 유지한다. Scene/Resource/Data/View/7개 State는 수정하지 않는다.

110개 추적 파일과 이전 검증 소스4,265개의 SHA-256을 `.godot/verification/step46`에 기록했다. 기존 검증을 덮어쓰지 않고 Step44 검증 트리의 소스291개를 `regression44/`로 복사했다. 사본의 경로만 새 디렉터리로 연결하고, Step44 pacing 사본에는 최종 boundary에서 새 API를10회 반복 검사하는 overlay를 추가했다. 이전 Step의 결과를 새 실행 결과로 재사용하지 않는다. 현행 콘텐츠를 읽는 상속 기반4파일도 별도로 복사해 과거 Case02 호환 fixture와 분리했다.

## 역할과 호출 계약

```gdscript
# Explicit developer/test API. No player-facing View calls this.
var snapshot: TestSequenceDispositionSnapshot = main.build_test_sequence_disposition_snapshot()
var facts: Dictionary = snapshot.to_dictionary()
```

| 구성 | 책임 | 소유하지 않는 것 |
|---|---|---|
| Main API | 기존 session getter로 facts 복사, current/sequence/Runtime identity 판정, 실제 View/response stage 보강, 기존 unique lookup 승인 | Run 종료·Settlement·conversion·신규 opportunity |
| `scripts/read_models/test_sequence_disposition_snapshot.gd` | typed RefCounted, 순수 pending/candidate projection, completion 사실 구별, 입력/출력 deep copy | mutable Gameplay State, Resource/Node/Callable/RNG 참조 |
| 기존 7개 State | 계속 authoritative Gameplay/연구 기록을 소유 | Snapshot을 source of truth로 사용하지 않음 |

Main에는 public 함수1개53줄을 추가했다. 기존 함수를 재작성하거나 Manager를 추출하지 않았다. projector는 입력 복사본과 기존 `_find_failure_source_case`/`_unique_response_content`를 일시적으로 호출한다. 해당 Callable과 authored Resource를 결과 객체에 저장하지 않는다. 기존 getter가 이미 복사본을 반환하므로 State 변경이나 신규 getter가 필요하지 않았다.

Snapshot 내부 `_facts`는 constructor에서 `duplicate(true)`로 보관하고, `to_dictionary()`마다 다시 deep copy한다. 반환 Dictionary와 중첩 Array/Dictionary를 수정해도 Snapshot의 다음 읽기와 Gameplay State는 바뀌지 않는다. 내부 객체를 직접 편집하는 개발자가 있더라도 원본 State와 참조를 공유하지 않는다. `read-only`는 게임에 대한 관찰 계약이며 GDScript가 모든 private 변수 접근을 언어 차원에서 차단한다는 주장은 아니다.

API는 명시적 fixture 호출만 제공한다. Next/Confirm/handoff/normal View가 호출하지 않으며 UI 버튼·단축키·자동 closure·JSON Save 기능이 없다. 중간 Case/Active Response에 대한 통제 probe도 허용하되 아래 `boundary_status`로 실제 마지막 제출 경계와 구별한다.

## Top-level 계약

| Field | 의미 |
|---|---|
| `boundary_kind` | 항상 `TEST_SEQUENCE_END`; 실제 종료를 실행했다는 의미가 아님 |
| `boundary_valid` | session State가 초기화되어 있고 current Case/Runtime ID와 unique sequence의 현재 index Resource identity가 일치함 |
| `boundary_status` | `AT_TEST_SEQUENCE_END`: 마지막 configured Case가 Confirm되고 해당 Runtime Room과 Pending이 일치함; `NOT_AT_TEST_SEQUENCE_END`: 유효한 중간/미제출 관찰; `INVALID_BOUNDARY`: identity/sequence/초기화 불일치 |
| `current_case_id` | 실제 current ID; 다른 Case로 fallback하지 않음 |
| `current_case_status` | `RESEARCH_IN_PROGRESS`, `SUBMITTED_PENDING`, `RESOLVED`, `INVALID_CURRENT_CASE`; ‘연구 진행’은 업무 상태이며 Success/Failure 추론이 아님 |
| `runtime_instance_id` | 개발자 identity 검증용 primitive integer; Runtime 객체를 보관하지 않음 |
| `current_view_stage` | 실제 Main Stage 이름; View 전환을 일으키지 않음 |
| `pending_submissions` | State 순서의 case_id/confirmed_room_id와 참조 분류 |
| `resolutions` | 이미 기록된 case_id/room_id/result/incident_id 복사본; 개발자 정보이며 player UI에 연결하지 않음 |
| `unresolved_candidates` | 기존 후보 순서의 사실/phase/참조 분류. 실제 active 후보도 같은 identity의 ACTIVE_RESPONSE phase로 보존함 |
| `active_response` | 단일 진행 중 authoritative 응답과 표시 단계의 보강 정보, 없으면 `{}` |
| `completed_responses` | 실제 Status.COMPLETED 응답의 facts와 phase.COMPLETED; unresolved로 재구성하지 않음 |
| `archived_cases` | 실제 Archive case_id와 discovered_entry_count만. 숨겨진 authored 내용 전체를 복사하지 않음 |
| `hypotheses_by_case` | configured Case들과 current ID의 실제 메모 개수. 내용/평가를 재작성하지 않음 |
| `current_research_count`, `current_observed_source_count`, `current_hypothesis_count` | identity가 맞는 Runtime의 이미 발견/관찰/작성한 정보 개수 |

`boundary_valid`와 각 entry의 content validity는 별개다. 유효한 boundary에도 invalid Pending/Candidate가 있을 수 있고, invalid boundary에서도 다른 session facts를 안전하게 읽을 수 있다. 마지막 경계 판단은 Confirm/Pending identity를 읽으며 authored Outcome 유무로 마지막 Case를 Run End로 바꾸지 않는다. 후보가0개라는 것은 후보 없음이지 Run 성공이 아니다.

## Pending과 Resolution

| Classification | 기준 | 상태 변화 |
|---|---|---|
| `RESOLVABLE_PENDING` | unique source Case/Room/Outcome, defined SUCCESS/FAILURE; FAILURE라면 unique Incident; 기존 Resolution/Failure Candidate 충돌 없음 | resolve하지 않음 |
| `UNRESOLVED_SUBMISSION` | 실제 소유 Room이지만 matching Outcome이 없음. 현재 Case03의 의도된 정책 | Pending 유지, 판정/후보 생성 없음 |
| `INVALID_SUBMISSION_REFERENCE` | Case/Room unavailable·ambiguous, duplicate Outcome, undefined result, unavailable·ambiguous failure Incident, 이미 판정된 Pending/기존 failure 후보 충돌 | 삭제/대체/fallback 없음 |

`has_valid_outcome`는 authored lookup 검증 사실이다. existing-state 충돌이 있으면 true이면서 invalid classification일 수 있다. `reference_issue`로 원인을 구분한다. missing Outcome은 `MISSING_OUTCOME`이고 `has_valid_outcome=false`다. prospective 결과값은 Pending entry에 포함하지 않는다. 유효한 Outcome이 있다는 사실을 SUCCESS/FAILURE 판정 사실로 바꾸지 않는다.

이미 기록된 Resolution은 그대로 출력한다. Step45의 실제 final Run에서 valid Pending을 먼저 hidden-resolve하는 정책은 여기서 실행하지 않는다. `_try_resolve_current_pending`, RNG threshold 생성, State try_record, remove_pending을 호출하지 않는다. 중간 Case snapshot 뒤 기존 handoff는 그대로 hidden resolution을 수행한다.

## Candidate 단계와 completion

Candidate entry는 `source_case_id`, `incident_id`, `opportunity_threshold`, `opportunities_seen`, `disturbance_triggered`, `major_opportunity_count`, `major_trigger_threshold`, `major_incident_triggered`를 기존 State getter에서 복사한다. `major_ready`는 actual disturbance=true와 count≥threshold라는 진행 사실로 파생한다. 이미 시작한 응답에서도 count는 유지되므로 이 값만으로 대기 사건을 세지 않는다. `major_incident_triggered`와 phase.ACTIVE_RESPONSE가 실제 진행 중 응답을 구별한다. `created_order`는 기존 후보 목록의0-based 상대 순서다. 삭제된 과거 후보의 절대 생성 번호/시간을 새로 저장하지 않는다.

| Phase | 근거 |
|---|---|
| UNDISTURBED | disturbance_triggered=false; threshold에 도달했어도 실제 표시 전이면 그대로 |
| DISTURBED_NOT_READY | 실제 교란=true, major count<threshold |
| MAJOR_READY | 실제 교란=true, major count≥threshold, 아직 active 응답 없음 |
| ACTIVE_RESPONSE | authoritative active 응답이 동일 source/incident identity를 가짐 |
| COMPLETED | 실제 response Status.COMPLETED. 별도 completed_responses의 사실이며 unresolved obligation이 아님 |

`phase`는 진행 사실, `classification`은 참조 유효성을 구분한다. unique source Case/Incident와 matching FAILURE Resolution을 검증한다. invalid이면 `INVALID_UNRESOLVED_EVENT`와 `reference_issue`를 표시하고 기존 진행 count/flag를 보존한다. 다른 Case나 첫 Incident를 fallback으로 선택하지 않는다. 이미 major-triggered인데 active 응답이 없는 불일치도 표시한다. 이 좁은 참조 검사는 전체 Broadcast/Option/Result 그래프의 offline validator나 ‘현재 즉시 재생 가능한 이벤트’ 판정이 아니다.

후보 출력 순서는 State `_case_order`이며 정렬 정책을 바꾸지 않는다. `active_response`는 같은 identity 후보의 응답 상세이지 두 번째 obligation이 아니다. 결과를 집계할 소비자는 source_case_id+incident_id로 연결해야 한다. Snapshot은 obligation 총수/경제 책임을 계산하지 않는다.

현재 정상 completion은 IncidentResult의 Resume 승인에서 `try_complete` 후 `remove_completed_candidate`를 수행한다. Result 화면이 보였다는 이유로 이 경계를 앞당기지 않는다. 실제 완료 기록과 같은 identity의 stale Candidate가 있는 통제 입력도 unresolved로 다시 만들지 않는다. FAILURE Resolution을 보고 제거된 후보를 재생성하지 않는다.

## Active Response와 정보 공개

Active entry는 기존 `source_case_id`, `incident_id`, `broadcast_id`, `confirmed_option_id`, `incident_result_id`, `status`를 읽고 `response_stage`, `context_valid`, `incident_result_displayed`만 보강한다. 현재 View가 Source Archive면 기존 `_source_archive_return_stage`로 응답 복귀 단계를 표현하고 actual View는 top-level에 별도로 남긴다. local `broadcast_draft`는 권위 있는 선택에 포함하지 않는다.

| 통제 상태 | Snapshot 사실 | 하지 않는 동작 |
|---|---|---|
| INCIDENT | ACTIVE_RESPONSE, Option 없음 | Broadcast 자동 이동 |
| BROADCAST 임시 선택 | confirmed_option_id 빈 값, Result 미표시 | draft를 확정으로 승격 |
| BROADCAST Confirm 후 | 실제 Option/Result ID, Result 아직 미표시 | Next 자동 실행 |
| INCIDENT_RESULT 표시 / Resume 전 | active 유지, result_displayed=true, Candidate 유지 | response completion/removal |
| 위 Result의 Source Archive | current_view_stage=Archive, response_stage=Result, 실제 표시 사실 유지 | Back/Resume 자동 실행 |
| Resume 승인 이후 | completed_responses facts, source 후보 없음 | 완료 사건을 unresolved로 재생성 |

`incident_result_displayed`는 현재 유효 context/Result View 및 기존 Source Archive 복귀 문맥으로 알 수 있는 표시 사실이다. 새로운 영구 노출 이력이나 읽기 완료/렌더 프레임 판정을 만들지 않는다. content가 변경되어 참조가 invalid하면 true를 추정하지 않는다. Snapshot은 normal interrupt 응답을 관찰하고, 기존 debug Monitoring은 Runtime과 기존 View 경로를 그대로 사용한다.

새 Research discovery/Archive merge/메모 변경을 호출하지 않는다. 미발견 Incident/Broadcast/Option/Result authored ID는 자동 발견하거나 Archive에 넣지 않는다. Snapshot의 개발자 Resolution과 Candidate ID를 normal View/Research Log/Archive에 렌더링하지 않는다. Hypothesis는 count만 읽고 실제 문구를 종료 결과로 재작성하지 않는다.

## 최소 fixture와 회귀 계획

새 fixture는 `.godot/verification/step46/snapshot_validation.gd`, runner는 `run_snapshot.ps1`에 있다. verification-only JSON은 같은 ignored 디렉터리에 저장되며 제품 Save 기능이 아니다. 기존 사본 기반 전체 runner는 `run_regression.ps1`이다.

| 새 검사 그룹 | 범위 |
|---|---|
| normal | 실제 버튼 callback의 Case01 SUCCESS→Case02 SUCCESS→Case03 Confirm, 각 중간 단계/최종 Pending snapshot 후 계속 정상 진행, 마지막 Next/Log 유지 |
| phases | undisturbed/disturbed/ready, dual 다른 phase/기존 순서, 네 ordinary View에서 반복 관찰 |
| response | source Case01 active+Case02 unresolved, Incident/draft/confirmed/Result/Source Archive/Resume/완료+미처리 혼합, stale completed 입력 |
| invalid | foreign Room/Case, duplicate Room/Outcome/Incident, undefined result/unknown Incident, invalid 후보+valid 후보 공존, duplicate sequence/current identity mismatch |
| isolation | snapshot/기존 getter 복사본 수정, 과거 snapshot 이후 live State 진행의 독립성, Archive/세 Case Hypothesis/Runtime/State identity/RNG/keys, snapshot 이후 Experiment→교란 진행 |
| copied Step44 overlay |144개 실제 threshold/실험량 경로 마지막에 API10회씩. all-Success/Case01-only/Case02-only/dual와 끝에 남는 각 phase를 실제 기록과 비교 |

정상 probe마다10회 반복, invalid probe는 진단 warning 양을 제한하기 위해1회 추가 반복하며 다른 valid entry가 계속 출력되는지 검사한다. State getter 값/instance ID, current View identity, interrupt context, processed keys, RNG state/seed, Runtime 전체 관찰/이력, Archive IDs와 Hypothesis 내용이 호출 전후 동일해야 한다. 모든 결과에 Resource/Node/Callable 없는 primitive-only 검사를 적용한다.

## 실행 및 결과

Godot **4.7.1.stable.official.a13da4feb**에서 다음 최종 유효 실행기록 **305개**를 확인했다. 과거 Step44 로그를 새 실행으로 재사용하지 않았다. 준비 실행/실패한 fixture 실행/동일 fixture의 중간 재실행은 이 합계에서 제외한다.

| 검사 묶음 | 유효 실행 | 결과 |
|---|---:|---|
| 기존 Step39 및 과거 핵심 회귀 사본 | 200 | PASS; 제품40 GDScript check-only 포함 |
| Step40 사건 개입/복귀 사본 | 16 | PASS, headless/native 및 세 해상도 |
| Step42 read boundary/context/source Archive 사본 | 20 | PASS |
| Step43 3-Case/cross-case/debug 사본 | 32 | PASS |
| Step44 pacing/queue/visual 사본 + final Snapshot overlay | 24 | PASS; 실제144 matrix Journey 포함 |
| 신규 Snapshot fixture5그룹 ×2모드 | 10 | PASS;1,564 assertions,74 probes |
| editor import/configured Main headless/native | 3 | PASS, warning/error0 |

최종 suite 로그에 parser/GDScript/runtime 오류는 없다. 기존 invalid-data 회귀의 예상 warning1,320개와 신규 invalid Snapshot fixture의 예상 warning36개를 정확히 대조했다. 정상 경로/신규 valid fixture에는 warning이 없다. Snapshot은 primitive-only이며 Source 상태/instance identity/active key/Hypothesis ID counter/임시 선택·확정 잠금/RNG state·seed/opportunity keys가 반복 호출 후 동일하다. 출력 복사본 수정 및 이후 Gameplay 진행으로 과거 Snapshot과 원본 사이의 alias가 생기지 않았다.

**Step44 기준선 비교:** 동일144개 경로의 events/spacing/meaningful/eligible/broadcasts/archive, Runtime instance number를 제외한 전체 버튼 timeline, 마지막 candidates/keys/확정 Room/active response/notice/Stage/Case를 원본과 비교해 동일함을 확인했다. Major122회(CCTV36/Containment86), 끝에 후보가 남는82경로, 그중 major-ready17경로, strict meaningful 간격 최소0을 유지했다. 따라서 기존 pacing 문제를 해결했다고 주장하지 않는다.

실제 최종 Snapshot의 leftover entry94개는 UNDISTURBED37 / DISTURBED_NOT_READY40 / MAJOR_READY17이다. 이는82개의 경로에 분포한 후보 record 수이며82와 같은 단위가 아니다. active/completed/draft/confirmed/Result-display fixture는 별도로 검증했다. 마지막 Case03의 미판정 Pending은 모든 matrix에서 UNRESOLVED_SUBMISSION으로 유지되었고 Research/Archive의 자동 merge나 response 강제 발생이 없었다.

Scene/UI 변경은0이며 기존 GPU 회귀에서1920×1080,1280×720,1024×768 창을 재검증했다. Case03 Confirm/잠금/No next test case configured 화면의 세 해상도 캡처도 육안으로 확인했다. 새로운 UI 디자인이나 사람의 재미/피로 검증을 수행한 것은 아니다.

**보존 검사:** baseline110파일 중 허용한 Main/README 외108파일의 byte hash는 동일하다. Main에서 추가 함수만 제거하면 기존 코드 전체가 동일하고, README에서 Step46 block만 제거하면 기존 내용 전체가 동일하다. 이전 검증 소스4,265개 hash도 동일하다. 생성3파일/수정2파일/삭제0/staged0, HEAD79955a1 유지, git diff --check 및 신규 파일 whitespace PASS, 요청한138항목을 연속 대조했다. `final_integrity.json`과 `natural_dispositions.json`은 ignored verification 아래의 결과이며 제품 저장 기능이 아니다.

### 발견 문제와 해결

1. 최초 sandbox editor import에서 Windows root certificate store 접근 오류가 발생했다. 프로젝트 parse 오류와 구분하여 정상 권한 환경에서 다시 실행했고 최종 import/Main 로그는 오류가 없다.
2. 새 all-Success fixture의 첫 버전에서 Case01의 Room01을 성공으로 잘못 가정했다. 실제 Resource에서 Case01 SUCCESS=Room02를 재확인해 fixture를 수정했다. 제품 Outcome/Room/판정 코드는 변경하지 않았다.
3. 기존 suite 사본의 PNG 출력용 빈 폴더가 누락되어 native screenshot 저장이 실패했다. 새 사본 디렉터리에만 출력 폴더를 복원했다. 같은 Step46에서 이미 새로 통과한 실행은 input signature와 log hash가 일치할 때만 resume했고 실패 지점 이후를 완료했다.
4. 사본 재연결에서 Step43 상속이 과거 Case02 compat snapshot(Outcome 없음)을 가리켜 edge fixture의 preload 배열 파싱이 실패했다. 현행3Case용 기존 상속 기반4소스를 별도 current_base로 복사해 원래 그래프를 복원했다. 기존 검증 원본이나 제품 파일을 고치지 않았고 이후 Step43/44를 새로 실행해 통과했다.

남은 제품 오류는 재현되지 않았다. Source lookup의 missing/ambiguous warning은 invalid entry와 함께 계속 관찰 가능하며, 전체 content graph의 검증이나 실제 최종 Run 책임 이전을 보장하는 것은 아니다.

## 변경 범위와 남은 단계

제품 수정은 Main의 개발자 API1개이고, 새 read model과 Godot 생성 UID만 추가했다. README에 짧은 Step46 설명을 넣고 이 보고서를 추가한다. 기존 설정/Scene/3Case/State/View/Data/Step43~45 문서는 보존하며 파일을 삭제하지 않는다. 커밋·push하지 않는다.

F07-B는 **CONTRACT FOUNDATION IMPLEMENTED / PARTIALLY ADDRESSED**다. 실제 final Run disposition이 구현된 것이 아니므로 RESOLVED가 아니다. 실제 Run/Shift/Settlement/conversion/obligation persistence/Save/Load/Campaign/Quota/Economy/Rewards/독립 시설 사건/Severity/Case04/Case03 Outcome/final UI/Audio/Animation/Shader/Manager/Singleton/EventBus는 추가하지 않았다. threshold2~4/Major1, disturbance-first, RNG와 연구-credit/shared pacing gate 미구현 상태를 유지한다.

다음 단계는 이 계약을 소비할 **명시적 종료 책임 이전의 멱등성 계약**을 별도로 설계하는 것이 적합하다. 실제 Run identity·결과 수신자·종료 종류·실패 시 retry 소유권을 확정한 뒤 구현해야 한다. Case03 Next를 closure로 바꾸거나 Snapshot을 mutable obligation State로 사용하지 않는다. ordering/pacing/독립 시설 사건을 그 구현과 한 번에 묶지 않는다.

## 요청한 종료 보고 138개 항목

| # | 요청 항목 | 확인/구현 결과 |
|---|---|---|
| 1 | 작업 전 Git 상태 | 시작 clean, staged0, 미커밋 변경0. source110개 hash baseline. |
| 2 | HEAD / branch / upstream | HEAD79955a1 / master / origin/main, 직전 동기화 상태. 이번 작업에서 변경하지 않음. |
| 3 | Step43~45 기존 변경 | 직전 요청으로 이미 커밋된 Step43~45를 baseline으로 보존. 새 미커밋으로 오해하지 않음. |
| 4 | Step45 정책 재확인 | Case/같은 Run Shift carry, 최종 Run conversion/active 처리/valid Pending 우선 판정은 미래 정책. 이번 API는 관찰만 함. |
| 5 | Snapshot 이름 | TestSequenceDispositionSnapshot. |
| 6 | Snapshot 구현 위치 | scripts/read_models/test_sequence_disposition_snapshot.gd; Main은 public 조립 함수1개. |
| 7 | Snapshot type | class_name의 typed RefCounted; nested records는 Dictionary/Array와 stable ID·primitive. |
| 8 | Gameplay State 여부 | Gameplay State가 아닌 detached projection. |
| 9 | Snapshot Source of Truth 여부 | Source of Truth 아님. 기존7State/Main identity가 계속 authoritative. |
| 10 | boundary_kind | 상수 BOUNDARY_KIND=TEST_SEQUENCE_END. |
| 11 | TEST_SEQUENCE_END 표현 | 출력의 boundary_kind=TEST_SEQUENCE_END; boundary_status로 실제 last 제출과 중간/invalid probe 구분. |
| 12 | RUN_END와의 구분 | Run End/settlement/conversion/reset을 실행하지 않고 RUN_END 명칭을 사용하지 않음. |
| 13 | current_case_id | 실제 current_case.case_id; Case03에서 TEST_CASE_03. invalid 때 다른 Case로 fallback 없음. |
| 14 | Runtime identity | runtime_instance_id primitive 출력과 호출 전후 live get_instance_id 동일성 검사. |
| 15 | Pending entry 구조 | case_id/confirmed_room_id/has_valid_outcome/classification/reference_issue. |
| 16 | confirmed room | PendingContainmentState.get_pending_room_id의 확정 사실만 복사. |
| 17 | valid Outcome detection | 기존 unique helper로 source/Room/Outcome/defined enum/failure Incident를 조회. prospective result는 미포함. |
| 18 | resolvable Pending classification | RESOLVABLE_PENDING: 유효 authored Outcome, 충돌 없는 미판정 제출. normal 중간 Case에서 검증. |
| 19 | unresolved submission classification | UNRESOLVED_SUBMISSION: 소유 Room에 matching Outcome 없음. 의도된 Case03 Pending 유지. |
| 20 | invalid Pending classification | INVALID_SUBMISSION_REFERENCE; foreign/ambiguous Room·Case, duplicate Outcome, undefined result/invalid Incident 및 기존 판정/후보 충돌 구별. |
| 21 | Pending을 resolve하지 않음 | _try_resolve_current_pending/try_record_resolution/remove_pending을 Snapshot에서 호출하지 않음. |
| 22 | Resolution entry 구조 | 기존 case_id/room_id/result/incident_id의 get_resolution deep copy. |
| 23 | Hidden result normal UI 비노출 | 개발자 API에만 존재. normal View/Log/Archive/Scene에 연결 없음, hidden 결과 자동 노출 없음. |
| 24 | Candidate entry 구조 | 기존 Candidate getter 전체 primitive 사실과 created_order/major_ready/phase/classification/reference_issue. |
| 25 | source_case_id | get_candidate.source_case_id 그대로; current ID로 치환하지 않음. |
| 26 | incident_id | 실제 candidate.incident_id 그대로; first Incident fallback 없음. |
| 27 | created order | 기존 get_candidate_case_ids 순서의0-based 상대 index. 절대 시간/삭제된 과거 순서를 새로 만들지 않음. |
| 28 | disturbance progress | opportunities_seen와 opportunity_threshold 복사, 증가·RNG sampling 없음. |
| 29 | disturbance triggered | disturbance_triggered actual flag; threshold 도달만으로 발생했다고 하지 않음. |
| 30 | major progress | major_opportunity_count와 major_trigger_threshold 복사. |
| 31 | major ready | actual disturbance=true이며 count≥threshold로 파생. ready라고 자동 표시하지 않음. |
| 32 | major triggered | major_incident_triggered 복사. active 연결 불일치라면 invalid reference issue. |
| 33 | candidate phase enum/string | 문자열 UNDISTURBED/DISTURBED_NOT_READY/MAJOR_READY/ACTIVE_RESPONSE; 완료 response에는 COMPLETED. |
| 34 | undisturbed | 교란 미발생, ready disturbance도 아직 실제 표시 전이면 UNDISTURBED. |
| 35 | disturbed-not-ready | 교란 발생=true/major count<threshold. |
| 36 | major-ready | 교란 발생=true/major count≥threshold이고 동일 active Response 없음. |
| 37 | completed 처리 | 실제 Status.COMPLETED는 별도 completed_responses. 제거된 Candidate를 Resolution에서 복원하지 않음. |
| 38 | invalid candidate | INVALID_UNRESOLVED_EVENT와 구체적인 reference_issue; count/flag 보존, valid 동반 entry 계속 출력. |
| 39 | source unique lookup | Main의 기존 _find_failure_source_case/_unique_response_content Callable 재사용, missing/duplicate source는 null. |
| 40 | Resource instance 저장 여부 | 결과 전체 primitive-only 검사. Resource/Node/Callable/RNG를 Snapshot에 저장하지 않음. |
| 41 | Active Response entry | get_active_response 복사본에 response_stage/context_valid/incident_result_displayed 보강. 없으면 빈 Dictionary. |
| 42 | response source | authoritative source_case_id/incident_id, 후보와 동일 identity로 연결. 별도의 두 번째 obligation 아님. |
| 43 | broadcast identity | 기록된 broadcast_id 그대로. |
| 44 | confirmed Option | IncidentResponseState.confirmed_option_id만; local 선택은 권위 없음. |
| 45 | response stage | 실제 Main Stage, Source Archive에서는 기존 return stage를 사용하고 actual View는 별도 top-level. |
| 46 | local draft 제외 여부 | _interrupt_context.broadcast_draft 및 View의 임시 Option은 포함하지 않음. Archive 복귀 후 draft 유지 확인. |
| 47 | Response auto completion 없음 | Snapshot에서 try_confirm/try_complete/Next/Resume 실행 없음. |
| 48 | Candidate auto completion 없음 | Snapshot에서 remove_completed_candidate/try_mark_major_triggered/advance 실행 없음. |
| 49 | Research auto discovery 없음 | discover/observe helper 호출 없음. current 연구 count는 이미 기록한 getter만 읽음. |
| 50 | Archive auto merge 없음 | ResearchArchiveState.merge_case_discoveries 호출 없음. |
| 51 | 미발견 content 비공개 | 미발견 Incident/Broadcast/Option/Result Research를 해금하지 않음. actual discovery만 기존 gameplay에 남음. |
| 52 | Archive snapshot 범위 | actual archived Case IDs와 discovered authored ID count. 전체 authored 본문/미발견 ID 복제 없음. |
| 53 | Hypothesis snapshot 범위 | sequence/current Case별 count와 current_hypothesis_count; 메모 본문·ID·평가 재작성 없음. |
| 54 | Snapshot≠Archive | Snapshot을 Archive에 삽입하지 않음. |
| 55 | Snapshot≠Result | 새 Result/Settlement View를 만들지 않음. |
| 56 | Trigger 방식 | Main.build_test_sequence_disposition_snapshot() 명시적 개발용 API + ignored 자동 fixture. |
| 57 | 기존 Case03 Next 유지 | Case03 Confirm→Pending→No next test case configured/Next disabled 유지. |
| 58 | player-facing UI 변화 | Scene/View/버튼/텍스트/단축키 변경0. player-facing 연결 없음. |
| 59 | Snapshot idempotency | 동일 facts에서 detached Snapshot 출력 동일; valid probe10회 반복과144개 실제 경로로 검사. |
| 60 | RNG 불변 | RNG state/seed 및 다음 결과 clone 검사; Snapshot은 RNG 호출 없음. |
| 61 | Opportunity 불변 | Gameplay Opportunity 생성/advance 없음. Snapshot 후 원래 이벤트가 계속 진행됨. |
| 62 | processed keys 불변 | _processed_opportunities before/after 동일. key 생성/삭제/중복 소비 없음. |
| 63 | current View 불변 | current View instance/stage, notice/context/draft/선택/잠금 유지. 네 ordinary View 및 Response/Archive 검사. |
| 64 | Test Sequence representative | 실제 버튼 callback으로 Case01 SUCCESS→Case02 SUCCESS→Case03 Confirm, 중간/최종 snapshot 후 기존 진행 유지. |
| 65 | Case03 unresolved Pending | Case03 Pending1/Resolution 없음/classification.UNRESOLVED_SUBMISSION. |
| 66 | Case03 Outcome 없음 처리 | Case03 authored Outcome 없음 유지, FAILURE/Candidate/자동 resolution 생성 없음. |
| 67 | Case01/02 Resolution | Case01/02 기록된 Resolution2개를 그대로 읽음. player Runtime 판정이나 source를 치환하지 않음. |
| 68 | all Success snapshot | all-Success candidate0/active 없음/Case03미판정 제출. 후보 부재를 Run Success라고 하지 않음. |
| 69 | one Failure snapshot | 통제1후보 + 복사 Step44 실제 Case01-only/Case02-only Failure 경로. |
| 70 | dual Failure snapshot | 통제 서로 다른 phase2개 + 복사 Step44 dual Failure 경로. |
| 71 | undisturbed leftover | threshold 이전 leftover UNDISTURBED 보존. |
| 72 | disturbed leftover | 실제 disturbance fact 이후 count0 등의 leftover DISTURBED_NOT_READY 보존. |
| 73 | major-ready leftover | presentation이 남지 않은 ready Candidate를 MAJOR_READY로 표시, response 자동 생성 없음. |
| 74 | two Candidate created order | State 배열의 상대 생성 순서 Case01→Case02 확인; 정렬/우선순위 정책 변경 없음. |
| 75 | active Response fixture | 통제 Case01 real _try_start_major_incident + Case02 unresolved 동반. |
| 76 | Incident stage | Incident stage ACTIVE_RESPONSE/source/broadcast identity, Snapshot 반복 후 같은 View. |
| 77 | Broadcast unconfirmed | local draft 선택 후 authoritative confirmed_option_id 빈 값/Result 미표시 유지. |
| 78 | Broadcast confirmed | 실제 Confirm callback 후 Option/Result ID 복사, 아직 Result 미표시 구별. |
| 79 | IncidentResult 상태 | IncidentResult View/기존 Archive return 문맥의 표시 사실을 파생. 새 노출 이력 State 없음. |
| 80 | completion 직전 상태 | Resume 전 active/Candidate 유지, Resume 후 완료와 제거 사실만 반영. |
| 81 | future disposition hint 여부 | future_disposition_hint는 검토 후 추가하지 않음. 현재 관찰 classification과 미래 Run 정책을 혼동하지 않음. |
| 82 | conversion 실제 실행 없음 | CONVERT_ON_FINAL_RUN 등 실제 conversion/인계/책임 이전 실행0. |
| 83 | Obligation State 추가 여부 | RunObligationState/SettlementState 없음. |
| 84 | 새 Resource schema 여부 | 새 Resource schema/.tres/CaseData 변경 없음. |
| 85 | Save/Load 없음 | 제품 disk Save/Load 없음. fixture JSON만 ignored verification 디렉터리에 출력. |
| 86 | Run/Shift/Campaign 없음 | RunState/ShiftState/CampaignState 및 실제 종료 시스템 없음. |
| 87 | Economy 없음 | Quota/Score/CR/Rewards/Permanent currency 없음. |
| 88 | Scripted Event 없음 | 독립 시설 scripted source/Event 없음. Step45 Policy E는 미구현. |
| 89 | Severity 없음 | Severity enum/schema 없음. |
| 90 | content lookup 재사용 | 기존 Main unique source/content helper 재사용; 전체 ContentValidator framework 구현 없음. |
| 91 | helper 추출 여부 | 작은 순수 read-model/projector 분리. 기존 identity 검사와 authored lookup의 소유는 Main 유지. |
| 92 | Main line count | Main1,563→1,616줄, 증가53줄. |
| 93 | Main function count | 84→85함수, 개발용 public 함수1개. |
| 94 | Main 책임 변화 | 현재 facts 수집/identity 승인/응답 표시 문맥 projection만 추가. 실제 closure 책임 없음. |
| 95 | CandidateState 변경 | FailureEventCandidateState 파일/규칙/API 변경0. |
| 96 | IncidentResponseState 변경 | IncidentResponseState 파일/status/completion/API 변경0. |
| 97 | read-only getter | 기존 getter로 충분해 신규 State getter0. get_candidate/get_resolution/get_responses/get_archived IDs/get_hypotheses 재사용. |
| 98 | internal Dictionary mutation leak | 기존 getter deep/shallow copy가 primitive nested 구조를 분리함을 조사/fixture 확인. internal mutable Dictionary 반환 없음. |
| 99 | Snapshot mutation isolation | Snapshot 출력의 중첩 pending/candidate/active/resolution/archive/hypothesis 복사본 수정 후 원본/Snapshot 다음 읽기 동일. |
| 100 | hidden Research safety | Snapshot 분류 lookup은 discovery/merge를 호출하지 않으며 normal hidden 정보 비노출 유지. |
| 101 | Snapshot 후 gameplay progression | 중간 Snapshot 후 정상 hidden resolve/handoff/세 Case 진행과 last Log open/back 확인. |
| 102 | Snapshot 후 Event progression | Snapshot 후 CCTV/Experiment opportunity가 기존대로 소비되고 actual disturbance/Major/Response progression 유지. |
| 103 | repeated Snapshot 10회 | valid probe10회, 실제144 Journey 최종 각10회, State hash/Runtime/keys/RNG/Archive/Hypothesis 동일. |
| 104 | invalid source fixture | foreign source/unknown Incident/duplicate source Case와 valid 동반 후보 검사; 전체 Snapshot 계속 생성. |
| 105 | invalid Pending fixture | foreign Room/Case, duplicate Room/Outcome/Incident, undefined result/unknown Incident 검사. invalid classification만 출력. |
| 106 | invalid current Case | Runtime case_id mismatch/current Resource-index mismatch는 INVALID_BOUNDARY, 현재 사실에서 다른 Case fallback 없음. |
| 107 | duplicate sequence | 기존 _has_unique_case_sequence/_has_next_test_case guard 유지; snapshot boundary invalid 및 source ambiguity 표시. |
| 108 | Archive identity | actual archived IDs/contents 및 Archive State identity 동일. current Case를 자동 archive하지 않음. |
| 109 | Hypothesis identity | 세 Case 메모 내용/개수/State identity 동일, local 결과와 source/current 가설 혼합 없음. |
| 110 | Runtime identity | current Runtime instance identity와 전체 이력·관찰·확정값 동일. |
| 111 | Pending identity | Pending State identity/ordered records 동일; resolve/remove 없음. |
| 112 | Resolution identity | Resolution State identity/ordered records 동일; 새 result 기록 없음. |
| 113 | Candidate identity | Candidate State identity/ordered records/counters/flags 동일; remove/advance 없음. |
| 114 | Response identity | Response State identity/records/active key의 사실 동일; confirm/complete 없음. |
| 115 | RNG identity | RNG state/seed 동일, reading 때문에 다음 threshold/sample 변화 없음. |
| 116 | product parser | 제품40개 GDScript의 새 Godot4.7.1 check-only 검사. 최종 실행 절 참조. |
| 117 | editor import | 새 editor import 실행. sandbox CA 환경 오류 뒤 정상 환경에서 재검증. 최종 로그에 parse/import 오류 없음. |
| 118 | configured Main headless | configured Main headless 새 실행, 이전 로그 재사용 아님. |
| 119 | configured Main native | configured Main native GL Compatibility 새 실행. |
| 120 | full regression | Step39~44 기존 사본 정책의 전체 핵심 회귀 새 실행; 원본 검증 소스 보존. |
| 121 | 3-Case normal regression | Case01→Case02→Case03, Case02 Success/Failure, Archive/Hypothesis/같은 Runtime 복귀 유지. |
| 122 | Step42 regression | Experiment 결과 읽기 경계/context/source Archive draft/Room hidden leak 회귀 포함. |
| 123 | Step43 cross-case regression | 실제 cross-case Deferred/dual/Case02-only/last Pending/debug route 회귀 포함. |
| 124 | Step44 pacing baseline 불변 | 동일144개 조합의 event/timeline/count/spacing/leftover를 기존 Step44 원본과 비교. 최종 실행 절 참조. |
| 125 | threshold 불변 | disturbance2~4/Major1 상수 및 sampling 코드 변경0. |
| 126 | ordering 불변 | 현재 disturbance-first/FIFO/opportunity 코드 변경0. oldest actionable 미구현. |
| 127 | pacing gate 미구현 | research credit/shared pacing bool/새 acknowledgment 없음. |
| 128 | F07-B 현재 판정 | CONTRACT FOUNDATION IMPLEMENTED / PARTIALLY ADDRESSED. 실제 Run disposition 없음; RESOLVED 아님. |
| 129 | 실제 변경 파일 | README.md, scripts/main/main.gd만 기존 파일 수정. Main은 함수 추가로 제한. |
| 130 | 생성 파일 | read_models/test_sequence_disposition_snapshot.gd와 Godot.uid, docs/step46_test_sequence_boundary_disposition.md. fixture/로그는 ignored .godot 아래. |
| 131 | 삭제 파일 | 삭제0. |
| 132 | git diff --check | git diff --check 및 new-file whitespace 검사 결과는 최종 보존 검증 절 참조. |
| 133 | staged 여부 | staged0 유지. git add/commit 없음. |
| 134 | 기존 변경 보존 | Step43~45 커밋된 모든 baseline 중 Main/README 외 source/설정/Scene/Resource/이전 문서 hash 보존. |
| 135 | commit/push 없음 | commit/push/rebase/reset/rollback 없음; HEAD79955a1 유지. |
| 136 | 발견 문제 | sandbox CA 접근/fixture Case01 매핑/사본 PNG 출력 폴더/3Case 상속의 compat 오연결을 구분해 해결. 제품 규칙을 변경하지 않고 최종 검증 통과; 실행 절 참조. |
| 137 | 아직 미구현 기능 | 실제 Run End/Shift/Settlement/conversion persistence/경제/독립 사건/Severity/Case04/Case03 Outcome/pacing/ordering/final UI 등 미구현. |
| 138 | 다음 Step 추천 | Snapshot을 소비할 명시적 종료 책임 이전/멱등성 계약을 별도 단계에서 설계. 실제 Run identity와 결과 수신자부터 확정하며 Next/숨은 closure는 추가하지 않음. |
