# Step48 — Meaningful Research / Read Boundary Pacing Gate

기존 Godot 프로젝트에 Step48만 구현했다. 새로운 연구 완료와 자발적인 읽기 경계 사이에서는 normal Environmental Disturbance/Major Incident를 연속 표시하지 않는다. readiness는 기존 opportunity 규칙대로 계속 진행한다.

## 조사와 변경 범위

저장소의 전체 비생성 파일 목록과 Git 상태를 먼저 조사했다. 기존 비생성 파일 114개, Scene 15개, GDScript 40개, Case Resource 3개, runtime State 7개, read model 1개, Autoload 0개다. project.godot의 configured Main은 scenes/main/main.tscn이며 Case01→02→03이다. 기본 UI는 1920×1080, 초기 창1280×720, canvas_items/keep/resizable, Compatibility GL 설정이다. 해당 설정과 모든 Scene/Resource/State를 보존했다.

이번 제품 수정은 scripts/main/main.gd와 scripts/views/experiment_view.gd 두 파일이다. README에는 이 보고서의 요약을 추가했다. 새 비생성 파일은 이 보고서 하나이며 삭제는 없다. 기존 Step46/47 미커밋 작업을 포함한 전체 git diff와 Step48 시작 baseline 대비 diff를 구분한다.

```text
cap/
├── project.godot                         (보존)
├── README.md                             (Step48 요약 추가)
├── docs/step48_meaningful_research_pacing_gate.md (신규)
├── scenes/                               (모두 보존)
├── resources/                            (모두 보존)
├── scripts/main/main.gd                  (gate/read checkpoint)
├── scripts/views/experiment_view.gd      (실제 표시 승인 결과 식별)
├── scripts/runtime/                      (모두 보존)
├── scripts/read_models/                  (Step46 작업 보존)
└── .godot/verification/step48/            (ignored 검증 source/log/PNG/JSON)
```

## 구현 계약

Main은 shared OPEN/CLOSED bool과 Case+kind+source ID 완료 token을 보관한다. View는 기존 사용자 action signal만 보낸다. Main이 active View/현재 Runtime/실제 표시 source/첫 완료 token을 확인해 credit을 승인한다. 여러 승인은 bool에 포화하며 Event 하나가 실제 표시되면 닫힌다. 후보별 queue, bank, score, Manager, Singleton, 새 signal/버튼/Timer는 없다.

| 위치 | 기존 readiness 진행 | 새 credit | 실제 presentation |
|---|---|---|---|
| PROFILE | 없음 | 없음 | 없음 |
| 첫 CCTV entry | 기존 count | 없음 | 없음, base 먼저 표시 |
| CCTV Next | 없음 | base가 draw된 최초 고유 source | OPEN이면 oldest 하나; 같은 CCTV 복귀 |
| EXP selection | 없음 | 없음 | 없음 |
| 승인 EXP Run | 기존 count/history/조건 snapshot | 없음 | 없음, 실제 결과 먼저 표시 |
| EXP Next | 없음 | draw된 실제 승인 결과 1개 | OPEN이면 oldest 하나, Major도 가능; EXP 결과 복원 |
| 첫 CONT entry | 기존 count | 없음 | OPEN이면 oldest 하나 |
| 최초 valid Confirm | 없음 | 고유 Case+Room 결정 | 없음; Pending/확정 lock 유지 |
| confirmed CONT Next | 없음 | 없음 | 유효 다음 Case/Next enabled이면 handoff 전에 하나 |
| Case03 final Confirm | 없음 | 최초 결정이면 OPEN | 없음; Next disabled/Outcome0/Pending 유지 |
| Dismiss/Resume/Log/Archive/Recheck/idle | 없음 | 없음 | 없음 |

native draw frame 증가와 process frame을 확인하고, headless에서는 실제 GPU가 없으므로 process frame을 표시 surrogate로 사용한다. Next는 자발적 읽기 경계의 proxy다. 읽기 이해도/완독/체류시간/scroll 끝은 증명하지 않는다. Run 여러 개 후에는 현재 실제 표시된 마지막 승인 결과만 인정하고 selection으로 지운 결과나 history-only는 인정하지 않는다.

## 동일 144 Journey의 전후 측정

Step47의 기존 matrix/log는 변경하지 않았다. FF81/FS27/SF27/SS9, D threshold 각2~4, Case02/03 실험 각각0/1/2, 기존 Case01 실험1의 동일 route ID 144개를 새로운 step48 경로에 실행했다. Event 뒤 동일 화면 Next를 다시 누르는 동작만 새 정책에 맞게 추가했다. 각 Journey의 eligible/기존 meaningful accounting과 threshold/hidden Resolution 계약을 대조했다.

| 지표 | Step47 before | Step48 after |
|---|---:|---:|
| Journey | 144 | 144 |
| Disturbance | 170 | 159 |
| Major | 131 | 88 |
| Broadcast | 131 | 88 |
| Interruption | 301 | 247 |
| Eligible opportunity | 1296 | 1296 |
| 기존 meaningful-action | 1296 | 1296 |
| 새 credited progress 총합 | 제도 없음/미수집 | 1200 |
| Interruption/eligible | 0.232253 | 0.190586 |
| Strict between min/max; zero | 0/4;75 | 1/3;0 |
| Causing 포함 min/max; zero | 0/4;63 | 1/3;0 |
| 새 credit-between min/max; zero | 미수집 | 1/2;0 |
| 연속 Event pair | 175 | 121 |
| final unresolved record | 85 | 128 |
| unresolved Journey | 82 | 113 |
| UNDISTURBED | 46 | 57 |
| DISTURBED_NOT_READY | 31 | 28 |
| MAJOR_READY | 8 | 43 |

