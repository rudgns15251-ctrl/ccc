# Step65 — UI/UX Acceptance Validation + Structural Stabilization + Asset Swap Readiness

작성일: 2026-10-09. 판단 기준은 요청 원문과 작업 시작 시점의 실제 저장소다. 이 문서는 Step65 delta를 기록하며 Step55~64의 기존 미커밋 변경을 이번 단계 변경으로 계산하지 않는다.

결론: 기존 제품 Campaign과 UI 경계를 유지하면서 재현된 입력·포커스 문제를 최소 보완했다. 정식 에셋 적용 전 구조 검증은 통과했다. 사용자 시각 취향, 인간의 3초 탐색 시간, 실제 정식 에셋의 라이선스·호환성은 확정하지 않았다. Save, Ending, Mandatory02/03과 기존 terminal OPEN을 해결했다는 의미가 아니다.

증거 루트: `.godot/verification/step65/`. 요청 사본 `request.txt`, 시작 해시 `baseline.json`, 초기 재현 `before_input_probe.json`, 실행 이력 `invocations.jsonl`, 최종 결과 `final_summary.json`, 이전 증거 보존 `old_evidence_preservation.json`, 전체 단계별 diff `step65_delta.patch`를 참조한다. QA 파일과 스크린샷은 제품 에셋이 아니다.

## 1. Repo Baseline

작업 전 전체 비캐시 파일 162개, 제품 GDScript 53개, Scene 17개, `.tres` 6개를 조사했다. `project.godot`, 모든 Main/Shell/View/Modal/Drawer Scene·script·Theme, Step62 memento, 실제 Case/Campaign/TEMP Incident Resource, Git 상태, focus neighbour/mouse_filter/anchor/container/minimum size/scroll 소유 관계를 확인했다. 시작 파일 전부의 SHA-256과 사본을 보관했다. repo/상위 폴더의 적용할 AGENTS.md는 없었다.

HEAD `6e8f167f699a3a95c91fee8668ae99d03e5d4db9`, branch `master`, upstream `origin/main`, staged 0. 기존 Step55~64 변경과 미추적 파일은 시작 때부터 존재했다. 기준 Main은 실제 142함수/2600줄이었다. Step64 문서의 수치를 추정해 적용하지 않았다. 이전 verification 59,562개 해시도 확보했다.

## 2. Step64 Structure Audit

실제 구조는 Main(Control) → GameShell(Control) → Frame(VBoxContainer) → Header / Body(HBoxContainer) / SystemBar다. Body에는 PrimaryNavigation, Workspace/ViewHost, UtilityRail이 있다. 별도 DrawerLayer는 Workspace 위에 겹쳐 열리고 Main의 Drawer cache는 같은 Runtime 내 미완성 노트를 보존한다. Main의 held-work 경로는 Archive 동안 기존 작업 View를 보관한다. Modal은 View 소유이며 기존 canonical handler가 최종 승인만 처리한다.

논리 좌표에서 Header 72px, Nav 176px, Rail 56px, SystemBar 40px, Workspace 1688×968이다. ViewHost 안 주요 View는 한 개이며 의도된 Drawer/Modal/환경 경고 overlay만 겹친다. Step64 보고서의 held-work, overlay, typed side resume, stale guard와 실제 코드를 대조했다. Step65는 전체 Scene 재배치나 책임 재설계를 하지 않았다.

## 3. Full Product Journey UX Audit

실제 `resources/campaigns/test_campaign_01.tres`와 실제 authored Resource를 사용했다. 서로 새로 초기화한 Case01 성공 → Case02 성공 → TEMP Mandatory Incident01 → Broadcast → Result → Case03 Profile 경로를 검증했다. Option A와 실제 오답 Option C를 별도 실행했다. TEMP 중 실제 보존된 Case01 Research를 열고 문서를 선택한 뒤 응답에 복귀했다. 추가 기존 product suite는 authored 7 journey를 검증한다. controlled UI stress/side schedule은 이 실제 제품 여정 수에 포함하지 않는다.

각 Stage 이름은 Header·Nav에, 내용은 Workspace에, 다음 행동은 고정 Actions 영역에 있다. Research/Archive/Hypothesis Rail은 진행 버튼과 다른 위치·기능으로 구별된다. CTA 위치와 clipping을 검사했지만 사람이 3초 안에 찾았다고 시간을 측정한 주장은 하지 않는다. 최종 시각 강도는 사용자 검토 사항이다.

### UI Acceptance Matrix

PASS는 구조·입력·소유자 검사의 통과이며 미학 승인이 아니다. R/N은 Research/Hypothesis Drawer, A는 Archive다. Nav는 단계 지표로서 비활성이고 자유로운 이전 단계 이동 버튼이 아니다.

| Screen | Primary information | Primary CTA | Secondary tools | Scroll | Focus | Mouse | Drawer | Modal | Incident behavior | 1280 result | 1920 result |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Profile | Subject·분류·설명 | CCTV 진행 | R/N/A | Document | Tab/ShiftTab PASS | Space/Enter·pointer PASS | 동일 작업 보존 | 없음 | side 복귀 Profile focus | PASS | PASS |
| CCTV | Feed placeholder·관찰·현재 조건 | Experiment 진행 | R/N/A | ConditionObservation | PASS | PASS | 동일 작업 보존 | 없음 | 조건 scroll/recheck 복귀 | PASS | PASS |
| Experiment | Catalog·draft·실행 결과 | EXECUTE / Containment | R/N/A·Recheck | Catalog / Result 분리 | PASS·마지막 항목 노출 | 선택·실행 PASS | draft/result 보존 | 없음 | exact resume | PASS | PASS |
| Containment | Room 설명·draft·확정 lock | AUTHORIZE / 다음 Case | R/N/A·Recheck | Room / Detail 분리 | PASS | 선택·승인 PASS | draft/lock 보존 | 최초 0·최종 1 | exact resume·hidden outcome | PASS | PASS |
| Research Drawer | 발견한 현재 Case 기록 | CLOSE | Category/Entry | List / Detail | 내부 cycle PASS | 기록 선택 PASS | overlay | 없음 | Notice/Side 전에 닫음 | PASS | PASS |
| Hypothesis Drawer | 미완성 문구·작성 기록 | SAVE / UPDATE | Edit/Delete/CLOSE | Notebook | editor Tab 포함 PASS | CRUD PASS | overlay·동일 Runtime draft | 없음 | draft 보존 | PASS | PASS |
| Archive List/Detail | 보존 Case·Research·note 문서 | BACK | Case/Entry 선택 | 각 열·문서 분리 | 모든 활성 항목 PASS | 실제 body/wheel PASS | full Workspace | 없음 | source boundary/held work | PASS | PASS |
| Disturbance | 환경 조건 변경 알림 | DISMISS | 없음 | Banner text | Dismiss 복귀 | PASS | 선행 Drawer 닫음 | 없음 | fake Major 아님 | PASS | PASS |
| Failure Major Incident | 과거 source·paused work | Response 진행 | source A | Report | PASS | PASS | R/N 비활성 | 없음 | 현재 작업 보존 | PASS | PASS |
| Sequential Incident | Facility event·TEMP report | Response 진행 | actual prior A | Report | PASS | PASS | R/N 비활성 | 없음 | current Case null | PASS | PASS |
| Side Incident | Scripted source·paused work | Response 진행 | A | Report | PASS | PASS | 먼저 닫음 | 없음 | 같은 Runtime exact resume | PASS | PASS |
| Broadcast | prompt·options·draft/lock | CONFIRM / Result | A | Prompt / Options | PASS | 문구 전체 선택 PASS | R/N 비활성 | 최초 0·최종 1 | 기존 승인 의미 | PASS | PASS |
| Incident Result | 실제 응답 결과 | route별 CTA | A | Report | PASS | PASS | R/N 비활성 | 없음 | Failure/Side resume·Sequential continue | PASS | PASS |

## 4. CTA Consistency

PrimaryButton 스타일과 고정 Actions 행, 기본 논리 높이 48px을 유지했다. Profile/CCTV 진행, Experiment EXECUTE와 다음 단계, Containment AUTHORIZE와 다음 Case, Broadcast CONFIRM과 Result, route별 Result CTA를 검증했다. 아직 선택하지 않았거나 확정 lock 상태일 때 disabled 조건은 기존 데이터를 따른다. disabled 클릭으로 canonical owner가 변하지 않는 검사는 기존 guard suite가 수행한다.

Hypothesis Edit/Delete와 Archive Open의 최소 높이만 36→48px으로 정렬했다. 공개 gameplay API·조건·실행 제한은 바꾸지 않았다. Rail은 여전히 보조 도구이며 Nav AVAILABLE은 정보 표시이지 클릭 가능 상태가 아니다.

