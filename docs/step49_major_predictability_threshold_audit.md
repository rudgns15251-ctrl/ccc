# Step49 — Major Predictability / Threshold Audit

2026-10-06 · Godot 4.7.1.stable.official.a13da4feb · Windows PC · GDScript · GL Compatibility.

**추천은 KEEP_MAJOR_1이다. 이번에는 제품 규칙을 변경하지 않았다.** Range1~2는 readiness variation을 만들고 노출 손실도 작아 후속 A/B 후보로 남길 가치가 있지만, 세 seed family 모두 Stage concentration과 source 기억 거리를 개선하지 못했다. 고정2는 규칙을 한 기회 늦추고, 2~3은 노출·최종 미해결 비용을 더 키웠다. 현재는 F01을 defer하고 F07-B의 명시적 종료 책임/Run disposition 설계를 먼저 진행하는 선택 C를 권고한다. 실제 종료 구현은 별도 요구·정책 확정 후 수행한다.

아래 CURRENT만 현재 제품 동작이다. FIXED_2/RANGE_1_2/RANGE_2_3/FIXED_3은 ignored verification fixture에서만 실행한 비교 모델이다. Simulation PASS를 제품의 새 threshold 적용 또는 전체 legacy regression PASS로 표현하지 않는다.

## 작업 전 조사와 제품 보호

시작 Git status는 ` M docs/step39_case_evidence.md` 1개였다. 폴더 트리 두 줄의 기존 공백→탭 편집이며 이번 작업에서 손대지 않았다. HEAD `d6d9e4efe625d1688d475e326f8c723d357540a5`, local `master` → upstream `origin/main`, staged0. Step46/47/48은 이 커밋에 이미 포함되어 있다. 저장소와 상위 경로에 적용할 AGENTS.md는 없었다.

추적 파일115개, Scene15개, 제품 GDScript40개, Case Resource3개, runtime State7개, read model1개, Autoload0을 조사했다. project.godot/Main Scene/Script/실제 Case sequence/UI 설정, README/Step45 정책/Step46 Snapshot/Step47 ordering/Step48 보고서·144 matrix·318개 인증 구조, Candidate/Response/Snapshot 원본과 checkpoint/handoff/final boundary를 읽었다. 318개 과거 인증은 historical core268(과거 checkpoint 호환 fixture 포함)+actual Step48 product50으로 구성되어 있으며 이번204개 새 실행과 합산하지 않는다.

1920×1080 logical UI, 초기1280×720, canvas_items/keep/resizable, GL Compatibility, configured `scenes/main/main.tscn`, Case01→02→03을 유지한다. 제품 파일100개와 기존 검증 source/Scene/UID/JSON9631개의 SHA256이 시작 baseline과 같다. Main은1714줄/93함수, 증가0이다.

이번 신규 변경은 README 요약과 이 보고서뿐이다. 제품 Script/Scene/Resource/State/read model/project 설정 변경0, 제품 test seam0, 삭제0, stage0, commit/push0. 기존 Step39 편집과 Step46~48 구현을 보존했다.

## 현재 코드의 readiness와 presentation

Main 상수는 `PROTOTYPE_DISTURBANCE_THRESHOLD = Vector2i(2,4)`와 `PROTOTYPE_MAJOR_THRESHOLD = 1`이다. `_ready()`에서 `_event_rng.randomize()`를 호출한다. `_try_resolve_current_pending()`의 유효 hidden FAILURE 기록 시 D를 `_event_rng.randi_range(2,4)`로 한 번 추첨하고 M=1을 Candidate에 전달한다. State 함수의 기본 인자3은 이 실제 Main 경로의 값이 아니다.

`_try_process_failure_event_opportunity()`가 고유 첫 CCTV entry/승인된 고유 EXP Run/첫 CONT entry만 센다. Major count를 D count/표시보다 먼저 증가시켜, 새 D의 같은 action은 자기 M count에 기여하지 못한다. `FailureEventCandidateState.advance_major_opportunity()`는 실제 D가 표시된 과거 source 후보만 threshold까지 증가시킨다. Next/Confirm 자체는 opportunity가 아니다.

`_try_present_ready_failure_event()`가 shared credit와 active View/Runtime/content/boundary를 검사하고, `_try_present_oldest_actionable_event()`가 등록 순서상 현재 actionable인 하나만 표시한다. CLOSED에서는 표시0. unready/invalid/nonpresentable은 retain+skip. 표시 성공 때만 credit CLOSED. 실제 완료 Response의 후보 제거는 기존 정상 계약이며, 남은 후보를 삭제·가짜 완료 처리하지 않는다.

Step48 checkpoint를 그대로 사용한다: CCTV/EXP는 내용을 실제 표시한 뒤 Next에서 고유 read credit 승인, CONT entry는 기존 OPEN일 때 표시 가능, Confirm은 credit만 승인, enabled CONT Next에서 handoff 전 표시 가능. Dismiss/Resume/Log/Archive/Recheck/idle은 credit이 아니다. final Case03 Confirm은 credit을 열 수 있으나 Next disabled이므로 자동 drain/Outcome/종료가 없다.

`TestSequenceDispositionSnapshot`은 getter fact 복사/분류만 한다. 실제 Run End/Settlement를 수행하지 않으며 마지막 Pending은 `UNRESOLVED_SUBMISSION`이다. Debug Monitoring/Incident/Broadcast는 normal gate·threshold audit에서 분리했다.

## 공정한 비교 fixture와 seed

CURRENT는 실제 configured Main Scene/제품 Main Script를 사용한다. 대안은 Scene에 test-only `policy_main.gd` subclass를 부착한다. 상속한 `_try_resolve_current_pending()`가 제품의 판정·D RNG·후보 등록을 모두 수행한 직후, 새로 생성된 메모리 복제 Candidate의 Major threshold 한 필드만 지정한다. 그 뒤 gate/order/opportunity/presenter/response/Runtime/Archive/Snapshot은 실제 제품 코드를 그대로 실행한다. threshold의 생성 이후 불변을 모든 버튼 timeline에서 검사했다. 제품 Main 상수를 반복 수정·복원하지 않았다.

각 Journey는 authored Resource deep clone을 사용한다. D threshold/Room/outcome/실험량은 정책 간 동일하다. D RNG를 원하는2~4 조합을 생성하는 deterministic seed로 준비하고, Major range에는 별도 RandomNumberGenerator를 사용한다. 제품 D RNG의 최종 state·실제 후보 D 값·hidden Resolution·Case03 Pending이 paired CURRENT와 같음을 확인했다. Major RNG는 후보 생성 때만 한 번 호출하고, 매 opportunity/Resume에 재추첨하지 않는다.

기본 seed `490001 + D01*10000 + D02*1000`은 EXP 사용량에 의존하지 않는다. 동일 outcome/D group의9개 실험 조합에서 같은 source threshold가 유지된다. 후보1/2는 독립 연속 draw이며 정책 간 같은 seed를 사용한다. 범위형은 기본 family 외 offset100000/200000을 추가했다. 각 family의24개 고유 실패 draw 위치가 실험9조합에 재사용되어216개 Candidate record를 이룬다. 따라서216개를 독립 random 표본216개로 부르지 않는다. 범위형 각 정책 총432 Journey/648 Candidate record이며 독립 배치 위치는72개다.

