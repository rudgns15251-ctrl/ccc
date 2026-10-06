# Step39 — Case Evidence 콘텐츠 정비

작업일: 2026-10-05. 기존 프로젝트의 Case01/02 텍스트를 정비했다. 새 Gameplay 기능, Scene, Script, State, Resource 필드는 추가하지 않았다. 커밋·push하지 않는다.

기본 Profile·CCTV·실험 결과와 Room 설비의 차이를 연결했다. 환경 사건이 없어도 판단할 수 있으며, 환경 관찰은 기존 판단을 재검토하는 보조 자료다. 조건 실험이 뒤늦게 불가능해지는 기존 규칙은 유지하고, 그 정보에 필수 판단을 의존하지 않도록 했다.

**판정 경계:** Case01의 기존 `TEST_ROOM_02 = SUCCESS`, `TEST_ROOM_01/03 = FAILURE` 매핑을 보존했다. Case02에는 원래 `containment_outcomes`가 없다. 아래 Case02 ROOM01은 콘텐츠상 합리적인 선택이며, 실제로 인코딩된 정답 또는 SUCCESS라고 보고하지 않는다. 마지막 Case02는 기존과 같이 격리 제출 후 Pending에 머문다.

## 작업 전 조사

HEAD `0e9ae101d792c4c91a5f1886673f574215ae6454` (`Audit core loop UX and correct prototype status labels`). `master`는 `origin/main`을 추적하며 working tree는 깨끗했다. 원격은 `https://github.com/rudgns15251-ctrl/ccc.git`이다. 기존 미커밋 변경은 없었다.

실제 tracked 파일 100개와 이전 검증 소스 2,346개의 SHA-256 기준선을 남겼다. 루트·상위 디렉터리에 적용할 AGENTS.md는 없었다. project.godot, Main Scene/Script, 전체 View/State/Resource, 두 Case의 ID 연결, Step38 보고서, 이전 검증 자료를 조사했다.

| 실제 구조 | 확인 결과 |
|---|---|
| project.godot | Main 실행 경로, 1920×1080 기준, canvas_items/keep, resizable, Compatibility 유지; Autoload 없음 |
| scenes | Main + 주요 화면 12개 + 보조 UI 2개 = 15 Scene |
| scripts | Main 1개, Main 소유 RefCounted State 6개, data 16개, View/common 15개 = 38 GDScript |
| resources/cases | test_case_01.tres, test_case_02.tres; Case03 없음 |
| assets | 실제 게임 에셋 없음; 기존 .gitkeep 보존 |
| docs / README | Step38 감사와 기존 개발 보고 이력 |
| .godot/verification | 기존 검사·로그·캡처; Git 제외 영역 |

Step38 F01: 기본 설명과 Room이 임시 문구라 관찰→판단 연결이 부족했다. F02: EXP01 조건 관찰은 active condition + 미사용 EXP01 + 실제 실행이 필요해 사건 시점과 순서에 따라 얻지 못했다. F03: 즉시 반응/CCTV/실험 조건 관찰의 ‘이동 감소·벽 접촉 지속’이 반복됐다. 이 세 CONTENT/GAME DESIGN 문제를 텍스트에서 다룬다. Main의 권한 승인, ID 연결, hidden resolution에 제품 코드 오류는 발견하지 않았다.

## 문서상 분류와 읽는 방법

- **CORE:** 환경 사건 없이 얻을 수 있는 Profile·기본 CCTV·기본 실험 결과. Profile/CCTV는 정상 흐름에서 표시된다. 실험은 선택·실행해야 하므로 CORE라고 해서 자동 획득 또는 모두 필수라는 뜻은 아니다.
- **GUARANTEED:** 실제 사건 후 실험 잔여량·실험 순서에 관계없이 접근 가능한 사건별 최소 관찰 채널. 즉시 반응은 Overlay에 표시되고, 해당 authored CCTV condition이 있으면 재확인으로 얻는다. 모든 사건에 CCTV condition이 필요하다는 규칙을 만들지 않았다.
- **OPPORTUNISTIC:** 조건이 활성화된 상태에서 아직 사용하지 않은 대응 실험을 실제 실행했을 때만 얻는 추가 관찰. 놓쳐도 기본 판단이 가능하다.

SUPPORT/WEAKEN/CONTEXT와 WEAK/MEDIUM/STRONG은 아래 수동 콘텐츠 감사에서 특정 가설에 대한 역할·정보 강도를 설명한다. 숫자 점수, Runtime enum, metadata, 자동 정답/가설 생성은 없다. ResearchEntry의 요약 본문은 원 출처와 별개의 독립 증거로 세지 않는다. Room 설명은 비교할 설비이며 증거 자체가 아니다.

## Case01 Evidence Map

