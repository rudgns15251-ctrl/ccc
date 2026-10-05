# Step41 — Major Incident Pacing / Response UX Audit

작업일: 2026-10-05. 기존 Step40 제품을 조사하고 정상 플레이·기존 debug 경로를 다시 실행한 감사다. 게임 규칙, threshold, Scene, Script, Resource, 프로젝트 설정을 변경하지 않았다. 커밋·push하지 않았다.

## 결론

**지연 사건 → 대응 → 현재 업무 복귀의 기술적 기반은 작동한다. 그러나 ‘예측하기 어려운 점진적 사고에 의미 있게 대응한다’는 경험은 아직 성립했다고 판단할 수 없다.**

1. 교란 이후 Major 임계값은 실제로 **1**이다. 다음 유효 행동에서 바로 사건이 시작되므로 반복하면 시점을 학습하기 쉽다.
2. Major가 EXPERIMENT 실행에서 시작되면 방금 결과를 넣은 View가 **같은 입력 처리 안에서 제거된다**. GPU에서도 결과를 읽을 첫 렌더 프레임이 없었다. 복귀하면 결과·조건 관찰·실행 이력은 복원되므로 데이터 손실은 아니다.
3. Broadcast A/B/C는 서로 다른 ID와 결과 문구를 기록하지만 대응 전략, 필요한 증거, trade-off가 없는 임시 문구다. 현재 업무에 시스템적인 차이도 없다.
4. Source Case와 현재 업무의 관계는 Incident 화면에서 명시되지 않는다. 반면 기존 Incident 설명의 `TEST_ROOM_01 failure` / `TEST_ROOM_03 failure`는 실패한 Room을 직접 드러낸다. **숨겨진 State가 비공개인 것과 표시 콘텐츠가 판단 결과를 누설하지 않는 것은 별개**다.
5. 후속 기회가 없는 경로에서 Candidate는 정상 보존된다. 이것은 현 두 Case의 콘텐츠 종료에 따른 **DEFERRED**이며, trigger 고장으로 분류하지 않았다.

P0/P1 코드 결함은 재현되지 않았다. 아래 문제는 P2 UX/GAME DESIGN/CONTENT 또는 P3 TECH DEBT로 분류한다. 이번 단계는 Audit이므로 사건 규칙·선택 결과·작성 콘텐츠를 임의로 변경하지 않았다.

## 조사 기준과 범위

작업 전 `git status --short --branch`는 `## master...origin/main`만 표시했다. staged/unstaged/untracked 변경은 없었다. HEAD는 `ac1605935a2bab92cb1c43b2709cdde0f5f36c81`, 제목은 `Refine case evidence and add delayed major incident responses`다. remote는 `https://github.com/rudgns15251-ctrl/ccc.git`, 로컬 master가 origin/main을 추적한다. Step41에서 Git 이력과 remote를 변경하지 않았다.

실제 추적 파일 **104개**, 기존 검증 소스 **2,869개**의 SHA-256 기준선을 새 `.godot/verification/step41/`에 저장했다. 저장소·상위 경로에서 적용할 AGENTS.md는 발견하지 않았다. 다음을 실제 파일로 조사했다.

| 영역 | 실제 상태 / 조사 대상 |
| --- | --- |
| 루트 | project.godot, README.md, .gitignore, .gitattributes; assets/.gitkeep |
| docs | Step38 core loop audit, Step39 evidence map, Step40 Major interrupt 보고서 |
| scenes | Main 1 + 주요 View 12 + 보조 UI 2 = 15 TSCN |
| scripts | Main 1 + runtime State 7 + data Resource 16 + View/공통 15 = 39 GDScript |
| resources/cases | test_case_01.tres, test_case_02.tres만 존재; Case03 없음 |
| Main 설정 | 실제 Case sequence는 Case01 → Case02; 각 View Scene을 상위 Main이 관리 |
| Case01 | Room01/03 FAILURE, Room02 SUCCESS authored Outcome; 두 Incident/Broadcast, Option·Result 각 6개 |
| Case02 | 실험 2개/limit 2, Room 2개, containment_outcomes 없음; 제출 후 Pending |
| State | CaseRuntime, PendingContainment, ContainmentResolution, FailureEventCandidate, IncidentResponse, ResearchArchive, WorkingHypothesis |
| UI | Incident/Broadcast/IncidentResult, Source Archive Detail, 조건 패널/Notice, EXP 결과·복원, CCTV 재확인, Containment 잠금 |
| 기존 테스트 | Step40 검증 소스와 legacy39의 normal/debug 전체 검사; 기존 파일을 수정하지 않고 새 위치에 복사하여 실행 |

`.godot/verification/step41`은 기존 `.gitignore`의 cache 제외 정책을 따르는 **개발자 검증 자료**다. 테스트에서 사용하는 Case 복사본·State-only 미래 ID·pre-existing disturbance fixture를 제품 콘텐츠나 정상 도달 경로로 세지 않았다.

감사 방법은 코드/문구/콘텐츠 연결 조사, seed 고정 실제 버튼 입력, 상태 전후 비교, native GPU 화면 검사다. `_click()`은 버튼 위치에 마우스 이동·press/release를 전달한다. 새 정상 Journey에서 Stage 강제 전환, threshold 교체, Case 추가를 사용하지 않았다. 조사자는 작성 의도를 알고 있으며 **새 플레이어의 첫 플레이 실험은 아니다**. 공포감·짜증·기억 부담·실제 읽기 시간에 대한 결론은 콘텐츠/행동 구조에서 도출한 위험 평가이며 사용자 연구 결과로 주장하지 않는다.

## 실제 trigger와 행동 수

Main의 `PROTOTYPE_DISTURBANCE_THRESHOLD = Vector2i(2,4)`, `PROTOTYPE_MAJOR_THRESHOLD = 1`을 확인했다. FailureEventCandidateState의 인자 기본값 `major_trigger_threshold = 3`은 기존 호출 호환용이며 **정상 Main은 1을 명시적으로 전달한다**.

유효 기회는 현재 Case당 `cctv:entry`, 승인된 서로 다른 `experiment:<ID>`, `containment:entry`다. 표시·재방문·선택·Confirm·Dismiss·Log/Archive/Back·Hypothesis 편집·idle 시간은 별도 기회가 아니다. 정전 후 Recheck CCTV는 연구를 읽을 수 있으나 새 entry 기회를 소비하지 않는다. Case02의 최대 pool은 **CCTV 1 + 실험 2 + Containment 1 = 4**다.

처리 순서는 이전 교란의 Major count 증가 → 이번 교란 적용 검사 → 교란 적용 시 즉시 return → 이미 준비된 Major 검사다. 따라서 **교란을 일으킨 같은 행동이 자신의 Major count를 늘리지 않는다**. 활성 Notice/Response 동안 gameplay 기회와 중첩 사건을 차단한다. Resume은 discovery/opportunity를 재소비하지 않는 표시 경로다.

seed 0..255의 첫 `randi_range(2,4)` 결과를 실제 Godot RNG로 기록했다. 대표 seed는 threshold2=1, threshold3=2, threshold4=0이고, 표본 횟수는 각각 86/90/80이다. 전체 허용 값 2/3/4를 모두 버튼 경로로 검증했다. 이는 **개발자 재현용 seed 표본이며 플레이어 사건 확률이나 체감 통계가 아니다**.

### 정상 Trigger Matrix

