# Step43 — Case02 Resolution + Case03 + Cross-Case Deferred Incident

2026-10-05. Godot 4.7.1 Standard / GDScript / Windows PC / GL Compatibility.

기존 프로젝트를 **Case01 → Case02 → Case03**의 정상 연속 플레이로 확장했다. Case02의 기본 관찰을 최소 보완한 뒤 두 Room 모두에 Prototype Test Outcome을 작성했다. 늦어진 Case01 후보가 Case02 handoff를 넘어 Case03에서 사건을 시작하고 동일한 Case03 Runtime으로 복귀하는 것을 확인했다. 두 Failure 후보, Case02만 Failure, 모두 Success, 마지막 경계의 Deferred 유지도 검증했다.

**Prototype Test Mapping이며 정식 Case 설정이 아니다.** Room01 Success/Room02 Failure는 아래에 설명한 제한된 테스트 관찰의 매핑이다. 장기 안전성·탈출 가능성·정식 Creature 세계관·최종 밸런스를 확정하지 않는다. threshold/RNG/event ordering을 바꾸지 않았고 커밋·push하지 않았다.

## 실제 저장소 조사

시작 Git 상태는 깨끗했고 staged/untracked 변경도 없었다. HEAD는 `ad2beae1a7cbee8836bc8f811abb82740bb0d5d3`, 메시지는 `Improve major incident response content and reading boundaries`다. `master`는 `origin/main`을 추적하고 시작 시 같은 커밋이었다. remote는 `https://github.com/rudgns15251-ctrl/ccc.git`이다.

실제 파일/폴더 inventory, project.godot, Main Scene/Script, 관련 View/Data/7개 State, Case01/02와 Research, Step39/40/41/42 보고서, 기존 검증 소스를 조사했다. 적용할 AGENTS.md는 저장소와 상위 디렉터리에서 발견되지 않았다. 106개 추적 파일과 이전 검증 파일 3,687개의 시작 SHA-256을 기록했다.

- 시작: Case 2개, Scene 15개, GDScript 39개, Autoload 0개.
- Case01: 기존 Outcome/사건/교란/대응/Research가 있음. 이번 단계에서 수정하지 않았다.
- Case02: 기본 4단계와 수신 환경 관찰은 있었으나 Outcome과 source Incident chain이 없었음.
- Case03: 존재하지 않았으며 이번에 새 Resource로 추가함.
- 기존 정상 마지막 Case 정책: Confirm 후 Pending을 유지하며 Next 비활성화. Campaign 완료를 정의하지 않음.
- 기존 event 정책: 교란 먼저, 각 ready 후보군은 State의 `_case_order` FIFO, 한 opportunity 한 표시 event, response 중 advancement 금지.
- Main: 시작 1,542줄/83함수 → 최종 1,563줄/84함수.

프로젝트의 UI 1920×1080, 초기 창 1280×720, canvas_items/기존 keep 및 resizable 기본값, GL Compatibility와 실행 Scene 경로를 보존했다. 기존 Scene/View/Data/State를 전면 재작성하지 않았다.

## Case02 Evidence 재감사와 Test Mapping

Step39에서 Room01은 합리적인 후보였지만 실제 SUCCESS로 인코딩하지 않았음을 재확인했다. 원래 EXP02의 rib tracing/smooth searching과 압력 증가 없음은 장기 격리의 성공·실패를 증명하지 않는다. 따라서 이번에 단순히 기존 Room 번호만 판정으로 바꾸지 않았다.

TEST 목적을 **반복 가능한 벽 추적 경로와 반복 service-grille 탐색의 차이를 비교하는 한정된 prototype sample**로 정했다. 기본 CCTV와 EXP02의 두 텍스트만 보완했다. 관찰은 공격/손상/최종 정답을 선언하지 않고 반복 경로의 차이를 더 명료하게 한다.

| Source | 기존 의미 | 이번 최종 관찰/역할 | 환경 사건 없이 접근 |
|---|---|---|---|
| Profile `TEST_CASE02_PROFILE_01` | 벽 접촉 상실 뒤 탐색; 손상 기록 없음 | 그대로 유지. 접촉 탐색 가설의 문맥이며 안전성 증명은 아님 | Yes |
| CCTV `TEST_CASE02_CAM_01` | 환기 전환에 배출구로 향함; 요철 추적/매끈한 면 옆 탐색 | ribbed tracing은 vent turn 뒤 재개; smooth 검색은 service grille에 반복 도달하고 vent cycling이 검색을 다시 시작시킴; 손상 없음 유지 | Yes |
| EXP01 `TEST_CASE02_EXP_01` | air pulse에 노즐 pivot, fan sound만으로 일관된 pivot 없음 | 그대로 유지. 공기 cue와 소리 cue를 구분; 표면 기능은 이 시험으로 미확정 | Yes, 실제 실행 시 |
| EXP02 `TEST_CASE02_EXP_02` | 요철 자국/매끈한 면 반복 옆 탐색, 압력 증가 없음 | 같은 airflow/lighting의 반복 pass에서 rib는 같은 경로로 돌아가고 smooth search는 service grille에 반복 도달; 압력 증가 없음/환기 주기 미비교 유지 | Yes, 실제 실행 시 |
| Room01 `TEST_CASE02_ROOM_01` | 연속 저풍량 + 날카롭지 않은 요철 + 일반 조명 | 그대로. 반복 tracing의 기준을 제공하고 restart cue를 줄이는 Test 구성 | Yes |
| Room02 `TEST_CASE02_ROOM_02` | start/stop 공기 + 매끈한 패널 + 낮은 조명 | 그대로. 반복 search의 기준을 제거하고 공기 전환 cue를 남기는 Test 구성 | Yes |
| 기존 정전/환기 관찰 | 즉시 반응/정전 CCTV/정전 EXP01 조건 | 전부 보존. 판단에 필요한 CORE를 대신하지 않는 optional supporting evidence | 사건 실제 발생 시만 |