## 5. Keyboard Focus

재현: Research Drawer를 연 뒤 실제 Tab 25회에서 Workspace/Rail로 focus가 빠졌다. View-local `_refresh_drawer_focus()`가 현재 보이는 활성 Control만 모아 `focus_next/focus_previous`를 양방향 cycle로 연결한다. filter 변경·note CRUD·활성 버튼 변경 후 deferred 재계산한다. 숨은 컨트롤/disabled 버튼은 cycle에서 제외한다. LEGACY 표시에는 새 trap을 적용하지 않는다.

Hypothesis TextEdit는 Tab을 편집 입력으로 소비할 수 있어 같은 View의 `_input()`에서 현재 editor에 focus가 있고 기존 input guard가 허용하는 경우만 ui_focus_next/prev를 처리한다. ESC 기존 close 흐름과 canonical save handler는 유지했다. 새로운 FocusManager는 없다.

각 활성 작업/Archive/Drawer 항목을 focus하고 실제 Tab·ShiftTab 이벤트를 보내 이동·clipped rect·scope를 확인했다. Modal 양방향 trap, Space와 Enter 최종 승인, ESC 취소, Drawer 열기 focus/닫기 이전 focus를 검사했다. 마우스로 Rail을 눌러 연 경우 복귀 focus는 클릭한 Rail이며, 기존 keyboard focus로 열었다면 그 이전 focus다. 테스트 기대를 제품의 실제 정책에 맞췄다.

## 6. Mouse Interaction

새 acceptance fixture는 `.pressed.emit()`로 클릭을 대체하지 않는다. `Viewport.push_input(InputEventMouseMotion/MouseButton, true)`로 실제 Godot GUI hit-test 경로를 거친다. key도 실제 InputEventKey다. 물리 OS 마우스를 사람이 눌렀다는 주장은 하지 않는다. 기존 canonical/negative suite에는 의도적인 signal callback 호출도 있으며 둘을 구별한다.

Broadcast는 원래 1064×65px 행 중 40×65px CheckBox만 클릭 가능해 문구 클릭이 선택되지 않았다. CheckBox가 기존 문구를 직접 표시하며 행 폭을 차지하도록 바꿨다. 기존 index0 checkbox/index1 label 구조와 label snapshot은 보존하고 label만 숨겼다. `[Confirmed]` 표시도 checkbox text와 동기화한다. 실제 문구 위치의 80% 지점 pointer 클릭으로 선택되고 기존 승인/lock/정답 비공개 정책이 유지됨을 검사했다.

## 7. Scroll Ownership

기존 ScrollContainer에 `follow_focus = true`만 추가했다. 부모/이름/anchor/minsize/memento path는 유지한다. 기존 last-item focus가 clipped 상태였던 15 Experiment fixture에서 마지막 항목이 보이고 실제 nonzero scroll이 발생했다. 실제 wheel은 해당 Catalog에만 작용하고 Result scroll은 0을 유지했다.

Profile Document, CCTV 관찰, Experiment Catalog/Result, Room/RoomDetail, Research List/Detail, Hypothesis 목록, Archive 각 열/Detail, Broadcast Prompt/Options, Incident/Result Report가 독립 scroll owner다. 고정 CTA는 문서 scroll 밖에 있다. 긴 Archive 40기록/120줄 문서에 실제 클릭·wheel과 focus 검사를 추가했다. exact resume의 저장된 scroll을 재검증했고 follow-focus 때문에 추가로 훼손되는 재현은 없었다.

## 8. Information Density

기존 1920 논리 배치와 여백/Container 비율을 유지했다. 긴 텍스트는 autowrap와 각 문서 scroll로 수용하며 Actions는 화면 안에 고정된다. Header/Body/Footer 비중첩, Workspace 한 View, primary rect와 UI bounds를 검사했다. 프로토타입 텍스트의 밀도·패널 비율·Drawer 폭의 개인 취향은 자동 판정하지 않는다. 최종 폰트 교체 시 같은 긴 텍스트와 1280 검사를 다시 해야 한다.


## 9. Header / Navigation

Header의 Subject/Stage/Environment는 Main이 실제 owners에서 계산해 Shell에 전달한다. raw source ID를 새로 노출하지 않았다. Sequential TEMP는 Subject `FACILITY EVENT`이고 current Case가 null이며 Case03 dispatch 후 새 Subject/PROFILE로 갱신된다. Failure/Side는 실제 paused work stage를 보존한다. Source와 paused work의 문구는 Incident View의 기존 projection을 따른다.

Nav는 CURRENT/VISITED/AVAILABLE/LOCKED 문구와 CurrentNavButton variation으로 구별한다. 전부 disabled indicator이고 자유 Back navigation을 새로 만들지 않았다. Runtime 교체 시 방문 표시가 초기화된다. side resume 후 Header/Nav/Rail이 실제 restored Stage와 일치하는 검사를 다시 수행했다.

## 10. Utility Rail

기존 R/A/N Button은 기존 signals를 Main에 전달한다. 재현된 열린 도구 표시 누락을 Shell의 `show_active_utility(kind)`와 Theme의 ActiveRailButton으로 보완했다. Main `_refresh_shell()`에는 실제 Drawer kind 또는 Archive stage에 따른 표시 갱신 한 줄만 추가했다. enable 판정은 기존 `display()` 입력 그대로다. Drawer Close 시 활성 skin은 해제되고 Archive 동안 A 표시를 유지한다. 이미지 icon은 적용하지 않았다.

## 11. Research Drawer

현재 Case에서 실제 발견한 snapshot만 표시한다. Category filter와 Entry 선택은 표시만 바꾸고 발견·실행·Facts를 새로 기록하지 않는다. 680px Drawer overlay 동안 작업 View와 Runtime은 동일하다. 새 focus cycle은 동적 항목 재생성 뒤 갱신된다. 1/40기록, 100줄 body의 별도 scroll 검사를 수행했다. 실제 authored Profile 기록 선택·body 표시·ESC 복귀에서 canonical owner가 동일함을 비교했다.

## 12. Hypothesis Drawer

560px Drawer에서 작성 초안·기존 CRUD·글자 제한을 사용한다. SAVE/UPDATE/Edit/Delete 실제 pointer와 editor focus를 검사했다. 새 Tab handler는 note 본문/최대 길이/저장 정책을 변경하지 않는다. 작업·Case identity가 같은 동안 경고/Side 닫기·재열기 후 미완성 draft가 보존된다. cleanup에서 cache/Drawer가 제거된다. 디스크 저장이나 session persistence를 추가하지 않았다. 기존 Hypothesis getter P3는 OPEN이다.

## 13. Archive

현재 작업은 Main의 held-work로 보관하고 Archive는 full Workspace에서 표시한다. List에서 Case를 고르고 Detail에서 문서를 읽은 뒤 BACK으로 복귀한다. 처음 Case01 Profile 때 Archive List가 비어 있는 것은 정상이다. 존재하지 않는 현재 Case의 보존 기록을 fixture 기대에 맞춰 생성하지 않았다.

실제 TEMP 동안 actual archived Case01의 문서를 pointer로 열었다. controlled snapshot은 Case1/6 목록과 Research40/120줄 문서 표시 stress에만 사용했다. 마지막 항목 클릭·document wheel·모든 focusable 항목 Tab/ShiftTab과 고정 Back 위치를 검증했다. 보조 탐색이 current Runtime/failure candidate/cursor/RNG/research discovery를 mutate하지 않음과 같은 work instance 복귀를 검사했다. Archive Open 높이만 48px으로 정렬했다.

## 14. Containment

room draft, authored description, 확정 뒤 lock을 표시한다. 정답/위험도/성공 여부를 새로 예측하지 않는다. 최초 AUTHORIZE는 Modal만 열고 Pending/canonical owner mutation은 0이다. Cancel/ESC도 0이며 최종 Modal AUTHORIZE가 기존 signal/handler를 한 번 실행한다. 중복 callback, stale/queued View, replaced Modal이 Pending을 다시 쓰지 않는 guard를 검증했다. Room2/4/8과 긴 detail scroll, draft/lock/focus/scroll exact resume도 유지했다.

## 15. Broadcast

prompt 하나와 authored options를 유지한다. 문구 전체 행 pointer 선택만 개선했고 option ID/group/draft/snapshot API·정답 판정·승인 의미는 그대로다. 최초 CONFIRM은 Modal이며 mutation0, ESC/Cancel0, 최종 TRANSMIT만 기존 승인 한 번이다. 결과가 확정되면 selection lock과 `[Confirmed]` 표시, Result CTA가 나타난다. 실제 Option A/C와 기존 B/D product 경로를 검증했다. 2/4/6옵션과 긴 prompt/option text를 별도 scroll에서 수용했다. final confirm 전에 correct/wrong 단서를 새로 노출하지 않는다.

