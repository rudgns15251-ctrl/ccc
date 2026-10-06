# Step51 — In-Memory Run Disposition Record + Ownership State

2026-10-06 · Godot `4.7.1.stable.official.a13da4feb` · GDScript · Windows.

**IMPLEMENTED: 독립 in-memory ownership recipient와 immutable-style value Record. NOT IMPLEMENTED: 실제 Run closure / conversion / Gameplay ownership transfer.** Main에는 연결하지 않았다. 명시적 fixture Record 전체를 검증하고, Run ID마다 결과1개와 receipt를 메모리에서 소유한다. 동일한 재요청은 기존 receipt를 반환하고, 다른 내용/경계의 요청은 CONFLICT로 거절한다.

F07-B: **PARTIALLY ADDRESSED**. `OWNERSHIP RECIPIENT IMPLEMENTED / CLOSURE INTEGRATION NOT IMPLEMENTED`이며 RESOLVED가 아니다. Step50의 요청→준비→인수 계약 중 recipient만 구현했다.

## 1. 작업 전 조사와 기존 변경 보호

HEAD `d6d9e4efe625d1688d475e326f8c723d357540a5`, `master`→`origin/main`, remote `https://github.com/rudgns15251-ctrl/ccc.git`. 시작 staged0, 미커밋 상태는 다음과 같다.

```text
 M README.md
 M docs/step39_case_evidence.md
?? docs/step49_major_predictability_threshold_audit.md
?? docs/step50_final_run_disposition_responsibility_contract.md
```

Step39 트리2줄의 공백→탭 편집, Step49/50 README append, 두 미추적 보고서를 baseline으로 보존한다. 전체 비생성 inventory117파일, project.godot, configured Main Scene/Script, 기존7 RefCounted State, read model, UID, verification 구조, README 및 Step50 계약을 조사했다. 적용할 AGENTS.md는 저장소/상위 경로에 없다.

시작 Scene15/GDScript40/Case Resource3/runtime State7/read model1/Autoload0이다. 현재 Main1,714줄/93함수, Case01→02→03, logical1920×1080/초기1280×720/canvas_items/keep/resizable/GL Compatibility를 보존한다. 현재 Candidate는 source_case_id, Response는 source_case_id+incident_id, Pending/Resolution은 authored case_id 기반 세션 기록이다. 새 타입이 이 State들을 읽거나 변환하지 않는다. 현재 Case03 Outcome 없음/Next 비활성/Snapshot read-only를 유지한다.

## 2. 생성·수정 범위

| 이번 변경 | 파일 / 책임 |
|---|---|
| 새 제품 Script | `scripts/runtime/run_disposition_record.gd`: detached primitive 값 보관/복사/정규화 |
| 새 제품 Script | `scripts/runtime/run_disposition_state.gd`: 전체 구조 검증/단일 Run 인수/receipt/lookup |
| 새 UID | 위 두 Script의 `.gd.uid`: Godot editor import가 생성; UID를 임의 작성하지 않음 |
| 새 보고서 | `docs/step51_run_disposition_ownership_state.md` |
| 수정 | README 기존 bytes 뒤에 Step51 요약만 append |
| ignored 검사 자료 | `.godot/verification/step51/`: 독립 fixture, runner, smoke 사본, 결과·로그·baseline/certification |

기존 제품 파일 수정0, Main0, Scene0, Resource0, 기존7 State0, Snapshot0, UI0, project0, 삭제0. runtime 폴더는 기존 convention을 따라 State8개+value Record1개가 됐다. value object 때문에 새 `models/` 계층을 만들지 않았다. 총 GDScript42/Scene15/Autoload0이다. Main에 var/preload/종료 API를 추가하지 않았다.

## 3. Record 입력과 immutable-style 계약

`RunDispositionRecord`는 `RefCounted`이며 Resource/Node/Gameplay State가 아니다. constructor는 Dictionary envelope를 받아 **저장 안전성만 먼저** 검사하고 Dictionary 키를 정규화한 독립 복사본을 보관한다. 일부 구조적으로 invalid한 Record도 만들 수 있고, 최종 structural/identity 검증은 State가 한다. assertion으로 잘못된 fixture 생성을 막지 않는다.

```gdscript
var record := RunDispositionRecord.new({
    "run_instance_id": "RUN_TEST_001", # Caller가 제공; 발급 시스템 없음.
    "boundary_type": "VOLUNTARY_RUN_END",
    "historical_facts": [], "obligations": [],
    "discoveries": [], "hypotheses": [],
})
var recipient := RunDispositionState.new() # Caller가 수명 소유.
var result: Dictionary = recipient.try_commit(record)
# result.status == "COMMITTED"; 실제 Gameplay 종료를 호출하지 않는다.
```

envelope는 위 정확한6필드다. run_instance_id는 nonblank String, boundary는 VOLUNTARY_RUN_END/FORCED_RUN_END만 허용하고 네 category는 Array다. receipt는 envelope에 넣지 않고 State가 소유한다. 새로운 envelope 확장이 필요하면 후속 schema 계약부터 명시적으로 수정한다. unknown top-level/entry field를 silently 무시하지 않는다.

