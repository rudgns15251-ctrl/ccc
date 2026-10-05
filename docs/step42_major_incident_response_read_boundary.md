# Step42 — Major Incident Response Content + Context + Read Boundary

2026-10-05, Godot 4.7.1 Standard / GDScript / Windows PC.

기존 프로젝트에 Step42를 구현했다. Case01의 두 사건·여섯 대응에 관찰 근거와 서로 다른 임시 조치·결과를 작성하고, 정상 대응 화면에 출처와 중단된 업무를 표시했다. EXP 실행은 결과를 먼저 보여주고 Major 준비만 기록한다. 준비된 사건은 다음 정상 CCTV/Containment 진입 경계에서 표시한다. 정상 Broadcast의 미확정 선택은 직접 Source Archive 왕복 동안만 보존한다.

점수·정답·새 gameplay consequence·Timer·추가 opportunity는 만들지 않았다. 임시 TEST 콘텐츠이며 최종 설정이나 장기 격리 해법을 확정하지 않는다. 커밋·push하지 않았다.

## 조사와 기준 상태

실제 저장소의 추적 파일, 폴더, Main/관련 View/State/Data/Resource와 이전 검증 자료를 조사했다. `AGENTS.md`는 저장소와 상위 경로에서 발견되지 않았다. 프로젝트에는 이미 정상 Case handoff, 실패 Candidate/환경 교란/Major Response, 세션 Archive/Hypothesis, 별도 debug Monitoring 흐름이 있었다. 새 프로젝트를 생성하지 않았다.

- HEAD: `ac1605935a2bab92cb1c43b2709cdde0f5f36c81` — `Refine case evidence and add delayed major incident responses`.
- branch: `master`, upstream: `origin/main`; 시작 시 remote와 동기화.
- remote: `https://github.com/rudgns15251-ctrl/ccc.git`.
- 시작 변경: `M README.md`, `?? docs/step41_major_incident_pacing_audit.md`. Step41 감사가 아직 미커밋이었다.
- 기존 product GDScript 39개, Scene 15개, Case Resource 2개, Autoload 0개. 새 product Script/Scene/Case는 추가하지 않았다.
- 시작 시 Main은 1,497줄/81함수, 변경 후 1,542줄/83함수다. 추가 함수는 표시 context 생성과 Broadcast draft 복원이다.
- 104개 추적 파일과 기존 Step41 보고서의 시작 SHA-256을 기록했다. 기존 검증 파일도 별도 hash로 보호했다.
- `project.godot`, Main Scene, Case02, Data/Runtime State schema, 기존 Scene UID/Script UID와 이전 검증 원본을 보존했다.

Step41의 F02~F06을 다시 실제 코드·Resource·실행으로 확인했다. 기존 Incident 화면뿐 아니라 authored Incident Research에도 `Room 01/03 failure` 문구가 있었다. **Step41의 Archive 관련 평가는 이 누설을 정확히 짚지 못했다.** 이번에는 화면과 Research를 함께 수정했고, 기존 Step41 보고서는 감사 당시 기록으로 그대로 보존했다.

## 변경 파일과 책임

| 파일 | 이번 변경 | 이유 |
|---|---|---|
| `scripts/main/main.gd` | EXP 읽기 경계, 표시 snapshot, Archive 왕복 draft 승인/복원, response View 높이 | 상위 Main이 전환·검증·현재 업무 문맥을 관리 |
| `scripts/views/flow_view.gd` | 전달된 context를 optional Label에 표시 | View는 Main/State를 조회하지 않음 |
| `scripts/views/broadcast_view.gd` | 미확정 ID 조회/복원, detached/confirmed guard | 로컬 선택을 복원하되 확정 signal을 발생시키지 않음 |
| `scenes/views/incident_view.tscn` | 숨겨진 `ResponseContext` Label 1개 | 정상 Major에서 출처와 현재 업무 표시 |
| `scenes/views/broadcast_view.tscn` | 같은 Label 1개 | 대응 선택 중에도 출처 유지 |
| `scenes/views/incident_result_view.tscn` | 같은 Label 1개 | 결과를 읽고 돌아갈 업무 안내 |
| `resources/cases/test_case_01.tres` | response 16 Resource + Research 16 Resource의 텍스트만 | 기존 evidence에 연결된 임시 authored 대응 |
| `README.md` | Step42 설명 블록 추가 | 현재 실행 정책 안내; 기존 내용 보존 |
| `docs/step42_major_incident_response_read_boundary.md` | 새 보고서 | 요청한 105개 항목과 검증 결과 |