## 16. Incident Type Comparison

| Type | Source | Current work | Result CTA / continuation | UI verification |
|---|---|---|---|---|
| Failure Major | 이전 실패 Case의 실제 Candidate | 현재 Case 작업 보존 | 기존 work로 resume | bounded path·source Archive·screen11 |
| Sequential Scripted | authored Campaign entry/TEMP Incident01 | current Case null | CONTINUE CAMPAIGN → Case03 | actual all-success/wrong option·screen12/15/19 |
| Mid-Case Scripted | typed interrupt occurrence | 같은 Case/Runtime·memento | paused work resume | controlled side schedule·screen16/17/18 |

세 route 모두 실제 response source의 Broadcast와 결과를 표시한다. Result에 임의의 공통 next policy를 덮어쓰지 않았다. side schedule은 현재 authored Campaign에서 비어 있으며 fixture의 typed schedule은 기능 검증용이다. Mandatory02/03을 제품에 추가하지 않았다.

## 17. Environmental Disturbance

기존 알림·현재 활성 환경 조건·Dismiss 경계를 유지했다. disturbance는 Major Incident/Scripted response의 대체 화면이 아니다. 기존 `_show_disturbance_notice()`는 Drawer를 닫고 work input을 pause하며 Dismiss가 동일 work로 복귀한다. warning asset swap용 숨은 TextureRect 슬롯만 추가했다. 빈 slot은 input을 무시하고 현재 layout에는 참여하지 않는다.

실제 Failure 환경 알림 screenshot과 기존 Notice+Side guard를 재검증했다. 추가 display-only fixture는 existing authored disturbance를 표시할 뿐 accounting/discovery를 fabricate하지 않는다. Drawer draft 보존·단일 Notice·owner equality·Dismiss 동일 work를 실제 pointer로 검사했다.

## 18. Modal / Drawer / Interrupt Collision

| Collision | Expected existing boundary | Evidence |
|---|---|---|
| Drawer + Notice | Drawer 닫고 Notice 하나, Dismiss 동일 work, note draft 보존 | new acceptance drawer_notice_* |
| Drawer + Side | Drawer 닫고 기존 typed due response, 같은 work/UI state 복원 | extra collision(false) |
| Modal + Side | 승인 중 interrupt 시작 차단, Cancel 뒤 safe draw에서 시작 | extra collision(true) |
| Notice + Side | 먼저 Notice 완료, due intent 유지·안전한 뒤 Side 시작 | side H_notice_* |
| stale/replaced Modal | 기존 canonical owner mutation0 | extra stale_modal·product/guard |
| terminal cleanup + aux UI | Drawer/cache 제거·NO ACTIVE RUN, source 재생성 없음 | extra aux_cleanup·cleanup/active/closure |

collision fixture는 이미 도달한 checkpoint/due intent 또는 기존 데이터를 명시적으로 제어한 검사다. 제품 trigger/threshold/RNG policy를 새로 변경했다고 주장하지 않는다. 첫 Modal click/ESC 시 owner 비교와 최종 승인은 새 pointer/key 경로에서도 확인했다.

## 19. Dynamic Content

duplicated Resource/snapshot에만 Experiment1/3/6, Room2/4/8, Option2/4/6, Research1/40, Archive Case1/6 데이터를 주입했다. 제품 배열 길이와 Child count가 일치하며 목록 scroll과 fixed CTA가 유지됐다. 별도 15 Experiment와 Archive Research40은 pointer/wheel/focus stress다. 모든 authored product Resource의 byte hash는 그대로다. 특정 버튼 개수에 맞춘 Main 하드코딩은 추가하지 않았다.

## 20. Long Text

Profile120줄, Experiment description120줄/result100줄, Incident120줄, Broadcast prompt100줄/option16줄, Result120줄, Research100줄, Archive document120줄을 검증했다. overflow가 실제 scrollbar max/page를 넘고 vertical scroll이 nonzero가 되며 문구가 pane 폭 안에서 wrap된다. 스크롤 문서가 CTA를 밀어내지 않는 rect 검사를 수행했다. stress copy는 제품 content로 저장하지 않았다. 사람마다 다른 읽기 속도나 최종 font의 가독성을 승인한 것은 아니다.

## 21. Resolution / Scaling

`project.godot` byte 그대로: 1920×1080 viewport, 1280×720 window override, canvas_items stretch, 기본 keep 비율, Compatibility renderer. Autoload0. Main configured 실행과 native Windows GL 검증을 완료했다. Scene/target 높이 변경이 있으므로 1024×768 추가 letterbox 회귀도 수행했다.

1920과1280 각각 필수19 Scene/state screenshot을 생성했다. 1280 필수 Profile/Experiment/Containment/Archive/Broadcast/Modal을 포함한다. 실제 image dimensions와 Shell/View rect를 확인했다. 검증은 command-line configured Main 실행이며 에디터에서 사람이 물리 F5를 누른 검사가 아니다. 기존 Main 설정으로 F5가 같은 Scene을 실행한다.

## 22. Theme Readability

기존 TEMP Theme 색/폰트/StyleBox를 유지하고 ActiveRailButton normal만 기존 primary StyleBox를 참조했다. default22, Title32, Heading26, Muted18, Nav18은 그대로다. 선택/실행 완료/확정/잠금은 checkbox·문구·disabled와 focus outline으로 구별한다. Warning/ Emergency는 서로 다른 panel tone과 실제 문맥 텍스트로 구별한다. 상세 contrast 수치는 최종 검증 요약에 기록한다. sRGB 값의 참고 contrast 계산이며 모든 테마 상태에 대한 접근성 인증은 아니다.

최종 녹색 톤·border texture·폰트 분위기를 자동으로 결정하지 않았다. disabled 텍스트의 시각 강도, active Rail과 current Nav의 구별은 사용자 checklist로 남긴다. 외부 font/texture/shader/audio0이다.

## 23. Step62 Exact Resume

기존 InterruptedWorkViewState helper byte와 whitelist path를 보존했다. Profile focus, CCTV condition scroll/recheck, Experiment draft/displayed result/history/list+result scroll/focus, Containment draft/lock/scroll/focus를 side/side_guards에서 다시 검증했다. Shell Header/Nav/Rail restored stage도 UI suite에서 검사했다.

중요 의존 경로는 `Margin/Content/Workspace/Catalog/ExperimentScroll/ExperimentList/ExperimentN/Select`, `Margin/Content/RoomScroll/RoomList/RoomN/Select`, 기존 Actions 이름과 recheck path다. 부모·동적 이름·capture/restore API는 바꾸지 않았다. asset swap은 Theme/icon/texture properties에서만 해야 한다. focus-follow 변화 후 primitive memento equality와 Runtime instance/canonical owners/RNG/cursor equality가 통과했다. restore failure의 fail-closed/developer retry OPEN을 자동 복구 기능으로 바꾸지 않았다.

## 24. Step63 Product Campaign

실제 authored 순서는 CASE01 → CASE02 → TEMP Mandatory Incident01 → CASE03 그대로다. Case/Campaign/TEMP `.tres` byte 보존을 확인했다. Option A 성공/Option C 오답을 새 pointer/key journey로 실행했고 기존 product suite의7경로도 유지했다. TEMP의 actual archived Case01 Research와 Case03 fresh Profile을 확인했다. Failure bounded와 Sequential/Side source lifetime·Facts/terminal 경계는 영향권 회귀로 보호했다. 제품 데이터나 gameplay 규칙을 UI 검사 편의를 위해 수정하지 않았다.


## 25. Asset Swap Manifest

현재 외부 정식 에셋은 0이다. 아래는 교체 위치와 **타입 후보**이며 실제 외부 파일/API가 존재한다는 가정이 아니다. Obssidian / Dead Channel / eXP Themes / VHS UI는 CANDIDATE 이름일 뿐, 설치·구매·다운로드·라이선스 검증하지 않았다. 향후 사용자가 선택한 정식 에셋의 라이선스를 먼저 확인하고 Theme/Icon/Texture 속성에 적용해야 한다. asset의 minimum size/StyleBox content margin 때문에 발생할 layout 차이는 다시 검증해야 한다.

경로 약칭 T=`resources/ui/temp_industrial_theme.tres`, M=`scenes/main/main.tscn`, V=`scenes/views/`, U=`scenes/ui/`. NO는 static skin 교체 기준이다. 실제 CCTV 영상·애니메이션·새 gameplay 연동을 의미하지 않는다.

