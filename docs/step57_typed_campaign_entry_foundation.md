# Step57 — Typed Campaign Entry Foundation + Existing 3-Case Migration

2026-10-07 · **TYPED CAMPAIGN ENTRY FOUNDATION / CASE ENTRIES ONLY**.

TEST_CAMPAIGN_01의 Case01→Case02→Case03을 stable `entry_id`를 가진 세 CASE entry로 이관했다. CampaignData.entries가 유일한 authored sequence이고, Main은 전체 검증 후 기존 gameplay용 Case 배열을 별도로 만든다. UI·판정·기존 Runtime State·developer 종료 계약은 유지했다. **NO STORY EVENT EXECUTION / NO ECONOMY / QUOTA / SETTLEMENT**.

## 1. Source of Truth / 작업 전 조사

현재 사용자 지시→기획/실행계획→실제 Repo→Step56 설계→Step55 구현→이전 보고 순으로 판단했다. 실제 Story와 Mandatory/Final/Ending 콘텐츠는 미확정이다. 이 리소스는 TEST Campaign이며 정식 스토리 확정본이 아니다. RunDisposition/developer_run은 기존 내부 lifecycle 이름으로 유지한다.

시작 HEAD `6e8f167f699a3a95c91fee8668ae99d03e5d4db9`, local `master`→`origin/main`, staged0. 기존 변경은 README/Main/main.tscn의 modified3과 Step55 report·Step56 report·Campaign .tres·CampaignData/.uid의 untracked5였다. 비생성132파일, 제품 GDScript44/Scene15/Resource4를 조사했다. 저장소/상위 AGENTS.md는 없었다.

기존 CampaignData는 `campaign_id`, `display_name`, `case_sequence: Array[CaseData]`와 read-only validator를 가졌다. Main은 검증 후 detached Case 배열을 생성했다. configured Main Scene에는 Campaign 하나만 연결되고 direct Case는 없었다. 기존 .tres subresource/typed Array convention에 맞춰 entry를 Campaign 안에 포함했다. 별도 entry .tres3개는 만들지 않았다.

Main startup/current_case/_case_index/Runtime 초기화, `_has_unique_case_sequence`, handoff/no-next, Snapshot, assignment mapping, closure/active termination/cleanup/CLEANED_NO_RUN과 복사할 fixture의 주입 지점을 확인했다. `.godot/verification/step57/baseline.json`은 기존 파일 및 Step55·56 증거592파일 SHA-256을 저장한다. 과거 증거는 수정하지 않았다.

## 2. Identity / authored-runtime 계약

| identity | 의미 | 현재 소유 / 사용 | 다른 identity와 관계 |
| --- | --- | --- | --- |
| campaign_id | authored Campaign 정의 | CampaignData, TEST_CAMPAIGN_01 | Run ID가 아니다 |
| entry_id | Campaign 안의 stable occurrence | CampaignEntryData, Campaign 내 unique | 배열 index나 case_id에서 runtime 생성하지 않는다 |
| case_id | Case 콘텐츠 정의 | CaseData 및 현재 Runtime State keys | 아직 assignment key처럼 사용하므로 반복 Case 거절 |
| developer run_instance_id | caller의 technical lifecycle | 기존 Step52 context/recipient | Campaign/entry ID로 강제 대체하지 않는다 |

| 대상 | authored / runtime | 책임 | 변경 허용 계약 |
| --- | --- | --- | --- |
| CampaignData | authored Resource | ID/name/entries 순서, 전체 검증 | editor authoring만; runtime mutation 없음 |
| CampaignEntryData | authored concrete Resource | occurrence ID/CASE kind/typed CaseData | editor authoring만; validator read-only |
| CaseData | authored Resource | 기존 Case 콘텐츠 | 기존 참조 공유, gameplay read-only |
| Main.case_sequence | runtime derived Array | 기존 navigation/API compatibility projection | 배열 자체는 entries와 alias하지 않음 |
| CaseRuntimeState | current Case runtime | 실험/관찰/확정/환경 조건 | handoff 시 새 instance, 기존 계약 유지 |

`CampaignEntryData`는 `class_name CampaignEntryData`, `extends Resource`이며 enum `EntryKind { CASE }` 하나만 정의했다. exported field는 `entry_id: String`, `entry_kind: EntryKind`, `case_data: CaseData` 세 개다. BaseClass/subclass hierarchy, future kind/nullable Event payload/condition/flag/effect 필드는 없다. exported authored field는 editor에서 편집 가능하며 물리적 immutable Resource를 만드는 framework는 추가하지 않았다. public runtime mutation method는 없다.

## 3. Migration / 파일 변경

| 항목 | Before | After |
| --- | --- | --- |
| authored sequence | CampaignData.case_sequence[CaseData] | CampaignData.entries[CampaignEntryData] |
| Main compatibility | Campaign Case Array duplicate | 검증된 entries를 순회하여 별도 case_sequence에 CaseData append |
| current identity | _case_index + current_case | 동일; corresponding entry는 validated entries[_case_index]로 조회 가능 |
| 기존 State keys | case_id | 동일, entry occurrence-aware migration 없음 |