새 credit-between은 이전 Event를 표시한 action 이후부터 다음 Event의 causing action까지 승인된 고유 token 수다. 기존 strict/causing meaningful metric을 바꾸거나 섞지 않았다. after의 121쌍은 credit1이70쌍, credit2가51쌍이다. Event를 유발한 같은 Next에서 새 token이 승인될 수 있으므로 그 action을 포함한다. 오래된 의미 있는 action을 새 credit으로 재분류하지 않았다.

| Event/return Stage | CCTV before→after | EXP before→after | CONT before→after |
|---|---:|---:|---:|
| Major |36→36|0→16|95→36|
| Disturbance |24→24|79→71|67→64|

최종 미해결 증가는 발표를 미루는 gate와 final boundary 무처리 정책의 결과다. gate는 READY를 취소하거나 후보를 삭제하지 않는다. D가 실제 표시되는 시점이 늦어지면 이후 M count의 출발 시점도 달라질 수 있지만 State의 기존 D→별도 opportunity→M 규칙은 그대로다.

이전 bypass9: FF_32_e00, FF_33_e01, FF_34_e02, FF_42_e01, FF_42_e10, FF_43_e01, FF_43_e11, FF_44_e02, FF_44_e12. 같은 ID의 전체 event/gap/final 후보를 matrix-comparison.json에 보관했다. 이전과 같은 Stage에서 경쟁한다고 가정하지 않았다. 별도 CLOSED/OPEN ordering matrix에서 CLOSED oldM/newD 무표시와 OPEN oldM 우선을 확인했다.

## 검증 범위와 실제 증거

Godot 실제 버전은 4.7.1.stable.official.a13da4feb이다. 최종 인증 프로세스 318개이며, 실제 Step48 제품 검사 50개와 historical core 회귀 268개를 분리했다. 이 숫자는 assertion 수나 Journey 수가 아니다.

| suite | 최종 프로세스 | 검증 계약 |
|---|---:|---|
| Step39 및 이전 core |200|제품 GDScript check-only40 + State/Resource/View/Archive/Hypothesis/debug 등160 |
| Step40 core |16|정상 response/hidden resolution/source identity/Runtime |
| Step42 core |20|context/Source Archive/Broadcast draft/confirmed lock |
| Step43 core |32|3-Case handoff/Archive/Deferred/Resource immutable |
| Step48 144 matrix |16|9 Journey씩, 기회 집계/credit spacing/최종 Snapshot |
| rich whole Journey |6|3해상도×headless/native, 2 Journey씩 |
| 이전 bypass 대표 native |3|3해상도×2 Journey |
| gate A/B/C/D |4|headless1 + native3해상도, 각15 scenario record |
| edge gate |2|Runtime/token/invalid/hidden/Snapshot/D→D/M→M, 각14 fixture |
| Step47 controlled ordering |2|20 record씩 + EXP read/finite stress/non-opportunity |
| Step44 queue contract |2|invalid retain/skip/finite ordering/farming, 각15 fixture |
| actual debug gate isolation |2|debug SUCCESS/FAILURE responses에서 normal gate 불변 |
| Step46 Snapshot |10|5 group×headless/native |
| configured Main/import |3|headless editor import, 지정 Main headless/native |

historical core 268개 중 과거 presentation 시점을 전제로 하는 검사는 테스트 전용 legacy_pacing_main subclass의 과거 checkpoint adapter를 사용한다. State/Resource/View/response/Archive/Hypothesis/hidden Resolution 코드는 현재 제품에서 상속한다. 과거 즉시 D 표시를 현재 Step48 pacing으로 통과했다고 주장하지 않는다. **새 gate 계약, 144 matrix, 실제 read-boundary response, Snapshot/ordering/debug 검사는 adapter 없이 실제 Main을 사용한다.** 기존 Step46의305개 핵심 범주에 해당하는 268+16+6+2+10+3=305개를 보존했고, Step47 ordering5 및 새 gate/debug/edge8개를 더해318개다.

controlled selector fixture는 후보/readiness 또는 OPEN을 명시적으로 준비한다. 이는 순서·retain/skip 검사용이며 normal gameplay Journey와 수를 합치지 않는다. D→D/M→M의 synthetic readiness도 제품 밸런스를 바꾸지 않는다. 정상 credit 생성은 별도로 기존 버튼의 실제 입력과 draw를 검증한다.

별도 계수 assertion: gate 4645, edge 818, ordering 3138, Snapshot 1564. matrix는144 Journey/121 gap, rich는12 Journey, bypass visual은6 Journey다. 다른 historical suite의 미계수 assertion을 이 숫자에 추정 합산하지 않았다.

정상 Main/matrix/visual/gate/debug warning0, 최종 SCRIPT/runtime/parse error0. invalid fixture의 의도된 warning 합계는1400이며 normal warning과 분리했다. Snapshot invalid18×2, ordering4×2, queue28×2, edge11×2 등 각 fixture의 예상 경고와 log SHA256을 certification.json에서 확인했다.

최종 실제 GPU는 Compatibility OpenGL3.3/AMD Radeon RX6800으로1920×1080,1280×720,1024×768을 실행했다. gate PNG와 actual frame probe를 남겼다. CCTV base, EXP 결과, locked CONT Resume의 화면을 직접 열어 배치/버튼/스크롤/잠금을 확인했다. 기존1920×1080 logical canvas와 keep/resizable 설정을 유지했다.

