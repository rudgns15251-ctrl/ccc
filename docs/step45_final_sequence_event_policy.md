# Step45 — Final Sequence Event Policy / Pacing Design Decision

2026-10-05 · Godot 4.7.1 / GDScript / Windows / 1920×1080 UI.

**추천 기본안은 ‘Case/같은 Run의 Shift에서는 carry, 최종 Run 종료에서는 미처리 의무 기록으로 conversion, 진행 중에는 읽기 경계와 최소 연구 여유를 지킨 oldest actionable 선택’이다.** 성공과 독립적인 시설 사건은 이 정책이 안정된 뒤 별도 source로 최소 한 번 제공한다. 아래는 다음 구현의 설계 계약이며 **현재 제품 동작이 아니다.** 이번 단계는 README와 이 문서만 작성한다.

## 실제 조사와 기준선

HEAD `ad2beae1a7cbee8836bc8f811abb82740bb0d5d3` (`Improve major incident response content and reading boundaries`), branch `master`, upstream `origin/main`. 저장소는 `https://github.com/rudgns15251-ctrl/ccc.git`을 사용한다. 작업 시작에는 Step43의 README/Case02/Main Scene/Main Script 수정 4개, Step43 보고서/Case03/Step44 보고서 추가 3개가 있었다. staged는 없었다. 이 미커밋 상태를 baseline으로 보존한다.

전체 파일 inventory, project.godot, README, Step43/44 보고서, Main, 7개 State, Case sequence, 기회 처리·교란 선택·readiness·presentation·handoff·last Case·normal/debug 경로 및 verification 자료를 조사했다. 적용할 AGENTS.md는 저장소와 상위 경로에서 발견되지 않았다. 실제 정상 sequence는 Case01→02→03, Scene15/Script39/Autoload0이며 Main은 1,563줄/84함수다. 기존 기준 UI/Stretch/Renderer 설정은 보존한다.

Step44 원본 `audit_*_1280_headless.json`을 다시 집계해 144 Journey, Major122(CCTV36=29.5%, CONT86=70.5%), 마지막 후보82경로/그중 ready17, strict meaningful 최소0, 한 Case 최대3 interruption을 재확인했다. P0/P1/code bug 없음, invalid oldest 우회와 유한3후보 진행은 기존 로그 계약대로다. 무한 새 교란 유입의 starvation은 코드 분석상 가능성이며 현재3Case에서 무한 유입이 재현된 것이 아니다.

이번에는 291개 Godot 실행을 다시 수행하지 않는다. Step44의 291개 최종 suite/별도 Main·import3개 로그 해시와 기존 소스 보존을 재확인한다. 정책의 효과를 구현·GPU·사람 테스트로 검증했다는 의미가 아니다.

| Finding | 현재 상태 | 이번 설계의 대응 |
|---|---|---|
| F01 | OPEN: ready1 고정/좁은 표시 경계의 예측성 | 읽기·여유 계약 선택; 완전한 예측성 해결은 미입증 |
| F44-01 | OPEN: Major→교란 및 교란→Major 사이 연구0 | Major만이 아닌 모든 interruption 사이 최소 연구 여유 |
| F44-02 | OPEN: 교란 우선의 age inversion/마지막 경계 점유 | oldest actionable 권고, 타입 우선·bypass counter는 채택 안 함 |
| F07-A | RESOLVED: 실제3Case continuation/동일 Runtime 복귀 | Case handoff carry 유지 |
| F07-B | OPEN: final sequence disposition 없음 | 종료 종류/책임 이전 계약 선택; 구현 전에는 해결 아님 |

## 종료 용어

| 용어 | 정의 | 현재 구현 |
|---|---|---|
| CASE END | 현재 연구·Room 판단의 제출과 업무 handoff; 사건 전체 완료와 다름 | 유효 다음 Case가 있으면 hidden resolution 후 handoff |
| TEST SEQUENCE END | 다음 Test Case가 설정되지 않은 개발 경계 | Case03의 `No next test case configured`; Pending/Runtime 유지 |
| SHIFT END | 같은 Run 안에서 업무 단위를 잠시 닫고 다음 Shift로 이어감 | [미구현] 시간 길이/Case 중간 휴식 여부 [미정] |
| RUN END | 해당 Run에서 더 이상 정상 업무를 진행하지 않는 경계 | [미구현] 종료 조건·결과 모델 [미정] |
| VOLUNTARY SETTLEMENT | 향후 할당량 달성 뒤 플레이어가 계속 업무 대신 Run 정산을 선택 | [미구현] quota/보상/허용 조건 [미정] |
| FORCED RUN END | 향후 할당량 실패 등 외부 조건으로 Run이 종료됨 | [미구현] 원인별 즉시 중단/표시 방식 [미정] |
| CAMPAIGN END | 여러 Run을 포함하는 전체 이야기의 최종 종료 | [미구현] 최종 연출·전체 잔여 사건 처리는 이번 범위 밖 [미정] |

Case03 Confirm은 Run 성공/실패/정산이 아니다. 지금의 마지막 Pending은 판정되지 않은 제출이며 Failure Candidate와도 다르다. Case03에 Outcome을 만들어 이를 닫거나 가짜 Next opportunity를 넣지 않는다.

## 종료 대안과 선정

| 대안 | 장점 | 단점 | 판단 |
|---|---|---|---|
| A CARRY | 지연 철학/기존 session State와 자연스러움; 가짜 기회 없음 | 완전히 닫힌 Run에는 이어갈 업무가 없음; 삭제 reset이면 정산 회피 | Case/같은 Run의 Shift 기본 |
| B DRAIN | ready 사건에 직접 대응; 종료로 사건을 숨기기 어려움 | 종료 사건 몰림; undisturbed를 억지로 Major화; 연구 업무 없는 response queue | 일괄 drain 비추천 |
| C SETTLEMENT CONVERSION | fake 기회·끝 사건 spam 없이 unresolved 결과 보존 | 대응 콘텐츠를 못 볼 수 있음; 결과 의무/소유 모델 필요, 피해·경제 아직 없음 | 최종 Run의 기본 |
| D HYBRID | 진행 carry와 최종 책임 보존을 분리; Active Response만 마무리 가능 | 경계별 계약을 정확히 구별해야 함 | **A+C+현재 active 처리의 한정된 hybrid 선정** |

선정 기준은 consequence 회피 방지 → random timing의 끝 사건 spam 방지 → 진행 중 지연 긴장 → 향후 Run/Shift 연결 → 불필요한 구조 방지 순서다. ‘만들기 쉬워서’만 선택하지 않는다. Shift ready-Major drain 예시는 채택하지 않는다. 같은 Run의 Shift를 쉬는 시간으로 보장하고 다음 정상 업무에서 후보를 이어간다.

**Conversion은 완료·면제·Success 판정이 아니다.** unresolved 사실과 후속 책임을 종료 결과의 소유자에게 이전한다. 이미 실패한 판정은 그대로이며, 아직 사건 UI를 보지 않았다는 이유로 의무를0으로 만들 수 없다. 실제 피해/비용/점수/다음 Run 영향은 [미정]이지만, 향후 결과 모델은 이 의무를 반드시 소비해야 한다. 지금은 결과 모델/영구 저장이 없으므로 ‘현재 회피 불가능한 경제 페널티가 구현됐다’고 주장하지 않는다.