허용 값은 null/bool/int/finite float/String/Array/Dictionary이다. Dictionary 키는 String 또는 GDScript dot assignment에서 생기는 StringName을 허용한 뒤 **String으로 정규화**한다. StringName 값/Vector/packed array/Object/Node/Resource/Callable/RNG/View/Runtime/State는 거절한다. NaN/Infinity도 거절한다. identity는 trim하여 바꾸지 않고 leading/trailing whitespace 또는 빈 ID를 거절한다.

순환 Array/Dictionary/혼합 graph는 ancestor의 참조 identity로 검사하고 복사 **전에** 거절한다. 최대64 container 깊이를 정한 stack 보호도 있다. 같은 acyclic Dictionary를 두 sibling에서 참조하는 것은 cycle이 아니므로 허용한다. 안전성을 확인한 뒤 recursive normalized copy로 각 입력 container를 분리한다. 잘못된 primitive 입력은 `_input_issue`만 남기며 State는 INVALID를 반환한다.

`to_dictionary()`는 매번 `duplicate(true)`를 반환한다. set/add/remove mutation API는 없다. **GDScript의 `_data` 접근 자체를 언어가 차단하지는 않는다.** State는 caller-owned Record의 참조를 저장하지 않고, 새 detached Record와 primitive snapshot을 staging하여 보관한다. fixture는 caller의 `_data`를 직접 바꿔도 이미commit한 State의 결과가 바뀌지 않음을 검사한다. State 자체의 private 필드를 의도적으로 조작하는 개발자까지 차단하는 보안/불변성 장치라는 주장은 하지 않는다.

## 4. Entry schema와 typed identity

모든 entry는 `identity_domain / source_case_definition_id / source_case_instance_id / entry_kind / actual_facts`를 가진다. source IDs/kind/domain은 nonblank String, actual_facts는 primitive Dictionary다. phase는 optional nonblank String payload다. EVENT만 optional nonnegative int created_order를 가진다. 같은 created_order 숫자는 허용하며 identity로 사용하지 않는다. Record parent의 Run ID를 상속하므로 entry에 run ID를 중복 저장하지 않는다.

| Category | identity_domain / entry_kind | 추가 identity field |
|---|---|---|
| historical_facts | RESOLUTION / RESOLUTION_FACT | 없음 |
| historical_facts | EVENT / COMPLETED_RESPONSE_FACT | incident_id |
| obligations | SUBMISSION / UNRESOLVED_SUBMISSION 또는 INVALID_UNRESOLVED_REFERENCE | 없음 |
| obligations | EVENT / UNMANIFESTED_FAILURE_OBLIGATION, DISTURBED_UNRESPONDED, READY_BUT_UNRESPONDED_OBLIGATION, INTERRUPTED_RESPONSE, INVALID_UNRESOLVED_REFERENCE | incident_id |
| discoveries | DISCOVERY / RESEARCH_DISCOVERY | entry_id |
| hypotheses | HYPOTHESIS / WORKING_HYPOTHESIS | hypothesis_id |

Success/Failure, 실제 D, confirmed Option/Result 노출, 사용자 메모는 actual_facts의 명시적 fixture 값이다. 실제 D/confirmed Option을 동일 사건의 새 EVENT entry로 여러 번 만들지 않고 판정/응답 entry의 nested actual_facts에 담는다. 이렇게 하면 완료 EVENT와 unresolved EVENT의 중복 책임을 엄격히 거절하면서 필요한 보조 사실도 표현할 수 있다. authored Resource lookup이나 실제 발생 판정은 수행하지 않는다.

UNKNOWN은 필요할 때 actual_facts의 명시적 `"UNKNOWN"`(또는 null)로 표현한다. fixture C는 result_displayed UNKNOWN과 confirmed Option을 별개로 보존한다. Validator가 confirmed ID를 보고 표시 사실을 true/false로 추측하지 않는다. actual_facts 내부 필드의 Gameplay 의미/진실성은 미래 caller/builder 책임이다.

typed key는 Run ID+assignment+domain의 String tuple이고 EVENT/DISCOVERY/HYPOTHESIS는 각각 Incident/entry/hypothesis ID를 추가한다. String tuple을 JSON으로 encode하므로 단순 구분자 결합의 충돌에 의존하지 않는다. arbitrary Dictionary hash/string order를 비교 키로 쓰지 않는다.

```text
SUBMISSION: (run_id, assignment, SUBMISSION)
RESOLUTION: (run_id, assignment, RESOLUTION)
EVENT:      (run_id, assignment, EVENT, incident_id)
DISCOVERY:  (run_id, assignment, DISCOVERY, entry_id)
HYPOTHESIS: (run_id, assignment, HYPOTHESIS, hypothesis_id)
```

동일 typed key는 모든 category를 통틀어 reject한다. phase/kind/created_order가 달라도 같은 EVENT이면 중복이다. completed historical EVENT와 interrupted obligation EVENT도 reject한다. SUBMISSION과 RESOLUTION은 다른 domain이지만 같은 assignment의 미판정 제출+확정 판정은 별도 상호 배타 검사로 reject한다. 같은 assignment의 definition ID도 일치해야 한다. 서로 다른 assignment의 authored definition/incident ID 재사용과 다른 Run의 같은 assignment는 허용한다.