EXP1/EXP2는 해당 Journey의 실행 순번이다. Case02의 authored EXP01/EXP02와 구분한다. `[0]`, `[1]`, `[0,1]`, `[1,0]` 양쪽 ID/순서를 각각 실제 실행했다. source Room01/03은 동일한 count 규칙을 쓰되 서로 다른 교란/사건 콘텐츠를 표시한다.

| 실행 실험 수 | 교란 threshold | Disturbance trigger point | Remaining opportunities | 실제 Major threshold | Major reachable? / 발생점 | Deferred? | Reason |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 0 | 2 | Containment 진입 | 0 | 1 | No | Yes, 교란 후 | 마지막 유효 기회에서 교란; 제출/Confirm은 기회 아님 |
| 0 | 3 | 발생하지 않음 | 해당 없음 | 1 | No | Yes, 교란 전 | 전체 2기회로 교란 threshold 미달 |
| 0 | 4 | 발생하지 않음 | 해당 없음 | 1 | No | Yes, 교란 전 | 전체 2기회로 교란 threshold 미달 |
| 1 | 2 | EXP1 완료 | 1: Containment | 1 | Yes, Containment | No | 교란 이후 별개의 유효 진입 1개 |
| 1 | 3 | Containment 진입 | 0 | 1 | No | Yes, 교란 후 | 후속 기회 없음 |
| 1 | 4 | 발생하지 않음 | 해당 없음 | 1 | No | Yes, 교란 전 | 전체 3기회로 교란 threshold 미달 |
| 2 | 2 | EXP1 완료 | 2: EXP2, Containment | 1 | Yes, EXP2 완료 | No | 다음 실제 실험 실행에서 Major |
| 2 | 3 | EXP2 완료 | 1: Containment | 1 | Yes, Containment | No | 실험 완료 후 별개 진입에서 Major |
| 2 | 4 | Containment 진입 | 0 | 1 | No | Yes, 교란 후 | 현재 콘텐츠 종료 |
| SUCCESS | 해당 없음 | 없음 | pool은 동일 | 해당 없음 | No | Candidate 자체 없음 | 실패가 없으므로 사건을 생성하지 않음 |

**CCTV 첫 진입에서 교란 또는 Major가 발생하는 경로는 현재 두 Case의 무주입 정상 흐름에는 없다.** 교란 최소값은 2이고 첫 CCTV는 첫 기회다. 기존 CCTV Major 진입/복귀 검사는 이미 교란이 존재하는 명시적 fixture이며 정상 콘텐츠 도달률에 포함하지 않는다.

### Opportunity Reachability — threshold 1/2/3 비교

1만 실제 Main의 값이다. 2/3은 독립 FailureEventCandidateState에 명시적으로 입력한 **개발자 가설**로 비교했으며 제품 상수/밸런스는 그대로다. 실험 수 0/1/2 × 교란 threshold 2/3/4 × Major 1/2/3의 27조합을 검사했다.

| Disturbance 위치 / 실제 조건 | Remaining Opportunities | Major threshold 1 (현재) | Major threshold 2 (가설) | Major threshold 3 (가설) | Reachability / 보류 |
| --- | --- | --- | --- | --- | --- |
| CCTV, pre-existing fixture만 | 최대 3 | EXP1 | EXP2 | Containment | 현 정상 sequence에서는 이 교란 시점에 도달 못 함 |
| EXP1, 실험 2회·교란2 | 2 | EXP2 | Containment | Deferred | 1/2만 현 pool 안에서 도달 |
| EXP1, 실험 1회·교란2 | 1 | Containment | Deferred | Deferred | 1만 도달 |
| EXP2, 실험 2회·교란3 | 1 | Containment | Deferred | Deferred | 1만 도달 |
| Containment, 교란 threshold까지 실행 | 0 | Deferred | Deferred | Deferred | 어떤 양의 threshold도 소비할 후속 기회 없음 |
| 교란 자체가 아직 없음 | 해당 없음 | 교란 전 Deferred | 교란 전 Deferred | 교란 전 Deferred | 먼저 부족한 교란 count를 채워야 함 |

기회를 줄인 경로에서 Major를 강제 생성하거나 마지막 Room Confirm을 새 기회로 만들지 않았다. 30개 서로 다른 실패 정상 Journey 중 12경로에서 Major, 18경로에서 보류였다. 선택한 테스트 조합의 집계일 뿐 확률 추정이 아니다.

### Deferred 보존 / 미래 Case

보류 경로에서 source_case_id, incident_id, disturbance threshold/count/flag, major threshold/count/flag가 Candidate에 남았다. 잘못된 authored mapping에서 ready Candidate를 잃거나 다른 사건으로 대체하는 동작도 없었다. 둘은 구분해야 한다.

| 구분 | 상태 / 원인 | 판단 |
| --- | --- | --- |
| CONTENT-END DEFERRED | 유효 authored chain; 남은 기회 0 또는 교란 이전 pool 소진 | 현 콘텐츠 길이의 제한; trigger 실패 아님 |
| INVALID-CONTENT DEFERRED | source/Incident/Broadcast/Result 유일 매핑 또는 내용이 부적합 | validation이 시작을 거부하고 Candidate 보존; 경고로 개발자 수정 필요 |
| 실제 trigger CODE failure | 유효 데이터와 충분한 별개 기회인데 시작/복귀가 깨짐 | 이번 감사에서 재현 없음 |

Candidate State는 current_case_id가 source와 다른 새 ID의 기회를 받으면 보류 count부터 이어간다. 27개 State-only 가설에서 미래 ID의 추가 기회로 진행 가능함을 확인했다. **Case03를 실행한 검사가 아니다.** Main의 handoff는 Candidate/Resolution/Archive/Hypothesis를 reset하지 않고 새 current Runtime과 기회 key만 마련한다.

다만 지금은 Case03가 없고 **Case02 Outcome도 없다**. Case03 Resource를 배열에 붙이기만 하면 Case02의 hidden resolution validation에서 막힌다. 실제 장기 continuation을 검증하려면 별도 단계에서 Case02 Outcome의 의미와 다음 업무 콘텐츠를 함께 확정해야 한다. 이번에 정답·Outcome·Case03를 만들지 않았다.

## 실제 Player Journey

대표 정상 경로: Case01 ROOM01 → Case02, 교란 threshold2(seed1), Case02 EXP02 → 정전 Notice → EXP01 → Major → A 확인 → Resume EXPERIMENT. ROOM03 경로의 환기 사건과 Containment 중단도 별도로 실행했다.

