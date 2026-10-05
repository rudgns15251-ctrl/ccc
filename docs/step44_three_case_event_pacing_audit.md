# Step44 — 3-Case Event Pacing / Cross-Case UX Audit

2026-10-05 · Godot 4.7.1 Standard / GDScript / Windows / GL Compatibility.

**다중 Case의 데이터·응답·복귀는 유지되지만, 사건 리듬이 충분히 여유롭거나 예측하기 어렵다고 판정할 수 없다.** 실제 버튼으로 144개의 threshold/실험량 조합을 측정했다. 사건 간 완료된 연구 행동은 최소 0개였다. 오래된 Major보다 새 교란이 먼저 보이는 정상 경로와, 마지막 경계에서 준비된 사건이 남는 경로를 분리해 확인했다. 명백한 제품 코드 버그는 재현되지 않아 gameplay 파일은 수정하지 않았다.

## 조사와 보존 기준

시작 HEAD `ad2beae1a7cbee8836bc8f811abb82740bb0d5d3`, `Improve major incident response content and reading boundaries`; `master` → `origin/main`, 시작 시 같은 커밋. remote `https://github.com/rudgns15251-ctrl/ccc.git`.

시작 미커밋은 Step43의 README/Case02/Main Scene/Main Script 수정 4개, Step43 보고서/Case03 Resource 추가 2개였다. 이 **기존 변경을 이번 baseline**으로 취급한다. 108개 저장소 파일과 기존 검증 원본 3,973개의 SHA-256을 기록했다. 저장소·상위 경로에서 적용할 AGENTS.md가 없었다.

전체 파일 inventory, project.godot, 15개 Scene/39개 Script, Case01/02/03, Step41~43 보고서, 7개 State, 각 View/Signal, response graph와 기존 전체 검증 suite를 조사했다. Autoload 0, Main 1,563줄/84함수. 기준 UI1920×1080, 초기 창1280×720, canvas_items/keep/resizable와 GL Compatibility를 유지한다.

Case01의 두 failure response chain, Case02의 Room01 SUCCESS/Room02 FAILURE Prototype Test Mapping, Case03 Outcome 없음과 마지막 Pending 정책을 재확인했다. Step42의 EXP 결과 draw 경계/Source Archive draft/context와 Step43 handoff·source/current 분리를 그대로 측정했다.

## 행동과 기회 정의

각 Case의 실제 순서:

| 단계/입력 | Opportunity key | 새 meaningful action | 의미/제한 |
|---|---|---|---|
| PROFILE 표시/읽기 | 없음 | 집계 제외 | 새 정보는 있지만 시간·읽기를 자동 추론하지 않음; 후보 count는 정지 |
| PROFILE Next → CCTV 최초 관찰 | `cctv:entry` | 1 | 새 CCTV source; Case01에는 과거 후보가 없어 event 없음 |
| CCTV Next → EXP View | 없음 | 0 | navigation만으로 실행 기회가 생기지 않음 |
| 유효 Experiment 선택/Run | `experiment:<id>` | 승인 시1 | 실제 이력에 추가된 고유 ID만; limit2, 기존 Case01은 후보3개 |
| EXP Next → CONT 최초 진입 | `containment:entry` | 0 | 기존 event boundary; Room 판단을 아직 확정하지 않아 meaningful로 부풀리지 않음 |
| Room 선택/Confirm | 없음 | 확정 시1 | 판단 제출; Next handoff에서 hidden resolution |
| CONT Next → 다음 PROFILE | 없음 | 0 | 현재 Case key clear/new Runtime, session 후보 보존 |

Case01은 이번 matrix에서 실험1회로 고정한다. Case02/03은 각각 0/1/2회, ID 순서는 authored 첫째→둘째로 고정했다. 전체 eligible=7+E02+E03, meaningful=7+E02+E03이다. **두 합계가 같아도 같은 입력 집합은 아니다:** CONT entry는 기회만, Confirm은 판단만 센다. 실험 순서/Case01 실험 사용량 전수 UX matrix는 이번 표본 밖이며 기존 회귀가 다른 순서·Room03도 다룬다.

Profile, Log Open/Back, 일반 Archive/Source Archive, Hypothesis add/edit, Recheck CCTV/Back, Dismiss, Resume entry, idle, focus, scroll, Room 임시 선택, 실험 임시 선택·실패/중복/limit초과 요청은 기회가 아니다. 최초 CCTV/CONT key는 같은 Runtime에서 재소비하지 않는다. Handoff는 key를 비우고 Resume는 유지한다. 계측용 UI·공포 시간·점수는 제품에 추가하지 않았다.

간격은 두 방식으로 표기한다. **strict**는 앞 event 표시 후 뒤 event 표시 전에 *완료한* meaningful action 수다. **causing 포함**은 뒤 event를 일으킨 행동이 meaningful일 때만1을 더한다. EXP/CCTV의 결과가 같은 action에서 Notice로 가려졌다는 이유로 읽기 완료를 주장하지 않는다. 대응/Archive 버튼과 Back을 간격의 연구 행동으로 세지 않는다. Broadcast/Result는 한 Major의 응답 화면이며 별도 interruption으로 중복 집계하지 않는다.

## 현재 Major 규칙과 F01

Main은 유효한 새 key를 등록한 뒤 모든 해당 과거 후보의 Major count를 먼저 증가시키고, 아직 교란되지 않은 후보의 disturbance count를 증가시킨다. 새 교란 자체는 같은 action의 Major count를 소비하지 않는다. count는 상한1에서 포화하며 readiness는 유지된다.

1. 먼저 유효한 disturbance-ready 후보를 FIFO로 표시하고 즉시 반환한다.
2. 교란을 표시하지 않았어도 EXP callback은 결과를 유지하고 반환한다.
3. CCTV/CONT boundary에서 major-ready 후보를 FIFO로 시도하고 한 Major만 표시한다.
4. Response 중에는 기회 처리/nested start가 차단된다. Resume는 `discover_displayed_source=false`로 복귀하므로 새 key/count/event를 소비하지 않는다.

따라서 정확한 표현은 **‘교란 뒤 한 후속 eligible opportunity에서 ready, 이후 교란이 선택되지 않는 허용 CCTV/CONT boundary에서 presentation’**이다. ‘다음 모든 행동에서 화면에 Major’는 부정확하다. EXP1의 교란 뒤 EXP2에서 ready가 되어도 그 결과는 draw되고 CONT에서야 Major가 표시된다. EXP2 교란 뒤 CONT는 readiness와 presentation이 같은 입력에서 일어나므로 완료한 새 연구 행동 간격이0이다.

144개의 균등 조합 표본에서 Major122회: CCTV36(29.5%), CONT86(70.5%), EXP0. 이 비율은 실제 사용자 확률이 아니라 **고정 seed·Room01 Failure·지정 실험 순서 표본의 실행 비율**이다. Case03 첫 CCTV의 Major36회는 모두 source Case01이다. Case01이 이미 disturbed된 채 handoff되면 새 Case 첫 CCTV가 강한 예측 신호가 된다. PROFILE은 event 없는 읽기·메모 공간을 제공하지만 첫 CCTV 위험은 그대로 남는다.

**F01 OPEN / P2 GAME DESIGN:** ready=1의 고정 관계와 좁은 presentation Stage의 예측성이 남아 있다. 읽기 경계는 결과 유실을 해결하지만 그 자체가 ‘실험 후 CONT에서 사건’의 반복성을 제거하지 않는다. threshold/RNG/range/priority는 변경하지 않았다.