별도64 deterministic seed×후보2 draw로 양 끝값 다양성과 같은 seed 재현성도 검사했다. RNG 호출을 새로 설계하거나 테스트 빈도를 실제 플레이어 확률로 해석하지 않았다.

기본 matrix는 정책마다 FF81/FS27/SF27/SS9=144 Journey다. D01/D02 각각2/3/4(실패 source만 사용), E02/E03 각각0/1/2, E01=1을 사용한다. Room은 Case01 F→Room01/S→Room02, Case02 F→Room02/S→Room01이다. 같은 Case에서 선택한 실험들을 Run하고 draw를 기다린 뒤 마지막 실제 표시 결과를 Next로 완료한다. Run2개가 credit2개를 뜻하지 않는다. 각 결과마다 Next를 누르는 다른 플레이 습관은 이 matrix 밖이다.

## 측정 정의와 censoring

- D→M readiness eligible: D 실제 표시 action 이후부터 source 후보가 처음 ready로 관찰된 action까지의 승인 opportunity 수. 미도달은 별도로 censored 처리한다.
- D→M presentation eligible/credit/meaningful: D 표시 action 제외, M 표시 action 포함 구간의 승인 opportunity/새 token/기존 meaningful action 수. 실제 M 표시된 후보만 분모다.
- Strict gap: consecutive Event action 사이의 기존 meaningful action, 양 끝 제외. Causing gap: 다음 Event causing action의 기존 meaningful도 포함. Credit gap: 이전 Event action 제외/다음 causing action 포함 승인 token 수.
- `max_stage_share`: 실제 M의 return/current 작업 Stage(CCTV/EXP/CONT) 중 최대 비율. 클릭한 버튼의 소속 Stage와 다를 수 있어 별도 checkpoint 표를 제공한다.
- Cross-Case delay: D가 실제 표시된 current Case와 M current Case의 차이. source age는 원인 Case와 M current Case 차이이며 서로 다른 지표다.
- 마지막 후보 phase는 제품 Step46 Snapshot을 oracle로 읽는다. ready-but-unshown은 MAJOR_READY이며, D만 표시되고 M 미표시에는 DISTURBED_NOT_READY도 포함한다. UNDISTURBED는 별도다.

현재 baseline의 이벤트·spacing·Archive·Snapshot facts는 Step48와144개 모두 일치했다. 프로세스마다 달라지는 `runtime_instance_id`만 Snapshot 비교에서 제외하고, 새 프로세스 내부 Runtime identity 보존은 실제 회귀로 확인했다.

## Table 1 — Policy Summary (각144 Journey, base family)

| 정책 | M 규칙 | D | M | B | D+M | 미해결 record | M-ready 잔여 | D 이후 다음 Case M | Max Stage share |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| CURRENT | 1 (제품) | 159 | 88 | 88 | 247 | 128 | 43 | 36 | 40.91% |
| FIXED_2 | 2 (비교) | 143 | 86 | 86 | 229 | 130 | 2 | 72 | 41.86% |
| RANGE_1_2 | 1~2 (비교) | 156 | 87 | 87 | 243 | 129 | 24 | 48 | 44.83% |
| RANGE_2_3 | 2~3 (비교) | 142 | 80 | 80 | 222 | 136 | 3 | 68 | 43.75% |
| FIXED_3 | 3 (참고) | 140 | 61 | 61 | 201 | 155 | 7 | 57 | 59.02% |

## Table 2 — Predictability

숫자는 min/median/max와 실제 도달 분모다. readiness 미도달을 threshold 값으로 보간하지 않았다.

| 정책 | D→M ready eligible | D→M shown eligible | D→M credit | normal meaningful | ready 미도달 |
| --- | --- | --- | --- | --- | --- |
| CURRENT | 1/1/1 (n=131) | 1/1/2 (n=88) | 1/1/2 (n=88) | 1/1.5/2 (n=88) | 28 |
| FIXED_2 | 2/2/2 (n=88) | 2/2/3 (n=86) | 1/2/3 (n=86) | 1/2/4 (n=86) | 55 |
| RANGE_1_2 | 1/1/2 (n=111) | 1/1/3 (n=87) | 1/2/3 (n=87) | 1/2/4 (n=87) | 45 |
| RANGE_2_3 | 2/2/3 (n=83) | 2/2/4 (n=80) | 1/2/3 (n=80) | 1/2/4 (n=80) | 59 |
| FIXED_3 | 3/3/3 (n=68) | 3/3/4 (n=61) | 1/3/3 (n=61) | 2/3/4 (n=61) | 72 |

| 정책 | readiness 분포 | shown eligible 분포 | credit 분포 | ready→표시 추가 eligible |
| --- | --- | --- | --- | --- |
| CURRENT | 1:131 | 1:80, 2:8 | 1:52, 2:36 | 0:80, 1:8 |
| FIXED_2 | 2:88 | 2:74, 3:12 | 1:14, 2:48, 3:24 | 0:74, 1:12 |
| RANGE_1_2 | 1:86, 2:25 | 1:57, 2:27, 3:3 | 1:39, 2:42, 3:6 | 0:78, 1:9 |
| RANGE_2_3 | 2:63, 3:20 | 2:53, 3:23, 4:4 | 1:12, 2:37, 3:31 | 0:67, 1:13 |
| FIXED_3 | 3:68 | 3:49, 4:12 | 1:4, 2:12, 3:45 | 0:49, 1:12 |

현재 ready 도달131개 모두 distance1이다. 표시88개 중80개(90.91%)는 D 뒤 opportunity1에서 M,8개는2에서 M이다. 하지만 D159개 중 M 미표시는71개이고, final M-ready43개는 실제 표시되지 않았다. 따라서 “D 후 다음 행동에 반드시 M”이라는 unconditional 공식은 성립하지 않는다. M88개 중 credit1은52개/credit2는36개다. 첫 새 credit action 자체가 M인 D는16개이며, Confirm처럼 credit만 만들고 후속 Next에서 표시하는 경우와 구별한다.

## Gate masking / paired checkpoint 비교

같은 logical checkpoint는 current Case/return Stage/누적 eligible ordinal/버튼 이름·라벨이 모두 같은 경우다. runtime instance ID나 이벤트 때문에 늘어난 raw action index로 비교하지 않는다.

| 정책 | CURRENT와 같은 M checkpoint | 달라진 M checkpoint | CURRENT M 소실 | 새 M | threshold 달라도 같은 checkpoint |
| --- | --- | --- | --- | --- | --- |
| CURRENT | 88 | 0 | 0 | 0 | 0 |
| FIXED_2 | 8 | 78 | 2 | 0 | 8 |
| RANGE_1_2 | 65 | 22 | 1 | 0 | 2 |
| RANGE_2_3 | 6 | 74 | 8 | 0 | 6 |
| FIXED_3 | 0 | 61 | 27 | 0 | 0 |

FIXED2의8개는 threshold1→2인데 실제 M checkpoint가 그대로다. Range1~2의 same65개 전체를 gate masking이라고 부르지 않는다. 그 중 실제 threshold가 달라진 채 같았던 것은2개다. M를 다음 Case로 넘기는 효과는 Table6에 별도로 나타낸다. threshold 차이가 전부 gate에 가려진 것도, 전부 새로운 표시 다양성을 만든 것도 아니다.

