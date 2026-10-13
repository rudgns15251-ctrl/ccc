# Step66 — Direct Navigation + Archive Exit UX Rework

> 개발 이력: 이 문서는 해당 단계 작성 당시의 설계·구현·검증 기록입니다. 현재 구조는 [코드 구조 안내](architecture.md)를 참고하세요. `.godot/verification/` 자료는 Git에 포함되지 않는 로컬 자료이며, 공개 검사 방법은 [검증 안내](verification.md)에 있습니다.

작성일: 2026-10-11. 실제 저장소를 기준으로 직접 Navigation을 구현했다. Step64/65의 비활성 Navigation 정책은 이 단계에서 변경하며 Gameplay 승인 조건은 유지한다.

결과: 왼쪽 업무 메뉴로 허용된 다음 단계에 진입하고 이미 접근한 화면을 재방문할 수 있다. Archive는 A 재클릭·Esc·BACK으로 원래 업무 또는 Response에 돌아간다. 탐색용 화면 표시와 승인된 Gameplay 진행을 구분했다. 기존 terminal OPEN의 해결이나 정식 에셋 완성을 의미하지 않는다.

증거 루트: `.godot/verification/step66/`. `request.txt`, `baseline.json`, `before/`, `change_audit.json`, `invocations.jsonl`, `attempts/`, `final_summary.json`, `git_audit.json`, `step66_delta.patch`, `old_evidence_preservation.json` 참조. 검증 사본과 GPU 캡처는 ignored QA 파일이며 제품 에셋이 아니다.

## 1. Repo Baseline

작업 전 비캐시 파일 163개 전체, 제품 GDScript 53개, Scene 17개, `.tres` 6개를 조사하고 SHA-256 및 사본을 보관했다. 실제 Main/Shell/View/Theme, CTA, Runtime/owner/read model, Archive held-work, Drawer, Modal, CCTV recheck, Step62 capture/restore, 실제 Campaign/Case/TEMP Resource 및 Git 상태를 확인했다.

시작 HEAD `19be4ea998d6479f5c46c3527d540ff4a16f2322`, branch `master`, upstream `origin/main`, staged 0, working tree clean. 원격 `https://github.com/rudgns15251-ctrl/ccc.git`. Main 142함수/2601줄. 기존 검증 증거 60,896파일의 해시도 확보했다. 과거 요청의 경로·Node 이름을 그대로 가정하지 않았다.

## 2. Existing Navigation Limitation

기존 `scripts/ui/game_shell.gd`는 네 업무 Button을 모두 disabled로 만들고 visited/current 상태만 표시했다. 실제 진행은 각 View의 고정 Next CTA에 의존했다. Archive가 열린 동안 Rail A도 disabled여서 BACK이 필요했다. 순차/Side Archive Detail은 목록을 거치는 두 번의 BACK이 필요했다. Main의 실제 View 필드는 `_current_view`이며 `_active_view`는 없다.

## 3. CurrentStage / Display Separation Audit

`_current_stage`는 기존 진행/Response/auxiliary 상태 계약을 유지한다. 일반 업무 재방문은 `_presented_work_stage`로 표시 대상을 구분하고 요청이 끝난 뒤 `_current_stage`를 변경하지 않는다. Header도 `PROFILE / REVIEW / WORK CONTAINMENT`처럼 실제 업무와 표시 화면을 함께 알린다.

기존 CCTV 재확인은 `_current_stage=CCTV`, `_cctv_review_return_stage=EXPERIMENT/CONTAINMENT`를 사용하는 별도 계약이다. 이를 새 Gameplay rollback으로 재해석하지 않았다. `_navigation_work_stage()`가 해당 parent 또는 Archive의 held-work 단계를 읽어 접근 가능 메뉴를 계산한다. 실제 canonical action handler는 그대로 승인한다.

