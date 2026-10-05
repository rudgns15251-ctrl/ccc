# Step40 — Delayed Major Incident Interrupt

작업일: 2026-10-05. 기존 프로젝트의 정상 Case 진행에 지연 Major Incident 대응을 연결했다. 기존 Step39 미커밋 변경을 보존했다. 커밋·push하지 않는다.

Case01의 실패는 handoff에서 내부 판정으로 남고, Case02의 안전한 Gameplay 기회가 환경 교란을 먼저 발생시킨다. 이후 별개의 유효한 기회에서 Case01의 INCIDENT → BROADCAST → INCIDENT_RESULT를 처리하고, 동일한 Case02 Resource/Runtime으로 중단했던 화면에 돌아온다. 정상 대응의 끝에 RESULT로 가지 않는다.

## 작업 전 실제 저장소

HEAD `0e9ae101d792c4c91a5f1886673f574215ae6454` (`Audit core loop UX and correct prototype status labels`). `master`가 `origin/main`을 추적한다. 기존 변경은 README.md, 두 Case `.tres`, 새 `docs/step39_case_evidence.md`였다. 프로젝트/상위 경로에서 적용할 AGENTS.md는 발견하지 않았다.

실제 소스 101개와 기존 검증 소스 2,539개의 SHA-256 기준선, 기존 diff, README 사본을 `.godot/verification/step40`에 저장했다. Main의 normal/debug route, 모든 기존 State/Resource/View 연결, Case01/02 콘텐츠와 Research 매핑, Step38/39 보고서, 기존 검증 자료를 조사했다. Step39의 두 Resource와 보고서는 이번 단계에서 변경하지 않았다.

| 실제 조사 대상 | 확인 결과 |
|---|---|
| project.godot / Main Scene | 1920×1080, canvas_items, keep, resizable, 1280×720 초기 창, Compatibility; Autoload 없음 |
| scenes | Main 1 + 주요 UI 12 + 보조 UI 2 = 15 Scene |
| scripts | 기존 Main 1 + State 6 + Resource 16 + View/common 15 = 38 GDScript |
| resources/cases | Case01/02 두 개; Case03 없음 |
| 기존 normal flow | PROFILE → CCTV → EXPERIMENT → CONTAINMENT → 다음 Case PROFILE; 마지막 Case02는 Pending |
| 기존 debug flow | test-only Main fixture의 MONITORING → INCIDENT → BROADCAST → INCIDENT_RESULT → RESULT |
| 기존 opportunity | CCTV 정상 entry, 성공한 고유 실험 실행, Containment 최초 entry; key 기반 중복 차단 |
| 기존 Research | current Case Runtime discovery, handoff Archive merge, authored ID validation, read-only Archive Detail, case별 Hypothesis |
| 기존 Case02 제한 | containment_outcomes 없음; 성공/실패나 다음 Case를 새로 만들지 않음 |

## 최소 구현과 책임

| 파일 | 변경 이유와 책임 |
|---|---|
| scripts/main/main.gd | 안전한 opportunity에서 delayed interrupt 시작, source ID lookup/승인, 명시적 normal/debug 분기, Source Archive navigation, source Research 병합, 같은 Runtime 복귀 |
| scripts/runtime/failure_event_candidate_state.gd | disturbance 이후 major count/threshold/triggered 추가, FIFO readiness 조회, 완료 후 정확한 candidate 제거 |
| scripts/runtime/incident_response_state.gd + .uid | 새 Main 소유 RefCounted 세션 상태. source/incident/broadcast/option/result ID와 ACTIVE/COMPLETED만 보관, 중복/중첩/덮어쓰기 차단, 깊은 복사 조회 |
| scripts/views/experiment_view.gd | 중단 직전에 완료한 실험의 결과를 기록된 ID/Snapshot으로 표시하는 작은 메서드 추가; 실행 승인/Runtime 변경 없음 |
| README.md / 이 문서 | Step40 요약, 임시 임계값, 검증과 실제 한계 기록 |

