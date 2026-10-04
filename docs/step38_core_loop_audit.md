# Step38 — Core Loop UX / 구조 감사

감사일: 2026-10-04. **기존 프로젝트 감사와 잘못된 안내 문구 수정만 수행했다.**
새 Gameplay 기능, 콘텐츠, 시스템, 밸런스, 화면 배치 변경은 없다. 커밋·push하지 않았다.

현재 Core Loop는 기술적으로 연결되어 있으나, **관찰을 근거로 Room을 선택하는 추리 경험은 아직 검증되지 않았다.**
Case01의 설명은 모두 임시 문구이고, Case02의 환경 관찰도 Room의 차이와 연결되지 않는다.
특히 기존 authored 실험 조건 관찰은 실험 순서와 사건 발생 시점에 따라 접근할 수 없다.
이 두 문제를 다음 작업의 우선순위로 권장한다. 아래 권장안은 확정 사양이 아니다.

## 조사 범위와 방법

작업 전 HEAD: `a1dfe02f5cf4c393fa1c831692d1b5e1d1db73cb` (`Add read-only research archive browsing`).
`master`가 `origin/main`을 추적하고 working tree는 깨끗했다. 기존 미커밋 변경은 없었다.
실제 tracked 파일 99개와 이전 검증 `.gd`/`.ps1`/`.tscn` 2,152개에 SHA-256 기준선을 남겼다.
저장소 및 상위 경로에 적용할 AGENTS.md는 발견하지 않았다.

| 실제 폴더 | 조사한 내용 |
|---|---|
| 루트 | project.godot, README Step23~37 포함 기존 이력, Git 상태·HEAD·ignore·attributes |
| assets | `.gitkeep`만 있으며 실제 게임 에셋 없음 |
| resources/cases | 실제 Case01/02 `.tres` 두 개; Profile/CCTV/실험/Room/Outcome/환경/Research ID와 문구 |
| scripts/data | authored Resource 형식 16개 |
| scripts/runtime | Main 소유 RefCounted State 6개, 변경·조회·reset 경계 |
| scripts/main | Stage, normal/debug 분기, handoff, hidden resolution, opportunity, discovery, Snapshot, 모든 요청 승인 |
| scripts/views, scenes/views | 주요 화면 12개, Overlay와 환경 표시 보조 Scene 2개, 공통 FlowView Script |
| scenes/main | Main Scene의 실제 노드, ViewHost, 헤더, 해상도 기준 표시 |
| .godot/verification | 기존 상태/보안/경계/긴 콘텐츠/화면/독립 downstream 검사와 이전 자료 |

검증은 Godot 4.7.1 `a13da4feb`의 headless와 Windows GPU(OpenGL Compatibility)에서 수행했다.
새 Journey 검사는 Main Scene을 그대로 생성하고 **버튼 위치에 마우스 이동·눌림·해제를 전달**했다.
A/B/C의 진행에 `_show_view` 호출, 임의 State 주입, debug Main을 사용하지 않았다.
사건을 재현하기 위해 Main의 RNG seed만 고정했다. 임계값·콘텐츠·판정 규칙은 그대로다.
Hypothesis 텍스트는 TextEdit에 대입하고 `text_changed`를 발생시켰으며 입력란 포커스와 저장/편집/삭제는 마우스로 확인했다.
키를 한 글자씩 입력하는 사람의 속도, 첫 플레이어의 이해도, 실제 소요 시간은 측정하지 않았다.
따라서 아래 UX 평가는 실행·코드·문구에 근거한 감사자의 판단이며 플레이어 사용성 실험 결과는 아니다.

## 클릭 측정과 실제 Journey

단위는 좌클릭 한 번이다. 텍스트 입력은 별도 행동이며 문자 수를 클릭 수에 더하지 않는다.
읽기·생각하기·스크롤은 클릭 수와 별도다. 모든 선택적 기능을 사용한 수치를 필수 수치로 해석하면 안 된다.

| 경로 | 측정 결과 | 조건 |
|---|---:|---|
| Case 시작 → 격리 확정 | 최소 5클릭 | Profile Next, CCTV Next, Experiment Next, Room 선택, Confirm; 실험/Log 없음 |
| Case01 시작 → Case02 Profile | 최소 6클릭 | 위 5개 + Next Case |
| Case01 → Case02 둘 다 격리 확정 | 11클릭 | Room02의 무사건 경로; 마지막 Case는 인계 불가 |
| 실험 한 개 선택·실행 | +2클릭 | 선택 1 + Run 1, 읽기 별도 |
| Log 읽고 원래 화면 복귀 | 2클릭 | Open + Back |
| 환경 변화 → CCTV 추가 관찰 → 원래 화면 | 3클릭 | Dismiss + Recheck + Back; 읽기 별도 |
| Gameplay → Log → Archive → 과거 Detail → Gameplay | 6클릭 | Open Log, Archive, Case Open, Back 3회 |
| Containment → Recheck CCTV → Log → Archive Detail → Containment | 8클릭 | 추가 Recheck 진입/복귀 포함, Back 4회 |
| B: Case02 Profile → 조건 관찰·가설 생성/편집 → 격리 확정 | 19클릭 | EXP02→EXP01, threshold=2, 입력란 포커스 2클릭 포함; 57자+87자 입력 별도 |
| B의 사전 조건 Case01 → Case02 | 6클릭 | Room01 확정·handoff. B 19클릭에 포함하지 않음 |

8클릭 경로는 실제 확인했다. 일반 6클릭 Archive 왕복은 그 중 Recheck 진입/복귀를 제외한 경로이며 기존 Archive 회귀에서도 확인했다.
B에서 가설 생성을 위한 Log 열기는 1회, A에서는 0회였다. C의 Archive 조회와 별도 CRUD 회귀를 사용 빈도에 섞지 않았다.
모든 단계마다 Log를 열 필요는 없다. 네 주요 화면마다 한 번씩 열면 단순 읽기 왕복만 8클릭이 추가된다.

### Player Journey A — No-Disturbance Case