개발자 관점의 TEST Mapping은 다음과 같다.

| Room | Test Outcome | 근거와 한계 |
|---|---|---|
| `TEST_CASE02_ROOM_01` | SUCCESS, incident_id 없음 | 기본 CCTV/표면 비교에서 반복 추적과 연결된 요철을 유지하고, 공기 전환에 대한 반복 방향 반응을 줄이는 구성이므로 한정된 tracing/service-search sample과 일관됨. 정식 장기 안전성 확정 아님 |
| `TEST_CASE02_ROOM_02` | FAILURE, `TEST_CASE02_INCIDENT_01` | 매끈한 면의 반복 grille 접근과 restart cue가 함께 남는 구성. TEST 후속 관찰에서 반복 접근과 service air-line discharge가 이어지는 미정착 상태로 매핑. ‘손상 없음’을 손상/경제/피해로 바꾸지 않음 |

기존 Profile/EXP01/Room 설명/환경 관찰과 기존 Research 6개는 ID와 내용까지 보존했다. 보완된 CCTV/EXP02 및 Room02 제출에 새 authored Research 3개를 붙였다. 기존 fallback 정책은 유지하며, 실제 authored ID가 없는 fallback을 synthetic ID로 Archive에 보존하지 않는다.

CORE Profile+CCTV로 두 구성의 차이를 비교할 수 있고, 두 실험은 공기/소리와 표면 축을 따로 보강한다. 환경 조건 관찰이 없거나 조건 실험을 놓쳐도 Test Mapping 판단에 필요한 단서는 남는다. 관찰만으로 정식 SUCCESS를 보장한다는 주장은 하지 않는다. 사람 플레이테스트로 이해도나 난이도를 측정한 결과도 아니다.

## Case02 Outcome과 최소 downstream

Case02의 모든 후보 Room에 unique Outcome을 제공했다. 두 Outcome의 debug 관찰 Stage는 기존 playback 방식의 0/10/20초 sample이다. 정상 hidden resolution은 이 Timer/Stage를 재생하지 않고 handoff에서 final_result를 기록한다. 새 Timer 지연을 구현하지 않았다.

실패 source는 `TEST_CASE02_INCIDENT_01` — **TEST SERVICE-GRILLE SEARCH INCIDENT**다. 반복 sideways search가 grille에 도달하고 접촉과 local service air discharge가 함께 관찰되며, outlet turn이 다음 search를 바꾸고 반복 wall path가 정착하지 않았다고 설명한다. wrong/correct Room, 실패 Room ID, hidden result enum을 player-facing 사건/대응/Research에 쓰지 않았다.

교란 `TEST_DIST_SERVICE_AIR_PULSES`는 **TEST SERVICE AIR-LINE PULSES**다. `SERVICE AIR-LINE: STEADY -> INTERMITTENT LOCAL JETS`를 표시한다. main ventilation은 기존 설정을 유지한다는 관찰로, 기존 POWER FAILURE/VENTILATION INSTABILITY와 다른 local air-line 현상을 작성했다. 시설 변화의 source는 Case02, 영향을 관찰하는 current subject는 Case03다.

| Broadcast Option | 근거/조치 | 다른 관찰 결과와 남는 문제 |
|---|---|---|
| `TEST_CASE02_OPTION_01_A` | EXP02에 따른 임시 연속 shallow-ribbed contact guide | 반복 tracing 회복/grille search 감소, 남아 있는 air jets는 outlet turn을 계속 유발 |
| `TEST_CASE02_OPTION_01_B` | EXP01 air-vs-sound 근거로 pulsing service line만 격리 | jets/관련 outlet turn은 멈춤, sideways wall searching과 접촉 guide 부족은 남음 |
| `TEST_CASE02_OPTION_01_C` | airborne fan sound 감소; wall/service cue는 유지 | 소리만 비교의 한계와 일치하게 search/air turn 지속; tracing path와 air cue는 미해결 |

Broadcast `TEST_CASE02_BROADCAST_01` prompt는 표면/공기 비교와 현재 현상을 요약한다. 과거 실험을 정확히 외워야만 대응하는 구조가 아니며 Source Archive는 optional이다. 결과 3개와 대응 Research는 조치/관찰/잔여 문제만 설명한다. gameplay consequence, 점수, optimal/correct Option schema는 없다.

Case02 신규 Research는 11개다: CCTV/EXP02/Room02 제출 3개, Incident/Broadcast 2개, confirmed Option 3개, displayed Result 3개. Outcome SUCCESS/FAILURE 자체의 Research는 없다. Incident → Broadcast → Confirm Option → displayed Result의 기존 incremental merge 경계를 재사용한다.

## Case03 Resource

`resources/cases/test_case_03.tres`, case_id `TEST_CASE_03`, display_name `TEST CASE 03`을 추가했다. Case03은 floor strip의 대비와 끊김을 따라가는 하나의 단순 TEST 관찰 테마다.