각 View의 setup/ready는 표시·로컬 선택 UI를 구성한다. Research 발견, draw receipt, opportunity, Stage/ACTION_ACCEPTED checkpoint는 Main이 실행한다. 재방문은 `_show_view(destination, false, true, true)`와 기존 memento 복원을 사용한다. 이 경로에서 발견·accounting·checkpoint를 실행하지 않는다. 원래 업무로 돌아오면 실제 draw 전 CTA를 받지 않도록 View별 draw receipt만 갱신한다. 이것은 결과 읽기 token, Stage checkpoint, opportunity 또는 Gameplay receipt가 아니다.

## 4. Primary Navigation Policy

Shell의 `navigation_requested(stage)`는 요청만 전달한다. Main이 현재 Runtime, 접근 이력, next 승인 조건과 Modal/Response/terminal/restore 경계를 검사한다. 이미 표시한 목적지 클릭은 View를 재생성하거나 focus/scroll/draw receipt를 초기화하지 않는다. Drawer/Archive가 열려 있으면 해당 보조 화면부터 닫는다.

미방문 목적지는 실제 canonical 업무의 바로 다음 단계만 후보가 된다. 실제 View의 Next CTA가 허용해야 하며 기존 `_on_advance_requested`를 재사용한다. 따라서 첫 진입 시 발생하던 정상 발견·read 경계·accounting·Story interrupt가 기존 규칙대로 한 번 발생할 수 있다. 재방문과 구별한다.

## 5. Stage Unlock / Review Rules

아래 표는 현재 Runtime에 속한 정상 업무 기준이다. visited는 해당 Runtime의 primitive work snapshot이 있는 화면이다. 새 Runtime이면 초기 PROFILE만 남는다. `AVAILABLE`은 방문 이력이 없는 바로 다음 업무, `REVIEW`는 접근한 다른 업무, `UNLOCKED`는 재방문 중 돌아갈 canonical 업무다.

| Current canonical stage | Presented screen | Clicked destination | Unlocked? | Allowed? | View-only or interactive? | Actual state mutation? | Return behavior |
|---|---|---|---|---|---|---|---|
| PROFILE | PROFILE | PROFILE | Yes | Yes | Same View | 0 | No-op |
| PROFILE | PROFILE | CCTV | Next candidate | CTA permits | Normal first access | Original approved CTA only | CCTV starts |
| PROFILE | PROFILE | EXPERIMENT / CONTAINMENT | No | No | None | 0 | PROFILE stays |
| CCTV | CCTV | PROFILE | Visited | Yes | Review | 0 | Saved Profile display |
| CCTV | PROFILE review | CCTV | Yes | Yes | Canonical work | 0 | Saved CCTV display |
| CCTV | Either | EXPERIMENT | Next candidate | CTA permits | Normal first access | Original CTA only | EXPERIMENT starts |
| CCTV | Either | CONTAINMENT | No | No | None | 0 | Same display |
| EXPERIMENT | EXPERIMENT | PROFILE / CCTV | Visited | Yes | Review | 0 | Draft/result retained |
| EXPERIMENT | PROFILE / CCTV review | EXPERIMENT | Yes | Yes | Interactive under existing execution rules | Navigation 0 | Restore draft/result/scroll/focus |
| EXPERIMENT | Any permitted work | CONTAINMENT | Next candidate | CTA permits | Normal first access | Original result-read/Next only | May pause for original Side/Major boundary |
| CONTAINMENT | CONTAINMENT | PROFILE / CCTV | Visited | Yes | Review | 0 | Room draft/confirmed lock retained |
| CONTAINMENT | Any work | EXPERIMENT | Visited | Yes | Recorded result / draft display only | Execution/discovery/accounting 0 | Run/select/Recheck disabled |
| CONTAINMENT | Earlier review | CONTAINMENT | Yes | Yes | Existing room selection / final authorization | Navigation 0 | Saved draft or canonical confirmed lock |
| CONTAINMENT | CONTAINMENT | CONTAINMENT | Yes | Yes | Same View | 0 | No-op; no submission |
| EXPERIMENT or CONTAINMENT parent | Legacy CCTV recheck | Parent | Yes | Yes | Original Back path | No extra Gameplay | Clear recheck return and restore parent work |
| EXPERIMENT parent | Legacy CCTV recheck / another review | First CONTAINMENT | Next candidate | Parent CTA permits | Original Back then original Next | Only existing approved Next | First Containment or existing incident pause |
| Any | Modal / notice / restore pending | Any Nav | Irrelevant | No | None | 0 | Boundary stays |
| Response / terminal / no run | Response or Source Archive | Any work | Irrelevant | No | None | 0 | Cannot bypass response/no-run |