별도 current_entry field/helper/ProgressState는 만들지 않았다. 현재 CASE-only mapping은 `_case_index`와 validated entries로 검사할 수 있어 새 authority/API가 필요하지 않다. projection을 조작하는 developer probe는 authored sequence를 변경하지 않는다. mixed dispatch는 아직 없다.

| entry_id | kind | 실제 definition / reference |
| --- | --- | --- |
| TEST_ENTRY_CASE_01 | CASE=0 | TEST_CASE_01 / resources/cases/test_case_01.tres |
| TEST_ENTRY_CASE_02 | CASE=0 | TEST_CASE_02 / resources/cases/test_case_02.tres |
| TEST_ENTRY_CASE_03 | CASE=0 | TEST_CASE_03 / resources/cases/test_case_03.tres |

정확히3 entry, authored 순서01→02→03. 각 ID는 .tres에 명시 저장했다. Story placeholder/Entry04는 없다. Case03 Outcome0와 No next test case configured/disabled Next를 보존한다. 마지막 entry를 Campaign completion/Ending으로 처리하지 않는다.

| Step57 파일 | 변경 / 이유 |
| --- | --- |
| scripts/data/campaign_entry_data.gd | 신규, 세 authored fields 및 entry validation |
| scripts/data/campaign_entry_data.gd.uid | 신규, fresh Godot editor import가 생성한 uid://c85r3d4jwx84f |
| scripts/data/campaign_data.gd | 기존 Step55 파일 최소 수정: entries 및 nested/duplicate 검증 |
| resources/campaigns/test_campaign_01.tres | 기존 Step55 파일 수정: 세 entry subresource, 기존 Case links 그대로 |
| scripts/main/main.gd | _ready의 projection 생성2행과 설명 comment만 변경; 전체2099→2100행/111→111함수 |
| README.md | 기존 bytes 그대로 두고 Step57 요약 append |
| docs/step57_typed_campaign_entry_foundation.md | 신규 본 보고서 및166개 답변 |

Step57 신규3파일/수정4파일/삭제0. 제품 Script 신규1+Godot UID1, 기존 Script 수정2, Resource 파일 신규0/수정1(내부 subresource3), Scene 수정0. 기존 main.tscn의 Step55 미커밋 변경도 byte 그대로 보존했다. Step55·56 보고서 및 모든 기존 State/UID/Case 리소스와 프로젝트 설정은 그대로다.

## 4. 검증 실패 / 정상 startup 계약

Entry.get_validation_error(): whitespace-only entry_id, unsupported kind, CASE null payload, blank Case ID를 거절한다. Campaign validator는 blank Campaign ID/empty entries/null entry, 모든 nested entry, duplicate entry ID와 duplicate Case ID를 검사한다. index 및 가능한 entry ID를 포함한 진단을 제공한다. 검증은 Resource를 변경하지 않는다.

Campaign 전체 검증이 완료되기 전 CaseRuntime/session State/View를 생성하지 않는다. invalid entry2/entry3 때문에 entry1을 부분 시작하지 않는다. invalid Campaign은 기존 direct current_case/sequence를 주입해도 명시 push_error 후 초기화를 중단한다. error View나 legacy case_sequence fallback은 없다.

정상: Campaign validation→entry validation→CASE projection→index0/current_case→fresh Runtime/기존 session States→PROFILE. Main에 schema validator를 복제하지 않았다. `_has_unique_case_sequence`와 모든 기존 handoff/prepare/return/terminal 함수는 Step57 전과 동일하다.

## 5. 새 Godot 4.7.1 실행 결과

실제 실행 binary: `Godot_v4.7.1-stable_win64_console.exe`, version `4.7.1.stable.official.a13da4feb`. Windows OpenGL Compatibility / AMD Radeon RX6800. 이전 Step55 수치는 재사용하지 않았다.

| 검증 | 최종 새 실행 / assertion | 결과 |
| --- | --- | --- |
| fresh editor import |1 process | PASS, UID 자동 생성 |
| 제품 전체 --check-only |45 processes | PASS |
| configured Main headless/native |2 processes | PASS, 실제 project Main 사용 |
| Campaign 정상 headless/native |150/156 | PASS, 3/2/1길이·reorder·alias·cleanup |
| controlled invalid Campaign |122 | PASS,13종, partial startup0 |
| Step46 Snapshot normal/phases/response/isolation |199/219/192/81 | PASS |
| Step47 oldest actionable |1569 | PASS |
| Step48 meaningful/read gate |1144 | PASS, D2~4/M1 보존 |
| Step51 ownership |274 | PASS |
| Step52 closure |460 | PASS |
| actual button A/B + closure headless/native |745/758 | PASS |
| Step53 active termination headless/native |708/719 | PASS |
| Step54 cleanup headless/native |1130/1152 | PASS |