검증 중 discovered stale Runtime credit는 동일 Case ID의 새 Runtime에 old CONT View가 credit을 생성하는 재현 검사로 찾았고, 표시 당시 Runtime ID guard로 수정했다. hidden View/Label도 credit을 승인하지 않는다. 복사된 Profile regression source 누락과 synthetic selector fixture의 Archive click sequencing 오류는 검증 fixture를 복원/분리하여 수정했다. 여러 native 검사 동시 실행 때 과거 fixture timeout이 발생하여 최종 historical 회귀는 GPU를 순차 실행했다. 모든 최종 인증 실행은 성공 log만 사용하며 초기 실패를 성공 수에 포함하지 않는다.

재실행 source: .godot/verification/step48/final_actual.ps1, historical 각 run_validation.ps1, certify.py. 결과: certification.json, matrix-comparison.json, gate_*.json, edge_gate_*.json, ordering_*.json, snapshot_*.json, PNG와 원본 로그. 이 증거는 ignored 캐시이므로 커밋 대상 제품 기능으로 추가하지 않았다.

## Finding 판정과 제한

| finding | 최종 상태 | 근거/남은 문제 |
|---|---|---|
| F44-01 |RESOLVED|144 정상 경로의 credit-between 최소1/zero0; 사람 피로도 개선은 아직 미검증 |
| F44-02 |RESOLVED 유지|등록 순서 oldest actionable, OPEN oldM/newD→oldM, CLOSED 전면 차단 |
| F01 |OPEN|Major threshold1/opportunity predictability와 player timing manipulation이 남음 |
| F07-B |PARTIALLY ADDRESSED|Snapshot 진단만 유지; final Outcome0/Pending/queue 미처리, 실제 Run 종료 없음 |
| CODE-48-01 |RESOLVED|same Case ID stale Runtime View credit 재현과 identity guard 회귀 통과 |
| UX-48-01 |OPEN/P2|Next-event 공식, double-Next, CONT handoff 보류, Resume 혼동은 사람 테스트 필요 |

최종 미해결 CODE P0/P1은 없다. P2 UX/GAME DESIGN과 Main bookkeeping 증가(P3)를 기록한다. 실제 피로도·읽기 이해도·원하는 사건 체감 간격을 이번 자동 검사만으로 판정하지 않는다. 다음 Step은 실제 플레이어의 Read Boundary/Resume/Handoff UX audit이 적합하다.

## Git와 보존 검증

HEAD 79955a147ece4398d59d76bc49e3f123423cdc17, master→origin/main은 그대로다. staged0, 삭제0, commit/push0. 시작 당시 비생성 파일114개 중 변경 범위는 두 Script와 README로 제한한다. 기존 검증 source/UID/JSON 9028개 SHA256도 모두 보존했다. project.godot/전체 Scene/Resource/State/Step46~47 문서/read_models는 baseline hash와 같고, Main의 Snapshot/handoff/hidden Resolution/response completion/Source Archive 함수는 본문 단위 비교가 동일하다. 최종 git diff --check와 diff/status 파일 목록을 확인했다.

## 요청한 192개 종료 보고 항목

### 1. 작업 전 Git 상태

작업 전 README.md와 scripts/main/main.gd가 modified, Step46/47 보고서와 scripts/read_models/가 untracked였다. staged 파일 0개. 정확한 status는 .godot/verification/step48/git-before.txt에 보관했다.

### 2. HEAD / branch / upstream

HEAD 79955a147ece4398d59d76bc49e3f123423cdc17, branch master, upstream origin/main, remote https://github.com/rudgns15251-ctrl/ccc.git. 이번 작업에서 변경하지 않았다.

### 3. Step46 변경 상태

Step46 Snapshot Script/UID와 보고서가 이전 작업의 untracked 파일로 남아 있었다. Main의 Snapshot API/본문, hidden Resolution, handoff를 baseline과 함수 단위 및 SHA256으로 대조해 보존했다.

### 4. Step47 변경 상태

Step47 보고서와 Main의 oldest actionable selector 변경이 미커밋 상태였다. 보고서는 그대로 보존하고 등록 순서 scan에 gate guard와 명시적 EXP read boundary만 추가했다.

### 5. 기존 threshold

기존 Disturbance threshold 2~4와 Major threshold1 상수를 변경하지 않았다.

### 6. 기존 RNG

기존 Main RNG instance와 FAILURE 등록 때의 threshold 추첨을 유지했다. gate/token/ready 조회에는 RNG 사용이 없다.

### 7. 기존 opportunities

기존 first CCTV entry, 승인된 EXP Run, first CONT entry의 dedup key와 count 규칙을 유지했다. Next/Confirm은 opportunity를 추가하지 않는다.

### 8. progression/presentation 분리

readiness count는 기존 gameplay opportunity에서 진행하고 presentation은 별도 OPEN bool과 허용 경계로 제한한다. CLOSED에서도 READY가 누적된다.

### 9. pacing gate 구현 위치

scripts/main/main.gd의 기존 화면 전환/실행/확정 callback과 작은 private helper에 구현했다. View는 pacing state를 소유하지 않는다.

### 10. gate 초기 상태

새 Main 세션의 bool은 true/OPEN이다. 기존 interruption이 없으므로 최초 Event는 이전 연구 요구 없이 표시할 수 있다.

### 11. gate OPEN 의미

현재 presentation boundary에서 oldest actionable Event 하나를 표시할 수 있다는 뜻이다. READY나 모든 후보의 자동 처리를 뜻하지 않는다.

### 12. gate CLOSED 의미

표시를 차단한다. count/threshold/후보/이미 적용된 환경은 유지하며 기존 opportunity에서 계속 readiness를 진행한다.