총 기존 파일 8개 수정, 문서 1개 생성이다. Git에는 이전 Step41 보고서도 untracked로 보인다. 그것은 이번에 생성한 파일이 아니다. 삭제 파일은 없다. 검사 Script/fixture/로그/PNG는 ignore된 `.godot/verification/step42/` 안에만 추가했다.

세 response Scene의 기존 역할·Node/Signal 경로는 유지한다. Scene 구조는 기존 `Control → Center → Content` 안에 `ResponseContext`가 이름/ID 뒤, 설명 앞에 들어간다. Broadcast의 기존 OptionScroll/Confirm/Next/Archive 버튼을 사용한다. Main ViewHost의 response 높이만 660으로 늘려 긴 설명과 5줄 context가 겹치지 않게 했다. 최종 UI 디자인은 아니다.

## 읽기 경계와 화면 context

기존 EXP callback은 승인된 실험의 Base/Condition 결과를 갱신한 직후 Major View로 교체해서, 결과가 렌더되기 전에 사라졌다. 이제 같은 callback에서 실험 이력·조건 관찰·Research 발견·기존 opportunity와 Major readiness를 기록한 뒤 EXP 화면을 유지한다.

현재 pool의 정상 경로는 다음과 같다.

```text
Case01 제출 → Case02 PROFILE → CCTV → EXPERIMENT
→ 실험/교란 Notice → Dismiss → 다음 실험 실행
→ 결과가 실제 draw된 EXPERIMENT, Major ready (count=1, triggered=false)
→ 읽기/스크롤/idle/Research Log 왕복
→ Next: CONTAINMENT (기존 정상 entry opportunity)
→ INCIDENT → BROADCAST → INCIDENT RESULT
→ Resume: CONTAINMENT (동일 Case02 Runtime)
```

새로운 입력/타이머/acknowledgment나 기회를 추가하지 않았다. 안전한 경계는 기존 정상 CCTV/Containment entry이며, 현재 정상 흐름에서 EXP 뒤 실제 선택 가능한 경계는 Containment 진입이다. Log Back, Recheck Back, Dismiss, idle은 준비된 Major를 표시하지 않는다. EXP 실행에서 readiness에 도달한 뒤 Containment entry에 도달해도 count는 기존 threshold 1에서 포화되고, 기존 entry key만 한 번 처리한다. 교란 우선 순서와 FIFO/dedup은 유지한다.

`_build_response_display_context()`는 Main의 기존 interrupt identity와 unique source lookup을 검증하고 5개의 표시용 문자열만 생성한다: `source_case_id`, `source_case_display_name`, `interrupted_case_id`, `interrupted_case_display_name`, `return_stage`. Result에만 표시용 `resume` bool을 덧붙인다. 기존 return Stage/instance identity를 바꾸거나 View에서 추론하지 않는다.

- INCIDENT/BROADCAST: `SOURCE CASE` + source 이름/ID, `CURRENT WORK INTERRUPTED` + current 이름/ID·Stage.
- INCIDENT RESULT: 같은 source와 `RESUME WORK` + 실제 current 이름/ID·복귀 Stage; 버튼은 짧게 `Resume: CONTAINMENT`.
- missing/foreign/stale identity, invalid Stage, invalid source에서는 다른 Case 이름으로 대체하지 않는다. 표시 row를 숨기고 유효 context 없는 진행을 막는다.
- debug는 cross-Case context를 받지 않는다. 추가 Label은 숨기고 기존 `Next: RESULT` 경로를 유지한다.