## 사건 간격과 밀집

대표 `FF_42_e22`: source Case01 교란(Case02 CONT) → Case01 Major(Case03 CCTV) → Case02 교란(Case03 EXP01) → Case02 Major(Case03 CONT).

| 구간 | strict / causing 포함 | 새 source와 판단 여지 |
|---|---|---|
| Case01 D → Case01 M | 1 /2 | Case02 Confirm1, 뒤 사건 action인 Case03 CCTV1; 그 사이 새 PROFILE을 자유롭게 읽을 수 있음 |
| Case01 M/Resume → Case02 D | 0 /1 | Next→EXP 자체는 navigation; Run EXP01의 새 결과와 Notice가 같은 입력에서 나타남 |
| Case02 D/Dismiss → Case02 M | 1 /1 | EXP02 결과1은 실제 draw; CONT 진입은 판단 확정 전에 중단 |

행동을 줄인 `FF_42_e20`은 Case01 Major 후 EXP를 건너뛰고 CONT에서 Case02 교란이 나타나 **strict/causing 모두0**이다. 단일 Failure threshold3·실험2회도 마지막 EXP에서 교란→CONT Major 간격0이다. matrix 전체 간격 범위 strict0~4/causing0~4, 한 Case에서 최대3 interruption을 관찰했다. 계속 발생하는 자동 타이머는 없으며, 플레이어는 Log·Hypothesis·idle로 멈춰 읽을 수 있다. 그러나 매개 action이0~1인 구간에서는 계속 진행하는 플레이어의 새 관찰 정리와 판단이 응답 UI에 밀릴 위험이 있다. 이것은 측정된 구조적 위험이며 피로/긴장/재미의 사람 체감을 증명하지 않는다.

144 Journey 합계: eligible1,296, meaningful1,296, Disturbance179/Major122/Broadcast122, interruption301. Event/eligible와 Event/meaningful 모두0.2323. case별108(Case02),193(Case03). 각 실제 Journey의 비율과 min/max는 아래 표 및 원본 JSON에 있으며 aggregate를 대표적인 사용자 경험으로 단정하지 않는다.

## Ordering과 starvation

| 경쟁 상태(통제 fixture) | 실제 선택 | 남는 상태 |
|---|---|---|
| Old Major / New Disturbance | New Disturbance | Old는 ready로 보존 |
| Old Disturbance / New Major | Old Disturbance | New Major 보존 |
| Two Majors | Old Major | 다른 ready 후보는 Resume에서 즉시 표시되지 않음 |
| Two Disturbances | Old Disturbance | 새 후보도 다음 eligible에서 재시도 |

정상 matrix의 8개 경로에서 ‘Case02 교란 → Case01 Major’의 화면 순서를 관찰했다. 해당 교란들은 EXP에서 발생하므로 **Major 표시가 원래 허용되지 않는 읽기 경계도 원인**이다. 모두를 priority 버그로 설명하지 않는다.

별도로 실제 CCTV/CONT에서 old Major가 준비되었는데 새 교란이 선택된 경로9개를 찾았다: `FF_32_e00`, `FF_33_e01`, `FF_34_e02`, `FF_42_e01`, `FF_42_e10`, `FF_43_e01`, `FF_43_e11`, `FF_44_e02`, `FF_44_e12`. 모두 마지막 Case03 CONT다. Case01 Major는 ready1로 보존되지만 다음 boundary가 없어 표시되지 않는다. 이는 **disturbance-first의 실제 priority bypass + 유한 sequence 종료**다. ‘현재3Case에서 무한 opportunity를 소비하면서 계속 굶는 starvation’은 재현되지 않았다.

| Candidate set | Initial/sequence | 실제 선택 | Eventually / starvation |
|---|---|---|---|
| 유효 A,B,C(별도 synthetic State/content fixture) | A Major-ready, B/C D-ready; 5개의 fresh safe keys | D(B)→D(C)→M(A)→M(B)→M(C) | 5회에 모두 완료; 유한 queue·후속 유효 기회 존재 조건 |
| invalid oldest + valid Case02 | missing source/Incident/Resolution/usable Broadcast, disturbed와 undisturbed 각각; 3 safe keys | invalid warning/retain, 유효 Case02 D→M 완료 | 앞 후보가 뒤 후보를 영구 block하지 않음 |
| 실제3Case 마지막 boundary | D 우선9경로 또는 Major1회 budget/late count | 남은 후보 retain | 기회 종료; infinite starvation과 구별 |
| 계속 새 후보 유입(코드 분석) | 부트스트랩 후 매 safe opportunity에 또 유효 D-ready | D가 매번 early return | old Major의 presentation을 이론상 무기한 미룰 수 있음; infinite loop 실행 안 함 |

유한 집합은 각 유효 disturbance를 최대1회 소비하므로, 뒤에 충분한 fresh safe opportunity가 있으면 Major도 진행한다. invalid 후보는 `continue` 또는 false-return 뒤 다른 후보를 시도하므로 실제 queue 전체 차단은 없다. invalid 후보 자체와 warning은 반복될 수 있어 offline 콘텐츠 검사의 대상이다. 현재 실제 pool은 최대2 Failure Candidate라 무한 유입을 제공하지 않는다. stress용 추가 ID는 메모리 clone이며 authored Case04나 정상 sequence가 아니다.

교란 우선은 각 사건의 환경 전조/현재 반응을 먼저 확보한다는 장점이 있다. 반면 서로 다른 source의 전조가 오래된 ready Major 앞에 끼고, 오래된 source를 잊거나 인과 순서를 새 사건과 혼동할 수 있다. FIFO는 각 ready 타입군 안에서만 보장된다.

## Cross-Case UX / Response 길이

| Event | Source / Current | 복귀 / Archive | 화면 근거와 혼동 위험 |
|---|---|---|---|
| 첫 Case01 D | Case01 / Case02 CONT | Dismiss→동일 CONT / current Log | 시설명·환경 변화와 current observation 제공, source Case를 직접 표시하지 않음 |
| Case01 Major | Case01 / Case03 CCTV | 동일 CCTV Runtime / Case01 Archive | SOURCE CASE/현재 CASE03·CCTV/Result RESUME WORK 일치 |
| Case02 D | Case02 / Case03 EXP01 | Dismiss→동일 EXP / Case03 Log | air jets와 current floor-strip 반응은 구분, Notice에 source/current Case ID는 없음 |
| Case02 Major | Case02 / Case03 CONT | 동일 CONT Runtime / Case02 Archive | source label이 Case02로 바뀌고 현재 CASE03 유지; 실제 C 선택/Confirm/Resume 성공 |

Major3화면의 Source/Current/Resume와 Archive target는 정확하다. response의 Archive는 개인 메모까지 source Case별로 표시하며 current working notes는 편집 가능한 Case03 Log에 남는다. 다만 과거 Archive에도 **WORKING HYPOTHESES** 제목을 써서 ‘현재 메모’로 잘못 읽을 가능성이 있다. Case header가 구별 단서지만 사람 comprehension test가 필요하다. 시설 Notice에는 Source Case가 직접 보이지 않으므로 두 source의 교란 causal binding은 Major context만큼 명확하지 않다. 이를 wrong Source/Archive 코드 결함으로 분류하지 않고 P2 UX로 기록한다. 향후 cue 보완은 hidden 판정 누설·의도된 시설 불확실성을 같이 검토해야 한다.