### 경계 계약

1. 일반 Case/같은 Run의 Shift에서 후보 ID·phase·count·created order를 그대로 보존한다. Shift를 새 Run처럼 reset하지 않는다. source Case/Incident/Broadcast/Result와 Archive의 고유 콘텐츠 lookup도 다음 업무에서 접근 가능해야 한다. 새 Shift의 Case 배열을 갈아끼워 과거 source만 unavailable로 만드는 것은 carry 완료가 아니다. CandidateState에 Resource를 저장하거나 전역 Registry를 미리 만들라는 뜻은 아니다. 환경 조건은 현재 Runtime 사실이며 후보 carry와 구별한다. 새 Case에 환경을 자동 복사하지 않는 기존 정책을 유지한다.
2. Run 닫기 요청에는 **이미 표시 중인 정상 Response만** 마무리 대상으로 삼는다. 자발 정산과 계획된 Shift 종료는 진행 중 response의 정상 Confirm/Result까지 완료한 뒤 경계를 확정한다. unconfirmed Option 자동 선택, fake completion, 다음 후보 연쇄 drain은 금지다. inactive 후보 존재 자체는 정산 금지 사유가 아니다.
3. 강제 Run 종료에서는 사용자가 응답할 수 있다는 가정을 하지 않는다. active response identity/이미 확정한 선택/표시된 연구 사실을 ‘응답 중단’ 종료 기록으로 보존하고 미처리 책임도 이전한다. 이를 `IncidentResponseState.Status.COMPLETED`나 자동 A/B/C 결과로 바꾸지 않는다. 이미 승인한 대응과 공개한 결과가 있다면 종료 결과도 그 사실을 인정해야 하며, Resume를 누르지 못했다는 이유만으로 ‘아무 대응도 하지 않음’의 책임을 중복 부과하지 않는다. 중단은 미래 종료 기록의 개념이며 현재 enum을 추가하지 않는다.
4. final Run에서 정상 제출된 Pending에 고유하고 유효한 Outcome이 있다면, 다음 Case 유무와 독립적인 정규 hidden-resolution 경계를 먼저 적용해야 한다. 그래야 마지막 제출 직후 정산으로 Failure 판정을 피하지 못한다. Case03처럼 Outcome이 없거나 불명확한 Pending은 **미판정 제출**로 보존하며 Success/Failure를 추측하지 않는다. 미제출 업무도 완료 성공으로 세지 않는다. 최종 콘텐츠의 Outcome 완전성은 향후 작성 검사의 대상이다.
5. 준비된 Major도 Run 끝에서 모두 재생하지 않고 phase를 보존해 conversion한다. Major-ready를 ‘진행 중’을 뜻하는 active response와 혼동하지 않는다. completed response는 재생·중복 conversion하지 않는다.
6. 경계 확정 전에 모든 의무의 책임 이전을 검증한다. 논리적으로 `Run/boundary + source_case_id + incident_id`에 대해 동일 종료 요청이 중복 기록/이중 책임을 만들지 않아야 한다. 소유자가 수락하기 전 Candidate/Pending/session reset 금지. 무조건 동일한 RefCounted 객체를 미래 Run까지 살리라는 뜻은 아니다.
7. 미발견 Incident/Option/Result의 authored Research를 종료 기록으로 자동 해금하지 않는다. 실제 표시된 Research만 기존 Archive에 incremental merge한다. 종료 의무 기록은 **발견 Research와 별도의 사실 범주**이며 current/source 가설·확정 Room·과거 관찰은 바꾸지 않는다. 상세 종료 UI의 공개 범위는 [미정]이다.

### End Boundary Matrix — 미래 권장, 현재 API 아님

| Boundary | Pending | Resolution | Undisturbed | Disturbed-not-ready | Major-ready | Active Response |
|---|---|---|---|---|---|---|
| Case End | 기존 유효 handoff 판정 후 제거; invalid 유지/진행 보류 | 고유 hidden 기록 유지 | carry | carry | carry | 응답을 끝낸 뒤 handoff; nested 전환 금지 |
| Shift End, 같은 Run | carry/재개; 임의 Outcome 없음 | 유지 | carry | carry | carry, 강제 drain 없음 | 계획된 종료는 현재 응답만 마무리한 뒤 pause |
| Voluntary Settlement / final Run | 유효 제출은 정규 판정; unknown은 미판정 의무 기록 | 결과 기록으로 유지 | 미처리 의무 conversion | 실제 교란 사실+미처리 의무 conversion | ready 사실+미처리 의무 conversion | 현재 response만 정상 완료 후 종료; 다음 후보는 재생하지 않음 |
| Forced Run End | 판정 가능한 제출만 정규 판정; unknown/미완료 구별 | 실패 Run에서도 보존 | 미처리 의무 conversion | 같은 conversion | 같은 conversion | 중단 identity/확정 선택/공개 사실 기록; 자동 완료 없음 |
| Campaign End | [미정] | [미정] | [미정] | [미정] | [미정] | [미정], 사실 삭제/거짓 완료는 공통 금지 |

Test Sequence End는 이 표의 Run End로 자동 취급하지 않는다. 다음 구현에서도 명시적 Test-only closure snapshot과 실제 Run 정산을 구별해야 한다.

### Candidate State Matrix

| phase | ACTIVE RUN | SHIFT END, 같은 Run | FINAL RUN END |
|---|---|---|---|
| Undisturbed | 기존 eligible count; 실제 교란만 표시/적용 | progress 그대로 carry | unmanifested obligation; 교란·Major를 강제 생성하지 않음 |
| Disturbed-not-ready | 이후 eligible로 ready 진행, 읽기 여유 | actual 시설 사실과 phase 구분해 carry | actual 교란+unresolved obligation |
| Major-ready | 아래 gate/safe/read/content 조건 충족 때 경쟁 | ready 그대로 다음 Shift carry | ready-but-unresponded obligation |
| Active Response | 한 개만, 선택/Source Archive/Result 이후 완료 | 계획된 pause는 active만 끝냄 | 자발은 완료, 강제는 interrupted record |
| Completed Response | 소스 후보 제거/사실 기록 유지 | 완료 기록 유지 | 재생·중복 부담 없음 |
| Invalid Candidate | warning+retain, 유효 actionable 후보는 우회 | 기록을 보존하고 작성 오류 표시 | unavailable/미처리 사실 이전; 거짓 완료 없음 |
| Pending without Outcome | Candidate 아님; 판정 사실 없음 | 제출 상태 보존 | unresolved submission, Failure로 바꾸지 않음 |

### 자발 정산 회피 대안

| 대안 | 이점 | 문제 | 선정 |
|---|---|---|---|
| ready Incident 전부 처리 후 정산 | ready consequence 직접 경험 | 남은 후보 수만큼 response 강요/끝 spam | 비추천; 이미 active인 응답만 끝냄 |
| 미처리를 정산 결과에 반영 | 언제 정산하든 의무가 남고 선택권 유지 | 결과 모델/책임 이전 필요 | 선정 |
| 후보가 있으면 정산 불가 | 조건 단순 | hidden 후보 존재 노출, undisturbed 때문에 강제 추가 업무 | 비추천 |
| 다음 Run까지 원래 후보 carry | 다음 업무에 늦은 사건 가능 | 독립 Run/reset/save 관계 복잡, 플레이어 기대 혼란 | 기본안 아님; 장기 세계 연속성 [미정] |