EXPERIMENT에서 원래 업무로 복귀한 경우 남은 횟수·실행 이력·선택 가능 여부는 기존 규칙을 그대로 따른다. CONTAINMENT 중 과거 EXPERIMENT를 표시해도 Main의 실제 실행 조건이 EXPERIMENT로 되돌아가지 않는다.

## 6. Direct Navigation Implementation

Main에 Runtime 단위 primitive snapshot `_work_screens`, 마지막 유효 업무 focus `_work_focus`, Runtime identity, presented stage, restore busy, held presented stage만 추가했다. Node나 owner/history를 View별로 복제하지 않는다. snapshot에는 기존 `capture_work_state()`의 draft/result ID/scroll/focus와 각 ScrollContainer의 경로·vertical 위치만 들어간다.

기존 `InterruptedWorkViewState` 검증과 View의 restore API를 재사용한다. 결과 문구와 조건은 실행 시 Runtime에 기록된 ID/조건을 읽고 다시 실행하지 않는다. layout 두 프레임 후 같은 active View인지 검증하고 복원한다. 다른 View로 교체되거나 queued 상태인 deferred restore는 적용하지 않는다. 새 Campaign entry/reset/auxiliary cleanup에서 캐시를 비운다. 새로운 Manager, Singleton, framework, source ownership State를 추가하지 않았다.

## 7. Archive Toggle / Esc

A가 열린 Archive에서 활성 상태로 남는다. A 재클릭, Esc, BACK은 같은 `_close_archive` 경로를 사용한다. 일반 업무의 Archive List와 Detail 모두 기존 held-work Node로 직접 복귀한다. `_utility_work_view`, canonical/presented stage, draw receipt 및 기존 focus 복원을 사용한다. 복귀한 뒤 held 참조를 해제하여 orphan을 남기지 않는다.

Modal은 자신의 Esc를 우선 처리하고, Drawer는 그 다음, Archive의 `_unhandled_key_input`은 남은 Esc만 처리한다. key echo는 무시한다. R/N/A는 Utility Rail 버튼이며 새 문자 단축키를 만들지 않았다.

## 8. Archive Direct Work Navigation

일반 업무 Archive에서 허용된 Nav 클릭은 held-work를 먼저 복원한 뒤 동일한 Nav 승인 경로를 수행한다. 방문한 다른 업무이면 순수 표시, held 업무와 같은 목적지면 같은 Node 복귀, 미방문 다음 업무이면 원래 Next 승인이다. locked 요청은 Archive를 닫지 않는다. Archive Detail에서도 원래 업무에 바로 복귀하므로 목록을 거치는 BACK이 필요 없다.

## 9. Response Source Archive Boundaries

| Archive source | A click | Esc | BACK (List or Detail) | Primary Nav click |
|---|---|---|---|---|
| Normal Work Archive | Same held work; toggle close | Same held work | Same held work directly | Allowed visited/next destination through work restore + Nav validation; locked stays Archive |
| Failure Source Archive | Original Incident/Broadcast/Result | Same Response stage/source | Same Response directly | Disabled; defensive request rejects; no Work resume |
| Sequential Scripted Source Archive | Original sequential Response | Same Response stage/source | Same Response directly | Disabled; no Campaign Continue/Case dispatch |
| Mid-Case Scripted Source Archive | Original Side Response | Same Response stage/source | Same Response directly | Disabled; no RESUME WORK/context release |

Response View은 기존 canonical response/source binding과 Broadcast draft를 읽어 복원한다. 새 response occurrence를 만들거나 confirmed option/result를 해제하지 않는다. Failure의 paused 업무, Sequential의 Campaign entry, Side의 exact-resume context를 각각 유지한다. Response Source Archive에서 일반 업무 Nav가 열리는 경로는 없다. Confirmed Broadcast lock을 A/Esc/BACK 후에도 확인했다.