Major 최소 response는 Next Incident + Option 선택 + Confirm + Next Broadcast + Resume의 **5입력**이다. Source Archive1회는 Open/Back2입력 추가(7). 이번 dense native Journey는 사건당4회의 Archive 왕복을 의도적으로 검사해13입력, 두 Major26입력을 수행했다. 이는 필수 response 길이가 아니다. Archive·응답 클릭은 meaningful 간격0을 13으로 늘리는 연구 업무라고 세지 않는다. authored prompt는 과거 단서를 다시 요약해 Archive 없이 선택 가능하다. Draft와 confirmed lock, incremental Incident→Broadcast→confirmed Option→displayed Result Research 경계를 보존한다. 각 source의 response로 해당 Archive만4개 증가하고 current Case03에는 섞이지 않았다.

세 해상도에서 source/current 긴 설명과 scroll 옵션/Confirm/Archive/Resume 접근이 가능했다. native에서는 Option C를 실제 클릭했고 C Result가 표시됐다. 1024×768의 keep render는1024×576으로, 개발용 헤더·ID·5줄 context와 긴 설명이 많은 공간을 차지하고 옵션 C는 scroll이 필요하다. clipping/진행 불가를 재현하지 않았지만, 작은 글자/반복 header는 P2 정보 밀도 및 P3 polish 대상이다. 최종 typography나 UI는 변경하지 않았다.

## Success / Failure 콘텐츠 격차

동일 실험량2/2와 같은 선택 C의 대표 snapshot 비교:

| 흐름 | 기본 새 연구/실험 | D / M / B | Archive C01/C02 | 중단 |
|---|---|---|---|---:|
| All Success `SS_00_e22` | Profile/CCTV/실험/제출 정상, Case03 개인 메모 가능 | 0/0/0 | 4/5 | 0 |
| Dual Failure `FF_42_e22` | 같은 실험 수 + 실제 환경 supporting observation | 2/2/2 | 8/10 | 4 |

Case02 baseline 수는 선택한 제출 Room authored Research와 환경 관찰로 달라진다. Case01 response +4, Case02 response +4이고 dual C02는 current 환경 Research1도 발견해9개 추가(전체9→18)다. 모든 실험/미선택 Option을 자동 공개하지 않는다.

all-Success matrix9개에서 D/M/B 모두0이었다. 실패를 잘 피할수록 대표 Broadcast/시설 사건 콘텐츠를 보지 못한다는 **P2 CONTENT/GAME DESIGN 위험**은 남는다. 재미·보상감의 실제 크기는 사람에게 확인해야 한다. 향후 실패와 독립적인 시설 사건1개를 검토하는 목적은 ‘모든 플레이어가 핵심 경험을 최소 한 번 접하기’다. 성공을 거짓 Failure로 바꾸거나 Forced Failure를 권장하지 않는다. 이번에는 Scripted/Forced Event를 추가하지 않았다.

## 마지막 경계: F07 분해

144경로 중82개가 마지막 Candidate를 남겼으며17개에는 ready Major가 있었다. FF81개 중63, FS27개 중1, SF27개 중18, SS9개 중0이다. 이는 균등 조합과 고정 행동량의 비율이며 사용자 실패율이 아니다. FF_44_e22의 Case02는 마지막 CONT 교란 뒤 major0으로 남는다. 다른 경로에는 아직 undisturbed거나 두 ready Major 중 첫째만 표시한 뒤 둘째가 남는 경우도 있다.

**F07-A RESOLVED:** 실제 Case01→02→03 continuation 및 Case01 deferred 정상 대응/동일 Runtime 복귀는 작동한다. **F07-B OPEN:** 유한 마지막 sequence의 미처리 event 정책이 없다. 전체 F07은 이 두 문제로 분해한다. 마지막 Case03 Confirm의 Pending/current Runtime/Research/Hypothesis와 Candidate 유지 자체는 현재 정책이며 코드 오류가 아니다.

Case04 추가는 기회 수를 늘리지만 모든 마지막 경계를 뒤로 옮기기만 한다. 먼저 Run/Shift/정산 경계에서 carry/drain/defer 중 어떤 정책인지 문서로 결정할 필요가 있다. 이번에는 완료를 강제하거나 Case03 Outcome/Campaign end를 만들지 않았다.

## 책임 감사와 finding 분류

Main 1,563줄/84함수 그대로다. opportunity dedup·content validation·candidate selection·presentation·response/archive routing·debug lookup을 orchestration하므로 3-Case 최소 기반은 유지되지만 정책 변경 시 집중도 위험이 크다. State를 더 늘리기보다 우선 현재 정책 계약을 문서·검사로 고정하고, 필요 시 읽기 전용 content lookup 경계를 검토하는 정도를 권장한다.

FailureEventCandidateState는 ID/진행 count/FIFO만, IncidentResponseState는 active/completed identity/confirmed selection만 보관한다. CaseRuntime은 current 실행/판단/발견/환경 사실, Pending/Resolution은 제출/hidden 판정, Archive/Hypothesis는 Case별 session 기록이다. Interrupt Context는 source/current Runtime 검증·복귀 Stage·Archive return·임시 broadcast draft를 위한 navigation 정보이며 별도 gameplay truth나 event pacing State가 아니다.

| Finding | 범주 / 심각도 | 재현/판정 | 이번 처리 |
|---|---|---|---|
| F01 | GAME DESIGN P2 | ready1, Major122개 중 CONT70.5%; 연구 간격0 가능 | OPEN, 값 유지 |
| F44-01 | UX/GAME DESIGN P2 | FF_42_e22 Major→EXP01 Notice 사이 완료 연구0; 몇 경로는 causing 포함도0 | gate/간격 설계와 사람 비교 추천만 |
| F44-02 | GAME DESIGN P2 | 정상 EXP source inversion8, 마지막 safe priority bypass9; 무한 유입 이론 | global age/fairness 별도 검토만 |
| F07-B | GAME DESIGN/CONTENT P2 | deferred82/144, ready17; 마지막 기회 종료 | 종료 정책 선행 추천 |
| F44-03 | UX P2 | Notice source/current 명시 부족; Archive의 WORKING HYPOTHESES 용어 | source 인과 이해 사람 검사 |
| F09 | CONTENT/GAME DESIGN P2 | all Success response0, 대표 dual response2 | 독립 시설 사건 후보 추천 |
| F10 | TECH DEBT P3 | Main1563/84, orchestration 책임 집중; invalid warning 반복 | 정책 계약/좁은 offline 검사 재평가 |
| F11 | UX P2 / polish P3 | 작은 창의 많은 개발 header/ID/context | 접근 가능; 최종 디자인 변경 없음 |

P0 crash/corruption/진행불가 및 P1 wrong Candidate/Case/Runtime/response는 재현되지 않았다. CODE bug finding 없음, 제품 수정0. 정상 마지막 Next 비활성화는 P0 진행 불가로 세지 않는다.

## 설계 대안 비교 — 구현하지 않음

