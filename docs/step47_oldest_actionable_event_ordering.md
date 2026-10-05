# Step47 — Oldest Actionable Event Ordering

2026-10-05 · Godot `4.7.1.stable.official.a13da4feb` · GDScript · Windows · GL Compatibility.

**현재 경계에서 실제 표시 가능한 이벤트를 후보 등록 순서로 하나 선택하도록 변경했다.** Old Major/New Disturbance가 모두 actionable인 CCTV/Containment에서는 Old Major가 먼저다. invalid/unready/non-presentable 후보는 삭제·완료하지 않고 건너뛴다. 단일 후보 흐름, 실험 결과 읽기 경계, source/current/Archive/Runtime 분리와 Step46 Snapshot 계약은 유지한다.

## 조사와 범위

작업 시작 `master` → `origin/main`, HEAD `79955a147ece4398d59d76bc49e3f123423cdc17` (`Extend three-case prototype and document event pacing policies`), remote `https://github.com/rudgns15251-ctrl/ccc.git`. 시작 미커밋은 Step46 README/Main 수정2개와 보고서/Snapshot/UID 추가3개다. commit/push/stage 없이 이 변경을 baseline으로 취급했다.

저장소 전체113파일, project.godot, Main Scene/Script, 15 Scenes/40 GDScripts/3 Case Resources, 7 State와 read model, UI/Signal/opportunity/response lookup, Step41~46 보고서 및 기존 검증을 조사했다. 적용할 AGENTS.md 없음. 기준1920×1080, 초기1280×720, canvas_items/keep/resizable, GL Compatibility와 Main 경로 불변. Autoload0.

이번 제품 수정은 `scripts/main/main.gd`의 기회 처리 구간뿐이다. 기존 D validation/presentation을 작은 helper로 이동하고, 분리된 D/M 두 scan을 등록 순서 한 scan으로 바꿨다. Main1,616→1,629줄/85→87함수(+13줄/+2 private functions). `README.md`에는 Step47 block만 추가했다. 새 tracked 대상은 이 보고서1개다. State/Data/Resources/Views/Scenes/read model/project 변경0, 삭제0. 검증 사본·runner·로그·JSON·PNG는 ignored `.godot/verification/step47/` 아래다.

## 선택 계약

```text
기존 Runtime/View/Notice/Response/key/opportunity guard
→ processed key 승인
→ 모든 해당 후보의 Major count 증가
→ 모든 해당 후보의 Disturbance count 증가
→ get_candidate_case_ids() 등록 순서 scan
   → 후보의 현재 phase/content/boundary에서 presenter 성공 시 즉시 return
   → invalid/unready/이미 적용 등 표시 불가면 다음 후보
```

`_try_present_oldest_actionable_event(disturbance_ready, major_ready) -> bool`은 승인된 기회 처리 함수에서만 호출한다. 선택과 실제 시도를 한 scan에서 수행하여 기존 Major content validator를 복제하지 않는다. 선택 실패는 다음 후보로 진행하고, 실제 표시가 성공했을 때만 true를 반환한다. 별도 반환 Resource/event record, timestamp, 절대 event ID, enum, priority score, severity, bypass counter, Framework를 만들지 않았다.

공통 guard는 current View identity/tree/queued/visible, current Case/Runtime/index identity, active response/normal interruption 부재, Notice 부재, 유효한 최초 gameplay key다. 기존 `_is_active_view`가 Notice 중 false이며, guard는 count/key 변경 전에 실행한다. 이미 ACTIVE/COMPLETED response record가 있는 후보는 재선택하지 않는다.

D는 아직 disturbance 미표시/count 도달/hidden Failure Resolution과 Incident ID 일치/unique source 및 Incident/유효 D 이름·Notice·condition 문구가 필요하다. 현재 Runtime의 같은 `(disturbance_id,reaction_id)`가 이미 적용되었으면 기존 `try_apply_disturbance` false로 뒤 후보를 시도한다. 유효 D가 실제 적용된 뒤 flag→조건 refresh→Notice→optional reaction discovery 순서를 유지한다.

M은 disturbed/count 도달/미trigger/response 미존재/Failure Resolution 일치/unique source·Incident·Broadcast/하나 이상의 유일·유효 Option/Result chain이 필요하다. production selector는 기존 CCTV/CONT 경계에서만 M을 시도한다. 기존 `_try_start_major_incident`의 직접 EXP 호출 호환 계약은 바꾸지 않았다. production EXP callback에서는 Major UI0이며 결과/ready 사실만 유지한다. EXP에서 old M과 young D가 경쟁하면 M은 현재 non-presentable이므로 D를 선택한다.

동일 후보는 D→M 순서다. Major count를 D 적용 전에 증가시키므로 새 D가 자기 action에서 M ready를 만들지 않는다. Dismiss/Resume/Log/Archive/idle/focus/scroll/Recheck/중복·invalid·limit초과 EXP/CONT 재진입은 새 기회가 아니다. Resume는 `_show_view(return_stage,false)`와 기존 key/Runtime을 유지한다.