| Screen/Action | Why player does it | Information gained | Optional? | Potential friction |
|---|---|---|---|---|
| Profile 읽기, Next | 대상 식별 후 진행 | subject/classification/임시 설명 | 이동 REQUIRED, 자세한 읽기는 강제하지 않음 | 현재 설명은 판단 근거가 아님 |
| CCTV 읽기, Next | 기본 관찰 확인 | 임시 기본 관찰 | 이동 REQUIRED | 실제 패턴 정보가 없음 |
| Experiment Next | 판단 준비 또는 진행 | 실험 후보·남은 횟수 | 이동 REQUIRED, 실행 OPTIONAL | 실행하지 않아도 진행되므로 실제 가치 검증 불가 |
| Room02 선택 | 격리 후보 선택 | 후보 이름·임시 설명 | REQUIRED | Room 간 추론 가능한 차이 부족 |
| Confirm | 결정 제출 | [Confirmed], 변경 잠금 | REQUIRED | 별도 클릭은 실수 방지에 기여하지만 내용 판단은 불가능 |
| Next Case | 다음 업무로 인계 | 새 Case Profile | CONTEXTUAL / 인계에는 REQUIRED | 결과가 숨겨져 성공/단순 인계 구별 불가 |
| Case02 같은 순서, Room 선택·확정 | 두 번째 Case 처리 | 새 Case의 자료·Pending | REQUIRED | 마지막은 No next test case configured; 완료 경험은 없음 |

### Player Journey B — Disturbance Case

| Screen/Action | Why player does it | Information gained | Optional? | Potential friction |
|---|---|---|---|---|
| Case01 Room01 확정·인계 | 과거 결정 후 새 업무 진행 | 정상 UI에는 과거 결과 없음 | 사전 조건 | 테스트 데이터가 실패 원인을 설명하지 않음 |
| Case02 Profile → CCTV → Experiment | 현재 대상 조사 | 기본 정보·관찰 | 이동 REQUIRED | 기존 문구로 새 가설의 기준선을 만들기 어려움 |
| EXP02 선택·Run | 먼저 한 실험 관찰 | base result, opportunity 2에서 사건 발생 | OPTIONAL | 이번 B는 조건 관찰에 도달하는 유리한 순서로 재현함 |
| Overlay 읽기·Dismiss | 시설 변화 확인, 업무 재개 | LIGHT NORMAL→OFF, 이동 감소·벽 접촉 지속 | 발생 시 CONTEXTUAL, 해제는 진행에 필요 | 즉시 팝업이 실험 결과 읽기를 끊음 |
| Recheck CCTV | 변화가 대상에 영향을 줬는지 재검토 | 별도 CCTV condition observation | CONTEXTUAL | Overlay와 주된 내용이 유사, 새 정보의 이득 작음 |
| Back: EXPERIMENT | 중단했던 조사 복귀 | 실행 이력/남은 횟수 유지 | CONTEXTUAL | 미확정 선택과 결과 화면은 재생성 정책에 따라 초기화 |
| EXP01 선택·Run, 결과 스크롤 | 현재 조건에서 실험 관찰 | 반응 시작 지연, 벽 접촉 지속 | OPTIONAL / CONTEXTUAL | 추가 관찰은 152px 결과 영역 아래에 위치함 |
| Log → 입력 → Add → Edit → Update | 여러 관찰을 한 가설로 정리 | 플레이어 자신의 문장; 게임은 평가하지 않음 | OPTIONAL | 생성·편집 2회 입력, 본문 재독, 저장 전 초안 소실 가능 |
| Back → Containment | 자료를 토대로 Room 결정 | 후보·현재 시설 조건 | 이동/선택/확정 REQUIRED | 새 관찰이 Room 구분과 연결되지 않음 |
| Recheck → Log → Archive → 과거 Case Detail → Back 4회 | 이전 업무 기록 비교 | 획득한 과거 authored 기록, 과거 개인 메모 | OPTIONAL / CONTEXTUAL | 5개 화면, 귀환은 4번; 자동 원인 연결 없음 |

## UX Audit 요약표

Required/Optional/Contextual은 이번 보고용 분류다. 코드에 등급이나 메타데이터를 추가하지 않았다.

| System | Purpose | Required/Optional/Contextual | Observed friction | Severity | Recommended action | Implemented now? Y/N |
|---|---|---|---|---|---|---|
| Profile | 대상 식별·기본 정보 | 화면 통과 REQUIRED | 임시 설명이 판단 정보를 주지 않음 | P1 CONTENT | 기존 Case 문구에 검증 가능한 기준선 작성 | N |
| CCTV | 기본/조건 관찰 | 최초 통과 REQUIRED, 재확인 CONTEXTUAL | 시설 변화·reaction과 추가 관찰의 차이가 작음 | P2 CONTENT/UX | 조건별로 새로운 비교 관찰인지 점검 | N |
| Experiment | 제한된 조사·결과 | 통과 REQUIRED, 실행 OPTIONAL | 조건 관찰의 접근 시점/순서 제약; 결과 영역 스크롤 | P1 GAME DESIGN/CONTENT, P2 UX | 관찰 기회 표를 먼저 작성; 본문 우선순위 검토 | N |
| Experiment 안내 | 실행 기록과 재진입 문구 일치 | 동일 | 기록이 있는데 실행 없음이라고 표시 | P2 CODE/UX | 이력 있는 경우 미선택 결과임을 정확히 표시 | Y |
| Containment | 한 Room 선택·확정 | REQUIRED | 정보는 다른 화면/Log에 분산, Room 설명은 임시 | P1 CONTENT, P2 UX | 단서→Room 판단 관계를 콘텐츠에서 검증 | N |
| Disturbance Overlay | 발생 사실과 즉시 영향 전달 | CONTEXTUAL | 결과 읽기 중단; reaction과 CCTV 내용 중복 | P2 UX/CONTENT | 즉시 관찰과 후속 관찰의 의미를 분리 | N |
| Recheck CCTV | 현재 조건으로 재관찰 | CONTEXTUAL | 얻는 정보보다 재진입 비용이 커질 수 있음 | P2 GAME DESIGN/UX | 추가 관찰 없는 조건도 콘텐츠 후보로 검토 | N |
| Research Log | 현재 Case 발견 자료·메모 작업 공간 | OPTIONAL | 긴 목록의 재스크롤, 실험 결과 재독 때 왕복 필요 | P2 UX | 실제 이용 빈도 확인 후 배치/정보 계층 제안 | N |
| Working Hypothesis | 플레이어 추론 외부화 | OPTIONAL | 자유 입력 부담, 가설과 원문 비교, 미저장 초안 소실 | P2 UX, P3 polish | 사용성 조사 후 입력 흐름 후보를 검토 | N |
| Archive | 과거 Case 기록 읽기 | OPTIONAL / CONTEXTUAL | 왕복 6~8클릭, fallback 원문 없음 | P2 UX/CONTENT | 보존 문구 누락 평가; 화면 구조 변경은 후속 결정 | N |
| Main 안내 | 프로젝트 개발 상태 설명 | 표시용 | 더 이상 사실이 아닌 no gameplay 문구 | P2 CODE/UX | test-content gameplay prototype으로 교정 | Y |