자발 정산은 아직 보지 않은 Broadcast **상호작용**을 피할 수 있지만 그 실패 의무를 없애지는 못한다. 상호작용 회피와 consequence 삭제를 같은 것으로 다루지 않는다. 강제 종료는 이미 Run이 실패했다는 이유로 과거 성공·실패·교란·선택을 삭제하지 않는다.

## 진행 중 pacing 계약

**추천은 readiness 수치 조정 없이, 표시 단계에 ‘최근 interruption 이후 최소1개의 새 의미 있는 연구 진행 완료’와 read-before-event를 적용하는 것이다.** F44-01의 Major→새 교란0간격까지 다루려면 gate는 Major만이 아니라 **Disturbance와 Major 모두의 presentation**에 적용해야 한다. readiness progression은 기존 eligible 정책과 분리하고, 새 기회/Timer/매 화면 acknowledgment를 만들지 않는다. 이 최소1은 미래 정책의 시작안이며 실제 효과·피로 감소는 구현 후 검증 대상이다.

### 어떤 행동을 완료로 셀 것인가

| 입력/정보 | 권장 credit | 완료 경계 | 주의 |
|---|---|---|---|
| 새 Case Base CCTV 최초 관찰 | Yes, 고유 source1회 | 실제 draw된 관찰에서 기존 Next를 자발적으로 누를 때 | entry 자체는 읽기 완료 아님; Recheck/Log 복귀는0 |
| 승인된 새 Experiment 결과 | Yes, 고유 ID1회 | 결과가 draw된 뒤 기존 Next로 결과 화면을 떠날 때 | ‘successful’은 실행 승인, 실험 정답/성공 판정이 아님 |
| Containment entry | No | 없음 | event opportunity와 research credit를 구별 |
| Containment Confirm | Yes, Room 판단1회 | 유효 확정 기록이 승인된 뒤 | 같은 Confirm callback에서 사건 금지; 선택·Room 판정 소급 변경 없음 |
| Case handoff / 새 Profile entry | No | 없음 | navigation으로 gate를 열어 실험 생략 메타를 숨기지 않음 |
| Log/Archive/Hypothesis/scroll/idle/Dismiss/Resume | No | 없음 | 읽을 자유는 있지만 farming credit 없음 |

기존 Next는 완료의 **관찰 가능한 대리 신호**다. 사람의 실제 이해를 확인했다고 표현하지 않는다. 같은 CCTV/결과를 왕복해 credit를 재사용할 수 없다. 실험 화면에서 연속 Run을 눌러도 그 callback에서 Major를 표시하지 않는다. 최소 gate에는 화면을 떠날 때 마지막 승인 결과1개가 충분하므로 모든 이전 Run에 별도 Read 버튼을 요구하지 않는다. 여러 실험의 과거 결과/condition 기록은 그대로 유지한다.

표시 가능한 자연스러운 사용자 경계는 앞으로 **CCTV의 Next(정보를 읽고 떠나는 경계), EXP Next→CONT, 확정 CONT의 Next→handoff**를 우선한다. CCTV 최초 entry/Run result 생성/Confirm callback에서 새 정보나 결정이 바로 덮이지 않게 한다. 이 새 presentation checkpoint는 **eligible opportunity 추가가 아니다.** 이미 ready인 사건을 표시할 수 있는 위치만 명시적으로 확장하는 미래 변경이다.

CCTV Next에서 중단하면 현재 CCTV를 복귀 업무로 기록하고, Resume 후 사용자가 Next로 이어간다. 확정 CONT Next에서 중단하면 같은 CONT/확정 잠금으로 복귀한 뒤 handoff한다. Resume는 원래 Next를 자동 재실행하거나 다른 사건을 표시하지 않는다. dedup된 credit가 재복귀 Next에서 다시 생기지 않아야 한다. EXP→CONT의 presentation은 기존 결과가 draw되고 사용자 Next 이후에만 가능하며 실제 CONT 복귀 위치를 명시한다. 아직 임시 Room 선택이 있는 View를 중단할 때는 그 선택을 잃지 않는 계약도 필요하다.

### 최소 gate의 범위

각 interruption이 **실제로 표시될 때** 공유 `연구 여유 없음` 상태로 돌아가고, 위의 새로운 완료1개가 뒤에 발생하면 여유가 열린다는 개념이다. 시작은 여유가 열린 상태로 두되 새 source의 읽기 경계는 별도로 지킨다. 직전 표시 사건 이후의 여유를 공유하므로 own Disturbance 이후의 Major도 적어도 하나의 뒤 연구 진행을 요구하게 된다. Case handoff/Shift carry는 여유를 자동으로 열지 않는다.

이 정책에는 per-candidate bypass/Severity/score scheduler가 필요 없다. 미래 구현은 Main의 session bool1개와 source 완료 dedup 정보로 시작할 수 있다. bool·source token은 아직 없는 **개념적 데이터**다. Candidate record에 개별 gate count를 넣는 안은 source별 전조 간격을 따로 제어할 때만 재검토하며 기본안에서는 불필요하다. 새 EventPacingState/Manager/Singleton은 추천하지 않는다.

gate가 닫힌 동안에는 시설 적용도 표시와 일치시켜야 한다. D-ready 자체만으로 조건을 몰래 적용하거나 reaction Research를 발견하지 않는다. Notice를 실제 표시·적용한 이후의 실험만 그 조건을 기록한다. 따라서 구현 후 optional condition observation의 타이밍은 현재 baseline과 달라질 수 있다. Base 필수 근거를 잃거나 과거 실험을 바뀐 환경으로 재작성해서는 안 된다.

### 실험0 경로와 마지막 경계

실험0이어도 새 CCTV를 읽고 Next를 누르는 행동과 실제 Confirm이 credit를 제공한다. 마지막 CONT 진입에서 교란이 표시된 경우는 이후 Confirm을 완료하고 Next intent를 통해 ready 여부를 확인하거나 다음 Case로 carry한다. Confirm 직후는 interrupt 금지이며 이미 결정한 Room을 취소·오답화하지 않는다. 새 CCTV entry에서 사건이 덮이지 않아 실험을 하지 않는 플레이어도 정상 정보를 읽을 수 있다.

이미 Confirm까지 마친 뒤 사건이 표시되어 마지막 업무에 **새 연구 진행이 남아 있지 않으면**, 억지 실험·idle·가짜 key로 gate를 열지 않는다. 같은 Run에 다음 업무가 있으면 carry, 실제 final Run이면 conversion한다. 따라서 gate 때문에 마지막 deferred가 늘어도 영구 response 강요가 되지 않는다. 사용자가 실험을 줄여 표시 timing을 조절할 여지는 남으며 ‘조작 불가능’이라고 주장하지 않는다. 의무 conversion이 consequence 삭제를 막는다.

