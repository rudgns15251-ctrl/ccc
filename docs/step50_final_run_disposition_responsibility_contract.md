# Step50 — Final Run Disposition Responsibility Contract

2026-10-06 · Godot 4.7.1 / GDScript / Windows / 1920×1080.

**DESIGN ONLY · NOT IMPLEMENTED.** 최종 Run의 책임은 결과 소유자가 검증된 전체 disposition을 한 번에 공개하고 commit receipt를 확정하는 순간 이전한다. 그 전에는 원본 Gameplay State가 책임을 가진다. 같은 Run의 재요청은 같은 결과를 반환하고, 수락 실패는 원본을 보존한 채 재시도한다. 이번 작업은 이 계약과 README 요약만 작성한다. 문서의 미래 타입·필드·절차는 현재 존재하는 클래스나 API가 아니다.

F07-B의 설계 계약은 **DESIGN CONTRACT COMPLETE / READY FOR IMPLEMENTATION**이다. 제품 finding은 **PARTIALLY ADDRESSED**를 유지하며 **RESOLVED가 아니다**. 실제 closure, obligation State, Settlement, 경제, Save, Campaign은 구현하지 않았다.

## 1. 조사한 현재 저장소와 근거

작업 전 HEAD `d6d9e4efe625d1688d475e326f8c723d357540a5`, branch `master`, upstream `origin/main`. 원격은 `https://github.com/rudgns15251-ctrl/ccc.git`이다. 이번에 fetch/stage/commit/push는 하지 않는다. 시작 상태는 다음과 같다.

```text
 M README.md
 M docs/step39_case_evidence.md
?? docs/step49_major_predictability_threshold_audit.md
```

README에는 Step49 요약이 이미 있고, Step49 보고서는 미추적 파일이다. Step39 트리 두 줄의 공백→탭 사용자 편집을 보존한다. 저장소 및 상위 경로에서 적용할 AGENTS.md는 발견되지 않았다. 비생성 파일 전체 목록, project.godot, Main Scene/Script, runtime 7 State, read model, Case 3 Resource, 화면/데이터 파일 구성, Step45~49 보고서와 기존 검증 자료를 조사했다. 기존 상태는 Scene15/GDScript40/Case Resource3/Autoload0이며 Main은 **1,714줄/93함수**다.

현재 구조의 주요 책임 경로는 다음과 같다.

| 실제 경로 | 현재 책임 / 이번 계약과의 관계 |
|---|---|
| `project.godot`, `scenes/main/main.tscn` | configured Main, Control UI, Case01→02→03; 해상도1920×1080/초기1280×720/canvas_items/keep/resizable/GL Compatibility 유지 |
| `scripts/main/main.gd:77` | `_ready`: 7 State의 세션 소유·초기화; Run identity/Run closure 없음 |
| `scripts/main/main.gd:880` | `build_test_sequence_disposition_snapshot`: developer read-only 관찰; Next/Confirm에서 자동 호출하지 않음 |
| `scripts/main/main.gd:933`, `:962` | `_handoff_to_next_case`, `_try_resolve_current_pending`: 다음 Case가 있어야 현 제출을 hidden resolve; 새 Runtime, session State carry |
| `scripts/main/main.gd:1048` 주변 | oldest actionable 및 공유 presentation credit; 본 단계에서 수정 없음 |
| `scripts/main/main.gd:1202`, `:1267`, `:1284` | Major 시작/Option 확정/Resume 완료; 정상 완료 뒤 후보 제거 |
| `scripts/main/main.gd:1312` | Source Archive의 underlying response stage와 unconfirmed draft 보존 |
| `scripts/runtime/pending_containment_state.gd` | authored case_id→Room 제출 1개; reset은 전체 삭제 |
| `scripts/runtime/containment_resolution_state.gd` | case_id당 확정 Success/Failure 기록 1개; 재판정 없음 |
| `scripts/runtime/failure_event_candidate_state.gd` | source_case_id당 후보; D/M count·trigger flag·상대 등록 순서 |
| `scripts/runtime/incident_response_state.gd` | `(source_case_id, incident_id)` 응답; ACTIVE/COMPLETED, 확정 Option/Result ID; 영구 노출 이력은 없음 |
| `scripts/runtime/research_archive_state.gd` | 실제 발견 entry ID의 중복 없는 병합; 미처리 의무 저장소 아님 |
| `scripts/runtime/working_hypothesis_state.gd` | 사용자 가설/메모; 사실·판정·의무와 별도 |
| `scripts/runtime/case_runtime_state.gd` | 현재 Case 실험·Room·발견·적용 환경·관찰 사실; handoff 시 새 객체 |
| `scripts/read_models/test_sequence_disposition_snapshot.gd` | facts deep copy / phase projection / invalid reference; State 변경·책임 인수 없음 |

위 line은 조사 시점 근거다. 현재 Main의 hidden resolve는 기존 Resolution/후보가 있으면 경고하고 Pending을 유지한다. 이것이 아래 미래 retry reconciliation까지 구현됐다는 뜻이 아니다. Snapshot은 Result stage와 content identity로 `incident_result_displayed`를 관찰하지만, native draw 완료를 영구 기록하는 별도 receipt는 없다. `incident_result_id`는 Confirm 시 저장되므로 **그 ID만으로 실제 표시를 증명할 수 없다**.

| 누적 단계 | 유지할 사실/정책 |
|---|---|
| Step45 | Case/동일 Run Shift carry; final Run conversion; voluntary는 현재 Active만 정상 완료, forced는 중단; Pending 정규 판정 선행 |
| Step46 | TEST_SEQUENCE_END Snapshot은 관찰이고 closure/Settlement/conversion/Gameplay truth가 아님 |
| Step47 | 등록 순서 oldest actionable, invalid/unready retain+skip; completion 후 순서 index 축소 |
| Step48 | D/M 공통 meaningful credit·read boundary; Resume/Dismiss/Log는 새 credit 아님; final Next 비활성 |
| Step49 | KEEP_MAJOR_1; baseline144 Journey의 M88/최종 후보128/잔여 발생113 Journey; 과거 Audit 결과이며 이번 새 실행 수치 아님 |

현재 D=2~4, Main이 전달하는 M=1을 유지한다. State의 단독 기본값과 Main의 실제 전달값을 혼동하지 않는다. Case03에는 matching Outcome이 없으며 Confirm 후 미판정 Pending과 `No next test case configured`가 남는다. Case04/Run End 버튼/정산/Case03 Outcome은 추가하지 않는다.

## 2. Boundary Responsibility Matrix

CASE_END는 현재 유효 다음 Case로 hidden resolve/handoff하는 경계다. 나머지 실제 Run/Shift/Campaign 종류는 미래 계약이며 TEST_SEQUENCE_END와 구별한다.

| Boundary | 의미 | 현재 여부 |
|---|---|---|
| CASE_END | 현재 업무 제출·다음 Case handoff; 모든 사건 완료와 다름 | [현재 구현] 유효 다음 Case가 있는 경로 |
| SHIFT_END | 같은 Run 안의 업무 단위 pause/carry | [미구현]; 시간/업무 경계 [미정] |
| VOLUNTARY_RUN_END | 플레이어가 허용 조건 아래 해당 Run을 닫겠다는 요청 | [미구현]; quota/허용 조건 [미정] |
| FORCED_RUN_END | 외부 조건으로 해당 Run 업무 종료 | [미구현]; 원인별 UX [미정] |
| TEST_SEQUENCE_END | 마지막 테스트 Case에 다음 구성 없음 | [현재 구현] 상태 유지/명시적 developer Snapshot; Run 성공/실패 아님 |
| CAMPAIGN_END | 여러 Run을 포함하는 전체 진행 종료 | [미구현]/[미정]; 이번 최종 Run 계약과 자동 동일시하지 않음 |

아래 Run 열은 전부 **향후 계약**이다. Shift도 미래 계약이다.

| State/fact | Case End | Shift End (같은 Run) | Voluntary Run End | Forced Run End | Test Sequence End |
|---|---|---|---|---|---|
| Pending | 유효 제출 hidden resolve; invalid이면 handoff 보류 | 제출 carry | 판정 가능한 제출부터 resolve; unknown/invalid 별도 이전 | 같은 선행 판정; unknown/invalid 별도 이전 | 미판정 상태 유지; Snapshot만 |
| Resolution | 확정 사실 carry | carry | 결과 historical fact | 실패 Run에서도 historical fact | 유지/관찰 |
| UNDISTURBED | 후보 carry | count/order carry | unmanifested obligation | 동일 | 유지/관찰 |
| DISTURBED_NOT_READY | 후보 carry; 새 Case 환경은 별개 | phase/사실 carry | 실제 D 사실+미완료 의무 | 동일 | 유지/관찰 |
| MAJOR_READY | ready 후보 carry | 강제 drain 없이 carry | ready-unresponded 의무 | 동일 | 유지/관찰 |
| ACTIVE_RESPONSE | 현재 응답 완료 후 handoff | 계획된 pause는 현재 응답 완료 후 | 현재 응답만 정상 완료할 때까지 commit 대기 | interrupted 사실+잔여 책임 | 자동 종료/완료 없음 |
| COMPLETED_RESPONSE | 완료 기록 유지 | 유지 | historical fact, 새 의무0 | 동일 | 유지/관찰 |
| INVALID reference | retain/skip 또는 제출 보류 | 오류 사실 carry | invalid unresolved reference 이전 | 동일 | 유지/관찰 |

Campaign End의 집계·장기 consequence는 [미정]. 공통으로 사실 삭제/가짜 완료는 허용하지 않는다. final Run 뒤에는 **원래 Candidate 객체를 다음 Run에 carry하지 않는다**. 결과 기록이 책임을 인수하는 conversion이며, 세계 환경/장기 영향은 별도 미래 정책이다.