실험·Log·Recheck·가설·Archive는 현재 진행을 위한 숨은 필수 조건이 아니다. A의 0회 사용 진행으로 확인했다.
다만 실험 결과를 다시 읽으려면 실행 항목을 재선택할 수 없어 Log가 사실상 재독 경로가 된다.
조건별 보너스 단서가 항상 CCTV/실험에만 있다면 최적 플레이에서는 이 Optional 기능들이 사실상 의무처럼 될 위험이 있다.
Archive는 현재 대상의 Room 정답이나 과거 실패 원인을 알 수 있는 지름길이 아니다.

## 사건, 추리, 반복 루틴에 대한 평가

**현재 확인한 사실:** Overlay는 시설 이상, `LIGHT: NORMAL → OFF`, 현재 대상의 즉시 반응을 구분해 표시한다.
CCTV는 BASE와 CONDITION 제목이 나뉘며, Experiment 조건 관찰은 실행 당시 조건을 명시한다.
Active Facility Condition은 세 작업 화면에서 동일한 현재 조건을 유지한다. 사건이 지나갔다고 조건이 사라지지 않는다.
Log/Archive 왕복은 추가 사건 기회를 만들지 않는다. 실행 완료 항목 재실행도 안 된다.
이미 완료한 실험에 이후 발생한 환경을 소급 적용하지 않는 경계는 일관된다.

**추리 효용에 대한 판단:** 조명 중단 후 이동량 감소는 “조명이 이동에 관여할 수 있다”는 약한 새 가설을 제시할 수 있다.
벽 접촉 지속은 “벽 접촉도 조명에 따라 함께 감소한다”는 단순 가설을 약화한다.
실험 조건 관찰의 “자극 후 움직임 시작 지연”은 이동량 감소를 다른 관찰축으로 보강할 수 있다.
그러나 Profile/CCTV 기본 문구에는 비교 가능한 정상 패턴이 없고, 실험은 자극의 구체적 내용이 없으며,
Room 후보에도 조명/벽 접촉/반응 지연과 연결되는 차이가 없다. 따라서 **시설 변화→약한 가설 후보까지는 표현되지만,
가설→격리 판단을 검증하는 콘텐츠로는 부족하다.** 단순 문자열 추가만은 아니지만, 현 플레이에서 판단을 바꾸는 효용은 입증하지 못했다.
CCTV condition은 Overlay reaction을 주로 재서술하므로 세 관찰 중 중복 비중이 가장 크다.
Hypothesis 저장은 이 효용을 만들어 주지 않는다. 노트의 존재와 추리의 성립은 별개다.

### 실제 authored 콘텐츠의 시점별 접근

아래 표는 Case01 Room01 인계 후 Case02에서 두 실험을 실제 버튼으로 실행한 결과다.
seed만 고정했으며 해당 Resource에 관찰을 추가하지 않았다.

| threshold | 실험 순서 | 사건 발생 행동 | EXP01 Condition Observation |
|---:|---|---|---|
| 2 | 01 → 02 | Run01 이후 | 없음. 실행 직후 발생한 조건은 소급하지 않으며 EXP02에는 매핑 없음 |
| 3 | 01 → 02 | Run02 이후 | 없음. 두 실험이 이미 끝남 |
| 4 | 01 → 02 | Containment 진입 | 없음. 두 실험이 이미 끝나고 정상 경로에 Experiment 복귀 버튼 없음 |
| 2 | 02 → 01 | Run02 이후 | 있음. 아직 남아 있던 EXP01을 조건 활성화 후 실행 |
| 4 | 실험 생략 | 발생하지 않음 | CCTV+Containment 2기회만 소비; 후보 유지 |

threshold 3/4에서도 02→01이면 EXP01이 사건 발생 전에 끝나므로 기존 조건 관찰을 얻지 못한다.
threshold=2에서도 어느 실험을 먼저 고르는지가 중요하다. 지금 문구는 그 선택을 추론할 근거를 제공하지 않는다.
이것은 크래시나 ID 연결 오류가 아니라 **GAME DESIGN/CONTENT 접근성 위험(P1)**이다.
실험이 Optional이어서 사건이 늦어지는 것 자체를 버그로 취급하지 않았다.
임계값, 기회 수, 실험 제한/재실행/역행 규칙은 변경하지 않았다.
“기존 실험을 반복해야 한다”는 튜토리얼이나 자동 재실행도 추가하지 않았다.

2~4는 이번 두 Case에서 CCTV 첫 진입, 실험 성공 실행 두 번, Containment 첫 진입의 최대 네 기회와 거의 대응한다.
반복하면 발생 위치가 몇 곳으로 좁혀져 예측하기 쉬워질 수 있다. 이번에는 2~4 값을 유지한다.
향후 범위 후보를 정한다면, **콘텐츠의 전체 조사 기회와 추가 관찰에 필요한 남은 행동 구간 사이**를 먼저 비교해야 한다.
검증 없이 더 작은/큰 숫자나 확률을 최종 밸런스로 추천하지 않는다.

### “사건→항상 CCTV→남은 실험 전부” 고정 루틴 위험

Recheck 버튼은 환경이 있으면 나타나지만 추가 관찰이 있는지 여부를 미리 구별해 주지는 않는다.
실험 기회·버튼도 대부분 고정되고 현 임시 Case02는 두 실험을 모두 실행할 수 있다.
조건 변화가 늘 보너스 단서를 준다면 읽기 비용만 감수하고 매번 같은 순서를 밟는 행동이 안전한 최적 전략처럼 굳을 수 있다.
그 경우 사건은 작업 패턴을 깨는 일이 아니라 새 체크리스트를 시작하는 신호가 된다.
반대로 threshold 3/4처럼 기회가 사라지는 사건은 “내가 뭘 해도 놓친다”는 감각을 만들 수 있다.
두 문제를 새 Evidence/State Machine/Manager로 해결할 근거는 없다.

**후속 콘텐츠 후보:** 어떤 교란은 즉시 반응만, 다른 교란은 CCTV만, 또 다른 교란은 실험만 추가 정보를 줄 수 있다.
Case02의 환기 reaction은 이미 CCTV/실험 조건 매핑이 없는 예다. 이것이 의도된 차이인지 문구로 플레이 테스트할 수 있다.
다만 매번 재확인했는데 무의미한 글만 나오게 만들면 또 다른 반복 비용이 된다.
선택 가능한 조사가 왜 유용하거나 불필요한지 기존 관찰 차이가 설명하도록 콘텐츠를 설계하는 후보를 권장한다.
이번에는 모든 Resource와 매핑을 그대로 보존했다.