## 10. Drawer Toggle / Esc

기존 R/N 재클릭 닫기·Esc·R↔N 전환을 실제 입력으로 확인했다. Drawer는 한 번에 하나이며 다른 Drawer로 전환하면 먼저 기존 cache를 캡처한다. Hypothesis 미저장 text/edit draft는 같은 Runtime에서 유지하고 자동 저장하지 않는다. 재방문 중 Research Rail도 표시 중인 View 기준으로 정상 요청한다. 사건에서는 기존 읽기 전용 Source Archive 정책을 따른다.

## 11. Focus / Scroll / Draft Preservation

보존 대상은 EXP 선택 draft/catalog scroll/recorded result/result scroll/focus, CONT room draft/room scroll/focus/confirmed lock, CCTV condition scroll/recheck return, PROFILE document scroll, N의 미저장 draft다. 재방문·현재 메뉴 재클릭·Drawer switch·Archive 복귀를 각각 검사했다.

마우스로 Nav를 누르면 focus가 외부 Nav로 이동하므로 마지막 유효 업무 focus를 별도로 기억한다. Modal 안의 focus는 업무 focus로 저장하지 않는다. 격리 확정 후 숨겨진 Confirm focus는 현재 보이는 Next CTA로 옮긴다. 유효하지 않은 primitive snapshot/restore는 warning과 input block으로 실패를 숨기지 않는다. Step62 memento schema와 failed-restore developer retry 계약은 변경하지 않았다.

## 12. Research / Experiment Protection

재방문은 source discovery, optional condition discovery, result-read token, opportunity, RNG를 변경하지 않는다. 순수 CCTV review에는 Runtime에서 이미 관찰한 조건만 표시한다. 원래 Recheck 동작은 기존 발견 규칙을 그대로 사용한다. 과거 EXP는 `set_review_only()`로 선택/Run/Recheck를 막으며 Main의 기존 EXP stage/Runtime/executed/limit 조건도 유지한다. recorded result는 기존 Runtime 이력에서 복원한다. 별도의 allowance/cost/history를 만들지 않았다.

## 13. Containment / Campaign Protection

Nav 자체가 room을 확정하거나 Pending/Resolution을 생성하지 않는다. 선택은 View draft, 최종 AUTHORIZE는 기존 Modal과 Main handler다. confirmed room 및 Pending/Resolution canonical record를 snapshot으로 덮어쓰지 않는다. 이미 확정한 room 변경/중복 확정은 거절한다. 새 entry에 대한 Nav access 이력은 reset되며 Campaign 순서와 completion 규칙은 Resource/기존 handler를 그대로 따른다.

## 14. Incident / Interrupt Compatibility

Response/notice/terminal, Side due, Side restore pending, closure busy, navigation restore busy, Modal을 Nav 경계로 검사했다. pure review에서는 Major 시작과 Side checkpoint/latch/start를 거절한다. 첫 업무 접근은 원래 CTA이므로 기존 Story-first/read-boundary/failure-offer 규칙을 따른다. 실제 Side result-read interrupt에서 source/context와 primitive work state가 원래대로 복원되고, Resume 직후 다음 사건을 자동 처리하지 않음을 확인했다.

CCTV recheck 중 parent 메뉴는 원래 BACK을 실행한다. 재확인 중 처음 CONTAINMENT를 요청하면 parent BACK 복원 후 기존 Next를 실행한다. canonical parent receipt를 새로 만들어 사건을 우회하지 않는다.

## 15. Actual Product Journey

원본 `resources/campaigns/test_campaign_01.tres`의 실제 Case01→Case02→TEMP Mandatory Incident01→Broadcast→Result→Case03을 사용했다. 새 Nav fixture는 첫 CCTV/EXP/CONT 진입과 이전 업무 재방문을 실제 포인터/키보드로 수행한다. Case01/02 실제 AUTHORIZE, TEMP의 실제 오답 Option C, Source Archive에서 실제 보존된 Case01 Research 선택, Campaign Continue를 확인했다. Case02 정상 업무에서도 Case01 Archive Detail을 A/Esc/BACK/Nav로 닫았다.