Major1은 반응이 빨라 테스트 reachability가 좋지만 고정 기대와0간격을 만든다. 1~N은 다양성,2~N은 최소 지연을 줄 수 있으나 safe Stage 집중·last Deferred·fairness·Success gap을 단독 해결하지 못한다. **현재 threshold2~4/major1/RNG는 그대로이며 다음 기본안에서도 먼저 gate 효과를 분리해 비교한다.** 고정 ready1의 예측감은 완전히 해결했다고 판정하지 않는다.

### Pacing Rule Matrix

| Rule | Predictability | Event density | Deferred risk | Code complexity | Player manipulation | Recommendation |
|---|---|---|---|---|---|---|
| Current major1 | readiness 고정, safe Stage 학습 | 연구0간격 가능 | 현재도 있음 | 현재 최소 | 실험 수로 timing 이동 | baseline 보존 |
| Threshold range | readiness 다양, 경계 집중은 남음 | 분산 가능하나 보장 없음 | 증가 가능 | 작은 RNG/record 변화 | 행동량·정산 timing 전략 | 단독 해결로 채택 안 함 |
| Meaningful gate + 읽기 | 여유 보장, ‘Next 뒤 사건’ 기대는 남음 | 최소1 완료 연구 | 증가 가능, conversion 필요 | 완료 dedup/표시 경계 | skip/반복 credit 우회 방지 필요 | **pacing 기본안** |
| Old-ready Major priority | age는 명확 | 간격을 보장하지 않음 | old 잔존 감소 가능 | 선택 loop 변경 | 연구량 조절 여전 | 전체 oldest actionable와 비교 |
| Hybrid bypass fairness | 타입 기대는 유지, aging 예외 | 별도 gate 없으면 밀집 | 감소 가능 | bypass reset/counter/예외 증가 | bypass 행동의 메타 위험 | 현재 규모에는 보류 |

## Ordering 계약

**기본안은 global oldest actionable event다.** created order로 후보를 보고 **지금 실제 표시 가능한 phase**만 선택한다. ‘가장 오래된 Candidate가 완료될 때까지 모두 대기’하는 strict oldest-candidate는 채택하지 않는다.

Actionable은 source/Incident/response chain 고유·유효, 해당 phase ready, 현재 연구 여유 gate 충족, 새 정보 읽기 경계 통과, active response/Notice 없음, 정상 사용자 presentation checkpoint라는 조건을 모두 만족한다. future 다른 event type에도 자기 eligibility를 적용한다. unready/invalid/source와 current 불일치/표시 불가 phase는 보존하고 **건너뛴다**. 후보의 created order는 기존 `_case_order`를 활용할 수 있으며 priority score나 새 Severity가 필요 없다.

| 경쟁 상태 | 현재 disturbance-first | 추천 oldest actionable | 조건 |
|---|---|---|---|
| Old Major / New Disturbance | New D | Old M | old M이 gate/read/safe/content 조건까지 충족 |
| Old Disturbance / New Major | Old D | Old D | old D actionable |
| Two Major | Old M | Old M | active1개, 완료 뒤 다음 여유 필요 |
| Two Disturbance | Old D | Old D | 표시 한 번, 다음 사건은 새 여유 필요 |
| Old unready / New ready | New의 해당 ready phase | New actionable | head-of-line block 금지 |
| Old invalid / New valid | invalid retain+warning, next 시도 | 같은 retain+skip | unavailable 후보를 completed로 속이지 않음 |

old-ready 우선은 가장 큰 priority inversion을 줄이지만, 모든 ready Major를 무조건 Disturbance보다 우선하면 오래된 D보다 새 M이 앞서는 새 타입 bias를 만든다. global oldest actionable은 양쪽 타입과 created order를 같이 보며 개별 사건은 자신의 D→M 순서를 유지한다. hybrid fairness는 전조 장점을 남길 수 있으나 bypass counter/상한/초기화/표시 불가에서의 aging 정의가 더 필요해 지금 기본안보다 설명하기 어렵다.

실제 현재 최대 후보2개, 통제 stress3개이며 정식2시간 Run의 Case 수·실패율은 [미정]이다. 수십 후보를 상정한 Director/Scheduler는 필요 근거가 없다. finite actionable 집합은 충분한 연구 진행과 checkpoint가 있으면 oldest부터 진행한다. 이미 actionable인 오래된 Major는 계속 더 새 D가 유입돼도 age 순서에서 밀리지 않는다. 다만 gate 미충족/기회 고갈/content invalid는 별도 지연 원인이므로 절대 완료 보장을 하지 않는다. Run conversion은 이 잔여를 보존한다.

## 성공과 독립적인 경험

현재 all Success D/M/B=0은 F01/F44-02와 별도 콘텐츠 문제다. 실패 consequence의 추가 사건을 성공 플레이어에게 모두 복제하지 않는다. **최소1개의 authored scripted facility 사건**을 향후 권장한다. source는 시설 자체/다른 부서이며 성공한 Case의 숨겨진 Failure로 위장하지 않는다. 모든 성공 Resolution/Room 판단은 유지하고 실패 수를 늘리지 않는다.

공통 핵심 범위는 실제 facility anomaly 관찰 → 시설 source의 Broadcast 선택 → 실제 표시/확정 결과의 Archive 기록이다. 공포가 실제로 성립하는지와 피해 규모·어떤 Archive UI/저장 범주로 나타낼지는 [미정]이다. 현재 Case별 ResearchArchive에 가짜 `Case00`이나 미발견 연구를 섞는 구현은 추천하지 않는다. 시설 source 기록의 명시적 범위를 별도 설계해야 한다.

Timing은 ‘Case03에서 항상 사고’나 무작위 generic horror 확률이 아닌 authored narrative/facility milestone의 적격 창으로 설계한다. 같은 pacing/read/order 계약을 적용하고 정상 연구 여유에서 제공한다. 그러나 **모든 독립 source가 후보 순서의 맨 뒤로만 들어가면 failure queue 때문에 공통 경험이 또 미노출될 수 있다.** 최소 공통 경험은 age priority를 깨는 긴급 예외로 보장하지 않고, 자발 정산이 가능한 milestone을 설계하기 전에 정상 업무 안에 경험 창을 확보하는 콘텐츠 계약으로 달성한다. 정상 완료 Run의 최소1회 경험은 기본안으로 선정한다. 실제 milestone과 강제 종료로 창에 못 도달했을 때의 표현은 [미정]이다.

그 창을 못 거친 강제 조기 종료나 현재처럼 짧은 Test Sequence에 대해 ‘무조건 Broadcast 경험 완료’라고 주장하지 않는다. 미발생 독립 사건을 종료 직전에 강제로 재생하지 않으며 최종 결과의 미처리 세계 사실로만 남길 수 있다. 성공 의미를 지키는 기본안은 정상 완료 가능한 Run에 **실패와 별개인 최소 시설 경험1회**, Failure run에는 추가 consequence 사건이다.