## Table 3 — Final Boundary Cost

| 정책 | 미해결 Journey | UNDISTURBED | DISTURBED_NOT_READY | MAJOR_READY / ready-but-unshown | 총 record | CURRENT 대비 |
| --- | --- | --- | --- | --- | --- | --- |
| CURRENT | 113 | 57 | 28 | 43 | 128 | +0 (+0.00%) |
| FIXED_2 | 113 | 73 | 55 | 2 | 130 | +2 (+1.56%) |
| RANGE_1_2 | 113 | 60 | 45 | 24 | 129 | +1 (+0.78%) |
| RANGE_2_3 | 115 | 74 | 59 | 3 | 136 | +8 (+6.25%) |
| FIXED_3 | 118 | 76 | 72 | 7 | 155 | +27 (+21.09%) |

FIXED2는 unresolved+2(+1.56%)로 총수 비용은 작지만 UNDISTURBED57→73, not-ready28→55, ready43→2로 잔여의 종류가 크게 바뀐다. ready 수가 줄었다는 이유로 처리가 좋아졌다고 해석하지 않는다. Range1~2의 기본 비용+1(+0.78%)도 작다. Range2~3은 base+8(+6.25%), 추가 family에서는+14~20(+10.94~15.63%)다. Fixed3은+27(+21.09%). Case03 Pending은 모두 남고 종료·conversion·강제 drain은 수행하지 않았다.

## Table 4 — Experiment Manipulation

각 칸은 **M shown / final unresolved record**, 각 실험 조합은 같은16 Journey(실패 source24개)다.

| 정책 | 0/0 | 0/1 | 0/2 | 1/0 | 1/1 | 1/2 | 2/0 | 2/1 | 2/2 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| CURRENT | 4 / 20 | 8 / 16 | 8 / 16 | 8 / 16 | 12 / 12 | 12 / 12 | 12 / 12 | 12 / 12 | 12 / 12 |
| FIXED_2 | 4 / 20 | 7 / 17 | 8 / 16 | 8 / 16 | 11 / 13 | 12 / 12 | 12 / 12 | 12 / 12 | 12 / 12 |
| RANGE_1_2 | 4 / 20 | 7 / 17 | 8 / 16 | 8 / 16 | 12 / 12 | 12 / 12 | 12 / 12 | 12 / 12 | 12 / 12 |
| RANGE_2_3 | 3 / 21 | 6 / 18 | 7 / 17 | 6 / 18 | 10 / 14 | 12 / 12 | 12 / 12 | 12 / 12 | 12 / 12 |
| FIXED_3 | 0 / 24 | 3 / 21 | 6 / 18 | 4 / 20 | 7 / 17 | 10 / 14 | 8 / 16 | 11 / 13 | 12 / 12 |

CURRENT와 Range1~2는0/0 M4→2/2 M12이며, 실험량만 바꿔도 표시가3배 달라진다. Fixed2도4→12로 회피 구조를 없애지 않는다. Range2~3 base는3→12, Fixed3은0→12이며 no-experiment에서 모든 Major가 미노출된다. 이는 선택한 동일 outcome/D/seed 조건의 경로 비교이며, 실제 유저 회피 성공 확률·재미·독해 능력의 측정은 아니다. 더 많은 Run이 readiness opportunity를 늘리지만 마지막 표시 결과 하나만 credit을 주므로, 0→1/1→2 효과도 균등하지 않다.

## Table 5 — Stage Distribution

| 정책 | CCTV | EXP | CONT | M Total | Largest share | CURRENT 대비 pp |
| --- | --- | --- | --- | --- | --- | --- |
| CURRENT | 36 | 16 | 36 | 88 | 40.91% | +0.00 |
| FIXED_2 | 36 | 32 | 18 | 86 | 41.86% | +0.95 |
| RANGE_1_2 | 39 | 20 | 28 | 87 | 44.83% | +3.92 |
| RANGE_2_3 | 24 | 35 | 21 | 80 | 43.75% | +2.84 |
| FIXED_3 | 0 | 36 | 25 | 61 | 59.02% | +18.11 |

표시 Stage와 버튼 소속 Stage를 분리한 추가 표다. EXP Next가 CONT에 들어가며 사건이 나타나면 return Stage는CONT, 클릭한 버튼은EXP Next로 기록된다.

| 정책 | CCTV Next | EXP Next (entry 포함) | CONT Next |
| --- | --- | --- | --- |
| CURRENT | 36 | 16 | 36 |
| FIXED_2 | 36 | 50 | 0 |
| RANGE_1_2 | 39 | 24 | 24 |
| RANGE_2_3 | 24 | 56 | 0 |
| FIXED_3 | 0 | 61 | 0 |

현재 M는 CCTV36/EXP16/CONT36으로 과거 CONT 집중에서 이미 분산됐다. Fixed3에서는 return Stage 두 개만 남고 클릭 checkpoint는 전부EXP Next(61/61)다. Fixed2도EXP Next50/86로 특정 버튼 결합이 강해진다. randomness만으로 checkpoint 구조를 다양화하지 못한다. 사람의 학습·예측감은 여기서 확정하지 않았다.

## Table 6 — Cross-Case Delay

| 정책 | D와 같은 current Case M | D보다+1 Case M | D보다+2 Case M | D 뒤 M 미표시 | source age1 | source age2 |
| --- | --- | --- | --- | --- | --- | --- |
| CURRENT | 52 | 36 | 0 | 71 | 36 | 52 |
| FIXED_2 | 14 | 72 | 0 | 57 | 0 | 86 |
| RANGE_1_2 | 39 | 48 | 0 | 69 | 24 | 63 |
| RANGE_2_3 | 12 | 68 | 0 | 62 | 0 | 80 |
| FIXED_3 | 4 | 57 | 0 | 79 | 0 | 61 |

중요한 별도 관찰: 기본 matrix의 모든 정책에서 실제 M source는Case01뿐이다. CURRENT는Case02에서36/Case03에서52이고, Fixed2/Range2~3/Fixed3은Case03에서만 M가 표시된다. Range1~2는Case02 24/Case03 63이다. Case02의 실패 후보는 다음 Case03에서 남아 있어도 actual Major response0이다. 이144개 경로에서는 gate·older 후보 경쟁·여러 Run 후 마지막 read 한 번·final disabled checkpoint가 함께 작용한다. 모든 가능한 사용 습관에서 Case02 M가 불가능하다는 주장은 하지 않는다. 종료 책임과 마지막 source 노출 부족을 threshold 하나로 해결했다고 말할 수 없다. source age 증가가 기억 부담 위험을 시사하지만 실제 기억력은 측정하지 않았다.

## Spacing, density, outcome control