### 13. Event display consume

실제 Disturbance Notice 또는 normal Major Incident 표시 성공 때만 CLOSED로 소비한다.

### 14. failed presentation consume 여부

failed/invalid/unready/non-presentable attempt는 credit을 소비하지 않는다. 나중 유효 후보를 계속 검사할 수 있다.

### 15. gate candidate별 여부

후보별 budget이 아닌 Main 세션의 shared bool 하나다. D/M과 서로 다른 Candidate도 같은 연구 간격을 적용받는다.

### 16. State 추가 여부

새 runtime State, class, Resource schema는 없다. Main-local bool/완료 token Dictionary/현재 표시 View·Runtime·frame metadata만 추가했다.

### 17. Manager 추가 여부

Manager, Singleton, Autoload, 범용 State Machine/Event Bus는 추가하지 않았다.

### 18. credit token storage

Main의 Dictionary[String,bool] _completed_research_tokens에 안정 ID tuple을 저장한다. Runtime handoff/reset에서 삭제하지 않고 새 Main 세션에서 비운다.

### 19. token stable identity

Resource에 이미 있는 stable ID만 쓴다. 조건 observation ID를 별도 credit으로 만들지 않는다.

### 20. index 사용 여부

token에 배열 index는 없다. 기존 UI 선택 index는 그대로 사용하지만 pacing key와 분리했다.

### 21. Case identity 포함

Case identity를 token에 포함한다. 다른 Case의 같은 camera_id는 별도 연구다.

### 22. token dedup

이미 저장된 token이면 bool을 다시 열지 않는다. Runtime reset 후 동일 Case의 같은 source도 중복이다.

### 23. bool saturation

여러 번 승인되어도 OPEN bool 하나다. 소비 가능한 credit을 은행처럼 누적하지 않는다.

### 24. CCTV credit 정의

유효 base CCTV 정보가 현재 View에서 실제 표시되고 draw 이후 기존 Next로 나갈 때 최초 credit을 준다.

### 25. CCTV entry credit 없음

CCTV entry는 count/discovery만 진행한다. credit이나 Event presentation은 없다.

### 26. CCTV draw-first

View/Runtime ID와 process/draw frame을 기록하고 Next가 이후 frame인지 확인한다. native는 실제 draw frame 증가를 요구한다.

### 27. CCTV Next credit

active·visible·현재 Runtime·유효 source·실제 Label 내용·첫 token을 확인하여 Next에서 승인한다.

### 28. CCTV Next presentation

승인 후 현재 boundary의 oldest ready Event 하나를 표시할 수 있다. Next에서는 count를 증가시키지 않는다.

### 29. CCTV Resume

D는 같은 CCTV View로 Dismiss, M은 같은 Runtime의 CCTV 단계로 Resume한다.

### 30. CCTV duplicate credit

다시 누른 Next는 동일 token으로 gate를 열지 않고 EXP로 진행한다.

### 31. Recheck credit 없음

Recheck CCTV의 Back 분기를 credit 로직보다 먼저 처리한다. 추가 source credit이 없다.

### 32. Log credit 없음

Research Log 진입/Back에는 grant 호출이 없다. Log로 돌아오더라도 token 기록은 유지한다.

### 33. Archive credit 없음

Archive 목록·상세·Source Archive·Back에는 grant 호출이 없다.

### 34. Experiment credit 정의

승인된 실행의 실제 표시 결과가 draw된 후 기존 EXP Next를 누를 때만 고유 credit을 준다.

### 35. EXP selection credit 없음

선택은 grant를 호출하지 않는다. 다른 실험 선택으로 결과를 지우면 history만으로 credit을 주지 않는다.

### 36. Run callback credit 없음

Run callback은 실행·history·조건 snapshot·결과 표시·기존 count만 진행한다. Event와 credit은 없다.

### 37. Result draw

approved result의 ID와 실제 Label 일치를 확인한다. native draw가 증가하기 전 Next는 진행하지 않는다.

### 38. EXP Next credit

현재 실제 표시 중인 승인 결과 1개만 고유 token으로 인정한다.

### 39. EXP Next presentation

EXP Next도 명시적 read boundary다. 이 위치에서는 오래된 Major도 actionable이다. Run 위치에는 이 권한이 없다.

### 40. multiple EXP result 정책

여러 Run 후에는 마지막 실제 표시 결과만 credit이다. 모든 execution history를 한꺼번에 승인하지 않는다.

### 41. duplicate EXP credit 없음

결과 복귀/재생성/동일 결과 Next는 token dedup로 credit을 추가하지 않는다.

### 42. invalid EXP credit 없음

외부 ID·duplicate ID·blank 결과·숨긴 View·선택만 한 상태·거절 Run·초과 limit·history-only는 credit이 없다.

### 43. Containment entry credit 없음

CONT entry는 credit을 생성하지 않는다.

### 44. Containment entry presentation

기존 CONT entry opportunity count를 증가시킨 뒤 OPEN gate이면 ready Event 하나를 표시할 수 있다.

### 45. gate CLOSED entry

CLOSED entry는 readiness만 증가시키고 환경·Notice·Major를 표시하지 않는다.

### 46. Room temporary selection

Room 임시 선택은 credit과 Pending 확정 사실을 생성하지 않는다.

### 47. Confirm credit

최초 유효 Room 확정 성공에 Case+containment+room token을 승인한다. 기존 Pending과 Research 확정 처리는 유지했다.

### 48. Confirm same-callback Event 없음

Confirm callback에서 presentation check는 호출하지 않는다. 같은 callback Event는 없다.

### 49. Room lock