수동 fixture에서는 결과 draw 후 기존 `_try_start_major_incident` API를 호출해 EXP 복귀 compatibility도 검증했다. 이것은 정상 presentation 경계가 아니며 정상 Case02는 위의 Containment로 복귀한다. 기존 CCTV 복귀와 확정 Containment 복귀 회귀도 유지한다.

## authored 대응과 관찰 근거

Incident01은 pump 시작 뒤 service-panel mount에 집중되는 타격과 구조 진동, 조명 끊김, 유지되는 wall tracing을 설명한다. Incident03은 vent stop/start에 따른 outlet turn-back과 tracing 중단, service restart 후 불안정한 airflow를 설명한다. 실패 Room ID·정오 평가·correct Room을 적지 않았다.

Case01의 기존 Profile/CCTV는 금속 지지부 pump timing, vent 전환과 turn-back, lamp sweep과 이동을 제시한다. EXP01은 금속/패딩 지지부 충격 비교, EXP02는 연속 저풍량/stop-start 비교, EXP03은 스피커 소리만 재생하는 비교다. **이 정보는 이번에 변경하지 않았다.** prompt에는 현재 사건과 관련 단서를 짧게 다시 설명하므로 Archive를 열지 않아도 대응할 수 있다. Archive는 실제 발견한 과거 상세 실험과 source 개인 메모를 다시 읽는 선택 경로다. 미발견 실험은 Archive에 추가하지 않는다.

| 사건/Option | 조치와 우선순위 | 근거와 남는 문제 | authored 결과 |
|---|---|---|---|
| 01 A | service mount를 기계적으로 분리하고 airflow 유지 | EXP01 지지부 전달 충격; seam 접근은 계속 관찰 | 타격 감소, wall tracing/seam 접근은 남음 |
| 01 B | 공기 전달 기계 소음 감소, rigid 연결·airflow 유지 | EXP03 소리만으로 strike 재현 안 됨; 구조 충격을 제거하지 않음 | speaker 방향 주시 중단, pump-start 타격 지속, 구조 전달 미해결 |
| 01 C | vent cycling으로 service panel에서 이동을 유도 | CCTV/EXP02 airflow 전환은 outlet turn-back을 유발할 수 있음 | 첫 이동 유도 뒤 반복 outlet turn-back, 타격 지속; cue 추가 |
| 03 A | 현재 lighting/support 아래 연속 저풍량 유지 | EXP02 반복 airflow 전환 제거; 다른 자극은 미검증 | turn-back 감소/tracing 길어짐, panel 접근 남음/구조 자극 미검증 |
| 03 B | task lighting 감소, vent cycling/support 유지 | CCTV lamp sweep은 이동 경로와 관계; airflow 원인은 남음 | crossing 감소/긴 pause, vent restart turn-back 지속 |
| 03 C | service mount damping 추가, vent cycling 유지 | EXP01 구조 전달 우선; 반복 airflow cue는 남음 | panel 진동 감소, vent turn-back과 tracing 중단 지속 |

모든 이름/설명은 TEST/temporary 문맥이다. A/B/C를 성공/실패나 점수로 분류하지 않는다. 결과는 서로 다른 관찰 변화와 잔여 문제의 텍스트이며 현재 Case의 환경/실험/판정에 영향을 주지 않는다. 장기 격리 정답을 안내하지 않는다. 기술 검증과 내용 검토를 수행했지만 사람 플레이테스트로 전략의 난이도·몰입감을 검증했다고 주장하지 않는다.

기존 Incident/Broadcast/Option/Result ID와 연결을 유지했다. Research 2+2+6+6개 title/body도 대응 화면과 동기화했다. Resource block 32개, 텍스트 필드 58개만 변경했고, 기존 schema와 모든 비텍스트 필드는 유지한다.

## Archive draft와 기록 경계

기존에는 미확정 선택이 Broadcast View 로컬에만 있어 Archive 왕복 시 새 View에서 사라졌다. 정상 Broadcast에서 유효 선택을 한 뒤 **직접 Source Archive를 여는 순간에만**, Main의 기존 `_interrupt_context["broadcast_draft"]`에 source Case/Incident/Broadcast/Option의 네 ID 문자열을 임시 저장한다.

