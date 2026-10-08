# Step60 — Campaign-Scoped Typed Fact Query Foundation + Source Lifetime Guard

CAMPAIGN-SCOPED TYPED FACT QUERY FOUNDATION · READ-ONLY EXISTING OWNER QUERIES · NO CAMPAIGN HISTORY COPY · SOURCE LIFETIME / RELEASE GUARD · NO STORY CONTENT · NO ECONOMY / QUOTA / SETTLEMENT

## 1. Repo / baseline

작업 전 실제 파일 143개(생성 cache/Git 제외), 제품 GDScript 48개, Scene 15개, authored .tres 4개를 조사했다. 프로젝트는 Godot 4.7.1 / GDScript / Windows / Control UI이고, 1920×1080 viewport, 1280×720 기본 창, canvas_items stretch, GL Compatibility 설정이다. Autoload 없음. 제품 TEST_CAMPAIGN_01은 여전히 CASE 3개만 가진다. Main은 2239행/121함수였다.

HEAD `6e8f167f699a3a95c91fee8668ae99d03e5d4db9`, local branch `master`, upstream `origin/main`, staged 0. 기존 Step55~59 누적 변경: tracked 수정 7개와 untracked 16개. 이 작업을 깨끗한 저장소로 가정하지 않았다. 기존 Scene, Main, Views, Response, Snapshot, Builder, Campaign typed definitions 및 Step59 문서를 보존했다.

기존 owner의 public API, Main의 ready/dispatch/handoff/Scripted ack/verified cleanup, Step54 reset 순서, Step58 mixed/repeated fixtures, read_models/UID 관례를 조사했다. `baseline.json`, `before/`, `prior-evidence-hashes.json`이 작업 전 증거다. Git HEAD와 이번 단계 baseline의 diff는 서로 다르므로 둘을 별도로 기록한다.

## 2. Implemented Query Architecture

`scripts/read_models/campaign_fact_queries.gd`의 `CampaignFactQueries extends RefCounted` 하나가 기존 owner를 읽는다. State/Manager/Node/Resource/Autoload가 아니다. 사실을 누적하는 Dictionary, 새 mutable history, global registry, Condition interpreter가 없다. Query body는 Main의 private resolver를 호출하지 않는다. `CampaignData.get_entry()`와 owner의 public read API를 사용한다.

```text
CampaignData + existing session owners
                 ↓ public reads
CampaignFactQueries (one Campaign binding)
                 ↓ primitive detached values
BooleanFactQuery / IdentifierFactQuery / CaseResolutionQuery
```

```gdscript
var facts: CampaignFactQueries = get_campaign_fact_queries()
var answer = facts.was_entry_completed("TEST_ENTRY_CASE_01")
if answer.availability == CampaignFactQueries.Availability.KNOWN:
    print(answer.value)
```

소비자는 반드시 availability를 먼저 확인한다. UNKNOWN의 false/빈 String/UNDEFINED는 유효 fact가 아니다. 반환 object는 해당 조회 시점의 값이며 이후 query authority나 자동 갱신 snapshot이 아니다.

## 3. Source Binding / Lifetime

Constructor가 actual CampaignData와 Campaign ID, Progress, Resolution, Pending, Response, Archive를 한 번 받는다. Progress에 기존 ID getter가 없어서 `get_campaign_id() -> String` 하나만 추가했다. Campaign ID와 Progress ID를 대조하고 실제 bound Resource의 validation/entry lookup을 수행한다. configure/rebind/reset API 없음. release 후에도 새 session으로 revive하지 않는다.

Candidate와 Hypothesis는 bind하지 않는다. setter/clear/release는 Main lifecycle 전용 관례이며 GDScript의 underscore/private 관례는 보안 sandbox가 아니다. trusted caller가 source를 임의로 교체하는 일반 framework는 없다.

## 4. Availability / Unknown Semantics

| Availability | 실제 예 | 사용 의미 |
|---|---|---|
| KNOWN | valid incomplete entry → false; 실제 Resolution → SUCCESS/FAILURE | live valid owner가 값을 확정 |
| UNKNOWN | NOT_RESOLVED, SUBMITTED_UNRESOLVED, MISSING_OUTCOME, NOT_CONFIRMED | false/실패로 해석 금지 |
| INVALID | INVALID_ENTRY_ID, INVALID_QUERY_SCOPE, INVALID_INCIDENT_ID, CAMPAIGN_SCOPE_MISMATCH, SOURCE_CONFLICT | ID/scope/source/content 검증 실패 |
| UNSUPPORTED | SCRIPTED_RESEARCH_UNSUPPORTED | 현재 지원하지 않는 provenance |
| SOURCE_RELEASED | cleanup 시작 이후 모든 API | 빈 owner를 미발생 fact로 오해 금지 |