| 정책 | strict min/med/max | causing min/med/max | credit min/med/max | zero-credit pair | D+M / eligible |
| --- | --- | --- | --- | --- | --- |
| CURRENT | 1/2/3 (n=121) | 1/2/3 (n=121) | 1/1/2 (n=121) | 0 | 247/1296 = 0.190586 |
| FIXED_2 | 1/2/4 (n=103) | 1/2/4 (n=103) | 1/2/3 (n=103) | 0 | 229/1296 = 0.176698 |
| RANGE_1_2 | 1/2/4 (n=117) | 1/2/4 (n=117) | 1/2/3 (n=117) | 0 | 243/1296 = 0.187500 |
| RANGE_2_3 | 1/2/4 (n=96) | 1/2/4 (n=96) | 1/2/3 (n=96) | 0 | 222/1296 = 0.171296 |
| FIXED_3 | 1/3/4 (n=75) | 1/3/4 (n=75) | 1/3/3 (n=75) | 0 | 201/1296 = 0.155093 |

| 정책 | strict 분포 | causing 분포 | credit 분포 |
| --- | --- | --- | --- |
| CURRENT | 1:53, 2:59, 3:9 | 1:53, 2:59, 3:9 | 1:70, 2:51 |
| FIXED_2 | 1:14, 2:65, 3:12, 4:12 | 1:14, 2:65, 3:12, 4:12 | 1:31, 2:48, 3:24 |
| RANGE_1_2 | 1:40, 2:65, 3:9, 4:3 | 1:40, 2:65, 3:9, 4:3 | 1:58, 2:53, 3:6 |
| RANGE_2_3 | 1:12, 2:52, 3:16, 4:16 | 1:12, 2:52, 3:16, 4:16 | 1:26, 2:38, 3:32 |
| FIXED_3 | 1:4, 2:23, 3:24, 4:24 | 1:4, 2:23, 3:24, 4:24 | 1:12, 2:15, 3:48 |

모든 base 정책의 eligible1296/기존 meaningful1296/고유 credit1200은 동일하며, 전체1296 matrix Journey에서 zero-credit pair0이다. strict/causing이 같은 것은 이번 실제 Event causing action들이 기존 meaningful action 정의에서 새 Run/Confirm으로 분류되지 않는 경로 특성이다. credit metric으로 재정의해서 맞춘 것이 아니다. 모든SS9 Journey와 모든 추가 seed SS는D/M/B0이다.

| 정책 | FF81 D/M/잔여 | FS27 D/M/잔여 | SF27 D/M/잔여 | SS9 D/M/잔여 |
| --- | --- | --- | --- | --- |
| CURRENT | 114/66/96 | 27/22/5 | 18/0/27 | 0/0/0 |
| FIXED_2 | 98/64/98 | 27/22/5 | 18/0/27 | 0/0/0 |
| RANGE_1_2 | 111/65/97 | 27/22/5 | 18/0/27 | 0/0/0 |
| RANGE_2_3 | 97/60/102 | 27/20/7 | 18/0/27 | 0/0/0 |
| FIXED_3 | 95/44/118 | 27/17/10 | 18/0/27 | 0/0/0 |

## Range seed sensitivity (각行144 Journey)

| 정책 | seed offset | D | M=B | 미해결 | U/NR/Ready | CCTV/EXP/CONT | Largest share | 실제 Candidate threshold 분포 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| RANGE_1_2 | 0 | 156 | 87 | 129 | 60/45/24 | 39/20/28 | 44.83% | {'1': 144, '2': 72} |
| RANGE_1_2 | 100000 | 144 | 86 | 130 | 72/40/18 | 39/27/20 | 45.35% | {'2': 135, '1': 81} |
| RANGE_1_2 | 200000 | 152 | 87 | 129 | 64/44/21 | 39/24/24 | 44.83% | {'1': 108, '2': 108} |
| RANGE_2_3 | 0 | 142 | 80 | 136 | 74/59/3 | 24/35/21 | 43.75% | {'2': 144, '3': 72} |
| RANGE_2_3 | 100000 | 140 | 68 | 148 | 76/65/7 | 9/37/22 | 54.41% | {'3': 135, '2': 81} |
| RANGE_2_3 | 200000 | 139 | 74 | 142 | 77/61/4 | 15/36/23 | 48.65% | {'2': 108, '3': 108} |

Range1~2: M86~87(현재88 대비-1.14~-2.27%), 잔여129~130(+0.78~1.56%), Stage max44.83~45.35%(현재40.91%)로 세 family에서 같은 방향이다. Range2~3: M68~80(-9.09~-22.73%), 잔여136~148(+6.25~15.63%), Stage max43.75~54.41%다. 이 min/max는 세 deterministic family의 관측 범위이며 모집단 신뢰구간이 아니다. 동일 seed에서 CURRENT/Range1~2/Range2~3 대표9 Journey씩 총27을 재실행해 process-local Runtime IDs를 제외한 전체 semantic 결과·threshold·RNG state·timeline·Archive·Snapshot이 일치했다.

## F01 분해와 정책 추천

| 정책 | F01-A readiness 고정성 | F01-B Stage/button 결합 | F01-C 행동량 조작 |
| --- | --- | --- | --- |
| CURRENT | OPEN: 도달값 전부1 | OPEN: 3 Stage, 전부 Next 경계 | OPEN: 0/0 M4 ↔ 2/2 M12 |
| FIXED_2 | UNCHANGED: 고정값2로 이동 | UNCHANGED/소폭 악화: max41.86%, EXP Next50/86 | UNCHANGED: M4↔12 |
| RANGE_1_2 | PARTIALLY IMPROVED(비교): 도달1/2 | UNCHANGED/악화: max44.83~45.35%, Next 경계 유지 | UNCHANGED: base M4↔12 |
| RANGE_2_3 | PARTIALLY IMPROVED(비교): 도달2/3 | UNCHANGED/악화: max43.75~54.41%, EXP 결합 | WORSE risk: base M3↔12; seed·행동에 민감 |

**KEEP_MAJOR_1을 추천하며 F01을 RESOLVED로 바꾸지 않는다.** 현재 readiness는 단순하지만 Step48 gate가 실제 표시까지의 eligible/credit·Stage 차이를 이미 만든다. Range1~2의 노출·잔여 비용은 작아서 비용만으로 배제할 정도는 아니다. 그러나 요구한 “특정 Stage 집중 악화 없음/행동량 회피 개선”을 충족하지 못하고 source age도 길어진다. 작은 random range를 넣는 것만으로 F01-B/C 해결을 입증하지 못했다. 사람 A/B를 한다면 Current1 vsRange1~2가 가장 작은 다음 비교 후보다.

Fixed2는 단지 두 번째 eligible readiness라는 새 공식으로 바뀐다. Stage max+0.95pp, D159→143(-10.06%)는 presentation slot 경쟁의 간접효과다. 이를 사건 수가 적어서 무조건 좋다/나쁘다고 판단하지 않는다. Range2~3은 variance가 있으나 current Case03로 source 기억 거리를 모두2로 늘리고 seed에 따라 M20회까지 잃는다. Fixed3은 no-experiment M0/Stage max59.02%/잔여+21.09%로 비추천한다.