| 단계 | Player Action | Information | State Change | Optional? | Potential Friction |
| --- | --- | --- | --- | --- | --- |
| Case01 정보 수집 | Profile/CCTV 읽기, 실험 선택·실행 | 지지 구조·환기 자극 비교 | 실제 실행/discovery ID만 current Runtime에 기록 | 실험 선택/수는 Optional | 기억할 두 비교 축; Archive로 나중에 다시 읽기 가능 |
| Case01 제출 | ROOM01 선택 → Confirm → Next CASE | Room 설비와 제출 잠금; 판정 비공개 | Pending 승인 → hidden FAILURE → Candidate → Archive merge → 새 Case02 Runtime | Room 제출 Required | 즉시 정오 feedback 없음은 현재 의도 |
| Case02 시작 | Profile → CCTV → Experiment | 새 업무 기본 관찰 | 새 Case discovery; CCTV entry 1회 | 정상 진행 Required | 이전 실패와 새 Case 환경 영향의 관계는 아직 비공개 |
| 첫 실험 | EXP02 선택 → Run | 표면 비교 결과 | EXP02 실행/연구 기록, 기회2에서 정전 적용 | 실험 Optional | 결과 위에 Notice가 겹치지만 Dismiss 후 같은 View |
| Disturbance | Notice 읽기 → Dismiss | 조명 변화 + Case02 즉시 관찰; source 정오 비공개 | 현재 Runtime 조건/reaction 발견; Dismiss는 기회 없음 | 발생한 Notice 닫기는 Required | 전조를 읽을 시간은 자율; Stage당 조건 요약 유지 |
| 추가 연구 | Recheck CCTV / Log / 메모 | 정전 후 조건 관찰·개인 가설 | 실제 CCTV 노출 시만 추가 discovery; 메모는 별 State | Optional | 기회를 늘리지 않으므로 읽기가 사건을 당기지는 않음 |
| 두 번째 실험 | EXP01 선택 → Run | 새 base/조건 결과가 기록됨 | 실행 승인 후 다음 기회에서 Major, interrupt context 저장 | 실험 Optional | 새 결과 View가 draw 전에 제거됨; 읽기는 Resume 뒤로 밀림 |
| Major / Incident | 사건 설명 읽기 → Next Broadcast | Major 제목, incident ID/name/임시 설명 | source Response ACTIVE, source Incident Research merge | 발생한 대응 Required | source/current Case 관계 부족; 실패 Room 문구 노출 |
| Source Archive | Open Source Archive → 읽기 → Back | Case01의 기존 연구·가설·공개된 사건 연구 | **읽기는 무변경**; 동일 Response 화면 복귀 | Optional, gate 없음 | 왕복 2클릭 + 읽기/스크롤; pre-confirm 임시 선택 초기화 |
| Broadcast | A/B/C 중 하나 → Confirm → Next | 임시 prompt/Option, 확정 잠금 | source Response Option/Result ID 확정; Option Research merge | 하나 확정 Required | 합리적 전략을 구분할 콘텐츠 없음 |
| Incident Result | 결과 읽기 → Resume EXPERIMENT | 선택된 임시 결과와 복귀 Stage | Result Research merge; Resume 시 Response COMPLETED/Candidate 제거 | Resume Required | 결과의 시설/업무 영향 없음; current Case 이름 없음 |
| 업무 복귀 | 결과/조건 관찰 읽기 → Containment | 방금 EXP01 결과·이력·활성 조건 복원 | 동일 Case02 Resource/Runtime; Resume 자체는 새 기회 없음 | 계속 진행 Required | 실험 화면으로 돌아와야 새 결과를 처음 읽음 |
| Case02 제출/끝 | Room 선택 → Confirm | 확정 Room; No next test case configured | Case02 Pending 유지; Next disabled | 제출 가능, 종료 콘텐츠는 없음 | 결과/Case03가 없어서 사건의 장기 영향은 평가 불가 |

Incident 도착 후 Archive를 열지 않는 최소 대응은 **5클릭**: Next Broadcast → Option 선택 → Confirm → Next Incident Result → Resume. Archive 1회 왕복은 **2클릭 추가**, 중간 목록 선택 없이 바로 source Detail이다. 세 단계에서 매번 1회 열면 +6클릭으로 총11클릭이다. 스크롤과 읽기는 별도다. 강화 검증에서는 Incident 2회/Broadcast 전후 각1회/Result 1회 총5왕복을 수행하지만 이를 필수 플레이 부담으로 계산하지 않았다.

Broadcast에서 미확정 B를 고른 뒤 Archive 왕복하면 선택은 초기화되어 재선택 1클릭이 필요했다. 이것은 기존 View 재생성/local selection 정책이며 승인 상태 손상이 아니다. Confirm 이후 왕복은 확정 ID·체크 표시·잠금을 정확히 복원했다. Archive 스크롤도 View 재생성에 따라 초기화된다.

## Broadcast Decision

두 사건의 각 Option을 실제 Resource에서 조사했다. 각각 result_id는 다르지만 전략·사전 지식·대가·성공 조건은 없다. 일반 게임에서 ‘똑같은 선택’이라고 단정하는 대신 **현재 임시 콘텐츠의 의미 차이가 아직 작성되지 않았다**고 분류한다.

| Option | Apparent intent | Required knowledge | Distinct from others? | Result meaning | Current gameplay consequence | Problem |
| --- | --- | --- | --- | --- | --- | --- |
| TEST_OPTION_01_A | Temporary response 01-A; 전략 미정 | 없음 | ID/A 문구만 다름 | Temporary incident result for option 01-A | Response IDs + source Archive의 A/ResultA 연구; current 업무 상태 동일 | 연구로 선택 이유를 뒷받침할 수 없음 |
| TEST_OPTION_01_B | Temporary response 01-B; 전략 미정 | 없음 | ID/B 문구만 다름 | option 01-B 임시 결과 | B/ResultB 기록; 동일한 Case02 복귀 | A와 비교할 trade-off 없음 |
| TEST_OPTION_01_C | Temporary response 01-C; 전략 미정 | 없음 | ID/C 문구만 다름 | option 01-C 임시 결과 | C/ResultC 기록; 동일한 Case02 복귀 | 오답/대안의 근거조차 아직 없음 |
| TEST_OPTION_03_A | Temporary response 03-A; 전략 미정 | 없음 | ID/A 문구만 다름 | option 03-A 임시 결과 | A/ResultA 기록; 동일한 Case02 복귀 | 환기 사건에 대한 대응 의미 미정 |
| TEST_OPTION_03_B | Temporary response 03-B; 전략 미정 | 없음 | ID/B 문구만 다름 | option 03-B 임시 결과 | B/ResultB 기록; 동일한 Case02 복귀 | 다른 대응 전략이 표현되지 않음 |
| TEST_OPTION_03_C | Temporary response 03-C; 전략 미정 | 없음 | ID/C 문구만 다름 | option 03-C 임시 결과 | C/ResultC 기록; 동일한 Case02 복귀 | 결과 정보가 선택 번호 재진술에 그침 |

현재 명백한 정답1/오답2 구조, Archive를 꼭 읽어야 하는 강제 gate, 기억을 못 하면 실패하는 퀴즈는 없다. 그 이유는 선택의 의미 자체가 미정이기 때문이다. Source Hypothesis는 과거 추론을 재구성할 가치가 있으나 현재 Broadcast는 이를 적용할 질문을 제공하지 않는다. 향후 대응을 작성할 때 목적과 불확실성, 근거를 화면에서 이해시키고 Archive는 보조 확인으로 유지하는 것이 좋다.

게임플레이 consequence 시스템이 당장 필요하다고 결론짓지 않는다. 먼저 다른 대응 의도와 관찰 가능한 결과 문구를 검증하고, 그것만으로 선택이 약한 경우 별도 기획 범위에서 최소 영향 하나를 검토한다. 이번에는 피해/점수/경제/Success-Failure/조건 변경을 추가하지 않았다.

## Pacing / 정보 / Resume 평가

교란은 시점만 2–4로 달라지고 이후 Major는 다음 유효 행동으로 고정된다. 현재 짧은 Case에서는 두 중단이 최대4기회 사이에 밀집하거나, 실험을 건너뛰고 late threshold를 만나 사건 자체를 못 보는 양극단이 있다. **가시적 교란 threshold 범위는 짧은 pool에 비해 늦은 값이 존재하고, 후속 Major 간격은 다양성이 없는 좁은 범위**다. threshold를 넓히는 것만으로 해결하면 deferred만 늘어날 수 있다. 임의 재밸런싱하지 않았다.