stable String reason IDs를 반환한다. Product warning/error는 invalid query에 출력하지 않는다. availability는 typed enum, phase는 실제 사용하는 String IDs다.

## 5. Result Value Types

세 개의 작은 nested RefCounted value class를 같은 파일에 둔다. 상속 framework/Base/Generic/Interface는 없다. Boolean/String/기존 `MonitoringOutcomeData.Result` value를 각각 갖는다. 공통 필드: availability, reason, campaign_id, entry_id, definition_id, phase, subject_id. subject_id는 Incident/Research query의 입력 ID다. constructor는 primitive 필드만 복사한다. Node/Resource/Callable/Signal/owner Dictionary를 저장하지 않는다. Resolution enum을 중복 정의하지 않았다.

| 실제 phase | 의미 |
|---|---|
| NOT_COMPLETED / COMPLETED | Progress 완료 membership 또는 Response 정상 완료 |
| SUBMITTED / RESOLVED | canonical Pending Room / canonical Resolution Room |
| NOT_STARTED / ACTIVE / ACTIVE_CONFIRMED | Response 없음 / 미확정 ACTIVE / 승인 링크가 있는 ACTIVE |
| DISCOVERED / NOT_DISCOVERED | actual Research membership |
| 빈 phase | source/scope 오류 또는 아직 submission 없는 값 |

## 6. Entry Completion Query

`was_entry_completed(entry_id)`는 Campaign에 존재하는 entry인지 확인한 뒤 `Progress.get_completed_entry_ids().has(entry_id)`만 읽는다. cursor가 앞서거나 Case ordinal이 낮다는 이유로 완료를 추정하지 않는다. CASE/Scripted 모두 같은 API다. 정상 UI handoff/Result ack 전후 false→true를 검증했다. cursor만 옮긴 controlled fixture에서도 false였다.

## 7. Case Resolution Query

`get_case_resolution(entry_id)`는 CASE entry→Case definition ID→Resolution getter로 조회한다. 실제 record만 SUCCESS/FAILURE authority다. Room/Case/Result/Failure incident 링크도 검사한다. authored Outcome은 판정 계산에 사용하지 않는다. Pending의 Room에 Outcome 정의가 있는지 여부만 UNKNOWN의 MISSING_OUTCOME 이유를 구분하는 데 읽는다. Pending이면 SUBMITTED_UNRESOLVED, Outcome 없는 Case03이면 MISSING_OUTCOME, 그 외 NOT_RESOLVED다. Candidate 부재나 entry completion으로 결과를 추정하지 않는다.

## 8. Case Room Query

`get_case_room(entry_id)`는 실제 Resolution Room을 RESOLVED로, valid Pending Room을 SUBMITTED로 반환한다. View draft는 읽지 않는다. current Runtime이 있을 때 confirmed getter와 agreement를 검사한다. Pending/Resolution/Runtime의 Room 충돌은 INVALID/SOURCE_CONFLICT다. Room 정의의 중복/없는 링크도 INVALID. canonical submission이 없으면 UNKNOWN/NOT_SUBMITTED다.

## 9. Response Completion Query

`was_response_completed(entry_id, incident_id)`는 authored entry kind에서 origin을 결정한다. CASE 또는 CAMPAIGN_ENTRY + source_entry_id + incident_id tuple로 public `get_responses()`의 detached record를 찾는다. record의 source_definition_id가 지정한 과거 entry의 case_id/event_id와 일치해야 한다. Main의 current-entry 전용 `_bound_scripted_entry()`는 사용하지 않는다. valid incident scope에서 record 없음은 KNOWN(false)/NOT_STARTED, ACTIVE는 false, 실제 COMPLETED는 true다. Candidate readiness는 읽지 않는다.

## 10. Option / Result Query

`get_confirmed_option()`과 `get_incident_result()`는 실제 State의 승인 ID를 조회한다. Incident→Broadcast→Option→Result content scope를 검증하고 일치하지 않으면 INVALID다. record 없음은 UNKNOWN/NOT_STARTED, View draft/미확정 ACTIVE는 UNKNOWN/NOT_CONFIRMED다. ACTIVE confirmed는 KNOWN/ACTIVE_CONFIRMED, 실제 정상 ack 이후에는 KNOWN/COMPLETED다. approved Result ID는 Result 화면을 읽었다는 뜻이나 Response 완료 판정이 아니다. 향후 Story 소비자는 COMPLETED가 필요한지 별도 계약으로 결정해야 한다. Condition evaluator는 구현하지 않았다.

## 11. Research Discovery Query