| Source | Source ID | Player sees | Evidence role | Possible hypothesis | Strength | Required/Optional | Available without Disturbance? |
|---|---|---|---|---|---|---|---|
| CORE Profile | TEST_PROFILE_01 | 금속 지지대에서 펌프 주기 뒤 타격; 말소리와 연결 없음 | SUPPORT / WEAKEN | 펌프 관련 기계 자극; 말소리 반응 가설은 약함 | WEAK | 정상 흐름 표시; 해석 필수 | Yes |
| CORE 기본 CCTV | TEST_CAM_01 | 펌프 시작에 타격 집중; 환기 주기 때 되돌아봄; 조명은 이동 경로만 변화; 벽 추적 지속 | SUPPORT / WEAKEN | 지지 구조 자극 + 환기 전환이 두 비교 축; 어둠이 타격을 제거한다는 가설은 약함 | MEDIUM | 정상 흐름 표시; 두 축 비교에 중요 | Yes |
| CORE 실험 01 | TEST_EXP_01 | 공기 중 소리/환기 고정, 금속 지지대 충격에 타격이 더 많음; 두 조건에서 벽 추적 지속 | SUPPORT | 소리 자체보다 지지대를 통한 충격 전달이 중요 | STRONG | Optional; 지지 구조 가설 검증에 유용 | Yes, 실제 실행 시 |
| CORE 실험 02 | TEST_EXP_02 | 지지/소리 고정, start/stop 공기 흐름에 되돌아봄이 많고 지속 약풍에서 적음 | SUPPORT | 환기 전환을 줄이는 것이 합리적 | STRONG | Optional; 환기 가설 검증에 유용 | Yes, 실제 실행 시 |
| CORE 실험 03 | TEST_EXP_03 | 충격/환기 변화 없이 소리만 재생하면 잠깐 향하지만 타격 집중은 재현되지 않음 | WEAKEN | 공기 중 펌프 소리만으로 기존 타격을 설명하기 어려움 | MEDIUM | Optional; 상대적으로 간접적인 부정 증거 | Yes, 실제 실행 시 |
| 설비 비교 | TEST_ROOM_01 | 방음 파티션 + 서비스 구조에 연결된 단단한 금속 지지대 + 지속 약풍 | CONTEXT | 소리 원인이라면 그럴듯하나 지지 구조 단서는 남음 | WEAK | 후보 읽기/Room 선택 Required | Yes |
| 설비 비교 | TEST_ROOM_02 | 기계적으로 분리된 완충 지지대 + 지속 약풍 + 일반 조명 | CONTEXT | 두 축의 자극을 함께 줄이는 후보 | WEAK | 후보 읽기/Room 선택 Required | Yes |
| 설비 비교 | TEST_ROOM_03 | 분리된 완충 지지대 + start/stop 환기 + 낮은 조명 | CONTEXT | 지지 축은 대응하지만 환기 축은 남음 | WEAK | 후보 읽기/Room 선택 Required | Yes |

Case01 자체에는 수신 reaction/CCTV condition/Experiment condition이 없다. 현재 정상 순서의 첫 Case이므로 앞선 실패 사건도 없다. Case01 Guaranteed/Opportunistic 항목을 존재한다고 가정하지 않았다.

**판단 연결:** Profile은 펌프와 타격의 시간 관계를 제시하며 원인을 확정하지 않는다. CCTV에서 지지 자극과 환기 전환의 두 축을 발견한다. EXP01은 지지 구조, EXP02는 환기 축을 각각 분리해 비교한다. ROOM02는 두 축을 함께 줄인다. EXP01만으로는 ROOM02/03이 모두 남고, EXP02만으로는 ROOM01/02가 모두 남으므로 다른 기본 출처를 함께 읽어야 한다. ROOM 번호를 추천하거나 정답을 진술하는 소스 문장은 없다.

독립 CORE 출처는 Profile·CCTV·EXP01·EXP02·EXP03의 5개다. 지지 축은 Profile/CCTV/EXP01 및 EXP03의 부정 비교, 환기 축은 CCTV/EXP02가 뒷받침한다. **최소 접근 경로는 Profile+CCTV의 2개 출처로 합리적 비교 가능**, 1개 유용한 실험을 더하면 3개 출처로 한 축을 더 강하게 검증하고, EXP01+02를 사용하면 4개 출처가 된다. 무실험 경로의 시간 상관 증거는 통제 실험보다 약하다. 모든 플레이어의 정답을 보장한다는 주장은 아니다.

ROOM01의 방음과 ROOM03의 완충·어두운 조명은 실제 속성을 가진 그럴듯한 후보다. 거짓 관찰로 함정을 만들지 않았다. EXP03을 택해도 ‘소리만 원인’이라는 가설을 약화하며, CCTV의 환기 정보를 보존하므로 2회 제한 안에서 진행할 수 있다.

## Case02 Evidence Map