최종 채택 검증 세트 **65개 Godot processes /9,778 assertions**. 정상 warning0/runtime exception0/parse error0. controlled 기존 negative 경로 warning21과 invalid Campaign의 예상 developer diagnostics13은 정상 실행과 분리했다. 정상 제품 에러로 오인하지 않는다.

총 verification invocation은74(성공73/fixture pilot 실패1)였다. 최종65세트 밖의8개 재검사는 legacy dependency 주입 이관/추가 property 보존 assertion 후 수행한 smoke6+Journey2이다. 중복 assertion은 최종 합계에 다시 더하지 않았다. --version 조회는 검증 process 집계에서 제외했다. `.godot/verification/step57/certification.json`에 개별 로그/시간/검사 수를 기록한다.

## 6. Fixture / UI / authored preservation 증거

13 invalid 종류: null Campaign, blank campaign_id, empty entries, null entry, blank entry ID, 동일 entry object 중복, clone duplicate entry ID, unsupported kind99, CASE null payload, blank Case ID, 동일 Case에 다른 entry IDs, clone Case의 같은 case_id, 마지막 Case ID blank. 각 invalid Resource tree를 validation/startup 전후 비교하고 Runtime/6 session State/View 없음, index-1, empty projection, invalid Snapshot 및 assignment 거절을 확인했다.

Normal fixtures는01→02→03,02→01→03,01→02,03 하나를 명시 typed Campaign으로 주입한다. 실제 버튼으로 PROFILE/CCTV/EXPERIMENT/CONTAINMENT/Confirm/Next를 진행하고 각 Case의 fresh Runtime, corresponding entry/reference/index, 한 View, 마지막 no-next와 idle 상태 불변을 검사했다. Main projection을 pop/reverse해도 Campaign/entry/Case tree가 바뀌지 않는다.

A/B Journey는 기존 실제 콘텐츠 및 deterministic 기존 failure pacing을 사용했다. A 정상 연구/격리 handoff, B 과거 Failure→Disturbance→Major→Incident→Broadcast→Result→Resume 이후Case03를 확인했다. Research Log/Archive, Source Archive 왕복·draft, Working Hypothesis와 snapshot/closure/termination/cleanup 회귀를 포함한다. authored tree/Resource identity는 startup·handoff·전체 failure journey·closure·cleanup 전후 동일하다.

이전 검증 자료를 덮어쓰지 않고 `.godot/verification/step57/`의 복사본만 이관했다. 실행 대상 Campaign injection과 ancestor의 legacy startup injection40곳도 typed Campaign으로 변경했다. startup 이후 projection/State 변조는 기존 방어 검증 목적의 runtime probe로 남겼다. archival dependency의 과거 gameplay assertion 전체를 별도로 재인증했다고 주장하지 않는다. 이번 필수 Step46~55와 A/B 실행 결과만 새 결과로 집계했다.

GPU 대표1280×720 capture를 직접 열어 Case01 PROFILE/CCTV 및 Case01→02 handoff 후 PROFILE/CCTV에서 정상 텍스트/버튼 배치를 확인했다. 대표 화면은 controlled success routing fixture이며 실제 authored A/B 여정은 별도 native 검사로 통과했다. logical1920×1080/single View/layout assertion도 통과했다. UI 변경이 없어3해상도 전체 재검사는 하지 않았다. project.godot/settings/layout/Scene bytes 동일.

증거: `campaign-headless.json`, `campaign-Windows.json`, `campaign-invalid.json`, `closure-journeys-headless.json`, `closure-journeys-Windows.json`, 각 run log 및 `02_entry_0_cctv.png`, `03_entry_1_profile.png`, `04_entry_1_cctv.png`(모두 .godot/verification/step57 아래).

## 7. 발견 사항 / P0–P3 / 변경 보호

Pilot invalid fixture에서 `Campaign.duplicate(true)`가 외부 Case 참조까지 자동 격리하지 않아 후속 fixture의 invalid 원인이 섞였다. 복사한 entry마다 CaseData를 명시 duplicate하고 원본 Campaign 전체 property tree 불변 assertion을 추가해 해결했다. 제품 코드는 이 문제로 수정하지 않았다. 실패 로그는 pilot-invalid.log에 보존하고 최종 새 실행 결과와 분리했다.

신규 미해결 제품 P0/P1/P2/P3는 발견하지 않았다. 기존 Step53 Active+resolvable/same-room residue Pending의 OPEN P2와 `ACTIVE_FORCE_REQUIRES_PREPARED_PENDING`/error freeze는 유지했다. 기존 Step54 cleanup은 cross-State transaction/general exception rollback이 아니며 partial reset 후 frozen same-recipient explicit retry 한계도 유지했다. 기존 Hypothesis key enumeration/getter seam 및 Main 규모의 P3를 해결하는 refactor는 하지 않았다.