content invalid의 기존 warning/false/continue 정책을 유지한다. invalid 후보 retain/skip과 runtime View 생성 오류를 구분한다. 검증된 preloaded Scene의 instantiate/add_child가 실패하는 경우를 새 복구 시스템으로 처리하지 않았다. 원래 presenters도 State 승인 후 View를 생성하며, 이 ordering 변경은 Scene 생성의 transaction/recovery 계약을 새로 도입하지 않는다. 정상 Scene parsing/실행·GPU 검증에는 해당 실패가 없었다.

## Controlled Ordering Matrix

각 핵심 조합을 CCTV와 CONT 모두 새 Godot로 확인했다. Snapshot 반복10회 후 selection도 동일하며, 생성 순서 역등록 Case02→Case01에서 Case02가 먼저 나와 Case sequence/문자열 sorting 사용이 없음을 확인했다.

| 조합 | 선택/남는 사실 |
|---|---|
| Old M / New D | Old M; New D-ready retain. Resume 자체에서는 새 Notice0 |
| Old D / New M | Old D; New M retain |
| Two M | 먼저 등록한 M |
| Two D | 먼저 등록한 D |
| Old unready / New ready | New D; old count 미달 상태 retain |
| Old invalid / New valid | old invalid warning/retain, New D→후속 M 정상 |
| Old valid / New invalid | Old M; invalid new 후보 소비0 |
| 역등록 Two M | Case02→Case01 등록 시 Case02 M |
| unD + 비정상 M count1 | D부터; 같은 action M 표시0 |
| EXP old M / young D | young D→Dismiss→EXP 결과 draw; 다음 CONT old M |
| M→Resume→fresh EXP | same Runtime; 즉시 event0, 실제 다음 Run에 young D |
| synthetic A/B/C | M(A)→D(B)→M(B)→D(C)→M(C); 완료 후 상대 순서 compact |

기존 Major 검사에서 유효 Broadcast/Option/Result가 없으면 M은 invalid이다. D의 actionability는 기존대로 Incident/D content로 판단하며, 선택적 reaction이 없거나 이후 Major chain이 invalid라는 이유로 이미 유효한 시설 D 자체를 새로 차단하지 않는다.

synthetic 후보·content은 메모리 clone fixture에만 있다. 제품 Case04/새 정상 opportunity는 없다. 유한 유효 집합과 충분한 기회에서 진행했음을 검증하며, 임의 workload 전체 starvation/무한 fairness를 주장하지 않는다.

## 144 경로 Before / After

비교 원본은 보존된 Step44 결과와 Step46의 동일144 matrix다. 새 Step47 실행16개에서144개의 실제 버튼 Journey를 측정했다. Scene tree native input은 실제 Mouse motion/down/up/ScrollContainer.ensure_control_visible를 사용한다. source Resource는 deep clone하며 actual Run/Confirm/Next/Archive/Resume 버튼을 눌렀다.

| 측정 | Before Step44/46 | After Step47 |
|---|---:|---:|
| Journeys | 144 | 144 |
| Disturbances | 179 | 170 |
| Majors | 122 | 131 |
| Broadcasts | 122 | 131 |
| Interruptions | 301 | 301 |
| Eligible | 1296 | 1296 |
| Meaningful | 1296 | 1296 |
| Ratio | 0.232253086419753 | 0.232253086419753 |
| CCTV | 36 | 36 |
| Containment | 86 | 95 |
| StrictMin | 0 | 0 |
| StrictMax | 4 | 4 |
| StrictZero | 75 | 75 |
| CausingMin | 0 | 0 |
| CausingMax | 4 | 4 |
| CausingZero | 63 | 63 |
| Unresolved | 94 | 85 |
| UnresolvedJourneys | 82 | 82 |
| UNDISTURBED 잔여 | 37 | 46 |
| DISTURBED_NOT_READY 잔여 | 40 | 31 |
| MAJOR_READY 잔여 | 17 | 8 |

**변경9 / 동일135.** FF81 중9개의 마지막 Case03 CONT에서 D02 대신 M01을 표시한다. FF 나머지72, FS27, SF27, SS9의 Event order와 final candidate facts는 동일하다. 모든144의 threshold/실험량/failure route/eligible·meaningful count/final Pending·Resolution 및 각 eligible action 직전의 순서 있는 candidate/counters가 동일하다. 변경은 마지막 경쟁 slot의 presentation과 그에 따른 완료·연구 노출 사실이다.

각 원래 bypass는 Case03 CONT의 승인된 count 증가 후, Old Case01 `MAJOR_READY`와 New Case02 `UNDISTURBED`(D-ready)가 동시에 actionable인 상태다. 표의 경쟁 phase는 selection 시점이며, 해당 action 전에는 old Major count가0인 경로도 있다. Before는 D02를 선택해 M01을 남겼고, After는 M01을 선택·응답 완료하여 D02-ready를 남긴다. 아래 표의 `D01/M01`은 source Case01, `D02/M02`는 source Case02이며 `@03/CONTAINMENT`는 current Case/return Stage다.