- Profile: 대비되는 floor strip을 따라가고 gap에서 잠깐 멈춤.
- CCTV: gap에서 pause/turn 후 보이는 strip으로 돌아감; 조명/airflow는 이 sample에서 일정.
- EXP01: 같은 표면/조명/airflow 아래 high/low contrast 비교.
- EXP02: 같은 조건의 continuous/interrupted strip 비교.
- experiment_limit 2, Room 2개: continuous strip/일반 조명과 interrupted strip/낮은 조명; airflow는 두 후보 모두 steady.
- Research 7개: Profile/CCTV/EXP 2/제출 Room 2/local air reaction 1.
- Case02 service-air 교란에 reaction 1개: jet에 strip 밖으로 방향을 바꾼 뒤 보이는 strip으로 돌아옴. 기존 gap pause는 지속.
- Case01 정전/환기에는 matching Case03 reaction을 만들지 않았다. 기존대로 facility-only condition과 observation 없는 Notice가 안전하게 동작한다.
- CCTV/Experiment condition observation은 추가하지 않았다. Outcome/Incident chain도 추가하지 않았다.

Case03은 마지막 TEST Case다. Confirm된 Room/Pending/Research/Hypothesis와 미완료 Candidate를 보존하고 `No next test case configured`로 Next를 막는다. Case03을 임의로 resolution하거나 Campaign Complete로 정의하지 않는다.

## 전환과 최소 코드 변경

Main Scene의 기존 export `case_sequence`에 Case03 Resource를 append했다. 순서는 Data array로 정하며 Main에 Case01→02→03 ID 분기를 추가하지 않았다. `Case02 → Case01 → Case03` reorder fixture도 코드 수정 없이 진행했다.

Main의 기존 handoff는 **유효 다음 Case/현재 Pending/Room/Outcome을 먼저 검증 → hidden Resolution 기록 → Failure Candidate 등록(해당 시) → Pending 제거 → 유효 current discoveries Archive merge → 새 Runtime/PROFILE** 순서다. prompt의 예시 순서를 무조건 가정하지 않고 실제 구현 순서를 보존했다. 유효하지 않은 Outcome은 Archive merge와 Runtime 교체 이전에 반환한다.

이번에 발견한 좁은 validation 공백 두 개만 보완했다.

1. `_has_unique_case_sequence()`를 추가해 null/blank/duplicate Case ID sequence의 startup/advance/handoff를 막는다. invalid startup에서 첫 Case나 Inspector current_case를 fallback으로 선택하지 않고 unavailable Profile과 disabled 버튼을 표시한다.
2. FAILURE Outcome의 incident_id가 실제 current Case의 unique Incident를 가리키는지 hidden record 전에 검사한다. unknown/duplicate Incident에서 Pending/Archive/Resolution/Candidate/Runtime/RNG를 바꾸지 않는다.

이는 전체 ContentValidator나 transaction framework가 아니다. 이후 commit 부분은 이미 검증된 State API들의 동기식 작업이며 await/callback 없이 진행한다. 명시적인 Undo/rollback 시스템을 추가했다는 의미도 아니다. duplicate/missing/undefined Outcome, blank/foreign Incident, 기존 Resolution/Candidate, Pending mismatch, invalid sequence를 통제 fixture로 검사했다.

Runtime은 handoff에서 새 객체가 되지만 Pending/Resolution/Candidate/IncidentResponse/Archive/Hypothesis 객체는 그대로 유지한다. Case02의 환경·실험 이력·Room·Research가 Case03 Runtime으로 승계되지 않는다. **Case01 Candidate는 session record이므로 disturbance/major count/threshold/identity가 그대로 유지된다.** Case02에서 발생한 환경 조건은 Case03으로 자동 복사하지 않는다. Case03에서 실제 발생한 교란만 그 Runtime에 적용한다.

## 이벤트 순서와 핵심 Journey

기존 코드의 실제 우선순위는 **교란 우선**, 교란 ready 후보군과 Major ready 후보군 안에서는 각각 FIFO다. 오래된 Major-ready와 더 새로운 disturbance-ready가 동시에 있을 때도 disturbance가 먼저 표시된다. 이를 전체 후보의 strict oldest-first 완료 정책이라고 표현하지 않는다. ordering fixture로 재확인했고 이번에 순서나 priority/severity를 바꾸지 않았다.

한 action은 Major readiness를 먼저 갱신하고 disturbance 후보를 처리한다. 교란을 표시하면 그 action은 즉시 종료한다. 새 교란 자신의 Major count는 같은 action에서 증가하지 않는다. EXP는 ready를 기록해도 같은 callback에서 Major View로 교체하지 않는다. response 중 모든 opportunity 처리와 nested response를 막는다. Resume는 기존 entry를 다시 소비하지 않는다.

| Scenario | 실제 정상 버튼 경로와 결과 |
|---|---|
| A: Case01 Deferred | Case01 Room01 또는03 Failure → Case02 2실험 후 마지막 CONT에서 threshold4 교란 → Dismiss/Case02 Room01 Success handoff → Case03 PROFILE의 같은 Candidate → CCTV entry에서 Case01 Major → Source Archive Case01/ABC/Result → 동일 Case03 CCTV |
| B: 두 Failure | A와 같이 늦은 Case01 + Case02 Room02 Failure threshold2 → Case03 첫 CCTV에서 Case01 Major → Resume 후 Case02 후보는 count1 그대로 → EXP01에서 service-air 교란 → EXP02 결과 draw/ready → CONT에서 Case02 Major → 동일 Case03 CONT |
| C: Case02만 Failure | Case01 Success → Case02 Room02 Failure → Case03 CCTV/EXP01에서 교란 → EXP02 draw/ready → CONT에서 source Case02 response ABC → 같은 Case03 CONT |
| D: 모두 Success | 두 Resolution Success/incident_id empty, Failure Candidate/Disturbance/Major 없음 → Case03 정상 4단계와 마지막 Pending |
| sequence end | 두 Failure 중 Case02 threshold4 → Case01은 Case03 CCTV에서 완료, Case02 교란은 Case03 마지막 CONT에서 발생 → Major count0의 Case02 Candidate를 Pending과 함께 유지 |