CCTV는 다른 Case에서 이미 조건이 생긴 상황의 의미 있는 업무 중단 지점일 수 있다. 하지만 현재는 텍스트 CCTV이므로 영상 관찰 중단의 긴장감을 증명하지 못했고 정상 두 Case에서는 해당 Major 지점에 도달하지 않는다. Containment 진입은 새 Room 선택 전이므로 선택 손실은 없지만, 판단 직전 과거 업무 대응을 요구해 기억 부담을 높일 위험이 있다. 확인된 Containment 상태의 복구는 별도 fixture에서 잠금/Room/Pending 유지로 검증했다.

교란→Major는 count상 확실하게 연결된다. 반면 플레이어가 보는 교란은 조명/환기 시설 변화이고 Major 설명은 ‘ROOM failure’ 임시 문구여서 **문장 수준의 단계적 악화 연결은 약하다**. 타이밍 패턴은 너무 분명하고 서사적 인과는 너무 빈약할 수 있다. 더 늦은 사건의 맥락 재안내도 필요하지만 이번에는 새 규칙/시간/음향을 만들지 않았다.

교란은 전조 외에도 Case02의 독립 연구 가치가 있다. 정전 즉시 반응은 일시적 이동 정지와 지속 접촉을 구분하고, 후속 CCTV는 어둠에서도 접촉/환기 반응이 유지됨을 보여준다. 정전 중 EXP01은 시작 지연을 보조 비교하되 공기/벽의 기본 근거를 대체하지 않는다. 환기 사건은 즉시 관찰이 보장 채널이며 **CCTV/EXP condition mapping은 없다**. 메모는 자동 생성·채점되지 않는다. Major 대응도 이 연구를 지우지 않는다. 다만 빠른 interrupt와 의미 없는 Broadcast가 플레이어의 주의를 연구에서 빼앗을 위험은 남는다.

SUCCESS는 Candidate/교란/사건이 없어 정상 업무만 이어진다. Case01 성공과 Case02 Pending을 검사했으며, Outcome이 없는 Case02까지 ‘모든 Case 성공’을 실행했다고 보고하지 않는다. 모든 격리를 성공해도 Broadcast를 반드시 경험해야 한다는 제품 목표가 유지된다면 향후 실패 사건과 별개의 시설/스토리 사건을 검토할 근거는 있다. 성공을 실패처럼 취급하거나 hidden 정오를 직접 알리는 방식은 피해야 한다. Forced/Scripted 사건과 failure 사건의 원인·공개 정보·빈도는 별도 설계가 필요하며 이번에 구현하지 않았다.

action-based 기회는 사용자가 읽는 동안 사건을 발생시키지 않아 현재 정적 UI에 적합하다. 실시간 Timer 재도입을 지지할 증거는 없다. 긴 Case에서 지금 세 종류의 기회가 충분할지는 authored 행동 수와 실제 읽기 세션으로 먼저 확인해야 한다. 종류를 늘리기 전에 긴 업무 구간/남은 pool을 확보하는 편이 검증 가치가 있다. 사건 다양성도 먼저 disturbance-only/delayed/story 각각의 목적을 정해야 하며, Severity enum이 그 자체로 Pacing 문제를 해결하지 않는다.

### Hidden Resolution과 공개 범위

교란 이전 정상 Case01 판정, Candidate의 숫자/flag, SUCCESS/FAILURE enum, 내부 RNG를 UI/Log로 전송하지 않았다. 교란 Notice도 source Case/Room 정오를 표시하지 않는다. Current Log는 Case02 정보만 읽고 source 대응 연구는 Case01 Archive에만 합쳐진다.

**Major 이후에는 제한이 완전히 지켜지지 않는다.** IncidentData.description의 기존 `Temporary incident data for TEST_ROOM_01 failure.` 및 ROOM03 문구가 그대로 보인다. 정답 Room02를 찾아 표시하는 API는 없고 State의 resolution을 자동 설명하는 formatter도 없지만, 현재 작성 문자열은 선택한 실패 Room을 명시한다. Archive의 사건 연구 문구는 사건을 관찰했다고 요약하며 원 화면의 Room failure 문구를 반복하지 않는다. 원 Scene/Resource를 보호하는 Audit 범위에서 이 CONTENT 문제를 보고하고 수정은 제안만 했다.

IncidentResult는 ID/name/임시 설명과 Resume Stage를 제공한다. 어떤 대응을 했고 시설에 무엇이 일어났는지 정보가 부족하지만 correct Room을 추가로 공개하지는 않는다. 출발·복귀 Case와 현재 업무가 보존된다는 표시를 더 명확히 하는 제안은 P2 UX다.

## 발견 사항 및 Incident UX 요약

P0=진행 불가/데이터 손상/크래시, P1=핵심 Incident/Resume 손상, P2=Pacing/선택 의미/Navigation, P3=polish 기준을 적용했다. 미래 콘텐츠 부족을 정상 흐름의 CODE P0/P1과 혼동하지 않는다.

| ID | 분류 | 우선순위 | 확인된 사실 / 경험상의 위험 | 처리 |
| --- | --- | --- | --- | --- |
| F01 | GAME DESIGN | P2 | 교란 뒤 Major가 1기회 고정; 반복 예측 가능 | 현재 값 유지; 충분한 pool의 리듬 비교 추천 |
| F02 | UX | P2 | EXP 새 결과를 draw하기 전에 Major로 전환; Resume에 데이터 있음 | 승인/기록과 읽기 기회 분리 정책을 다음 단계에서 결정 |
| F03 | CONTENT / GAME DESIGN | P2 | Broadcast 6개 전략·근거·trade-off 부재; current consequence 없음 | 대응 의도와 결과 콘텐츠를 먼저 구체화 |
| F04 | UX | P2 | Incident/Broadcast에 source/current Case 관계 명시 부족, Resume에 Stage만 있음 | 정오 비공개를 유지하는 출처·업무 맥락 안내 추천 |
| F05 | CONTENT | P2 | Incident의 기존 실패 Room 문구가 판단 결과를 직접 드러냄 | debug 임시 문자열과 player-facing 사실 설명 분리 추천 |
| F06 | UX | P2 | Source Archive 왕복 후 미확정 Option/스크롤 초기화; 재선택 비용 | local temporary draft 보존 여부를 별도 결정; 확정은 유지 |
| F07 | CONTENT / GAME DESIGN | P2 | Case02 종료와 Outcome 부재로 late Major/장기 continuation 실제 검증 불가 | 다음 Case는 장기 리듬 검증용으로만 승인된 범위에서 작성 |
| F08 | CONTENT | P2 | 조명/환기 교란에서 generic Room failure로 넘어가 악화의 관찰 연결 부족 | 공통 시설 원인과 새 관찰의 연결을 문구로 먼저 검증 |
| F09 | GAME DESIGN | P2 | 성공 플레이어는 실패 기반 대응 콘텐츠를 보지 못함 | Broadcast 경험 보장 목표 확인 후 별도 스토리/시설 사건 검토 |
| F10 | TECH DEBT | P3 | Main 1,497줄/81함수; normal/debug 조회·표시 승인 책임 공존 | 콘텐츠/UX 검증 이후 읽기 전용 조립/조회 경계부터 점진 검토 |
| F11 | UX / CONTENT | P3 | 개발용 ID·임시 이름·기준 해상도 헤더가 업무 화면 정보보다 큼 | 최종 UI 범위에서만 정리; 현재 개발 표시 유지 |