`was_entry_research_discovered(case_entry_id, research_entry_id)`는 CaseData의 실제 authored Research ID를 확인한다. 현재 CASE는 verified current Runtime OR Archive read-only union, 다른 CASE는 Archive membership을 읽는다. merge/discover/observe를 호출하지 않는다. valid undiscovered는 KNOWN(false), 없는 ID는 INVALID, Scripted non-Case provenance는 UNSUPPORTED다. case_id compatibility API와 past Experiment API는 필요하지 않아 추가하지 않았다.

정상 `_handoff_to_next_case()`는 resolve 성공 후 `_merge_current_case_discoveries()`를 수행하고 그 다음 Progress advance/dispatch를 호출한다. 실제 fixture에서 Profile discovery는 handoff 전 Runtime에만 있고, handoff 후에는 Archive에서 참으로 조회됐다. 정상 handoff의 history-loss seam은 발견하지 않았다. 잘못된 discovery ID는 기존 Main이 filter/reject하며 query도 authored ID를 요구한다. private dispatch 강제 호출이나 외부 owner reset으로 정상 lifecycle을 우회하는 동작은 지원 계약이 아니며 history 복구 API를 추가하지 않았다. current Runtime context가 없으면 UNKNOWN/CURRENT_RUNTIME_UNAVAILABLE, 잘못된 binding은 INVALID/INVALID_RUNTIME_CONTEXT다.

## 12. Current Runtime Context

Main dispatch 시작에서 old Runtime context를 clear한다. CASE가 시작되면 entry/definition/Runtime을 검증해 set하고 PROFILE을 표시한다. Scripted/sequence-end에는 null context다. 실제 A→Scripted→B에서 A→null→B와 weakref A 소멸을 확인했다. adapter 안에 retired Runtime/history array는 없다. pending/historical Case 조회는 session owner에서 수행한다.

## 13. Source Release / Cleanup

Verified cleanup의 recipient/receipt/category/State identity/View parent preflight가 모두 성공한 다음, View detach와 첫 owner reset보다 먼저 `release_sources()`를 호출한다. 모든 owner/Resource/Runtime 참조를 null로 지우고 released만 유지한다. 후속 query는 ID가 잘못돼도 SOURCE_RELEASED가 우선한다.

preflight failure는 release0, COMMITTED_FROZEN은 cleanup 전 live read 가능. 첫 Pending reset에 query를 삽입한 controlled fixture에서 이미 SOURCE_RELEASED였다. reset 일부 실패 후에도 released를 유지하고 verified retry/ALREADY_CLEANED가 동작한다. Main `_exit_tree()`도 release한다. 외부 adapter reference가 남은 Main free 후 동일 guard를 검증했다. cleanup 자체의 기존 atomicity 한계는 해결하지 않았다.

## 14. Read-only Mutation Audit

`fact_validation.gd`는 Progress ID/current/completed/intent, Pending Room records, Resolution records, Candidate thresholds/counters, Response records, Archive, Hypothesis와 ID counters, Runtime execution/observation/Room/Research/environment, current Case/Stage/View, RNG seed/state/object, pacing credit, Research tokens, opportunity keys, source context와 authored property tree를 전후 비교한다.

1/10/100회 반복과 역순 query를 검증한다. 반환 availability/reason/metadata/value를 모두 변경해도 owner 변화0, 같은 live source의 결과 의미 동일. Native와 headless 동일 suite가 통과했다. 검사 횟수는 반복/필드 assert를 포함한 수치이며 독립 시나리오 수를 의미하지 않는다.

## 15. Repeated Event Identity

같은 Event Resource를 ENTRY_EVENT_A/B occurrence로 두 번 사용해 실제 UI에서 Option0/Result0와 Option1/Result1을 선택했다. 과거 entry와 현재 entry query가 각각 다른 값을 유지한다. CASE와 Scripted가 동일 incident_id 문자열을 사용한 controlled fixture에서도 origin/entry tuple로 충돌0. event_id-only lookup/Global registry 없음. repeated Case는 기존 CampaignData validation이 계속 거절한다.

| Identity | 역할 |
|---|---|
| campaign_id | adapter session scope / Progress 소유 범위 |
| entry_id | authored occurrence lookup, completion/response/research input |
| case_id | CASE definition + 기존 Resolution/Pending/Archive owner key |
| event_id | Scripted definition ID; occurrence key를 대체하지 않음 |
| incident_id | origin+entry 내 Response key와 content lookup |
| option_id | 승인 Broadcast option; 해당 Broadcast scope 검사 |
| result_id | 승인 Option link와 Result content 검사 |
| research_entry_id | CASE scoped authored Research membership |

## 16. Invalid / Cross-Scope Cases