## 3. Policy Decision Table

| Policy Area | Options | Recommended | Reason | Future Cost | Risk |
|---|---|---|---|---|---|
| Run identity | A runtime UUID; B session 단조번호; C 명시 RunInstanceId; D 안정 opaque Save-compatible ID | C 의미의 explicit RunInstanceId, A 방식 생성 가능한 D 표현 | authored sequence/노드 수명과 분리; 한 실제 Run 시작에 1회 발급 | 세션 결과 record에 ID 전달; UUID 생성 방식 후속 결정 | B만 사용하면 재시작 충돌; UUID도 저장 없으면 crash 복구 불가 |
| Case instance | authored case_id만 / Run+할당 identity | CaseAssignmentId(=이 계약의 CaseInstanceId) | 같은 콘텐츠 재할당/변종 구별 | Run 안 불변 allocation ordinal 또는 opaque token | 순서 변경 때 재생성하면 dedup 실패 |
| Boundary | 테스트/Shift/final 통합 / explicit 종류 | explicit boundary; final terminal key는 Run ID 하나 | 같은 Run voluntary/forced 이중 결과 방지 | precommit intent 전환 guard | boundary를 dedup key에 넣으면 두 final result 가능 |
| Transfer | reset 후 결과 생성 / 항목별 / 전체 수락 | 전체 검증→원자적 수락→receipt→cleanup | half-transfer 및 자료 유실 방지 | 작은 immutable Record·accept 함수 | receipt 미확인 시 reset 위험 |
| Idempotency | callback ID / boundary별 ID / Run terminal key+typed source keys | canonical final Run ID와 불변 source 키 | 클릭·signal·retry·boundary 변경을 같은 종료로 합침 | 한 Run result index; 충돌 검증 | phase/type 변경을 새 사건으로 세면 중복 |
| Retry | 재판정/RNG 재추첨 / 원본 유지·재조정 | 원본 사실 유지, 최신 상태 재검증, committed receipt 조회 | 이미 resolve한 제출을 다시 판정하지 않음 | 단조 prepare subtransaction·한 번 저장한 threshold | source/result 불일치 무시 시 의무 소실 |
| Active Response | 자동 선택 / 전부 drain / voluntary 현재만·forced 중단 | 마지막 안 | 사용자 선택/표시 사실 존중 | stage·exposure 증거 필요 | result ID를 display로 간주하는 오류 |
| Pending | skip / 모두 Failure / 유효만 hidden resolve | 유효 판정 선행, unknown/invalid 별도 | Confirm→즉시 정산 판정 회피 방지 | handoff와 독립적인 판정 경계·재시도 계약 | 기존 current-case helper를 그대로 쓰면 retry 불충분 |
| Candidate phase | 전부 replay / 전부 삭제 / 사실+의무 conversion | phase에 맞춘 conversion | 미발생/ready/active/completed 구분 | 한 event obligation에 fact attachment | 실제 D를 가짜 발생/미발생으로 바꾸는 오류 |
| Result owner | Run Result State / Run History / Settlement Result / Save·Campaign | 작은 in-memory RunDispositionState가 committed RunDispositionRecord 소유 | 실제 인수·dedup·retry 책임에 한정 | Main보다 긴 세션 수명으로 소유하는 호출측 필요 | Main만 소유하면 Main 교체 시 결과 소실 |

C와 D는 경쟁하는 구현 라이브러리가 아니라 identity 의미와 표현의 선택이다. 현재 `get_instance_id()`는 process-local 객체 guard이며 RunInstanceId 대체물이 아니다. Run UUID 발급/저장 코드도 이번에 만들지 않는다.

Result owner 대안의 차이도 분명히 한다. **Run Result State**는 현재 필요한 수락/index/receipt 책임을 가장 작게 담는다. **Run History Record**는 immutable 값으로 적합하지만 그 값 자체가 중복 수락과 수명을 관리하지는 못하므로 State가 보유하는 Record로 사용한다. **Settlement Result**를 먼저 소유자로 삼으면 아직 없는 정산·경제 의미와 결합된다. **Save/Campaign 계층**은 장기 보존 후보지만 crash/schema/여러 Run 정책까지 필요하므로 지금의 첫 owner로 채택하지 않는다. 권고 State는 세션 메모리에만 보존하며 영구 보존을 약속하지 않는다.

`CaseDefinitionId`는 authored 콘텐츠 lookup ID, `CaseAssignmentId`는 실제 Run 내 배정 identity다. 배정 ID는 `(RunInstanceId, immutable allocation ordinal)`로 시작할 수 있으나 mutable array index와 다르며 제거/삽입으로 재번호하지 않는다. 같은 Definition을 두 번 배정하거나 변종이 같은 incident_id를 쓰더라도 source assignment가 다르다. 변종 콘텐츠 ID/version의 작성 규약은 후속 결정이 필요하다. 현재는 unique case_id를 강제하므로 반복 Case를 지원하지 않는다. 미래 Step48 source token도 assignment+source ID를 써야 하며, 지금의 case_id dedup을 변경하지 않는다.

## 4. Closure phases와 책임 이전

### REQUESTED → PREPARING → COMMITTED (미래 명세)

1. REQUESTED: 해당 Run에 canonical 종료 intent 1개를 등록한다. 요청은 reset도 성공 판정도 아니다. 새 업무/새 후보 presentation을 멈추고, voluntary의 현재 정상 Active Response만 기존 Confirm/Next/Source Archive/Resume로 끝낼 수 있게 한다. 자동 Option 선택/다음 후보 시작은 금지한다.
2. Active가 있는 voluntary는 여기서 대기한다. 콘텐츠 손상으로 정상 완료 불가능하면 오류와 원본을 보존하고 commit하지 않는다. forced로 바꾸려면 실제 forced 종료 요청이 필요하며 시간 초과가 forced 승인으로 간주되지 않는다.
3. PREPARING: gameplay mutation을 잠시 동결하고 현재 Run/배정/Runtime/7 State 객체 identity를 확인한다. 필요한 valid Pending의 정규 hidden resolution을 먼저 확정한다. 새 Failure 후보는 이 prepare에서 UNDISTURBED로 기록할 수 있으나 D/M 기회를 만들거나 사건 UI를 표시하지 않는다.
4. 판정 후 direct State에서 facts/의무/실제 discovery/가설을 복사하여 immutable **FinalRunDispositionPlan**을 만든다. Plan은 제안이며 Gameplay truth, Outcome, committed 결과가 아니다.
5. 결과 소유자는 전 항목의 identity/완전성/중복/Response terminal 배타성을 검증하고 공개되지 않은 전체 Record를 구성한다. 전 항목 수락 전에 결과 일부를 노출하거나 원본을 지우지 않는다.
6. **COMMIT POINT:** 단일 Run terminal index에 전체 immutable Record와 commit receipt를 함께 공개한다. 논리적 책임 이전은 이 순간이다. 수락 통보만 먼저 보내는 방식은 금지한다.
7. 호출측은 Run ID/Record receipt를 재확인한 뒤에만 session cleanup을 요청할 수 있다. 새 Run 시작은 별도 명시적 행위다. cleanup 재시도는 같은 receipt 아래에서 idempotent이며 새 obligation을 만들지 않는다.

결과 owner는 작은 RefCounted State 후보이고 Autoload/Manager를 요구하지 않는다. 미래 Run을 시작하는 호출측이 해당 owner를 **종료된 Main/Runtime보다 오래** 보유해야 한다. 현재 그 상위 소유자/실제 Run entry point는 존재하지 않는다. Step51에서는 테스트 호출측의 명시적인 객체 참조로 수명을 증명하고, 실제 앱 수명 통합은 Step53 이후 정한다. Save나 Campaign을 먼저 만들어서 해결하지 않는다.

### Ownership Matrix

| 대상 | 종료 전 | Prepare 중 | Commit 후 | 실패/재시도 |
|---|---|---|---|---|
| Pending/Resolution/Candidate | 현재 Main이 보유한 Gameplay State | 동일 State; valid resolve의 단조 사실만 변경 가능 | 결과 owner의 미판정 제출/판정 사실/의무 Record | 수락 전 실패: source 유지; 준비 판정은 재사용 |
| Active/Completed Response | IncidentResponseState + Main context | voluntary 현재만 완료, forced 동결 후 사실 복사 | historical completed 또는 interrupted+잔여 책임; 둘 다 금지 | 완료/중단 race 재검증; 자동 완료 없음 |
| Archive/current 발견 | Archive 및 현재 Runtime | 실제 ID만 합집합·중복 제거; 새 해금 없음 | 결과의 discovery facts 보존; obligation과 분리 | source 발견 보존; 결과 실패로 발견 취소 없음 |
| Hypothesis | WorkingHypothesisState | 원문/ID 별도 복사 | notes 범주로 보존; penalty 아님 | 소유 인수 전 메모 삭제 금지 |
| 현재 environment/관찰 | current Runtime | 실제 확인 가능한 facts 복사 | historical context; 다음 Run에 자동 적용 안 함 | 원본 Runtime 유지; 없는 과거 이력은 unknown |
| Plan | 없음 | 비소유 immutable proposal | receipt에 대응하는 입력; 새로운 truth가 아님 | 폐기/재생성 가능; 원본 대체 불가 |
| Final Record/receipt | 없음 | private 구성은 authoritative 아님 | RunDispositionState가 sole authoritative owner | commit 전 미공개; commit 후 통보 실패는 receipt 조회 |