| 후보 | 장점 | 단점/선행 결정 |
|---|---|---|
| 전역 oldest Candidate FIFO | source 인과 순서/age를 이해하기 쉬움 | old가 unready/invalid이면 head-of-line block 위험; newer 환경 전조를 가릴 수 있음 |
| 명시적 event priority / old ready 우선 | 현재 교란 우선과 ready fairness를 비교 가능 | 새 교란 전조 지연/그룹 간 설명 필요; Severity와 혼동하면 복잡해짐 |
| 최소 meaningful action gate | 0간격 연속 interruption을 직접 제한 | 무엇을 연구 행동으로 승인할지/Confirm 전 event/마지막 기회 정책 필요; 억지 실험을 유도할 위험 |
| Major1 vs1~N vs2~N | range는 timing variation,2최소는 한 후속 기회 즉시ready를 줄임 | 짧은 pool에서 미노출/deferred 증가; 결국 safe Stage 쏠림과 ‘언젠가 곧’ 기대는 남음 |
| disturbance-only/delayed/direct/scripted facility | 단일 D→M 학습과 Success 콘텐츠 격차를 줄일 후보 | source 설명/독립 event 계약/범위와 종료 정책 필요; direct는 전조를 줄임 |
| Severity enum | gameplay 결과·위험도 분기에 쓰일 때 유용 | 현재 text-only responses에는 점수/경제/결과 모델이 없어 enum만 추가하는 이익 적음 |

random range를 넓히는 것만으로 공포의 예측성이나 불공정 queue를 해결했다고 볼 수 없다. event type 다양성은 Severity 없이도 패턴을 바꿀 수 있다. 현재 세 원인(A 고정 readiness/B 우선순위/C 종료)을 한 조정값으로 해결하려 하지 않는다.

가장 중요한 pacing 문제3개: **A F01+0간격**, **B 교란 우선과 source 인과/fairness**, **C F07-B 마지막 처리 정책**. 다음 구현 후보3개는 (1) 종료 경계의 carry/drain 정책, (2) 의미 있는 행동 간격 또는 old-ready 우선 정책 중 작은 한 실험, (3) 성공과 독립적인 최소 시설 사건이다. 1은 상태 처리 기준을 닫지만 정책 결정이 필요하고, 2는 간격/공정성을 개선할 수 있으나 새 pacing State·기회 조작 위험이 있으며, 3은 콘텐츠 노출을 보장하지만 pacing 문제를 단독으로 해결하지 못한다.

**다음 Step45 추천: Final Sequence Event Policy / Pacing Design Decision.** 종료 정책을 먼저 명시하고, 지금의 재현 baseline으로 사람 플레이테스트와 작은 정책 후보 비교를 승인한 뒤 구현한다. Case04·threshold 변경을 자동으로 다음 작업으로 간주하지 않는다.

## 자동 검증과 사람 검사 경계

자동 검사로 state identity/queue ordering/opportunity counts/readiness와 presentation/action spacing/버튼 접근/draft lock/Research isolation/resource immutability를 확정할 수 있다. 사람에게는 사건 직전 기대/연속 response 피로/Notice→source 인과 기억/Case03 복귀 이해/작은 글자의 읽기/Success 콘텐츠 손실감을 확인해야 한다. 실제 사람 플레이테스트는 수행하지 않았고 ‘무섭다/재미있다/적당히 긴장된다’는 결론을 내리지 않는다.

최종 suite는 기존199 + Step40 16 + Step42 20 + Step43 32 + Step44 24 = **291**, headless172/native119. 별도 editor import/configured Main headless/native3도 검사했다. 파싱·실행 오류0. expected invalid warnings는 기존1278+새 queue42=1320, 정상/새 matrix/visual/debug/기본 실행0이다.

Step44 matrix는16 suite×9 =144 정상 Journey; dense/allSuccess visual은3해상도×2mode×2 =12 Journey. queue는15개 controlled fixture×2mode =30. 내부 Journey/fixture 수를291 suite에 합산하지 않는다. 3-candidate/invalid/ordering/containment reentry는 controlled fixture, 정상 matrix는 seed를 준비한 실제 root.push_input 버튼 Journey다. current/source Runtime/Archive/Hypothesis/다른 Candidate과 오래된 CCTV/EXP/CONT/Incident/Broadcast/IncidentResult/Archive의 연결 신호를 비교했다.

기존 검증 원본은 수정하지 않고 `step44/regression43/` 사본으로 실행했다. 과거 2-Case/Case02 Outcome 없음 계약은 기존 HEAD snapshot을 쓰며235 legacy 결과를 새 Case02 데이터 자체 검사라고 표현하지 않는다. 새 Case02/03 및3Case Main은 Step43 32+Step44 24와 entry로 검증했다. 제품의39 GDScript check와 debug Case01/02 Success/Failure, Monitoring→Incident→Broadcast→IncidentResult→Result도 포함했다. 수동 F5키 입력이 아닌 configured Main CLI 실행이다.

Windows native RX6800 GL Compatibility의 실제 draw/PNG를1920×1080,1280×720,1024×768에서 생성했고, 대표7장을 직접 열어 Source Case01/02 전환, current Case03, Source Archive, 긴 옵션/결과/Resume/다음 Notice/allSuccess 마지막 CONT를 확인했다. raw PNG는1024×576의16:9영역을 기록한다. 자동 actual click과 Resource content snapshot도 통과했다.

검사 준비 중 발견한 문제는 모두 ignored fixture에 한정됐다: typed Array 인수 보완, wheel 입력의 release 누락 보완, legacy 사본의 screenshot subfolder 생성. 최종 소스로 재실행/로그 해시를 검사했으며 실패 진단 실행은291 성공 suite에 포함하지 않는다. 이미 이번 Step44에서 통과한 legacy 실행은 input/log hash가 일치할 때만 Resume했다. 과거 Step43 실행 로그를 이번 결과로 재사용한 것이 아니다.

## 변경 범위

이번 Step44: **README.md 요약 추가1개, 이 보고서 생성1개; 제품 코드·Scene·Resource 변경0, 삭제0**. 이전 Step43의4 modified/2 new 상태는 그대로 유지한다. 따라서 HEAD 대비 최종 status의 modified4/new3은 Step43+44 합계다. project.godot, Main/threshold/모든 authored Case/State/View/기존 검증 원본은 이번 baseline hash와 일치한다. README 이전 본문은 Step44 블록을 제외하면 byte/text 동일하다.

계측 Script/runner/JSON/로그/PNG/사본은 ignore된 `.godot/verification/step44/`에 있다. 재현: `run_validation.ps1`의24개 검사, `analyze.ps1`의144개 matrix 통계, regression43의기존 runner들. `metrics.json`, `safe-priority-bypasses.json`, `audit_*.json`과 `queue_*.json`이 원본 증거다. 최종 범위/로그 hash/132개 응답 번호/staged·HEAD·diff check를 `final_integrity.json`에 기록한다.

threshold/range/cooldown/gate/priority enum/global FIFO/Severity/event pacing State/Forced/Scripted/Case04/Case03 Outcome/Campaign/Shift/Quota/Economy/Save/Load/final UI/audio/animation/shader/Manager/Singleton/EventBus는 추가하지 않았다. **커밋·push하지 않는다.**

## Event Density — 대표 동일 실험량(2/2)