Back 때 active response/현재 Runtime/Stage/ID/unique Option/valid result를 재검증하고 새 Broadcast View의 로컬 선택을 복원한 뒤 draft를 소비한다. old View를 재사용하지 않는다. 다른 Stage, 종료/초기화, foreign response/ID, confirmed response에서는 폐기한다. 반복 왕복은 그때의 로컬 선택을 새로 저장한다. Scroll 위치는 복원하지 않는다.

draft는 confirmation이 아니다. 선택·Archive 왕복으로 Response의 `confirmed_option_id`나 Research/Archive를 기록하지 않으며 Next는 계속 잠긴다. **Confirm Broadcast** 승인 후에만 기존 authoritative response에 Option을 기록하고 Option Research를 merge한다. 이후 Archive 왕복에서는 기존 confirmed snapshot이 잠금을 복원한다. Result 표시에서만 Result Research를 merge하고, Resume 후 Candidate를 완료/제거한다. Incident → Broadcast → confirmed Option → displayed Result의 incremental merge와 ID dedup을 유지한다.

## 검증 결과와 재현 자료

Godot `4.7.1.stable.official.a13da4feb`, Windows, GL Compatibility / AMD Radeon RX 6800을 사용했다. 실행당 60초 timeout, exit code/ERROR/SCRIPT ERROR/Parse Error/예상 warning 수를 검사하고 로그 hash를 기록했다.

| 묶음 | 실행 수 | 내용 |
|---|---:|---|
| 기존 회귀 사본 | 199 | product Script 39개 parse; 상태/Archive/Hypothesis/조건/경계/stale/ID/debug/resize |
| Step40 대응 회귀 사본 | 16 | normal Major/FIFO/navigation/restore/evidence/edge |
| Step42 | 20 | 정상 6대응×Archive 유무, 읽기/draw/context/draft, current authored debug, invalid edge, EXP resume fixture |
| 합계 | 235 | headless 136, native GPU 99; 내부 assertion/반복 Journey 수와 합산하지 않음 |
| 별도 기본 실행 | 3 | editor import, configured Main headless, configured Main native |

Step42 정상 대응 12경로를 3해상도×2모드에서 반복해 72 Journey를 확인했다. SUCCESS 6, late Deferred 12, current authored debug 42(각 실행당 실패 6+성공 1), invalid context/draft 24, EXP resume compatibility fixture 6경로는 별도 내부 시나리오 수다. 이것을 235개 suite 실행 수에 더하지 않았다.

예상된 invalid/null/duplicate fixture warning은 기존 1,226개와 새 edge 4개, 총 1,230개다. 정상 대응/current authored debug/읽기/기본 실행의 warning은 0개다. 오류/파싱 오류는 없다. 방어 코드 warning이 뜨는 invalid fixture를 정상 제품 warning으로 오해하지 않도록 묶음별 수를 기록했다.

기존 검사 원본 3,134개를 수정하지 않고 Step42 폴더에 사본을 만들었다. 변경된 read-boundary 기대값, 숨겨진 context Label node 수, 허용된 authored text 비교만 사본에서 조정했다. 과거 debug 테스트의 literal 임시 문구 검사는 HEAD의 Case01 snapshot을 사용하는 역사 fixture로 유지했고, **현재 실제 authored Case01 debug SUCCESS/FAILURE는 새 검사를 별도로 6회 실행**했다. Step41은 문제를 기록한 audit이므로 같은-callback Major 발생을 요구하는 옛 audit을 새 정상 계약으로 재사용하지 않았다.

정상 Journey는 seed로 기존 2/3/4 RNG 결과를 재현하고 제품의 실제 버튼 위치에 InputEvent mouse press/release를 전달했다. 정상 전환을 Stage 강제 변경으로 대체하거나 threshold 상수를 바꾸지 않았다. 별도 invalid/context/ready-entry/debug playback fixture는 보완 회귀를 위한 통제된 입력이며 정상 플레이 Journey와 구분했다. 새 플레이어의 첫 플레이를 직접 관찰한 연구는 아니다.