foreign entry, wrong kind, invalid Incident/Research, 다른 Campaign ID owner binding, 같은 entry 문자열의 별도 Campaign/owner, wrong Response definition, broken approved link, Room conflict, missing/mismatched Runtime, released reuse를 검증했다. 직접 재bind API 없음. invalid Campaign startup 13종과 invalid Scripted bundle 17종에서는 adapter getter가 null이고 부분 bind도 없었다. invalid query는 availability/reason만 반환하고 source를 수정하지 않는다.

## 17. Regression

fresh Godot `4.7.1.stable.official.a13da4feb` 사용. editor import1, product GD check-only49, configured Main headless/native2. Step46 Snapshot4 groups, Step47 ordering, Step48 gate, Step51 ownership, Step52 closure+actual journeys, Step53 active termination, Step54 cleanup, Step55/57 typed Campaign routing/invalid startup, Step58 mixed/repeated/bounded/invalid Scripted regression을 새 namespace에서 실행했다. 실제 정상 Case Failure→Disturbance→Major→Incident→Broadcast→Result→Resume journey에 새 query 검증도 결합했다. Source Archive roundtrip과 stale callbacks/once guards도 유지됐다.

최종 통과 데이터셋: **73 processes / 832118 assertion 호출**, normal warnings0, expected controlled warnings19(ordering4/closure13/active2), expected startup developer diagnostics30(13+17), 최종 runtime/script/parse errors0. 여기에 포함된 새 query suite는 headless/native 각각411594 assertions다. GPU 1280×720 mixed Incident/Broadcast draft/Result/next PROFILE와 bounded 화면을 새로 capture했고 대표 Incident와 PROFILE 이미지를 시각 확인했다. UI 변경0이므로 3해상도 전체 반복은 하지 않았다.

실제 실행 시도는78회(77통과/1fixture 실패); 73은 최신 고유 성공 로그의 집계다. initial fixture가 Incident 없는 Case03에 index0을 사용해 Out-of-bounds 오류를 냈다. 제품 오류가 아니며 fixture를 empty-array-aware로 고친 뒤 headless/native 재실행했다. 최초 로그는 `attempt1-*`로 보존했다. 새 namespace before/ snapshot 복제 충돌도 저장된 baseline SHA256과 일치하는 원본을 복원한 후 Step60-only diff를 다시 만들었다.

## 18. Files / Main Impact

이번 단계 생성: `scripts/read_models/campaign_fact_queries.gd`(338행), 해당 `.gd.uid`, 이 report. 수정: `scripts/main/main.gd`(+14행/+2함수;2253행/123함수), `scripts/runtime/campaign_progress_state.gd`(+4행/get_campaign_id), README append. Main의 신규 함수는 public adapter getter와 exit-tree release이고 query logic은 없다. 기존 진행/cleanup 판정 로직을 재작성하지 않았다.

project.godot/Scene/View/.tres/CampaignData/EntryData/ScriptedIncidentData/IncidentSource/Response/Resolution/Pending/Archive/Runtime/Snapshot/Builder 변경0 (이번 단계 baseline 대비). 기존 파일 삭제0. 새 검증물은 ignored `.godot/verification/step60/`에만 있다. 이전 모든 verification 파일 55000개의 hash를 별도로 검증한다. Git diff는 이전 단계 누적 변경을 포함하며 Step60-only `.diff`를 함께 저장했다.

## 19. Known Gaps

새 P0/P1 없음. 기존 Step53 P2 `ACTIVE_FORCE_REQUIRES_PREPARED_PENDING`, Step54 다중 owner reset atomic rollback 미보장, Hypothesis 일부 private enumeration P3는 유지한다. ACTIVE Scripted terminal은 `UNSUPPORTED_ACTIVE_CAMPAIGN_RESPONSE` 그대로다. completed Scripted는 query에서는 조회 가능하지만 기존 Case-only final recipient projection에는 계속 누락된다. 이 query layer가 terminal gap을 해결했다는 주장은 하지 않는다.

Campaign final/Ending/actual Story Condition/Mandatory/Final Incident/Save/HistoryState/StoryFlagState/past Experiment history/repeated Case/economy/quota/settlement 추가0. Source lifetime 종료 뒤 query는 역사 보관함이 아니므로 SOURCE_RELEASED다. 향후 lifetime 이후 보존된 fact가 필요하면 기존 recipient contract를 별도로 확정해야 한다.

## 20. Next Step Recommendation

후속 consumer는 Main private field나 복제 History Dictionary 대신 이 query surface에서 actual fact를 읽을 수 있다. 미확정과 live false, released source를 구분한다. 다음 단계 선택은 자료/목표 검토 후 해야 한다: A 첫 authored Story condition, B completed Scripted terminal projection gap, C 실제 Mandatory Incident 자료 기반 콘텐츠. 현재 자료 없이 하나를 자동 구현하지 않는다. 실제 Story/Ending 조건, required completed phase, UNKNOWN/INVALID/release 처리, occurrence identity, 소비 시점과 terminal lifetime 자료가 있어야 한다.