semantic equality는 Run/boundary/네 ordered category의 전체 payload다. Dictionary 키를 재귀적으로 정규화하고, 비교할 때도 key iteration order에 의존하지 않는다. **Array 순서는 의미가 있으며** category list/nested Array를 뒤집으면 conflict다. primitive 타입도 비교하므로 int1과 float1.0은 다른 payload다. Receipt는 equality에 포함하지 않는다.

## 5. State commit point / 결과 / lookup

`RunDispositionState`는 RefCounted로, `_committed: run_id → {record, receipt}`만 보유한다. Run terminal key는 **Run ID 하나**이며 boundary를 키에 넣지 않는다. 별도 Manager/Singleton/Autoload/Run History 정렬 목록은 없다. 지금은 ID lookup과 committed count만 필요하므로 ordered commit list/list API도 만들지 않았다.

```text
try_commit(caller Record)
 → primitive 안전한 independent staging snapshot
 → 전체 envelope/category/entry/typed identity/conflict 검사
 → 이미commit한 Run이면 전체 semantic comparison
 → 새 Run이면 receipt와 전체 data를 함수 local에서 준비
 → _committed[run_id] = {record: data, receipt: receipt}   ← COMMIT POINT
 → detached result Dictionary 반환
```

이 함수는 await/callback/signal/항목별 publish가 없다. 마지막 단일 index assignment 전에는 새 결과가 공개되지 않는다. 실제 source State를 읽거나 삭제하지 않으므로, 이 commit은 **isolated recipient commit**이지 Gameplay 책임 이전이 아니다. 실패 시 원본 gameplay 보존/실제 retry 준비는 Step52 통합 책임이고 이번 State는 결과 storage 변경0만 보장한다.

| status | 의미 | receipt / 기존 결과 |
|---|---|---|
| COMMITTED | valid 새 Run 전체 수락 | 신규 deterministic receipt, 결과1 |
| ALREADY_COMMITTED | boundary 포함 전체 semantic duplicate | 기존 receipt, 기존 결과 유지 |
| CONFLICT | 같은 Run의 boundary 또는 payload가 다름 | 기존 receipt 제공, 덮어쓰기/새 결과0 |
| INVALID | primitive/구조/identity 위반 또는 null Record | receipt 없음, Run ID 점유0 |

결과 Dictionary는 `status/run_instance_id/receipt/reference_issue`다. invalid primitive envelope를 보관하지 못한 경우 run_instance_id는 빈 String이며 진단이 이유를 설명한다. 일반 INVALID/CONFLICT는 engine error/warning 대신 반환 상태로 표현한다. invalid 입력을 자동 dedup/fix하거나 누락 항목을 임의 생성하지 않는다.

receipt는 `{run_instance_id, receipt_id: "RUN_DISPOSITION_RECEIPT::" + run_id}`다. 이 namespace와 run ID의 결합은 같은 State의 같은 Run에 deterministic이고 다른 Run에는 다르다. receipt는 인수 확인 값이며 random UUID 발급기/Save durability/보안 토큰이 아니다. 독립 State들 사이의 persistent transaction identity까지 제공하지 않는다.

공개 lookup은 `has_committed_run`, `get_committed_record`, `get_commit_receipt`, `get_committed_run_count`다. record/receipt는 deep copy Dictionary, missing 조회는 `{}`/false다. 전체 map/내부 Record instance를 반환하지 않는다. remove/overwrite/force_commit/reset API는 없다. caller가 State 수명을 명시적으로 보유하며 Record caller 참조가 사라져도 결과가 유지된다. 프로세스 종료 후에는 사라지고 disk/crash consistency가 없다.

## 6. Step50 계약 대응

| Step50 계약 | Step51 구현 / 아직 하지 않은 것 |
|---|---|
| 결과 소유자가 전체 수락 | 모든 category 검증 후 단일 index 공개; 실제 source와 연결0 |
| Run별 terminal result1 | Run ID key, boundary conflict도 결과2개 생성0 |
| duplicate entry0 | typed tuple 전역 중복 reject, completed/interrupted 배타 |
| 거절 시 half-transfer0 | INVALID/CONFLICT에서 index mutation0; 실제 source cleanup은 없음 |
| caller와 detached ownership | constructor/output copy 및 State-owned staging; caller Record alias0 |
| receipt retry | deterministic 기존 receipt lookup/반환; closure request 재준비는 미구현 |
| 유효 Pending 판정 선행 | 이번에 Pending/Resolution State 접근0; fixture structural conflict만 검사 |
| actual fact/obligation/Research/notes 분리 | 네 category 및 primitive actual_facts; 자동 discovery/penalty0 |
| forced Active 사실 보존 | 명시적 fixture의 interrupted payload 수락; 실제 workflow conversion0 |
| Main보다 긴 recipient 수명 | isolated caller가 State 참조 보유; Main lifecycle integration0 |
| 무작위 threshold/UI 유지 | 기존 source hash 동일; D2~4/M1/pacing/ordering/UI 변경0 |