F44-01/F44-02는 이번 실제 회귀에서도 RESOLVED 계약을 유지한다. F07-B는 PARTIALLY ADDRESSED이며 Snapshot 진단만 있다. 마지막 미판정 제출과 남은 후보의 실제 종료 책임은 여전히 없다. Major readiness의 결정성은 threshold의 직접 영향이고, presentation의 Next 결합/마지막 checkpoint 부재/실험량 조작은 threshold보다 경계 구조의 영향이 크다. threshold 변경 대신 콘텐츠 다양성도 후속 고려 대상이지만 이번에는 Event type/Facility/Severity를 추가하지 않았다.

다음 Step은 **선택 C: threshold 유지 + 명시적 최종 disposition 책임 계약**을 추천한다. Run identity/종료 종류/결과 수신자/멱등성/실패 시 retry·미판정 제출·미처리 후보 이전을 먼저 정한다. 제품 Case03 Next를 바로 종료 버튼으로 바꾸거나 숨은 queue를 전부 재생하지 않는다. 정책 확정 전 구현하지 않는다. 사람이 불편하다고 입증하지 않았으므로 UX를 억지로 변경하지 않았다. 긴2시간 실제 게임에선 이번3Case의 censoring이 작아질 수 있지만 미래 Case 수를 이유로 현재 비용을 무시하지 않는다.

## 새 실행 검증과 제한

Godot actual4.7.1에서 인증204프로세스: 제품 CURRENT73, 대안 Simulation130, 정책 혼합 controlled1. 제품40개 check-only, editor import1, configured Main headless/native2, Step46 Snapshot5그룹, Step47 ordering, Step48 gate/edge/queue/debug, actual CURRENT GPU3해상도 대표 Journey를 새로 실행했다. 이전318개 전체 legacy suite를 다시204개로 통과시켰다는 뜻이 아니다. 이번 요구한 현재 핵심 회귀를 모두 실행했다.

base matrix80프로세스=5정책×16프로세스×9Journey=720, 추가 range seed64프로세스=576 Journey, 합계1296 matrix Journey다. GPU3프로세스의6 rich Journey와 반복3프로세스의27Journey는 matrix와 별도다. controlled49 selector scenario record/2566 assertions와64seed×2draw×2range 검사는 Journey 수에 합치지 않는다. native 실제GPU OpenGL3.3 AMD Radeon RX6800에서1920×1080/1280×720/1024×768 draw·layout·single View·Resume를 검사하고 PNG를 육안 확인했다. 새 UI가 없어서 대안별 GPU capture는 하지 않았다.

정상 warning0, 최종 runtime/GDScript/parse error0. invalid fixture 예상 warning75개는 Snapshot18 + edge11 + ordering4 + queue28 + controlled14다. controlled는 누락 Broadcast7건에서 lookup warning과 presenter warning이 각각1개씩 발생하는7쌍이다. warning 수를 실패 후 임의로 무시하지 않고 해당 invalid 콘텐츠/경로를 확인했다.

초기 검증 환경에서는 기본 user log 쓰기 제한으로 엔진이 실패했고, sandbox Windows root certificate 읽기 제한도 발생했다. workspace 테스트 APPDATA/LOCALAPPDATA와 정상 권한 실행으로 해결했다. 대안 fixture는 set_script가 export 값을 초기화하므로 부착 후 Case sequence를 주입하도록 고쳤다. controlled fixture의 typed Array 누락도 수정했다. Snapshot baseline의 프로세스별 Runtime ID 및 Python Windows path 구분자 차이는 측정 도구에서 명시적으로 정규화했다. 이들은 제품 bug 수정이 아니다. 모든 최종 인증은 성공 exit/log만 포함하고 초기 실패는 PASS 수에서 제외했다. 제품 P0/P1 bug는 발견하지 않았다.

Read completion은 실제 draw 뒤 사용자의 Next라는 proxy다. 완독/이해도/실제 공포·예측감·재미·기억력·실험 선택 이유·2시간 workload는 자동화가 측정하지 않는다. 여러 결과마다 별도 Next를 누르는 사람 행동, 새 Case 추가, 실제 Run/Save/Settlement는 이 Audit 범위 밖이다. Current1과 Range1~2가 비용상 근접하므로 실제 채택 판단에는 사람 A/B가 필요하다.

## 재현 자료와 Git 범위

ignored `.godot/verification/step49/`: `prepare.py`(baseline/copy), `policy_main.gd`(대안 한 필드 주입), `audit.gd`(실제 버튼 timeline), `controlled.gd`(selector/gate/Snapshot/RNG), `run.py`(current/alternatives/core/controlled/repeat/seeds), `analyze.py`(분포/paired/거리), `certify.py`(exit/log/hash), `build_report.py`(보고서). `base48/`는 원본 검증 source의 경로 복사본이며 이전 verification source/JSON은 변경하지 않았다.

원시 증거: `audit_*.json`, `analysis.json`, `baseline-confirmation.json`, `controlled.json`, `certification.json`, `*-runs.json`, 원본 stdout/stderr/engine log와PNG. 새 실행 프로세스 exit/warning/log SHA256을 certification에서 검증한다. 비교 결과의 제품 소스 hash,115개 tracked baseline,9631개 기존 검증 hash를 보존했다. 이 ignored 증거는 cache 삭제/새 clone에서 없어질 수 있으므로 git에는 아래 상세 수치·방법·174개 답변을 남긴다.

최종 변경: README 수정1 + 이 보고서 신규1. 기존 미커밋 Step39 문서는 baseline과 byte 동일. 제품 code0/삭제0/staged0/commit0/push0, HEAD/branch/upstream 불변. README는 시작 bytes를 그대로 prefix로 보존해 Audit block만 추가한다. `git diff --check`와 새 보고서 whitespace/실제 변경 파일 목록을 확인했다.

## 요청한 174개 종료 보고 항목