Source Archive 왕복은 실제 Open/Back 버튼을 사용하며 미확정 draft와 confirmed lock을 유지한다. Context는 source Case01 또는02, current Case03, 실제 CCTV 또는CONT resume Stage를 표시한다. 해당 source Archive만 response Research가 증가한다. Current Log는 Case03의 실제 발견 기록과 편집 가능한 개인 메모만 표시한다. Archive 목록은 handoff된 Case01/02 순서를 유지하고 Case03을 과거 Case로 넣지 않는다.

Case03 response 직전/후 Runtime instance ID와 facts/Hypothesis/opportunity key가 동일함을 비교했다. 이전 Case Runtime WeakRef는 handoff 뒤 해제됨을 확인했다. source Runtime을 재생성하지 않는다. 다른 Candidate의 전체 record도 response 중/Resume 뒤 보존됐으며, completed source Candidate만 정확히 제거됐다. 오래된 Case02 EXP/Containment, response/Archive View 신호가 현재 Case03 state를 변경하지 않음도 확인했다.

## 3-Case Reachability 재측정

Case01 Room01 Failure, Case02 Room01 Success, Case01에 1개 실험, Case03에 2개 실험을 사용하는 실제 버튼 Journey다. 기존 RNG seed로 disturbance threshold 2/3/4를 재현하며 제품 상수를 바꾸지 않는다. ‘남은 기회’는 교란 후 Case02에 남은 원래 eligible action 수다.

| 교란 threshold | Case02 실험 수 | 실제 교란 위치 | Case02 남은 기회 | Case03에 후보 carry | 실제 Major 위치 | 도달 |
|---|---:|---|---:|---|---|---|
| 2 | 0 | Case02 CONT | 0 | Yes, disturbed/count0 | Case03 CCTV | Yes |
| 2 | 1 | Case02 EXP01 | 1 | No, Case02에서 완료 | Case02 CONT | Yes |
| 2 | 2 | Case02 EXP01 | 2 | No, Case02에서 완료 | Case02 CONT | Yes |
| 3 | 0 | Case03 CCTV | 0 | Yes, 아직 undisturbed | Case03 CONT | Yes |
| 3 | 1 | Case02 CONT | 0 | Yes, disturbed/count0 | Case03 CCTV | Yes |
| 3 | 2 | Case02 EXP02 | 1 | No, Case02에서 완료 | Case02 CONT | Yes |
| 4 | 0 | Case03 EXP01 | 0 | Yes, 아직 undisturbed | Case03 CONT | Yes |
| 4 | 1 | Case03 CCTV | 0 | Yes, 아직 undisturbed | Case03 CONT | Yes |
| 4 | 2 | Case02 CONT | 0 | Yes, disturbed/count0 | Case03 CCTV | Yes |

새 3-Case pool로 Case01의 late 후보 9개 표본 모두 Major에 도달했다. Case02 source의 threshold2 대응과 threshold4 마지막 Deferred도 별도 정상 시나리오로 확인했다. Case02 source threshold3을 포함한 모든 실험 순서/두 후보 조합을 전수 조사했다고 주장하지 않는다.

**F07: PARTIALLY RESOLVED.** 원래 Case02 뒤 continuation 부재와 Case01 Deferred의 normal 검증 공백은 해결됐다. 그러나 pool은 여전히 3개이며, 마지막 Case03에서 늦게 발생한 Case02 교란 뒤 후속 기회 부족은 남는다. Case04/Case03 Outcome을 추가해 억지로 닫지 않았다.

**F01: 미해결, 값 유지.** 새 pool에서도 disturbed 이후 count1에서 ready가 되고 다음 가능한 CCTV/CONT에 presentation한다는 관계는 강하다. EXP read-boundary와 다른 교란 우선순위 때문에 ‘바로 다음 모든 action에서 Major’는 아니지만, safe boundary 패턴은 학습하기 쉽다. 사람의 체감 연구 결과가 아니라 실제 행동 구조의 예측성 위험이다.

두 후보 Scenario B에서 Case01 Resume 후 Next→EXP01은 실제 gameplay 입력 공간이지만 그 Run이 곧 Case02 Notice를 표시하고, EXP02→CONT에서 다음 Major가 이어진다. nested 폭발은 없으나 response/notice의 밀집은 pacing 위험으로 남는다. 이번에는 cooldown/threshold/Forced/Scripted 사건으로 조정하지 않았다.

## 실행과 검증

엔진 `4.7.1.stable.official.a13da4feb`, Windows native GL Compatibility / AMD Radeon RX 6800. 각 실행 60초 timeout, exit/ERROR/SCRIPT ERROR/Parse Error/warning 수와 로그 hash를 검사했다.