Git/hash 검사는 이번 delta와 누적 Step55·56 변경을 구분한다. 기존132파일 중 의도된 변경은 Main/CampaignData/Campaign .tres/README 네 개뿐이고 나머지128파일 hash는 동일하다. README의 기존434357바이트 prefix 동일. Step55·56 evidence592파일 동일. HEAD/branch/upstream/index 그대로, stage/commit/push0, deleted0, git diff --check PASS. 최종 증거는 final-integrity.json.

## 8. 아직 없는 기능 / 다음 단계

Story/Event execution, EventData/StoryEventData/ScriptedIncidentData/Mandatory/Final/Ending, Case04, CampaignProgressState/current_entry State/완료 marker, Manager/Singleton/Autoload, flags/blackboard/conditions, runtime history/CaseResult, Save/Load, 경제/Credit/Quota/Settlement는 추가하지 않았다. 기존 `_event_presentation_credit` boolean은 사건 표시 pacing이며 화폐가 아니다.

entry_id와 case_id는 분리됐지만 Pending/Resolution/Candidate/Response/Archive/Hypothesis는 여전히 case_id 기반이다. duplicate Case를 계속 거절하며 repeated Case 지원 완료 또는 generalized Incident source/Response rekey라고 주장하지 않는다.

Step58은 사용자 승인 범위에서 Scripted Incident의 source model·기존 Response/View/Archive 재사용·완료와 return policy·필요한 최소 progression authority를 구현하기 좋은 지점이다. mixed dispatch는 아직 없으므로 entry kind와 exactly-one payload validation을 그때 실제 새 kind에 맞춰 확장해야 한다. 현재 CASE foundation에는 실제 Story 대사/인물/Ending 자료가 필요하지 않았다. 실제 Mandatory/Final 콘텐츠 구현 전에는 Step56의 Story 목적·위치·사용 정보·판단·변화/Ending 자료가 필요하며 AI가 임의 확정하지 않는다.

## 9. 요청된166개 종료 보고 항목