새 제품 여정은 headless/1920/1280 각 1회다. 별도 기존 제품 suite 7여정과 Step65 acceptance의 정답 A·오답 C 각 환경 2여정도 통과했다. 합성 long/Side/failure fixture를 제품 authored 여정으로 세지 않았다. Campaign/Case/TEMP Resource의 byte hash는 그대로다.

## 16. Pointer / Keyboard Verification

`InputEventMouseMotion`, `InputEventMouseButton` down/up, `InputEventKey` down/up를 실제 Godot Viewport에 전달했다. Button signal만 emit한 검사와 구별한다. visible/disabled/hit area를 검사하고 실제 GUI hit-test 및 focus/Space/Enter/Tab/ShiftTab/Esc/wheel 경로를 사용했다. 물리 OS 마우스 조작이나 인간 사용성 승인으로 표현하지 않는다.

최종 새 Nav 검사: headless 1920, Windows GPU 1920×1080, Windows GPU 1280×720에서 각각 **766 assertion 호출 / 763 기록 row**, 실패 0. 반복 helper 호출은 독립 scenario 수가 아니다. 별도 Step65 actual-input acceptance 각각 588검사도 통과했다. GPU는 AMD Radeon RX 6800 / OpenGL Compatibility다.

최소 10개 상태 캡처가 두 해상도 각각 존재한다. Source 종류 추가 3개를 포함해 Nav fixture는 각각 13개 고유 캡처를 저장했다.

| Required capture | File stem (suffix `_1920.png` / `_1280.png`) |
|---|---|
| 01 Profile + clickable Nav | `ui_66_01_profile_nav` |
| 02 CCTV via Nav | `ui_66_02_cctv_nav` |
| 03 Experiment via Nav | `ui_66_03_experiment_nav` |
| 04 Containment via Nav | `ui_66_04_containment_nav` |
| 05 Past Profile review | `ui_66_05_profile_review` |
| 06 Back to Containment | `ui_66_06_back_containment` |
| 07 Archive A toggle | `ui_66_07_archive_toggle` |
| 08 Archive direct CCTV | `ui_66_08_archive_direct_cctv` |
| 09 Response Source Archive | `ui_66_09_response_source_archive` |
| 10 Mid-Case exact resume | `ui_66_10_midcase_exact_resume` |

`../.godot/verification/step66/navigation_contact_1920.png`, `../.godot/verification/step66/navigation_contact_1280.png`. 실제 GPU contact sheet와 별도 full-size review/Archive 화면을 열어 Header·Nav·Rail·Actions의 clipping과 배치를 확인했다. 모델의 시각 검토이며 최종 디자인 승인이 아니다.

## 17. Negative / Stale / Duplicate Guards

locked EXP/CONT, current 메뉴 반복, Modal 뒤 pointer hit와 직접 늦은 요청, Response Source Archive에서 네 Nav pointer/request, 순수 review 실행/Side latch/start, queued Archive/Drawer/work callback, restore 중 두 번째 destination, 같은 frame의 A 두 번, confirmed containment 재확정, confirmed Broadcast 재사용을 검사했다. 정상 owner mutation 0과 실제 표시/Runtime identity를 함께 비교했다.

개발 중 재현·수정한 문제: 모달 focus가 업무 cache에 들어간 경우, 확정 후 숨겨진 Confirm focus, legacy recheck에서 처음 CONT 요청이 parent까지만 이동하던 경우, review 중 R 요청의 stage 불일치. 각각 업무 focus 필터/유효 CTA fallback, 원래 Back+Next, presented stage 요청으로 해결했다. 사본 getter 오기·중복 Case fixture와 구 Archive 기대값도 수정하고 재실행했다. 실패 attempt는 삭제하거나 PASS로 바꾸지 않았다.