## 종료 보고 — 요청된 193개 항목

1. **작업 전 Git 상태** — tracked 수정7/untracked16/staged0. Step55~59 누적 미커밋 변경 상태.

2. **HEAD** — 6e8f167f699a3a95c91fee8668ae99d03e5d4db9; HEAD 유지.

3. **branch/upstream** — master / origin/main. branch/upstream 유지.

4. **기존 변경 보호** — 기존 baseline SHA256, README prefix, verification55000 hash로 보호. 최소 Main/Progress 추가 외 원본 동일.

5. **Main before lines/functions** — 2239행/121함수, 실제 조사 기준.

6. **query adapter 이름** — CampaignFactQueries.

7. **query adapter path** — scripts/read_models/campaign_fact_queries.gd.

8. **base type** — RefCounted; Node/Resource/Autoload 아님.

9. **State 여부** — State 아님. historical truth 누적/소유0.

10. **Manager 여부** — Manager 아님. public owner read model.

11. **mutable history 여부** — mutable history/cache0. local query-time projection만 있음.

12. **Campaign bind** — Constructor가 actual CampaignData와 session owners를 한 번 받음.

13. **campaign_id** — bound campaign_id와 Progress.get_campaign_id 대조.

14. **bound CampaignData** — 실제 bound Resource validation/get_entry 사용. global registry0.

15. **bound Progress** — Progress public current/completed/Campaign-ID getter 사용.

16. **bound Resolution** — Resolution public detached get_resolution 사용.

17. **bound Pending** — Pending public has_pending/get_pending_room_id 사용.

18. **bound Response** — Response public detached get_responses 사용.

19. **bound Archive** — Archive public has_discovered_entry 사용.

20. **current Runtime binding** — 현재 entry/definition 일치 Runtime 하나만 bind.

21. **Candidate binding 여부** — Candidate binding0; readiness는 historical truth가 아님.

22. **Hypothesis binding 여부** — Hypothesis binding0; editable notes는 canonical fact 대상 아님.

23. **initial bind timing** — 전체 Campaign validation/Progress.configure/owner 생성 이후 첫 dispatch 이전.

24. **rebind policy** — constructor-only, configure/rebind/reset0. release 후 revive 불가.

25. **runtime context update** — CASE dispatch 생성 직후 set; old context는 dispatch 시작에서 clear.

26. **Scripted context** — Scripted/sequence-end context=null.

27. **old Runtime retention** — retired Runtime A weakref 소멸, 과거 Research는 Archive 조회.

28. **release method** — release_sources: released=true, 모든 owner/Resource/Runtime refs=null.

29. **cleanup release timing** — verified 전체 preflight 성공 후, View detach/첫 Pending reset 전에 release.

30. **preflight failure behavior** — preflight reject는 release0; live query 유지.

31. **partial cleanup behavior** — partial reset 실패에도 released 유지, 자동복구0, explicit cleanup retry 가능.

32. **CLEANED_NO_RUN behavior** — 모든 query SOURCE_RELEASED; 빈 State를 false로 읽지 않음.

33. **availability enum/representation** — Availability enum KNOWN/UNKNOWN/INVALID/UNSUPPORTED/SOURCE_RELEASED.

34. **KNOWN 의미** — 검증된 live owner가 실제 값을 확정할 수 있음.

35. **KNOWN false 의미** — valid live membership의 실제 미발생만 KNOWN(false).

36. **UNKNOWN 의미** — 미제출/미판정/미승인 또는 current Runtime unavailable; false 아님.

37. **INVALID 의미** — entry/kind/Campaign/definition/content/source agreement 오류.

38. **UNSUPPORTED 의미** — 현재 지원하지 않는 Scripted Research provenance.

39. **SOURCE_RELEASED 의미** — verified cleanup 시작 또는 Main 종료로 query source authority 해제.

40. **stable reason** — stable reason String IDs: KNOWN/NOT_RESOLVED/MISSING_OUTCOME/SOURCE_CONFLICT 등.

41. **result value types** — nested BooleanFactQuery/IdentifierFactQuery/CaseResolutionQuery3개, framework0.

42. **detached copy** — primitive 필드만 복사. 결과 변경 테스트의 owner/RNG/authored 변화0.

43. **result Resource refs 여부** — 반환 result Resource refs0; adapter의 Resource ref는 release에서 해제.

44. **Node/Callable 여부** — 반환 Node/Callable/Signal refs0.

45. **common metadata** — availability/reason/campaign_id/entry_id/definition_id/phase/subject_id/value.

46. **was_entry_completed** — was_entry_completed(entry_id), 실제 Progress 완료 membership.

