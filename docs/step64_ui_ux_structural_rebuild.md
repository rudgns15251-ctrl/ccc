# Step64 — Final UI/UX Structural Rebuild + Temporary Industrial Theme

2026-10-08 · Godot 4.7.1 stable official a 13da 4feb · Windows/GDScript · 기준 1920×1080.

공통 GameShell로 업무/사건 View를 재배치하고 Research/Hypothesis Drawer, 전체 Workspace Archive, 두 확정 Modal과 공통 TEMP Theme을 적용했다. 기존 판정·진행·기록 소유권을 유지한다. 최종 그래픽 완성은 아니며 stage/commit/push하지 않았다. 경로는 프로젝트 루트 기준이다. 증거는 `.godot/verification/step64/`의 baseline/before/scope_audit/validation_summary/invocations/attempts/실행별JSON/log/GPU PNG에 있다.

## 1. Repo Baseline

HEAD `6e8f167f699a3a95c91fee8668ae99d03e5d4db9`, branch `master`, upstream `origin/main`, staged0. 시작 tracked modified10/untracked 표시27줄(resources/campaigns와 incidents는 directory 표시)이었다. 기존 Step55~63 작업을 보존했다. 제품·문서154파일, GD51, Scene15, .tres5, Theme0, 별도font0. 기존 verification57,500파일 해시를 저장했다. assets에는 .gitkeep만 있었다. project.godot/모든Scene/script/resource/setup/signal/memento를 실제 조사했다.

기존 Scene 은 Main 과 Profile/CCTV/Experiment/Containment/Monitoring/Result/Incident/Broadcast/IncidentResult/ResearchLog/ArchiveList/ArchiveDetail/EnvironmentalDisturbanceNotice/EnvironmentConditions 다. 새 프로젝트 생성/기반 초기화 없음. 전체 초기 사본은 before/에 보관했다.

## 2. Existing UI Architecture Audit

Main Control 이 Campaign/Case/Runtime/response owner 를 연결하고 독립 View 를 교체했다. FlowView 는 advance/research signal, input guard, primitive focus state 를 제공했다. 중앙 임시 UI 와 View 별 font override, 독립 ResearchLog Stage/List→Detail Archive 구조였다. 기존 public setup/signal, Step62 capture/restore 및 generated node names 를 확인한 뒤 Scene 을 재배치했다. Main lifecycle/SourceArchive/response binding/terminal cleanup 과 Monitoring/Result debug 경로를 유지했다.

## 3. Provided UI/UX Specification Mapping

| 요청 | 구현/경계 |
|---|---|
|공통 Shell|Main 내부 GameShell, container+작은 표시 script|
|Research/Hypothesis|동일 업무 View 위 단일 우측 Drawer; stage 변경 0|
|전체 Archive|Workspace 3열; 정상 업무 Node 를 보관해 동일 instance 복귀|
|확정 재검토|Containment AUTHORIZE/Broadcast TRANSMIT 에만 Modal|
|세 사건 출처|actual context/route 로 문구와 복귀 결정|
|교체 가능한 TEMP skin|Theme/StyleBoxFlat/default font|
|Gameplay 보호|project/Case/Campaign/TEMP/runtime/data/query hash 일치|

CCTV schema 는 cctv_data 한 record 다. CAM 01만 표시하고 CAM 02/03과 새 다중 Camera 시스템을 만들지 않았다. Broadcast 는 기존 single prompt/options 이며 multi-question schema 없음. Nav 는 기존 허용된 이동을 늘리지 않는 진행 indicator 다.

## 4. GameShell Implementation

`scenes/main/main.tscn`의 Main/GameShell + `scripts/ui/game_shell.gd`. 별도 GameShell PackedScene 대신 Main 자식을 선택해 기존 root ownership/entry를 유지했다. Main은 기존 state/route, Shell은 Label/Nav/rail signal/Drawer geometry만 관리한다. UI Manager/Singleton/Framework 없음.

```
Main (Control, main.gd, common Theme)
├─ GameShell (Control, game_shell.gd)
│  ├─ Frame (VBox)
│  │  ├─ Header (72)
│  │  ├─ Body (HBox)
│  │  │  ├─ PrimaryNavigation (176)
│  │  │  ├─ Workspace / ViewHost (1688×968)
│  │  │  └─ UtilityRail (56)
│  │  └─ SystemBar (40)
│  ├─ DrawerLayer
│  ├─ OverlayLayer
│  └─ ModalLayer
└─ EnvironmentalDisturbanceNotice (only while active)
```

고정 구역은 container 최소 크기, Workspace 는 expand/fill. overlay layers 는 full-rect anchors/mouse-ignore, 실제 Drawer/Modal 자식만 입력 수신. 고정 논리 치수는 Scene/UI script 에 있으며 Main 에 pixel/color/font 코드 없음. 기존 WindowSize Label 은 hidden 으로 보존.

## 5. Header

72높이, FACILITY / OPERATIONS, 실제 Case.display_name/Stage/applied condition 이름. 지원하지 않는 TEMP/HUM sensor 값 위조 0. Sequential FACILITY EVENT, Side/Failure actual paused Case 와 return stage. Source/paused Case 는 context 에서 분리한다. rawID wrapper 제거, authored TEST/TEMP display text 는 유지. Pause 미구현이라 버튼 0. cleanup 후 NO ACTIVE RUN.

GPU에서 resume 뒤 PAUSED와 disabled rail이 남는 표시 오류를 발견했다. `_restore_side_work()` 성공검증/context해제 후 `_refresh_shell()` 한 호출을 추가했고 복귀 stage/rail assertion으로 재검증했다.

## 6. Primary Navigation

176폭, PROFILE/CCTV/EXPERIMENT/CONTAINMENT. CURRENT outline/VISITED/다음 AVAILABLE/이후 LOCKED. 모두 disabled indicator 이며 이동은 기존 업무 CTA 로만. runtime identity 변경 시 표시용 방문 상태 초기화. response/Archive 업무 Nav 잠금. free-back-navigation/cursor mutation 0.

## 7. Utility Rail

56폭 R/A/N glyph, Research Log/Research Archive/Working Hypothesis tooltip. icon 은 Main Scene 에서 교체 가능. 업무 R→현재 CaseResearch, A→전체 Archive, N→Hypothesis. response R/A→기존 source-aware Archive, N disabled. Notice/Modal/restore-pending/terminal guard 적용. 최대 Drawer 1, Research 680/Hypothesis 560. switch 시 primitive UI cache 보관.

## 8. System Bar

40높이. SESSION MEMORY / NO PERSISTENT SAVE 와 실제 확정 Containment decision. 저장 기능/가짜 Autosave/Saved 없음. scroll 밖 fixed.

## 9. Profile

Identity 520+document remaining. native Panel placeholder, actual subject/classification/description. body scroll, OPEN CCTV fixed right. Profile setup/signal script 는 원본 유지, Scene 만 재배치.

## 10. CCTV

Feed 1120+observation remaining. native visual placeholder, actual single record CAM 01 indicator. actual description/observation/condition 만. camera_id hidden Label 은 기존 discovery 계약용. 실제 condition observation 이 있을 때 UPDATED. existing Recheck return_stage/Back 경로 유지; 새 read opportunity 없음.

## 11. Experiment