## 18. Step62/63/64/65 Regression

최종 **86 process slot (native 10), 437,562 literal assertion 호출**, 모든 final slot 통과. 핵심 import/제품 53 script `--check-only`/configured Main headless+native 56실행, product/Side/guards/bounded/mixed/Facts/active terminal/cleanup/closure/keyboard/Campaign/ordering/gate/snapshot/UI/extra/acceptance/Nav를 포함한다. 이것은 독립 test case 437,562개라는 뜻이 아니다.

| Area | Final evidence / outcome |
|---|---|
| Godot 4.7.1 / GDScript / Main | `core-runs.json`; import + 53 checks + configured Main; PASS |
| Step58 typed sequential response / bounded handoff | `mixed-runs.json`, `bounded-runs.json`; PASS |
| Step60 Facts / source lifetime | `facts-runs.json`; typed/repeated detached read and invalid lifetime guards; PASS |
| Step62 exact resume / environment / collisions | `side-runs.json`, `side_guards-runs.json`, new Nav Side; PASS |
| Step63 real Campaign / Mandatory01 | `product-runs.json`, actual-input acceptance/Nav; PASS |
| Step64/65 Shell / modal / drawer / keyboard | `ui_*`, `acceptance_*`, `keyboard-runs.json`; PASS |
| Terminal / cleanup | `active-runs.json`, `cleanup-runs.json`, `closure-runs.json`, snapshot groups; PASS |
| Oldest action / meaningful read gate | `smoke-runs.json` ordering + gate; PASS |
| Dynamic list / long text | `extra_*`; EXP 1/3/6, room 2/4/8, research 1/40, archive 1/6, broadcast 2/4/6; PASS |
| Resize/aspect | GPU 1920/1280 plus `ui_1024-runs.json` at 1024×768; logical Shell dimensions/keep; PASS |

일반 product/runtime/parse/script 오류 및 warning 0. 의도한 controlled diagnostics는 active terminal WARN2, closure WARN13, ordering invalid content WARN4 합계 19이며 정상 실행 경고와 분리했다. Step66 normal gameplay에 경고가 있다는 뜻이 아니다.

이전 비활성 Nav/상세→목록→업무 BACK 기대값은 **Step66 사본**에서만 정책에 맞춰 변경했다. main guards/owner equality/assertion을 제거해 통과시키지 않았다. 최초 ordering timeout은 예전 Detail Back→List 가정으로 사본이 업무 View에 `%CaseList`를 요청한 원인이었고, 각 역사 자료 접근 전 Archive를 다시 열도록 사본을 고쳤다. 이후 ordering/gate PASS. 이전 검증 파일 60,896개의 final SHA-256 모두 동일, 삭제 0, Step66 밖 새 증거 0.

최종 성공 기준 1~12는 각각 Nav 클릭/Next 재사용/visited review, A/Esc/Archive Nav, Source boundaries, mutation guards, exact resume, 실제 Campaign, Shell/asset compatibility, pointer+keyboard, OPEN 유지의 위 증거로 대응한다.

## 19. Asset Swap Compatibility

`project.godot`는 그대로다: 기준 1920×1080, 기본 창 1280×720, `canvas_items`, 기본 aspect `keep`, GL Compatibility, 기존 clear color, configured `scenes/main/main.tscn`, 새 Autoload 0. 논리 Header72 / Nav176 / Rail56 / SystemBar40 / Workspace1688×968은 Scene 재배치 없이 유지했다.

17개 Scene, 모든 anchor/container/minimum size/focus/overlay hierarchy와 Profile/CCTV 이미지 slot, placeholder, font, shader/audio를 변경하지 않았다. Theme의 `CurrentNavButton/styles/normal`에 기존 primary StyleBox만 지정했다. 기존 색/semantic type/asset slot을 사용한다. Step65 Asset Swap Manifest의 Scene/slot/ratio는 그대로이며 이전 문서의 disabled indicator 정책만 이번 정책으로 supersede한다. 외부 에셋 다운로드·구매·라이선스 자산 추가 0.

## 20. Files / Main Impact

