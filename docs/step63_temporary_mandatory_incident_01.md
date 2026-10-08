# Step63 — Temporary Mandatory Incident 01 Authored Campaign Integration

**TEMPORARY MANDATORY INCIDENT 01 · FIRST PRODUCT AUTHORED SCRIPTED STORY ENTRY · CASE02 → TEMP INCIDENT → CASE03 · DATA-DRIVEN REPLACEABLE CONTENT · ALL-SUCCESS PLAYERS STILL EXPERIENCE BROADCAST · NO FINAL STORY CLAIM · NO ECONOMY / QUOTA / SETTLEMENT**

기존 프로젝트에 actual authored TEMP 사건1개를 통합했다. 확정된 순차 구조와 임시 콘텐츠/미정 최종 Story를 구분한다. 새 Gameplay 시스템·Main/Scene/Script 수정0, stage/commit/push0.

## 1. Repo Baseline

작업 전 실제 비생성 파일152개, 제품 GDScript51개, Scene15개, authored .tres4개. project.godot, 실제 Scene/Script/Resource 전체 목록, Campaign/Main/Response/Archive/FactQueries/terminal/side 경로, CASE01/02의 Profile·CCTV·전체 Experiment·Result·Research·Room·Outcome·Failure Incident를 조사했다. 적용 AGENTS.md 없음.

HEAD `6e8f167f699a3a95c91fee8668ae99d03e5d4db9`, branch `master`, upstream `origin/main`, staged0. 누적 tracked 수정10개/untracked25개는 Step55~62의 기존 변경이다. 이번 작업의 변경과 구분하며 rollback/stage/commit/push 하지 않았다. 이전 verification56,538개 파일을 해시 보호했다. baseline은 `.godot/verification/step63/baseline.json`, 원본 bytes는 `before/`, 이전 증거 해시는 `prior-evidence-hashes.json`에 보존했다.

최종 폴더 구성: 기존 assets / resources/cases·campaigns / scenes/main·views / scripts/data·runtime·read_models·main·views / docs를 유지하고 `resources/incidents/`만 새로 추가했다. 새 Resource1개와 보고서1개, 수정 Campaign1개와 README append만 있다. 최종 비생성154개, GDScript51개, Scene15개, authored .tres5개. Main2455행/133함수 및 모든 Script·Scene·설정 bytes를 보존했다.

## 2. Actual Existing Case Evidence Audit

[resources/cases/test_case_01.tres](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/resources/cases/test_case_01.tres:1) / [resources/cases/test_case_02.tres](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/resources/cases/test_case_02.tres:1)

| 조사 항목 | CASE01 실제 authored 정보 | CASE02 실제 authored 정보 |
|---|---|---|
| Profile | TEST_PROFILE_01: 금속 지지대 위 펌프 주기 뒤 타격, 대화 timing 연관 없음 | TEST_CASE02_PROFILE_01: 벽 접촉 소실 뒤 탐색, 손상 기록 없음 |
| CCTV | TEST_CAM_01: 펌프 시작/타격, 환기 전환/회귀, 조명 sweep은 이동을 변경 | TEST_CASE02_CAM_01: 얕은 골 벽 tracing, 매끈한 면의 그릴 방향 탐색, 환기 전환 반복 |
| Experiments/Results | TEST_EXP_01 금속/패딩 impulse 비교; 02 지속/반복 airflow 비교; 03 sound-only 재현 실패. limit2이므로 세 결과가 모두 보장되지 않음 | EXP_01 air pulse/fan sound 비교; EXP_02 ribbed/smooth surface 비교. limit2 |
| Research | 24개. Profile/CCTV는 정상 노출, EXP는 실제 실행/표시 시 발견, Incident/Broadcast/Option/Result는 선택적 Failure 경로 | 17개. Profile/CCTV/실행 EXP와 Room, Failure response, 조명 관련 condition observation을 포함 |
| Rooms | ROOM_01 rigid metal+acoustic partition+steady air; ROOM_02 padded mechanical isolation+steady air; ROOM_03 isolation+cycling air+reduced light | ROOM_01 continuous air+shallow ribs; ROOM_02 cycling air+smooth walls+reduced light |
| Outcome | ROOM_02 SUCCESS; ROOM_01/03 FAILURE. 이 hidden 판정은 신규 정답의 근거로 쓰지 않음 | ROOM_01 SUCCESS; ROOM_02 FAILURE. journey의 실제 handoff 판정 확인에만 사용 |
| Failure Incident | TEST_INCIDENT_01 support vibration; TEST_INCIDENT_03 ventilation. 기존 선택지/Result/Research 모두 존재 | TEST_CASE02_INCIDENT_01 grille/search/local air jets, 3개 대응과 Result |

기존 Case 내용 변경0. 기존 실패 사고는 연구/회귀 조사 자료이며 Mandatory 발생 원인이나 필수 정답 단서가 아니다.

## 3. TEMP Target Case Selection

`TEMP_TARGET_CASE = TEST_CASE_01`, 대상 표시명은 실제 `TEST SUBJECT`에 Case ID를 함께 표시한다.

[확정 구조] CASE02 다음 순차 사건에서 과거 정보를 다시 판단한다. [TEMP STORY CONTENT] 대상 CASE01 및 maintenance support bypass 문제는 임시 선택이다. CASE01은 support/airborne sound/airflow/light의 서로 다른 관찰을 실제 Profile·CCTV·실험·Archive에서 비교할 수 있어 우선 대상에 적합하다. 새로운 빛 약점·생물학적 내성·탈출 능력을 창작하지 않았다. CASE02도 surface/airflow 자료가 있지만 이번 target으로 선택하지 않았다.

## 4. TEMP Story Content

[TEMP STORY CONTENT] 유지보수 제어 이상으로 service bypass가 pump impulse를 지지대로 전달한다. 펌프 시작과 타격이 겹치고 airflow는 steady이며 현장 인원이 즉시 방송 지시를 기다린다. 과거 연구로 support/sound/airflow cue를 구분하라고 안내한다.