기존 Scene, project.godot, Case Resource, CaseRuntimeState, ResearchArchiveState, WorkingHypothesisState와 기존 View 파일을 전면 재작성하지 않았다. Incident/Broadcast/Result/Archive UI는 기존 Scene 그대로 사용한다. Main이 normal interrupt에서 기존 Research Log 버튼을 **Open Source Archive**로 바꾸고 해당 요청을 source Case Detail로 보낸다. IncidentResult에도 같은 읽기 경로를 제공한다. debug에서는 원래 Research Log 동작을 유지한다.

최종 구조:

```text
cap/
├── project.godot                         (보존)
├── README.md                            (Step40 요약 추가)
├── assets/                              (보존)
├── resources/cases/test_case_01.tres      (기존 Step39 변경 그대로)
├── resources/cases/test_case_02.tres      (기존 Step39 변경 그대로)
├── scenes/main/main.tscn                 (보존)
├── scenes/views/                         (기존 14 UI Scene 보존)
├── scripts/main/main.gd
├── scripts/data/                         (기존 16 Resource Script 보존)
├── scripts/runtime/                      (기존 6 State + IncidentResponseState)
├── scripts/views/                        (ExperimentView 표시 메서드만 추가)
└── docs/
    ├── step38_core_loop_audit.md         (보존)
    ├── step39_case_evidence.md           (기존 미커밋 파일 보존)
    └── step40_major_incident_interrupt.md
```

실제 제품은 39 GDScript, 15 Scene, 2 Case Resource, 0 Autoload다.

## 타이밍, 데이터 경계, 재현

`PROTOTYPE_DISTURBANCE_THRESHOLD = Vector2i(2, 4)`는 보존했다. `PROTOTYPE_MAJOR_THRESHOLD = 1`을 Main 한 곳에 추가했다. **TEMPORARY / PROTOTYPE 값이며 최종 밸런스가 아니다.** Main은 새 후보에 major threshold 1을 전달한다. Candidate API의 기존 3인자 호출은 추가 인자의 기본값 3으로 호환된다. threshold를 후보에 보관하므로 생성 후 같은 후보의 기준이 바뀌지 않는다.

opportunity 처리 시 기존 교란이 있는 후보의 major readiness를 먼저 계산한다. 이번 action에서 새 교란을 적용하면 Overlay를 표시하고 즉시 반환하므로 Major 화면을 동시에 열지 않는다. 교란을 이번에 얻은 후보의 major count는 0이다. Dismiss/idle/Log/Archive/Recheck/Room 선택과 Confirm은 기회를 추가하지 않는다. 기존 `_processed_opportunities`를 공유한다.

Main의 `IncidentRoute.DEBUG_RUNTIME / NORMAL_INTERRUPT`가 분기한다. 임시 navigation context에는 interrupted_case_id, return_stage와 동일 인스턴스 검증용 Runtime/Case instance ID 정수 두 개만 둔다. Resource나 Gameplay Snapshot을 넣지 않는다. Response에는 Resource를 넣지 않는다. 현재 CaseRuntime의 Monitoring/Broadcast 필드는 debug 경로의 기존 책임을 유지한다.

Experiment에서는 실행 승인과 base result 표시, 조건 결과, 실행 이력, 실제 Research discovery, UI 실행 상태 갱신을 마친 뒤 opportunity를 처리한다. Resume에서는 같은 Runtime의 마지막 완료 실험 ID와 **실행 당시 기록한** condition observation ID로 결과를 복원한다. 당시 조건 대신 나중 active condition을 대입하지 않는다. 미확정 선택을 저장하지 않고, 복귀한 실행 버튼은 선택이 없는 상태다.

Source Archive 병합은 실제 Incident 표시 → Broadcast 표시 → Option Confirm → IncidentResult 표시 순서다. source Case의 `_get_valid_research_entries` 정책을 그대로 사용해 source kind/id, 유일한 mapping/entry ID를 검사한다. fallback에는 synthetic ID를 만들지 않는다. 모든 추가 기록은 Archive의 **source_case_id + entry_id**로 들어가고 Case02 Runtime에는 들어가지 않는다.

candidate threshold/count, RNG seed, hidden Resolution object, 내부 status enum을 플레이어 UI에 표시하지 않는다. 개발 확인용 authored 콘텐츠 ID와 기존 설명만 표시한다.