| Slot | TEMP Current | Final Replacement Candidate | Scene/Theme path | Gameplay dependency | Requires code change? | Requires hierarchy change? |
|---|---|---|---|---|---|---|
| BASE THEME | 내장 font·StyleBoxFlat | 정식 Godot Theme 리소스 | M Main.theme / T | 없음, Theme inheritance | NO | NO |
| Panel Normal | panel flat | StyleBoxTexture/Flat | T PanelContainer/styles/panel | 없음 | NO | NO |
| Panel Warning | warning flat | warning border/panel style | T WarningPanel/styles/panel | 없음 | NO | NO |
| Panel Emergency | emergency flat | emergency style | T EmergencyPanel/styles/panel | 없음 | NO | NO |
| Panel System | system flat | system strip style | T SystemPanel/styles/panel | 없음 | NO | NO |
| Button Normal | button flat | normal style | T Button/styles/normal | 기존 Button signal 유지 | NO | NO |
| Button Hover | hover flat | hover style | T Button/styles/hover | 없음 | NO | NO |
| Button Pressed | pressed flat | pressed style | T Button/styles/pressed | 없음 | NO | NO |
| Button Disabled | disabled flat | disabled style | T Button/styles/disabled | canonical enabled 판정 유지 | NO | NO |
| Button Focus | focus outline | visible focus border | T Button/styles/focus | focus path 유지 | NO | NO |
| Primary CTA | primary flat | primary emphasis style | T PrimaryButton/styles/normal | Actions/Button identity 유지 | NO | NO |
| Nav Current | current primary + CURRENT | current indicator style | T CurrentNavButton/styles/disabled | 실제 work_stage 입력 유지 | NO | NO |
| Nav Locked | disabled + LOCKED | locked indicator style | T NavButton / M Navigation buttons | Nav는 indicator 정책 유지 | NO | NO |
| Rail Button / Active | Button / ActiveRailButton | rail normal/active styles | T ActiveRailButton/styles/normal / M UtilityRail/Tools | 실제 kind 전달 유지 | NO | NO |
| Scrollbar | Godot 기본 Theme fallback | scroll/grabber style·icons | T에서 HScrollBar/VScrollBar Theme items, 기존 ScrollContainer 유지 | scroll owner/memento 유지 | NO | NO |
| Checkbox / Radio | Godot 기본 indicator + 현 Button styles | checked/unchecked/radio Theme icons | T CheckBox Theme items / existing generated CheckBox | IDs/ButtonGroup 유지 | NO | NO |
| Modal Backdrop | semi-transparent flat | backdrop style | T ModalBackdropPanel/styles/panel / U confirmation_modal.tscn | modal input trap 유지 | NO | NO |
| Header icon/logo | 숨은 빈 TextureRect | 정식 static Texture2D | M Main/GameShell/Frame/Header/HeaderRow/HeaderIconSlot.texture·visible | 없음, mouse_ignore | NO | NO |
| Research icon | R text Button | 정식 Button.icon Texture2D | M %Research.icon / text | research_requested 동일 | NO | NO |
| Archive icon | A text Button | 정식 Button.icon Texture2D | M %Archive.icon / text | archive_requested 동일 | NO | NO |
| Hypothesis icon | N text Button | 정식 Button.icon Texture2D | M %Hypothesis.icon / text | hypothesis_requested 동일 | NO | NO |
| Warning icon | 숨은 빈 TextureRect | 정식 static Texture2D | V environmental_disturbance_notice.tscn Banner/BannerRow/WarningIconSlot.texture·visible | 없음, mouse_ignore | NO | NO |
| CCTV frame/overlay | PanelContainer + placeholder | static frame/StyleBoxTexture | V cctv_view.tscn Margin/Content/Workspace/Feed/CameraImage theme_override_styles/panel | 실제 feed 로직 없음; 관찰·resume 무관 | NO | NO |
| Incident visual | PanelContainer + placeholder | static report illustration StyleBoxTexture | V incident_view.tscn Margin/Content/Workspace/Report/IncidentImage theme_override_styles/panel | response source semantics 무관 | NO | NO |
| Profile visual | PanelContainer + placeholder | static subject portrait StyleBoxTexture | V profile_view.tscn Margin/Content/Workspace/Identity/SubjectImage theme_override_styles/panel | Case data 변경 불필요 | NO | NO |

새 Header/Warning TextureRect는 빈 숨은 슬롯이다. 기존 gameplay/memento node를 이동·rename하지 않았다. 향후 texture를 지정하고 visible을 켜는 Scene property 변경만으로 static icon을 넣을 수 있다. 내장 scrollbar/checkbox Theme item은 Godot Inspector에서 확인해 등록해야 하며 특정 외부 plugin의 setter API를 가정하지 않는다.

## 26. Hardcoding Audit

Main/runtime/data/read_models에서 외부 패키지명·texture filename·새 font/shader/audio preload 의존을 추가하지 않았다. 기존 Main Scene preload와 Main의 Scene path는 화면 dispatch를 위한 실제 프로젝트 dependency이지 skin filename gameplay dependency가 아니다. 화면별 minsize/폭과 palette는 Scene/Theme에 있으며 canonical gameplay code에 texture 크기별 판정을 넣지 않았다.

실제 memento의 node path dependency는 계속 존재한다. 이를 generic serializer로 추상화하지 않는다. 정식 static skin은 Theme/StyleBoxTexture/Button.icon/기존 slot의 texture에 적용하면 기존 focus path를 바꿀 필요가 없다. 새 asset의 margin/font metrics가 바뀌면 UI 검증을 반복해야 한다. NO CODE CHANGE는 asset 종류를 초월한 보장이 아니며 새 영상·animation 기능은 별도 범위다.

## 27. Human Review Package

1920×1080 우선 필수19 화면과 1280×720 동일19 화면을 보관했다. 원본은 `.godot/verification/step65/ui_<state>_<width>.png`, contact sheet는 `.godot/verification/step65/contact_sheet_1920.png`이다. 1024×768 window의 keep 비율 검사는 1024×576 viewport 콘텐츠 캡처이므로 OS 전체 window/letterbox screenshot이라고 부르지 않는다. 추가 long-text screenshot도 QA 루트에만 존재한다.

| Review state | 1920×1080 | 1280×720 |
|---|---|---|
|01_profile_shell|[ui_01_profile_shell_1920.png](../.godot/verification/step65/ui_01_profile_shell_1920.png)|[ui_01_profile_shell_1280.png](../.godot/verification/step65/ui_01_profile_shell_1280.png)|
|02_cctv|[ui_02_cctv_1920.png](../.godot/verification/step65/ui_02_cctv_1920.png)|[ui_02_cctv_1280.png](../.godot/verification/step65/ui_02_cctv_1280.png)|
|03_experiment_selection|[ui_03_experiment_selection_1920.png](../.godot/verification/step65/ui_03_experiment_selection_1920.png)|[ui_03_experiment_selection_1280.png](../.godot/verification/step65/ui_03_experiment_selection_1280.png)|
|04_experiment_result|[ui_04_experiment_result_1920.png](../.godot/verification/step65/ui_04_experiment_result_1920.png)|[ui_04_experiment_result_1280.png](../.godot/verification/step65/ui_04_experiment_result_1280.png)|
|05_containment_rooms|[ui_05_containment_rooms_1920.png](../.godot/verification/step65/ui_05_containment_rooms_1920.png)|[ui_05_containment_rooms_1280.png](../.godot/verification/step65/ui_05_containment_rooms_1280.png)|
|06_containment_modal|[ui_06_containment_modal_1920.png](../.godot/verification/step65/ui_06_containment_modal_1920.png)|[ui_06_containment_modal_1280.png](../.godot/verification/step65/ui_06_containment_modal_1280.png)|
|07_research_drawer|[ui_07_research_drawer_1920.png](../.godot/verification/step65/ui_07_research_drawer_1920.png)|[ui_07_research_drawer_1280.png](../.godot/verification/step65/ui_07_research_drawer_1280.png)|
|08_research_archive|[ui_08_research_archive_1920.png](../.godot/verification/step65/ui_08_research_archive_1920.png)|[ui_08_research_archive_1280.png](../.godot/verification/step65/ui_08_research_archive_1280.png)|
|09_hypothesis_drawer|[ui_09_hypothesis_drawer_1920.png](../.godot/verification/step65/ui_09_hypothesis_drawer_1920.png)|[ui_09_hypothesis_drawer_1280.png](../.godot/verification/step65/ui_09_hypothesis_drawer_1280.png)|
|10_environmental_disturbance|[ui_10_environmental_disturbance_1920.png](../.godot/verification/step65/ui_10_environmental_disturbance_1920.png)|[ui_10_environmental_disturbance_1280.png](../.godot/verification/step65/ui_10_environmental_disturbance_1280.png)|
|11_failure_incident|[ui_11_failure_incident_1920.png](../.godot/verification/step65/ui_11_failure_incident_1920.png)|[ui_11_failure_incident_1280.png](../.godot/verification/step65/ui_11_failure_incident_1280.png)|
|12_temp_sequential_incident|[ui_12_temp_sequential_incident_1920.png](../.godot/verification/step65/ui_12_temp_sequential_incident_1920.png)|[ui_12_temp_sequential_incident_1280.png](../.godot/verification/step65/ui_12_temp_sequential_incident_1280.png)|
|13_broadcast_four_options|[ui_13_broadcast_four_options_1920.png](../.godot/verification/step65/ui_13_broadcast_four_options_1920.png)|[ui_13_broadcast_four_options_1280.png](../.godot/verification/step65/ui_13_broadcast_four_options_1280.png)|
|14_broadcast_modal|[ui_14_broadcast_modal_1920.png](../.godot/verification/step65/ui_14_broadcast_modal_1920.png)|[ui_14_broadcast_modal_1280.png](../.godot/verification/step65/ui_14_broadcast_modal_1280.png)|
|15_sequential_result|[ui_15_sequential_result_1920.png](../.godot/verification/step65/ui_15_sequential_result_1920.png)|[ui_15_sequential_result_1280.png](../.godot/verification/step65/ui_15_sequential_result_1280.png)|
|16_side_result|[ui_16_side_result_1920.png](../.godot/verification/step65/ui_16_side_result_1920.png)|[ui_16_side_result_1280.png](../.godot/verification/step65/ui_16_side_result_1280.png)|
|17_experiment_resume|[ui_17_experiment_resume_1920.png](../.godot/verification/step65/ui_17_experiment_resume_1920.png)|[ui_17_experiment_resume_1280.png](../.godot/verification/step65/ui_17_experiment_resume_1280.png)|
|18_containment_resume|[ui_18_containment_resume_1920.png](../.godot/verification/step65/ui_18_containment_resume_1920.png)|[ui_18_containment_resume_1280.png](../.godot/verification/step65/ui_18_containment_resume_1280.png)|
|19_case03_profile|[ui_19_case03_profile_1920.png](../.godot/verification/step65/ui_19_case03_profile_1920.png)|[ui_19_case03_profile_1280.png](../.godot/verification/step65/ui_19_case03_profile_1280.png)|