| 번호 | 요청 항목 | 실제 결과·근거 |
| --- | --- | --- |
| 1 | 작업 전 Git 상태 | 기존 미커밋 docs/step39_case_evidence.md 1개(트리 공백→탭); byte/hash 그대로 보존. |
| 2 | HEAD / branch / upstream | HEAD d6d9e4efe625d1688d475e326f8c723d357540a5; master→origin/main; 원격 ccc, 이번 fetch/commit/push 없음. |
| 3 | Step46 변경 | Step46 Snapshot/Main/read_models/report는 이미 HEAD에 포함; 수정0. |
| 4 | Step47 변경 | Step47 registered oldest-actionable/retain+skip은 HEAD에 포함; 수정0. |
| 5 | Step48 변경 | Step48 shared credit/read-boundary/실제 결과 식별은 HEAD에 포함; 수정0. |
| 6 | 현재 제품 Major threshold | 제품 PROTOTYPE_MAJOR_THRESHOLD=1 불변. |
| 7 | 현재 Disturbance threshold | 제품 D=2~4 불변. |
| 8 | RNG 위치 | Main._ready randomize, _try_resolve_current_pending의 D randi_range; 비교 M는 독립 test RNG. |
| 9 | Candidate threshold sampling | 유효 hidden FAILURE 생성 때 D 한 번/M fixed1; test range는 새 Candidate 생성 직후 한 번 주입. |
| 10 | readiness advancement | 첫 CCTV entry/승인 Run/첫 CONT entry; Major count를 새 D 표시 이전에 증가. |
| 11 | presentation gate | 새 고유 CCTV/EXP read 또는 Confirm token이 OPEN; Event 실제 표시 성공이면 CLOSED. |
| 12 | oldest actionable | 등록 순서 oldest actionable 하나, invalid/unready/nonpresentable retain+skip. |
| 13 | Snapshot | Step46 fact 복사/분류만; no RNG/state progression, deep copy, no closure. |
| 14 | Audit 제품 코드 변경 여부 | 제품 코드 변경0, seam0. |
| 15 | 비교 fixture 방식 | deep-cloned authored Resources + 실제 configured Scene; 대안만 Main subclass의 신규 Candidate 한 필드 주입. |
| 16 | product/simulation 분리 | CURRENT product73 process / simulated130 / mixed controlled1을 분리. |
| 17 | CURRENT1 정의 | CURRENT1 실제 제품; configured Main 상수1. |
| 18 | FIXED2 정의 | FIXED2 test-only 모든 신규 후보 M2. |
| 19 | RANGE1_2 정의 | RANGE1_2 test-only 독립 RNG로 등록 때1~2. |
| 20 | RANGE2_3 정의 | RANGE2_3 test-only 독립 RNG로 등록 때2~3. |
| 21 | FIXED3 사용 여부 | 참고 FIXED3도144 Journey 추가, 큰 지연 비용 비교용. |
| 22 | Disturbance threshold 동일성 | 모든 paired Journey D01/D02 각2~4 동일; 실제 Candidate/제품 D RNG state 확인. |
| 23 | RNG comparability | D seed/stream 불변, M 별도 RNG; 실험량 변경에도 M seed/후보 threshold 고정. |
| 24 | seed 정책 | 기본 seed490001+D01*10000+D02*1000; 추가 offset100000/200000; 64seed RNG replay. |
| 25 | 144 Journey 구조 | FF81/FS27/SF27/SS9; E02/E03 각0/1/2, E01=1. |
| 26 | policy당 Journey 수 | 각5정책144; ranges 추가각288; primary720+extra576=1296 matrix Journeys. |
| 27 | CURRENT 재현성 | 대표 CURRENT9 Journey 새 재실행 semantic 동일; Runtime IDs만 제외. |
| 28 | Step48 baseline 일치 | 새 CURRENT144의 event/spacing/Archive/Snapshot facts가 Step48와 일치; D159/M88/잔여128. |
| 29 | CURRENT D | CURRENT base144: D=159. |
| 30 | CURRENT M | CURRENT base144: M=88. |
| 31 | CURRENT B | CURRENT base144: B=88. |
| 32 | CURRENT interruption | CURRENT base144: interruptions=247. |
| 33 | CURRENT unresolved | CURRENT base144: unresolved=128. |
| 34 | CURRENT unresolved Journey | CURRENT base144: unresolved_journeys=113. |
| 35 | CURRENT phase breakdown | CURRENT U/NR/Ready=57/28/43; actual Step46 Snapshot. |
| 36 | CURRENT CCTV M | 36회. |
| 37 | CURRENT EXP M | 16회. |
| 38 | CURRENT CONT M | 36회. |
| 39 | CURRENT credit gap | CURRENT credit gap 1/1/2 (n=121); distribution 1:70, 2:51. |
| 40 | FIXED2 D | FIXED_2 base144: D=143. |
| 41 | FIXED2 M | FIXED_2 base144: M=86. |
| 42 | FIXED2 B | FIXED_2 base144: B=86. |
| 43 | FIXED2 interruption | FIXED_2 base144: interruptions=229. |
| 44 | FIXED2 unresolved | FIXED_2 base144: unresolved=130. |
| 45 | FIXED2 unresolved Journey | FIXED_2 base144: unresolved_journeys=113. |
| 46 | FIXED2 phase breakdown | FIXED_2 U/NR/Ready=73/55/2; actual Step46 Snapshot. |
| 47 | FIXED2 Stage distribution | {'CONTAINMENT': 18, 'EXPERIMENT': 32, 'CCTV': 36}; Largest share 41.86%. |
| 48 | FIXED2 readiness distance | 2/2/2 (n=88); distribution 2:88. 미도달은 별도. |
| 49 | FIXED2 presentation distance | 2/2/3 (n=86); distribution 2:74, 3:12. 미도달은 별도. |
| 50 | FIXED2 credit distance | 1/2/3 (n=86); distribution 1:14, 2:48, 3:24. 미도달은 별도. |
| 51 | RANGE1_2 D | RANGE_1_2 base144: D=156. |
| 52 | RANGE1_2 M | RANGE_1_2 base144: M=87. |
| 53 | RANGE1_2 B | RANGE_1_2 base144: B=87. |
| 54 | RANGE1_2 interruption | RANGE_1_2 base144: interruptions=243. |
| 55 | RANGE1_2 unresolved | RANGE_1_2 base144: unresolved=129. |
| 56 | RANGE1_2 unresolved Journey | RANGE_1_2 base144: unresolved_journeys=113. |
| 57 | RANGE1_2 phase breakdown | RANGE_1_2 U/NR/Ready=60/45/24; actual Step46 Snapshot. |
| 58 | RANGE1_2 Stage distribution | {'CCTV': 39, 'CONTAINMENT': 28, 'EXPERIMENT': 20}; Largest share 44.83%. |
| 59 | RANGE1_2 readiness variation | 1/1/2 (n=111); distribution 1:86, 2:25. 미도달은 별도. |
| 60 | RANGE1_2 presentation variation | 1/1/3 (n=87); distribution 1:57, 2:27, 3:3. 미도달은 별도. |
| 61 | RANGE2_3 D | RANGE_2_3 base144: D=142. |
| 62 | RANGE2_3 M | RANGE_2_3 base144: M=80. |
| 63 | RANGE2_3 B | RANGE_2_3 base144: B=80. |
| 64 | RANGE2_3 interruption | RANGE_2_3 base144: interruptions=222. |
| 65 | RANGE2_3 unresolved | RANGE_2_3 base144: unresolved=136. |
| 66 | RANGE2_3 unresolved Journey | RANGE_2_3 base144: unresolved_journeys=115. |
| 67 | RANGE2_3 phase breakdown | RANGE_2_3 U/NR/Ready=74/59/3; actual Step46 Snapshot. |
| 68 | RANGE2_3 Stage distribution | {'CONTAINMENT': 21, 'EXPERIMENT': 35, 'CCTV': 24}; Largest share 43.75%. |
| 69 | RANGE2_3 readiness variation | 2/2/3 (n=83); distribution 2:63, 3:20. 미도달은 별도. |
| 70 | RANGE2_3 presentation variation | 2/2/4 (n=80); distribution 2:53, 3:23, 4:4. 미도달은 별도. |
| 71 | optional FIXED3 결과 | FIXED3 D140/M61/B61/interrupt201/unresolved155; no-exp M0, Stage max59.02%. |
| 72 | strict spacing per policy | 모든 base strict min1/median2(고정3은3)/max3~4; 상세 분포표 참조. |
| 73 | causing spacing per policy | 모든 base causing=min1/median2(고정3은3)/max3~4; strict와 같음. |
| 74 | credit spacing per policy | base credit min1, median1~3/max2~3; 추가576 Journey도min>=1. |
| 75 | zero-credit per policy | 모든1296 matrix Journey zero-credit pair0. |
| 76 | Event density per policy | CURRENT.190586, Fixed2.176698, Range1_2.1875, Range2_3.171296, Fixed3.155093. |
| 77 | Major Stage max share | CURRENT40.91%, Fixed2 41.86%, Range1_2 44.83%, Range2_3 43.75%, Fixed3 59.02%; 추가seed 표 별도. |
| 78 | D→M readiness min | CURRENT min=1, FIXED_2 min=2, RANGE_1_2 min=1, RANGE_2_3 min=2, FIXED_3 min=3. 해당도달/표시 분모는Table2. |
| 79 | D→M readiness median | CURRENT median=1, FIXED_2 median=2.0, RANGE_1_2 median=1, RANGE_2_3 median=2, FIXED_3 median=3.0. 해당도달/표시 분모는Table2. |
| 80 | D→M readiness max | CURRENT max=1, FIXED_2 max=2, RANGE_1_2 max=2, RANGE_2_3 max=3, FIXED_3 max=3. 해당도달/표시 분모는Table2. |
| 81 | D→M presentation min | CURRENT min=1, FIXED_2 min=2, RANGE_1_2 min=1, RANGE_2_3 min=2, FIXED_3 min=3. 해당도달/표시 분모는Table2. |
| 82 | D→M presentation median | CURRENT median=1.0, FIXED_2 median=2.0, RANGE_1_2 median=1, RANGE_2_3 median=2.0, FIXED_3 median=3. 해당도달/표시 분모는Table2. |
| 83 | D→M presentation max | CURRENT max=2, FIXED_2 max=3, RANGE_1_2 max=3, RANGE_2_3 max=4, FIXED_3 max=4. 해당도달/표시 분모는Table2. |
| 84 | D→M credit min | CURRENT min=1, FIXED_2 min=1, RANGE_1_2 min=1, RANGE_2_3 min=1, FIXED_3 min=1. 해당도달/표시 분모는Table2. |
| 85 | D→M credit median | CURRENT median=1.0, FIXED_2 median=2.0, RANGE_1_2 median=2, RANGE_2_3 median=2.0, FIXED_3 median=3. 해당도달/표시 분모는Table2. |
| 86 | D→M credit max | CURRENT max=2, FIXED_2 max=3, RANGE_1_2 max=3, RANGE_2_3 max=3, FIXED_3 max=3. 해당도달/표시 분모는Table2. |
| 87 | same-Case Major | D와 동일 current Case M: 52/14/39/12/4 (정책 순서 CURRENT/2/1~2/2~3/3). |
| 88 | cross-Case +1 | D보다+1 Case M:36/72/48/68/57. |
| 89 | cross-Case +2 | D보다+2 Case M 전정책0; source age2와 혼동 금지. |
| 90 | unshown Major | D 뒤 M 미표시71/57/69/62/79; UNDISTURBED 제외. |
| 91 | source/current distance | M source age1/2: CURRENT36/52, Range1_2 24/63; 나머지 표시M 전부age2. |
| 92 | no-experiment results | E02/E03 0/0의M/잔여:4/20,4/20,4/20,3/21,0/24. |
| 93 | full-experiment results | E02/E03 2/2 전정책M12/잔여12. |
| 94 | 0/0 experiment combination | E02/E03=0/0: CURRENT M4/잔여20, FIXED_2 M4/잔여20, RANGE_1_2 M4/잔여20, RANGE_2_3 M3/잔여21, FIXED_3 M0/잔여24. |
| 95 | 0/1 | E02/E03=0/1: CURRENT M8/잔여16, FIXED_2 M7/잔여17, RANGE_1_2 M7/잔여17, RANGE_2_3 M6/잔여18, FIXED_3 M3/잔여21. |
| 96 | 0/2 | E02/E03=0/2: CURRENT M8/잔여16, FIXED_2 M8/잔여16, RANGE_1_2 M8/잔여16, RANGE_2_3 M7/잔여17, FIXED_3 M6/잔여18. |
| 97 | 1/0 | E02/E03=1/0: CURRENT M8/잔여16, FIXED_2 M8/잔여16, RANGE_1_2 M8/잔여16, RANGE_2_3 M6/잔여18, FIXED_3 M4/잔여20. |
| 98 | 1/1 | E02/E03=1/1: CURRENT M12/잔여12, FIXED_2 M11/잔여13, RANGE_1_2 M12/잔여12, RANGE_2_3 M10/잔여14, FIXED_3 M7/잔여17. |
| 99 | 1/2 | E02/E03=1/2: CURRENT M12/잔여12, FIXED_2 M12/잔여12, RANGE_1_2 M12/잔여12, RANGE_2_3 M12/잔여12, FIXED_3 M10/잔여14. |
| 100 | 2/0 | E02/E03=2/0: CURRENT M12/잔여12, FIXED_2 M12/잔여12, RANGE_1_2 M12/잔여12, RANGE_2_3 M12/잔여12, FIXED_3 M8/잔여16. |
| 101 | 2/1 | E02/E03=2/1: CURRENT M12/잔여12, FIXED_2 M12/잔여12, RANGE_1_2 M12/잔여12, RANGE_2_3 M12/잔여12, FIXED_3 M11/잔여13. |
| 102 | 2/2 | E02/E03=2/2: CURRENT M12/잔여12, FIXED_2 M12/잔여12, RANGE_1_2 M12/잔여12, RANGE_2_3 M12/잔여12, FIXED_3 M12/잔여12. |
| 103 | timing manipulation | 고정seed/Outcome/D에서 실험량이 eligible/opportunity와 현재 표시credit을 바꿔 timing 조작 가능. |
| 104 | Major avoidance risk | CURRENT/Fixed2/Range1_2 0/0 M4 vs full12; Range2_3 base3, Fixed3 0. 회피 구조 유지/악화. |
| 105 | final leftover increase | 잔여 CURRENT128→130/129/136/155; 추가Range1_2 129~130, Range2_3 136~148. |
| 106 | F07-B burden | ready 감소가 의무 해결은 아님; final Pending 및 미처리 후보 책임은 그대로 필요. |
| 107 | all-Success unchanged | 모든SS control D/M/B0, 후보0. |
| 108 | Step47 ordering maintained | 전정책/양끝 threshold의 controlled49 record 및 actual ordering 회귀 통과. |
| 109 | CLOSED ordering | CLOSED ready oldM/newD에서도 선택/상태변경0. |
| 110 | OPEN ordering | OPEN old readyM 우선; old unready/invalid는 retain하고 youngD. |
| 111 | Step48 gate maintained | 전정책 credit min>=1/one checkpoint one Event; core gate/edge 회귀. |
| 112 | read-before-event | CCTV/EXP 실제 draw 뒤 read Next, Run same callback 사건0. |
| 113 | CCTV credit | 고유Case+base CCTV source의 첫 Next만credit; duplicate/Recheck 없음. |
| 114 | EXP credit | 고유실행 결과 중 현재 실제 표시 source의 첫 read Next만credit; multiple Run history-only 없음. |
| 115 | Confirm credit | 유효 최초Room Confirm credit만; 같은 callback 사건0/Pending잠금 유지. |
| 116 | Dismiss/Resume no credit | Dismiss/Resume no credit/no opportunity/즉시 nested Event0; controlled 각정책 확인. |
| 117 | Environment timing | 실제D 표시 성공 뒤 조건적용; readiness만으로 조건변경 없음. Presenter 제품 hash 동일/회귀. |
| 118 | hidden D 없음 | 숨은D 적용 추가0; actual Notice/application 계약과 core gate 유지. |
| 119 | past Experiment immutable | 기존 실행 시 condition observation ID snapshot을 소급 수정하지 않음; actual gate/edge/rich 회귀. |
| 120 | Archive | 현재 Runtime/source Archive 분리, 실제 표시된 response만 incremental merge; rich response/core 회귀. |
| 121 | Hypothesis | Case별 가설분리; Log/가설편집 no credit/opportunity; rich/core 회귀. |
| 122 | Case03 Pending | 전Journey Case03 Pending1 유지, matching confirmedRoom. |
| 123 | Case03 Outcome 없음 | Case03 Outcome0/monitoring UNDEFINED/Next disabled 유지. |
| 124 | Snapshot output | 전Journey final Step46 Snapshot 수집·10회 불변/phase·Pending·boundary 일치. |
| 125 | Candidate delete 없음 | 남은Candidate 삭제0; 정상 COMPLETED Response 뒤 기존 제거만 허용. |
| 126 | Resource immutable | deep clone content 전후 _shape 회귀/제품 .tres hash 불변. |
| 127 | product parser | 제품 GDScript40개 새 check-only 통과. |
| 128 | editor import | 새 headless editor import1 통과. |
| 129 | Main headless | 새 configured Main headless 정상실행/종료. |
| 130 | Main native | 새 configured Main native 정상실행/종료. |
| 131 | current full regression | Step46 Snapshot5group/Step47 ordering/Step48 gate·edge·queue·debug 핵심 모두 새 실행. 과거318 전체 반복 주장 안 함. |
| 132 | simulated comparison execution | 대안64base+64extra+2repeat=130프로세스; 실제 제품 적용 아닌 simulation. |
| 133 | 3해상도 | CURRENT native3해상도, 각2richJourney/실제draw/PNG 육안 확인. |
| 134 | warning | 정상warning0; 의도된invalid75(Snapshot18/edge11/order4/queue28/controlled14) 별도. |
| 135 | runtime error | 최종runtime/GDScript error0; 초기 환경/fixture 실패 제외. |
| 136 | parse error | 최종parse error0. |
| 137 | Main line count | Main1714줄 그대로. |
| 138 | Main function count | Main93함수 그대로. |
| 139 | actual product code 변경 | 제품code/Scene/Resource/State/project 수정0. |
| 140 | README 변경 | README 끝에 Step49 Audit 결과 block만 추가, 원본bytes prefix보존. |
| 141 | 보고서 생성 | docs/step49_major_predictability_threshold_audit.md 신규. |
| 142 | 삭제 파일 | 삭제0. |
| 143 | git diff --check | 최종git diff --check 통과, 신규보고서 whitespace도검사. |
| 144 | staged | staged0. |
| 145 | 기존 변경 보존 | 제품100파일·기존verification9631hash 보존; Step39 사용자편집 byte동일. |
| 146 | commit/push 없음 | commit/push 없음, HEAD/branch/upstream 불변. |
| 147 | F01-A CURRENT | OPEN: ready 도달131개 전부1. |
| 148 | F01-A FIXED2 | UNCHANGED: 결정적 readiness1을2로 이동. |
| 149 | F01-A RANGE1_2 | PARTIALLY IMPROVED(비교): readiness1/2 variation. |
| 150 | F01-A RANGE2_3 | PARTIALLY IMPROVED(비교): readiness2/3 variation; censoring 증가. |
| 151 | F01-B CURRENT | OPEN: Stage3개 분포, 모두Next 경계. |
| 152 | F01-B FIXED2 | UNCHANGED/소폭악화: Stage max41.86%, EXP Next50/86. |
| 153 | F01-B RANGE1_2 | UNCHANGED/악화: 세seed Stage max44.83~45.35%; Next 결합 유지. |
| 154 | F01-B RANGE2_3 | UNCHANGED/악화: 세seed Stage max43.75~54.41%, EXP결합 강화. |
| 155 | F01-C CURRENT | OPEN: 실험0/0→2/2 M4→12. |
| 156 | F01-C FIXED2 | UNCHANGED: M4→12. |
| 157 | F01-C RANGE1_2 | UNCHANGED: baseM4→12. |
| 158 | F01-C RANGE2_3 | WORSE risk: baseM3→12 및 seed variation, no-exp 노출 감소. |
| 159 | F44-01 회귀 | RESOLVED 계약유지:1296 matrix zero-credit0, 실제 core gate 통과. |
| 160 | F44-02 회귀 | RESOLVED 계약유지:oldest actionable CLOSED/OPEN 모든정책 회귀. |
| 161 | F07-B 상태 | PARTIALLY ADDRESSED: Snapshot만 있으며 종료/정산 없음. |
| 162 | 예측성 개선 폭 | Range1_2 ready1/2, shown distance1~3; Fixed2 same checkpoint8/88, Range1_2 threshold-change masking2개. Stage 개선 미입증. |
| 163 | Event 노출 손실 | base M loss Fixed2-2(-2.27%), Range1_2-1(-1.14%), Range2_3-8(-9.09%), Fixed3-27(-30.68%). 추가seed 범위 표. |
| 164 | final boundary 비용 | Range1_2 잔여+0.78~1.56%; Range2_3+6.25~15.63%; Case03 미판정Pending 그대로. |
| 165 | 가장 균형 좋은 정책 | 현재 KEEP_MAJOR_1이 요구한 balance를 가장잘 유지. 변경 후보중 Range1_2는 비용작은 A/B 후보. |
| 166 | 정책 추천 | KEEP_MAJOR_1 추천, 실제제품 유지. |
| 167 | 추천하지 않은 정책 이유 | Fixed2 결정성 유지/거리증가, Range1_2 B/C 개선없음, Range2_3/Fixed3 노출·잔여·Stage 비용 증가. |
| 168 | 사람 플레이테스트 필요 여부 | Current1 vs Range1_2 비용차이 작으므로 실제채택 판단에는 사람 A/B 필요; 이번 사람테스트0. |
| 169 | threshold가 핵심 원인인지 | readiness A는 threshold 직접원인; B/C·final차단은 checkpoint/opportunity구조 영향이 더 큼. |
| 170 | presentation checkpoint 영향 | 표시Stage와 클릭한버튼 구별; Next/read/Confirm/finaldisabled 경쟁이 핵심. |
| 171 | random range 효과 | range는ready variance만확실; random=공포/예측불가 아님, 실제표시는 gate로희석. |
| 172 | Fixed threshold 효과 | fixed2/3은정해진기회로지연, fixed3 클릭전부EXP Next61/61. |
| 173 | 다음 구현 여부 | 이번threshold 구현0; 추천안도적용하지 않음. |
| 174 | 다음 Step 추천 | 선택C: threshold유지 + 명시적최종disposition책임/Run identity·멱등성 계약 우선; 구현은별도. |