### 현재 콘텐츠에서 가능한 진행

| Case02 교란 임계값 | 정상 진행 예 | Major/복귀 |
|---|---|---|
| 2 | CCTV(1) → EXP02 실행(2, 교란) → Dismiss → EXP01 실행 | EXP01 기록/조건 Research 완료 후 Major; EXPERIMENT 복귀 |
| 3 | CCTV(1) → EXP02(2) → EXP01(3, 교란) → Dismiss → Containment 최초 진입 | CONTAINMENT 복귀, Room 선택 전 |
| 4 | CCTV(1) → 두 실험(2,3) → Containment(4, 교란) | 뒤의 유효한 기회가 없어 보류; candidate 유지 |
| SUCCESS | Case01 ROOM02 제출 → Case02 | candidate/교란/Major 없음 |

실험 하나를 건너뛰거나 순서가 달라도 같은 key/threshold 원칙을 따른다. 현재 Case02에는 정상 CCTV 첫 entry 이전에 교란이 발생할 경로가 없다. 따라서 **CCTV Major 진입/복귀는 기존 교란이 존재하는 명시적 fixture로 검증했다.** 이를 현 두 Case의 무주입 정상 경로라고 보고하지 않는다. 확인된 Containment 잠금 복구도 확정 상태를 가진 안전한 entry fixture로 검사했다. 세 번째 Case나 억지 사건/기회를 추가하지 않았다.

## 검증 방법과 결과

Godot `4.7.1.stable.official.a13da4feb`, Windows, OpenGL Compatibility GPU를 사용했다. 실제 normal Main을 생성하고 버튼의 좌표에 mouse motion/press/release를 전달했다. 재현을 위한 RNG seed 고정 외에 12개 정상 응답 경로에는 stage/state 주입을 사용하지 않았다. 별도 CCTV/확정 Containment/FIFO/invalid fixtures는 각각 명시했다.

새 flow 검사 한 번에 두 실패 Incident × A/B/C × EXPERIMENT/CONTAINMENT = 정상 응답 12경로, CCTV fixture 6경로, late defer 2경로, SUCCESS 1경로를 검사한다. 이를 headless/GPU × 세 해상도에서 반복했다. 별도 edge 검사에 invalid source/Incident/Broadcast, duplicate mapping/Option, Result 거부 후 수리, nested/FIFO, blank IDs/deep copy/reset, source Research fallback을 포함했다. 추가 restore 검사는 실제 조건 결과 Label/스크롤 하단/Research와 확정 Containment Runtime/Pending/잠금을 검사한다.

기존 Step39 검증 소스는 수정하지 않았다. `.godot/verification/step40/legacy39`에 사본을 만들고 기존 환경-only 회귀에는 **Major 시작만 막는 test-only Main**을 사용했다. 환경 표시·기회·discovery·Runtime·경계 assertion은 유지했다. 기존 downstream debug fixture는 MONITORING~RESULT 경로를 그대로 검사한다. 따라서 과거 환경-only 성공 결과를 새로운 normal Major 경로의 증거로 혼동하지 않는다.

**최종 215/215 검사 통과:** headless 126개 + Windows GPU 89개. 기존 회귀/제품 파싱 199개와 Step40 flow/edge/restore/navigation 실행 16개다. 별도 최종 editor import도 오류·경고 0으로 통과했다. 실제 설정된 Main Scene을 두 backend에서 실행했다. 수동 F5 키 입력은 하지 않았다.