이는 새 **임시 시설 상황**이며 최종 시설 비밀·책임자·lore 확정이 아니다. 성공한 방 선택을 무효화하거나 플레이어의 격리 실패를 원인으로 말하지 않는다. 결과 A는 immediate support disturbance 통제, B/C/D는 해당 지시의 한계·철회·후속 isolation 요청이다. 향후 정량 피해나 장기 결과를 자동 생성하는 효과는 없다.

[미정 최종 Story] 대상·사고 원인·제목·문장·정답/오답·최종 결과 전부 교체 가능하다. 최종 시나리오 완성 주장을 하지 않는다.

## 5. Campaign Entry Integration

[resources/campaigns/test_campaign_01.tres](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/resources/campaigns/test_campaign_01.tres:1)

| 순서 | Before | After | kind |
|---|---|---|---|
| 1 | TEST_ENTRY_CASE_01 | TEST_ENTRY_CASE_01 | CASE |
| 2 | TEST_ENTRY_CASE_02 | TEST_ENTRY_CASE_02 | CASE |
| 3 | TEST_ENTRY_CASE_03 | TEMP_ENTRY_MANDATORY_01 | SCRIPTED_INCIDENT |
| 4 | 없음 | TEST_ENTRY_CASE_03 | CASE |

[확정 구조] CASE02→TEMP Incident→CASE03. 제품 authored sequence를 처음 의도적으로 변경했다. 기존 enum SCRIPTED_INCIDENT=1과 external ScriptedIncidentData를 사용한다. 별도 success condition 없음. side `scripted_interrupts`는 default empty, Mandatory02/03 추가0. 기존 Case reference와 stable ID는 그대로다. Campaign valid, entry/Case ID uniqueness, bundle와 모든 Incident/Broadcast/Option/Result 링크를 실제 제품 preload로 검증했다.

## 6. Incident Resource

[resources/incidents/temp_mandatory_incident_01.tres](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/resources/incidents/temp_mandatory_incident_01.tres:1)

신규 파일의 subresource convention은 기존 Case bundle과 같다. ScriptedIncidentData event_id=`TEMP_EVENT_MANDATORY_01`, Incident ID=`TEMP_INCIDENT_MANDATORY_01`, Broadcast ID=`TEMP_BROADCAST_MANDATORY_01`. 파일명·ID·개발 comment의 `[TEMP STORY CONTENT]`·제목 `TEMP:`로 임시 콘텐츠임을 식별한다.

Incident title: `TEMP: SUPPORT CONTROL INTERRUPTION`.

Incident body: “Maintenance control fault: a service bypass is transmitting pump impulses into the supports of TEST SUBJECT (TEST_CASE_01). Strikes coincide with pump starts; airflow is steady. Staff await an immediate broadcast instruction. Review the earlier research records to distinguish support, sound and airflow cues.”

환경 disturbance payload는 지정하지 않았다. 따라서 Story 자체가 가짜 Failure Candidate나 새 환경 effect를 만들어내지 않는다. Research source reference도 추가하지 않는다.

## 7. Broadcast Resource

Broadcast title=`TEMP: IMMEDIATE SUPPORT RESPONSE`.

Prompt: “Which instruction should staff follow while pump-start strikes continue? Address the current support fault using the earlier observations. This instruction is a temporary response, not a new containment decision.”

4개 대응, 정답은 authored 의미상 A 하나다. IncidentResultData에는 정답 bool이나 SUCCESS/PARTIAL/FAILURE enum이 없으므로 새 분류/판정 framework를 만들지 않았다. draft→Confirm→approved Option/Result와 lock은 기존 View/Main/IncidentResponseState가 처리한다. A를 선택하기 위해 Archive를 반드시 열 필요는 없다.

## 8. Option / Result Matrix

모든 ID는 `TEMP_OPTION_MANDATORY_01_` / `TEMP_RESULT_MANDATORY_01_` prefix를 사용한다. 제품 bundle validation 및 네 실제 journey에서 링크를 검사했다.

| Option | 실제 방송 지시 | Result ID | 임시 결과 의미 | approved link |
|---|---|---|---|---|
| A (correct) | maintenance bypass 분리, support mechanical isolation 복원, low airflow 지속, task light 유지 | TEMP_RESULT_MANDATORY_01_A | pump-start 타격 감소, wall tracing 지속; 즉시 support disturbance 통제, protocol 유지 | valid |
| B (wrong) | acoustic partition으로 airborne pump noise 감소; bypass 유지, steady air/task light 유지 | TEMP_RESULT_MANDATORY_01_B | 소리는 줄지만 타격 timing 지속, noise-only 지시 철회, isolation 요청 | valid |
| C (wrong) | vent cycling으로 panel에서 이동 유도; bypass/light 유지 | TEMP_RESULT_MANDATORY_01_C | outlet 회귀 추가, 타격 지속, cycling 철회 및 steady air/isolation 요청 | valid |
| D (wrong) | task lighting 감소로 crossing 억제; bypass와 steady air 유지 | TEMP_RESULT_MANDATORY_01_D | 이동 변화만 있고 타격 지속, lighting 복구 및 isolation 요청 | valid |

모든 result prose의 완전한 source of truth는 새 `.tres`다. 결과 차이는 설명문으로 표현하며 사망자·damage·Ending Flag·경제값으로 저장하지 않는다. 오답도 Continue Campaign을 막지 않는다.

## 9. Evidence / Fairness Matrix