| 번호 | 항목 | 답변 |
| ---: | --- | --- |
| 1 | 작업 전 Git 상태 | 작업 전 modified3/untracked5, staged0. Step55·56 변경이 있는 상태에서 시작했다. baseline.json의 전체 status를 보존했다. |
| 2 | HEAD | 6e8f167f699a3a95c91fee8668ae99d03e5d4db9. 이번 작업에서도 유지했다. |
| 3 | branch/upstream | local master → origin/main, 변경 없음. |
| 4 | Step55 변경 보호 | Step55의 Campaign 기반을 rollback하지 않았다. CampaignData/.tres/Main만 이번 요구에 맞게 최소 확장했고 main.tscn·Step55 보고서·기존 UID는 byte 동일하다. |
| 5 | Step56 변경 보호 | Step56 report byte 동일, README의 기존 Step56 부분을 포함한 원문 prefix 동일. Step55·56 evidence592파일 동일. |
| 6 | 기존 CampaignData 구조 | 기존 authored campaign_id/display_name/case_sequence:Array[CaseData]와 read-only validator 구조였다. |
| 7 | 새 CampaignEntryData | concrete CampaignEntryData Resource를 추가했다. stable entry_id/CASE kind/typed CaseData와 read-only validation만 가진다. |
| 8 | CampaignEntryData path | scripts/data/campaign_entry_data.gd, Godot 자동 생성 .gd.uid. |
| 9 | CampaignEntryData base type | extends Resource. 추상 BaseClass/상속 계층은 없다. |
| 10 | entry_id | exported String, whitespace-only 거절, .tres에서 명시 작성. index 기반 runtime 생성 없음. |
| 11 | entry_kind | exported EntryKind enum. 현재 CASE만 지원하고 다른 정수 값은 validator에서 거절한다. |
| 12 | CASE kind | EntryKind.CASE=0, enum 정의는 CASE 하나뿐이다. |
| 13 | future kind 추가 여부 | 미래 STORY/MANDATORY/FINAL/ENDING enum/payload는 추가하지 않았다. |
| 14 | case_data | exported CaseData typed reference. CASE entry는 non-null이 필수다. |
| 15 | runtime State 여부 | authored Resource이며 Runtime State가 아니다. |
| 16 | public mutation 여부 | public runtime mutation method 없음. exported field는 authoring 용도로 편집 가능하며 물리적 immutability framework는 없다. runtime mutation0. |
| 17 | validation API | CampaignEntryData.get_validation_error():String 및 기존 CampaignData.get_validation_error() 패턴을 유지했다. |
| 18 | blank entry_id | entry_id.strip_edges().is_empty()이면 INVALID. blank/whitespace fixture 통과. |
| 19 | unsupported kind | CASE 외 kind INVALID. set(entry_kind,99) controlled fixture 통과. |
| 20 | null Case | CASE null CaseData payload INVALID, index/entry ID diagnostic 포함. |
| 21 | blank case_id | case_data.case_id blank/whitespace INVALID. 마지막 entry invalid도 시작 전에 거절한다. |
| 22 | CampaignData.entries | @export var entries:Array[CampaignEntryData]. 유일한 authored sequence이다. |
| 23 | old CampaignData.case_sequence 제거 | CampaignData의 exported case_sequence 필드와 제품 .tres 저장 필드를 제거했다. |
| 24 | two authored source 여부 | 두 authored source 없음. Main.case_sequence는 runtime derived Array다. |
| 25 | silent fallback 여부 | legacy case_sequence fallback 없음. invalid/empty entries는 명시 오류 후 초기화 중단. |
| 26 | CampaignData validation | campaign_id/entries/null entry/nested validation/duplicate entry ID/duplicate Case ID의 전체 검증 후 시작한다. |
| 27 | duplicate entry_id | 동일 object/clone의 같은 entry_id 모두 INVALID. 진단에 index와 ID 포함. |
| 28 | duplicate case_id | 현재 duplicate case_id도 INVALID. 서로 다른 entry IDs 또는 Case clone이어도 거절한다. |
| 29 | repeated Case 지원 여부 | 지원하지 않는다. State key migration과 assignment occurrence 분리는 이번 범위가 아니다. |
| 30 | TEST_CAMPAIGN migration | resources/campaigns/test_campaign_01.tres 안에 CASE subresource3개를 명시 이관했다. |
| 31 | Entry01 ID | TEST_ENTRY_CASE_01. .tres에 stable authored 문자열로 저장. |
| 32 | Entry02 ID | TEST_ENTRY_CASE_02. .tres에 stable authored 문자열로 저장. |
| 33 | Entry03 ID | TEST_ENTRY_CASE_03. .tres에 stable authored 문자열로 저장. |
| 34 | Case01 definition | TEST_CASE_01 / 기존 resources/cases/test_case_01.tres 참조 동일. |
| 35 | Case02 definition | TEST_CASE_02 / 기존 resources/cases/test_case_02.tres 참조 동일. |
| 36 | Case03 definition | TEST_CASE_03 / 기존 resources/cases/test_case_03.tres 참조 동일. Outcome0 유지. |
| 37 | exact authored order | entries 순서 TEST_ENTRY_CASE_01→02→03, payload Case01→02→03. 실제 reference/entry ID 검사 통과. |
| 38 | placeholder Story entry 여부 | Story/TODO/Entry04 placeholder0. |
| 39 | Campaign length | 현재 제품 Campaign 정확히3 CASE entries. |
| 40 | Main Campaign injection | Main의 exported campaign_data 주입 유지. main.tscn은 TEST_CAMPAIGN_01 하나만 연결한다. |
| 41 | Main Scene direct Case 여부 | main.tscn direct Case resource0. Scene 파일 byte 동일. |
| 42 | Main Script direct Case preload | Main에 direct authored Case preload0, fallback0. |
| 43 | Main derived case_sequence | Main.case_sequence:Array[CaseData]를 기존 API/navigation compatibility projection으로 유지했다. |
| 44 | projection construction | 전체 Campaign validator 성공 후 entries를 순회해 각 entry.case_data를 detached Array에 append한다. |
| 45 | projection alias isolation | pop_back/reverse한 Main Array가 Campaign/Entry/Case property tree를 변경하지 않음. Array alias isolation 통과. |
| 46 | Campaign entry mutation | 제품 runtime의 Campaign entry pop/remove/reorder/field mutation0. property tree/identity 보존 검사 통과. |
| 47 | CaseData mutation | CaseData gameplay mutation0. 기존3 .tres SHA 동일 및 nested tree preservation 통과. |
| 48 | current_case | 기존 current_case는 derived projection[index]의 동일 authored reference. startup Case01, handoff 다음 Case. |
| 49 | _case_index | 기존 _case_index 사용: 정상0→1→2, invalid/cleanup -1. 별도 current entry authority 없음. |
| 50 | Runtime | 기존 CaseRuntimeState, 각 handoff에서 fresh instance. 새 Campaign State 없음. |
| 51 | PROFILE | configured Main은 Case01 PROFILE에서 시작. single View/native capture/actual journey 통과. |
| 52 | Profile→CCTV | 기존 버튼 signal→Main routing 유지. headless/native 실제 button journey와 GPU 화면 확인. |
| 53 | Experiment | 기존 선택/승인/실험 제한/실행 이력/조건 관찰 유지. View/Runtime bytes 동일, A/B journey 통과. |
| 54 | Containment | 기존 Room 선택/Confirm/Pending/잠금/Next 유지. 정상/invalid/final fixture 통과. |
| 55 | hidden resolution | 기존 hidden resolution/prepare/RNG 함수 동일. SUCCESS/FAILURE 및 final UNKNOWN 계약 회귀 통과. |
| 56 | Case01→02 | 실제 A/B 및 controlled fixture Case01→02 handoff 통과, fresh Runtime/Archive merge/PROFILE 유지. |
| 57 | Case02→03 | 실제 A/B 및 controlled fixture Case02→03 handoff 통과, 기존 deferred candidate/response 계약 유지. |
| 58 | Case03 behavior | 제품 Case03 Outcome0 유지. Confirm 후 final Pending 가능, 자동 판정/Story/Ending 없음. |
| 59 | no-next | 마지막 Case는 No next test case configured/Next disabled. idle/stale callback 보존 검사 통과. |
| 60 | Campaign complete 여부 | Campaign complete marker/처리 추가0. 마지막 entry를 완료로 꾸미지 않는다. |
| 61 | Ending 여부 | Ending 구현/자동 호출0. |
| 62 | Story Event 실행 여부 | Story Event 실행0, mixed dispatch 없음. |
| 63 | Scripted Incident 여부 | Scripted Incident Data/실행0. 기존 failure/debug response만 유지. |
| 64 | CampaignProgressState 여부 | CampaignProgressState 추가0. |
| 65 | current entry runtime State 여부 | 별도 current_entry field/State0. validated entries[_case_index]로 mapping 확인 가능해 helper도 추가하지 않았다. |
| 66 | entry completion marker 여부 | entry completion marker/completed_entry State0. |
| 67 | CampaignManager 여부 | CampaignManager0. |
| 68 | EventManager 여부 | EventManager0. |
| 69 | Singleton/Autoload | Singleton/Autoload 추가0. project.godot byte 동일. |
| 70 | flags | Story/Campaign flags/blackboard0. |
| 71 | Save | Save/Load0. |
| 72 | CaseResult | CaseResult/history State 추가0. |
| 73 | repeated Case | 반복 Case 지원0. duplicate Case는 계속 거절한다. |
| 74 | generalized source | generalized Incident source0. 기존 source_case_id 기반. |
| 75 | Response key 변경 여부 | Response key [source_case_id,incident_id] 동일, State byte 동일. |
| 76 | Archive key 변경 여부 | Archive case_id/research entry scope 동일, rekey0. |
| 77 | Pending key 변경 여부 | Pending case_id key 동일, State byte 동일. |
| 78 | Resolution key 변경 여부 | Resolution case_id key 동일, State byte 동일. |
| 79 | Candidate key 변경 여부 | Candidate case_id key/ordering 동일, State byte 동일. |
| 80 | Hypothesis key 변경 여부 | Hypothesis case_id key 동일, State byte 동일. |
| 81 | Campaign ID 의미 | campaign_id는 authored Campaign 정의 ID이며 caller lifecycle Run ID가 아니다. |
| 82 | Entry ID 의미 | entry_id는 Campaign 안의 stable authored occurrence ID이며 array index가 아니다. |
| 83 | Case ID 의미 | case_id는 CaseData 콘텐츠 정의 ID. 현재 States는 assignment key처럼 사용한다. |
| 84 | developer Run ID 의미 | developer Run ID는 기존 caller technical lifecycle identity. rename0/경제0. |
| 85 | four identity separation | Campaign/entry/Case/developer Run은 의미와 owner가 다르다. entry_id를 assignment/Response key에 강제 적용하지 않았다. |
| 86 | developer assignment mapping | configure_developer_run_identity는 derived case_sequence를 그대로 사용한다.3 Case mapping/중복/누락 검증과 caller ID 계약 회귀 통과. |
| 87 | Snapshot 변경 | Step46 Snapshot schema/Script/Builder 변경0.199/219/192/81 assertions 및 no-run observation 통과. |
| 88 | Ordering 변경 | Step47 oldest actionable ordering 함수 byte 동일.1569 assertions 통과. |
| 89 | Pacing 변경 | Step48 meaningful/read gate/credit/opportunity byte 동일.1144 assertions 통과. |
| 90 | threshold | PROTOTYPE_DISTURBANCE_THRESHOLD=Vector2i(2,4), PROTOTYPE_MAJOR_THRESHOLD=1 유지. 새 numeric priority/Severity0. |
| 91 | closure | Step52 closure 함수/State/Builder 동일.460 assertions 및 A/B closure 통과. |
| 92 | active termination | Step53 active voluntary/forced/freeze/retry/stale response/source 계약 동일.708/719 assertions 통과. |
| 93 | cleanup | Step54 verified recipient/source cleanup/reentrant/partial retry 동일.1130/1152 assertions 통과. |
| 94 | CLEANED_NO_RUN | cleanup 후 index-1/current_case null/Runtime null/empty projection/blocked routing/no auto new Run 유지. |
| 95 | invalid null Campaign | null Campaign 명시 오류, runtime direct injection 시도도 초기화 우회 불가. partial State/View0. |
| 96 | invalid blank campaign_id | blank/whitespace campaign_id INVALID, authored tree 불변. |
| 97 | invalid empty entries | empty entries INVALID. legacy sequence fallback0. |
| 98 | invalid null entry | null entry INVALID. 해당 index diagnostic 및 partial startup0. |
| 99 | invalid blank entry_id | blank/whitespace entry_id INVALID. read-only validation 및 partial startup0. |
| 100 | invalid duplicate entry_id | duplicate entry_id INVALID. 동일 object와 다른 clone의 ID 중복 모두 검사했다. |
| 101 | invalid unsupported kind | unsupported entry_kind99 INVALID. future payload/type를 만들지 않고 안전한 controlled fixture로 검사했다. |
| 102 | invalid CASE null Case | CASE null CaseData INVALID. entry index/ID 포함 diagnostic. |
| 103 | invalid blank Case ID | blank Case ID INVALID. 중간 entry 및 마지막 entry 검사. |
| 104 | invalid duplicate Case ID | duplicate Case ID INVALID. entry IDs가 달라도 현재 assignment key 충돌 때문에 거절. |
| 105 | identical entry object duplicate | 동일 entry Resource 두 번 사용 INVALID. duplicate entry ID diagnostic 통과. |
| 106 | clone entry duplicate ID | 다른 entry clone이 같은 entry_id이면 INVALID. object identity와 authored identity 구분. |
| 107 | same Case different entry IDs | 동일 CaseData를 서로 다른 entry IDs로 연결하면 INVALID. 반복 Case 지원 아님. |
| 108 | clone Case same case_id | 다른 CaseData clone의 같은 case_id도 INVALID. reference 차이로 key 충돌 우회 불가. |
| 109 | valid order fixture | controlled order01→02→03. 실제 버튼 routing/reference/index/entry/fresh Runtime/single View/no-next 통과. |
| 110 | reordered fixture | controlled02→01→03. Main 수정 없이 entries 순서대로 실제 navigation 통과. |
| 111 | short campaign fixture | controlled2 entries01→02. 정상 handoff 및 마지막 Next disabled 통과. |
| 112 | one-entry fixture | controlled1 entry03. PROFILE 시작/Containment/no-next/idle 불변 통과. |
| 113 | authored mutation fixture | Campaign/Entry/Case storage property+Resource identity를 validation/startup/handoff/failure journey/closure/cleanup 전후 비교. 불변. |
| 114 | projection mutation fixture | Main projection pop_back/reverse 후 Campaign entries와 payload tree 동일. authored 배열과 alias하지 않는다. |
| 115 | actual Journey A | actual authored Journey A + closure: 기존 정상 연구/격리 Case01→02→03와 final unresolved Pending 통과. |
| 116 | actual Journey B | actual Journey B: 과거 Failure→Disturbance→Major→Incident/Broadcast/Result/Resume 및 후속 Case routing 통과. |
| 117 | Research Archive | Research Log/Archive/discovered authored IDs/Source Archive·Back·draft 복귀 회귀 통과. 추가 해금/필터 변경0. |
| 118 | Working Hypothesis | Working Hypothesis note/session lifetime/Archive 왕복/closure/cleanup 회귀 통과. 공식 fact로 전환0. |
| 119 | Step46 regression | Step46 Snapshot normal199/phases219/response192/isolation81. schema bytes 동일. |
| 120 | Step47 regression | Step47 ordering1569. oldest actionable 및 controlled negative 진단 유지. |
| 121 | Step48 regression | Step48 gate1144. 실제 read와 idle/미읽음/연속 사건 제한 계약 유지. |
| 122 | Step51 regression | Step51 ownership274. publish-once/receipt/conflict/source-lifetime 계약 유지. |
| 123 | Step52 regression | Step52 closure460 및 A/B actual closure 통과. assignment ID semantics 동일. |
| 124 | Step53 regression | Step53 active708/headless·719/native. existing P2/error freeze 회귀 유지. |
| 125 | Step54 regression | Step54 cleanup1130/headless·1152/native. verified transfer/no-run/stale/reentrant/retry 통과. |
| 126 | Step55 regression | Step55 data-driven validation/routing/fixture를 entries로 명시 이관. fallback없이3/2/1길이/reorder/invalid13종 통과. |
| 127 | parser | 전체 제품 GDScript45개 fresh Godot --check-only PASS. |
| 128 | editor import | fresh --headless --editor --quit PASS. CampaignEntry UID는 Godot가 자동 생성했다. |
| 129 | Main headless | configured project --headless --quit-after20 PASS. 실제 Main Scene setting 사용. |
| 130 | Main native | configured Windows project --quit-after30 PASS. 대표1280×720/native Compatibility. |
| 131 | GPU smoke | GPU PNG를 직접 열어 Case01 PROFILE/CCTV 및 handoff 후 Case02 PROFILE/CCTV 확인. actual A/B native도 통과. logical1920×1080/layout 보존. |
| 132 | warning | 정상 Campaign warning0. 기존 controlled negative warning21은 별도 집계. |
| 133 | controlled diagnostics | invalid Campaign 예상 명시 developer errors13. Index/가능한 entry ID 진단 확인. fixture assertion failure와 구분. |
| 134 | runtime error | 최종 runtime/GDScript exception0. controlled push_error13은 검증된 developer diagnostic. |
| 135 | parse error | 최종 parse errors0. |
| 136 | process count | 최종 검증 세트65 Godot processes. 실제 verification invocation74=성공73+pilot fixture 실패1; 재검사8은 중복 최종 집계 제외. |
| 137 | assertion count | 최종9778 assertions. certification.json의 각 log count를 합산했으며 Step55 수치는 재사용하지 않았다. |
| 138 | Main before lines | 작업 전 Main2099행. |
| 139 | Main after lines | 작업 후 Main2100행, +1. projection 순회1행 증가와 설명 comment 변경만. |
| 140 | Main before functions | 작업 전111함수. |
| 141 | Main after functions | 작업 후111함수. 변경 함수 _ready 하나, 다른110함수 byte-equivalent text 동일. |
| 142 | new product files | scripts/data/campaign_entry_data.gd 및 Godot 생성 .uid, 제품 파일2개 신규. |
| 143 | modified product files | scripts/data/campaign_data.gd / scripts/main/main.gd 기존 Script2개 수정. Resource 변경은 별도 항목. |
| 144 | new Resources | 새 Resource class script1개, Campaign 안 entry subresource3개. standalone .tres 신규0. |
| 145 | modified Resources | resources/campaigns/test_campaign_01.tres1개 수정. 기존3 Case .tres 변경0. |
| 146 | modified Scenes | Scene 수정0. main.tscn의 기존 Step55 변경과 전체15 Scene bytes 보존. |
| 147 | deleted files | 삭제0. |
| 148 | README | README 기존434357바이트 prefix 보존, Step57 foundation/migrated CASE-only/no Story/no economy 요약 append. |
| 149 | report | docs/step57_typed_campaign_entry_foundation.md 신규. Source of Truth/identity/owner/migration/verification/166답변 포함. |
| 150 | direct Case audit | Main authored Case preload0/Scene direct Case0. 실제 product Campaign만 세 leaf Case link를 가진다. |
| 151 | old field audit | CampaignData 및 Campaign .tres에 authored case_sequence 사용0. 제품 .campaign_data.case_sequence 참조0. Main compatibility Array는 의도적으로 유지. |
| 152 | unused Story symbols audit | 새 Entry/Campaign 제품 schema에 future StoryEventData/EventManager/CampaignFlag/EndingData symbols0. 기존 gameplay enum/debug code는 보존. |
| 153 | authored Resource property preservation | nested authored tree/instance identity 및 원본 product Campaign 불변 assertion 통과. 파일 hash 보호도 별도 통과. |
| 154 | git diff --check | git diff --check PASS. Step57 시작 baseline과 누적 Git diff를 구분해 검사했다. |
| 155 | staged | staged0. index 수정0. |
| 156 | commit/push | stage/commit/push0. HEAD/branch/upstream 유지. |
| 157 | P0 | 이번 구현/최종 회귀에서 발견한 새 미해결 P0 없음. |
| 158 | P1 | 이번 구현/최종 회귀에서 발견한 새 미해결 P1 없음. |
| 159 | P2 | 새 미해결 P2 없음. 기존 Step53 Pending/freeze 및 Step54 cleanup 제한 보존. |
| 160 | P3 | 새 미해결 P3 없음. 기존 Hypothesis getter seam/Main 규모 이슈는 이번 범위에서 refactor하지 않았다. |
| 161 | Step53 existing P2 | 기존 Active+resolvable/same-room residue Pending OPEN P2 및 ACTIVE_FORCE_REQUIRES_PREPARED_PENDING/error freeze 유지. 해결했다고 주장하지 않는다. |
| 162 | Step54 cleanup limitation | Step54 cleanup은 cross-State transaction/general exception rollback 아님. partial reset 후 frozen same-recipient explicit retry 한계 및 회귀 유지. |
| 163 | Step58 readiness | CASE typed authored identity/projection foundation 준비. mixed dispatch/source-aware Response/once completion/progression은 아직 없다. |
| 164 | Story materials required 여부 | 이번 구조 이관에는 actual Story 자료가 필요하지 않았다. 실제 Mandatory/Final/Ending 내용 전에는 Step56 자료가 필요하며 아직 미확정. |
| 165 | final implementation summary | 현재3 Case는 stable entry_id를 가진 typed CASE entries. CampaignData가 유일 authored source, Main은 검증 후 detached Case projection. States는 아직 case_id 기반으로 반복 Case를 거절한다. |
| 166 | next Step recommendation | Step58에서 승인된 최소 Scripted source/Response/View/Archive/return·completion 및 필요한 작은 progression authority를 검토한다. Story 창작/경제/반복 Run/Ending/Save 선구현 금지. |