| 검증 증거 | 결과 |
|---|---|
| flow 6회 | 응답 108경로(정상 72 + CCTV fixture 36), late defer 12경로, SUCCESS 6경로 |
| edge 2회 | 상태 ID/복사/reset + invalid/repair/FIFO/nested fixture 32개 |
| restore 6회 | 실행 당시 조건 결과 Label/Log/스크롤 복원 + 확정 Containment safe-entry fixture |
| navigation 2회 | Source Archive 중 stale Broadcast Confirm, 복귀 후 stale Detail Open/Back 차단 |
| 기존 199회 | 전체 제품 Script 39개 check-only, normal/environment/read-only/session 회귀, debug downstream/경계 회귀 |
| 로그 무결성 | 모든 최종 PASS 로그 SHA와 반환값·경고 수 재검사 통과 |
| 의도한 invalid fixture 경고 | 기존 1,172 + 새 edge 54 = 1,226; 예상치와 일치, 예상 밖 오류/경고 0 |
| Scope / diff | 기준선 101개 중 97개 SHA 동일, 허용된 4개만 수정; Step40 3개 추가, 삭제 0 |
| 기존 작업 보존 | Step39 두 Resource/보고서 SHA 동일, README 기존 내용/줄끝 보존, 이전 검증 소스 2,539개 SHA 동일 |
| 프로젝트 / Scene | project.godot과 기존 모든 Scene byte SHA 동일; Autoload/해상도/Stretch 추가 변경 없음 |
| Git | git diff --check 통과, HEAD 그대로, commit/push 없음 |

검증 준비 중 새 검사에 스크롤 helper가 없던 문제와 Vent fixture ID 오타를 수정했다. 기존 GPU flow 회귀 사본의 빈 `regression` 캡처 폴더가 누락되어 PNG 저장이 한 번 실패했고, 해당 폴더를 생성한 뒤 동일 입력 서명/로그 SHA가 확인된 성공 검사들을 재사용하여 남은 회귀를 완료했다. 원본 검증 코드를 수정하거나 assertion을 약화하지 않았다. 최종 제품 파싱/실행 오류는 없다.

GPU capture는 창 1920×1080 / 1280×720 / 1024×768에서 얻었다. 4:3 창의 root render texture는 keep 정책의 1024×576 영역이며, 캡처 파일은 창 바깥 letterbox를 포함하지 않는다. 새 Major 제목/버튼/Archive/복귀 화면과 실험 결과 스크롤 하단을 직접 확인했다. 최종 UI 디자인이나 콘텐츠 품질을 검증했다는 뜻은 아니다.

검증 소스/로그/이미지/기준선은 기존 정책에 따라 Git에서 제외된 `.godot/verification/step40`에 있다. 대표 실행 명령:

```powershell
& 'C:\Users\newsj\Downloads\Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64_console.exe' --headless --path . --editor --import --quit
& .godot/verification/step40/run_validation.ps1
```

## 요청한 106개 종료 보고 항목