| Broadcast Option | Evidence supporting/contradicting | Source Type / Source ID | Normally visible? | Archive accessible? | Why fair? |
|---|---|---|---|---|---|
| A | 금속 support impulse에서 타격이 더 많고 padded에서 적음; pump-start 타격/steady airflow 현재 상황과 부합 | Experiment TEST_EXP_01 / Research TEST_RESEARCH_EXP_01 | 실행하면 보임; 선택적이므로 유일 근거 아님 | 해당 실행 발견 후 yes, 실제 fixture 확인 | 전달 impulse의 연결을 차단함; 새 biology 없음 |
| A | 금속 지지대 pump timing, CCTV pump-start strike correlation; 시설 bypass fault가 현재 상황에 명시됨 | Profile TEST_PROFILE_01, CCTV TEST_CAM_01 / Research TEST_RESEARCH_PROFILE_01·TEST_RESEARCH_CCTV_01 | 정상 Profile/CCTV 흐름에서 yes | 두 guaranteed 기록 실제 확인 | Profile/CCTV 자체는 상관관계지만 현재 명시된 support fault와 결합해 응답을 추론할 수 있음 |
| B | 펌프 소리 때문에 그럴듯함; sound-only trial은 strike burst를 재현하지 않음, bypass는 유지됨 | Experiment TEST_EXP_03 / Research TEST_RESEARCH_EXP_03, Profile/CCTV | 선택 실행 시 EXP; Profile/CCTV는 정상 visible | EXP 발견 시 yes | airborne sound와 transmitted support impulse 혼동, 선택 실행이 없어도 현재 support fault를 고치지 않음 |
| C | vent로 이동을 돌리는 것처럼 보임; cycling은 outlet turn-back을 유발하고 연결 impulse는 남음 | CCTV TEST_CAM_01, Experiment TEST_EXP_02 / Research TEST_RESEARCH_CCTV_01·TEST_RESEARCH_EXP_02 | CCTV 보장, EXP 선택 | CCTV guaranteed / EXP 실행 시 yes | 관찰된 이동 반응을 오해한 지시, 현재 steady airflow에 불필요한 transition 추가 |
| D | lamp sweeps가 travel을 바꾸므로 그럴듯함; strike timing은 바꾸지 않았고 연결은 남음 | CCTV TEST_CAM_01 / Research TEST_RESEARCH_CCTV_01 | 정상 visible | guaranteed yes | 이동과 타격 원인의 차이를 기존 카메라 정보로 구분 가능 |

Containment Room은 가시 구성 비교의 보조 맥락이며 정답의 필요 조건으로 사용하지 않는다. hidden Outcome은 근거0. 선택적 Failure Incident/condition Research는 유일 단서0. EXP를 하나도 실행하지 않고 선택적 Case01 Failure Research도 발견하지 않은 B/D 및 Case02 Failure journey가 정상 완료됐다. 새로운 false clue나 관찰되지 않은 생물학적 특성을 넣지 않았다. 신규 시설 fault와 새 결과 관찰은 모두 TEMP narrative이며 최종 과학/Story 사실 확정이 아니다.

## 10. Research Archive Use

[scripts/main/main.gd](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/scripts/main/main.gd:1825) / [scripts/views/research_archive_list_view.gd](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/scripts/views/research_archive_list_view.gd:1) / [scripts/views/research_archive_detail_view.gd](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/scripts/views/research_archive_detail_view.gd:1)

순차 Scripted Incident/Broadcast/Result의 Open Source Archive는 전체 List로 간다. 실제 Case01→Detail에서 원래 ResearchEntry body와 동일한 Profile/CCTV 기록, 실행했을 때의 TEST_RESEARCH_EXP_01을 확인했다. Detail→List→Back은 원래 응답 stage/source로 복귀한다. draft와 Confirm lock 및 approved Result 유지.

Archive를 연 행위 자체는 발견/merge/unlock0, owners/RNG/pacing mutation0. 정상 제품 흐름에서는 두 과거 Case의 Profile 기록이 있어 완전 empty가 되지 않는다. 별도의 **controlled empty Archive** journey만 owner.reset을 주입하여 EmptyState와 Back·Broadcast·Continue가 막히지 않음을 검사했다. 정상 플레이로 empty가 발생했다고 주장하지 않는다.

## 11. All-Success Route

실제 설정된 Main을 instantiate하고 export된 product Campaign을 그대로 실행했다. Case01 ROOM_02와 Case02 ROOM_01을 실제 버튼으로 제출하면 handoff에서 두 실제 Outcome이 SUCCESS로 기록된다. Case02의 Next는 `Next: SCRIPTED INCIDENT`, 승인 후 TEMP Incident→Broadcast→Result→Continue→CASE03 PROFILE.

A/C는 실제 EXP_01 실행 및 Archive 이용, B/D는 EXP 실행0·Archive 접근0. 네 경우 모두 Failure Candidate0, Mandatory 발생. 모든 이전 격리에 성공한 플레이어도 Broadcast를 경험한다. success branch 하드코딩이 아닌 entries order 때문이다.

## 12. Failure-Coexistence Route

| Product route | 실제 실행 및 보존 | 검증 구분 |
|---|---|---|
| Case01 SUCCESS + Case02 FAILURE | Case02 ROOM_02 제출→accepted handoff에서 FAILURE Resolution 및 Candidate 생성→TEMP 응답→CASE03; Candidate 계속 보존 | 실제 authored room/outcome, 별도 가짜 Candidate 주입0 |
| Case01 FAILURE + Case02 SUCCESS | Case01 ROOM_01 실제 제출/FAILURE→Case02 ROOM_01 확정→old Case01 Major 1회→same Case02 Containment→TEMP→CASE03 | 실제 실패 source; **경계 도달 후 owner API로 readiness/credit만 통제**한 bounded 정책 fixture |

두 번째 route는 natural RNG timing이 항상 동일하다는 주장이 아니다. 실제 Failure source를 만들고 boundary의 ready 상태를 통제했다. old Failure response를 수행했기 때문에 그 Candidate 완료·삭제와 기존 Research 변화가 정상 발생하는 예외를 허용했다. 그 뒤 TEMP source scope에 들어간 순간부터 다른 Case owners/Candidate/RNG/Research는 바뀌지 않았다.