47. **valid incomplete entry** — valid incomplete→KNOWN(false)/NOT_COMPLETED.

48. **completed entry** — accepted handoff/normal Scripted ack→KNOWN(true)/COMPLETED.

49. **cursor inference 여부** — cursor inference0. cursor만 앞당긴 fixture도 미완료 false.

50. **get_case_resolution** — get_case_resolution: CASE→CaseID→canonical Resolution.

51. **SUCCESS** — actual SUCCESS record만 KNOWN SUCCESS/RESOLVED.

52. **FAILURE** — actual FAILURE record만 KNOWN FAILURE/RESOLVED; incident link 검증.

53. **unresolved** — record 없음→UNKNOWN/NOT_RESOLVED, 성공/실패 추정0.

54. **Pending** — valid Pending→UNKNOWN/SUBMITTED_UNRESOLVED/SUBMITTED.

55. **Case03 missing Outcome** — Case03 submitted Room known, 판정 UNKNOWN/MISSING_OUTCOME/UNDEFINED.

56. **authored Outcome inference 여부** — Outcome 판정 실행0. 정의 존재 여부는 UNKNOWN reason 구분만.

57. **Candidate inference 여부** — Candidate inference0, owner binding 자체 없음.

58. **Progress inference 여부** — Progress completion으로 Resolution 추정0; 독립 owner 읽기.

59. **get_case_room** — get_case_room, canonical Pending/Resolution Room과 phase.

60. **resolved Room** — actual Resolution Room→KNOWN/RESOLVED.

61. **submitted Room** — valid Pending Room→KNOWN/SUBMITTED.

62. **current Runtime agreement** — 현재 Runtime confirmed getter와 Pending/Resolution agreement 검사.

63. **unconfirmed draft** — View draft 읽기0. canonical submission 없음→UNKNOWN/NOT_SUBMITTED.

64. **source conflict** — 불일치→INVALID/SOURCE_CONFLICT. 조용한 source 선택0.

65. **was_response_completed** — was_response_completed(entry_id,incident_id), CASE/Scripted 공통.

66. **CASE origin** — CASE entry→IncidentSource.OriginKind.CASE.

67. **SCRIPTED origin** — SCRIPTED_INCIDENT entry→CAMPAIGN_ENTRY.

68. **response tuple** — origin_kind+source_entry_id+incident_id tuple. definition ID 별도 일치검증.

69. **definition validation** — 지정된 과거 Campaign entry의 case_id/event_id와 Response definition 일치 필수.

70. **not-started response** — valid scope/no record→KNOWN(false)/NOT_STARTED.

71. **active response** — ACTIVE 및 ACTIVE_CONFIRMED completion은 false.

72. **completed response** — actual COMPLETED만 true. Result 표시/승인만으로 완료 추정0.

73. **invalid incident** — invalid Incident→INVALID/INVALID_INCIDENT_ID.

74. **get_confirmed_option** — get_confirmed_option, 실제 State 승인 ID와 Broadcast Option 검사.

75. **draft Option** — View draft→UNKNOWN/NOT_CONFIRMED, 승인 추정0.

76. **confirmed Option** — 승인 ID→KNOWN, ACTIVE_CONFIRMED 또는 COMPLETED.

77. **content link validation** — Incident→Broadcast→Option→Result scope/link 검증; mismatch INVALID.

78. **get_incident_result** — get_incident_result, actual approved incident_result_id.

79. **active confirmed Result** — approved ACTIVE result→KNOWN/ACTIVE_CONFIRMED; completion false.

80. **completed Result** — normal ack 이후 result→KNOWN/COMPLETED.

81. **result display 의미** — approved ID는 실제 읽음/완료가 아님. 후속 소비자는 phase contract 필요.

82. **was_entry_research_discovered** — was_entry_research_discovered(case_entry_id,research_entry_id).

83. **CASE validation** — CASE 입력 검증, Scripted non-Case provenance UNSUPPORTED.

84. **research definition validation** — CaseData.research_entries의 actual unique authored ID 요구.

85. **past Archive query** — 현재 아닌 CASE는 canonical Archive membership 조회.

86. **current Runtime union** — current Runtime OR Archive read-only union; merge0.

87. **valid undiscovered** — valid undiscovered→KNOWN(false)/NOT_DISCOVERED. current source 없음은 UNKNOWN.

88. **invalid Research** — INVALID_RESEARCH_ID, 없는 ID를 false로 위장0.

89. **Scripted Research** — UNSUPPORTED/SCRIPTED_RESEARCH_UNSUPPORTED, fake Case provenance0.

90. **compatibility case_id API** — case_id compatibility API 필요 없어 추가0; occurrence API 우선.