기존 confirmation state와 Room/Confirm 잠금을 유지한다.

### 50. CONT Next presentation

confirmed CONT의 실제 enabled Next와 유효 다음 Case가 있으면 handoff 전에 ready Event를 하나 검사한다.

### 51. Resume locked CONT

Response 뒤 현재 Runtime·Pending·confirmed Room이 그대로인 locked CONT로 복귀한다.

### 52. second Next handoff

Resume 뒤 두 번째 Next는 새로운 credit 없이 기존 handoff를 수행한다.

### 53. duplicate Confirm credit 없음

try_confirm의 최초 성공에만 token을 승인한다. 중복 Confirm으로 gate가 열리지 않는다.

### 54. final Case Next disabled

Case03의 No next test case configured/disabled Next를 유지했다.

### 55. final Event auto drain 없음

마지막 Confirm은 credit을 열 수 있어도 Event를 표시하지 않는다. 강제 Next·idle·Timer·Snapshot으로 queue를 drain하지 않는다.

### 56. Case handoff credit 없음

handoff에 grant 호출이 없다. 기존 Pending→hidden Resolution 과정은 그대로다.

### 57. handoff gate reset 여부

handoff는 session gate/token을 reset하지 않는다. Runtime만 교체된다.

### 58. new Case Profile

다음 Case는 기존 PROFILE에서 시작한다. 이전 interruption context나 Runtime을 가져오지 않는다.

### 59. Profile credit 없음

Profile entry와 Next는 credit이 아니다.

### 60. Hypothesis credit 없음

Hypothesis add/edit/delete는 credit이나 opportunity가 아니다.

### 61. Dismiss credit 없음

Dismiss는 credit을 승인하지 않는다. modal lock 해제와 기존 조건 갱신만 처리한다.

### 62. Resume credit 없음

Resume는 credit을 승인하지 않는다. 실제 표시 결과를 복원해도 과거 token이 재승인되지 않는다.

### 63. idle credit 없음

idle에는 grant/presentation trigger가 없다.

### 64. scroll/focus credit 없음

scroll/focus/time 경과는 credit 기준이 아니다. 최소 읽기 시간이나 scroll 끝 도달 판정을 추가하지 않았다.

### 65. Disturbance closes gate

D 환경 적용/Notice 표시 성공 뒤 CLOSED가 된다. invalid content는 소비하지 않는다.

### 66. Major closes gate

Major response 시작과 Incident View 표시 성공 뒤 CLOSED가 된다.

### 67. shared gate

D/M 모두 같은 gate를 소비한다. 한 타입 뒤 다른 타입도 새 연구를 요구한다.

### 68. D→M 간격

CCTV D→실험 실제 결과→EXP Next M 경로에서 새 credit 1개를 확인했다.

### 69. M→D 간격

old M→Resume→fresh EXP Result Next→later D의 실제 read 경계를 검증했다.

### 70. D→D 간격

controlled D→D readiness fixture도 실제 CCTV/EXP Next의 새 credit을 요구했다. synthetic threshold는 제품에 반영하지 않았다.

### 71. M→M 간격

두 Major-ready 후보의 M→M 경로에서도 새 EXP Result Next 없이는 두 번째 M이 표시되지 않았다.

### 72. readiness while CLOSED

CLOSED CONT entry와 Run에서 count가 증가해도 표시되지 않는 검사를 통과했다.

### 73. ready accumulation

최종 Snapshot의 MAJOR_READY 증가도 gate가 후보를 삭제하거나 readiness를 되돌리지 않았음을 보여준다.

### 74. oldest actionable integration

OPEN은 registration-order scan으로 전달된다. CLOSED는 selection/presentation 전에 차단한다.

### 75. one checkpoint one Event

표시 성공하면 callback에서 return하므로 checkpoint당 Event 하나다.

### 76. one credit one Event

표시 성공이 bool을 닫으므로 같은 credit으로 연속 두 Event가 나올 수 없다.

### 77. invalid oldest

invalid source/Incident/Resolution/Broadcast는 retain한다. invalid 시 credit이 남고 유효한 나중 후보를 검사한다.

### 78. unready oldest

unready 후보는 skip하고 삭제하지 않는다. 나중 ready 후보의 진행을 막지 않는다.

### 79. same Candidate D→M

D-trigger 이후의 기존 별도 opportunity에서 M count를 진행한다. 같은 D 표시 action을 M opportunity로 재사용하지 않는다.

### 80. environment apply timing

D 환경 적용은 실제 presentation 성공 함수에만 있다.

### 81. hidden D environment 없음

ready+CLOSED 상태에서 applied_disturbances가 비어 있고 disturbance_triggered=false인 검사를 통과했다.

### 82. reaction discovery timing

D reaction의 표시·discovery는 실제 D presentation 때만 수행한다.

### 83. condition observation timing

CCTV 조건 observation은 실제 적용 환경, EXP 조건 observation은 기존 실행 시 snapshot을 따른다. READY만으로 조건이 적용되지 않는다.

### 84. past Experiment no retroactive change

과거 execution의 조건 ID/result/history는 이벤트 뒤와 Resume에도 보존한다. 뒤늦은 환경을 과거 결과에 붙이지 않는다.

### 85. Core Evidence 유지

Core Evidence 계약과 authored 데이터는 불변이다. 기존 supporting/optional 환경 증거 검사를 유지했다.

### 86. token 수명

token 수명은 Main 세션이다. 저장 파일이나 Resource에 기록하지 않는다.

### 87. Runtime replacement와 token

Runtime 교체/reset으로 token을 지우지 않는다. 오래된 View의 Runtime ID는 새 Runtime의 credit 승인에 사용할 수 없다.