물리적으로 source container가 commit 이후 cleanup까지 남아 있을 수 있다. 이것은 active ownership 2개가 아니라 읽기 전용 잔여 사본이다. commit 이후 원본 gameplay를 재개해서는 안 된다. **거절 확정(미commit)**과 **acknowledgment 불명(이미commit 가능)**을 구별한다. 후자는 gameplay를 계속 동결하고 recipient의 canonical Run receipt를 조회한다. receipt가 있으면 수락 완료이며 다시 쓰지 않고 cleanup만 재시도한다.

## 5. Idempotency / atomicity / TOCTOU

final transaction key는 **`RunInstanceId` 하나**다. boundary_type은 Record의 provenance이지 dedup domain이 아니다. `run+VOLUNTARY`와 `run+FORCED`를 별개 키로 사용하지 않는다. commit 전 voluntary가 forced로 승격될 수 있지만 같은 transaction을 재준비한다. commit 후 다른 boundary 재요청은 기존 receipt를 반환하고 reason conflict를 진단할 뿐 결과를 덮어쓰지 않는다. 별도 FinalResultRequestId는 현재 필요하지 않다. 로컬 prepare generation은 request identity와 다르다.

entry identity는 phase나 status에 의존하지 않는다. 정규화한 typed tuple로 구분한다.

```text
SUBMISSION: (run_id, source_assignment_id, SUBMISSION)
RESOLUTION: (run_id, source_assignment_id, RESOLUTION)
EVENT:      (run_id, source_assignment_id, incident_id, EVENT)
DISCOVERY:  (run_id, source_assignment_id, entry_id, DISCOVERY)
```

SUBMISSION은 Room 변경으로 새 키가 되지 않는다(확정 Room 불변). resolved이면 unresolved submission은0이고 Resolution fact만 남는다. EVENT의 obligation 종류/phase는 값이지 키가 아니다. Candidate와 forced Active는 같은 EVENT의 한 항목으로 병합하며, `INTERRUPTED_RESPONSE`와 `MAJOR_READY_UNRESPONDED` 두 obligation을 동시에 만들지 않는다. completed evidence가 유효하면 EVENT는 completed historical 범주에만 있다. Failure Resolution은 별도 판정 사실이며 같은 Failure를 의무 하나 추가하는 근거로 세지 않는다. entry_kind는 출력 분류이며 위 불변 key-domain과 동일한 변경 가능한 값으로 쓰지 않는다.

현재처럼 배정당 Incident 하나면 이 키로 충분하다. 같은 배정에서 같은 Incident가 반복 발생하는 기능을 도입할 때만 별도 EventOccurrenceId가 필요하다. Candidate 리스트의 `created_order`는 completion 뒤 축소되는 상대 순서로, 절대 timestamp/중복 방지 ID가 아니다. 미래 Run 내 등록 ordinal을 불변으로 보관하는 것은 반복 사건이 실제 요구될 때 검토한다.

### Idempotency Matrix

| 경합/재시도 | 계약 | 결과 |
|---|---|---|
| double End / duplicate signal | 같은 Run canonical intent 또는 receipt 반환 | Final Record1, source별 obligation 최대1 |
| Scene 전환 retry | recipient Run receipt 조회부터 | 이미commit이면 결과 재생성 없이 cleanup만 |
| plan 생성 실패 | 원본 보존, plan 폐기 | 결과0, source가 책임 유지 |
| owner 수락 거절 | 전체 미공개; 원본 삭제0 | 결과0, 같은 Run 재준비 가능 |
| 일부 항목 검사/할당 실패 | private staging 전체 폐기 | 반쪽 결과/부분 transfer0 |
| commit 뒤 ack 유실 | Run receipt 조회; 원본 동결 | 결과1, duplicate write0 |
| voluntary 요청 뒤 forced | precommit면 같은 intent 승격/재준비; postcommit는 기존 반환 | final terminal result1 |
| Active completion vs forced | 동결/직렬화 전에 완료됐으면 completed, 아니면 interrupted | 같은 EVENT completed+interrupted0 |
| Pending resolution vs closure | 단일 배정 판정 subtransaction 확인/재사용 | 재판정/재추첨/중복Candidate0 |
| Candidate completion vs plan | 최신 유효 Completed 증거로 재분류 | stale obligation 폐기; 완료를 신규 의무로 전환0 |

논리 atomicity의 최소 범위는 **하나의 in-memory 전체 Record 공개와 receipt**다. 프로세스 crash/파일 기록/재실행 recovery는 아직 보장하지 않는다. Save 도입 시 durable commit journal/schema migration이 별도로 필요하다. 메모리 record가 disk 저장과 같다고 주장하지 않는다.

TOCTOU: Snapshot을 받은 뒤 Runtime 교체·Option Confirm·Resume·Pending 판정이 발생할 수 있다. Snapshot 단독을 accept 입력의 authority로 사용할 수 없다. 추천 최소안은 Godot main-thread에서 **동기식 prepare/validate/accept 구간 동안 mutation guard**, Run/assignment/Runtime/State 객체 identity 및 content unique link 직접 재검증이다. 이 구간은 `await`, 외부 callback, reentrant gameplay signal을 허용하지 않고 통보 signal은 commit 후에 내보낸다. 직렬 실행이어도 reentrancy 때문에 guard는 필요하다.

향후 async/프레임을 넘는 prepare가 필요하면 관련 mutation마다 증가하는 작은 revision 또는 generation stamp를 추가하여 plan과 commit의 값 일치를 확인한다. object identity만으로 객체 내부 변경은 잡을 수 없다. 이번에는 revision/state/locking framework를 추가하지 않는다. voluntary 대기 중에는 immutable 최종 plan을 미리 고정하지 않고 완료 후 다시 읽는다. source/content mismatch는 stale이면 재준비하고, 구조적 충돌이면 원본을 유지해 오류를 보고한다.

## 6. Pending first / Resolution contract

### Pending Matrix

| 상황 | 미래 prepare 동작 | 최종 의미 / retry |
|---|---|---|
| RESOLVABLE_PENDING | source/assignment/confirmedRoom 및 unique valid Outcome 재검증; 정규 hidden resolve를 먼저 확정 | RESOLVED_BEFORE_CLOSURE; Success/Failure 사실은 Resolution에서 인수 |
| MISSING_OUTCOME | 판단하지 않음; 제출한 Room 사실만 복사 | UNRESOLVED_SUBMISSION, result UNKNOWN; Case03 현재 사례 |
| INVALID_OUTCOME | duplicate/undefined/불일치 Incident 등 오류 설명 보존 | INVALID_SUBMISSION; Success/Failure 없음 |
| INVALID_SUBMISSION_REFERENCE | source/Room missing·ambiguous ID 보존 | INVALID_SUBMISSION; fake authored lookup 없음 |
| ALREADY_RESOLVED_PENDING | 기존 immutable Resolution과 same assignment/Room 검증; 일치하면 pending 잔여를 reconciliation | 재판정0; 불일치면 구조적 충돌로 commit 보류 |
| FAILURE + existing Candidate | Resolution/source/Incident 및 기존 Candidate identity 일치 확인; 기존 phase/threshold 유지 | Candidate 재추가/threshold 재추첨0; mismatch 보류 |
| existing Failure + Completed Response | 유효 완료 증거 유지, 남은 duplicate Pending/Candidate를 정합화 | 완료 사실만; Failure로 후보 재구성 금지 |

현재 `_try_resolve_current_pending`를 고치지 않았다. 미래에는 next Case 유무와 독립적인 hidden-resolution 경계가 필요하다. prepare 안에서 유효 제출별 **Resolution + 필요한 최초 Candidate + Pending 해소를 하나의 논리 subtransaction**으로 만든다. validation/threshold 한 번 결정→private 준비→전체 확정 순서다. 중간 실패로 Resolution만 먼저 생기는 경로를 만들지 않는다. 여러 Pending 중 앞의 prepare 판정이 성공한 뒤 뒤쪽 준비/최종 owner 수락이 실패하면, 그 앞 판정은 원본 owner의 단조 사실로 유지되고 retry에서 재사용한다. 이것은 최종 책임 partial transfer가 아니다.

기존 손상 상태가 `Failure Resolution + Candidate 없음 + 완료 증거 없음`이면 Candidate 부재를 완료로 추측하지 않는다. 정상 prepare의 저장된 subtransaction receipt로 정확한 재시작이 가능하면 그 준비 결과만 회복한다. 그런 증거가 없으면 구조적 모순으로 commit을 보류하고 원본을 보존한다. 임의 threshold 재추첨/Outcome 재판정으로 고치지 않는다. authored content unavailable/unknown을 invalid obligation으로 보존하는 정상 conversion과, 서로 충돌한 State 사실을 silently 고치는 행위는 구별한다.

Success Resolution은 성공 사실만, Failure Resolution은 실패 사실과 해당 EVENT disposition을 별도 범주로 보존한다. 이미 기록된 Outcome은 콘텐츠를 나중에 바꾸었다고 재판정하지 않는다. 유효 Pending의 판정 선행은 Confirm→즉시 정산으로 Failure를 누락시키는 우회를 막지만, 경제 페널티 자체가 현재 구현됐다는 뜻은 아니다.

## 7. Candidate Phase Matrix와 interrupted response