| Scenario | Meaningful | Eligible | D | M | B | Interruptions | Event/action | Spacing strict/causing |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| FF_22_e22 | 11 | 11 | 2 | 2 | 2 | 4 | 0.364 | 1/1, 2/3, 1/1 |
| FF_23_e22 | 11 | 11 | 2 | 2 | 2 | 4 | 0.364 | 1/1, 3/4, 0/0 |
| FF_24_e22 | 11 | 11 | 2 | 1 | 1 | 3 | 0.273 | 1/1, 4/4 |
| FF_32_e22 | 11 | 11 | 2 | 2 | 2 | 4 | 0.364 | 0/0, 2/3, 1/1 |
| FF_33_e22 | 11 | 11 | 2 | 2 | 2 | 4 | 0.364 | 0/0, 3/4, 0/0 |
| FF_34_e22 | 11 | 11 | 2 | 1 | 1 | 3 | 0.273 | 0/0, 4/4 |
| FF_42_e22 | 11 | 11 | 2 | 2 | 2 | 4 | 0.364 | 1/2, 0/1, 1/1 |
| FF_43_e22 | 11 | 11 | 2 | 2 | 2 | 4 | 0.364 | 1/2, 1/2, 0/0 |
| FF_44_e22 | 11 | 11 | 2 | 1 | 1 | 3 | 0.273 | 1/2, 2/2 |
| FS_20_e22 | 11 | 11 | 1 | 1 | 1 | 2 | 0.182 | 1/1 |
| FS_30_e22 | 11 | 11 | 1 | 1 | 1 | 2 | 0.182 | 0/0 |
| FS_40_e22 | 11 | 11 | 1 | 1 | 1 | 2 | 0.182 | 1/2 |
| SF_02_e22 | 11 | 11 | 1 | 1 | 1 | 2 | 0.182 | 1/1 |
| SF_03_e22 | 11 | 11 | 1 | 1 | 1 | 2 | 0.182 | 0/0 |
| SF_04_e22 | 11 | 11 | 1 | 0 | 0 | 1 | 0.091 |  |
| SS_00_e22 | 11 | 11 | 0 | 0 | 0 | 0 | 0.000 |  |

## Threshold Matrix — 두 Failure, 실험2/2

| T01/T02 | Source01 D | Source01 M | Source02 D | Source02 M | 마지막 Deferred | strict spacing |
|---|---|---|---|---|---|---|
| 2/2 | C02/EXPERIMENT [TEST_CASE02_EXP_01] | C02/CONTAINMENT | C03/EXPERIMENT [TEST_CASE03_EXP_01] | C03/CONTAINMENT | 없음 | 1, 2, 1 |
| 2/3 | C02/EXPERIMENT [TEST_CASE02_EXP_01] | C02/CONTAINMENT | C03/EXPERIMENT [TEST_CASE03_EXP_02] | C03/CONTAINMENT | 없음 | 1, 3, 0 |
| 2/4 | C02/EXPERIMENT [TEST_CASE02_EXP_01] | C02/CONTAINMENT | C03/CONTAINMENT | — | TEST_CASE_02: D=True, M=0 | 1, 4 |
| 3/2 | C02/EXPERIMENT [TEST_CASE02_EXP_02] | C02/CONTAINMENT | C03/EXPERIMENT [TEST_CASE03_EXP_01] | C03/CONTAINMENT | 없음 | 0, 2, 1 |
| 3/3 | C02/EXPERIMENT [TEST_CASE02_EXP_02] | C02/CONTAINMENT | C03/EXPERIMENT [TEST_CASE03_EXP_02] | C03/CONTAINMENT | 없음 | 0, 3, 0 |
| 3/4 | C02/EXPERIMENT [TEST_CASE02_EXP_02] | C02/CONTAINMENT | C03/CONTAINMENT | — | TEST_CASE_02: D=True, M=0 | 0, 4 |
| 4/2 | C02/CONTAINMENT | C03/CCTV | C03/EXPERIMENT [TEST_CASE03_EXP_01] | C03/CONTAINMENT | 없음 | 1, 0, 1 |
| 4/3 | C02/CONTAINMENT | C03/CCTV | C03/EXPERIMENT [TEST_CASE03_EXP_02] | C03/CONTAINMENT | 없음 | 1, 1, 0 |
| 4/4 | C02/CONTAINMENT | C03/CCTV | C03/CONTAINMENT | — | TEST_CASE_02: D=True, M=0 | 1, 2 |

## 실험 사용량과 도달 — 두 Failure T01=4/T02=2

| E02/E03 | 사건 순서 | 마지막 Candidate |
|---|---|---|
| 0/0 | C01:DISTURBANCE@C03/CONTAINMENT | TEST_CASE_01: D=True, major=0;TEST_CASE_02: D=False, major=0 |
| 0/1 | C01:DISTURBANCE@C03/EXPERIMENT [TEST_CASE03_EXP_01] → C02:DISTURBANCE@C03/CONTAINMENT | TEST_CASE_01: D=True, major=1;TEST_CASE_02: D=True, major=0 |
| 0/2 | C01:DISTURBANCE@C03/EXPERIMENT [TEST_CASE03_EXP_01] → C02:DISTURBANCE@C03/EXPERIMENT [TEST_CASE03_EXP_02] → C01:MAJOR@C03/CONTAINMENT | TEST_CASE_02: D=True, major=1 |
| 1/0 | C01:DISTURBANCE@C03/CCTV → C02:DISTURBANCE@C03/CONTAINMENT | TEST_CASE_01: D=True, major=1;TEST_CASE_02: D=True, major=0 |
| 1/1 | C01:DISTURBANCE@C03/CCTV → C02:DISTURBANCE@C03/EXPERIMENT [TEST_CASE03_EXP_01] → C01:MAJOR@C03/CONTAINMENT | TEST_CASE_02: D=True, major=1 |
| 1/2 | C01:DISTURBANCE@C03/CCTV → C02:DISTURBANCE@C03/EXPERIMENT [TEST_CASE03_EXP_01] → C01:MAJOR@C03/CONTAINMENT | TEST_CASE_02: D=True, major=1 |
| 2/0 | C01:DISTURBANCE@C02/CONTAINMENT → C01:MAJOR@C03/CCTV → C02:DISTURBANCE@C03/CONTAINMENT | TEST_CASE_02: D=True, major=0 |
| 2/1 | C01:DISTURBANCE@C02/CONTAINMENT → C01:MAJOR@C03/CCTV → C02:DISTURBANCE@C03/EXPERIMENT [TEST_CASE03_EXP_01] → C02:MAJOR@C03/CONTAINMENT | 없음 |
| 2/2 | C01:DISTURBANCE@C02/CONTAINMENT → C01:MAJOR@C03/CCTV → C02:DISTURBANCE@C03/EXPERIMENT [TEST_CASE03_EXP_01] → C02:MAJOR@C03/CONTAINMENT | 없음 |

## 전체 3-Case Pacing Timeline — FF_42_e22

Select/Next 등 비기회 action도 표시한다. a는 실제 버튼 입력 index이며 응답/Archive 입력도 포함하되 meaningful 간격에는 포함하지 않는다.