| Event type | 가능 가치 | 주의 | 권고 |
|---|---|---|---|
| disturbance-only | 연구 중 독립 시설 변화, D→M 공식 깨기 | 이후 Major가 없는 것을 누락 bug와 구별할 authored 계약 | 미래 콘텐츠 후보 |
| delayed-major | 원인 기억과 지연 기대 | 범위만 늘리면 끝 deferred 확대 | 별도 pacing 비교 후보 |
| direct-major | 전조 없이 다른 양상 | 필수 근거·읽기 침해, 모든 Failure에 적용하면 불공정 | 특별한 authored 근거 때만 후보 |
| scripted-facility | 성공과 독립적인 핵심 시스템 경험/세계 사건 | 정산 직전 몰림·새 source 기록 범위 필요 | 정책 안정 후 최소1개 권장 |

**Severity는 보류.** 피해 규모·비용·대응 난이도·Run consequence/priority에 실제 쓰이는 모델이 있을 때 도입한다. 현재 text-only 결과에서는 event type만으로 다양성을 만들 수 있다. 성공한 모든 플레이어에게 같은 재난·같은 피해를 강제해 성공 의미를 지우지 않는다.

### Success Experience Matrix — 미래 권장량, 확정 밸런스 아님

| 경로 | Failure D / Major / Broadcast | Archive 변화 | 공통 scripted facility |
|---|---|---|---|
| All Success | Failure0/0/0 유지 | 정상 연구+공통 시설의 실제 표시/확정 기록 | 정상 완료 Run의 적격 창에서 최소1회 목표 |
| One Failure | 해당 failure type와 진행에 따라0~1씩, 미처리는 conversion | source 연구/response 실제 공개 증분+공통 시설 기록 | 같은 창, 필요하면 여유에 맞춰 이연 |
| Dual Failure | 현재 D→M형이면 최대2씩, 전부 gameplay에서 강제 완료하지 않음 | source별 기록 분리+미처리 의무 구별 | 추가 사건 밀집 방지, 정상 진행 창 확보 |

후보 개수와 event type은 아직 최종 게임 콘텐츠량이 아니다. Living Research Archive의 사실 누적은 유지하며 새 세계 이벤트로 과거 연구를 거짓으로 만들지 않는다.

## 통합 Policy Set

| 계약 | 선정 기본안 | 구현 상태 |
|---|---|---|
| A Active Case/Run carry | 일반 handoff와 같은 Run의 업무 연속성에 source/phase/진행 보존 | 기존 Case carry만 구현, Shift는 [미구현] |
| B Run/Shift end | 같은 Run Shift carry, final Run obligation conversion; active만 자발 완료/강제 중단 기록 | [미구현], Test Sequence와 구별 |
| C Major pacing | readiness 유지 + 모든 interruption 사이 완료된 새 연구1개 + read-before-event checkpoint | [미구현], 수치/RNG 그대로 |
| D Event ordering | 가장 오래된 현재 actionable event, invalid/unready는 retain+skip | [미구현], 지금은 disturbance-first |
| E Success-independent | 정상 완료 Run의 authored 적격 창에서 시설 source 경험 최소1회 | [미구현], 거짓 Failure 없음 |

## 통합 Decision Table

| Policy Area | Option A | Option B | Option C | Recommended | Reason | Implementation Cost | Risk |
|---|---|---|---|---|---|---|---|
| Case/active Run | carry | 일괄 drain | conversion | carry | 지연 consequence와 기존 handoff 유지 | 작음, 계약/회귀 | final 경계가 없으면 누락 |
| Shift same Run | carry | ready만 drain | 모든 drain | carry, active만 마무리 | 업무 휴식·전조 단계 보존 | 작음~중간, pause 범위 결정 | ready가 다음Shift로 이연 |
| Final Run | carry-only | drain-all | conversion | carry+final conversion hybrid | 회피/끝 spam 동시 방지 | 중간, 결과 의무/ownership | 실제 결과 모델 미구현 |
| Voluntary active response | active만 완료 | 후보 있으면 정산 금지 | 자동 Option | active만 완료+나머지conversion | 현재 책임은 처리, hidden 후보로 퇴근 막지 않음 | 중간, closure guard | interrupted 상황과 구분 필요 |
| Forced active response | 자동 완료 | 삭제 | interrupted 기록 | interrupted+의무이전 | 선택/사실을 거짓으로 만들지 않음 | 중간, 독립 종료 기록 | 표현/후속 비용 미정 |
| Pacing | major1만 유지 | range만 변경 | 의미진행+읽기 gate | gate; readiness/RNG는 먼저 유지 | 0간격·정보 유실 직접 다룸 | 중간, dedup/checkpoint | deferred/Next 기대 증가 |
| Ordering | D-first | Major type 우선 | oldest actionable | oldest actionable | old fairness, unready HOL 방지 | 작음~중간, selector/회귀 | 새 전조가 늦어짐 |
| Common experience | Failure만 | Forced Failure | authored facility | 독립 authored 최소1개 목표 | Success 진실/핵심 경험 동시 유지 | 중간, source 기록 경계 | eligible 창·조기종료 미정 |
| Severity | 지금 도입 | 영구 배제 | 실제 consequence까지 보류 | 보류 | enum보다 실제 행위 차이 우선 | 이번0 | 나중 schema 검토 필요 |

## 검증 가능한 통합 계약과 충돌 점검

| 계약 예 | 권장 결과 | 검사할 불변조건 |
|---|---|---|
| 일반 handoff, disturbed/ready source01 + source02 새 실패 | 두 후보 carry, 새 Runtime/기회 key만 정상 reset | source ID/count/order와 session identity 보존 |
| 같은 Run Shift pause, old ready | 기회·gate를 만들지 않고 다음 업무로 carry | pause/resume가 farming 아님 |
| Run 종료, 미발생/교란/ready 각 후보 | phase별 obligation snapshot, 사건 UI0개 강제추가 | count/RNG 증가0, completed로변경0, 의무수 누락0 |
| 자발 정산 중 active 응답 | 현재 응답 정상 완료, 나머지 의무 이전 | Option 자동선택0, 다음 response 자동drain0 |
| 강제 종료 중 unconfirmed/confirmed 응답 | interrupted+현재선택 사실, 미완료 의무 | completed/미표시Result발견0, 중복부담0 |
| 최종 Pending의 Outcome valid/없음/duplicate | valid는정규판정, 나머지는unknown제출 | false Success/임의Candidate0, Case03정책과구별 |
| D 이후 신규 EXP 결과 | draw→자발Next→credit; Major-ready라야 eligible표시 | 결과/condition가 사라지거나소급되지 않음 |
| 실험0, 새 CCTV와 Confirm | 실제 정보/판단으로gate진행; 없는기회는conversion | 강제Run/idle/Archivefarming0 |
| Old M/New D 둘 다 actionable | Old M; gateblocked/unready/invalid는skip | 한checkpoint한event, active1개, valid후보HOL0 |
| 성공독립 시설 사건 | 성공Resolution 유지, 시설source 사실기록 | 거짓Failure/가짜CaseID/CaseResearch혼입0 |

이 표는 문서의 논리 검사이며 미래 코드 테스트 통과 결과가 아니다. 자동 검증 후보는 carry/phase/ownership transfer의 멱등성, gate credit dedup, read draw, priority, final conversion, optional ready drain 대안의 무승격, Archive/source/current identity, same Runtime Resume, invalid/stale/double key/normal-debug 분리다. 기본안은 final drain을 하지 않으므로 자동 검사에서도 **종료가 ready나 undisturbed를 강제 표출하지 않음**을 확인한다.