[1920×1080 Contact sheet](../.godot/verification/step65/contact_sheet_1920.png) — mandatory19의 축소 배치. 원본39개(19×2+contact sheet)는 별도 QA 파일이며 long/1024는 추가 증거다.

실제 contact sheet와 1280 Broadcast/Hypothesis 원본을 열어 layout·문구·CTA·활성 Rail 표시를 확인했다. crop된 것은 의도된 Drawer 뒤 작업 영역과 scroll viewport이며 CTA가 문서 밖으로 밀려 숨는 재현은 없었다. contact sheet 축소 썸네일로 폰트 가독성을 승인하지 않고 원본을 사용자 검토에 제공한다. 최종 checklist는 문서 마지막에 있다.

### Visual / input issue log

| ID | Screen | Reproduction | Objective issue | Fix | Verification |
|---|---|---|---|---|---|
| UI65-01 | Research/Hypothesis Drawer | 열기 후 Tab25 | focus가 Workspace/Rail로 누출 | visible/enabled local cycle | before_input_probe.drawer_tab_leak=true → 새 양방향 trap PASS |
| UI65-02 | Rail | Research 열기 | 열린 도구 variation 빈 문자열 | ActiveRailButton + Shell helper | active kind·close clear·Archive skin PASS |
| UI65-03 | Broadcast | option 문구 중심 클릭 | 1064×65 행 중 40×65 체크만 hit | full-width CheckBox text, 기존 child snapshot 보존 | 문구80% 위치 실제 pointer 선택 PASS |
| UI65-04 | 긴 Catalog | 15 Experiment 마지막 항목 focus | focus 항목 clipped·scroll0 | ScrollContainer follow_focus | 마지막 항목 visible/nonzero·wheel owner PASS |
| UI65-05 | Hypothesis editor | editor에 Tab/ShiftTab | editor가 Tab을 소비해 다음 focus로 이동하지 않음 | guarded local ui_focus 처리 | strict focus!=previous·cycle PASS |
| UI65-06 | Note/Archive actions | 기존 target min36 | 공통 CTA48과 다른 작은 목표 | Edit/Delete/Open min48 | 실제 visible hit-height44+ PASS |

기능상 문제는 위 delta로 해결했다. 최종 색·font·placeholder 비율의 주관적 변경은 하지 않았다. 새로운 미해결 P0/P1/P2/P3를 관찰하지 않았다는 범위의 결과이며 모든 가능한 사용자 환경의 무결함 보증은 아니다. 기존 OPEN은 §30에 남긴다.

## 28. Regression

최종 **75 Godot process slots(native8/headless67)** PASS. **428,626 literal assertion calls**를 수행했다. 새 Step65 acceptance는 환경별 **588개 named/literal 검사**, actual authored2journey씩 headless/1920/1280에서 반복했다. 기존 product7journey와 controlled side15journey는 별도로 기록한다. 이 반복 횟수를 새로운 독립 시나리오 수로 합산하지 않는다. ledger 전체155 completed attempts에는 초기 실패2와 중간 성공·반복이 포함된다. before probe 직접 실행 및 종료 기록은 ledger 밖에 별도로 있다.

| Final group | Process slots | Literal calls | Evidence |
|---|---:|---:|---|
| Core import/scripts/Main |56|검사 결과 exit/diagnostic|core-runs.json|
|acceptance_headless|1|588|acceptance_headless-runs.json|
|acceptance_1920|1|588|acceptance_1920-runs.json|
|acceptance_1280|1|588|acceptance_1280-runs.json|
|mixed|1|168|mixed-runs.json|
|bounded|1|180|bounded-runs.json|
|facts|1|411594|facts-runs.json|
|side|1|6237|side-runs.json|
|side_guards|1|1211|side_guards-runs.json|
|product|1|1888|product-runs.json|
|active|1|708|active-runs.json|
|cleanup|1|1130|cleanup-runs.json|
|closure|1|460|closure-runs.json|
|ui_headless|1|155|ui_headless-runs.json|
|ui_1280|1|155|ui_1280-runs.json|
|ui_1920|1|155|ui_1920-runs.json|
|extra_headless|1|886|extra_headless-runs.json|
|extra_1280|1|890|extra_1280-runs.json|
|extra_1920|1|890|extra_1920-runs.json|
|ui_1024|1|155|ui_1024-runs.json|

정상 WARN/ERROR0; controlled WARN15(active2+closure13), controlled ERROR0; 최종 unexpected runtime/SCRIPT/PARSE0. 참고 sRGB contrast: normal/panel12.74, disabled/disabled4.35, muted/panel6.90, warning/warning6.08, focus/button9.79. disabled4.35를 일반 본문 대비 기준 통과로 단정하지 않는다. Palette를 이번 단계에서 변경하지 않았다.

검사 범위: fresh editor import; 모든 제품53 GDScript check-only; configured Main headless/native; 실제 authored 제품 journey; Step58 mixed/ bounded Failure; Step60 typed FactQueries/lifetime; Step62 side/guards; Step63 product; Step64 UI/extra; active termination/closure/cleanup 핵심. 수를 늘리기 위해 모든 과거 exhaustive suite를 돌리지 않았다. Main/View 공통 표시에 영향을 받는 suite는 Step65 namespace 복사본에서 다시 수행했다.

실행은 `run.py`의 고유 attempt directory에 stdout/stderr/Godot log를 보관하고 ledger에 exit·WARN·ERROR·SCRIPT/PARSE를 기록했다. `*-runs.json`은 마지막 성공 결과를 가리키므로 ledger 전체와 중복된다. copied fixture303파일은 실행303회가 아니다. normal WARN/ERROR0, closure13WARN/active2WARN은 의도된 거부 경계이며 expected count를 검증한다. 최종 unexpected runtime/SCRIPT/PARSE0이다.

### Initial failures and corrections