| Journey | Old source/phase | New source/phase | Before order | After order | Selected Before→After | Before leftover | After leftover |
|---|---|---|---|---|---|---|---|
| FF_32_e00 | Case01 / MAJOR_READY | Case02 / UNDISTURBED (D-ready) | D01@03/CCTV → D02@03/CONTAINMENT | D01@03/CCTV → M01@03/CONTAINMENT | D02→M01 | 01:MAJOR_READY(D3/3,M1/1); 02:DISTURBED_NOT_READY(D2/2,M0/1) | 02:UNDISTURBED(D2/2,M0/1) |
| FF_33_e01 | Case01 / MAJOR_READY | Case02 / UNDISTURBED (D-ready) | D01@03/CCTV → D02@03/CONTAINMENT | D01@03/CCTV → M01@03/CONTAINMENT | D02→M01 | 01:MAJOR_READY(D3/3,M1/1); 02:DISTURBED_NOT_READY(D3/3,M0/1) | 02:UNDISTURBED(D3/3,M0/1) |
| FF_34_e02 | Case01 / MAJOR_READY | Case02 / UNDISTURBED (D-ready) | D01@03/CCTV → D02@03/CONTAINMENT | D01@03/CCTV → M01@03/CONTAINMENT | D02→M01 | 01:MAJOR_READY(D3/3,M1/1); 02:DISTURBED_NOT_READY(D4/4,M0/1) | 02:UNDISTURBED(D4/4,M0/1) |
| FF_42_e01 | Case01 / MAJOR_READY | Case02 / UNDISTURBED (D-ready) | D01@03/EXPERIMENT → D02@03/CONTAINMENT | D01@03/EXPERIMENT → M01@03/CONTAINMENT | D02→M01 | 01:MAJOR_READY(D4/4,M1/1); 02:DISTURBED_NOT_READY(D2/2,M0/1) | 02:UNDISTURBED(D2/2,M0/1) |
| FF_42_e10 | Case01 / MAJOR_READY | Case02 / UNDISTURBED (D-ready) | D01@03/CCTV → D02@03/CONTAINMENT | D01@03/CCTV → M01@03/CONTAINMENT | D02→M01 | 01:MAJOR_READY(D4/4,M1/1); 02:DISTURBED_NOT_READY(D2/2,M0/1) | 02:UNDISTURBED(D2/2,M0/1) |
| FF_43_e01 | Case01 / MAJOR_READY | Case02 / UNDISTURBED (D-ready) | D01@03/EXPERIMENT → D02@03/CONTAINMENT | D01@03/EXPERIMENT → M01@03/CONTAINMENT | D02→M01 | 01:MAJOR_READY(D4/4,M1/1); 02:DISTURBED_NOT_READY(D3/3,M0/1) | 02:UNDISTURBED(D3/3,M0/1) |
| FF_43_e11 | Case01 / MAJOR_READY | Case02 / UNDISTURBED (D-ready) | D01@03/CCTV → D02@03/CONTAINMENT | D01@03/CCTV → M01@03/CONTAINMENT | D02→M01 | 01:MAJOR_READY(D4/4,M1/1); 02:DISTURBED_NOT_READY(D3/3,M0/1) | 02:UNDISTURBED(D3/3,M0/1) |
| FF_44_e02 | Case01 / MAJOR_READY | Case02 / UNDISTURBED (D-ready) | D01@03/EXPERIMENT → D02@03/CONTAINMENT | D01@03/EXPERIMENT → M01@03/CONTAINMENT | D02→M01 | 01:MAJOR_READY(D4/4,M1/1); 02:DISTURBED_NOT_READY(D4/4,M0/1) | 02:UNDISTURBED(D4/4,M0/1) |
| FF_44_e12 | Case01 / MAJOR_READY | Case02 / UNDISTURBED (D-ready) | D01@03/CCTV → D02@03/CONTAINMENT | D01@03/CCTV → M01@03/CONTAINMENT | D02→M01 | 01:MAJOR_READY(D4/4,M1/1); 02:DISTURBED_NOT_READY(D4/4,M0/1) | 02:UNDISTURBED(D4/4,M0/1) |

이9개는 모두 **마지막** safe boundary다. 따라서 정상3Case 흐름에서는 Resume 뒤 D02를 실제 표시할 새 기회가 없으며, 미처리 상태로 남는 것이 이번 정책의 올바른 결과다. 억지로 CONT key를 지우거나 Case04를 만들어 정상 Journey라고 보고하지 않았다. 후속 fresh opportunity에서 D가 진행하는 계약은 통제 fixture의 실제 Case03 Run에서 따로 확인했다.

Snapshot은 등록 순서/phase/count와 완료 사실을 읽기만 한다. 마지막 Case03 `UNRESOLVED_SUBMISSION`, Outcome0, Next disabled가 모두 유지된다. M 표시가9회 증가해 그 source의 Incident/Broadcast/Option/Result Research가 더 발견되고, 대신9회 미표시된 D의 현재 reaction/condition 관찰은 아직 발견되지 않는다. 이것은 authored Resource/merge 규칙 변경이 아니라 실제 노출 차이다.

## 새 실행 검증 및 보존

최종 **310개 process 실행 PASS**: product parse40개를 포함하는 legacy core200 + Step4016 + Step4220 + Step4332 + Step44/46 matrix·queue24 + import/configured Main3 + Snapshot10 + 새 Ordering5. 각 인증의 실제 exit0/log hash/expected warnings를 확인했다. normal product/import/Main/matrix/visual warnings0, 최종 Parse/Script/runtime error0. 예상 invalid/guard fixture warnings 1378개이며 이전 queue21→28/회는 older invalid source/Incident/Broadcast 검사 시도가7개 늘었기 때문이다. 새 Ordering invalid Broadcast 검사는4개/모드다. 초기 diagnostic/preparatory 재시도는 최종310에 더하지 않았다.