| 실제 phase/증거 | 최종 record category | actual facts | 금지 |
|---|---|---|---|
| UNDISTURBED | UNMANIFESTED_FAILURE_OBLIGATION | hidden Failure/source ID; D 미발생 | 시설 사고/환경 적용/Incident 표시를 생성했다고 기록 |
| DISTURBED_NOT_READY | DISTURBED_UNRESPONDED | 실제 D 발생 flag와 확인 가능한 적용 사실, Major 미완료 | 환경 변화를 미발생으로 되돌림/추가 기회 생성 |
| MAJOR_READY | READY_BUT_UNRESPONDED_OBLIGATION | 실제 D, readiness count/threshold; Incident 미시작 | 자동 Incident/Broadcast/drain |
| ACTIVE_RESPONSE, voluntary | 완료 대기 후 COMPLETED 역사 | 정상 confirmed/display/discovery를 유지 | 강제 Option/자동 Resume/다음 Candidate 시작 |
| ACTIVE_RESPONSE, forced | INTERRUPTED_RESPONSE (동일 EVENT의 단일 의무) | source/response stage/confirmedOption/result exposure/실제 discovery | COMPLETED 강제 설정/아무 대응 없음으로 축소 |
| COMPLETED_RESPONSE | COMPLETED_RESPONSE_FACT (obligation0) | 기존 완료 응답/확정 선택/판정 사실 | Failure를 읽어 후보 재생성 |
| INVALID | INVALID_UNRESOLVED_REFERENCE | 원래 source/Incident/phase/오류와 이미 확정된 사실 | 삭제/가짜 완료/가짜 authored 콘텐츠 |

invalid 표시는 별도 두 번째 EVENT를 생성하지 않고 해당 EVENT의 validity issue로 남긴다. completed의 콘텐츠 lookup이 나중에 unavailable이어도 이미 확정된 역사 자체를 취소하지 않는다. source identity 충돌처럼 서로 다른 사건을 구분할 수 없는 경우는 위 구조적 충돌 보류 규칙을 따른다.

### Active Response Stage × 종료 종류

| 실제 응답 위치 | Voluntary | Forced |
|---|---|---|
| INCIDENT | 사용자 Next→Broadcast→Confirm→Result→Resume까지 현재 것만 대기 | interrupted, confirmedOption 없음; 실제 Incident 노출만 |
| BROADCAST draft | local 선택은 사용자가 확정해야 함 | draft는 authoritative 선택 아님; optional 진단으로만 별도 |
| BROADCAST confirmed | 확정 Option 불변; 사용자가 Result/Resume 진행 | confirmedOption/result ID 유지; Result 표시 여부는 별도 |
| INCIDENT_RESULT displayed | 정상 Resume completion까지 commit 대기 | result displayed 사실 유지, interrupted; no-response 아님 |
| Source Archive | underlying INCIDENT/BROADCAST/RESULT에 복귀해 정상 진행 | archive 화면을 Response phase로 쓰지 않음; underlying stage와 실제 발견 기록 |
| Resume pending | 아직 State.Status.ACTIVE; 사용자 Resume를 기다림 | completed로 승격하지 않음; confirmed/displayed 사실을 모두 인정 |

Interrupted는 남은 진행이 중단됐다는 terminal disposition이며 현재 ResponseState enum에 추가한 상태가 아니다. 완료도 아니고 무응답도 아니다. forced request를 먼저 동결한 후 late Resume callback은 원본을 완료시키지 않는다. 실제 완료가 먼저 승인된 경우 forced plan은 completed history로 읽는다. callback 순서를 명시적으로 정렬하고 중복 분류를 거절한다.

forced 기록의 `response_stage`는 Archive 같은 현재 overlay View가 아니라 underlying workflow stage다. `incident_result_id`는 Confirm receipt에 있는 ID이고 `result_displayed`는 실제 표시 증거다. 후속 구현에서 실제 draw/exposure를 기록해야 하며, 없는 역사 정보를 false로 채워 넣지 않는다. `KNOWN_TRUE / KNOWN_FALSE / UNKNOWN` 또는 nullable evidence를 사용한다. 과거 Snapshot의 stage projection은 참고자료이고 영구 exposure receipt를 대신하지 않는다.

## 8. Research / environment / Resource 경계

### Research Visibility Matrix

| 데이터 | 기록 가능한 것 | conversion으로 추가 해금? | 공개 UI |
|---|---|---|---|
| 실제 발견 Research | Archive ID + 현재 Runtime의 실제 발견 ID 합집합 | 아니오; 기존 실제 발견만 | 기존 Archive 규칙 |
| authored 미발견 Incident/Option/Result entry | 링크 유효성 검사에 내부 참조 가능 | **금지** | 미공개 유지 |
| obligation fact | source identity/phase/책임/오류 | Research 아님 | 플레이어에게 어느 상세를 공개할지 [미정] |
| confirmedOption / displayedResult | 실제 승인/노출 증거 각각 | Confirm만으로 Result entry 해금 금지 | 기존 discovery 경계 |
| Hypothesis | 사용자가 작성한 원문/ID; 독립 notes | Research/정답/penalty 전환 금지 | 이후 UI 정책 [미정] |

Result의 별도 범주는 (1) 판정·완료·발생·선택의 historical facts, (2) unresolved obligations, (3) actual research discoveries, (4) hypotheses/notes다. Count만 인수하고 원본 entry IDs/가설 텍스트를 지우면 책임 인수가 아니다. 연구가 authored entry 없이 fallback으로 노출된 경우에는 실제 관찰 source identity를 기록할 수 있지만 없는 entry ID를 만들어 Archive에 넣지 않는다.

현재 environment는 현재 Runtime에 적용된 D/reaction 사실이고 past source Candidate는 의무 source다. Candidate `disturbance_triggered`는 발생 증거지만 어느 과거 target Case에서 발생했는지의 전체 이력을 저장하지 않는다. Runtime은 handoff 때 교체된다. 미래 상세 이력이 필요하면 실제 manifestation 경계에 source assignment/target assignment/disturbance ID를 최소 fact로 남겨야 한다. 지금 잃어버린 과거 target/시각/노출을 authored Resource로 추정 복원하지 않는다. 확인 불가능하면 UNKNOWN으로 보존한다.

새 Run에 current environment를 기본 복사하지 않는다. 결과에 actual fact를 남기는 것과 다음 세계에 효과를 적용하는 것은 다르다. 다음 Run/world continuity consequence는 [미정]. `.tres`를 플레이 결과로 수정하지 않으며 장기 Record에는 Resource 객체/Node/get_instance_id를 저장하지 않는다. authored lookup은 stable definition/content ID로 수행하되 missing/changed content는 unavailable 진단과 기존 primitive 사실을 유지한다. 삭제/변경된 authored content의 Save version/migration은 위험으로 기록하고 이번에 해결하지 않는다.

## 9. 최소 Final Record / Entry 필드 (설계)

Record envelope는 `run_instance_id`, terminal `boundary_type`, schema identity(향후 Save 시 버전), commit receipt, 배열 `historical_facts / obligations / discoveries / hypotheses`를 가진다. 지금 schema version을 구현하라는 뜻은 아니다. Run/boundary는 envelope에 한 번 두고 모든 entry에 중복 저장하지 않는다.

| 후보 필드 | 최소 채택 / 의미 |
|---|---|
| run_instance_id | 필수 envelope; entry는 부모 참조로 상속; actual Run마다 불변 |
| boundary_type | 필수 envelope provenance; 최종 dedup key에 넣지 않음 |
| source_case_definition_id | entry 필수 authored lookup; unresolved missing도 원래 ID 유지 |
| source_case_instance_id | entry 필수 assignment identity; repeat Case 구별 |
| incident_id | EVENT 필수; SUBMISSION에는 없음(빈 가짜 Incident를 만들지 않음) |
| entry_kind | obligation/fact 의미의 discriminator; immutable identity domain과 분리 |
| phase | Candidate/Response의 종료 시 phase, 해당하지 않는 record는 생략 |
| actual_facts | 필요한 primitive 증거만: Room/result/trigger/count/threshold/confirmed IDs/exposure/reference issue; 미확인 값 UNKNOWN |
| created_order | 필요한 EVENT의 종료시 상대 순서를 보존; identity/절대시각 아님 |
| status | unresolved/invalid/interrupted/completed는 category로 이미 표현; 중복 generic status는 기본 생략. 이후 obligation 소비 lifecycle가 생길 때 독립 상태 추가 |
| Resource reference | 저장하지 않음; 안정 ID와 승인 당시 사실값만 |

receipt의 구현 표현은 후속 결정하며 현재 callback request counter를 만들지 않는다. Record는 commit 이후 immutable이다. future 소비/경제 조정이 원본 종료 사실을 덮어쓰지 않도록 separate consumption record가 필요한지는 해당 시스템 도입 때 결정한다.

의무 분류의 최소 vocabulary는 UNRESOLVED_SUBMISSION / UNMANIFESTED_FAILURE_OBLIGATION / DISTURBED_UNRESPONDED / READY_BUT_UNRESPONDED_OBLIGATION / INTERRUPTED_RESPONSE / INVALID_UNRESOLVED_REFERENCE다. INVALID_SUBMISSION은 마지막 분류의 submission variant다. 실제 이름은 구현 때 일관되게 결정할 수 있다. 완료 사실에는 Success/Failure Resolution, 실제 D, confirmed Option, 실제 Result 노출, COMPLETED Response가 포함된다. 같은 사건의 환경 사실과 잔여 의무를 별도 관점으로 참조하되 중복 책임으로 세지 않는다.

경제 비용/penalty/CR/Quota/보상은 **[미정]/[미구현]**이다. inactive 후보 존재만으로 settlement를 금지하지 않는다. hidden 후보 개수로 버튼 enabled를 바꾸면 존재 자체가 누출된다. 정산 허용 조건은 별도 미래 정책, active voluntary 완료 대기는 현재 응답의 책임 처리 조건이다. 결과가 어떤 consequence를 부과할지는 나중에 정하더라도 의무 사실을 소실시키면 안 된다. failed Run도 성공/실패/선택/노출 사실을 보존한다.

## 10. 구체적 사례와 failure/retry 흐름

아래는 **미래 Run End contract 사례**다. 현재 제품에는 해당 종료 API가 없다. A/B의 제출/판정/응답 상태는 현재 3Case prototype에서 관찰 가능한 종류이며, 최종 Record 생성만 가상이다. C는 의도적으로 구성한 future/controlled fixture이며 Step49 정상144 Journey에서 이 조합을 재현했다고 주장하지 않는다. D의 forced trigger도 가상이다.