## 사람 플레이테스트 계획

먼저 현재 baseline에서 A All Success, B Case01 Failure only(대표3 및4), C Case02 Failure only(2/3/4의마지막경계), D Dual dense(4/2,2실험씩)를 비교한다. 실험0 경로도 B/D의 보조표본으로 둔다. 방금 읽은 결과·다음 업무·source를 자신의 말로 설명하게 하고, 사건이 나오기 전에 ‘지금 예상되는가’를 짧게 기록한다. source/correct Room을 미리 알려주지 않는다.

구현 후에는 동일 authored 콘텐츠·Room/seed·실험 선택과 세 해상도로 carry/종료기록, gate, ordering을 하나씩 비교한다. presentation이달라져도 기존 사실/정보source가동일한지 확인한다. 시행 순서를 바꿔 학습효과를 줄이고 참가자수·목표효과크기는 [미정]으로 둔다. 시간은 보조이며 예측감/정보처리/피로/source기억/Resume 업무복구가 핵심이다. 사람 테스트는 이번에 수행하지 않았다.

짧은 질문9개(1~5점과 자유응답):

1. 다음 사건이 언제 나올지 쉽게 예상했나요? 예상한 버튼/이유도 적어주세요.
2. 사건 때문에 정상 연구가 너무 자주 끊겼나요?
3. 방금 실험 결과를 충분히 읽고 비교할 수 있었나요?
4. 마지막 Incident의 원인 Case와 현재 업무 Case는 각각 무엇이었나요?
5. Source Archive를 몇 번 열었고 무엇을 확인하려 했나요?
6. Resume 직후 어떤 업무를 이어야 하는지 분명했나요?
7. 성공 경로에서도 시설/Broadcast 핵심 경험을 충분히 봤나요?
8. 실패 경로의 사건은 결과로 이해됐나요, 과도한 벌처럼 느껴졌나요?
9. 긴장/피로/혼란이 가장 컸던 구간과 바꾸고 싶은 점을 적어주세요.

자동화는 실제 두려움·재미·적당한 긴장·읽기 이해를 확정하지 못한다. 정책 확정은 설계 기본안 선정이며 사용자 체감 승인이나 밸런스 완성 선언이 아니다.

## 다음 구현의 좁은 범위

| 순서/후보 | 예상 변경 경계 | 규모/위험 | 이번 구현 |
|---|---|---|---|
| 1. Test Sequence boundary disposition 계약 | 명시적인 test-only 종료 snapshot/미처리사실·책임 이전 검증; Main read-only 조립과 작은 기록 구조/fixture | 작음~중간, Run정산과Test끝을혼동하거나unknownPending을Failure로만드는위험 | 없음 |
| 2a. Oldest actionable ordering | 기존 Main 선택 loop의 ready/content filter/created order, CandidateState FIFO 재사용 | 작음~중간, 새D전조 지연/normal-debug/현재late회귀 결과변화 | 없음 |
| 2b. Read/meaningful presentation gate | Main의공유여유bool/완료dedup/자발Next checkpoint, 필요시View 표시snapshot 연결 | 중간, Case01/02/03condition 발견 timing변화·잠금/복귀·실험0/lastdeferred | 없음 |
| 3. Success-independent facility 사건 | 최소1authored시설source/content와명시적Archive범위/적격창 | 중간,CaseResearch혼입/밀집/항상Case03공식/종료직전강제 | 없음 |

**다음 Step46은 1만 권장한다:** 현재 마지막 Case03를 Run End라고 바꾸지 않은 채, 명시적 Test-only boundary의 미처리 disposition을 읽기 전용 snapshot으로 표현하고 반복 요청/phase/Pending/Archive 보존을 검사한다. 현재 Confirm에 자동 closure를 붙이거나 Settlement UI/Run/Shift 전체를 만들지 않는다. 실제 책임 이전·결과 모델은 이 snapshot 계약을 바탕으로 별도 좁은 구현 단계에서 다룬다. 개발용 명시 종료 trigger를 UI/API 중 어느 쪽으로 둘지는 [미정]이며 기존 Next disabled를 조용히 교체하지 않는다.

1을 먼저 두는 이유는 gate/range가 deferred를 늘릴 수 있기 때문이다. 2a와2b는 한 변경으로 뭉개지 말고 분리해 비교한다. Scripted 사건은 기존 Failure pacing이 안정된 뒤 3번째에 추가한다. 새 source를 지금 넣으면 밀집이 더 심해지고 측정 원인이 섞인다. 각 단계가 한 번에 전체 Campaign이 될 필요는 없다.

Main에 새로 예상되는 책임은 boundary snapshot/closure guard, progress completion 승인, actionable selection이다. 현재 길이만으로 EventManager/GameManager를 추천하지 않는다. 정책 변경 전에 검증된 읽기 전용 content lookup·snapshot 조립을 작은 순수 helper로 분리할 필요는 검토할 수 있지만, 같은 identity 검사를 두 곳에 복제하는 리팩터링은 피한다. 이번에는 Main 리팩터링0이다.

CandidateState는 계속 ID/count/created order로 충분하고 UI/read token/content lookup은 넣지 않는다. IncidentResponseState의 정상 active/completed 의미는 유지하며 forced 중단은 별도 종료 기록에서 표현하는 것이 우선이다. 현재 Response는 Case source 전용이므로, 후보3의 시설 사건에는 실제 source identity와 Archive 소유 범위를 별도로 확장해야 한다. source 종류와 비교 가능한 생성 순서가 필요할 수 있지만 가짜 Failure Candidate/Case ID로 대신하지 않는다. 그 구체적인 데이터 표현은 후보3 설계에서 정하며, 지금 일반 Event Framework를 만들지 않는다. boundary의 독립 소유·멱등성 책임이 실제로 생길 때 작은 State를 평가하고, bool 하나를 위한 Singleton/Manager는 만들지 않는다.

offline authored validator는 3Case/늘어난 graph에서 이제 유용한 시점이다. Case/local ID 고유성, 모든 정규 판정 Room의 Outcome coverage(현재 Case03의 의도적 제외 명시), FAILURE→Incident→Broadcast→Option→Result 링크, Research source 고유성/환경 reaction 참조를 읽기 전용으로 검사할 수 있다. runtime State/queue 정책과 별개이며 이번에는 validator도 구현하지 않는다.

## 변경과 확인

이번 Step45는 `README.md`에 짧은 요약을 추가하고 `docs/step45_final_sequence_event_policy.md`를 생성했다. 제품 code/Scene/Resource/주석 변경0, 삭제0. 기존 Step43/44의 파일·미커밋 diff는 그대로이며 staged0/HEAD 유지다. Git 전체 표시는 이전 단계를 합친 4modified/4untracked가 되므로 이번 product 변경으로 오해하지 않는다.