새 controlled ordering은 headless/native 각각2,125 assertions, 합4,250을 통과했다. 기존 Snapshot10실행은1,564 assertions/74 probe이며 두 합을 full legacy assertion 수로 부풀리지 않는다. 144 matrix는 Journey 수이고16개 process 실행이며, baseline visual6실행에 dense/Success12 Journey, 별도 ordering GPU3실행에2개씩6 Journey가 있다. 나머지 오래된 복합 suite의 내부 assert 총량은 별도로 합산하지 않았다.

GPU는1920×1080/1280×720/1024×768에서 native Windows OpenGL Compatibility로 실제 frame_post_draw·PNG를 확인했다. `FF_32_e00`에서 마지막 경쟁 slot의 Case01 Major/SOURCE CASE01/CURRENT CASE03/CONTAINMENT/Archive/Resume를 확인했다. `FF_42_e22`의 Case01 Major→same Runtime CCTV Resume→fresh EXP의 Case02 air-line Notice와 실제 EXP 결과 draw도 확인했다. captures의 레이아웃/Source·Current 표기·단일 hosted View·비율 유지에 새 깨짐이 없었다. 사람의 공포/피로/자연스러움 평가는 수행하지 않았다.

Step46의 Main은 HEAD Main에 현 Snapshot 함수를 삽입하면 시작 baseline hash `FBDEFFE40A84B0BBB825FDF8AED5B3E31055136AC805A79FC64D6BF5F9F1CAA4`와 정확히 일치한다. 이것과 현재 Main의 차이는 opportunity handler와 두 helper뿐이며 Snapshot 함수와 나머지 Main은 동일하다. README는 새 block 제거 시 시작 hash와 동일하다. 113 baseline 파일 중 허용 README/Main 외111개, 과거 검증8,737개 hash 동일. staged0/삭제0/HEAD·branch·upstream 유지, git diff --check 및 신규 보고서 whitespace PASS. 기존 Step463추가파일도 그대로 보존했다.

검증 준비 중 profile 설정 파일을 사본 대상에 포함해 없는 출력 폴더 오류가 있었지만, 그것은 제품 파일이 아니며 새 runner가 격리된 profile을 만들었다. 최초 ordering test는 재사용한 `_run_and_read`가 자동 Dismiss까지 수행하는 사실 때문에 “Notice가 남아 있음”이라는 잘못된 assertion에서 실패했다. 해당 test를 실제 Select/Run 입력으로 바꾸고 모든 최종 로그를 새로 실행했다. 제품 오류를 숨기거나 기대값을 임의 완화하지 않았다. 기존 copied Step43 edge의 disturbance-first assertion도 old M→Resume→fresh EXP young D→CONT young M 계약으로 바꿔 새 실행했다. copied queue의 `[Old M/New D]` 및3후보 기대 순서만 승인된 새 정책에 맞게 수정했고, invalid warning 증감도 실제 검증 attempt 수에 근거해 기록했다.

## Findings와 다음 단계

| Finding | 판정 | 근거/남는 범위 |
|---|---|---|
| F44-02 disturbance-first age inversion | **RESOLVED** | 같은 안전 경계에서 actionable old M 우선; 실제 bypass9개 모두 제거. EXP/non-ready/invalid skip은 별도 사실 |
| F01 readiness/presentation predictability | **OPEN / P2 GAME DESIGN** | Major1 유지; CCTV/CONT에만 표시, CONT 집중 남음 |
| F44-01 strict meaningful spacing0 | **OPEN / P2 GAME DESIGN/UX** | 새 research/read gate 없음; 최소0 여전 |
| F07-B final disposition | **PARTIALLY ADDRESSED / P2** | Step46 read-only Snapshot foundation만; Run closure/Settlement/자동 전환 없음 |

새 P0/P1 CODE bug는 재현되지 않았다. 순서 공정성 개선을 pacing/UX 전체 해결로 확장하지 않는다. 마지막 opportunity에 old 의무를 먼저 소비하므로 미표시 전조가 늘 수 있고, 무작정 오래된 *후보*를 대기시키는 gate를 만들면 head-of-line block이 다시 생길 수 있다.

다음 작업은 별도의 **Meaningful Research / Read Boundary Pacing Gate**가 적합하다. readiness counter 증가와 display permission을 분리하고, EXP 결과 실제 읽기 경계/새 source 연구의 승인 계약을 먼저 정의해야 한다. Dismiss/Resume/Archive/idle/recheck를 연구 credit으로 쓰거나, gate 거절에서 flag/key/RNG를 재소비하지 않도록 해야 한다. last boundary leftovers와 실제 source/current/Archive/Runtime도 재측정한다. 이번에는 gate/Run/Settlement/Save·Load/성공 독립 사건/Case04/Case03 Outcome/새 UI·Shader·Audio를 추가하지 않았다.

## 요청한 종료 보고 144개 항목