### A. 모든 판정 가능 Case 성공 + Case03 unknown

Case01 TEST_ROOM_02→Success, Case02 TEST_CASE02_ROOM_01→Success, Case03 Room 제출→Outcome 없음. source resolution2, candidate0, completed response0, Pending1이다. Run closure prepare는 이미 판정된 두 Case를 재판정하지 않는다. 최종 historical Success2 + UNRESOLVED_SUBMISSION1, Failure0/event obligation0, Archive와 notes는 실제 기록만. 제목의 all-success는 **판정 가능한 두 Case**를 뜻하며 Case03까지 성공한 것이 아니다.

### B. Case01 실패 응답 완료 + Case03 unknown

Case01 TEST_ROOM_01 또는03 Failure, 해당 정상 Response의 Confirm/Result/Resume 완료, Case02 Success, Case03 unknown 제출. historical Failure1/Success1/CompletedResponse1 + unresolved submission1이다. Failure를 보고 완료 후보를 재생성하지 않는다. 확정 Option/실제 discovery는 보존하고 event obligation0이다. source Candidate 제거 사실만으로 완료를 추론하는 것이 아니라 Completed Response record를 확인한다.

### C. Case01 Major-ready + Case02 disturbed-not-ready + Case03 unknown

가상 Run R의 source assignment A1/A2/A3를 사용한다. A1 M-ready/D발생, A2 D발생/M-not-ready, A3 미판정 제출. 최종 event obligation2(ready1, disturbed1)+submission1; historical Failure2와 실제 D 증거 각각 보존. 자동 Incident0/Broadcast0/추가 opportunity0. 상대순서 A1→A2를 저장하고 해당 Source/target 중 모르는 이력은 UNKNOWN이다. 두 Candidate 중 첫 항목만 결과에 먼저 공개하는 것은 금지한다.

Step49의 해당 matrix에서는 Case02 Major 표시가0이었다. 이것은 특정 실험/읽기 fixture·gate·끝 경계의 결과이며 가능한 모든 플레이의 법칙이 아니다. 위 동시 phase는 계약 경계용 fixture 예시이고 제품 정상 재현 실적이 아니다.

### D. Confirmed Broadcast 중 Forced End

R/A1/I1/B1 Option O1이 이미 확정되고 result ID R1이 있다. 아직 Result View를 표시하지 않았다면 `confirmed=O1, result_id=R1, result_displayed=KNOWN_FALSE`라는 **표시 미발생 증거가 있는 fixture**를 사용한다. interrupted stage=BROADCAST, 완료0, EVENT 의무1. Result Research는 해금하지 않는다. 실제 Result draw 후 Resume 전 forced라면 displayed=KNOWN_TRUE와 실제 discovered ID를 보존하고 여전히 interrupted다. 기존 상태만으로 표시 이력을 확정할 수 없다면 UNKNOWN을 사용한다. Source Archive를 열고 있어도 underlying BROADCAST/RESULT로 기록한다.

### Duplicate End / 두 Candidate write 실패 (명세 trace, 실행 결과 아님)

```text
End(R, voluntary) -> canonical REQUESTED(R)
End(R, voluntary) again -> same intent (result count0)
prepare: resolve valid Pending once -> source retains Resolution/initial Candidate
build entire plan P: EVENT A1 + EVENT A2 + submissions/facts
recipient validates A1 privately -> A2 validation/allocation fails
  -> discard private record; visible result count0; source owns A1 and A2
retry End(R): re-read source, reuse resolutions/thresholds, build P'
recipient accepts ALL P' -> publish record+receipt R exactly once (commit)
source confirms receipt -> cleanup permitted
late duplicate End(R) -> same record/receipt (result count1, obligation count2)
```

Plan build 성공 뒤 owner write 거절도 동일하다. source는 지우지 않는다. commit 이후 ack만 실패하면 recipient에는 result1이 있으며 source는 동결 잔여 사본이다. retry는 먼저 receipt를 조회하고 재write하지 않는다. 정합성이 바뀐 stale plan은 재준비하며 그 과정에서 예전 Pending을 다시 판정하거나 같은 Candidate의 D threshold를 다시 추첨하지 않는다.

## 11. Future 책임 분리와 구현 순서

Main은 종료 intent의 orchestration, 현재 context 확인, 정상 Active 완료 대기, hidden resolve 준비 요청, facts 수집, plan 제출/receipt 확인만 담당한다. CandidateState는 진행 중 후보 phase/count/order, ResponseState는 승인/완료, Archive는 actual discovery truth를 유지한다. 각 truth owner를 하나의 종료 Framework로 흡수하지 않는다.

RunDispositionState는 **commit된 ownership/Run terminal index/receipt/duplicate refusal**라는 실제 새 책임만 갖는다. pure plan builder는 값 변환이 커질 때 분리할 수 있지만 manager/bus/interface hierarchy는 필요 없다. Snapshot은 inspection용; category projection/primitive copying 규약은 재사용 가능하되 Snapshot 숫자/사본만으로 인수하지 않는다. 전체 assignment identity, live consistency, full response chain/exposure, 실제 discovery IDs/메모 내용, commit receipt는 별도 필요하다.

| 후속 단계 후보 | 가장 작은 책임 | 완료 증거 |
|---|---|---|
| Step51 | in-memory RunDispositionRecord + 작은 ownership State; caller가 수명 보유 | 전체 수락/거절, Run1결과, immutable copy, typed-key 중복 거절, 원본 독립 보존을 isolated fixture로 확인 |
| Step52 | explicit developer closure API + Pending 선행/동기 prepare + idempotent commit/cleanup guard | missing/invalid/valid Pending, two-candidate rejection/retry, stale identity, ack 재조회, 이미 완료된 응답 중복0 |
| Step53 | voluntary/forced Active 처리와 실제 Run 수명 integration | stage별 중단/확정/표시/Resume race; 강제 drain0; 전달 후에만 reset |

Step51은 실제 RunState/Campaign이 없는 상황에서 gameplay entry와 묶지 않고 명시적인 Run/assignment ID fixture로 owner 계약부터 구현하는 추천이다. 최소 in-memory 계약이 확인된 뒤 Step52의 실제 Prototype developer API 통합 범위를 다시 정한다. Step53 전에 Run 시작/종료의 상위 수명·Run ID 생성 책임이 구체화돼야 한다. 세 단계 이름은 제안이며 이번에 코드를 생성하지 않는다.

Settlement UI는 데이터 책임 뒤, Economy는 의무 의미/소비 정책 뒤, Save/Load는 안정된 in-memory identity/commit 뒤에 둔다. offline validator는 이번 범위가 아니다. Main 증가 예상은 rough estimate로 Step51 **0~15줄/0~1함수**(참조 연결이 필요할 때), Step52 **약50~100줄/3~5함수**, Step53 **약30~70줄/2~4함수**이며 정책/guard 통합에 따라 달라진다. 제품 수정 예상치를 보장하거나 이번 실제 변경으로 보고하지 않는다. 단순 line count보다 ownership 독립성 때문에 작은 State가 정당하며 포괄 Manager/Autoload로 분리하지 않는다.

F07-B를 향후 RESOLVED로 바꾸려면 다음을 실제 구현/검증해야 한다.

- TEST_SEQUENCE_END와 구별한 실제 final Run boundary/identity가 존재한다.
- valid Pending을 hidden resolve한 뒤 conversion하며 unknown/invalid를 가짜 Success/Failure로 바꾸지 않는다.
- unresolved source 책임이 전체 Result로 인수되고 interrupted/completed를 배타적으로 보존한다.
- duplicate/race/stale/partial rejection/receipt retry에서 최종 Record1·의무 중복0을 검증한다.
- 수락 확인 전 reset0, 승인 후 cleanup, no force drain/auto Option을 검증한다.
- actual Research/환경/노트가 의무 ledger와 분리되고 미발견 해금0이다.

사람 테스트는 향후 voluntary 대기 의미/forced interruption 공개 범위 확인에 필요할 수 있다. 이번 semantic 계약에 UI 변화나 사람 테스트 결과를 붙이지 않는다. F01 defer/KEEP_MAJOR_1과 Next/Resume UX는 그대로다.

## 12. 작업 범위와 검증

생성: 이 문서1개. 수정: README의 Step50 append1개. 제품 Script/Scene/Resource/State/read model/project 설정 수정0, 삭제0, Main 증가0이다. 기존 README prefix/Step39 사용자 편집/미추적 Step49 문서/기존 검증 자료를 SHA256 baseline으로 보존 검사한다. ignored `.godot/verification/step50/`의 integrity 도구·baseline·결과는 개발 검사 자료이며 제품 코드나 종료 구현이 아니다.

이번은 문서 작업이므로 Godot/GDScript/GPU 실행을 다시 수행하지 않는다. Step49 실행 검증은 과거 근거로만 인용한다. 새 verification은 파일 무결성, README append, 178개 항목 연속성, Git 범위/whitespace/staged/deleted/HEAD/branch/upstream 검사다. 줄바꿈의 LF→CRLF Git 안내는 기존 attributes의 경고이고 제품 오류가 아니다. 검사 결과의 정확한 파일 수는 아래 최종 결과 블록에 기록한다.

아직 미정: 실제 Run 시작/종료 트리거·quota/경제·의무 consequence·결과 공개 UI·world continuity·Campaign boundary·Save schema/ID 발급 구현·authored version migration. 책임 이전/키/실패/Active/Pending의 기본 계약은 이 문서로 선정했지만 위 기능들을 구현했다고 해석하지 않는다.

## 13. 요청한 178개 종료 보고 항목