| 실제 창 | logical UI / 캡처 영역 | 확인 |
|---|---|---|
| 1920×1080 | 1920×1080 / 1920×1080 | full response, draft Archive, 결과/조건 읽기, debug, Resume |
| 1280×720 | 1920×1080 / 1280×720 | 동일 경로, 긴 문자열 wrap/Option scroll |
| 1024×768 | 1920×1080 / 1024×576 | keep 비율의 여백; 작은 창에서 세 Option 접근/버튼과 context |

native 실제 입력 후 frame draw 증가와 동일 EXP View를 검사했다. 각 해상도의 첫 ready 입력은 `56 → 59` frames drawn, Stage는 EXPERIMENT, Condition 관찰 1개였다. 해상도별 ready draw probe 12개 모두 통과했다. 숫자 자체를 고정 계약으로 삼지 않고 입력 이후 draw 증가를 검사했다. Base 결과, Condition 관찰 상단/스크롤 끝, Incident source/current, Broadcast 선택, Result resume, Archive, debug PNG를 세 해상도로 저장했다. PNG를 직접 열어 텍스트 줄바꿈/범위/버튼을 확인했다. 긴 Condition Label은 기존 ResultScroll보다 높으므로 스크롤 상단과 끝의 intersection/readability를 각각 검사한다. 한 번에 label 전체가 viewport 안에 들어간다고 가정하지 않았다. 1024×768의 PNG는 keep 여백을 제외한 16:9 render 영역이다.

프로젝트의 기준 1920×1080, 초기 창 1280×720, `canvas_items`와 기존 keep/resizable 기본값, GL Compatibility 설정은 그대로다. F5 키를 에디터에서 수동으로 누르지는 않았고, 같은 `application/run/main_scene`의 CLI headless/native 실행으로 확인했다.

자료는 `.godot/verification/step42/`의 `validation-results.json`, `basic-results.json`, `responses_*.json`, `context_edge_*.log`, `scope-results.json`, PNG에 있다. 기존 회귀 결과는 `legacy40/validation-results.json`과 `legacy40/legacy39/validation-results.json`에 있다. git ignore된 로컬 자료이며 runtime product에 연결하지 않았다.

## 발견 문제와 제한

- Step41의 Archive 평가에서 놓친 Incident Research의 실패 Room 누설을 발견해 이번 authored 문구와 함께 제거했다.
- 최초 회귀 실패는 새 hidden Label 추가 후 과거 Scene child-count 기대값이 5였기 때문이다. 검사 사본만 6/hidden으로 갱신했다.
- 새 조건 관찰 검사의 최초 실패는 긴 Label 전체가 ScrollContainer 안에 포함되어야 한다는 잘못된 검사 조건이었다. 스크롤 상·하단의 실제 표시를 검사하도록 수정했다.
- 최초 invalid draft fixture는 새 Archive가 layout되기 전에 버튼 좌표를 클릭했다. frame/layout 대기 후 실제 Back을 클릭하도록 검사만 수정했다.
- F01의 Major threshold 1 고정 리듬과 F07의 작은 pool/Case02 끝 이후 continuation은 미해결이다. Case02 Outcome/Case03/장기 콘텐츠를 추가하지 않았다.
- Broadcast draft 선택은 보존하지만 스크롤 위치는 기존 정책대로 초기화된다. 현재 단계의 요청 범위는 미확정 Option 보존이다.
- UI 텍스트가 길어진 만큼 Option/Archive/Condition은 스크롤한다. 최종 typography/디자인/접근성 튜닝과 사람 플레이테스트는 후속 과제다.

## 요청한 105개 종료 항목