## 7. 신규 실행 검증

인증된 최종 실행 **52개**: editor import1 + 제품42Script check-only + configured Main headless1/native1 + ownership fixture1 + 기존 핵심 smoke6. 모두 Godot4.7.1 새 실행이며 과거 Step49 결과를 실행 수로 합치지 않는다.

| 검사 | 결과 |
|---|---|
| 독립 ownership fixture | **274 assertions / invalid fixture52 / failed=false** |
| valid A | Success Resolution1+unknown submission1, COMMITTED |
| valid B | Failure2/actualD payload+M-ready/D-not-ready EVENT2+발견/메모, COMMITTED |
| valid C | FORCED/Interrupted/confirmed Option+Result exposure UNKNOWN, COMMITTED |
| valid D | Failure+Completed Response historical, EVENT obligation0, COMMITTED |
| duplicate/conflict | 동일 Record10회 재요청/키 순서 normalization, boundary/payload/Array order/type conflict; 기존 결과/receipt 유지 |
| isolation | constructor input, Record output, caller private Record mutation, State getter, receipt output, caller lifetime 모두 통과 |
| malformed | late category, missing identity, duplicate4category, phase duplicate, completed/interrupted, submitted/resolved, primitive objects/Callable,3종 cycle,depth limit 통과 |
| identity | same authored definition/incident 다른 assignment, 다른 Run 같은 assignment, SUBMISSION/EVENT domain 분리 통과 |
| Step46 Snapshot smoke4 | normal199 / phases219 / response192 / isolation81 =691 checks |
| Step47 ordering smoke | 1,569 assertions; invalid content retain/skip의 예상 warning4 |
| Step48 gate smoke | 1,144 assertions; warning0 |
| configured Main native | AMD Radeon RX6800/OpenGL3.3 Compatibility, 정상 exit0; 신규 native screenshot audit는 수행하지 않음 |

전체 fixture/smoke **3,678 assertions** 통과. 최종52실행의 runtime/script/parse error0, 정상 warning0; ordering invalid fixture의 예상 warning4를 구별했다. threshold 대안 simulation/전체Journey matrix를 다시 실행하지 않았다. 기존 source byte 불변과 핵심 smoke로 범위를 검증했다.

개발 중 수정한 문제: 첫 primitive guard가 GDScript dot assignment의 StringName 키를 거절해 valid event fixture를 INVALID로 만들었다. StringName **키만** String으로 정규화하여 해결했고, 최종 fixture가 통과했다. 초기 실패 fixture의 후속 접근 오류/timeout은 해당 개발 시도의 결과이고 최종 인증 실행에 포함하지 않았다. 첫 sandbox 실행은 Windows root certificate store 접근과 기본 사용자 editor settings 저장이 제한됐다. 전용 APPDATA/LOCALAPPDATA를 Step51 내부로 두고 허용된 Godot 실행 환경에서 다시 검사하여 최종 import/실행 error0을 확인했다. 제품 project 설정을 바꾸어 우회하지 않았다.

검증 사본은 Step49/base48의 Script/Scene282개를 Step51/smoke로 복사하고 내부 verification 경로만 바꾼 것이다. 출력 JSON/PNG/log는 새 경로에 보관하며 기존 검증을 덮어쓰지 않았다. 제품이 새 recipient를 호출하지 않는 것은 Main·기존 State·Snapshot hash 및 참조 검색으로 확인한다.

## 8. Git / 미구현 범위 / 다음 단계

기존 비생성117개 중 README 원래 bytes prefix를 보존하며 append1개만 변경한다. 기존116개(제품100개/Step39/Step49/Step50 등)는 SHA256 동일하다. 이전 검증 자료50,890개의 SHA256도 기존 baseline과 비교한다. staged0/삭제0, HEAD/branch/upstream 불변, commit/push0. 신규 비생성 파일은 제품Script2+UID2+보고서1이다. git diff에는 원래 Step39 편집과 Step49/50 README append도 보이므로 이를 이번 변경으로 오인하지 않는다.

미구현: RunState/Run 시작·ID 발급/CaseAssignment 생성/closure request·prepare·Main API/hidden Pending resolve/Candidate conversion/Snapshot converter/Plan class/실제 Active voluntary·forced integration/cleanup/Settlement/UI/Economy/Quota/CR/Save/Campaign/Scripted Facility Event/Severity/Case04/Case03 Outcome. 기존 Scene/UI/threshold/pacing/ordering을 변경하지 않았다.

Step52는 명시적 developer closure API와 **source→plan→recipient** 사이 live identity/정합성 검증·valid Pending 선행 판정·receipt 확인을 좁게 연결하는 다음 후보이다. 실제 Run/assignment ID의 caller 수명·mapping을 먼저 확정해야 한다. 현재 arbitrary fixture는 실제 Gameplay 사실의 증거가 아니므로, 이번 structural validator를 builder의 의미 검증 대체물로 사용하지 않는다. voluntary/forced workflow 통합은 그 뒤 Step53에서 판단한다.