Step58의 source/target intent·failure_offer_consumed 및 최대1회 정책 변경0. Mandatory는 Failure source로 표시되지 않으며 CAMPAIGN_ENTRY origin/occurrence/definition으로 독립한다. authored sequence CASE02→TEMP→CASE03과 visible route의 old event interposition을 구분한다.

## 13. Sequential Completion / CASE03

[scripts/main/main.gd](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/scripts/main/main.gd:1780) / [scripts/runtime/campaign_progress_state.gd](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/scripts/runtime/campaign_progress_state.gd:61)

CASE02 handoff에서 completed=`[TEST_ENTRY_CASE_01, TEST_ENTRY_CASE_02]`, current=`TEMP_ENTRY_MANDATORY_01`, current_case/Runtime=null, Case ordinal=-1. response source는 CAMPAIGN_ENTRY / TEMP_ENTRY_MANDATORY_01 / TEMP_EVENT_MANDATORY_01이고 fake source_case_id 없음.

approved Result ack에서 Main이 IncidentResponseState.try_complete를 호출하고 CampaignProgressState.try_complete_and_advance로 순차 entry를 완료한다. current=`TEST_ENTRY_CASE_03`, completed에 TEMP가 한 번 추가되고 새 CaseRuntime, empty execution history, PROFILE, host child1개. 고유 Runtime instance가 이전 Case02와 다름을 확인했다. Room/Resolution/Archive/old Candidate·RNG·credit·tokens는 scripted ack로 변하지 않는다.

Case03 Outcome0·final no-next behavior 및 Ending 미구현 상태는 유지한다. 이번 테스트 종료점은 CASE03 PROFILE 진입이다.

## 14. Fact Query Verification

[scripts/read_models/campaign_fact_queries.gd](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/scripts/read_models/campaign_fact_queries.gd:1)

실제 product journey의 NOT_STARTED / ACTIVE draft / ACTIVE_CONFIRMED / COMPLETED에서 read-only typed queries를 각10회 호출했다. Case02 entry completion=true, TEMP entry completion은 ack 전 false/후 true, response completion도 전 false/후 true. option/result는 unconfirmed에서 UNKNOWN, Confirm 후 해당 TEMP Option/Result ID를 KNOWN으로 반환한다. 반환 객체를 수정해도 source state mutation0.

새 condition evaluator/Story variation/flag/cache/history 없음. Step60 full repeated query regression은 별도로 headless/native 모두 재실행했다.

## 15. Stale / Duplicate Guards

실제 교체되어 queue_free 대기 중인 Containment/Incident/Broadcast/Result/Archive List·Detail을 retained callback으로 검사했다. 연결 signal 및 Main handler의 advance/archive/confirm/list/detail 호출은 mutation0. Result ack 직후 stale ack를 반복해도 progress/current Runtime ID/owner fingerprint 변화0, CASE03 duplicate Runtime0.

Confirm 전 선택 변경 가능; Confirm 후 repeated Confirm와 다른 option 입력은 mutation0·locked. Archive 왕복에서 draft와 approved lock 보존. 제품 검증은 실제 버튼 signal 경로·toggle/focus 효과·native GPU rendering을 사용했다. 물리적 OS 마우스 클릭/F5 키 입력을 자동화했다고 주장하지 않는다.

## 16. Mid-Case Step62 Regression

Step62 side / side_guards / side_invalid를 headless/native 각각 재실행했다. PROFILE·CCTV·Experiment actual Result/draft·Containment draft·scroll/focus resume, Story-vs-Failure accounting/arbitration, side queries, stale binding, resume-pending 및 terminal guards 유지. 제품 side schedule은 여전히 empty다.

이번 Step63 복사본에서는 과거 suite의 CASE-only helper가 신규 sequential entry를 Case로 오인하지 않도록 typed CASE projection을 사용했다. product-only assertion은 3→4 entries로 갱신하고 CASE ID/reference 검증은 유지했다. 과거 원본 suite/증거 수정0. 재사용 Scenario는 in-memory controlled data; 새 product suite는 별도로 실제 .tres를 사용한다.

## 17. Terminal / Cleanup Regression

Step46 snapshot 4그룹, Step47 ordering, Step48 gate, Step51 ownership, Step52 closure/journey, Step53 active termination, Step54 verified cleanup, Step55/57 campaign 및 invalid, Step58 mixed/repeated/bounded 및 invalid, Step60 facts, Step62 side/guards/invalid를 재실행했다. Failure Major와 Source Archive 검증 포함.

현재 ACTIVE TEMP Scripted에서 voluntary/forced developer closure는 UNSUPPORTED_ACTIVE_CAMPAIGN_RESPONSE로 명시 차단하며 recipient0/freeze0/owner mutation0. completed Scripted terminal projection gap은 **OPEN**: 기존 Case 중심 final recipient projection이 완료된 Scripted fact를 보관하지 않는 문제는 그대로다. 이 사건 실행 완료가 Run-End contract 완성을 의미하지 않는다.

## 18. Replaceability Audit

### Story Content Audit

| TEMP field | Actual source | Replace later without code? | Final status |
|---|---|---|---|
| Target Subject | Incident.description의 실제 TEST SUBJECT/TEST_CASE_01 + 기존 근거 audit | yes, 설명/선택/결과를 새 실제 근거에 맞게 Resource 편집 | TEMP |
| Facility premise | 새 Incident description, player failure dependency 없음 | yes | TEMP |
| Incident title/prose | IncidentData subresource | yes | TEMP |
| Broadcast title/question | EmergencyBroadcastData subresource | yes | TEMP |
| Four response texts | BroadcastOptionData subresources | yes | TEMP |
| Correct response meaning | 기존 관찰과 A Result prose | yes, 새 근거 및 option/result를 함께 수정 | TEMP |
| Option→Result links | option.result_id 및 bundle.incident_results | yes, schema validation 조건 준수 | TEMP |
| Result titles/prose | IncidentResultData subresources | yes | TEMP |
| Authored position | Campaign.entries | yes, 순서 편집; 기존 entry/Case uniqueness 제약 준수 | 확정 구조 / 위치는 현재 CASE02 뒤 |