| 번호 | 항목 | 결과 |
|---|---|---|
| 1 | 작업 전 Git | README 수정 + 기존 Step41 보고서 untracked; staged 없음. |
| 2 | HEAD | ac1605935a2bab92cb1c43b2709cdde0f5f36c81 유지. |
| 3 | Step41 재확인 | F02~F06 실제 코드/콘텐츠 재현; Archive Incident Research도 Room leak 확인. |
| 4 | 실제 범위 | product 7파일 + README 수정, Step42 보고서 생성; 검사 자료는 ignored. |
| 5 | Incident01 이전 leak | TEST_ROOM_01/Room01 실패가 사건 설명·Research에 노출됨. |
| 6 | Incident03 이전 leak | TEST_ROOM_03/Room03 실패가 사건 설명·Research에 노출됨. |
| 7 | leak 제거 | 사건/response Research를 시설 관찰과 조치/결과로 교체; ID/평가 leak 검사 통과. |
| 8 | correct Room | 자동 노출·정답 안내 없음; Archive의 기존 제출 Room 사실은 유지. |
| 9 | Incident01 설명 | pump-start service-panel 타격/구조 진동/조명 끊김/지속 tracing. |
| 10 | Incident03 설명 | vent pulses/outlet turn-back/불안정 airflow/tracing 중단. |
| 11 | source 표시 | 정상 세 화면의 SOURCE CASE + Case01 이름/ID. |
| 12 | current 표시 | CURRENT WORK INTERRUPTED + Case02 이름/ID. |
| 13 | Stage 표시 | 기존 interrupt return_stage를 검증해서 문자열 표시. |
| 14 | Result resume | RESUME WORK + 실제 Case02/Stage와 Resume 버튼. |
| 15 | Context 구조 | 5개 string snapshot, Result 표시 bool; FlowView setter. |
| 16 | gameplay State 아님 | 판정/후보/Response schema 추가 없음; 표시만 담당. |
| 17 | debug Context | hidden, 기존 IncidentResult → RESULT; 정상 cross-Case 정보 없음. |
| 18 | 기존 읽기 문제 | EXP result draw 전 same callback에서 Major View 교체. |
| 19 | 새 정책 | EXP는 기록/ready만; 다음 기존 normal CCTV/Containment entry에서 presentation. |
| 20 | same callback | EXP 결과 View 동일/Stage EXP/triggered=false 유지. |
| 21 | Base draw | native frame 증가 + actual result Label/PNG 확인. |
| 22 | Condition draw | 실제 관찰 ID/Label, scroll 상단·끝 native draw 확인. |
| 23 | idle | 30 process frame + render 대기에도 동일 화면/후보; 자동 trigger 없음. |
| 24 | next safe boundary | 현재 흐름의 Next: CONTAINMENT 진입; Log/idle/Dismiss는 제외. |
| 25 | readiness | 기존 FailureEventCandidateState count/threshold 포화 유지; 새 flag/schema 없음. |
| 26 | threshold | Disturbance 2~4, Major 1 그대로; 추가 opportunity 없음. |
| 27 | Deferred | 후속 정상 기회 없는 late Candidate 유지; 자동 완료/강제 발생 없음. |
| 28 | prompt01 | pump-start 타격 vs sound-only, airflow turn-back 단서와 temporary 목적. |
| 29 | 01A 의도 | 구조 충격 전달 분리 + steady airflow. |
| 30 | 01B 의도 | airborne noise 감소, 구조 연결 유지. |
| 31 | 01C 의도 | vent cycling으로 이동 유도, 새로운 outlet cue 위험. |
| 32 | 01A 결과 | 타격 감소, seam 접근/tracing 남음. |
| 33 | 01B 결과 | speaker 주시 감소, pump-start 타격/구조 전달 미해결. |
| 34 | 01C 결과 | 첫 이동 뒤 turn-back 반복, 타격 지속. |
| 35 | prompt03 | airflow 전환/tracing 중단, lamp 이동과 구조 충격 비교 단서. |
| 36 | 03A 의도 | 연속 저풍량으로 반복 transition 제거. |
| 37 | 03B 의도 | task light 감소로 crossing 제한; vent cycling 유지. |
| 38 | 03C 의도 | support damping 우선; airflow cue 유지. |
| 39 | 03A 결과 | turn-back 감소/tracing 지속 길어짐, panel 접근/미검증 구조 남음. |
| 40 | 03B 결과 | crossing 감소/pause 증가, restart turn-back 지속. |
| 41 | 03C 결과 | panel 진동 감소, vent turn-back/tracing 중단 지속. |
| 42 | Option 차별성 | 6개 unique 텍스트/기존 result link, 구조·소리·공기·조명 조치 구분. |
| 43 | Research 근거 | 기존 Profile/CCTV/EXP01·02·03 비교에 연결; 발견한 상세 기록만 Archive. |
| 44 | Archive optional | Archive 없이 6대응 완료; 버튼/Confirm에 Archive prerequisite 없음. |
| 45 | 기억력 위험 | prompt가 필요한 현상·비교 cue를 요약; 사람 플레이테스트는 후속 필요. |
| 46 | consequence | 서로 다른 authored 결과 텍스트만; current gameplay facts 무변경. |
| 47 | score schema | score/correct/optimal/consequence 필드나 계산 없음; Data schema 원본 hash 동일. |
| 48 | Incident Research | 두 사건 title/body를 새 관찰에 동기화, 실패 Room 문구 제거. |
| 49 | Broadcast Research | 두 prompt의 임시 목적·관찰 근거를 기록. |
| 50 | Option Research | 여섯 확정 조치의 의도/trade-off 기록; 선택만으로 발견하지 않음. |
| 51 | Result Research | 여섯 관찰 변화·잔여 문제 기록; 표시 뒤 발견. |
| 52 | incremental merge | 기존 발견 뒤 Incident → Broadcast → Confirm Option → displayed Result 순서. |
| 53 | dedup | 반복 Archive/Confirm/Resume 뒤 ID 배열 중복 없음. |
| 54 | 이전 draft | View 교체로 미확정 local selection 유실. |
| 55 | 새 draft | 정상 Broadcast 직접 Source Archive 왕복 선택 ID 보존. |
| 56 | 위치 | 기존 Main _interrupt_context.broadcast_draft, 네 ID string만. |
| 57 | confirmation 아님 | confirmed_option_id/Research 무변경, Next 잠금; Confirm만 승인 기록. |
| 58 | 수명 | Archive 동안 저장, Back 때 consume; 다른 Stage/종료/foreign/confirmed 폐기. |
| 59 | confirmed 복원 | 기존 authoritative snapshot으로 선택/잠금 유지; draft로 변경 불가. |
| 60 | stale draft | source/Incident/Broadcast/Option/Stage/old View/다른 response 검증 및 폐기. |
| 61 | normal Journey | 두 실패 source의 교란 → ready EXP 읽기 → CONT Major → response → CONT Resume. |
| 62 | no Archive | 두 사건×ABC를 실제 Confirm/Next로 완료. |
| 63 | with Archive | 두 사건×ABC, draft/confirmed/Result 단계 direct Source Archive/Back 확인. |
| 64 | 01A | Archive 유무×3해상도×2모드 통과. |
| 65 | 01B | 같은 조합 통과; draft/Result 화면 캡처. |
| 66 | 01C | 같은 조합 통과; scroll로 Option C 선택 가능. |
| 67 | 03A | 같은 조합 통과. |
| 68 | 03B | 같은 조합 통과. |
| 69 | 03C | 같은 조합 통과; 실제 result ID 연결. |
| 70 | Runtime identity | 중단 전/후 같은 current Runtime instance; old source WeakRef 해제. |
| 71 | current facts | Case/실험 이력·사용 수·조건 IDs·Research·Room 확정 보존 비교. |
| 72 | 환경 | applied environment 그대로; response 텍스트가 current 상태를 바꾸지 않음. |
| 73 | 가설 | current/source Hypothesis 두 배열 내용·ID 보존. |
| 74 | 분리 | Source Archive는 Case01 메모, current Log는 Case02 메모; 섞이지 않음. |
| 75 | Resume | 표시 Stage와 실제 CONT 일치; 기존 CCTV/EXP compatibility/confirmed CONT 별도 회귀. |
| 76 | 완료 | IncidentResponse completed + active 해제, 해당 Candidate 제거. |
| 77 | 재발 없음 | 완료 후 동일 entry 재요청 시 새 response 생성 없음. |
| 78 | late Deferred | threshold4 후속 Major 기회 없는 두 실패 경로 유지. |
| 79 | stale EXP | 제거된 EXP execute/advance/Log 신호가 대응/Runtime에 영향 없음; compatibility fixture 포함. |
| 80 | stale Incident | 제거된 Incident Next/Archive 신호 차단; 기존 normal 회귀. |
| 81 | stale Broadcast | Archive 후 old Confirm/Advance/Research 및 draft getter/restore 차단. |
| 82 | stale Result | 완료/다른 Stage old Advance/Archive 차단, duplicate completion 없음. |
| 83 | invalid context | missing/foreign case/instance/Stage/source에서는 row 숨김·진행 차단·현재 이름 fallback 없음. |
| 84 | Resource 불변 | 실행 전/후 두 instantiated Case 구조/내용 비교; 디스크 resource hash도 동일. |
| 85 | 경로 분리 | normal ResponseState와 debug Runtime confirmation/Monitoring 분리 유지. |
| 86 | debug SUCCESS | current authored Case01 Room02 → RESULT, Major context/Response 없음. |
| 87 | debug FAILURE | current authored 두 Incident×ABC → IncidentResult → RESULT, cross-Case Resume 없음. |
| 88 | F02 | RESOLVED: 새 결과가 실제 draw된 뒤 다음 player boundary에서 Major. |
| 89 | F03 | CONTENT RESOLVED: 6전략·근거·잔여 문제 작성; gameplay consequence/밸런스는 의도적으로 미구현. |
| 90 | F04 | RESOLVED: source/current/Stage/실제 resume 목적지 명시. |
| 91 | F05 | RESOLVED: 화면과 response Research의 실패 Room/정오 leak 제거. |
| 92 | F06 | 선택 draft RESOLVED: Archive 왕복 보존; Scroll 위치 복원은 미구현. |
| 93 | F01 | 미해결 유지: Major threshold1 고정 pacing; 변경/재밸런스 없음. |
| 94 | F07 | 미해결 유지: Case02 뒤 continuation/pool 부족; 새 Case/Outcome 없음. |
| 95 | 해상도 | 1920×1080, 1280×720, 1024×768 headless/native; 기존 keep/scale 유지. |
| 96 | Wrap/Scroll | 긴 prompt/result/context 범위, Option C 접근, Archive/Condition 상단·끝 확인. |
| 97 | 전체 회귀 | 기존 215 + 신규20 =235 suite, headless136/native99; fixture 조정 명시. |
| 98 | parsing/run | product39 Script parse, 3개 별도 import/Main 실행 통과; 오류 없음. |
| 99 | 발견 문제 | 기존 Research leak 수정; node count/scroll 포함/layout 대기는 검사 사본 수정. |
| 100 | 변경 파일 | 위 파일 표의 8수정/1생성; git diff/허용 field/hash 검사. |
| 101 | 기존 변경 | Step41 보고서 hash 그대로; README 기존 전체 내용 그대로 + Step42 삽입. |
| 102 | Main 크기 | 1497→1542줄, 81→83함수; 기존 Main 전면 재작성 없음. |
| 103 | 미구현 | score/정답/consequence/새 State/Case03/Timer/강제확인/최종 UI·Audio·Animation·Shader 없음. |
| 104 | 우선순위 | 실제 플레이어의 읽기·근거 이해·선택 판단을 다시 감사하고 긴 Option 가독성 확인. |
| 105 | 다음 Step | Step43 Response Comprehension / Read Boundary UX 재감사 추천; pacing/pool은 별도 승인 범위에서 검토. |

최종 scope 검사는 시작 파일 hash, 기존 검증 원본 hash, README의 Step42 블록 제거 후 원본 전체 비교, Case01의 허용된 58개 text field 외 동일 비교, `git diff --check`, staged 없음/HEAD 유지/삭제 없음으로 확인한다. 이 보고서와 README 외의 의도하지 않은 파일 수정은 없다.