| Source | Source ID | Player sees | Evidence role | Possible hypothesis | Strength | Required/Optional | Available without Disturbance? |
|---|---|---|---|---|---|---|---|
| CORE Profile | TEST_CASE02_PROFILE_01 | 벽 접촉 상실 뒤 탐색; 손상 기록 없음 | SUPPORT / WEAKEN | 접촉이 방향 탐색의 기준일 수 있음; 접촉을 곧 공격으로 보는 해석은 약함 | WEAK | 정상 흐름 표시 | Yes |
| CORE 기본 CCTV | TEST_CASE02_CAM_01 | 환기 전환에 배출구로 향함; 얕은 요철을 따라 발 추적; 매끈한 면에서 옆으로 탐색; 새 손상 없음 | SUPPORT / WEAKEN | 연속 접촉의 탐색 기능 + 공기 변화에 대한 방향 반응; 접촉=위험 단정 약화 | MEDIUM | 정상 흐름 표시; 두 축 비교에 중요 | Yes |
| CORE 실험 01 | TEST_CASE02_EXP_01 | 벽/조명 고정; 공기 펄스에 노즐로 돌아선 뒤 벽 추적 재개; 팬 소리만으로 일관된 회전 없음 | SUPPORT / WEAKEN | 소리보다 공기 자극에 방향 반응; 벽 재질 기능은 이 실험만으로 미확정 | STRONG | Optional; 공기/소리 비교에 유용 | Yes, 실제 실행 시 |
| CORE 실험 02 | TEST_CASE02_EXP_02 | 공기/조명 고정; 요철을 따르는 발 자국, 매끈한 면의 옆 탐색 반복; 접촉 압력 증가 없음 | SUPPORT / WEAKEN | 벽은 접촉 탐색 기준일 수 있음; 요철 접촉을 힘 증가로 단정하기 어려움 | STRONG | Optional; 표면 가설 비교에 유용 | Yes, 실제 실행 시 |
| 설비 비교 | TEST_CASE02_ROOM_01 | 지속 약풍 + 날카롭지 않은 얕은 요철 벽 + 일반 조명 | CONTEXT | 반복 공기 전환을 줄이고 접촉 기준을 유지하는 후보 | WEAK | 후보 읽기/선택 Required | Yes |
| 설비 비교 | TEST_CASE02_ROOM_02 | start/stop 공기 + 걸릴 곳 없는 매끈한 벽 + 낮은 조명 | CONTEXT | 벽 접촉을 등반 위험으로 해석하면 그럴듯하나 기본 관찰과 충돌 | WEAK | 후보 읽기/선택 Required | Yes |
| GUARANTEED 정전 즉시 반응 | TEST_CASE02_REACTION_POWER_OFF | 불이 꺼지자 8초 이동 정지; 요철 접촉 유지; 이후 벽 추적 재개 | CONTEXT / SUPPORT | 빛이 이동 시작을 조절할 수 있지만 접촉 행동을 없애지는 않음 | WEAK | 사건 실제 발생 시 자동 표시; 판단 Optional | No; 정전 실제 발생 필요 |
| GUARANTEED 정전 CCTV | TEST_CASE02_POWER_CCTV_OBS | 2분 동안 이동 횟수는 감소하지만 요철 추적/환기 전환 반응은 지속 | WEAKEN / SUPPORT | 어둠이 기본 반응을 제거한다는 가설 약화; 접촉/공기 가설 유지 | MEDIUM | 정전 후 CCTV 재확인 가능; 판단 Optional | No; 정전 활성 + CCTV 열기 |
| GUARANTEED 환기 즉시 반응 | TEST_CASE02_REACTION_VENTILATION | 예기치 않은 첫 환기 정지에 배출구로 향하고 두 번 옆 탐색; 접촉 유지/압흔 증가 없음 | SUPPORT / CONTEXT | 계획되지 않은 전환도 탐색을 유발할 수 있음; 단 한 번의 관찰 | WEAK | 사건 실제 발생 시 자동 표시; 판단 Optional | No; 환기 사건 실제 발생 필요 |
| OPPORTUNISTIC 정전 실험 01 | TEST_CASE02_POWER_EXP01_OBS | 같은 공기 펄스에 회전하지만 밝을 때보다 첫 발 시작이 늦음; 벽 추적 재개 | SUPPORT / CONTEXT | 빛은 반응 시작 지연에 관련될 수 있음; 지연만으로 벽 탐색은 설명 안 됨 | WEAK | Optional; 정전 활성 + EXP01 미사용 + 실제 실행 | No |

Case02 기본 CCTV/EXP02/ROOM02와 환기 반응은 기존 fallback이며 authored entry ID를 만들지 않았다. 환기 사건에는 CCTV/실험 condition 매핑이 **없다**. 그래도 즉시 반응이 보장 채널이므로 CCTV를 모든 사건의 필수 루틴으로 만들지 않는다.

**판단 연결:** Profile+CCTV는 ‘벽 접촉 자체가 해로운가, 탐색 기준인가’를 비교하고 공기 전환 반응을 알려 준다. EXP01은 공기와 소리를, EXP02는 표면과 압력을 분리한다. 이를 설비 설명과 대조하면 ROOM01이 합리적이다. Profile/CCTV의 독립 2개 출처, 한 실험을 택하면 3개, 두 실험을 모두 쓰면 4개 CORE 출처다. EXP01만으로 표면 기능을 확정하거나 EXP02만으로 공기 전환 조건을 확정하지 않는다. 실제 안전성의 장기 증명 또는 미구현 정답 판정으로 확대하지 않는다.

EXP02의 ‘요철을 따라가는 발 자국’은 방향 기준 사용 또는 등반 시도라는 서로 다른 해석이 가능하다. 압력 증가가 없다는 비교만으로 장기 손상/탈출 가능성을 판정하지 않는다. 접촉을 잃었을 때 탐색했다는 Profile과 CCTV의 손상 없음/매끈한 면 탐색을 함께 읽어 현재의 비공격적 해석을 뒷받침한다. EXP01의 공기 반응도 단순 방향 반응인지 불안정성을 키우는지 혼자 확정하지 않는다. 단일 결과에서 나머지 축·안전 판정을 생략할 근거는 없다. 다만 후보가 2개라 한 축으로 빨리 추측하는 난이도 위험은 남으며 실제 첫 플레이로 확인해야 한다.

## 변경한 임시 문구

Profile와 기본 CCTV는 고정된 기존 View에 맞게 압축했다. 핵심 비교 축을 지우지 않고 긴 문단을 짧게 바꿨다. UI 크기나 Scene은 바꾸지 않았다.