### 숨겨진 결과와 공포 리듬

SUCCESS 경로는 인계만 일어난다. 긴장감을 남길 수 있지만 선택의 효과를 학습할 피드백도 없다.
FAILURE 경로에서는 다음 Case 조사 중 시설 문제가 발생한다. 현재 UI는 원인 Case/Room/FAILURE/Incident ID를 공개하지 않는다.
분리된 시간감은 가능하지만 임시 기본 정보로 인과관계를 추론할 수 없어 무작위 시설 이벤트처럼 느낄 위험이 크다.
반복 플레이에서 “환경 변화가 있으면 CCTV를 확인할 수 있다”는 버튼 언어는 학습할 수 있다.
“어떤 결정이 왜 문제였는가”를 학습할 수 있는지는 현재 콘텐츠로 확인할 수 없다.

Overlay의 짧은 팝업 한 번은 업무→중단→복귀의 리듬을 만든다. 해제 후 같은 View/확정 잠금/선택/결과가 유지된다.
오디오·아트·애니메이션 없이 놀람/공포 강도를 평가하지 않았다. 반복 시 정형 알림이 될 위험만 보고한다.
MAJOR Incident의 더 큰 업무 중단이나 Broadcast는 정상 경로에 없다. debug 경로를 정상 경로인 것처럼 평가하지 않았다.
향후 재연결 때는 시설 조건 적용과 큰 Incident 개시 승인, 사건 종료 후 원래 업무 복귀를 구별해야 한다.
지금 debug Result의 SUCCESS/FAILURE 공개 UI를 그대로 정상 경로에 연결하면 hidden-result 정책과 충돌한다.

## 읽기·탐색·정보 밀도

| Case02 제공 문자열 | 문자 수 | 관찰 |
|---|---:|---|
| Profile | 154 | 임시 소개, 결정 정보 없음 |
| 기본 CCTV | 141 | 짧지만 기준 패턴 없음 |
| Disturbance Overlay | 252 | 시설 상태와 즉시 반응 분리 |
| Recheck CCTV | 463 | 기본/조건/시설 반복 포함 |
| 조건 실험 실행 후 Experiment | 869 | 목록, 결과, 조건, 버튼, ID 포함 |
| 가설 편집 후 Log | 1,825 | Research 7행과 개인 메모, ID와 조작 안내 포함 |
| 격리 확정 후 Containment | 414 | 후보와 조건, 확정 잠금 |

이는 View가 제공하는 문자열 총량이다. **스크롤 아래 문구도 포함**하고 Main 공통 헤더는 제외한다.
실제 읽은 양/시간/가독성 점수는 아니다. source ID, 테스트 표기와 버튼 문구가 포함되어 본문만의 밀도보다 크다.
현재는 Log의 길이보다 중복된 임시 문구와 의미 없는 ID가 핵심 비교 관찰을 밀어내는 문제가 더 크다.

Experiment 결과는 152 논리 px 영역이므로 base 결과와 조건 설명 일부만 처음 보인다.
Condition의 구체적인 반응 문장은 아래로 스크롤해야 읽힌다. 실제 휠 눌림/해제 입력으로 마지막 문장까지 접근했다.
이는 화면 잘림 버그가 아니라 기존 ScrollContainer 동작이며 **새 정보가 처음부터 눈에 띄지 않는 UX(P2)**다.
Log의 Research/개인 메모, Archive Detail의 두 목록도 개별 스크롤된다.
긴 Research 30개, 500자 메모 20개, 여러 환경 조건/긴 CCTV·실험 관찰의 끝까지 접근 및 고정 버튼 복귀를 검증했다.
폰트/배치/스크롤 영역 크기/최종 UI는 바꾸지 않았다.

Log는 현재 발견 자료를 다시 읽고 메모하는 공간이고 Archive는 과거 Case의 읽기 전용 자료다.
화면 구성은 비슷하지만 현재 Runtime과 과거 authored ID 목록을 섞지 않는 역할 차이는 분명하다.
같은 관찰을 화면과 Log 양쪽에 표시하는 것은 재독 목적의 중복이다. 다만 읽은 행을 다시 찾아야 하는 비용은 남는다.
새 튜토리얼, 자동 연결, pinned evidence, 검색/필터는 구현하지 않았다.

Archive fallback은 보존하지 않는다. Case02 기본 CCTV/EXP02/Room02/환기 reaction에는 authored ID가 없다.
handoff 후에는 그런 구체적인 원문을 Archive로 재검토할 수 없어 과거 비교에 구멍이 생길 수 있다.
현재 마지막 Case02는 인계가 없어서 이 누락을 그 Case의 실제 Archive UI로 재현할 수 없다. 기존 fallback 경계 검사로 정책을 확인했다.
ArchiveState가 Case 목록을 만들므로 authored 발견 ID가 전혀 없는 Case는 메모가 별도 State에 남아도 목록에 안 나온다.
현재 두 Case에는 authored Profile이 있어 이 조건은 정상 콘텐츠에서 발생하지 않는다. 향후 콘텐츠의 한계로 보고만 한다.

가장 깊은 탐색은 Containment→Recheck CCTV→Log→Archive List→Detail, **5화면/4번의 복귀**다.
Detail→List→Log→CCTV→Containment를 확인했다. Back은 “직전 탐색 계층으로 복귀”이며 Recheck는 원래 작업으로 복귀한다.
현재 두 단계 return 변수로 충분하다. 범용 stack/navigation framework를 만들지 않았다.
일부 Back은 목적지 명칭 없이 Back만 써서 긴 탐색 후 기억에 의존한다. 잘못된 목적지는 발견하지 않았다.

미확정 Experiment/Room 선택은 Log/Recheck로 View가 재생성될 때 소실된다.
실행 이력과 확정 Room은 복원된다. Overlay Dismiss는 같은 View를 유지하므로 미확정 선택도 보존한다.
Log의 미저장 가설 초안/편집 모드와 스크롤 위치 역시 재진입 시 초기화된다.
기존 의도된 정책이며 새 draft-preservation 기능은 이번에 구현하지 않았다. Room 선택 후 재독하면 재선택 1클릭이 필요하다.

## 구조·경계 감사