### 88. Snapshot 변경 여부

Snapshot Script/API/출력 schema를 수정하지 않았다. gate/token을 출력하지 않는다.

### 89. Snapshot role 유지

Snapshot은 진단용 읽기 전용 사실 복사다. gate를 열거나 Event를 처리하는 권한이 없다.

### 90. stale View

active View identity/visible/queued deletion/Runtime 검사를 통과해야 credit을 승인한다.

### 91. stale Next

View 교체 뒤 old Next는 active View 검사에서 차단된다. 같은 ID Runtime 교체 뒤 Next도 차단된다.

### 92. repeated signal

modal 중 입력 거절과 token dedup, View 교체 뒤 stale signal 거절로 credit/stage 중복 처리를 막았다.

### 93. CCTV representative

새 CCTV 표시→draw→Next D→Dismiss 동일 CCTV→중복 Next EXP를 3해상도에서 실행했다.

### 94. EXP representative

Run→실제 결과 draw→Next M→Source Archive/draft/Result→Resume EXP→중복 Next CONT를 실행했다.

### 95. CONT representative A

OPEN CONT entry presentation은 기존 boundary로 유지했다. entry 자체의 credit은 없고 하나 표시 후 CLOSED다.

### 96. CONT representative B

CLOSED CONT entry→Room Confirm OPEN/No Event→Next M/No handoff→Resume locked CONT→Next 실제 handoff를 실행했다.

### 97. final Case representative

Case03 Confirm→Pending/Outcome0/Next disabled→idle 후 queue 유지 검사를 통과했다.

### 98. all Success

SS 9개 기준 Journey와 3해상도 rich Success 경로에서 failure Event가 발생하지 않았다.

### 99. Case01-only Failure

Case01-only Failure 27개 기준 Journey를 동일 threshold/실험 수로 재실행했다.

### 100. Case02-only Failure

Case02-only Failure 27개 기준 Journey를 동일 threshold/실험 수로 재실행했다.

### 101. dual Failure

dual Failure 81개 기준 Journey를 재실행하고 순서·Runtime·최종 Pending을 확인했다.

### 102. Step47 bypass9

이전 bypass9의 같은 ID를 재실행해 matrix-comparison.json에 전체 event/gap/final 후보 기록을 보관했다. 정책 변경으로 실제 presentation 위치가 바뀔 수 있다.

### 103. CLOSED OldM/NewD

CLOSED oldM/newD와 다른 조합에서 표시·조건 적용·후보 삭제가 없었다.

### 104. OPEN OldM/NewD

OPEN oldM/newD는 등록된 old Major를 선택한다. CCTV/EXP read/CONT controlled matrix를 통과했다.

### 105. credited progress metric

앞 Event action 이후, 다음 Event를 유발한 action까지 승인된 고유 token 수를 세는 별도 metric이다. 기존 meaningful counter와 섞지 않았다.

### 106. credited progress minimum

144개 Journey의 연속 Event 121쌍에서 credited-progress-between 최소 1, 최대 2다.

### 107. zero-credit paths

0-credit pair는 0개다. credit 수는 종류별 누적 점수나 readiness와 무관하다.

### 108. 기존 strict spacing

기존 strict-between-actions는 0~4/zero75에서 1~3/zero0으로 바뀌었다. 기존 정의를 유지했다.

### 109. causing spacing

기존 including-causing-action은 0~4/zero63에서 1~3/zero0으로 바뀌었다.

### 110. Before/After Disturbance

Disturbance 170→159. 후보를 제거한 결과가 아니라 표시 경계/credit 제한 때문에 일부는 final에 남는다.

### 111. Before/After Major

Major 131→88. readiness threshold는 그대로이며 presentation을 지연했다.

### 112. Before/After Broadcast

Broadcast 131→88. 정상 Major가 줄어 연계 response가 함께 줄었다.

### 113. Before/After Interruptions

Interruption 301→247. eligible당 비율 0.232253→0.190586이다.

### 114. Before/After eligible

eligible opportunity 총합 1296→1296, 모든 개별 Journey의 7+e2+e3 accounting이 동일하다.

### 115. Before/After 기존 meaningful

기존 meaningful-action 총합 1296→1296. 새로운 승인 token은 after 1200이며 before에는 이 metric이 없었다.

### 116. CCTV presentation

Major CCTV 36→36, D CCTV 24→24. entry 대신 draw 이후 Next에서 표시한다.

### 117. Containment presentation

Major CONT 95→36, D CONT 67→64. EXP read Major 0→16, D EXP 79→71도 별도로 기록했다.

### 118. final unresolved records

final unresolved Candidate record 85→128. Candidate 삭제나 종료 처리로 숫자를 낮추지 않았다.

### 119. unresolved Journeys

unresolved가 남은 Journey는 82→113이다. 이 증가를 숨기지 않았다.

### 120. phase breakdown

UNDISTURBED 46→57, DISTURBED_NOT_READY 31→28, MAJOR_READY 8→43이다.

### 121. Event 삭제 없음

gate 때문에 Event/Candidate를 삭제하지 않는다. 기존 유효 response 완료 시 후보 제거 정책만 유지했다.

### 122. Candidate count 보존

candidate 등록/조회/threshold/count State API는 그대로다. presentation 전 ready 후보 수가 누적될 수 있다.

### 123. Candidate flags 보존

disturbance_triggered와 major_incident_triggered는 실제 표시 성공 함수에서만 변경한다. READY만으로 flag를 변경하지 않는다.

### 124. Candidate order 보존