Catalog 520+detail/result remaining. actual array/기존 selectable/completed/locked/remaining. selected checked/outline, completed [Executed]. catalog/result independent scroll. EXECUTE 240×48 fixed footer right, draft 없음/limit/recordlock 이면 disabled. CONTINUE secondary. 실행 결과 same View, Modal 0; 기존 signal/history/count 유지.

## 12. Containment

동적 RoomScroll+독립 RoomDetailScroll+footer. actual display_name/description 만, rating/property/outcome 위조 0. draft→AUTHORIZE→640×360Modal→최종 AUTHORIZE 에서 original confirmation signal 1. Cancel/ESC 는 draft 유지. 기존 confirmed lock/next action 유지, authorizing 때 Success/Failure 표시 0.


## 13. Research Log Drawer

기존 ResearchLogView를 RESEARCH mode로 사용한다. category 선택, 발견된 authored entry 목록, 선택한 실제 body를 각각 표시한다. snapshot에 없는 기록을 추가하지 않는다. 열기·필터·읽기·닫기는 discovery/opportunity/RNG/owner를 바꾸지 않는다. 업무는 같은 View instance와 Stage이며, 닫거나 ESC를 누르면 focus를 복원한다. primitive UI cache는 같은 Runtime에서만 유지한다. 기존 developer-only RESEARCH_LOG Stage는 terminal 회귀 검사 계약용으로 보존했다.

## 14. Research Archive

전체 Workspace는 Case300, Research/Working Note420, Detail 나머지의3열이다. 각 영역에 독립 scroll을 둔다. 실제 archived Case, authored research 및 saved note body만 표시한다. Case를 선택하기 전은 우측 내용이 비어 있고, 선택하면 같은3열 Detail Scene으로 표시한다.

정상 Archive는 업무 Node를 detach해 보관한다. Back에서 같은 instance를 재부착해 draft/result/scroll/focus와 research display receipt를 유지한다. 새 업무 표시·discovery·opportunity는 발생하지 않는다. Failure Archive는 실제 source Case만 허용하고, Sequential/Side는 전체 Archive를 사용한다. 기존 response draft/context/return 계약을 유지한다.

## 15. Working Hypothesis Drawer

폭560. 기존 TextEdit, 길이 검증, Save/Edit/Delete API를 사용한다. unsaved draft/edit ID/scroll은 같은 Runtime의 UI cache로 유지한다. 닫기·Drawer 전환·Side 복귀 이후에도 draft를 보존한다. 명시적 편집 요청만 WorkingHypothesisState를 변경한다. 자동 기록·점수·Research 발견·RNG 변경 없음. response Archive는 읽기 전용이며 Runtime 교체/reset/verified cleanup에서는 UI cache를 삭제한다.

## 16. Environmental Disturbance

Workspace 상단1688×88 amber banner다. notice instance의 Main parent를 유지해 기존 verified cleanup 검증을 보호한다. Scene이 위치·scroll·Button을 소유한다. 기존 input block/view process disable/ack/dismiss/focus/condition 계약을 유지한다. Drawer는 먼저 닫고 원래 opportunity에서만 발생한다. current work는 같은 View이며 dismiss 후 draft/lock/조건을 보존한다.

## 17. Incident

1040폭 report와 나머지 context 열. 실제 title/description을 scroll로 표시하고 native placeholder, Source Archive와 고정 EMERGENCY RESPONSE를 둔다. Failure는 source Case와 paused Case를 구분한다. Sequential은 FACILITY EVENT, Side는 CAMPAIGN EVENT와 실제 중단 업무를 표시한다. 검증용 ID는 내부 dictionary에 유지하고 UI wrapper에서는 제거한다.

## 18. Emergency Broadcast

560폭 prompt/context와 나머지 options 열. 실제 배열을 순회해 selected draft를 checked 상태로 표시한다. 긴 prompt/options는 각각 scroll한다. CONFIRM ORDERS는680×420 Modal만 열고 TRANSMIT에서 원래 confirmation 요청을 한 번 보낸다. Cancel/ESC는 draft/focus를 유지한다. 확정 후 selection lock과 REVIEW RESPONSE가 적용된다. 실제 TEMP4옵션과 source Archive 왕복 계약을 유지하며 multi-question schema를 추가하지 않았다.

## 19. Incident Result

1050폭 selected orders/report와 나머지 context. 실제 선택 Option.display_text와 IncidentResultData를 표시한다. Failure/Side는 RESUME WORK, Sequential은 CONTINUE CAMPAIGN이다. label은 기존 route로 결정하고 `_advance_response()` 본체를 보존한다. wrong choice도 기존 authored 결과와 진행을 유지한다.

## 20. Confirmation Modal

`scenes/ui/confirmation_modal.tscn`과 `scripts/ui/confirmation_modal.gd`. FlowView의 작은 local helper가 instance/focus lifetime을 관리한다. body scroll, Cancel/final CTA, 공통 backdrop Theme를 사용한다. one-shot `_resolved`, same live Modal/View, nonqueued 상태, captured Resource/ID/draft와 Main input guard를 검사한다. 닫힌 뒤 기존 canonical handler가 다시 검증한다.

ESC는 직접 취소하며 Tab/Space는 Godot GUI에 전달한다. Tab/Shift-Tab focus는 Cancel/Confirm 안에서 순환한다. Modal 중 Side 시작을 보류하고 닫힌 후 기존 draw safe boundary에서 재시도한다. Modal을 memento로 저장하거나 범용 manager/framework를 만들지 않았다.

## 21. TEMP Theme

`resources/ui/temp_industrial_theme.tres`. StyleBoxFlat과 Godot default font22, Title32/Heading26/Muted18. gray-green 바탕, light text, muted-green active, amber warning, desaturated-red emergency, disabled gray와 focus outline 역할을 나눈다. Button normal/hover/pressed/disabled/focus와 Primary/Nav/CurrentNav/Rail, Panel/Warning/Emergency/System/Backdrop variations를 중앙화한다. 동적 Label의 font override를 통합했다. 기존 environment_conditions Scene의18pt heading은 보존했다. Main gameplay에 color/font/외부 asset filename 추가0.

## 22. External Asset Policy / Inventory

외부 Asset 실제 사용: **NO**.

**Step64 uses only project/Godot-native temporary UI resources.**

assets에는 .gitkeep만 있었다. 외부 asset/font/license/attribution package 발견0, 사용0, 구매/다운로드/이미지 생성0. Obssidian/Dead Channel/VHS Asset을 설치했다고 주장하지 않는다. Theme/Panel/glyph는 project-native 자원이다. license 불명 파일이나 product binary asset을 사용하지 않았다. PNG/contact sheet는 .godot QA 증거이며 제품 asset이 아니다.

## 23. Step62 Resume Compatibility

memento primitive fields/schema/validation 규칙과 Runtime ownership을 유지했다. whitelist의5경로 문자열만 새 hierarchy로 갱신했다. unique Scroll Nodes와 generated ExperimentN/RoomN 이름은 동일하다. 기존15 journeys와 guards가 Profile focus, CCTV condition scroll/review, EXP draft/result/history/scroll/focus, CONT draft/lock/scroll/focus를 검사한다.

추가 GPU 검사는 EXP nonzero140/110, CONT nonzero60 scroll 및 focus를 확인했다. Case/Runtime object ID, Progress, Candidate/history, RNG/opportunity fingerprint가 같다. Modal 보류/Drawer 닫기와 draft cache/Side exact resume 및 복귀 후 Header/rail 활성 상태를 검증했다.