| Case/Source | 최종 문구 또는 의미 |
|---|---|
| Case01 Profile | `TEST: metal-support pump cycles preceded strikes; no talk link.` |
| Case01 CCTV | `TEST: strikes cluster at pump starts; vent cycling prompts turn-backs. Lamp sweeps alter travel, not strike timing. Wall tracing continues.` |
| Case02 Profile | `TEST: wall-contact loss precedes searching; no damage recorded.` |
| Case02 CCTV | `TEST: vent cycles prompt turns to the outlet. A paw follows shallow wall ribs; on smooth patches it sweeps sideways. No new damage appears.` |
| Case01 EXP01 절차/결과 | 같은 작은 충격을 금속/완충 지지대로 전달하며 소리/환기는 고정. 금속 지지대에서 타격이 더 많음; 환기 비교는 수행하지 않음 |
| Case01 EXP02 절차/결과 | 지속 약풍과 start/stop 펄스를 비교하며 지지/소리는 고정. 후자에서 되돌아봄이 더 많음; 지지 절연 비교는 수행하지 않음 |
| Case01 EXP03 절차/결과 | 지지 충격/공기 변화 없이 스피커로 펌프 소리만 재생. 잠깐 방향 반응은 있으나 기존 타격 집중은 재현 안 됨 |
| Case02 EXP01 절차/결과 | 고정 노즐의 짧은 공기 펄스와 팬 소리만을 비교; 벽/조명 고정. 공기는 회전 유발, 팬 소리만은 일관된 반응 없음; 벽 재질 기능은 미확정 |
| Case02 EXP02 절차/결과 | 동일 공기/조명 아래 인접 요철/매끈한 패널의 발 자국·압력 비교. 요철 추적/매끈한 면 옆 탐색, 압력 증가 없음; 지속/간헐 공기는 미비교 |

Research Profile/CCTV/실험/정전 반응/조건 본문은 원 관찰과 한계를 유지한 별도 기록형 요약이다. 문장을 그대로 복제하지 않으며 새 결과를 추가하지 않는다. Room 기록은 제출한 설비를 설명하며 결과를 추가하지 않는다. 변경한 기존 Research title은 `Intake record: support and machinery timing`, `Camera 01: pump, airflow and lamp comparison`, `Experiment 01: support comparison`, `Experiment 02: airflow comparison`, `Experiment 03: sound-only comparison`, `Case 02 intake: wall contact and searching`, `Case 02 experiment 01: airflow and sound cues`다. 기존 Source/entry ID와 발견 규칙은 유지했다. 정확한 영어 절차/결과/Room/조건 원문은 두 `.tres`와 이번 git diff에서 확인할 수 있다.

## 사건 관찰의 역할과 접근 시점

| 경로 | 즉시 반응 | CCTV condition | Experiment condition | 기본 판단 |
|---|---|---|---|---|
| 사건 없음 | 없음 | 없음 | 없음 | CORE로 비교 가능 |
| 정전이 EXP01 실행 뒤 발생 | 8초 일시 정지/접촉 유지 | 재확인 시 2분 지속 패턴 | EXP01 재실행 불가; 소급 없음 | CORE로 가능 |
| 정전이 모든 실험 뒤 발생 | 동일 | 잔여 0이어도 재확인 가능 | 없음 | CORE로 가능 |
| 정전 활성 후 미사용 EXP01 실행 | 동일 | 재확인 가능 | 시작 지연 보조 관찰 획득 | CORE + 선택적 보조 |
| 환기 사건 발생 | 단일 전환의 방향/탐색/압흔 반응 | authored 없음 | authored 없음 | CORE + 즉시 반응 |

정전 즉시 반응은 **발생 직후의 순간**, CCTV는 **시간이 지난 지속 패턴**, 실험 조건은 **통제 자극에 대한 시작 지연**을 다룬다. 벽 접촉 지속이라는 공유 기준선은 의도적 연결이다. 세 경로를 독립적인 필수 정답 세트로 세지 않는다. 실험 조건에만 있는 지연 비교는 판단의 필수 축이 아니다.

정전은 ‘빛이 이동 시작을 조절하는가’라는 새로운 의심을 만들고, CCTV는 ‘어둠이면 접촉/공기 반응이 사라진다’는 해석을 약화한다. 조건 실험은 지연 가설을 제한적으로 강화한다. 환기 반응은 ‘예기치 않은 전환도 탐색을 유발하는가’를 묻게 하지만 단 한 번 관찰의 한계를 명시한다. 어느 관찰도 특정 Room을 추천하지 않는다.

8초·2분은 임시 authored 관찰 기록의 시간 범위다. 실제 대상 이동/정지 시뮬레이션, 새로운 Timer, 2분 대기 조건을 구현했다는 뜻은 아니다. 기존 조건 관찰 표시 API에 텍스트만 전달한다.

정상 두 Case 흐름에서 Case02 CCTV 최초 진입은 opportunity 1이고 현재 임계값은 2~4다. **따라서 ‘첫 실험 이전에 사건’은 현재 정상 버튼 동선만으로 생기지 않는다.** 별도 developer fixture에서 실제 Case01 실패/Case02 인계 후 기존 후보의 opportunity를 한 번 선행시키고 실제 CCTV 진입으로 사건을 발생시켰다. 범위·제품 RNG·Main은 바꾸지 않았다. 정상 early 경로(첫 실행 뒤 사건), all-used 경로(Containment에서 사건), no-event 경로는 실제 버튼 동선으로 확인한다.