91. **repeated Case** — duplicate case_id validation 유지; repeated Case 지원0.

92. **repeated Event** — distinct entry_id 반복 Event 조회 지원.

93. **same Event definition** — 같은 Event Resource2회 actual UI Option0/Result0 vs Option1/Result1 조회 분리.

94. **cross-origin same incident** — CASE/Scripted 동일 incident 문자열도 origin/entry로 별도 fact.

95. **past Experiment API** — past Experiment API 자체 추가0; history capture0.

96. **Story Flag** — Story Flag query/state0.

97. **Hypothesis** — Hypothesis canonical query0.

98. **damage/casualty** — damage/casualty query0, canonical owner 없음.

99. **Candidate readiness** — Candidate readiness/threshold query0.

100. **existing State getter changes** — 부족한 Progress scope getter 하나만 추가; 다른 owner API 충분.

101. **CampaignData changes** — CampaignData 변경0, 기존 lookup 재사용.

102. **Progress changes** — Progress +4행 get_campaign_id만, 진행/완료/intent/reset 책임 유지.

103. **Response changes** — Response 변경0(이번 단계 baseline); public getter 사용.

104. **Resolution changes** — Resolution 변경0; public record getter 사용.

105. **Pending changes** — Pending 변경0; public Room getter 사용.

106. **Archive changes** — Archive 변경0; public discovery getter 사용.

107. **Runtime changes** — Runtime 변경0; public confirmed/discovery getters 사용.

108. **Main integration** — Main bind/getter/context/cleanup release/exit_tree만 +14행.

109. **Main query logic 여부** — Main query body0; historical resolver는 adapter에 있음.

110. **public getter** — get_campaign_fact_queries() -> CampaignFactQueries; invalid startup null.

111. **query mutation** — 전체 owner/Runtime/UI/current identity/authored fingerprint mutation0.

112. **RNG mutation** — RNG seed/state/instance 동일, sampling0.

113. **credit mutation** — pacing presentation credit 변화0; Economy/Credit 시스템 추가0.

114. **token mutation** — Research token/display 상태 변화0.

115. **opportunity mutation** — opportunity keys/transition budget 변화0.

116. **Candidate mutation** — Candidate threshold/counters/triggered flags 변화0.

117. **Progress mutation** — Progress campaign/current/completed/intent 변화0.

118. **Research mutation** — Archive merge/Runtime discover/observe0.

119. **Response mutation** — Response begin/confirm/complete0.

120. **Pending mutation** — Pending add/remove/resolve/reset0.

121. **Resolution mutation** — Resolution record/rejudge0.

122. **Hypothesis mutation** — Hypothesis records/ID counters 변화0.

123. **repeated query stability** — 같은 상태 1/10/100회 결과 의미 동일.

124. **query ordering stability** — 정방향/역방향 실제 호출 결과/source 동일.

125. **result mutation safety** — 모든 반환 primitive 필드 변경, source/authored 변화0.

126. **source release safety** — release 후 source refs=null; 모든 API SOURCE_RELEASED.

127. **cross Campaign** — foreign entry INVALID, 다른 Campaign owner INVALID, 같은 entry 문자열은 실제 bound owner만 조회.

128. **release after cleanup** — CLEANED/partial cleanup 후 released, verified retry 가능.

129. **source false disguise 여부** — post-cleanup false disguise0; UNKNOWN placeholder도 유효 값이 아님.

130. **current Runtime switch** — actual CASE_A→Scripted→CASE_B에서 Runtime A→null→B.

131. **old Runtime retained 여부** — old Runtime retention0, weakref 소멸 검증.

132. **authored preservation** — Campaign/Entry/Case/Scripted/Incident/Broadcast/Result property tree 및 .tres bytes 동일.

133. **Query suite** — 새 fact suite headless/native 각각411594 assertions PASS.

134. **mixed suite** — fresh mixed headless/native PASS, Source Archive/stale/once guards 유지.

135. **repeated Event suite** — same definition two occurrence 다른 선택 query와 기존 repeated flow PASS.

136. **unresolved suite** — actual Case03 Room known/UNKNOWN MISSING_OUTCOME PASS.

137. **Research suite** — current pre-merge/past after merge/B current union/undiscovered false PASS.

138. **release suite** — normal/preflight reject/reset release/partial retry/Main free PASS.

139. **readonly suite** — 100회 전체 source fingerprint/역순/결과 변경 PASS; 반복 field assertions 포함.

140. **invalid suite** — kind/entry/Incident/Research/definition/approved link/scope/context/Room conflict PASS.

141. **Step46 regression** — Snapshot normal/phases/response/isolation fresh PASS.

142. **Step47 regression** — ordering PASS, oldest actionable arbitration 유지.