## 24. Step63 Product Campaign Compatibility

실제 Campaign의 Case01→Case02→TEMP Mandatory01→Case03 순서와 모든 .tres byte를 보존했다. 기존7 journeys를 headless/native 각각 실행했다: all-success A/Archive, B/noArchive, wrong C/D, Case02 failure, bounded Case01 failure, controlled empty Archive. A correct/B-C-D wrong의 실제 authored 결과와 Case03 dispatch를 유지했다. Side/empty Archive/bounded readiness controlled fixture는 실제 product journey와 구분한다. Mandatory02/03 추가0, product side schedule empty 유지.

## 25. Dynamic Content

| 유형 | 최소/최대 | 실제 schema/scroll | 고정 count |
|---|---|---|---|
|Experiment|1/3/6|actual array/catalog/result|없음|
|Room|2/4/8|actual array/RoomScroll/detail|없음|
|Option|2/4/6+product 4|singleprompt/options|없음|
|Research|1/40|discoveredsnapshot/category/list/detail|없음|
|ArchiveCase|1/6|immutable display snapshot/Case scroll|없음|
|Camera|actual 1|singleCCTVrecord/CAM 01|현재 schema 단일, fake 3cam 없음|

복귀 stress 는 EXP 15/Room 11, product Resource 복제본만확장. Profile/EXP/Incident/Result 120-line, EXPresult 100-line, Researchdetail 100-line, Option 16-line, Room 12-line. 실제 verticaloverflow/nonzeroscroll/horizontaloverflow 0/fixed CTA 검증, product authored 수정 0.

## 26. Resolution / Scaling

project.godot byte가 동일하다: viewport1920×1080, override1280×720, canvas_items, default keep, GL compatibility. GPU1280×720/1920×1080 각각 필수19 unique + long15 파일. capture 호출은 각20이지만 Side Result를 두 번 같은 파일에 저장하므로 필수 unique19다. 추가1024×768의 기존 keep/letterbox 검사도 통과했다. 새 최소지원 해상도를 선언하지 않는다.

Header/Nav/CTA는 고정이고 긴 자료는 각각 scroll한다. focus outline은 실제 복귀 화면에서 확인했다. RX6800 OpenGL compatibility를 사용했다. 수동 editor F5는 누르지 않았으며 configured Main native 실행 및 실제 SceneTree/button/input journey로 동등 경로를 검사했다. 모든 OS mouse 위치의 수동 사용성 검사를 했다고 주장하지 않는다.

## 27. Stale / Duplicate Guard

first CTA0/Cancel·ESC0/final signal1/double0. replaced Modal, stale View/Drawer, underlying callback은 canonical owner mutation0이다. confirmed selection lock, Drawer 최대1/Modal 최대1. Modal은 이미 due인 Side를 보류하고 Cancel 후 기존 safe draw에서 시작한다. Drawer는 시작 전 닫되 같은 Runtime draft를 유지한다. actual setup/signal/input 및 owner fingerprints를 검사했다. 추가 실제 키 입력 검사로 Cancel default focus, Tab 순환, Space 확정1회/반복0, ESC 취소를 검증했다.

## 28. Regression

최종 94 process slot: editor1+제품GD check-only53+Main2+기존회귀29+새UI7+Modal 키보드2. native15/headless79/allExit 0. assertion 호출 857,207(typedfactquery 반복지배적), 독립 scenario 수가아님. MainUI 99named×4/extra 86named×3는 namedassertion, journey 수아님. Side 15journeys×2/product 7×2/closure 2×2별도.

정상 warning/runtime/script/parse 0. 의도적 negative: ordering 4WARN/closure 13WARN/active 2WARN, Campaign 13ERROR/Scripted 17ERROR/Side 20ERROR×2 = controlled WARN 19/ERROR 70. expectedcount/exit 0/mutation 0검사. 정상오류와분리.

`*-runs.json`은 최종94개 성공 process slot 집합이다. `invocations.jsonl`은 ledger 도입 후331회 시도(실패10 포함)를 기록하며 final 실행도 그 안에 포함한다. 둘을 합산하지 않는다. ledger 이전 초기 import/probe/core 로그도 별도로 보존했으므로331을 개발 중 전체 process 총수라고 주장하지 않는다.

초기 실패:

- Modal이 ESC 외의 키까지 소비하던 UI 오류: ESC만 직접 처리하고 Cancel/Confirm Tab 순환을 지정했다. 실제 headless/native Tab/Space/ESC6개 검사 각각 통과, 전체 회귀를 재실행했다.

- Main최소크기코드제거중emptyif→parsefail: emptybranch제거,import/check통과.
- ArchiveuniqueEntry/NoteNode누락/exitShellrefresh→unique설정+insideTreeguard수정.
- oldsingleclickfixture가newModal확정전멈춤→Step64복사본에actualfinalModalclick추가. canonicalassertion보존.
- oldResearchStage/nodepaths/rawID/CTAcase의존→새Drawer/path/displayadapter; 원본검증증거수정0.
- UIprobeViewtype오류/failurepacingreadnotice우회→correcttypedView/button/readboundaryfixture수정; gameplaythreshold/RNG변경0.
- extrahelpernamecollision→rename. 12-lineoverflow가없음→controlled120-linedocument로검증.
- 1차전체통과후GPU에서sideResumeHeader/rail잔류→verifiedresumesuccessrefresh+newassertion. 전체91 재실행+추가1024+키보드2=94 PASS.

| 단계 | final fixture | 보호 |
|---|---|---|
|46|snapshot 4groups|isolation/nomutation|
|47|ordering|oldest actionable|
|48|gate|meaningfulread|
|51|ownership|disposition/owner|
|52|closure+journey|idempotentclosure|
|53|active|responsefreeze/preparation|
|54|cleanup|verifiedpreflight/no-run|
|55/57|campaign+invalid|datadrivencursor/validation|
|58|mixed/invalid/bounded|sequentialsource/response|
|60|factsnative/headless|typedquery/lifetime|
|62|side/guards/invalidnative/headless|exact resume/staleproof|
|63|product 7native/headless|actual TEMPentry/dispatch|

| Final process | assertion calls |
|---|---|
| active | 708 |
| bounded | 180 |
| bounded_native | 181 |
| campaign | 150 |
| campaign_invalid | 135 |
| cleanup | 1,130 |
| closure | 460 |
| extra_1280 | 890 |
| extra_1920 | 890 |
| extra_headless | 886 |
| facts | 411,594 |
| facts_native | 411,594 |
| closure_journey | 802 |
| closure_journey_native | 815 |
| keyboard | 6 |
| keyboard_native | 6 |
| mixed | 168 |
| mixed_invalid | 129 |
| mixed_native | 172 |
| ownership | 274 |
| product | 1,888 |
| product_native | 1,946 |
| side | 6,237 |
| side_guards | 1,211 |
| side_guards_native | 1,217 |
| side_invalid | 42 |
| side_invalid_native | 42 |
| side_native | 6,275 |
| snapshot_normal | 198 |
| snapshot_phases | 219 |
| snapshot_response | 192 |
| snapshot_isolation | 81 |
| ordering | 3,468 |
| gate | 2,401 |
| ui_1024 | 155 |
| ui_1280 | 155 |
| ui_1920 | 155 |
| ui_headless | 155 |