Main/GDScript 안에 Case02 ID나 TEMP ID hardcode를 추가하지 않았다. 새 data schema0, Script0, Manager0. 기존 UI/선택형 response mechanic 범위에서 교체할 수 있다. 최종 Story가 새로운 mechanic·효과·조건을 요구할 때는 별도 구현이 필요하다. 이번에 미리 구현하지 않았다.

## 19. Files / Main Impact

| Step63 delta | 파일 | 이유 |
|---|---|---|
| modified | resources/campaigns/test_campaign_01.tres | 새 external bundle + 순차 SCRIPTED_INCIDENT entry 삽입; 기존 Case reference/IDs 유지 |
| modified | README.md | 기존 byte prefix를 보존하고 Step63 append |
| created | resources/incidents/temp_mandatory_incident_01.tres | 기존 typed schema의 TEMP authored bundle |
| created | docs/step63_temporary_mandatory_incident_01.md | 필수22섹션·171항목 보고 |
| deleted | 없음 | 보존 |

Main 수정0. [scripts/main/main.gd](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/scripts/main/main.gd:2289)와 [scripts/main/main.gd](C:/Users/newsj/OneDrive/문서/ChatGPT/cap/scripts/main/main.gd:2272)의 기존 data-driven 동작으로 충분했다. 모든 Scene/View/Script/project.godot/UID/기존 Case/기존 보고서 bytes 유지. 1920×1080 reference,1280×720 override,canvas_items stretch,GL Compatibility,Autoload0 그대로다.

최종 Git의 누적 수정은 기존 작업까지 포함한다. `git diff HEAD`만으로 Step63 크기를 판단하지 않는다. baseline diff(이전에 untracked였던 Campaign 포함), status, diff --check, HEAD/branch/upstream/staged 검사를 새 verification에 저장했다. Git의 기존 LF/CRLF 경고는 파일 오류나 Godot warning이 아니며 설정/줄바꿈을 임의 normalize하지 않았다.

## 20. Verification

Godot `4.7.1.stable.official.a13da4feb`. 새 `.godot/verification/step63/`와 독립 APPDATA/LOCALAPPDATA profile을 사용했다.

| 최종 검증 | process slots | 결과 |
|---|---:|---|
| fresh editor import | 1 | PASS |
| 전체 product GDScript --check-only | 51 | PASS |
| configured product Main headless/native | 2 | PASS |
| actual authored product journey headless/native | 2 | 각7 journey PASS, 1888/1946 assertion calls |
| 기존 핵심 suite headless | 20 | PASS |
| 기존 mixed/bounded/facts/journey/side/side_invalid/side_guards native | 7 | PASS |
| 합계 | **83** | **854,344 assertion calls** |

83은 최종 판정용 고유 process slots다. 초기 product fixture 실패2회와 추가 assertion에 따른 비최종 성공 재실행4회를 포함하면 이번 fresh Godot 호출은89회다. assertion 호출 수는 반복 query/세부 invariant를 포함하며 독립 scenario 수가 아니다. product suite는7개 journey(이 중 bounded readiness/empty Archive2개는 통제 조건)와102개 named assertion IDs를 두 renderer에서 검사했다. 새 product assertion 총3834회, 나머지는 기존 회귀 재실행이다.

일반 실행 warning0/runtime error0/script error0/parse error0. 기존 invalid/rejection suite의 controlled WARNING19·ERROR70은 별도 기대값으로 검사했다. product suite 자체 controlled diagnostics0. 초기 fixture 실패를 일반 최종 오류 수에 포함하거나 숨기지 않는다.

초기 실패1: 존재하지 않는 CaseData.get_research_entry를 검증용 코드에서 호출해 Archive Back 이후 stage 오류가 연쇄 발생. 실제 research_entries 배열 조회로 **fixture만 수정**했다. `initial-product-1/`에 실패 코드/로그/JSON 보존.

초기 실패2: 실제 old Failure response를 거친 bounded route에서도 선택적 Failure Research가 없다고 기대한 assertion이 틀렸다. optional-missing 검사는 Case01 성공 경로에 적용하고, bounded route는 정상 Failure discovery 예외로 구분했다. fixture만 수정, `initial-product-2/` 보존. 이후 headless/native 모두 PASS. 초기 patch 도구의 신규 Resource 파일 쓰기는 실패로 제품 수정 없이 종료되어 디렉터리 생성 후 native 파일 도구로 작성했다. 최종 보고서 감사에서는 Campaign 표의 순번1~4까지 171항목 번호로 읽은 검사 오류가 있어, 검사 범위를 종료 보고 appendix로 한정했다. 제품 파일 오류는 아니며 감사 스크립트만 수정했다.

GPU1280×720에서 CASE02 확정/Next, TEMP Incident, Archive Detail 실제 연구, Broadcast Confirm lock 및 scroll 하단 C/D, A/B/D Result와 CASE03 Profile을 직접 열어 확인했다. 기존 ScrollContainer로 네 선택지가 모두 표시/선택됨을 검사했다. Scene/layout 변경0이므로 세 해상도 전체 반복0. 최종 UI 미학 완성 주장은 하지 않는다.

증거: `verification-summary.json`, `product-headless.json`, `product-windows.json`, 각 `*-runs.json`/log/PNG, `regression-batch.json`, `native-and-product-batch.json`, baseline/final audit. 대표 화면은 `01_all_success_A_archive_mandatory_incident.png`, `06_all_success_A_archive_broadcast_options_bottom.png`, `29_all_success_D_no_archive_broadcast_options_bottom.png`이다.

## 21. Known Gaps

신규 제품 P0/P1/P2를 이번 검증에서 발견하지 않았다. 완전한 전 경로 무결점 주장 아님. 신규 blocking P3 없음; 긴 개발용 TEMP ID와 네 선택지의 스크롤은 기존 prototype UI 특성이다.