| a | Case / Stage | Action | Opp / Meaningful | Candidate before → after (seen,D,major,triggered) | Displayed Event | Strict since previous |
|---:|---|---|---|---|---|---|
| 1 | C01 / PROFILE | Next: CCTV | True/True | — → — | — | — |
| 2 | C01 / CCTV | Next: EXPERIMENT | False/False | — → — | — | — |
| 3 | C01 / EXPERIMENT | TEST EXPERIMENT 01 | False/False | — → — | — | — |
| 4 | C01 / EXPERIMENT | Run Experiment | True/True | — → — | — | — |
| 5 | C01 / EXPERIMENT | Next: CONTAINMENT | True/False | — → — | — | — |
| 6 | C01 / CONTAINMENT | TEST ROOM 01 | False/False | — → — | — | — |
| 7 | C01 / CONTAINMENT | Confirm Containment | False/True | — → — | — | — |
| 8 | C01 / CONTAINMENT | Next: CASE | False/False | — → C01=(0,0,0,0) | — | — |
| 9 | C02 / PROFILE | Next: CCTV | True/True | C01=(0,0,0,0) → C01=(1,0,0,0) | — | — |
| 10 | C02 / CCTV | Next: EXPERIMENT | False/False | C01=(1,0,0,0) → C01=(1,0,0,0) | — | — |
| 11 | C02 / EXPERIMENT | TEST CASE 02 EXPERIMENT 01 | False/False | C01=(1,0,0,0) → C01=(1,0,0,0) | — | — |
| 12 | C02 / EXPERIMENT | Run Experiment | True/True | C01=(1,0,0,0) → C01=(2,0,0,0) | — | — |
| 13 | C02 / EXPERIMENT | TEST CASE 02 EXPERIMENT 02 | False/False | C01=(2,0,0,0) → C01=(2,0,0,0) | — | — |
| 14 | C02 / EXPERIMENT | Run Experiment | True/True | C01=(2,0,0,0) → C01=(3,0,0,0) | — | — |
| 15 | C02 / EXPERIMENT | Next: CONTAINMENT | True/False | C01=(3,0,0,0) → C01=(4,1,0,0) | C01 DISTURBANCE | — |
| 16 | C02 / CONTAINMENT | Dismiss | False/False | C01=(4,1,0,0) → C01=(4,1,0,0) | — | — |
| 17 | C02 / CONTAINMENT | TEST CASE 02 ROOM 02 | False/False | C01=(4,1,0,0) → C01=(4,1,0,0) | — | — |
| 18 | C02 / CONTAINMENT | Confirm Containment | False/True | C01=(4,1,0,0) → C01=(4,1,0,0) | — | — |
| 19 | C02 / CONTAINMENT | Next: CASE | False/False | C01=(4,1,0,0) → C01=(4,1,0,0);C02=(0,0,0,0) | — | — |
| 20 | C03 / PROFILE | Next: CCTV | True/True | C01=(4,1,0,0);C02=(0,0,0,0) → C01=(4,1,1,1);C02=(1,0,0,0) | C01 MAJOR | 1 |
| 21 | C03 / INCIDENT | Next: BROADCAST | False/False | C01=(4,1,1,1);C02=(1,0,0,0) → C01=(4,1,1,1);C02=(1,0,0,0) | — | — |
| 22 | C03 / BROADCAST |  | False/False | C01=(4,1,1,1);C02=(1,0,0,0) → C01=(4,1,1,1);C02=(1,0,0,0) | — | — |
| 23 | C03 / BROADCAST | Confirm Broadcast | False/False | C01=(4,1,1,1);C02=(1,0,0,0) → C01=(4,1,1,1);C02=(1,0,0,0) | — | — |
| 24 | C03 / BROADCAST | Next: INCIDENT RESULT | False/False | C01=(4,1,1,1);C02=(1,0,0,0) → C01=(4,1,1,1);C02=(1,0,0,0) | — | — |
| 25 | C03 / INCIDENT_RESULT | Resume: CCTV | False/False | C01=(4,1,1,1);C02=(1,0,0,0) → C02=(1,0,0,0) | — | — |
| 26 | C03 / CCTV | Next: EXPERIMENT | False/False | C02=(1,0,0,0) → C02=(1,0,0,0) | — | — |
| 27 | C03 / EXPERIMENT | TEST CASE 03 CONTRAST COMPARISON | False/False | C02=(1,0,0,0) → C02=(1,0,0,0) | — | — |
| 28 | C03 / EXPERIMENT | Run Experiment | True/True | C02=(1,0,0,0) → C02=(2,1,0,0) | C02 DISTURBANCE | 0 |
| 29 | C03 / EXPERIMENT | Dismiss | False/False | C02=(2,1,0,0) → C02=(2,1,0,0) | — | — |
| 30 | C03 / EXPERIMENT | TEST CASE 03 GAP COMPARISON | False/False | C02=(2,1,0,0) → C02=(2,1,0,0) | — | — |
| 31 | C03 / EXPERIMENT | Run Experiment | True/True | C02=(2,1,0,0) → C02=(2,1,1,0) | — | — |
| 32 | C03 / EXPERIMENT | Next: CONTAINMENT | True/False | C02=(2,1,1,0) → C02=(2,1,1,1) | C02 MAJOR | 1 |
| 33 | C03 / INCIDENT | Next: BROADCAST | False/False | C02=(2,1,1,1) → C02=(2,1,1,1) | — | — |
| 34 | C03 / BROADCAST |  | False/False | C02=(2,1,1,1) → C02=(2,1,1,1) | — | — |
| 35 | C03 / BROADCAST | Confirm Broadcast | False/False | C02=(2,1,1,1) → C02=(2,1,1,1) | — | — |
| 36 | C03 / BROADCAST | Next: INCIDENT RESULT | False/False | C02=(2,1,1,1) → C02=(2,1,1,1) | — | — |
| 37 | C03 / INCIDENT_RESULT | Resume: CONTAINMENT | False/False | C02=(2,1,1,1) → — | — | — |
| 38 | C03 / CONTAINMENT | TEST CASE 03 ROOM 01 | False/False | — → — | — | — |
| 39 | C03 / CONTAINMENT | Confirm Containment | False/True | — → — | — | — |

## 요청한 종료 보고 132개 항목