| 검증 묶음 | suite 실행 | 실제 표본과 계약 |
|---|---:|---|
| 기존 회귀 사본 | 199 | product GDScript39 parse, State/Research/Archive/Hypothesis/조건/invalid/stale/debug/resize |
| Step40 사본 | 16 | Major/FIFO/entry/restore/navigation/edge |
| Step42 사본 | 20 | actual draw/read-boundary/context/draft/6대응/normal-debug/invalid/EXP resume compatibility |
| 신규 Step43 | 32 | 4 normal group + Case02 debug를 3해상도×2모드, edge 2모드 |
| 합계 | **267** | headless152 / native115 |
| 별도 project entry | 3 | editor import, configured Main headless, configured Main native |

신규 정상 Journey는 해상도/모드 조합당 carry6 + Case02 response6 + dual/end/success3 + reach9 =24개, 총 **144 Journey**다. 새 Case02 debug는 ABC Failure3+Success1을 6조합에서 반복해24 Journey다. 통제 edge fixture는20개를 두 모드에서 반복해40 Scenario다. 내부 assertion/Journey 수를267 suite 실행 수에 합산하지 않았다. 최초 개발 중 진단 실행도 최종267에 더하지 않았다.

기존 검증 원본은 모두 보존하고 `.godot/verification/step43/legacy42/`에 사본을 만들었다. 과거 “2-Case/Case02 Outcome 없음” 계약은 HEAD의 Case02와 2-Case Main Scene snapshot으로 검증한다. product Main/State/View 코드와 기존 Case01은 사용하며, 과거 literal debug 문구용 fixture도 유지한다. **이 235개 결과를 새 Case02 데이터 자체에 대한 검사라고 표현하지 않는다.** 새 실제 Case02/Case03와 configured 3-Case Scene은 신규32개와 별도 entry에서 검증했다.

정상 Journey는 실제 Scene의 버튼 좌표에 root.push_input mouse press/release를 전달한다. 실험·Confirm·Next·Source Archive·Log/Hypothesis UI를 사용한다. seed/Resource deepcopy는 재현 가능한 검사 준비이며 정상 경로를 Stage 강제 호출로 대체하지 않는다. retained old EXP/invalid data/동시 ready ordering은 통제 fixture로 명시적으로 구분한다.

| 창 크기 | logical UI / PNG | native 확인 |
|---|---|---|
| 1920×1080 | 1920×1080 /1920×1080 | Deferred Case01→Case03, 두 source의 response/Archive/Resume, 새 교란 |
| 1280×720 | 1920×1080 /1280×720 | 같은 정상 경로와 Case02 debug, 긴 설명/Context wrap |
| 1024×768 | 1920×1080 /1024×576 | keep 여백, Option scroll/C 접근, 작은 창의 결과·환경·버튼 |

GPU PNG를 실제 열어 Case01→Case03 CCTV context, Case02→Case03 CONT context, service-air Notice/current reaction, EXP 결과/환경, Broadcast/Result/Archive 목록을 확인했다. 긴 Option은 기존 ScrollContainer를 사용한다. 1024×768 PNG는 keep 여백을 제외한 16:9 render 영역이다. Step42의 조건 결과 상/하단 draw도 기존 사본 회귀로 유지했다. F5 키를 에디터에서 수동으로 누른 검사는 아니며 같은 configured Main의 CLI 실행으로 검증했다.

예상 invalid fixture warning은 기존1,230 + 신규edge48 = **1,278**개다. 신규edge는 실행당24개: 잘못된 판정11, invalid startup12, 미작성 Case03 Outcome 조회1. 정상/새 debug/entry 실행 warning은0개, 파싱/실행 오류는0개다. 정상 제품에서 1,278개 warning이 발생한다는 뜻이 아니다.

재현 자료는 ignore된 `.godot/verification/step43/`의 runner/로그/JSON/PNG에 있다. normal JSON은 handoff Candidate 전후, old Runtime 해제/new instance, hidden Resolution/Pending, response current Runtime ID/facts, source Archive 증분/다른 후보 보존, Hypothesis를 기록한다. `reach_*`에는 위9행의 실제 event trace가 있다. `validation-results.json`과 각 legacy 결과는 실행 hash를 기록한다. 마지막 `scope-results.json`/`final_integrity.json`은 Git/파일/로그 대조 자료다.

## 변경 범위와 오류 처리

| 파일 | 변경 |
|---|---|
| `resources/cases/test_case_02.tres` | CCTV/EXP02 두 관찰 문구 보완; Outcome2, Stage6, Incident1, Disturbance1, Broadcast1, Option3, Result3, Research11 추가 |
| `resources/cases/test_case_03.tres` | 새 TEST Case; 최소4단계/Research7/reaction1; Outcome 없음 |
| `scenes/main/main.tscn` | Resource 참조1개/sequence append/load_steps만 변경 |
| `scripts/main/main.gd` | sequence ID guard/invalid startup 버튼/FAILURE Incident preflight; +21줄/+1함수 |
| `README.md` | 현재 순서 안내와 Step43 요약 |
| `docs/step43_cross_case_deferred_incident.md` | 이 보고서 |

기존 파일4개 수정, 파일2개 생성, 삭제0개다. project.godot/Case01/기존 UI Scene/View/모든 Data·State schema/UID/과거 docs는 보존했다. 새 State/Manager/Singleton/Autoload/ContentValidator/score/consequence/경제/저장/Case04/Case03 Outcome/최종 UI·audio·animation·shader는 없다.

발견된 product validation 공백은 invalid sequence의 first-case fallback과 FAILURE의 unknown Incident preflight이며 위의 최소 guard로 해결했다. 첫 새 Journey 검사에서는 상속된 `_archive()`와 검사 보조 함수의 signature가 충돌했다. 검사만 `_source_archive()`로 바꿨고 제품 코드 오류는 아니었다. fallback 검사는 authored entry를 실행 전에 제거해 실제 fallback을 확인하도록 정리했다.