| 숫자 | 실제 값과 기준 |
|---|---|
| Main line count | 1,244 (공백/주석 포함), 변경 없음 |
| Main function count | 66 (`^func ` 기준), 변경 없음 |
| State class count | 6, 모두 RefCounted·Main 소유 |
| View count | 주요 Stage View 12 + 보조 UI 2 = 14; 별도로 FlowView 공통 Script 1 |
| Resource data type count | 16 (`scripts/data/*.gd`) |
| Scene count | Main 1 + 주요 View 12 + 보조 2 = 15 |
| 제품 GDScript | Main 1 + State 6 + data 16 + View/공통 15 = 38 |
| Case Resource | `.tres` 2, 신규 Case 없음 |
| Autoload | 0; project.godot 설정 없음 |

### 여섯 State의 소유권

| State | 저장·변경 경계 | 중복/누출 감사 |
|---|---|---|
| CaseRuntimeState | 현재 Case 실행 이력, 확정 Room, discovery/노출 순서, 적용 조건; Main 승인 실행·확정·실제 표시·사건 적용 | 현재 업무 상태. handoff에서 새로 생성. debug Monitoring/Broadcast 결과도 있으나 정상 경로에서 미정 |
| PendingContainmentState | Confirm 때 Case/Room 제출, 성공한 내부 판정 때 제거 | Runtime 확정 Room과 키가 겹치지만 Runtime 교체 이후의 제출 수명 때문에 구별됨 |
| ContainmentResolutionState | handoff 내부 판정 1회 | 숨겨진 과거 결과. 화면 표시 DTO에 넣지 않음 |
| FailureEventCandidateState | 실패 후보 생성, 유효 기회 증가, 교란 발생 표시 | 판정 자체를 중복 계산하지 않고 지연 발생을 관리; 타이머 State 아님 |
| ResearchArchiveState | handoff/debug Result 경계에서 유효 authored ID incremental merge | Runtime discovery와 수명이 다름; 원문/정답/실행 당시 전체 snapshot 없음 |
| WorkingHypothesisState | 활성 Log의 현재 Case 요청 승인 후 Add/Update/Delete | 플레이어 자유 메모, 판정/discovery와 무관; getter deep copy |

State 변경은 Main의 승인 경계에서 일어난다. View는 UI 임시 선택·표시만 소유하고 Main/Runtime/테스트 Case를 탐색하지 않는다.
Resource Script는 exported authored 값과 enum만 갖는다. View가 참조하는 일부 authored Resource는 읽기 전용이며 실행 결과를 써넣지 않는다.
새 실행 전후 제품 파일 hash와 in-memory Case/중첩 Resource 직렬화 비교가 일치했다.
DTO/Snapshot은 전달·표시용이다. Log·Archive 읽기와 Snapshot 생성은 게임 State/RNG/opportunity/Archive/메모를 변경하지 않는다.
Archive/메모 복사본을 수정해도 State와 원본 Resource는 그대로다. debug Result Summary의 Resource 참조도 표시만 한다.

**ID 연결:** Case→Room→Outcome, Outcome→Incident, Incident→Disturbance/Broadcast,
Disturbance→Reaction, CCTV/실험 ID+Disturbance→Condition, source kind+source ID→Research, Case+entry ID→Archive를 확인했다.
UI의 목록 index는 선택한 Resource를 찾아 ID를 요청하는 데만 사용한다. 콘텐츠 배열 순서를 정답/조건 연결로 사용하지 않는다.
case_sequence index는 의도된 업무 순서이며 Stage→PackedScene 배열은 기존 enum 기반 UI 매핑이다.
두 방식 자체를 새로운 콘텐츠 index coupling 결함으로 분류하지 않았다.
중복/missing/invalid ID는 기존 경계에서 차단하거나 [Unavailable]/fallback을 표시한다.
일부 오래된 debug 조회는 첫 ID 일치를 사용한다. 정상 hidden resolution/Archive/condition 경계는 중복을 거부한다.
debug lookup 정책 통일은 향후 부채 후보이며 이번에 전면 교체하지 않았다.

**stale/중복/cleanup:** Overlay는 활성 인스턴스·tree·queue 상태를 확인한다.
Archive List/Detail은 Stage, 활성 View, visible, archived Case ID를 검사한다.
Log 메모는 활성 visible Log, Case/Runtime 일치, 복사된 View Case ID까지 승인한다.
이전 View의 늦은 요청, 숨긴/분리한 View 요청, overlay 뒤의 요청, forged ID, 반복 setup/reentry를 기존·새 검사에서 거부했다.
연결은 _ready/새 View 생성에서 한 번; setup은 데이터/동적 UI만 새로 만든다.
Research/메모/Case 목록/detail/환경/조건 관찰은 remove_child 후 queue_free하며 반복 refresh에서 행이 누적되지 않는다.
새 stale signal/null crash/Back destination/동적 Node 중복 오류는 발견하지 않았다.

### Main 분리 여부

**이번 단계 결론: 현 상태 유지.** 줄 수만으로 분리하지 않았다.
Main은 단순 화면 전환 외에 authored 조회·검증, 공개 Snapshot 조립, hidden resolution과 opportunity/discovery 순서도 소유한다.
Research/Archive 표시 조립은 사건 진행과 비교적 독립되어 분리 후보가 될 수 있고,
기존 검증은 `_show_view`, `_build_*`, private Stage/RNG 등 내부 구현을 많이 호출해 변경에 민감하다.
또한 _show_view가 모든 View/보조 복귀 경계를 설정하므로 unrelated flow에 대한 회귀 부담은 실제로 있다.
반면 Case 두 개, 명확한 Main 승인, 여섯 State의 분리, 66개 함수의 역할 구분과 회귀 검사가 있어 지금 즉시 대규모 분리할 필요는 없다.

향후 콘텐츠 종류가 늘면 **읽기 전용 authored 조회·Snapshot 조립**을 독립 함수/모듈로 옮기는 경계를 먼저 검토할 수 있다.
그 경계는 State를 새로 소유하거나 이벤트를 발생시키면 안 된다. 요청 승인과 실제 discovery/진행 변경은 Main에 남겨야 한다.
debug downstream을 정상 정책에 재연결하는 작업도 별도 경계로 검토해야 한다.
ResearchManager/ArchiveManager/EnvironmentManager/CaseManager/EventManager는 만들지 않았다.

## 발견 사항: 확정 사실과 후속 제안 구분

P0=진행 불가/손상/크래시, P1=핵심 추리 방해, P2=반복/가독성/탐색 불편, P3=향후 polish.
아래 P1은 기술적 진행 실패가 아니라 콘텐츠/설계의 추리 경험 위험이다.