- 첫 before probe가 유효 response 없이 Broadcast를 Main에 열려 했다. fixture의 잘못된 가정으로 warning/null script error와 대기가 발생했다. 자신의 정확한 Godot process만 종료했고 로그 `initial_probe_missing_response.log`를 보존했다. existing actual TEMP broadcast Resource로 독립 UI fixture를 구성해 재현했다. 제품 Resource를 만들거나 response 정책을 바꾸지 않았다.
- 새 acceptance에서 mouse로 Rail을 열고 NextButton focus 복귀를 기대했던 것은 잘못된 fixture 기대였다. 실제 정책은 클릭 직전 Rail focus를 보관한다. current Case01의 Archive가 비어 있는데 Detail row0을 접근했던 오류도 수정했다. 이미 archived된 실제 TEMP Case01 경로에서 검증했다. immutable failed attempts를 보존했다.
- strict editor Tab 검사에서 실제 local focus 이동 문제를 확인해 UI65-05를 보완했다. 이전346/402/418 검사 수는 중간 fixture 단계이며 최종 수와 더해 독립 scenario라고 하지 않는다.
- 첫 native acceptance는 down/up를 서로 다른 frame에 주입했을 때 ESC 뒤 재열기 클릭이 실패하고 null Modal cascade가 났다. Windows 이벤트 interleaving이 원인이라는 해석에 따라 입력 쌍을 연속 전달했다. 제품 코드 변경 없이 fixture의 input down/up를 연속 전달하도록 고쳤다. 동일1920/1280 실제 native 입력 journey가 통과했다. 초기6 ERROR/2 SCRIPT ERROR는 해당 실패 attempt에 남아 있으며 최종 runtime error로 은폐하지 않는다.

## 29. Files / Main Impact

Main **142함수/2600줄 → 142함수/2601줄**. delta는 `_refresh_shell()`의 `game_shell.show_active_utility(...)` **한 줄**이다. 수정된 기존 제품 파일은21개, README append를 포함하면22개다. 신규 관리 파일은 이 보고서1개다. 이전 미커밋 변경을 제외한 목록:

- `scripts/views/research_log_view.gd`
- `scripts/views/research_archive_list_view.gd`
- `scripts/views/broadcast_view.gd`
- `scripts/ui/game_shell.gd`
- `scripts/main/main.gd`
- `scenes/views/result_view.tscn`
- `scenes/views/research_log_view.tscn`
- `scenes/views/research_archive_list_view.tscn`
- `scenes/views/research_archive_detail_view.tscn`
- `scenes/views/profile_view.tscn`
- `scenes/views/monitoring_view.tscn`
- `scenes/views/incident_view.tscn`
- `scenes/views/incident_result_view.tscn`
- `scenes/views/experiment_view.tscn`
- `scenes/views/environment_conditions_view.tscn`
- `scenes/views/environmental_disturbance_notice.tscn`
- `scenes/views/containment_view.tscn`
- `scenes/views/cctv_view.tscn`
- `scenes/views/broadcast_view.tscn`
- `scenes/main/main.tscn`
- `resources/ui/temp_industrial_theme.tres`
- `README.md`

신규: `docs/step65_ui_ux_acceptance_and_stabilization.md`. 삭제0. data/runtime/read_models 70파일 byte 동일, 제품 `.tres`5개·project.godot·Step64 보고서 byte 동일. 이전 verification59,562개 hash 동일/누락0. 최종 비캐시 관리 후보 파일163개. 상세 `final_scope.json` 및 `step65_delta.patch` 참조.

제품 script 책임: `game_shell.gd`는 도구 active skin만 표시하고 `research_log_view.gd`는 Drawer-local focus를 처리한다. `broadcast_view.gd`는 실제 선택 hit area와 confirmed 문구 표시를 조정한다. `research_archive_list_view.gd`는 Open target 최소 높이만 조정한다. Main의 화면/owner/응답 수명 책임은 그대로다. 새로운 Manager/Singleton/framework0이다.

기존 미커밋 파일 중 read_models/runtime/content/settings/이전 docs는 이번 Step65 baseline 대비 보존됐다. Theme delta도 기존 StyleBox 참조2항목뿐이다. `.godot` QA 출력은 Git ignore다. 파일 삭제0. README는 이전 byte prefix 뒤에 Step65 설명만 append했다. Git diff와 baseline delta를 모두 기록하고 HEAD/index를 변경하지 않았다.

## 30. Known Gaps

다음은 기존 OPEN으로 유지하며 이번 작업의 해결 대상이 아니다.

- completed Scripted terminal projection gap.
- Step53 prepared Pending/residue P2.
- Step54 여러 State 사이 cleanup atomic rollback 한계.
- Step62 failed restore의 fail-closed context/developer retry; 플레이어 recovery UI 없음.
- Hypothesis getter P3.

Save/Load, Ending, Mandatory02/03, 경제·Credit·Quota·Shop·Upgrade·Reward·Meta, 새 Story/Case, final visual asset/font/shader/audio를 추가하지 않았다. UI 검사가 이 영역을 구현하거나 승인했다는 주장을 하지 않는다. native 입력은 엔진 GUI 경로 자동 주입이며 실제 사용자 usability test나 물리 OS 입력 end-to-end 인증은 아니다.

## 31. Next Step Recommendation

Step66에서 사용자가 승인한 static skin의 **라이선스와 원본 파일**을 확인한 뒤 §25 슬롯의 Theme/Icon/Texture만 교체하는 작업을 시작할 수 있다. hierarchy와 focus path는 유지하고 asset margin/font metrics 변경 후 actual Campaign·Modal·Drawer·Archive·긴 문서·Step62 exact resume·1280/1920 회귀를 다시 수행한다. 현재 색상·폰트·비율을 정식 디자인으로 확정하지 않는다. gameplay 기능을 추가할 단계라면 기존 terminal OPEN과 asset-only 작업을 별도 범위로 관리해야 한다.

다음의170개 항목은 종료 요청과 1:1로 대응한다. 마지막 시각 검토10개는 구현을 중단시킬 승인이 아니라 구체적인 원본 화면을 검토할 사용자 판단 목록이다.


### 종료 보고170개 항목