이번 범위의 미해결 P0/P1/P2/P3 제품 결함은 발견하지 않았다. 검증은 recipient의 명시적 schema와 현재 smoke 범위이며 전체 미래 gameplay/crash/persistence를 입증하지 않는다.

## 9. 요청한 174개 종료 보고 항목

| 번호 | 요청 항목 | 답변 |
|---|---|---|
| 1 | 작업 전 Git 상태 | modified README/Step39, untracked Step49/50 보고서; staged0. §1 원본 status 보존. |
| 2 | HEAD | d6d9e4efe625d1688d475e326f8c723d357540a5 불변. |
| 3 | branch/upstream | master→origin/main 불변; fetch/branch 작업 없음. |
| 4 | 기존 Step39 편집 | 트리2줄 공백→탭 사용자 편집 byte/hash 보존. |
| 5 | Step49 변경 | 기존 Step49 보고서와 README 요약 보존; Audit 재작성/대안 재실행 없음. |
| 6 | Step50 변경 | Step50 책임 계약 문서와 README 요약 보존; DESIGN ONLY 내용 수정0. |
| 7 | Step50 계약 재확인 | whole accept commit point/Run key1/실패원본보존/actual facts 분리 계약; recipient 부분만 구현(§6). |
| 8 | 새 Record 이름 | RunDispositionRecord. |
| 9 | 새 Record 위치 | scripts/runtime/run_disposition_record.gd; 새 models 계층 만들지 않음. |
| 10 | Record base type | RefCounted; detached immutable-style primitive value. |
| 11 | Gameplay State 여부 | Gameplay State 아님; 실제 State 조회/변환0. |
| 12 | Resource 여부 | Resource/.tres 아님; Resource instance 거절. |
| 13 | Node 여부 | Node 아님; Node instance 거절. |
| 14 | Record envelope | 정확한6필드 run/boundary/historical_facts/obligations/discoveries/hypotheses. |
| 15 | run_instance_id | nonblank String caller fixture ID; 실제 발급기0. |
| 16 | boundary_type | VOLUNTARY_RUN_END/FORCED_RUN_END provenance; terminal key 아님. |
| 17 | historical_facts | RESOLUTION_FACT/COMPLETED_RESPONSE_FACT; 판정/D/선택은 actual_facts payload, 자동 의미 판정0. |
| 18 | obligations | Step50 vocabulary6종 지원; 동일 EVENT의 중복 phase/kind reject. |
| 19 | discoveries | RESEARCH_DISCOVERY의 source assignment+entry ID; Archive 읽기/해금0. |
| 20 | hypotheses | WORKING_HYPOTHESIS의 assignment+hypothesis ID+primitive actual_facts 텍스트. |
| 21 | receipt Record 포함 여부 | receipt는 Record에 포함 안 함; State가 record와 함께 소유. |
| 22 | constructor deep copy | primitive/cycle 안전성 확인 후 recursive normalized detached copy; 입력 container alias0. |
| 23 | output deep copy | to_dictionary마다 duplicate(true); getter output 변조 무영향. |
| 24 | public mutation API | set/add/remove mutation API 없음. getter/진단/값 비교만. |
| 25 | immutable-style 한계 | GDScript private 접근은 언어가 차단하지 않음; public 계약과 copy isolation이며 보안장치 아님. |
| 26 | primitive-only | JSON형태 null/bool/int/finite float/String/Array/Dictionary; StringName 키만 String 정규화. |
| 27 | Node reject | nested Node input INVALID; fixture 후 Node free, 저장/receipt0. |
| 28 | Resource reject | Resource/RefCounted/RNG object nested input INVALID. |
| 29 | Callable reject | Callable nested input INVALID; warning/error를 API failure로 쓰지 않음. |
| 30 | cyclic container reject | ancestor is_same 검사; Array/Dictionary/mixed cycle 거절, acyclic shared alias 허용; 깊이64 제한. |
| 31 | typed identity | parent Run+assignment+typed domain(+해당 ID), category 전역 중복 검사. |
| 32 | SUBMISSION key | (run, assignment, SUBMISSION); Room/phase로 새 identity 만들지 않음. |
| 33 | RESOLUTION key | (run, assignment, RESOLUTION); 판정payload는 identity 아님. |
| 34 | EVENT key | (run, assignment, EVENT, incident); phase/kind/order 변경도 같은 사건. |
| 35 | DISCOVERY key | (run, assignment, DISCOVERY, entry_id). |
| 36 | HYPOTHESIS key | (run, assignment, HYPOTHESIS, hypothesis_id). |
| 37 | source definition ID | nonblank authored lookup ID; 같은 assignment에서는 일치, 다른 assignment 재사용 허용. |
| 38 | source instance ID | fixture explicit source_case_instance_id; generator/assignment system0. |
| 39 | incident ID | EVENT 필수 nonblank incident_id; SUBMISSION에 가짜 incident field 거절. |
| 40 | entry_kind | category/domain에 맞는 kind만 수락; discriminator는 typed key에 포함하지 않음. |
| 41 | phase | optional nonblank String payload; 실제 phase의 truth는 후속 builder 책임. |
| 42 | actual_facts | primitive Dictionary 필수; confirmed/result/D/UNKNOWN/메모를 fixture로 표현. Gameplay 진실성 검사0. |
| 43 | created_order | EVENT optional nonnegative int relative order; 동일 숫자 허용, key로 사용0. |
| 44 | UNKNOWN 표현 | 명시적 UNKNOWN String 또는 null; ID로 display/success/failure 추측0. |
| 45 | Record equality | 전체 Run/boundary/네 ordered category payload; numeric type까지 구별, receipt 제외. |
| 46 | Dictionary normalization | Dictionary 키 String 정규화/정렬; semantic 비교는 key order 무관. hash/임의 출력 순서 의존0. |
| 47 | Array order 의미 | Array 순서까지 semantic equality; category/nested Array 무조건 sort0. |
| 48 | 새 State 이름 | RunDispositionState. |
| 49 | State 위치 | scripts/runtime/run_disposition_state.gd. |
| 50 | State base type | RefCounted; 독립 explicit caller가 수명 보유. |
| 51 | Manager 여부 | Manager 생성0. |
| 52 | Singleton 여부 | Singleton 생성0. |
| 53 | Autoload 여부 | Autoload0/project 변경0. |
| 54 | State responsibility | whole validation/atomic accept/Run terminal index/receipt/duplicates/conflict/lookup만. |
| 55 | internal index | _committed: String Run ID→record+receipt pair; 내부 map 공개0. |
| 56 | canonical terminal key | run_instance_id 하나; 같은 Run final result1. |
| 57 | boundary key 여부 | boundary는 value/equality에 포함, dedup key 아님. |
| 58 | commit API | try_commit(record) 단일 entry point; Record/null 입력과 명시 상태 반환. |
| 59 | commit success | fullvalidate→State-owned staging→receipt→단일 index assignment→COMMITTED. |
| 60 | receipt 구조 | primitive run_instance_id/receipt_id 두 필드; State 소유. |
| 61 | receipt 생성 방식 | RUN_DISPOSITION_RECEIPT:: + caller Run ID; random/UUID 시스템0. |
| 62 | receipt determinism | 같은 committed Run 재조회/duplicate에서 동일 receipt. |
| 63 | receipt uniqueness | 서로 다른 Run ID의 receipt는 다름; 독립 State 간 durable transaction uniqueness 주장0. |
| 64 | COMMITTED | valid 새 Run 전체 수락; 새 data+receipt 한 번 publish. |
| 65 | ALREADY_COMMITTED | 전체 semantic duplicate, 기존 data/receipt 유지, 새 결과0. |
| 66 | CONFLICT | same Run 다른 boundary/payload 거절, 기존 receipt 제공, overwrite0. |
| 67 | INVALID | primitive/구조/identity invalid/null 거절, 새 기록/receipt/Run점유0. |
| 68 | exact duplicate | RUN_A 동일 Record10회 ALREADY_COMMITTED, count 유지 fixture 통과. |
| 69 | boundary conflict | voluntary→forced 동일 Run은 CONFLICT; 기존 receipt 유지. 새 terminal result0. |
| 70 | payload conflict | 확정Room payload/Array순서/numeric type 변경도 CONFLICT; 기존data 유지. |
| 71 | invalid mutation 없음 | full validation 전 index 변경0; malformed late hypothesis 뒤 앞 historical 저장0. |
| 72 | whole validation | envelope/categories/identity/kinds/assignment definition/typed duplicate/submitted-resolved 전체 검사. |
| 73 | private staging | 함수 local detached Record/data/receipt 준비; 기존 map을 변경하며 검증하지 않음. |
| 74 | partial publish 없음 | 마지막 단일 assignment만 publish, await/signal/callback 없음. |
| 75 | duplicate entry reject | 네 category duplicate typed entry 전부 reject; 자동 dedup/부분 수락0. |
| 76 | phase duplicate | 같은 EVENT M-ready/interrupted phase payload가 달라도 duplicate reject. |
| 77 | completed/interrupted conflict | historical COMPLETED_RESPONSE_FACT+INTERRUPTED_RESPONSE 같은 EVENT reject. |
| 78 | submission/resolution conflict | 같은 assignment SUBMISSION+RESOLUTION reject 권고 채택. |
| 79 | discovery duplicate | 같은 source+entry DISCOVERY 두 번 reject. |
| 80 | hypothesis duplicate | 같은 source+hypothesis ID 두 번 reject. |
| 81 | created_order 처리 | 같은 created_order 숫자는 valid B에서 허용; negative/float는 invalid. |
| 82 | getter | has_committed_run/get_committed_record/get_commit_receipt/get_committed_run_count. |
| 83 | getter isolation | record/receipt는 detached Dictionary; missing은 빈 Dictionary/false. |
| 84 | internal Dictionary leak | 내부 map/Record instance 반환0. 반환 Dictionary를 바꿔도 ownership 불변. |
| 85 | remove API | remove_run API 없음. |
| 86 | overwrite API | replace/force_commit/overwrite API 없음. |
| 87 | reset API | reset/clear API 없음; isolated 테스트는 새 State 사용. |
| 88 | invalid then valid | RUN_Z invalid→기록0/receipt0→valid COMMITTED fixture 통과. |
| 89 | conflict then lookup | boundary/payload conflict 뒤 lookup/receipt/count 원래값 유지. |
| 90 | multi-run | A/B/C/D 및 추가 fixture Run의 저장 domain 독립. |
| 91 | cross-run assignment | 다른 Run 같은 CASE_1/CASE_2 assignment는 독립 저장. |
| 92 | repeated authored definition | DEF_SHARED가 한 Run의 CASE_1/CASE_2에 재등장해도 허용. |
| 93 | same incident ID different assignment | INCIDENT_SHARED가 다른 assignment의 EVENT2개에서 충돌하지 않음. |
| 94 | typed domain separation | 같은 assignment SUBMISSION/EVENT는 다른 domain; submitted/resolved만 별도 배타 검사. |
| 95 | valid fixture A | Success Resolution1+unresolved submission1 valid A COMMITTED. |
| 96 | valid fixture B | Failure2/actualD payload/M-ready1/DNR1/발견2/메모2 valid B COMMITTED. |
| 97 | valid fixture C | FORCED/Interrupted/confirmed Option/Result exposure UNKNOWN valid C COMMITTED. |
| 98 | valid fixture D | Failure fact+Completed Response historical, EVENT obligation0 valid D COMMITTED. |
| 99 | duplicate same fixture | 같은 A10회 duplicate→ALREADY_COMMITTED, receipt/count 동일. |
| 100 | boundary conflict fixture | A의 boundary만 forced 변경→CONFLICT/기존receipt/결과1 유지. |
| 101 | payload conflict fixture | A의 Room payload 변경→CONFLICT/기존data 유지. |
| 102 | duplicate EVENT fixture | 동일 EVENT obligation 복제 및 phase 다름 모두 INVALID. |
| 103 | completed/interrupted fixture | completed/interrupted 동일 EVENT INVALID/partial publish0. |
| 104 | submission/resolution fixture | unresolved submission/resolution 동일 assignment INVALID. |
| 105 | input isolation | constructor 원본 nested Array/Dictionary 수정 후 Record 불변. |
| 106 | output isolation | Record 및 State getter nested output 수정 후 다음 getter 불변. |
| 107 | State-owned isolation | caller Record._data 직접 수정/참조해제 후에도 State-owned copy 유지. |
| 108 | primitive invalid fixture | Node/Resource/RefCounted/RNG/Callable/Vector/packed array/NaN/Infinity/nonstring key 거절. |
| 109 | cycle fixture | Array/Dictionary/mixed cycle3종 거절; depth limit 거절; shared acyclic graph는 valid. |
| 110 | committed count | explicit committed count getter 제공; 신규 result 증가/duplicate·conflict 무증가 검증. |
| 111 | caller lifetime | fixture local State 참조가 수명 유지; caller Record 해제 후 lookup valid. |
| 112 | Main integration 여부 | Main integration0; _ready var/preload/API 추가0. |
| 113 | Run ID generator 여부 | 실제 Run ID generator0; fixture explicit ID만. |
| 114 | CaseAssignment generator 여부 | CaseAssignment generator0; fixture explicit assignment만. |
| 115 | Snapshot converter 여부 | Snapshot converter0. |
| 116 | Plan class 여부 | FinalRunDispositionPlan class0; value Record/recipient만. |
| 117 | Candidate integration 여부 | CandidateState 읽기/변환/삭제0. |
| 118 | Pending integration 여부 | PendingState 읽기/hidden resolution0. |
| 119 | Response integration 여부 | ResponseState workflow/forced·voluntary conversion0. |
| 120 | Archive integration 여부 | Archive 읽기/merge/Research unlock0. |
| 121 | Hypothesis integration 여부 | WorkingHypothesisState 읽기0; fixture가 전달한 값만. |
| 122 | cleanup 여부 | Gameplay cleanup/reset0. |
| 123 | closure API 여부 | Main/실제 Run closure API0; try_commit은 recipient 함수이며 closure가 아님. |
| 124 | Settlement 여부 | Settlement/Settlement UI0. |
| 125 | Economy 여부 | Economy/Quota/CR/penalty0. |
| 126 | Save/Load 여부 | Save/Load0; process 종료 후 메모리 소실. |
| 127 | Campaign 여부 | Campaign0. |
| 128 | threshold 불변 | D2~4/M1 source byte 보존, 대안 simulation0. |
| 129 | pacing 불변 | Step48 공유 credit/read 경계 source 불변, gate1144 smoke 통과. |
| 130 | ordering 불변 | Step47 oldest actionable source 불변, ordering1569 smoke 통과. |
| 131 | UI 불변 | UI/View/layout source 변경0. |
| 132 | Scene 불변 | 기존15 Scene byte 변경0; 신규 제품Scene0. |
| 133 | Resource 불변 | Case Resource3 및 모든 기존 Resource 변경0; 신규.tres0. |
| 134 | project.godot 불변 | project.godot byte 변경0; Autoload0/기존해상도·Stretch 유지. |
| 135 | Main 불변 여부 | Main byte 변경0, 1714줄/93함수 불변. |
| 136 | 기존 State 불변 여부 | 기존7 State byte 변경0; 새 ownership State1 및 value Record1 추가. |
| 137 | Snapshot 불변 여부 | Step46 Snapshot byte 변경0. |
| 138 | parser | 제품42 Script check-only 새 실행 통과; final parse error0. |
| 139 | editor import | editor import 새 실행 통과; 엔진이 신규 UID2 생성. |
| 140 | configured Main headless | configured Main headless --quit-after20 새 실행 exit0/warning0/error0. |
| 141 | configured Main native | configured Main native --quit-after30 RX6800/OpenGL3.3 새 실행 exit0; 새 화면capture audit는 없음. |
| 142 | isolated fixture | 실제 Godot4.7.1 independent headless fixture1, source Gameplay instantiate0. |
| 143 | assertions | ownership274 + Snapshot691 + ordering1569 + gate1144 =3678 assertions. |
| 144 | warnings | 최종 normal warning0; ordering invalid-content 예상warning4; recipient invalid52도 warning0. |
| 145 | runtime errors | 최종 인증52실행 runtime/script error0. 초기 키 거절에 따른 개발fixture 후속 오류/timeout은 해결/제외. |
| 146 | parse errors | 최종42Script/import 포함 parse error0. |
| 147 | Step46 smoke | Snapshot normal199/phases219/response192/isolation81, read-only regression 통과. |
| 148 | Step47 smoke | ordering1569, invalid retain/skip 예상warning4, source/복귀 계약 통과. |
| 149 | Step48 smoke | gate1144, shared credit/read/Resume/Case03 final 보존 통과. |
| 150 | Major=1 확인 | Main const PROTOTYPE_MAJOR_THRESHOLD1 불변; 기존 fixed State default와 실제 전달값 구분. |
| 151 | 제품 변경 파일 | 기존 제품 수정0; 추가 run_disposition_record.gd/run_disposition_state.gd 및 UID2. |
| 152 | 신규 파일 | 신규 비생성5개=Script2/UID2/Step51보고서1; ignored fixture/runner/smoke 자료 별도. |
| 153 | 삭제 파일 | 삭제0. |
| 154 | README 변경 | 기존bytes prefix 보존, in-memory recipient implemented/actual closure not implemented 요약 append. |
| 155 | 보고서 생성 | docs/step51_run_disposition_ownership_state.md; 구현/미구현/계약대응/검증/174답변. |
| 156 | git diff --check | git diff --check 및 신규파일 whitespace 검사 통과; LF→CRLF 안내는 기존 Git policy. |
| 157 | staged | staged0 유지, git add 실행0. |
| 158 | 기존 변경 보존 | 기존116개 SHA256/README 원래prefix 보존; Step39/49/50 변경 포함. 기존검증50890파일 검사. |
| 159 | commit/push | commit/push0, HEAD/branch/upstream 불변. |
| 160 | F07-B 현재 상태 | F07-B PARTIALLY ADDRESSED 유지; RESOLVED 아님. |
| 161 | Ownership recipient 상태 | OWNERSHIP RECIPIENT IMPLEMENTED; 독립 State가 전체 결과+receipt 메모리 소유. |
| 162 | 실제 closure 상태 | CLOSURE INTEGRATION NOT IMPLEMENTED; 실제 종료 UI/API/변환0. |
| 163 | actual Gameplay ownership transfer 여부 | 실제 Gameplay ownership transfer0; fixture recipient commit과 구별. |
| 164 | atomicity 범위 | 한 함수 호출 내 in-memory 전체 index publish logical atomicity; disk transaction 아님. |
| 165 | crash consistency 여부 | crash consistency 보장0; Save 단계에서 별도 설계 필요. |
| 166 | persistence 여부 | persistence0; caller가 State 수명을 보유하는 동안만 메모리 결과 유지. |
| 167 | 다음 Step52 준비도 | recipient 계약 준비됨; Step52에서 실제source identity/판정/plan/receipt 통합을 별도로 검증해야 함. |
| 168 | 발견 P0 | 이번 검증 범위에서 미해결 P0 발견0. |
| 169 | 발견 P1 | 이번 검증 범위에서 미해결 P1 발견0. |
| 170 | 발견 P2 | 초기 StringName 키 false reject 수정 완료; 최종 fixture 통과, 미해결 P2 발견0. |
| 171 | 발견 P3 | sandbox 인증서/editor profile 제약은 dedicated profile+허용된 실행환경으로 해결; 제품 P3 미해결 발견0. |
| 172 | 최종 구현 요약 | detached Record+whole validator+canonical Run index+deterministic receipt+duplicate/conflict+copy lookup. |
| 173 | 미구현 목록 | Run lifecycle/IDs/closure/Pending resolve/conversion/Active integration/cleanup/Settlement/Economy/Save/Campaign/UI 미구현. |
| 174 | 다음 Step 추천 | Step52 developer closure boundary와 live identity/Pending 선행/recipient 인수·receipt 검증부터; voluntary/forced 통합은 그 뒤. |