## 검증 방법과 제한

검증 소스·변경 전 사본·로그·캡처·JSON은 `.godot/verification/step39/`에만 있다. 이 영역은 Git 제외이며 제품 실행은 로드하지 않는다. 이전 검사 파일은 편집하지 않고 새 사본에서 텍스트 기대값과 실제 스크롤/클릭 동작만 조정했다. 테스트 결과를 게임 Resource에 저장하지 않는다.

새 `evidence_validation.gd`는 아래 26경로를 headless/Windows GPU 각각 세 해상도에서 실행한다. Source 표시·발견/Log ID·한 View·스크롤·잔여량·조건 접근·Pending·기존 Outcome·원본 Resource를 검사한다. 의미·추론·공정성은 위 Evidence Map에서 수동 감사한다. 영어 키워드 점수, 자연어 판정, 자동으로 정답 후보를 고르는 테스트는 없다. 테스트가 선택하는 Room은 감사자가 정한 확인 대상이다.

- 무사건 12경로: Case01 `[]`, `[01]`, `[02]`, `[03]`, `[01,02]`, `[03,01]`, `[03,02]`; Case02 `[]`, `[01]`, `[02]`, `[01,02]`, `[02,01]`.
- 사건 12경로: Case01 ROOM01 정전/ROOM03 환기 실패 인계 × 임계값 2/3/4 × Case02 EXP01→02/02→01.
- 첫 실험 전 fixture 2경로: 정전/환기 각각 선행 opportunity 1회 후 실제 CCTV/EXP01→02.

26 × 3해상도 × 2백엔드 = 156경로다. 이 중 12회는 첫 실험 전 developer fixture이며 정상 UI 경로로 포장하지 않는다. 기존 Journey A/B/C는 무실험 인계, 환경/CCTV/실험/Log/가설, 과거 Archive 왕복을 실제 마우스 입력으로 검사한다. 키를 한 글자씩 입력하는 사람의 속도나 첫 플레이어의 이해도는 측정하지 않았다.

무사건 12패턴은 Main Scene에 기존 Case의 deep copy 1개만 넣는 single-Case fixture다. 버튼과 Runtime은 실제 제품 구현을 사용하며, 이 fixture의 마지막 제출에서는 handoff가 없다. 정상 두 Case 순서/실패 인계/hidden resolution은 기존 Journey와 별도 사건 12패턴에서 확인한다. Case01을 single-Case fixture로 제출한 것만으로 SUCCESS 판정이 실행됐다고 주장하지 않는다.

최종 실행 수치·변경 범위 검증 결과는 아래 종료 보고에 기록한다.

Journey B의 최종 Log 본문/ID/버튼/가설 제공 텍스트는 2,185자(이전 Step38 1,825자)다. 원문 복제 초안 2,336자에서 별도 기록 요약으로 151자를 줄였다. 화면 밖 스크롤 본문도 포함하고 Main 헤더는 제외한 측정이므로 한 화면에 동시에 보이는 글자 수가 아니다. 문구는 늘었고 읽기 비용은 남는다. 엔트리 수는 격리 확정 전 7개, 확정 후 8개로 그대로이며 새 중복 행을 추가하지 않았다. 의미 있는 비교를 제공하는 것과 정보 밀도를 낮추는 것은 별개로 후속 사람 플레이에서 평가해야 한다.

## 요청한 70개 종료 항목