| No. | Requested item | Answer / evidence |
|---:|---|---|
|1|baseline|작업 전 비캐시162파일을 조사하고 byte hash/사본/Git 상태를 baseline.json에 보관했다.|
|2|HEAD|HEAD 6e8f167f699a3a95c91fee8668ae99d03e5d4db9 유지.|
|3|branch/upstream|master / origin/main 유지.|
|4|staged|시작 staged0, index를 수정하지 않았다.|
|5|Step64 file preservation|Step64 보고서·이전 evidence는 보존했고 관련 제품 Scene/View는 이번 UI delta만 적용했다.|
|6|product Resource preservation|Campaign/Case/TEMP 제품 Resource5개 byte 동일; Theme만 표시 variation2항목 추가.|
|7|Main before functions/lines|실측142함수/2600줄.|
|8|Main after functions/lines|실측142함수/2601줄, 새 Main 함수0.|
|9|GameShell structural changes|Shell active Rail helper 추가, 기존 Header/Nav/Workspace 책임 유지; Main Scene 빈 HeaderIconSlot 추가.|
|10|Theme changes|ActiveRailButton base_type/normal2항목만 추가; palette·font·기존 StyleBox 그대로.|
|11|Profile UX|Subject/Document·fixed CTA·focus·pointer·120줄 PASS.|
|12|CCTV UX|Feed placeholder/관찰·ConditionScroll·recheck exact resume PASS.|
|13|Experiment UX|Catalog/Result 분리·draft/completed·실제 실행·focus-follow PASS.|
|14|Containment UX|Room draft/확정 lock·Modal·hidden outcome·scroll/resume PASS.|
|15|Research Drawer UX|발견 snapshot·Category·Entry·양방향 focus trap·close owner0 PASS.|
|16|Hypothesis UX|draft·CRUD·editor Tab·ESC·Side/Notice draft 보존 PASS; getter P3 유지.|
|17|Archive UX|held work·actual TEMP Case01 Research·List/Detail·긴 문서 pointer/wheel/focus PASS.|
|18|Disturbance UX|Drawer 닫기·input pause·Dismiss same work·current condition PASS; fake Major0.|
|19|Failure Incident UX|기존 bounded Failure/source Archive/paused work 경로 유지 PASS.|
|20|Sequential Incident UX|actual TEMP neutral Header·Broadcast·CONTINUE CAMPAIGN→Case03 PASS.|
|21|Side Incident UX|controlled typed Side·paused context·exact resume PASS; product schedule 추가0.|
|22|Broadcast UX|문구 전체 hit area 개선·actual OptionA/C·승인 의미/lock 유지 PASS.|
|23|Result UX|route별 Result 문구와 기존 CTA 유지 PASS.|
|24|Primary CTA consistency|기존 PrimaryButton/fixed Actions/48높이 유지; 진행·실행·승인 역할 검증.|
|25|Secondary CTA consistency|보조 Rail/Archive/Recheck 위치 유지; Note/Open 목표 높이만48 정렬.|
|26|disabled CTA behavior|기존 canonical enabled 정책 그대로; hidden/disabled는 focus cycle 제외, guard PASS.|
|27|Nav current|CURRENT 문구/CurrentNavButton disabled indicator; stage와 일치 PASS.|
|28|Nav available|AVAILABLE 문구는 stage indicator, 클릭 navigation 아님; 정책 변경0.|
|29|Nav locked|LOCKED indicator disabled·경로 우회0 PASS.|
|30|Rail states|기존 enable 판정 유지; 실제 kind에 active skin 표시.|
|31|Drawer active state|Research/Hypothesis/Archive actual kind 강조·닫기 해제 PASS.|
|32|Drawer focus|Drawer 열기 focus 내부·동적 filter/CRUD 후 cycle 재생성 PASS.|
|33|Drawer close focus|ESC/Close 이전 valid focus 복귀; mouse Rail로 연 경우 Rail focus PASS.|
|34|Archive focus|List/Detail 모든 활성 항목 Tab/ShiftTab·긴 목록 focus visible PASS.|
|35|Modal focus trap|양방향 Modal trap PASS, underlying focus로 누출0.|
|36|Modal Tab|실제 KEY_TAB을 Modal에 주입해 내부 scope PASS.|
|37|Modal ShiftTab|실제 Shift+Tab을 Modal에 주입해 내부 scope PASS.|
|38|Modal Space|최종 Confirm에 Space 실제 승인·mutation1 PASS.|
|39|Modal Enter|최종 Confirm에 Enter 실제 승인·mutation1 PASS.|
|40|Modal ESC|ESC로 취소·owner mutation0·재열기 PASS.|
|41|Mouse primary CTA|새 fixture에서 실제 Godot pointer hit-test로 progression/EXECUTE/approve 클릭 PASS.|
|42|Mouse dynamic item|Experiment/Room/Broadcast/Research/Archive 항목 actual pointer PASS.|
|43|mouse hit area|새 acceptance 실제 clipped target의 논리 높이44+; Note/Open min48, Broadcast 전체 폭 PASS.|
|44|Profile scroll|Profile120줄 wrap·vertical document scroll·fixed CTA PASS.|
|45|CCTV scroll|CCTV ConditionObservation scroll·recheck/resume preserved PASS.|
|46|Experiment list scroll|Catalog follow_focus·15번째 item visible·wheel scroll PASS.|
|47|Experiment result scroll|ResultScroll 별도 owner·긴 결과·resume equality PASS.|
|48|Containment room scroll|RoomScroll/RoomDetailScroll 분리·2/4/8·draft focus/scroll restore PASS.|
|49|Archive scroll|Archive 각 열·Detail120줄 실제 wheel·40항목 focus PASS.|
|50|Broadcast scroll|Prompt/OptionScroll 분리·2/4/6 options·긴 문구 PASS.|
|51|Result scroll|Result report120줄·fixed route CTA PASS.|
|52|scroll reset issues|Step62 primitive scroll equality PASS; 새 의도하지 않은 reset 재현0.|
|53|nested scroll issues|독립 pane wheel owner 검사 PASS; scroll 이동으로 CTA가 밀리지 않음.|
|54|header raw ID exposure|Header는 기존 display projection; raw source ID 새 노출0.|
|55|header stale state|fresh Case03·Runtime 교체·tool close에서 Header 갱신 PASS.|
|56|resume header state|side resume 후 실제 Stage/Header/Nav/Rail 복원 PASS.|
|57|sequential header|Sequential Subject FACILITY EVENT/current Case null PASS.|
|58|side header|Side는 실제 current Case와 paused stage 표시 PASS.|
|59|failure header|Failure는 과거 source와 현재 paused work 분리 PASS.|
|60|fake source|새 source fabrication0; actual authoring과 controlled fixture를 구별.|
|61|Containment draft clarity|draft checkbox/room detail·확정 lock 표시 유지 PASS.|
|62|Containment hidden outcome|승인 전 정답/실패·임의 risk rating 새 노출0.|
|63|Containment modal first click|최초 AUTHORIZE는 Modal만 열고 Pending/owner0 PASS.|
|64|Containment final confirm|최종 AUTHORIZE만 기존 canonical handler 한 번 PASS.|
|65|Broadcast draft clarity|option draft/confirmed marker·selection lock 유지 PASS.|
|66|Broadcast modal first click|최초 CONFIRM은 Modal만, response owner0 PASS.|
|67|Broadcast final transmit|최종 TRANSMIT만 기존 승인 한 번 PASS.|
|68|Broadcast wrong answer leak|승인 전 wrong/correct leak 새 추가0, actual wrong OptionC 경로 PASS.|
|69|Response lock|확정 option과 room selection lock·중복 canonical callback guard PASS.|
|70|Result CTA failure|Failure Result은 기존 paused work로 복귀 PASS.|
|71|Result CTA sequential|Sequential Result CONTINUE CAMPAIGN→actual Case03 PASS.|
|72|Result CTA side|Side Result RESUME WORK→same Runtime/UI memento PASS.|
|73|drawer+notice|new acceptance drawer_notice: Drawer 닫기·Notice 하나·same work·draft 보존 PASS.|
|74|drawer+side|extra collision(false): Drawer 닫고 typed Side·exact resume·note cache PASS.|
|75|modal+side|extra collision(true): Modal 동안 due hold, Cancel 뒤 safe start PASS.|
|76|notice+side|side H_notice: due 유지·Notice 끝난 뒤 Side, nested response0 PASS.|
|77|exact Profile resume|Profile 기존 focus path/capture equality·same Runtime PASS.|
|78|exact CCTV resume|CCTV condition scroll/recheck exact resume·owner/RNG equality PASS.|
|79|exact Experiment draft|Experiment selected ID draft exact equality PASS.|
|80|exact Experiment result|displayed result/history/recorded conditions exact restore PASS.|
|81|exact Experiment list scroll|experiment_scroll primitive equality PASS.|
|82|exact Experiment result scroll|result_scroll primitive equality PASS.|
|83|exact Experiment focus|Experiment 동적 Select/Run/Actions focus whitelist 보존 PASS.|
|84|exact Containment draft|Containment selected_room_id/confirmed_room_id와 canonical lock equality PASS.|
|85|exact Containment scroll|Containment room_scroll equality PASS.|
|86|exact Containment focus|Containment RoomN/Select 및 Actions focus whitelist 보존 PASS.|
|87|exact Shell after resume|resume Shell Header/Nav/Rail 일치 PASS.|
|88|product all-success|actual authored OptionA all-success Campaign→Case03, 새3환경 각1+기존 product 경로 PASS.|
|89|product wrong option|actual authored OptionC wrong result→Case03, 새3환경 각1+기존 B/C/D 경로 PASS.|
|90|product Archive|TEMP 동안 실제 archived Case01 Research entry를 mouse로 읽고 복귀 PASS.|
|91|product Case03|실제 authored Case03 fresh Profile/Subject/Stage dispatch PASS; 새 내용0.|
|92|Failure coexistence|bounded Failure + Sequential/Side 공존 경계 PASS; threshold/RNG/candidate 정책 변경 없음.|
|93|dynamic Experiment1/3/6|controlled duplicate Experiment1/3/6 count/scroll/completed/lock PASS.|
|94|dynamic Room2/4/8|controlled duplicate Room2/4/8 count/list/detail scroll PASS.|
|95|dynamic Option2/4/6|controlled duplicate Option2/4/6 count/prompt/options scroll PASS.|
|96|Research1/40|controlled Research snapshot1/40、Category filter、100줄 body PASS.|
|97|ArchiveCase1/6|controlled Archive Case snapshot1/6 list PASS.|
|98|long Profile|Profile120줄 autowrap/vertical scroll/fixed CTA PASS.|
|99|long Experiment|Experiment description120/result100줄 scroll/fixed CTA PASS.|
|100|long Incident|Incident120줄 report/fixed response CTA PASS.|
|101|long Broadcast|Broadcast prompt100/option16줄 independent scroll PASS.|
|102|long Result|Result120줄 report/fixed route CTA PASS.|
|103|horizontal overflow|long text pane width bounds 검사 PASS; 새 horizontal overflow 재현0.|
|104|CTA overlap|primary CTA rect가 Workspace 안에 있음 PASS; overlay는 의도된 Modal/Drawer뿐.|
|105|Header overlap|Header72/Body968/SystemBar40 logical rect와 overlap 검사 PASS.|
|106|1920 GPU|native AMD RX6800 Compatibility 실제1920×1080 필수19 unique screenshots PASS.|
|107|1280 GPU|native1280×720 필수19 unique screenshots PASS; 핵심6 포함.|
|108|contrast baseline|sRGB 참고 contrast normal12.74/disabled4.35/muted6.90/warning6.08/focus9.79; 전체 접근성 인증 아님.|
|109|selected/completed distinction|selected checkbox/draft·Executed 문구·disabled 완료·Confirmed lock·outline으로 구별 PASS.|
|110|warning/emergency distinction|warning/emergency 서로 다른 기존 panel+문맥 텍스트; 미학 확정0.|
|111|Asset Theme slot|Main.theme 및 T BASE THEME 교체 slot; static skin NO CODE/NO HIERARCHY.|
|112|Panel slots|Normal/Warning/Emergency/System StyleBox slots 명시; 같은 panel node 유지.|
|113|Button slots|Normal/Hover/Pressed/Disabled/Focus/Primary Theme slots 명시.|
|114|Nav slots|CurrentNavButton/NavButton/LOCKED indicator Theme slots 명시.|
|115|Rail icon slots|기존 R/A/N Button.icon 속성과 signals 유지; 정식 Texture 지정만.|
|116|CCTV visual slot|CameraImage panel override StyleBoxTexture로 static CCTV frame 가능; 실제 영상 구현 범위 아님.|
|117|Incident visual slot|IncidentImage panel override StyleBoxTexture로 static illustration 가능.|
|118|external filename gameplay hardcode|Main/runtime/data/read_models에서 외부 패키지/asset filename dependency 새 추가0; scan hit0.|
|119|specific texture gameplay hardcode|gameplay texture 크기별 판정/texture path hardcode 추가0.|
|120|hierarchy change needed for asset swap|§25 static skin 교체는 기존 hierarchy 유지 가능; Header/Warning 빈 슬롯 준비.|
|121|final asset code change needed|static Theme/Icon/Texture 교체는 gameplay code 수정 NO; animation/영상 신규 기능은 별도.|
|122|contact sheet|verification/contact_sheet_1920.png 실제1920×1080, mandatory19 source montage.|
|123|human review checklist|문서 마지막 [USER VISUAL DECISION]10항목 YES/CHANGE 제공.|
|124|editor import|fresh --editor --quit 최종 exit0/WARN0/ERROR0.|
|125|scripts check-only|제품53 GDScript --check-only 모두 최종 exit0/SCRIPT/PARSE0.|
|126|Main headless|configured Main headless --quit-after20 exit0.|
|127|Main native|configured Main native --quit-after30 exit0/actual GPU; 물리 F5를 누른 검사 아님.|
|128|UI suite headless|UI headless155/extra886/new acceptance588 literal calls PASS.|
|129|UI suite native|UI native1280/1920 각155, extra각890, new acceptance각588 PASS.|
|130|Step58 regression|Step58 mixed168/bounded180 PASS; 순차 source/Failure boundary 보존.|
|131|Step60 regression|Step60 FactQueries411594 literal calls PASS; typed/lifetime/owner mutation 경계.|
|132|Step62 regression|Step62 side6237calls/15journeys, guards1211calls PASS; exact resume/helper byte 유지.|
|133|Step63 regression|Step63 product1888calls/7actualjourneys 및 새 actual mouse2×3회 PASS.|
|134|Failure Major regression|bounded Failure Major/actual UI failure source path PASS.|
|135|Archive regression|held work/actual source Archive/tempCase01/body/back 및 dynamic list/detail PASS.|
|136|terminal/cleanup regression|active708/closure460/cleanup1130calls 핵심 PASS; 기존 OPEN 유지.|
|137|warnings|최종 normal WARN0; active2/closure13 expected rejection WARN 총15.|
|138|controlled diagnostics|최종 controlled ERROR0, expected WARN15 count 확인; initial failures 별도 보존.|
|139|runtime errors|최종 unexpected runtime ERROR0.|
|140|script errors|최종 SCRIPT ERROR0; 초기 fixture SCRIPT errors는 immutable attempts/로그에 보존.|
|141|parse errors|최종 Parse Error0.|
|142|initial failures|초기 missing-response probe/잘못된 Archive·focus 기대/native 분리 입력 문제를 §28에 원인·해결 기록.|
|143|process count|최종75 Godot process slots(native8/headless67); ledger155 completed attempts는 반복/실패 포함; 직접 before probe 별도.|
|144|assertion calls|최종 literal assertion calls428626; FactQuery 반복 포함, 독립 scenario 수 아님.|
|145|independent journey count|새 actual authored2journeys를 각3환경 반복; 기존 product7/controlled side15 별도; 중복 실행을 고유 scenario로 합산하지 않음.|
|146|files modified|Step65 baseline 대비 existing22 modified(제품21+README1); 전체 Git dirty는 이전 Step55~64 포함.|
|147|files created|제품 관리 파일 신규1: docs/step65_ui_ux_acceptance_and_stabilization.md; QA fixture/PNG는 ignored namespace.|
|148|files deleted|제품 파일 삭제0; 이전 evidence 누락0.|
|149|project.godot|project.godot byte 동일; 1920/1280 canvas_items/keep/Compatibility/Autoload0.|
|150|Campaign .tres|test_campaign_01.tres byte 동일; cursor/sequence/schedule 변경0.|
|151|Case .tres|test_case_01/02/03.tres 모두 byte 동일.|
|152|TEMP Incident .tres|temp_mandatory_incident_01.tres byte 동일; TEMP 내용 변경0.|
|153|external asset used|외부 정식/유료 asset 사용·다운로드·clone·구매0.|
|154|new font|새 font0; 기존 default22/Title32/Heading26/Muted18/Nav18 유지.|
|155|new shader|새 shader/CRT/VHS0.|
|156|new audio|새 audio/SFX0.|
|157|completed Scripted terminal gap|completed Scripted terminal projection gap OPEN 유지; 해결 주장0.|
|158|Step53 P2|Step53 prepared Pending/residue P2 OPEN 유지.|
|159|Step54 limitation|Step54 cross-state atomic rollback 한계 OPEN 유지.|
|160|Step62 restore limitation|Step62 restore failure/developer retry OPEN 유지; player recovery 신규0.|
|161|new P0|새 미해결 P0 관찰0; 검증된 입력·구조 범위에 한정.|
|162|new P1|새 미해결 P1 관찰0; 기존 terminal 제한은 여전히 OPEN.|
|163|new P2|재현한 UI focus/hit-area 이슈 해결; 새 미해결 P2 관찰0; 기존 prepared P2 유지.|
|164|new P3|새 미해결 P3 관찰0; 기존 Hypothesis getter P3 유지.|
|165|git diff --check|git diff --check exit0; Git line-ending 변환 안내는 엔진 오류 아님.|
|166|staged final|최종 staged0; index untouched.|
|167|commit/push|stage/commit/push0; HEAD unchanged.|
|168|Step66 asset integration readiness|정식 asset 원본/라이선스 확인 후 static Theme/Icon/Texture 교체 준비 완료; final skin 적용 아님.|
|169|user visual decisions remaining|Header/비율/Drawer/옵션 밀도/CTA/색/폰트 등10 사용자 시각 결정 남김.|
|170|final recommendation|사용자 시각 검토와 licensed static skin 교체 뒤 1280/1920·긴 문서·Modal·Step62/63 재검증 권장.|