CODE 분류의 실제 결함은 재현되지 않았다. F02의 같은-callback 교체는 실제 동작이나, 현재 즉시 결과와 안전 interrupt 정책의 충돌이므로 P2 UX로 분류했다. 기능이나 밸런스 결정을 대신해 Timer/새 acknowledgment/새 opportunity를 넣지 않았다. F06도 기존 미확정 draft 정책을 데이터 손상이라고 하지 않았다.

| 대상 | Purpose | Observed friction | Severity | Recommendation | Implemented now? |
| --- | --- | --- | --- | --- | --- |
| Disturbance | 시설 변화/현재 관찰/전조 | 후속 Major가 빠르지만 자체 연구 가치는 남음; 한 번 Notice 닫기 필요 | P2 | 독립 증거의 읽기 가치와 악화 연결을 같이 검증 | No |
| Major Trigger | 과거 실패의 늦은 업무 중단 | 1기회 고정, EXP 결과 draw 전 전환, late pool 부족 | P2 | Case 길이·읽기 경계부터 비교; threshold 임의 수정 금지 | No |
| Incident | 발생 사건과 긴급 대응 소개 | source/current Case 모호; 실패 Room 문구 노출 | P2 | 출처·중단 업무 안내, 판단 정오 대신 관찰 사실 작성 | No |
| Source Archive | 과거 연구·가설 보조 확인 | direct 왕복2클릭은 적절; 미확정 draft와 스크롤 초기화 | P2 | optional 유지, draft 보존 정책 결정 | No |
| Broadcast | 대응 선택·Confirm | 전략/근거/대가 없이 임시 A/B/C | P2 | 한 사건의 구별되는 대응 의도를 먼저 작성 | No |
| Incident Result | 선택 결과와 복귀 연결 | 선택 ID 재진술 수준; 시스템 영향/업무 맥락 없음 | P2 | 무엇이 관찰되었는지와 복귀 업무를 설명 | No |
| Resume | 중단한 현재 업무 계속 | 상태/잠금 정상; EXP는 이제 새 결과를 처음 읽음 | P2 | 최신 결과와 이어갈 업무의 주의 흐름 검증 | No |

## 상태 경계와 Main 구조

| 주체 | 책임 / 승인 경계 | 감사 결과 |
| --- | --- | --- |
| CaseRuntimeState | current Case의 실행/history/조건 snapshot IDs, Room 확정, discovery/환경; debug Monitoring/Broadcast 사실 | 정상 대응 중 동일 객체·사실 유지; source 사건을 넣지 않음 |
| PendingContainmentState | 제출한 Case/Room ID, resolution 성공 후 제거 | Case01 handoff에서 제거; 마지막 Case02 보존 |
| ContainmentResolutionState | hidden Case/Room/Result/Incident ID 사실 | 정상 Major 이전 판정 비공개; Response 진행이 재판정하지 않음 |
| FailureEventCandidateState | source/Incident ID, 별도 교란/Major threshold/count/flag, FIFO 후보 | 기회당 count, 교란 자체는 Major count0; Deferred 유지; 완료한 정확한 후보만 제거 |
| IncidentResponseState | source+Incident 복합 ID, Broadcast/Option/Result ID, ACTIVE/COMPLETED | 한 active, 한 Confirm, completed 중복 방지, deepcopy; Resource/current Runtime 소유 안 함 |
| Interrupt Context | interrupted_case_id, return_stage, runtime_instance_id, case_instance_id | navigation context만 유지; 동일 인스턴스 확인 후 복귀, gameplay Snapshot/Framework 아님 |
| ResearchArchiveState | Case별 authored entry ID 순서/dedup incremental merge | 기존 연구 → Incident → Broadcast → Option Confirm → IncidentResult; Back/reopen 중복 없음 |
| WorkingHypothesisState | case별 사용자가 적은 세션 메모, current Log CRUD 승인 | source Detail 읽기 전용; response 동안 편집/자동 판정 없음 |
| View | Resource/Snapshot 표시, 임시 선택/스크롤, 요청 signal | Main 승인 상태를 직접 변경하지 않음; old View signal 거부 |
| Main | Stage/Case orchestration, ID 유일 조회/validation, 공개 Snapshot, hidden resolution, 기회/연구 순서, interrupt/resume 승인 | normal/debug route 분리 유지; 승인과 read-only 조립이 함께 커지는 부채 있음 |

Main은 Step38 **1,244줄/66함수**에서 현재 **1,497줄/81함수**로 +253줄(20.3%)/+15함수(22.7%)다. 공백/주석 포함 물리적 줄수와 `^func ` 기준이다. State는 6→7, 제품 GD는 38→39다. 이번 Audit 전후 수치는 동일하다.

이 숫자만으로 지금 대규모 분리가 필요하다고 결론짓지 않는다. 문제 경계는 source ID 조회/표시 조립과 gameplay 승인 책임의 동거, normal은 유일 매핑 검증이고 legacy debug는 일부 first-match lookup인 차이다. authored 데이터가 늘고 두 경로의 정책이 어긋나기 시작하면 **읽기 전용 lookup/snapshot 조립부터** 검토하는 것이 자연스럽다. State 소유권, 실행 승인, 기회 순서, 실제 discovery는 Main에 남긴 채 회귀 보호가 필요하다. 새로운 Manager/Singleton/BaseClass/EventBus/전역 상태를 만들지 않았다.

invalid source Case/Incident/Broadcast/Option/Result, duplicate/blank mapping은 시작 전에는 Candidate를 보존하고 거부한다. Response 도중 forged IDs, 잘못된 Result link와 중복 Option은 Confirm/진행을 승인하지 않는다. fixture에서 데이터/identity를 복구하면 정상 진행했다. 정상 immutable authored data 중에 일어나는 crash로 재현되지 않았다. **의도적으로 진행 중 데이터를 제거한 경우 자동 취소/대체/복구 UI가 구현되어 있다는 의미는 아니다.** 임의 Resource 재작성에 대한 완전한 게임 복구 기능은 주장하지 않는다.

## 실행 검증과 증거

실제 엔진은 `4.7.1.stable.official.a13da4feb`, Windows Compatibility OpenGL/RX6800이다. 절대 엔진 경로는 `C:\Users\newsj\Downloads\Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64_console.exe`다. 새 폴더에 복사한 runner는 원 검증 소스/기대 warning 수를 유지하며 출력 경로만 Step41 아래로 변경했다. 기존 normal/debug fixture의 용도도 그대로 유지했다.

| 검사 묶음 | 최종 실행 수 | 검증 내용 |
| --- | --- | --- |
| legacy39 전체 | 199 | 39 product GD check-only +160 normal/debug/state/edge/discovery/Archive/Hypothesis/condition regression |
| Step40 전체 | 16 | A/B/C normal/CCTV fixture, stale/navigation, invalid/repair/FIFO/nested, 조건 결과/Containment 잠금 복원 |
| Step41 새 Audit | 18 | 3해상도 ×2..4 교란값 ×headless/native; 각10 실패Journey+1SUCCESS, threshold2에서 임시 선택 Archive 왕복 추가 |
| 위 suite 합계 | **233** | headless135/native98; 동일 Case/Runtime, 반복 merge/dedup, Deferred 및 실제 동작 검사 |
| 별도 project entry | 3 | headless editor import/parse, configured Main headless 실행, configured Main native 실행 |