아래 답변의 미래 절차는 모두 DESIGN ONLY / NOT IMPLEMENTED다.

| 번호 | 요청 항목 | 답변 |
|---|---|---|
| 1 | 작업 전 Git 상태 | 시작 modified README/Step39 각1, untracked Step49 보고서1; staged0. §1의 원본 status를 보존했다. |
| 2 | HEAD / branch / upstream | HEAD d6d9e4efe625d1688d475e326f8c723d357540a5, master→origin/main. 이번 fetch/branch 변경 없음. |
| 3 | 기존 사용자 변경 | Step39 트리2줄 공백→탭 사용자 편집, Step49 README append와 미추적 보고서를 baseline으로 보호했다. |
| 4 | Step45 종료 정책 | Case/동일 Run Shift carry, final conversion; voluntary 현재 Active만 완료, forced interrupted, 유효 Pending 판정 선행(§2). |
| 5 | Step46 Snapshot 역할 | read-only 사실 사본과 참조 분류; closure/Settlement/conversion/truth owner 아님(§1/11). |
| 6 | Step47 ordering | 등록 순서 oldest actionable; invalid/unready retain+skip; 변경0. 상대순서는 identity가 아님. |
| 7 | Step48 pacing | D/M 공유 meaningful credit와 읽기 경계; Confirm 사건 표시0, Resume/Dismiss credit0; 변경0. |
| 8 | Step49 Major=1 결론 | KEEP_MAJOR_1. Step49 baseline144 Journey M88/최종후보128/잔여113 Journey는 과거 Audit 수치. |
| 9 | F07-B 현재 상태 | PARTIALLY ADDRESSED 유지; 종료 계약 설계 완료와 제품 RESOLVED를 구별한다. |
| 10 | Test Sequence End 정의 | 다음 Test Case가 없는 개발 경계; Case03 Pending/Runtime 유지. 실제 final Run이 아님. |
| 11 | Case End 정의 | 현재 유효 next Case hidden resolution→handoff; 사건 완료 경계가 아니라 업무 제출 경계. |
| 12 | Shift End 정의 | 동일 Run 업무 pause/carry; 미구현, Shift 시간·업무 정의 미정. |
| 13 | Voluntary Run End 정의 | 허용 조건 아래 명시적 자발 Run 종료 요청; Active 정상 완료 후 commit. 현재 API 없음. |
| 14 | Forced Run End 정의 | 외부 원인에 의한 Run 종료; Active 자동 완료 없이 interrupted. 현재 trigger 없음. |
| 15 | Campaign End 범위 | 여러 Run의 전체 종료는 미구현/미정; 삭제/거짓 완료 금지 외 집계 정책은 범위 밖. |
| 16 | Run Identity 후보 | A runtime UUID/B session counter/C explicit RunInstanceId/D stable opaque ID 비교(§3). |
| 17 | 추천 Run Identity | C의 독립 identity를 D의 opaque token으로 표현; 실제 Run 시작1회 발급. UUID 생성 방식은 후속 구현 결정. |
| 18 | authored Case ID와 차이 | authored CaseDefinitionId는 콘텐츠 lookup, RunInstanceId는 실제 플레이 수명; case_sequence와 다르다. |
| 19 | Case Instance Identity 필요성 | Run별 불변 CaseAssignmentId 필요. authored ID가 같은 재배정도 구별한다. |
| 20 | 재등장/변종 identity 위험 | 재등장/변종의 같은 case/incident ID만 쓰면 이전 의무·credit 충돌; assignment와 콘텐츠 version 규약 필요. |
| 21 | Step48 token future risk | 현재 case_id 기반 token은 반복 배정에 위험; 미래 assignment+source token 권고, 코드 변경0. |
| 22 | Closure Request 의미 | REQUESTED는 종료 intent 등록; reset/성공/정산 완료 아님. 같은 Run intent 재사용. |
| 23 | Closure Prepare 의미 | PREPARING은 동결·identity 검증·Pending 선행 판정·전체 plan 복사; source ownership 유지. |
| 24 | Closure Commit 의미 | COMMITTED는 전체 Record+receipt의 원자적 공개; 이 시점에만 책임 이전(§4). |
| 25 | Disposition Plan 정의 | FinalRunDispositionPlan은 판정 후 원본 사실에서 만든 immutable 인수 제안; 이번 클래스 생성0. |
| 26 | Plan Source of Truth 여부 | Plan은 Source of Truth 아님. commit 전 원본 State, commit 후 recipient Record가 authority. |
| 27 | Snapshot과 차이 | Snapshot은 관찰만; Plan은 현재 identity/일관성을 다시 검증한 transfer 입력(§5/11). |
| 28 | Result Owner 정의 | 전체 수락·terminal index·receipt·immutable 결과를 보유하고 source보다 오래 생존하는 객체. |
| 29 | 추천 Result Owner | 최소 in-memory RunDispositionState+RunDispositionRecord 권고. Save/Campaign/Settlement를 owner로 먼저 만들지 않는다. |
| 30 | Main 역할 | 현재 7 State/View 소유. 미래 intent/context/prepare 요청/receipt 확인 orchestration만 담당. |
| 31 | State 역할 | 기존 State는 truth, 미래 DispositionState는 committed ownership/dedup 책임; 역할 혼합 금지. |
| 32 | Manager 필요성 | 포괄 Manager 불필요. 실제 record 인수 책임만 가진 작은 State로 시작. |
| 33 | Ownership transfer 시점 | recipient가 전체 Record와 receipt를 단일 Run index에 공개하는 순간; 생성/요청/부분 검증 시점 아님. |
| 34 | transfer 전 owner | 현재 Main이 보유한 Gameplay State; Plan/private result는 owner 아님. |
| 35 | transfer 후 owner | RunDispositionState의 committed Record가 sole owner; source는 cleanup 전 동결 사본. |
| 36 | 실패 시 owner | precommit 거절이면 source. commit 후 ack 불명은 receipt 조회하며 동결; 이미commit이면 recipient. |
| 37 | transfer 전 reset 금지 | 수락 확인 전 State/Runtime/Archive/notes reset·삭제 금지; valid Pending 판정 해소는 정상 prepare subtransaction. |
| 38 | commit 후 cleanup 가능 조건 | 같은 Run의 commit receipt 확인 후에만 cleanup 가능; 재요청은 cleanup만 재시도. |
| 39 | idempotency 정의 | 같은 Run 종료를 반복해도 최종 Record1/source별 의무 최대1이며 확정 사실을 재판정하지 않는 계약. |
| 40 | idempotency key | transaction RunInstanceId; entry typed run+assignment(+incident) key. boundary/phase는 payload이며 dedup key 아님(§5). |
| 41 | Candidate duplicate 방지 | Candidate/Active를 동일 EVENT 키로 합친다. phase 변화나 invalid 진단을 새 obligation으로 세지 않는다. |
| 42 | Pending duplicate 방지 | SUBMISSION 키 run+assignment; resolved 제출은 unresolved 배열에서 제외. Room을 새 transaction key로 쓰지 않는다. |
| 43 | Active Response duplicate 방지 | EVENT terminal 분류 배타적; 유효 completed 증거 우선, 동결 후 late 완료 거절; interrupted와 completed 동시0. |
| 44 | double End | 같은 Run intent/receipt 반환. voluntary와 forced가 달라도 final Record는1. |
| 45 | duplicate signal | 중복 signal도 Run key로 합침; commit 통보는 공개 후 내보내 reentrant mutation 방지. |
| 46 | retry | source retained→fresh 검증/판정 receipt 재사용→전체 수락 재시도. 이미commit이면 receipt 조회만. |
| 47 | partial failure | 두 후보 중1개 성공은 private staging일 뿐; 두 번째 실패 시 staging 전체 폐기/공개0/source 유지(§10). |
| 48 | atomicity | in-memory 전체 Record+receipt 한 번 공개; 항목별 외부 공개/부분 transfer 금지. |
| 49 | TOCTOU | 관찰 이후 Runtime/Confirm/Resume/판정이 변할 수 있음. 동기 mutation guard와 direct 재검증 필요. |
| 50 | stale snapshot 위험 | old Snapshot로 commit하면 active/completed·Pending 분류가 stale; 사본을 truth로 신뢰하지 않는다. |
| 51 | commit 전 identity 재검증 | Run/assignment/Runtime/State identity, immutable 판정/현재 response/content link를 직전 직접 검증. |
| 52 | Pending 처리 순서 | 모든 유효 Pending 정상 hidden resolution 후 Candidate/Response disposition plan 생성. |
| 53 | RESOLVABLE_PENDING | unique valid source/Room/Outcome와 Incident 링크 재검증 후 판정; RESOLVED_BEFORE_CLOSURE로 처리. |
| 54 | hidden resolution requirement | next Case 존재와 독립적인 정상 hidden-resolution 경계 필요. 이번 resolve 구현0. |
| 55 | settlement abuse 방지 | Confirm 직후 final End라도 valid Failure가 source State에 생성된 뒤 이전돼 누락 회피를 막는다. |
| 56 | UNRESOLVED_SUBMISSION | matching Outcome 없음은 UNRESOLVED_SUBMISSION/result UNKNOWN; Case03 현재 사례. |
| 57 | invalid Pending | unavailable/ambiguous source/Room/Outcome/Incident는 INVALID_SUBMISSION 진단과 원래 IDs 보존. |
| 58 | false Success 금지 | unknown/invalid 제출을 성공 처리하지 않는다. 제출만으로 완료/보상 사실을 만들지 않는다. |
| 59 | false Failure 금지 | unknown/invalid 제출을 실패로 추정하거나 Candidate를 만들지 않는다. |
| 60 | existing Resolution | 기존 Resolution 재사용; duplicate Pending은 same assignment/Room이면 reconciliation, 충돌이면 보류. |
| 61 | Success Resolution | 역사 Success fact; event Candidate 없음. Case01Room02/Case02Room01 실제 authored 근거. |
| 62 | Failure Resolution | 역사 Failure fact+별도 EVENT phase; 이미 Completed면 새 Candidate를 만들지 않는다. |
| 63 | UNDISTURBED disposition | UNMANIFESTED_FAILURE_OBLIGATION; D 미발생, 사고/환경 적용을 거짓 생성하지 않는다. |
| 64 | DISTURBED_NOT_READY disposition | DISTURBED_UNRESPONDED; 실제 D 사실과 아직 미완료 Major 책임을 분리 보존. |
| 65 | MAJOR_READY disposition | READY_BUT_UNRESPONDED_OBLIGATION; readiness 사실만, Incident/Broadcast 강제 재생0. |
| 66 | ACTIVE_RESPONSE disposition | voluntary 정상 완료 대기; forced INTERRUPTED_RESPONSE 단일 EVENT 의무와 승인/노출 사실. |
| 67 | COMPLETED_RESPONSE disposition | COMPLETED_RESPONSE_FACT/history만, 새 의무0. Failure Resolution로 후보 재구성 금지. |
| 68 | Invalid Candidate disposition | INVALID_UNRESOLVED_REFERENCE; 원래 source/phase/오류/확정 사실 유지, 삭제/완료 금지. |
| 69 | Voluntary Active Incident | 현재 Incident→Broadcast→Result→Resume 정상 완료까지 voluntary commit 대기. |
| 70 | Voluntary Broadcast draft | draft는 사용자가 Confirm해야 함; 종료 요청이 A/B/C를 선택하지 않는다. |
| 71 | Voluntary confirmed Option | 확정 Option 불변으로 유지; 정상 Result/Resume를 기다림. |
| 72 | Voluntary Result displayed | displayed 사실 보존, 정상 Resume completion 전에는 voluntary commit 대기. |
| 73 | Forced Active Incident | stage INCIDENT의 interrupted; 실제 공개된 Incident/Research만 기록, auto Option0. |
| 74 | Forced Broadcast draft | draft는 authoritative 선택 아님. forced 종료가 확정으로 승격시키지 않는다. |
| 75 | Forced confirmed Option | confirmed Option/Result ID를 유지; Result actual display는 따로 증거를 확인. |
| 76 | Forced Result displayed | 실제 Result 노출/discovery 보존, interrupted로 인수; no-response로 축소하지 않는다. |
| 77 | Source Archive 상태 | Archive overlay 대신 underlying response stage 사용. 실제 발견 IDs만 보존(§7). |
| 78 | Resume pending 상태 | Resume 전 State는 ACTIVE; forced는 interrupted, voluntary는 사용자의 정상 Resume를 기다림. |
| 79 | auto Option 금지 | 자동 선택/Confirm/result fabrication 금지; forced에서도 동일. |
| 80 | next Candidate drain 금지 | 종료 과정에서 현재 Active 뒤 새 ready Candidate를 시작하지 않는다. 전체 replay/drain0. |
| 81 | Interrupted 의미 | 기존 승인·노출을 인정한 채 남은 workflow가 종료로 중단됐다는 의미; future record 개념. |
| 82 | Interrupted≠completed | Interrupted는 정상 COMPLETED receipt가 없으므로 completed로 세지 않는다. |
| 83 | Interrupted≠no response | 이미 confirmed/displayed면 수행 사실이 있다. interrupted를 무응답으로 해석하면 사실 유실. |
| 84 | discovered Research | Archive와 current Runtime의 실제 discovered IDs만 합집합; fallback 관찰도 사실로 구분. |
| 85 | hidden Research | 미발견 authored Incident/Option/Result Research는 conversion으로 해금하지 않는다. |
| 86 | Archive | actual discovery truth; 의무 ledger로 재사용 금지. Count만 복사해 IDs를 버리지 않는다. |
| 87 | Hypothesis | 별도 notes로 원문/ID 보존, 정답·판정·penalty가 아님. |
| 88 | obligation vs Research | obligation은 처리 책임, Research는 실제 발견 정보. 하나의 존재가 다른 쪽 공개를 뜻하지 않음. |
| 89 | current environment | current Runtime 환경과 past source Candidate 분리; 실제 적용 증거만 기록. |
| 90 | cross-Run environment carry | 새 Run에 환경 자동 복사 없음. world continuity 효과는 미정. |
| 91 | Resource mutation | .tres/Resource에 결과 쓰기0; stable ID/primitive 사실만 장기 기록. |
| 92 | Final Disposition Entry 최소필드 | §9 envelope와 entry 표. source IDs/kind/해당 phase/actual facts/상대 order; redundant status는 기본 생략. |
| 93 | run_instance_id | 불변 explicit 실제 Run identity; envelope에서 상속, 현재 생성 코드 없음. |
| 94 | boundary_type | envelope provenance; final dedup key에 추가하지 않으므로 voluntary/forced 중복 결과 없음. |
| 95 | source definition ID | authored lookup용 source_case_definition_id; missing이라도 원래 ID 보존. |
| 96 | source instance ID | source_case_instance_id=CaseAssignmentId; 같은 Definition 재등장 구별. |
| 97 | incident_id | EVENT source Incident ID 필수; submission-only에 가짜 Incident ID 없음. |
| 98 | entry_kind | obligation/fact 분류; phase나 kind 변경을 identity 변경으로 사용하지 않는다. |
| 99 | phase | 종료 시 실제 Candidate/Response phase; 해당하지 않는 record는 생략. |
| 100 | actual_facts | Room/판정/D/count/threshold/확정 IDs/노출/reference issue 중 실제 증거만; unknown은 UNKNOWN. |
| 101 | created_order | 현 후보 relative index 순서 복사; completed 제거 시 축소, 절대 시각/identity 아님. |
| 102 | status | category로 unresolved/interrupted/completed 표현; 독립 generic status 기본 생략. 미래 소비 lifecycle와 구별. |
| 103 | Resource reference 저장 여부 | Resource/Node 객체 저장하지 않는다. 현재 get_instance_id도 장기 Run identity가 아님. |
| 104 | authored lookup | stable Definition/content ID lookup; 삭제/변경 시 unavailable 진단과 기존 primitive 사실 유지. |
| 105 | obligation type 목록 | 미판정 제출/미발현 실패/교란후미응답/ready미응답/중단응답/invalid reference; 이름은 §9. |
| 106 | completed facts 목록 | Success/Failure Resolution, actual D, confirmed Option, actual Result exposure, Completed Response history. |
| 107 | Result Owner 데이터 범주 | historical facts / unresolved obligations / actual discoveries / hypotheses를 별도 배열 범주로 인수. |
| 108 | economy 미구현 | economy/penalty/CR/Quota/보상 구현0; 금액은 미정. |
| 109 | consequence 미정 | obligation의 경제/장기 세계 영향은 미정; 책임 기록 보존만 선정. |
| 110 | settlement abuse | 의무는 종료로 사라지지 않게 인수; 실제 penalty/정산 효과까지 구현됐다고 주장하지 않는다. |
| 111 | hidden candidate UI leak | hidden 후보 존재로 정산 버튼 disabled하면 정보 누출. 결과 상세 공개 범위는 별도 미정. |
| 112 | candidate로 settlement 금지 여부 | inactive 후보 존재만으로 settlement 금지하지 않음. voluntary 현재 Active 완료 대기는 별개. |
| 113 | Forced End fact 보존 | 실패 Run에서도 과거 성공/실패/교란/승인/노출 facts 보존. |
| 114 | Shift carry | 같은 Run Shift에서는 phase/count/source lookup/의무 carry; final conversion으로 오인하지 않음. |
| 115 | Case carry | 일반 Case handoff는 session State carry; current environment는 새 Runtime에 자동 복사 안 함. |
| 116 | Campaign 미정 | Campaign 종료/집계/장기 잔여 책임 미정; 이 문서에서 시스템 구현0. |
| 117 | Test Sequence read-only | TEST_SEQUENCE_END Snapshot은 read-only; final End/정산/새 opportunity를 실행하지 않음. |
| 118 | closure trigger 미구현 | 실제 closure trigger/button/API 없음. Case03 Next는 그대로 disabled. |
| 119 | 새 State 필요성 | 향후 committed ownership/index/receipt라는 실제 독립 책임 때문에 작은 State가 정당. |
| 120 | State 도입 기준 | source보다 긴 수명·전체 수락·idempotency·retry 검증이 필요한 때 도입; 미래 필요만으로 framework0. |
| 121 | Manager 미필요 | Campaign/Case/Incident/Run Manager를 추가하지 않는다. |
| 122 | Autoload 판단 | Autoload0 유지. future result owner도 명시 caller 참조를 우선; 전역 Singleton 필요 입증 안 됨. |
| 123 | Main future responsibility | Main은 intent/context/prepare 요청/plan 제출/receipt 확인; 장기 결과 authority는 recipient. |
| 124 | Result Owner future responsibility | 전체 plan validate/atomic accept/Run terminal index/immutable Record/receipt/retry 조회 책임. |
| 125 | CandidateState responsibility | closure 전 D/M phase/count/상대순서 truth 유지; 결과 경제/정산 책임 맡지 않음. |
| 126 | ResponseState responsibility | 실제 승인 Option/ACTIVE/COMPLETED truth; 미래 노출 증거 추가 필요는 별도로 표시. |
| 127 | Archive responsibility | 실제 발견 entry ID truth; hidden obligation을 discovery로 바꾸지 않음. |
| 128 | builder 필요성 | pure value builder는 필요 시 분리 가능; 이번 builder class/code0. |
| 129 | Snapshot 재사용 범위 | phase projection/deep-copy/category naming 참고 가능; developer Snapshot 자체는 인수 authority 아님. |
| 130 | Snapshot만으로 부족한 부분 | valid Pending mutation/Run·배정 ID/현재 일관성/full option-result link/노출 receipt/IDs·notes 내용/commit은 부족. |
| 131 | State revision 필요성 | 동기 guard+direct identity 우선. async prepare 도입 때 related mutation revision/generation 필요; 이번 추가0. |
| 132 | retry flow | owner 거절→source 유지→최신 재검증/판정 재사용→전체 retry→receipt확인(§10). |
| 133 | idempotent commit flow | duplicate End(R)→same intent→Record1; commit 뒤 재요청은 same receipt 반환(§5/10). |
| 134 | partial failure flow | 두 후보 중1개 private 처리 뒤 실패하면 전체 staging 폐기; 외부 result0, source 후보2 유지. |
| 135 | crash consistency 범위 | 메모리 논리 atomicity만. process crash/durable Save/re시작 복구는 보장하지 않음. |
| 136 | relative order | 종료시 Candidate 상대 등록 순서 보존. order를 키로 쓰거나 절대 시간을 주장하지 않는다. |
| 137 | absolute identity 필요성 | 반복 Incident가 실제 요구되면 EventOccurrenceId; 현재 한 배정 한 Incident엔 run+assignment+incident 충분. |
| 138 | Case instance identity | 미래 assignment identity 필수; 현재 authored case_id uniqueness 코드 수정0. |
| 139 | Run 간 carry 여부 | final Run에서는 원 Candidate 객체를 다음 Run으로 carry하지 않음. 결과 owner가 기록을 보유. |
| 140 | final conversion 의미 | conversion은 완료/면제/성공이 아니라 사실·잔여 처리 책임의 ownership 이전. |
| 141 | all-success 예시 | §10A: 판정가능 Success2+Case03 unknown submission1; event obligation0. Case03 성공 아님. |
| 142 | completed failure 예시 | §10B: Failure1/Success1/CompletedResponse1 history+unknown1; 완료 사건 신규 의무0. |
| 143 | unresolved multi-candidate 예시 | §10C future controlled fixture: M-ready1+D-not-ready1+unknown1; EVENT2+SUBMISSION1; 강제 재생0. |
| 144 | forced active response 예시 | §10D forced trigger 가상: confirmed Option 보존, displayed 증거 별도, interrupted EVENT1/완료0. |
| 145 | Boundary Responsibility Matrix | §2 표의 8 State/fact×5 Boundary; Campaign은 별도 미정 표기. |
| 146 | Ownership Matrix | §4 표: source/prepare/commit/실패 owner, ack 불명과 확정 거절 구별. |
| 147 | Idempotency Matrix | §5 표: double/duplicate/retry/partial/ack/forced승격/completion·resolution race 전부 계약화. |
| 148 | Active Response Matrix | §7 표: Incident/draft/confirmed/displayed/Archive/Resume pending의 voluntary/forced 차이. |
| 149 | Pending Matrix | §6 표: resolvable/missing/invalid/already-resolved/Failure+Candidate/Completed reconciliation. |
| 150 | Candidate Phase Matrix | §7 표: UNDISTURBED/DNR/MREADY/ACTIVE/COMPLETED/INVALID 최종 category와 금지 행위. |
| 151 | Research Visibility Matrix | §8 표: actual Research/hidden authored/obligation/confirmed-display/notes의 기록·해금·공개 구별. |
| 152 | F07-B RESOLVED 기준 | §11 checklist의 actual boundary/Pending 선행/전체 transfer/Active 배타성/retry/reset/no-drain/no-false-outcome 구현 검증 필요. |
| 153 | 이번 Step F07-B 판정 | DESIGN CONTRACT COMPLETE, 제품 F07-B PARTIALLY ADDRESSED; RESOLVED 아님. |
| 154 | Step51 추천 | 작은 in-memory Record+ownership State, explicit fixture ID로 전체 수락/불변/중복 거절을 먼저 검증. |
| 155 | Step52 추천 | developer closure API/hidden resolve 경계/동기 검증/idempotent commit/receipt cleanup guard. |
| 156 | Step53 추천 | 실제 Run 수명 및 voluntary/forced Active stage·노출·race integration; 범위는 Step51/52 결과로 조정. |
| 157 | Settlement UI 순서 | Settlement UI는 데이터 책임 인수 계약 구현 후. 지금 버튼/UI 추가0. |
| 158 | Economy 순서 | Economy는 obligation 의미와 소비 책임 안정 후; penalty 수치 미정. |
| 159 | Save/Load 순서 | Save/Load는 in-memory identity/commit 안정 후; durable transaction/migration 별도. |
| 160 | Main line/function 현재값 | 실제 Main1714줄/93함수; 제품 보존 SHA256으로 증가0 확인. |
| 161 | future Main 증가 예상 | rough Step51 0~15줄/0~1함수, Step52 50~100줄/3~5함수, Step53 30~70줄/2~4함수; 실제 변경 아님. |
| 162 | refactor 판단 | 줄수만으로 Manager 분리하지 않음. 실제 committed ownership 책임이 작은 State 도입 근거. |
| 163 | Snapshot/Disposition 역할 분리 | Snapshot inspection/read model; DispositionState committed ownership. 하나를 다른 쪽 truth로 사용하지 않음. |
| 164 | offline validator | offline validator 범위 밖, 생성0. |
| 165 | Major=1 유지 | Main Major1/D2~4 불변. threshold Audit 결론을 추가 실험으로 뒤집지 않음. |
| 166 | UX 변경 없음 | Next/Resume/레이아웃/실제 표시 UI 변경0; final Next 기존 동작 유지. |
| 167 | 제품 code 변경 | Script/Scene/Resource/State/read model/project 수정0; 이번 제품 diff0. |
| 168 | README 변경 | 기존 README bytes prefix 유지하며 Step50 DESIGN ONLY/NOT IMPLEMENTED 요약만 append. |
| 169 | 보고서 생성 | docs/step50_final_run_disposition_responsibility_contract.md 생성1; 결정표/7 matrices/4사례/178답변 포함. |
| 170 | 삭제 파일 | 삭제0; baseline 모든 비생성 원본 및 이전 검증 자료 유지. |
| 171 | git diff --check | git diff --check와 신규 문서 whitespace 검사 통과; LF→CRLF 안내는 Git 기존 줄바꿈 정책. |
| 172 | staged 여부 | staged0 유지. add/commit/push 실행0. |
| 173 | 기존 변경 보존 | Step39/Step49 보고서와 README 원래 prefix byte 보존; hash 결과는 §14. |
| 174 | commit/push 없음 | commit/push 없음; HEAD/branch/upstream 불변. |
| 175 | 아직 미정 사항 | Run trigger/quota/경제/consequence/공개 UI/world continuity/Campaign/Save/version migration/ID 생성 구현 미정. |
| 176 | 최종 책임 계약 요약 | 요청≠reset; Pending 선행; 전항목 atomic 수락에서 이전; Run key1결과; 실패원본보존; 실제 사실만. |
| 177 | 구현 준비도 | 계약 READY FOR IMPLEMENTATION, 제품 NOT IMPLEMENTED. F07-B 완료를 주장하지 않음. |
| 178 | 다음 Step 최종 추천 | Step51 ownership Record/State의 isolated in-memory 계약 구현부터. 실제 종료 UI/경제/Save를 먼저 만들지 않음. |