143. **Step48 regression** — gate PASS, read pacing credit/token 불변.

144. **Step51 regression** — ownership PASS, recipient authority/record contract 유지.

145. **Step52 regression** — closure/actual success+failure journeys headless/native PASS.

146. **Step53 regression** — active termination PASS, 기존 prepared-pending 제한 유지.

147. **Step54 regression** — cleanup PASS, no-run/rejection/partial retry/recipient 보존.

148. **Step55 regression** — Campaign routing lengths/reorder/startup PASS.

149. **Step57 regression** — typed CASE/Scripted/duplicate/future kind reject PASS.

150. **Step58 regression** — mixed/repeated/invalid bundle/bounded arbitration headless/native PASS.

151. **ACTIVE Scripted block** — UNSUPPORTED_ACTIVE_CAMPAIGN_RESPONSE 유지; query로 terminal 지원되지 않음.

152. **completed Scripted terminal gap** — completed Scripted는 final recipient Case-only projection에서 여전히 누락.

153. **Campaign final** — Campaign final 구현0, last Case boundary를 Campaign ending으로 일반화0.

154. **Story condition** — actual Story condition/evaluator0.

155. **Ending** — Ending/branching0.

156. **Save** — Save/Load0.

157. **HistoryState** — CampaignHistoryState/history database0.

158. **StoryFlagState** — StoryFlagState/freeform flags0.

159. **Experiment history** — past Experiment history 추가0, 기존 current history 유지.

160. **product GDScript count** — 제품 GD49(48+adapter1).

161. **parser** — Godot4.7.1 GD49개 check-only PASS.

162. **editor import** — fresh editor import PASS, UID 생성.

163. **Main headless** — configured Main headless PASS.

164. **Main native** — configured Main native PASS.

165. **GPU smoke** — 1280×720 mixed/bounded/journey GPU smoke, 대표이미지 시각 확인; UI 변화0이라 3해상도 반복 생략.

166. **process count** — 고유 최종73 processes. 실제 시도78(77성공/1fixture 실패); 재실행 중복은 성공 집계에서 제외.

167. **assertion count** — 832118 assertion 호출; query 합계823188. 반복 field 검사를 포함하며 독립 시나리오 개수 아님.

168. **warnings** — normal warnings0; controlled19(ordering4/closure13/active2).

169. **controlled diagnostics** — expected startup diagnostics30(13+17); invalid query console errors0.

170. **runtime errors** — 최종 runtime/script errors0; 최초 fixture 빈 배열 index 오류 수정/재실행/로그 보존.

171. **parse errors** — 제품/최종 parse errors0.

172. **Main after lines/functions** — Main2253행/123함수, +14행/+2함수.

173. **new product files** — 새 product GD1개 campaign_fact_queries.gd, nested values3개.

174. **modified product files** — Main/Progress만 수정, lifecycle 연결/scope getter.

175. **new UID files** — campaign_fact_queries.gd.uid1개, nested class 별도UID0.

176. **modified Scene** — 이번 단계 Scene 변경0; 기존 Main Scene 변경 보존.

177. **modified Resource .tres** — 이번 단계 .tres 변경0; 제품3CASE sequence 그대로.

178. **project.godot** — project.godot bytes 동일, 1920×1080/canvas_items/GL Compatibility 유지.

179. **README** — README 원본 bytes prefix 보존, Step60 요약 append.

180. **report** — 이 문서: 필수20섹션/identity·availability·phase tables/193개 개별답변.

181. **git diff --check** — git diff --check 및 새 파일 whitespace, Step60-only baseline diff 검사.

182. **staged** — staged0, git add0.

183. **commit/push** — commit/push0, 요청대로 실행하지 않음.

184. **P0** — 새 P0 없음.

185. **P1** — 새 P1 없음.

186. **P2** — 기존 terminal/cleanup/prepared-pending P2 유지, 새 query 회귀 없음.

187. **P3** — 기존 Hypothesis private enumeration P3 유지, adapter binding0.

188. **Step53 existing P2** — ACTIVE_FORCE_REQUIRES_PREPARED_PENDING 유지.

189. **Step54 cleanup limitation** — multi-owner atomic rollback 미보장 유지, verified receipt/frozen retry+query released guard.

190. **Scripted terminal gap** — ACTIVE Scripted block / completed Scripted terminal gap 둘 다 OPEN.

191. **next Story material requirement** — authored Story ID/조건/completed phase/UNKNOWN 정책/소비시점 자료 필요. 임의 content0.

192. **Step61 readiness** — public query 소비 기반 확보, Step61 목표/자료 검토 후 범위 결정.

193. **final recommendation** — A 첫 Story/B terminal gap/C 준비된 Mandatory 자료 중 후속 선택 필요; 자동구현0.