기존 gap은 모두 유지한다: completed Scripted terminal projection OPEN; ACTIVE Scripted closure unsupported; Step53 P2 ACTIVE_FORCE_REQUIRES_PREPARED_PENDING; Step54 multi-owner reset은 atomic rollback 보장이 없음; Step62 UI 복원 실패는 fail-closed/completed binding을 보존하고 private developer retry에 의존하며 player recovery UI 없음. Case03 Outcome/Ending 없음. 가설 private enumeration/focus hierarchy의 기존 P3도 해결됐다고 주장하지 않는다.

Mandatory02/03·Final Incident·Ending·Save/Load·StoryFlag·generic Condition/variation·CampaignHistory·Victim/Damage·Economy/Quota/Settlement·새 Audio/Animation/Font/Shader/asset 구현0. 대상·원인·정답·문구·결과는 전부 [TEMP STORY CONTENT], 최종 Story [미정].

## 22. Next Step Recommendation

먼저 이 임시 콘텐츠의 근거/지시/결과가 원하는 Story 판단 경험을 주는지 검토하고, 최종 시나리오가 준비되면 새 bundle의 대상·문구·Option/Result와 Campaign 순서를 Resource로 교체하는 작업부터 시작하는 것이 적합하다.

그 다음은 별도 사용자 범위가 확정될 때 completed Scripted terminal fact 보존 계약 또는 Mandatory02/03 authored checkpoint 배치를 선택한다. 이번 Step에 해당 미래 기능을 추가하지 않았다. 최종 UI 리빌드와 이번 기능 검증을 혼합하지 않는다.

## 종료 보고 171항목 개별 답변

표의 번호는 사용자 요청 번호와 같다. 상세 근거·검증 범위는 위 22개 섹션 및 verification JSON과 연결된다.