## 29. Files / Main Impact

Step64baseline 비교 modified 28/created 8/deleted 0. HEADdiff 에는기존 Step 55~63변경이포함되어 Step64scope 는 baselineSHA 로판정. 기존미커밋 Resource/runtime/data/query/report 보호, READMEbyteprefixappend 만.

**수정 28**

- `README.md`
- `scenes/main/main.tscn`
- `scenes/views/broadcast_view.tscn`
- `scenes/views/cctv_view.tscn`
- `scenes/views/containment_view.tscn`
- `scenes/views/environmental_disturbance_notice.tscn`
- `scenes/views/experiment_view.tscn`
- `scenes/views/incident_result_view.tscn`
- `scenes/views/incident_view.tscn`
- `scenes/views/monitoring_view.tscn`
- `scenes/views/profile_view.tscn`
- `scenes/views/research_archive_detail_view.tscn`
- `scenes/views/research_archive_list_view.tscn`
- `scenes/views/research_log_view.tscn`
- `scenes/views/result_view.tscn`
- `scripts/main/main.gd`
- `scripts/read_models/interrupted_work_view_state.gd`
- `scripts/views/broadcast_view.gd`
- `scripts/views/cctv_view.gd`
- `scripts/views/containment_view.gd`
- `scripts/views/environment_conditions_view.gd`
- `scripts/views/experiment_view.gd`
- `scripts/views/flow_view.gd`
- `scripts/views/monitoring_view.gd`
- `scripts/views/research_archive_detail_view.gd`
- `scripts/views/research_archive_list_view.gd`
- `scripts/views/research_log_view.gd`
- `scripts/views/result_view.gd`

**생성 8**

- `docs/step64_ui_ux_structural_rebuild.md`
- `resources/ui/temp_industrial_theme.tres`
- `scenes/ui/confirmation_modal.tscn`
- `scenes/ui/utility_drawer.tscn`
- `scripts/ui/confirmation_modal.gd`
- `scripts/ui/confirmation_modal.gd.uid`
- `scripts/ui/game_shell.gd`
- `scripts/ui/game_shell.gd.uid`

새 Main methods: `_refresh_shell`, `_shell_research_requested`, `_accept_drawer_action`, `_open_drawer`, `_close_drawer`, `_shell_archive_requested`, `_restore_utility_work`, `_on_confirmation_changed`, `_dispose_auxiliary_ui`.

Main method133→142; new9은Shellrefresh/rail/Drawer/normalArchiveheldView/Modalchanged/auxiliarycleanup등UI접속만. 기존16method는ready/exit/showView/ResearchHyppermission/Archive/back/activeViewguard/cleanupUI/conditionrefresh/notice/side/resumerefresh. `_advance_response`/판정/threshold/checkpoint/RNG/Campaigndispatch/factmutation본체unchanged. cleanupsourcevalidation/canonicalreset순서보존.

publicgameplaysetup/signal/capture/restore 계약유지. 새 Flowconfirmationhelpers/signal,Researchmode/cache,Archivedetailcase_requested/set_case_summaries 는표시 API. mementohelper 는 5focuspath 만. Protected 71bytehash 동일, 기존 verification 57,500hash 동일(old_evidence_preservation.json). environment_conditions_view.tscnoriginalbyte 보호.

gitstatus/diff/diff--check/HEAD/upstream/staged 최종기록. diff--check 0,staged 0,HEAD/branch/upstream 동일. GitCRLF 변환통지는 Godotwarning 과별도. stage/commit/push 0.

## 30. Known Gaps

기존 OPEN 유지:

1. completed Scripted response fact의 final RunDisposition recipient projection gap.
2. Step53 active+resolvable/same-Room residue Pending prepared-pending P2.
3. Step54 cleanup은 cross-State atomic transaction/exception rollback이 아니다. silent reset 실패의 partial cleanup 가능성과 proof/frozen/retry 방침 유지.
4. Step62 failed restore는 cross-object atomic rollback이 아니다. fail-closed/context/developer retry 유지, player recovery UI 없음.
5. 기존 Hypothesis getter P3와 developer-only terminal 한계 변경 없음.

새 미해결 P0/P1 없음. resume Shell 표시와 Modal 키 입력 차단 오류를 해결했다. 재현 확인된 새 P2/P3 없음. 실제 사용자의 장시간 UX 평가와 최종 palette/font/icon 검토는 후속 사항이다.

CRT/VHS/Glitch/Audio/Horror/SaveLoad/Ending/Mandatory02/03/newFlags/newCase/multiCamera 시스템을 추가하지 않았다. TEMP placeholder는 의도한 범위다.

## 31. Next Step Recommendation

Step65는 이 구조에서 실제 플레이어의 정보 밀도/scroll/focus/CTA 이해를 확인하며 시작할 수 있다. licensed asset을 도입한다면 common Theme/Scene Texture/Icon을 교체하고 Step62/63 및 두 Modal을 재검증한다. Gameplay/terminal gap 수정은 별도 작업 범위다. 최종 visual/shader/audio 완성은 아직 선언하지 않는다.

### Screen Matrix

| Screen | Shell / Header / Nav / Utility | Scroll | Main CTA | Modal | Interrupt |
|---|---|---|---|---|---|
|Profile|common/current/RAN|document|OPEN CCTV|none|exact focus|
|CCTV|common/current/RAN/actual conditions|observation/conditions|OPEN EXPERIMENT or existing Back|none|exact review/scroll|
|Experiment|common/current/RAN|catalog/result|EXECUTE/CONTINUE|none|draft/result/history/scroll/focus|
|Containment|common/current/RAN|rooms/detail|AUTHORIZE / existing Next|640×360|draft/lock/scroll/focus|
|Research|same Shell/work-overlay/RAN|entries/body|CLOSE|none|same work;closebeforestart|
|Hypothesis|same Shell/work-overlay/RAN|edit/notes|SAVE/CLOSE|none|draft cachedsameRuntime|
|Archive|common/UTILITYARCHIVE/locked|Case/entries/detail|BACK|none|same work/source-response|
|Disturbance|common+amberbanner|noticebody|ACKNOWLEDGE|none|existing blocking/dismiss|
|Incident|common/actual source/locked/RA|report|EMERGENCY RESPONSE|none|existing route|
|Broadcast|common/actual source/locked/RA|prompt/options|CONFIRM ORDERS/REVIEW RESPONSE|680×420|draft/confirmed route|
|IncidentResult|common/actual source/locked/RA|orders/report|RESUME WORK/CONTINUE CAMPAIGN|none|existing route|

### CTA Matrix

| View | primary | secondary | disabled/blocked | final route |
|---|---|---|---|---|
|PROFILE|OPEN CCTV|R/A/N|notice/modal/terminal/stale|CCTV|
|CCTV|OPEN EXPERIMENT / Back|R/A/N|same guards|EXP / Recheckreturn|
|EXPERIMENT|EXECUTE|CONTINUE/Recheck/RAN|nodraft/completed/limit/guard|same result;Continue→CONT|
|CONTAINMENT|AUTHORIZE then existing Next|Recheck/RAN|nodraft/confirmed/guard|Modal→Pendingonce/existing dispatch|
|INCIDENT|EMERGENCY RESPONSE|SOURCE ARCHIVE|invalidbroadcast/context/guard|BROADCAST|
|BROADCAST|CONFIRM ORDERS→TRANSMIT;REVIEW RESPONSE|SOURCE ARCHIVE|nodraft/confirmed lock/guard|INCIDENTRESULT|
|RESULT|RESUME WORK / CONTINUE CAMPAIGN|SOURCE ARCHIVE|invalidbinding/restore/terminal|existing route|