| ID | Severity / 분류 | 관찰·영향 | 이번 수정 | 향후 후보 |
|---|---|---|---|---|
| F01 | P1 CONTENT/GAME DESIGN | 기본 관찰/실험/Room 설명이 임시 문구여서 관찰→판단을 검증 못함 | N | 기존 Case 내용으로 기준선·가설·Room 관계 검증 |
| F02 | P1 GAME DESIGN/CONTENT | EXP01 조건 관찰이 발생 시점·실험 순서에 따라 접근 불가 | N | 시점별 단서 기회 표와 콘텐츠 변형 검증; 즉시 밸런스 수정 금지 |
| F03 | P2 CONTENT/UX | Overlay/CCTV의 이동 감소·벽 접촉 지속 반복 | N | 후속 관찰이 새 정보를 주는지 authored 문구 비교 |
| F04 | P2 UX | 실험 추가 관찰이 짧은 Scroll 영역 아래, Log 목록의 재스크롤 | N | 핵심 문구 우선순위/배치 후보를 사용자 테스트 후 결정 |
| F05 | P2 UX | 미확정 선택/메모 초안은 View 재생성 때 소실 | N | 의도된 정책 유지, 실제 재선택 부담을 관찰 |
| F06 | P2 UX | Archive 왕복 6클릭, Recheck 포함 8클릭/5화면 | N | 과거 비교 빈도를 확인한 뒤 탐색 단축 후보 검토 |
| F07 | P2 CONTENT/UX | fallback의 과거 원문 미보존, authored ID 없는 Case의 메모 접근 한계 | N | 콘텐츠 coverage부터 점검; snapshot 보존 새 기능은 미구현 |
| F08 | P2 GAME DESIGN | 숨겨진 SUCCESS는 학습 피드백이 없고 FAILURE는 random으로 느낄 위험 | N | 공개 관찰의 인과 추론 가능성 검증, 성공 알림 미추가 |
| F09 | P2 GAME DESIGN/UX | 항상 재확인+잔여 실험 실행이 최적 루틴처럼 굳을 위험 | N | 즉시/CCTV/실험의 관찰 유무·효용이 다른 콘텐츠 후보 |
| F10 | P2 CODE/UX | Main 헤더가 실제와 달리 no gameplay라고 표시 | Y | test content prototype 안내로 수정 |
| F11 | P2 CODE/UX | 실행 이력 있는 Experiment의 초기/재진입/거절 후 안내가 실행 없음 | Y | 미선택 결과라는 문구로 수정, 기록/재실행 정책 유지 |
| F12 | P3 TECH DEBT | Main 표시 조립·진행 승인 공존, 내부 구현에 결합된 테스트 | N | 확장 시 읽기 전용 조립 경계 검토, 현재 구조 유지 |
| F13 | P3 UX | 작은 창에서 개발 ID와 긴 영어 테스트 문구, Back 목적지 기억 부담 | N | 정식 폰트/최종 UI 이전에 실제 사용 빈도와 문구 검토 |

P0 발견 없음. 진행 차단인 마지막 Case의 No next test case configured는 기존 명시된 프로토타입 경계이며 새 P0로 분류하지 않았다.
실제 수정한 CODE 문제는 F10/F11뿐이다. F01~09/F12~13은 이번에 구현하지 않은 제안/위험이다.

## 변경 파일, 검증, 한계

| 제품/문서 파일 | 실제 변경 이유 |
|---|---|
| scenes/main/main.tscn | Notice.text 한 줄 교정. Node/Scene/배치/크기 변경 없음 |
| scripts/views/experiment_view.gd | 초기 결과 문구를 실행 이력 기준으로 교정; 거절 후 이력 표시 갱신 때도 문구를 일치시킴. 결과/선택/State 규칙 변경 없음 |
| README.md | Step38 감사 보고서 링크와 간단한 결과 추가. 이전 Step37 및 더 오래된 보고서는 그대로 보존 |
| docs/step38_core_loop_audit.md | 이 감사 보고서 신규 생성 |

생성한 제품 Scene/Script/Resource/State/에셋은 **0개**, 삭제 파일 **0개**다.
검증 자료는 Git 제외 `.godot/verification/step38/`와 `step38-timing/`에만 생성했다.
기존 2,152개 검증 파일은 수정하지 않았다. 변경 전 제품 99개 중 3개 변경·96개 보존, 새 문서 1개를 scope 감사했다.
project.godot, Main Script, 두 Case Resource, 모든 State, 기존 Scene 배치·Stretch는 SHA-256이 동일하다.
`git status`, `git diff`, `git diff --check`와 전체 변경 파일 hash를 검사했다. 의도하지 않은 수정·삭제는 없다.

| 검사 | 결과 |
|---|---|
| 제품 GDScript 38개 check-only | Godot 4.7.1 파싱 통과 |
| 기존 회귀 186 + 새 Journey 6 | **192개 통과**, headless 114 / Windows GPU 78 |
| 시점/순서/휠/임시 선택 추가 감사 | headless / Windows GPU **2개 통과**; 위 192와 별도 |
| editor import | exit 0, 파싱 오류·경고 없음 |
| A normal Case01→Case02 | 성공 경로, 실험/Log 없이 정상 확정·인계; 마지막 Pending 보존 |
| B 환경 흐름 | 실제 실패 인계→후보→기회→Overlay→Recheck→CCTV 발견→실험 조건 발견→가설 생성/편집→격리 확정 |
| B 세 해상도 | 1920×1080, 1280×720, 1024×768 모두 headless/Windows GPU 통과 |
| C와 CRUD | 과거 기록 읽기, Back 4회, 원래 작업/확정 잠금 복원; 가설 삭제 통과 |
| debug downstream | Monitoring Timer 독립 경로, SUCCESS/FAILURE, Incident/Broadcast/IncidentResult/Result 회귀 통과; 정상 경로와 별도 |
| long/multiple UI | 긴 Research/메모/조건 목록의 wrap·scroll·끝 항목·고정 탐색 버튼 접근 통과 |
| State/Resource 경계 | stale/forged/duplicate/missing/null/반복 setup, snapshot 읽기 무변경, Resource hash/메모리 내용 보존 |
| 화면 확인 | 새 Journey PNG 30개 중 핵심 화면 6개와 실제 휠 결과 1개 직접 확인; 긴 콘텐츠 추가 캡처 확인 |