| 번호 | 요청 항목 | 결과 / 근거 |
|---:|---|---|
| 1 | 작업 전 Git 상태 | tracked 수정10/untracked25, 이전 변경을 포함한 작업 전 상태. |
| 2 | HEAD | 6e8f167f699a3a95c91fee8668ae99d03e5d4db9. |
| 3 | branch/upstream | master / origin/main. |
| 4 | staged | 0. |
| 5 | 기존 변경 보호 | 152개 baseline bytes 및 이전 verification56,538개 해시 보호; 기존 파일은 Campaign/README 이외 보존. |
| 6 | 제품 Campaign before | CASE01→CASE02→CASE03. |
| 7 | 제품 Campaign after | CASE01→CASE02→TEMP Mandatory01→CASE03. |
| 8 | new Scripted entry ID | TEMP_ENTRY_MANDATORY_01. |
| 9 | entry 위치 | entries[2], CASE02 뒤/CASE03 앞. |
| 10 | ScriptedIncidentData ID | TEMP_EVENT_MANDATORY_01. |
| 11 | Incident ID | TEMP_INCIDENT_MANDATORY_01. |
| 12 | Broadcast ID | TEMP_BROADCAST_MANDATORY_01. |
| 13 | Option IDs | TEMP_OPTION_MANDATORY_01_A/B/C/D. |
| 14 | Result IDs | TEMP_RESULT_MANDATORY_01_A/B/C/D. |
| 15 | TEMP marker | temp 파일명·TEMP_ IDs·[TEMP STORY CONTENT] comment·TEMP title. |
| 16 | target Case | TEST_CASE_01 / TEST SUBJECT. |
| 17 | target Case 선정 근거 | 기존 support/sound/airflow/light 관찰이 대응 비교와 과거 Archive 재조회에 적합. |
| 18 | actual Profile evidence | TEST_PROFILE_01 금속 support pump timing; 대화 timing 연관 없음. |
| 19 | actual CCTV evidence | TEST_CAM_01 pump starts/strikes, vent changes/turn-backs, lamp travel 변화. |
| 20 | actual Experiment evidence | TEST_EXP_01 metal/padded, EXP02 steady/cycling air, EXP03 sound-only 재현 실패. |
| 21 | actual Research evidence | TEST_RESEARCH_PROFILE_01/CCTV_01/EXP_01/02/03; 표9 참조. |
| 22 | containment evidence 사용 여부 | 가시 Room 구성은 보조 맥락; 정답 필수 근거0. |
| 23 | hidden Outcome 사용 여부 | 0. 실제 journey Outcome 판정 확인에만 사용. |
| 24 | 정답 근거 | 기존 support impulse evidence + 현재 명시된 bypass fault, steady air 유지. |
| 25 | 정답 visible 여부 | Profile/CCTV 정상 노출, EXP는 선택 실행; Incident의 시설 fault도 가시. |
| 26 | optional evidence 여부 | EXP/Failure Research는 선택적이며 유일 근거0. |
| 27 | archive evidence 여부 | 정상 발견 Profile/CCTV, 실행한 EXP01을 실제 Detail에서 확인. |
| 28 | undiscovered path fairness | EXP0/선택적 Failure Research0에서도 mandatory→CASE03 완료. |
| 29 | false clue 여부 | 새 contradictory biological clue0. |
| 30 | new lore 여부 | 최종 lore0. 중립 maintenance fault라는 새 TEMP 시설 상황만 작성. |
| 31 | facility incident cause | maintenance control/service bypass fault. |
| 32 | player failure dependency | 없음. 기존 SUCCESS에서도 발생. |
| 33 | all-success trigger | 네 all-success product journey에서 발생. |
| 34 | Case02 failure trigger | CASE02 ROOM02 실제 FAILURE journey에서도 발생. |
| 35 | fake Failure 여부 | 없음. origin=CAMPAIGN_ENTRY. |
| 36 | fake Candidate 여부 | 없음. 실제 실패 제출의 기존 Candidate만 생성. |
| 37 | fake Resolution 여부 | 없음. 실제 Case Outcome Resolution만 사용. |
| 38 | Campaign cursor | CampaignProgressState sole entries cursor. |
| 39 | Case02 complete | accepted handoff에서 TEST_ENTRY_CASE_02 완료. |
| 40 | Scripted current state | TEMP current, current_case/Runtime=null, _case_index=-1. |
| 41 | CASE03 dispatch | ack 후 entries[3] actual Case03/new Runtime/PROFILE. |
| 42 | bounded old Failure behavior | ready old Failure 최대1회→같은 Containment→TEMP. product readiness controlled 및 bounded 회귀. |
| 43 | Step58 policy mutation 여부 | 0. |
| 44 | Incident title | TEMP: SUPPORT CONTROL INTERRUPTION. |
| 45 | Incident body | support bypass/pump-start strikes/steady airflow/현장 방송 요청/이전 연구 참고. §6 전문. |
| 46 | Broadcast prompt | 현재 support fault에 즉시 어떤 지시를 내릴지 질문. §7 전문. |
| 47 | Option A | bypass 분리·mechanical isolation·steady low air/task light 유지. |
| 48 | Option B | airborne pump noise 감소, bypass 유지. |
| 49 | Option C | vent cycling으로 이동 유도, bypass 유지. |
| 50 | Option D 여부 | 있음: task lighting 감소, bypass 유지. |
| 51 | correct Option | A. 의미상 정답이며 새 correct/outcome schema 없음. |
| 52 | wrong Option rationale | B 소리/진동 혼동, C airflow 회귀 cue 추가, D travel/strike timing 혼동. §9. |
| 53 | Option→Result links | 4개 실제 option.result_id→bundle result 링크 모두 valid. |
| 54 | Result A | support disturbance 통제/타격 감소/protocol 유지. |
| 55 | Result B | 소리는 줄지만 pump-start strikes 지속/지시 철회. |
| 56 | Result C | outlet turn-back 추가/strike 지속/cycling 취소. |
| 57 | Result D 여부 | 있음: 이동만 변화/support fault 지속/lighting 복구. |
| 58 | success/partial/failure scheme 여부 | IncidentResultData는 ID/title/prose만 존재. 새 outcome 분류0. |
| 59 | casualty system 여부 | 0. |
| 60 | damage system 여부 | 0. |
| 61 | Story flag 여부 | 0. |
| 62 | condition evaluator 여부 | 0. |
| 63 | Archive default | 전체 Research Archive List. |
| 64 | Archive target detail path | List 실제 Case01 Open→Detail→List→응답 Back. |
| 65 | Archive empty behavior | 정상 흐름은 Profile 기록으로 nonempty; owner.reset 통제 fixture에서 EmptyState/Back 확인. |
| 66 | current Research merge 여부 | Mandatory Archive 접근 merge0. |
| 67 | Broadcast draft Archive roundtrip | draft 변경→Archive→동일 선택 복원 PASS. |
| 68 | confirmed lock | Confirm 뒤 option/Confirm lock 및 Archive 왕복 PASS. |
| 69 | Result Archive roundtrip | approved Result 동일/Continue Campaign 유지 PASS. |
| 70 | response completion authority | IncidentResponseState.try_complete, Main이 actual source/result를 검증 후 호출. |
| 71 | entry completion authority | CampaignProgressState.try_complete_and_advance, Main의 scripted ack 경로. |
| 72 | double ack | queued old Result의 반복 signal/handler 호출에서 duplicate progress/Runtime0. |
| 73 | stale Incident | actual retained queued Incident mutation0. |
| 74 | stale Broadcast | actual retained queued Broadcast confirm/advance mutation0. |
| 75 | stale Result | actual retained queued Result advance mutation0. |
| 76 | stale Archive | actual retained queued List/Detail/back/case callback mutation0. |
| 77 | Research mutation | Story/Archive 자체0; 정상 Case discovery/old Failure 응답은 별도. |
| 78 | Candidate mutation | Story 자체0; 실제 old Failure 처리 때만 기존 정상 변화. |
| 79 | RNG mutation | Story 실행0; Case02 실제 Failure 최초 Candidate threshold 추첨은 기존 동작. |
| 80 | Progress mutation | Case02 완료→TEMP current→TEMP 완료→Case03 current, once. |
| 81 | Query entry completed CASE02 | handoff 후 KNOWN true. |
| 82 | Query entry completed TEMP | ack 전 KNOWN false, 후 true. |
| 83 | Query Response completed | draft/approved ACTIVE false, ack 후 true. |
| 84 | Query confirmed Option | unconfirmed UNKNOWN, Confirm 후 해당 TEMP Option KNOWN. |
| 85 | Query Result | unconfirmed UNKNOWN, Confirm 후 해당 TEMP Result KNOWN. |
| 86 | UNKNOWN semantics | 유지. draft가 approved fact가 되지 않음. |
| 87 | all-success product journey | A/B/C/D 네 product all-success journey headless/native PASS. |
| 88 | failure coexistence journey | Case02 실제 Failure coexistence 및 실제 Case01 Failure+controlled bounded readiness PASS. |
| 89 | correct option product journey | A 실제 authored product PASS. |
| 90 | wrong option product journey | B/C/D 모두 실제 authored product PASS. |
| 91 | Archive evidence journey | Case01 Profile/CCTV 및 실행 EXP01 Detail 확인 PASS. |
| 92 | Archive-not-opened journey | B/D 실제 Archive 접근0, 완료 PASS. |
| 93 | optional Research missing journey | EXP01/Case01 Incident Research 미발견인 성공·Case02실패 경로 PASS. |
| 94 | actual product .tres execution | export된 실제 Campaign + external TEMP .tres, product override0. |
| 95 | in-memory fixture 사용 여부 | 기존 regression/통제 readiness·empty 조건에는 사용; product 콘텐츠는 .tres 그대로. |
| 96 | product Main headless | configured Main --headless --quit-after20 PASS. |
| 97 | product Main native | configured Main native --quit-after30 PASS. |
| 98 | GPU Incident | 실제 GPU Incident screenshot 확인. |
| 99 | GPU Broadcast | 실제 GPU Confirm lock 및 ScrollContainer 하단 C/D 확인. |
| 100 | GPU Result | GPU A/B/D Result 직접 확인; 모든 A/B/C/D renderer journey PASS. |
| 101 | GPU CASE03 | fresh Case03 PROFILE GPU 확인. |
| 102 | layout modification | 0. |
| 103 | Scene modification | 0. |
| 104 | View modification | 0. |
| 105 | Theme modification | 0. |
| 106 | asset modification | 0. |
| 107 | project.godot | byte unchanged; 1920×1080/canvas_items/1280×720 override/GL compatibility. |
| 108 | Main modification | 0; 2455행/133함수 유지. |
| 109 | Main hardcoded Case02 ID 여부 | 추가0. |
| 110 | Main hardcoded TEMP ID 여부 | 추가0. |
| 111 | new GDScript | product0. ignored verification fixture만 추가. |
| 112 | new Resource files | resources/incidents/temp_mandatory_incident_01.tres 1개. |
| 113 | modified Resource files | resources/campaigns/test_campaign_01.tres 1개. |
| 114 | replace target without code? | yes, 새 실제 근거와 target/option/result Resource 함께 교체. |
| 115 | replace incident text without code? | yes. |
| 116 | replace Broadcast without code? | yes. |
| 117 | replace Options without code? | yes, 기존 typed schema/unique IDs 준수. |
| 118 | replace Results without code? | yes, option.result_id와 bundle result 함께 수정. |
| 119 | move Campaign position without code? | yes, Campaign.entries 순서 편집. |
| 120 | final Story dependency | 최종 Story 미확정. 새 mechanic 필요 시 별도 단계 구현. |
| 121 | Step62 side schedule product contents | default empty 유지. |
| 122 | Mandatory02 content | 0. |
| 123 | Mandatory03 content | 0. |
| 124 | Ending | 0. |
| 125 | Save | 0. |
| 126 | completed Scripted terminal gap | OPEN. Case 중심 terminal recipient의 Scripted history 누락 유지. |
| 127 | ACTIVE Scripted terminal block | UNSUPPORTED_ACTIVE_CAMPAIGN_RESPONSE 유지, 실제 product 검증. |
| 128 | Step46 regression | snapshot 4그룹 PASS. |
| 129 | Step47 regression | ordering PASS, controlled warning4. |
| 130 | Step48 regression | gate PASS. |
| 131 | Step51 regression | ownership PASS. |
| 132 | Step52 regression | closure + actual journey PASS. |
| 133 | Step53 regression | active termination PASS, controlled warning2. |
| 134 | Step54 regression | verified cleanup PASS. |
| 135 | Step55 regression | Campaign routing/length/final boundary PASS. |
| 136 | Step57 regression | typed CASE projection/invalid Campaign PASS. |
| 137 | Step58 regression | mixed/repeated/bounded/invalid headless 및 native PASS. |
| 138 | Step60 regression | facts headless/native PASS. |
| 139 | Step62 regression | side/side_guards/side_invalid headless/native PASS. |
| 140 | Failure Major regression | ordering/gate/active/bounded/side arbitration suites PASS. |
| 141 | Source Archive regression | mixed/side/product Archive roundtrip PASS. |
| 142 | GDScript count | 51 product scripts. |
| 143 | check-only | 51/51 PASS. |
| 144 | editor import | fresh editor import PASS. |
| 145 | process count | 최종 고유 process83; 초기 실패2/비최종 재실행4 포함 실제 호출89. |
| 146 | assertion calls | 854,344 호출; product3834, 나머지 기존 회귀. 독립 scenario 수 아님. |
| 147 | scenario distinction | product7 journey/102 named assertion IDs, 두 renderer 반복; 통제 bounded/empty 구분. |
| 148 | normal warnings | 0 normal Godot warnings. |
| 149 | controlled diagnostics | 의도된 기존 invalid/rejection WARNING19/ERROR70, 별도 기대 수 검사. |
| 150 | runtime errors | 0 normal final runtime errors. |
| 151 | script errors | 0 final SCRIPT ERROR. |
| 152 | parse errors | 0 final Parse Error. |
| 153 | initial failures | fixture API 오호출→배열 조회, bounded Research 부재 기대 오류→정상 Failure discovery 예외 구분. 두 실패 보존. |
| 154 | files modified | 2: Campaign, README append. |
| 155 | files created | 2: TEMP Resource, Step63 report. |
| 156 | files deleted | 0. |
| 157 | README | 기존 byte prefix 유지 후 Step63 append. |
| 158 | report | docs/step63_temporary_mandatory_incident_01.md, 22섹션/171항목. |
| 159 | git diff --check | exit0; 기존 Git line-ending conversion 경고만 존재. |
| 160 | staged final | 0. |
| 161 | commit/push | 하지 않음. |
| 162 | new P0 | 새 P0 발견0 (검증 범위 내). |
| 163 | new P1 | 새 P1 발견0. |
| 164 | new P2 | 새 P2 발견0; 기존 gaps 유지. |
| 165 | new P3 | 새 blocking P3 발견0. 긴 TEMP IDs/scroll prototype 특성은 최종 UI 품질 claim 없음. |
| 166 | existing Step53 P2 | ACTIVE_FORCE_REQUIRES_PREPARED_PENDING P2 OPEN. |
| 167 | Step54 atomic limitation | multi-owner cleanup의 atomic rollback 미보장 유지. |
| 168 | Step62 restore limitation | fail-closed resume/pending context/private developer retry, player recovery UI0 유지. |
| 169 | Story content TEMP status | 모든 새 대상·시설 문제·문구·정답·결과 TEMP. |
| 170 | final replacement readiness | 기존 mechanic 내에서 Resource만 교체 가능; 최종 mechanic 선구현0. |
| 171 | next step recommendation | TEMP 판단 경험 검토/최종 Resource 교체; 이후 별도 terminal Scripted facts 또는 Mandatory02/03 범위 결정. |