Step41 정상 시나리오는 30 실패경로 +3 SUCCESS 경로를 여섯 모드/해상도 조합에서 반복한 **198 Journey**이고, 미확정 Option Archive 왕복 **6 Scenario**가 추가된다. 여기서 30은 두 source 실패 Room ×3교란값 ×다섯 실험 순서다. 27 threshold 가설과 미래 ID-only 연속 검사는 별도 State test이며 정상 콘텐츠 Journey에 포함하지 않는다. 이런 내부 assertion/반복 경로 수를 233 실행 수와 합쳐 검사 수를 부풀리지 않았다.

새 검사는 메모리에 실제 사용된 두 Case Resource의 필드도 시작/끝 비교한다. 디스크 전체 hash 비교와 원 preload Resource 검사에 더해, 중첩 Resource/배열의 Runtime 플레이 중 변경도 검사했다.

| Native Window | 논리 UI / viewport capture | 정상 Major 전체 대응 | 복귀/추가 경계 |
| --- | --- | --- | --- |
| 1920×1080 | 1920×1080 /1920×1080 | 두 source, EXP/Containment → Incident → Broadcast → Archive → Result → Resume | Runtime/Resource identity, 조건 결과, 잠금, late Deferred 통과 |
| 1280×720 | 1920×1080 /1280×720 | 같은 전체 경로, source 연구/가설 확인 | 단일 주요 View, 버튼 경계/자동 줄바꿈/스크롤 통과 |
| 1024×768 | 1920×1080 /1024×576 | 같은 전체 경로; 16:9 keep 비율 여백 | 작은 창에서도 UI 겹침/버튼 잘림 없음; 결과/Archive는 스크롤 |

1920/1280/1024 PNG를 실제 열어 Incident, Broadcast, Archive, Result, Resume의 제목·버튼·source ID·문구·조건과 스크롤을 확인했다. root viewport PNG는 keep의 여백을 제외한 렌더 영역이므로 1024×768 창의 캡처가 1024×576이다. 설정을 바꿔 해상도를 맞춘 것이 아니다. 별도 restore 회귀는 스크롤 아래 실제 condition 결과 Label까지 검사한다.

EXP→Major native 입력에서 `Engine.get_frames_drawn()`의 before/after 값이 동일하고 이전 View는 이미 SceneTree에서 제거되어 있었다. 대표 1920 경로는 332→332였다. 결과 Label은 대입되었고 Resume 후 표시가 복원된다. frame 수는 실행마다 달라질 수 있으며 동일 입력 callback 내 draw 부재를 비교하는 증거다. headless draw0만으로 시각적 결론을 낸 것이 아니다.

source Case01 Runtime은 handoff 이전 WeakRef/instance ID를 기록하고 이후 실제 해제됨을 확인했다. 대응 전/후 Case02 instance ID가 동일했고 Case01 Runtime은 다시 소유/생성하지 않았다. Main 코드는 source CaseData와 ID 기반 Archive/Resolution/Response만 참조한다. 보존 비교는 Case Resource, experiment history/condition IDs, discovered/observed Research, applied environment, current/source hypotheses, Room 확정, processed opportunities를 포함한다.

기존 debug SUCCESS→RESULT, FAILURE→INCIDENT→BROADCAST→INCIDENT_RESULT→RESULT와 restart, 정상 Case handoff, stale old View 요청, Source Archive Back, 미확정/확정 잠금, duplicated composite IDs, invalid authored mapping, reset/deepcopy 경계를 모두 다시 실행했다. 기본 Main은 project.godot 지정 경로로 실제 실행했다. **F5 키를 Godot 에디터에서 수동으로 누른 검사는 아니며**, 동일 configured Main의 CLI 실행과 실제 native 버튼 시나리오로 검증했다.

최종 suite 기대 경고는 invalid/debug fixture의 **1,226개**이며 각각 runner의 exact expected warning count와 일치한다. 정상 새 Audit와 project entry는 warning0, 파싱/GDScript/runtime ERROR0, exit0이다. 기대 경고를 정상 게임의 경고 또는 무시한 오류로 계산하지 않았다.

개발자 로컬 재현 명령(PowerShell, 프로젝트 루트):

```powershell
& .godot/verification/step41/legacy40/run_validation.ps1
& .godot/verification/step41/run_audit.ps1
```

자료: `source-before.json`, `tests-before.json`, `legacy40/validation-results.json`, `legacy40/legacy39/validation-results.json`, `audit-results.json`, `entry-results.json`, `audit_<width>_<threshold>_<display>.json`, PNG, 로그, 최종 `final_integrity.json`. 이 자료는 `.godot` 아래 ignored이므로 clean clone에 자동 포함되지 않는다. 제품 빌드/에셋/일반 테스트 시스템을 새로 추가한 것은 아니다.

검증 개발 중 한 차례 ‘실험1회에서 Major 없음’이라는 테스트 예상이 실제 Containment Major와 달라 실패했다. 기회 총수를 CCTV+실험+Containment로 고쳐 예상표를 수정했고 제품 코드는 바꾸지 않았다. 메모리 Resource hash/필드 비교도 보강해 최종 suite를 재실행했다. 최종 통과 결과와 초기 검증 스크립트의 예상 오류를 구분한다.

## 변경 범위와 미구현

제품 변경은 없다. 추가한 추적 대상 문서는 `docs/step41_major_incident_pacing_audit.md`, 수정 문서는 README.md의 Step41 안내 블록뿐이다. 삭제 파일 없다. `project.godot`, 모든 기존 Scene/GDScript/Resource/UID/기존 docs/Git 설정 파일은 작업 전 SHA-256과 동일하다. README는 안내 추가만으로 변경했다. 원 검증 소스 2,869개도 동일하다. 작업 전 미커밋 변경이 없었으므로 별도로 복원하거나 섞어 넣은 이전 변경은 없다.

`git status`, `git diff --stat`, `git diff`, 새 보고서 `git diff --no-index`, `git diff --check`, 새 문서 whitespace 검사를 수행했다. Git staged 변경, HEAD 변경, 의도하지 않은 제품 파일 변경은 없다. 모든 새 실행 자료는 기존 `.godot` ignore 범위다.

Case03, Case02 Outcome/정답, Severity/MINOR/MODERATE, Forced/Scripted Incident, Broadcast gameplay consequence, Economy, Save/Load, Campaign, 새 opportunity, threshold rebalance, final UI/font/assets, Audio/Animation/Shader, 새 Timer, Manager/Singleton/EventBus/Framework를 구현하지 않았다. 기존 debug Monitoring Timer는 유지했고 정상 사건 timing에 연결하지 않았다.

## 다음 우선순위와 권장 Step42

1. **대응의 의미와 공개 정보**: 한 기존 사건의 prompt/A/B/C/결과를 연구에 연결되는 서로 다른 의도로 설계하고, 실패 Room 직접 문구를 관찰 사실로 바꾸는 콘텐츠 범위를 먼저 확정한다. consequence 시스템보다 먼저 비교할 수 있다.
2. **읽기와 복귀의 맥락**: source Case/현재 업무/Resume 목적지를 명료하게 안내하고, EXP 결과를 읽을 기회를 확보하는 정책을 결정한다. 지금의 같은-callback 교체를 고치기 위해 Timer나 기회를 임의 추가하지 않는다. Archive 미확정 draft 보존 정책도 함께 검토한다.
3. **장기 pacing의 검증 공간**: Case02 Outcome 및 이후 Case의 목적을 승인된 범위에서 먼저 정의하고, 늦은 Candidate continuation/성공 경험/여러 실패의 빈도를 검증한다. Case03는 단순히 사건을 강제로 띄우는 fixture가 아니라 ‘이전 판단 영향 아래 독립 업무를 이어가기’의 검증 콘텐츠여야 한다.