get_candidate_case_ids의 등록 순서를 사용한다. Case ID 정렬이나 event-type 우선 sorting은 없다.

### 125. Research auto unlock 없음

gate OPEN만으로 Research를 자동 unlock하지 않는다. 기존 실제 source 표시/승인 action에서 discovery한다.

### 126. Source Archive

정상 response의 Source Archive source/current 구분과 current Runtime 보존을 actual read 경로에서도 검증했다.

### 127. Archive incremental merge

기존 Archive의 source-specific incremental merge와 Hypothesis 독립성 검사를 유지했다.

### 128. Broadcast draft

Broadcast의 임시 draft 복원과 confirmed 잠금은 유지했다. grant를 추가하지 않았다.

### 129. return CCTV

CCTV return_stage와 같은 Runtime 보존을 확인했다.

### 130. return EXP

EXP return_stage에서 마지막 실제 승인 결과 ID/text와 실행 시 조건 snapshot을 복원한다.

### 131. return CONT

CONT return_stage에서 confirmed Room/Pending과 버튼 잠금을 복원한다.

### 132. handoff 자동 실행 없음

Response 중·Resume 순간에는 handoff를 수행하지 않는다. 사용자 기존 Next가 필요하다.

### 133. View state 보존

D는 기존 View 인스턴스의 임시 상태를 유지하고 M은 기존 response 복원 계약에 따라 EXP 결과/CONT 확정 상태를 유지한다.

### 134. Runtime identity

모든 actual response의 before/after Runtime identity와 현재 Case identity를 검사했다.

### 135. handoff Runtime replacement

실제 handoff에서 Runtime 교체/old Runtime 해제, session State 유지, 새 Runtime reset을 검사했다.

### 136. invalid candidate

invalid 후보 fallback/retain+skip와 Snapshot invalid classification 회귀를 실행했다.

### 137. failed presentation credit

failed presentation은 bool을 소비하지 않는다. 새 token을 승인한 뒤 invalid만 있으면 OPEN을 유지한다.

### 138. no-experiment route

e2/e3=0 경로를 포함한 동일 144 matrix를 사용했다. 없는 EXP credit을 history나 가짜 Run으로 채우지 않았다.

### 139. Experiment 강제 없음

실험은 선택 사항이며 limit와 execution approval을 변경하지 않았다.

### 140. player timing manipulation

플레이어의 실험 수·Next 시점 선택은 readiness/presentation 타이밍에 영향을 준다. 이번 gate는 그 조작 가능성 전체를 해결하지 않는다.

### 141. F01 재측정

F01: OPEN 유지. Major threshold1과 opportunity 기반 predictability는 유지된다. 실제 Stage 빈도는 별도 table에 재측정했다.

### 142. F44-01 재측정

F44-01: 측정된 모든 정상 자동 Journey에서 최소 fresh credit≥1과 zero0이므로 RESOLVED. 사람의 피로감 개선은 미검증이다.

### 143. F44-02 재측정

F44-02: RESOLVED 유지. gate OPEN에서 oldest actionable, CLOSED에서 전면 차단한다.

### 144. F07-B 상태

F07-B: PARTIALLY ADDRESSED 유지. 최종 disposition의 사실 진단만 있고 Run/Settlement/queue drain은 없다.

### 145. Next-event 공식 위험

Next마다 사건이 끼어드는 공식으로 느껴질 가능성이 있다. token과 readiness가 의미적 연구 간격을 보장해도 체감 pacing은 사람 테스트가 필요하다.

### 146. double-Next UX 위험

Event 후 같은 단계의 Next를 한 번 더 눌러야 한다. 새 버튼을 추가하지 않은 정책의 double-Next UX 위험이다.

### 147. Resume confusion 위험

Resume가 화면 이동인지 연구 완료인지 혼동할 수 있다. 이번에는 text/UI 설계를 바꾸지 않았고 risk로 남겼다.

### 148. Main line count

Main은 작업 전 1629줄에서 1714줄로 증가했다. 전체 파일 재작성은 하지 않았다.

### 149. Main function count

Main top-level func는 87→93개다.

### 150. helper 추가

context 검증, 표시 frame 기록/확인, 실제 source ID 조회, token 승인, ready presentation 조회 helper 6개다.

### 151. View 수정

ExperimentView에 표시 결과 ID와 검증 getter 2개를 추가했다. 선택이 승인 Run 후 해제되는 기존 구조에서 history만으로 실제 표시 결과를 판단할 수 없어서 필요한 변경이다.

### 152. signal 추가 여부

새 signal·Scene·Button·Timer·Animation은 없다. 기존 Next/Confirm/Run 요청 signal을 사용한다.

### 153. State 변경

runtime State 파일은 수정하지 않았다.

### 154. Manager/Singleton

Manager·Singleton·Autoload·범용 framework는 추가하지 않았다.

### 155. Resource 불변성

Case/Resource/schema와 project.godot/Scene SHA256이 baseline과 동일하다. mutation fixture는 deep duplicate에만 적용했다.

### 156. debug Monitoring

현재 제품 Main에서 debug Monitoring→Incident/Broadcast/Result 경로를 별도 headless/GPU 검사했다.

### 157. normal/debug 분리

debug 경로는 normal Failure Candidate gate/token을 소비·생성하지 않는다. normal interrupt의 source/current context도 사용하지 않는다.

### 158. parser

40개 현재 제품 GDScript의 --check-only 검사를 수행했다.

### 159. editor import

Godot 4.7.1 headless editor import를 완료했다.

### 160. Main headless

project.godot에 지정된 실제 Main을 --headless --quit-after로 실행했다.