1024×768 창의 내용 렌더 영역은 기존 keep 비율의 **1024×576**이다. PNG는 viewport texture이며 전체 창/letterbox 캡처가 아니다.
Main 논리 영역은 항상 1920×1080이다. 기존 window override 1280×720, canvas_items, 기본 keep/resizable, GL Compatibility를 유지했다.
F5 키를 직접 누르는 자동화는 하지 않았다. F5가 사용하는 동일 project main_scene의 기본 실행과 실제 버튼 진행을 양쪽 backend에서 검증했다.
정상 경로와 editor import는 오류·경고 0이다. 일부 invalid-content 회귀의 경고는 기존 예상 개수와 정확히 일치했다.

초기 검증 중 구문/테스트 오류는 최종 결과와 구별한다.
추가 시점 검증기의 자동 debug wrapper가 새 검사 경로를 오해해 로드 실패했고, 검증기 경로만 수정했다.
휠 눌림만 보낸 테스트에서는 다음 클릭이 처리되지 않아 휠 해제도 전달하도록 검증기를 수정했다.
기존 실행 UI 회귀에서는 stale 데이터의 거절 후 초기 안내가 실제 이력과 어긋나는 경우를 발견해 F11 갱신 문구를 보완했다.
Step38에 복사한 기존 회귀의 문구 기대값만 이력 유무에 맞췄으며 selection/history/횟수/State/실행 거절 검사는 그대로다.
제품 수정 후 전체 검사를 다시 시작했다. 복사한 회귀의 캡처 출력 폴더 누락도 발견해 폴더를 마련했다.
이때 소스 SHA와 로그 SHA가 같은 성공 검사만 재사용하고 나머지를 완료해 전체 192개 최종 통과를 확인했다.
이전 검사 원본을 수정하거나 검사를 생략하지 않았다.

## 요청한 85개 종료 항목 대응

위 표·분석과 함께 읽는 항목별 요약이다. 권장 항목은 현재 확정 사양이 아니다.

