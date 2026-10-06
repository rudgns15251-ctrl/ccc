# CAP — 개발 기반과 Case 흐름 UI 프로토타입

Godot **4.7.1 Standard**, GDScript, Windows PC용 2D UI 프로젝트입니다.
정상 플레이는 Main Scene에 설정한 Case01 → Case02 → Case03 순서로 각 Case의 PROFILE → CCTV → EXPERIMENT → CONTAINMENT를 진행합니다. 기존 Monitoring/결과/실패 후속 화면은 독립 prototype/debug 검사용으로 보존했습니다. Research Log는 정상 흐름의 네 화면과 기존 debug 경로의 네 화면에서 열 수 있으며 MONITORING에서는 열 수 없습니다.
EXPERIMENT 목록에서 하나를 선택하고 즉시 테스트 결과 텍스트를 표시할 수 있습니다.
각 Experiment ID는 Case당 한 번만 실행할 수 있고 CaseData.experiment_limit을 소비합니다.
Main이 소유하는 메모리 CaseRuntimeState가 중복과 제한을 검증한 뒤 승인한 실행만 기록합니다.
활성 환경에서 실제 실행한 Experiment는 Base 결과 뒤에 authored 조건 관찰을 추가할 수 있습니다. 실행 당시 관찰 ID만 기록하고 이후 환경 변화는 과거 결과에 소급하지 않습니다. 조건 관찰은 선택적 보조 증거이며 실험 횟수와 정답은 바꾸지 않습니다.
CONTAINMENT는 후보 Resource 배열의 이름·설명을 표시하고 하나를 임시 선택할 수 있습니다.
선택은 View 안에만 유지하며 Confirm Containment로 확정한 Room ID는 CaseRuntimeState에 기록합니다. 같은 승인 경계에서 Main 소유 PendingContainmentState에 Case ID와 실제 확정 Room ID를 등록합니다. 선택만으로는 등록하지 않습니다.
Confirm은 화면을 이동하지 않습니다. 확정 뒤 Next: CASE는 현재 Pending의 Case/Room ID로 Outcome을 검색하고 결과를 숨겨진 ContainmentResolutionState에 한 번 기록합니다. 성공한 판정만 Pending에서 제거하며 실패 결과에는 별도 FailureEventCandidateState를 등록합니다. Research를 Archive에 보존한 뒤 새 Runtime으로 다음 PROFILE을 엽니다. Room 자체에 정답 필드는 없습니다. 마지막 Case의 Next는 No next test case configured로 비활성화되며 현재 Pending을 유지합니다.
MONITORING은 확정 Room ID에 맞는 Outcome을 time_offset에 따라 순차 재생하고 관찰 기록을 누적합니다. 모든 유효 Stage가 공개된 뒤 Main/Runtime이 결과를 확정합니다. SUCCESS는 RESULT로, FAILURE는 ID로 찾은 IncidentData를 INCIDENT에, 연결된 EmergencyBroadcastData와 단일 선택 Option 목록을 BROADCAST에 표시합니다. Confirm Broadcast가 승인되어 두 ID를 Runtime에 기록한 뒤 INCIDENT_RESULT에서 해당 결과 콘텐츠를 표시하고 RESULT로 진행합니다.
이 MONITORING 경로는 **prototype/debug resolution playback**입니다. 0/10/20초는 prototype verification timing이며 정상 판정은 Timer를 사용하지 않습니다. 이번 Vertical Slice의 내부 판정 경계는 handoff이며 실제 시설 영향은 이후 의미 있는 행동 opportunity와 숨겨진 threshold로 분리합니다. 최종 게임의 판정·사건 시점과 밸런스는 아직 확정하지 않았습니다. debug Timer는 Pending을 resolve하거나 제거하지 않습니다.
RESULT는 Main이 전달한 표시용 snapshot으로 Case, 확정 결과/Room, 실제 실행 순서의 Experiment와 사용 수를 읽기 전용으로 요약합니다. FAILURE에는 현재 Incident/Broadcast/확정 Option/IncidentResult도 표시하며 SUCCESS에는 없음/해당 없음으로 표시합니다.
RESEARCH LOG는 현재 Case의 Profile/CCTV, 실제 실행한 Experiment의 설명·결과, 확정 Room, 완료된 Monitoring 관찰, FAILURE의 확정 응답·결과를 카테고리별로 읽기만 합니다. 기존 Stage/Runtime 공개 조건을 만족하고 해당 유효 ResearchEntryData.entry_id를 현재 Case Runtime에서 실제로 발견한 경우에만 Log 전용 title/body_text를 사용합니다. 작성 콘텐츠가 없거나 잘못된 매핑, 발견 기록이 없는 공개 Source는 기존 문구를 사용합니다. 게임 화면 문구와 영구 기록은 변경하지 않습니다.
ResearchArchiveState는 결과 확정 여부와 관계없이 획득한 Case별 Research ID를 세션 메모리에 보관합니다. 정상 handoff 직전에 유효 발견 ID를 incremental merge하며 기존 debug RESULT 경계의 merge도 유지합니다. 현재 Research Log는 계속 현재 Runtime만 사용합니다. 마지막 Case의 발견 기록은 handoff가 없으므로 현재 Runtime에 유지됩니다. 읽기 전용 Research Archive는 Research Log에서 열 수 있으며, 이미 archived된 Case의 authored Research와 개인 메모만 표시합니다. 디스크 저장은 없습니다.
환경 교란이 실제 발생하면 현재 Case의 해당 reaction_id를 OBSERVATION으로 추가합니다. 발생 전에는 표시/발견하지 않습니다. Notice는 시설 조건 변화와 현재 관찰 사실만 보여주며 원인 Case나 숨겨진 성공/실패를 공개하지 않습니다. Dismiss 후 동일 View를 이어갑니다.
적용된 교란은 현재 Case Runtime의 활성 환경 조건입니다. CCTV / EXPERIMENT / CONTAINMENT의 **ACTIVE FACILITY CONDITION**에서 계속 확인할 수 있으며, Dismiss와 Research Log Open/Back으로 사라지지 않습니다. Runtime 교체/reset 시 초기화하며 다른 Case로 자동 승계하지 않습니다.
CCTV는 **BASE OBSERVATION**을 유지하고, 실제 적용된 환경에 대응하는 **CONDITION OBSERVATION**을 별도로 표시합니다. 활성 조건이 있으면 Experiment / Containment의 **Recheck CCTV**로 다시 확인하고 원래 화면으로 돌아올 수 있습니다. 추가 관찰 Research는 CCTV에 실제 표시된 뒤에만 발견하며, Overlay를 본 것만으로는 발견하지 않습니다.
Research Log의 WORKING HYPOTHESES에서 현재 Case의 자유 메모를 Add/Edit/Delete할 수 있습니다. Main 소유 WorkingHypothesisState가 Case별로 세션 동안 유지하며, Runtime 교체와 ResearchArchive 초기화로 삭제되지 않습니다. 가설을 추천하거나 평가하지 않고 연구 발견/게임 판정에도 연결하지 않습니다.
최종 게임 시스템과 디자인은 아직 구현하지 않았습니다.

## Step47: Oldest Actionable Event Ordering

현재 safe boundary에서 실제 표시 가능한 이벤트를 Failure Candidate 등록 순서로 하나 선택합니다. Old Major/New Disturbance 경쟁에서는 Old Major를 먼저 표시하고, invalid/unready/EXP에서 non-presentable Major는 뒤 후보를 막지 않습니다. 기존 State/Resource/View/해상도·Stretch·Step46 Snapshot은 유지했습니다.

144 matrix 재실행에서 age inversion9개를 제거했습니다. F44-02는 RESOLVED이며, F01/F44-01은 OPEN, F07-B는 PARTIALLY ADDRESSED입니다. 새 pacing gate나 Run 종료 처리는 없습니다.

최종310개 Godot 실행, 9경로 Before/After 및144개 보고 항목: [Step47 보고서](docs/step47_oldest_actionable_event_ordering.md). 커밋·push하지 않았습니다.

## Step46: Test Sequence Boundary Disposition Snapshot

`Main.build_test_sequence_disposition_snapshot()`으로 현재 Pending/기록된 Resolution/미처리 Candidate phase/Active Response/완료 Response/연구·메모 보존 현황을 개발용으로 관찰합니다. 결과는 Resource를 보관하지 않는 detached read model이며, `to_dictionary()`의 중첩 복사본을 수정해도 Gameplay State가 바뀌지 않습니다.

`TEST_SEQUENCE_END`는 Run End가 아닙니다. Case03의 Outcome 없는 Pending과 Next 비활성화를 유지하고, Snapshot은 판정·기회·RNG·이벤트·Research/Archive·Runtime을 변경하지 않습니다. player-facing UI나 실제 closure/Settlement/conversion/ordering/pacing gate를 추가하지 않았습니다.

계약, 138개 보고 항목과 새 Godot 실행 검증: [Step46 보고서](docs/step46_test_sequence_boundary_disposition.md).

## Step45: Final Sequence Event Policy / Pacing Design Decision

설계 문서만 작성했으며 현재 Gameplay 규칙은 유지합니다. 추천 기본안은 Case/같은 Run의 Shift에서는 후보 이월, 최종 Run에서는 미처리 의무 기록으로 전환하는 방식입니다. 자발 종료는 현재 active 응답만 마무리하고, 강제 종료는 자동 선택 없이 중단 사실을 보존합니다.

진행 중에는 모든 interruption 사이 새 의미 있는 연구 진행1개와 읽기 경계를 지킨 뒤 가장 오래된 actionable event를 선택하는 안을 권장합니다. 성공 플레이에는 별도 시설 source의 authored 핵심 경험을 최소1회 제공하는 방향입니다. 종료·gate·ordering·독립 사건은 아직 구현하지 않았습니다.

102개 항목, 정책 비교표와 다음 Step46의 좁은 범위: [Step45 정책 문서](docs/step45_final_sequence_event_policy.md).

## Step44: 3-Case Event Pacing / Cross-Case UX Audit

Step43의 미커밋 기반을 보존한 Audit이다. 제품 코드·Scene·Resource는 변경하지 않았다. 실제 버튼으로 144개 threshold/실험량 조합과 세 해상도의 dense/all-Success 흐름을 측정했다.

- Major readiness=1과 실제 CCTV/Containment presentation을 구분한다. 122회 중 Containment86/CCTV36이며 완료된 연구 행동 간격0도 있다.
- 교란 우선의 실제 순서/마지막 경계 지연과 무한 유입의 이론상 starvation을 분리했다. invalid oldest는 유효 후보 전체를 막지 않는다.
- F01은 OPEN, F07은 continuation 해결(A)과 마지막 미처리 정책(B OPEN)으로 분해한다. threshold/RNG/pacing/Case 수는 그대로다.
- 291개 최종 suite와 별도 import/Main3개, source/current Archive·같은 Runtime 복귀·기존 debug 회귀를 검증했다. 사람의 공포/재미/피로를 검증한 것은 아니다.

132개 보고 항목과 timeline/density/threshold/ordering/starvation/UX 표: [Step44 보고서](docs/step44_three_case_event_pacing_audit.md).

## Step43 — Case02 Resolution + Case03 + Cross-Case Deferred Incident

정상 sequence를 Case01 → Case02 → Case03으로 확장했습니다.
Case02의 기본 CCTV/표면 실험을 최소 보완한 뒤 모든 Room에 Prototype Test Outcome과 최소 실패 후속 chain을 작성했습니다.
이 매핑은 시스템 검증용이며 정식 Creature 설정이나 장기 격리 정답을 확정하지 않습니다.
늦어진 Case01 Candidate가 Case02 handoff를 넘어 Case03에서 사건을 시작하고 같은 Case03 Runtime으로 복귀합니다.
두 Failure 후보, Case02만 Failure, 모두 Success, sequence 끝 Deferred 보존을 검증했습니다.
threshold/RNG/교란 우선·FIFO/Step42 읽기 경계·Context·Archive draft는 유지했습니다.
Case03은 Test 콘텐츠와 최소 reaction만 제공하며 Outcome 없이 마지막 Pending을 보존합니다.

145개 종료 항목과 Case02 Evidence/Mapping, 실제 3-Case reachability,
변경 범위와 검증 결과는 [Step43 보고서](docs/step43_cross_case_deferred_incident.md)에 정리했습니다.
기존 235개 + 신규 32개 suite, 별도 import/기본 Main 실행 3개를 통과했습니다.
F07은 부분 해결, Major1의 F01 pacing과 마지막 Case의 후속 기회 부족은 남았습니다.
커밋·push하지 않았습니다.

## Step42 — Major Incident Response Content + Context + Read Boundary

Case01의 두 사건·여섯 임시 대응에 기존 관찰/실험 근거와 서로 다른 조치·결과를 작성했습니다.
정상 INCIDENT / BROADCAST / INCIDENT RESULT에 source Case와 중단된 current Case·Stage를 표시합니다.
EXP 실행은 결과와 조건 관찰을 먼저 보여주고 Major 준비를 기록하며, 다음 정상 CCTV/Containment 진입에서 사건을 표시합니다.
현재 정상 EXP 이후에는 Next: CONTAINMENT에서 중단하고 대응 후 같은 Case02 Containment로 복귀합니다.
idle / Log 왕복은 사건을 발생시키지 않으며 threshold·기존 opportunity는 유지했습니다.
정상 Broadcast의 미확정 Option은 직접 Source Archive 왕복 동안 보존하며, Confirm 승인과는 구분합니다.
실패 Room을 노출하던 Incident 화면과 authored Incident Research 문구를 함께 제거했습니다.
점수·정답·새 gameplay consequence·Timer·추가 Case/시스템은 구현하지 않았습니다.

검증과 기존 Step41 변경 보존, 요청한 105개 항목은
[Step42 보고서](docs/step42_major_incident_response_read_boundary.md)에 정리했습니다.
기존 215개 + Step42 20개 suite와 별도 import/기본 Main 실행을 검증했습니다. 커밋·push하지 않았습니다.

## Step41 — Major Incident Pacing / Response UX Audit

정상 Case01 → Case02의 교란·Major·Source Archive·Broadcast·Result·Resume를
실제 버튼 입력과 세 해상도 GPU 실행으로 감사했습니다. 게임 코드·Scene·Resource·
프로젝트 설정·threshold는 변경하지 않았습니다.

- 기술적 대응/복귀와 동일 current Runtime 보존은 확인했습니다.
- 교란 이후 Major는 현재 **다음 유효 행동 1회**로 고정되어 예측 가능성이 높습니다.
- EXP에서 발생한 Major는 새 결과의 첫 렌더 전에 화면을 전환합니다. Resume 후 결과는 복원됩니다.
- Broadcast A/B/C는 아직 전략·근거·결과 의미가 없는 임시 콘텐츠입니다.
- 기존 Incident 설명은 실패한 Room을 직접 표시합니다. 내부 판정 비공개와 별개의 콘텐츠 문제입니다.
- 후속 기회가 없는 경로는 Candidate가 유지되는 **DEFERRED**로 확인했습니다.

전체 107개 요청 항목, 실제 Journey/Trigger/Decision/UX 표와 상태·변경 범위,
검증 결과는 [Step41 감사 보고서](docs/step41_major_incident_pacing_audit.md)에 정리했습니다.
기존 215개와 새 18개 suite 실행, 별도 import/기본 실행을 검증했습니다.
다음 단계는 기존 사건의 대응 콘텐츠와 source·resume 맥락, EXP 결과 읽기 정책을
먼저 구체화하는 것이 적합합니다. 이번 감사에서는 커밋·push하지 않았습니다.

## 실행

1. Godot 4.7.1에서 이 폴더의 `project.godot`를 가져오거나 엽니다.
2. `scenes/main/main.tscn`을 연 뒤 **F6**으로 해당 Scene을 실행하거나, **F5**로 프로젝트를 실행합니다.
3. Case01의 **PROFILE**에서 시작합니다. 버튼으로 **CCTV → EXPERIMENT → CONTAINMENT** 순서로 이동합니다.
   PROFILE에는 테스트 Resource의 subject_name, classification, basic_description이 표시됩니다.
   CCTV에는 camera_id, observation_text가 표시됩니다.
   EXPERIMENT에는 available_experiments 배열의 이름과 설명이 동적 목록으로 표시됩니다.
   이름 옆 선택 Control을 클릭하면 해당 항목만 선택됩니다. 재클릭해도 선택이 유지됩니다.
   선택 후 **Run Experiment**를 누르면 해당 Resource의 result_text가 표시됩니다.
   다른 실행 가능한 항목을 선택하면 이전 결과가 초기화됩니다.
   실행 완료 항목은 **[Executed]**와 disabled 상태로 표시되며 재선택·재실행할 수 없습니다.
   **Experiments Remaining**으로 남은 횟수를 확인합니다. 0이면 모든 항목과 Run이 비활성화됩니다.
   선택만 하면 기록하지 않으며, 정상 실행할 때마다 이력에 ID 하나를 추가합니다.
   CONTAINMENT에는 available_containment_rooms 배열의 후보 이름과 설명이 표시됩니다.
   이름 옆 선택 Control을 클릭하면 하나만 선택되며 재클릭해도 유지됩니다.
   초기 상태에는 선택이 없고 Confirm과 **Next: CASE**가 비활성화됩니다.
   Room을 선택한 뒤 **Confirm Containment**를 누르면 현재 Case 후보를 검증하고 한 번만 확정합니다.
   확정된 후보는 **[Confirmed]**로 표시되며 후보 변경과 재확정은 불가능합니다.
   Confirm 후 화면에 머무르며 **Next: CASE**로 Case02의 PROFILE에 진입합니다. Case01 Pending은 내부 판정 성공 후 제거되고 숨겨진 Resolution과 Archive가 유지됩니다. 새 Case Runtime은 실행 이력·확정 Room·결과·발견 목록과 적용 교란 기록을 새로 시작합니다. 새 PROFILE의 유효 작성 Research는 실제 표시 시 발견됩니다. 판정 데이터가 잘못되면 Pending을 유지하고 handoff를 차단합니다.
4. Case02도 같은 네 화면을 진행합니다. CCTV, 두 번째 Experiment, 두 번째 Room에는 authored Research가 없어 기존 fallback 문구로 Research Log를 표시합니다. Case01 Room01 또는 Room03을 확정했다면 Case02의 의미 있는 행동 도중 임시 환경 교란이 한 번 발생할 수 있습니다. **FACILITY DISTURBANCE**에서 조건 변화와 **UNPLANNED OBSERVATION**을 읽고 **Dismiss**로 이어갑니다. Room02 경로는 후보/교란이 없습니다. 이 설명은 개발 검증 안내이며 실제 UI는 과거 Case 판정과 원인을 공개하지 않습니다.
   마지막 Case는 **No next test case configured**로 진행을 차단하며 Case02 Pending을 유지합니다. 정상 Route에서 결과 화면이나 Campaign 완료는 없습니다.
5. 네 화면의 **Open Research Log → Back**은 현재 Case와 원래 Stage로 돌아갑니다. 이전 Case Archive를 섞지 않습니다. 이 탐색은 opportunity를 소비하지 않습니다. Log 왕복의 미확정 임시 선택은 초기화하고 실행·확정 상태는 복원합니다. 교란 Notice의 Dismiss는 View를 재생성하지 않아 현재 UI context를 유지합니다. 창 크기를 바꾸면 기존 비율과 UI scaling을 유지합니다.

6. Research Log의 **Open Research Archive**로 보존된 Case 목록을 열고 **Open**으로 연구·메모를 읽기 전용 조회합니다. **Back**은 Detail → List → Research Log → 원래 View 순서입니다. 아직 handoff되지 않은 현재 Case는 Archive에 넣지 않습니다. 가설 편집은 현재 Research Log에서만 가능합니다.

아래 Monitoring 이후 설명은 정상 F5 진행에 포함되지 않는 기존 debug 기능입니다. 검사용 Main 확장은 `.godot/verification/step32/debug_main.gd`에만 있으며 제품 코드에는 debug 전환 버튼이나 설정을 추가하지 않았습니다. debug 검사는 단일 Case01에서 확정 후 MONITORING으로 진행합니다. SUCCESS는 RESULT, FAILURE는 INCIDENT → BROADCAST → INCIDENT_RESULT → RESULT입니다.

   MONITORING에는 확정 Room ID와 전체 Stage 개수가 표시됩니다. 테스트 기록은 진입 직후, 10초 후, 20초 후 하나씩 누적됩니다.
   미래 Stage 내용과 최종 결과는 미리 공개하지 않습니다. 마지막 Stage 후 Main이 해당 Case/Room Outcome의 결과를 검증합니다.
   Runtime에 결과를 한 번 기록한 뒤 **Monitoring Result: SUCCESS / FAILURE**를 표시하고 **Next: RESULT**를 활성화합니다.
   확정 결과가 있는 같은 Case 재진입에서는 전체 기록과 결과를 즉시 복원하며 Timer를 시작하지 않습니다.
   결과가 없는 재진입은 처음부터 재생합니다. 데이터 누락·미정의 결과·기록 실패는 경고와 함께 Next를 차단합니다.
   Monitoring의 기존 **Next: RESULT** 버튼은 진행 요청만 보냅니다. Main이 Runtime 결과에 따라 다음 화면을 결정합니다.
   FAILURE의 INCIDENT는 현재 Case에서 ID로 검색한 incident_id / display_name / description을 표시합니다. Room01은 TEST_INCIDENT_01, Room03은 TEST_INCIDENT_03입니다. 유효 Incident와 연결된 Broadcast/Option이 있어야 Next: BROADCAST를 활성화합니다. 누락 시 경고와 대체 문구 또는 진행 차단을 적용합니다.
   BROADCAST는 broadcast_id / display_name / prompt_text와 options의 ID·문구를 Label로 표시합니다. 각 문구 옆 CheckBox로 하나를 임시 선택할 수 있고 재클릭해도 선택을 유지합니다. 처음에는 Confirm과 Next가 비활성화됩니다. 유효 Option을 선택하면 **Confirm Broadcast**만 활성화됩니다. Confirm 시 Main이 현재 Case/FAILURE/Incident/Broadcast와 Option ID, Option.result_id에 대응하는 실제 IncidentResultData까지 다시 확인하고 최초 ID 쌍만 Runtime에 기록합니다. 확정 항목은 **[Confirmed]**, 모든 Option과 Confirm은 disabled, **Next: INCIDENT RESULT**는 활성화됩니다. 같은 Broadcast 재진입은 이 상태를 복원합니다. 다른 Broadcast 또는 잘못된 snapshot은 경고와 함께 진행을 차단합니다. 연결된 결과가 없으면 Confirm을 거부하고 미확정 Next를 비활성 상태로 유지합니다. 피해/점수 판정은 없습니다.
   INCIDENT_RESULT에는 확정 Option의 result_id로 검색한 결과 ID/이름/설명을 표시합니다. 정상 데이터에서 Next: RESULT가 활성화됩니다. 누락 데이터는 경고/대체 문구와 진행 차단을 적용합니다. 다른 결과를 대신 표시하지 않습니다.
   Debug RESULT에서 Case ID/이름, **SUCCESS / FAILURE**, 확정 Room ID/이름, 실행 순서의 Experiment ID/이름, **Experiment Usage**를 확인합니다. FAILURE에는 연결된 Incident/Broadcast/확정 Option/IncidentResult의 ID와 이름·문구를 표시합니다. SUCCESS에는 Incident 없음, 나머지 실패 항목 해당 없음으로 표시합니다. 이력이 길어지면 요약 영역을 스크롤합니다.
   **Open Research Log**로 현재 Case의 확인된 정보를 열람하고 **Back**으로 동일 요약에 돌아옵니다. PROFILE / CCTV / EXPERIMENT / CONTAINMENT / INCIDENT / BROADCAST / INCIDENT_RESULT에서도 열 수 있고, Back은 원래 화면으로 복귀합니다. 현재 Stage까지 공개 가능한 정보만 표시하며 MONITORING에는 Open 버튼이 없습니다. 이 이동은 Runtime과 Resource를 변경하지 않습니다. View를 재생성하므로 미확정 Experiment/Room/Option 임시 선택은 초기화되고 실행·확정 상태는 복원됩니다.
   **Restart: PROFILE** 버튼으로 흐름을 반복합니다.
   이 버튼은 화면 흐름만 다시 시작합니다. 같은 Case의 실행 이력, 격리 확정, Monitoring 결과, Broadcast 확정 ID 쌍과 Research 발견 ID 목록은 유지됩니다. Runtime.reset()은 이 상태를 모두 초기화합니다.

각 View Scene을 따로 F6 실행하면 해당 임시 화면만 표시됩니다. 다음 화면의
선택은 Main이 담당하므로 전체 흐름 검증에는 Main의 F6 또는 프로젝트 F5를 사용합니다.
PROFILE / CCTV를 단독 실행하면 상위 계층이 데이터를 전달하지 않았으므로 명확한
누락 경고와 `Profile data unavailable` / `CCTV data unavailable`이 표시됩니다.
버튼의 진행 요청 기능은 유지됩니다.
EXPERIMENT를 단독 실행하면 빈 목록 경고와 `No experiments available`이 표시됩니다.
CONTAINMENT를 단독 실행하면 빈 목록 경고와 `No containment rooms available`이 표시됩니다.
MONITORING을 단독 실행하면 Outcome 누락 경고와 `Monitoring data unavailable`이 표시됩니다.
INCIDENT를 단독 실행하면 IncidentData 누락 경고와 `Incident data unavailable`, Next disabled 상태가 표시됩니다.
BROADCAST를 단독 실행하면 Broadcast 누락 경고와 `Broadcast data unavailable`, 빈 Option 목록과 Next disabled 상태가 표시됩니다.
INCIDENT_RESULT를 단독 실행하면 Result 누락 경고와 `Incident result data unavailable`, Next disabled 상태가 표시됩니다.
RESULT를 단독 실행하면 summary 누락 경고와 `[Unavailable]` / `None`, 빈 실행 목록, Next disabled 상태가 표시됩니다.
RESEARCH LOG를 단독 실행하면 snapshot 누락 경고와 빈 목록을 표시합니다. Back은 진행 요청만 보내며 실제 복귀는 Main이 담당합니다.

## 프로젝트 설정

| 항목 | 값 |
| --- | --- |
| Main Scene | `res://scenes/main/main.tscn` |
| UI 기준 크기 | 1920×1080 |
| 개발용 초기 창 크기 | 1280×720, 창 크기 변경 가능 |
| Stretch Mode | `canvas_items` |
| Stretch Aspect | `keep` — 16:9 유지, 다른 비율에서는 여백 표시 |
| Renderer | Compatibility (`gl_compatibility`) |
| Autoload / 플러그인 | 없음 |

기준 UI 크기와 실제 창 크기는 다릅니다. 아래의 `--resolution 1920x1080`은
1920×1080 창을 요청하는 옵션입니다. 일반 창에서는 Windows 작업 영역과
창 테두리 때문에 요청한 크기가 줄어들 수 있습니다. 고해상도 화면에서도 기본 선형
필터링과 Godot 기본 폰트를 사용하며, 별도 Theme나 Shader는 없습니다.

## 폴더 구조

```text
cap/
├── .gitattributes
├── .gitignore
├── README.md
├── project.godot
├── assets/                 # 앞으로 사용할 이미지·폰트·오디오 등의 원본 자산
│   └── .gitkeep
├── resources/
│   ├── .gitkeep
│   └── cases/
│       ├── test_case_01.tres # 기존 콘텐츠, Outcome3개/Stage9개/Incident2개/Broadcast2개/Option6개/IncidentResult6개/ResearchEntry24개/Disturbance2개
│       └── test_case_02.tres # Profile1/CCTV1/Experiment2/Room2/Research5/Reaction2/CCTVConditionObservation1, downstream 배열은 비어 있음
├── scenes/
│   ├── main/
│   │   └── main.tscn       # 기존 기반 UI와 ViewHost
│   └── views/
│       ├── profile_view.tscn
│       ├── cctv_view.tscn
│       ├── experiment_view.tscn
│       ├── containment_view.tscn
│       ├── monitoring_view.tscn
│       ├── result_view.tscn
│       ├── incident_view.tscn # IncidentData 표시, incident_view.gd 사용
│       ├── broadcast_view.tscn # Option 목록, Confirm Broadcast / Next: INCIDENT RESULT
│       ├── incident_result_view.tscn # 결과 ID/이름/설명과 Next: RESULT
│       ├── research_log_view.tscn # 현재 연구·편집 가능한 메모·Archive Open·Back
│       ├── research_archive_list_view.tscn # archived Case 목록/Open/Back
│       ├── research_archive_detail_view.tscn # 연구·메모 읽기 전용/Back
│       ├── environment_conditions_view.tscn # CCTV/Experiment/Containment 내부 표시 영역
│       └── environmental_disturbance_notice.tscn # Main의 modal overlay, 정규 Stage 아님
└── scripts/
    ├── data/
    │   ├── environmental_disturbance_data.gd / .gd.uid
    │   ├── case_disturbance_reaction_data.gd / .gd.uid
    │   ├── cctv_condition_observation_data.gd / .gd.uid # CCTV ID + Disturbance ID의 작성 관찰
    │   ├── broadcast_option_data.gd
    │   ├── broadcast_option_data.gd.uid
    │   ├── incident_result_data.gd
    │   ├── incident_result_data.gd.uid
    │   ├── emergency_broadcast_data.gd
    │   ├── emergency_broadcast_data.gd.uid
    │   ├── case_data.gd
    │   ├── case_data.gd.uid
    │   ├── cctv_data.gd
    │   ├── cctv_data.gd.uid
    │   ├── containment_data.gd
    │   ├── containment_data.gd.uid
    │   ├── incident_data.gd # ID/이름/설명과 Broadcast 연결 ID
    │   ├── incident_data.gd.uid
    │   ├── experiment_data.gd
    │   ├── experiment_data.gd.uid
    │   ├── monitoring_outcome_data.gd
    │   ├── monitoring_outcome_data.gd.uid
    │   ├── monitoring_stage_data.gd
    │   ├── monitoring_stage_data.gd.uid
    │   ├── research_entry_data.gd # Log 작성 문구: entry_id/source_kind/source_id/title/body_text
    │   ├── research_entry_data.gd.uid
    │   ├── profile_data.gd
    │   └── profile_data.gd.uid
    ├── main/
    │   ├── main.gd         # 창 크기 표시, View 전환, Runtime 연결, 격리 후보 검증/진행 보호
    │   └── main.gd.uid
    ├── runtime/
    │   ├── containment_resolution_state.gd / .gd.uid # 숨겨진 Case별 판정
    │   ├── failure_event_candidate_state.gd / .gd.uid # threshold/발생 여부, 세션 후보
    │   ├── case_runtime_state.gd # 메모리 Case ID, 실행 이력, 격리 ID, Monitoring 결과, Broadcast 확정 ID 쌍, Research 발견 ID 목록
    │   ├── case_runtime_state.gd.uid
    │   ├── pending_containment_state.gd # Case별 결과 대기 격리 결정, Case/Room ID만 저장
    │   ├── pending_containment_state.gd.uid
    │   ├── working_hypothesis_state.gd / .gd.uid # Main 소유 Case별 세션 개인 메모
    │   ├── research_archive_state.gd # 획득한 Case별 발견 ID, 결과 판정과 독립적인 세션 메모리 상태
    │   └── research_archive_state.gd.uid
    └── views/
        ├── environment_conditions_view.gd / .gd.uid # 표시용 Summary/Condition과 동적 상태 목록
        ├── environmental_disturbance_notice.gd / .gd.uid # 환경/관찰 표시와 Dismiss
        ├── broadcast_view.gd # 동적 Option/임시 선택/확정 요청, 확정 snapshot 복원과 UI 잠금
        ├── broadcast_view.gd.uid
        ├── flow_view.gd    # 진행/Open 버튼 입력을 요청 signal로 전달
        ├── flow_view.gd.uid
        ├── incident_view.gd # IncidentData 표시/누락 처리/Next 보호
        ├── incident_view.gd.uid
        ├── incident_result_view.gd # 전달된 IncidentResultData 표시/누락 처리/진행 요청
        ├── incident_result_view.gd.uid
        ├── cctv_view.gd    # 전달받은 CCTVData 표시
        ├── cctv_view.gd.uid
        ├── containment_view.gd # 목록/임시 선택/확정 요청, Runtime snapshot 표시
        ├── containment_view.gd.uid
        ├── experiment_view.gd # 전달받은 ExperimentData 배열을 동적 목록으로 표시
        ├── experiment_view.gd.uid
        ├── monitoring_view.gd # 전달된 Outcome의 Room ID와 Timer 기반 누적 Stage 재생
        ├── monitoring_view.gd.uid
        ├── result_view.gd # 표시용 Summary snapshot, 읽기 전용 요약/동적 실행 이력/누락 처리
        ├── result_view.gd.uid
        ├── research_log_view.gd # 현재 연구 Snapshot/Entry, 개인 메모 request, Archive Open
        ├── research_archive_list_view.gd / .gd.uid # CaseSummary/Snapshot와 Case ID request
        ├── research_archive_detail_view.gd / .gd.uid # 읽기 전용 Research/메모 Snapshot renderer
        ├── research_log_view.gd.uid
        ├── profile_view.gd # 전달받은 ProfileData 표시
        └── profile_view.gd.uid
```

`.godot/`는 실행 시 생성되는 로컬 캐시이며 Git에서 제외합니다.
폴더는 필요한 기능이 실제로 생겼을 때 확장합니다. 콘텐츠 데이터는
`resources/`, 실행 로직은 `scripts/`, 화면은 `scenes/`에서 시작할 수 있습니다.
Manager, Singleton, Interface, 별도의 추상 Base Class나 Framework는 없습니다.

## Scene 구성과 화면 전환

```text
Main (Control, main.gd)
└── Margin / Center / Content
    ├── Title
    ├── ReferenceSize
    ├── WindowSize
    ├── Notice
    └── ViewHost (Control)
        └── 현재 View 하나
            └── Center / Content
                ├── ScreenTitle
                ├── SubjectName / Classification (PROFILE만)
                ├── CameraId (CCTV만)
                ├── DisplayName / IncidentId (INCIDENT만)
                ├── BroadcastId / DisplayName (BROADCAST만)
                ├── ResultId / DisplayName (INCIDENT_RESULT만)
                ├── OptionScroll / OptionList (BROADCAST만, 동적 HBox → CheckBox + Label)
                ├── RoomId (MONITORING만)
                ├── Description
                ├── Workspace (EXPERIMENT만)
                │   ├── ExperimentScroll / ExperimentList (동적 항목)
                │   └── Execution / RemainingCount / RunButton / ResultTitle / ResultText
                ├── RoomScroll / RoomList (CONTAINMENT만, 동적 이름 CheckBox / 설명 Label)
                ├── Actions / ConfirmButton / NextButton / OpenResearchLogButton (CONTAINMENT, BROADCAST)
                ├── StageScroll / StageList (MONITORING만, 동적 시간/관찰 Label)
                ├── SummaryScroll / SummaryColumns (RESULT만)
                │   ├── Common: Case / FinalResult / Containment / Usage / 동적 ExperimentList
                │   └── FailureDetails: Incident / Broadcast / 확정 Option / IncidentResult
                ├── Actions / OpenResearchLogButton / NextButton (PROFILE, CCTV, EXPERIMENT, INCIDENT, INCIDENT_RESULT, RESULT)
                ├── MonitoringResult / EntryScroll / EntryList (RESEARCH LOG)
                └── NextButton (MONITORING, RESEARCH LOG)
```

화면 이름과 버튼 이름은 해당 `.tscn`에 있습니다. PROFILE / CCTV / EXPERIMENT / CONTAINMENT / MONITORING 콘텐츠는 Resource에
있습니다. INCIDENT, BROADCAST, INCIDENT_RESULT도 Case Resource의 데이터를 표시하고 RESULT는 확정된 Runtime과 현재 Case에서 파생한 snapshot을 표시합니다. Main에는 콘텐츠 문자열을 하드코딩하지 않았습니다.
모든 View는 Control 기반 독립 Scene입니다. Profile / CCTV / Experiment / Containment / Monitoring / Incident / Broadcast / IncidentResult / Result / ResearchLog 전용 Script는 기존 `flow_view.gd`를 한 단계 상속해 버튼 요청 기능을 재사용합니다.
EnvironmentalDisturbanceNotice는 Main 아래 Margin과 나란히 생성하는 별도 Control입니다. ViewHost와 정규 Route 밖에서 표시하며 FlowView를 상속하지 않습니다.
별도의 Scene 상속이나 추상 Base Class 계층은 없습니다.

`NextButton.pressed → advance_requested → Main._on_advance_requested() → 다음 View`로
진행합니다. [Godot signal](https://docs.godotengine.org/en/4.7/getting_started/step_by_step/signals.html)을
사용하며 개별 View는 Main이나 다른 View를 참조하지 않습니다.

`main.gd`는 `Stage` enum, 이에 대응하는 10개 PackedScene 목록, 현재 단계와
현재 View 참조, Inspector에서 지정한 `case_sequence: Array[CaseData]`, 현재 배열 index와 `current_case`를 보유합니다. 기본 Scene의 순서는 Case01, Case02입니다. 단일 Case 독립 검사 호환성을 위해 기존 current_case export도 유지하며 배열이 있으면 배열을 우선합니다. 전환 시 이전 View를 ViewHost에서 제거한 뒤
`queue_free()`하고 다음 View 하나를 추가합니다. 정상 Containment Next는 다음 Case의 PROFILE로 handoff하며, 기존 debug RESULT 다음은 같은 Case의 PROFILE입니다.
Stage enum은 PROFILE=0, CCTV=1, EXPERIMENT=2, CONTAINMENT=3, MONITORING=4,
RESULT=5, INCIDENT=6, BROADCAST=7, INCIDENT_RESULT=8, RESEARCH_LOG=9입니다. 새 Stage를 배열 끝에 추가해 기존 인덱스를 보존했습니다.
_get_next_stage(stage)의 match가 다음 Stage를 명시적으로 반환하고, -1이면 전환하지 않습니다.
RESEARCH_LOG는 이 정규 Route에 포함되지 않아 -1을 반환합니다. 각 View의 research_log_requested와 Log의 advance_requested는 Main의 전용 Open/Back handler에 연결합니다. Main은 8개 허용 Stage와 bind한 발신 Stage/활성 View를 검사하며, 복귀 Stage는 Main의 임시 정수 하나에만 저장합니다. Log에서는 다시 Log를 열 수 없으며 잘못된 복귀 Stage는 경고 후 차단합니다. 허용된 원래 Stage ↔ RESEARCH_LOG만 이동합니다.
진행 signal에는 발신 View를 bind합니다. 현재 View와 다른 객체, Tree 밖 객체,
queue_free 예정 객체의 요청은 무시해 이전 Monitoring / Incident / Broadcast / IncidentResult의 중복 전환을 차단합니다.
Main._is_active_view()가 이 생명주기 검사를 공통으로 수행하며 화면 진행, Experiment 실행,
Containment/Broadcast 확정, Monitoring 완료, Research Log Open/Back 요청 모두 같은 검사를 통과해야 합니다.
기존 debug 결과 Route는 Runtime.get_monitoring_result()만 사용하며 표시 문구나 View 내부 bool을 읽지 않습니다.
INCIDENT는 기존 FlowView를 사용하는 Control → CenterContainer → VBoxContainer에
제목, 이름, ID, 설명, NextButton을 둡니다. Incident Scene의 기존 콘텐츠를 보존하고 진행 버튼 옆에 Open을 추가했습니다. Broadcast Scene의 기존 Actions/ConfirmButton/NextButton에 Open 버튼을 추가했습니다. Runtime의 기존 Broadcast/Option 확정 ID 문자열 두 개를 유지하며 별도 Result 필드는 추가하지 않았습니다.
기존 창 크기 표시 함수와 연결은 보존했습니다.
Main._ready()에서 첫 Case ID로 CaseRuntimeState를 생성하며, 정상 handoff마다 다음 Case ID로 새 객체를 생성합니다. 이전 Runtime 객체를 reset하거나 수정하지 않습니다.
PendingContainmentState도 한 번 생성하며, 정상 Containment Confirm 승인 뒤에만 결정 ID를 등록합니다. 정상 handoff의 숨겨진 판정 기록이 성공한 Case만 remove_pending으로 제거합니다. debug 재생과 Log 왕복은 소비하지 않습니다.
같은 초기화 경계에서 ResearchArchiveState를 한 번 생성합니다. 검증된 정상 handoff 직전에 유효 authored 발견 ID를 merge하고 기존 debug RESULT의 merge 경계도 유지합니다. 단순 View 생성과 Research Log Open/Back은 Archive를 변경하지 않습니다.
일반 View 전환, RESULT → PROFILE, ExperimentView.setup()은 런타임 상태를 초기화하지 않습니다.
Containment handoff는 활성 View, 현재 Case/Runtime ID, 확정 Room, Pending Case/Room 일치, 현재 Case 후보 Room, 유효한 다음 배열 항목과 중복 Pending 여부를 검사합니다. Archive merge 뒤 index/current_case/Runtime을 교체하고 Log 복귀 Stage를 -1로 초기화합니다. Monitoring은 정상 Route에서 제외하며 Scene/Timer/Schema/debug 결과 처리 코드는 보존합니다.
View 버튼 disabled 상태뿐 아니라 Main의 진행 요청 처리에서도 확정 여부를 검사합니다.

`flow_view.gd`는 버튼 signal 연결, 버튼의 초기 키보드 포커스, 진행/Open 요청
signal 전송만 담당합니다. Open 버튼이 없는 Scene은 연결하지 않습니다. 다음 단계 결정, 데이터 처리, 결과 판정을 하지 않습니다.

## 테스트 Resource와 데이터 전달

[Godot Resource](https://docs.godotengine.org/en/4.7/tutorials/scripting/resources.html)를
데이터 컨테이너로 사용합니다. 열네 콘텐츠 클래스는 `class_name`과 typed export 필드로 콘텐츠를 정의합니다. MonitoringOutcomeData에는 최종 결과 enum도 있습니다.

| 파일 | 책임 / 필드 |
| --- | --- |
| `scripts/data/case_data.gd` | CaseData: 기존 필드, containment_outcomes: Array[MonitoringOutcomeData], incidents: Array[IncidentData], emergency_broadcasts: Array[EmergencyBroadcastData], incident_results: Array[IncidentResultData], research_entries: Array[ResearchEntryData], disturbance_reactions: Array[CaseDisturbanceReactionData] |
| `scripts/data/research_entry_data.gd` | ResearchEntryData: 기존 0~7 SourceKind 유지, DISTURBANCE_REACTION=8 추가; entry_id/source_id/title/body_text, 발견/저장 상태 없음 |
| `scripts/data/profile_data.gd` | ProfileData: profile_id, subject_name, classification, basic_description |
| `scripts/data/cctv_data.gd` | CCTVData: camera_id, observation_text만 정의 |
| `scripts/data/experiment_data.gd` | ExperimentData: experiment_id, display_name, description, result_text만 정의 |
| `scripts/data/containment_data.gd` | ContainmentData: room_id, display_name, description만 정의 |
| `scripts/data/monitoring_stage_data.gd` | MonitoringStageData: time_offset: int(프로토타입 검증용 초), observation_text: String; 최종 progression offset은 미정 |
| `scripts/data/monitoring_outcome_data.gd` | 현재 prototype resolution 콘텐츠: Result enum(UNDEFINED/SUCCESS/FAILURE), room_id, stages, final_result, incident_id |
| `scripts/data/incident_data.gd` | IncidentData: incident_id, display_name, description, broadcast_id, environmental_disturbance: EnvironmentalDisturbanceData |
| `scripts/data/broadcast_option_data.gd` | BroadcastOptionData: option_id: String, display_text: String, result_id: String |
| `scripts/data/incident_result_data.gd` | IncidentResultData: result_id: String, display_name: String, description: String |
| `scripts/data/emergency_broadcast_data.gd` | EmergencyBroadcastData: broadcast_id: String, display_name: String, prompt_text: String, options: Array[BroadcastOptionData] |
| `resources/cases/test_case_01.tres` | 기존 테스트 콘텐츠, Room별 Outcome 3개와 각 Stage 3개(0/10/20초), 검증용 문구, Room01/03 FAILURE·Room02 SUCCESS, Incident01/03 → Broadcast01/03 ID 연결, 각각 Option3개와 result_id로 연결한 개발용 IncidentResult6개 |
| `resources/cases/test_case_02.tres` | 독립 TEST_CASE_02, Profile1/CCTV1/Experiment2/Room2, 작성 Research4/Reaction2, 실행 제한2; Outcome/Incident/Broadcast/IncidentResult 없음 |
| `scenes/main/main.tscn` | Main.case_sequence에 Case01/Case02 Resource를 배열 순서대로 연결 |
| `scripts/main/main.gd` | 데이터 전달/전환, 현재 Runtime 및 네 독립 세션 상태 소유, 기존 실행/확정/Research 검증, 정상 handoff의 숨겨진 판정·Pending 소비·Archive 보존·새 Runtime·다음 PROFILE, opportunity와 overlay orchestration, 기존 debug 결과/후속 Route 유지 |
| `scripts/runtime/case_runtime_state.gd` | RefCounted 메모리 객체, Case ID/실행 이력, 중복·제한 검증, 격리 ID/Monitoring 결과/Broadcast ID 쌍 한 번 확정·조회/reset, 첫 발견 순서의 Research entry_id 목록과 중복 거부/getter 복사 |
| `scripts/runtime/pending_containment_state.gd` | RefCounted 세션 상태, case_id→확정 room_id, 중복·빈 ID 거부, 등록 순서 getter 복사, 독립 reset/remove_pending; 결과/시간/Resource 없음 |
| `scripts/runtime/containment_resolution_state.gd` | RefCounted, 숨겨진 최초 판정의 Case/Room/result/Incident ID, 복사 getter와 독립 reset |
| `scripts/runtime/failure_event_candidate_state.gd` | RefCounted, Case별 후보 ID/threshold/기회 수/triggered, ready 등록 순서와 복사 getter |
| `scripts/data/environmental_disturbance_data.gd` | ID/제목/시설 알림/명시적 조건 변화 문구 |
| `scripts/data/case_disturbance_reaction_data.gd` | Reaction ID/Disturbance ID/제목/관찰 사실 문구 |
| `scripts/views/environmental_disturbance_notice.gd` | 전달한 문구 표시, keyboard input 처리와 Dismiss 요청만 담당 |
| `scripts/views/profile_view.gd` | setup(ProfileData), 3개 표시 필드 반영, 누락/빈 필드 경고와 대체 문구 |
| `scenes/views/profile_view.tscn` | 제목·데이터 Label·기존 진행 버튼 레이아웃 |
| `scripts/views/cctv_view.gd` | setup(CCTVData), 두 필드 표시, 누락/빈 필드 경고와 대체 문구 |
| `scenes/views/cctv_view.tscn` | 제목·CameraId·Description·기존 진행 버튼 레이아웃 |
| `scripts/views/experiment_view.gd` | 목록/선택, experiment_execution_requested(ID), 승인 후 결과와 전달된 실행 상태 표시 |
| `scenes/views/experiment_view.tscn` | 제목·목록·RemainingCount·RunButton·결과 영역·기존 진행 버튼 |
| `scripts/views/containment_view.gd` | setup(rooms, confirmed_room_id), 후보/선택/확정 요청, snapshot 표시, 누락 처리; configure_next_action(text, can_advance)로 상위에서 전달한 다음 버튼 상태 표시 |
| `scenes/views/containment_view.tscn` | 기존 제목·개수·목록, Actions의 Confirm Containment / Next: CASE |
| `scripts/views/monitoring_view.gd` | prototype/debug playback: setup(outcome, finalized_result), Timer 순차 공개/완료 signal, 결과 적용/재진입 복원/Next 보호 |
| `scenes/views/monitoring_view.tscn` | 기존 제목/진행 버튼, RoomId/Description/StageScroll/StageList, one-shot PlaybackTimer |
| `scripts/views/incident_view.gd` | setup(IncidentData, can_advance=false), ID/이름/설명 표시, 누락 처리, Main이 전달한 Broadcast 가용성으로 Next 보호 |
| `scenes/views/incident_view.tscn` | 기존 제목/Next와 DisplayName/IncidentId/Description Label |
| `scripts/views/broadcast_view.gd` | setup(broadcast, confirmed_broadcast_id, confirmed_option_id), 동적 목록/임시 선택/확정 요청, snapshot 표시·복원·잠금, Next 보호 |
| `scenes/views/broadcast_view.tscn` | 기존 Control/목록, Actions → Confirm Broadcast / Next: INCIDENT RESULT |
| `scripts/views/incident_result_view.gd` | setup(IncidentResultData), ID/이름/설명 표시, 누락/빈 필드 처리, Next 요청 |
| `scenes/views/incident_result_view.tscn` | Control/Center/VBox, 제목·ResultId·DisplayName·Description·Next: RESULT |
| `scripts/views/result_view.gd` | setup(Summary), 공통/실패 요약, 실행 순서대로 동적 목록, 누락 경고·대체 표시, 기존 진행 signal |
| `scenes/views/result_view.tscn` | 기존 Control/제목/Restart, SummaryScroll 안의 공통 정보·FailureDetails 두 열 |
| `scripts/views/research_log_view.gd` | 작은 typed RefCounted Snapshot/Entry, setup 후 동적 읽기 전용 표시·목록 정리·스크롤 초기화 |
| `scenes/views/research_log_view.tscn` | Control/Center/VBox, 제목·Case·MonitoringResult·EntryScroll/EntryList·Back |
| `scripts/views/flow_view.gd` | 기존 진행 기능과 선택적 Open 버튼 요청만 담당; 데이터/복귀 위치/Stage 검증 없음 |

```text
test_case_01.tres (CaseData)
    └── profile_data (내장 ProfileData)
            ↓
Main.current_case.profile_data
            ↓
ProfileView.setup(profile_data)
            ↓
SubjectName / Classification / Description

Main.current_case.cctv_data (내장 CCTVData)
            ↓
CCTVView.setup(cctv_data)
            ↓
CameraId / Description

Main.current_case.available_experiments (내장 ExperimentData 배열)
            ↓
ExperimentView.setup(experiments)
            ↓
ExperimentList에 이름 CheckBox / 설명 Label 묶음을 배열 길이만큼 생성

Main.current_case.available_containment_rooms (내장 ContainmentData 배열)
            ↓
ContainmentView.setup(rooms, case_runtime.get_confirmed_containment_room_id())
            ↓
RoomList에 이름 CheckBox / 설명 Label 묶음을 배열 길이만큼 생성

CaseRuntimeState.get_confirmed_containment_room_id()
            ↓
Main._get_monitoring_outcome(): current_case.containment_outcomes의 room_id 일치 검색
            ↓
MonitoringView.setup(outcome, case_runtime.get_monitoring_result())
            ↓
RoomId / 전체 개수 / StageList에 시간 Label + 관찰 Label 묶음 생성
```

Main은 View를 트리에 추가하기 전에 `setup()`을 호출합니다. 여덟 전용 View는 데이터를
보관하고 `_ready()`에서 기본 진행 기능의 `super._ready()`를 호출한 뒤 표시합니다.
트리에 들어간 후 `setup()`을 다시 호출하는 경우에도 표시를 갱신하도록 했습니다.
여덟 View는 특정 `.tres` 경로를 알거나 로드하지 않으며, 데이터를 수정하지 않습니다.
순환 후 View를 새로 만들 때에도 동일한 Case의 데이터를 다시 전달합니다.

Incident 데이터 전달은 Runtime FAILURE + 확정 Room → 해당 MonitoringOutcome → incident_id
→ CaseData.incidents의 동일 ID → Main → IncidentView.setup(incident, broadcast_available) 순서입니다.
Main._get_current_incident_data()는 Runtime이 FAILURE인지 먼저 확인하며 다른 결과에서는 검색하지 않습니다.
Case/확정 Room/Outcome/Room 일치/Outcome FAILURE/비어 있지 않은 incident_id를 검증한 뒤
incidents 배열을 ID로 검색합니다. null·빈 ID 후보는 warning 후 건너뛰고, 없으면 null을 반환합니다.
Incident01/03은 각각 Room01/03 Failure용 임시 문구입니다. SUCCESS Outcome의 incident_id는 빈 값입니다.
SUCCESS에 실수로 Incident ID가 있어도 Route는 Runtime SUCCESS → RESULT이며 Incident와 Broadcast를 조회하거나 생성하지 않습니다.
ContainmentData와 IncidentData는 이번 단계에서 변경하지 않았습니다. IncidentData에는 기존 Broadcast 연결 ID만 있으며 트리거/Room/결과/피해 필드는 없습니다.

IncidentView는 전달된 Resource만 표시하고 Case/Main/Runtime이나 특정 .tres를 탐색하지 않습니다.
setup은 준비 전 데이터를 저장하며 _ready에서 표시합니다. 준비 후 반복 setup은 Label 전체와 Next를 갱신합니다.
null 또는 빈 incident_id는 warning, Incident data unavailable, Next disabled입니다.
ID가 유효하고 이름/설명만 비어 있으면 [Missing display_name] / [Missing description]으로 표시하며, 연결 Broadcast와 유효 Option이 있을 때 진행할 수 있습니다.
View의 pressed 처리와 Main의 현재 Incident → Broadcast 재검색/유효 Option 검사 양쪽에서 누락 진행을 차단합니다.
Main은 disabled 상태나 이전 View snapshot을 믿지 않으며, 현재 Case에 유효 Incident/연결 Broadcast/유효 Option이 없으면 직접 advance signal도 거부합니다.
재진입은 현재 확정 Room/Outcome/ID에서 같은 데이터를 다시 파생하며 별도 Incident Runtime 상태를 저장하지 않습니다.
읽기와 화면 전환은 Resource나 Experiment/격리/Monitoring Runtime 상태를 변경하지 않습니다.

Broadcast 데이터는 Runtime FAILURE → 현재 Incident.broadcast_id → CaseData.emergency_broadcasts의 동일 ID
→ Main → BroadcastView.setup(broadcast, confirmed_broadcast_id, confirmed_option_id) 순서로 전달합니다. 배열 인덱스나 특정 테스트 ID로 연결하지 않습니다.
각 Option은 입력 순서대로 HBoxContainer 안에 CheckBox와 기존 줄바꿈 Label을 생성합니다. null Option은 warning 후 건너뛰고 빈 option_id는
[Missing option_id]를 표시하며 선택 버튼을 비활성화하고 유효 개수에 포함하지 않습니다. 빈 display_text는 warning/대체 문구를
표시하되 ID가 유효하면 선택과 진행이 가능합니다. 빈 이름/문구도 warning/대체 문구를 표시합니다.
null/빈 Broadcast ID/빈 options/유효 Option 0개는 Next disabled이며 Main도 최신 데이터를 재검증합니다.
반복 setup은 기존 Option을 제거·해제하고 필드/버튼/스크롤/선택 인덱스/ButtonGroup/snapshot을 초기화합니다. 재진입은 현재 데이터와 실제 Runtime ID 쌍을 다시 전달해 미확정 선택 없음 또는 확정 잠금을 복원합니다.
Broadcast 선택은 View의 _selected_option_index와 ButtonGroup에만 둡니다. Main/Resource/Runtime에는 저장하지 않습니다.
ButtonGroup.allow_unpress=false와 표시 동기화로 최대 하나만 선택되고 같은 Option 재클릭은 선택을 유지합니다.
programmatic pressed 요청도 그룹의 각 버튼을 set_pressed_no_signal로 동기화해 중복 선택/신호 재귀를 방지합니다.
이전 그룹·Tree 밖·해제 예정 버튼/View의 요청과 무효 ID 선택을 거부합니다. Option 클릭은 Main에 signal을 보내지 않습니다.
선택만으로는 Next를 활성화하거나 Runtime에 기록하지 않습니다. 유효 선택 시 Confirm만 활성화됩니다.
`ConfirmButton.pressed → broadcast_confirmation_requested(broadcast_id, option_id) → Main` 순서로 요청합니다.
Main은 현재 단계/발신 View/Tree/해제 예정 여부, 현재 Case/FAILURE/Incident 연결을 다시 검사하고 요청 Broadcast ID의 일치와 현재 options 안의 Option ID 존재 여부를 확인합니다. 배열 인덱스로 확정하지 않습니다.
선택 Option.result_id가 빈·공백이 아니며 현재 Case.incident_results에 동일 ID의 데이터가 있는지까지 검사합니다.
최초 정상 승인만 Runtime.try_confirm_broadcast_option()으로 두 ID를 함께 기록하며 기존 실험/격리/Monitoring 상태는 보존합니다.
승인/거부 후 Main은 실제 두 ID를 update_confirmation_state()로 전달합니다. View는 Runtime이나 Main을 직접 읽지 않습니다.
유효 확정 snapshot은 해당 항목에 [Confirmed]를 표시하고 모든 Option/Confirm을 잠그며 Next를 활성화합니다.
다른 Broadcast/없는 Option/부분 ID 쌍은 경고와 함께 잠금 및 Next disabled로 처리합니다. 같은 Broadcast 재진입에서는 재기록하지 않습니다.
View 버튼 검사와 Main의 Runtime 확정 ID 쌍·현재 Broadcast·현재 Option ID 재검증으로 미확정 직접 advance도 차단합니다.
확정 쌍에서 파생한 실제 Option의 result_id로 IncidentResultData를 검색하고 IncidentResultView.setup(result)로 전달합니다. Runtime에 Result ID/완료 상태를 추가하지 않습니다.
BROADCAST/INCIDENT_RESULT의 직접 advance에서도 이 현재 결과 연결이 유효해야 진행합니다. 없으면 warning/대체 UI/Next 차단, 다른 Result fallback은 없습니다.
IncidentResultView는 받은 Resource의 ID/이름/설명만 표시합니다. null/빈 ID는 경고와 진행 차단, 정상 ID의 빈 이름/설명은 경고와 [Missing ...] 문구입니다.
반복 setup은 모든 텍스트/Next를 갱신하며 signal은 _ready에서 한 번만 연결합니다. Main/Runtime/Case/.tres를 직접 찾지 않습니다.
별도 Item Scene, 결과 평가, 피해/점수 필드는 없습니다. 실행 중 콘텐츠 Resource는 변경하지 않습니다.

ContainmentView는 배열 순서대로 VBoxContainer와 이름 CheckBox / 설명 Label을 생성합니다.
ExperimentView와 같은 ButtonGroup 패턴을 사용하며 별도 Item Scene은 없습니다.
선택 인덱스 `_selected_room_index`는 View 안의 임시 상태이며 -1은 선택 없음입니다.
ButtonGroup.allow_unpress=false로 최대 하나만 선택되고 같은 후보 재클릭은 선택을 유지합니다.
선택 변경만으로 Main이나 CaseRuntimeState에 기록하지 않습니다.
재진입과 setup() 재호출 시 임시 선택 인덱스와 그룹을 초기화하고 이전 항목을 제거/해제하며
스크롤을 처음으로 되돌립니다. 기본 3개는 한 화면에
표시되며 4개부터 스크롤로 볼 수 있습니다. 빈 배열은 `No containment rooms available`,
null은 `[Missing ContainmentData]`, 빈 이름/설명은 `[Missing display_name]` / `[Missing description]`으로
표시합니다. null이나 빈 문자열/공백 room_id는 경고와 선택 비활성화로 처리합니다.
정상 ID의 이름/설명이 비면 대체 문구를 표시하고 선택은 가능합니다.
선택 없음일 때 Confirm은 비활성화되며 유효한 후보 선택 시 활성화됩니다.
후보를 수정하려면 테스트 Case의 available_containment_rooms 배열이나 각 Resource의 세 필드를 편집합니다.
Confirm 입력은 `containment_confirmation_requested(room_id)`를 Main에 전달합니다.
Main은 현재 View에서 온 요청인지와 현재 Case 후보 배열에 ID가 실제 존재하는지 확인한 뒤
Runtime의 `try_confirm_containment_room()`을 호출합니다. null/빈·공백 ID/없는 후보는 기록하지 않습니다.
승인/거부 후 모두 실제 Runtime ID를 `update_confirmation_state()`로 전달합니다.
View는 Runtime을 직접 탐색하지 않고 snapshot만 표시합니다.
확정 시 해당 이름에 `[Confirmed]`를 붙이고 후보 전체와 Confirm을 잠그며 Next를 활성화합니다.
같은 Case 재진입과 반복 setup에서는 Runtime의 확정 ID를 그대로 전달해 이 표시를 복원합니다.
격리 확정은 최종 결정으로 취급하며 같은 ID 요청도 두 번째 확정은 거부합니다.
Main에는 격리 상태 사본이나 격리실 자체의 정답 판정이 없습니다. Monitoring의 final_result만 현재 Case에서 확인해 Runtime에 전달합니다.

아래 Monitoring 설명은 유지 중인 prototype/debug resolution playback에만 해당합니다.
최종 normal gameplay에서는 실시간 Timer를 사용하지 않고 게임 진행 단위를 사용할 예정입니다.
최종 게임의 단위/간격은 미정이며, 이번 prototype에서는 handoff를 숨겨진 판정 경계로 사용합니다.
기존 time_offset/Timer/Outcome Schema와 debug Route를 보존하며, 정상 Pending 소비는 숨겨진 Resolution 기록 성공 뒤에만 수행합니다.

Main은 MONITORING 생성 시 확정된 Room ID로 현재 Case의 containment_outcomes를 검색합니다.
배열 인덱스나 첫 Outcome으로 대신 연결하지 않으며, ID가 일치하는 첫 유효 Outcome을 전달합니다.
확정 Room/Case/목록/일치 Outcome이 없으면 경고와 null을 전달합니다. null Outcome과 빈 ID 항목은 경고하고 건너뜁니다.
MonitoringView는 Room ID, 전체 Stage 개수와 공개된 관찰 기록만 표시합니다.
Stage마다 기존 VBoxContainer와 시간/관찰 Label 두 개를 추가하며 이미 공개한 기록은 남깁니다.
기존 시간 표기 `[0s]` / `[10s]` / `[20s]`, 스크롤과 레이아웃을 유지합니다.

Main은 Tree 추가 전에 완료 signal을 연결하고 setup(outcome, runtime_result)를 호출합니다.
setup은 Outcome/확정 결과 snapshot을 저장하고 인덱스/offset/active/completed를 초기화합니다.
_ready()에서 버튼/Timer를 한 번 연결하고 표시를 시작합니다. Tree 밖에서 Timer.start()는 호출하지 않습니다.
이미 준비된 View의 setup은 기존 Timer를 중단하고 행을 제거/해제하며 스크롤/Next/이전 결과 표시를 초기화합니다.
_exit_tree()에서 Timer 정지와 진행 차단을 처리하며 View 해제 시 자식 Timer와 연결도 해제됩니다.

UNDEFINED snapshot에서는 one-shot PlaybackTimer 하나로 원래 Stage 배열 순서대로 재생합니다.
대기는 max(현재 offset − 이전 유효 Stage offset, 0)이며 첫 기준은0입니다.
0초/동일시간 Stage는 즉시 반복 처리하고 음수/역행은 경고하며 Resource를 보정하거나 정렬하지 않습니다.
유효 Stage를 모두 공개한 뒤 local active=false/completed=true, Timer 정지 상태가 됩니다.
이 시점에도 Next는 disabled이고 결과는 숨깁니다. 인자 없는 monitoring_playback_completed signal만 보냅니다.

Main은 현재 View와 Case, 확정 Room, ID로 다시 찾은 Outcome, room_id 일치, 해당 Outcome의 실제 로컬 재생 완료,
유효한 SUCCESS/FAILURE, Runtime에 결과가 없음을 검사합니다.
UNDEFINED/지원하지 않는 enum, 다른 Outcome, 미완료/이전 View 요청, 기록 실패는 결과를 확정하지 않습니다.
try_set_monitoring_result() 성공 후 Runtime의 실제 결과를 apply_monitoring_result()로 전달합니다.
View는 기존 Description Label에 `Monitoring Result: SUCCESS` 또는 `Monitoring Result: FAILURE`를 표시하고 Next를 활성화합니다.
apply는 완료 전/유효하지 않은 값/이미 표시된 결과를 바꾸는 요청을 적용하지 않습니다.
Main도 Monitoring 진행 요청에서 Runtime 결과를 확인하므로 UI의 disabled/문구/로컬 상태를 우회해도 UNDEFINED에서는 진행하지 않습니다.

Runtime 결과가 있는 재진입/setup은 유효 Stage 전체와 결과를 즉시 복원합니다.
Timer 시작이나 완료 signal 재전송, Runtime 결과 재기록은 없습니다. 결과가 없는 재진입은 처음부터 재생합니다.
null Outcome/빈 배열/전부 null은 대체 UI, Timer 정지, Next disabled로 처리합니다.
일부 null Stage는 경고하고 건너뛰며 빈 관찰 문구는 `[Missing observation_text]`를 표시합니다.
final_result가 UNDEFINED여도 Stage 재생은 가능하지만 마지막에 Main이 경고하고 결과/Next를 미확정 상태로 유지합니다.
Main._get_next_stage()는 Runtime SUCCESS → RESULT, FAILURE → INCIDENT, UNDEFINED → -1(진행 거부)를 반환합니다. FAILURE는 INCIDENT → BROADCAST(결과 연결 검증 후 확정) → INCIDENT_RESULT → RESULT → PROFILE이며 순차 +1 계산을 사용하지 않습니다.

MonitoringOutcomeData.Result는 UNDEFINED=0, SUCCESS=1, FAILURE=2입니다.
검증용 Case의 Room01/03 Outcome은 FAILURE, Room02 Outcome은 SUCCESS이며 정식 콘텐츠 정답을 뜻하지 않습니다.
CaseRuntimeState의 _monitoring_result와 has/get/try_set_monitoring_result API로 결과를 한 번만 확정합니다.
UNDEFINED/미지원값/이미 확정된 같은 값·다른 값은 거부합니다.
reset()은 기존 Case ID 정책을 유지하면서 실험 이력/확정 Room/Monitoring 결과/Broadcast 확정 ID 쌍/Research 발견 ID 목록을 모두 초기화합니다.
Stage 진행 위치나 경과 시간은 Runtime에 넣지 않았습니다. ContainmentData/공용 flow_view/설정/UID는 변경하지 않았습니다.

ExperimentView는 배열 순서대로 `VBoxContainer`와 이름 CheckBox / 설명 Label을 생성합니다.
기존 이름 Label만 CheckBox로 바꿨으며 별도 Component Scene이나 Script는 없습니다.
목록을 다시 표시하기 전에 이전 항목을 컨테이너에서 제거하고 해제하므로 반복 `setup()`에도
중복되지 않습니다. 기본 세 항목은 스크롤 없이 보이며, 네 번째 항목부터는 스크롤로 확인합니다.
선택 상태는 View의 `_selected_experiment_index`(-1은 선택 없음)에만 저장합니다.
View 내부 `ButtonGroup`과 기본 선택 표시를 사용해 최대 하나만 선택됩니다.
`CheckBox.pressed → _on_experiment_selected(index)`로 인덱스만 갱신하며 Main으로 전달하지 않습니다.
같은 항목을 다시 클릭해도 해제되지 않습니다. View 재진입과 `setup()` 재호출 시 선택 인덱스와
그룹을 초기화합니다. null 항목은 누락 문구를 유지하고 선택 Control을 비활성화합니다.
ExperimentData에는 선택 상태 필드가 없으며 콘텐츠를 수정하지 않습니다.
진행 버튼은 스크롤 영역 밖에 있으며 선택 여부와 관계없이 다음 View로 이동합니다.

실행 버튼은 선택 없음일 때 비활성화됩니다. 미실행이며 남은 횟수가 있는 항목을 선택하면 활성화되며,
`RunButton.pressed → _on_run_experiment_pressed()`에서 선택 인덱스와 Resource를 확인하고
비어 있지 않은 experiment_id를 확인한 뒤 `experiment_execution_requested(ID)`를 보냅니다.
Main은 현재 Stage/활성 View/Case Runtime 소속과 실제 Case 후보 ID를 확인한 뒤 `CaseRuntimeState.try_record_experiment_execution(ID, limit)`으로 승인과 기록을 요청합니다.
성공한 경우에만 `show_execution_result(ID, true)`가 Resource의 result_text를 표시합니다.
거부되면 결과를 표시하지 않으며 어느 경우든 Main이 최신 실행 상태를 View에 전달합니다.
비동기 처리나 대기 시간은 없습니다.
결과 상태는 View 안의 Label 표시 값뿐이고 Resource에 기록하지 않습니다.
다른 항목 선택, setup() 재호출, View 재진입 시 `No experiment has been executed.`로 초기화합니다.
같은 미실행 항목 재클릭은 선택을 유지합니다. 승인된 항목은 선택을 해제하고 재실행을 차단하며
결과는 화면에 유지합니다. Main은 결과 텍스트나 실행 UI를 처리하지 않습니다.
ExperimentView는 Runtime State를 소유하거나 탐색하지 않으며 flow_view.gd는 그대로입니다.
`setup(experiments, executed_ids, remaining_count, experiment_limit)`에 현재 이력 복사본과
Runtime에서 계산한 남은 횟수, Case 콘텐츠 제한을 전달합니다. View의 이력/횟수 값은 표시용
snapshot이며 실행 최종 권한을 갖지 않습니다. Runtime snapshot을 생략하면 안전하게 실행 불가입니다.
재진입 또는 setup 재호출 시 임시 선택/결과를 초기화하고 전달된 완료 상태/남은 횟수를 다시 반영합니다.

CaseRuntimeState는 `case_id: String`, `_experiment_execution_history: Array[String]`,
`_confirmed_containment_room_id: String`, `_monitoring_result`, `_confirmed_broadcast_id: String`, `_confirmed_broadcast_option_id: String`을 보유합니다.
생성 시 Case ID를 지정할 수 있고 `reset(case_identifier = "")`은 기존 ID 지정 정책대로 이력과 확정 ID를 비웁니다.
`try_confirm_containment_room(room_id)`는 빈·공백 ID와 두 번째 확정을 거부하고 최초 정상 ID만 기록합니다.
`has_confirmed_containment()`와 `get_confirmed_containment_room_id()`로 확정 상태를 조회합니다.
현재 Case 후보 여부 검증은 Main이 담당하며 Runtime은 콘텐츠 Resource를 참조하지 않습니다.
`try_record_experiment_execution(experiment_id, limit)`는 빈/공백 ID, 중복, 소진된 제한을 거부하고
검증과 기록을 하나의 동기 API로 수행합니다. 이전의 무제한 기록 API는 이 안전한 API로 교체했습니다.
정상 ID는 원래 문자열로 추가하며 승인된 실행 순서를 보존합니다.
`has_executed_experiment()`와 `can_execute_experiment()`로 현재 상태를 조회합니다.
`get_remaining_experiment_count(limit)`는 제한과 이력 크기에서 0 이상 값을 계산합니다.
`get_experiment_execution_history()`는 복사본을 반환하고,
`get_experiment_execution_count()`는 배열 크기에서 계산합니다. 별도의 count/remaining 필드는 없습니다.
CaseData.experiment_limit의 기본값은 0입니다. 테스트 Case는 검증용 임시 값 2이며 최종 밸런스가 아닙니다.
0은 실행 불가, 음수는 경고와 실행 불가로 처리하며 Resource의 원래 값은 수정하지 않습니다.
State는 .tres나 디스크에 저장하지 않으며 Main이 해제되거나 프로그램을 종료하면 사라집니다.
Broadcast API는 `try_confirm_broadcast_option(broadcast_id, option_id) -> bool`, `has_confirmed_broadcast_option() -> bool`, `get_confirmed_broadcast_id() -> String`, `get_confirmed_broadcast_option_id() -> String`입니다. 초기 ID 쌍은 빈 문자열입니다. 빈·공백 ID 및 두 번째 같은/다른 쌍은 false로 거부하고 기존 쌍을 보존합니다. 최초 정상 쌍은 한 동기 호출에서 두 ID를 함께 기록합니다. 현재 Case 콘텐츠 검증은 Main의 책임이며 Runtime은 Resource를 참조하지 않습니다.

Runtime의 `try_apply_disturbance(disturbance_id, reaction_id = "")`는 같은 쌍의 중복을 거부합니다.
`get_applied_disturbances()`는 Dictionary 배열의 deep copy를 반환하며 `reset()`은 적용 기록도 초기화합니다.
현재 Runtime의 debug Monitoring 결과와 숨겨진 session Resolution은 서로 다른 상태입니다.

테스트 Resource 교체는 `main.tscn`의 **Main**을 선택하고 Inspector의
**Current Case (`current_case`)**에 다른 CaseData Resource를 지정한 뒤 Scene을 저장합니다.
GDScript에는 테스트 Resource 경로가 없으므로 Script를 수정할 필요가 없습니다.

표시 값만 바꾸려면 `test_case_01.tres`를 열고 내장 `profile_data`의
`subject_name`, `classification`, `basic_description`을 편집해 저장한 뒤 게임을 다시 실행합니다.
같은 Resource의 내장 `cctv_data`에서 `camera_id`, `observation_text`도 편집할 수 있습니다.
`available_experiments` 배열에서는 ExperimentData의 이름/설명을 편집하거나 항목을 추가·제거합니다.
각 항목의 필드는 experiment_id, display_name, description, result_text이며 기본 테스트 데이터는 세 개입니다.
테스트 결과를 바꾸려면 해당 Experiment의 result_text를 편집하고 저장한 뒤 다시 실행합니다.
Resource를 실행 중 자동 갱신하는 기능은 추가하지 않았습니다.

데이터가 null이면 경고와 대체 문구를 표시합니다. 빈 문자열 또는 공백만 있는 표시 값은
필드 이름이 포함된 경고와 `[Missing 필드명]`으로 표시합니다. PROFILE/CCTV와 실험을 건너뛰는
Next는 정보성 진행이므로 유지하지만, 격리 확정·Monitoring 완료·Broadcast 확정·결과 연결 등
진행 전제가 필요한 화면은 해당 상태가 없으면 View와 Main에서 진행을 차단합니다.
`case_id`, `display_name`, `profile_id`가 비어 있을 때도 해당 필드 경고를 출력합니다.
별도 Content Validator 시스템은 없습니다.
Experiment 배열이 비면 `No experiments available`을 표시합니다. null 항목은 해당 위치에
누락 대체 항목을 표시하고, 빈 experiment_id는 목록 표시 시 경고하며 실행 시 실패 처리합니다. 이름/설명이 비면
해당 Label에 `[Missing display_name]` / `[Missing description]`을 표시합니다.
선택이 없거나 Resource가 null이면 실행을 방지하고, 강제 실행 요청에도 경고와 초기 문구를
표시합니다. result_text가 빈 문자열 또는 공백뿐이면 경고와 `[Missing result_text]`를 표시합니다.
유효한 ID의 빈 결과는 기존 정책대로 실행 성공으로 취급해 이력에 기록합니다.
이 경우에도 Runtime이 중복/제한을 승인한 경우에만 대체 결과를 표시하고 1회를 소비합니다.

## 명령행 검사

PowerShell에서 Godot 콘솔 실행 파일 경로를 지정한 후 프로젝트 루트에서 실행합니다.

```powershell
$godotExe = 'C:\path\to\Godot_v4.7.1-stable_win64_console.exe'
& $godotExe --headless --path . --import
& $godotExe --headless --path . --script res://scripts/main/main.gd --check-only
& $godotExe --headless --path . --script res://scripts/views/flow_view.gd --check-only
& $godotExe --headless --path . --script res://scripts/views/profile_view.gd --check-only
& $godotExe --headless --path . --script res://scripts/views/cctv_view.gd --check-only
& $godotExe --headless --path . --script res://scripts/views/experiment_view.gd --check-only
& $godotExe --headless --path . --script res://scripts/views/result_view.gd --check-only
& $godotExe --headless --path . --script res://scripts/data/profile_data.gd --check-only
& $godotExe --headless --path . --script res://scripts/data/cctv_data.gd --check-only
& $godotExe --headless --path . --script res://scripts/data/experiment_data.gd --check-only
& $godotExe --headless --path . --script res://scripts/data/case_data.gd --check-only
& $godotExe --headless --path . --quit-after 10
& $godotExe --path . --resolution 1920x1080 --quit-after 120
```

Headless 검사는 파싱과 실행 오류를 확인합니다. 실제 화면 확인은 마지막
명령이나 에디터의 F5로 진행합니다. Windows 실행 파일 배포용 export preset과
export template 설정은 배포 단계에서 추가합니다.

## 1단계 기반 검증 결과

검증 엔진: `4.7.1.stable.official.a13da4feb` (Windows Standard).

| 검사 | 결과 |
| --- | --- |
| Headless editor import | 종료 코드 0, 프로젝트/Scene/Script 파싱 오류 없음 |
| `main.gd`의 `--check-only` | 종료 코드 0, GDScript 오류 없음 |
| 설정된 Main Scene의 headless 실행 | 10프레임 실행, 종료 코드 0 |
| Windows Compatibility GPU 렌더링 | AMD Radeon RX 6800 / OpenGL 3.3, 종료 코드 0 |
| 1920×1080 실제 렌더 | 1920×1080 이미지, Main의 논리적 UI 크기 1920×1080, 문구 정상 |
| 1280×720 실제 렌더 | 비례 축소와 창 크기 문구 갱신 정상 |
| 1024×768 창 | 16:9 콘텐츠 영역 1024×576, 논리적 UI 크기와 창 크기 문구 정상 |

실제 화면 이미지를 직접 확인해 텍스트 표시와 중앙 정렬을 검증했습니다.
정확한 1920×1080 캡처는 검증용 임시 스크립트에서 테두리 없는 창으로 수행했습니다.
이 창 설정은 `project.godot`나 Main Scene에 추가하지 않았습니다.

첫 제한된 샌드박스 실행에는 Windows 인증서 저장소 읽기 및 사용자 에디터
설정 저장 오류가 있었습니다. 실행 권한을 확보하고 검증 프로필을 격리한 후
가져오기와 실행 로그에 해당 오류가 없는 것을 확인했습니다.
미해결 프로젝트 오류는 없습니다.

검증용 스크립트, 격리 프로필, 로그, 캡처는 Git에서 제외되는
`.godot/verification/`에만 있습니다. 게임에서 로드하지 않는 로컬 검증 자료입니다.
UID 파일은 Git 보존 대상입니다. 25·26단계까지 `c8c993d`에 커밋·push되어 있으며 27·28단계 변경은 미커밋 상태입니다.

## 2단계 UI 흐름 검증 결과

같은 Godot **4.7.1**에서 다음을 검증했습니다. 미해결 프로젝트 오류는 없습니다.

| 검사 | 결과 |
| --- | --- |
| 전체 프로젝트 editor import | 종료 코드 0, 파싱 오류 없음 |
| Main / 공용 View GDScript `--check-only` | 모두 종료 코드 0 |
| 설정된 Main의 headless 및 Windows GPU 실행 | 모두 종료 코드 0 |
| 6개 View의 개별 Scene 실행 | 모두 종료 코드 0 |
| PROFILE 시작 및 전체 흐름/재시작 | 마우스 누름·해제를 GUI에 전달해 검증, 성공 |
| 1920×1080, 1280×720, 1024×768 | 각 크기에서 6번 클릭으로 전체 흐름과 재시작 완료 |
| Headless / Windows GPU 흐름 검사 | 각각 18번 클릭, 3회 순환, 종료 코드 0 |
| View 표시 및 해제 | 전환 직후에도 ViewHost의 자식은 하나, 이전 View 해제 확인 |
| 레이아웃 | Main 논리 크기 1920×1080 유지, View/버튼이 영역 내부에 위치, 설명 높이 정상 |
| GPU 캡처 | 6개 화면 × 3개 창 크기, 18개 PNG 생성; 6개 원본 크기 화면 및 작은 창 캡처 직접 확인 |
| 프로젝트 설정과 기존 검증 코드 | 작업 시작 전 SHA-256과 동일 |

1024×768 창의 콘텐츠 렌더 영역은 기존과 같이 1024×576입니다. 정확한
1920×1080 GPU 검증은 임시 테두리 없는 창을 사용했으며 제품 설정은 변경하지 않았습니다.
F5 키 자체를 자동 조작하지는 않았지만, 같은 `run/main_scene`을 사용하는
프로젝트 기본 실행을 headless와 Windows GPU 양쪽에서 확인했습니다.

검증 Script와 로그, 캡처, 변경 전 파일 사본 및 비교 결과는
`.godot/verification/step2/`에만 있습니다. 이전 검증 코드는 수정하지 않았습니다.
흐름 검증 Script는 `flow_validation.gd`이며 Godot의 `--script` 옵션으로 실행했습니다.
이 자료는 Git 제외 대상이며 게임 실행에서 로드하지 않습니다.

## 40단계 Delayed Major Incident Interrupt

과거 Case의 hidden FAILURE 후보가 환경 교란을 먼저 일으키고, 이후 별개의 안전한 Gameplay opportunity에서 기존 INCIDENT → BROADCAST → INCIDENT_RESULT를 처리한다. 정상 대응은 같은 current Case/Runtime과 중단 stage로 복귀하며 RESULT로 가지 않는다. debug downstream 경로는 보존했다.

Main 소유 IncidentResponseState가 source Case 응답 ID와 ACTIVE/COMPLETED만 보관한다. source Research는 실제 표시/Confirm 때 Archive에 incremental merge하고 current Case Runtime에 넣지 않는다. 대응 화면의 Open Source Archive는 과거 Case Research/Hypothesis를 읽기 전용으로 보여준다.

**TEMPORARY / PROTOTYPE:** 기존 교란 threshold 2–4 유지, Major threshold는 Main 한 곳의 `PROTOTYPE_MAJOR_THRESHOLD = 1`. 교란 action/Dismiss/읽기/Resume는 Major 기회가 아니다. 마지막 Containment에서 교란이 발생하면 후속 기회가 없어 보류된다. 현 두 Case의 첫 CCTV Major는 기존 교란 fixture로만 검증했다.

요청한 106개 보고 항목, 변경 범위, 정상/fixture 구분, 검증 결과와 한계는 [Step40 보고서](docs/step40_major_incident_interrupt.md)에 정리했다. 기존 Step39 미커밋 파일과 프로젝트/Scene/해상도 설정을 보존했다. 커밋·push하지 않는다.

Godot 4.7.1에서 **215/215 검사(headless 126 + Windows GPU 89)**와 최종 editor import를 통과했다. 이번 단계는 기존 파일 4개 수정·3개 추가이며, 두 Step39 Resource/보고서와 이전 검증 소스 2,539개가 보존되었다. 세 해상도에서 Major/Source Archive/복귀와 기록된 실험 조건 결과 화면을 확인했다.

## 39단계 Case Evidence 콘텐츠 정비

기존 두 Case의 Profile·CCTV·실험·Room 설명과 연결된 Research 문구를 정비했습니다.
Case01은 지지 구조/환기 전환, Case02는 벽 접촉의 기능/공기 반응을 기본 증거로 비교합니다.
환경 사건은 순간 반응·지속 관찰·선택적 실험 비교로 역할을 나눴으며,
조건 실험을 놓쳐도 기본 판단에 필요한 정보는 기존 CORE 출처에서 얻을 수 있습니다.
실험 제한·ID·판정·Main·State·View·해상도 설정은 유지했습니다.
Case02에는 기존 Outcome가 없으므로 ROOM01은 콘텐츠상 합리적인 후보이며,
마지막 Case의 제출 후 Pending 경계는 그대로입니다.
두 Evidence Map, 시점별 접근성, 요청한 70개 항목과 검증 결과는
[Step39 콘텐츠 보고서](docs/step39_case_evidence.md)에 있습니다. 커밋·push하지 않았습니다.

## 38단계 Core Loop UX / 구조 감사

새 Gameplay 기능 없이 현재 동선·클릭 수·정보 밀도·추리 효용·State/표시 경계를 감사했습니다.
정상 Case의 격리 확정은 최소 5클릭, 다음 Case 인계는 6클릭이며,
환경 변화·CCTV 재확인·조건 실험·가설 생성/편집을 포함한 검증 동선은 19클릭입니다.
현재 테스트 콘텐츠의 단서→Room 판단 연결과 조건 관찰의 시점별 접근성은 후속 검증 과제로 보고했습니다.
Main 상단과 Experiment 재진입의 잘못된 안내 문구만 수정했습니다.
요청한 85개 종료 항목, UX Audit/Journey 표, 구조 수치와 검증 결과는
[Step38 감사 보고서](docs/step38_core_loop_audit.md)에 있습니다. 커밋·push는 하지 않았습니다.

## 37단계 읽기 전용 Research Archive

기존 프로젝트를 확장했습니다. 작업 전 HEAD는 `4295dd1103d162edc37ca180ccab7ec085f3d483`,
브랜치는 `master`(`origin/main` 추적), working tree는 깨끗했습니다.
실제 제품 파일 93개와 이전 검증 GDScript/PowerShell 소스 1,793개를 조사하고 SHA256 기준선을 남겼습니다.
Main/Stage/두 session State/Runtime/CaseData/ResearchEntry/현재 Log Snapshot·Scene·Script,
case_sequence와 handoff, authored validation/discovery/fallback, Log return-stage,
Recheck CCTV와 active/stale guard, Hypothesis request와 기존 검증·README·설정을 확인했습니다.

Archive는 **이미 ArchiveState에 보존된 authored Research ID와 해당 Case의 플레이어 메모**만 조회합니다.
과거 Runtime, hidden resolution, 후보/threshold/정답 Room/최종 결과/원인 Incident를 조회하지 않습니다.
현재 환경과 공개된 authored Research를 자동 연결하지 않으며, 읽기는 discovery/merge/opportunity가 아닙니다.

### UI와 탐색

```text
Main
  정상 View → ResearchLogView → ResearchArchiveListView → ResearchArchiveDetailView
                    ↑                 ↑                         │
                    └── Back ─────────┘──────── Back ────────────┘
  ResearchLogView Back → 기존 _research_log_return_stage의 View (discover=false)
```

기존 Stage 값 뒤에 `RESEARCH_ARCHIVE_LIST`, `RESEARCH_ARCHIVE_DETAIL`을 추가했습니다.
두 Scene의 list/detail 책임과 Main 승인 경계를 분리하는 편이 기존 _show_view/active View 패턴과 자연스럽습니다.
기존 Stage 숫자/정규 next-stage/RESEARCH_LOG_STAGES는 바꾸지 않았습니다. Manager/State Framework는 없습니다.
Research Log 안에만 Open Research Archive 버튼을 추가했습니다. 기존 Research/Notebook/Back을 보존했습니다.
Main이 모든 Open/Case 선택/Back을 승인하고 View는 ID signal과 표시 Snapshot만 사용합니다.
List→Log는 return-stage를 소비하지 않고, 마지막 Log→원래 View에서만 기존 정책대로 clear합니다.
Recheck CCTV의 복귀 문맥도 기존 변수에 그대로 남습니다. 저장하지 않은 Notebook draft와 미확정 선택은
기존 View 재생성 정책대로 사라집니다. 새로운 draft/selection 보존 시스템은 없습니다.

List Scene은 900 폭/440 높이 ScrollContainer 안에 동적 Case 행을 표시합니다.
Detail Scene은 440+20+440 두 열에 ARCHIVED RESEARCH / WORKING HYPOTHESES와 각각 360 높이 Scroll을 표시합니다.
Main의 두 보조 ViewHost는 660이며, 긴 Case 이름/Research/500자 메모에 wrap과 scroll을 사용합니다.
Archive Detail에는 입력창/Edit/Delete가 없고 Back만 있습니다. 최종 디자인은 하지 않았습니다.

### 데이터와 승인

- `ArchiveListView.CaseSummary extends RefCounted`: case_id, display_name, research_count, hypothesis_count, available.
- `ArchiveListView.Snapshot extends RefCounted`: 작성된 CaseSummary 배열.
- `ArchiveDetailView.ResearchEntry extends RefCounted`: archived entry_id와 표시 category/source_id/title/body_text.
- `ArchiveDetailView.Snapshot extends RefCounted`: case_id, display_name, research_entries, 복사된 hypotheses.

각 Open에서 Snapshot을 재생성합니다. 영구 캐시/Resource/새 session 저장소가 아닙니다.
Case 목록은 ResearchArchiveState.get_archived_case_ids의 최초 Archive 순서이고,
Research는 get_discovered_entry_ids의 실제 merge/발견 순서입니다. Resource 배열 순서로 정렬하지 않습니다.
WorkingHypothesisState getter의 deep copy를 받아 작성 순서와 stable ID를 그대로 표시합니다.

Main은 case_sequence에서 case_id가 정확히 한 번 존재할 때만 CaseData를 반환합니다.
sequence가 빈 단일 Case debug Main에서만 일치하는 current_case를 사용합니다.
누락/중복이면 warning, 목록에 해당 Case ID와 [Unavailable] 및 수를 표시하고 Open을 비활성화합니다.
직접 Case signal을 보내도 같은 lookup으로 거부합니다. 다른 Case를 대신 사용하지 않습니다.

기존 _get_valid_research_entries에 선택적 CaseData 인자만 추가해 같은 ID/SourceKind/source mapping
중복/누락 검증을 Archive에도 적용했습니다. 기존 무인자 호출은 current_case로 동작합니다.
Main의 작은 _research_category가 기존 SourceKind 의미를 사용하며 Log의 authored 행과 Archive가 함께 씁니다.
PROFILE / OBSERVATION(CCTV·교란·CCTV 조건 관찰) / EXPERIMENT(기본·조건 관찰) / CONTAINMENT / INCIDENT입니다.
Research entry_id를 해당 Case의 유효 authored 목록에서 정확히 찾아 문자열만 복사합니다.
없거나 duplicate/invalid mapping이면 warning과 [Unavailable Research Entry] + 원래 archived entry_id를 표시합니다.
비슷한 항목으로 대체하거나 첫 duplicate를 고르지 않습니다.

Archive Open은 RESEARCH_LOG Stage/active·visible View/current Case·Runtime/Log Case ID/정상 return-stage를 검증합니다.
Case Open은 Archive List Stage/active·visible View/실제 archived case_id/유일 CaseData mapping을 검증합니다.
Back도 Stage/active·visible View를 검증합니다. stale/detached/hidden View와 forged ID는 UI·State를 바꾸지 못합니다.
Archive에는 gameplay 신호 처리/Timer/merge/discovery/가설 CRUD 경로가 없습니다.

### fallback 보존의 현재 한계

ResearchArchiveState는 **유효 authored entry_id만** 저장합니다. handoff와 기존 debug RESULT merge 정책을 유지했습니다.
현재 Log에서 보이는 derived Profile/CCTV/Experiment/Containment/Monitoring/실패 후속 fallback body는
그 문구 자체가 ArchiveState에 저장되지 않습니다. 특히 현재 Case02의 CCTV/Experiment02/Room02 fallback과
debug Monitoring stage 기록은 ID/body snapshot 없이 과거 Archive에서 재구성할 수 없습니다.
현재 authored condition observation/교란 reaction은 실제 발견 후 merge된 ID가 있을 때 조회할 수 있습니다.
이번 단계에서는 synthetic ID, 가짜 ResearchEntry, runtime body snapshot을 추가하지 않았습니다.
State에 없는 현재 Case와 메모만 존재하는 Case도 목록에 넣지 않습니다.

### 요청한 84개 항목 보고

| 번호 | 항목 | 구현 및 검증 |
| --- | --- | --- |
| 1 | Git 상태 | HEAD 4295dd1, master→origin/main, 작업 전 변경 0. |
| 2 | 전체 UI | Log→Case List→Case Detail, 연구/메모 읽기 전용. |
| 3 | Stage | enum 뒤에 보조 Stage 두 개 추가, 기존 값/정규 route 보존. |
| 4 | Main 탐색 | _show_view와 request guard로 생성/전환/Back 관리. |
| 5 | Log Open | 기존 Log에만 Open Research Archive 추가. |
| 6 | Back | Detail→List→Log→원래 View, 마지막 단계에서만 return-stage 소비. |
| 7 | Return-stage | Archive 진입·상세 선택 동안 기존 _research_log_return_stage 보존. |
| 8 | List Source | get_archived_case_ids만 사용. CaseData 목록을 그대로 노출하지 않음. |
| 9 | Case 순서 | State의 최초 Archive 순서 유지, 현재/미획득 Case 추가 없음. |
| 10 | Identity | Case signal은 case_id, 배열 index를 식별자로 사용하지 않음. |
| 11 | 이름 | 해당 CaseData.display_name과 case_id, 다른 Case 이름 fallback 없음. |
| 12 | Missing Case | warning/[Unavailable]/해당 ID·개수/disabled Open, 직접 요청 거부. |
| 13 | Duplicate Case | 정확히 하나만 허용, first-match 미사용. |
| 14 | List Snapshot | typed CaseSummary와 Snapshot RefCounted. 개수/조회 가능 여부만 표시. |
| 15 | Detail Snapshot | Case ID/이름, 새 표시 ResearchEntry 배열, 복사된 hypotheses. |
| 16 | 표시 데이터 | Resource/Runtime/Archive replacement 아님. Snapshot mutation 격리 검증. |
| 17 | Archive ID | 각 Case get_discovered_entry_ids를 읽기만 함. |
| 18 | 재구성 | 같은 Case의 valid authored entry_id로만 문자열 복사. |
| 19 | ID 검증 | 기존 ID/source_kind/source_id/duplicate 검증 재사용. |
| 20 | Missing Entry | warning + Unavailable Research Entry + 원래 archived entry_id. |
| 21 | Duplicate Entry | ID/source mapping 중복 모두 제외, 첫 항목 대신 사용하지 않음. |
| 22 | Research 순서 | archived IDs 순서 그대로, Resource 배열 sort 없음. |
| 23 | Category | PROFILE/OBSERVATION/EXPERIMENT/CONTAINMENT/INCIDENT 기존 의미. |
| 24 | SourceKind | 작은 Main 변환 함수를 authored Log/Archive가 함께 사용. enum/schema 변경 없음. |
| 25 | Authored | State에 실제 보존된 ID만 표시. 독립 fixture에서 모든 authored SourceKind 재구성 확인. |
| 26 | Fallback 한계 | ID 없는 derived body와 debug Monitoring 기록은 Archive에 없음. 위 설명 참조. |
| 27 | Synthetic 없음 | fake ID/ResearchEntry/body snapshot 추가 없음. |
| 28 | Hypothesis | WorkingHypothesisState.get_hypotheses(case_id) copy 사용. |
| 29 | 메모 순서 | 작성 순서/기존 stable ID 그대로. |
| 30 | Read-only | Detail에 TextEdit/Edit/Delete/request API 없음. |
| 31 | 메모 Empty | No working hypotheses recorded. |
| 32 | Hidden Resolution | Snapshot/renderer/builder가 Resolution를 조회하지 않음. |
| 33 | 결과 비노출 | Snapshot에 Monitoring/final_result 없음. 실제 실패 handoff 후 UI 누출 검사. |
| 34 | Room 평가 | 획득 authored Containment만 표시, correct/wrong 평가 덧붙이지 않음. |
| 35 | Candidate | 존재 여부/threshold/기회 수 표시 없음. 읽기 전후 상태·RNG 비교. |
| 36 | 원인 Incident | hidden Incident/source Case/failure 연결 문구 생성 없음. |
| 37 | 환경 Research | archived reaction/CCTV condition/Experiment condition entry_id 재구성 지원·검증. |
| 38 | 환경 격리 | 과거 CaseData와 archived ID만 사용, 현재 Runtime 환경을 조회하지 않음. 실제 활성 교란/Recheck 중 Archive의 Case01 IDs/State 격리 검증. |
| 39 | List UI | 이름/ID/Research 수/Hypotheses 수/Open/Back 동적 행. |
| 40 | Detail UI | Case header + 두 읽기 전용 Scroll 열 + Back. |
| 41 | Dynamic | Container에 배열 길이만큼 생성, 고정 콘텐츠 슬롯 없음. |
| 42 | 0/1/5/20 Case | 긴 이름 독립 fixture, 마지막 행 Open까지 scroll 접근·forged ID 거부. |
| 43 | 0/1/10/30 Research | 독립 Detail fixture, repeated/null setup 및 Scroll. |
| 44 | 긴 Research | 긴 title/body와 multiline wrap, 최소 높이/폭/enclosure 검사. |
| 45 | 긴 메모 | 20개 500자 multiline 메모 읽기 전용 wrap/scroll. |
| 46 | Open 경계 | Stage/active/visible/current Case+Runtime/Log Case ID/return-stage. |
| 47 | Detail 경계 | List Stage/active/visible/archived ID/unique mapping. |
| 48 | Forged ID | unarchived/current/fixture/임의 ID 요청 거부. |
| 49 | Stale | 이전 Log/List/Detail의 Open/Back/Select signal 차단, hidden/detached도 거부. |
| 50 | Read-only State | Runtime/Archive/Hypotheses/Pending/Resolution/Candidate/RNG 전후 비교. |
| 51 | 발견 없음 | observed/discovered arrays와 ResearchArchive 내용 불변. |
| 52 | Opportunity | processed opportunity/후보/threshold/RNG 불변. |
| 53 | 교란 없음 | 새 Timer/trigger 없음, 기존 후보가 있는 Archive 탐색 중 상태 불변. |
| 54 | Experiment 왕복 | Log→Archive→Log→Back 후 Experiment 복귀, 미확정 선택 초기화 정책 유지. 활성 환경 Recheck CCTV→Log→Archive 왕복도 Experiment 복귀 확인. |
| 55 | Monitoring | 기존 Log 접근 불허 정책 유지, 직접 Archive 버튼 없음. |
| 56 | 실제 handoff | Case01 Room 확정과 Next:CASE 후 Case02 Log에서 Case01 Archive 노출. |
| 57 | Case01 메모 | handoff 이전 메모 수정, 이후 Detail에서 최신 text 확인. |
| 58 | 현재 Case 제외 | Case02 메모가 있어도 미archived Case02는 List/Case01 Detail에 없음. |
| 59 | Incremental | 기존 IDs 뒤 추가 merge 후 Snapshot 재생성에 최신 목록/순서 반영. |
| 60 | 최신 text | 메모 Source of Truth는 WorkingHypothesisState, cache 없음. |
| 61 | 편집 없음 | Archive Snapshot/Scene/Script에 Hypothesis mutation signal 없음. |
| 62 | 재생성 | List/Detail 진입 및 Back마다 현재 session State에서 생성. |
| 63 | CaseData | 변경 없음, runtime 필드/Archive flag 추가 없음. |
| 64 | ResearchEntry | 변경 없음, 현재 ID/SourceKind/title/body만 사용. |
| 65 | Resource | 원본 Case01/02 deep content와 모든 Resource 해시 불변. |
| 66 | Session | 모든 기존 State 코드/identity/records 불변. |
| 67 | Archive Empty | No archived research available., null Snapshot 안전. |
| 68 | Log 회귀 | 기존 current authored/fallback/discovery 순서/Back/Recheck 검사 유지. |
| 69 | Hypothesis 회귀 | Step36 Add/Edit/Delete/취소/500자/Case 분리/stale/reset 검사를 그대로 실행. |
| 70 | Resolution 회귀 | Step32 이후 숨겨진 판정 경계 유지. |
| 71 | Candidate 회귀 | 숨겨진 후보/threshold/opportunity 정책 유지. |
| 72 | Disturbance 회귀 | overlay/dismiss/context/환경 요약/late signal 검사 유지. |
| 73 | CCTV 조건 | 실제 표시/발견/Recheck/OpenBack/환경 reset 회귀 유지. |
| 74 | Experiment 조건 | 실제 실행 시 snapshot/후발 환경 소급 없음/limit/history 회귀 유지. |
| 75 | Archive State | merge/dedup/Case 순서/getter/reset/Runtime 독립성 기존 검사 유지. |
| 76 | Debug Monitoring | 독립 debug Main playback/SUCCESS/FAILURE/UNDEFINED 검사 유지. |
| 77 | Failure Debug | Incident/Broadcast/확정 Option/IncidentResult/Result와 invalid fixtures 유지. |
| 78 | 해상도 | 1920×1080/1280×720/1024×768 창에서 List/Detail/Log wrap·scroll. 기존 canvas_items/keep/resizable 보존. GPU Archive 캡처 57개 중 대표 8개 육안 확인. 4:3 창의 viewport capture는 기존 keep으로 1024×576. |
| 79 | 파싱/실행 | Godot 4.7.1 official.a13da4feb: 186개 검사(Headless 111 / GPU 75) 통과. 제품 GDScript 38개 check-only, 최종 editor import와 실제 Main/Archive 정상 실행 오류·경고 0. 의도적 invalid fixture의 기존/신규 예상 경고 수 일치. 카테고리 및 Stage 테스트 사본 수정 후 전체 재실행 완료. |
| 80 | 문제/해결 | 긴 Case 이름 독립 Detail fixture에서 높이 초과 발견. 새 Detail Scroll 높이 400→360으로 조정 후 enclosure/wrap 검사 통과. 기존 Experiment Condition Observation category가 EXPERIMENT임을 회귀 검사로 확인하여 공유 변환을 수정. 기존 Stage 수를 고정 가정한 회귀 사본의 제목 매핑에 Archive 두 항목을 추가했고 기존 assertions와 원본 테스트는 유지. 문서 변경 범위 검사에서 과거 보고 한 문장에 새 설명이 붙은 것을 찾아 원래대로 복구. 재검사로 역사 보고 보존 확인. 기존 파일 전면 재작성 없음. |
| 81 | 변경 파일 | 기존 4개 수정/새 6개/삭제 0. 아래 파일별 책임 참조. |
| 82 | 미커밋 보존 | 시작 변경 0. 기존 제품 89개·이전 검증 소스 1,793개/이전 README 보고 보존. commit/push 없음. |
| 83 | 제외 기능 | Archive 편집/search/filter/sorting/tagging/evidence/fallback snapshot/SaveLoad/Campaign/Case03/Severity/MAJOR/자동 Broadcast/Manager/Singleton/EventBus/최종 UI 없음. |
| 84 | 다음 단계 | 실제 handoff 후 과거 연구 조회의 가독성 검토. fallback 보존이 필요하면 synthetic ID 대신 안정된 provenance/저장 정책을 별도 설계. 결과 공개·정답 평가와 자동 연결하지 않음. |

### 실제 변경 파일과 책임

생성:
- `scripts/views/research_archive_list_view.gd` + `.uid`: 표시 Snapshot/동적 Case 행/ID 선택 request.
- `scripts/views/research_archive_detail_view.gd` + `.uid`: 독립 표시 Snapshot/읽기 전용 연구·메모 renderer.
- `scenes/views/research_archive_list_view.tscn`: List Scroll/Open/Back.
- `scenes/views/research_archive_detail_view.tscn`: Research/메모 두 Scroll 열/Back.

수정:
- `scripts/main/main.gd`: 보조 Stage/Scene 연결, Main request 승인, Case lookup/Snapshot 생성, 기존 authored validation/category 재사용.
- `scripts/views/research_log_view.gd`: Archive request signal과 버튼 연결만 추가, 기존 Research/Notebook 함수 유지.
- `scenes/views/research_log_view.tscn`: Open Research Archive 버튼만 추가.
- `README.md`: 현재 사용 설명과 84개 항목 보고.

project.godot/Main Scene/Case .tres/모든 Data/기존 여섯 State/다른 View는 변경하지 않았습니다.
검증 자료는 Git 제외된 `.godot/verification/step37/`의 신규 Archive tests와 이전 tests의 사본,
소스 기준선, log/pass certificate, 캡처, scope audit에 남깁니다. 제품은 이를 참조하지 않습니다.
기존 테스트 소스는 수정하지 않았습니다. 커밋과 push는 하지 않았습니다.

## 36단계 플레이어 작성 Working Hypothesis Notebook

기존 프로젝트를 확장했습니다. 작업 전 HEAD는 `7e4dfe4542fb3bfe439098260b66804733115f01`,
브랜치는 `master`(`origin/main` 추적), Git working tree는 깨끗했습니다.
제품 파일 91개와 기존 검증 GDScript/PowerShell 소스 1,604개를 조사하고 SHA256 기준선을 남겼습니다.
Main/Runtime/Archive/ResearchLog Snapshot·Script·Scene/ResearchEntry와 발견 경계,
실제 Case01→02 sequence와 Runtime 교체, 네 정상 화면의 Log 진입, CCTV Recheck,
stale/modal 방어, 기존 테스트·README·프로젝트 설정을 확인했습니다.

가설은 **플레이어가 작성한 개인 메모**입니다. 공식 ResearchEntry, 게임 판정, 정답 후보가 아닙니다.
추천/자동 생성/평가/확률/정답 일치/환경 또는 Evidence 자동 연결은 없습니다.
서로 모순되는 생각, 임의 단어·기호·욕설·BBCode 같은 문자열도 내용 그대로 기록합니다.
Label/TextEdit의 plain text로 표시하며 문자열의 의미를 해석하지 않습니다.
Step34~35의 condition observations are supporting/optional evidence 원칙도 유지합니다.

`WorkingHypothesisState`는 Main이 생성/소유하는 세션 `RefCounted`입니다.
CaseRuntimeState/ResearchArchiveState에 넣지 않았습니다. Runtime 종료/reset/교체 후에도
메모가 남아야 하고 Research 발견 ID와는 다른 데이터이기 때문입니다.
`Dictionary[String, Array]`에 Case ID별 작성 순서의 `{hypothesis_id, text}`만 저장합니다.
각 Case의 단조 증가 counter로 `HYP_001`, `HYP_002` 등을 발급합니다. Array index는 identity가 아닙니다.
Delete, clear_case, clear_all은 record만 지우고 counter는 유지하므로 같은 세션에서 ID를 재사용하지 않습니다.
새 Main/State 생성으로 새 세션이 시작됩니다. 다른 Case의 같은 ID는 Case ID와 함께 구분합니다.

API는 `add_hypothesis(case_id, text) → String`(실패 시 빈 ID),
`update_hypothesis(...) → bool`, `remove_hypothesis(...) → bool`,
`get_hypotheses(case_id) → Array[Dictionary]`, `clear_case(case_id)`, `clear_all()` 여섯 개입니다.
Getter는 각 record를 deep copy합니다. 없는 Case는 empty Array이며 존재하지 않는 ID 수정/삭제는 false입니다.
Add/Update는 앞뒤 whitespace만 제거하고 빈/whitespace-only/500자 초과 입력은 거부합니다.
내부 newline/기호/내용은 보존하고 자동 수정/조용한 truncation은 없습니다.
`WorkingHypothesisState.MAX_TEXT_LENGTH = 500` 한 곳에서 조절합니다. **prototype UI safety limit**이며 밸런스가 아닙니다.
Godot String.length 기준으로 Unicode 문자 길이를 검사하고 500개 emoji도 테스트했습니다.

```text
WorkingHypothesisState (세션/Case ID별 실제 메모)
  → Main._build_research_log_snapshot()
  → 기존 ResearchLogView.Snapshot + 복사된 hypotheses / UI max length
  → View: 기존 Research 목록 옆 WORKING HYPOTHESES
      TextEdit → Add / Edit → Update / Cancel Edit / Delete
  → Case ID + text / stable hypothesis ID를 담은 request signal
  → Main: RESEARCH_LOG Stage + active/visible View + current Case/Runtime + View Case ID 검증
  → State API 승인
  → 복사된 갱신 목록만 View에 전달, Research 영역과 gameplay는 건드리지 않음
```

ResearchLogView는 State instance를 찾거나 읽지 않습니다. Snapshot과 Main의 승인 응답만 받습니다.
Add/Update 성공 시 입력과 edit ID를 비우고 목록을 즉시 갱신합니다.
Edit는 현재 ID의 text를 같은 multiline TextEdit로 불러오고 focus합니다. Update는 ID와 위치를 유지합니다.
Cancel Edit는 임시 입력만 버립니다. Delete는 confirmation modal 없이 즉시 요청하며 다른 메모의 draft는 보존합니다.
실패한 요청은 입력을 유지하고 저장되지 않았다는 중립 메시지를 표시합니다. 입력의 정답성 평가가 아닙니다.
빈 목록에는 `No working hypotheses recorded.`를 표시합니다.
Back 시 저장하지 않은 draft는 View와 함께 사라지며, 승인된 메모는 세션 State에 유지됩니다.

Scene은 기존 Content 안에 HBox Workspace를 두어 왼쪽 기존 EntryScroll/EntryList와 오른쪽 Notebook을 함께 표시합니다.
기존 Research 행 생성·카테고리·문구·발견·정렬 코드는 유지합니다. 기존 900 폭을 440+20+440으로 나누고
Research Scroll 높이는 160→420으로 늘렸습니다. Notebook 목록은 높이 160 Scroll이며 모든 메모 Label은 wrap합니다.
TextEdit는 높이 96, soft wrap/multiline입니다. 길이 표시와 초과 안내를 제공하고 유효 입력만 Add/Update를 활성화합니다.
Research Log ViewHost만 660으로 확보했습니다. 다른 화면의 높이/게임 흐름/저장된 Main Scene/Stretch는 그대로입니다.
Enter는 TextEdit newline 입력, Escape는 기존 navigation shortcut이 없으므로 화면을 이동하지 않습니다.
새 키 바인딩, 자동 저장, 이벤트 처리기를 만들지 않았습니다. Log 입력·CRUD는 Gameplay Opportunity가 아닙니다.

### 요청한 82개 항목 보고

| 번호 | 확인 항목 | 구현 및 검증 결과 |
| --- | --- | --- |
| 1 | 작업 전 Git | 위 HEAD/브랜치, 미커밋 변경 0. 이번 작업에서 commit/push 없음. |
| 2 | State 구조 | Main 소유 RefCounted. Case별 Array/ID counter만, Manager/Resource/Autoload 아님. |
| 3 | 세션 범위 | 플레이어 메모를 Runtime 사실/Research 발견에서 분리하여 handoff 후에도 유지. |
| 4 | Case 분리 | Dictionary의 case_id 키, 다른 Case 목록을 현재 UI에 넘기지 않음. |
| 5 | ID 생성 | Case별 단조 counter → HYP_001 등. index identity 없음. |
| 6 | ID 재사용 | 삭제/clear_case/clear_all 후에도 counter 유지. 새 State만 새 세션. |
| 7 | Record | hypothesis_id/text 두 필드, 작성 순서는 Array 위치로 유지. gameplay 필드 없음. |
| 8 | API | add/update/remove/get/clear_case/clear_all 여섯 메서드, bool/빈 ID로 실패 반환. |
| 9 | Getter | Array 및 각 Dictionary deep copy, 외부 수정으로 원본 불변. |
| 10 | Whitespace | 앞뒤 strip_edges. 내부 newline/공백/내용 보존. empty/whitespace-only 거부. |
| 11 | 최대 길이 | MAX_TEXT_LENGTH=500 한 곳. UI/State 동일 reject 정책, truncate 없음, UI safety 명시. |
| 12 | Resource | 메모는 RefCounted만. .tres/CaseData/ResearchEntry 변경 없음. |
| 13 | Main 소유 | _ready에서 한 번 생성, handoff/Runtime reset/Log 재생성으로 교체하지 않음. |
| 14 | Log 통합 | 기존 Stage/Snapshot에 hypotheses 복사 데이터, 별도 WORKING HYPOTHESES Section. |
| 15 | 기존 Research | EntryList 생성/내용 그대로, 옆 영역에서 계속 wrap/scroll 열람 가능. |
| 16 | 입력 UI | 여러 문장·newline을 담기 위한 multiline/soft-wrap TextEdit. |
| 17 | Add | 승인된 현재 Case에 추가 → 목록 즉시 refresh → 입력/편집 ID 초기화. |
| 18 | Edit | 같은 ID의 text 로드/focus → Update로 text만 수정. Cancel은 State 변경 없음. |
| 19 | Delete | 현재 Case/ID 삭제, 즉시 refresh. confirmation modal 없음, 다른 연구/gameplay 불변. |
| 20 | Empty | No working hypotheses recorded. 메모 없는 Case도 입력 가능. |
| 21 | 순서 | 작성 순서, 자동 알파벳 정렬 없음. |
| 22 | Edit 순서 | 기존 Dictionary text만 갱신, ID/상대 위치 유지. |
| 23 | Delete 순서 | 해당 record만 제거, 남은 상대 순서 유지. |
| 24 | View 재생성 | queue_free/recreate해도 State 기록 유지. 임시 미저장 draft만 사라짐. |
| 25 | Open/Back | Add → Back → Open에서 같은 ID/text 확인. |
| 26 | 승인 경계 | Main의 _can_edit_hypotheses에서 Stage/active/visible/Case Runtime/Case ID/View ID 검증. |
| 27 | Active View | 기존 _is_active_view를 사용, detached/queued/modal 상태 거부. |
| 28 | Stale 방어 | Back/교체/handoff 이전 View의 Add/Update/Delete 늦은 signal 무효. |
| 29 | 현재 Case UI | Snapshot/current_case의 notes만 표시/편집, 다른 Case 조회 UI 없음. |
| 30 | Case01/02 | handoff 후 Case01 State는 유지, Case02 UI empty로 시작, Case02 작성 후 독립 목록. |
| 31 | Runtime reset | reset 및 new instance 후 기존 Case02 notes 유지. Runtime 코드 변경 없음. |
| 32 | Archive | Archive reset은 notes 유지, notes clear는 Archive 유지. |
| 33 | Pending | CRUD 전후 Pending instance/Case/Room 기록 불변. |
| 34 | Resolution | CRUD 전후 hidden resolution 기록 불변. |
| 35 | Candidate | CRUD 전후 candidate/threshold/기회 수 불변. |
| 36 | Gameplay | Room/Outcome/limit/Incident/Disturbance/Research/RNG/기회 상태 전후 비교. 변경 없음. |
| 37 | 평가 없음 | 맞음/틀림/정답 접근성/Containment 일치 feedback 없음. |
| 38 | 자동 가설 없음 | Research 발견을 notes add/update와 연결하지 않음. |
| 39 | Preset 없음 | 자유 TextEdit만, LIGHT/SOUND 같은 후보 선택 UI/Resource 필드 없음. |
| 40 | 환경 연결 없음 | 교란/조건 관찰이 notes를 생성/수정/삭제하지 않음. |
| 41 | Confidence | 확률/slider/score/status/AI 평가 없음. |
| 42 | Evidence | entry_id/source_id 연결/pin/reference 필드/코드 없음. |
| 43 | 모순 허용 | 빛이 원인/무관하다는 메모 동시 저장 허용. 임의 기호·BBCode·욕설 문자열도 plain text 유지. |
| 44 | Research 발견 | hypothesis_id를 discovery/observed source에 넣지 않음. 새 SourceKind 없음. |
| 45 | Archive merge | notes를 ResearchArchive에 merge하지 않음. 기존 discovered entry ID 정책 그대로. |
| 46 | 0개 UI | empty label, 기존 연구 목록/입력/버튼 정상. |
| 47 | 1개 UI | stable ID/text/Edit/Delete 표시와 Back/Open 유지. |
| 48 | 5개 UI | 순서/wrap/목록 scroll/마지막 메모 Edit/Delete. |
| 49 | 20개 UI | 독립 fixture 최대 길이 20행; 마지막 행 액션까지 scroll 접근. 실제 콘텐츠 추가 없음. |
| 50 | 긴 텍스트 | 500자 Unicode 및 multiline, wrap/scroll/edit/delete 안전. 501자는 거부. |
| 51 | Keyboard | TextEdit focus 후 실제 Enter/Escape key event. Enter newline, navigation/save 미발생. |
| 52 | Opportunity 없음 | 입력/CRUD/Log Open/Back 중 processed opportunity/Candidate/RNG 불변. |
| 53 | Save/Load | 세션 메모리만, 디스크 저장/게임 재시작 복원 없음. |
| 54 | 미래 Archive | get_hypotheses(case_id)로 과거 Case notes 조회 가능, Archive 화면 미구현. |
| 55 | Identity | case_id + hypothesis_id 쌍. 다른 Case의 HYP_001 허용/분리 검증. |
| 56 | Invalid Case | empty/공백/현재 Case 아닌 UI 요청 거부, 기존 다른 Case notes 보존. |
| 57 | Invalid ID | nonexistent/empty/공백 Update/Delete false, 다른 record 불변. |
| 58 | Invalid text | empty/공백/newline-only add/update 거부, text 자동 truncation 없음. |
| 59 | Duplicate ID | 200개 독립 생성 fixture에서 uniqueness 확인, 삭제/clear 후 재사용 없음. |
| 60 | Max length | 500개 emoji/500자 일반 텍스트 허용, 501자 거부. trim 후 검사 일관성. |
| 61 | Add 테스트 | 요청 A 문구 저장/앞뒤 정리/입력 clear/현재 Case 즉시 표시. |
| 62 | Edit 테스트 | 요청 B 문구로 same ID/order 수정, Cancel draft 불저장. |
| 63 | Delete 테스트 | 중간 메모 삭제 후 상대 순서 보존, 연구/Archive/gameplay 불변. |
| 64 | Handoff 테스트 | 실제 Case01→02 정상 handoff, Case01 note State 유지, 새 Case UI 미표시. |
| 65 | Case02 테스트 | 새 note를 Case02에만 기록, Case01 목록 그대로. |
| 66 | Runtime 재생성 | Case02 Runtime reset/new + Archive reset 후 notes 유지. |
| 67 | Stale 테스트 | queued old Log의 이전 Case/새 Case request 모두 차단. hidden/detached/mismatch도 거부. |
| 68 | Research Log 회귀 | Profile/CCTV/Experiment/Containment/Reaction/CCTV 조건/EXP 조건/authored/fallback/discovery order/Open Back 유지. |
| 69 | Hidden Resolution | 기존 handoff/Pending/Outcome/한 번 판정/Failure Candidate 회귀, 코드 변경 없음. |
| 70 | Disturbance | 기존 opportunity/modal/input-block/Dismiss/Active Environment/Case 반응 회귀. |
| 71 | CCTV 조건 | Recheck/Back/조건 관찰 실제 확인/순서/제한/Research 회귀. 구현 파일 변경 없음. |
| 72 | EXP 조건 | 실행 당시 ID snapshot/Base 유지/무료 재실행 없음/no retroactive/다음 실험 영향 회귀. |
| 73 | ResearchArchive | 기존 Case ID+entry ID merge/dedup/유효 발견/reset 분리 회귀. |
| 74 | Monitoring | 독립 debug Main의 playback/SUCCESS/FAILURE/UNDEFINED 회귀, 정상 Timer 추가 없음. |
| 75 | Failure debug | Incident/Broadcast 선택·확정/IncidentResult/Result/잘못된 매핑/미확정 진행 차단 유지. |
| 76 | 해상도/Stretch | 1920×1080, 1280×720, 1024×768 창; canvas_items/keep/resizable 및 1920×1080 논리 UI 보존. GPU 캡처 27개 중 empty/1/5/20 및 마지막 액션 대표 7개 육안 확인. 1024×768의 viewport texture는 비율 유지로 1024×576. |
| 77 | 파싱/실행 | Godot 4.7.1 official.a13da4feb: 176개 검사(Headless 105 / GPU 71) 통과. 제품 GDScript 36개 check-only, 최종 editor import와 실제 Main/Notebook 실행은 오류·경고 0. 의도적 invalid fixture의 기존 예상 경고 수도 일치. null Snapshot 오류 수정 후 전체 재실행 완료. |
| 78 | 문제/해결 | 자동 UI 입력 테스트에서 TextEdit.text setter와 사용자 text_changed를 구분해 수정. Scroll 밖 Delete를 클릭하던 fixture는 실제 scroll 후 클릭으로 수정. 동적 Main Archive fixture는 typed String ID 배열로 수정. 기존 독립 Research Log fixture의 높이 360을 현재 Main과 같은 660으로 조정했고 기존 레이아웃 assertions는 유지. null Snapshot 회귀에서 typed Array에 untyped 빈 Array를 대입하는 런타임 오류를 발견해 clear 후 유효 Snapshot만 복사하도록 수정. |
| 79 | 변경 파일 | 아래 기존 4개 수정/새 2개/삭제 0, git diff --check 통과. |
| 80 | 미커밋 보존 | 시작 시 변경 0. 기존 제품 87개와 이전 검증 소스 1,604개 byte-identical. commit/push 없음. |
| 81 | 제외 기능 | 추천/preset/정답평가/confidence/AI/evidence/pin/Archive UI/SaveLoad/Severity/MAJOR/Campaign/Case03/자동 Broadcast/Manager/Singleton/EventBus/최종 UI 없음. |
| 82 | 다음 단계 | 자유 메모 작성 흐름과 가독성을 먼저 사용 검토. 향후 Evidence 연결이 필요하면 authored/fallback을 모두 식별하는 정책부터 설계하고, 가설 평가·정답 시스템에는 자동 연결하지 않음. |

### 변경 파일과 최종 구조

생성:
- `scripts/runtime/working_hypothesis_state.gd`: Case별 session records와 여섯 API.
- `scripts/runtime/working_hypothesis_state.gd.uid`: Godot 생성 stable UID.

수정:
- `scripts/main/main.gd`: State 소유/Snapshot 복사/세 request 승인/Log 영역 높이.
- `scripts/views/research_log_view.gd`: 기존 Snapshot에 표시 데이터 추가, TextEdit/목록/CRUD request/승인 응답.
- `scenes/views/research_log_view.tscn`: 기존 EntryScroll 옆 Notebook, multiline input/버튼/상태/empty/목록 Scroll.
- `README.md`: 현재 설명과 82개 항목 보고.

삭제 없음. project.godot/Main Scene/두 Case .tres/모든 Data Resource/기존 다섯 State와 다른 View는 보존했습니다.
기존 Research 행 생성과 공개/정렬/발견/Archive 함수는 유지하며 Main의 승인 request 세 개와 공통 guard만 추가했습니다.
기존 Research Snapshot과 View API는 기본 empty notes 값을 가지므로 기존 standalone/debug 검사와 호환됩니다.

검증 소스/로그/캡처/baseline/pass certificate/scope audit는 `.godot/verification/step36/`에 남겼습니다.
게임은 이 자료를 참조하지 않고 `.godot/` Git 제외 설정도 그대로입니다.
신규 `hypothesis_state_validation.gd`, `hypothesis_validation.gd`와 기존 검증 사본을 사용했습니다.
기존 검증 소스에는 수정이 없으며, 새 정상 Stage나 콘텐츠 Resource도 추가하지 않았습니다.


## 35단계 실행 당시 환경에 따른 Experiment 추가 관찰

기존 프로젝트를 확장했습니다. 작업 전 HEAD는 `a540260a40aad48fa749bdb28bf0c6b96fc208cf`,
브랜치는 `master`(`origin/main` 추적), Git working tree는 깨끗했습니다.
제품 파일 89개, 이전 검증 GDScript/PowerShell 소스 1,418개를 조사하고 SHA256 기준선을 남겼습니다.
실제 Main, CaseRuntimeState, 모든 환경/관찰/실험/Research Resource, 두 Case, 실행 승인·횟수·이력,
Log Snapshot/발견/Archive, Step33 환경 표시, Step34 Recheck, 기존 검증 코드와 설정을 확인했습니다.

**condition observations are supporting/optional evidence**.
환경 추가 관찰은 선택적 보조 증거입니다. 이미 사용한 실험을 환경 발생 후 다시 실행할 수 없으므로
필수 정답 단서로 설계하지 않습니다. 기존 Base result, 실험 사용 수, 정답 Room/Outcome은 바꾸지 않습니다.
이 원칙을 신규 테스트와 이번 회귀 테스트 사본에도 기록했습니다. 이전 검증 소스는 수정하지 않았습니다.

새 `ExperimentConditionObservationData`는 다섯 필드만 가집니다.
`observation_id`, `experiment_id`, `disturbance_id`, `display_name`, `observation_text`입니다.
`CaseData.experiment_condition_observations: Array[ExperimentConditionObservationData]`에 배치했습니다.
기존 CCTV 추가 관찰/Reaction/Research와 같은 Case별 authored 콘텐츠이고,
ExperimentData의 기본 결과와 실행 의미를 보존하는 데 이 위치가 자연스럽습니다.
`experiment_id + disturbance_id`를 ID로 연결하고, Main에는 Power/Vent 등 콘텐츠별 분기가 없습니다.
이번 콘텐츠는 한 쌍에 관찰 하나입니다. 쌍 중복 또는 관찰 ID 중복/빈 필수 문구는 경고 후 생략합니다.

```text
현재 ExperimentView의 Run 요청
  → Main: 현재 Stage/View/가시성/Case Runtime/실험 ID/중복/limit 확인
  → 실행 시작 당시 active disturbance ID 순서로 matching authored 관찰 검색
  → ConditionSnapshot: 관찰 문구와 실행 당시 환경 설명을 문자열로 복사
  → Runtime: 기존 execution ID + 그 실행의 condition observation ID 배열 기록
  → ExperimentView: BASE EXPERIMENT RESULT 먼저, CONDITION OBSERVATION 뒤에 표시
  → 실제 표시된 ID: Base discovery → Condition A discovery → Condition B discovery
  → 기존 successful-execution Gameplay Opportunity
  → 필요하면 Disturbance Overlay (그 실험에는 소급 적용하지 않음)
```

실행 승인/표시는 동기적으로 처리하며 그 사이 `await`/환경 이벤트를 호출하지 않습니다.
일반 UI의 선택된 Resource가 실제 Case Resource와 일치할 때만 추가 관찰 Snapshot을 만듭니다.
기존 테스트/내부 ID-only 승인 호출의 Base 실행 정책은 호환성을 위해 유지합니다.
선택되지 않은 내부 ID-only 승인에는 추가 관찰 이력/발견을 기록하지 않습니다.
새 관찰 발견은 View가 반환한 실제 표시 ID에만 적용합니다. Resource 존재, 활성화, 선택으로는 발견하지 않습니다.

Runtime의 기존 `get_experiment_execution_history(): Array[String]`는 그대로입니다.
작은 `Dictionary[String, Array]`에 실험 ID별 실행 당시 관찰 ID만 저장합니다.
`try_record_experiment_execution(id, limit, condition_observation_ids = [])`의 세 번째 인자는 선택적이며
기존 두 인자 호출은 관찰 없는 정상 실행입니다. `get_experiment_condition_observation_ids(id)`는 복사본입니다.
중복/빈 관찰 ID를 제거하며 거부된 실행은 metadata도 기록하지 않습니다.
Resource/동적 상태/환경 수치/별도 실행 State를 저장하지 않고 reset으로 이 정보도 초기화합니다.

새 SourceKind는 맨 뒤의 `EXPERIMENT_CONDITION_OBSERVATION = 10`이며 기존 0~9 값은 유지합니다.
`source_id = observation_id`, 기존 authored `entry_id` 발견은 Base 실험과 독립적입니다.
Log는 실행 이력에 저장된 ID와 실제 노출 Source 기록을 사용하며 현재 active environment로 재계산하지 않습니다.
현재 환경이 제거되어도 과거 실행의 관찰은 유지됩니다. 유효 authored Research의 문구를 우선하고,
없거나 무효이면 그 관찰 Resource의 문구를 fallback으로 표시합니다. 가짜 entry_id는 없습니다.
카테고리는 기존 `EXPERIMENT`이며 제목에 `Condition Observation:`을 붙여 Base와 구분합니다.
Step34의 실제 노출 순서 정렬을 새 Kind에도 적용하여 Base → A → B 순서를 보존합니다.
Archive 구조/API는 바꾸지 않았고 기존 `(case_id, entry_id)` incremental merge에 포함됩니다.

Case02에는 `TEST_CASE02_EXP_01 + TEST_DIST_POWER_FAILURE`에 TEMP 관찰 하나와 authored Research 하나를 추가했습니다.
조명 중단 상태에서 자극 뒤 첫 움직임의 개시가 임시 정상 조명 reference보다 늦고 벽 접촉은 계속된다는 관찰입니다.
실험/환경 중 무엇이 지연의 원인인지 확정하지 않습니다. 기존 일반 TEMP 결과와 충돌하는 Creature trait도 없습니다.
어두움이 정답/안정 조건이라는 결론은 제시하지 않습니다. 정상 reference는 authored 테스트 문구이며
게임이 정상/교란 실행을 두 번 수행하거나 비교/분석/시뮬레이션하는 기능은 없습니다.
실제 ExperimentData, experiment_limit=2, 두 기존 실험, Room/Outcome, Case01 콘텐츠는 보존했습니다.

결과는 기존 오른쪽 Execution 영역의 높이 152 ScrollContainer 안에 Base/추가 관찰 순서로 놓았습니다.
문구는 wrap하고 여러 조건/긴 문구는 스크롤로 마지막 항목까지 볼 수 있습니다.
Step33 Active Environment는 현재 상태로 계속 표시하며 각 결과에도 **Active condition at execution**을 붙입니다.
두 개념을 분리하므로 이후 환경 refresh/Dismiss가 과거 결과를 교체하지 않습니다.
스크롤 추가 후 발견된 View 높이 초과를 해결하기 위해 Experiment의 ViewHost만 일반 400/조건 활성 580으로 조정했습니다.
기존 CCTV/Containment 높이 정책, 저장된 Main Scene, project.godot, Stretch 설정은 그대로입니다.

### 요청한 67개 항목 보고

| 번호 | 확인 항목 | 구현 및 검증 결과 |
| --- | --- | --- |
| 1 | 작업 전 Git | 위 HEAD/브랜치. 미커밋 변경 0, 이번 작업에서 commit/push 없음. |
| 2 | Observation Resource | 다섯 문자열 필드만 추가. 별도 condition rule/판정/보상 필드 없음. |
| 3 | 배치 위치 | CaseData authored 배열, CCTV/Reaction/Research와 일관성. Experiment 기본 결과에서 분리. |
| 4 | Stable ID | experiment_id + disturbance_id 조합, observation_id로 기록/Research 연결. index/콘텐츠별 분기 없음. |
| 5 | CaseData | typed experiment_condition_observations 배열 하나 추가. |
| 6 | ExperimentData | 스키마/문구/Research 관계 모두 수정 없음. |
| 7 | Base Result | 기존 ResultText를 먼저 표시. 조건 유무와 무관하게 원본 result_text 유지. |
| 8 | Condition 구조 | 별도 typed 표시 Snapshot과 동적 Label 목록. 현재 환경 설명과 관찰 문구 구분. |
| 9 | 실행 Snapshot | 실제 selected Resource + 승인 가능한 실행에 실행 시작 당시 active ID 목록을 순회해 값 복사. |
| 10 | 소급 변경 방지 | 실행 ID별 확정 관찰 ID만 저장. 환경 refresh/Overlay/Dismiss/Log에서 재계산 없음. |
| 11 | 무료 재실험 | once-per-case 거부 유지. 교란 후 사용한 실험 재요청은 이력/발견 불변. |
| 12 | Limit 유지 | Case01/02 모두 기존 2. refund/+1/-1 없음. 사용 수는 기존 실행 ID 이력으로 계산. |
| 13 | 보조 증거 | condition observations are supporting/optional evidence. README/테스트에 기록. 필수 단서/정답 요건 없음. |
| 14 | 정답 노출 | 움직임 개시/벽 접촉 사실만 제시. 정답 Room/LIGHT OFF 결론 없음. |
| 15 | 거짓 단서 | generic TEMP Base/Case02 벽 접촉 관찰과 모순되는 trait 없음. 테스트 reference는 authored 문구로 명시. |
| 16 | 여러 조건 | 같은 실험의 Power/Vent 독립 관찰을 모두 표시/기록. overwrite/조합 엔진 없음. |
| 17 | 표시 순서 | Runtime disturbance 최초 적용 순서. Resource 역순 배열과 동일 disturbance의 여러 쌍도 검증. |
| 18 | Missing mapping | Base만 표시, 환경 요약 유지. 다른 실험/조건의 관찰을 빌리지 않음. |
| 19 | Duplicate mapping | 한 쌍 1:1. 중복 쌍/중복 ID/빈 필수값은 warning 후 생략, first fallback 없음. |
| 20 | History 호환 | Array[String] execution history 그대로. 별도 작은 실험 ID → 관찰 ID 배열. |
| 21 | ID 기록 | 승인 시 복사/빈 ID 제거/중복 제거. Resource 저장 없음. Getter 수정으로 원본 변하지 않음. |
| 22 | 소급 계산 금지 | Log는 기록 ID 조회. 환경 제거/나중 발생/재진입으로 과거 목록 수정 없음. |
| 23 | SourceKind | EXPERIMENT_CONDITION_OBSERVATION=10 추가, 기존 0~9 보존. |
| 24 | Source ID | observation_id. authored entry_id는 별도 기존 ResearchEntry 정책. |
| 25 | Base 독립 | Base EXPERIMENT discovery와 Condition discovery를 순서대로 별도 호출. |
| 26 | 발견 시점 | 성공 승인 후 Base/Condition 실제 UI 표시 ID 확인. Resource/active/선택만으로 발견하지 않음. |
| 27 | 거부된 실행 | unknown/empty/used/limit/stale/hidden/modal/mismatch 요청의 metadata/Research 불변. |
| 28 | Authored Research | 기존 유효 entry_id/source pair 검증과 발견 정책. duplicate authored Research는 안전하게 거부. |
| 29 | Fallback | observation_text 사용, entry_id를 만들어 기록/Archive하지 않음. |
| 30 | Log category | 기존 EXPERIMENT, 제목 Condition Observation 접두사로 Base와 구분. 새 대형 category 없음. |
| 31 | 발견 순서 | 실제 source 노출 순서: Base → A → B. Log도 동일, 정렬은 Kind/ID 쌍 기준. |
| 32 | 환경 제거 후 이력 | active 배열 제거 fixture에서도 실행 ID/발견/Log 문구 유지. 현재 환경 UI만 사라짐. |
| 33 | Archive | 기존 case_id + 유효 discovered entry_id merge. API/Archive UI 추가 없음. |
| 34 | Case02 | EXP01 + 기존 Power 교란의 TEMP 관찰/Research 한 쌍 추가. |
| 35 | 정보 강도 | 자극 이후 첫 움직임 지연/벽 접촉 지속. 원인과 정답/성공 결과 해석 없음. |
| 36 | 교란 전 실행 | Base 표시/발견, condition IDs empty, Condition 미발견. |
| 37 | 교란 후 실행 | Base + 추가 관찰 표시, execution ID/condition ID/Research 정확히 기록. |
| 38 | 실행 후 교란 | 기존 Base UI/이력 유지, Condition Research 소급 발견 없음. |
| 39 | 재실행 거부 | 사용한 EXP 재요청/최대 사용 후 재요청 모두 불변. 무료 재실험 없음. |
| 40 | 여러 조건 테스트 | Power/Vent 관찰 모두 표시, 긴 문구/순서/중복 적용 ID 검증. |
| 41 | 일부 mapping | A/B active, A만 mapping → Base+A. 다른 EXP는 Base만. |
| 42 | Stale View | detached/queued/교체/Case handoff 이후 요청 차단. 현재 Runtime/Research/metadata 보존. |
| 43 | Overlay selection | 선택 유지한 동일 View Dismiss 후 Run → 현재 활성 환경 관찰. Overlay 중 Run은 차단. |
| 44 | 실행/Opportunity 순서 | 실행 당시 snapshot → 기록 → 실제 표시 → 발견 → 기존 opportunity. |
| 45 | 같은 action 교란 | CCTV 기회 1 + EXP 기회 2로 Power 발생 fixture: 해당 EXP 결과는 Base만. |
| 46 | 다음 실험 | 그 뒤 unused EXP02에 독립 matching fixture 관찰 추가 → 새 환경 관찰. 기존 EXP01 ID는 empty. |
| 47 | Result 호환 | Summary는 기존 ID history 그대로 사용. 기존 debug 결과 요약/정상 실행 회귀. 새 결과 항목 강제 추가 없음. |
| 48 | CCTV 독립 | 기존 Resource/Script/Scene 그대로. Recheck 발견은 Experiment metadata/사용 수를 변경하지 않음. |
| 49 | Resource 불변성 | 원본 Case01/02 전체 script 변수와 검증 전후 해시 확인. 테스트 변경은 deep duplicate fixture에만 적용. |
| 50 | Runtime 안전성 | 기록/Getter 복사, 거부 불변, reset, 다른 Runtime/Archive 독립성 검증. |
| 51 | Hidden Resolution | 정상 handoff의 Pending/Outcome ID/한 번 판정 정책 회귀. 구현 수정 없음. |
| 52 | Failure Candidate | threshold/FIFO/한 기회 한 이벤트/독립 session 기록 회귀. 구현 수정 없음. |
| 53 | Disturbance | overlay/modal/dismiss/반응/기회 중복 방지 회귀. 기존 이벤트 처리 함수 그대로. |
| 54 | Active Environment | 0/1/3/10 조건, 순서/wrap/scroll/복사/복귀/reset 회귀. Experiment 최소 높이만 조정. |
| 55 | CCTV Recheck | EXP/확정 Containment Back/Log 공개 조건/기회 증가 없음/실행 잠금 유지 회귀. |
| 56 | Research Log | authored/fallback/mixed/보안/Stage 공개/재진입/실제 순서 회귀. 화면 Script/Scene 수정 없음. |
| 57 | ResearchArchive | merge/dedup/Case ID 식별/fallback 가짜 ID 없음/reset 분리 회귀. 구현 수정 없음. |
| 58 | Case handoff | 실제 두 Case handoff에서 조건 Research merge, 새 Runtime metadata/active 초기화, stale 거부. |
| 59 | Monitoring debug | 기존 test-only debug Main으로 playback/time_offset/SUCCESS/FAILURE/UNDEFINED 회귀. 정상 Timer 경로 추가 없음. |
| 60 | Failure downstream | Incident/Broadcast 선택·확정/IncidentResult/Result/무효 ID/미확정 진행 차단 회귀. |
| 61 | 세 해상도/Stretch | 1920×1080, 1280×720, 1024×768; 기준 논리 UI 1920×1080와 canvas_items/keep/resizable 보존. |
| 62 | 파싱/실행 | Godot 4.7.1 공식 실행 파일: 167개 검사 통과(headless 100, Windows GPU 67), 35개 제품 GDScript check-only, 기본 Main 실행 및 최종 editor import 오류/경고 0. 잘못된 fixture 경고는 기대 수와 일치. 실제 F5 키는 누르지 않았으며 설정된 Main을 CLI로 실행함. |
| 63 | 문제 및 해결 | sandbox Windows 인증서 접근 오류는 정상 실행 환경 검사로 해결. 결과 Scroll로 인한 View 초과는 EXP 높이 400/580으로 해결. Fixture handoff 준비 때 이미 resolve된 Case01을 초기화해 독립 테스트를 올바르게 구성. 기존 GPU 회귀 캡처의 빈 출력 폴더 누락은 폴더 생성으로 해결하고 실패한 검사부터 재실행. |
| 64 | 실제 파일 | 아래 변경 목록. 무관 파일 변경/삭제 없음, git diff --check 통과. |
| 65 | 기존 미커밋 보존 | 시작 시 변경 0. 이전 제품 81개와 이전 검증 소스 1,418개 byte-identical. 커밋/push 하지 않음. |
| 66 | 제외 기능 | 무료 재실행/limit 변경/Base 교체/정답·Outcome 변경/compound rules/시뮬레이션/Severity/MAJOR/자동 Broadcast/시설 상태 Case 간 지속/Case03/Campaign/SaveLoad/Hypothesis/Archive UI/Manager/Singleton/RuleEngine 없음. |
| 67 | 다음 지점 | CaseData의 두 condition observation authored 목록과 ResearchEntry에서 근거 문구를 검토·확장할 수 있음. 조건별 관찰은 계속 선택적 보조 증거로 유지하고, 새 로직은 별도 요구사항 확정 후 추가. |

### 변경 파일과 최종 구조

새 파일:
- `scripts/data/experiment_condition_observation_data.gd`
- `scripts/data/experiment_condition_observation_data.gd.uid` (Godot 생성 stable UID)

수정 파일:
- `scripts/data/case_data.gd`: authored 배열.
- `scripts/data/research_entry_data.gd`: Kind 10 추가.
- `scripts/runtime/case_runtime_state.gd`: 실행별 관찰 ID metadata/조회/reset.
- `scripts/main/main.gd`: 실행 당시 matching/snapshot, 추가 관찰 발견/Log, EXP 높이.
- `scripts/views/experiment_view.gd`: Base 뒤 조건 관찰 표시, 실제 표시 ID 반환/선택 확인/reset.
- `scenes/views/experiment_view.tscn`: 기존 Result 영역의 Scroll/wrap/관찰 목록.
- `resources/cases/test_case_02.tres`: TEMP 관찰/Research 한 쌍. 기존 subresource 내용 보존.
- `README.md`: 현재 설명 및 이 67개 항목 보고.

삭제 파일은 없습니다. Main/Case01 Scene/Resource, ExperimentData, CCTV/Containment/Research Log View,
EnvironmentalDisturbanceData/ReactionData/CCTVConditionObservationData, ResearchArchive/Pending/Resolution/Candidate,
project.godot, .gitignore/.gitattributes는 byte-identical입니다.
기존 Scene 계층은 유지하며 Experiment의 오른쪽 Execution 안의 Result 영역만 Scroll → VBox → Base/Condition으로 감쌌습니다.
Result/Log 열람 자체가 실행이나 새로운 발견/기회를 만들지 않습니다.

검증 자료는 `.godot/verification/step35/`에 있습니다. 실행용 게임에 참조하지 않고 `.godot/` Git 제외 정책을 유지합니다.
새 `experiment_condition_validation.gd`와 `experiment_condition_edge_validation.gd`, 기존 검사 사본,
`run_validation.ps1`, per-run log/pass certificate, editor import, source/test baseline 및 scope audit를 남겼습니다.
기존 enum 크기와 Case02 연구 배열 추가에 따라 사본의 기대값만 확장하고 원본 테스트는 보존했습니다.
기존 회귀 흐름의 expected source/text에는 실제 새 조건 관찰을 반영했습니다. 기존 판정 검사를 제거하지 않았습니다.


## 34단계 환경 조건에 따른 CCTV 추가 관찰과 실제 확인 기록

기존 프로젝트를 확장했습니다. 작업 전 HEAD는 `1c4eea4c195fd1ba7447bdca447a7f533b92e756`,
브랜치는 `master`(`origin/main` 추적)이었습니다. 미커밋 경로 35개(수정 16, 미추적 19),
제품 파일 87개와 이전 검증 소스 1,235개를 조사하고 작업 전 사본/해시를 남겼습니다.
Main, 두 Case Resource, 모든 State/Data/View 및 기존 검증 흐름을 실제 파일 기준으로 확인했습니다.

새 `CCTVConditionObservationData`는 `observation_id`, `cctv_id`, `disturbance_id`,
`display_name`, `observation_text`의 다섯 필드만 가집니다.
`CaseData.cctv_condition_observations: Array[CCTVConditionObservationData]`에 둡니다.
기존 Case의 authored Reaction/Research 배열과 역할이 같고, 여러 CCTV의 관찰도 ID로
연결할 수 있으므로 이 위치를 선택했습니다. 기존 `CCTVData` 스키마/기본 문구는 변경하지 않았습니다.
이번 콘텐츠는 CCTV/Disturbance 조합당 합쳐진 관찰 하나입니다. 동일 조합 중복은 warning 후
모두 생략하며, 여러 활성 조건에는 각각의 관찰을 동적 목록으로 표시합니다.

```text
기존 Runtime 적용 기록 + 현재 Case authored CCTV 관찰
  → Main: Case/Runtime/CCTV ID/적용 ID/관찰 ID 유효성 검증
  → CCTVView.ConditionSnapshot (표시 문자열 복사)
      BASE OBSERVATION (기존 문구)
      ACTIVE FACILITY CONDITION (Step33 상태)
      CONDITION OBSERVATION (조건별 추가 관찰, 높이 144의 Scroll)
  → 현재/실제 표시 CCTV 확인 → Main 승인
      Runtime observed source 순서 기록 + 유효 authored entry_id 발견
  → Research Log: OBSERVATION, authored 또는 실제 확인한 관찰의 fallback
```

Runtime에는 작은 `_observed_research_sources` 순서 배열을 추가했습니다.
`{source_kind, source_id}`만 저장하며 별도 상태 객체/게임 판정/시설 상태를 만들지 않습니다.
기존 authored `entry_id` 목록만으로는 fallback 관찰의 확인 여부와 전체 확인 순서를
구분할 수 없어서 필요한 기록입니다. Getter는 deep copy, 중복은 Kind/ID 쌍으로 거부하고
reset으로 초기화합니다. 가짜 Research ID를 만들지 않으며 Archive API도 그대로입니다.
새 관찰을 확인한 Log는 공개 가능한 기존 항목을 실제 source 확인 순서로 배열합니다.
새 관찰이 없는 기존 경로는 기존 Log 배열/Stage 공개 정책을 유지합니다.
추가 SourceKind는 맨 뒤의 `CCTV_CONDITION_OBSERVATION = 9`이며 기존 0~8은 그대로입니다.
표시 Entry에 Kind를 함께 전달해 다른 Kind의 같은 source_id와도 순서 연결이 충돌하지 않습니다.

활성 조건이 생긴 Experiment / Containment에는 **Recheck CCTV**가 나타납니다.
Main은 원래 Stage만 기억하고 CCTV로 이동하며, 재확인은 새 Failure opportunity를 소비하지 않습니다.
CCTV의 **Back: EXPERIMENT / CONTAINMENT**로 돌아옵니다. 실행/확정 상태는 Runtime에서 복원하며,
미확정 임시 선택은 기존 Log Back과 같은 View 재생성 정책에 따라 초기화됩니다.
재확인 중 Log에는 원래 화면까지 이미 공개된 정보가 유지됩니다. 미래 결과는 공개하지 않습니다.
Recheck 버튼이 표시된 Experiment/Containment에는 ViewHost 높이 550, 추가 관찰 CCTV에는 660을
실행 중 확보합니다. CCTV 안의 간격만 8로 조정했고 저장된 Main Scene/프로젝트 Stretch는 그대로입니다.

교란이 CCTV 위에서 발생하면 조건 관찰은 Overlay 중에는 갱신/발견하지 않습니다.
Dismiss 후 동일 CCTV instance의 추가 관찰 영역만 갱신하고 실제 표시를 확인해 발견합니다.
Experiment / Containment에서 발생하면 그 화면의 환경 상태만 유지하며 CCTV 확인 전에는 미발견입니다.
조건 추가 관찰의 표시 refresh는 State/Resource를 쓰거나 opportunity를 호출하지 않습니다.
발견은 별도 승인 함수에서 current View/Stage/표시 여부/실제 CCTV 데이터와 mapping을 재검증합니다.

### 요청한 65개 항목 보고

| 번호 | 확인 항목 | 구현 및 검증 결과 |
| --- | --- | --- |
| 1 | 작업 전 Git | 위 HEAD/브랜치/미커밋 35개 경로. 커밋/push 없음. |
| 2 | 관찰 데이터 | Resource 다섯 문자열 필드, 불필요한 조건/판정 필드 없음. |
| 3 | Resource 위치 | CaseData의 authored 배열. 기존 Reaction/Research 콘텐츠 구조와 일관성, 여러 CCTV ID 연결 가능. |
| 4 | Stable ID | 현재 CCTV camera_id = cctv_id, 적용 disturbance_id = 관찰 disturbance_id. 콘텐츠별 Main 분기 없음. |
| 5 | CaseData | typed `cctv_condition_observations` 배열 하나 추가. |
| 6 | CCTVData | 수정 없음. camera_id/observation_text 스키마 그대로. |
| 7 | Base 보존 | 기존 Description Node/문구/표시 함수를 유지. BASE OBSERVATION 표제만 추가. |
| 8 | 추가 관찰 | 별도 조건 관찰 영역에 typed Snapshot의 동적 Label 목록. |
| 9 | 여러 조건 | Power와 Vent가 동시에 적용되면 각 관찰 표시. |
| 10 | 표시 순서 | 적용 ID 최초 순서, 같은 disturbance의 여러 Reaction 쌍은 한 번만 표시. 정렬 없음. |
| 11 | 중복 mapping | 이번 조합당 한 관찰 정책. 동일 CCTV/Disturbance 중복은 경고 후 생략. |
| 12 | 없는 mapping | Base/Active를 유지하고 추가 영역만 숨김. 다른 관찰 대체 없음. |
| 13 | Invalid ID | 빈/중복 observation_id 및 빈 표시 문구를 거부. 다른 CCTV/불일치 Runtime는 매칭되지 않음. |
| 14 | CCTV UI | Base → Active → Condition → 기존 Open/Next 또는 Back. |
| 15 | 구분 | BASE OBSERVATION / ACTIVE FACILITY CONDITION / CONDITION OBSERVATION 표제. |
| 16 | 긴 문구 | WORD_SMART 줄바꿈, 144 높이 Scroll, 긴 두 번째 관찰 끝 접근 검사. |
| 17 | Main → View | Main이 ID를 해석해 `set_condition_observations(snapshot)` 전달. |
| 18 | Snapshot | CCTVView의 작은 RefCounted ConditionSnapshot/ConditionObservation. 표시 문자열만 복사. |
| 19 | Runtime 접근 | CCTVView가 Main/Runtime/Session 객체를 찾지 않음. |
| 20 | 직접 load | 새 관찰 Resource/TRES를 View가 load하지 않음. 기존 CCTVData 입력만 유지. |
| 21 | Same View | 상태 표시 setter로 추가 영역만 갱신, setup 재실행 없음. |
| 22 | CCTV 유지 | Notice/Dismiss 전후 동일 instance와 기존 Base 내용 확인. |
| 23 | SourceKind | 맨 뒤에 CCTV_CONDITION_OBSERVATION 추가. 총 10, 기존 값 보존. |
| 24 | source_id | observation_id. 기존 CCTV camera_id 매핑과 독립. |
| 25 | Authored | 실제 확인 뒤 유효 authored entry_id만 기존 API로 발견. Log 전용 title/body 사용. |
| 26 | Fallback | 실제 확인한 authored 없는 관찰의 이름/observation_text 사용. 가짜 entry_id 없음. |
| 27 | Category | 기존 OBSERVATION으로 표시. 새 대분류 없음. |
| 28 | Timing | 적용 여부 + 유효 mapping + 현재 실제 표시 CCTV를 Main 승인 경계에서 확인. |
| 29 | 적용 전 | Resource가 있어도 추가 영역/확인 기록/authored discovery 없음. |
| 30 | 적용 직후 | Experiment Overlay/Dismiss 직후에도 CCTV 추가 관찰은 미발견. |
| 31 | 확인 후 | Recheck 실제 클릭 후 확인 source와 authored ID 발견, fallback도 확인 기록 생성. |
| 32 | CCTV 위 교란 | Overlay 중 미발견, Dismiss 뒤 표시/발견. 별도 재진입 불필요. |
| 33 | 중복 발견 | Kind/ID 확인 기록과 entry_id 발견 기록 모두 기존/추가 중복 guard로 한 번만 기록. |
| 34 | Log farming | Open/Back 반복으로 확인/발견/실행/조건/Candidate 값 증가 없음. |
| 35 | Opportunity farming | Recheck/Back/추가 영역 refresh는 opportunity 호출 없음. 기존 key와 실제 승인 행동 유지. |
| 36 | 상태/발견 독립 | 환경 적용만으로는 CCTV 발견하지 않음. 표시와 discovery를 별도 함수로 구분. |
| 37 | Resource 불변 | 표시/발견 중 모든 authored Resource deep 비교 및 디스크 해시 검사. |
| 38 | Runtime 불변 | refresh만 반복하면 불변. 실제 새 관찰 승인 때만 확인/authored 발견 목록 변화. |
| 39 | Case02 콘텐츠 | Power용 TEST_CASE02_POWER_CCTV_OBS 및 authored TEST_CASE02_RESEARCH_POWER_CCTV_OBS 하나 추가. |
| 40 | 정답 비노출 | 기존 Power Reaction과 일치하는 이동 감소/벽면 접촉 유지라는 임시 관찰 사실만 작성. 격리 정답/안정 trait 판정 없음. |
| 41 | SUCCESS | Case01 Room02→Case02에서 조건/추가 관찰/Recheck 표시 없음. |
| 42 | FAILURE 전 | threshold 전 CCTV에는 Base만, 추가 관찰 미발견. |
| 43 | FAILURE 후 | 실제 Experiment 승인 → Power 교란 → CCTV 확인 → 추가 관찰/Log 발견. |
| 44 | 조건 독립 | 메모리 Vent 관찰을 추가하고 Resource 순서를 뒤집어도 Power→Vent 적용 순서로 둘 다 표시. |
| 45 | Unknown 조건 | 현재 활성 조건에 매핑이 없으면 Base/Active 유지, 추가 관찰 없음. |
| 46 | Reset | 확인 source/authored ID/applied 조건 초기화, 새 Runtime 독립. |
| 47 | Archive | Main의 기존 merge로 새 authored ID 보존. fallback에는 가짜 Archive ID 없음. |
| 48 | Stale View | 이전/분리/Modal 상태의 CCTV discovery 요청 무시. current CCTV 데이터 일치도 확인. |
| 49 | Hidden Resolution | 기존 Outcome/Pending/handoff 검증 유지. |
| 50 | Candidate | threshold/FIFO/하나씩 발생/잘못된 콘텐츠 보존 정책 유지. |
| 51 | Overlay | 입력 차단/focus/same View/stale Dismiss/중복 방지 회귀. |
| 52 | Active Environment | 기존 공통 표시/0·1·3·10개/순서/누락 처리/지속/reset 회귀. |
| 53 | Experiment | 결과/실행 이력/횟수/중복 제한 그대로. Recheck 요청만 추가. |
| 54 | Containment | Room 임시 선택/Confirm/확정 잠금/Pending/Next 유지. Recheck 후 확정 잠금 복원. |
| 55 | Research Log | 기존 Stage 공개와 authored/fallback 보존. 실제 추가 관찰 확인 뒤에는 실제 source 확인 순서로 배열. |
| 56 | ResearchArchive | API/Session 수명 그대로. 기존 보존/중복 merge 회귀. |
| 57 | Debug Monitoring | 기존 검증용 Main으로 Timer/관찰/결과 검사. 정상 Route에 Monitoring 추가 없음. |
| 58 | 실패 Debug | Incident/Broadcast/Option/IncidentResult/Result 기존 회귀 검사. |
| 59 | 해상도 | 1920×1080 / 1280×720 / 1024×768, canvas_items/keep/resizable/Compatibility 그대로. |
| 60 | 파싱/실행 | Godot 4.7.1 import, 모든 GDScript check-only 및 정상/이전 회귀 결과는 아래 기록. |
| 61 | 문제/해결 | 재확인 경로 부재→작은 요청 버튼/복귀 Stage 추가. fallback 확인 여부·순서 부재→source 확인 기록 추가. UI 공간→작은 간격/고정 Scroll/필요한 높이 확보. 현재 CCTV 데이터 일치 guard 보강 후 최종 전체 검사 재실행. |
| 62 | 실제 변경 | 기존 파일 13개 수정, 새 Data Script/UID 2개 추가. 아래 책임 목록. 삭제 없음. |
| 63 | 이전 변경 | 이전 미커밋 전부 보존. 이전 보고/검증 소스 1,235개 보존 검사. |
| 64 | 미구현 | Experiment Variant, 정답 변경, trait/시설 simulation, Severity/MAJOR/Broadcast 자동, Case03/Campaign/SaveLoad/Archive UI/영상·음향·최종 디자인/Manager/Rule Engine. |
| 65 | 다음 단계 | CCTV 추가 단서와 기존 Experiment의 추리 관계를 콘텐츠 검토하는 지점. 조건별 Experiment Variant는 이번 단계에서 구현하지 않음. |

### 파일 변경과 책임

- 추가: `scripts/data/cctv_condition_observation_data.gd`, 해당 `.gd.uid` — authored 관찰 스키마.
- 수정: `scripts/data/case_data.gd`, `research_entry_data.gd` — 콘텐츠 배열/SourceKind 추가.
- 수정: `resources/cases/test_case_02.tres` — 관찰과 authored Research 하나씩 추가. 기존 모든 sub_resource 값 보존.
- 수정: `scripts/runtime/case_runtime_state.gd` — source 확인 순서/중복/복사 조회, reset 한 줄. 기존 실행/확정/조건 API 그대로.
- 수정: `scripts/main/main.gd` — 재확인 요청/복귀, mapping 검증, Snapshot/실제 표시 발견, Log 순서와 알려진 화면 공개 범위.
- 수정: `scripts/views/cctv_view.gd`, `scenes/views/cctv_view.tscn` — 추가 관찰 영역과 표시 전용 API, 기존 CCTV 그대로.
- 수정: `scripts/views/experiment_view.gd`, `containment_view.gd`, 두 `.tscn` — 활성 환경일 때 Recheck 버튼/요청 signal만 추가.
- 수정: `scripts/views/research_log_view.gd` — Entry에 source_kind/기본값 매개변수 추가. 기존 Log 표시 UI/함수 그대로.
- 수정: `README.md` — 현재 흐름/구조와 이 보고. 33단계 이하 과거 보고 보존.

검증 코드/로그/캡처/변경 전 사본은 Git 제외 `.godot/verification/step34/`에만 있습니다.
이전 검사 원본은 그대로 두고 복사본에 새 SourceKind 총수, 정확한 Reaction fallback 제거,
새 관찰이 없는 기존 CCTV modal fixture만 반영했습니다. 새 CCTV 발견 timing은 별도 검사합니다.
제품에는 debug Main/Scene/검증 fixture를 추가하지 않았습니다.

최종 **158개 검사 모두 통과**했습니다(headless 95, Windows GPU 63).
제품 GDScript 34개 `--check-only`, 프로젝트 기본 Main 실행, Step32/33와 이전 debug 회귀를 포함합니다.
추가 관찰은 세 해상도 각각 양쪽 실행 방식에서 A/B/C 발견 시점, Recheck/Back,
same CCTV Dismiss, authored/fallback, 실제 확인 순서, 복수 조건과 장문 스크롤을 검사했습니다.
이전 정상 Flow의 360회 Open/Back과 새 재확인 경로의 60회 Open/Back을 포함해 farming을 확인했습니다.
일반 실행과 최종 editor import의 오류/경고는 0이며, 부적합 fixture의 warning은
검사별 예상 수와 전부 일치했습니다. 제품 Script/Resource는 검증 실행 중 변경되지 않았습니다.
GPU 캡처 186개를 생성하고 세 해상도의 Base/Active/Condition 및 장문/Log를 시각적으로 확인했습니다.
151→158개로 늘어난 검사 로그/증명 파일은 모두 실제 파일 경로와 로그 해시로 재확인했습니다.
F5 키 자체를 UI 자동 조작하지는 않았으며 같은 `run/main_scene`의 기본 실행을 확인했습니다.
1024×768 창의 콘텐츠 렌더 영역은 기존 비율 유지에 따라 1024×576입니다.
작업 전 사본 비교와 `git diff --check` 결과는 제품 13개 수정/2개 추가/삭제 0,
변경 없는 기존 파일 74개, 이전 검증 소스 1,235개 보존입니다.
Main 기존 함수 37개, Runtime 기존 함수 22개는 그대로이며, 기존 Case02 sub_resource와
Scene 노드도 추가 영역/허용한 CCTV 간격 외에는 보존했습니다. 커밋/push 없음.
상세 증거는 `validation-results.json`, 검사별 `.pass.json`/로그, `audit-results.json`에 있습니다.

## 33단계 현재 Case의 활성 환경 조건 표시

기존 프로젝트를 확장했습니다. 작업 시작 당시 `master`는 `origin/main`을 추적했고,
HEAD는 `1c4eea4c195fd1ba7447bdca447a7f533b92e756`이었습니다.
Step29~32의 변경 28개 경로(수정 12, 미추적 16)가 남아 있었습니다.
실제 제품 파일 84개, 기존 검증 GDScript/PowerShell 소스 1,053개를 먼저 조사·보존했습니다.
`project.godot`, Main Scene, Case01/Case02 Resource, 다섯 State, Data 스키마,
Notice/Profile/Log 및 debug 화면은 이번 단계에서 수정하지 않았습니다.

```text
CaseRuntimeState.get_applied_disturbances() → Main._build_environment_summary()
  → EnvironmentConditions.Summary (RefCounted)
      entries: Array[Condition]
      Condition: disturbance_id / display_name / condition_change_text
  → CCTV / Experiment / Containment.set_environment_conditions(summary)
      → EnvironmentConditions (VBoxContainer)
          Heading: ACTIVE FACILITY CONDITION
          ConditionScroll: 높이 96, 가로 스크롤 없음
              ConditionList: 발생 순서의 동적 Label 목록, 자동 줄바꿈
```

상태의 저장소는 기존 Runtime 기록 하나입니다. Summary는 매번 생성하는 표시용 값이며
새 Runtime/Session 상태가 아닙니다. Main이 `case_sequence`와 현재 Case의 Incident에
연결된 Disturbance를 ID로 찾습니다. 동일 ID의 이름/조건이 일치하는 재사용 정의는 허용하고,
표시 내용이 충돌하거나 누락·빈 값이면 warning과 ID/`[Unavailable]`을 표시합니다.
현재 Case에 Reaction이 없거나 authored Research를 사용할 수 없어도 시설 조건은 유지합니다.
원인 Case, Room 정답, 숨겨진 결과, creature 관찰 전체 문장을 Summary에 넣지 않습니다.

View 생성 직전과 실제 교란 적용 직후에 표시 전용 API만 호출합니다. 전체 `setup()`이나
화면 전환을 다시 호출하지 않습니다. 공통 표시 영역은 Summary 문자열을 복사하므로
외부에서 표시 객체를 수정해도 UI/Runtime에 영향을 주지 않습니다.
조건이 있으면 Main의 ViewHost 최소 높이를 실행 중 360→500으로 조정해 기존 버튼의
공간을 확보합니다. 조건이 없거나 다른 화면으로 이동하면 360으로 복원합니다.
Main Scene의 저장된 레이아웃과 프로젝트 해상도/Stretch 설정은 그대로입니다.

### 요청한 61개 항목 보고

| 번호 | 확인 항목 | 구현 및 검증 결과 |
| --- | --- | --- |
| 1 | 작업 전 Git | 위 HEAD/브랜치, 기존 미커밋 28개 경로. 커밋/push 없음. |
| 2 | Active Environment | 현재 Runtime의 적용 기록을 활성 조건 목록으로 표시. |
| 3 | 기록 재사용 | 기존 `_applied_disturbances`와 복사본 getter를 그대로 사용. |
| 4 | 새 Runtime 상태 | 없음. Summary는 일시적인 표시 데이터. |
| 5 | Summary 구조 | typed RefCounted Summary와 Condition, 세 문자열 필드. |
| 6 | Main → View | Main이 ID를 해석해 `set_environment_conditions(summary)` 전달. |
| 7 | CCTV 표시 | Camera/기존 observation_text 아래, Actions 위에 상태 표시. |
| 8 | Experiment 표시 | 기존 Workspace와 결과 아래, Actions 위에 상태 표시. |
| 9 | Containment 표시 | Room 목록 아래, Confirm/Next/Open 위에 상태 표시. |
| 10 | 조건 없음 | 공통 영역 전체 숨김. 빈 패널 없음. |
| 11 | 조건 1개 | 정상 Failure의 Power 또는 Airflow 표시. |
| 12 | 다중 조건 | 동적 목록, 복수 후보 및 3/10개 fixture 확인. |
| 13 | 순서 | Runtime 최초 적용 순서 유지. 자동 정렬 없음. |
| 14 | 중복 | Runtime의 기존 쌍 중복 거부 유지, Summary는 disturbance_id 기준 한 줄. |
| 15 | Overlay 이후 | Dismiss는 Notice만 닫으며 조건을 지우지 않음. |
| 16 | same View | CCTV/Experiment/Containment에서 Notice 전후 동일 instance 확인. |
| 17 | Experiment 선택 | 기존 Step32 선택 보존 회귀와 반복 refresh 검사 통과. |
| 18 | Containment 선택 | 미확정 Room 선택 상태에서 실제 opportunity/Notice/Dismiss 후 유지. |
| 19 | Confirm 잠금 | refresh 후 확정 후보/Confirm 및 마지막 Case Next 잠금 유지. |
| 20 | Log 복귀 | View를 재생성해도 조건 목록 복원. 기존 미확정 선택 초기화 정책 유지. |
| 21 | CCTV 재진입 | Main이 Runtime에서 새 Summary를 전달해 복원. |
| 22 | Runtime 직접 접근 | 대상 View와 공통 상태 영역에서 없음. |
| 23 | Resource 직접 load | 새 상태 표시에서 없음. 기존 타입 Script preload만 사용. |
| 24 | Disturbance 누락 | warning, 해당 ID와 `[Unavailable]`; 다른 정의로 대체하지 않음. |
| 25 | Reaction 누락 | 시설 조건 표시 유지, 관찰 생성 정책은 기존 그대로. |
| 26 | authored/fallback | 조건은 Reaction/Research 텍스트 선택과 독립. 기존 양쪽 경로 검증. |
| 27 | handoff 초기화 | 활성 조건이 있던 Case01→Case02 실제 handoff 및 Runtime 교체/reset 검사. |
| 28 | Session 독립 | Pending/Resolution/Candidate/Archive 객체와 값이 표시/교체/reset으로 변하지 않음. |
| 29 | Source Failure 숨김 | Summary에 source_case_id/result/Room 정보를 넣지 않음. |
| 30 | 정답/해석 | 조건 변화 사실만 표시. 기존 답/Outcome/result_text 변경 없음. |
| 31 | UI 구조 | 세 View 내부에 작은 공통 VBox/Scroll/동적 Label Scene. 새 주요 Stage 없음. |
| 32 | 긴 문구 | WORD_SMART 줄바꿈, 고정 높이 스크롤, 10개 장문 마지막 항목 접근 검사. |
| 33 | 반복 refresh | 상태 영역만 갱신. 세 번 반복해도 선택/결과/잠금/State 유지. |
| 34 | 0/1/3/10 | 각 개수를 세 View × 세 해상도 × headless/GPU에서 검사. |
| 35 | Resource 불변 | 디스크 해시 및 deep 콘텐츠 비교. 실제 TRES 수정 없음. |
| 36 | Runtime 불변 | Summary 생성/표시/재진입 전후 Runtime와 네 Session 값 비교. |
| 37 | Overlay 회귀 | 기존 입력 차단, focus 복원, same View Dismiss 회귀 검사. |
| 38 | Opportunity 회귀 | 실제 승인 행동, 유효 Stage, 처리 key, 숨겨진 threshold 정책 유지. |
| 39 | Research farming | Open/Back 반복으로 추가 opportunity/교란/발견 없음. |
| 40 | Hidden Resolution | 기존 handoff 판정/부적합 데이터 Pending 보존 검사 유지. |
| 41 | SUCCESS | Case01 Room02→Case02 정상 흐름에서 교란 후보/조건 없음. |
| 42 | FAILURE | Power authored와 Vent fallback, 반응 작성 데이터 누락 경로 확인. |
| 43 | Experiment 교란 | 실제 승인 실행 이후 Notice와 상태 영역, 선택 유지 회귀. |
| 44 | Containment 교란 | 정상 threshold4 진입 및 미확정 선택 중 적용 fixture 확인. |
| 45 | CCTV 교란 | 실제 CCTV entry opportunity 검사. threshold1은 검증용 메모리 후보에만 적용. |
| 46 | Reentry | 세 View Log Back 및 Profile를 거친 재진입 시 조건 복원. |
| 47 | Research Observation | 기존 reaction_id OBSERVATION과 authored/fallback 보존, 상태 영역에 관찰 전체 반복 없음. |
| 48 | ResearchArchive | handoff merge/Reaction ID 보존과 debug Archive 회귀. |
| 49 | Case handoff | 승인/불가 Next, 기존 Runtime 보존 및 새 Runtime 독립 검사. Case03 없음. |
| 50 | debug Monitoring | 기존 test 전용 Main으로 Timer/누적 관찰/결과 회귀 검사. |
| 51 | Failure downstream | Incident/Broadcast/확정 Option/IncidentResult/Result debug 회귀 검사. |
| 52 | stale/signal | 오래된/분리된 View 요청 무시, 현재 signal 단일 연결 검사. |
| 53 | 단일 View | ViewHost에 주요 View 하나. 상태 영역은 내부 자식 Scene. |
| 54 | Overlay 중복 | 기존 중복 key/triggered/modal guard 및 stale Dismiss 검사. |
| 55 | 해상도/Stretch | 1920×1080, 1280×720, 1024×768, canvas_items/keep/resizable 그대로. |
| 56 | 파싱/실행 | Godot 4.7.1 import 및 전체 GDScript 검사, 기본 Main 실행과 headless/GPU 회귀 결과는 아래 기록. |
| 57 | 문제/해결 | 기존 ViewHost 360에는 추가 영역이 넘칠 수 있어 조건이 있을 때만 500 확보. 검증 fixture의 반복 ID 정의 충돌/해제된 View 참조를 수정한 뒤 재검사. |
| 58 | 실제 변경 | 아래 목록: 기존 파일 8개 수정, 공통 Scene/Script/UID 3개 추가, 삭제 없음. |
| 59 | 이전 변경 보존 | 이전 변경을 취소하지 않음. 수정 없는 기존 제품 76개/이전 검증 소스 1,053개 해시 및 기존 함수/Scene 내용 비교. |
| 60 | 미구현 | 환경별 CCTV/Experiment Variant, 정답 변경, penalty, severity, 시설 simulation, Manager/Singleton, Campaign/Case03, Save/Load, 연출/최종 디자인. |
| 61 | 다음 단계 | 실제 기획에 맞는 환경별 authored 관찰/실험 콘텐츠 계약을 먼저 정리하는 지점. 이번에는 Variant 구현 없음. |

### 실제 변경 파일과 책임

- 추가: `scenes/views/environment_conditions_view.tscn`, `scripts/views/environment_conditions_view.gd`, 해당 `.gd.uid`.
- 수정: `scripts/main/main.gd` — Summary 생성/ID 해석, 상태 영역 갱신, 조건이 있는 화면의 높이 확보.
- 수정: `scripts/views/cctv_view.gd`, `experiment_view.gd`, `containment_view.gd` — 각각 작은 표시 전용 setter 추가. 기존 함수는 그대로.
- 수정: `scenes/views/cctv_view.tscn`, `experiment_view.tscn`, `containment_view.tscn` — 기존 Actions 앞에 공통 Scene instance 하나 추가.
- 수정: `README.md` — 현재 정책/폴더 구조 및 이 보고 추가. 32단계 이하 과거 보고 본문 보존.

검증 자료는 Git 제외 `.godot/verification/step33/`에만 있습니다.
기존 검증 소스를 덮어쓰지 않고, 현재 Main을 사용하는 정상 테스트와 이전 debug Route를
사용하는 검증용 복사본을 분리했습니다. F5 키를 UI로 자동 조작하지는 않았으며 동일한
`run/main_scene` 프로젝트 기본 실행을 headless와 Windows GPU에서 검사했습니다.
1024×768 창의 실제 콘텐츠 렌더 영역은 비율 유지로 1024×576입니다.

최종 검증은 **151개 모두 통과**했습니다(headless 91, Windows GPU 60).
GDScript 33개 `--check-only`, 프로젝트 기본 실행, 기존 정상/실패 debug Route를 포함합니다.
일반 실행과 최종 editor import는 오류/경고 0이며, 부적합 데이터 fixture의 경고는
검사별 예상 수와 일치했습니다. Power authored / Vent fallback / Reaction 작성 누락 / SUCCESS의
정상 흐름에서 총 360회 Open/Back을 확인했고, 별도 상태 표시 검사에서 0/1/3/10개와 장문,
선택/잠금, 재진입, CCTV/Containment 교란, Runtime 교체/reset을 확인했습니다.
GPU 캡처 165개를 생성하고 세 해상도의 실제 상태 표시와 장문 스크롤을 시각적으로 점검했습니다.
`validation-results.json`, 각 검사 `.pass.json`/로그, `audit-results.json`에 결과를 보관했습니다.
검증 결과 확인용 명령의 잘못된 경로 조합도 수정했으며 실제 151개 로그 해시/Script 경로를 재확인했습니다.
Git diff 검사 및 작업 전 사본 비교 결과 삭제/의도하지 않은 변경이 없고,
기존 Main/View 함수와 기존 Scene 노드 구성, 32단계 이하 보고는 보존됐습니다.

## 32단계 숨겨진 판정과 환경 교란 관찰 Vertical Slice

현재 정상 Route는 그대로 네 화면씩 Case01 → Case02를 진행합니다. 현재 저장소에는
과거 실패를 다음 제출에서 즉시 Incident 화면으로 연결하는 정상 Route가 없었으며,
31단계의 Pending 보존/handoff 기반에 아래 구조를 추가했습니다.

```text
Containment Confirm → Pending (화면 유지)
Next/handoff → Case ID + Room ID로 유일한 Outcome 검색
  → 숨겨진 Resolution 한 번 기록 → FAILURE이면 후보 등록 → Pending 제거
  → 기존 Research Archive merge → 새 Runtime → 다음 PROFILE

후속 Case의 실제 CCTV 진입 / 승인된 Experiment 실행 / Containment 진입
  → 중복 없는 opportunity → 후보별 카운트
  → threshold에 도달한 가장 오래된 유효 후보 하나
  → IncidentData.environmental_disturbance
  → 현재 Case의 disturbance_id 일치 Reaction 검색
  → Runtime applied record → modal Notice → authored discovery
  → Dismiss 후 동일 View 계속 → Research Log OBSERVATION
```

내부 결과는 기존 `MonitoringOutcomeData.final_result`가 Source of Truth입니다.
정상 경로에서는 Monitoring Timer, 현재 Runtime의 monitoring_result, Incident/Broadcast
Route를 사용하지 않습니다. 실패 원인 Case와 SUCCESS/FAILURE는 플레이 UI에 전달하지 않습니다.
판정이 잘못됐거나 중복이면 handoff를 차단하고 Pending과 현재 상태를 유지합니다.
마지막 Case는 다음 항목이 없으므로 판정하지 않고 현재 Pending/Runtime에 머무릅니다.

Main은 현재 Runtime과 네 독립 세션 상태를 소유합니다. Resolution은 Case별 최초 판정을
보존하고 Candidate는 source_case_id/incident_id/threshold/count/disturbance_triggered를
보존합니다. 각 getter는 복사본을 반환합니다. Candidate의 환경 영향이 발생해도 후보를
삭제하지 않습니다. 이 상태들은 Resource나 Manager가 아니며 서로를 참조하지 않습니다.

`PROTOTYPE_DISTURBANCE_THRESHOLD = Vector2i(2, 4)`는 **TEMPORARY / PROTOTYPE** 값입니다.
후보 생성 때 Main의 RNG로 한 번 선택하며 초 단위 Timer/random polling이 없습니다.
실제 행동이 없으면 기다린 시간만으로 발생하지 않습니다. 두 번의 Experiment를 모두
건너뛰면 이번 두 Case sequence 안에서 threshold에 도달하지 않을 수도 있습니다.
모든 대기 후보는 같은 유효 opportunity에서 카운트를 진행하고 ready 후보를 등록 순서로
검사합니다. 잘못된 콘텐츠의 후보는 유지하고 건너뛰며, 가장 오래된 유효 후보 하나만
적용합니다. 중복 disturbance+reaction은 현재 Runtime에 다시 적용하지 않습니다.

Incident01은 TEST POWER INTERRUPTION, Incident03은 TEST VENTILATION INSTABILITY입니다.
조건은 각각 `LIGHT: NORMAL → OFF`, `AIRFLOW: STEADY → INTERMITTENT`로 명시합니다.
Case02에는 두 반응을 작성했습니다. 전원 반응에는 Research Entry를 추가하고 환기 반응은
fallback을 사용합니다. 문구는 이동 빈도/반복 벽 접촉 같은 임시 관찰 사실이며 정답·해석·
고의적인 거짓 단서를 넣지 않습니다. 후보/실험 제한/CCTV/Room/Research를 삭제하거나
숫자형 불이익을 주지 않습니다. 환경 전체를 시뮬레이션하지 않습니다.

Notice는 Main의 자식 Control이며 Stage 목록과 ViewHost에 포함되지 않습니다.
뒤 화면의 처리를 잠시 비활성화하고 전체 화면의 mouse input을 막으며 keyboard input은
Notice가 처리합니다. Dismiss 또는 ui_accept으로 닫습니다. Main의 활성 View 검증도
Notice 동안 진행/Open/실행/확정 요청을 차단합니다. 같은 View 객체와 임시 선택을 보존하고
기존 process mode/focus를 복원합니다. 긴 문구는 Notice 안에서 스크롤할 수 있습니다.

Research Log는 실제 applied record가 있는 현재 Case Reaction만 표시합니다.
SourceKind DISTURBANCE_REACTION=8을 배열 끝에 추가했으며 기존 0~7은 그대로입니다.
Source ID는 reaction_id, 표시 category는 OBSERVATION입니다. 유효 authored 항목을 실제
발견했으면 작성 문구, 그렇지 않으면 Reaction 문구를 사용합니다. Source Case의 Incident/
Broadcast/IncidentResult Research는 발견하지 않습니다. 기존 merge helper가 Reaction 발견
ID도 보존하며 마지막 Case에서는 기존 정책대로 현재 Runtime에 남습니다.

### 요청한 76개 항목의 작업 보고

| 번호 | 항목 | 구현 및 검증 내용 |
| --- | --- | --- |
| 1 | 작업 전 Git | master → origin/main, HEAD 1c4eea4. 기존 수정7개/미추적5개, 제품73파일과 기존 검사 원본872개를 먼저 스냅샷/해시로 보관. |
| 2 | Hidden Resolution | 정상 handoff에서 Pending Case/Room ID로 유일한 기존 Outcome을 검색, Timer 없이 final_result 사용. |
| 3 | ResolutionState | Main 소유 RefCounted. Case ID/Room ID/result/FAILURE incident_id, 최초 기록/복사 조회/순서/reset. |
| 4 | Pending 전환 | 판정·후보 조건을 먼저 검사하고 기록 성공 뒤 remove_pending. 실패하면 현재 상태와 Pending 유지. |
| 5 | SUCCESS | Resolution만 저장. Runtime 결과/알림/후보/교란 없음. |
| 6 | FAILURE | Resolution에 Incident ID와 결과 기록 후 ID 중심 후보 등록. 즉시 UI 사건 없음. |
| 7 | CandidateState | source_case_id/incident_id/threshold/opportunities_seen/disturbance_triggered, 여러 Case 등록/복사 getter/명시적 reset. |
| 8 | 판정/사건 분리 | handoff 판정과 이후 gameplay opportunity 발생을 분리. PROFILE 직후 사건 없음. |
| 9 | 후보 수명 | Runtime 교체/reset과 독립이며 triggered 이후도 유지. |
| 10 | DisturbanceData | disturbance_id/display_name/notice_text/condition_change_text만 typed Resource. |
| 11 | Incident 연결 | environmental_disturbance: EnvironmentalDisturbanceData 필드 하나 추가. Main에 특정 Incident ID 분기 없음. |
| 12 | ReactionData | reaction_id/disturbance_id/display_name/observation_text만 typed Resource. |
| 13 | CaseData | disturbance_reactions: Array[CaseDisturbanceReactionData] 추가. 기존 필드 보존. |
| 14 | SourceKind | DISTURBANCE_REACTION=8 추가. 기존 0~7/Monitoring 제외 정책 유지. |
| 15 | Runtime 기록 | disturbance_id/reaction_id 쌍, 없는 반응은 빈 reaction_id. 중복 쌍 거부, deep-copy getter, reset 초기화. |
| 16 | discovery | 유효 현재 반응을 Notice로 실제 보여준 경계에서 기존 helper로 발견. |
| 17 | 작성/fallback | 유효 발견 ID가 있는 authored 사용, 없거나 충돌이면 실제 Reaction 문구. 가짜 ID 생성 없음. |
| 18 | Opportunities | 실제 CCTV 진입, 승인된 개별 Experiment 실행, 실제 Containment 진입만. |
| 19 | 중복 방지 | 현재 Case의 Main key 집합. handoff에서 초기화, 동일 key 한 번만. |
| 20 | Log farming | Open/Back은 opportunity 아님. Back 생성은 기존 false 경계, key 중복 방어도 유지. |
| 21 | Experiment | 승인 완료된 ID별 key. 선택/거부/중복 실행은 소비하지 않음. |
| 22 | threshold | 한 곳의 임시 2~4 범위, 후보 생성 시 한 번 RNG 선택. 첫 opportunity 자동 발생 없음. |
| 23 | RNG 검사 | ignored 검사에서 private RNG seed를 지정해 2/3/4 threshold를 재현. 제품 Debug API 추가 없음. |
| 24 | 여러 후보 | 모든 대기 후보 진행, ready 중 가장 오래된 유효 후보 하나 처리. 잘못된 후보 보존. |
| 25 | FIFO | 등록 순서의 ready 목록. Severity/Priority engine 없음. |
| 26 | 한 번 한 Event | Main loop는 성공한 하나의 Notice 이후 break. 독립 두 후보 검사. |
| 27 | Overlay | 독립 Control Scene/Script, 시설 제목/조건 변화/선택적 관찰/Dismiss, 스크롤 영역. |
| 28 | Stage 아님 | 기존 enum/PackedScene Route 배열 변경 없음. Main 자식 overlay. |
| 29 | View 유지 | Notice와 Dismiss에서 현재 View 생성/해제 없음. 같은 객체 유지. |
| 30 | 입력 차단 | 전체 화면 mouse 차단, keyboard 처리, ViewHost process 중단, Main 활성 View guard. |
| 31 | 환경 명시 | LIGHT/AIRFLOW 변화 문구를 Notice에 표시. |
| 32 | 관찰 | 해당 현재 Case Reaction의 observation_text만 UNPLANNED OBSERVATION 표시. |
| 33 | 정답 비노출 | 정답 Room이나 안정화 해석을 쓰지 않음. |
| 34 | 거짓 단서 없음 | 실제 작성한 현재 Case 반응만 표시, 다른 반응 대체 없음. |
| 35 | 필수 정보 보존 | Experiment/CCTV/Room/Research/limit를 교란으로 제거·수정하지 않음. |
| 36 | Case01 콘텐츠 | Incident01 전원/Incident03 환기 교란 연결. 기존 Outcome/Stage/후속 콘텐츠 보존. |
| 37 | Case02 반응 | 전원·환기 각 하나. disturbance_id 검색. |
| 38 | Research | 전원 반응 authored1 추가, 환기 fallback. 기존 Research3 보존. |
| 39 | 숨겨진 실패 | 새 Runtime monitoring_result는 UNDEFINED. Case02 UI/Log에 source FAILURE 없음. |
| 40 | 원인 Case | Notice에 source_case_id/incident_id/판정 전달 없음. |
| 41 | 후보 보존 | triggered=true로 남김. 삭제/resolve/MAJOR 전환 없음. |
| 42 | MAJOR | Incident/Broadcast/IncidentResult 자동 interrupt 미구현. |
| 43 | SUCCESS 후보 | SUCCESS 흐름 후보0, applied record0, Notice0 확인. |
| 44 | debug 보존 | Monitoring Scene/Timer/Schema와 기존 debug Route 유지. 정상 판정에서 사용하지 않음. |
| 45 | 원인 Research | Source Case의 Incident/Broadcast/결과 발견 없음. 실제 기존 discovery 목록만 Archive merge. |
| 46 | Runtime reset | 적용 기록/현재 발견은 지우고 독립 Resolution/Candidate/Archive는 유지. |
| 47 | 상태 독립 | 현재 Runtime + Pending/Resolution/Candidate/Archive의 수명·API 분리. Resource 저장 없음. |
| 48 | 정상 SUCCESS | Room02 확정 → 숨겨진 SUCCESS → 새 Case02 정상 진행, 알림 없음. |
| 49 | 정상 FAILURE | Room01/03 → 숨겨진 FAILURE → 후보 → 후속 행동 → 교란 한 번/현재 반응. |
| 50 | 발생 전 | Case02 PROFILE과 첫 CCTV 행동에는 반응 기록/발견/Notice 없음. |
| 51 | 발생 후 | applied record와 해당 authored discovery, 후보 triggered만 변경. 현재 Stage 유지. |
| 52 | Dismiss | 같은 View/Stage와 미실행 임시 Experiment 선택 유지, 처리/focus 복원. |
| 53 | Log 전/후 | 발생 전 미공개, 발생 후 현재 Case OBSERVATION의 authored/fallback 정확한 문구 확인. |
| 54 | 누락 반응 | 시설 조건 Notice만 표시, 빈 reaction_id 기록, 관찰/가짜 발견 없음. |
| 55 | 중복 반응 | 같은 disturbance 복수/같은 reaction ID 충돌은 경고 후 관찰 생략. 첫 항목 fallback 없음. |
| 56 | 잘못된 교란 | null/빈 ID/누락 문구/없는 또는 중복 Incident는 이벤트 없이 후보 유지. |
| 57 | 배열 순서 | Outcome/Incident/Reaction 배열을 뒤집어도 ID 매칭. |
| 58 | stale 차단 | 활성/Tree/queue-free 검증 유지, 이전 Case/View와 분리 객체 요청은 opportunity 소비 없음. |
| 59 | reentry | CCTV Log 왕복과 같은 key 재요청 반복에도 카운트 증가 없음. |
| 60 | 두 후보 | 한 행동에서 첫 후보만 triggered, 다음 실제 행동에 다른 후보 처리, 두 후보 모두 보존. 독립 fixture 검사만 사용. |
| 61 | Resource 불변 | 원본 Case/Incident/Disturbance/Reaction/Research deep snapshot과 디스크 해시 검사. |
| 62 | Archive 회귀 | 기존 API/경계/ID/충돌/증분 merge와 반응 발견 보존 검사. |
| 63 | Log 회귀 | authored/fallback/mixed/Open/Back/공개 조건/lifecycle/security 검사 유지. |
| 64 | handoff 회귀 | 기존 Case01→Case02/Archive/새 Runtime/stale/단일 View, Pending 정책만 새 판정 소비로 변경. |
| 65 | Monitoring 회귀 | 기존 0/10/20 prototype playback, 완료/복원/보호 검사. |
| 66 | debug 실패 | Room01/03 Incident→Broadcast Confirm→IncidentResult→Result 검사. |
| 67 | 주요 View | ViewHost 자식 하나, Notice는 별도 Main 자식. |
| 68 | Overlay 중복 | 열려 있을 때 opportunity/전환 요청 차단, 한 행동 한 Notice. |
| 69 | signal | 진행/Open/Dismiss 연결 하나, 오래된 Dismiss/현재 View 요청으로 중복 진행 없음. |
| 70 | 해상도 | 기존 1920×1080/1280×720/1024×768, canvas_items/keep 유지, overlay 레이아웃/입력/캡처 검사. |
| 71 | 파싱/실행 | 완료된 최종 검증 결과는 아래 기록에 기재. |
| 72 | 문제/해결 | 기존 coverage 검사의 enum 개수8은 복사본에서9로만 갱신. 제품 파싱/실행 오류는 초기 import·새 흐름/상태/경계 검사에서 발견되지 않음. |
| 73 | 실제 파일 | 신규5 GD+각 UID5+Notice Scene1. 수정 Main/Runtime/Pending/Data3/Case2개/README9개. 아래 범위 표 참조. |
| 74 | 이전 변경 | 기존 미커밋 구현·UID·Scene 설정·검사 원본은 보존하며, 변경한 파일은 필요한 경계만 확장. 커밋/push 금지 준수. |
| 75 | 미구현 | Severity/MAJOR/자동 Broadcast/연쇄 사건/시간 trigger/환경 Simulation/숫자 penalty/Case03/Campaign/Save/Load/Archive UI/Manager/최종 UI·Audio·Animation·Shader 없음. |
| 76 | 다음 단계 | 유지된 후보가 언제 MAJOR 영향으로 발전할지와 플레이 중단/복귀 정책을 먼저 설계. 다음 제출 즉시 사건이라는 규칙을 자동으로 넣지 않음. |

### 32단계 실제 변경 범위

| 구분 | 파일 / 이유 |
| --- | --- |
| 신규 Resource Schema | scripts/data/environmental_disturbance_data.gd, case_disturbance_reaction_data.gd 및 UID |
| 신규 세션 State | scripts/runtime/containment_resolution_state.gd, failure_event_candidate_state.gd 및 UID |
| 신규 UI | scenes/views/environmental_disturbance_notice.tscn, scripts/views/environmental_disturbance_notice.gd 및 UID |
| 수정 orchestration | scripts/main/main.gd: 숨겨진 판정, 의미 있는 행동 경계, Notice, 현재 반응 Log 연결 |
| 수정 현재/대기 상태 | case_runtime_state.gd: 적용 쌍/복사 getter/reset; pending_containment_state.gd: remove_pending만 추가 |
| 수정 기존 Schema | case_data.gd/incident_data.gd: typed 필드 각1; research_entry_data.gd: enum 끝에1종 추가 |
| 수정 테스트 콘텐츠 | test_case_01.tres: 교란2와 Incident typed 연결; test_case_02.tres: 반응2/Research1 추가 |
| 수정 문서 | README: 현재 실행 안내/구조/32단계 보고, 아래 Step31 이하 역사 보고 보존 |

검사 자료는 Git 제외 `.godot/verification/step32/`에 저장합니다. 기존 검사 원본을 수정하지
않고 독립 debug Main과72개 복사본에서 이전 단일 Case 기능을 검사합니다. 새 normal flow는
제품 Main Scene을 그대로 실행합니다. RNG seed와 비정상 콘텐츠 조작은 ignored 검사 fixture에만 있습니다.
### 32단계 최종 검증 기록

- Windows Standard Godot `4.7.1.stable.official.a13da4feb`, AMD Radeon RX 6800/OpenGL 3.3 Compatibility에서 검사했습니다.
- 최종 에디터 import: exit=0, errors=0, warnings=0. 전체 **144검사(headless87/native57)** 통과. 제품 GDScript32개의 check-only를 포함합니다.
- 정상 slice 흐름은 SUCCESS/전원 FAILURE/환기 FAILURE/전원 authored 누락 fallback 네 시나리오를 세 창 크기 × headless/native에서 검사했습니다. 실행마다 실제 Open/Back60회, 합계360회입니다. threshold2/3/4를 seed로 재현했습니다. 정상 Main 실행과 정상 흐름은 경고 없이 통과했습니다.
- 비정상 상태 edge 검사의 의도한 경고20개와 기존 debug edge 검사의 지정한 경고 개수가 각각 일치했습니다. 없는/중복 Outcome, 기존 Resolution/Candidate, invalid Disturbance/Incident/source, 누락/중복/invalid Reaction과 충돌 authored mapping을 포함합니다.
- 새 흐름 캡처129장(overlay9장 포함), 기존 debug authored/fallback/mixed navigation 캡처234장. 전원/환기 overlay의 조건·관찰·Dismiss와 Research Log, 기존 SUCCESS/FAILURE Result를 직접 열어 확인했습니다. 1024×768 keep 렌더링 영역은 1024×576입니다.
- 검사 중 제품 Script/Resource 디스크 해시와 원본 콘텐츠 deep snapshot이 유지됐습니다. 결과는 `.godot/verification/step32/validation-results.json`, 각 *.log, `final_editor_import.log`에 있습니다.
- 최종 audit: 작업 전73파일 중64개 바이트 동일, 필요한9개 수정, 신규11개, 삭제0개. 기존 검사 원본872개 해시 동일, 기존 Case 두 Resource의 모든 subresource 필드는 새 typed Incident 연결 외에 보존됐습니다.
- Main은 기존36함수 중 필요한7개만 변경하고7개 추가(총43). Runtime 기존21함수는 reset의 적용 기록 초기화만 변경하고2개 추가. Pending 기존5함수는 그대로이며 remove_pending1개만 추가했습니다.
- project.godot/Main Scene/기존 Containment UI/Monitoring Scene·Script·Schema/Archive Script/기존 UID 및 Step31 이하 README 보고는 보존했습니다. git diff --check 통과, HEAD 동일, staged0개, 커밋/push 없음.

보류 사항: 마지막 Case의 Pending은 다음 Case handoff가 없으므로 유지됩니다. 기다린 시간이나 Log 탐색으로 threshold를 소비하지 않으며, 최소 행동만 하고 끝내면 후보가 이번 sequence에서 아직 드러나지 않을 수 있습니다. 이는 임시 opportunity 기반 정책이며 최종 밸런스·Severity·MAJOR 발생 규칙은 미정입니다.

## 31단계 두 Case의 순차 업무 진행

정상 Main Scene은 `case_sequence = [test_case_01, test_case_02]`를 설정합니다.
두 Case 모두 PROFILE → CCTV → EXPERIMENT → CONTAINMENT를 진행합니다.
Confirm은 현재 Room 확정과 Pending 등록만 수행하고 화면에 머무릅니다.
Next는 검증된 다음 Case가 있을 때 현재 Research를 Archive에 합친 뒤
새 Runtime을 생성하고 다음 PROFILE을 표시합니다. 이전 Runtime은 수정하지 않습니다.
Archive와 Pending은 Main이 처음 생성한 동일한 객체를 계속 사용합니다.

```text
Case01 PROFILE → CCTV → EXPERIMENT → CONTAINMENT
    Confirm: Runtime Room + Pending[Case01] 기록, 화면 유지
    Next: 유효 발견 ID merge → index 증가 → 새 Runtime → Case02 PROFILE
Case02 PROFILE → CCTV → EXPERIMENT → CONTAINMENT
    Confirm: Pending[Case01] + Pending[Case02] 유지
    Next: No next test case configured (disabled), 현재 상태 유지
```

Archive는 이제 “결과가 확정된 Case”만을 뜻하지 않습니다. 결과 판정 없이도
실제로 획득한 Research ID를 Case별로 보존합니다. 같은 ID의 중복 merge는 멱등이며
추가 발견은 기존 순서를 유지하면서 뒤에 합칩니다. 기존 유효 entry 검사와 충돌
제외 로직을 재사용하고 별도 Validator를 만들지 않았습니다. 정상 마지막 Case는
handoff하지 않으므로 발견 ID가 현재 Runtime에 유지되며 Archive에 새로 합치지 않습니다.
현재 Case Log는 Archive를 조회하지 않습니다.

Case02는 Case01과 구분되는 Case/Profile/CCTV/Experiment/Room/Research ID를 사용합니다.
Profile1, CCTV1, Experiment2, Room2, Research3과 실행 제한2만 있습니다.
Profile·Experiment01·Room01에는 작성 Research가 있고 CCTV·Experiment02·Room02에는
작성 Research가 없어 기존 fallback을 검증합니다. Outcome/Incident/Broadcast/IncidentResult는
빈 배열이며 정상 업무 진행은 이를 요구하지 않습니다.

### 요청한 49개 항목의 작업 보고

| 번호 | 항목 | 구현 및 검증 내용 |
| --- | --- | --- |
| 1 | 작업 전 Git | master → origin/main, HEAD 1c4eea4. README/Main/Monitoring 관련 4파일 수정과 Pending/Archive GD·UID 4파일 미추적. 먼저 72파일과 기존 검사 원본 693개의 해시를 보관함. |
| 2 | Case sequence | Main Scene의 typed Array[CaseData] export. Resource 순서만 설정. |
| 3 | Case02 구조 | 새 test_case_02.tres, TEST_CASE_02 및 독립 Source/Research ID. |
| 4 | 콘텐츠 범위 | Profile1/CCTV1/Experiment2/Room2/Research3, 임시 문구와 limit2. downstream 없음. |
| 5 | Manager 미사용 | Campaign/Manager/Singleton/범용 상태 프레임워크 없음. |
| 6 | index/state | Main의 _case_index 정수, current_case, 현재 Case Runtime. 배열이 있으면 첫 항목에서 시작. |
| 7 | Confirm | 기존 승인 경계에서 Room 확정과 Pending 등록. 화면 유지. |
| 8 | Next | Research 보존 후 다음 index/Case/새 Runtime/PROFILE으로 handoff. |
| 9 | Guard | 활성 View·현재 Stage·Case/Runtime 일치·확정 Room·동일 Pending Room·실제 Room 후보·배열/index/다음 Case 유효성·중복 Pending 검사. |
| 10 | 미확정 차단 | 버튼 disabled와 Main의 독립 검증. 강제 활성화와 직접 signal도 거부. |
| 11 | 정상 Monitoring 제외 | Containment 진행 handler는 handoff만 호출하며 _get_next_stage의 해당 Monitoring 분기를 제거함. |
| 12 | debug 보존 | 기존 Scene/Timer/Schema/결과 처리 보존. ignored 검사용 Main 확장에서만 Containment → Monitoring 연결. 제품 debug UI 추가 없음. |
| 13 | merge 시점 | Guard 통과 후 이전 Runtime/Case 교체 전에 유효 발견 ID merge. |
| 14 | Archive 의미 | 결과 확정과 독립적인 획득 Research의 Case별 세션 기록. |
| 15 | incremental merge | 기존 API의 멱등·추가 발견·순서·getter 복사·독립 reset 검사 유지. |
| 16 | Runtime 교체 | 새 CaseRuntimeState.new(next_case.case_id). 이전 객체 reset 없이 새 업무 상태 시작. |
| 17 | 누출 방지 | 이전 실행/Room/결과/Broadcast/발견 목록 누출 없음. 이전 객체도 불변. |
| 18 | 이전 Pending | Case01 실제 확정 Room 유지. |
| 19 | 이전 Archive | Case01 첫 발견 순서의 유효 ID 유지, Case02 Log에 섞지 않음. |
| 20 | Case02 PROFILE | handoff 즉시 새 subject/classification/description 표시. |
| 21 | Case02 discovery | 실제 Profile 표시, Experiment 승인 실행, Room 확정에 해당 작성 ID만 발견. fallback Source는 authored ID를 만들지 않음. |
| 22 | Case02 Log | 현재 Stage/현재 Runtime 공개 조건, 작성·fallback 정확한 문구와 Back 복원 확인. |
| 23 | Experiment | Case02 ID 실행 이력·순서·중복/limit 유지. 선택만으로 소비/발견하지 않음. |
| 24 | Containment | Case02 후보 표시/선택/한 번 확정/Log 복원. 판정 없음. |
| 25 | 두 Pending | Case01+Case02의 실제 Room과 등록 순서 동시 유지. |
| 26 | Research 식별 | Archive는 Case ID별 ID 목록. 독립 세 번째 fixture에 동일 Research ID를 넣어도 Case 구분 유지. |
| 27 | 배열 순서 | Case02→Case01 역순과 Case01→Case02→세 번째 fixture도 코드 변경 없이 검사. |
| 28 | 마지막 Next | No next test case configured, disabled. 직접 요청도 경고 후 현재 상태 유지. |
| 29 | 종료 개발 상태 | Containment에서 머무르는 테스트 데이터 끝. 완료 시스템/Result 없음. |
| 30 | Pending 미판정 | resolve/remove/지연 시간/진행 단위 없음. |
| 31 | 정상 결과 없음 | 두 Case Runtime 결과 UNDEFINED, Incident/Broadcast 확정 없음. |
| 32 | Incident Queue | 미구현. 기존 debug Incident 표시와 구분. |
| 33 | stale signal | 이전 Case01 View 및 Log의 늦은 진행/확정/Open/Back 차단. Tree 밖/queue-free 발신자도 차단. |
| 34 | Resource 불변 | 원본 Case01/Case02 deep snapshot과 디스크 해시 검사. Runtime 상태를 Resource에 쓰지 않음. |
| 35 | Archive 회귀 | 기존 상태/경계/불일치/잘못된 ID/충돌 검사 유지. |
| 36 | Log 회귀 | 기존 authored/fallback/mixed, Stage gate, lifecycle/security/Back 검사 유지. |
| 37 | Monitoring 회귀 | 독립 prototype 0/10/20 재생·완료·복원·보호 검사. Pending은 미판정. |
| 38 | FAILURE 회귀 | Room01/03의 Incident→Broadcast Confirm→IncidentResult→Result 검사. |
| 39 | SUCCESS 회귀 | Room02의 Monitoring→Result, 실패 콘텐츠 없음 검사. |
| 40 | 정상 전체 경로 | 다섯 순차 시나리오, 창 크기별 실제 버튼 Open/Back 77회, headless/native 검사. |
| 41 | 단일 View | 모든 전환과 Log 왕복에서 ViewHost 자식 하나 유지. |
| 42 | signal 중복 | 활성 View 진행/Open 연결 한 개, stale 중복 요청으로 재진행하지 않음. |
| 43 | 해상도/Stretch | 1920×1080, 1280×720, 1024×768. 기준 1920×1080/canvas_items/keep 유지, 긴 마지막 버튼 포함 레이아웃 검사. |
| 44 | 파싱/실행 | Godot 4.7.1 에디터 import와 137검사 통과. 오류 없음. F5가 사용하는 설정 Main Scene을 headless/native 명령행으로 실행. |
| 45 | 문제/해결 | 테스트가 해제된 이전 View에 신호를 보내던 시점을 같은 프레임으로 수정. 기존 테스트 두 곳의 직접 Main Scene 참조는 복사본에서만 debug Scene으로 조정. 누락된 debug 캡처 폴더도 생성. 제품 실행 오류 수정이나 기존 검사 원본 변경은 없음. |
| 46 | 실제 변경 | 신규 Case02 TRES 하나. 기존 Main GD/Scene, Containment GD/Scene, README 다섯 파일만 Step31 수정. |
| 47 | 이전 변경 보존 | 기존 Step29/30 구현·설명과 693 검사 원본 보존. 커밋/push 없음. |
| 48 | 미구현 | delayed resolution 규칙·SUCCESS/FAILURE 판정·IncidentQueue·Shift/Campaign·영구 결과·Archive UI·Save/Load·Validator·Manager·최종 디자인/에셋/Audio/Animation/Shader 없음. |
| 49 | 다음 단계 | 결과 대기 Case의 콘텐츠를 어떤 경계에서 다시 조회할지 정하고 명시적인 resolve 경계를 별도 설계. 몇 Case 뒤 또는 몇 초 뒤라는 규칙은 아직 만들지 않음. |

### 31단계 변경 이유와 검증 기록

- Main Scene은 기존 UI 노드를 유지하면서 두 Resource의 배열 연결만 변경했습니다.
- Main Script는 정상 Containment 진행을 handoff로 바꾸고 Archive filtering을 기존 debug RESULT와 공유하도록 추출했습니다. 기존 결과 경계 보호는 유지합니다.
- Containment Script/Scene은 상위에서 전달하는 Next 문구와 가용성을 반영합니다. 선택·확정 코드는 유지합니다.
- README 현재 실행 안내는 새 정상 경로를 반영하며 아래의 Step30 이하 기록은 당시 동작의 역사 기록으로 보존합니다.
- 검증 자료는 Git 제외 `.godot/verification/step31/`에 보관합니다. 기존 검사 원본을 수정하지 않고 72개 복사본과 test-only debug Main으로 기존 단일 Case 경로를 검사합니다.
- 검증 엔진은 Windows Standard `4.7.1.stable.official.a13da4feb`, native 렌더러는 AMD Radeon RX 6800/OpenGL 3.3 Compatibility입니다.
- 최종 에디터 import는 exit=0, error=0, warning=0입니다. 전체 137검사(headless81/native56)가 통과했으며 27개 제품 GDScript의 check-only를 포함합니다. 정상 경로와 Main 실행은 경고 없이 통과했고 잘못된 상태를 주입한 검사는 지정한 경고 개수까지 일치했습니다.
- 정상 순차 진행은 세 창 크기 × headless/native × 다섯 시나리오로 검사했습니다. 실행별 실제 Open/Back 77회, 합계462회입니다. Case01 Room01/02/03, Case02 작성/미작성 Room, 역순 배열, 독립 세 번째 fixture를 포함합니다.
- 정상 경로 캡처60장, 기존 debug authored/fallback/mixed navigation 캡처234장을 생성했습니다. Case02의 Profile/CCTV/Experiment/최종 Containment/Log와 기존 debug SUCCESS/FAILURE Result를 직접 열어 확인했습니다. 1024×768 창의 keep 렌더링 영역 캡처는 1024×576이며 창 크기 문구는 1024×768입니다.
- 입력 서명과 로그 해시가 일치한 성공 검사만 재사용하여 누락 캡처 폴더 수정 후 남은 검사를 재개했습니다. 검사 결과/로그는 validation-results.json과 각 *.log, 파싱 기록은 final_editor_import.log에 있습니다.
- 최종 audit-results.json: 작업 전72파일 중67개 바이트 동일, 허용한5개만 수정, 신규 Case02 Resource1개, 삭제0개, 기존 검사 원본693개 해시 동일. Main 기존33함수 중 필요한5개만 변경하고3개 추가(총36개), 다른 함수와 Containment 선택/확정 함수는 보존했습니다.
- Step30 이하 README 보고는 보존했습니다. project.godot, 기존 Case01, 세 Runtime 상태 클래스, Monitoring Scene/Script/Schema와 기존 UID도 작업 시작 시점과 동일합니다. git diff --check 통과, HEAD 동일, staged 파일0개, 커밋/push 없음.

## 30단계 Delayed Containment Resolution 기반 준비

작업 전 HEAD는 `1c4eea4`, master→origin/main입니다. 29단계의 Main/README 수정과
ResearchArchiveState GD/UID 추가가 미커밋 상태였으며 이를 보존했습니다.
실제 작업 파일 70개와 기존 로컬 GD/PS1 검증 자료 687개의 SHA-256 및 기존 diff를 보관했습니다.
현재 프로젝트는 Case 1개, Main과 10개 View Scene, 26개 GDScript, authored ResearchEntry 24개를 사용합니다.
Main의 Containment Confirm→Runtime 기록, Monitoring Timer/완료 검사, SUCCESS/FAILURE Route,
Incident/Broadcast/IncidentResult/Result/Log/discovery 및 RESULT Archive 승격 경계를 조사했습니다.

`PendingContainmentState`는 Main이 한 번 생성하는 작은 RefCounted 세션 상태입니다.
별도 Record 객체를 만들지 않고 `_rooms_by_case: Dictionary[String, String]`에
Case ID→실제 확정 Room ID만 저장합니다. `_case_order: Array[String]`은 최초 등록 순서를 보존합니다.
초/Timer/resolve_after_cases/결과/Incident/Resource/배열 인덱스를 저장하지 않습니다.
CaseRuntimeState, PendingContainmentState, ResearchArchiveState는 서로 참조하지 않는 독립 객체입니다.
세션은 Main 수명 동안 유지되며 앱 종료 후에는 저장되지 않습니다.

| 구조 판정 | 현재 책임 |
| --- | --- |
| CaseRuntimeState | 현재 Case의 플레이 사실 |
| PendingContainmentState | 나중에 결과를 처리할 Case별 격리 결정 |
| ResearchArchiveState | Runtime보다 오래 유지할 확보한 Research ID |
| MonitoringOutcomeData | 현재 prototype resolution 콘텐츠 |

이 책임 분리는 다음 Case로 Runtime을 교체해도 이전 제출과 Research를 유지할 기반입니다.
실제 handoff와 delayed resolver는 아직 없습니다.

| API | 정책 |
| --- | --- |
| `try_add_pending(case_id, room_id) -> bool` | 빈/공백 ID와 동일 Case 재등록을 false로 거부; 최초 결정만 저장 |
| `has_pending(case_id) -> bool` | 정확한 Case ID로 대기 결정 존재 여부 조회 |
| `get_pending_room_id(case_id) -> String` | Room 문자열 반환; 없는 Case는 빈 문자열, 가변 Record 노출 없음 |
| `get_pending_case_ids() -> Array[String]` | 최초 등록 순서의 배열 복사본 |
| `reset()` | Pending만 비움; Runtime/Archive 비변경 |

Main은 기존 Containment 요청의 Stage/활성 View/현재 Case와 Runtime ID 일치 조건을 유지합니다.
현재 Case 후보에서 요청 Room ID를 찾고 `try_confirm_containment_room()`이 성공한 직후에만,
current_case.case_id와 Runtime getter의 실제 확정 Room ID를 Pending에 전달합니다.
기존 Research 발견 승인도 같은 경계에서 유지합니다. 단순 선택/setup/Open/Back/실패한 Confirm은 등록하지 않습니다.
같은 Case의 기존 Pending 결정은 같은/다른 Room 재등록으로 덮어쓰지 않습니다.
Pending API가 false를 반환하며, 현재 debug Confirm 경로는 기존 기록을 보존하고 계속 기존 Runtime 정책을 따릅니다.
Runtime을 따로 reset한 뒤 같은 Case를 다시 Confirm해도 Pending의 최초 결정은 유지됩니다.

격리 제출과 결과 판정은 분리된 의미입니다. 이번 단계는 제출 상태만 마련합니다.
**자동 delayed resolution, progression counter, scheduler, resolve 메서드는 없습니다.**
현재 debug Monitoring은 기존처럼 Runtime의 SUCCESS/FAILURE를 기록하고 downstream 연결을 검증합니다.
이 결과는 최종 delayed gameplay resolution이 아니므로 Pending을 소비하거나 제거하지 않습니다.
따라서 debug RESULT 이후에도 해당 제출 ID가 남습니다. 최종 정상 경로에서 Timer를 제거하는 변경은
다음 Case handoff와 실제 delayed resolution이 동작할 때 진행할 대상입니다.

MonitoringView에는 debug 재생임을 밝히는 주석 두 줄,
MonitoringStageData.time_offset에는 prototype verification timing임을 밝히는 주석 한 줄만 추가했습니다.
MonitoringOutcomeData와 두 Schema의 필드/이름, Timer의 실행 코드, 모든 Scene, 원본 0/10/20초 콘텐츠는 보존했습니다.
어떤 Case/Shift 단위 또는 몇 Case 뒤에 결과가 나오는지는 정하지 않았습니다.

Archive도 기존 RESULT merge 경계를 유지합니다. 기존 API는 동일 Case에 발견 ID를 추가 merge하고
중복을 제거하므로 향후 별도 단계에서 `Containment 제출→현재 발견 merge`,
`Incident 완료→추가 발견 merge`를 구성할 수 있습니다. 지금 그 호출 시점을 이동하거나 Archive UI를 추가하지 않았습니다.

### 요청한 35개 항목의 작업 보고

| 번호 | 항목 | 구현·검증 결과 |
| --- | --- | --- |
| 1 | 작업 전 Git | `1c4eea4`, master→origin/main. 29단계 Main/README 수정과 Archive GD/UID 미추적 파일 유지. |
| 2 | Pending 구조 | 새 PendingContainmentState, RefCounted 세션 상태 하나. |
| 3 | 내부 저장 | typed Case→Room Dictionary와 Case 등록 순서 배열; ID 문자열만. |
| 4 | API | try_add_pending/has_pending/get_pending_room_id/get_pending_case_ids/reset. |
| 5 | Case 식별 | case_id 원문 문자열; Case당 최초 결정 한 개. |
| 6 | Room 저장 | Runtime 승인 성공 후 getter의 실제 확정 Room ID; index/Resource 미저장. |
| 7 | Confirm 경계 | 기존 Main Stage/활성/Case/후보 검증과 Runtime 승인 뒤에만 등록. |
| 8 | 선택 미등록 | 실제 Room 선택과 선택 없는 disabled Confirm 클릭에서 Pending 공백 확인. |
| 9 | Confirm 실패 | 이미 확정한 Runtime과 빈/공백/unknown/foreign Room 요청에서 미등록. |
| 10 | stale 요청 | 이전/분리/Tree 밖/queue-free Containment View 요청 미등록. |
| 11 | 중복 Case | 같은 Room/다른 Room 재등록 모두 false; 최초 Room과 순서 유지. |
| 12 | invalid 입력 | 빈/공백 Case·Room 거부, 기존 상태 비변경. |
| 13 | Case A/B | 독립 상태 검증으로 CASE_A→ROOM_A, CASE_B→ROOM_B 동시 유지. 실제 Case 추가 없음. |
| 14 | getter 보호 | ID 배열 duplicate, Room은 문자열 값; 외부 배열 reverse/append로 내부 상태 변경 불가. |
| 15 | Runtime reset | Pending/Archive 유지; Runtime 객체 교체 후에도 동일 세션 Pending 유지. |
| 16 | Pending reset | Runtime 이력·Room·결과·발견 및 Archive 동일; 반복 reset 가능. |
| 17 | Archive 독립성 | Archive reset은 Pending/Runtime을 지우지 않음; 세 상태 간 참조 없음. |
| 18 | Main 검증 | Case/Runtime ID 불일치, null Case/Runtime, 빈 Case 정보는 등록 거부. |
| 19 | Resource | 원본 Case/Containment/Outcome/Research 콘텐츠 snapshot과 파일 hash 보존. |
| 20 | Outcome 유지 | 파일·Result enum·필드·ID 연결·원본 콘텐츠 그대로. |
| 21 | Stage 유지 | time_offset 이름/타입/값 그대로; 검증용 시간임을 주석으로 명시. |
| 22 | Timer 의미 | prototype/debug playback. 최종 real-time 게임 규칙 아님; progression 단위/간격 미정. |
| 23 | Vertical Slice | 기존 Containment→Monitoring→SUCCESS/FAILURE→Incident/Result debug 경로 보존. |
| 24 | Archive incremental | 기존 추가 merge/중복 제거/최초 순서 지원 확인; API와 승격 시점 변경 없음. |
| 25 | SUCCESS 회귀 | Room02 정상 경로와 결과/요약/Archive 유지, Pending은 debug 완료 후에도 남음. |
| 26 | FAILURE 회귀 | Room01/03 × Option A/B/C 6경로의 Incident/Broadcast/IncidentResult/Result 유지. |
| 27 | Log 회귀 | authored/fallback/혼합, Stage gate/현재 발견/Open/Back/Monitoring 차단 유지. |
| 28 | Archive 회귀 | 실제 발견/순서 일치, 독립 reset, invalid ID/Case 방어, RESULT 재생성 비변경. |
| 29 | 전체 시스템 | 기존 이력/제한/확정/재생/결과/후속 콘텐츠/발견/세션 상태/stale/단일 View 검사. |
| 30 | 해상도/Stretch | 1920×1080, 1280×720, 1024×768 창 및 canvas_items/keep 보존. |
| 31 | 파싱/실행 | 아래 검증 기록 참조. |
| 32 | 실제 파일 | Pending GD/UID 추가; Main/README 수정, MonitoringView/StageData는 주석만. 삭제 없음. |
| 33 | 기존 변경 보존 | Archive GD/UID 및 29단계 승격 helper/API, 기존 README 보고 내용 보존. |
| 34 | 미구현 | 두 번째 Case/다음 Case 버튼/Campaign/scheduler/resolve 간격·실제 delayed 결과/Incident Queue/Archive UI/저장/Timer pause/Manager/최종 UI 없음. |
| 35 | 다음 단계 | 별도 요청에서 Case handoff와 과거 Case 콘텐츠 조회·Pending 소비 경계를 설계한 뒤 delayed resolution을 구현; 진행 단위/간격은 그때 결정. |

### 30단계 검증 기록

새 검증 자료는 Git에서 제외한 `.godot/verification/step30/`에만 있습니다.
Pending 단위/등록 경계 검사와 기존 22~29단계 전체 회귀를 headless 및 Windows GPU에서 실행합니다.
authored/fallback/혼합 UI 검사는 세 창 크기마다 정상 SUCCESS 1개와 FAILURE 6개 경로를
실제 입력으로 진행하며, 선택 전/후 Pending 공백, Confirm 직후 실제 Room 일치,
debug 완료/RESULT/Log 왕복/재시작에서 Pending/Archive/Runtime의 불변성을 함께 검사합니다.
원본 0/10/20초 debug 재생도 유지하고, 빠른 흐름 테스트만 독립 Resource 복사본의 offset을 0으로 변경합니다.
원본 콘텐츠는 변경하지 않습니다. 기대 경고 수를 검사하고, Resume은 입력/로그 hash와 성공 인증서가 일치할 때만 허용합니다.

Godot **4.7.1.stable.official.a13da4feb**에서 **129개 검사**가 모두 통과했습니다.
27개 제품 GDScript의 check-only를 포함한 headless 77개와 Windows GPU 52개 검사입니다.
GPU는 AMD Radeon RX 6800, OpenGL 3.3 Compatibility입니다. 새 Pending 단위/경계 검사는 두 모드에서
모두 오류/경고 0으로 완료했고, 기존 비정상 fixture의 경고 개수도 예상과 일치했습니다.
정상 SUCCESS 및 FAILURE 6경로, Research Log/discovery/Archive와 기존 전체 회귀도 통과했습니다.
최종 에디터 `--headless --editor --import --quit`는 exit 0이며 파싱/GDScript 오류와 경고가 없습니다.
프로젝트 Main 실행은 명령행으로 검증했으며 에디터 F5 키를 직접 누른 검증은 아닙니다.
이번 변경에서 별도 제품 코드 오류나 기존 기능의 회귀는 재현되지 않았습니다.

세 창 크기에서 authored/fallback/혼합 흐름을 검사하고 새 UI 캡처 **234개**를 생성했습니다.
주요 화면을 직접 확인했으며 전체 PNG의 크기/16:9 비율과 UI bounds 검사도 통과했습니다.
1024×768 창은 keep 설정에 따라 UI Viewport 캡처가 1024×576이며 레터박스 여백은 캡처에 포함하지 않습니다.
1920×1080 기준 UI, 초기 창 1280×720, canvas_items/keep, Main/모든 View Scene은 그대로입니다.

최종 `git status`, `git diff`, `git diff --check` 및 SHA-256 감사 결과:
작업 전 존재한 파일 70개 중 66개는 바이트 그대로이며,
Main/README 수정과 MonitoringView/MonitoringStageData의 주석 추가만 있습니다.
이번에 추가한 제품 파일은 Pending GD/엔진 생성 UID 두 개이고 삭제는 없습니다.
Main 함수 개수는 33개 그대로이며 `_ready()`와 Containment Confirm 처리만 변경했습니다.
Archive 승격을 포함한 기존 함수 31개와 29단계 Archive GD/UID는 그대로입니다.
Monitoring의 주석을 제외한 실행 코드/Stage Schema, 모든 원본 .tres와 기존 검증 자료 687개,
29단계부터 이전 README 보고도 보존했습니다.
검증 자료는 `validation-results.json`, `change-audit.json`, `immutability-evidence.json`과 개별 로그에 있습니다.
커밋/푸시는 하지 않았고 HEAD는 계속 `1c4eea4`입니다.

## 29단계 완료한 Case의 세션 Research Archive

작업 전 Git은 HEAD `1c4eea4`, `master` / `origin/main`이며 변경 파일이 없었습니다.
실제 저장소의 추적 파일 68개, 기존 로컬 GD/PS1 검증 자료 681개를 조사하고 SHA-256 기준을 보관했습니다.
프로젝트에는 Main과 10개 View Scene, 25개 GDScript, 테스트 Case 1개 및 authored ResearchEntry 24개가 있습니다.
Step25~28은 이미 커밋된 상태이므로 이번 작업에서는 기존 HEAD의 콘텐츠와 동작을 보존합니다.

Main이 두 메모리 상태를 소유합니다. `CaseRuntimeState`는 현재 플레이에서 확정한 사실을,
새 `ResearchArchiveState`는 완료한 Case의 발견 ID를 보관합니다. 둘 다 RefCounted이며
서로 참조하지 않습니다. Main이 해제되거나 앱을 종료하면 세션 기록도 사라집니다.
Runtime.reset()과 Archive.reset()은 서로 영향을 주지 않습니다.

Archive 내부는 `_entries_by_case: Dictionary[String, Array]`와 `_case_order: Array[String]`입니다.
Dictionary의 각 값은 merge 내부에서 만든 `Array[String]`이며 Case/Entry ID 문자열만 저장합니다.
동일 Case 안의 동일 Entry는 한 번만 보관하고, 다른 Case의 같은 Entry ID는 독립적으로 허용합니다.
Case는 최초 유효 Entry가 들어온 순서, Entry는 해당 Case의 최초 발견 순서를 유지합니다.
ID는 원문 문자열을 식별자로 사용하며 빈/공백뿐인 문자열을 거부합니다. 자동 정렬이나 ID 정규화는 없습니다.
빈 배열 또는 유효 Entry가 없는 merge는 빈 Case 항목을 만들지 않습니다. 기존 항목도 지우지 않습니다.

| API | 역할 |
| --- | --- |
| `merge_case_discoveries(case_id, entry_ids)` | 유효 문자열만 최초 발견 순서대로 추가; 중복 merge는 상태 동일 |
| `has_discovered_entry(case_id, entry_id)` | Case와 Entry 두 ID로 정확한 발견 여부 조회 |
| `get_discovered_entry_ids(case_id)` | 해당 Case Entry 배열의 복사본; 없는 Case는 빈 배열 |
| `get_archived_case_ids()` | 최초 등록 순서의 Case 배열 복사본 |
| `reset()` | Archive만 비움; 반복 호출 가능 |

정상 `MONITORING → RESULT` 또는 `INCIDENT_RESULT → RESULT` 진행 요청을 처리한 뒤,
Main의 `_archive_case_discoveries()`가 현재 Case/Runtime ID 일치와 RESULT/확정 결과를 확인합니다.
기존 `_get_valid_research_entries()`로 null, 빈 ID, 잘못된 enum, 중복 entry_id/Source 매핑을 제외하고,
Runtime 발견 순서를 그대로 순회하여 유효 ID만 전달합니다. 알 수 없는 ID는 경고 후 제외하며 나머지를 보존합니다.
RESULT 진입으로 Runtime에 새 발견을 추가하지 않습니다. `_show_view(RESULT)` 자체는 승격 경계가 아니므로
RESULT 재표시와 Log Open/Back은 merge조차 수행하지 않습니다. 정상 완료를 반복해도 merge 중복 정책이 적용됩니다.

현재 Log의 정보 공개 조건, authored/fallback 문구, Source of Truth는 기존과 같습니다.
Archive에서 발견한 ID만으로 현재 Case Log의 authored 문구가 열리지 않습니다.
fallback에는 가짜 연구 ID를 만들지 않으며 title/body_text와 콘텐츠 Resource 객체는 Archive에 저장하지 않습니다.
Main에는 소유 필드, 초기화 한 줄, 완료 경계 호출과 승격 helper 한 개만 추가했습니다.
기존 Runtime/Data/View/Scene/해상도 설정과 테스트 콘텐츠는 변경하지 않았습니다.

### 요청한 52개 항목의 작업 보고

| 번호 | 항목 | 구현·검증 결과 |
| --- | --- | --- |
| 1 | 작업 전 Git | `1c4eea4`, master→origin/main, 깨끗한 작업 트리. |
| 2 | Archive 구조 | `scripts/runtime/research_archive_state.gd`, RefCounted 상태 클래스 하나. |
| 3 | 내부 저장 | Case→문자열 Entry 배열 Dictionary와 Case 등록 순서 배열. |
| 4 | 식별 정책 | case_id + entry_id; 다른 Case의 동일 Entry ID는 별도 기록. |
| 5 | API | merge, has, Entry getter, Case getter, reset의 5개 API. |
| 6 | 입력 검증 | 빈/공백 Case 및 Entry를 저장하지 않음. |
| 7 | 중복 | 같은 Case/Entry는 최초 한 번만 저장; 반복 merge는 동일 상태. |
| 8 | Case별 순서 | Runtime discovery 순서 유지; 추가 merge는 새 ID만 뒤에 추가. |
| 9 | Case 등록 순서 | 최초 유효 Entry가 등록된 순서 유지; 재merge로 이동하지 않음. |
| 10 | getter 보호 | 두 Array getter 모두 복사본; 반환값 reverse/append/clear 검증. |
| 11 | Main 소유 | `_ready()`에서 research_archive를 한 번 생성. |
| 12 | 수명 분리 | Runtime과 Archive가 서로 참조하지 않는 별도 객체. |
| 13 | 승격 시점 | 활성 View의 정상 진행이 RESULT에 도달한 뒤. |
| 14 | RESULT 발견 아님 | Runtime discovery를 추가하거나 repair하지 않고 기존 ID만 승격. |
| 15 | SUCCESS | 실제 발견 5개(Profile/CCTV/EXP03/EXP01/Room02), 실패 관련 ID 없음. |
| 16 | FAILURE | Room01/03 × Option A/B/C의 6경로마다 실제 발견 9개와 Archive 순서 일치. |
| 17 | Case 불일치 | warning 후 merge 거부; OTHER_CASE로 잘못 등록하지 않음. |
| 18 | invalid discovery | UNKNOWN_RESEARCH 제외, 같은 배열의 유효 Profile ID는 보존. |
| 19 | fallback | 전체 fallback에서는 Archive가 비어 있음; CCTV/EXP03 혼합 fallback에도 가짜 ID 없음. |
| 20 | 중복 ResearchEntry | 기존 validator 재사용; ID/매핑 충돌의 모든 후보 제외, 무관한 유효 ID 보존. |
| 21 | 저장 대상 | ID 문자열만 저장; title/body/이름/Resource 저장 없음. |
| 22 | Log와 Archive | 현재 Log는 Runtime discovery와 Stage gate만 사용; Archive 조회 코드 없음. |
| 23 | Open/Back | 각 Stage의 왕복 전후 Runtime·Archive·콘텐츠 동일. |
| 24 | RESULT 재진입 | RESULT↔Log에서 Archive 비변경; 재생성 자체로 merge하지 않음. |
| 25 | RESULT 반복 | 3회 직접 RESULT 생성/왕복에도 새로운 정상 discovery를 Archive에 추가하지 않음. |
| 26 | Runtime reset | 발견 배열은 비워지고 이미 승격한 Archive ID는 유지. |
| 27 | Archive reset | Dictionary와 Case 등록 순서 모두 비움; 새 등록 순서도 검증. |
| 28 | reset 독립성 | Archive reset 전후 Runtime의 이력·Room·결과·확정 쌍·발견 ID 동일. |
| 29 | Case A/B | A=[ENTRY_01,ENTRY_02], B=[ENTRY_01,ENTRY_03] 독립 저장 확인. |
| 30 | 추가 merge | A에 ENTRY_02/ENTRY_03 재merge → [ENTRY_01,ENTRY_02,ENTRY_03]. |
| 31 | 빈 discovery | 신규 Case를 등록하지 않음; 기존 Case도 변경하지 않음. |
| 32 | 잘못된 Case ID | 빈/공백 Case merge는 기존 상태 비변경. |
| 33 | 발견 순서 | Profile→CCTV→EXP03→EXP01→Room 및 실패 후속 ID 순서 정확히 유지. |
| 34 | 콘텐츠 변경 | 독립 ResearchEntry의 title/body 변경에도 Archive ID 배열 동일. |
| 35 | Runtime 독립성 | merge/get/reset에서 Runtime 필드와 승인 호출 횟수를 변경하지 않음. |
| 36 | Resource 불변성 | 원본 및 독립 Case 콘텐츠 snapshot, 파일 SHA-256 동일. |
| 37 | Main 구조 | 소유/전달/전환 경계 유지; 별도 Manager나 추상화 분리 불필요. |
| 38 | 다중 Case | 실제 두 번째 Case, 선택/진행/로딩 시스템 없음; A/B는 상태 테스트만. |
| 39 | Save/Load | 없음; 세션 종료 후 기록 유지 없음. |
| 40 | Research Log 회귀 | authored/fallback/혼합, 발견 조건, Stage gate, 복귀, Monitoring 차단 유지. |
| 41 | 전체 회귀 | 기존 실험 제한/이력, 격리 확정, Monitoring 재생/결과, 사고/응답/후속 결과/요약 검사. |
| 42 | SUCCESS Route | PROFILE→CCTV→EXPERIMENT→CONTAINMENT→MONITORING→RESULT→PROFILE. |
| 43 | FAILURE Route | MONITORING→INCIDENT→BROADCAST→INCIDENT_RESULT→RESULT, 6경로. |
| 44 | stale/signal | 이전/Tree 밖/queue-free View와 중복·중첩 요청 차단; signal 연결 한 번. |
| 45 | 단일 View | 정상/왕복/재시작 단계 모두 ViewHost 자식 하나. |
| 46 | 세 해상도 | 1920×1080, 1280×720, 1024×768 창; canvas_items/keep와 UI bounds 유지. |
| 47 | 파싱/실행 | 아래 검증 기록 참조. |
| 48 | 발견한 문제 | 테스트의 정적 타입 검사 표현을 Variant로 수정. 미완료 RESULT 경고 2개도 기대 경고로 명시. 제품 코드 오류는 재현하지 않음. |
| 49 | 실제 파일 | Main/README 수정, Archive GD/엔진 생성 UID 추가. 삭제 없음. |
| 50 | 기존 변경 보존 | 작업 전 미커밋 파일 없음; 기존 28단계까지 커밋 내용 보존. |
| 51 | 미구현 | Archive UI/과거 Log/다중 Case/Campaign/Save/Load/점수/보상/수집률/Manager/최종 디자인 없음. |
| 52 | 다음 단계 | 별도 요청에서 읽기 전용 Archive 조회용 snapshot을 설계하는 지점부터 시작 가능. |

### 29단계 검증 기록

검증 스크립트와 로그는 Git에서 제외한 `.godot/verification/step29/`에 보관합니다.
`run_validation.ps1`은 기존 22~28단계 회귀 검사와 새 Archive 단위/경계 검사,
Archive 상태 비교를 추가한 authored/fallback/혼합 실제 UI 입력 테스트를 실행합니다.
headless와 Windows Compatibility GPU 모드를 모두 사용하고, 기존 20초 Monitoring 재생도 검증합니다.
비정상 입력 테스트는 알려진 경고 수를 정확히 검사하며 정상 흐름은 경고 없이 실행되어야 합니다.
실패 기록을 통과로 취급하지 않습니다. Resume은 동일 입력/로그 SHA-256과 성공 인증서가 있을 때만 재사용합니다.

Godot **4.7.1.stable.official.a13da4feb**에서 최종 **124개 검사**가 모두 통과했습니다.
26개 제품 GDScript check-only를 포함한 headless 74개와 Windows GPU 50개 검사입니다.
GPU는 AMD Radeon RX 6800, OpenGL 3.3 Compatibility를 사용했습니다. 정상 경로는 오류/경고 0이며,
비정상 fixture의 경고는 기대 개수와 일치했습니다. 새 경계 검사는 의도한 14개 경고를 각각 확인했습니다.
최종 에디터 `--headless --editor --import --quit`도 exit 0, 파싱/스크립트 오류 없이 완료했습니다.
프로젝트 Main 실행은 명령행으로 확인했으며 에디터 F5 키를 직접 누른 검증은 아닙니다.

SUCCESS 1개와 Room01/03 × Option A/B/C의 FAILURE 6개 경로를 authored/fallback/혼합 데이터로,
headless와 native에서 세 창 크기마다 실제 UI 입력으로 실행했습니다. Archive의 완료 이전 공백,
완료 직후 실제 발견 순서와의 일치, Open/Back/재시작에서의 불변성을 확인했습니다.
전체 authored는 SUCCESS 5개/FAILURE 9개 ID, CCTV·EXP03 authored를 뺀 혼합은 3개/7개 ID,
전체 fallback은 0개 ID와 빈 Case 목록입니다. 정상 Case에 미선택 Option/Result나 미래 Entry가 들어가지 않았습니다.
기존 0/10/20초 생산 데이터 재생도 수정 없이 실행했고 완료 후에만 RESULT에 도달했습니다.

새 로컬 UI 캡처 234개를 생성했습니다. 세 창 크기의 주요 화면과 Log를 직접 확인했고,
전체 캡처 PNG 헤더의 크기/16:9 비율과 UI bounds 검사도 통과했습니다.
1024×768 창의 Viewport 캡처는 keep 정책에 따라 1024×576이며 창의 레터박스 여백은 포함하지 않습니다.
기준 1920×1080, 초기 창 1280×720, canvas_items/keep 및 모든 Scene 파일은 보존했습니다.

최종 `git status`, `git diff`, `git diff --check`, SHA-256 감사 결과:
기존 추적 파일 68개 중 Main/README만 수정했고 나머지 66개는 바이트 그대로입니다.
Archive GD와 엔진 생성 UID 두 파일만 추가했으며 삭제는 없습니다.
이전 GD/PS1 검증 자료 681개와 28단계부터 이전 README 보고 내용도 보존했습니다.
Main의 기존 32개 함수 중 `_ready()`/`_on_advance_requested()`만 변경했고 승격 helper 하나를 추가했습니다.
나머지 기존 30개 함수는 동일합니다. 커밋/푸시는 하지 않았으며 HEAD는 `1c4eea4`입니다.
검증 결과는 `validation-results.json`, 보존 감사는 `change-audit.json`과 `immutability-evidence.json`에 있습니다.

## 28단계 test_case_01의 주요 Research 작성 콘텐츠 확장

작업 전 Git은 HEAD `c8c993d`, `master` / `origin/main`이며 Main Script, Runtime Script,
README에 27단계 미커밋 변경이 있었습니다. 25·26단계는 이미 HEAD에 포함된 상태였습니다.
전체 68개 추적 파일과 기존 로컬 GD/PS1 검증 자료 673개를 조사·백업한 뒤 작업했습니다.
실제 8종 SourceKind, Case의 모든 Source ID, 8개 기존 Research 매핑,
Main의 공개 조건/발견 처리와 authored/fallback 검증 코드를 확인했습니다.

이번 단계에서 프로젝트 파일은 `resources/cases/test_case_01.tres`와 `README.md`만 수정했습니다.
Core 버그를 재현하지 않았으므로 Main, Runtime, 모든 Data/View Script, Scene, project.godot,
25개 UID를 변경하지 않았습니다. Git의 Main/Runtime 수정 표시는 기존 27단계 변경입니다.
새 프로젝트 파일과 삭제 파일은 없으며 새 로컬 검증 자료는 `.godot/verification/step28/`에만 있습니다.

ResearchEntry는 **8개 → 24개**입니다. 기존 8개 entry_id와 SubResource ID/Source 매핑을
보존하며 title/body_text를 보완하고, 부족한 16개 authored Entry를 추가했습니다.
12개 Script 참조와 기존 게임 콘텐츠는 그대로이고, 추가 SubResource에 맞춰 load_steps만 57→73으로 갱신했습니다.
Monitoring 9개 Stage와 3개 Outcome은 Research 대상이 아니며 기존 time_offset/observation_text를 유지합니다.

원본 테스트 데이터는 구체적인 행동·피해·격리 조건을 제공하지 않습니다. 따라서 연구 문구도
대상/분류, 해당 임시 관찰·실험 결과의 기록, 확정한 Room/응답, 현재 공개된 사고·후속 결과만
짧게 요약합니다. 게임 화면 문자열을 그대로 복사하지 않았으며 행동·피해 수치·정답·새 세계관을 만들지 않았습니다.
Room 문구에는 성공/실패를 넣지 않고, Option에는 결과를 넣지 않습니다.
Incident/Broadcast/IncidentResult는 각각 해당 화면에서 공개된 정보만 사용합니다.

| SourceKind | 정확한 Source ID | Research entry_id | 변경 |
| --- | --- | --- | --- |
| PROFILE | TEST_PROFILE_01 | TEST_RESEARCH_PROFILE_01 | 문구 보완, 기존 ID 유지 |
| CCTV | TEST_CAM_01 | TEST_RESEARCH_CCTV_01 | 문구 보완, 기존 ID 유지 |
| EXPERIMENT | TEST_EXP_01 | TEST_RESEARCH_EXP_01 | 문구 보완, 기존 ID 유지 |
| EXPERIMENT | TEST_EXP_02 | TEST_RESEARCH_EXP_02 | 추가 |
| EXPERIMENT | TEST_EXP_03 | TEST_RESEARCH_EXP_03 | 추가 |
| CONTAINMENT | TEST_ROOM_01 | TEST_RESEARCH_ROOM_01 | 추가 |
| CONTAINMENT | TEST_ROOM_02 | TEST_RESEARCH_ROOM_02 | 문구 보완, 기존 ID 유지 |
| CONTAINMENT | TEST_ROOM_03 | TEST_RESEARCH_ROOM_03 | 추가 |
| INCIDENT | TEST_INCIDENT_01 | TEST_RESEARCH_INCIDENT_01 | 문구 보완, 기존 ID 유지 |
| INCIDENT | TEST_INCIDENT_03 | TEST_RESEARCH_INCIDENT_03 | 추가 |
| BROADCAST | TEST_BROADCAST_01 | TEST_RESEARCH_BROADCAST_01 | 문구 보완, 기존 ID 유지 |
| BROADCAST | TEST_BROADCAST_03 | TEST_RESEARCH_BROADCAST_03 | 추가 |
| BROADCAST_OPTION | TEST_OPTION_01_A | TEST_RESEARCH_OPTION_01_A | 추가 |
| BROADCAST_OPTION | TEST_OPTION_01_B | TEST_RESEARCH_OPTION_01_B | 문구 보완, 기존 ID 유지 |
| BROADCAST_OPTION | TEST_OPTION_01_C | TEST_RESEARCH_OPTION_01_C | 추가 |
| BROADCAST_OPTION | TEST_OPTION_03_A | TEST_RESEARCH_OPTION_03_A | 추가 |
| BROADCAST_OPTION | TEST_OPTION_03_B | TEST_RESEARCH_OPTION_03_B | 추가 |
| BROADCAST_OPTION | TEST_OPTION_03_C | TEST_RESEARCH_OPTION_03_C | 추가 |
| INCIDENT_RESULT | TEST_INCIDENT_RESULT_01_A | TEST_RESEARCH_RESULT_01_A | 추가 |
| INCIDENT_RESULT | TEST_INCIDENT_RESULT_01_B | TEST_RESEARCH_RESULT_01_B | 문구 보완, 기존 ID 유지 |
| INCIDENT_RESULT | TEST_INCIDENT_RESULT_01_C | TEST_RESEARCH_RESULT_01_C | 추가 |
| INCIDENT_RESULT | TEST_INCIDENT_RESULT_03_A | TEST_RESEARCH_RESULT_03_A | 추가 |
| INCIDENT_RESULT | TEST_INCIDENT_RESULT_03_B | TEST_RESEARCH_RESULT_03_B | 추가 |
| INCIDENT_RESULT | TEST_INCIDENT_RESULT_03_C | TEST_RESEARCH_RESULT_03_C | 추가 |

정상 Route에서는 주요 Source마다 authored 문구를 사용하고 Monitoring만 derived로 표시합니다.
EXP03도 이제 실행 성공 후 `TEST_RESEARCH_EXP_03`을 발견합니다. 실행하지 않은 EXP02 등은 계속 제외됩니다.
독립 혼합 Case는 CCTV/EXP03 authored Entry만 제거하여 Profile/EXP01/Room 및 나머지 authored를 유지합니다.
authored를 전부 제거한 Case의 기존 fallback 흐름도 유지합니다. 실제 플레이에서는 Entry 24개를 일괄 발견하지 않습니다.

### 요청한 61개 항목의 작업 보고

| 번호 | 항목 | 결과 |
| --- | --- | --- |
| 1 | 작업 전 Git | `c8c993d`, Main/Runtime/README의 27단계 미커밋 변경 3개 확인·보존. |
| 2 | 기존 authored 수 | 8개, 8종 SourceKind마다 1개인 부분 coverage. |
| 3 | 작업 후 authored 수 | 24개, 요청된 주요 Source 전체; Monitoring 제외. |
| 4 | 추가/보완 Source | 위 매핑 표의 16개 추가/8개 문구 보완. 기존 Source/entry ID 변경 없음. |
| 5 | Profile | 대상·분류·임시 기본 정보만 요약, CCTV/실험 정보 없음. |
| 6 | CCTV | 현재 카메라의 임시 observation만 기록, 실험·격리 결과 없음. |
| 7 | EXP01 | 기존 ID 유지, 해당 실험의 임시 결과 기록으로 보완. |
| 8 | EXP02 | 독립 authored 추가, EXP02 단독 실행 검증. |
| 9 | EXP03 | 독립 authored 추가, 단독 및 EXP03→EXP01 실행 검증. |
| 10 | Room01 | 확정한 Room01 기록 추가; FAILURE 암시 없음. |
| 11 | Room02 | 기존 ID 유지, 확정 기록만 작성; SUCCESS 암시 없음. |
| 12 | Room03 | 확정한 Room03 기록 추가; FAILURE 암시 없음. |
| 13 | Incident01 | 현재 사고 화면의 Room01 실패 연관 정보만 요약. |
| 14 | Incident03 | 현재 사고 화면의 Room03 실패 연관 정보만 요약. |
| 15 | Broadcast01 | incident01의 현재 emergency prompt, 응답 요구만 기록. |
| 16 | Broadcast03 | incident03의 현재 emergency prompt, 응답 요구만 기록. |
| 17 | Option01 A/B/C | 각각 확정한 응답만 기록, B의 기존 ID 유지; 정답·피해·결과 없음. |
| 18 | Option03 A/B/C | 각각의 확정 응답 기록 3개 추가. |
| 19 | IncidentResult01 A/B/C | 각 응답 후 공개된 임시 결과만 요약, B의 기존 ID 유지. |
| 20 | IncidentResult03 A/B/C | 각각 연결된 임시 결과 기록 3개 추가. |
| 21 | entry_id 유일성 | 24개 nonblank/유일, 기존 TEST_RESEARCH_* 규칙 유지. |
| 22 | Source 매핑 유일성 | 실제 24개 kind+ID 쌍과 authored 매핑 집합이 정확히 일치, 충돌 없음. |
| 23 | 배열 순서 독립 | authored/실험/Room/Outcome/Incident/Broadcast/Option/Result 배열을 역순으로 해도 ID 연결 유지. |
| 24 | 미실행 실험 | 전체 authored가 있어도 초기/선택 상태와 다른 실험 Entry는 미발견·비노출. |
| 25 | 실행 순서 | Log는 Runtime의 EXP03→EXP01 순서를 유지, 연구 배열 순서로 바뀌지 않음. |
| 26 | Confirm 전 Room | 선택만 한 Room의 발견 ID/Entry 없음. |
| 27 | Confirm 후 Room | Room01/02/03 각각 정상 Confirm 후 정확한 authored 발견. |
| 28 | Incident gate | FAILURE에서 실제 Incident 표시 후 발견, 이전 Stage에는 Entry 없음. |
| 29 | Broadcast gate | 실제 Broadcast 표시 후 발견, Incident Stage에서 미래 Entry 없음. |
| 30 | Option Confirm 전 | 선택만으로 발견하지 않음; authored가 있어도 Entry 없음. |
| 31 | Option Confirm 후 | 현재 Broadcast의 정상 Confirm 승인 후 해당 Option만 발견. |
| 32 | IncidentResult gate | Option Confirm 시에는 미발견, 결과 View 표시 뒤 발견; BROADCAST에서는 결과 Entry 없음. |
| 33 | SUCCESS | 실패 authored가 모두 있어도 Incident/Broadcast/Option/IncidentResult 미발견·비노출. |
| 34 | FAILURE01 A/B/C | 세 응답 각각 현재 Option과 대응 결과 authored, 다른 응답 비노출. |
| 35 | FAILURE03 A/B/C | 세 응답 각각 정확한 03 콘텐츠, 01 경로 정보 누출 없음. |
| 36 | 실제 발견 coverage | 매 Stage의 ID 배열이 실제 표시/승인한 authored Source 목록과 일치. |
| 37 | 발견 순서 | Profile→CCTV→실행 순서 Experiment→확정 Room→Incident→Broadcast→Option→IncidentResult. |
| 38 | 혼합 검증 | Profile/EXP01/Room authored + CCTV/EXP03 fallback의 전체 7개 Route 검사. |
| 39 | 제거 fallback | authored 24개 각각 제거해 해당 Source만 derived로 복귀; 전체 제거 Case도 정상. |
| 40 | invalid Entry | null/빈·공백 ID/빈 Source ID/잘못된 kind는 경고·미발견·fallback. |
| 41 | 중복 Source | 충돌 모두 제외, 배열 어느 순서에서도 첫 항목을 임의 사용하지 않음. |
| 42 | 중복 entry_id | 서로 다른 Source의 동일 ID는 모두 제외, 발견하지 않음. |
| 43 | orphan | Resource에 존재해도 실제 Source 공개·승인 없이 자동 Entry/발견 없음. |
| 44 | Main 변경 | 이번 단계 변경 없음, Step27 SHA-256 유지. |
| 45 | Runtime 변경 | 이번 단계 필드/API/reset 의미 변경 없음, Step27 SHA-256 유지. |
| 46 | View/Scene 변경 | 전체 Script/Scene 변경 없음, UI 요소/색상/필터 추가 없음. |
| 47 | Schema 변경 | Data Script/typed export/SourceKind 변경 없음, 기존 구조만 사용. |
| 48 | Resource 불변 | 실행 전후 디스크 SHA-256와 메모리 fingerprint 비교, 실행 중 원본 mutation 없음. |
| 49 | Open/Back | 기존 8개 허용 Stage·원래 Stage 복귀·확정 상태 복원·discovery 보존, MONITORING 차단. |
| 50 | 전체 회귀 | 선택/실행/limit/이력/격리/20초 Monitoring/Incident/Broadcast Confirm/결과/요약/Log/discovery 유지. |
| 51 | SUCCESS Route | 기존 Profile→CCTV→Experiment→Containment→Monitoring→Result→Profile 유지. |
| 52 | FAILURE Route | 기존 Incident→Broadcast→IncidentResult→Result 경로 및 두 Room×세 Option 유지. |
| 53 | stale/signal | detached/queued/replaced/wrong-stage/Case 소속 불일치/위조 요청 차단, 버튼·요청 연결 1개. |
| 54 | 단일 View | 전환·Open/Back마다 ViewHost 자식 1개, 이전 View 해제. |
| 55 | 해상도/Stretch | 1920×1080, 1280×720, 1024×768 창 검증. 마지막 창의 렌더 영역은 keep 비율의 1024×576이며 여백 유지; canvas_items/keep/resizable 보존. |
| 56 | 파싱/실행 | Godot 4.7.1 정규 119건(25개 GDScript check-only 포함), 최종 editor import 통과. 종료 0/오류 0, 정상 시나리오 경고 0. |
| 57 | 문제·해결 | 기존 8개/부분 authored fixture 전제는 독립 로컬 검증 복사본으로 유지하고 24개 coverage 검사를 추가. 추가 테스트의 조건부 배열 할당을 typed Array.assign으로 수정 후 재검사. 프로젝트 Core 버그와 미해결 오류 없음. |
| 58 | 실제 변경 파일 | Step28: test_case_01.tres, README. 누적 Git diff는 Step27 Main/Runtime 포함 4파일. 생성/삭제 프로젝트 파일 0개. |
| 59 | 미커밋 보호 | 시작 시 Main/Runtime 바이트 동일, README 이전 27단계 이하 보고 보존, 기존 검증 673개 보존; 커밋/push 없음. |
| 60 | 미구현 | 새 게임 시스템/영구·다중 Case Archive/Campaign/저장/보상·점수·수집률/Monitoring Research/Timer 정책/Validator/Manager/검색·필터/최종 UI 없음. |
| 61 | 다음 단계 | 각 Source의 실제 콘텐츠가 준비되면 해당 authored 요약을 보완하고 현재 발견·공개 경계를 유지해 검증하기 좋음. |

실행·검증 결과는 `.godot/verification/step28/validation-results.json`, `final-import.log`,
파일 보존 감사는 `preservation-audit.json`, 최종 증거 목록은 `final-evidence.json`에 기록했습니다.
authored/혼합/전체 fallback의 7개 Route × 3개 크기 × headless/native에서
126개 Route와 2,178회 실제 버튼 Open/Back을 확인했습니다. 3개 Experiment의 독립 실행,
24개 authored 개별 제거, invalid/duplicate/orphan 및 stale/위조 요청도 검사했습니다.
GPU 캡처는 authored/혼합/fallback 각각 78개, 총 234개이며 세 크기의 화면을 직접 확인했습니다.
파일명의 크기는 테스트 창 크기입니다. Viewport texture 캡처는 콘텐츠 영역이므로
1024×768 창에서는 PNG가 1024×576입니다. 이는 기존 keep 비율 유지 동작입니다.
정상 검사에는 경고가 없고, 부정 테스트의 경고는 사전에 정한 개수와 일치했습니다.
66개 나머지 추적 파일과 기존 검증 소스 673개는 바이트 그대로이고 기존 8개 Research ID/매핑 및
원본 게임 Source/Outcome/Monitoring 데이터도 보존했습니다. `git diff --check`를 통과했습니다.
이 폴더는 Git에서 제외되며 게임에서 로드하지 않습니다. 이번 커밋/push는 하지 않았습니다.

## 27단계 현재 Case의 authored Research 발견 기록

작업 전 전체 저장소, 설정, Main/10개 View, Data/Resource, Runtime, Stage gate와
기존 로컬 검증 자료를 조사했습니다. Git은 `master` / `origin/main`, HEAD `c8c993d`이고
변경 없는 상태였습니다. 요청문에 언급된 25·26단계 미커밋 변경은 이미 이 커밋에 포함되어 있습니다.
기존 68개 추적 파일과 로컬 검증 GD/PS1 664개의 SHA-256을 먼저 기록했습니다.

이번 변경은 `scripts/main/main.gd`, `scripts/runtime/case_runtime_state.gd`, `README.md` 세 파일입니다.
새 프로젝트 파일과 삭제 파일은 없습니다. 모든 Scene/View Script/Data Script/UID와
`test_case_01.tres`, `project.godot`는 그대로 유지합니다.

Runtime에 `_discovered_research_entry_ids: Array[String]` 하나를 추가했습니다.
`try_discover_research_entry(entry_id) -> bool`은 첫 유효 ID만 append하고 빈 ID/중복은 false,
`has_discovered_research_entry(entry_id) -> bool`은 포함 여부,
`get_discovered_research_entry_ids() -> Array[String]`은 복사본을 반환합니다.
정렬 없이 실제 첫 발견 순서를 유지하며 reset만 목록을 비웁니다.
콘텐츠 Resource에는 발견 플래그를 넣지 않았고 디스크 저장과 다른 Case 공유는 없습니다.

Main의 `_try_discover_research_entry(kind, source_id)`는 기존 Step26의
`_get_valid_research_entries()`와 `_find_research_entry()`를 재사용합니다.
null/빈 ID/invalid kind/중복 entry_id/중복 kind+source_id 정책과 경고를 유지하며
유효한 authored 매핑이 없으면 Runtime ID를 만들지 않습니다.
`_has_current_case_runtime()`는 유효 Case ID/이름과 Runtime 소속 일치를 검사합니다.
`_discover_displayed_research_entry()`는 현재 Stage/활성·표시 View와 Source를 확인합니다.

| 사건 | 발견 시점 |
| --- | --- |
| PROFILE / CCTV | 해당 Case의 유효 콘텐츠를 가진 View를 트리에 추가하고 실제 활성 표시한 뒤 |
| EXPERIMENT | 실제 후보 ID 검증 후 Runtime 실행 기록이 성공한 뒤; 진입/선택은 기록하지 않음 |
| CONTAINMENT | 실제 Room 후보의 Confirm 기록이 성공한 뒤; 선택은 기록하지 않음 |
| INCIDENT | FAILURE의 유효 Incident View를 실제 표시한 뒤 |
| BROADCAST | FAILURE의 유효 Broadcast View를 실제 표시한 뒤; Option/Result를 미리 기록하지 않음 |
| BROADCAST_OPTION | 기존 Broadcast/Option/Result 연결 재검증과 Runtime Confirm이 성공한 뒤 |
| INCIDENT_RESULT | 확정 Option에 연결된 유효 결과 View를 실제 표시한 뒤 |
| MONITORING / RESULT / Log Open·Back | 새로운 발견 없음 |

`_show_view(stage, discover_displayed_source=true)`의 일반 전환은 표시 후 발견을 기록합니다.
Log Back은 `_show_view(return_stage, false)`로 돌아오므로 독립 테스트에서 발견 기록이
빠져 있어도 Open/Back 자체로 복구하거나 해금하지 않습니다. 이 인자는 Main 내부 이동 처리에만 사용합니다.
Snapshot의 기존 Source 공개 조건과 순서는 그대로입니다. `_append_source_research_entry()`에서
유효 authored ID의 현재 Runtime 발견 여부를 추가로 검사하고, 발견되지 않았으면 기존 fallback을 사용합니다.
ResearchLogView는 여전히 category/source_id/title/body_text만 표시합니다.

### 요청한 58개 항목의 구현·검증 보고

| 번호 | 항목 | 결과 |
| --- | --- | --- |
| 1 | 작업 전 Git | HEAD `c8c993d`, 깨끗한 `master`, `origin/main` 추적. 전체 구조와 68개 파일 확인. |
| 2 | Runtime discovery | 현재 Case 전용 private typed ID 배열 1개; 기존 6필드와 합쳐 7필드. |
| 3 | Runtime API | try_discover / has_discovered / get_discovered 세 API 추가. |
| 4 | 중복 정책 | 빈/공백 ID와 기존 ID는 false; ID당 최초 1회만 기록. |
| 5 | 순서 | append 순서 유지. C→A→B API 테스트 및 역순 Resource 배열의 실제 Route 검사. |
| 6 | reset 변경 | 기존 Case ID/게임 상태 초기화에 발견 배열 clear 한 줄 추가. |
| 7 | Main helper | Case 소속, 표시 사건, kind+ID 발견의 작은 helper 3개. |
| 8 | 유효성 재사용 | Step26 검증·검색 함수 원문 유지, 별도 Validator 없음. |
| 9 | PROFILE 시점 | 활성 표시 후 발견; 잘못된 Case/ID/표시 필드, 숨김/미생성/이전 View 제외. |
| 10 | CCTV 시점 | 활성 표시 후 발견; PROFILE 시점에는 CCTV 미발견. |
| 11 | Experiment 시점 | 후보 ID 검증 + Runtime 실행 성공 직후. 초기 진입/선택 제외. |
| 12 | 실행 실패 | blank/unknown/orphan/limit/잘못된 Stage·Case/비활성 요청으로 이력·발견 변화 없음. |
| 13 | 실행 중복 | EXP01 재요청 거부; 게임 이력과 발견 ID 추가 없음. |
| 14 | Containment 시점 | 선택은 미발견; Room02 Confirm 성공 직후 authored ID 1회. |
| 15 | Confirm 실패 | invalid/이미 확정된 Room/이전 View 요청에서 새 발견 없음. |
| 16 | Incident 시점 | FAILURE의 실제 유효 표시; SUCCESS 및 invalid 표시 데이터 제외. |
| 17 | Broadcast 시점 | 실제 유효 표시에서 Broadcast ID만 발견. |
| 18 | Option 시점 | 선택은 미발견; 정상 Confirm 승인 후 해당 Option ID만 발견. |
| 19 | IncidentResult 시점 | Option Confirm 시에는 미발견; 결과 View 실제 표시 후 발견. |
| 20 | Monitoring | SourceKind/Stage ID/발견 기록 추가 없이 기존 derived Log 유지. |
| 21 | authored 조건 | 기존 공개 조건 AND 유효 authored 매핑 AND 현재 Runtime의 발견 ID. |
| 22 | undiscovered 처리 | 공개 Source는 derived fallback, 미래 Source는 Entry 자체 제외. |
| 23 | fallback | EXP03 및 authored가 전혀 없는 Case의 전체 Route 보존; 가짜 ID 없음. |
| 24 | ResearchLogView | Script/Scene/Snapshot/Entry 변경 없음. |
| 25 | Profile 검사 | 시작 직후 PROFILE ID 1개, Log authored 문구와 실제 Label 일치. |
| 26 | CCTV 검사 | 진입 전 ID 없음, 실제 진입 후 ID 추가; Log 복귀 시 중복 없음. |
| 27 | EXP authored | EXP01 승인 후 ID 발견과 authored 표시 확인. |
| 28 | EXP fallback | EXP03→EXP01 실제 실행 순서, EXP03 derived 유지와 발견 ID 미생성 확인. |
| 29 | Containment 검사 | Room02 선택/확정 구분, 재확정 차단, authored 표시 확인. |
| 30 | FAILURE 순서 | Room01/B에서 Profile→CCTV→EXP01→Incident01→Broadcast01→Option01-B→IncidentResult01-B. |
| 31 | SUCCESS 미발견 | Room02 Route에 Incident/Broadcast/Option/IncidentResult 발견 ID 없음. |
| 32 | Open/Back 영향 | 매 이동 전후 7개 Runtime 필드 비교; 누락 discovery 독립 상태에서도 변화 없음. |
| 33 | RESULT 영향 | 정상·독립 누락 상태 모두 RESULT 진입으로 일괄 발견하지 않음. |
| 34 | 재진입 | Open/Back의 View 재생성에 발견 목록 보존, 선택만 기존 정책대로 초기화. |
| 35 | 반복 생성 | Incident/Broadcast/IncidentResult 반복 표시에도 최초 ID 1개. |
| 36 | stale discovery | 승인 3종과 표시 5종에 detached/queued/replaced/wrong-stage 차단 확인. |
| 37 | 위조 discovery | unknown EXP/Room, 잘못된 Broadcast/Option, SUCCESS Confirm, Case 소속 불일치 차단. |
| 38 | 중복 Source | 충돌 모두 제외, 경고, 배열 순서와 관계없이 어느 ID도 미발견. |
| 39 | 중복 entry_id | 서로 다른 Source의 동일 entry_id 모두 제외, 경고, 순서 독립. |
| 40 | reset 결과 | 게임 이력/Room/결과/확정 쌍/발견 목록 초기화와 다른 인스턴스 보존. |
| 41 | Runtime 독립성 | 발견 API는 게임 6필드 보존; 기존 승인 API는 발견 목록 보존. |
| 42 | getter 보호 | 반환 배열 clear/append로 내부 배열과 포함 여부를 바꿀 수 없음. |
| 43 | Resource 불변 | 메모리 fingerprint 및 디스크 SHA-256 검사, 원본 Case/authored/콘텐츠 불변. |
| 44 | 이중 gate | 강제 future ID도 PROFILE/BROADCAST gate, 미실행·미확정 gate 및 SUCCESS 정책 우회 불가. |
| 45 | Open Stage | 기존 8개 허용, MONITORING/LOG/unknown 금지, return Stage 정책 보존. |
| 46 | SUCCESS Route | Profile→CCTV→Experiment→Containment→Monitoring→Result→Profile 정상. |
| 47 | FAILURE Route | 두 실패 Room의 A/B/C 전부 Incident→Broadcast→IncidentResult→Result 정상. |
| 48 | Log 회귀 | authored/fallback, 동적 목록, 정확한 문구, 순서, 미래 차단, 복귀·확정 복원 검사. |
| 49 | 전체 회귀 | 기존 선택/실행/limit/이력/격리/20초 Monitoring/결과/Incident/Broadcast/요약/lifecycle/alternate Case 유지. |
| 50 | signal/stale | 공용 버튼과 요청 연결 1개, 이전·nested·잘못된 return 요청 차단. |
| 51 | 단일 View | 전환/Open/Back 후 ViewHost 자식 1개, 이전 View 해제 확인. |
| 52 | 해상도/Stretch | 1920×1080, 1280×720, 1024×768 실제 렌더·레이아웃 검사; canvas_items/keep 유지. |
| 53 | 파싱/실행 | Godot 4.7.1 정규 109건(25개 GDScript check-only 포함), 보충 2건, 최종 import 1건 모두 종료 0/오류 0. 정상 시나리오 경고 0. |
| 54 | 문제·해결 | EXP callback의 unknown ID 승인 가능성을 후보 검증으로 차단. invalid Case 조기 거부로 기존 Broadcast 부정 테스트 경고가 27→26건; 새 테스트의 중복 경고 8건을 명시. 미해결 오류 없음. |
| 55 | 실제 변경 | Main Script, Runtime Script, README만 수정. 생성/삭제 프로젝트 파일 0개. |
| 56 | 이전 변경 보호 | 25·26단계는 이미 커밋 상태였고 그대로 보존. 65개 나머지 추적 파일 및 기존 로컬 검증 664개 불변. 이번 커밋/push 없음. |
| 57 | 미구현 | 영구 저장/Case 공유/Archive/Campaign/보상·점수·수집률/Monitoring Research/Log Timer 정책/검색·필터/Validator/Manager/최종 UI 추가 없음. |
| 58 | 다음 단계 | 현재 단일 Case의 authored 기록 콘텐츠를 작성하고 정상 승인·표시 시점과 공개 gate를 유지하며 검증 사례를 늘리기 좋음. |

검증 자료는 Git에서 제외되는 `.godot/verification/step27/`에만 둡니다.
기존 검증 코드는 수정하지 않고 Step27의 실제 발견 조건을 확인하는 wrapper와 독립 테스트를 추가했습니다.
정규 전체 검사 `validation-results.json`, 보충 edge 로그 `supplemental_headless.log` / `supplemental_native.log`,
최종 `final-import.log`, 파일 보존 감사 `preservation-audit.json`에 결과를 기록했습니다.
authored/fallback의 7개 Route × 3개 크기 × headless/native에서 총 84개 Route와 1,452회 실제 버튼 Open/Back을 확인했습니다.
156개 GPU 캡처 중 세 크기의 authored Log 화면을 직접 확인했고, 전체 자동 배치/문구/스크롤 검사를 통과했습니다.
부정 테스트는 예상된 경고 개수를 검사하여 허용했고, 파싱/Script/실행 오류는 없습니다.
Main의 기존 29개 함수 중 23개와 Runtime의 기존 18개 함수 중 reset을 제외한 17개 원문을 보존했습니다.
25·26단계 이하의 이전 보고 내용도 그대로 유지했습니다. `git diff --check`는 통과했고 변경 파일은 위 세 파일뿐입니다.

## 26단계 선택적 Research Log 작성 콘텐츠

작업 전 HEAD는 `345d93fe3539edee39657b9ee76ccd52765f9fcc`, master→origin/main이었습니다.
25단계13파일 미커밋 변경을 확인하고 현재 원본66개/24GDScript/24UID/11Scene/11개 콘텐츠 Script,
Main Snapshot·Stage gate·ID helper·typed Entry·Runtime·테스트 .tres·설정·README와 기존 검증655개의 해시를 보관했습니다.
25단계의 View/접근/Back/Runtime 정책과 보고는 보존했습니다.

```text
CaseData.research_entries: Array[ResearchEntryData]
  → Main: 현재 Open의 로컬 유효 후보 배열 (null/ID/enum/중복 검증)
  → 기존 Stage gate + Runtime 이력/확정 조건으로 Source Entry 생성
  → source_kind + source_id 정확히 일치하는 작성 문구 선택
  → 기존 category/source_id + 선택된 title/body_text 문자열 Snapshot
  → 변경 없는 ResearchLogView.setup()
```

`ResearchEntryData`는 Resource이며 entry_id, SourceKind enum, source_id, title, multiline body_text만 가집니다.
SourceKind 값은 PROFILE=0/CCTV=1/EXPERIMENT=2/CONTAINMENT=3/INCIDENT=4/BROADCAST=5/BROADCAST_OPTION=6/INCIDENT_RESULT=7입니다.
source_id는 각각 profile_id/camera_id/experiment_id/room_id/incident_id/broadcast_id/option_id/result_id를 그대로 사용합니다.
entry_id는 작성 콘텐츠의 안정적인 ID이며 지금은 Runtime/Save/Snapshot에 저장하지 않습니다.
CaseData에 typed 배열 한 줄만 추가했고 기존 다른10개 콘텐츠 Script의 Schema에는 필드를 추가하지 않았습니다.

Main의 `_get_valid_research_entries()`는 매 Snapshot마다 현재 Case 배열을 읽어 임시 후보를 만들고,
`_find_research_entry()`는 후보에서 kind+ID로 검색합니다. `_append_source_research_entry()`는 기존 Entry의
category/source_id를 유지하면서 title/body_text만 선택합니다. 콘텐츠를 갱신하거나 별도 Validator 객체를 만들지 않습니다.
null, 공백 ID, 범위 밖 enum은 경고 후 제외합니다. 같은 kind+ID는 모든 충돌 항목을 제외하므로 첫 항목을 선택하지 않습니다.
중복 entry_id도 모든 충돌 항목을 경고/제외하는 정책입니다. 유효한 빈 title/body_text는 작성 의도로 사용합니다.
유효하지만 현재 Source에 연결되지 않는 orphan은 자동 Entry를 만들지 않고 조용히 무시합니다.
원래 Source Resource가 누락되었으면 작성 문구가 있더라도 기존 unavailable 처리로 남습니다.

Stage gate, 실행 순서, Confirm, 최종 결과와 Log Open/Back은 바꾸지 않았습니다.
작성 데이터의 존재는 공개 시점을 결정하지 않습니다. Monitoring Stage는 기존 offset/observation_text 기반이며,
Kind나 stage_id를 추가하지 않았습니다. Snapshot Entry 네 문자열과 ResearchLogView/모든 Scene은 이번 단계 변경이 없습니다.

### 26단계 테스트 콘텐츠

| SourceKind | source_id | entry_id |
| --- | --- | --- |
| PROFILE | TEST_PROFILE_01 | TEST_RESEARCH_PROFILE_01 |
| CCTV | TEST_CAM_01 | TEST_RESEARCH_CCTV_01 |
| EXPERIMENT | TEST_EXP_01 | TEST_RESEARCH_EXP_01 |
| CONTAINMENT | TEST_ROOM_02 | TEST_RESEARCH_ROOM_02 |
| INCIDENT | TEST_INCIDENT_01 | TEST_RESEARCH_INCIDENT_01 |
| BROADCAST | TEST_BROADCAST_01 | TEST_RESEARCH_BROADCAST_01 |
| BROADCAST_OPTION | TEST_OPTION_01_B | TEST_RESEARCH_OPTION_01_B |
| INCIDENT_RESULT | TEST_INCIDENT_RESULT_01_B | TEST_RESEARCH_RESULT_01_B |

제목은 `TEST RESEARCH: ...`, 본문은 `Research note override for ... Development validation content only.`로 구분합니다.
EXP03/Room01·03/Incident03/Broadcast03/다른 응답·결과는 작성 문구를 두지 않아 fallback을 검증합니다.
기존 화면용 문구와 기존 콘텐츠 Resource는 그대로이며 별도 .tres 파일을 만들지 않고 현재 테스트 Case에8개 내장 Resource만 추가했습니다.

### 26단계 요청 55항목 보고

| 번호 | 항목 | 처리 / 검증 |
| --- | --- | --- |
| 1 | 작업 전 Git | HEAD345d93f, 25단계13수정 미커밋. 실제 저장소/소스66개/기존 검증655개 조사·해시 보관. |
| 2 | ResearchEntryData | Resource, typed export5필드; 작성 콘텐츠만. |
| 3 | SourceKind | 명시적 enum8종, Monitoring Stage 없음. |
| 4 | entry_id | 작성 콘텐츠 고유 ID, Runtime/Save/Snapshot에 기록하지 않음. |
| 5 | source_id | 기존 Source ID 그대로, index 연결 없음. |
| 6 | CaseData | research_entries: Array[ResearchEntryData]=[] 한 줄 추가; 기존 Case는 빈 배열 fallback. |
| 7 | 기존 Schema | 다른10개 기존 콘텐츠 Script와 Runtime 그대로, research_text/research_entry_id 일괄 추가 없음. |
| 8 | 검색 helper | Main의 작은 검증·kind+ID 검색·문구 선택 helper3개. 별도 시스템 없음. |
| 9 | 매핑 | kind+source_id 동시 정확 비교; 서로 다른 Kind가 같은 ID를 쓰는 충돌 예도 정상 분리. |
| 10 | 작성 우선 | 유효하고 유일한 authored title/body_text만 우선. |
| 11 | fallback | 없음/잘못됨/충돌이면 기존 derived Entry를 유지; Source 누락은 unavailable 유지. |
| 12 | invalid | null/빈·공백 ID/enum -1·999 경고 및 fallback. |
| 13 | 중복 Source | 관련 후보 전부 제외/경고; 배열 앞/뒤 모두 같은 fallback. invalid ID 후보와 충돌해도 임의 선택 없음. |
| 14 | 중복 entry_id | 경고하며 충돌 후보 전부 제외; 아직 미공개 Source와 중복되어도 동일 정책. |
| 15 | 배열 순서 | 모든 작성 항목을 역순으로 바꾼 정상 경로, 중복/제거 배열 역순도 결과 동일. |
| 16 | 테스트 구성 | 현재 Case에8종 각1개, entry_id 고유. 미작성 Source도 유지. |
| 17 | Profile 작성 | Log만 TEST RESEARCH 문구; Profile 화면 원본 텍스트 보존. |
| 18 | CCTV 작성 | Log만 작성 문구; CCTV 화면 원본 텍스트 보존. |
| 19 | Experiment 작성 | 실제 실행한 EXP01에서 작성 title/body 표시. |
| 20 | 미실행 차단 | EXP01 데이터가 존재해도 실행 전/선택만 한 상태에서는 Entry 없음. |
| 21 | Experiment fallback | 실행한 EXP03은 기존 display_name/description/result_text 그대로. |
| 22 | 실행 순서 | 실제03→01 순서; 작성 배열 순서와 무관. |
| 23 | Containment 작성 | 확정 Room02에서 작성 문구 사용. |
| 24 | 미확정 Room | Room02 임시 선택만으로는 Entry 없음. |
| 25 | Incident 작성 | FAILURE의 Incident01 진입 이후 사용, SUCCESS에는 없음. |
| 26 | Broadcast 작성 | BROADCAST부터 Broadcast01 작성 문구 표시. |
| 27 | Option 작성 | 정상 Confirm한01-B만 작성 문구 사용. |
| 28 | 미확정 Option | 선택만 한 응답은 기록하지 않음. |
| 29 | IncidentResult 작성 | INCIDENT_RESULT부터 확정01-B 결과 작성 문구 표시. |
| 30 | 미래 Result | BROADCAST Confirm 이후에도 IncidentResult 문구 숨김. |
| 31 | Monitoring 기록 | 기존 offset/관찰/배열 순서 그대로, 작성 override 없음. |
| 32 | 최종 결과 | 기존 Runtime SUCCESS/FAILURE만 사용, 작성 콘텐츠는 결과에 영향 없음. |
| 33 | category | PROFILE/OBSERVATION/EXPERIMENT/CONTAINMENT/INCIDENT 기존 정책 보존. Kind와 별개. |
| 34 | View 변경 | ResearchLogView/typed Entry/모든 Scene 변경0. View는 작성 Resource를 알지 않음. |
| 35 | Runtime | 소스/필드/getter/승인 정책 그대로, 해금 이력 추가 없음. |
| 36 | 접근 정책 | 8개 허용 Stage/Monitoring·Log·unknown 차단/원래 Stage Back 그대로. |
| 37 | 미래 차단 | 기존 Stage gate/실행 이력/확정 상태를 유지하고 문구만 선택. |
| 38 | Snapshot 최신 | 매 Open 새 문자열 Snapshot, 독립 콘텐츠 갱신 후 새 Snapshot만 갱신. 이전 Snapshot 값 보존. |
| 39 | 제거 fallback | 8종 각각 독립 복사에서 제거해 원래 derived 문구 복원. |
| 40 | orphan | 없는 EXP/잘못된 Kind·ID의 유효 콘텐츠는 자동 노출 없음. |
| 41 | 불변성 | 매 Open/Back의 기존·작성 Resource 값과 Runtime/승인 호출 수 비교, 파일 SHA-256 비교. |
| 42 | SUCCESS | Room02 전체 경로와 작성/fallback 양쪽 검증, 실패 항목 없음. |
| 43 | FAILURE | Room01·03의 A/B/C 전체 경로, 작성/미작성 항목과 확정 결과 ID 확인. |
| 44 | Open/Back 회귀 | 8개 Source/반복/원래 Stage 복귀/임시 선택 초기화/확정 상태 복원 유지. |
| 45 | 전체 시스템 | Profile/CCTV/Experiment/제한·이력/Containment/Monitoring/Incident/Broadcast·Confirm/IncidentResult/Summary/UNDEFINED/누락·예외/다른 Case 검사. |
| 46 | stale | 25단계 detached/queued/replaced/wrong-stage/Open/Back/위조/nested 검증 재사용. |
| 47 | signal | 반복 재생성 후 Open/Next/Confirm/Back 연결1개. |
| 48 | 단일 View | 전환 직후 자식1개, 이전 객체 제거/해제 확인. |
| 49 | 세 크기/Stretch | 1920×1080/1280×720/1024×768, 기존 keep/canvas_items/호스트/버튼/텍스트 유지. |
| 50 | 파싱/실행 | 최종 기록은 아래 검증 결과 참조. |
| 51 | 문제/해결 | 기존 Log 검사의 정확한 derived 문구 기대는 별도 fallback Case 복사로 보존; 새 authored 검사로 작성 문구도 검증. 제품 오류 수정 없음. |
| 52 | 실제 파일 | 아래 기존4수정/신규2/삭제0, Scene 수정0. |
| 53 | 기존 보존 | Step25의 UI/접근/복귀/선택/Runtime 정책, 기존 UID/설정/콘텐츠/검증/과거 보고 보존. 커밋·push 없음. |
| 54 | 미구현 | 영구 해금/공유·다중·과거 Case/Save·Load/Monitoring ID·Open·Timer정책/검색·필터·편집·즐겨찾기/Validator시스템/Campaign/Manager·Singleton/Audio·Animation·Shader/최종 UI 없음. |
| 55 | 다음 추천 | 각 Case의 research_entries에서 필요한 Source 문구를 작성·검증. 영구/다중 기록 요구는 별도 Runtime/저장 정책을 먼저 결정. |

### 26단계 실제 변경 파일

- 신규 `scripts/data/research_entry_data.gd`와 Godot 생성 UID.
- 수정 `scripts/data/case_data.gd`: typed 배열 한 줄.
- 수정 `scripts/main/main.gd`: Snapshot의8개 정상 Source에 문구 선택, 로컬 검증/검색/선택 helper3개.
- 수정 `resources/cases/test_case_01.tres`: 새 Script 참조와8개 내장 작성 문구, root 배열/load_steps만 추가.
- 수정 `README.md`: 현재 구조/사용법과 이번 보고.

### 26단계 검증 기록

Godot `4.7.1.stable.official.a13da4feb`에서 **105개 headless/Windows GPU 검사와 최종 editor import1개, 총106개**가 통과했습니다.
현재25개 GDScript의 check-only, 기본 Main 실행, 기존 정상/예외/생명주기/다른 Case 검사와 새 작성/기존 fallback 검사를 포함합니다.
작성 문구 있는 Case와 research_entries가 비어 있는 독립 Case 복사에서 각각7개 경로×3개 크기×headless/native를 실행했습니다.
각 경우 Open/Back726회, 합계**1,452회** 실제 마우스 입력을 검증했습니다. 새 예외 검사는 null/공백/잘못된 enum,
중복 kind+ID/entry_id, 역순,8종 작성 제거, 동일 source_id의 다른 Kind, 빈 작성 문자열, Snapshot 격리/최신성,
orphan, 원래 Source 누락, Resource/Runtime 불변성을 확인했습니다.

모든 실행 종료0, 파싱/GDScript/실행 오류0, 정상 경고0이며 예외의 의도한 경고 수만 정확히 일치했습니다.
새 작성 예외는 모드별23개 경고가 예상대로 발생했습니다. F5 키 자체는 자동 누르지 않았으며 같은 Main 기본 실행을 양쪽 모드에서 확인했습니다.
1920×1080/1280×720/1024×768 GPU PNG156개를 생성하고 작성 Log와 기존 게임 화면의 대표 캡처를 직접 확인했습니다.
본문은 기존 ScrollContainer로 읽으며 1024×768 창의 기존 keep 콘텐츠 렌더 영역은1024×576입니다.
해상도/Stretch/Scaling/모든 Scene/모든 View/Runtime/Monitoring Timer는 이번 단계 변경이 없습니다.

시작 시점 대비 **기존4개 수정/신규2개/삭제0**, 기존 원본66개 중62개 및 UID24개는 SHA-256 동일합니다.
CaseData의 새 배열과 .tres의8개 작성 항목/Script 참조/load_steps를 제외하면 이전 Schema/콘텐츠가 정확히 같습니다.
Main의 기존26개 함수 중25개는 원문이 동일합니다. Snapshot의 문구 선택 추가를 제외한 Stage gate/순서/원래 fallback도 원문 보존을 확인했습니다.
25단계 이하 보고와 이전 검증655개를 보존했고, 최종 코드의105개 실행 증명 signature/log SHA-256도 일치했습니다.
누적 Git 상태는 25·26단계의15수정/2신규, HEAD345d93f 유지, staging 비어 있음, `git diff --check` 통과, 커밋/push 없음입니다.
실행 증거는 `validation-results.json`/각 `.pass.json`/`final-import.log`, 보존 증거는 `final-audit.json`,
이번 단계만의 변경은 `incremental-*.diff`에서 확인할 수 있습니다.
새 검증/로그/캡처/시작 해시/단계별 diff는 `.godot/verification/step26/`에만 생성합니다.
원래 검증 파일은 수정하지 않았고, 이전 검사와 helper를 재사용하며 작성 문구/예외/기존 fallback 검사를 추가했습니다.

## 25단계 현재 Stage의 읽기 전용 Research Log 접근

시작 HEAD는 `345d93fe3539edee39657b9ee76ccd52765f9fcc`, master→origin/main, 작업 트리는 clean이었습니다.
첨부 요청의 Step24 미커밋 보존 조건과 달리 실제 Step24는 이미 커밋·push되어 있었습니다.
전체 원본66개(24 GDScript/24 UID/11 Scene/콘텐츠 .tres1개), 실제 Main/각 View/공용 Flow/Runtime/11개 Data,
Summary/ID helper/Route/설정과 이전 검증을 조사했습니다. 변경 전 원본과 기존 검증의 SHA-256을 보관했습니다.

기존 9개 정규 Stage의 Route와 Log의 Stage=9/PackedScene 매핑은 그대로입니다.
독립 View 재생성 정책을 유지하며 Log는 Main의 보조 이동으로만 열립니다.

```text
지원 View의 OpenResearchLogButton.pressed
  → FlowView.research_log_requested
  → Main: 허용 Stage + bind한 발신 Stage + 활성 View 검사
  → Main._research_log_return_stage에 원래 Stage 저장
  → 새 Snapshot 생성 → RESEARCH_LOG 하나 표시
Log의 Back → Main: 활성 Log + 허용 복귀 Stage 검사
  → 복귀 Stage를 -1로 초기화 → 원래 View 재생성/setup
```

FlowView에는 선택적 버튼 연결과 요청 signal만 추가했습니다. ResultView의 같은 코드를 공통 구현으로 옮겨
중복 연결을 제거했습니다. Main에는 임시 정수 하나와 허용 목록만 두었으며 Runtime/Resource에 이동 상태를 저장하지 않습니다.
Snapshot/Entry의 기존 문자열/enum/typed 배열 스키마는 바꾸지 않았습니다. 현재 Case 및 Runtime의 getter를 읽고,
기존 Result Summary의 ID 검색 결과를 재사용하되 **원래 Stage gate를 통과한 문자열만** 새 Log Snapshot에 복사합니다.
완료 Runtime이 남은 Restart PROFILE에서도 Profile만 표시합니다. 이전 Log Snapshot을 재사용하지 않습니다.

미확정 Experiment/Room/Option의 임시 선택은 View 재생성으로 초기화됩니다. 실행 이력/사용 횟수/확정 Room/확정
Broadcast 쌍은 Runtime에서 복원합니다. Log 이동은 실행/Confirm/결과 확정 메서드를 호출하지 않습니다.
Result 복귀는 기존 `_build_result_summary()`로 동일 내용을 재생성합니다.

### 25단계 요청 53항목 보고

| 번호 | 항목 | 처리 / 검증 |
| --- | --- | --- |
| 1 | 작업 전 Git | HEAD 345d93f, clean, Step24 이미 커밋·push. 실제66파일/Scene/Script/Resource/UID/설정/기존 검증 조사. |
| 2 | 허용 Stage | PROFILE / CCTV / EXPERIMENT / CONTAINMENT / INCIDENT / BROADCAST / INCIDENT_RESULT / RESULT. |
| 3 | 제외 Stage | MONITORING / RESEARCH_LOG / 알 수 없는 Stage. |
| 4 | 공통 Open | 선택적 Open 버튼 → FlowView signal → Main, 다음 View 참조 없음. |
| 5 | Flow 변경 이유 | 버튼 요청 공통화만 추가; Result 중복 구현 제거. 데이터/전환 결정은 없음. |
| 6 | Main 검증 | 허용 목록, bind한 source Stage==현재 Stage, 기존 `_is_active_view`를 모두 검사. RESULT는 확정 Monitoring도 검사. |
| 7 | return 저장 | Main의 `_research_log_return_stage: int` 하나, 정상 Back에서 -1로 초기화. |
| 8 | Runtime 이동 필드 | 추가 없음. 기존 getter를 읽기만 하며 Open/Back에서 승인/기록/reset 호출 없음. |
| 9 | Resource 이동 필드 | 추가/수정 없음. 콘텐츠 .tres와 Data/UID 그대로. |
| 10 | Back | 원래 Stage 재생성, 유효성 검사 후 이동. Back 문구 일반화. |
| 11 | 정규 Route | `_get_next_stage` 원문 보존; LOG=-1. 정규 Route와 Restart 그대로. |
| 12 | 현재 Snapshot | 매 Open마다 현재 Case/Runtime/원래 Stage로 신규 객체 생성. |
| 13 | 미래 정보 | Stage별 조기 반환, 실제 실행/확정 getter, 완료 결과 조건. 단순 ID 연결만으로 Entry 생성하지 않음. |
| 14 | PROFILE | Profile만. 재시작의 이전 완료 Runtime이 있어도 후속 정보 숨김. |
| 15 | CCTV | Profile+CCTV만. |
| 16 | EXPERIMENT | Profile+CCTV+실행 이력 순서의 Experiment 설명·결과. |
| 17 | 미실행 제외 | 선택만 한 항목과 미실행 결과 없음. |
| 18 | 추가 실행 | 0→03→03,01 이력으로 각각 재생성/갱신 확인. |
| 19 | CONTAINMENT 전 | 기존 공개 정보만; 임시 선택 Room Entry 없음. |
| 20 | CONTAINMENT 후 | 확정 Room ID/이름/설명 추가, Monitoring 제외. |
| 21 | INCIDENT | 완료 Monitoring 결과/관찰+Incident까지; Broadcast/Option/IncidentResult 제외. |
| 22 | BROADCAST 전 | Broadcast 추가, 미확정 Option과 IncidentResult 제외. |
| 23 | BROADCAST 후 | 확정 응답 추가; 연결된 IncidentResult는 아직 제외. |
| 24 | INCIDENT_RESULT | 확정 응답의 IncidentResult까지 표시. |
| 25 | RESULT | 기존 Step24 전체 확정 Log, Summary 표시/Restart 보존. |
| 26 | SUCCESS | 실패 카테고리 Entry 없음. |
| 27 | Monitoring 차단 | Open 버튼 없음; signal/직접 handler 요청도 거부. Timer 정책 변경 없음. |
| 28 | 위조 Open | source Stage 불일치, 금지/미정의 Stage를 직접 전달해도 이동 없음. |
| 29 | stale Open | 8개 허용 Stage 각각 detached/queued/replaced/wrong-stage 거부. |
| 30 | stale Back | detached/queued/replaced/wrong-stage 및 교체 직후 이전 Log 요청 거부. |
| 31 | 잘못된 return | -1/MONITORING/LOG/999는 경고 후 Log 유지, RESULT fallback 없음. |
| 32 | 중첩 Log | 버튼 없음; 위조 nested signal/직접 요청 거부, return 값 유지. |
| 33 | 임시 선택 | 재생성 시 초기화; 이동은 확정 동작이 아니며 실행/Confirm을 요구하지 않음. |
| 34 | Experiment 복귀 | 실행/잔여 횟수/잠금 복원, 임시 선택 초기화와 Run disabled 확인. |
| 35 | Containment 복귀 | 미확정 선택 초기화; 확정 ID/잠금/Next 가능 상태 복원. |
| 36 | Broadcast 복귀 | 미확정 선택 초기화; 확정 쌍/잠금/Next 가능 상태 복원. |
| 37 | Result 복귀 | 기존 Summary 재생성, 모든 공통/실패 필드 동일. |
| 38 | 반복 | 세 크기×headless/native, 각121회 Open/Back 검증. |
| 39 | 최신성 | 매 Open 신규 Snapshot, 실행 추가와 Confirm 직후 Entry 갱신, 이전 객체 재사용 없음. |
| 40 | Runtime 불변 | 여섯 상태 필드/getter와 Broadcast 승인 호출 수를 매 이동 전후 비교. |
| 41 | Resource 불변 | 원본/테스트 콘텐츠 값과 파일 SHA-256 전후 비교; 새 Entry는 문자열만 참조. |
| 42 | SUCCESS Route | Log 없는 기존 Route와 새 Log를 섞은 Room02 Route 모두 검사. |
| 43 | FAILURE Route | Room01/03 각각 A/B/C, 원래 Route와 확정 결과 ID 조회 회귀. |
| 44 | 전체 회귀 | Profile/CCTV/Experiment/제한·이력/Containment/Monitoring/Incident/Broadcast·Confirm/IncidentResult/Result/Step24 Log/UNDEFINED/예외/다른 Case/생명주기 검사. |
| 45 | signal | Open/Next/Back/Confirm의 연결1개, 반복 재진입 중복 없음. |
| 46 | 단일 View | 전환 직후 ViewHost 자식1개, 이전 View 제거/queue_free/해제 확인. |
| 47 | 화면/설정 | 1920×1080/1280×720/1024×768, 버튼·목록 영역/가독성 확인; project.godot/Main Scene/Stretch/Scaling 그대로. |
| 48 | 파싱/실행 | 최종 검사 결과는 아래 검증 기록 참조. |
| 49 | 문제/해결 | 이전 Broadcast 검사가 버튼 수를 +2로 고정. 원본 검사는 보존하고 새 wrapper에서 +3만 반영. 게임 회귀 수정 불필요. |
| 50 | 변경 파일 | 아래13개 수정. 새 게임 파일0/삭제0; 새 검증은 Git 제외 `.godot/verification/step25/`에만 생성. |
| 51 | 기존 보존 | Step24 커밋/UID/Runtime/Data/콘텐츠/기존 검증/과거 보고 보존. 변경 범위 SHA-256/diff 검사. 커밋·push 없음. |
| 52 | 미구현 | Monitoring Open/pause/continuation, 영구·다중 Case·unlock·별도 Entry Resource·검색·필터·편집·즐겨찾기·stack·Manager·Singleton·Campaign·Save/Load·Audio·Animation·Shader·최종 UI 없음. |
| 53 | 다음 지점 | Main Snapshot→ResearchLogView.setup 경계에서 필요한 표시 문구를 한 가지씩 검증. Monitoring/영구 기록은 별도 요구로 정책부터 결정. |

### 25단계 실제 변경 파일

- `scripts/main/main.gd`: 허용 검사, 임시 복귀 위치, Stage gate만 추가.
- `scripts/views/flow_view.gd`: 선택적 Open 버튼 요청 공통화.
- `scripts/views/result_view.gd`: 중복 Open 구현 제거, Summary 기능 보존.
- `scripts/views/research_log_view.gd`: 미확정/초기 Stage의 최종 결과 Label 숨김.
- `scenes/views/{profile,cctv,experiment,incident,incident_result}_view.tscn`: 기존 Next 옆에 Open을 추가한 Actions.
- `scenes/views/{containment,broadcast}_view.tscn`: 기존 Actions에 Open 추가, 세 버튼이 기존 폭에 맞도록 최소 폭만 조정.
- `scenes/views/research_log_view.tscn`: Back 문구만 일반화.
- `README.md`: 현재 사용법/구조와 이번 검증 기록.

### 25단계 검증 기록

Godot `4.7.1.stable.official.a13da4feb`에서 **96개 headless/Windows GPU 검사와 최종 editor import 1개, 총97개**가 통과했습니다.
GDScript24개 check-only, 기본 Main 실행, 기존 기능/예외/생명주기/다른 Case 검사 및 신규 navigation/security를 포함합니다.
Open/Back은 7개 SUCCESS/FAILURE 경로×3개 창 크기×headless/native에서 **총726회** 실제 마우스 입력으로 검증했습니다.
모든 실행 종료0, 파싱/GDScript/실행 오류0입니다. 누락·잘못된 데이터 검사에서 의도한 경고만 정확히 일치했고 정상 검사 경고0입니다.
잘못된 return Stage 4종의 경고도 의도적으로 검증했습니다. F5 키 자체는 자동 누르지 않았으며 동일한 Main 기본 실행을 양쪽 모드에서 확인했습니다.

1920×1080 / 1280×720 / 1024×768의 source/Log PNG78개를 생성하고 8개 source 화면과 Log의 대표 캡처를 직접 확인했습니다.
기존 keep 비율로 1024×768 창의 콘텐츠 렌더 영역은 1024×576입니다. 기존 호스트/버튼/목록 영역 내 배치와 읽기 가능한 텍스트를 확인했습니다.
`project.godot`/Main Scene/해상도/Stretch/Scaling/Monitoring Timer와 콘텐츠는 바꾸지 않았습니다.

최종 diff: **원본66개 중13개 수정, 신규0/삭제0, 나머지53개와 UID24개 동일**.
이전 검증 소스646개와 24단계 이하 보고를 보존했습니다. Main의 기존26개 함수 중22개는 원문이 동일하고,
정규 Route/Result Summary/ID 조회/게임 승인/활성 View 방어 함수는 그대로입니다.
`git diff --check` 통과, staging 비어 있음, HEAD345d93f 유지, 커밋/push 없음.
실행 증거는 `validation-results.json`/각 `.pass.json`/`final-import.log`, 보존 증거는 `final-audit.json`에 있습니다.
검증 코드/로그/캡처/시작 해시는 `.godot/verification/step25/`에만 있으며 게임에서 로드하지 않습니다.
기존 검증을 상속·재사용하고 새 navigation/security 검사를 추가했습니다. Stage gate에 맞춘 Step24 snapshot
wrapper와 추가 버튼 수를 반영한 Broadcast wrapper만 새로 두었으며 이전 테스트 파일을 수정하지 않았습니다.

## 24단계 현재 Case의 읽기 전용 Research Log

시작 시 HEAD는 `c9b3074fb261f3f44fcd5209e475e1a59d4a699c`, 작업 트리는 clean이었습니다.
23단계는 사용자 요청으로 이미 커밋·push되어 있어 별도 미커밋 변경은 없었습니다.
전체 원본63개/GDScript23개/UID23개/Scene10개/콘텐츠 .tres1개, Main·모든 콘텐츠·View·Runtime·
Summary·ID helper·Stage/Route·설정·기존 검증 코드를 조사하고 원본 및 기존 검증 소스640개의 해시를 보관했습니다.

이번 구현은 **RESULT에서만 여는 보조 화면**입니다. 정규 Case Route와 기존 RESULT→PROFILE은 그대로입니다.
Stage.RESEARCH_LOG=9를 끝에 추가해 기존0~8 값을 유지하고 PackedScene도 같은 위치에 추가했습니다.
`_get_next_stage()`의 본문은 변경하지 않았으며 RESEARCH_LOG에는 -1을 반환합니다.
Open과 Back은 Main의 별도 handler가 해당 Stage와 `_is_active_view()`를 검사한 뒤 명시적으로 전환합니다.
Monitoring 진행 중 열람/Timer 정지 정책을 새로 만들지 않았습니다.

```text
ResultView
└ Actions
  ├ OpenResearchLogButton → research_log_requested → Main → RESEARCH_LOG
  └ NextButton → 기존 advance_requested → Main → PROFILE

ResearchLogView (Control, 기존 FlowView 한 단계 상속)
└ Center / Content
  ├ ScreenTitle: RESEARCH LOG
  ├ Description: Case 이름/ID
  ├ MonitoringResult: Runtime SUCCESS/FAILURE
  ├ EntryScroll (ScrollContainer)
  │ └ EntryList (VBoxContainer)
  │   └ 동적 VBox: Category / Title / Source ID / Body Label
  └ NextButton: Back to Result → advance_requested → Main 전용 Back handler → RESULT
```

`ResearchLogView.Snapshot`은 case_id, case_display_name, monitoring_result, typed Entry 배열만 가진
작은 RefCounted입니다. Entry는 category/source_id/title/body_text 네 문자열의 RefCounted입니다.
Resource 참조와 Runtime 참조를 저장하지 않으며 장기 보관·게임 규칙의 입력·두 번째 Runtime이 아닙니다.
읽기 전용은 표시 계약이며 불변 타입이나 범용 DTO Framework는 만들지 않았습니다.

Main은 기존 `_build_result_summary()`의 정확한 ID 검색 결과를 짧게 재사용하고, Profile/CCTV와
`_get_monitoring_outcome()`의 Stage를 추가하여 독립 문자열 snapshot을 만듭니다.
Result Summary 자체의 Schema·생성 코드·역할은 그대로이며 ResultView는 여전히 최종 요약입니다.
ResearchLogView는 Main/Runtime/특정 .tres/다른 View를 찾거나 생성하지 않습니다.

| 범주 | 표시 기준 |
| --- | --- |
| PROFILE | 현재 Profile의 ID, subject_name, classification, basic_description |
| OBSERVATION | CCTV camera_id/observation_text, 확정 Monitoring Outcome의 Stage를 배열 순서대로 time_offset/observation_text 표시 |
| EXPERIMENT | Runtime 실행 이력의 ID만 현재 Case에서 검색. 실행 순서 그대로 description/result_text 표시, 미실행 후보 제외 |
| CONTAINMENT | 확정 Room ID가 있을 때 같은 ID의 이름/설명 표시. 미확정이면 Entry 생략 |
| INCIDENT | FAILURE에만 Incident, Broadcast prompt, 실제 확정 Option의 Selected Response, 연결된 IncidentResult 표시 |

Monitoring 최종 결과는 Snapshot의 Runtime 결과로 별도 표시합니다. Resource.final_result로 플레이 결과를 추정하지 않습니다.
정상 SUCCESS는 이력2개 기준 Entry8개, FAILURE는 Entry12개입니다. 이력0개 SUCCESS는6개이며
EXPERIMENT Entry는0개입니다. Scene의 항목 수는 고정하지 않습니다.
누락된 실행 ID/Room/Outcome/Incident/Broadcast/Option/IncidentResult는 warning과 `[Unavailable]`로
표시하며 알 수 있는 원래 ID를 유지합니다. 중간 참조가 없어 결과 ID를 알 수 없는 경우에는
Source ID도 `[Unavailable]`입니다. 다른 Room/Option/결과로 대체하지 않습니다.

ResultView의 Open 버튼은 유효 SUCCESS/FAILURE Summary에서만 활성화되며 Main도 Runtime 확정을 검사합니다.
Log에서 돌아오면 기존 Summary를 새로 생성하여 같은 내용을 복원합니다. 화면 전환에서 Runtime 승인/reset API는 호출하지 않습니다.
ResearchLogView.setup()은 ready 전 전달과 ready 후 교체를 지원하고 기존 Entry를 제거·queue_free한 뒤
새 목록을 생성하며 scroll_vertical=0으로 초기화합니다. signal 연결은 _ready에서 한 번만 합니다.
Result의 버튼 두 개는 HBox에 배치해 기존 높이를 유지했습니다. Log의 스크롤 높이는160으로 맞췄습니다.
초기180 높이에서는 제목이 기존360 ViewHost 밖으로 나오는 문제가 실제 검사에서 발견되어 수정했습니다.

기존 Step22 검증을 직접 재사용했습니다. Stage/Scene 매핑 검사만 새 Step24 wrapper에서
RESEARCH_LOG 제목 기대값을 추가했으며 기존 검사 본문을 바꾸지 않았습니다.
Step23 생명주기/다른 Case 검사도 재사용했고 Step24의 Log 흐름·예외·생명주기 검사만 추가했습니다.
정상 Log 흐름은 독립 메모리 Case의 주요 배열/Option을 역순으로 두고 실제 버튼으로
EXP03→EXP01 실행, Room 선택/Confirm, Monitoring 완료, FAILURE 응답/Confirm, Result 진입을 수행합니다.
빠른 새 흐름 검사의 Stage만0초이며 제품의0/10/20초 재생은 기존 production_playback 검사로 별도 확인합니다.
SUCCESS1경로+Room01/03의 A/B/C FAILURE6경로 × 세 해상도, 실행 모드마다21시나리오/63 Open·Back 순환입니다.
독립 예외 검사에서는 각 참조를 제거하고 확정 Broadcast 쌍 불일치/null Stage도 검사합니다.
SUCCESS↔FAILURE/다수→0/40 Entry/긴 본문/null snapshot setup 교체, 스크롤 초기화, 이전 Node 해제도 검사합니다.

| 번호 | 요청 보고 항목 | 결과 |
| --- | --- | --- |
| 1 | 작업 전 Git | c9b3074, clean, Step23 이미 커밋·push됨. |
| 2 | 전체 구조 | 기존 Main+Data+Runtime+View 경계, 독립 ResearchLog Scene/Script/UID만 추가. |
| 3 | 새 Resource 타입 | 없음. 콘텐츠 Schema와 .tres 유지. |
| 4 | Runtime 변경 | CaseRuntimeState 파일·필드·승인 정책 변경 없음. |
| 5 | Snapshot | typed RefCounted: Case ID/이름, Runtime Monitoring 결과, Entry 배열. |
| 6 | Entry | typed RefCounted: category/source_id/title/body_text 문자열만. |
| 7 | 카테고리 | PROFILE/OBSERVATION/EXPERIMENT/CONTAINMENT/INCIDENT 문자열5개, 별도 시스템 없음. |
| 8 | Profile | ID/대상 이름/분류/설명 표시. |
| 9 | CCTV | camera_id/observation_text, 방문 Runtime 필드 없음. |
| 10 | Experiment 기준 | Runtime 승인 실행 이력만 사용, 현재 Case의 정확한 ID 검색. |
| 11 | 실행 순서 | 03→01 그대로, 자동 정렬 없음. |
| 12 | 미실행 제외 | EXP02 Entry 없음. |
| 13 | 실험 결과 | 실행한 Resource의 description/result_text까지 표시. |
| 14 | Containment | 확정 Room ID/이름/설명, 미확정 Entry 생략. |
| 15 | Monitoring Stage | 완료 Runtime일 때 현재 Room의 Outcome Stage를 Resource 배열 순서로 표시. |
| 16 | Monitoring 결과 | Runtime SUCCESS/FAILURE를 화면에 표시. |
| 17 | SUCCESS Incident | 관련 Entry0개, 실패 검색/결과 노출 없음. |
| 18 | FAILURE Incident | 현재 Outcome의 Incident ID/이름/설명. |
| 19 | Broadcast | 현재 Incident의 Broadcast ID/이름/prompt. |
| 20 | 확정 Option | Runtime Broadcast/Option 쌍과 일치하는 Selected Response만 표시. |
| 21 | Incident Result | 확정 Option.result_id로 파생, Runtime 새 필드 없음. |
| 22 | Result Open | OpenResearchLogButton이 요청 signal만 전송. |
| 23 | Main Open | RESULT/확정 Runtime/활성 View 검사 후 Log 생성·setup. |
| 24 | Log View | 독립 Control Scene, 제목/Case/결과/ScrollContainer/VBox 목록/Back. |
| 25 | 동적 목록 | Snapshot Entry 수대로 VBox와 Label4개 생성. |
| 26 | Back | 전용 Main handler가 Log Stage/활성 View 확인 후 RESULT 명시 복귀. |
| 27 | Route 비포함 | _get_next_stage 원문 유지, Log의 다음 정규 Stage=-1. |
| 28 | Summary 복원 | Back 후 기존 Summary 재생성, 같은 ID/이름/사용 수/결과. |
| 29 | SUCCESS Log | Room02, EXP03→01, Profile/CCTV/확정 Room/관찰, Incident 없음. |
| 30 | FAILURE Log | Room01/03 A/B/C 모두 정확한 확정 Option/결과, 다른 응답 제외. |
| 31 | 이력0개 | EXPERIMENT Entry0, 크래시/경고 없음. |
| 32 | 누락 Experiment | 원래 실행 ID 유지, warning+Unavailable, 순서 유지. |
| 33 | 누락 Room | 확정 ID 유지, warning+Unavailable, 다른 Room 대체 없음. |
| 34 | 누락 Outcome | 확정 Room ID의 Monitoring unavailable, 다른 Outcome 대체 없음. |
| 35 | 누락 실패 연결 | Incident/Broadcast/Option/Result 각 예외를 검사, 원래 알려진 ID와 unavailable 표시. |
| 36 | 반복 setup | 이전 Node 제거·해제, 새 수량, 스크롤0, SUCCESS/FAILURE/0/40 교체. |
| 37 | stale 요청 | 이전 화면 및 detached/queued/replaced/wrong-stage Open/Back 차단, UNDEFINED Open 차단. |
| 38 | Runtime 불변 | Snapshot 생성/열기/Back/반복 setup에서 모든 필드·실행 수·승인 호출 수 보존 검사. |
| 39 | Resource 불변 | 표시용 문자열 독립, snapshot 수정도 콘텐츠/Runtime 불변, 원본 .tres/Schema 해시 보존. |
| 40 | Summary 회귀 | 기존 Summary 검사 재사용 및 Log Back 후 동일 내용 확인. |
| 41 | SUCCESS Route | 기존 M→RESULT→PROFILE 유지. |
| 42 | FAILURE Route | 기존 M→INCIDENT→BROADCAST→INCIDENT_RESULT→RESULT→PROFILE 유지. |
| 43 | 전체 기능 회귀 | 기존 목록/선택/실행 제한·이력/확정/Timer/매핑/요약/상태 유지 검사를 재사용. |
| 44 | signal 중복 | pressed/request 각1개, setup·재진입 후에도1개. |
| 45 | 해상도/Stretch | 1920×1080/1280×720/1024×768, 논리1920×1080·canvas_items·keep 유지. |
| 46 | 파싱/실행 | Godot4.7.1 GDScript24개/전체 회귀·Log 검사90개 + 최종 editor import1개 =91개 성공, headless/Windows GPU 양쪽. |
| 47 | 문제/해결 | Log 높이180에서 host 초과를 재현,160으로 조정. 테스트 독립 View 크기 지정의 anchor 경고도 테스트에서 해결. |
| 48 | 변경 파일 | 신규 Log .tscn/.gd/.uid3개, 수정 Main/Result Script/Result Scene/README4개, 삭제0. |
| 49 | 이전 변경 보존 | 기존 소스/UID/검증 보존 해시와 HEAD/staging 최종 비교. |
| 50 | 미구현 | 영구/다중 Case/과거 기록, 전체 화면 열람, 검색·필터·수정·정렬·메모·즐겨찾기, 새 Resource/Validator/Manager, Campaign/저장/연출/최종UI. |
| 51 | 확장 지점 | Main snapshot builder→ResearchLogView.setup. 정식 문구가 달라지면 Resource, 진행 중 열람은 Timer 정책, 영구/다중 기록은 별도 요구 시 설계. |

검증·로그·캡처·해시·diff는 Git 제외 폴더 `.godot/verification/step24/`에 있습니다.
검증 엔진은 `4.7.1.stable.official.a13da4feb`, Windows Compatibility/OpenGL3.3, AMD Radeon RX6800입니다.
최종90개 검사와 editor import는 모두 종료 코드0이며 정상 검사에는 경고·오류가 없습니다.
의도적 누락 입력의 새 Log 검사는 각 모드34개 예상 warning, 기존 예외 검사는 이전 warning 수를 유지했습니다.
새 Log의 native GPU 상단/하단 캡처42개를 생성하고 세 해상도의 SUCCESS/FAILURE 화면을 직접 확인했습니다.
1024×768 창의 콘텐츠 렌더는 기존 keep 설정대로1024×576입니다. F5 키 자체는 조작하지 않았으며
동일 application/run/main_scene의 프로젝트 기본 실행을 검증했습니다.
이전 원본59개/UID23개/검증 소스640개, Main의 기존 함수20개와 이전 단계 보고를 그대로 보존했습니다.
수정한 기존 Main 함수는 _show_view의 Log 연결/setup뿐이며 정규 Route·승인·Summary 생성 함수는 그대로입니다.
최종 원본은66개/GDScript24개/UID24개/Scene11개, 기존 .tres1개이며 신규 콘텐츠/삭제 원본은 없습니다.
기존 검증 파일은 수정하지 않았고 HEAD/staging도 변경하지 않았습니다. 커밋·push는 수행하지 않았습니다.

## 23단계 단일 Case Core 구조 감사와 최소 정리

이번 단계의 판단은 **Main + Resource + CaseRuntimeState + View를 유지**하는 것입니다.
정상 게임 규칙·콘텐츠·Route는 변경하지 않았습니다. 실제 재현된 비활성 View 요청의
Runtime 변경만 Main의 작은 private helper로 차단했습니다. 새로운 게임 기능은 없습니다.

재개 시 HEAD는 `6dbc42af1c21ab1bd416302a070c269235d7215a`이며 작업 트리는 깨끗했습니다.
사용자 요청으로 19~22단계 변경이 이미 이 커밋에 포함된 상태입니다. 이전 감사 시작 시의
미커밋 수정9/신규7과 혼동하지 않도록 재개 시 Git 상태를 다시 보관했습니다.
소스 63개, GDScript/UID 각각23개, Scene10개(Main+View9개), 콘텐츠 .tres1개,
콘텐츠 Resource Script11개를 조사했습니다. Autoload/플러그인은 없습니다.
작업 전 소스 사본·해시와 이전 로컬 검증 파일355개의 해시를 보관했습니다.

Main은 작업 전405줄·20함수, 작업 후409줄·21함수입니다. 빈 줄/주석도 라인 수에 포함합니다.
책임은 (1) 시작 시 Case 기본 검사·Runtime 생성, (2) 창 크기 표시,
(3) View 생성/제거와 setup 전달, (4) ID 기반 콘텐츠 연결 검색,
(5) 실행/확정/완료 요청을 Runtime 승인에 연결, (6) Route 선택,
(7) 읽기 전용 Result Summary 생성입니다. 별도 Manager로 분리할 필요는 현재 없습니다.
View setup 분기는9개, Route의 Stage 분기는9개이며 Monitoring 안의 결과 분기2개와
미정의/알 수 없는 Stage의 -1 반환을 갖습니다. 현재 결합은 작고 명시적이며 실제 매핑 검사로 보호합니다.

| 경계 | 감사 판단 |
| --- | --- |
| Data Resource | 콘텐츠 필드만 존재. selected/confirmed/실행 이력 등의 플레이 상태 없음. Outcome.final_result는 콘텐츠의 예정 결과이며 실제 완료 여부와 다름. |
| CaseRuntimeState | 이번 Case에서 확정한 사실만 보관. UI Node/선택 인덱스/Timer/Resource/.tres 참조 없음. |
| View | 받은 Resource와 표시용 snapshot, 임시 선택·재생·Label·버튼 상태만 관리. Runtime/Main 탐색과 특정 .tres load 없음. |
| Main | 콘텐츠 문구/테스트 ID 하드코딩 없음. 현재 Case 연결, 승인, 생명주기, 전환을 조정. |
| Result Summary | 표시 시 값/이력 사본과 현재 콘텐츠 참조를 전달하는 수명이 짧은 RefCounted. Resource 복제·장기 보관·두 번째 Runtime·게임 규칙 의존 없음. 읽기 전용은 사용 방식의 계약이며 불변 타입을 새로 만들지 않음. |

| Runtime 필드 | 유지 이유 |
| --- | --- |
| case_id | 플레이 상태가 어느 Case에 속하는지 나타내는 식별자. CaseData.case_id와 초기 값이 같아도 Runtime의 소속을 보존하는 메타데이터. |
| _experiment_execution_history | 실제 승인된 실행 ID와 순서. count/remaining은 조회할 때 계산하므로 중복 필드 없음. |
| _confirmed_containment_room_id | 실제 확정한 선택. 후보 콘텐츠만으로 재계산할 수 없음. |
| _monitoring_result | 실제 완료 후 한 번 확정한 결과. Resource의 final_result만으로 재생 완료/UNDEFINED 상태를 알 수 없음. |
| _confirmed_broadcast_id | 확정 Option이 속하는 Broadcast 맥락. Option ID는 Broadcast 내부에서만 유일하면 되므로 필요한 식별자. |
| _confirmed_broadcast_option_id | 실제 확정한 응답. IncidentResult ID는 현재 Resource 관계에서 파생하므로 별도로 저장하지 않음. |

직접 ID 검색 loop를 가진 private helper는5개입니다:
`_get_monitoring_outcome`, `_get_current_incident_data`, `_get_current_emergency_broadcast`,
`_get_broadcast_option`, `_get_incident_result_for_option`.
`_get_current_confirmed_broadcast_option`과 `_get_current_incident_result`는 이를 연결하는
간접 검색 helper2개입니다. Summary의 Experiment/Room 매핑2곳과 Containment 승인 loop1곳도 조사했습니다.
확정 Room 검색은 승인과 요약에서 짧게 반복되고 확정 Option 검색도 현재 검증/조회 과정에서
반복되지만, 경계와 오류 정책이 다르고 현재 비용이 작아 이번에 통합하지 않았습니다.
Main과 View의 Option 유효성 검사도 승인 경계와 전달 snapshot의 UI 경계가 달라 유지합니다.
비슷한 for 패턴을 범용 Repository나 ID Database로 바꾸지 않았습니다.

실제 발견하고 수정한 Core 문제는 생명주기 보호의 차이입니다.
기존 Experiment/Containment 요청은 발신 객체 동일성만 검사했고 Monitoring 완료는
동일성과 Stage만 검사했습니다. 테스트에서 현재 View를 Tree 밖으로 빼거나 queue_free한 뒤
signal을 보내면 Experiment/Containment의 detached·queued4개와 Monitoring의 queued1개에서
Runtime이 바뀌는 것을 수정 전에 재현했습니다. 정상 UI 클릭의 결과를 바꾼 수정이 아닙니다.
`_is_active_view(view)`는 유효 객체, 현재 View, Tree 내부, 삭제 예정 아님을 검사합니다.
기존 Broadcast/advance의 중복 검사를 이 helper로 옮기고 위 세 요청에도 적용했습니다.
Stage/데이터 검증/Runtime 승인/Route/public API는 그대로입니다.
수정 후 detached/queued/replaced9개는 상태를 바꾸지 않으며 정상 요청은 한 번만 기록합니다.
Monitoring의 Timer 중지/완료 snapshot/재진입과 반복 setup의 기존 보호도 유지했습니다.

현재 콘텐츠의 모든 ID와 참조가 유효했습니다. Experiment3/Room3/Outcome3/Incident2/
Broadcast2/각 Option3(총6)/IncidentResult6, 각 Outcome의 Stage3(총9)를 확인했습니다.
각 컬렉션 ID와 Broadcast 내부 Option ID는 비어 있지 않고 중복이 없습니다.
Room마다 Outcome 하나, FAILURE Outcome→Incident, Incident→Broadcast, Option→IncidentResult가
모두 존재합니다. Stage offset도 0/10/20 순서입니다. 정상 .tres는 수정하지 않았습니다.
전용 개발용 Content Validator의 도입 시점은 **다중 Case 제작 시작 시**로 판단합니다.
현재 단일 Case는 이번 참조 감사와 기존 진행 검증으로 충분하지만, 여러 Case를 제작하면
진입하지 않은 분기의 중복 ID/누락 연결도 편집 단계에서 검사할 필요가 있습니다.
이번에는 제품 Validator·캐시·Manager를 만들지 않았습니다.

다른 Case 내용 때문에 Core를 바꿀 필요가 있는지도 실행으로 확인했습니다.
검증용 메모리 Case의37개 Resource(Case 자신 포함)를 독립 복제한 것을 먼저 확인한 뒤
모든 ID·문구를 ALT로 바꾸고 주요 배열과 Option 배열을 역순으로 배치했습니다.
Main.current_case를 ready 이전에 전달하여 PROFILE부터 실제 선택·Run·Confirm·진행 버튼을 눌렀습니다.
SUCCESS1개와 Room01/03 A/B/C FAILURE6개, 총7경로×세 해상도에서 결과 요약과 상태 유지까지 통과했습니다.
검증 Case의 Stage만0초로 바꿨으며 제품의0/10/20초 Timer는 별도 기존 회귀에서 실제로 검증했습니다.
새 콘텐츠 .tres나 Case 선택/로딩/Campaign 기능은 추가하지 않았습니다.

Null 처리의 차이는 화면별 전제에서 나옵니다. PROFILE/CCTV의 안내와 Experiment의 선택적 실행은
경고·대체 문구를 보여주고 정보성 Next를 유지합니다. Containment/Monitoring/Incident/Broadcast/
IncidentResult는 필요한 확정·참조가 없으면 Next와 Main 진행을 차단합니다.
Result는 이미 확정된 사실의 요약이므로 일부 FAILURE 정보가 없어도 unavailable로 표시하고
PROFILE 복귀를 허용합니다. 미정의/빈 Summary는 Next가 비활성화됩니다.
의미가 다른 정책을 강제로 동일 Base Class에 넣지 않았으며 README의 포괄적인 Next 설명만 바로잡았습니다.

자동 검증에도 기술 부채가 있습니다. 기존 로컬 .gd/.ps1 파일355개 중 단계 경로만 정규화하면
동일한 파일을 가진52개 그룹/255개 파일이 있습니다. 과거 단계 보관본이 포함된 숫자이며
이를 모두 현재 회귀 검사로 실행하면 과거 API/Route 기대값과 충돌할 수 있습니다.
최신 Step22의34개 .gd를 재사용했고, 이번에는 전체 검증 Script를 다시 복제하지 않았습니다.
상속된 `_validate`, `_snapshot`, `_advance`, `_assert_rows` 등의 의도적 override와 내부 필드/
private helper/Node 구조 검사에 결합된 부분이 있습니다. 현재 실행 충돌은 없지만 향후 공통 helper로
정리할 대상입니다. 회귀의 동작 검사와 소스/Git/해시 감사는 별도 실행 단계로 유지했습니다.
기존 실행기의 Resume은 로그만으로 성공을 추정할 수 있어 이번 Step23 실행기에서는
실제 종료 코드0, 입력 코드 해시, 로그 해시, 실행 인자/모드/예상 warning이 일치하는 성공 기록이
있을 때만 재사용하도록 보강했습니다. 기존 검증 파일355개는 수정하지 않았습니다.

성능 감사에서는 실제 FAILURE Summary 생성 helper를 각 모드에서10,000번 호출했습니다.
headless 평균21.5561µs, Windows GPU 평균21.694µs였습니다. 현재 컬렉션 크기에서만 측정한 값입니다.
100회 실제 View 교체 후 프레임 대기를 포함한 시간은 각각 약2.06/2.12초이며 항상 ViewHost 자식1개입니다.
프레임 대기를 포함하므로 이 값을 순수 View 생성 시간으로 해석하지 않습니다.
현재는 선형 검색·동적 작은 목록·one-shot Timer에 의미 있는 성능 문제를 확인하지 못했습니다.
다수 항목/동시 View가 실제 요구될 때 프로파일링 후 필요한 최적화만 고려합니다.

| 번호 | 요청 보고 항목 | 결과 |
| --- | --- | --- |
| 1 | 작업 전 Git | HEAD6dbc42a, 재개 시 clean. 19~22단계는 이미 사용자 요청으로 커밋됨. |
| 2 | 전체 구조 | 소스63, GD/UID23씩, Scene10, Data Script11, 콘텐츠 .tres1. 기존 폴더 유지. |
| 3 | Main 크기 | 405줄/20함수→409줄/21함수. setup9, Stage Route9+결과2. |
| 4 | Main 책임 | 초기 검사/Runtime 생성, 창 표시, View lifecycle/setup, ID 검색, 승인 연결, Route, Summary. |
| 5 | Main 분리 | 현재 필요 없음. 단일 Case 조정자의 일관된 책임. |
| 6 | 책임 경계 | Data/Runtime/View/Main 경계 유지. 위 경계 표 참조. |
| 7 | View Runtime 접근 | 없음. getter 탐색이나 소유 없이 전달 snapshot만 사용. |
| 8 | View .tres load | 없음. 특정 테스트 Resource 경로는 Main Scene Inspector 연결에만 존재. |
| 9 | Resource 상태 혼입 | 없음. 선택·확정·실행 상태는 콘텐츠 필드에 없음. |
| 10 | ID 검색 helper | 직접5/간접2, Summary 매핑2/격리 승인loop1 추가 조사. |
| 11 | 실제 중복 검색 | Room 승인/요약 loop와 Option 검증/조회 반복. 다른 컬렉션 for 문은 서로 다른 관계. |
| 12 | 중복 제거 판단 | ID 검색 유지. 실제 불일치가 있던 lifecycle 검증만 공통 private helper로 정리. |
| 13 | Experiment ID | 3개 모두 유효·유일. |
| 14 | Room ID | 3개 모두 유효·유일. |
| 15 | Room→Outcome | 각 Room에 정확히 Outcome1개, 고아/중복 없음. |
| 16 | Outcome→Incident | FAILURE2개가 실제 Incident01/03에 연결. |
| 17 | Incident→Broadcast | Incident2개 모두 정확한 Broadcast01/03 연결. |
| 18 | Option ID | 각 Broadcast3개 유효·해당 Broadcast 내부 유일. |
| 19 | Option→Result | 6개 모두 실제 IncidentResult에 연결. |
| 20 | 중복 ID | 모든 해당 컬렉션/Option 범위 중복0. |
| 21 | Validator 시점 | 다중 Case 제작 시작 시 필요. 현재 제품 시스템 추가 없음. |
| 22 | Runtime 필드 | 소속 ID, 실행 순서, 확정 Room, 완료 결과, 확정 Broadcast/Option 맥락. 위 필드 표 참조. |
| 23 | Runtime 중복 | 불필요한 count/remaining/result_id/UI 상태 없음. 6필드 유지. |
| 24 | Summary | ResultView 표시용, 게임 규칙/장기 저장/두 번째 Runtime 아님. 그대로 유지. |
| 25 | Route | 기존 SUCCESS/FAILURE와 UNDEFINED=-1 보호 유지. |
| 26 | enum/Scene 위험 | 인덱스 결합은 있으나9개 명시적 목록과 실제 전체 매핑 검사로 현재 관리 가능. Router 재설계 없음. |
| 27 | lifecycle | 비활성 요청 Runtime 변경5개 재현·차단. Timer 종료/반복 setup/기존 stale 보호 회귀 통과. |
| 28 | 새 Case | 메모리 독립 Case를 ready 전 전달, 모든 값이 달라도 Core 추가 수정 없이7경로 통과. |
| 29 | 배열 순서 | 주요 배열/Option 역순에서도 ID 기반 연결 유지. UI 목록만 전달 배열 순서대로 표시. |
| 30 | Null 정책 | 정보성 진행/확정 전제/읽기 전용 종료에 맞는 정책 차이. 실제 모순 없음, 문서 설명 수정. |
| 31 | 자동 검증 | 과거 복제/긴 상속/내부 결합 확인. 최신 검사 재사용, Step23 Resume 성공 증거 보강, 기존 파일 보존. |
| 32 | 성능 | 현재 Summary 평균약22µs, 100교체 후 View1개. 현재 최적화 필요 없음. |
| 33 | 발견 문제 | 세 승인 callback의 약한 lifecycle 보호와 실행기의 불충분한 Resume 성공 근거. |
| 34 | 실제 수정 | Main private helper1개/guard5곳, README 경계·Next 정책·감사 보고, 로컬 Step23 실행기. |
| 35 | 유지한 구조 | Runtime/Data/모든 View/Scene/Route/ID 검색/Summary/설정. 기능과 참조 검사 정상. |
| 36 | 미래 정리 | 다중 Case Validator, 협업 시 공유 테스트/짧은 helper, 측정 후 검색 최적화, 요구 시 Case 시작/저장 경계. |
| 37 | SUCCESS 회귀 | Room02 실제 흐름과 독립 ALT Case 모두 M→RESULT→PROFILE 통과. |
| 38 | FAILURE 회귀 | Room01/03, A/B/C 모두 M→Incident→Broadcast→IncidentResult→RESULT→PROFILE 통과. |
| 39 | 전체 기능 회귀 | Profile/CCTV/실험 목록·선택·실행·limit·이력/격리·Confirm/Timer·결과/각 매핑·확정/요약 통과. |
| 40 | signal/stale | 비활성9사례, live3사례 승인·중복 기록 차단, 기존 stale/단일 View/반복 setup 연결1개 통과. |
| 41 | 해상도 | 1920×1080/1280×720/1024×768, logical1920×1080·canvas_items·keep·scaling 그대로. |
| 42 | 파싱/실행 | Godot4.7.1 import1 + 검사85 =86 성공. headless/Windows Compatibility GPU 모두. |
| 43 | diff --check | 통과. 공백 오류 없음. |
| 44 | 변경 파일 | Git 대상 Main/README2개 수정, 신규/삭제0. 로컬 검증 자료는 .godot/verification/step23에만. |
| 45 | 기존 변경 보존 | 이전 단계 내용 보존, 기존 소스61/UID23/검증 파일355 동일. HEAD/staging 변경 없음. |
| 46 | A: 유지 | Main/Resource/Runtime/View, typed Summary, 명시적 Stage/Route, ID 기반 관계. |
| 47 | B: 현재 수정 | 실제 비활성 승인 방어와 그 공통 검사, 문서 정확성, 로컬 Resume 성공 근거. |
| 48 | C: 미래 수정 | 다중 Case 제작 시 Validator, 규칙 증가 시 필요한 Main 분리, 협업/CI 시 검증 공통화, 측정 후 최적화. |
| 49 | 다음 추천 | 다음 요청에서 읽기 전용 Research Log부터 현재 실행 이력 getter→Main 전달→독립 View 표시 경계를 사용. 이번에는 구현하지 않음. |

검증 엔진은 `4.7.1.stable.official.a13da4feb`, Windows Compatibility/OpenGL3.3,
AMD Radeon RX6800입니다. 정상 검사와 새 감사 검사는 경고·오류 없이 종료 코드0입니다.
의도적 누락 데이터 검사는 기존 예상 warning 수를 유지하며 오류 없이 통과했습니다.
F5 키 자체는 자동 조작하지 않았고 같은 application/run/main_scene 기본 실행을 검증했습니다.
세 해상도의 ALT 결과 GPU 캡처21개를 만들고 SUCCESS/Room01·03 화면을 직접 확인했습니다.
1024×768 창의 콘텐츠 렌더는 기존 keep 비율대로1024×576입니다.

이번 단계의 게임 소스 변경은 Main의 최소 방어 수정뿐이며 README에49개 보고 항목을 기록했습니다.
참조 검사/다른 Case/성능/stale 검증과 입력·로그 해시 증거, 전후 diff·보존 해시는
Git에서 제외되는 `.godot/verification/step23/`에 있습니다. 기존 검증 소스는 그대로입니다.
Research Log/Campaign/다음 Case/저장/Settings/경제·점수·피해·할당량/이벤트/연출/최종 UI는
추가하지 않았고, 커밋·push도 수행하지 않았습니다.

## 22단계 읽기 전용 Case Result 요약 검증 결과

작업 전 실제 저장소 전체, 설정, 모든 Scene/Script/Resource와 기존 검증 코드/UID를 조사했습니다.
소스 61개, GDScript/UID 각각 22개, Scene 10개(Main + View 9개), 테스트 .tres 1개가 있었고
Autoload/플러그인은 없습니다. HEAD는 `ceb548b57d816a4e3251ddd893f80238e7e2ad14`입니다.
Step19~21의 기존 미커밋 파일은 수정 8개/신규 5개였습니다. 변경 전 사본·SHA-256·Git diff와
이전 검증 파일 318개의 해시를 `.godot/verification/step22/`에 먼저 보관했습니다.

이번 단계는 기존 파일 3개(Main Script, Result Scene, README)를 수정하고
`scripts/views/result_view.gd`와 Godot 생성 UID만 추가했습니다. 삭제는 없습니다.
CaseRuntimeState, 모든 Data Script/콘텐츠 .tres, 공용 flow_view, 다른 View, project.godot,
Main Scene, 기존 UID 22개, 이전 검증 파일 318개는 작업 전과 동일합니다.
최종 소스는 63개, GDScript/UID 각각 23개, Scene 10개입니다.
Git 누적 상태는 수정 9개/신규 7개이며 기존 Step19~21 파일을 포함한 숫자입니다.
커밋·push는 수행하지 않았습니다.

Main._build_result_summary()는 Runtime의 Case ID/결과/확정 Room/실행 이력 사본과
현재 Case의 display_name/limit, 정확한 ID로 찾은 Room/Experiment Resource를 전달합니다.
12개의 표시 항목을 긴 인자 목록으로 전달하는 대신 ResultView 안에 작은 typed RefCounted
`Summary`를 두었습니다. 콘텐츠 Resource, 저장 결과, Runtime 상태 타입이 아닙니다.
FAILURE일 때만 기존 Incident/Broadcast/확정 Option/IncidentResult 검색 helper를 호출합니다.
ResultView는 Main/Runtime/current_case/.tres를 탐색하거나 상태를 확정하지 않습니다.
기존 enum/PackedScene 인덱스/Route/stale 방어와 RESULT→PROFILE 정책은 보존했습니다.

```text
ResultView (Control, result_view.gd → 기존 flow_view.gd)
└── Center / Content (VBoxContainer)
    ├── ScreenTitle: RESULT
    ├── SummaryScroll (ScrollContainer, 900×220 기준)
    │   └── SummaryColumns (HBoxContainer)
    │       ├── Common (VBoxContainer)
    │       │   ├── Description: Case ID/이름
    │       │   ├── FinalResult / Containment / ExperimentUsage
    │       │   ├── ExperimentTitle / ExperimentEmpty
    │       │   └── ExperimentList (실행 순서의 동적 Label)
    │       └── FailureDetails (VBoxContainer)
    │           ├── IncidentInfo / BroadcastInfo
    │           └── ResponseInfo / IncidentResultInfo
    └── NextButton: Restart: PROFILE
```

| 번호 | 보고 항목 | 구현 및 검증 결과 |
| --- | --- | --- |
| 1 | 작업 전 Git | HEAD ceb548b, Step19~21 수정8/신규5. 작업 전 사본·해시·diff 보관. |
| 2 | 기존 Result | flow_view.gd 기반 임시 설명과 Restart, 전용 Script 없음. |
| 3 | 변경 Result | 기존 Control/제목/Restart 유지, 공통·실패 요약 2열과 최소 ScrollContainer. |
| 4 | 전용 Script | result_view.gd와 UID 추가, 기존 flow_view.gd 한 단계 상속. |
| 5 | 데이터 전달 | Main → 작은 typed Summary(RefCounted) → setup. View는 전달 내용만 읽음. |
| 6 | CaseResult Resource | 생성하지 않음. 새 콘텐츠 타입/저장 결과/이력 없음. |
| 7 | Runtime | 파일·필드·API 변경 없음. 확정과 reset 동작도 기존 그대로. |
| 8 | Case 정보 | Runtime case_id와 현재 Case.display_name을 함께 표시. |
| 9 | 최종 결과 | Runtime Monitoring SUCCESS/FAILURE 표시. UNDEFINED는 경고와 unavailable. |
| 10 | Containment | 확정 ID를 현재 Case Room과 매핑, ID/이름 표시. |
| 11 | 실행 이력 | Runtime history 사본을 기준으로 동적 Label 생성. 0/1/2/12개 검증. |
| 12 | 순서 | 정렬 없음. 03→01 그대로 표시, Case 배열을 뒤집어도 ID 매핑 유지. |
| 13 | 사용 수 | history.size / Case.experiment_limit. 기본 2/2, 향후 12/12 표시 검증. |
| 14 | SUCCESS Incident | None (not occurred), Broadcast/응답/IncidentResult는 Not applicable. |
| 15 | FAILURE Incident | 기존 Outcome→Incident ID helper로 찾은 정확한 ID/이름. |
| 16 | Broadcast | Incident.broadcast_id로 검색한 Broadcast ID/이름. |
| 17 | 확정 Option | Runtime 확정 ID 쌍에 대응하는 Option ID/display_text. 임시 선택은 사용 안 함. |
| 18 | IncidentResult | 확정 Option.result_id로 검색한 Result ID/이름. 다른 결과 fallback 없음. |
| 19 | Room02 SUCCESS | 실제 GUI Experiment01+03/Room02 확정/Monitoring 재생 후 공통 요약과 없음 표시. |
| 20 | Room01 FAILURE | Incident01/Broadcast01/확정 Option/대응 Result 정확히 표시. |
| 21 | Room03 FAILURE | Incident03/Broadcast03/각 03 Option/Result 표시, Room01 누출 없음. |
| 22 | Broadcast01 A | TEST_OPTION_01_A / TEST_INCIDENT_RESULT_01_A 표시. |
| 23 | Broadcast01 B | TEST_OPTION_01_B / TEST_INCIDENT_RESULT_01_B 표시. |
| 24 | Broadcast01 C | TEST_OPTION_01_C / TEST_INCIDENT_RESULT_01_C 표시. |
| 25 | Experiment 누락 | 실제 실행 ID·순서·사용 수 유지, [Unavailable]과 warning. 다른 이름 대체 없음. |
| 26 | Room 누락 | Runtime 확정 ID 유지, [Unavailable]과 warning. 다른 Room 대체 없음. |
| 27 | 일부 FAILURE 누락 | Incident/Broadcast/확정 Option/Result 각각 누락 검증. 해당 항목 unavailable, 크래시 없음. |
| 28 | 반복 setup | SUCCESS↔FAILURE, Room01→03, 유효→누락→유효, 기존 Label 해제·문구 초기화·signal 1개. |
| 29 | Runtime 불변성 | 생성/진입/재진입/setup 전후 객체·Case ID·이력·사용 수·Room·결과·확정 쌍·API 호출 수 동일. |
| 30 | Restart | PROFILE로 이동만 수행. 같은 Runtime의 모든 상태 유지. stale Result 요청도 무시. |
| 31 | Resource 불변성 | 모든 콘텐츠 필드 snapshot와 파일 SHA-256 동일. 표시 시 Resource에 쓰지 않음. |
| 32 | Experiment 회귀 | 선택/실행/중복/limit/Runtime/재진입 통과. 실제 실행01+03 결과 요약도 검사. |
| 33 | Containment 회귀 | 선택/Confirm/1회 확정/후보 검증/재진입/진행 보호 통과. |
| 34 | Monitoring 회귀 | 실제 0/1/2초 및 제품 20초 Timer, 순차 공개/한 번 결과 확정/복원/UNDEFINED 차단 통과. |
| 35 | Incident 회귀 | ID 매핑, 표시/누락 처리, Broadcast 가용성에 따른 Next 보호 통과. |
| 36 | Broadcast 회귀 | ID 매핑/임시 단일 선택/Confirm/확정 쌍 기록/복원/잠금/누락 보호 통과. |
| 37 | IncidentResult 회귀 | 6개 Option→Result ID 매핑, 역순 배열, 표시/누락/현재 연결 검증 통과. |
| 38 | 전체 Route | SUCCESS M→R→PROFILE, FAILURE M→I→B→IR→R→PROFILE. enum/배열/분기 그대로. |
| 39 | signal/stale | 주요 View 하나, 이전 View 해제, 반복 setup의 연결1개, stale/Tree 밖/삭제 예정 발신 방어. |
| 40 | 해상도/Stretch | 1920×1080/1280×720/1024×768, 논리1920×1080, canvas_items/keep/resizable 유지. |
| 41 | 파싱/실행 | Godot4.7.1 import 1개 + Script/회귀/새 요약 검사79개 성공. headless와 Windows GPU 실행. |
| 42 | 문제/해결 | 최초 요약 높이의 ViewHost 초과를 Scroll 220으로 해결. 실패 항목 간격8로 기본 내용 전체 표시. 미해결 제품 오류 없음. |
| 43 | 변경 파일 | 수정 Main/Result Scene/README 3개, 신규 Result Script/UID 2개, 삭제0. |
| 44 | 기존 변경 보존 | Step19~21 내용/신규5개 유지. Main의 이번 추가를 제거하면 작업 전 내용과 동일. 기존 source58/UID22/검증318개 동일. |
| 45 | 미구현 | Campaign/다음 Case/Restart reset/피해·사망·점수·보상·penalty·quota·economy/Research Log/저장/Settings/Manager/연출/최종UI 없음. |
| 46 | 다음 확장 지점 | 현재 확정 상태 → Main._build_result_summary() → ResultView.setup(Summary)의 표시 경계. 저장/진행은 요구가 정해졌을 때 별도 설계. |

Godot 검증 엔진은 `4.7.1.stable.official.a13da4feb`, Windows Compatibility/OpenGL3.3,
AMD Radeon RX6800입니다. 정상 검사는 경고·오류 없이 종료 코드0입니다.
의도적으로 잘못된 데이터를 넣는 edge 검사는 예상 warning만 있으며 오류 없이 통과했습니다.
Step22 누락 검사는 headless/GPU 각각 warning31개를 명시적으로 검사합니다.
이전 edge 검사의 RESULT 강제 진입에 새 요약이 적용되므로 네 검사의 예상 warning 수만
81/27/126/108로 조정했고 실제 메시지 내용을 확인했습니다. 다른 회귀 기대값은 유지했습니다.
새 검증 스크립트의 Array 타입 처리 오류도 수정 후 정상 통과했습니다.

새 RESULT GPU 캡처는 기본7경로×세 창 크기21개와 12개 이력 top/bottom×세 크기6개,
총27개입니다. 원본/작은 창의 SUCCESS/Room01·03 및 긴 목록 캡처를 직접 확인했습니다.
1024×768 창의 렌더 콘텐츠는 기존 비율대로 1024×576이며 여백 유지 설정은 변경하지 않았습니다.
F5 키 자체는 자동 조작하지 않았고 동일한 application/run/main_scene의 기본 실행을 양쪽 모드로 검사했습니다.
검증 파일/로그/캡처/전후 비교는 Git 제외 경로 `.godot/verification/step22/`에만 있습니다.

## 21단계 Broadcast Option과 Incident Result 연결 검증 결과

작업 전 실제 저장소 전체와 현재 Git diff를 조사했습니다. 소스 56개, GDScript 20개/UID 20개,
Scene 9개(Main + View 8개), 테스트 Case Resource 1개가 있었습니다. Autoload/플러그인은 없습니다.
HEAD는 `ceb548b57d816a4e3251ddd893f80238e7e2ad14`이며 README, Broadcast Scene, Main,
CaseRuntimeState, BroadcastView의 19·20단계 변경 5개가 미커밋 상태였습니다.
이 상태의 소스 사본·SHA-256·Git diff와 기존 검증 코드 282개의 해시를 먼저 보관했습니다.

이번 단계의 기존 파일 수정은 6개입니다.

- `scripts/data/broadcast_option_data.gd`: result_id 필드 하나 추가.
- `scripts/data/case_data.gd`: incident_results 배열 하나 추가.
- `resources/cases/test_case_01.tres`: 각 Option의 ID 연결과 임시 결과 6개 추가, 기존 콘텐츠 보존.
- `scripts/main/main.gd`: 확정 Option/Result ID 검색, Confirm 결과 연결 검사, Stage/진행 보호.
- `scenes/views/broadcast_view.tscn`: 기존 Next의 문구만 Next: INCIDENT RESULT로 변경.
- `README.md`: 현재 동작/구조/이번 보고 반영, 이전 단계 보고 보존.

새 파일은 5개입니다.

- `scripts/data/incident_result_data.gd`와 Godot가 생성한 `.gd.uid`.
- `scripts/views/incident_result_view.gd`와 Godot가 생성한 `.gd.uid`.
- `scenes/views/incident_result_view.tscn`.

삭제 파일은 없습니다. Runtime과 BroadcastView Script는 이번 단계에서 변경하지 않았습니다.
Git 누적 diff의 Runtime/View 변경은 기존 19·20단계 변경입니다. 최종 소스는 61개,
GDScript 22개/UID 22개, Scene 10개(Main + View 9개)이며 해상도/Stretch 설정은 그대로입니다.

연결은 `Runtime 확정 Broadcast ID/Option ID → 현재 Case의 Broadcast/Option 검색 → Option.result_id`
`→ Case.incident_results의 동일 result_id 검색 → IncidentResultView.setup(result)`입니다.
별도 Result Runtime 필드, 상태 완료 플래그, Manager나 결과 평가 시스템은 없습니다.
Main은 선택 요청의 결과 연결을 확인한 뒤에만 Runtime에 최초 ID 쌍을 기록합니다.
확정 전에 잘못된 연결을 거부해 다른 정상 Option을 다시 선택할 수 있습니다.
확정 후에는 BROADCAST와 INCIDENT_RESULT 양쪽의 advance 처리에서 현재 결과 연결을 다시 검사합니다.
잘못된 콘텐츠로 바뀌면 이미 표시된 유효 snapshot이나 직접 signal이 있어도 진행하지 않습니다.

```text
IncidentResultView (Control, incident_result_view.gd → 기존 flow_view.gd)
└── Center (CenterContainer)
    └── Content (VBoxContainer)
        ├── ScreenTitle: INCIDENT RESULT
        ├── DisplayName
        ├── ResultId
        ├── Description (줄바꿈)
        └── NextButton: Next: RESULT
```

Godot `4.7.1.stable.official.a13da4feb`에서 에디터 import 1회와 정식 검증 74개를 통과했습니다.
22개 GDScript check-only, headless/GPU Main 실행, 기존 회귀 및 새 정상/예외 검사를 포함합니다.
6개 Option 각각을 세 창 크기에서 실제 입력/표시로 확인하고 결과 배열뿐 아니라 Broadcast/Option 배열도 뒤집었습니다.
정상 검사는 오류·경고가 없으며 고의 누락/잘못된 데이터 검사에서만 예상 경고가 발생했습니다.
Incident Result 예외의 경고는 실행 모드마다 79개, 기존 Broadcast Confirm 25개, Broadcast 109개,
Incident 100개, Monitoring 결과 10개, Containment 9개, Experiment 제한 17개, Playback 17개로 예상값과 일치했습니다.
기존 원본 0/10/20초 Monitoring 재생도 양쪽 모드에서 통과했습니다. F5 키를 직접 누르지는 않았고
F5와 같은 설정된 Main Scene을 명령행으로 실행했습니다. GPU 캡처도 직접 확인했습니다.

| 번호 | 요청 항목 | 결과 |
| --- | --- | --- |
| 1 | 작업 전 Git | HEAD ceb548b, 기존 19·20단계 5개 수정. 사본/해시/diff 보관. staged·신규·삭제 없음. |
| 2 | IncidentResultData | 기존 Resource 클래스 패턴으로 독립 class_name/Resource 구현. |
| 3 | Result 필드 | result_id, display_name, description 세 String만 export. description은 multiline. |
| 4 | BroadcastOptionData | result_id String 하나만 추가, 선택/확정 상태 필드 없음. |
| 5 | CaseData | incident_results: Array[IncidentResultData] = [] 하나 추가. |
| 6 | 테스트 Result | 01-A/B/C, 03-A/B/C를 구별하는 개발용 데이터 6개. |
| 7 | Option 연결 | TEST_OPTION_01/03_A/B/C → TEST_INCIDENT_RESULT_01/03_A/B/C 각각 연결. |
| 8 | 확정 Option 검색 | 현재 FAILURE/Incident/Broadcast와 Runtime 쌍 검증 후 options에서 ID 검색. |
| 9 | Result 검색 | Option.result_id를 Case.incident_results의 result_id와 비교, 정확한 객체 반환. |
| 10 | ID 매핑 | 배열 index 및 첫 Result fallback 없음, 배열 역순에서도 동일 ID. |
| 11 | Confirm 강화 | 실제 Result 연결이 유효할 때만 Runtime 기록 API 호출. |
| 12 | 빈 result_id | 빈 문자열·공백 모두 거부, Runtime/Next 미변경, 정상 Option 재선택 가능. |
| 13 | 없는 result_id | 거부, 기록 API 호출 0, Next disabled, 크래시 없음. |
| 14 | Runtime | 파일/필드/API/reset 모두 20단계와 동일, Result는 기존 쌍에서 파생. |
| 15 | Stage | INCIDENT_RESULT=8을 끝에 추가, 기존 0~7 유지. PackedScene과 일치. |
| 16 | FAILURE Route | MONITORING→INCIDENT→BROADCAST→INCIDENT_RESULT→RESULT→PROFILE. |
| 17 | Scene | 독립 Control/Center/VBox, 제목·이름·ID·설명·Next만 구성. |
| 18 | Script | FlowView 한 단계 상속, setup/표시/누락 처리/안전한 진행 요청만 담당. |
| 19 | 데이터 전달 | Main이 현재 결과를 검색하고 setup(result) 전달. View는 Main/Runtime/Case/tres 탐색 안 함. |
| 20 | Option01-A | TEST_INCIDENT_RESULT_01_A의 ID/이름/설명 정확히 표시. |
| 21 | Option01-B | TEST_INCIDENT_RESULT_01_B 표시. |
| 22 | Option01-C | TEST_INCIDENT_RESULT_01_C 표시. |
| 23 | Broadcast03 | A/B/C 각각 03_A/B/C 표시, 01 결과 누출 없음. |
| 24 | 배열 순서 변경 | Result/Broadcast/Option 배열을 역순으로 바꿔도 6개 매핑 모두 통과. |
| 25 | 누락 Result | 빈 배열/없는 연결/일치 후보 없음은 warning, 대체 표시/Next 차단, fallback 없음. |
| 26 | null Result | 검색 시 warning 후 건너뜀, View null은 이전 텍스트 초기화/Next disabled. |
| 27 | 빈 필드 | 빈·공백 result_id 후보 제외. 정상 ID의 빈 이름/설명은 warning/[Missing ...], 표시/진행 허용. |
| 28 | Next 보호 | 유효 Result에서만 View Next 활성, BROADCAST/INCIDENT_RESULT 둘 다 Main 최신 검증. |
| 29 | 직접 signal | 직접 advance·강제 pressed·위조 유효 View snapshot도 실제 연결이 없으면 차단. |
| 30 | Broadcast 재진입 | 기존 확정 잠금 복원, 재기록 없이 현재 Option.result_id로 정확한 결과 검색. |
| 31 | 반복 setup | 준비 전/후, valid→null→valid, 01-A→03-C, 빈 필드/ID 갱신, 노드/signal 중복 없음. |
| 32 | stale signal | 이전 Broadcast/IncidentResult 및 해제 예정/Tree 밖 View 요청 무시. |
| 33 | Runtime 독립성 | 기존 실험 이력/남은 횟수·격리 Room·Monitoring 결과·확정 쌍 보존. |
| 34 | Resource 불변성 | 콘텐츠 정의의 허용 추가 외 실행 중 파일 해시 및 메모리 콘텐츠 snapshot 변화 없음. |
| 35 | SUCCESS Route | Room02는 RESULT 직행, Incident/Broadcast/Incident Result 검색·생성·기록 없음. |
| 36 | FAILURE Route | Room01/03 모두 Confirm 이후 새 결과 화면을 거쳐 RESULT. |
| 37 | Experiment | 동적 목록·선택·실행·결과·ID 중복·limit·Runtime 회귀 통과. |
| 38 | Containment | 후보·선택·Confirm·1회 확정·Room·진행 보호 회귀 통과. |
| 39 | Monitoring | Timer·누적 공개·결과 확정·재진입·SUCCESS/FAILURE·UNDEFINED 차단 회귀 통과. |
| 40 | Incident | ID 연결·표시·누락·현재 데이터 재검증 회귀 통과. |
| 41 | Broadcast | ID 연결·동적 목록·단일 선택·Confirm·잠금·Runtime 복원·우회 차단 통과. |
| 42 | 전체 Route | 기존 주요 화면, 두 분기, RESULT→PROFILE, 한 주요 View만 유지. |
| 43 | signal | 버튼/진행/확정 연결 수 1, 반복 setup/재진입/전환에서 중복 없음. |
| 44 | 해상도/Stretch | 1920×1080, 1280×720, 1024×768에서 논리 UI 1920×1080 및 canvas_items/keep 유지. |
| 45 | 파싱/실행 | 에디터 import + 74개 검사 통과, 파싱/GDScript 오류 없음, 실제 Main 실행/GPU 화면 확인. |
| 46 | 문제/해결 | 제품 오류 없음. 기존 검증 코드의 Route 기대값만 새 Stage에 맞춘 복사본에서 갱신. |
| 47 | 실제 변경 | 기존 파일 6개 수정, 새 파일 5개(UID2 포함), 삭제 0. 누적 Git에는 이전 단계 변경도 함께 표시. |
| 48 | 보존 | 기존 소스 50개·기존 UID20개·검증282개·이전 보고·Runtime/BroadcastView 보존, commit/push 없음. |
| 49 | 미구현 | 피해/사망/점수/보상/페널티/등급/Case Result/Research Log/Campaign/Save·Load/GameState/Manager/Audio/Animation/Shader/최종 UI. |
| 50 | 다음 지점 | IncidentResultData → Main의 ID 검색 → IncidentResultView.setup 경계에서 다음 요구사항만 확장. |

작업 전 사본, 이번 단계만의 diff, 누적 Git diff, 검증 코드/로그/캡처는 Git 제외
`.godot/verification/step21/`에 보관합니다. 같은 Case의 RESULT→PROFILE은 기존 Runtime 유지 정책입니다.


## 20단계 Broadcast Confirm과 Runtime 기록 검증 결과

작업 전에 실제 저장소의 파일·Scene·Script·Resource·설정·Git 상태를 조사했습니다.
소스 56개, GDScript 20개, Scene 9개(Main + View 8개), 테스트 Case Resource 1개가 있었습니다.
HEAD는 `ceb548b57d816a4e3251ddd893f80238e7e2ad14`이며 README와 BroadcastView에 19단계 미커밋 변경이 있었습니다.
작업 전 56개 파일 사본·SHA-256·Git diff와 기존 검증 코드 250개의 해시를 보관했습니다.

이번 단계는 기존 프로젝트의 5개 파일을 수정했습니다. 새 프로젝트/소스 파일 생성과 파일 삭제는 없습니다.

- `scripts/runtime/case_runtime_state.gd`: 확정 ID 문자열 2개, 한 번 기록/조회 API, reset 확장.
- `scripts/main/main.gd`: 요청 연결, 현재 Broadcast/Option ID 검증, 실제 Runtime snapshot 전달, 확정 전 진행 차단.
- `scripts/views/broadcast_view.gd`: 기존 동적 목록/임시 단일 선택을 보존하고 Confirm 요청·잠금·복원 추가.
- `scenes/views/broadcast_view.tscn`: Actions/ConfirmButton 추가, 기존 NextButton을 Actions로 이동.
- `README.md`: 현재 동작과 이번 검증 결과 반영. 아래 이전 단계 보고는 그대로 보존했습니다.

Godot `4.7.1.stable.official.a13da4feb`에서 에디터 import 1회와 정식 검증 68개를 통과했습니다.
20개 GDScript check-only, headless 및 실제 OpenGL GPU Main 실행, 정상/예외/전체 흐름 회귀를 포함합니다.
정상 검사에는 오류·경고가 없고, 고의 누락/불일치 검사에서만 예상된 경고가 발생했습니다.
Broadcast Confirm 예외 25개, 기존 Broadcast 105개, Incident 100개, Result 10개,
Containment 9개, Experiment 제한 17개, Monitoring 재생 17개의 경고가 각 실행 모드에서 예상값과 일치했습니다.
Room02의 원본 0/10/20초 재생도 headless/GPU 양쪽에서 그대로 검증했습니다.
에디터 F5 키를 직접 누르지는 않았으며 F5와 같은 설정된 Main Scene을 명령행으로 실행했습니다.

| 번호 | 요청 항목 | 결과 |
| --- | --- | --- |
| 1 | 작업 전 Git | HEAD ceb548b, README/View 2개 수정, staged·신규·삭제 없음. 19단계 변경 사본 보관. |
| 2 | Runtime 상태 | `_confirmed_broadcast_id`, `_confirmed_broadcast_option_id`: String, 초기 빈 문자열. |
| 3 | Runtime API | try_confirm_broadcast_option / has_confirmed_broadcast_option / 두 ID getter, 명시적 bool/String 반환. |
| 4 | reset | 두 ID를 함께 비우고 기존 Case ID 정책·실험 이력·격리·Monitoring 초기화 보존. |
| 5 | Confirm 버튼 | Broadcast Scene Actions에 Confirm Broadcast 추가, 기존 Next 재사용. |
| 6 | 초기 Confirm | disabled, 선택 없음. |
| 7 | 초기 Next | 유효 목록이어도 disabled. |
| 8 | Option 선택 | 하나만 임시 선택, Confirm enabled, Next disabled. 재클릭 유지. |
| 9 | 선택 변경 | Runtime 전체 snapshot과 Resource가 그대로 유지됨. |
| 10 | signal | View의 broadcast_confirmation_requested(Broadcast ID, Option ID) → Main, 발신 View bind. |
| 11 | Broadcast 재검증 | Main이 현재 Case/FAILURE/확정 Room/Outcome/Incident 연결에서 다시 검색. 요청 ID 일치 필수. |
| 12 | Option 재검증 | 현재 options의 ID 검색. 순서 변경·null·빈 ID 후보에도 인덱스로 기록하지 않음. |
| 13 | 정상 Confirm | 최초 정상 쌍만 승인, 실제 Runtime 상태를 UI에 반영. |
| 14 | Runtime 기록 | 두 ID 함께 1회 기록. 테스트 계수로 Main의 기록 API 호출 1회 확인. |
| 15 | UI 잠금 | 모든 Option/Confirm disabled, 확정 항목만 [Confirmed] 및 선택 표시. |
| 16 | 확정 Next | 일치하는 정상 snapshot에서 enabled, Main도 현재 데이터와 실제 Runtime 재검증. |
| 17 | 두 번째 Confirm | 같은/다른 요청 거부, 최초 쌍과 기존 상태 보존. |
| 18 | 없는 Option ID | 기록/진행 거부, 미확정 Next disabled 유지. |
| 19 | Broadcast ID 불일치 | 다른/없는/빈·공백 ID 거부. |
| 20 | 선택 없이 Next | 강제 pressed·직접 advance도 View/Main에서 차단. |
| 21 | 선택만 후 Next | Runtime 미확정이므로 강제 pressed·직접 advance 차단. |
| 22 | Broadcast01 | Room01 FAILURE → Incident01 → Broadcast01, A→B 선택/확정 → RESULT 검증. |
| 23 | Broadcast03 | Room03 FAILURE → Incident03 → Broadcast03, A→B 선택/확정 → RESULT 검증. |
| 24 | 재진입 | 같은 Broadcast의 잠금/표시/Next 복원, Runtime 재기록 없음. |
| 25 | snapshot 불일치 | 다른 Broadcast/없는 Option/부분 ID 쌍은 warning, false 확정 표시 없음, Next 차단. |
| 26 | 반복 setup | 준비 전/후, 같은/다른 Broadcast, null→정상, 3→4→2→4 Option 목록·선택·그룹·snapshot 초기화 확인. |
| 27 | stale signal | 이전 View, Tree 밖, 해제 예정 View/이전 Option 그룹 요청 무시. |
| 28 | SUCCESS | Room02는 RESULT 직행, Incident/Broadcast 검색·생성·확정 기록 없음. |
| 29 | FAILURE | Room01/03은 Incident/Broadcast를 거치고 확정 후에만 RESULT 진입. |
| 30 | Runtime 독립성 | 실험 이력/횟수·격리 Room·Monitoring FAILURE 보존, 독립 Runtime은 새 쌍 없음. |
| 31 | Resource 불변성 | Data Script 및 test_case_01.tres 해시/메모리 콘텐츠 snapshot 보존. |
| 32 | Experiment | 단일 선택/즉시 결과/ID 중복·Case 제한/이력/재진입 회귀 통과. |
| 33 | Containment | 동적 후보/단일 선택/1회 확정/잠금/Room ID/진행 보호 회귀 통과. |
| 34 | Monitoring | Timer 누적 표시/완료 검증/1회 결과/복원/UNDEFINED 차단 통과. |
| 35 | Incident | ID 연결·누락·표시·Next/현재 데이터 재검증 회귀 통과. |
| 36 | 전체 Route | PROFILE→CCTV→EXPERIMENT→CONTAINMENT→MONITORING, SUCCESS/FAILURE 경로, RESULT→PROFILE 통과. 한 주요 View만 유지. |
| 37 | signal 중복 | 반복 setup/재진입에서도 버튼·요청 연결 수 1, 중복 전환·기록 없음. |
| 38 | 해상도/Stretch | 1920×1080 / 1280×720 / 1024×768, 논리 UI 1920×1080, canvas_items/keep 유지. 실제 Main 캡처와 경계 검사 통과. |
| 39 | 파싱/실행 | 에디터 import + 68개 검사 통과, Main 실행 가능, GDScript/파싱 오류 없음. |
| 40 | 문제/해결 | 독립 View 테스트 캡처 뒤에 이전 Main이 남는 문제를 테스트에서 숨김 처리 후 재검증. 예상 경고 수를 실제 예외 사례와 일치시킴. 제품 오류는 발견하지 않음. |
| 41 | 실제 변경 | 위 5개 파일. Git 전체 diff에는 기존 19단계 2개 파일 변경이 함께 포함됨. 소스 신규/삭제 없음. |
| 42 | 기존 보존 | 19단계 선택/누락/동적 목록과 이전 보고 보존, project.godot/Main Scene/Resource/UID20개/기존 검증250개 보존. 커밋·push 없음. |
| 43 | 미구현 | Option 결과/Incident 결과/피해/점수/Broadcast 성공·실패/Case Result/Research Log/Campaign/Save·Load/GameState/Manager/Audio/Animation/Shader/최종 UI. |
| 44 | 다음 지점 | Runtime 확정 ID 쌍과 Main의 현재 Resource 검증 경계. 다음 요구사항이 정해지면 이 쌍을 입력으로 필요한 동작만 확장. |

검증 코드·로그·캡처·작업 전 사본은 Git 제외 `.godot/verification/step20/`에 있습니다.
실제 Main 확정 화면은 `selection_room1_confirmed_*` / `selection_room3_confirmed_*` 캡처에서 확인할 수 있습니다.
일반 RESULT→PROFILE은 기존 정책대로 같은 Case 상태를 유지하며 새 Case 초기화는 Runtime.reset() 경계입니다.

## 19단계 Broadcast Option 단일 선택 검증 결과

Godot **4.7.1.stable.official.a13da4feb**에서 production Script20개 check-only,
headless/Windows Compatibility GPU 실행·회귀·예외 검사48회, editor import1회로 최종 **69개 검사**를 통과했습니다.
정상 입력은 오류·경고0이며, 의도적인 예외의 warning은 각 환경에서 선택5 / Broadcast103 /
Incident100 / Result10 / 격리확정9 / 실험제한17 / Playback17건으로 예상과 일치했습니다.
최종 수정 전후 테스트용 헬퍼 이름 충돌과 direct pressed 표시 문제를 수정하고 최종 코드 전체를 다시 검증했습니다.
기본 프로젝트 Main 실행과 GPU GUI 마우스 이벤트로 검증했으며 F5 키 자체는 자동 조작하지 않았습니다.

| 번호 | 보고 항목 | 결과 |
| --- | --- | --- |
| 1 | 작업 전 Git | HEAD ceb548b, master→origin/main, clean. Step18 이미 커밋·push, 미커밋 변경 없음. 전체56소스/Scene/Script/Resource/UID/설정과 Main setup/Next/Route/신호/해제, 기존 Experiment·Containment CheckBox/ButtonGroup, 이전 검증 조사 |
| 2 | 선택 방식 | 기존 검증 패턴인 CheckBox + ButtonGroup. allow_unpress=false, 로컬 pressed 처리에서 그룹 표시를 동기화 |
| 3 | Option Node | OptionList의 각 HBoxContainer → CheckBox + ID/문구 Label. 기존18px 줄바꿈 Label 유지, null은 기존대로 건너뜀 |
| 4 | Item Scene | 생성하지 않음. 간단한 동적 Control 생성만으로 충분하고 다른 코드 중복을 줄일 필요가 없음 |
| 5 | 상태 위치 | BroadcastView._selected_option_index=-1과 _selection_group만 사용. Main 선택 상태 없음 |
| 6 | 콘텐츠/Runtime 분리 | Data Script/Resource/Main/CaseRuntimeState 수정 없음. 선택은 View 생성 동안의 임시 UI 상태 |
| 7 | 선택 UI | Godot 기본 CheckBox 라디오 표시. 별도 Theme/색상/최종 디자인/선택 문구 없음 |
| 8 | 초기 상태 | 준비 전 setup/최초 진입/반복 setup/재진입 모두 선택 없음. 첫 항목 자동 선택 없음 |
| 9 | A 선택 | A만 표시되고 선택 index0 |
| 10 | B 변경 | A 해제, B만 표시되고 index1 |
| 11 | C 변경 | B 해제, C만 표시되고 index2 |
| 12 | 같은 항목 재클릭 | C 재클릭에도 C 선택 유지. 클릭해서 해제되는 Toggle 없음 |
| 13 | 최대 하나 | 빠른 GUI 클릭과 반복당90개 direct pressed 요청에서 모두 하나만 선택. set_pressed_no_signal로 재귀 signal 없이 동기화 |
| 14 | Broadcast01 | A→B→C→C, 초기/선택 상태/Next/신호/콘텐츠 불변성 모두 세 크기에서 headless/native 통과 |
| 15 | Broadcast03 | 같은 선택 규칙 통과, 01→03→01 반복 때 선택 누출 없음 |
| 16 | 재진입 | Room01/03 각각3회 콘텐츠 정확히 복원, 선택은 없음으로 초기화. 이전 Runtime 상태 유지 |
| 17 | 반복 setup | 01→03→01, 선택→null→유효, 3→4→2→4→3에서 목록/그룹/index/스크롤 초기화. 이전 행 해제와 이전 버튼 signal 무시 확인 |
| 18 | null Option | 경고 후 행 생성 없이 건너뜀. 이후 유효 Option의 원본 배열 index와 선택이 정확함 |
| 19 | 빈 option_id | 빈 문자열/공백 모두 disabled. GUI/직접 pressed/disabled 강제 변경 후 pressed도 로컬 데이터 검사로 차단 |
| 20 | 빈 display_text | 경고/[Missing display_text at index N] 표시. 유효 ID이면 정상 선택 가능 |
| 21 | 3→4 | 독립 Resource 복사본의 배열만 늘려4개 표시/선택/한 개 유지, production 코드나 .tres 변경 없음 |
| 22 | 3→2 | 배열만 줄여2개 표시/선택/재클릭/한 개 유지. 이전 Option 누적 없음; 2→4도 통과 |
| 23 | Resource 불변성 | BroadcastOption/EmergencyBroadcast/Incident/Case/원본 .tres와 나머지 Data Script 모두 작업 시작 SHA-256 동일. 선택 후 메모리 콘텐츠 snapshot도 동일 |
| 24 | Runtime | CaseRuntimeState 파일 동일. 선택·전환·재진입 전후 Case ID/실험 이력·남은 횟수/격리 ID/Monitoring 결과와 객체 동일. Broadcast 필드 추가 없음 |
| 25 | Next 유지 | 선택 없음과 선택 후 모두 유효 Broadcast+유효 Option≥1이면 Next 가능. 기존 _has_valid_options/_on_next_button_pressed/Main guard 정확히 보존 |
| 26 | SUCCESS | Room02 Monitoring→SUCCESS→RESULT→PROFILE. 실수로 Incident ID가 있어도 Incident/Broadcast lookup0, View 생성 없음 |
| 27 | FAILURE | Room01/03 Monitoring→FAILURE→각 Incident→각 Broadcast→RESULT→PROFILE. 선택 없이도 진행, 선택 후도 동일 |
| 28 | 진행 보호 | 누락 Broadcast/무효 Option의 Incident·Broadcast UI/Main 차단, 직접 signal/위조 snapshot/최신 Case 변경 재검증 통과 |
| 29 | Experiment | 동적 목록/단일 선택/실행/결과/ID 중복 방어/limit/남은 횟수/Runtime 이력/재진입 회귀 통과 |
| 30 | Containment | 동적 목록/단일 선택/Confirm/확정 ID/확정 후 변경 차단/재진입 복원/Monitoring 진입 보호 통과 |
| 31 | Monitoring | Room ID 매핑/Timer 순차 공개/미래 기록 비공개/한 번 결과 확정/복원/UNDEFINED·미완료 차단 통과. 복사본0/1/2초 전체 흐름과 원본0/10/20초 별도 실제 재생 |
| 32 | signal/stale | Next 연결1개, 각 Option pressed 연결1개, 선택은 Main에 signal 없음. 이전 그룹/Tree 밖/해제 예정 버튼·View 요청 무시, 전환 시 단일 View/해제 확인 |
| 33 | 크기/Stretch | 1920×1080·1280×720·1024×768 통과. 논리1920×1080/canvas_items/keep 유지. 1024×768의 콘텐츠 렌더는1024×576. 선택 상태21개 캡처 생성, 세 크기 직접 확인 |
| 34 | 파싱/실행 | 최종69검사 통과, 모든 정상 로그 오류·경고0. AMD RX6800/OpenGL3.3 Compatibility GPU 실행/GUI 입력 검증 |
| 35 | 문제/해결 | 테스트 헬퍼 _button이 상속된 기존 헬퍼와 충돌해 _option_button으로 변경. 직접 pressed 후 set_pressed_no_signal(true)만으로는 다른 버튼이 해제되지 않아 그룹 전체 표시 동기화 추가. 최종 전체 검사 통과, 미해결 오류 없음 |
| 36 | 실제 파일 | production 수정2개: scripts/views/broadcast_view.gd, README.md. 생성/삭제0, Scene/Data/Main/Runtime/UID 추가 없음. 소스56개 유지 |
| 37 | 기존 보존 | Step18 커밋 ceb548b 유지, 다른54소스와 UID20개/Main/모든Scene/모든Resource/설정/이전 검증221개/역사 보고 보존. diff --check 통과. staging/커밋/push 없음 |
| 38 | 미구현 | Confirm Broadcast/선택 필수화/확정/Runtime 상태/Option 결과/피해/점수/Incident 결과/Case Result/Research Log/Campaign/Save Load/GameState/Managers/Audio/Animation/Shader/최종 Theme 없음 |
| 39 | 다음 확장 | BroadcastView의 로컬 선택 처리와 현재 데이터 유효성 검사 경계. 확정 기능은 다음 요구사항에서만 추가; 이번 단계 Main/Runtime에 선택 전달 없음 |

코드 변경은 선택 index/그룹 초기화, HBox+CheckBox+기존 Label 생성, index를 bind한 로컬 처리와
현재 그룹·Tree·해제 상태·유효 Option 확인, 표시 동기화뿐입니다. 기존 표시 문구/누락 정책/Next 조건과
Main의 Scene 등록·ID 조회·Route·진행 보호는 그대로입니다. 별도 Item Scene/Manager/Framework를 만들지 않았습니다.
검증용 Script/프로필/로그/capture/baseline/SHA증거와 `step19-only.diff`는 Git 제외 `.godot/verification/step19/`에만 저장했습니다.
`validation-results.json`, `immutability-evidence.json`, `audit-results.json`으로 실행·변경 범위를 확인할 수 있습니다.

## 18단계 Resource 기반 Emergency Broadcast 표시 검증 결과

Godot **4.7.1.stable.official.a13da4feb**에서 editor import 1회, production GDScript 20개 check-only,
headless/Windows Compatibility GPU 실행·회귀·예외 검사 44회, 총 **65개 검사**를 통과했습니다.
정상 입력은 오류·경고 0건입니다. 예외 입력의 경고는 각 실행에서 Broadcast103 / Incident100 /
Result10 / Containment확정9 / Experiment제한17 / Playback17건으로 예상 수와 일치했습니다.
Window GPU는 AMD Radeon RX6800/OpenGL3.3입니다. 79개 캡처 중 Broadcast15개를 생성하고
Room01 1920×1080, Room03 1280×720, Option4개 1024×768 창의 렌더를 직접 확인했습니다.

| 번호 | 보고 항목 | 결과 |
| --- | --- | --- |
| 1 | 작업 전 Git | HEAD b8e697e, master→origin/main, clean. Step17 이미 커밋·push. 소스49개, 실제 전체 폴더/Scene/Script/Resource/UID/설정/Git/이전 검증, Main 전환/setup/guard/해제 조사 |
| 2 | BroadcastOptionData | Resource를 상속하는 class_name, typed export로 정의. 선택/결과/판정 기능 없음 |
| 3 | Option 필드 | option_id: String, display_text: String만 추가 |
| 4 | EmergencyBroadcastData | Resource를 상속하는 class_name, typed export로 정의 |
| 5 | Broadcast 필드 | broadcast_id/display_name/prompt_text: String, options: Array[BroadcastOptionData]만 추가 |
| 6 | IncidentData | 기존 incident_id/display_name/description 보존, broadcast_id: String만 추가 |
| 7 | CaseData | 기존 필드 보존, emergency_broadcasts: Array[EmergencyBroadcastData]만 추가 |
| 8 | 테스트 Broadcast | TEST_BROADCAST_01/03 각각 고유 Option3개, 총6개 ID/임시 문구. 기존 콘텐츠/Outcome/Stage는 동일 |
| 9 | Incident01 연결 | TEST_INCIDENT_01.broadcast_id → TEST_BROADCAST_01 |
| 10 | Incident03 연결 | TEST_INCIDENT_03.broadcast_id → TEST_BROADCAST_03 |
| 11 | SUCCESS | Runtime SUCCESS → RESULT. 실수로 Incident ID가 있어도 Incident/Broadcast 검색 횟수0, 생성 없음 |
| 12 | Main 검색 | Runtime FAILURE → 현재 Case/확정 Room/Outcome → 현재 Incident → incident.broadcast_id → Case 배열 동일 ID 검색 |
| 13 | ID 연결 | Room/Incident/Broadcast 배열 인덱스나 TEST ID 분기 없음. 배열 순서를 바꿔도 동일 ID를 찾음 |
| 14 | Stage/Route | 기존0~6 보존, BROADCAST=7과 PackedScene 마지막 추가. FAILURE는 MONITORING→INCIDENT→BROADCAST→RESULT→PROFILE |
| 15 | Scene | Control→CenterContainer→VBoxContainer. ScreenTitle/DisplayName/BroadcastId/Description/OptionScroll→OptionList/NextButton |
| 16 | Script | 기존 flow_view.gd 한 단계 상속. 전달된 데이터 표시/동적 Label/누락 처리/로컬 Next 방어/advance_requested만 담당 |
| 17 | setup 전달 | Main이 Tree 추가 전 BroadcastView.setup(EmergencyBroadcastData)를 호출. 준비 전 저장, _ready에서 표시 |
| 18 | Option 동적 목록 | 입력 순서대로 Label 생성. null은 경고 후 건너뜀. 선택 Control/선택 강조/확정 버튼 없음; Label 클릭은 상태·진행 요청을 바꾸지 않음 |
| 19 | Room01 FAILURE | Profile/CCTV/Experiment/Room01확정/Monitoring 시간 재생→FAILURE→Incident01→Broadcast01 이름·ID·prompt·Option3개→Result→Profile 통과 |
| 20 | Room03 FAILURE | 전체 흐름에서 Incident03→Broadcast03와 해당 Option3개 표시, Result/Profile 복귀 통과 |
| 21 | SUCCESS 전체 | Room02확정→Monitoring→SUCCESS→RESULT→PROFILE, Incident/Broadcast 모두 건너뜀 |
| 22 | Incident 진행 보호 | Next: BROADCAST는 연결 Broadcast와 유효 Option 존재 시만 허용. View flag와 Main의 현재 데이터 재검색 모두 검사; 직접/위조 signal 차단 |
| 23 | Broadcast 진행 보호 | 유효 Broadcast ID와 유효 Option≥1 조건을 View/Main 모두 검사. 오래된 UI snapshot으로 Main을 우회할 수 없음 |
| 24 | 빈 broadcast_id | 빈 문자열/공백 경고, null 검색 결과, Incident 진행 차단. 강제 Broadcast 진입에서도 fallback/Next 차단 |
| 25 | 미존재 ID | 다른 Broadcast로 대체하지 않고 warning/null/진행 차단 |
| 26 | null Broadcast | Case null/빈 배열/null 후보/누락 setup 방어. Broadcast data unavailable/빈 목록/Next disabled |
| 27 | 빈 options | 경고/대체 문구/Next disabled; Incident에서 진입도 차단. 직접 advance도 거부 |
| 28 | null Option | 경고 후 건너뜀. 모두 null이면 진행 차단, 유효 Option과 섞이면 유효 항목으로 진행 가능 |
| 29 | 빈 Option 필드 | 빈 option_id는 [Missing option_id], 유효 개수 제외. 빈 display_text는 [Missing display_text at index N]/warning, 유효 ID이면 진행 허용. 이름/prompt도 대체 문구 |
| 30 | Broadcast 순서 | Case 배열 reverse와 null/빈ID/다른ID 후보 뒤의 정확한 ID 검색을 headless/GPU 양쪽 검증 |
| 31 | 3→4 | 검증용 독립 Resource 복사본의 options만 추가해 Label4개 생성. production GDScript 변경 없이 세 크기에서 표시/경계/클릭 검증 |
| 32 | 3→2 | 독립 Resource 복사본 배열 resize만으로 Label2개 생성. 이전 행 제거·해제/표시/버튼 정상 |
| 33 | 반복 setup | 3→4→2→3→다른Broadcast, 유효→null→유효/빈ID를 검증. 이전 Label/ID/이름/문구 잔존 없음, 스크롤 초기화, signal 연결1개 |
| 34 | 재진입 | Room01/03 각각3회 새 View 생성 및 최신 콘텐츠 재검색. 정확한 Broadcast 복원, 기존 Runtime 상태 유지 |
| 35 | Runtime | case_runtime_state.gd 원본 SHA-256 동일. 새 Broadcast/Incident Runtime 필드 없음; Case ID/실험 이력/격리 ID/Monitoring 결과 동일 |
| 36 | Resource 불변성 | 실행 전후 production .tres/schema/GDScript SHA-256 동일. 읽기/전환/클릭/setup으로 원본 Resource 변경 없음 |
| 37 | Incident 회귀 | 기존 검색 함수 그대로, ID/이름/설명/빈필드/null/오래된 signal 방어 정상. 변경은 Broadcast 가용성 전달과 Next 문구/guard뿐 |
| 38 | Monitoring 회귀 | 현재 Room 매핑/Timer 순차 재생/미래 내용 비공개/완료 후 결과 한 번 기록/재진입 복원/미완료·UNDEFINED 차단 통과 |
| 39 | Experiment/Containment | 동적 목록/선택/실행/결과/중복·limit/Runtime 이력/격리 목록·선택·Confirm·확정 복원/진입 보호 통과 |
| 40 | 전체 Route | SUCCESS/두 FAILURE와 재시작, UNDEFINED 진행 차단을 headless 및 native 검증. 통합 검증은 Resource 복사본 0/1/2초, 원본 0/10/20초도 별도 실제 재생 |
| 41 | signal/단일 View | 직접 advance/위조 snapshot/이전 View/queue_free 예정 발신자 차단, 전환 직후 ViewHost 자식1개, 해제 완료, Next 연결1개 |
| 42 | 해상도/Stretch | 1920×1080,1280×720,1024×768 세 창 크기 통과. 논리1920×1080/canvas_items/keep 보존, 1024×768 콘텐츠는1024×576, 기존 창 크기 문구 갱신 |
| 43 | 파싱/실행 | editor import/20Script check-only/프로젝트 기본 Main 실행/실제 GPU GUI 입력 등 총65검사 통과. F5 키 자체는 조작하지 않고 동일 run/main_scene으로 실행 |
| 44 | 문제/해결 | 예외 테스트에서 shallow Resource 복사 뒤 공유 options 배열을 assign한 테스트 fixture 오류를 독립 배열 복사로 수정. 생산 코드 오류 없음. 새 재검증 경로의 의도적 Incident 경고 수100 확인. 미해결 오류 없음 |
| 45 | 실제 변경 | 생성7개: Broadcast Scene, Data Script2개/View Script1개+UID3개. 수정7개: CaseData/IncidentData/Main/IncidentView/Incident Scene/test_case_01.tres/README. 삭제0, 소스49→56 |
| 46 | 기존 변경 보존 | 시작 clean, Step17 b8e697e 보존. 다른42소스/기존 UID17개/Main Scene/설정/Monitoring/Runtime/기존 콘텐츠·승인 로직/이전 검증192개/역사 보고 보존. diff --check 통과, staging 없음, HEAD 동일, 커밋·push 없음 |
| 47 | 미구현 | Broadcast 선택·확정·Runtime·Option 결과·성공/실패·대응 판정, Incident 결과/피해/점수, Case Result/Research Log/Campaign/Save Load/GameState/Managers/Event Bus/Audio/Animation/Shader/최종 UI 없음 |
| 48 | 다음 확장 | EmergencyBroadcastData/BroadcastOptionData → Incident.broadcast_id → Main ID 검색 → BroadcastView.setup() 경계. 다음 요구사항에서 필요한 기능만 추가 |

Step18에서 설정/Main Scene/Monitoring Scene 및 Script/CaseRuntimeState/FlowView는 수정하지 않았습니다.
Main 변경은 Scene 등록/setup/ID lookup/유효 Option 검사/두 Next guard/Route 추가이고, IncidentView는
Main이 전달한 Broadcast 가용성을 반영하도록 최소 변경했습니다. 다른 View를 직접 참조하지 않습니다.
검증 코드·프로필·로그·PNG·baseline·SHA 증거·별도 diff는 Git 제외 `.godot/verification/step18/`에 있습니다.
`validation-results.json`, `immutability-evidence.json`, `audit-results.json`, `step18-only.diff`로 범위를 확인할 수 있습니다.

## 17단계 Resource 기반 Incident 표시 검증 결과

기존 Incident Scene을 재사용하고 IncidentData / IncidentView Script를 추가했습니다.
Route와 Runtime 구조는 그대로이며 ID 검색, 표시, 누락 진행 차단만 구현했습니다. 커밋/push는 하지 않았습니다.

| 번호 | 항목 | 실제 결과 |
| --- | --- | --- |
| 1 | 작업 전 Git | HEAD 13d6ade, master→origin/main, clean. Step16 이미 커밋·push되어 미커밋 변경 없음. 소스45개와 모든 Scene/Script/Resource/UID/설정/Main Route·setup·진행·신호·해제/기존 검증 조사 |
| 2 | IncidentData | 기존 Resource 패턴으로 class_name IncidentData, extends Resource, typed export |
| 3 | 필드 | incident_id:String, display_name:String, description:String 세 개만 정의. description은 export_multiline |
| 4 | CaseData | incidents:Array[IncidentData]=[] 필드 하나 추가. 이전 필드/동작 보존 |
| 5 | Outcome | incident_id:String="" 필드 하나 추가. 기존 Result enum/Room/Stage/final_result 보존. Incident 객체 직접 중첩 없음 |
| 6 | TEST 구성 | 내장 IncidentData 두 개, TEST_INCIDENT_01/03, TEST INCIDENT 01/03, 해당 테스트 Room Failure용 임시 설명. load_steps28→31 |
| 7 | Room01 연결 | FAILURE Outcome.incident_id=TEST_INCIDENT_01. Incident01만 전달/표시 |
| 8 | Room03 연결 | FAILURE Outcome.incident_id=TEST_INCIDENT_03. Incident03만 전달/표시 |
| 9 | SUCCESS 처리 | Room02의 incident_id="". 독립 사본에 잘못된 Incident01 ID를 넣어도 SUCCESS→RESULT, 검색 helper 호출0회, Incident 생성/표시 없음 |
| 10 | Main 검색 | _get_current_incident_data(): Runtime FAILURE→Case→확정 Room→Outcome→Room 일치→Outcome FAILURE→유효 incident_id→incidents ID 검색. 없는 데이터는 null |
| 11 | ID 매핑 | 배열 위치 대신 IncidentData.incident_id == Outcome.incident_id로 검색. 다른 Room/결과의 데이터는 반환하지 않음 |
| 12 | 전용 Script | incident_view.gd 생성. flow_view.gd를 한 단계 상속해 기존 진행 signal 재사용 |
| 13 | Scene | 기존 Control/Center/VBox/제목/Next 유지, DisplayName·IncidentId Label 추가, Description unique-name/표시용 조정, 초기 Next disabled. 기존360 높이에 맞춰 간격24→16/설명26→24 |
| 14 | 전달 경계 | Main이 Tree 추가 전 IncidentView.setup(incident)를 호출. View는 전달 Resource만 보관/표시하고 Main/Case/Runtime/.tres를 직접 탐색하지 않음 |
| 15 | Room01 표시 | Confirm→Monitoring FAILURE→INCIDENT에서 ID/TEST INCIDENT 01/Room01 설명 일치, Next→RESULT |
| 16 | Room03 표시 | 같은 흐름에서 ID/TEST INCIDENT 03/Room03 설명 일치. Incident01 오표시 없음 |
| 17 | SUCCESS 회귀 | Room02 Confirm/완료/SUCCESS→RESULT→PROFILE 및 재진입. Incident 검색 없이 통과 |
| 18 | 순서 변경 | 독립 Case 사본의 incidents와 outcomes 배열을 뒤집어도 Room01/03의 정확한 ID 매핑 유지 |
| 19 | 빈 incident_id | 빈 문자열/공백 Outcome ID는 warning, null, Incident data unavailable, Next disabled. 직접 signal도 차단, FAILURE 유지 |
| 20 | 없는 incident_id | TEST_INCIDENT_NOT_EXISTS를 다른 Incident로 대체하지 않음. warning+누락 UI+Next 차단 |
| 21 | null 후보 | null Incident 경고 후 검색 계속. null·빈 ID·Incident03 뒤의 유효 Incident01도 검색 성공. 전부 null은 누락 처리 |
| 22 | 빈 필드 | 빈 ID는 후보/진행 거부. 이름/설명만 빈 경우 warning+[Missing display_name]/[Missing description], 유효 ID의 진행 허용 |
| 23 | Next 보호 | IncidentView pressed 처리에서 null/빈 ID/disabled를 검사. 유효 데이터는 공용 signal로 RESULT |
| 24 | 우회 보호 | Main이 현재 Incident를 다시 검색. 유효한 로컬 UI로 조작해도 현재 Case 데이터가 없으면 직접 advance/pressed/클릭 모두 차단. 표시 후 데이터 제거도 차단 |
| 25 | setup 반복 | 준비 전 setup, 준비 후01→03 반복, 유효→null→유효→빈 ID→유효 통과. 모든 Label/Next 갱신, 이전 텍스트·노드·signal 누적 없음 |
| 26 | 재진입 | Room01/03의 FAILURE Runtime으로 각각3회 직접 재생성 및 전체 Route 재진입. 동일 Incident를 Room/Outcome/ID에서 다시 파생 |
| 27 | Runtime | 생성/표시/Next/Result→Profile 전후 동일 State 인스턴스·Case ID·Experiment01/03 이력·remaining0·확정 Room·FAILURE 유지. Runtime 파일 SHA 동일, Incident 필드0 |
| 28 | Resource 불변성 | 실행 전후 소스/Resource 해시와 모든 테스트 콘텐츠 값 동일. 콘텐츠 정의 추가를 제거하면 기존 .tres가 기준 사본과 동일. 0/10/20초, 관찰 문구, final_result(2/1/2) 유지 |
| 29 | Experiment | 목록/선택/실행/result_text/ID별1회/limit/승인·거부/이력/남은 횟수/재진입·반복setup 회귀 통과 |
| 30 | Containment | 목록/단일 선택/Confirm/후보 검증/1회 확정/Runtime/잠금/확정 전 진입 차단/재진입 회귀 통과. ContainmentData 변경 없음 |
| 31 | Monitoring | 정확한 Room ID lookup/Timer/미래 숨김/누적/완료/결과1회 확정/미지원 거부/즉시 재진입 복원 회귀 통과. 재생 Script/Scene 변경 없음 |
| 32 | Route | Step16 enum/PackedScene/_get_next_stage() 그대로. SUCCESS→RESULT, FAILURE→INCIDENT→RESULT, UNDEFINED→진행 차단 유지 |
| 33 | 전체 흐름 | PROFILE→CCTV→실험2회→CONTAINMENT→각 Room Confirm→Monitoring 완료→결과별 경로→RESULT→PROFILE 반복. 세 Room×세 크기, Headless/GPU 통과 |
| 34 | 신호/수명 | 기존 bound 발신 View 검사 유지. 이전 Monitoring/Incident·queue_free 예정 객체 무시, 이중 전환 없음. 버튼/진행/Timer/완료 연결1회, 한 View, 이전 View/행 해제 |
| 35 | 해상도 | 1920×1080 / 1280×720 / 1024×768 GPU 검증. Incident01/03 캡처와 ID/이름/설명/Next 직접 확인. 논리1920×1080, canvas_items/keep, Scaling/창 변경 유지 |
| 36 | 파싱/실행 | Godot4.7.1 a13da4feb, production Script17개 check-only+Headless/GPU 실행40개+editor import1개=58개 통과. 정상 오류/경고0, 잘못된 데이터 검사의 예상 경고96/10/9/17/17개씩 일치 |
| 37 | 문제/해결 | 미해결 프로젝트 오류 없음. Step16 검증의 placeholder 기대값을 실제 Incident 필드로 변경, 단축 재생 사본에 incident_id 보존, 실패 Route 단위 테스트의 Room/Outcome 일치 및 신규 누락 검증 추가 |
| 38 | 실제 파일 | 생성4개: incident_data.gd/incident_view.gd와 Godot 생성 UID2개. 수정6개: CaseData/MonitoringOutcomeData/Main/test_case_01.tres/Incident Scene/README. 삭제0, 소스45→49개 |
| 39 | 기존 변경 보호 | 작업 전 미커밋 변경 없음. 나머지39개 소스·이전 검증 gd/ps1 166개 SHA-256 동일, 기존 보고 보존. Main/CaseData/Outcome/.tres의 이번 추가분을 제거하면 기준 코드/콘텐츠 동일. HEAD/staging 유지, git diff --check 통과 |
| 40 | 미구현 | Emergency Broadcast/BroadcastData/선택지/Incident Runtime/피해·탈출 대응·성공실패/CaseResult/Research Log/Campaign/Save·Load/GameState·Manager·EventBus/Audio·Animation·Shader/최종 UI |
| 41 | 다음 확장 | IncidentData 콘텐츠→Main의 ID 검색→IncidentView.setup 경계. Route는 기존 Main helper 유지. 추가 데이터나 실제 이벤트/Broadcast는 다음 요구사항에서 필요한 부분만 구현 |

통합검사는 독립 Case/Outcome 사본의 0/1/2초 재생으로 세 Room과 세 창 크기를 검사했습니다.
원본 Stage 시간을 바꾸지 않았으며 Room02의 실제0/10/20초도 Headless/GPU 별도로 검증했습니다.
Headless B=10.005s/C=20.017s, Windows GPU B=10.016s/C=20.003s입니다.
GPU는 AMD Radeon RX6800 / OpenGL3.3 Compatibility이며 로컬 PNG82개를 생성했습니다.
프로젝트 설정의 Main Scene을 명령행으로 실행하고 GUI 마우스 입력을 검증했습니다. 에디터 F5 키 자체를 자동 입력하지는 않았습니다.
누락 데이터 검증은 독립 사본에서 의도적으로 잘못된 값을 사용하며, 경고는 해당 검사에서만 예상한 수와 일치해야 통과합니다.

로컬 증거: `.godot/verification/step17/validation-results.json`, `audit-results.json`,
`incident_validation_*.log`, `expected_incident_edge_*.log`, `route_validation_*.log`,
`result_integration_*.log`, `production_playback_validation_*.log`, `editor-import.log`,
`step17-only.diff`, `git-step17.diff`, `incident_room*_*.png`.
검증 Script/사본/로그/캡처는 Git 제외 .godot 안에만 저장하며 게임에서 로드하지 않습니다.

## 16단계 Monitoring 결과별 Route와 Incident placeholder 검증 결과

Main의 순차 이동을 명시적 Route로 바꾸고 FAILURE용 독립 Incident Scene만 추가했습니다.
Runtime 결과 확정, 재생, 리소스 데이터와 기존 화면은 유지했습니다. 커밋/push는 하지 않았습니다.

| 번호 | 항목 | 실제 결과 |
| --- | --- | --- |
| 1 | 작업 전 Git | HEAD 4d26d6f, master→origin/main, clean. Step15는 이미 커밋되어 미커밋 변경 없음. 소스44개, 모든 Scene/Script/Resource/UID/설정/기존 검증과 Main setup/완료/전환/해제 조사 |
| 2 | 이전 Route | (_current_stage + 1) % VIEW_SCENES.size(), 6개 Scene 순환. Monitoring SUCCESS/FAILURE 모두 RESULT |
| 3 | 새 Route | PROFILE→CCTV→EXPERIMENT→CONTAINMENT→MONITORING; SUCCESS→RESULT, FAILURE→INCIDENT→RESULT, RESULT→PROFILE |
| 4 | 다음 Stage | Main._get_next_stage(stage)의 작은 match 함수. UNDEFINED/미지원 Stage는 -1, handler는 전환하지 않음. 순차 인덱스 계산 제거 |
| 5 | enum/Scene | 기존0~5 보존, INCIDENT=6과 PackedScene 배열 끝 항목 추가. 7개 Scene의 실제 제목과 인덱스 단위 검증 통과 |
| 6 | Incident Scene | full-rect Control→CenterContainer→VBoxContainer; INCIDENT Label, 임시 설명 두 줄, Next: RESULT Button |
| 7 | Incident Script | 추가하지 않음. 기존 flow_view.gd가 버튼/진행 signal만 담당하므로 그대로 재사용 |
| 8 | SUCCESS | TEST_ROOM_02 Confirm/재생/결과 확정/Next→RESULT. 방문 순서에 INCIDENT 없음 |
| 9 | FAILURE | TEST_ROOM_01·03 Confirm/재생/결과 확정/Next→INCIDENT. 두 Room 모두 동일 경로 |
| 10 | UNDEFINED | Next disabled/pressed/advance_requested 우회와 가짜 SUCCESS snapshot에서도 MONITORING 유지. Main이 Runtime 결과로 차단 |
| 11 | Incident→Result | 공용 advance_requested→Main→RESULT. 이전 Incident의 추가 signal은 무시 |
| 12 | Result→Profile | 기존 버튼 동작 유지. Experiment 이력/남은 횟수/확정 Room/Monitoring 결과 자동 reset 없음 |
| 13 | Route 권위 | CaseRuntimeState.get_monitoring_result()의 SUCCESS/FAILURE만 분기 입력. Runtime 구조/API 변경 없음 |
| 14 | UI 비의존 | 결과 반대 문구·로컬 completed=false·finalized=UNDEFINED·disabled=true로 변조해도 확정 Runtime대로 이동. UI 문구 파싱 없음 |
| 15 | SUCCESS 재진입 | Step15 snapshot 복원, 전체 Stage 즉시 표시, Timer 정지, 완료 signal 재전송 없이 RESULT |
| 16 | FAILURE 재진입 | 동일 snapshot 복원, Timer 정지 상태에서 INCIDENT→RESULT 경로 유지 |
| 17 | stale 방어 | 발신 View를 bind. 현재 객체/inside_tree/queued_for_deletion 검사. 이전 Monitoring/Incident의 중복 signal과 현재 queue_free 예정 발신 무시, 이전 View 실제 해제 |
| 18 | Containment gate | Runtime 확정 전에는 버튼 상태/직접 진행 signal을 우회해도 CONTAINMENT 유지. 후보 검증/Confirm 승인 보존 |
| 19 | Monitoring gate | 결과 확정 전 Next 차단. 결과 UNDEFINED일 때 Main Route=-1. 미완료/다른 Outcome/기록 거부 회귀도 통과 |
| 20 | Experiment Runtime | ID별1회, limit2, Experiment01/03 실행 이력/remaining0, 중복·소진 거부와 재진입 표시 유지 |
| 21 | Containment Runtime | 한 번 확정한 Room 유지, 재확정 거부/후보 잠금/재진입 snapshot 유지 |
| 22 | Monitoring Runtime | UNDEFINED 초기값, SUCCESS/FAILURE 1회 기록, 미지원/중복/반대값 거부, 기존 reset 정책 보존 |
| 23 | 전체 SUCCESS | PROFILE→CCTV→실험2회→CONTAINMENT→Room02 Confirm→MONITORING 완료→RESULT→PROFILE 및 재진입 반복, Headless/GPU 모두 통과 |
| 24 | 전체 FAILURE | 같은 전체 흐름에서 Room01·03→MONITORING 완료→INCIDENT→RESULT→PROFILE 및 재진입 반복, Headless/GPU 모두 통과 |
| 25 | 반복 Incident | Room01·03 × 세 크기 × 초기+재진입2회, 각 모드18회 Incident 방문. 항상 ViewHost 자식1개, 이전 View/행 해제, 누적 없음 |
| 26 | signal | advance_requested/버튼 pressed/PlaybackTimer.timeout/완료 signal의 상위 연결1회. 완료1회, 재진입 완료0회, 이전 객체 요청 중복 전환 없음 |
| 27 | 해상도 | 1920×1080 / 1280×720 / 1024×768 실제 GPU, 논리1920×1080 유지. canvas_items/keep·창 변경·Scaling 보존. Incident 세 크기와 Result 캡처 직접 확인, 텍스트/버튼 잘림 없음 |
| 28 | 파싱/실행 | Godot4.7.1 a13da4feb: Script15개 check-only + Headless/GPU 실행·회귀36개 + editor import1개 =52개 통과. 정상 검사 오류/경고0. 잘못된 데이터 검사는 예상 경고10/9/17/17개씩 정확히 일치 |
| 29 | 문제/해결 | 프로젝트 오류 없음. 기존 테스트의 순차 Stage 기대값을 별도의 명시적 기대 Route로 변경하고 FAILURE 방문/중복 signal 검사를 추가. Monitoring의 기존 Next: RESULT 문구는 보존하며 실제 목적지는 Main이 선택 |
| 30 | 실제 파일 | 수정2개: main.gd/README.md. 생성1개: incident_view.tscn. 새 Script/UID/Resource·삭제0. 소스44→45개. 테스트/로그/캡처/별도 diff는 Git 제외 .godot/verification/step16 안에만 저장 |
| 31 | 이전 변경 보존 | 기존42개 소스와 이전 검증 gd/ps1 144개 SHA-256 동일. Step15~기존 보고 보존. Main의 변경 부분을 제외하면 setup/승인/매핑/완료 코드는 기준 사본과 동일. HEAD/staging 유지, git diff --check 통과 |
| 32 | 미구현 | IncidentData/실제 콘텐츠/탈출·피해·대응/Runtime Incident 상태/Emergency Broadcast/CaseResult/Research Log/Campaign/Save·Load/Manager·Singleton·Framework/Audio·Animation·Shader/최종 UI |
| 33 | 다음 확장 | Route는 Main._get_next_stage(), Incident 표시는 incident_view.tscn. 실제 데이터/전용 Script는 다음 요구사항이 있을 때 추가. 현재 Runtime/Resource 경계 유지 |

통합검사에서는 Case/Outcome의 독립 사본으로 0/1/2초 재생을 사용해 세 Room×세 크기를 검사했습니다.
원본 Resource의 0/10/20초는 변경하지 않았으며 Room02 실제20초 재생도 별도로 검증했습니다.
Headless B=10.005s/C=20.017s, Windows GPU B=10.022s/C=20.017s로, 마지막 기록 이전에는 결과가 숨겨지고 Next가 차단됐습니다.
GPU는 AMD Radeon RX6800 / OpenGL3.3 Compatibility입니다. 전체 PNG82개를 로컬 검증 폴더에 생성했습니다.
명령행으로 프로젝트 설정의 Main Scene을 실행하고 GUI 마우스 입력으로 흐름을 검증했습니다. 에디터 F5 키 자체를 자동 입력하지는 않았습니다.

로컬 검증 증거: `.godot/verification/step16/validation-results.json`, `audit-results.json`,
`route_validation_*.log`, `result_integration_*.log`, `production_playback_validation_*.log`,
`editor-import.log`, `step16-only.diff`, `git-step16.diff`, `incident_room*_*.png`.

## 15단계 Monitoring 최종 결과 확정 검증 결과

이번 단계는 Playback 완료 후 현재 Case/Room의 Outcome final_result를 Main이 검증하고,
Runtime에 한 번 기록한 뒤 결과 표시와 Next를 승인하는 기능까지 구현했습니다.
성공과 실패는 모두 기존 RESULT로 진행하며 후속 Route 분기는 없습니다.

| 번호 | 항목 | 결과 |
| --- | --- | --- |
| 1 | 작업 전 저장소 | HEAD 48f35b2, master→origin/main, Git clean. 11~14단계는 이미 커밋·push된 상태. 소스44개와 전체 Scene/Script/Resource/설정/UID/완료/진행/setup/Timer/매핑/신호/해제/검증 코드 조사, 이전 검증125개 SHA-256 기록 |
| 2 | 결과 enum | MonitoringOutcomeData.Result: UNDEFINED=0, SUCCESS=1, FAILURE=2. 별도 전역 타입/Manager 파일 없음 |
| 3 | Outcome | enum과 @export final_result:Result=UNDEFINED 추가. 기존 room_id/stages 유지, 다른 결과·Incident 필드 없음 |
| 4 | 임시 결과 | TEST_ROOM_01 FAILURE, TEST_ROOM_02 SUCCESS, TEST_ROOM_03 FAILURE. .tres의 final_result 3줄만 추가, 정식 Case 정답이 아님 |
| 5 | Runtime 상태 | _monitoring_result 하나, 초기 UNDEFINED. Stage 위치/시간/재생 상태는 계속 View에만 존재 |
| 6 | Runtime API | has_monitoring_result(), get_monitoring_result(), try_set_monitoring_result(result). SUCCESS/FAILURE만 허용, UNDEFINED/미지원값/두 번째 기록 거부 |
| 7 | reset | 기존 case_id 정책 유지. 실험 이력/확정 Room을 초기화하면서 결과도 UNDEFINED로 초기화. 기본/새 ID reset 모두 통과 |
| 8 | 완료 signal | monitoring_playback_completed(), 인자 없음. 마지막 유효 Stage 이후 로컬 완료 및 Timer 정지, Next disabled 상태에서 한 번 전달. View는 Main/Runtime 조회 없음 |
| 9 | Main 검증 | 현재 View/단계, Case, 확정 Room, ID로 다시 찾은 Outcome, Room 일치, 동일 Outcome의 완료 여부, 유효 final_result, 미확정 Runtime을 검사. View가 결과값을 전달하지 않음 |
| 10 | 기록 전 Next | Scene 기본 disabled 및 setup 초기화 유지. 로컬 완료만으로 활성화하지 않음. Main도 Runtime 결과가 없거나 버튼 disabled면 직접 진행 signal을 차단 |
| 11 | 기록 후 반영 | try_set 성공 후 실제 Runtime 결과를 apply_monitoring_result로 전달. 완료 전/미지원값/상충 결과 적용은 거부. Description Label 재사용 후 Next 활성화 |
| 12 | SUCCESS UI | Monitoring Result: SUCCESS |
| 13 | FAILURE UI | Monitoring Result: FAILURE |
| 14 | 공개 시점 | 진입/A/B/마지막 직전에는 결과 UI 없음, Runtime UNDEFINED. 마지막 Stage 후 Main 승인에 성공했을 때만 표시 |
| 15 | SUCCESS 검증 | Room02 in-memory 0/1/2초, 실제 기다림, A/B/완료 직전 UNDEFINED, 마지막 후 SUCCESS/Next enabled. 대표 GPU B=1.009초/C=2.003초, ±0.35초 tolerance 통과 |
| 16 | FAILURE 검증 | Room01/03 동일 조건, 완료 전 UNDEFINED, 마지막 후 FAILURE/Next enabled. 별도 Incident 이동 없음 |
| 17 | UNDEFINED | Stage 자체는 완료 가능하나 Main warning, Runtime 미확정, 결과 미표시/Next disabled. 미지원99도 동일하게 거부 |
| 18 | 불일치 | 다른 View Outcome과 현재 Case Outcome 객체 불일치 거부. 검증 전용 Main에서 Room02 확정/Room03 반환을 강제해 명시적 Room 일치 검사도 통과. 결과 기록/대체/진행 없음 |
| 19 | 재기록 차단 | SUCCESS/FAILURE 확정 후 같은 값·반대 값·UNDEFINED·미지원값 모두 거부. 중복 완료 요청에도 원래 결과 유지 |
| 20 | 독립성 | EXP01/03 history, remaining0, 확정 Room ID와 Monitoring 결과가 서로 초기화/덮어쓰기 없이 공존. Runtime 인스턴스 간에도 독립 |
| 21 | SUCCESS 재진입 | 같은 Runtime으로 전체 흐름 후 Room02 Monitoring 진입, 전체 Stage/SUCCESS 즉시 표시, Timer 정지, Next enabled. snapshot setup 반복에도 완료 signal0 |
| 22 | FAILURE 재진입 | Room01/03에서 전체 Stage/FAILURE 즉시 복원, Timer 없음, Next enabled, 결과 유지, 완료 signal 재전송 없음 |
| 23 | setup 반복 | 재생 중 UNDEFINED snapshot은 이전 Timer/행/결과를 정리하고 재생. 확정 snapshot은 전체 기록/결과 복원. 다시 UNDEFINED로 바꾸면 이전 결과 숨김, 새 재생. old 행 해제 확인 |
| 24 | Timer/신호 | 기존 one-shot Timer/timeout 연결1개 유지. active Timer→확정 snapshot 후 예전 callback 시점에도 오염 없음. 제거/free, 중간 setup, 완료 요청/Next signal 연결 회귀 통과 |
| 25 | Resource 불변 | .tres의 의도된 final_result 3줄 외 기존 데이터/0·10·20/순서/관찰 문구 동일. 실행 동안 Case/Experiment/Containment/Stage/Outcome와 production GDScript SHA-256 동일 |
| 26 | Experiment 회귀 | 목록/선택/실행/result_text/limit/Runtime history/중복·제한 거부/완료 복원/선택만으로 기록 없음, 세 해상도 통과 |
| 27 | Containment 회귀 | 목록/단일 선택/Confirm/Main 후보 검증/확정 전 진행 차단/확정 ID/잠금/중복 거부/재진입/reset/오류 후보 처리 통과. ContainmentData 및 View 변경 없음 |
| 28 | Playback 회귀 | 실제 0/1/2 순차 공개, 0초/누적/미래 숨김/동일·역행·음수/부분 null/빈 문구/없는 데이터/Timer 해제 유지. 원본 Room02 실제 0/10/20 재생 headless B=10.005초/C=20.017초, GPU B=9.991초/C=20.029초, ±0.5초 통과 |
| 29 | 전체 흐름 | 3 Room × 3해상도 × headless/GPU에서 Outcome 배열을 역순으로 해도 ID 매핑 유지. 두 결과 모두 RESULT→PROFILE 순환, 한 View/이전 View 해제/신호 중복 없음. 1920×1080/1280×720/1024×768, canvas_items/keep/scaling 유지 |
| 30 | 파싱/실행 | GDScript --check-only15 + editor import1 + headless/GPU 실행·정상·오류 입력34 = 총50건 통과. Godot 4.7.1.stable.official.a13da4feb, AMD RX6800 Compatibility. 기본 run/main_scene으로 실행, F5 키 자체 자동 조작 없음 |
| 31 | 문제/해결 | 0초 완료가 _ready 안에서 동기 발생하므로 결과 적용은 Tree/로컬 완료 기준으로 처리, pre-ready 승인/복원 검증 통과. 오류 입력 검증 Script의 untyped 배열 대입을 typed 배열로 수정하고 재검증 통과. 미해결 프로젝트 오류 없음 |
| 32 | 실제 파일 | 수정7개: Outcome Script, Runtime Script, Main Script, Monitoring Script, test_case_01.tres, Result Scene, README. Result Scene은 이전 No success or failure is determined 문구만 중립 안내로 교체, 구조/Route 유지. production 생성/삭제0, 전체44개 |
| 33 | 기존 변경 | 시작 Git clean, 이전 11~14단계는 48f35b2에 보존. 다른37소스, UID15개, 설정, Case/Containment/Stage schema, 기존 Main 매핑/승인/전환·Runtime 함수, 기존 보고와 검증125개 보호. 이번 단계 커밋/push 없음 |
| 34 | 미구현 | 결과별 Result View/FAILURE→Incident/IncidentData/Broadcast/breach/damage/reward/score/Research Log/Save·Load/GameState/Manager/Campaign/Audio/Animation/최종 Theme 없음 |
| 35 | 다음 경계 | Main 결과 승인 후와 Runtime 확정 결과 조회 경계. 후속 요구사항에서만 SUCCESS/FAILURE별 Route를 연결할 수 있으며 현재는 동일 RESULT 유지 |

정상 데이터 검사에서 warning0입니다. 오류 입력 검사는 결과10개, Containment9개,
Experiment17개, Playback17개의 예정된 warning을 headless/GPU 각각 확인했습니다.
이전 검증은 수정하지 않고 복사본에서 검증 전용 in-memory Case/Outcome을 사용했습니다.
Production speed API는 추가하지 않았으며 실제 Resource의 0/10/20을 유지합니다.
로그·GPU 캡처·원본 사본·SHA-256 manifest·검증 Script·audit-results.json·
step15-only.diff·git-step15.diff는 Git 제외 `.godot/verification/step15/`에 있습니다.

## 14단계 Monitoring Playback 검증 결과

이번 변경은 Monitoring View의 Timer 기반 순차 공개와 누적 기록, 재생 완료 후 진행까지만 구현했습니다.
아래 검사는 Godot **4.7.1.stable.official.a13da4feb**, Windows Compatibility renderer에서 수행했습니다.

| 번호 | 항목 | 결과 |
| --- | --- | --- |
| 1 | 작업 전 저장소 | 실제 소스44개(설정1, Scene7, GDScript15, UID15, Resource1, 문서/구성/자리표시5), 전체 폴더/설정/콘텐츠/전환/신호/검증 조사. HEAD d029272, master→origin/main. 11~13단계의 기존 수정8개/미추적6개 보존. 기존 검증 Script110개 SHA-256 기록 |
| 2 | Playback 방식 | Outcome 배열 순서대로 Stage를 공개하고 이전 기록을 남김. 미래 observation_text는 UI Node로 만들지 않음 |
| 3 | Timer | Monitoring Scene에 one-shot PlaybackTimer 하나 추가. 양수 delay에만 재사용, autostart 없음, timeout 연결 한 개 |
| 4 | setup / ready | setup은 Outcome 저장과 인덱스/offset/active/completed 초기화. _ready는 공용 버튼과 Timer 연결 후 표시·재생 |
| 5 | Tree 진입 전 | Main이 setup 이후 ViewHost.add_child를 호출함을 확인. Tree 밖 setup에서는 Timer 시작 없음, 실제 pre-tree 검사 통과 |
| 6 | Stage 상태 | 인덱스, 이전 offset, active, completed가 MonitoringView 안에만 존재. Runtime/콘텐츠 필드 추가 없음 |
| 7 | time_offset | 시작 기준 상대 초. 정상 0/10/20이면 즉시/약10초/약20초 공개 |
| 8 | delay | 현재 offset − 이전 유효 Stage offset, 첫 기준0. 실제 wait는 max(차이,0). 원래 배열/값 보존 |
| 9 | 0초 Stage | 시작 동기 호출에서 즉시 공개. 0 delay는 while로 연속 처리, 256개 즉시 Stage도 정지/재귀 문제 없음 |
| 10 | 누적 UI | 기존 StageList에 시간/관찰 Label 두 개로 구성된 행을 추가. 기본 3개와 기존 스크롤/레이아웃 유지 |
| 11 | 미래 숨김 | A만 → A+B → A+B+C 실제 Timer와 화면 캡처로 확인. 다음 관찰 문구가 UI에 미리 표시되지 않음 |
| 12 | Next 보호 | Scene 기본 disabled, 재생 중 disabled. pressed를 직접 발생시켜도 완료 전 진행 요청 없음. 완료 후에만 활성화 |
| 13 | 완료 조건 | 한 개 이상 유효 Stage가 있고 모두 공개된 경우 Timer 정지/active=false/completed=true/Next 활성화. 문구는 Monitoring sequence complete |
| 14 | 재진입 | 새 Monitoring View가 같은 ID의 원래 Outcome으로 0부터 시작. Next가 다시 잠기고 A만 표시됨 |
| 15 | 중간 setup | OLD 0/1 재생 중 NEW 0/2 setup. 기존 행 해제, Next/상태 초기화, 예전 1초 callback 시점에도 NEW_1 조기 공개 없음 |
| 16 | 제거/free | 재생 중 remove_child에서 Timer 정지. 1.1초 후에도 행 추가 없음. queue_free 후 View/Timer 모두 해제, callback/Node 접근 오류 없음 |
| 17 | 없는 데이터 | null Outcome/빈 배열/전부 null은 경고+대체 UI, Timer 정지/Next disabled/완료 false. 일부 null은 경고하고 건너뛰며 나머지 유효 Stage 완료 가능 |
| 18 | 음수 offset | -1/1에서 경고. 첫 Stage 즉시, 다음 Stage는 원래 차이 2초로 대기, 음수 duration 없음. 원래 -1 값과 표시 유지 |
| 19 | 역행 offset | 0/2/1에서 경고. 0 즉시, 2초 뒤 두 나머지 Stage를 원래 순서로 공개. 음수 대기는0, 자동 정렬/Resource 보정 없음 |
| 20 | 동일 offset | 0/0/1에서 처음 두 Stage 즉시/배열 순서 유지, 마지막 Stage 약1초 후 완료. 무한 대기 없음 |
| 21 | 0/1/2 검증 | 별도 in-memory Outcome 사용. 대표 headless B=1.021초/C=2.029초, Windows GPU B=1.018초/C=2.011초. ±0.35초 tolerance로 순서/누적/미래 숨김/Next 통과 |
| 22 | 실제 Resource | 원본 3 Room × 0/10/20와 Stage 순서/문구 SHA-256 동일. Room02 실제 재생: headless B=10.012초/C=20.023초, GPU B=10.002초/C=20.015초. ±0.5초 tolerance 통과 |
| 23 | Room 매핑 | 3 Room × 3해상도 × headless/GPU, 테스트 Case의 Outcome 배열을 역순으로 해도 정확한 confirmed ID의 원래 Outcome 선택. index 검색으로 변경하지 않음 |
| 24 | Experiment Runtime | EXP01/03 이력, remaining0, 승인 결과, 중복/제한 거부, 선택만으로 기록 없음, setup/재진입/전체 흐름 복원 통과 |
| 25 | Containment Runtime | 단일 선택/Confirm, 후보 검증, 확정 전 버튼·signal 진행 차단, ID 저장/잠금/중복 거부/재진입 복원/reset 회귀 통과 |
| 26 | 불변성 | Stage/Outcome/Case/Containment/test_case_01.tres와 기존 Runtime/설정/Main/UID는 작업 시작 SHA-256과 동일. 검증 동안 production GDScript도 동일 |
| 27 | 전체 회귀 | Profile/CCTV/Experiment/Containment/Monitoring/Result 순환, 재시작, 한 View, 이전 View 해제, signal 단일 연결 통과. 1920×1080/1280×720/1024×768의 layout/stretch/scaling 유지 |
| 28 | 파싱/실행 | editor import1 + GDScript --check-only15 + headless/Windows GPU 실행·정상·오류 입력 검사30 = 총46건 통과. 기본 run/main_scene으로 PROFILE 시작 확인. F5 키 자체는 자동 조작하지 않음 |
| 29 | 문제와 해결 | 모든 Room/해상도를 한 GPU 프로세스로 검사하던 검증이45초 제한을 초과. 검증만 해상도별 실행으로 분리해9조합 모두 통과. 미해결 프로젝트 오류 없음. 잘못된 입력 검사의 예정된 warning과 Git README 줄바꿈 안내는 오류가 아님 |
| 30 | 실제 파일 | 이번 단계 수정3개: scripts/views/monitoring_view.gd, scenes/views/monitoring_view.tscn, README.md. production 생성/삭제0. 검증 자료는 Git 제외 .godot/verification/step14에만 생성 |
| 31 | 기존 변경 보존 | Step14 시작 사본과 별도 incremental diff로 비교. 다른41소스, 이전 검증110개, 기존13단계 이하 보고, 기존 미커밋 범위를 보존. 커밋/push 없음 |
| 32 | 미구현 | 정답/Success/Failure/is_success/final_state/breach/Incident/Broadcast/Monitoring Runtime 저장/Save·Load/progress bar/animation/audio/CCTV 변화/Research Log/Case Result/GameState·Manager/Campaign/최종 Theme 없음 |
| 33 | 다음 확장 지점 | MonitoringStageData/OutcomeData → Main ID 검색 → MonitoringView.setup/재생 완료 경계. 다음 요구사항에서 필요한 표시나 완료 후 연결만 추가하며 판정 시스템은 아직 없음 |

검증의 정상 데이터에서는 warning0입니다. 오류 입력 검사는 Monitoring17개, 기존 Containment9개,
기존 Experiment17개의 예정된 warning을 headless/GPU 각각 확인했습니다.
검증 코드·로그·원본 사본·GPU 캡처·SHA-256 manifest·`step14-only.diff`와
`combined-step11-through-step14.diff`는 `.godot/verification/step14/`에 있습니다.
이전 검증은 수정하지 않고 복사본의 전체 흐름에만 in-memory 0초 Stage를 전달했습니다.
실제 시간 검사는 별도로 0/1/2와 원본 0/10/20을 기다렸으며 production speed API는 없습니다.

## 13단계 Monitoring 콘텐츠와 Room별 데이터 전달 검증 결과

이번 단계는 Monitoring 콘텐츠 Resource와 확정 Room에 대응하는 읽기 전용 표시만 추가했습니다.
Runtime/Containment/Experiment 승인 및 확정 전 진행 보호는 유지했습니다. Timer나 판정은 없습니다.

| 번호 | 보고 항목 | 결과 |
| --- | --- | --- |
| 1 | 작업 전 저장소 | 소스38개와 전체 Scene/Script/Resource/UID/설정, setup/전환/확정/공용 흐름/기존 검증 조사. HEAD d029272, master→origin/main, 기존 11·12단계 5개 파일 미커밋. Monitoring Scene은 있었으나 전용 Script는 없음 |
| 2 | MonitoringStageData | class_name Resource, 개별 표시 상태 정의 |
| 3 | MonitoringOutcomeData | class_name Resource, Room에 대응하는 Stage 묶음 정의 |
| 4 | 필드 | Stage: time_offset:int(초), observation_text:String. Outcome: room_id:String, stages:Array[MonitoringStageData]. 추가 결과/에셋/상태 필드 없음 |
| 5 | CaseData | containment_outcomes:Array[MonitoringOutcomeData] 한 필드 추가, 기존 필드 유지 |
| 6 | 테스트 .tres | Room01/02/03 Outcome 각1개, 각 Stage3개(0/10/20초), 총 Outcome3/Stage9. 서로 다른 Temporary monitoring state XX-A/B/C 문구. 기존 콘텐츠 보존 |
| 7 | Room→Outcome | 확정된 room_id와 Outcome.room_id 문자열 일치로 연결. 배열 인덱스 결합 없음 |
| 8 | Main 검색 | _get_monitoring_outcome()에서 현재 확정 ID/Case/목록 확인 후 같은 ID의 첫 유효 Outcome 반환. null/빈 ID 경고 후 건너뜀, 매칭 없으면 경고+null |
| 9 | 전달 | Main이 MONITORING 생성 전에 MonitoringView.setup(outcome) 호출. View의 직접 load/Main 탐색/Runtime 접근 없음 |
| 10 | UI | 기존 Control/제목/Next 유지, RoomId/전체 개수/StageScroll→StageList 추가. 각 Stage는 VBoxContainer→시간 Label/관찰 Label |
| 11 | 동적 목록 | stages.size()만큼 기본 Control 생성. Item Scene/Manager/고정 Stage 노드 없음 |
| 12 | Room01 매핑 | Room01 확정 후 Room01 Outcome/01-A/B/C 표시, Outcome 배열 역순에서도 동일 |
| 13 | Room02 매핑 | Room02 확정 후 Room02 Outcome/02-A/B/C 표시, 배열 순서와 무관 |
| 14 | Room03 매핑 | Room03 확정 후 Room03 Outcome/03-A/B/C 표시, 배열 역순에서도 동일 |
| 15 | 3→4 | .tres의 Room02 Stage만 4개로 임시 변경, headless/Windows GPU에서 개수4 및 30초 02-D 스크롤 표시 성공. GDScript15개 SHA-256 동일 |
| 16 | 3→2 | .tres에서 Room02 Stage 하나 제거, 양쪽에서 개수2 표시 성공. 검증 후 원래 3개 Resource 바이트/SHA-256 복원, 복원 후 재실행 성공 |
| 17 | 없는 Outcome | Room02 확정 후 Outcome01만 있는 경우 경고와 Monitoring data unavailable, 목록0개. 다른 Room으로 대체하지 않음 |
| 18 | 누락 데이터 | 미확정/없는 Case/빈 Outcome 배열/null Outcome/빈·공백 ID/빈 stages/null Stage/빈·공백 관찰 문구 모두 경고·대체 UI로 처리. 정상 매칭 항목은 표시 가능 |
| 19 | 시간 오류 | 음수와 역행 offset 경고, 원래 숫자/배열 순서 유지. 자동 정렬/클램프 없음 |
| 20 | 반복 setup | 이전 항목 제거/해제, 스크롤 초기화, 새 목록 생성. 반복 진입/재호출 후 중복 목록/signal 없음 |
| 21 | Experiment Runtime | EXP01/03 실행 이력과 remaining0가 Monitoring 표시/setup/전환/재진입 동안 유지 |
| 22 | Containment Runtime | 확정 ID 및 잠금 상태 유지. 확정 전 Next/직접 signal 우회 차단 유지. Runtime Script와 Containment Script/Scene/Resource 변경 없음 |
| 23 | Resource 불변성 | 콘텐츠 전체 snapshot과 실행 전후 .tres/스키마 SHA-256 동일. Resource 임시 편집 검사만 명시적으로 변경하고 복원. View는 읽기 전용 |
| 24 | 기존 회귀 | Profile/CCTV 표시, Experiment 선택/실행/result/제한/중복 거부/완료 복원, Containment 선택/Confirm/재확정 거부/reset 통과 |
| 25 | 전체 흐름 | PROFILE→CCTV→EXPERIMENT→CONTAINMENT→확정→MONITORING→RESULT→PROFILE 및 재진입 통과. 한 View/이전 View 해제/signal1회 확인 |
| 26 | 파싱/실행 | Godot4.7.1 editor import1 + 전체 GDScript check-only15 + headless/Windows GPU 실행·회귀22 + Resource-only5, 총43개 성공. 1920×1080/1280×720/1024×768 및 기존 canvas_items/keep/Scaling 정상 |
| 27 | 문제/해결 | 초기 스크롤 높이가 기본 Stage3개보다 작아 Monitoring 내부 글자/간격/스크롤 높이만 조정. Resource 생성 스크립트 형식 지정 오류도 수정. 미해결 파싱/실행 오류 없음 |
| 28 | 실제 파일 | 새 Script3개(MonitoringStageData/OutcomeData/View)+Godot UID3개. 수정5개(CaseData/Main/test_case_01.tres/Monitoring Scene/README). 삭제 없음, 최종 소스44개 |
| 29 | 기존 변경 보호 | 이전 11·12단계 변경 기준 사본/diff 저장, 그 위에 필요한 부분만 추가. 기존 소스33개/이전 검증 Script96개 동일, 이전 단계 보고 보존. 이번 변경만의 diff 별도 저장, 커밋/push 없음 |
| 30 | 미구현 | Timer/자동 Stage 전환/Monitoring Runtime 필드/진행률/Animation·Audio·CCTV 변화/정답·Success·Failure/Breach/Incident/Broadcast/Case Result/Research Log/Save·Load/GameState·Manager/Campaign/최종 UI |
| 31 | 다음 확장 지점 | MonitoringStageData/OutcomeData, Main의 ID 검색, MonitoringView.setup 경계. 실제 재생 규칙은 다음 요구사항이 정해졌을 때 추가 |

정상 검사에는 오류·경고가 없습니다. 부정 데이터 검사에는 예상 경고만
Monitoring27개, 기존 Containment9개, 기존 Experiment17개가 발생했습니다.
9개 Room/창 크기 조합과 Outcome 역순 검증, 반복 진입, 기존 격리 승인/거부/reset 검사를 수행했습니다.
GPU 캡처에서 기본3개/확정 Room/작은 창/네 번째 Stage 스크롤을 직접 확인했습니다.
1024×768의 콘텐츠 렌더 영역은 기존 비율 유지에 따라 1024×576입니다.
F5 키 자체를 조작하지 않았으며 같은 run/main_scene의 기본 프로젝트 실행을 양쪽에서 검증했습니다.

검증 사본/전용 Script/실행기/로그/PNG/작업 전 사본/해시/결과 JSON과
기존 변경 diff 및 Step13만의 diff는 Git 제외 `.godot/verification/step13/`에 있습니다.
이 자료는 게임에서 로드하지 않습니다. 기존 검증 Script는 수정하지 않았습니다.

## 12단계 Containment 확정 및 Runtime 기록 검증 결과

이번 단계는 명시적 확정과 Room ID 기록, 확정 전 Monitoring 진행 차단만 추가했습니다.
후보가 정답인지 판단하지 않습니다. Main은 현재 후보 여부를 검증하고 Runtime은 최초 확정만 기록합니다.

| 번호 | 보고 항목 | 결과 |
| --- | --- | --- |
| 1 | 작업 전 저장소 | 실제 소스 38개와 모든 Scene/Script/Resource/UID/설정, 기존 검증 코드, 선택/진행/setup/해제/Experiment 승인 연결 조사. HEAD d029272, master → origin/main. 11단계 README/ContainmentView 두 파일 미커밋 상태 |
| 2 | 확정 흐름 | Room 선택 → Confirm → confirmation_requested(ID) → Main 후보 검증 → Runtime 최초 기록 → snapshot 반영 → Next 활성화 |
| 3 | 추가 Runtime 상태 | private `_confirmed_containment_room_id: String = ""` 하나. 임시 선택은 View 내부 유지 |
| 4 | Runtime API | try_confirm_containment_room(room_id) → bool / has_confirmed_containment() / get_confirmed_containment_room_id() |
| 5 | 후보 검증 | Main._on_containment_confirmation_requested(): 현재 View만 허용, current_case의 실제 배열과 ID 일치 확인, null/빈 ID/없는 후보 거부 |
| 6 | Confirm 버튼 | Containment Scene의 Actions HBox에 ConfirmButton 추가, 기존 Next와 한 줄 배치. 선택 없음 disabled, 유효 선택 enabled |
| 7 | 진행 보호 | View의 Next disabled + Main의 Runtime 확정 검사. 클릭/pressed/advance_requested 직접 호출과 조작된 UI snapshot에서도 확정 전 이동 불가 |
| 8 | signal | containment_confirmation_requested(room_id: String), View는 Runtime을 읽거나 탐색하지 않음 |
| 9 | Main 연결 | 현재 ContainmentView에 signal 1회 연결, setup에 확정 ID 전달, 처리 후 실제 Runtime ID로 update_confirmation_state() 호출 |
| 10 | 정상 선택 | 초기 없음, 01→02→03→03→02, 최대 하나만 선택 및 재클릭 유지. 유효 후보 01/02/03 모두 확정 가능 |
| 11 | 선택과 Runtime | 후보 선택/변경만으로 확정 ID 및 Experiment 이력/남은 횟수 변경 없음 |
| 12 | 확정 성공 | TEST_ROOM_02 선택 후 Confirm으로 Runtime에 TEST_ROOM_02 한 번 기록 |
| 13 | 확정 UI | 해당 후보 [Confirmed]와 선택 표시, 임시 선택 인덱스 -1, Confirm disabled, Next enabled |
| 14 | 후보 변경 차단 | 확정 후 모든 후보 disabled, 다른 후보 클릭해도 확정 ID와 UI 유지 |
| 15 | 재확정 차단 | 같은/다른 ID의 두 번째 요청을 Runtime API 자체에서 false로 거부. Main signal 직접 요청도 기존 확정 유지 |
| 16 | 없는 ID | TEST_ROOM_NOT_EXISTS 및 stale UI 후보 요청 거부, Runtime 변경 없음, Next 잠금 유지. 실제 Case 배열에서 후보가 제거된 뒤 오래된 UI 행이 남아 있어도 안전하게 거부 |
| 17 | 빈 ID | 빈 문자열/공백 ID를 View·Main·Runtime 단계에서 거부. null/선택 없음/선택 후 데이터 무효화도 기록 불가 |
| 18 | 재진입 | 확정 후 전체 6개 View 순환, 동일 State/확정 ID/Experiment 이력 유지. 확정 표시와 잠금/Next 활성화 복원 |
| 19 | 반복 setup | 확정 전/후 각각 2회 재호출, 목록/버튼/그룹 새로 생성, 이전 노드 해제, 임시 선택 초기화, snapshot 확정 복원, signal 중복 없음. 트리 진입 전 setup도 확인 |
| 20 | reset | 기존 case_id 지정/기본 빈 ID 정책 유지. Experiment 이력과 확정 ID 동시 초기화, reset 이후 새 확정 가능 |
| 21 | Runtime 독립성 | limit 2: TEST_EXP_01 실행 → remaining1, TEST_EXP_03 → remaining0, 이어 Room02 확정. history 01/03 및 remaining0 유지 |
| 22 | 콘텐츠 불변성 | Case/Profile/CCTV/Experiment/Containment 필드 snapshot 동일. CaseData/ContainmentData/test_case_01.tres SHA-256 동일. Resource 런타임 필드 추가 없음 |
| 23 | 기존 회귀 | Profile/CCTV 표시, Experiment 목록/선택/실행/result_text/제한/중복 거부/완료 복원 통과. 기존 Experiment 승인 코드 보존 |
| 24 | 전체 흐름 | PROFILE → CCTV → EXPERIMENT → CONTAINMENT → 확정 → MONITORING → RESULT → PROFILE 통과. View 하나, 이전 View 해제, 중복 signal 없음 |
| 25 | 파싱/실행 | Godot 4.7.1 editor import1 + 전체 GDScript check-only12 + headless/Windows GPU 실행·회귀20, 총33개 성공. 1920×1080/1280×720/1024×768 및 기존 canvas_items/keep/Scaling 유지 |
| 26 | 문제/해결 | 검증 코드가 전체 순환 후 해제된 이전 View를 참조하던 문제는 새 View 참조 갱신으로 해결. 후보 배열 축소 시 오래된 UI 행의 배열 범위 접근도 방어하고 관련 검사 재실행 성공. 미해결 오류 없음 |
| 27 | 파일 변경 | 이번 작업은 Main Script, Runtime Script, Containment Script/Scene, README 총5개 수정. 소스 생성/삭제 없음. 기존 Next 위치만 Actions 안으로 이동, unique name/API 유지 |
| 28 | 기존 변경 보존 | 11단계 변경 파일을 작업 전 사본으로 저장하고 그 위에 필요한 부분 추가. 이전 단계 문서와 기존 검증 Script84개 보존. 이번 변경과 기존 diff를 별도 저장 |
| 29 | 미구현 | 정답/오답/Success·Failure/환경 조건/Monitoring 데이터·Timer·상태 변화/Breach/Incident/Broadcast/Research Log/Case Result/Save·Load/Campaign/Manager/GameState/최종 Theme |
| 30 | 다음 확장 지점 | Runtime 확정 ID 조회와 Resource → Main → View.setup 경계. Monitoring이나 판정 요구사항이 정해지면 상위 계층에서 명시적으로 연결 |

정상 경로에는 오류·경고가 없으며 부정 데이터 검사에는 예상 경고만 9개(격리 데이터),
17개(기존 Experiment 제한) 발생했습니다. 초기/선택/확정/재진입 GPU 캡처와 작은 창 화면을 확인했습니다.
1024×768에서 콘텐츠는 기존 비율 유지에 따라 1024×576으로 렌더합니다.
F5 키 자체를 자동 조작하지 않았으며 동일한 run/main_scene의 기본 프로젝트 실행을 양쪽에서 검증했습니다.

로컬 검증 사본/확정 전용 Script/실행기/로그/PNG/변경 전 사본/SHA-256/결과 JSON과
기존 11단계 diff 및 이번 작업만의 diff는 Git 제외 `.godot/verification/step12/`에 있습니다.
이 자료는 게임에서 로드하지 않습니다. 커밋과 push는 하지 않았습니다.

## 11단계 Containment 단일 선택 검증 결과

이번 단계는 후보 단일 선택만 추가했습니다. 기존 `containment_view.gd`와 이 README만 수정했으며
소스 파일/Scene/Resource/UID의 생성·삭제는 없습니다. 커밋과 push는 하지 않았습니다.

| 번호 | 보고 항목 | 결과 |
| --- | --- | --- |
| 1 | 작업 전 저장소 | 소스 38개와 전체 Scene/Script/Resource/UID, Main/setup/signal/해제, Experiment ButtonGroup, 설정, 기존 검증 코드 조사. master → origin/main, HEAD d029272, 변경 없음 |
| 2 | 선택 방식 | Experiment와 동일한 CheckBox + ButtonGroup, allow_unpress=false |
| 3 | 항목 Node | RoomList → VBoxContainer → 이름 CheckBox / 설명 Label |
| 4 | 별도 Item Scene | 생성하지 않음. 기본 Control 두 개와 선택 연결만 필요 |
| 5 | 선택 저장 | ContainmentView._selected_room_index, -1은 선택 없음. 그룹도 View 내부 |
| 6 | 콘텐츠 분리 | ContainmentData는 기존 room_id/display_name/description 세 필드만 유지. Main/Runtime 선택 상태 없음 |
| 7 | 선택 표시 | Godot 기본 그룹 선택 표시 사용. 별도 Theme/색상 없음 |
| 8 | 초기 진입 | 후보 3개, 선택 인덱스 -1, 눌린 버튼 없음 |
| 9 | Room 01 | TEST_ROOM_01만 선택, 인덱스 0 |
| 10 | Room 02 변경 | 01 해제, TEST_ROOM_02만 선택, 인덱스 1 |
| 11 | 동일 후보 재클릭 | Room 03 재클릭 후 선택 유지. 선택 해제 Toggle 없음 |
| 12 | 최대 선택 수 | 모든 클릭 단계에서 정확히 하나만 선택, 초기 상태는 0개 |
| 13 | View 재진입 | 새 View의 후보 3개, 선택 없음. 이전 View 해제, 목록/signal 중복 없음 |
| 14 | 반복 setup | 선택 후 2회 반복, 인덱스/그룹 초기화. 이전 항목/버튼 해제와 이전 그룹의 버튼 0개 확인. 트리 진입 전 setup도 확인 |
| 15 | 잘못된 데이터 | 빈 배열/null/빈·공백 ID/이름/설명 대체 문구 유지. null/빈 ID 선택 비활성화. 혼합 목록의 정상 후보 선택 가능, 정상 ID의 누락 이름/설명도 선택 가능 |
| 16 | Resource 불변성 | Case/Experiment/Containment 필드 snapshot 동일. test_case_01.tres 및 CaseData/ContainmentData SHA-256 동일. 선택 상태 필드 추가 없음 |
| 17 | Experiment Runtime | limit 2에서 TEST_EXP_01 → remaining 1, TEST_EXP_03 → 0. 이력 01/03 유지, Containment 선택/setup/전환으로 변경 없음. 오래된 UI의 중복/제한 초과 요청 거부도 유지 |
| 18 | 기존 콘텐츠/실험 | Profile/CCTV 표시, Experiment 목록/선택/실행/result_text/완료 상태/제한/재진입 회귀 통과 |
| 19 | 전체 흐름 | PROFILE → CCTV → EXPERIMENT → CONTAINMENT → MONITORING → RESULT → PROFILE 통과. 선택 없이도, 선택 후에도 진행. View 한 개/이전 View 해제 확인 |
| 20 | 파싱/실행 | Godot 4.7.1 editor import 1개 + 전체 GDScript check-only 12개 + headless/Windows GPU 실행·회귀 18개, 총 31개 성공. 1920×1080/1280×720/1024×768, canvas_items/keep/Scaling 유지 |
| 21 | 문제/해결 | 혼합 목록 검증 코드가 스크롤 밖 후보 위치를 클릭해 진행 버튼을 누름. ensure_control_visible() 후 클릭하도록 검증 코드만 수정하고 재검증 통과. 제품 코드 오류 및 미해결 오류 없음 |
| 22 | 실제 변경 범위 | containment_view.gd: 이름 Label을 CheckBox로 교체, 폰트 18로 기존 Experiment 패턴 적용, 그룹/인덱스/선택 핸들러 추가. README: 현재 동작과 결과 갱신. 기존 Scene/설정/UID 유지 |
| 23 | 기존 변경 보존 | 시작 시 미커밋 변경 없음. 나머지 소스 36개 및 기존 검증 Script 73개 SHA-256 동일. 이전 단계 결과 문서 보존 |
| 24 | 구현하지 않은 것 | 격리 확정/선택 필수/Runtime 격리 기록/정답/환경 조건/Monitoring/Success·Failure/Incident/Broadcast/Research Log/Save·Load/Manager/GameState/Campaign/최종 Theme |
| 25 | 다음 확장 지점 | ContainmentView 선택 처리와 기존 Resource → Main → View.setup 경계. 확정 규칙 및 상태 전달은 다음 요청에서 결정 |

정상 경로에는 오류와 경고가 없습니다. 부정 데이터 검사는 예상 경고만 각각 9개(혼합 선택),
8개(기존 Containment 누락), 17개(기존 Experiment/제한)로 확인했습니다.
GPU 캡처에서 기본 세 후보/선택 표시/설명/진행 버튼을 직접 확인했습니다.
1024×768의 실제 콘텐츠 렌더 영역은 기존 비율 유지 설정에 따라 1024×576입니다.
F5 키 자체는 자동 조작하지 않았으며 동일한 run/main_scene의 기본 프로젝트 실행을 검증했습니다.

이번 로컬 검증 Script, 실행기, 로그, PNG, 변경 전 사본, SHA-256 manifest, 결과 JSON과 diff는
Git 제외 경로 `.godot/verification/step11/`에 있습니다. 게임에서는 로드하지 않습니다.
기존 검증 Script는 그대로 보존하고 이번 경로에 회귀 검사 사본과 선택 전용 검사를 추가했습니다.

## 10단계 Containment Resource 동적 후보 목록 검증 결과

작업 전에 소스 34개, 모든 Scene/Script/콘텐츠 Resource/UID, 설정, Main의 setup/signal/View 해제,
동적 Experiment 목록과 Runtime, 기존 검증 코드를 조사했습니다. Containment Scene은 존재했으나
전용 Script는 없었고 flow_view.gd 기반 임시 설명과 진행 버튼만 있었습니다.
Step 9 미커밋 변경 7개를 사본·해시·diff로 보관했습니다. 커밋/HEAD와 기존 변경을 되돌리지 않았습니다.

생성은 containment_data.gd / containment_view.gd와 Godot가 생성한 UID 두 개, 총 4개입니다.
수정은 CaseData, 테스트 .tres, Main Script, 기존 Containment Scene, README 총 5개이며 삭제는 없습니다.
기존 Scene을 재사용하고 NextButton·advance_requested·6개 흐름을 유지했습니다.
목록 공간은 Containment Scene 내부 간격과 개수 설명 크기만 조정해 확보했습니다.
Main Scene의 360 높이 ViewHost, project.godot, 해상도/Stretch를 변경하지 않았습니다.

ContainmentData는 `room_id: String`, `display_name: String`, `description: String`의 세 export만 가집니다.
CaseData에 `available_containment_rooms: Array[ContainmentData]`를 추가했고 기존 필드는 보존했습니다.
테스트 .tres에는 TEST_ROOM_01/02/03의 임시 이름/설명을 내장 Resource로 추가했습니다.
새 Script와 sub_resource에 맞춰 load_steps만 10→14로 갱신했고 기존 Profile/CCTV/Experiment 값과 limit 2는 유지했습니다.
정답·환경 조건·선택·실행 상태를 콘텐츠에 추가하지 않았습니다.

```text
CaseData.available_containment_rooms → Main → ContainmentView.setup(rooms)
    → RoomScroll / RoomList → 배열 길이만큼 VBoxContainer + Label 두 개 생성
```

표시만 필요한 단계여서 기존 목록 구현과 같은 단순한 Label/Container 방식을 사용했습니다.
별도 Item Scene, Component 계층, Manager, Runtime 상태나 새로운 진행 signal은 필요하지 않았습니다.
View는 Main이나 .tres를 탐색하지 않고 전달받은 콘텐츠를 읽기만 합니다.

| 검증 | 결과 |
| --- | --- |
| 기본 후보 | 3개, 배열 순서/이름/설명 일치, 각 항목은 Label 2개, 선택 UI 없음 |
| 반복 진입 | 창 크기마다 첫/두 번째/세 번째 진입 모두 같은 개수, 3→6→9 누적 없음 |
| 반복 setup | 이전 항목 해제, 배열 개수 유지, 스크롤 초기화, signal 중복 없음 |
| Resource-only 3→4 | .tres만 수정, Headless/GPU에서 4개 표시, 네 번째 후보까지 스크롤 가능 |
| Resource-only 3→2 | .tres만 수정, Headless/GPU에서 2개 표시 |
| 복원 | 원래 3개 파일 바이트/SHA-256로 복원, 3개 재실행 성공 |
| 코드 불변성 | 3/4/2 검증 동안 생산 GDScript 12개 해시 동일 |
| 오류 처리 | 빈 목록, null, 빈/공백 ID·이름·설명에서 경고/대체 문구, MONITORING 진행 가능 |
| Runtime 회귀 | 01 실행 후 remaining 1, 03 실행 후 0, Containment/setup/전환 중 history와 State 유지 |
| 기존 기능 | Profile/CCTV, Experiment 목록/선택/승인/거부/result/완료/limit 회귀 통과 |
| 전체 흐름 | 6개 View 순환, RESULT→PROFILE, 한 View, 이전 View 해제, 단일 signal 연결 |
| 해상도 | 1920×1080 / 1280×720 / 1024×768, canvas_items/keep/Scaling 유지 |
| 파싱 | Godot 4.7.1 import 성공, 생산 GDScript 12개 check-only exit 0 |
| 실행 | Main Headless/GPU 성공, 최종 33개 검사 exit 0 |
| 경고 | 정상 입력 오류/경고 없음, 후보 오류 시험 각 8개, 기존 Experiment 오류 시험 각 17개로 일치 |
| GPU 화면 | AMD Radeon RX 6800 / OpenGL 3.3 Compatibility, 기본3/변경2/작은창4 스크롤 캡처 직접 확인 |

F5 키 자체는 자동 조작하지 않았으며 같은 Main Scene을 명령행으로 실행했습니다.
발견된 프로젝트 오류와 미해결 문제는 없습니다. Runtime/Experiment Script/Scene과 기존 검증 원본을 보존했습니다.
검증용 Script는 이전 검사 사본과 작은 후보 목록 검사를 사용하며 별도 Framework를 추가하지 않았습니다.
`.godot/verification/step10/`에 로그·캡처·사본·해시와 `resource-edit-evidence.json`, `validation-results.json`,
`change-summary.json`을 보관합니다. `changes-step10.diff`는 Step 10 시작 시점과 비교한 변경,
`changes-all-uncommitted.diff`는 Step 9를 포함한 현재 전체 변경입니다. 검증 파일은 Git에서 제외됩니다.

이번 단계에는 Containment 선택·확정·정답·환경 판정, Monitoring 로직, Success/Failure,
Incident/Broadcast/Research Log/Campaign/Save/Load, Audio/Animation/Shader/Theme/Manager를 추가하지 않았습니다.
다음 단계는 요구사항이 확정되면 ContainmentData와 setup 경계를 유지하며 표시 항목이나 동작을 추가하기 좋습니다.
현재는 후보 목록 표시만 담당합니다. 커밋과 push는 하지 않았습니다.

## 9단계 A 규칙 Experiment 제한 검증 결과

작업 전에 소스 34개, Case/ExperimentData, Runtime, Main, 실행 순서, 목록/선택/setup/signal,
전체 Scene과 설정, UID, 기존 검증 코드를 조사했습니다. 작업 트리는 깨끗했으며 Step 6/7/8은
직전 커밋 `a09c2b7a8fadea60b2f5298fc43918aef24f4703`에 포함되어 있었습니다.
로컬 master는 origin/main보다 1개 커밋 앞서 있습니다. 이번 단계에서는 커밋/push를 하지 않았습니다.

기존 Step 8의 중복 기록 허용 규칙은 이번 확정된 A 규칙으로 교체했습니다.
하나의 Case에서 ID별 최대 1회 실행, 승인마다 limit 1회 소비, 소진 후 미실행 ID도 실행 불가입니다.
콘텐츠 Resource는 정의만 보유하고 Runtime이 유일한 실행 이력 원본입니다.
Main에는 중복 이력/횟수 필드나 실행 규칙을 추가하지 않았습니다.

```text
ExperimentView → experiment_execution_requested(ID) → Main
    → Runtime.try_record_experiment_execution(ID, current_case.experiment_limit)
    → 승인·기록 성공 후 View 결과 표시 → 최신 snapshot으로 UI 갱신
```

| 검증 | 결과 |
| --- | --- |
| 테스트 콘텐츠 | 후보 01/02/03 유지, experiment_limit = 2만 추가, 최종 밸런스 미확정 |
| 초기 / 선택만 | history [], remaining 2, 선택 변경/선택 후 전체 순환에도 소비 없음 |
| 첫 실행 | TEST_EXP_01 승인, history [01], remaining 1, 결과 즉시 표시 |
| 중복 차단 | 완료 항목 disabled, 오래된 UI를 일부러 전달한 실제 Run 요청도 Runtime에서 거부 |
| 재진입 1회 | 01 Executed/disabled, 02/03 가능, remaining 1, 선택 없음/결과 초기화 |
| 두 번째 실행 | TEST_EXP_03 승인, history [01,03], remaining 0 |
| 제한 소진 | 02는 미실행이나 disabled, 오래된 UI의 02 Run도 거부, 이력/횟수 불변 |
| 재진입 0회 | 01/03 Executed, 모든 항목과 Run disabled, remaining 0 |
| setup 반복 | 현재 snapshot으로 복원, 이전 항목 해제, 단일 ButtonGroup/연결 유지, State 불변 |
| 승인 순서 | 결과 선표시 제거, Runtime 거부 시 결과 없음 확인 |
| State 직접 검사 | A true → A false → B true → C false, history A/B, count 2, remaining 0 |
| 잘못된 데이터 | 빈/공백 ID, null, 빈 목록, 0/음수 limit, 선택 Resource 변경 후 강제 Run 방어 |
| 빈 결과 정책 | Runtime 승인한 빈/공백 result_text는 기존 [Missing result_text] 표시와 1회 소비 |
| Resource 불변성 | CaseData/ExperimentData Script와 .tres 실행 전후 해시 동일, 공유 콘텐츠 필드 값 불변 |
| 회귀 | Profile/CCTV 표시, 동적 세 항목, 단일 선택, 전체 6개 흐름, 한 View, 이전 View 해제 |
| 크기 / Stretch | 1920×1080, 1280×720, 1024×768, 논리 UI/keep/canvas_items 유지 |
| 파싱 / 실행 | Godot 4.7.1 import 성공, 생산 GDScript 10개 check-only 성공, Headless/GPU 실행 성공 |
| GPU | AMD Radeon RX 6800 / OpenGL 3.3 Compatibility, 실제 상태별 화면 캡처 확인 |
| 최종 검사 | 24개 exit 0, 정상 입력 오류/경고 없음, 잘못된 데이터 시험은 각 환경에서 예상 경고 17개 |

F5 키 자체는 자동 조작하지 않았으며 같은 설정된 Main Scene을 명령행으로 실행했습니다.
새 검증 Script에서 동적 setup 호출에 넘긴 빈 배열이 untyped였던 문제는 `Array[String]`을
명시해 수정했습니다. 최종 검증은 통과했으며 프로젝트 미해결 오류는 없습니다.
이전 단계의 검증 Script 원본은 보존했습니다. 중복 허용/결과 선표시를 가정하던 검사는
새 규칙에 맞는 작은 개발 검사로 대체했고, 기존 Profile/CCTV/전체 흐름 검사는 출력 경로만 바꾼 사본을 실행했습니다.

수정한 프로젝트 파일은 CaseData, 테스트 Case .tres, CaseRuntimeState, Main Script,
ExperimentView Script/Scene, README의 7개입니다. 프로젝트 소스 생성/삭제는 없습니다.
기존 설정, Main Scene, 다른 View/Data, flow_view.gd, UID와 과거 단계 보고는 그대로입니다.
검증용 파일·로그·캡처와 시작 시점 사본/해시는 Git 제외 경로 `.godot/verification/step9/`에 있습니다.
`validation-results.json`, `resource-immutability.json`, `change-summary.json`, `changes-step9.diff`로
실행과 이번 단계 변경 범위를 확인할 수 있습니다.

Research Log/Entry, Tag/Flag, 실험 시간/비용, Animation/Audio, Containment/Monitoring 로직,
Success/Failure, Incident/Broadcast, Campaign, Save/Load, Singleton/Manager, 최종 Theme는 추가하지 않았습니다.
다음 단계는 필요한 화면 데이터·규칙이 확정되면 기존 Resource → Main → View 경계를 확장하는 지점입니다.
실험 승인 및 제한의 최종 권한은 Runtime에 유지합니다.

## 8단계 Case Runtime State와 Experiment 실행 이력 검증 결과

작업 전에 프로젝트 소스 32개, 6개 Scene, Main의 View 생성/해제와 setup/signal,
모든 콘텐츠 Resource, 선택·실행·결과 처리, UID, 기존 검증 Script와 Git 상태를 확인했습니다.
기존 Step 6/7 미커밋 변경은 README, 테스트 .tres, Experiment Scene, ExperimentData,
Experiment Script의 5개 파일에 있었습니다. 이를 `.godot/verification/step8/baseline/`에
사본/해시로 보관한 뒤 필요한 변경만 추가했으며 기존 작업은 되돌리지 않았습니다.

이번 단계의 소스 생성은 `scripts/runtime/case_runtime_state.gd`와 Godot가 생성한 UID입니다.
수정은 `scripts/main/main.gd`, `scripts/views/experiment_view.gd`, 이 README 3개이며 삭제는 없습니다.
Main에는 State 생성/소유, 실행 signal 연결, 기록 API 전달만 추가했습니다.
ExperimentView에는 정상 실행 signal과 빈 ID 실행 방어만 추가했습니다.
프로젝트 설정, 모든 Scene, 콘텐츠 Data Script와 .tres, flow_view.gd, 기존 UID는 그대로입니다.

실행 흐름은 다음과 같습니다.

```text
RunButton → ExperimentView: 선택 Resource/ID 확인 → 즉시 result_text 표시
          → experiment_executed(ID) → Main → CaseRuntimeState.record_experiment_execution(ID)
```

| 검증 | 결과 |
| --- | --- |
| Godot 버전 | 4.7.1.stable.official.a13da4feb |
| 파싱 / 스크립트 | Editor import 성공, 생산 GDScript 10개 check-only exit 0 |
| Main | Headless / Windows GPU 실행 exit 0, 기존 F5 대상 유지 |
| State 직접 검증 | 초기 0, A/B/A 순서·중복·count 3, 조회 복사본, reset, 인스턴스 독립성 통과 |
| 선택만 수행 | signal / 실행 이력 추가 없음 |
| 실행 | 첫 진입에서 TEST_EXP_01 / TEST_EXP_03 / TEST_EXP_03 순서, count 1/2/3 |
| 반복 / 전환 | 중복 ID 유지, 3회 전체 순환 동안 동일 State와 이력 유지, 총 9개 |
| 재진입 / setup | 선택 없음·결과 초기화·Run 비활성화, 실행 이력 유지, 연결 중복 없음 |
| 실패 실행 | 미선택, null, 빈/공백 ID에서 signal 및 기록 없음 |
| 빈 결과 | 유효한 ID는 기존 [Missing result_text] 표시와 성공 기록 정책 유지 |
| State 방어 | 직접 빈/공백 ID 기록 요청도 false, 이력 유지 |
| Resource 보호 | CaseData / ExperimentData Script와 .tres 실행 전후 SHA-256 동일, 네 Experiment 필드 값 동일 |
| 회귀 | 기존 Profile/CCTV, 동적 목록, 단일 선택, 결과 초기화, 반복 실행, 6개 View 흐름 통과 |
| 창 / 배치 | 1920×1080 / 1280×720 / 1024×768, 기존 Stretch/Scaling/한 View 표시 유지 |
| 실행 방식 | Headless와 AMD Radeon RX 6800 / OpenGL 3.3 Compatibility에서 검증 |
| 검증 수 | 최종 29개 검사 exit 0, 정상 입력 경고/오류 없음 |

F5 키 자체는 자동 조작하지 않았으며 같은 application/run/main_scene을 명령행으로 실행했습니다.
새 잘못된 실행 검사는 Headless/GPU 각각 예상 경고 14개, 기존 실행 예외 검사는 각각 6개,
기존 누락 데이터 검사는 5개로 일치했습니다. 프로젝트 오류는 없습니다.
검증 도중 새 검증 Script의 정적 타입상 불가능한 `is Resource/Node` 표현을 native class 조회로
수정했고, 복사한 화면 회귀 검사의 캡처 출력 폴더를 생성했습니다. 최종 재검증은 통과했습니다.
기존 검증 Script 원본은 수정하지 않고 Step 8 사본의 출력 경로만 변경했습니다.
1920×1080 및 작은 창 실행 캡처도 직접 확인했습니다.

검증 로그, 캡처, 새 작은 개발 검사와 runner는 Git 제외 경로 `.godot/verification/step8/`에 있습니다.
`validation-results.json`, `resource-immutability.json`, `change-summary.json`에 검사와 보존 결과를,
`changes-step8.diff`에 시작 시점 대비 Step 8 변경만,
`changes-all-uncommitted.diff`에 기존 Step 6/7을 포함한 전체 Git 변경을 보관합니다.

이번 단계에서는 실행 횟수 제한, 남은 횟수 UI, 중복 금지, Research Log/Entry, Tag/Flag,
Save/Load, Manager/Singleton, Case 전환 시스템과 다른 게임 로직을 구현하지 않았습니다.
후속 단계는 필요가 확정되면 Runtime State의 조회 API를 상위 계층에서 연결하는 지점이 적합합니다.
현재 UI 선택/결과와 콘텐츠 Resource의 경계는 유지합니다. 커밋과 push는 하지 않았습니다.

## 7단계 Experiment 즉시 실행과 결과 텍스트 검증 결과

작업 전 원본 파일 32개와 기존 검증 Script 27개를 조사했습니다. Git은 `master`가
`origin/main`을 추적하며 HEAD는 `0f1229f`입니다. 6단계의 README / Experiment Scene /
Experiment Script 변경 세 개가 미커밋 상태였으므로 해당 작업 트리의 사본·해시·diff를
먼저 저장해 보존했습니다. 기존 목록은 CheckBox + ButtonGroup, 선택 인덱스는 View 내부였으며
ExperimentData는 결과 필드 없이 콘텐츠 세 필드만 갖고 있었습니다.

추가한 콘텐츠 필드는 typed `result_text: String` 하나뿐입니다. 테스트 Experiment 01~03에는
`Temporary result for TEST EXPERIMENT 01.`처럼 서로 다른 임시 결과를 넣었습니다.
선택·실행·횟수·사용 기록 필드는 Resource에 추가하지 않았습니다.

목록과 실행/결과 영역을 HBoxContainer 안에 나란히 배치해 기존 ViewHost 높이를 유지했습니다.
RunButton은 초기 disabled, 유효한 선택 후 enabled입니다. 결과는 RESULT 제목 아래 Label에
즉시 표시하며, 실행 버튼은 _ready()에서 한 번만 연결합니다. 진행 버튼과 기존 signal은 유지했습니다.

| 검사 | 결과 |
| --- | --- |
| Godot 엔진 | 4.7.1.stable.official.a13da4feb, Windows Standard |
| 프로젝트 import / 전체 9개 Script check-only / Main 기본 실행 | 통과, 종료 코드 0 |
| 기존 Profile / CCTV / 동적 목록 / 단일 선택 | 기존 검사 사본 재사용, 내용·개수·signal 보존 |
| 초기 상태 / 재진입 | 선택 없음, Run 비활성화, 이전 결과 없음 |
| Experiment 01~03 실행 | 각 Resource의 서로 다른 result_text 정상 표시 |
| 선택 변경 | 이전 결과 초기화, 새 항목 실행 전 상태로 전환 |
| 같은 선택 / 재실행 | 같은 항목 재클릭 시 결과 유지, 두 번 연속 실행해도 같은 결과 |
| 동일 인스턴스 setup | 목록·선택·그룹·결과 정리, Run 비활성화, 중복 연결 없음 |
| 전체 View 회귀 / Scaling | 18회 진행 클릭·3회 순환, 1920×1080 / 1280×720 / 1024×768 통과 |
| Windows GPU | AMD Radeon RX 6800 / OpenGL 3.3 Compatibility, 정상·예외 검사 통과 |
| 실행 예외 | 선택 없음 강제 요청, null 선택 Resource, 빈/공백 결과, null/빈 목록에서 안전하게 진행 |
| 결과 변경 검증 | TEST_EXP_02.result_text 하나만 변경해 Headless / GPU에서 변경 결과 확인 |
| 코드 보호 | Resource 변경 검사 동안 실행용 GDScript 9개 SHA-256 동일 |
| Resource 보호 | 선택/실행/다른 선택/반복 실행 전후 .tres 해시 동일, 런타임 네 콘텐츠 필드 동일 |
| 복원 | .tres 원본 바이트·해시로 복원 후 재실행 통과 |
| 실제 화면 | 기본 결과 / 변경 결과 / 초기 상태 / 작은 창 결과 캡처 직접 확인 |

Resource-only 검사에서는 TEST_EXP_02의 결과만
`Temporary edited result for TEST EXPERIMENT 02.`로 변경했습니다. 검증 후 세 Experiment의
원래 결과 문구를 복원했습니다. 정상 입력 로그에는 오류·경고가 없고, 실행 예외 검사에는
의도한 경고 여섯 개만 있습니다. 미해결 프로젝트 오류는 없습니다.
Main 화면 공간은 그대로 두고 Experiment 안에 목록과 결과를 나란히 배치해 레이아웃 검사를
통과했습니다. F5 키 자체는 자동 조작하지 않았으며 동일 Main Scene의 기본 실행을 검증했습니다.

이번 단계에서 수정한 원본은 ExperimentData, 테스트 .tres, Experiment Scene, Experiment Script,
이 README의 다섯 파일입니다. 생성/삭제한 게임 파일은 없습니다. 기존 미커밋 변경을 포함하는
전체 git diff와 별도로, 7단계 시작 사본에 대한 diff를 저장해 단계별 범위를 구분했습니다.
CaseData / ProfileData / CCTVData, Main, flow_view.gd, 다른 View, project.godot, 해상도/Stretch,
기존 UID와 검증 Script는 원본 해시로 보존 여부를 확인했습니다.

검증 Script·로그·캡처·변경 전 사본·Resource 변경 증거·해시·diff는 Git 제외 폴더
`.godot/verification/step7/`에만 있습니다. 기존 검증 코드는 수정하지 않았고 사본의 출력 경로만
바꿨습니다. 실행 전용 검사는 기존 선택/전체 흐름 검사를 확장해 재사용했습니다.
이번 단계에서는 커밋이나 push를 하지 않았습니다.

## 6단계 Experiment 단일 선택 검증 결과

작업 전 원본 파일 32개와 기존 검증 Script 18개를 조사했습니다. Experiment 항목은
이름/설명 Label 두 개를 가진 동적 VBoxContainer였고 선택 상태는 없었습니다.
Main은 기존 배열을 setup()으로 전달하고 이전 View를 제거·해제하는 구조였습니다.
Git은 `master`가 `origin/main`을 추적하며 HEAD는 `0f1229f`, 작업 트리는 깨끗했습니다.

선택은 기존 이름 Label을 CheckBox로 바꾸고 View 내부 ButtonGroup으로 묶는 방식입니다.
기본 Radio 선택 표시를 사용하므로 별도 Item Scene, StyleBox, Theme, 전역 상태는 없습니다.
기존 동적 목록과 데이터 전달 방식은 유지했습니다.

| 검사 | 결과 |
| --- | --- |
| Godot 엔진 | 4.7.1.stable.official.a13da4feb, Windows Standard |
| import / 전체 9개 GDScript / Main 기본 실행 | 통과, 종료 코드 0 |
| 초기 상태 | Experiment 3개, 선택 인덱스 -1, 모든 항목 선택 없음 |
| GUI 선택 | 01 → 02 → 03마다 이전 선택 해제, 항상 정확히 하나 선택 |
| 같은 항목 재클릭 | 03 재클릭 후 03 선택 유지 |
| 재진입 | 선택한 채 CONTAINMENT 진행, 전체 순환 후 선택 없음으로 재진입 |
| 동일 인스턴스 setup | 선택 초기화, 항목 중복 없음, 이전 항목 해제, 이전 그룹 참조 정리 |
| 선택 항목 제거 | 02 선택 후 03만 있는 새 목록 전달, 선택 없음으로 초기화, 새 03 정상 선택 |
| 빈 목록 / null | 선택 후 빈 배열로 교체해도 안전, null Control 비활성화, 유효 선택을 방해하지 않음 |
| 기존 누락 입력 | 기존 다섯 오류 시나리오의 경고·대체 문구·진행 유지 |
| Resource 보호 | 런타임 세 필드 값 비교 통과, .tres 및 모든 Data Script 원본 SHA-256 동일 |
| Profile / CCTV | 기존 검사 재사용, 표시 값·진행·signal 유지 |
| 전체 순환 / Scaling | 18회 진행 클릭과 3회 순환, 1920×1080 / 1280×720 / 1024×768 통과 |
| signal | 진행과 각 선택 버튼에 연결 하나씩, 반복 setup 후에도 중복 없음 |
| Windows GPU | AMD Radeon RX 6800 / OpenGL 3.3 Compatibility, 회귀·선택·예외 검사 통과 |
| 실제 화면 | 선택 없음, 02 선택, 작은 창의 03 선택 캡처 직접 확인 |

기본 CheckBox의 최소 높이가 Label보다 커져 초기 검사에서 세 번째 항목 일부에 스크롤이
필요한 문제가 발견되었습니다. Experiment 내부 간격을 3, 목록 높이를 202로 조정하고
선택 글자 크기를 18로 맞춰 기존 360 높이 안에서 세 항목과 진행 버튼이 모두 보이도록 했습니다.
Main Scene과 프로젝트 설정은 그대로입니다. 수정 후 정상 입력 로그에는 오류·경고가 없습니다.
빈 데이터 검사의 경고는 예상된 결과이며 미해결 프로젝트 오류는 없습니다.
F5 키 자체는 자동 조작하지 않았으며 동일 Main Scene의 기본 실행을 검증했습니다.

원본 변경은 `scripts/views/experiment_view.gd`, `scenes/views/experiment_view.tscn`,
이 README의 세 파일뿐입니다. 새 게임 파일과 삭제한 파일은 없습니다.
CaseData / ProfileData / CCTVData / ExperimentData, 테스트 .tres, Main, 공용 flow_view.gd,
다른 View, project.godot, 기존 UID, 기존 검증 Script는 보존했습니다.
검증용 추가 파일과 로그·캡처·원본 사본·해시·diff는 Git 제외 폴더
`.godot/verification/step6/`에만 있습니다. 기존 검증 Script는 수정하지 않았고,
새 회귀 검사 사본에서 출력 경로와 이름 Node의 타입 검사(Label → CheckBox)만 조정했습니다.
선택 전용 검사는 기존 전체 순환 검사에 GUI 선택과 setup 초기화 확인을 추가했습니다.
이번 단계에서는 커밋이나 푸시를 하지 않았습니다.

## 5단계 Experiment 배열과 동적 목록 검증 결과

작업 전 원본 파일 28개와 기존 검증 Script 10개를 확인했습니다. Profile / CCTV는
Main의 `setup()` 전달 방식이었고, Experiment는 공용 진행 Script와 고정 임시 문구만
사용했습니다. 기존 CaseData에는 Experiment 배열이 없었습니다. Git은 `master`,
최초 커밋 전 미추적 상태였습니다. Autoload와 추가 게임 시스템은 없었습니다.

| 검사 | 결과 |
| --- | --- |
| Godot 엔진 | 4.7.1.stable.official.a13da4feb, Windows Standard |
| 전체 프로젝트 import / 9개 GDScript check-only / Main 실행 | 통과, 종료 코드 0 |
| 기본 세 Experiment | TEST_EXP_01~03, 서로 다른 이름/설명, UI 항목 정확히 세 개 |
| 반복 진입 | 18회 GUI 클릭/3회 순환, EXPERIMENT는 매번 세 개, 이전 View 해제 |
| 반복 setup | 기존 항목 제거/해제 후 동일 개수 유지, signal 연결 하나씩 |
| Profile / CCTV 회귀 | 기존 검증 Script 재사용, 데이터와 진행 동작 유지 |
| 창 크기 / Scaling | 1920×1080 / 1280×720 / 1024×768, 기존 6개 화면 회귀 통과 |
| Windows GPU | AMD Radeon RX 6800 / OpenGL 3.3 Compatibility, 모든 검사 종료 코드 0 |
| 3→4 Resource-only | .tres에 TEST_EXP_04 추가, Headless / GPU에서 4개 표시, 마지막 항목 스크롤 확인 |
| 3→2 Resource-only | .tres의 세 번째 항목 제거, Headless / GPU에서 2개 표시 |
| Resource 검사 중 Script 보존 | 실행용 GDScript 9개 SHA-256 동일, Profile/CCTV 값 유지 |
| 복원 | .tres 원본 바이트/해시로 3개 상태 복원 후 Headless 재실행 통과 |
| 오류 데이터 | 빈 배열 / null 항목 / 각 필드의 공백: 예상 경고 5개, 표시와 CONTAINMENT 진행 확인 |
| 화면 확인 | 기본 3개, 변경 4개 스크롤, 변경 2개, 작은 창 캡처 직접 확인 |

초기 레이아웃 검사에서 Experiment 내용의 최소 높이가 363으로 기존 ViewHost의
360을 넘는 문제가 발견되었습니다. Experiment 내부 간격과 글자 크기를 조정해
진행 버튼을 기존 영역 안에 배치했습니다. Main Scene이나 프로젝트 설정은 바꾸지 않았습니다.
수정 후 정상 입력 로그에는 오류·경고가 없고 미해결 프로젝트 오류도 없습니다.
F5 키 자체는 자동 조작하지 않았으며, 동일 Main Scene을 사용하는 프로젝트 기본 실행을 검증했습니다.

새 원본 파일은 ExperimentData / ExperimentView Script와 자동 생성 UID 두 개로 총 4개입니다.
수정한 기존 파일은 CaseData, Main Script, 테스트 .tres, Experiment Scene, 이 README의 5개입니다.
Main에는 Script 참조와 데이터 전달 분기만 추가했습니다. 삭제한 원본 파일은 없습니다.
Profile/CCTV 관련 파일과 해당 내장 Resource 내용, flow_view.gd, Main Scene, 다른 View,
project.godot와 해상도/Stretch 설정, 기존 UID, 기존 검증 Script는 그대로 보존했습니다.

검증 Script와 로그·캡처·변경 전 사본·해시·diff는 Git 제외 폴더
`.godot/verification/step5/`에 있습니다. GPU 회귀 검사 사본은 기존 코드에서 출력 경로만
바꿨으며, Experiment 전용 검사는 기존 Profile/CCTV 검사에 목록 검증을 추가했습니다.
최초 커밋 전 상태이므로 `git diff --no-index`와 원본 사본/해시로 실제 변경을 확인합니다.
커밋은 만들지 않았습니다.

## 4단계 CCTV Resource 연결 검증 결과

작업 전 실제 원본 파일 24개와 기존 검증 자료를 조사했습니다. CaseData는 ProfileData만
참조했고, CCTV는 공용 진행 Script와 고정 임시 설명을 사용했습니다. Autoload와 추가
게임 시스템은 없었습니다. Git은 `master`, 최초 커밋 전이며 모든 원본 파일이 미추적 상태였습니다.

검증 엔진은 **4.7.1.stable.official.a13da4feb**입니다.

| 검사 | 결과 |
| --- | --- |
| 프로젝트 import / 전체 7개 GDScript 파싱 / Main 기본 실행 | 모두 종료 코드 0 |
| CCTV Resource 표시 | camera_id / observation_text가 전달된 Resource와 일치 |
| 기존 Profile 회귀 | 기존 검증 Script 통과, 3개 표시 필드와 signal 연결 유지 |
| 6개 화면 이동과 재시작 | Headless / Windows GPU 각각 18회 GUI 클릭, 3회 순환 통과 |
| 한 번에 View 하나 | 전환 직후 자식 하나, 이전 View 해제, signal 중복 없음 |
| 창 크기 변경 | 1920×1080 / 1280×720 / 1024×768 순환 통과, 기존 비율 유지 |
| 누락 CCTVData / 공백 camera_id / 공백 observation_text | 각각 예상 경고와 대체 문구, EXPERIMENT 진행 확인 |
| Resource-only 변경 | .tres의 CCTV 두 필드만 수정해 Headless / Windows GPU 표시 변경 확인 |
| 변경 검증 중 GDScript / Profile 보존 | 실행용 Script 7개 SHA-256 동일, Profile 표시 값 동일 |
| 데이터 복원 | .tres 원본 해시로 복원 후 기본 값 재실행 통과 |
| 실제 화면 | 기본/변경 CCTV의 1920×1080 캡처와 작은 창 배치 직접 확인 |

Resource 변경 검증에서는 camera_id를 `TEST_CAM_01 — RESOURCE EDIT`, observation_text를
`Temporary edited CCTV observation for Resource-only validation.`으로 바꿨습니다.
최종 Resource에는 `TEST_CAM_01`과 원래 임시 설명을 복원했습니다. 정상 입력 로그에는
오류나 경고가 없으며, 누락 입력 검사에는 의도한 경고 세 개만 있습니다. 미해결 프로젝트 오류는 없습니다.
F5 키 자체를 자동 조작하지는 않았으며, 같은 Main Scene을 실행하는 기본 프로젝트 명령을
Headless와 Windows GPU에서 검증했습니다.

추가한 원본 파일은 CCTVData / CCTVView Script와 해당 UID로 총 4개입니다.
수정한 파일은 CaseData, Main Script, 테스트 .tres, CCTV Scene, 이 README의 5개입니다.
Main은 CCTV 전달 분기만 추가했고, CCTV Scene은 Script 연결과 데이터 Label만 변경했습니다.
삭제한 원본 파일은 없습니다. Main Scene, Profile 관련 Scene/Script/Data, 공용 flow_view.gd,
다른 네 View, project.godot와 해상도/Stretch 설정, 기존 UID와 기존 검증 Script는 보존했습니다.

기존 검증 코드를 재사용했고 GPU 회귀 검사 사본에서는 출력 경로만 바꿨습니다.
검증 Script, 격리 프로필, 로그, 캡처, 변경 전 사본, SHA-256 비교와 `git diff --no-index`
자료는 Git 제외 폴더 `.godot/verification/step4/`에만 있습니다. 일반 `git diff`는
미추적 원본 파일을 비교할 수 없어 작업 전 사본을 기준으로 검사했습니다. 커밋은 만들지 않았습니다.

## 3단계 Resource 연결 검증 결과

검증 엔진은 동일한 **4.7.1.stable.official.a13da4feb**입니다.

| 검사 | 결과 |
| --- | --- |
| 프로젝트 import, 전체 5개 GDScript 파싱, Main 기본 실행 | 모두 종료 코드 0 |
| CaseData / 내장 ProfileData와 3개 표시 필드 | typed Resource 참조와 실제 Label 값 확인 |
| PROFILE → CCTV, RESULT → PROFILE, 반복 순환 | 데이터 검사에서 12번 GUI 클릭/2회 순환, 복귀마다 표시 값 동일 |
| signal 연결 | 각 View 진행 요청과 버튼에 연결이 하나씩, 중복 전환 없음 |
| 기존 6개 화면 회귀 검사 | 기존 검증 코드를 보존해 재사용, Headless/Windows GPU 양쪽 통과 |
| 창 크기 변경 | 1920×1080, 1280×720, 1024×768에서 각 1회 순환과 재시작 통과 |
| Resource-only 변경 | .tres의 3개 표시 필드만 수정해 Headless 및 GPU 실행 시 새 값 표시 확인 |
| Script 보존 및 데이터 복원 | 값 변경 검증 동안 실행용 GDScript SHA-256 동일, .tres 원본 해시로 복원 후 재실행 통과 |
| 누락 데이터 | Case 미지정, Profile null, 공백 문자열: 예상 경고/대체 문구/진행 버튼 동작 확인 |
| 화면 확인 | 기본/변경 Resource의 1920×1080 캡처 및 1024×768 창의 PROFILE 배치 직접 확인 |

값 변경 검증에서 subject_name은 `TEST SUBJECT — RESOURCE EDIT`, classification은
`TEST CLASSIFICATION — EDITED`, basic_description은
`Temporary edited profile text for Resource-only validation.`으로 바꿨습니다.
게임을 새 프로세스로 실행해 처음과 두 번 순환한 뒤의 Label 값을 확인했습니다.
최종 `.tres`에는 원래 TEST SUBJECT / TEST CLASSIFICATION / 기본 설명을 복원했습니다.

정상 입력 실행 로그에는 파싱/런타임 오류나 경고가 없습니다. 누락 입력 검사는 의도한
경고가 발생하는지 별도로 확인했습니다. 초기 새 검증 Script에서 반복한 마우스 진입
알림이 경고를 발생시켰으며 해당 불필요한 알림을 제거한 뒤 재검증했습니다.
미해결 프로젝트 오류는 없습니다.

검증용 Script, 격리 프로필, 로그, 캡처, Resource 변경 증거, 변경 전 사본과 diff는
`.godot/verification/step3/`에만 있습니다. 기존 1·2단계 검증 Script는 수정하지 않았습니다.

### 3단계 조사와 실제 변경 범위

작업 전 원본 파일 17개를 조사했습니다. 6개 View는 모두 공용 진행 Script를 사용했고
Resource 콘텐츠는 없었습니다. 기존 UID 두 개와 Git의 최초 커밋 전 상태를 확인했습니다.

새로 만든 원본 파일은 Resource Script 2개, Profile Script 1개, 해당 UID 3개,
테스트 .tres 1개로 총 7개입니다. 수정한 기존 파일은 Main Scene, Profile Scene,
Main Script, 이 README의 4개입니다. 삭제한 파일은 없습니다.
공용 flow_view.gd, 다른 5개 View, project.godot와 해상도/Stretch 설정, 기존 UID,
Git 설정용 파일과 기존 검증 코드는 SHA-256 비교로 보존 여부를 확인했습니다.
최초 커밋이 없어 `git diff --no-index`와 작업 전 사본/해시로 변경 범위를 구분했고
커밋은 만들지 않았습니다.

## 2단계 작업 전 조사와 변경 범위

2단계 시작 시 기존 기반 파일 9개, Main의 Label 4개, 창 크기 표시 Script와
기존 검증 자료가 있었습니다. 추가 View, Resource 콘텐츠, Autoload, 플러그인은 없었습니다.
Git은 `master`에서 커밋/추적 파일이 없는 상태였고 기존 기반 파일도 미추적 상태였습니다.
`project.godot`의 비율 유지와 창 크기 변경 항목은 에디터가 저장한 Godot 기본값이었습니다.

이번 단계에서는 6개 View Scene과 `flow_view.gd`, Godot가 생성한 해당 UID를
추가했습니다. 수정한 기존 파일은 Main Scene, Main Script, 이 README뿐입니다.
Main Scene은 기존 레이아웃을 유지하면서 제목/안내 문구 2개와 ViewHost만 변경했고,
Main Script에는 전환에 필요한 코드만 추가했습니다. `project.godot`, 기존 UID,
`.gitignore`, `.gitattributes`, assets/resources의 `.gitkeep`, 기존 검증 코드는 보존했습니다.

추적 파일이 없어 일반 `git diff`만으로는 2단계 변경을 구분할 수 없으므로,
작업 시작 전 사본과 `git diff --no-index` 및 SHA-256 비교로 범위를 검사했습니다.
삭제되거나 의도하지 않게 수정된 원본 파일은 없으며 커밋은 만들지 않았습니다.

### 1단계 작업 시작 전 상태

저장소 전체 조사 결과 `.git`만 존재했습니다. `project.godot`, Scene, Script,
Resource, Autoload, 기존 콘텐츠는 없었습니다. Git은 `master` 브랜치에 최초
커밋이 없는 상태였으며, 보존 또는 덮어쓰기 대상인 기존 프로젝트 파일은 없었습니다.

## 범위와 다음 단계

현재 구현은 임시 Main UI, 창 크기 표시, 9개 View의 명시적 Route와 테스트 Resource의
PROFILE / CCTV 텍스트, EXPERIMENT 목록·단일 선택·즉시 결과 텍스트 표시와
현재 Case의 메모리 실행 ID 이력, ID별 1회와 Case 횟수 제한, 완료/남은 횟수 표시입니다.
CONTAINMENT의 Resource 후보 목록, 임시 단일 선택, 명시적 확정과 메모리 Runtime 기록도 포함합니다.
MONITORING은 확정 Room ID별 Outcome을 Timer로 순차 재생하고 시간/관찰 기록을 누적하며 완료 후 Main이 SUCCESS/FAILURE를 Runtime에 한 번 확정하고 결과 표시와 Next를 활성화합니다.
SUCCESS는 RESULT로, FAILURE는 ID로 찾은 IncidentData 표시 → Broadcast/Option 표시·선택·Confirm → Runtime ID 쌍 기록 → IncidentResultData 표시 → RESULT로 진행합니다. UNDEFINED와 미확정 진행은 Main에서 차단합니다. 테스트 Case는 시스템 검증용이며 정식 세계관/크리쳐가 아닙니다.
CCTV 이미지·영상·상태 변화·환경 수치, Experiment 결과 이미지/오디오, Containment 환경 조건·정답 판정,
Monitoring 진행 위치·경과시간 저장, 실제 Result 콘텐츠, Campaign, 정식 Case 로직,
정식 Incident 콘텐츠·탈출/피해/대응·Runtime Incident 상태, Broadcast Option 결과의 피해·점수·성공/실패 판정, 영구/다중 Case Research Log,
Save/Load, Settings, Horror Event, 검열·이미지 시스템, CRT/Shader, Audio, Animation,
GameState Singleton, CaseManager, CampaignManager, 최종 UI/폰트/에셋은 구현하지 않았습니다.

다음 단계에서는 이번 CaseData → 화면별 Resource → View.setup() 경계를 유지하면서
필요한 표시 항목을 한 가지씩 검증할 수 있습니다. 다른 화면의 데이터가 실제로 필요해지면 해당 화면용
Resource와 표시 Script만 추가하는 지점이 적합합니다. 아직 사용하지 않는 필드나
게임 시스템은 미리 만들지 않습니다.
Experiment 표시 확장은 `experiment_data.gd`와 `experiment_view.gd`에서 시작할 수 있습니다.
현재 선택과 결과는 View 내부에만 있으며 실행 ID 이력은 Main이 소유하는 CaseRuntimeState에 있습니다.
이력 조회를 다른 UI/로직에 연결하는 작업은 다음 단계의 요구사항이 정해졌을 때 추가합니다.
현재 Research Log는 MONITORING을 제외한 8개 Stage에서 열람하는 읽기 전용 파생 표시입니다. 현재 Stage와 Runtime 확정 여부로 후속 정보를 차단합니다. 진행률·영구 기록은 없으며 테스트 limit 2는 최종 게임 밸런스가 아닙니다.
Containment 확장은 `containment_view.gd`의 선택 처리에서 시작할 수 있습니다.
확정 ID 조회와 현재 Resource → Main → View.setup 경계에서 다음 요구사항을 확장할 수 있습니다.
Monitoring 확장은 MonitoringStageData/MonitoringOutcomeData와 MonitoringView.setup 및 재생 완료 경계에서 시작할 수 있습니다.
다음 단계 요구사항이 정해지면 이 경계에만 필요한 동작을 추가합니다. Stage 재생 완료와 Runtime 결과 확정은 별개이며 이후 Route는 Main._get_next_stage()에서 결정합니다. Incident 표시 확장은 IncidentData → Main의 ID 검색 → IncidentView.setup() 경계에서 시작할 수 있습니다. Broadcast 확장은 EmergencyBroadcastData/OptionData → Main의 ID 검색 → BroadcastView.setup() / confirmation signal → Runtime ID 쌍 경계에서 시작합니다. 피해/점수와 이벤트 트리거 등은 다음 요구사항이 있을 때 추가합니다.

Broadcast Option 선택은 View 내부의 임시 상태이며, 현재 단계에서는 명시적 확정과 Runtime ID 쌍 기록이 Next의 필수 조건입니다. 다음 단계에서는 두 확정 ID와 현재 Case의 Resource 조회 경계에서 요구된 기능만 추가할 수 있습니다.

Incident Result 표시는 BroadcastOptionData.result_id → Main의 ID 검색 → IncidentResultView.setup() 경계에서 확장할 수 있습니다. 별도의 Runtime Result 상태 없이 기존 확정 쌍에서 파생합니다.
Case Result 표시는 기존 Runtime 조회 → Main._build_result_summary() → ResultView.setup(Summary) 경계에서 확장할 수 있습니다. 현재는 읽기 전용 표시이며, 저장 결과/다음 Case/피해·점수 요구사항은 구현하지 않았습니다.
Research Log 표시는 Main._build_research_log_snapshot() → ResearchLogView.setup(Snapshot) 경계에서 확장할 수 있습니다. 작성 문구는 현재 CaseData.research_entries의 ResearchEntryData를 kind+source_id로 연결해 추가할 수 있으며, MONITORING 중 열람이 필요해지면 Timer 정책을 먼저 정합니다. 영구/다중 Case 기록은 별도 요구가 있을 때 설계합니다.


## Step48 — Meaningful Research / Read Boundary Pacing Gate

기존 readiness threshold/count/RNG와 Step47 oldest actionable 순서를 유지하고, 실제 interruption 뒤 새 연구 완료와 자발적인 읽기 경계를 요구하는 Main-local shared gate를 적용했습니다.
CCTV/EXP는 실제 내용을 먼저 표시하고 기존 Next에서만 고유 credit을 승인합니다. CONT Confirm은 credit만 승인하고 Event는 enabled Next에서 검사합니다. Dismiss/Resume/Log/Archive/Recheck/중복 입력은 credit이 아닙니다.
Runtime 교체/reset에도 session token을 보존하며 stale Runtime View는 승인하지 않습니다. 마지막 Case03은 기존 Outcome0/Pending/Next disabled로 유지합니다.

동일144 Journey에서 credited-progress-between 최소1/zero0, opportunity와 기존 meaningful 각각1296 유지, interruption301→247을 확인했습니다. final unresolved는85→128로 늘었고 종료 처리로 숨기지 않았습니다.
최종318개 검증 프로세스는 historical core268개(과거 checkpoint 호환 fixture)와 실제 Step48 제품 검사50개를 구분했습니다. Godot4.7.1 import/지정 Main/headless/GPU3해상도와 Snapshot/ordering 검사를 통과했습니다.
F44-01/F44-02는 RESOLVED, F01은 OPEN, F07-B는 PARTIALLY ADDRESSED입니다. double-Next/Resume/Next-event 공식과 실제 피로도는 사람 테스트가 필요합니다.

변경 파일·metric·검증 범위·192개 응답은 [Step48 보고서](docs/step48_meaningful_research_pacing_gate.md)에 있습니다. 기존 Step46/47 미커밋 작업을 보존했고, 커밋/푸시는 하지 않았습니다.


## Step49 — Major Predictability / Threshold Audit

제품 Major1/Disturbance2~4, Step47 ordering, Step48 gate와 UI를 그대로 유지한 Audit입니다.
CURRENT1/Fixed2/Range1~2/Range2~3 및 참고 Fixed3의 같은144 Journey를 비교하고, 범위형 두 추가 seed family까지 총1296 matrix Journey를 새로 실행했습니다.
기본 CURRENT D159/M88/잔여128은 Step48와 일치했습니다. 비교 모델의 M/잔여는 Fixed2 86/130, Range1~2 87/129, Range2~3 80/136, Fixed3 61/155입니다.
전정책 사건 사이 credit 최소1/zero0을 유지했습니다. Range1~2는 readiness variation을 만들지만 세 seed family에서 Stage 집중·행동량 조작을 개선하지 못해 KEEP_MAJOR_1과 명시적 final disposition 책임 설계 우선을 추천합니다.
대안 threshold는 제품에 적용하지 않았습니다. 인증204프로세스는 CURRENT73/Simulation130/controlled1을 구분하며, 제품40Script 검사와 Snapshot/ordering/gate/headless/native/GPU3해상도 핵심 회귀를 새로 수행했습니다.
상세 표·seed sensitivity·한계·174개 답변은 [Step49 보고서](docs/step49_major_predictability_threshold_audit.md)에 있습니다. 기존 Step39 미커밋 편집을 보존했고, 커밋/푸시는 하지 않았습니다.

## Step50 — Final Run Disposition Responsibility Contract

**DESIGN ONLY · NOT IMPLEMENTED.** [Step50 책임 계약](docs/step50_final_run_disposition_responsibility_contract.md)에 Run/Case assignment identity, Pending 선행 판정, 전체 수락 시 ownership 이전, Run별 idempotent commit 및 실패/receipt retry 규칙을 정리했다.

- voluntary는 현재 Active Response만 정상 완료하고, forced는 승인/노출 사실을 보존한 interrupted record로 인수한다. 미처리 후보 강제 drain/미발견 Research 해금은 하지 않는다.
- F07-B는 PARTIALLY ADDRESSED 유지; DESIGN CONTRACT COMPLETE는 실제 Run End/Settlement 구현이나 RESOLVED 판정이 아니다. Major1/기존 pacing·ordering·UI·프로젝트 설정은 보존했다.
- 다음 추천은 Step51의 작은 in-memory Record/ownership State다. 이번 제품 코드 변경0, 기존 Step39/Step49 변경 보존, commit/push 없음.

## Step51 — In-Memory Run Disposition Record + Ownership State

**in-memory recipient implemented / actual closure not implemented.** 독립 `RunDispositionRecord`와 `RunDispositionState`를 추가했습니다. 전체 primitive Record를 수락한 뒤 Run ID 하나에 결과·receipt를 함께 저장합니다. 같은 결과는 기존 receipt를 반환하고, boundary/payload 충돌과 duplicate typed identity는 거절합니다.

- Main·기존 Gameplay State·Snapshot과 연결하지 않았으며 실제 Run 종료/판정/conversion/cleanup은 없습니다. 입력·출력·State-owned 복사를 분리했고 F07-B는 PARTIALLY ADDRESSED입니다.
- Godot4.7.1 최종52실행: 제품42Script 검사/import/Main headless·native/독립274검사와 기존 Snapshot·ordering·gate smoke 포함3,678검사 통과. 예상 invalid-content warning4 외 정상warning0/runtime·parse error0입니다.
- 파일·API·schema·계약대응·174개 답변은 [Step51 보고서](docs/step51_run_disposition_ownership_state.md)에 있습니다. 기존 Step39/49/50 변경과 설정을 보존했고, 커밋/푸시는 하지 않았습니다.


## Step52 — Developer Closure API + Live State Preparation

**DEVELOPER CLOSURE API ONLY**

**NO PLAYER RUN END / NO SETTLEMENT**

`Main.configure_developer_run_identity(run_id, assignments)`로 caller의 고정 identity를 바인딩하고,
`Main.developer_commit_run_disposition(boundary_type, recipient)`를 명시 호출하여 live State의 valid Pending을 먼저 판정한 뒤 Step51 recipient에 primitive final Record/receipt를 인수한다. Active Response는 voluntary/forced 모두 차단한다.

동일 요청·post-resolution retry는 재판정/재추첨 없이 기존 사실과 receipt를 사용한다. 일반 플레이 자동 호출, player 종료 UI, source freeze/cleanup, Settlement는 없다. Godot4.7.1 최종56 processes/5694 assertions 통과; 설정·Scene·Resource·기존State/Snapshot 보존. F07-B는 PARTIALLY ADDRESSED다.

[Step52 통합 보고서: 정책·변경·검증·210항목](docs/step52_developer_closure_integration.md)


## Step53 — Active Response Run-End Integration + Terminal Source Freeze

**DEVELOPER RUN-END INTEGRATION ONLY**

**NO PLAYER RUN END / NO SETTLEMENT / NO SOURCE CLEANUP**

Step52의 Active 차단 정책을 확장했다. final boundary의 voluntary 요청은 현재 Response의 정상 completion만 허용하고 Resume 이후 explicit commit retry를 기다린다. forced 요청은 source를 진행시키지 않고 matching EVENT 하나를 INTERRUPTED_RESPONSE로 recipient에 인수한다. accepted intent/commit/error 이후 정상 source callbacks를 동결한다.

Main-local intent/receipt proof는 결과 authority가 아니며 final Record/receipt의 owner는 caller-owned recipient다. forced source Response는 ACTIVE historical copy로 남을 수 있고 Step46 Snapshot과 final disposition은 역할이 다르다. 기존 정상 여정/설정/State/Record/Scene/Research 내용은 유지했다.

Godot4.7.1 최종58 processes/7056 assertions 통과. 정상warning0, controlled invalid-fixture warning21, parse/runtime error0. F07-B는 PARTIALLY ADDRESSED: ACTIVE TERMINATION + TERMINAL FREEZE INTEGRATED / SOURCE CLEANUP + PLAYER RUN LIFECYCLE NOT IMPLEMENTED.

[Step53 보고서: 변경·제한·검증·230항목](docs/step53_active_termination_and_terminal_freeze.md)

Step54 추천은 verified receipt 기반 cleanup/reset + no-run/next-run boundary다. Settlement는 별도 단계 가능하다. 이번 작업은 stage/commit/push를 하지 않았다.


## Step54 — Verified Source Cleanup + Terminal No-Run Boundary

**DEVELOPER CLEANUP / NO-RUN BOUNDARY ONLY**

**NO PLAYER RUN END / NO SETTLEMENT / NO NEW RUN START**

`Main.developer_cleanup_committed_run(recipient)`는 Step53의 COMMITTED_FROZEN에서 bound recipient의 Run ID/receipt/Record/boundary를 재검증한 뒤 source State를 reset하고 Case/Runtime/View 참조를 해제한다. commit 성공 직후 자동 cleanup하지 않는다. 같은 cleanup은 ALREADY_CLEANED이며 recipient Record/receipt는 그대로 보존한다.

cleanup 이후 Main은 CLEANED_NO_RUN이다. 과거 callback은 source를 재생성할 수 없고 동일 Main에 새 Run configure/closure prepare는 거절한다. authored case_sequence/Scene/Resource/설정은 유지한다. WorkingHypothesis에 whole-session reset만 추가했고 기존 clear_all의 ID 정책은 보존했다.

Godot4.7.1 최종60 processes/9338 assertions 통과. 정상warning0, controlled invalid-fixture warning21, parse/runtime error0. F07-B는 PARTIALLY ADDRESSED: SOURCE OWNERSHIP RELEASE + NO-RUN BOUNDARY INTEGRATED / PLAYER RUN LIFECYCLE NOT IMPLEMENTED.

[Step54 보고서: API·cleanup 정책·제한·검증·215항목](docs/step54_verified_source_cleanup_no_run_boundary.md)

Step53 Active+resolvable Pending P2는 그대로 유지한다. 다음 추천은 명시적 no-run→new-run initializer 계약이며 이번에는 새 Run/Player 종료/Settlement/경제/Save를 구현하지 않았다. stage/commit/push도 하지 않았다.