## 14. 최종 integrity 결과

- baseline 비생성 파일116개 중 기존 README만 append; 나머지115개 SHA256 동일. 제품100개/Step39/미추적 Step49 포함.
- 이전 `.godot/verification` 파일50,890개의 SHA256 동일; Step50 자체 검사 디렉터리는 별도 생성.
- README 시작 bytes 전체 보존. Step50 신규 문서1개 외 추가 비생성 파일0, 삭제0, staged0.
- Main1,714줄/93함수 불변, HEAD/branch/upstream 불변. `git diff --check` 및 신규 문서 whitespace 검사 통과.
- §13의 번호1~178 연속/중복0, 결정표·7개 책임 matrix·사례A~D·duplicate/retry/half-write 명세 포함.
- 새 Godot/GPU 실행0; 현재 실행 검증을 했다고 주장하지 않음. 새 검사 결과는 `.godot/verification/step50/verification.json`에 보관.

## 15. 성공 기준 10개에 대한 답

1. 책임 이전 시점: recipient의 전체 Record+receipt 원자적 공개 순간. 통보/cleanup은 그 뒤다.
2. 중복 방지: Run terminal key1개와 불변 typed source entry key; boundary/phase 변화는 새 transaction이 아니다.
3. 전환 실패 owner: commit 전 source, commit 후 recipient. ack 불명이면 원본 동결/receipt 조회로 판별한다.
4. Outcome 없는 Pending: 판정 근거가 없으므로 UNKNOWN 제출이다. Success/Failure 어느 쪽도 만들지 않는다.
5. 미발현 D: 실제 발생 증거가 없으므로 unmanifested 의무이며 환경 발생 fact를 만들지 않는다.
6. Major-ready: 대응 준비와 실제 시작이 다르다. final conversion 정책이므로 Broadcast를 강제 재생하지 않는다.
7. forced Active: underlying stage/확정 Option/실제 Result 노출/Research와 잔여 책임만 기록; draft 확정/자동 완료0.
8. completed: 유효 완료 응답이 역사 증거다. Failure Resolution로 후보/의무를 재생성하지 않는다.
9. Archive/obligation: 실제 발견 정보와 처리 책임은 별개다. 의무 인수는 hidden Research 공개가 아니다.
10. 첫 구현: 작은 in-memory RunDispositionRecord+ownership State의 전체 수락/거절/dedup부터 시작한다.