세 Case의 local IDs/Research source linkage와 Outcome/response 링크를 검사했다. 지금은 runtime guard와 좁은 테스트로 충분하지만 작성 graph가 커지면 **별도 offline 콘텐츠 검사**가 유용할 시점이다. 전체 validator framework는 이번 단계에 추가하지 않았다.

## 요청한 145개 종료 항목

| 번호 | 항목 | 결과 |
|---|---|---|
| 1 | 작업 전 Git | working tree 깨끗함, staged/untracked 없음. |
| 2 | HEAD/branch/upstream | ad2beae1a7cbee8836bc8f811abb82740bb0d5d3, master→origin/main. |
| 3 | 기존 미커밋 | 없음; 시작106파일 hash 보존 기준. |
| 4 | Step42 재확인 | EXP ready/read-boundary, Context, draft, leak 제거와 기존235개 계약 확인. |
| 5 | Case02 기존 Evidence | 접촉 상실/요철 추적/smooth 탐색/공기 pulse pivot/소리 단독 비일관 반응. |
| 6 | Outcome 판단 | 원문은 장기 판정에 부족; 반복 tracing/search sample의 TEST Mapping으로 한정. |
| 7 | 보완 필요 | CCTV/EXP02 반복 경로의 차이를 최소 명료화. |
| 8 | 실제 Evidence 수정 | CCTV vent 뒤 tracing 재개/반복 grille search; EXP02 반복 pass에서 rib 경로 복귀/smooth grille 도달. |
| 9 | SUCCESS Room | TEST_CASE02_ROOM_01, prototype only. |
| 10 | SUCCESS 근거 | 지속 공기/요철로 반복 경로 유지, restart cue 감소; 장기 확정 아님. |
| 11 | FAILURE Room | TEST_CASE02_ROOM_02, prototype only. |
| 12 | FAILURE 근거 | smooth 검색/air transition 두 cue가 남고 반복 service 접근이 이어짐. |
| 13 | Prototype Mapping | 명시; multi-case Pending/Resolution/Event 검증용. |
| 14 | 정식 설정 | Creature/세계관/최종 격리/밸런스 미확정. |
| 15 | Outcome 구조 | Room별 unique Outcome2, final_result, debug sample Stage 각3. |
| 16 | SUCCESS Incident | incident_id empty; Candidate 없음. |
| 17 | FAILURE Incident | TEST_CASE02_INCIDENT_01 unique link. |
| 18 | IncidentData | TEST SERVICE-GRILLE SEARCH INCIDENT; 관찰 기반, Room 평가 없음. |
| 19 | 교란 | TEST_DIST_SERVICE_AIR_PULSES, local service jets; main ventilation과 구별. |
| 20 | Broadcast | TEST_CASE02_BROADCAST_01; contact guide/air cue/소리 비교 prompt. |
| 21 | Option A | 임시 연속 ribbed contact guide, air cue는 유지. |
| 22 | Option B | local service line 격리, 벽 탐색 기준 부족은 유지. |
| 23 | Option C | airborne fan sound 감소, 표면/air cue는 유지. |
| 24 | Result A | 반복 tracing/grille search 개선, outlet air turn 남음. |
| 25 | Result B | jets/air turn 중단, sideways search 남음. |
| 26 | Result C | search/air turn 지속, 두 cue 미해결. |
| 27 | Research 추가 | 11개; CCTV/EXP02/Room02 3 + 사건/대응/Option/Result 8. |
| 28 | Room leak | 사건/response Research에 correct/wrong/실패 Room ID 없음; 제출 사실은 별도 유지. |
| 29 | normal SUCCESS | Room01 hidden Success → Case03 PROFILE, Case02 Candidate 없음. |
| 30 | normal FAILURE | Room02 hidden Failure → Candidate Case02 → Case03 PROFILE. |
| 31 | Case03 구조 | Profile/CCTV/EXP2/limit2/Room2/Research7/reaction1. |
| 32 | case_id | TEST_CASE_03 unique. |
| 33 | Profile | 대비 strip 따라가기/gap pause. |
| 34 | CCTV | strip travel, gap turn 뒤 visible strip 복귀. |
| 35 | Experiments | 대비 비교와 gap 비교, 독립 ID 두 개. |
| 36 | limit | 2, 기존 실행/중복 제한 재사용. |
| 37 | Rooms | continuous/ordinary와 interrupted/reduced lighting, steady airflow. |
| 38 | Research | 7개, 실제 표시/실행/확정/reaction 발견 경계. |
| 39 | Outcome | Case03 없음, 불필요하게 만들지 않음. |
| 40 | Test 전용 | TEST ID/display/content, 정식 퍼즐 품질 주장 없음. |
| 41 | sequence | Main Scene의 기존 array에 Case03 append. |
| 42 | ID 하드코딩 | Main에 Case01/02/03 전환 분기 추가 없음. |
| 43 | handoff | Case02 Confirm/Pending → 검증/Resolve/merge → 새 Case03 PROFILE. |
| 44 | atomicity | 검증 실패 시 commit 이전 반환, 동기 State 경계 유지; rollback framework 없음. |
| 45 | invalid Outcome | missing/duplicate/undefined/unknown Incident 등 Pending/Runtime/RNG/Archive 보존. |
| 46 | Pending 제거 | 성공적으로 resolution한 Case02만 제거. |
| 47 | Resolution | source Room/result/incident record Case02에 한 번 생성. |
| 48 | Success 후보 | 생성하지 않음, incident_id empty. |
| 49 | Failure 후보 | 기존 RNG2~4/major1로 Case02 등록. |
| 50 | 두 Candidate | Case03 PROFILE에서 Case01/02 동시에 존재. |
| 51 | identity | source_case_id + incident_id, 별도 record, 덮어쓰기 없음. |
| 52 | FIFO | `_case_order` 순서, 각 event ready 후보군 안에서 유지. |
| 53 | 한 opportunity | 한 Notice 또는 Major만 표시, 새 교란의 same-action Major 없음. |
| 54 | ordering | disturbance-first, then FIFO Major; global oldest-completion 우선순위로 오해하지 않음. |
| 55 | Scenario A | 늦은 Case01 교란 → Case02 Success handoff → Case03 CCTV response. |
| 56 | Deferred carry | Case01 Candidate 전체 snapshot handoff 전/후 동일. |
| 57 | Case03 Major | 정상 CCTV entry에서 실제 발생, Stage 강제 전환 아님. |
| 58 | source | Case01 이름/ID/콘텐츠/Archive. |
| 59 | current | Case03 이름/ID/Runtime/중단 Stage. |
| 60 | Runtime identity | response 직전/후 instance ID 동일; 이전 Case Runtime 해제. |
| 61 | Resume | 동일 Case03 CCTV 또는 실제 CONT 목적지. |
| 62 | Source Archive | Case01 사건에서는 Case01만 표시. |
| 63 | 증분 merge | source Incident→Broadcast→confirmed Option→displayed Result 증가. |
| 64 | 혼입 없음 | Case03 Runtime/Current Log/Archive에 source response Research 넣지 않음. |
| 65 | Case03 Hypothesis | 실제 Log Add/Back, response 전후 내용·ID 동일. |
| 66 | Scenario B | Case01/02 Failure → Case03에서 순차 교란·대응 완료. |
| 67 | 두 Failure | 두 Resolution/Candidate가 독립 유지. |
| 68 | 첫 처리 | Case03 첫 CCTV source Case01 Major/완료/정확한 제거. |
| 69 | 둘째 유지 | source Case02 record가 response/Resume 중 그대로. |
| 70 | 둘째 진행 | EXP01 교란 → EXP02 ready/read → CONT Major. |
| 71 | nested 없음 | active response 중 Case02 start/opportunity 차단. |
| 72 | Resume 중첩 없음 | entry/key 재소비 없음, 둘째 후보 count1 유지. |
| 73 | gameplay 공간 | Resume 뒤 실제 Next/실험 행동 존재; 교란·대응 밀집 위험은 남음. |
| 74 | Scenario C | Case01 Success/Case02 Failure의 source Case02 response ABC. |
| 75 | Case01 이벤트 없음 | Candidate는 Case02 하나, source01 response 없음. |
| 76 | Scenario D | 모두 Success로 Case03 4단계 정상 진행. |
| 77 | 성공 상태 | Candidate/교란/Major 없음, hidden Success record만 유지. |
| 78 | Forced 없음 | 성공 경로에 강제 사건 추가 안 함. |
| 79 | threshold | disturbance2~4/major1 그대로. |
| 80 | RNG | 기존 randomize/randi_range 유지; 검증은 기존 seed 재현. |
| 81 | Case03 환경 | 실제 Case03 event에서만 current Runtime에 apply; 앞선 조건 자동 승계 없음. |
| 82 | Reaction | Case02 service-air 수신 관찰1개만 필요하여 추가. |
| 83 | missing reaction | Case01 power 발생 때 facility-only Notice, fake creature fallback/Research 없음. |
| 84 | Condition observation | Case03에는 추가하지 않음, 기존 none 경계 안전. |
| 85 | Pending snapshot | Case03 시작에 앞선 Pending 없음; 끝에는 Case03만 보존. |
| 86 | Resolution snapshot | Case01/02 record 독립, Case03 없음. |
| 87 | Hidden 비노출 | handoff PROFILE/Current Log/Archive에서 enum/threshold/판정 자동 표시 없음. |
| 88 | FAILURE 공개 | handoff 즉시 Case02 FAILURE 화면 없음; 실제 사건의 관찰만 공개. |
| 89 | correct/wrong leak | Case02 사건/대응/결과/Research에서 Room 평가 없음. |
| 90 | Archive Case01/02 | handoff 뒤 각각 실제 발견한 authored ID가 있음. |
| 91 | Current Archive | Case03은 handoff 전 과거 Archive 목록에 넣지 않음. |
| 92 | 순서 | 첫 archive order Case01→Case02, 증분 merge가 재정렬하지 않음. |
| 93 | Hypothesis 분리 | 세 Case의 note/ID 독립, source detail read-only/current Log 편집. |
| 94 | fallback | authored ID 없는 fallback 영구 merge 없음; synthetic ID 없음. |
| 95 | 마지막 정책 | Next 비활성 No next test case configured, Campaign completion 없음. |
| 96 | Case03 Pending | confirmed Room/Research/Hypothesis와 함께 보존. |
| 97 | end Candidate | Case02 threshold4 last disturbance 뒤 Candidate 계속 남음. |
| 98 | Runtime isolation | Case02 이력/Room/Research/환경이 Case03 Runtime에 누출되지 않음. |
| 99 | session persistence | 기존 7개 State 객체/records가 Runtime 교체와 독립 유지. |
| 100 | stale Case02 | old Confirm/Advance/Log 및 retained EXP execute/review 요청 무변경. |
| 101 | stale response | Incident/Broadcast/Result old signal로 current facts/다른 후보 변경 없음. |
| 102 | stale Archive | old Source Archive Back/늦은 요청이 navigation을 깨지 않음. |
| 103 | normal/debug | normal IncidentResponse와 debug Runtime/Monitoring 분리. |
| 104 | debug SUCCESS | 새 Case02 Room01 → Monitoring sample → RESULT, normal Candidate 없음. |
| 105 | debug FAILURE | 새 Case02 Room02 → Incident/Broadcast ABC/Result → RESULT. |
| 106 | Case03 debug | Outcome empty 조회 null, foreign fallback 없음; playback 억지 실행 안 함. |
| 107 | Step42 읽기 | ready EXP callback 동일 View, native draw/idle/Log 및 이전 조건 결과 회귀 유지. |
| 108 | Step42 Context | source/current/실제 resume Stage; Case03에서도 명시. |
| 109 | Step42 draft | direct Source Archive 왕복 미확정 선택 유지, Confirm과 분리. |
| 110 | Step42 콘텐츠 | Case01 기존 여섯 대응 텍스트 그대로; 새 Case02도 관찰/근거/trade-off. |
| 111 | Step39 원칙 | CORE로 비교 가능, 환경 Evidence optional/supporting 유지. |
| 112 | Case02 Map | 위 CORE/설비/기존 환경 표와 Test Mapping 근거 참조. |
| 113 | Case03 Evidence | 단일 strip contrast/gap 테마, 장기 Outcome 주장 없음. |
| 114 | 3해상도 | normal carry/case2/dual/reach 모두 headless/native 3조합 통과. |
| 115 | GPU cross-case | Case01 late→Case03 source response→동일 Case03 Resume actual draw/PNG. |
| 116 | headless | 총152 suite; 신규16, old136. |
| 117 | editor import | 4.7.1 최종 프로젝트 import exit0, 오류/warning 없음. |
| 118 | Main launch | configured Main headless/native exit0; F5 수동 키 검사 아님. |
| 119 | Resource 불변 | 세 instantiated Case content 전후 동일, 원본 파일 hash도 검사. |
| 120 | Candidate snapshot | Case02→03 source01 모든 count/flag/ID/threshold 보존, 다른 후보도 response 중 보존. |
| 121 | Runtime snapshot | old WeakRef 해제/new ID, Major 직전/복귀 같은 current ID. |
| 122 | Archive snapshot | handoff order/IDs, source만 incremental 증가, 다른 Archive 동일. |
| 123 | Hypothesis snapshot | Case별 note3개 비교/JSON 기록, source/current 분리. |
| 124 | Reachability | threshold2~4×Case02 실험0~2의 정상9행, 위 표. |
| 125 | F07 | PARTIALLY RESOLVED: Case02 뒤 continuation 해결, 마지막 Case의 장기 pool 부족은 남음. |
| 126 | F01 | 미해결/재측정: major1의 다음 safe entry 관계와 예측성 유지. |
| 127 | 두 후보 pacing | nested 없음; Resume 뒤 다음 실험에서 Notice, 이후 CONT Major로 밀집 가능. |
| 128 | 반복 패턴 | disturbance→ready1→safe entry 패턴 강함, 변경하지 않음. |
| 129 | Main lines | 1542→1563, +21. |
| 130 | Main functions | 83→84, +1 unique-sequence helper. |
| 131 | Main 책임 | 기존 전환/검증/State 승인 유지, sequence/Incident preflight만 보완. |
| 132 | Validator 평가 | graph 확대 시 별도 offline 검사 유용, 이번 framework 미추가. |
| 133 | 새 State | 없음, 기존 7개 사용. |
| 134 | Manager | 없음; Singleton/EventBus/Autoload 추가 없음. |
| 135 | 오류 | 최종267 suite/entry 오류0; 초기 검사 signature 충돌만 수정. |
| 136 | warning | expected invalid1278, 정상/새 debug/entry0; 실제 수 일치. |
| 137 | 변경 파일 | Case02/Main Scene/Main/README 4개. |
| 138 | 생성 파일 | Case03 Resource와 이 보고서 2개; 검증 자료는 ignored. |
| 139 | 삭제 | 0개. |
| 140 | 기존 변경 보존 | 시작 미커밋 없음, 기존 reports/Case01/검증 원본 보존. |
| 141 | diff check | git diff --check 및 새 파일 whitespace 검사 통과. |
| 142 | staged | 없음, HEAD 유지, commit/push 없음. |
| 143 | 미구현 | rebalance/Severity/Forced/Scripted/Campaign/Economy/Save/Case04/Case03 Outcome/final UI·audio·animation·shader 없음. |
| 144 | 우선순위 | 3-Case 사건 밀집/읽기/출처 이해를 사람 플레이와 UX 감사로 재측정. |
| 145 | 다음 Step | Step44 — 3-Case Event Pacing / Cross-Case UX Audit 추천; threshold 결정은 별도 단계. |

최종 범위 검사는 106개 baseline 파일에서 위4개 수정만 허용하고, 이전 검증 원본3,687개 hash와 이전 docs/Case01/project.godot가 그대로임을 확인한다. README 기존 내용은 현재 순서 첫 문장 갱신과 Step43 블록 추가 외에 보존한다. staged/삭제 없음과 HEAD 유지, 전체 로그 hash/warning 수, 세 해상도 normal snapshot을 마지막으로 대조한다.