Step42는 **기존 Major Incident의 authored response/content와 source·resume 안내 개선**을 좁은 범위로 진행하는 것이 적합하다. threshold/새 사건 규칙/Severity/대규모 Main 분리를 함께 묶지 말고, 필요한 데이터 공개 원칙과 EXP 읽기 정책을 먼저 정한다. 긴 sequence 확장은 그 이후 별도 단계가 적합하다.

## 요청한 107개 항목 대응

| 번호 | 항목 | 결과 |
| --- | --- | --- |
| 1 | 작업 전 Git 상태 | ac16059, master→origin/main, clean; baseline104개. |
| 2 | Audit 방법 | 코드/작성 문구 조사, actual mouse input, seed/State 비교, GPU PNG; 첫 사용자 연구는 아님. |
| 3 | 정상 Major Journey | Case01 실패 handoff→Case02 교란→후속 기회→source 대응→동일 current Case Resume. |
| 4 | 교란 가능 위치 | EXP1/EXP2/Containment; 첫 CCTV는 현 정상 sequence에서 불가. |
| 5 | 남은 Opportunity | 실험2회 EXP1 후2, 실험1회 EXP1/실험2회 EXP2 후1, Containment 후0. |
| 6 | Major threshold 도달 | 현재1; 가설2/3은 Reachability 표/27 State 모델에 별도 명시. |
| 7 | Deferred 조건 | 교란 이전 count 미달 또는 교란 이후 후속 기회 부족; invalid chain 거부 별도. |
| 8 | Candidate 유지 | 보류경로 source/Incident/threshold/count/flag 보존. |
| 9 | 콘텐츠 종료 보류 | 현 최대4기회와 Case02 끝; 정상 데이터에서 CONTENT-END DEFERRED. |
| 10 | 코드 버그 보류 | 유효 chain/충분한 기회의 trigger failure 재현 없음. |
| 11 | 미래 Case 지속 | Candidate State ID-only 기회에서 연속; 실제 future Case 미구현, Case02 Outcome 필요. |
| 12 | 예측 가능성 | 교란 후 다음 eligible1회로 고정, 반복 학습 가능. |
| 13 | threshold 체감 | Major 간격 좁음; 교란 late값은 짧은 pool 대비 보류 위험, 현재값 유지. |
| 14 | CCTV trigger | pre-existing fixture 정상 복귀; current slice 정상 도달 없고 영상 긴장감 미검증. |
| 15 | EXP trigger | 새 결과 draw 전 교체; Resume 복구, P2 읽기 중단. |
| 16 | Containment trigger | 새 선택 전 중단, 손실 없지만 판단 직전 기억 부담. |
| 17 | 교란→Major 연결 | State/count 연결 확실; player-facing 악화 설명 부족. |
| 18 | 너무 강한 연결 | 한 행동 뒤 Major라는 타이밍 규칙은 학습하기 쉬움. |
| 19 | 너무 약한 연결 | 시설 관찰→generic Room failure 서사 연결 약함; 더 늦은 사건은 맥락 재안내 필요. |
| 20 | 전조 역할 | 기술적으로 선행하지만 반복 예고 공식이 될 위험. |
| 21 | 독립 연구 가치 | Case02 즉시/정전 CCTV/optional EXP 근거와 메모, 기본 추리 대체 안 함. |
| 22 | 연구 무의미화 | 상태/근거는 유지; 빠른 대응과 낮은 선택 의미로 주의 가치 약화 위험. |
| 23 | 시작 가독성 | Major 제목 명확, 현재 업무가 보존된 긴급 source 사건이라는 설명은 부족. |
| 24 | source 식별 | Incident ID만으로 과거 Case를 알아야 함; Archive에는 Case name/ID 명시. |
| 25 | Source Archive 효용 | 과거 연구/메모 재열람 유용; 현 Broadcast 전략 연결 없음. |
| 26 | Archive 강제성 | gate 없음, 읽지 않고도 5클릭 대응 가능. |
| 27 | navigation cost | direct Detail 왕복2클릭+읽기/스크롤; 미확정 선택이면 재선택1추가. |
| 28 | Option A | 01-A/03-A 모두 임시 문구, 전략/근거 미정. |
| 29 | Option B | 서로 다른 ID/결과 기록, 다른 의도 없음. |
| 30 | Option C | 동일 구조, 대안 의미/대가 미정. |
| 31 | 차별성 | 문구/ID 차이만 현재 확인; gameplay 전략 차이 없음. |
| 32 | Research 연결 | 대응 질문/선택 근거가 아직 없어서 참고 지식이 선택을 바꾸지 못함. |
| 33 | 기억력 테스트 | 현재 정답/지식 요구 없음; source 맥락 부족은 향후 기억 부담 위험. |
| 34 | 명백한 정답 | 정답1/오답2 체계 없음; 모든 Option chain 유효. |
| 35 | Result 차별성 | option 번호별 임시 설명, 의미 있는 관찰 결과 미작성. |
| 36 | current consequence | Response/Archive 기록 차이뿐, Case02 gameplay facts 동일. |
| 37 | consequence 필요성 | content 의미 먼저 검증 후 별도 최소 영향 검토; 시스템 당장 추가하지 않음. |
| 38 | Result 정보량 | ID/name/임시 설명/Resume Stage; 대응 의도·관찰 변화·업무 맥락 부족. |
| 39 | 정답 과도 노출 | correct Room 자동 표시 없음; Incident authored description이 실패 Room 직접 노출(F05). |
| 40 | Resume UX | 같은 Stage/current Runtime으로 복귀, 목적지 Case 안내는 부족. |
| 41 | EXP Resume | 마지막 실행 결과/조건 관찰/이력/사용 count 복구, 실행 잠금 유지. |
| 42 | CCTV Resume | boundary fixture에서 조건/관찰 discovery 유지, same current Runtime. |
| 43 | Containment Resume | 정상 entry와 confirmed boundary fixture의 Room/Pending/확정 잠금 보존. |
| 44 | 즉시 중복 Event | Resume/Back/replayed entry에서 재발 없음; 다른 준비 후보는 다음 별개 기회. |
| 45 | Current Runtime | identity 및 모든 비교 facts 유지; Response Current Monitoring/Broadcast에 안 씀. |
| 46 | source Runtime 미생성 | old WeakRef handoff 후 해제, Main은 source Data/IDs만 조회; 다시 소유하지 않음. |
| 47 | merge 순서 | 기존 source 연구→Incident 표시→Broadcast 표시→Option Confirm→Result 표시. |
| 48 | Archive 중복 | repeated Open/Back/Confirm/completion에서 ID 중복 없음; 임시 내용은 의미상 반복 경향. |
| 49 | source Hypothesis | 과거 추론 복기 가능, readonly/current과 분리; 현 대응 활용 질문 미정. |
| 50 | Hidden Resolution | 내부 State/enum/threshold 비공개 유지; authored 실패 Room 문구의 별도 누설 발견. |
| 51 | Major 이전 비노출 | 정상 UI/Log/Notice에 hidden Result/source Room 정오/threshold 없음. |
| 52 | Major 이후 범위 | 사건 콘텐츠/Archive/선택/결과 공개; 자동 correct Room 없음, authored wrong Room leak 있음. |
| 53 | SUCCESS 체감 | Case01 성공은 조용한 업무 지속; 완료 feedback/사건정보량 적음. |
| 54 | 성공 콘텐츠 손실 | 실패 기반 모델만으로는 successful player가 대응을 거의 못 볼 수 있음. |
| 55 | Forced Incident | Broadcast 경험 보장 목표가 유지되면 별도 scripted시설 사건 검토; 이번 미구현. |
| 56 | Failure/Scripted 분리 | 원인/공개 정보/빈도를 분리해야 성공을 실패로 오해시키지 않음. |
| 57 | Horror pacing | 업무→교란→업무→사건→복귀 골격 가능; 예측성/짧음/placeholder로 공포 경험 입증 못 함. |
| 58 | 빈도 과다 | 최대4기회 사이 두 blocking event, EXP 새 정보 읽기 중단 위험. |
| 59 | 희소성 | 실험 skip/late threshold 시 교란 또는 Major 못 봄, Candidate 보존. |
| 60 | Timer | 정적 UI의 자율 읽기에 action-based 적합, 실시간 Timer 필요 증거 없음. |
| 61 | pool 충분성 | 현재2~4기회는 긴 pacing 평가에 부족; 새 종류보다 충분한 업무 콘텐츠 먼저. |
| 62 | 반복 패턴 | 교란+1eligible 공식 학습 위험; 현재 재밸런싱 안 함. |
| 63 | 다양성 | disturbance-only/delayed/story의 목적별 검토 유용; 규칙 추가는 후속 기획. |
| 64 | Severity | enum 자체로 선택/리듬 해결 못 함; 필요성 입증 전 추가 불필요. |
| 65 | Case03 | 장기 continuation 검증에는 추가 업무가 필요; 이번 없음. |
| 66 | Case03 목적 | 사건 강제 fixture가 아닌 이전 영향 아래 독립 업무·성공/실패 긴 리듬 비교. |
| 67 | Case02 Outcome 부재 | 현 마지막 Pending 정상; next Case만 붙여도 hidden resolve에서 차단됨. |
| 68 | Main line count | 1,497; Step38 1,244 대비 +253(20.3%), 이번 변화0. |
| 69 | Main function count | 81; Step38 66 대비 +15(22.7%), 이번 변화0. |
| 70 | Main 책임 | Stage/Case/승인/유일 조회/표시Snapshot/hidden판정/opportunity/discovery/interrupt. |
| 71 | 분리 필요성 | 지금 대규모 분리 없음; 확장 시 readonly lookup/snapshot 경계부터 검토. |
| 72 | ResponseState | source 사건별 IDs/ACTIVE/COMPLETED, once confirm/completion/dedup/deepcopy. |
| 73 | CandidateState | source IDs/threshold/count/flag/FIFO, Deferred 지속/완료후 정확 제거. |
| 74 | Interrupt Context | 복귀 Case/Stage/instance IDs 4필드만, gameplay State/Framework 아님. |
| 75 | normal/debug 안전성 | NORMAL_INTERRUPT/DEBUG_RUNTIME 분기; normal Case02 facts와 debug 후속 사실 분리. |
| 76 | stale signal | removed view/Archive Back/late Confirm/old Advance 무변경; active identity gate 통과. |
| 77 | invalid source | missing/duplicate source lookup 거부, Candidate 유지; controlled fixture. |
| 78 | invalid Incident | missing/duplicate/empty content 시작 거부, 다른 사건 substitute 안 함. |
| 79 | invalid Broadcast | missing/duplicate/prompt 누락 chain 거부, Candidate 유지. |
| 80 | invalid Option | forged/duplicate/invalid Result Confirm 거부, 최초 승인만 잠금. |
| 81 | invalid Result | start/confirm/advance link validation, repair fixture 정상 복구; 자동 recovery UI는 없음. |
| 82 | Resource 불변성 | 파일 hash, preload 및 실제 instantiated nested Resource 비교 통과. |
| 83 | mutation boundary | Main 승인→해당 State 쓰기; 표시/Archive읽기/Resume는 gameplay mutation 없음. |
| 84 | P0 | 유효 정상 콘텐츠의 crash/손상/진행 실패 재현 없음; 마지막 Case end 의도적 차단. |
| 85 | P1 | 핵심 Incident/Resume 손상 재현 없음. |
| 86 | P2 | F01~F09: pacing/읽기/대응 의미/source맥락/Room누설/draft/콘텐츠길이/연결/성공경험. |
| 87 | P3 | F10 구조 부채, F11 개발 표시 polish. |
| 88 | CODE | 최소 수정할 명백한 결함 재현 없음; 잘못된 새 테스트 예상만 교정. |
| 89 | UX | F02/F04/F06: draw 전 interrupt, source/resume 맥락, draft navigation. |
| 90 | GAME DESIGN | F01/F03/F07/F09: 고정 간격·선택 의미·pool·성공 콘텐츠 위험. |
| 91 | CONTENT | F03/F05/F07/F08: 임시 대응/Room 누설/Case02 end/악화 연결 미작성. |
| 92 | TECH DEBT | F10 Main 공존 책임, normal/debug 조회 정책 차이; 즉시 framework 도입 불필요. |
| 93 | 이번 수정 | 제품 수정 없음; 감사 문서/README 추가와 ignored 검증 도구만. |
| 94 | 미구현 추천 | 콘텐츠·안내·읽기 정책·draft·장기 pool·story 사건 제안은 구현하지 않음. |
| 95 | Journey 표 | ‘실제 Player Journey’의 행동/정보/State/optional/friction 표. |
| 96 | Reachability 표 | 실제 Trigger Matrix 및 actual1/hypothetical2/3 기회 표. |
| 97 | Decision 표 | 여섯 Option의 intent/knowledge/차별성/결과/consequence/problem. |
| 98 | UX 표 | Disturbance/Trigger/Incident/Archive/Broadcast/Result/Resume 목적·문제·priority·제안·미구현. |
| 99 | 전체 회귀 | 기존215 + 새18 =233 실행; 별도 import/default entry3, 기대 warning 일치. |
| 100 | 3해상도 | 1920×1080,1280×720,1024×768 native 전체 대응/Archive/복귀; logical1920×1080. |
| 101 | Runtime identity | 동일 current Instance/facts, old source WeakRef 해제; JSON증거. |
| 102 | debug downstream | SUCCESS/FAILURE/Incident/Broadcast/Result/Restart 원래 검증 전체 통과. |
| 103 | 파싱/실행 | Godot4.7.1 모든39 GD check-only, editor import, configured Main headless/native exit0. |
| 104 | 실제 변경 파일 | README.md 수정, 이 보고서 신규; 제품/기존검증 변경·삭제 없음. |
| 105 | 미커밋 보존 | 시작 clean; 원104파일/2,869검증 해시 대조, README의 이번 안내만 변경. |
| 106 | 우선순위3 | 대응 콘텐츠/공개정보 → 읽기·source/Resume 맥락 → 장기 pacing 검증 공간. |
| 107 | 다음 Step | Step42 기존 response 콘텐츠와 source/resume 안내 개선을 좁게; 기획 승인 후 읽기 정책, 새 시스템은 별도. |