시작 baseline109개 파일에서 README 추가 블록 외 기존 내용을 보존했고 이전 검증 원본4,264개의 해시가 일치했다. Step44 수치 재집계/291개 최종 로그·기본3개 로그 해시, 102개 응답 번호, `git diff --check`와 신규 문서 whitespace를 확인했다. 새 Godot 실행은0이다. 증거는 ignore된 `.godot/verification/step45/`에 둔다. 정책의 표와 용어/미구현·미정/5개 최종 규칙도 대조했다. 커밋/push/rebase/reset/checkout rollback하지 않았다.

## 요청한 종료 보고 102개 항목

| 번호 | 요청 항목 | 결과 |
|---:|---|---|
| 1 | 작업 전 Git 상태 | Step43/44 미커밋4수정/3추가, staged0에서 시작; 모두 baseline. |
| 2 | HEAD | ad2beae1a7cbee8836bc8f811abb82740bb0d5d3, master→origin/main. |
| 3 | Step44 핵심 수치 재확인 | 원본144 JSON 재집계:Major122/CCTV36/CONT86/deferred82/ready17/strict최소0/Case최대3중단. |
| 4 | F01 상태 | F01 OPEN; 기본안 선정만으로 고정ready1의 예측성이 해결된 것은 아님. |
| 5 | F44-01 상태 | F44-01 OPEN; 모든 interruption의 표시 여유 gate를 권고. |
| 6 | F44-02 상태 | F44-02 OPEN; oldest actionable 권고, 아직 D-first. |
| 7 | F07-A 상태 | F07-A RESOLVED;3Case 실제 continuation/same Runtime 계약 유지. |
| 8 | F07-B 상태 | F07-B OPEN; final 책임 이전 계약 선택, 제품미구현. |
| 9 | 현재 Case End 의미 | 제출/정규hiddenresolution/handoff이며 사건전체완료 아님. |
| 10 | 현재 Sequence End 의미 | No next test case configured의개발경계, Run/GameOver/정산 아님. |
| 11 | Shift End 정의 후보 | 같은Run의업무단위pause→다음Shift, 길이/중간Casepause 미정. |
| 12 | Run End 정의 후보 | 더이상해당Run의정상업무가없는경계; 조건/결과모델 미구현. |
| 13 | Settlement 정의 후보 | 향후quota달성후자발Run종료선택, 허용조건/보상 미정. |
| 14 | Carry 정책 분석 | 지연철학/기회추가없음, 최종Run에만사용하면회피/소유문제. |
| 15 | Drain 정책 분석 | 직접대응/누락방지,끝spam/미발생승격 위험; 일괄drain 비추천. |
| 16 | Settlement Conversion 분석 | 미처리의무전환으로spam방지, 모델/실제consequence소비필요. |
| 17 | Hybrid 정책 분석 | Case/Shift carry+final conversion+active한정처리 hybrid. |
| 18 | 추천 종료 정책 | A+C와activeresponse한정처리의hybrid 선정. |
| 19 | Case End 권장 | candidate source/phase/count/order carry, current Runtime 교체와구별. |
| 20 | Shift End 권장 | 같은Run Shift carry,계획pause는현재active만마무리,readydrain없음. |
| 21 | Voluntary Settlement 권장 | active응답만정상완료후나머지conversion,후보존재만으로정산금지X. |
| 22 | Forced Run End 권장 | 선택/공개사실/activeidentity를interrupted로보존,자동완료X. |
| 23 | Campaign End 미정 범위 | Campaign최종연출/전체잔여정책 미정,사실삭제/거짓완료만공통금지. |
| 24 | Settlement abuse 위험 | ready뿐아니라unknownPending도최종판정/의무보존없으면회피가능. |
| 25 | unresolved consequence 회피 위험 | conversion은완료/면제X,소유자수락전reset금지; 경제페널티구현X. |
| 26 | Undisturbed Candidate 정책 | active/Shift carry,final은unmanifested obligation,강제D/M없음. |
| 27 | Disturbed-not-ready 정책 | 실제교란사실+phase carry/conversion,환경을새Case자동복사X. |
| 28 | Major-ready 정책 | 진행중gate/safe/content/order로표시,Shiftcarry/finalready의무conversion. |
| 29 | Active Response 정책 | 자발/계획pause는현재응답만완료,forced는중단기록,자동Option없음. |
| 30 | Current Major1 장점 | major1은빠른반응/짧은prototype reachability. |
| 31 | Current Major1 단점 | 고정ready/좁은Stage기대/0간격, 다음모든행동presentation은아님. |
| 32 | Threshold range 장점 | range는ready시점다양성,최소지연범위조정가능. |
| 33 | Threshold range 단점 | safe쏠림/lastdeferred/fairness/Successgap남음,단독해결비추천. |
| 34 | Meaningful gate 장점 | 실제연구여유/읽기보장,원인A와0간격을직접다룸. |
| 35 | Meaningful gate 단점 | deferred증가/Next기대/완료dedup필요,사람체감미입증. |
| 36 | meaningful action 추천 정의 | 새CCTV/승인결과의자발Next완료와고유Confirm,entry/nav/UI왕복제외. |
| 37 | Experiment gate 평가 | 승인된고유실험의draw뒤기존Next credit,정답성공과다름. |
| 38 | CCTV gate 평가 | 새Case최초CCTV draw뒤Next credit,entry/Recheck는읽기완료아님. |
| 39 | Containment entry 평가 | CONTentry는기회일뿐meaningfulgate credit0. |
| 40 | Containment Confirm 평가 | 유효Confirm판단1,같은callbackMajor금지/확정Room불변. |
| 41 | no-experiment 경로 | CCTV읽기/Confirm credit;새진행없으면carry/conversion,강제실험X. |
| 42 | read-before-event 정책 | 새source표시입력에서즉시덮지않고draw+자발Next를관찰proxy로사용. |
| 43 | 추천 pacing 정책 | readiness그대로,직전interruption뒤새연구1개완료+자발checkpoint. |
| 44 | current disturbance-first 장점 | 전조/현재반응/연구연결과개별D→M순서제공. |
| 45 | current disturbance-first 단점 | age inversion/oldready밀림/마지막boundary점유. |
| 46 | old-ready 우선 분석 | oldMajor공정성개선,Major-type편향과새D지연 가능. |
| 47 | global oldest actionable 분석 | created order에서현재gate/read/phase/content가유효한가장오래된event. |
| 48 | hybrid fairness 분석 | D-first+bypass상한은fairness후보지만counter/reset/예외복잡,보류. |
| 49 | 추천 ordering 정책 | global oldest actionable 기본안,strict oldest-candidate 차단정책X. |
| 50 | starvation 위험 | 현poolmax2/stress3,무한유입이론과기회고갈분리;새안도gate/content보장없이절대완료X. |
| 51 | Event type 다양성 | type다양성으로단일D→M공식분화 가능,새enum필수아님. |
| 52 | disturbance-only 후보 | D-only는독립환경연구,누락과구별할작성계약필요. |
| 53 | delayed-major 후보 | delayed는기억/지연기대,범위만넓히면lastdeferred증가. |
| 54 | direct-major 후보 | direct는다른양상,특별한작성근거/필수증거보호필요. |
| 55 | scripted-facility 후보 | authored facility는성공독립경험/anchor,적격창/source기록계약필요. |
| 56 | Severity 도입 판단 | Severity 보류;피해/비용/난이도/Run결과/priority에실제쓸때검토. |
| 57 | all-Success 문제 | allSuccess현재D/M/B0,콘텐츠문제이며pacing과별도. |
| 58 | Scripted Incident 필요성 | 정상완료Run에실패독립최소1시설사건권장,현재미구현. |
| 59 | Scripted Incident 목적 | Broadcast/시설세계사실/Archive핵심경험,실패처벌이목적아님. |
| 60 | Forced Failure 비추천 | 성공Case를가짜Failure로바꾸는Forced Failure 비추천. |
| 61 | Success 의미 보존 | 성공Resolution/Room진실유지,같은추가피해를무조건강제X. |
| 62 | 공통 핵심 경험 범위 | 시설anomaly→Broadcast→실제공개/확정기록,조기강제종료미도달미정. |
| 63 | Policy Set A | A:activeCase/같은Run carry,현재Casehandoff만구현. |
| 64 | Policy Set B | B:Shiftcarry/finalconversion/active자발완료또는강제중단. |
| 65 | Policy Set C | C:ready유지+전interruption연구여유1+읽기checkpoint. |
| 66 | Policy Set D | D:oldest actionable,unready/invalid는retain+skip. |
| 67 | Policy Set E | E:정상완료Run의authored facility창에최소1경험,독립source. |
| 68 | End Boundary Matrix | Case/Shift/자발/forced/Campaign의Pending~active6상태표. |
| 69 | Candidate State Matrix | undisturbed/disturbed/ready/active/completed/invalid/unknownPending의active/Shift/final표. |
| 70 | Pacing Rule Matrix | current1/range/gate/oldready/hybrid의예측/밀도/deferred/복잡도/조작표. |
| 71 | Ordering Matrix | OldM/NewD,OldD/NewM,TwoM,TwoD와unready/invalid충돌비교표. |
| 72 | Success Experience Matrix | Success/OneFailure/Dual의failureevent/Archive/공통facility범위표. |
| 73 | 자동검증 항목 | carry/ownership멱등/gatededup/draw/order/forceddrain없음/Archive/Runtime/normaldebug. |
| 74 | 사람검증 항목 | 예측/긴장/피로/source이해/읽기와복귀,자동화로확정불가. |
| 75 | baseline 플레이테스트 시나리오 | Success/F01only/F02only/Dual4-2dense,실험0보조표본. |
| 76 | 설문 질문 | 9문항 Likert+Case기억/예상버튼/Archive목적/피로구간자유응답. |
| 77 | 다음 구현 후보1 | Test Sequence boundary disposition 계약,Run정산과구별. |
| 78 | 후보1 예상 변경 범위 | 명시testclosure의read-onlysnapshot/Main조립/작은기록fixture,Campaign/SettlementUI없음. |
| 79 | 후보1 위험 | Test끝을Run완료로혼동/unknownPending거짓판정/의무중복/삭제. |
| 80 | 다음 구현 후보2 | 2a oldestactionable와2b read/meaningfulgate를분리비교. |
| 81 | 후보2 예상 변경 범위 | Mainselector/완료dedup/sessionbool/자발Nextcheckpoint,필요시Viewsnapshot. |
| 82 | 후보2 위험 | 새D지연/조건관찰timing/잠금복귀/skip실험/lastdeferred증가. |
| 83 | 다음 구현 후보3 | 성공독립authoredfacility최소1개. |
| 84 | 후보3 예상 변경 범위 | 시설sourceidentity/content/Archive범위/정산가능전적격창. |
| 85 | 후보3 위험 | 밀집/Case03공식/거짓Failure/미도달공통경험/끝강제재생. |
| 86 | 구현 순서 | 종료snapshot계약→ordering단독→gate단독→독립시설,원인을한번에섞지않음. |
| 87 | Main 영향 | boundary조립/guard,완료진행승인,actionableselector의책임예상. |
| 88 | Main 분리 필요성 | 1563/84길이만으로분리X,read-onlycontent조회/snapshot의명확한경계만검토. |
| 89 | CandidateState 책임 변화 예상 | 기존ID/count/order유지가능,UI/content는침범X;시설source는후속설계. |
| 90 | IncidentResponseState 영향 | active/completed정상의미유지,forced중단은종료기록;시설identity확장필요. |
| 91 | 새 State 필요성 | gatebool/dedup은Mainlocal부터,독립ownership책임이생길때작은State검토. |
| 92 | Event Manager 필요성 | EventManager/GameManager/Scheduler자동추천X. |
| 93 | offline validator 필요성 | offlinegraph검사는유용시점,Case03의의도적Outcome없음제외명시;이번구현X. |
| 94 | 이번 Step product code 변경 | product Script/Scene/Resource/주석0,threshold/priority/State그대로. |
| 95 | README 변경 | 짧은Step45설계기본안블록만추가,이전본문보존. |
| 96 | 보고서 생성 | docs/step45_final_sequence_event_policy.md 신규. |
| 97 | git diff --check | git diff --check와신규문서whitespace검사통과. |
| 98 | 기존 변경 보존 | Step43/44baseline파일/원본검사소스hash보존,rollback없음. |
| 99 | commit/push 없음 | staged0/HEAD그대로,commit/push/rebase/reset/checkout없음. |
| 100 | 아직 미정인 사항 | Shift길이/Run조건/실제consequence비용/공통facilitymilestone및Archive표현/Campaign/영구저장미정. |
| 101 | 최종 추천 기본안 | carry+final obligationconversion+active한정처리/readgate/oldestactionable/독립facility의일관된기본안. |
| 102 | 다음 Step 추천 | Step46 Test Sequence Boundary Disposition Contract,1번후보만좁게검토. |