| 번호 | 항목 | 결과 |
|---|---|---|
| 1 | 작업 전 Git | 위 HEAD, master→origin/main, clean. 커밋·push하지 않음 |
| 2 | Step38 재확인 | F01 판단 연결 부족, F02 조건 실험 시점 의존, F03 환경 관찰 중복을 실제 코드/콘텐츠에서 확인 |
| 3 | Case01 Evidence Map | 위 표: CORE 5 Source + Room 3 설비; 수신 환경 관찰 없음 |
| 4 | Case02 Evidence Map | 위 표: CORE 4 Source + Room 2 + Guaranteed 3 관찰 + Opportunistic 1 |
| 5 | Case01 CORE | 지지 구조 자극/환기 전환의 두 축; 소리만·조명만 가설에 부정 비교 |
| 6 | Case02 CORE | 벽 접촉 탐색 기능/공기 방향 반응; 소리만·접촉=손상 가설에 부정 비교 |
| 7 | Case01 CORE 판단 | Profile+CCTV만으로 ROOM02의 두 축 비교 가능. 통제 실험은 확신 강화; 무실험 증거는 더 약함 |
| 8 | Case02 CORE 판단 | Profile+CCTV로 ROOM01이 합리적. 구현된 Outcome는 없으므로 실제 정답 검증이라고 주장하지 않음 |
| 9 | 독립 Source 수 | Case01 최소 2, 유용한 실험 1개 포함 3, 주 비교 실험 모두 포함 4; 총 5. Case02 최소 2/실험 1개 3/모두 4. 복제 Research는 추가로 세지 않음 |
| 10 | 의미 있는 오답 | Case01 방음/어둠·절연 후보는 한 축에서 그럴듯함. Case02 매끈한 벽/낮은 조명은 접촉을 위험으로 해석하면 그럴듯하나 CORE와 대조 가능 |
| 11 | 거짓 단서 | 관찰을 거짓으로 작성하지 않음. 후보의 실제 속성과 반응의 원인 해석을 구분 |
| 12 | 부정 증거 | Case01 소리만으로 타격 미재현, 램프와 타격 시점 무연결; Case02 팬 소리만 반응 없음, 손상/압력 증가 없음 |
| 13 | 한 문장 정답 | Room 번호/추천 없이 두 축을 서로 다른 출처와 설비 설명에서 대조. 단일 실험의 미비교 축을 명시 |
| 14 | Profile 변경 | 위 정확한 영어 원문 두 개; 식별/분류 ID는 유지 |
| 15 | CCTV 변경 | 위 정확한 기본 영어 원문 두 개; Case02 정전 후속은 2분 지속 비교로 변경 |
| 16 | Experiment 변경 | 총 5개 기존 절차/결과 변경, 조건 EXP01 보조 지연 관찰 변경; 실행 로직 변경 없음 |
| 17 | Research 변경 | 기존 원 Source와 같은 의미의 별도 요약, 7개 기존 title 정비, Room은 제출 설비/미판정 문맥 유지. 새 entry 없음 |
| 18 | Disturbance Reaction | 정전 직후 8초 정지; 환기 첫 전환 탐색. 사건 직후의 제한된 반응 |
| 19 | CCTV Condition | 정전 후 2분 동안 접촉/공기 반응이 유지되는지 후속 비교; 환기는 매핑 없음 |
| 20 | Experiment Condition | 정전 아래 통제 공기 펄스의 시작 지연. 기회가 있을 때만 얻는 보조 자료 |
| 21 | 세 관찰 중복 | 순간/지속/통제 비교로 차별화. 접촉 지속 기준선 공유는 허용하며 독립 필수 3개로 과장 안 함 |
| 22 | Guaranteed 정의 | 실제 사건 뒤 실험 횟수/순서와 무관한 최소 관찰 채널. 정전은 즉시+CCTV, 환기는 즉시 반응 |
| 23 | Opportunistic 정의 | 정전 활성·미사용 EXP01·실제 실행 모두 필요. 조건 관찰을 놓쳐도 필수 축은 CORE에 있음 |
| 24 | 모든 실험 선사용 | 잔여 0, 조건 실험 없음, 즉시 반응/정전 CCTV 접근 가능. 환기는 즉시 반응만; 무료 재실행 없음 |
| 25 | 사건 선발생 | developer fixture에서 실제 CCTV 후 EXP01의 보조 결과 확인. 현재 정상 흐름의 earliest는 첫 실험 실행 뒤 |
| 26 | 사건 없음 | 두 Case 무사건 12경로로 CORE/Log/Containment 진행 확인 |
| 27 | 조건 실험 없이 해결 | Case01 기존 정답 축과 Case02 콘텐츠 판단 축은 기본 출처에 있음. 조건 실험은 보조 지연 비교뿐 |
| 28 | 무료 재실험 | 미구현; 기존 ID 중복 실행 거절 유지 |
| 29 | 소급 결과 | 미구현; 사건 전에 실행한 EXP01에 나중에 조건 결과 추가하지 않음 |
| 30 | experiment_limit | 두 Case 모두 2; 배열 개수/순서/ID도 유지 |
| 31 | Condition 강도 | 정전 CCTV MEDIUM, 즉시/실험 조건 WEAK; 특정 Room 판정 또는 CORE 대체로 사용 안 함 |
| 32 | 정답 노출 | Profile/CCTV/실험/조건 본문에 정답 Room/추천 없음. 기존 hidden Outcome는 UI에 노출하지 않음 |
| 33 | 새 가설 | 조명과 반응 시작 지연, 예기치 않은 환기 전환과 탐색이라는 의심을 제공 |
| 34 | 가설 강화/약화 | 접촉·공기 축 유지, 어둠이면 반응 소실 가설 약화. 자동 Working Hypothesis 업데이트 없음 |
| 35 | 단순 텍스트 증가 | 새로운 비교 기준/시간 범위/한계를 추가했다. 문구 분량도 증가했지만 새 엔트리나 같은 의미의 관찰만 늘리지 않음 |
| 36 | Log 중복 | Source와 같은 관찰/한계를 요약해 설명 불일치 제거. 같은 행 수, 기존 획득 순서 유지. 화면과 Log의 의도적 반복은 남음 |
| 37 | CORE 접근 | Profile/CCTV 정상 표시, 미선택 실험 결과는 표시하지 않음. 사건 없이 선택 실험 결과/Log 접근 가능 |
| 38 | Containment 전 | 실행한 Source를 Log에서 다시 읽을 수 있음. 사건 후 CCTV 재확인은 기존 동선 사용; 미발견 결과는 누설 안 함 |
| 39 | Working Hypothesis | 자유 입력/편집/삭제/세션 보존 그대로. 가설 추천/평가/자동 입력 없음 |
| 40 | Hidden Resolution | Case01 다음 Case 인계 시 기존 hidden resolution, current Case02 Pending 경계 유지 |
| 41 | Archive | 획득한 authored ID와 개인 메모만 기존 merge 경계로 보존; 미획득/실패 원인을 자동 연결하지 않음 |
| 42 | fallback | Case02 CCTV/EXP02/ROOM02/환기 반응은 기존 fallback. 원문은 현재 Log에서 읽지만 새 authored Archive 항목을 만들지 않음 |
| 43 | 검증 구조 | 위 26경로×6실행 + 기존 A/B/C + normal/state/edge/debug downstream 회귀 |
| 44 | 자연어 자동 판정 | 미사용; 테스트는 원문과 authored/fallback 표시의 정확성/출처·상태·레이아웃 검사, 의미 판단은 수동 Evidence Map |
| 45 | Runtime metadata | 새 enum/필드/Resource metadata 없음. CORE 등은 문서 분류 |
| 46 | 정상 Case01 | 무실험/각 단독 실험/유용한 두 실험/EXP03 포함 경로 및 실제 두 Case 인계 검증 |
| 47 | 정상 Case02 | 무실험/각 단독/두 순서 경로, 마지막 ROOM01 제출 Pending 확인. 미구현 SUCCESS를 검사하지 않음 |
| 48 | 덜 유용한 실험 | Case01 EXP03은 직접 Room 선택보다 간접적이나 소리 가설을 약화. CCTV+남은 한 실험으로 비교 유지 |
| 49 | Before-Experiment | 정전/환기 각 fixture; 실제 첫 실험 전에는 정상 opportunity 순서상 도달 불가라고 구분 |
| 50 | After-all-Experiments | 임계값 4에서 Containment 진입 후 사건; 조건 결과 없음/환급 없음/보장 채널 유지 |
| 51 | No-Disturbance | Case01 SUCCESS 인계 및 단독 Case fixtures에서 no-event 확인 |
| 52 | correct outcome 불변 | Case01 ROOM02 SUCCESS, ROOM01/03 FAILURE 및 incident ID 원본과 동일; Case02 Outcome 없음 유지 |
| 53 | 반복 Recheck 위험 | 현 UI는 추가 authored 관찰 유무를 진입 전에 알려주지 않아 헛왕복 가능. 반복해도 새 기회/무료 실험/기록 증가 없음 |
| 54 | 다양성 | 현재 환기는 reaction만, 정전은 후속/선택 실험이 있어 최소한의 역할 차이 확보. 다른 사건을 전부 CCTV 필수로 만들 필요 없음 |
| 55 | CONTENT | 기존 placeholder를 비교 가능한 관찰·절차·후보 설비로 교체, 필수 사실을 CORE로 배치 |
| 56 | GAME DESIGN | 실험 순서에 따른 선택 관찰 상실은 유지. 필수 정보 의존은 제거했지만 반복 탐색 가치/최소 정보량은 사람 플레이 검증 과제 |
| 57 | CODE | 제품 로직 오류를 발견하지 않음; 텍스트 기대값/스크롤 입력을 새 테스트 사본에서만 조정 |
| 58 | Main | 수정 없음; 1,244줄/66함수 기존 구조 유지 |
| 59 | State | 6개 모두 수정 없음 |
| 60 | View | Script/Scene 모두 수정 없음; 스크롤/레이아웃/임시 선택 복원 정책 변경 없음 |
| 61 | Resource 불변성 | 디스크의 의도한 텍스트 변경과 실행 중 mutation을 구분. non-text 구조는 변경 전과 같고 실행 전후 원본 deep content/SHA 비교 |
| 62 | 전체 회귀 | 198개 모두 PASS: headless 117 + Windows GPU 81. 최종 모든 로그 SHA/입력 signature 일치 |
| 63 | debug downstream | 독립 debug fixture의 Monitoring/Incident/Broadcast/Result/confirmation/playback 검사; 정상 루트와 구분 |
| 64 | 세 해상도 | 1920×1080, 1280×720, 1024×768. 기존 keep의 4:3 letterbox, 기준 좌표 1920×1080 유지 |
| 65 | 파싱/실행 | 제품 GDScript 38개 check-only, editor import 오류/경고 0, headless/native 기본 Main 실행 PASS. F5 키 자체는 자동 조작하지 않음 |
| 66 | 발견/해결 | 고정 Profile/CCTV의 긴 초안은 문구 압축. 기존 테스트의 짧은 본문/전체 행 한 화면 가정은 새 사본에서 실제 스크롤/도달 검사로 수정. 별도 Research 요약 기준은 콘텐츠로 보존. 개발용 helper 연결 오류 해결; 제품 코드 오류 없음 |
| 67 | 실제 변경 | 두 Case .tres 텍스트, README 링크/요약 수정; 이 문서 1개 추가. 삭제 없음 |
| 68 | 기존 미커밋 | 시작 clean; 이전 제품/검증 파일 보존 비교. 커밋·push하지 않음 |
| 69 | 남은 문제 | Case02 실제 Outcome 없음, 인간 추리 이해도 미검증, 작은 창 긴 본문 스크롤 비용, fallback Archive 제외, Recheck 정보 유무 안내 없음 |
| 70 | 다음 단계 | 새 시스템보다 두 Case 첫 플레이 테스트: 선택 이유/잘못된 가설/단독 실험 이해/사건 없이 판단/읽기 비용 기록 후 콘텐츠 수정 여부 결정 |