| # | 항목 | 결과 |
|---:|---|---|
| 1 | 작업 전 Git | a1dfe02, master→origin/main, clean |
| 2 | Audit 방법 | 저장소/문구/요청 경계 조사, SHA 기준선, 실제 마우스 입력, GPU 캡처, 기존 회귀 |
| 3 | 실제 Scenario | A 무사건, B 과거 실패/현재 환경/가설, C 과거 기록과 복귀, 별도 CRUD/시점 감사 |
| 4 | 정상 클릭 | 확정 5, 인계 6, 두 Case 확정 11; 0 실험/0 Log 가능 |
| 5 | Disturbance 클릭 | B 19, 사전 인계 6 별도; 가설 타이핑 57+87자 별도 |
| 6 | Archive 행동 | 일반 6, Recheck 포함 8 |
| 7 | Required | 기본 화면 Next, Room 선택/확정; 다음 Case 인계 시 Next Case |
| 8 | Optional | 실험 실행, Log 읽기/메모 CRUD, Archive 조회 |
| 9 | Contextual | 사건 Dismiss, 환경 시 Recheck, 보조 화면 Back; 사용 후 복귀에 필요 |
| 10 | 사실상 강제 Optional | 진행 강제 없음; 결과 재독은 Log 의존, 보너스 단서가 고정되면 재확인 루틴 위험 |
| 11 | Log 빈도 | A 0회, B 1회; C/CRUD 회귀는 별도 |
| 12 | Log 반복 | 모든 단계 왕복하면 +8클릭; 스크롤/재독 비용 |
| 13 | Archive 역할 | 과거 acquired authored 기록·메모를 읽음 |
| 14 | Log/Archive 중복 | 비슷한 표시, 현재 작업/과거 참조로 수명과 역할 분리 |
| 15 | Hypothesis 효용 | 여러 관찰을 자신의 문장으로 외부화; 평가/정답 시스템 아님 |
| 16 | Hypothesis friction | 입력/편집·원문 비교·미저장 초안 소실 |
| 17 | Disturbance 이해 | 시설 변화/대상 반응은 구분; 과거 결정과의 인과 이해는 부족 |
| 18 | Overlay 정보량 | 해당 경로 252자 제공, 짧은 시설/조건/반응 |
| 19 | Overlay 중복 | CCTV 후속과 이동 감소/벽 접촉 정보가 유사 |
| 20 | Active Environment | 유지 상태 확인에 필요, 여러 화면에서 반복·ID 소음 |
| 21 | Base/Condition | 제목 분리·실행 당시 조건 명시; 실험 세부 관찰은 스크롤 아래 |
| 22 | Discovery timing | 실제 CCTV 표시/승인 실행 후 발견, 단순 활성화/Resource 존재는 미발견 |
| 23 | Hidden 공정성 | 정책은 지켰으나 임시 단서로 Room 판단/인과 학습을 검증 못함 |
| 24 | Failure 예측 | 4개 고정 기회 중 2~4에 발생; 반복 위치 예측 위험 |
| 25 | threshold 체감 | 2는 조사 도중, 3은 두 번째 실험 뒤, 4는 격리 진입; 규칙 불변 |
| 26 | Opportunity 품질 | 업무 행동과 결합, Log 왕복 제외; Optional 실험과 시점 연동 주의 |
| 27 | 새 가설 여부 | 조명·이동/반응 지연 가설 후보와 벽 접촉 반례 가능 |
| 28 | 텍스트 증가 여부 | CCTV는 중복 비중 큼, 실험은 다른 관찰축이나 Room 판단 연결 없음 |
| 29 | 정보 밀도 | B 154→141→463→869→1,825자 제공; 스크롤/ID 포함 |
| 30 | 단서 매몰 | 작은 결과 영역과 긴 Log, 유사 관찰 반복이 핵심 차이를 묻을 위험 |
| 31 | Containment UX | Log 재독 가능, EXP 화면 역행은 없음; 후보 구분 콘텐츠 부족 |
| 32 | Recheck 효용 | 현재 조건의 관찰/발견을 확보하고 원래 업무 복귀 |
| 33 | Recheck 반복 | 반복은 새 기회/보상 없음; 습관적 확인 비용 위험 |
| 34 | Recheck 복귀 | Back: EXPERIMENT 또는 CONTAINMENT, 확정 잠금 유지 |
| 35 | 최대 depth | 확인한 정상 경로 5화면/4복귀 |
| 36 | Back 일관성 | Detail→List→Log→CCTV→원래 작업, 잘못된 목적지 없음 |
| 37 | 선택 소실 | View 재생성 시 미확정만 초기화; 실행/확정 복원, 정책 변경 없음 |
| 38 | Overlay pacing | 업무 입력 중단, 동일 View 복귀; 짧은 단일 알림 |
| 39 | Horror pacing | 업무→이상→업무 형태만 확인, 아트/오디오/MAJOR 없음 |
| 40 | Incident 재연결 | debug 보존, 정상 정책과 복귀 승인·hidden 공개 경계부터 검토 필요 |
| 41 | State 책임 | 6개 State 표의 수명/쓰기 경계 구분 |
| 42 | State 중복 | Case/Room/entry 키는 겹쳐도 현재/제출/판정/세션 수명 달라 유지 |
| 43 | Main 크기 | 1,244줄/66함수 |
| 44 | Main 책임 | 화면/승인/조회/검증/Snapshot/hidden 판정/opportunity/discovery |
| 45 | 분리 필요 | 이번 Step 현 상태 유지 |
| 46 | 미래 분리 경계 | 읽기 전용 authored 조회·Snapshot 조립 후보, State 새 소유 금지 |
| 47 | Resource | authored exported 값, runtime mutation 없음 |
| 48 | View | 표시/local 선택/signal, Runtime/Main/test Resource 탐색 없음 |
| 49 | ID linkage | 콘텐츠 ID 기준; UI 로컬 index·sequence 순서는 별개 |
| 50 | stale signal | Overlay/Archive/Log 메모 active/tree/visible/Case 승인과 회귀 통과 |
| 51 | duplicate signal | 반복 setup/reentry에서도 한 번 연결, 누적 없음 |
| 52 | cleanup | 동적 행 detach+queue_free, 개수/해제 검증 |
| 53 | Resource mutation | 디스크 SHA 및 메모리 중첩 직렬화 불변 |
| 54 | Runtime boundary | Main 승인 쓰기, 표시/조회 무변경 |
| 55 | Snapshot | 복사된 표시 DTO, 두 번째 Gameplay State 아님 |
| 56 | fallback 한계 | authored ID 없는 과거 원문 없음, 이번 미수정 |
| 57 | 콘텐츠 적합성 | 기술 경계 테스트 충분, 가설→판단 검증은 부족 |
| 58 | SUCCESS 체감 | 무사건/인계만 보여 선택 학습 피드백 부족 위험 |
| 59 | FAILURE 체감 | 지연 시설 사고, 임시 내용으로는 random처럼 느낄 위험 |
| 60 | 시스템 학습 | 변화 후 Recheck 버튼은 학습 가능, 인과/판단 언어는 미검증 |
| 61 | 최적 루틴 | 사건마다 재확인/모든 잔여 실험을 체크리스트로 할 위험 상세 분석 |
| 62 | 콘텐츠 다양성 | 즉시/CCTV/실험 관찰 유무·다른 관찰축 후보; 구현 없음 |
| 63 | P0 | 없음 |
| 64 | P1 | F01/F02 CONTENT/GAME DESIGN |
| 65 | P2 | F03~F11 반복/탐색/가독성/학습·두 잘못된 문구 |
| 66 | P3 | F12/F13 구조 부채와 polish |
| 67 | CODE | F10/F11 문구만 수정, 신규 진행/손상 결함 없음 |
| 68 | UX | 스크롤/왕복/선택·초안 소실/ID 소음 |
| 69 | GAME DESIGN | 숨김 학습/기회·순서/고정 루틴 위험 |
| 70 | CONTENT | 기본 패턴·Room 연결·후속 관찰 차이 부족 |
| 71 | TECH DEBT | Main의 표시 조립/승인 혼합, 내부 결합 테스트, debug lookup 차이 |
| 72 | 실제 수정 | Main Notice 1줄, Experiment 이력 기반 초기/갱신 안내 |
| 73 | 추천만 | F01~09/F12~13; 화면 통합/튜토리얼/밸런스/보존 정책 구현 없음 |
| 74 | UX 요약표 | 위 9개 주요 기능 및 문구 수정 행 |
| 75 | Journey A | 위 No-Disturbance 단계 표 |
| 76 | Journey B | 위 Disturbance 단계 표 |
| 77 | 전체 회귀 | 192통과 + 추가 감사 2통과 |
| 78 | B 3해상도 | 실제 normal 버튼 진행 양 backend 6회 통과 |
| 79 | debug downstream | 독립 경로 SUCCESS/FAILURE/Incident/Broadcast/IncidentResult/Result 통과 |
| 80 | 파싱/실행 | 38 GD와 editor import 통과, 실제 기본 Main 실행 확인 |
| 81 | 변경 파일 | 기존 3 + 문서 신규 1, 제품 코드/Scene 신규 0, 삭제 0 |
| 82 | 미커밋 보존 | 작업 전 없음, 기존 파일/검증 hash 감사 완료 |
| 83 | 구조 숫자 | Main1,244/66, State6, UI View14+base1, Resource16, Scene15 |
| 84 | 최우선 3개 | 아래 세 가지 순서 권장 |
| 85 | 다음 Step | 기존 Case 콘텐츠의 단서→가설→격리 판단 검증 권장 |

## 다음 작업 권장 순서

1. **기존 Case의 추리 연결 작성:** 정상 기준 패턴, 환경 반응 차이, 실험 자극/관찰, Room의 비교 가능한 조건을 한 장으로 연결한다. 정답 공개나 새 시스템 없이 플레이어가 왜 그 선택을 했는지 설명할 수 있는지 검증한다.
2. **단서 기회 검증:** threshold/실험 순서/실험 생략별로 어떤 정보를 언제 얻는지 비교한다. 후속 콘텐츠가 추가 단서를 놓쳐도 판단 가능하도록 보조/필수 구분을 검토한다. 그 후에만 authored 변형 또는 밸런스 후보를 별도 결정한다.
3. **짧은 실제 플레이 테스트:** 개발 설명 없이 처음 플레이하는 사람이 재확인/Log/가설/Archive를 언제 쓰는지, 어느 문구를 근거로 Room을 골랐는지 관찰한다. 왕복과 재독 빈도를 확인한 뒤 UI 개선 후보를 결정한다.

**Step39 추천:** 위 1~2를 중심으로 기존 두 Case의 “관찰→가설→격리 판단” 콘텐츠 검증을 먼저 진행한다.
이번 보고는 그 단계의 구현 승인이 아니다. Severity/MAJOR/자동 Broadcast/Case03/Campaign/SaveLoad/Evidence linking/
Archive fallback snapshot/Tutorial/새 Manager/최종 UI·폰트·에셋/오디오·애니메이션·Shader/밸런스 overhaul은 추가하지 않았다.