### 161. Main native

지정 Main을 Compatibility OpenGL/AMD RX6800 native GPU로 실행했다.

### 162. full regression

검증 프로세스와 Journey/assertion 수를 구분한 세부 table을 따른다. 과거 pacing assertion은 테스트 전용 호환 checkpoint fixture이고 현재 gate 계약은 실제 Main의 새/적응 검사를 사용한다.

### 163. Step46 Snapshot regression

Snapshot의 10개 headless/native 그룹을 재실행했다. idempotency/deep copy/State·Runtime·UI·opportunity·RNG·gate 비변경을 검사했다.

### 164. Step47 ordering regression

Step47의 20개 controlled ordering record, invalid/unready/reverse/same-phase와 finite candidate stress를 현재 Main에서 실행했다.

### 165. 144 matrix 새 실행

기존 로그는 보존하고 step48 아래 새 16개 프로세스×9개=144 Journey를 실행했다.

### 166. 3해상도

1920×1080, 1280×720, 1024×768의 logical1920/keep scaling과 하나의 주요 View를 검증했다.

### 167. GPU actual draw

native draw frame 증가와 PNG 캡처를 사용했다. viewport 캡처는 4:3 창에서 keep의 실제 16:9 render area일 수 있다. 사람의 실제 읽기 이해도를 측정한 것은 아니다.

### 168. warning

normal Main/144 matrix/gate/visual에는 warning0. invalid fixture만 예상 warning을 별도 집계한다.

### 169. runtime error

최종 성공 실행의 runtime/SCRIPT ERROR는 0이다. 구현 중 stale Runtime credit 결함과 verification fixture 오류는 수정하고 재실행했다.

### 170. parse error

최종 성공 실행의 parse error는 0이다. 과거 Profile fixture 복사 누락도 복원했다.

### 171. 실제 변경 파일

이번 제품 수정은 scripts/main/main.gd와 scripts/views/experiment_view.gd다. README와 Step48 보고서는 문서 변경이다.

### 172. 생성 파일

새 tracked 후보는 docs/step48_meaningful_research_pacing_gate.md 하나다. 검증 source/log/PNG/JSON은 ignored .godot/verification/step48에 있다.

### 173. 삭제 파일

기존 파일 삭제는 없다.

### 174. git diff --check

git diff --check가 통과했다. 줄끝 정규화 안내는 기존 gitattributes의 Git 안내다.

### 175. staged 여부

staged 파일은 0이다.

### 176. 기존 변경 보존

기존 Step46/47 보고서·read_models·기존 README block과 Main Snapshot/handoff/hidden Resolution 구현을 보존했다. source-before/tests-before SHA256 대조 결과를 기록했다.

### 177. commit/push 없음

HEAD/remote/branch를 변경하지 않았다. git commit/push를 실행하지 않았다.

### 178. P0

최종 미해결 P0 CODE finding은 없다.

### 179. P1

최종 미해결 P1 CODE finding은 없다. 측정된 zero-credit interruption 문제는 수정됐다.

### 180. P2

P2 UX: Next-event 공식/double-Next/CONT handoff 지연/Resume 혼동. P2 GAME DESIGN: F01/F07-B는 남는다.

### 181. P3

P3: Main-local 검증 helper와 표시 ID bookkeeping의 증가를 기록했다. 범용 refactor는 이번 범위에 추가하지 않았다.

### 182. CODE findings

CODE-48-01: 같은 Case ID의 새 Runtime에 old CONT가 credit 생성하던 문제를 재현→표시 당시 Runtime ID guard로 해결했다. hidden View/label, stale Next/Confirm도 차단한다.

### 183. UX findings

UX finding은 상태 전환과 draw를 확인한 자동/GPU audit이다. 사람이 내용을 읽고 Next/Resume를 해석하는 체감 검증은 별도다.

### 184. GAME DESIGN findings

GAME DESIGN: interruption 표시를 연구 간격에 묶었지만 threshold/opportunity predictability·player timing 선택·final unresolved를 해결하지 않았다.

### 185. F44-01 최종 판정

F44-01 최종 RESOLVED: 정상 matrix 121 연속 쌍의 credited min1/zero0. 피로도에 대한 일반화는 하지 않는다.

### 186. F44-02 최종 판정

F44-02 최종 RESOLVED 유지: 이전 bypass9 replay와 OPEN ordering/CLOSED denial을 보존했다.

### 187. F01 최종 판정

F01 최종 OPEN: Major threshold1과 임시 balance는 그대로다.

### 188. F07-B 최종 판정

F07-B 최종 PARTIALLY ADDRESSED: snapshot만 있고 마지막 Case Outcome0/Pending/후보를 실제 종료 처리하지 않는다.

### 189. gate가 해결한 것

즉시 연속 interruption을 차단하고, 새 CCTV/EXP 내용을 먼저 보여 준 뒤 자발적 Next에서만 끼어들며 Confirm action 중 Event를 분리했다.

### 190. gate가 해결하지 않은 것

읽기 이해도·사람 피로도·Next 예측 공식·실험 수 timing 조작·최종 sequence 종료 정책은 해결하지 않았다.

### 191. 사람 테스트가 필요한 것

첫 플레이에서 Next 두 번/Resume/Containment 보류를 이해하는지, 0/1/2 실험 선택 시 피로도·예측성이 어떻게 다른지 사람 테스트가 필요하다.

### 192. 다음 Step 추천

다음 Step은 새 기능보다 실제 플레이어 대상 Read Boundary/Resume/Handoff UX audit을 권한다. 종료/Settlement는 별도 정책 결정 이후 별도 구현한다.