## 범위와 미구현 항목

제품 폴더/Scene 구조는 그대로다. `resources/cases/`의 두 기존 파일만 Gameplay 콘텐츠 변경이다. `docs/step39_case_evidence.md`와 README는 개발 문서다. 검증 자료는 `.godot/verification/step39/`에 격리했다.

```text
cap/
├── project.godot / README.md / .gitignore / .gitattributes
├── assets/                         기존 .gitkeep
├── resources/cases/                기존 두 Case .tres 텍스트 수정
├── scenes/main/                    Main Scene 보존
├── scenes/views/                   주요/보조 UI Scene 보존
├── scripts/main/                   Main Script 보존
├── scripts/runtime/                6 State 보존
├── scripts/data/                   16 Resource Script 보존
├── scripts/views/                  View/common Script 보존
└── docs/
	├── step38_core_loop_audit.md    보존
	└── step39_case_evidence.md      추가
```

기존 상위 Main이 View를 생성하고 요청 signal을 승인하며, Runtime이 실행/획득 상태를 유지하고 View가 Resource/Snapshot을 표시한다. 이번 단계에서는 이 책임 분리나 화면 전환 구조를 수정하지 않았다. Room의 설비 설명은 authored 비교 정보이며 실제 공기·접촉 물리 시뮬레이션을 추가한 것이 아니다. 시설 조건을 근거로 Room 정답을 동적으로 바꾸지도 않는다.