| # | 항목 | 실제 구현/확인 |
|---|---|---|
| 1 | 작업 전 Git | 위 HEAD/branch와 Step39 네 파일 변경 확인, SHA 기준선 확보. |
| 2 | 정상 지연 흐름 | 실패 handoff → Case02 교란 → 이후 opportunity → Incident/Broadcast/Result → Case02 Resume. |
| 3 | 교란/Major 분리 | 서로 다른 candidate flag/count와 서로 다른 UI 경로. |
| 4 | 같은 action 차단 | 새 교란 적용 action은 Notice를 표시하고 return; 해당 후보 major count 0. |
| 5 | Major threshold | 후보별 major_trigger_threshold와 major_opportunity_count. |
| 6 | 임시 값 | Main 상수 1, 기존 교란 범위 2–4; TEMPORARY/PROTOTYPE 명시. |
| 7 | Candidate 변경 | major count/threshold/triggered와 advance/mark/완료 제거 API 추가. |
| 8 | source Case 정책 | 후보 source_case_id를 유지; 현재 Case ID로 대체하지 않음. |
| 9 | current/source 구분 | 응답은 Case01, Runtime/current_case는 Case02. |
| 10 | source lookup | case_sequence의 정확히 하나인 case_id 매핑만 허용. |
| 11 | duplicate Case | warning/defer, 첫 매칭 사용 금지; edge fixture 통과. |
| 12 | Incident lookup | source Case의 incident_id 유일 매핑; null/중복은 defer. |
| 13 | 안전한 기회 | 기존 CCTV entry/성공한 고유 실험/Containment entry만 사용. |
| 14 | 위험 시점 차단 | active/modal/route guard, Timer/process trigger 없음; mutation 완료 뒤 실행. |
| 15 | 실험 순서 | 승인/결과/조건/이력/discovery/UI 갱신 후 opportunity. |
| 16 | Room 선택/Confirm | opportunity 처리 호출 없음; Containment entry에서만 검사. |
| 17 | 읽기/가설 제외 | Log/Archive/가설 CRUD/recheck는 opportunity가 아님. |
| 18 | farming 방지 | 기존 processed key 재사용; resume/recheck/reading은 false entry. |
| 19 | 여러 후보 | State의 case order/Dictionary 유지; 동일 source 후보 중복 차단. |
| 20 | FIFO | oldest ready 중 유효한 첫 후보만 시작, 다른 후보는 유지; FIFO fixture. |
| 21 | 중첩 차단 | normal route 또는 ACTIVE Response가 있으면 새 opportunity/start 거부. |
| 22 | Response State | 작은 RefCounted 세션 상태 1개 추가. |
| 23 | identity | source_case_id + incident_id의 JSON pair key, index 사용 안 함. |
| 24 | Resource 미보관 | Response 값은 ID String/status int; getter copies 검사. |
| 25 | Main 소유 | _ready에서 Main이 상태 생성; 전역 등록 없음. |
| 26 | Runtime 독립 | 정상 응답을 Case02 Runtime Broadcast/Monitoring 필드에 기록하지 않음. |
| 27 | Interrupt Context | Main 임시 navigation Dictionary, 완료 시 clear. |
| 28 | context 필드 | interrupted_case_id/return_stage + 동일 인스턴스 검사 정수 2개. |
| 29 | 시작 승인 | ready candidate/hidden failure/source unique/display content/사용 가능한 응답 체인 확인. |
| 30 | 실패 공개 시점 | Major 시작에서 기존 authored Incident 표시; hidden Outcome 자동 요약 미추가. 기존 authored 설명의 failure 문구는 보존. |
| 31 | Incident 재사용 | 기존 Incident Scene/Script 그대로; normal 제목만 MAJOR CONTAINMENT INCIDENT. |
| 32 | Broadcast lookup | source Incident.broadcast_id를 source Case에서 조회. |
| 33 | Confirm 저장 | Main 승인 뒤 IncidentResponseState.try_confirm. |
| 34 | Case02 Runtime | 대응 전/후 exact Runtime snapshot 및 instance 동일성 확인. |
| 35 | Confirm 검증 | active view/route/context/source/incident/broadcast/unique option/유효 result + 실제 표시 Resource 확인. |
| 36 | dead-end 방지 | 최소 usable chain 시작 전 확인; invalid result는 잠금 전 거부. |
| 37 | 중복 Confirm | State가 confirmed_option_id overwrite 거부, View 잠금 복원. |
| 38 | Result lookup | source Case result_id 유일 조회, confirmed result 연결 변경도 거부. |
| 39 | 완료 시점 | 실제 IncidentResult View의 enabled Next에서 active guard/context/result 검증 후 COMPLETED. |
| 40 | 후보 제거 | 응답 완료 승인 뒤 source_case_id + incident_id/triggered 확인해 제거. |
| 41 | 환경 보존 | 응답/Archive 접근/Resume에서 applied disturbances를 지우지 않음. |
| 42 | Resume | 저장 return_stage에 false entry로 돌아감. |
| 43 | 동일 Runtime | Runtime instance ID context 검사; case_runtime 교체/reset 없음. |
| 44 | 동일 Case | current_case instance ID context 검사; reload/replace 없음. |
| 45 | View 재생성 | 기존 정책 유지; history/조건/확정 잠금 Runtime에서 복원. |
| 46 | transient 선택 | 별도 저장 시스템 없음; 안전한 기회에서만 interrupt. |
| 47 | Resume opportunity | _show_view(return_stage, false); processed keys 그대로. |
| 48 | source Research | Case01 entries를 Case02 discovery에 넣지 않음. |
| 49 | 직접 incremental merge | ResearchArchiveState.merge_case_discoveries(source.case_id, [entry.entry_id]). |
| 50 | Incident 발견 | 실제 normal Incident View 표시 및 유효 Next 확인 후 merge. |
| 51 | Broadcast 발견 | 실제 source Broadcast View 표시 때만 merge. |
| 52 | Option 발견 | valid Confirm 승인 성공 때만 merge. |
| 53 | Result 발견 | 실제 source IncidentResult View 표시 때만 merge. |
| 54 | authored 검증 | 기존 source_kind/id, 중복 source/entry ID rejection 사용. |
| 55 | fallback | authored entry 없으면 기존 UI 문구만 표시; synthetic Archive ID 없음. |
| 56 | Case02 Log 분리 | source 종류 4/5/6/7과 Case01 discovery ID가 Runtime/Log에 없음 확인. |
| 57 | Source Archive | Incident/Broadcast/IncidentResult의 Open Source Archive → Case01 Detail → Back. |
| 58 | 기존 Log 버튼 | normal에서는 같은 버튼을 source Archive action으로 전환; current Log를 열지 않음. debug 보존. |
| 59 | source 가설 읽기 | 기존 Detail snapshot의 Case01 hypotheses 사용, Current hypothesis 혼입 없음. |
| 60 | 읽기 opportunity | 여러 Open/Back 전후 candidate/processed keys/Response/Runtime 동일. |
| 61 | SUCCESS | ROOM02 정상 handoff 후 후보/교란/Response 없음. |
| 62 | 교란 전 FAILURE | 임계값 이전에 Response 없음 확인. |
| 63 | 교란 action | Notice와 active Response 동시 없음, major count 0. |
| 64 | 정상 Major 흐름 | 두 실패 × A/B/C × threshold2/3 = 정상 12경로/검사 실행. |
| 65 | Experiment interrupt | 실행 결과·history·Research 완료 후 Major; 결과/조건 UI 복원. |
| 66 | CCTV interrupt | pre-existing disturbance fixture 6경로; 동일 CCTV 복귀, opportunity 재처리 없음. |
| 67 | Containment interrupt | 최초 정상 entry에서 발생, Room 선택 전 복귀; 확정 잠금 별도 fixture. |
| 68 | Option A | 두 Incident의 A Confirm/result/completion/resume 통과. |
| 69 | Option B | 두 Incident의 B와 Archive 잠금 왕복 통과. |
| 70 | Option C | 두 Incident의 C 통과. |
| 71 | 다른 실패/debug | ROOM01/03 모두 source lookup; 기존 debug 6 downstream 경로 회귀 유지. |
| 72 | Archive 순서 | 기존 Profile/CCTV/실험/Room 뒤 Incident/Broadcast/Option/Result ID 순서 assertion. |
| 73 | dedup | 반복 source View/Archive Open/Back에서 entry_ids 중복 없음. |
| 74 | 후보 재발 | 완료 후 후보 없음, 같은 processed key로 두 번째 Response 생성 없음. |
| 75 | 완료 응답 보존 | COMPLETED record 세션 유지; 별도 history UI 없음. |
| 76 | Response duplicate | ACTIVE/COMPLETED 동일 pair 생성 거부; 다른 source의 같은 incident_id 허용. |
| 77 | invalid source | 누락/중복 source Case warning/defer/current Runtime/candidate 유지. |
| 78 | invalid Incident | 누락/중복/빈 설명 거부; 현재 Gameplay 유지. |
| 79 | invalid Broadcast | 누락/중복/빈 prompt 또는 usable chain 없음은 시작 거부. |
| 80 | invalid Result | Confirm 거부/미잠금/Response 유지; fixture 수리 후 진행 확인. |
| 81 | stale View | 이전 Incident/Broadcast/Result의 advance/log/confirm active guard, archive/resume 전후 검사. |
| 82 | forged Option | 존재하지 않는 option_id/다른 broadcast_id 거부. |
| 83 | stale Source Archive | 이전 Detail Back/Open 요청이 현재 대응 stage/state를 바꾸지 않음. |
| 84 | Case02 환경 | Power/Vent 교란 Runtime 보존, CCTV/Experiment/Containment 표시 복원. |
| 85 | 조건 Research | Runtime의 observed/discovered/condition IDs 유지; 조건 Label/Log 추가 확인. |
| 86 | Case02 가설 | Current hypothesis 대응 전후 동일; 자동 생성/수정 없음. |
| 87 | 가설 분리 | Case01 source Detail read-only, Case02 notebook 상태 독립. |
| 88 | normal RESULT 제외 | normal _advance_response는 Resume만 호출; 정상 흐름에서 RESULT 표시 없음. |
| 89 | debug RESULT 유지 | 원래 Monitoring/Incident/Broadcast/IncidentResult/Result 분기 보존 및 회귀. |
| 90 | 명시적 mode | IncidentRoute enum으로 두 저장/종료 정책 구분; 일반 Stage 프레임워크 없음. |
| 91 | Main 책임 | 승인/lookup/discovery/navigation orchestration; 콘텐츠 규칙/정답 표 미추가. |
| 92 | Manager 없음 | Singleton/Autoload/IncidentManager/ResponseManager/EventBus 없음. |
| 93 | Severity 없음 | MAJOR slice UI 이름만 사용; MINOR/MODERATE/MAJOR enum/우선순위 없음. |
| 94 | 미래 종류 여지 | 교란 적용과 Major 시작은 별개 API/flag; 이번 테스트 후보만 delayed 경로 사용. |
| 95 | 강제 사건 없음 | all-success/idle/Case02 마지막 submit에 사건을 만들지 않음. |
| 96 | Resource 불변 | 기존 Step39 두 .tres SHA 보존, 실행 중 authored Resource snapshot 불변. |
| 97 | Runtime 경계 | 현 Case facts는 Runtime, cross-case research는 Archive, source 응답은 Response, 복귀는 Main context. |
| 98 | 정상 회귀 | Profile/CCTV/실험/Containment/handoff/discovery/환경/Log/Archive/Hypothesis 기존 assertion 유지. |
| 99 | debug 회귀 | 별도 debug fixture에서 Monitoring~RESULT, A/B/C, invalid data/stale/confirmation/security 유지. |
| 100 | 세 해상도 | 1920×1080/1280×720/1024×768 actual GPU + headless; 기존 stretch/keep 설정 불변. |
| 101 | 파싱/실행 | Godot 4.7.1 editor import, 전체 제품 Script check-only, 설정된 Main 실행. 수동 F5 키 입력은 하지 않음. |
| 102 | 오류/해결 | 검증 helper/fixture ID/캡처 폴더 누락 수정 후 전체 완료. 최종 제품 오류·예상 밖 경고 0. |
| 103 | 파일 변경 | Step40 기존 4개 수정 + 3개 추가; Scene/설정/Case Resource 삭제·수정 없음. |
| 104 | 기존 변경 보호 | 두 Step39 Resource/보고서 byte SHA, README 기존 내용, 이전 검증 소스 보존 검사. |
| 105 | 미구현 | Severity/Case03/Campaign/SaveLoad/idle Timer/임의 interrupt/환경 cross-case persistence/History UI/자동 가설/점수/최종 효과·UI 없음. |
| 106 | 다음 시작점 | 기존 authored Incident/Broadcast 임시 문구와 delayed opportunity 밸런스 수동 UX 검증. 미래 종류는 별도 요구 확정 후 구현. |

## 발견한 제한과 다음 단계

현재 authored Incident 설명에는 `TEST_ROOM_01/03 failure`라는 기존 임시 문구가 있다. Step40은 이를 그대로 표시하며 hidden resolution에서 Room 정오답 설명을 새로 합성하지 않는다. 응답 내용/실험/격리 평가를 최종 게임 콘텐츠라고 간주하지 않는다.

기회 부족으로 사건이 보류되는 것은 의도한 delayed 조건의 결과다. 마지막 Case02에는 Outcome/다음 Case가 없어 기존 Pending 정책을 보존했다. 재시작/세션 저장, 모든 종류의 교란 escalations, 임의 시점 선택 보존, severity balance는 이번 범위가 아니다. 다음에는 정상 두 Case 플레이에서 교란·대응·복귀를 사용자가 이해하는지, source Archive가 응답 판단에 충분한지를 수동 UX로 확인하기 좋다.