### Incident Type Matrix

| Type | Source | Paused work | Archive | Final CTA | Return |
|---|---|---|---|---|---|
|CASE FAILURE|actual historicalsourceCase|actual interruptedCase/stage|source-only|RESUME WORK|exact work;existing candidatecomplete|
|SEQUENTIAL SCRIPTED|FACILITY EVENT/authoredtitle|none/fakeCase 0|whole|CONTINUE CAMPAIGN|Case 03dispatchonce|
|MID-CASE SCRIPTED|CAMPAIGN EVENT/authoredtitle|same Case/Runtime/stage|whole|RESUME WORK|Step62exactrestore,cursoradvance 0|

### Memento Matrix

| View | old→new paths | captured transient | restore / GPU |
|---|---|---|---|
|PROFILE|Center/Content/Actions/*→Margin/Content/Actions/*|focus|legacy journey+currentShellPASS|
|CCTV|Actions same mapping;%ConditionObservationScroll retained|condition_scroll/focus/reviewreturn|legacy 15+native PASS|
|EXPERIMENT|Center/Content/Workspace/ExperimentScroll→Margin/Content/Workspace/Catalog/ExperimentScroll; Run Center/Content/Workspace/Execution/RunButton→Margin/Content/Actions/RunButton|draft/resultID/list/resultscroll/focus|nonzero 140/110exact,screenshot 17|
|CONTAINMENT|Center/Content/RoomScroll→Margin/Content/RoomScroll|draft/confirmed/roomscroll/focus|nonzero 60exact,screenshot 18|

Recheck Center/Content/RecheckCCTVButton→Margin/Content/RecheckCCTVButton. 기존 valid actions 및 ExperimentN/RoomN names 유지. 새 RoomDetailScroll 은 Step64 표시용, 기존 memento schema 추가 0.

### Final Asset Replacement Audit

| 질문 | 답변 |
|---|---|
|Theme 하나로 대부분 skin 교체?|YES. StyleBoxFlat/color/font/variations 중앙화; layout 은 Scene 소유|
|Button 마다 직접 Texture?|NO. native ThemeStates, binaryexternalasset 0|
|View 별 duplicatecolorconstant?|NO. 신규 0, dynamic fontoverride 통합|
|externalassetfilename 이 gameplay 에?|NO. commonUIResource 참조만|
|Main 수정 없이 final icon 교체?|YES. RailSceneButton icon/text 교체|
|Viewlogic 수정 없이 Panel 교체?|YES. Themevariation styleResource 교체|


### Required GPU screenshot s

| # | PNG stem (1280 / 1920 / optional 1024 suffix) |
|---|---|
| 1 | `ui_01_profile_shell` |
| 2 | `ui_02_cctv` |
| 3 | `ui_03_experiment_selection` |
| 4 | `ui_04_experiment_result` |
| 5 | `ui_05_containment_rooms` |
| 6 | `ui_06_containment_modal` |
| 7 | `ui_07_research_drawer` |
| 8 | `ui_08_research_archive` |
| 9 | `ui_09_hypothesis_drawer` |
| 10 | `ui_10_environmental_disturbance` |
| 11 | `ui_11_failure_incident` |
| 12 | `ui_12_temp_sequential_incident` |
| 13 | `ui_13_broadcast_four_options` |
| 14 | `ui_14_broadcast_modal` |
| 15 | `ui_15_sequential_result` |
| 16 | `ui_16_side_result` |
| 17 | `ui_17_experiment_resume` |
| 18 | `ui_18_containment_resume` |
| 19 | `ui_19_case03_profile` |

### Termination Questions — all 263 items

사용자지정번호에일대일대응. assertion 호출/processslot/독립 journey 를구분한다.

| # | 요청 항목 | 실제 결과/근거 |
|---|---|---|
| 1 | 작업 전 Git 상태 | 작업 전 modified 10/untracked 27줄; 기존 작업 보존, baseline.json git 전문 기록. |
| 2 | HEAD | HEAD 6e 8f 167f 699a 3a 95c 91fee 8668ae 99d 03e 5d 4db 9. |
| 3 | branch/upstream | master / origin/main; 종료 동일. |
| 4 | staged | 시작 staged 0, 종료 staged 0. |
| 5 | baseline file count | 제품·문서 154개, GD 51/Scene 15/.tres 5; cache/git 제외. |
| 6 | existing Scenes | Main+14 Scene 실제 조사, before/ 전체 사본 보관. |
| 7 | existing Views | 12 route Views 와 EnvironmentConditions/Disturbance helper, 모든 setup/signal 조사. |
| 8 | existing Theme | 기존 Theme 0, 새 common Theme 1. |
| 9 | external asset directories found | assets/.gitkeep 만. 외부 asset directory 발견 0. |
| 10 | external licenses found | third-party license 발견 0; license 불명 파일 사용 0. |
| 11 | external assets actually used | NO. Step64 uses only project/Godot-native temporary UI resources. |
| 12 | GameShell implementation choice | 기존 Main 의 GameShell 자식; root entry/ownership 유지, UI Manager 0. |
| 13 | GameShell path | scenes/main/main.tscn Main/GameShell + scripts/ui/game_shell.gd. |
| 14 | root ownership | Main 기존 state/route owner, Shell 표시/rail signal 만. |
| 15 | Header dimensions | Header 1920×72 logical. |
| 16 | Nav dimensions | Nav 176×968 logical. |
| 17 | Workspace dimensions | Workspace 1688×968 logical. |
| 18 | Utility Rail dimensions | Rail 56×968 logical. |
| 19 | SystemBar dimensions | SystemBar 1920×40 logical. |
| 20 | container vs absolute layout | VBox/HBox/anchors/expand-fill; Main 절대 pixel 배치 0. |
| 21 | Header Case display | actual current_case.display_name, 없으면 FACILITY EVENT/NO ACTIVE RUN. |
| 22 | Header Stage display | actual Stage/paused return stage, resume success refresh 검사. |
| 23 | Header environment | actual applied condition names 만; 가짜 sensor 0. |
| 24 | sequential event Header | FACILITY EVENT, null Case/Runtime 에서 가짜 environment 0. |
| 25 | side interrupt Header | same actual current Case 와 PAUSED return stage. |
| 26 | developer ID exposure | rawID wrapper 제거; authored TEST/TEMP display_name/title 는 그대로. |
| 27 | Nav entries | PROFILE/CCTV/EXPERIMENT/CONTAINMENT. |
| 28 | Nav current | CURRENT skin/밝은 outline, actual current stage 기준. |
| 29 | Nav available | 다음 AVAILABLE. 이동은 work CTA 만. |
| 30 | Nav locked | 이후 LOCKED; response 업무 Nav locked. |
| 31 | free-back-navigation 여부 | free back-navigation 0. Nav pressed owner mutation 0 검증. |
| 32 | Incident Nav disable | Incident/Broadcast/Result 업무 Nav disabled. |
| 33 | Utility Rail buttons | R/A/N glyph,56폭. |
| 34 | Research button | 업무 R→current CaseResearch, response R→source Archive. |
| 35 | Archive button | 업무 wholeArchive, response existing source-awareArchive. |
| 36 | Hypothesis button | 업무 HypothesisDrawer, response disabled. |
| 37 | tooltip | Research Log/Research Archive/Working Hypothesis tooltip. |
| 38 | drawer count | 동시에 Drawer 1; switch/close 검증. |
| 39 | Research Drawer width | Research 680 logical px. |
| 40 | Hypothesis Drawer width | Hypothesis 560 logical px. |
| 41 | drawer overlay behavior | same live work 위 overlay; stage/instance 유지. |
| 42 | drawer gameplay mutation | toggle/filter/read/close facts/opportunity/RNG/progress 0; 명시적 note save 만 기존 API. |
| 43 | drawer stale behavior | detachedDrawer callback 0, Runtime change cache 초기화. |
| 44 | Archive full workspace | Workspace 전체 3열. |
| 45 | Archive Case column | Case 300, actual archived cases 만. |
| 46 | Archive Entry column | Research/WorkingNote 420, actual records 만. |
| 47 | Archive Detail column | Detail 나머지, actual selected body. |
| 48 | Archive scroll | independent Case/Entry/Note/Detail scroll. |
| 49 | normal Archive return | stored same work Node 재부착, draft/result/scroll/focus 유지. |
| 50 | Failure Archive return | 실제 source Case 로 제한, exact response Stage 로 Back. |
| 51 | Sequential Archive return | wholeArchive→same sequential response Stage/draft. |
| 52 | Side Interrupt Archive return | wholeArchive→same side response Stage/draft. |
| 53 | fake Case source | fake Case source 생성 0, sequential neutral context. |
| 54 | Hypothesis TextEdit | 기존 TextEdit/length validation/CRUD 유지. |
| 55 | Hypothesis persistence | same Runtime unsaved cache; saved in-memory notes 기존 owner. new Runtime/reset/cleanup 초기화. |
| 56 | Hypothesis scoring | scoring 0, note→Researchdiscovery 0. |
| 57 | System Bar | SESSION MEMORY / NO PERSISTENT SAVE + actual decision. |
| 58 | fake Autosave status 여부 | fake Autosave/Saved status 0. |
| 59 | Profile columns | Profile identity 520/documentremaining. |
| 60 | Profile image | native Panel TEMP IMAGE PLACEHOLDER, imageasset 0. |
| 61 | Profile metadata | actual subject/classification 만. |
| 62 | Profile body scroll | bodyScroll,120-line fixture overflow 확인. |
| 63 | Profile CTA | OPEN CCTV fixed footer-right. |
| 64 | CCTV columns | CCTV 1120 feed/observationremaining. |
| 65 | CCTV camera tabs | single actual record CAM 01 indicator. |
| 66 | camera dynamic count | current schema 가 단일 record. multiCamera 시스템/가짜 3개 없음. |
| 67 | CCTV visual area | native placeholder panel, 실제 video 추가 0. |
| 68 | environment bar | actual existing EnvironmentConditions, sensor 위조 0. |
| 69 | observation scroll | actual observations/condition bodyScroll. |
| 70 | CCTV CTA | OPEN EXPERIMENT; Recheck 때 existing Back return stage. |
| 71 | Recheck UPDATED | actual condition observations 가 있으면 UPDATED. |
| 72 | Recheck return | 기존 _cctv_review_return_stage 와 resume guard 보존. |
| 73 | Experiment columns | catalog 520/detail+resultremaining. |
| 74 | Experiment list | available_experiments 배열에서 generatedlist. |
| 75 | experiment dynamic count | 1/3/6 fixture 통과, 고정 count 없음. |
| 76 | experiment state visuals | selected checked/outline, completed[Executed], limit/lockdisabled Theme 상태. |
| 77 | remaining count | 기존 runtime remaining/limit 계산표시. |
| 78 | selected detail | actual selected name/description; 가짜 properties 0. |
| 79 | result area | same View actual result/condition observations scroll. |
| 80 | Execute CTA | EXECUTE 240×48 footer-right, Modal 0. |
| 81 | Experiment selected draft restore | selected_experiment_id primitive exact restore 통과. |
| 82 | displayed Result restore | displayed_result_id/history unchanged exact restore. |
| 83 | experiment list scroll restore | %ExperimentScroll 유지, nonzero 140 equality/GPU. |
| 84 | result scroll restore | %ResultScroll 유지, nonzero 110 equality/GPU. |
| 85 | Experiment focus restore | RunButton/select 새 유효 path, exact focus/GPUoutline. |
| 86 | Containment layout | 동적 RoomScroll/RoomDetailScroll/fixed footer. |
| 87 | Room dynamic list | actual available_rooms 배열,2/4/8검증. |
| 88 | Room fields | actual display_name/description 만, rating/outcome/property 위조 0. |
| 89 | selected Room detail | actual selected description independentScroll. |
| 90 | AUTHORIZE CTA | AUTHORIZE firstclick 은 Modal 만; original signal 0. |
| 91 | Containment modal | reusable 640×360, actual selection/environment 요약. |
| 92 | Modal Cancel | Cancel/ESC draft 유지, Pending/facts/RNG 0. |
| 93 | Modal final Authorize | final AUTHORIZE 만 original confirmation handler once. |
| 94 | confirm signal count | final signal 1, duplicate 0. |
| 95 | hidden Outcome UI | authorizing 에 Success/Failure/outcome 노출 0. |
| 96 | Room draft restore | selected_room_id/confirmed_room_id primitive equality. |
| 97 | Room scroll restore | %RoomScroll 유지, nonzero 60 equality/GPU. |
| 98 | Room focus restore | ConfirmButton/RoomN/Select 새유효 path exact focus. |
| 99 | Research Log UI | category/discoveredlist/actual body 읽기전용 Drawer. |
| 100 | undiscovered entries | snapshot 에 undiscoveredEntry 추가 0. |
| 101 | Environmental Disturbance layout | Workspace-top 1688×88 amberbanner, native Theme. |
| 102 | disturbance gameplay contract | 기존 input block/ack/dismiss/condition contract 유지. |
| 103 | current work preservation | same workView/draft/lock, 새로운 Stage 0. |
| 104 | Failure Incident layout | Incident 1040report+actual source contextremaining. |
| 105 | Sequential Incident layout | same layout FACILITY EVENT, fakeCase 0. |
| 106 | Side Incident layout | same layout CAMPAIGN EVENT+actual paused case/stage. |
| 107 | Failure source display | historicalsourceCase.display_name 와 paused Case 별도. |
| 108 | Sequential source display | authoredtitle/neutralfacility, rawEntryID display 0. |
| 109 | Side source display | authoredtitle/actual paused case, rawinterruptID display 0. |
| 110 | Paused Work display | actual return_stage/interrupted_case_display_name. |
| 111 | Incident Archive | 기존 source-awareArchive; rail/secondary same route. |
| 112 | Emergency Response CTA | EMERGENCY RESPONSE fixed right, existing validBroadcastguard. |
| 113 | Broadcast columns | Broadcast 560 prompt/context + remainingoptions. |
| 114 | Broadcast context | actual responsecontext/source-kind 별표시. |
| 115 | Broadcast option count dynamic | actual optionsarray,2/4/6검증. |
| 116 | Step63 four options | actual TEMP 4옵션표시, resourcebyteunchanged. |
| 117 | Broadcast scroll | prompt/options separateScroll,16-lineoptions 확인. |
| 118 | draft visualization | selected draft checkedmarker, canonicalconfirm 전 0. |
| 119 | CONFIRM ORDERS CTA | CONFIRM ORDERS→Modal only, ownerconfirm 0. |
| 120 | Broadcast modal | reusable 680×420 actual draft/contextModal. |
| 121 | Modal Cancel | Cancel/ESC draft/focus 유지. |
| 122 | TRANSMIT | TRANSMIT 만 original final confirm. |
| 123 | Response confirm count | original Responseconfirmation 1, repeat 0. |
| 124 | confirmed lock | confirmed immutable/selectiondisabled, REVIEW RESPONSE 표시. |
| 125 | Broadcast Archive roundtrip | SourceArchive 왕복 draft/confirmed bindingunchanged. |
| 126 | Incident Result layout | Result 1050 orders/report + remainingcontext. |
| 127 | Result report scroll | actual result bodyScroll,120-linefixturePASS. |
| 128 | Failure Result CTA | Failure RESUME WORK. |
| 129 | Sequential Result CTA | Sequential CONTINUE CAMPAIGN. |
| 130 | Side Result CTA | Side RESUME WORK. |
| 131 | route-derived CTA | existing _incident_route 기반, _advance_responseunchanged. |
| 132 | generic modal framework 여부 | 작은 localhelper+한 ModalScene, genericManager/framework 0. |
| 133 | modal stale callback | same Modal/liveView/nonqueued/capturedDraftResource+MainGuard, staleapply 0. |
| 134 | Primary action placement | primaryfixedbottom-right, scroll 밖. |
| 135 | secondary action placement | footerprimary 왼쪽/utilityrail, indicator 는 route 하지않음. |
| 136 | button min size | primary 240×48logical, Modalfinal 동일; rail/선택높이 48이상. |
| 137 | fixed header scroll 여부 | Header 는 Body scroll 밖 fixed. |
| 138 | fixed CTA scroll 여부 | CTA 는 bodyScroll 밖 fixed. |
| 139 | Theme path | resources/ui/temp_industrial_theme.tres. |
| 140 | Theme color roles | gray-green/lighttext/mutedgreen/amber/red/disabled/outline 역할. |
| 141 | Theme button states | normal/hover/pressed/disabled/focus + Primary/Nav/Railvariations. |
| 142 | Theme panel styles | normal/warning/emergency/system/backdropStyleBoxFlat. |
| 143 | duplicate hardcoded visual values | Viewduplicatecolors 0, dynamic fonts 중앙화; original environmentheading 18유지. |
| 144 | external Asset hardcodes | externalAssetfilename 0, Theme/Scene 참조는 presentation. |
| 145 | final Asset replaceability | Theme/SceneTexture/Icon 교체로 skin 변경; gameplayowner 수정불필요. |
| 146 | CRT shader | CRTshader 0. |
| 147 | VHS shader | VHSshader 0. |
| 148 | glitch | glitch 0. |
| 149 | new SFX | new SFX 0. |
| 150 | new font | new font 0, Godotdefault. |
| 151 | third-party license file | third-partylicense 사용/추가 0. |
| 152 | project.godot | project.godot SHA baseline 동일. |
| 153 | Campaign .tres | Campaign .tres byte 동일. |
| 154 | Case .tres | Case 3 .tres byte 동일. |
| 155 | TEMP Incident .tres | TEMPIncident .tres byte 동일. |
| 156 | side schedule | actual productside schedule empty 그대로, controlled duplicate 만검증. |
| 157 | Main gameplay changes | 판정/owner/progression 정책변경 0; UIinputguard/displaywiring 만. |
| 158 | Main presentation changes | Shellrefresh/Drawer/heldworkNode/Modalchanged/Archivesetup. |
| 159 | View public API changes | 기존 gameplaysetup/signal/capture/restore 유지, UIhelper 만추가. |
| 160 | Scene changes | existing Scene 14재배치, environment_conditions_view.tscn original 유지. |
| 161 | new UI Resources | Theme .tres 1. |
| 162 | new UI Scenes | confirmation_modal/utility_drawer .tscn 2. |
| 163 | deleted files | 파일삭제 0. |
| 164 | Step62 Profile resume | Profile exact focus/runtime/stage old sideSuitePASS. |
| 165 | Step62 CCTV resume | CCTV conditionScroll/review/runtime/stage old sideSuitePASS. |
| 166 | Step62 Experiment resume | EXPdraft/result/history/scroll/focus old 15+new GPU 17PASS. |
| 167 | Step62 Containment resume | CONTdraft/lock/scroll/focus old 15+new GPU 18PASS. |
| 168 | Recheck resume | Recheckreturnstage/focus path 보존, old sidevalidationPASS. |
| 169 | Modal + Interrupt collision | Modal 동안 dueSidehold, Cancel 후 existing safedrawstart 검증. |
| 170 | Drawer + Interrupt collision | Drawer 닫고 Side, same runtime unsaveddraftcache+exact resume 검증. |
| 171 | exact Runtime proof | actual RuntimeobjectID/Caseobjectfingerprint 동일. |
| 172 | exact Stage proof | _current_stage==return_stage, HeaderactualStage+railenabled 검증. |
| 173 | Research mutation | Drawer/ArchiveUIdiscovery 0, 기존 genuinesource/executedwork 발견만. |
| 174 | Experiment execution mutation | UI 열기/닫기 추가 execution 0, 명시적 EXECUTE 기존행동. |
| 175 | Containment Pending mutation | firstAUTHORIZE/cancelPending 0, final originalhandleronce. |
| 176 | Failure Candidate mutation | UItoggleCandidate 0, 기존 failurepath 보존. |
| 177 | RNG mutation | UI-only/sideResume RNGfingerprint 동일, thresholdsunchanged. |
| 178 | Campaign Progress mutation | UI/sideProgressidentity/cursor/completed/transition 동일; sequentialcontinueonce 기존동작. |
| 179 | all-success Step63 journey | actual Case 01/02success→TEMP→Case 03, product headless/native 7suitePASS. |
| 180 | Step63 correct option | actual OptionA correctauthoredresult 보존. |
| 181 | Step63 wrong option | actual B/C/Dwrongauthoredresult 보존, 판정변경 0. |
| 182 | Step63 Archive | actual discoveredArchive/body/return product journeyPASS. |
| 183 | CASE03 dispatch | acknowledgedsequential→freshCase 03once, screenshot 19. |
| 184 | Failure Major journey | realCase 01failure/read/disturbance/Major/Archive/Broadcast/resumePASS. |
| 185 | Sequential Scripted journey | realTEMPsequential/neutralHeader/4options/continuePASS. |
| 186 | Mid-Case Scripted journey | controlled typedSideSchedule→response→same workexactresumePASS. |
| 187 | Source Archive journey | actual Archivebodyselection/source filterPASS. |
| 188 | Research Log drawer journey | R 680/same work/snapshot/close/facts 0PASS. |
| 189 | Hypothesis drawer journey | N 560/draft/save/close/sidepreserve/cleanupPASS. |
| 190 | Containment modal journey | CONTfirst 0/cancel 0/final 1/double 0/stale 0PASS. |
| 191 | Broadcast modal journey | Broadcastfirst 0/ESC 0/final 1/lock/ArchivePASS. |
| 192 | double confirm | one-shot/canonicalguard, duplicatefinalmutation 0. |
| 193 | stale modal | queued/replacedmodalclosure 0 assertion. |
| 194 | stale View | detached/staleViewsignal 0 ownerfingerprint 검증. |
| 195 | dynamic experiment1 | experiments 1fixturePASS. |
| 196 | dynamic experiment3 | experiments 3fixturePASS. |
| 197 | dynamic experiment6 | experiments 6fixturePASS. |
| 198 | dynamic room2 | rooms 2fixturePASS. |
| 199 | dynamic room4 | rooms 4fixturePASS. |
| 200 | dynamic room8 | rooms 8fixturePASS. |
| 201 | dynamic option2 | options 2fixturePASS. |
| 202 | dynamic option4 | options 4fixturePASS. |
| 203 | dynamic option6 | options 6fixturePASS. |
| 204 | long Profile | Profile 120-line bodyScroll/fixed footerPASS. |
| 205 | long Experiment | EXP 120description/100result, separateScrollPASS. |
| 206 | long Incident | Incident 120report/responseCTAfixedPASS. |
| 207 | long Broadcast | Options 16-line prompt/optionScrollPASS. |
| 208 | long Result | Result 120body/fixed responsePASS. |
| 209 | 1920x1080 GPU | native 1920×1080 mandatory 19unique+long 15. |
| 210 | 1280x720 GPU | native 1280×720 mandatory 19unique+long 15. |
| 211 | scaling | original canvas_items/keepunchanged, additional 1024×768letterboxPASS. |
| 212 | clipping | primarygeometryboundsPASS, clipping 은의도한 View/Scroll 내부만. |
| 213 | overlap | Header/Body/footer 비중첩, Drawer/Modal/banner 는의도한 overlay. |
| 214 | scroll usability | separateverticaloverflow/nonzeroscroll/restore, horizontaloverflow 0assertions. |
| 215 | focus visibility | actual focus edNodeequality/commonoutline/GPUresume 직접검토. |
| 216 | editor import | fresh --editor --quit exit 0/정상 diagnostic 0. |
| 217 | product scripts check-only | 제품 53GD --check-only exit 0. |
| 218 | Main headless | configuredMain --headless --quit-after 20 exit 0. |
| 219 | Main native | configuredMainnative --quit-after 30 exit 0, actual GPU. |
| 220 | UI journey headless | MainUI 155checks/99named + extra 886checks/86namedheadless. |
| 221 | UI journey native | 기본 1280/1920/1024각 155checks/99named;extra 각 890checks/86named. |
| 222 | GPU screenshots | 필수 38unique(19×2), optional 1024의 19, long 30(15×2);capturecall 과 unique 구분. |
| 223 | process count | final94 모두 PASS(native15/headless79). Ledger 331회는 초기 실패/반복 포함이며 final과 중복된다. |
| 224 | assertion calls | final 857207assertioncalls, 반복 typedqueries 포함/독립 scenario 아님. |
| 225 | scenario distinction | actual authored 7×2,Side 15×2,closure 2×2;controlled fixture 구분. |
| 226 | normal warnings | 정상 warning 0. |
| 227 | controlled diagnostics | expectedcontrolledWARN 19/ERROR 70, expectedcount/exit 0/mutation 0검사. |
| 228 | runtime errors | 최종 unexpectedruntimeerror 0; negativepush_error 분리. |
| 229 | script errors | final SCRIPT ERROR 0; 초기 fixture 오류보존/해결. |
| 230 | parse errors | final Parse Error 0; initialemptyif 해결. |
| 231 | initial failures | initialparse/uniqueNode/exitguard/fixtureadapters/type/scroll/helper/resumeShell 은 Regression 에원인/해결기록. |
| 232 | Step46 regression | Step 46snapshot 4groupsPASS. |
| 233 | Step47 regression | Step 47ordering 3468calls/20rows/4controlledWARNPASS. |
| 234 | Step48 regression | Step 48gate 2401calls/15scenariosPASS. |
| 235 | Step51 regression | Step 51ownership 274calls/52invalidfixturesPASS. |
| 236 | Step52 regression | Step 52closure 460calls/41calls+actual 2journeysheadless/native PASS. |
| 237 | Step53 regression | Step 53active 708calls/61requests/2controlledWARNPASS,P 2OPEN. |
| 238 | Step54 regression | Step 54cleanup 1130calls/62requestsPASS,atomiclimitation 유지. |
| 239 | Step55 regression | Step 55foundation 은현재 typedCampaigndispatch/validation 으로회귀, cursorunchanged. |
| 240 | Step57 regression | Step 57campaign 150/invalid 135calls+13controlledERRORPASS. |
| 241 | Step58 regression | Step 58mixed 168/172,bounded 180/181,invalid 129+17controlledERRORPASS. |
| 242 | Step60 regression | Step 60facts 각 411594callsheadless/native,lifetimeguardPASS. |
| 243 | Step62 regression | Step62side 6237/6275calls 15journeys,guards 1211/1217,invalid 42각 PASS. |
| 244 | Step63 regression | Step63product 1888/1946calls 각 7actualjourneysPASS. |
| 245 | completed Scripted terminal gap | completedScriptedterminalprojectiongapOPEN,fixclaim 0. |
| 246 | Step53 P2 | Step 53prepared-pending/residueP 2OPEN. |
| 247 | Step54 atomic limitation | Step 54crossStateatomicity/rollbacklimitationOPEN. |
| 248 | Step62 restore failure limitation | Step62failclosedrestore/context/developerretryOPEN,playerRecoveryUI 없음. |
| 249 | new P0 | 새미해결 P 0관찰없음. |
| 250 | new P1 | 새 미해결P1 없음; resume Shell 표시와 Modal 키 입력 차단 오류를 해결하고 전체 재검증. |
| 251 | new P2 | 새재현 P 2없음, 기존 P 2유지. |
| 252 | new P3 | 새재현 P 3없음, 기존 getterP 3유지. |
| 253 | files modified | Step64modified 28, baselinecomparison 실제목록 Files 절. |
| 254 | files created | created 8, uid 2/report 1포함. |
| 255 | files deleted | deleted 0. |
| 256 | README | READMEappendonly,8markers/reportlink,old byteprefix 검증. |
| 257 | report | docs/step 64_ui_ux_structural_rebuild.md,31sections/all 263answers/matrices. |
| 258 | git diff --check | git diff --check exit 0,final evidence 보관. |
| 259 | final staged | staged 0. |
| 260 | commit/push | stage/commit/push 0. |
| 261 | Step65 readiness | Step 65는 actual UXreview/asset-onlyreplacement 부터가능; terminalgaps 별도. |
| 262 | final Asset replacement readiness | commonTheme/Scene/icon/texture 교체준비,final licensedasset 적용 claim 0. |
| 263 | final recommendation | 기존 gameplaybaseline 유지,실제사용 UX 확인후 licensedskin 교체와 Step62/63회귀권장. |