free rerun, refund, limit 변경, retroactive observation, dynamic correct room, automatic hypothesis, evidence scoring/metadata/UI, hint/AI hint, Manager/Rule Engine, Severity/MAJOR Incident, automatic Broadcast, Case03, Campaign, Save/Load, final UI/폰트/에셋은 추가하지 않았다. 기존 기능을 이번 단계에서 다시 구현하거나 삭제하지 않았다.

## 최종 실행 및 변경 범위 기록

Godot `4.7.1.stable.official.a13da4feb`, Windows PC, AMD Radeon RX 6800의 OpenGL Compatibility로 완료했다.

| 검증 | 최종 결과 |
|---|---|
| 전체 실행 검사 | **198 / 198 PASS**; headless 117개(제품 GDScript 38개 check-only 포함), native GPU 81개 |
| 최종 로그 | exit 0, ERROR/SCRIPT ERROR/Parse Error 0; 각 로그 SHA-256과 pass certificate 일치 |
| 경계 검사 경고 | 잘못된 ID/빈 Resource/중복 요청 등을 의도한 fixture 경고 총 1,172개; 각 검사 예상 수와 정확히 일치. 예상 밖 경고 없음 |
| Editor import | 최종 콘텐츠의 headless editor `--import`: exit 0, 오류 0, 경고 0 |
| 새 증거 경로 | 6실행 × 26패턴 = 156경로; 정상 첫 실험 전 사건으로 오인하지 않도록 developer fixture 12회를 구분 |
| 화면/입력 | 1920×1080, 1280×720, 1024×768; 실제 Godot View 마우스 이벤트, wrap/scroll/행 선택/상태 잠금/Dismiss/Log·Archive 복귀 확인 |
| 수동 화면 확인 | 최종 native 캡처 12개 직접 확인: Profile/기본·조건 CCTV/결과 스크롤 끝/Room/환기 Overlay/Log·가설/Archive. 여러 조건의 긴 스크롤 끝 이미지는 developer fixture |
| 해상도 보존 | project.godot SHA 보존; 1920×1080 viewport, 1280×720 기본 창, canvas_items, 기본 keep/resizable 유지. 1024×768 창의 viewport 캡처는 letterbox 제외 1024×576 |
| Resource 보존 | non-text 구조/배열/ID/limit/Outcome 원본 비교, 실행 중 원본 deep content 비교 PASS; 최종 suite 입력 signature도 전체 제품/검사 입력이 실행 전후 동일함을 확인 |
| 기존 파일 | 기준선 100개 중 **97개 SHA 동일**. README의 기존 이력은 삽입 구간을 제외하고 동일 |
| 이전 검증 | 이전 GDScript/PowerShell/Scene 소스 **2,346개 SHA 동일** |
| Git 범위 | README + Case01/02 수정, 이 문서 1개 추가, 삭제 0. `git diff --check` PASS, 의도하지 않은 변경 없음 |
| Git 상태 | HEAD/브랜치 유지. 커밋·push하지 않음 |

두 `.tres`의 diff는 합계 **44개 기존 텍스트 행 교체**다(Case01 24, Case02 20). README는 Step39 요약/링크 12행 삽입이다. 모든 제품 `.gd`/`.tscn`/`.uid`와 설정·기존 Step38 보고서는 보존했다. 새 검증 코드와 캡처는 Git 제외 영역이며 제품 변경 파일 수에 포함하지 않았다.

최종 suite 입력 SHA-256: `5B16DBC2C8C51922C4F4C45DF4C0716A463EFC45ECE73B6E633453F0A6145CF7`.
`validation-results.json`, `final-integrity.json`, `scope-audit.json`, `visual-review.json`과 개별 `.log`/`.pass.json`에서 검사별 결과·해시·fixture 구분을 확인할 수 있다.

현재 개발 환경에서 재실행:

```powershell
& '.godot/verification/step39/run_validation.ps1'
& '.godot/verification/step39/editor_import.ps1'
& '.godot/verification/step39/scope_audit.ps1'
```

검증 자료는 현재 로컬 workspace용으로 보존했으며 Git 제외이므로 새 clone에 자동 포함되지 않는다. F5 키 자체나 사람의 첫 플레이 이해도/소요 시간은 자동 검사하지 않았다. 다음 작업은 사람이 두 Case를 읽고 선택한 이유, 잘못된 가설, 놓친 보조 관찰, 스크롤/재확인 비용을 기록하는 콘텐츠 플레이 테스트가 적합하다.