제품 수정 4개, 문서 수정 README 1개, 문서 신규 1개, 제품 신규/삭제 0. ignored QA는 Step66 namespace에만 생성했다.

| File | Responsibility / delta |
|---|---|
| `scripts/main/main.gd` | Nav validation/canonical-vs-presented/cache/Archive exit/Review guards; original CTA/owner/source functions retained |
| `scripts/ui/game_shell.gd` | Actual Button requests and allowed/current/review/locked presentation; obsolete indicator-only visited tracking removed |
| `scripts/views/experiment_view.gd` | Review-only selection/Run/Recheck UI; original execution validation/limit/result restore retained |
| `resources/ui/temp_industrial_theme.tres` | Current enabled Nav normal StyleBox uses existing primary |
| `README.md` | Step66 result/report link append; existing prefix retained |
| `docs/step66_navigation_interaction_ux_rework.md` | This 22-section report and two required matrices |

Main **142→151함수, 2601→2767줄**. 추가 9함수는 `_clear_work_navigation`, `_is_work_review`, `_navigation_work_stage`, `_on_work_focus_changed`, `_capture_work_navigation`, `_restore_navigation_screen`, `_on_work_navigation_requested`, `_close_archive`, `_unhandled_key_input`. 기존 18함수에 연결/표시/guard/복귀를 추가했고 함수 삭제 0. 세부 `change_audit.json` 참조. 판정/experiment execution/Campaign/source/terminal owner 구현을 새 subsystem으로 옮기지 않았다.

최종 Scene 구조는 기존 Main(Control) → GameShell(Control, `main.tscn` 내 Node) → Frame(Header / Body / SystemBar), Body(PrimaryNavigation / Workspace·ViewHost / UtilityRail), DrawerLayer·ModalLayer 그대로다. ViewHost 주요 View는 하나이며 기존 utility/confirmation/notice overlay만 별도다. 새로운 game_shell.tscn을 만들거나 있다고 가정하지 않았다.

Git: HEAD/branch/upstream 시작과 동일, staged 0, modified 5, created 1, deleted 0. `git diff --check` 통과. Git 상태·diff·numstat은 `git_audit.json`/`step66_delta.patch`에 보관했다. CRLF→LF 안내는 Git text 정규화 알림이며 공백 오류가 아니다.

## 21. Known Gaps

다음 기존 OPEN은 그대로다: completed Scripted terminal projection, Step53 prepared Pending P2, Step54 atomic rollback limitation, Step62 restore failure developer retry, Hypothesis getter P3. 새 Nav restore는 primitive 검증 실패 시 input을 막고 경고하며 자동 owner rollback/recovery framework를 제공하지 않는다. 유효한 실제 여정에서는 최종 실패 0이다.

Save/Load, Ending, Mandatory02/03, Final Assets, 경제/할당량/정산, 새 Story 조건/flags/새 사건 trigger를 구현하지 않았다. 임시 UI의 영어 label과 실제 authored TEMP 문구를 최종 문구라고 주장하지 않는다. 사용자 주관의 시각·조작 만족은 별도 리뷰다.

## 22. Next Step Recommendation

우선 에디터 F5에서 PROFILE→CCTV→EXPERIMENT→CONTAINMENT를 왼쪽 메뉴로 이동하고, 과거 Profile/CCTV/EXP를 확인한 뒤 CONT draft로 돌아오는 조작을 직접 확인하기 좋다. A/Esc로 Archive를 닫고, R/N 전환과 미저장 노트를 확인한다. 사건 중에는 SOURCE ARCHIVE만 읽고 원래 Response로 돌아온 뒤 기존 승인/RESUME WORK를 수행한다.

다음 작업은 이 Nav 정책을 유지한 실제 사용자 조작 피드백 또는 기존 Asset Swap Manifest에 따른 skin 검토부터 시작할 수 있다. terminal OPEN/정식 Story/Save를 다룰 때는 별도 범위와 계약을 먼저 정한다. 이번 변경이 이를 구현하거나 해결한 것으로 취급하지 않는다.