## 추천 기본안의 다섯 계약

1. **일반 Case가 끝날 때 unresolved Event는 source·phase·진행을 보존해 다음 정상 업무로 이월한다.**
2. **같은 Run의 Shift가 끝날 때는 이월하고, 최종 Run 종료에서는 이미 active인 응답을 자발 종료라면 마무리하거나 강제 종료라면 중단 기록으로 보존한 뒤 나머지를 미처리 의무 기록으로 전환한다.**
3. **Disturbance 이후 Major는 기존 readiness와 유효 콘텐츠 조건에 더해 직전 interruption 뒤 새 의미 있는 연구 진행1개가 완료되고 새 정보의 읽기 경계를 지난 사용자 checkpoint에서 표시한다.**
4. **서로 다른 Candidate의 Event가 경쟁하면 gate/read/phase/content 조건을 충족하는 가장 오래된 actionable event부터 한 번에 하나 처리한다.**
5. **모든 격리에 성공한 플레이어에게는 정상 완료 Run의 authored 적격 창에서 실패와 독립적인 시설 source 사건으로 최소 Incident/Broadcast·사실 기록 경험을 제공한다. 조기 강제 종료의 미도달 창은 [미정]이며 끝에 몰아 재생하지 않는다.**

이 기본안은 실제 Shift/Run/경제/영구저장/공통시설source가 아직 [미구현]이라는 전제의 설계 결정이다. 세 문제 A/B/C의 해법을 문서로 분리했으며 현재 제품의threshold·priority·기회·마지막Case동작은바꾸지않았다.