| 번호 | 요청 항목 | 결과/근거 |
|---:|---|---|
| 1 | 작업 전 Git 상태 | 시작 수정 README/Main 2개, untracked Step46 보고서/Snapshot/UID 3개. source-before113파일과 과거 검증8,737개 hash 기록. |
| 2 | HEAD / branch / upstream | 79955a147ece4398d59d76bc49e3f123423cdc17; master → origin/main; remote rudgns15251-ctrl/ccc.git. 변경 없음. |
| 3 | Step46 미커밋 변경 | Step46 Main Snapshot 함수53줄과 README block, 보고서/Read Model/UID 보존. Main 원본을 정확한 baseline hash로 복원해 이번 차분 분리. |
| 4 | Step46 Snapshot 기준 | detached read model, deep copy, 읽기 전용 phase/relative order/Case03 Pending 관찰. 종료 처리나 선택의 State Source of Truth가 아님. |
| 5 | 기존 ordering 코드 위치 | 기존 Main _try_process_failure_event_opportunity 내부 분리된 D loop→EXP return→M loop. |
| 6 | 기존 disturbance-first 규칙 | D-ready FIFO를 먼저 모두 시도하고, D를 표시하지 않았을 때만 M-ready FIFO. safe boundary에서도 새 D가 old M을 우회. |
| 7 | 새 ordering 정책 | 실제 등록 순서로 scan; 현재 boundary에서 실제 표시 가능한 첫 Event 1개. invalid/unready/non-presentable 후보는 retain/skip. |
| 8 | created order Source of Truth | FailureEventCandidateState._case_order / get_candidate_case_ids(). Case ID 사전순·Case sequence·Archive 순서를 사용하지 않음. |
| 9 | new absolute order ID 추가 여부 | 추가0. 기존 relative order만 사용. |
| 10 | selector 구현 위치 | Main._try_present_oldest_actionable_event(); 기존 opportunity guard/count 승인 뒤에만 호출되는 private helper. |
| 11 | selector return type | bool: 실제 표시 성공 여부. 별도 event record/Resource 보관 없이 scan 중 기존 presenter를 시도해 validation 중복을 피함. |
| 12 | generic Event framework 미추가 | Framework0. 순서 scan과 기존 D presenter 분리만 추가. |
| 13 | Disturbance actionable 조건 | 유효 과거 source/resolution/Incident/D content; !disturbed; count≥threshold; response 기록 없음; 현재 Runtime에 적용 가능한 기존 opportunity. |
| 14 | Major actionable 조건 | disturbed; M count≥threshold; !majorTriggered; response 없음; source/Incident/Broadcast와 하나 이상의 유일·유효 Option/Result chain; safe Stage. |
| 15 | current Stage 조건 | Major CCTV/CONT만; EXP에서 D는 기존대로 가능. Profile/Log/Archive에는 새 checkpoint 없음. |
| 16 | content validation 조건 | 기존 _find_failure_source_case/_unique_response_content 및 Major display/usable chain 검사 그대로 재사용; D 기존 검사를 이동. |
| 17 | active response guard | 기존 normal interruption/active response early return이 key·count mutation보다 앞에 있음. |
| 18 | notice guard | 기존 _is_active_view가 유효 Notice 동안 false. 새 selection·counter·nested Major 차단. |
| 19 | invalid candidate skip | 기존 warning/false/continue로 뒤 후보 진행. source/Incident/resolution/Broadcast invalid 복사 fixture 검증. |
| 20 | unready candidate skip | ready 배열에 없는 후보 건너뜀. Old threshold4 count0/New D-ready에서 New D 선택. |
| 21 | strict oldest Candidate 미사용 | 무조건 맨앞을 기다리는 FIFO queue 아님. 맨앞이 지금 표시 불가하면 뒤 actionable 후보 진행. |
| 22 | oldest actionable 정의 | phase/count/content/current boundary/guard를 모두 만족하여 실제 표시 가능한 후보 중 등록 순서 첫째. |
| 23 | same Candidate D→M 보존 | D 미표시 후보는 advance_major가 건너뜀. 비정상 M count1 fixture에서도 D 먼저; 동일 action의 새 D는 Major count0. |
| 24 | Old M/New D 결과 | CCTV·CONT 모두 Old Case01 M. EXP에서는 old M non-presentable이므로 New D; 타입 우선순위가 아님. |
| 25 | Old D/New M 결과 | CCTV·CONT 모두 Old Case01 D. |
| 26 | Two M 결과 | CCTV·CONT 모두 먼저 등록된 M. 역등록 Case02→Case01 fixture에서는 Case02 M. |
| 27 | Two D 결과 | CCTV·CONT 모두 Old Case01 D. |
| 28 | Old unready/New ready | Old 미달 count 유지하며 New D 선택; head-of-line block 없음. |
| 29 | Old invalid/New valid | Old invalid Broadcast M warning/retain, New valid D. copied queue의 source/Incident/resolution invalid도 통과. |
| 30 | Old valid/New invalid | Old valid M을 먼저 표시; 뒤 invalid D는 소비/삭제하지 않음. |
| 31 | invalid retain 여부 | 삭제/완료/복구 없음. Snapshot·Candidate getter에 남아 다시 관찰 가능. |
| 32 | fallback 없음 | content fallback/repair 없음. 선택적 reaction 미존재 처리는 기존 정책 그대로. |
| 33 | one opportunity one event | D 또는 M presenter 성공 즉시 bool true return. 기회당 둘 다 표시하지 않음. |
| 34 | Dismiss 새 event 없음 | Dismiss는 View 복귀·조건 관찰만; key/count/selection 호출 없음. ready others를 즉시 표시하지 않음. |
| 35 | Resume 새 event 없음 | Resume는 _show_view(return_stage,false). 같은 Runtime/key 유지; 다음 fresh opportunity에서만 재평가. |
| 36 | EXP same-callback Major 없음 | 생산 opportunity selector의 M branch는 CCTV/CONT 조건. EXP same-callback M0; 직접 private Major 호출 호환 fixture는 기존대로 유지. |
| 37 | EXP read boundary | EXP 결과 draw/12frame idle 검증 유지; EXP에서 old M skip·New D 후 Dismiss 결과 보존, CONT에서 Old M. |
| 38 | CCTV boundary | 기존 cctv:entry 최초1회 승인. D/M 모두 현재 actionable이면 등록 순서 선택. |
| 39 | Containment boundary | 기존 containment:entry 최초1회 승인. Room Confirm은 새 event checkpoint가 아님. |
| 40 | Profile non-opportunity | Profile key 승인 없음. UI 표시/읽기/메모가 counter를 진행하지 않음. |
| 41 | Log/Archive non-opportunity | current Log/일반 Archive/Source Archive Open·Back에 selection 없음. ready 후보/counter/RNG 유지. |
| 42 | Recheck farming 없음 | Recheck CCTV는 같은 key 소비0. 새 State·Event 생성 없음. |
| 43 | duplicate Experiment | 같은 ID 재실행/invalid/limit초과는 Run 승인 실패; count/key 변화 없음. |
| 44 | Containment reentry | 같은 Runtime containment entry 재진입은 processed-key로 차단. |
| 45 | processed key | 기존 Case별 _processed_opportunities 보존; handoff만 clear, Resume·Dismiss 유지. |
| 46 | stale View | 현재 View identity/tree/queued/visible 및 Runtime/index identity guard. 실제 stale signal 회귀 유지. |
| 47 | Case handoff candidate order | handoff가 후보 State 객체/등록 순서를 유지. 144 matrix pre-opportunity ordered records 동일. |
| 48 | completion 후 order | 완료 source만 기존 remove_completed_candidate로 제거; Case02가 상대 order0가 됨. |
| 49 | 새 Candidate append order | synthetic C는 A/B 뒤 append. stress M(A)→D(B)→M(B)→D(C)→M(C), 5 fresh safe keys에 완료. |
| 50 | CandidateState 변경 | CandidateState 수정0. |
| 51 | IncidentResponseState 변경 | IncidentResponseState 수정0. |
| 52 | Snapshot 변경 | Snapshot Script/UID 및 Main Snapshot 함수 수정0; byte/범위 검사. |
| 53 | Snapshot order | Snapshot created_order는 살아 있는 candidate의 현재 relative index; 완료 후 compact. 새로운 절대번호 없음. |
| 54 | Snapshot idempotency | 10회 반복마다 facts/RNG/keys 동일. Step46 phase/deep-copy/isolation 및 새 선택 전 반복 probe 통과. |
| 55 | normal Case01-only Failure | FS 27개 matrix와 기존 carry 회귀; Event order/counters/final facts 동일. |
| 56 | normal Case02-only Failure | SF 27개 matrix와 기존 case2 회귀; Event order/counters/final facts 동일. |
| 57 | dual Failure | FF81개 중 safe inversion9개 변경, 나머지72개 동일. 다른 State/content 규칙 유지. |
| 58 | all Success | SS9개 및 dense Success native: Candidate/Event0 유지. |
| 59 | actual Old M/New D normal Journey | 실제 FF_32_e00 CONT에서 Case01 M 선택; FF_42_e22에서는 old M→Resume→fresh EXP New D를 실제 버튼/GPU 검증. |
| 60 | Step44 priority bypass9 재실행 | 9개 모두 새 144 matrix에 포함·재실행. 아래 Before/After 표 참조. |
| 61 | 각 bypass 기존 order | 9개 모두 source01 D→source02 D; Old Case01 MAJOR_READY가 마지막에 retain. |
| 62 | 각 bypass 새 order | 9개 모두 source01 D→source01 M; New Case02 D는 다음 fresh boundary까지 retain. |
| 63 | final leftover 변화 | 미처리 Candidate 94→85, 잔여 Journey 82→82. Snapshot으로 phase/count 비교; pending Case03/hidden resolution 동일. |
| 64 | total Disturbance | 179→170. |
| 65 | total Major | 122→131. |
| 66 | total Broadcast | 122→131. |
| 67 | interruptions | 301→301 (총량 불변). |
| 68 | Event/action ratio | 0.2323→0.2323; eligible/meaningful 각각 1296→1296. 균등 fixture 표본 비율이며 플레이어 확률/체감 아님. |
| 69 | strict spacing | min/max 0/4→0/4; zero gap 75→75. |
| 70 | causing spacing | min/max 0/4→0/4; zero gap 63→63. |
| 71 | CCTV Major 수 | 36→36. |
| 72 | Containment Major 수 | 86→95. |
| 73 | F01 재측정 | M1/readiness 유지, CONT presentation 비중 70.5%→72.5%. F01 OPEN. |
| 74 | F44-01 재측정 | 완료한 새 연구 행동0 간격 여전. F44-01 OPEN. |
| 75 | F44-02 재측정 | 안전 경계에서의 9개 age inversion 모두 제거. EXP 비표시는 read-boundary이며 inversion으로 집계하지 않음. |
| 76 | F07-B 상태 | F07-B PARTIALLY ADDRESSED. Snapshot 기반 관찰만 있고 final Run 책임 이전/closure 없음. |
| 77 | threshold 불변 | D2~4/M1 상수·sample 코드 byte/범위 불변; 144 threshold 값 동일. |
| 78 | RNG 불변 | 생산 seed/randomize/randi 방식 변경0. Snapshot read/no-RNG 계약 및 각 경로 threshold 동일. |
| 79 | pacing gate 미구현 | meaningful/read credit/gate 추가0. |
| 80 | new presentation checkpoint 없음 | CCTV Next/EXP Next 새 checkpoint 추가0. |
| 81 | Scripted Incident 없음 | 성공 독립 시설 사건 없음. |
| 82 | Run/Settlement 없음 | Run/Settlement/closure/자동 conversion 없음. |
| 83 | Case03 Outcome 없음 | Case03 Resource 불변; Outcome0·UNRESOLVED_SUBMISSION·Next disabled 유지. |
| 84 | Current Runtime identity | 각 response에서 actual Runtime 인스턴스 동일, current Case03 유지. |
| 85 | other Candidate 보존 | response/Archive/Resume 동안 다른 후보 records/counters/flags/order 보존. 기회 승인 시 모든 해당 후보의 기존 count 증가만 허용. |
| 86 | Source Case 정확성 | Case01·Case02 응답 source unique lookup; 실제 SOURCE CASE label 검증. |
| 87 | Current Case 정확성 | interrupted Case03과 return CCTV/CONT 표시; current_case가 source로 바뀌지 않음. |
| 88 | Archive target | Source Archive가 해당 Response source Case를 사용. 현재 Case03 Log/notes와 분리. |
| 89 | Archive incremental merge | 응답의 실제 단계 노출/Option 확정별 source Archive incremental merge 유지. 바뀐 Event 노출 때문에 9경로 discovered IDs 차이는 의도된 관찰 결과. |
| 90 | Research isolation | current Runtime에 source response Research 쓰지 않음; 다른 Case Archive 변경 없음. |
| 91 | Hypothesis isolation | source 메모 읽기/current notes 편집 분리; Case별 WorkingHypothesis 보존/평가 없음. |
| 92 | same Runtime Resume | Resume Runtime 동일; return stage·confirmed locks·EXP recorded result 복원 회귀 유지. |
| 93 | nested Event 없음 | Notice/active Response 동안 새 Event 없음. |
| 94 | response 완료 후 즉시 다음 Event 없음 | Response completed callback에서 다음 selection 호출 없음; next fresh key가 필요. |
| 95 | debug SUCCESS | 실제 debug SUCCESS/RESULT 흐름 copied regression 통과. |
| 96 | debug FAILURE | debug FAILURE/Incident/Broadcast/confirmed Option/Result copied regression 통과. |
| 97 | normal/debug 분리 | debug route는 normal Candidate 순서 소비0. 복사된 debug Main fixture로 과거 경로만 검사. |
| 98 | Resource 불변성 | State/Data/Resource/View/Scene/project 파일 이번 변경0, validation 전후 hash 동일. |
| 99 | Main line count | Main 1,616→1,629줄(마지막 newline 빈 항 제외), +13줄. |
| 100 | Main function count | 85→87함수, +2 private helpers. |
| 101 | Main 책임 변화 | boundary/key/counter orchestration은 그대로. 타입별 두 scan을 등록 순서 한 scan으로 교체. |
| 102 | helper 추가 | _try_present_oldest_actionable_event, _try_present_candidate_disturbance. 기존 content 검사 재사용/이동; read-only 별도 validator 중복 없음. |
| 103 | Manager 추가 여부 | Manager 추가0. |
| 104 | Singleton/Autoload 여부 | Singleton/Autoload0; project.godot 불변. |
| 105 | Event enum 여부 | 새 Event enum0. existing Stage/IncidentRoute만 유지. |
| 106 | Severity 없음 | Severity 추가0. |
| 107 | bypass counter 없음 | bypass counter 추가0. |
| 108 | numeric priority 없음 | numeric priority 추가0. |
| 109 | offline validator 없음 | offline ContentValidator 추가0. |
| 110 | product parser | 40개 product GDScript --check-only 새 실행 통과. |
| 111 | editor import | Godot4.7.1 editor import 새 실행 통과. |
| 112 | Main headless | configured Main headless --quit-after30 새 실행 통과. |
| 113 | Main native | configured Main native GL Compatibility 새 실행 통과. |
| 114 | full regression | 최종310회 process 실행(기존 core200+16+20+32+24+3+Snapshot10+새 Ordering5); 전부 새 실행 PASS. 과거 성공 로그로 대체하지 않음; input/log hash 검증. |
| 115 | Step46 regression | Step46 snapshot10실행·1,564 assertion·74 probe 통과. phase/idempotency/deep copy/Case03/no RNG/key mutation 유지. |
| 116 | Step44 144 matrix 새 실행 | 16개 matrix 실행에서144 actual-button journeys. policy-specific copied Step43 edge/Step44 queue 기대값만 변경. |
| 117 | 3해상도 | 1920×1080 /1280×720 /1024×768 native dense/Success/ordering. UI1920×1080와 keep scaling/단일 hosted View 유지. |
| 118 | GPU actual draw | GPU 캡처/실제 frame 증가/Context label·layout 확인. inversion 마지막 경계는 후속 기회가 없어 New D가 남는 것이 정상; later-D GPU는 별도 실제 FF_42_e22와 통제 fresh EXP fixture. |
| 119 | warning | 1378개 예상 fixture warning; queue21→28/회는 older invalid 후보를 먼저 시도하는7개 diagnostic 증가, 새 Ordering4/모드. normal product/import/Main/matrix/visual warnings0; invalid/ambiguous/guard probe 예상 경고는 별도 합산. |
| 120 | runtime error | 최종 성공 인증 로그 runtime error0. 최초 새 test helper는 자동 Dismiss 때문에 잘못된 assertion 실패, helper 호출 수정 후 재실행 통과. |
| 121 | parse error | 제품/최종 검증 Parse Error0. |
| 122 | 실제 변경 파일 | 이번 수정 README.md, scripts/main/main.gd. HEAD diff에는 이전 Step46 변경도 보임; baseline diff로 구분. |
| 123 | 생성 파일 | 이번 tracked 대상 생성 docs/step47_oldest_actionable_event_ordering.md 1개. 새 검사·사본·로그는 ignored .godot/verification/step47에만 생성. |
| 124 | 삭제 파일 | 이번 삭제0. |
| 125 | git diff --check | git diff --check 및 새 보고서 whitespace 검사 PASS. |
| 126 | staged 여부 | staged0. git diff --cached empty. |
| 127 | 기존 변경 보존 | 113 baseline 파일 중 허용 README/Main 외111 hash 동일; 기존 검증8,737 hash 동일. Step46 원본 Main 재구성 hash 일치 및 Snapshot 함수 불변. |
| 128 | commit/push 없음 | HEAD/branch/upstream 유지; commit/push 미실행. |
| 129 | 발견 CODE bug | 새 P0/P1 CODE bug 재현 없음. 기존 D-first age inversion은 이번 요청한 selection 정책 문제로 좁혀 수정. |
| 130 | 발견 UX 변화 | 옛 source Major가 먼저 나타나고 source/current context·Archive는 유지. 인간의 자연스러움/공포/피로 향상은 검증하지 않음. |
| 131 | 발견 GAME DESIGN 변화 | 마지막 safe slot 배분이 새 D에서 old M으로 바뀜. 미노출 새 전조/잔여 phase는 의도된 ordering 결과; 종료 보상/정산 규칙 없음. |
| 132 | P0 | 새 P0 없음. |
| 133 | P1 | 새 P1 없음. |
| 134 | P2 | P2: F01/F44-01/F07-B 남음; 시설 Notice source cue/사람 comprehension 위험은 과거 Audit 범위대로 유지. |
| 135 | P3 | 새 P3 없음. Main 규모 유지관리 위험은 별도 책임 분리 필요성으로 관찰하되 Framework 추가 안 함. |
| 136 | F44-02 최종 판정 | F44-02 RESOLVED: disturbance-first age inversion만. unready/invalid/EXP skip 또는 무한 workload 전체 starvation 해결 주장은 하지 않음. |
| 137 | F01 최종 판정 | F01 OPEN: Major1 및 좁은 presentation Stage 예측성 유지. |
| 138 | F44-01 최종 판정 | F44-01 OPEN: meaningful/read gate 없음, strict0 여전. |
| 139 | F07-B 최종 판정 | F07-B PARTIALLY ADDRESSED: Step46 Snapshot만; 순서로 잔여 수가 줄어도 final Run disposition 해결 아님. |
| 140 | Ordering Matrix | 아래 Ordering Matrix 및 ignored ordering_headless/native.json, queue 결과 참조. |
| 141 | Before/After priority bypass 표 | 아래 9개 Before/After 표: source/phase/selected/final leftover 포함. |
| 142 | 144 Matrix diff 요약 | 아래 144 matrix 요약/metrics/table. 변경9·동일135; 단일 후보/Success 모든54+9 경로 동일. |
| 143 | 다음 pacing gate에서 주의할 점 | 별도 gate는 counter/readiness와 presentation을 구분하고 EXP draw 이후에만 credit 처리; Dismiss/Resume/Log/recheck credit 없음; 최종 boundary leftovers·source/current 보존 재검증. |
| 144 | 다음 Step 추천 | 다음은 Meaningful Research / Read Boundary Pacing Gate를 별도 요청 범위로 설계·구현. Run/Settlement 및 성공 독립 사건은 독립 작업. |