| 번호 | 요청 항목 | 결과 |
|---:|---|---|
| 1 | 작업 전 Git 상태 | Step43 미커밋4수정/2추가, staged0에서 시작. |
| 2 | HEAD / branch / upstream | HEAD ad2beae1a7cbee8836bc8f811abb82740bb0d5d3, master→origin/main, 동기 상태. |
| 3 | 기존 미커밋 변경 | README/Case02/Main Scene/Main Script, Step43 doc/Case03를 baseline으로 보존. |
| 4 | Step43 재확인 | 3Case/Case02 Test Mapping/Case03 last/267 기존 회귀 계약 재확인. |
| 5 | 정상 Opportunity Map | 각 Case CCTV 최초1 + 승인된 고유 실험0~2 + CONT 최초1. |
| 6 | Non-opportunity Map | Profile/Log/Archive/Hypothesis/Recheck/Dismiss/Resume/idle/scroll/임시 선택 등 제외. |
| 7 | 전체 3-Case action timeline | 아래 FF_42_e22 전체 실제 버튼 timeline, candidate before/after/key/event 기록. |
| 8 | Case01 only Failure threshold2 | FS_20의 E02/E03 3×3 실제 실행, 대표 실험2/2 D=C02EXP01,M=C02CONT. |
| 9 | Case01 only Failure threshold3 | FS_30 대표 D=C02EXP02,M=C02CONT, strict0. |
| 10 | Case01 only Failure threshold4 | FS_40 대표 D=C02CONT,M=C03CCTV; E02=0/E03=0은 마지막 D만. |
| 11 | Case02 only Failure | SF threshold2/3/4×실험량3×3=27, D18/M9, 마지막 미완료18. |
| 12 | dual Failure | FF 9threshold×9실험량=81, D134/M87; 가장 중요한 dense Journey 재현. |
| 13 | all Success | SS 9matrix +6visual repeat, 이벤트0. |
| 14 | experiment 0 사용 | E02/E03=0 포함, 최소 meaningful7/eligible7; 사건 미노출/최종 Deferred 가능. |
| 15 | experiment 1 사용 | 각1 포함, meaningful9; 익숙한 특정 source를 다음 Case로 미룰 수 있음. |
| 16 | experiment 2 사용 | 각2 포함, meaningful11; 대표 두 Failure interruption4. |
| 17 | player action timing variation | 같은seed·선택에서 실험 수만 바꿔 사건 위치/완료 여부가 달라짐. |
| 18 | timing manipulation 가능성 | 예 FF_42_e22의 C02 마지막 교란이 E02=1이면 C03 CCTV로 밀림; meta 조작 가능, 차단 안 함. |
| 19 | F01 정확한 현재 규칙 | D 다음 eligible에서 ready1, 교란 없는 허용 CCTV/CONT에서만 presentation; EXP는 결과 유지. |
| 20 | readiness 시점 | 전체 timeline candidate major_count 전후; EXP에서 ready가 되어도 trigger=false. |
| 21 | presentation 시점 | 각 event의 실제 action_index/Case/Stage 및 draw 기록으로 별도 측정. |
| 22 | CCTV presentation 비율 | 122 Major 중 CCTV36=29.5%; matrix 표본 비율. |
| 23 | Containment presentation 비율 | CONT86=70.5%; 실제 사용자 발생 확률 아님. |
| 24 | PROFILE 안전구간 | 새 PROFILE은 count/event 없는 자유 읽기·메모 공간. |
| 25 | Containment 직전 반복 위험 | EXP02 D→CONT Major strict0; EXP1 D→EXP2 결과→CONT의 반복 학습 위험. |
| 26 | 새 Case 첫 CCTV 반복 위험 | CCTV Major36은 모두 Case01 source의 Case03 first entry; 강한 cross-case cue. |
| 27 | disturbance-first 현재 코드 | Main advance_major→advance_disturbance/FIFO→early return→EXP return→Major loop. |
| 28 | Old Major/New Disturbance 결과 | 통제 matrix New D 선택, old M ready 보존; 정상 safe bypass9도 측정. |
| 29 | Global age inversion | 정상 source2 D→source1 M 화면순서8은 EXP read-boundary도 원인; 구별. |
| 30 | 현재 starvation 재현 여부 | 무한 기회 소비 starvation은 현재 pool에서 재현되지 않음; 최종 경계 ready 잔존은 재현. |
| 31 | 3-candidate stress | 합성 A M-ready/B,C D-ready, D(B)→D(C)→M(A)→M(B)→M(C). |
| 32 | finite queue 진행 여부 | 5개의 fresh safe opportunity로 유효3후보 완료; 실제 Case04 아님. |
| 33 | continuous inflow theoretical starvation | 새 유효 D-ready가 매 safe opportunity 유입되면 early return이 old M을 이론상 무기한 지연. |
| 34 | disturbance-first 장점 | 환경 전조/현 subject 반응/개별 D→M 진행을 먼저 확보. |
| 35 | disturbance-first 단점 | global age 역전·source 기억 약화·최종 경계 점유·밀집 위험. |
| 36 | global FIFO 대안 | 전역 FIFO는 age 명확, old unready/invalid head-of-line block 위험; 구현 없음. |
| 37 | event priority 대안 | 명시 priority는 fairness 비교 가능, 전조와 old-ready 간 trade-off; 구현 없음. |
| 38 | pacing gate 대안 | meaningful gate는0간격 제한, 기회 정의/강제실험/마지막 경계 부작용; 구현 없음. |
| 39 | threshold range 대안 | 1 고정/1~N 다양성/2~N 최소지연 비교, 짧은pool Deferred 증가; 값 유지. |
| 40 | random range의 실제 효용 | range만 넓혀도 safe Stage 집중/언젠가 곧 기대/queue 공정성은 남음. |
| 41 | Event type 다양성 필요성 | D-only/delayed/direct/독립시설 후보로 반복 pattern 분화 검토만. |
| 42 | Severity 필요성 | 현재 text-only 결과에는 Severity enum 필요 근거 부족; type 다양성부터. |
| 43 | dual Failure 실제 action sequence | C01 D(C02CONT)→C01 M(C03CTV)→C02 D(EXP01)→C02 M(CONT), real buttons. |
| 44 | Major→Disturbance spacing | 대표 M→D strict0/causing1; 실험0 경로는0/0. |
| 45 | Disturbance→Major spacing | 대표 D→M strict1/causing1; threshold3·EXP02 D는0/0. |
| 46 | player breathing room | 유효 행동 간격0~4; 시간/사람 긴장감 입증 아님. |
| 47 | Research Log 사용 여지 | event 사이 Log/Back은 기회 없음, 무기한 읽을 수 있으나 자연스러운 처리 여유는 미검증. |
| 48 | Hypothesis 사용 여지 | Case03 실제 UI 메모 추가 후 counts 보존; event action 간 정보 정리는 사람 검사 필요. |
| 49 | Source Archive interaction length | Source Archive Open/Back1회당2입력, optional; stress에서는4왕복. |
| 50 | 전체 Response length | 필수5입력, Archive1회7, 검사4회13; 두 Major26응답 입력은 연구 spacing에서 제외. |
| 51 | Case01/02 Source 구분 | Major SOURCE CASE는01/02로 정확히 변경; Notice에는 직접source 이름이 없어 P2 이해 위험. |
| 52 | Current Case03 구분 | CURRENT WORK/RESUME WORK는 Case03로 유지; 시설 Notice의 subject binding은 문구만. |
| 53 | Resume 이해도 | 실제 Case03 CCTV/CONT same Runtime 복귀; Notice는 EXP/CONT 동일 View. |
| 54 | Source Archive 정확성 | 첫 response Case01 Archive, 둘째 Case02 Archive; 혼입0. |
| 55 | Hypothesis source/current 구분 | source Archive past note와 Case03 current note 분리; Archive 제목 WORKING HYPOTHESES는 UX 위험. |
| 56 | Archive incremental merge | Incident/Broadcast/Confirmed Option/Displayed Result만 해당 source incremental merge. |
| 57 | UI 정보 밀도 | source/current/긴 내용은 표시 정확, 작은 창 정보밀도 P2/개발header polish P3. |
| 58 | 1024×768 접근성 | 1024×768 native에서 C scroll선택/Confirm/Archive/Resume 실제 접근; render1024×576. |
| 59 | all-Success Event 수 | SS matrix9개 모두 D/M/B=0, visual에서도0. |
| 60 | dual-Failure Event 수 | 대표2/2 dense D2/M2/B2, interruption4; FF 전체최대4, 한Case최대3. |
| 61 | Success/Failure 콘텐츠 격차 | 대표 Archive총9→18; response8개 추가와 C02 환경 supporting1의 차이. |
| 62 | 성공 플레이어 콘텐츠 손실 위험 | 성공시 대표 Broadcast 노출0의 콘텐츠손실 위험, 실제 느낌은 사람에게 확인. |
| 63 | Scripted Incident 필요성 | 실패 독립 facility event1개는 경험보장 후보; 구현 안 함. |
| 64 | Forced Failure 비추천 여부 | 거짓 FAILURE/Forced Failure로 핵심콘텐츠를 보여주는 접근 비추천. |
| 65 | Case03 last boundary | Case03 confirmed Room/Pending 유지, Next disabled, Outcome/Campaign완료 없음. |
| 66 | final Deferred Candidate | FF_44_e22 source02 disturbed=true/major0 남음; 다른 경로 ready/untriggered도 남음. |
| 67 | sequence end 정책 필요성 | carry/drain/defer의 실제 Run/Shift 경계 정책 선행 필요; 결정 안 함. |
| 68 | Case04 필요성 | Case04는 경계 문제를 미룰 뿐; 작성 안 함. |
| 69 | Campaign boundary 선행 필요성 | Campaign/Shift 구현 전에 최소 종료정책 문서부터 권장. |
| 70 | F07-A 판정 | F07-A continuation RESOLVED:3Case실제 정상 source사건/Resume. |
| 71 | F07-B 판정 | F07-B final sequence events OPEN:82/144에 후보,17에ready. |
| 72 | Main line count | Main 1,563줄, baseline 대비0. |
| 73 | Main function count | 84함수, baseline 대비0. |
| 74 | Main 책임 | opportunity/content/selection/presentation/response/archive/debug orchestration, 다음 정책 수정 집중도 위험. |
| 75 | FailureEventCandidateState 책임 | FailureEventCandidateState는 ID/count/FIFO, UI/content조회 없음. |
| 76 | IncidentResponseState 책임 | IncidentResponseState는 active/completed identity/confirmation, authored Resource 없음. |
| 77 | Interrupt Context 책임 | Interrupt Context는 Runtime/Case identity·return Stage·Archive return·draft 임시navigation. |
| 78 | processed opportunity key 정책 | 키는Runtime별, CCTV/CONT 최초와 actual고유EXP만; user읽기 입력은 제외. |
| 79 | handoff key reset | handoff clear/new Runtime, 같은 문자열key도 새Case에서 정상소비. |
| 80 | Resume key 유지 | Resume _show_view(...,false), 후보/keys 보존, 즉시event 없음. |
| 81 | Recheck farming | 실제 Recheck/Back 후 counts/keys 그대로. |
| 82 | failed/duplicate experiment | foreign/duplicate/known over-limit 요청 뒤 전체 state 불변. |
| 83 | containment reentry | controlled CONT re-create에 같은key 재처리 없음. |
| 84 | stale CCTV | dense/crosscase 실제 old CCTV 연결 signal 뒤 state/hash 불변. |
| 85 | stale Experiment | old EXP signal 검사 및 Step43 retained EXP fixture 회귀 통과. |
| 86 | stale Containment | old CONT handoff 신호가 새Runtime/후보에 영향 없음. |
| 87 | stale Incident | old Incident advance/log 재전송 차단. |
| 88 | stale Broadcast | old Broadcast advance/foreign confirmation/log 차단. |
| 89 | stale Result | old IncidentResult advance/log가 다음 response를 시작하지 않음; debug Result 회귀도 보존. |
| 90 | stale Archive | old Archive detail/list 신호 차단; current/source state 유지. |
| 91 | invalid Candidate | missing source/incident/resolution/broadcast의 양phase8fixture, warn+retain. |
| 92 | invalid oldest Candidate queue block | 다음 valid Case02 D→M 완료, invalid만잔존; queue영구block 없음. |
| 93 | 발견 P0 | P0 재현0; 마지막Nextdisabled는 명시적prototype정책. |
| 94 | 발견 P1 | P1 재현0:wrongsource/runtime/Archive/response/data손상 없음. |
| 95 | 발견 P2 | P2 F01,0간격,priority/인과,finalDeferred,Notice/Hypothesis맥락,Success격차,small-window밀도. |
| 96 | 발견 P3 | P3 Main집중/반복invalidwarning/개발헤더·ID polish. |
| 97 | CODE findings | CODE bug finding 없음; 기존continue/false-return이 invalid oldest를 우회. |
| 98 | UX findings | UX:정보처리 여유/Notice출처/Archive메모제목/작은글자, 접근불가 재현 없음. |
| 99 | GAME DESIGN findings | GAME DESIGN:A 고정ready/Bpriority/C경계+Success경험, 서로 다른 원인. |
| 100 | CONTENT findings | CONTENT:실패만대표응답노출, Case03 마지막 정책; Case02Mapping은 여전히Test. |
| 101 | TECH DEBT | TECH DEBT:1563/84Main의정책집중, invalid로그반복, 좁은lookup/offline검사 검토. |
| 102 | 이번 Step에서 수정한 bug | 제품bug수정0; 임시fixturetyped Array/wheelrelease/legacycapture폴더만 보완. |
| 103 | 구현하지 않은 design recommendations | range/cooldown/gate/globalFIFO/priority/Severity/type다양성/Scripted/Case04/endpolicy 모두 미구현. |
| 104 | Pacing Timeline 표 | generated 전체 버튼 timeline 표와 raw144 JSON. |
| 105 | Event Density 표 | 대표16표/전체301event,1296meaningful 및opportunity,비율0.2323. |
| 106 | Threshold Matrix | 두Failure9threshold조합×실험량9 실제실행,2/2표와4/2실험variation표. |
| 107 | Ordering Matrix | Old M/New D,Old D/New M,Two M,Two D 통제표. |
| 108 | Starvation 표 | 유한3후보/invalidoldest/실제최종경계/무한유입가정 구분표. |
| 109 | Cross-Case UX 표 | Case01/02 source/current03/Resume/Archive/이해위험 표. |
| 110 | Success vs Failure 표 | 동일2/2 Success와Dual Failure 연구/중단/Archive 비교표. |
| 111 | 사람 플레이테스트가 필요한 항목 | 예측기대/피로/인과기억/복귀이해/작은글자/성공콘텐츠손실 사람검사 필요. |
| 112 | 자동 검증으로 확정 가능한 항목 | state/order/key/readiness/presentation/actiongap/access/draft/immutability 자동확정 가능. |
| 113 | 전체 normal regression | 기존199+40 16+42 20+43 32회귀와Step44정상156journey. |
| 114 | debug regression | Case01/02 debugSuccess/Failure와Monitoring/Incident/Broadcast/IncidentResult/Result 회귀 보존. |
| 115 | 3해상도 | 1920×1080/1280×720/1024×768 dense+success+SourceArchive 실버튼검증. |
| 116 | native GPU | native GL RX6800 actual draw/PNG, COption결과/Resume/다음Notice 확인. |
| 117 | headless | 전체headless172, thresholdmatrix144Journey와controlledqueue15fixture 포함. |
| 118 | Resource 불변성 | 매정상Journey content snapshot 및시작Case01/02/03file hash와일치. |
| 119 | parsing/run | 39scriptcheck/editorimport/configuredMain headless/native 통과,오류0. |
| 120 | 예상 warning / 실제 warning | 기존1278+새queue42=예상1320,실제일치;normal/visual/debug/basic0. |
| 121 | 실제 변경 파일 | Step44README수정1/보고서생성1,제품0;HEADdiff는이전Step43포함4M/3new. |
| 122 | 생성 파일 | Step44보고서1개;검사사본/계측자료는ignored step44만. |
| 123 | 삭제 파일 | 삭제0. |
| 124 | 기존 변경 보존 | 시작108개파일 중 README만추가블록,이전3973검사소스 hash보존. |
| 125 | git diff --check | git diff --check/newreport whitespace 검사 및범위검사 통과. |
| 126 | staged 없음 | staged0,HEADad2beae유지,commit/push 없음. |
| 127 | F01 최종 Audit 판정 | F01 OPEN P2;readiness정확화와122건presentation집중/0간격 측정. |
| 128 | F07 최종 재분류 | F07-A RESOLVED/F07-B OPEN으로분해,전체완료로표현안함. |
| 129 | 가장 중요한 pacing 문제 3개 | Aready1+0gap,Bpriority/sourcefairness,Cfinalevent정책부재. |
| 130 | 다음 구현 후보 3개 | 종료carry/drain정책,작은gate또는old-ready우선실험,성공독립facilityevent 후보3개. |
| 131 | 각 후보의 장단점 | 종료계약/간격개선/경험보장 장점,정책결정/새state및강제실험/범위증가 trade-off 문서화. |
| 132 | 다음 Step 추천 | Step45 Final Sequence Event Policy / Pacing Design Decision,먼저정책과사람검사. |