### [USER VISUAL DECISION] — Human review checklist

원본 화면을 보고 각 항목에 YES(현재 비율 유지) / CHANGE(원하는 변경)로 답할 수 있다. 자동 미학 승인이 아니며 구현 완료를 기다리는 permission 요청도 아니다.

1. Header의 Subject/Stage/Environment 정보량을 유지할까? — YES / CHANGE (01/10/11)
2. Profile 이미지 placeholder와 문서 비율을 유지할까? — YES / CHANGE (01/19)
3. CCTV feed와 관찰 영역 비율을 유지할까? — YES / CHANGE (02)
4. Experiment Catalog/Result 폭과 EXECUTE 강조를 유지할까? — YES / CHANGE (03/04/17)
5. Containment Room 설명 밀도와 AUTHORIZE 강도를 유지할까? — YES / CHANGE (05/06/18)
6. Research/Hypothesis Drawer 폭과 active Rail 표시를 유지할까? — YES / CHANGE (07/09)
7. Archive3열 비율과 문서 탐색 배치를 유지할까? — YES / CHANGE (08)
8. Failure/Sequential/Side의 source/paused context 구별이 충분한가? — YES / CHANGE (11/12/16)
9. Broadcast option 밀도와 TRANSMIT Modal 배치를 유지할까? — YES / CHANGE (13/14)
10. TEMP 색상·border·현재 font 분위기를 향후 asset 선택의 참고로 유지할까? — YES / CHANGE (전체 원본; 정식 확정 아님)
