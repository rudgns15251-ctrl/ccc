# Step66.1 — Utility Rail Direct Switching UX Fix

검증 환경: Godot 4.7.1.stable.official.a13da4feb / Windows / GL Compatibility / AMD Radeon RX 6800. 이번 단계는 UI 탐색 수정이다. stage/commit/push는 하지 않았다.

## 1. 실제 문제 원인 / 사전 조사

전체 파일 목록, 164개 기존 파일의 SHA-256·원본, Git 상태, Main Scene/Script, Shell, Drawer, Archive List/Detail, held-work와 canonical/presented Stage, Navigation/Response guard를 먼저 조사했다. 적용되는 AGENTS.md는 없었다.

`_refresh_shell()`의 `work`는 PROFILE~CONTAINMENT만 인정했다. Archive Stage에서는 일반 held-work가 있어도 R/N이 비활성화됐다. 또한 R/N Handler는 Archive를 정상 업무로 복원하는 연결이 없어서 버튼만 활성화해도 Drawer를 열 수 없었다. Drawer 내부만 순환하던 Tab 연결도 Rail 접근을 막았다.

시작 시 HEAD `19be4ea998d6479f5c46c3527d540ff4a16f2322`, branch `master`, upstream `origin/main`. 기존 Step66 변경: README, Theme, Main, GameShell, Experiment 및 신규 Step66 보고서. 이 변경을 기준 snapshot으로 보존하고 이번 delta를 별도로 검사했다.

## 2. Normal Archive / Source Archive 구분

`_has_normal_work_archive()`는 Archive Stage + 정상 Case Runtime + Response route 아님 + active Response 없음 + 유효한 detached held-work + 정상 canonical/presented Stage + 동일 Runtime display receipt + 동일 Campaign entry를 모두 확인한다. 화면 이름이나 마지막 클릭 버튼으로 추정하지 않는다.

Failure Major(`CASE`), Sequential Scripted(`CAMPAIGN_ENTRY`), Mid-Case Side(`CAMPAIGN_INTERRUPT`) Source Archive는 이 조건을 만족하지 않는다. 기존 Source Archive / Response context와 A/Esc/BACK 복귀 계약을 유지한다. 사건 중 R/N의 pointer 및 직접 지연 Handler 호출을 모두 거부했다.

## 3. Enable / Disable 조건

기존 `blocked` 조건(Navigation busy, developer closure, notice, resume pending, due interrupt, Modal, terminal guard)을 그대로 적용한다. 유효한 Normal Archive를 정상 업무 R/N 허용 조건에 추가했다. Source Archive는 A만 기존대로 허용하고 R/N은 비활성 상태를 유지한다. ActiveRailButton 표시는 기존 `show_active_utility()`로 한 도구에만 적용한다.

## 4. R/A/N 전체 전환 Matrix

R = Research Log, A = Archive, N = Working Hypothesis. 각 셀은 버튼 클릭 1회이다.

| 현재 도구 | R 클릭 | A 클릭 | N 클릭 |
|---|---|---|---|
| R | 닫고 업무 복귀 | R 닫고 A 열기 | R 닫고 N 열기 |
| A (Normal) | held-work 복원 후 R 열기 | 닫고 동일 업무 복귀 | held-work 복원 후 N 열기 |
| N | N 닫고 R 열기 | N 닫고 A 열기 | 닫고 업무 복귀 |
| A (Source) | 비활성 / 거부 | 원래 Response 복귀 | 비활성 / 거부 |

A→R/N은 context 검증 → 기존 `_close_archive()` → 동일 held-work 부착 → 복원 identity 검증 → 기존 Drawer 생성 순서다. 복귀와 열기 사이에 await/Next가 없어 중간 업무 화면만 그리는 frame을 만들지 않는다. 9개 조합을 Profile, Experiment draft, Experiment result, Containment draft의 4개 문맥에서 반복 검사했다.

## 5. Esc / Keyboard

새 전역 키보드 단축키는 없다. 실제 InputEvent의 Tab/ShiftTab으로 Rail에 도달하고 Space/Enter로 전환했다. Esc는 Drawer 또는 Archive를 닫으며 기존 Modal 취소 우선순위를 유지한다.

Drawer의 포커스 범위는 현재 Drawer + 활성 R/A/N으로 제한한다. 뒤쪽 업무 화면으로 Tab이 빠지지 않는다. 기존 Drawer-only 범위에서 Rail만 명시적으로 허용한 변경이다. Modal은 기존 Modal-only trap이다. Drawer 닫기 시 Rail의 이전 focus_next/previous 경로를 지워 제거된 Drawer로 향하는 링크를 남기지 않는다. 독립/LEGACY View에는 새 외부 포커스 범위를 강제하지 않는다.

## 6. Held-work / Runtime 보존

Archive 복귀 시 Scene을 재생성하지 않고 실제 동일 held-work Node를 복원한다. Case/Runtime/entry identity, canonical/presented Stage, 기존 CCTV 재확인 부모, display receipt, Experiment draft/result/catalog·body scroll, Containment Room draft/확정 잠금을 기존 구조로 유지한다.

Utility 전환 전후의 owner fingerprint(Campaign/Runtime/기록/Response/실험 횟수/발견/Failure accounting/Story checkpoint/RNG)가 동일함을 검사했다. 전환에는 Gameplay Next, discovery, execution, confirmation, opportunity, response completion, checkpoint, RNG 호출을 추가하지 않았다. 과거 Case01 Archive Detail에서 R/N을 열어도 실제 현재 Case02 snapshot/메모를 표시했다.

## 7. Hypothesis 초안 보존

기존 Main의 Runtime별 `_drawer_cache`를 사용한다. draft/editing/selected entry/category/scroll을 유지하고 `focus_path`를 추가했다. 마지막 내부 포커스만 기억하므로 Rail 클릭이 편집 포커스 cache를 덮지 않는다. 동적 Entry/메모 Actions 버튼에 안정적인 Node 이름을 주어 새 Drawer에서도 로컬 경로를 찾는다.

레이아웃 후 scroll/focus를 복원하며 detached/queued/입력 guard 실패 시 지연 복원을 중단한다. 실제 Edit 버튼으로 편집 중인 메모, 미저장 텍스트, nonzero note scroll, editor focus를 준비하고 N→A→N 및 N→R→N에서 동일 snapshot과 focus를 확인했다. 원본 노트 목록은 동일하며 자동 추가/수정/삭제는 없다. Runtime 교체/종료의 기존 cache 초기화 경로를 유지한다.

## 8. Archive 탐색 상태 보존 여부

이번에는 기존 초기 Archive List로 다시 연다. 선택했던 과거 Case/Entry/Scroll 자체의 재열기 복원은 추가하지 않았다. 실제 Archive List/Detail에는 primitive capture/restore API가 없고 Detail 선택은 개별 버튼 callback으로 표시된다. 이를 보존하려면 두 Archive View의 선택 식별자/API와 Main의 별도 Runtime별 cache·복원 수명을 추가해야 한다. 선택 사항을 위해 직접 전환보다 변경 범위를 넓히지 않기로 했다. 실제 재열기 List 동작도 검사했다. 업무 View와 Hypothesis의 기존 cache 보존과는 별개다.

## 9. Stale / Duplicate 보호

같은 frame 실제 pointer로 A→R→R, A→N→N, R→A→N→N, N→R→A→A와 동일 버튼 double click을 검사했다. Drawer/Archive 중복, held-work 중복 부착, detached orphan 없이 기존 toggle 규칙대로 끝났다.

queued Drawer의 메모 요청, queued Archive의 Back/Case 요청, Navigation restore 중 추가 요청을 거부한다. 잘못된 Runtime receipt에서는 R/N 표시와 직접 Handler 모두 차단된다. Source Archive R/N도 거부된다. A→R/N 복귀는 동기 처리라 별도 비동기 복귀 구간을 새로 만들지 않는다. Drawer의 기존 지연 layout/focus 복원은 삭제/분리 상태를 확인한다.

## 10. 실제 변경 파일 / 범위

Step66 시작 snapshot 대비 제품 수정 **2개**, 문서 수정 **1개**, 문서 생성 **1개**, 제품 생성/삭제 **0개**.

| 파일 | 이번 책임 |
|---|---|
| `scripts/main/main.gd` | Normal Archive 판별·R/N 허용·동기 held-work 복귀 연결·Rail 포커스 전달/해제 |
| `scripts/views/research_log_view.gd` | Drawer+Rail 포커스 범위, 안정적인 로컬 경로, 기존 cache의 scroll/focus 복원 |
| `README.md` | 기존 내용 뒤에 Step66.1 결과만 추가 |
| `docs/step66_1_utility_rail_direct_switching.md` | 이 보고서 |

GameShell Script/Scene, 17개 Scene, Theme, 게임 데이터, project.godot, Assets는 이번 단계에서 수정하지 않았다. 이전 Step66의 변경은 남아 있으므로 HEAD 기준 git diff 전체와 이번 delta는 다르다. 새 Manager/Singleton/owner/Scene/전역 shortcut은 없다. Main에 UI helper 2개만 추가했다.

`project.godot`: 기준 1920×1080, 기본 창 1280×720, canvas_items, 기존 keep aspect 기본값, GL Compatibility, configured Main Scene 유지. 기존 Shell 비율/asset slot/Modal hierarchy도 동일하다.

## 11. Godot 검증 결과 / 초기 실패

증거는 ignored `.godot/verification/step66_1/`에 분리했다. `invocations.jsonl`과 `attempts/`에 최초 실패도 보존했다. 원본 Step66 이하 fixture를 수정하지 않고 사본만 사용했다.

- 전체 53개 제품 GDScript check-only, editor import, configured Main headless/native 실행 통과: 56 process slots.
- 신규 Utility fixture: headless 1920, Windows GPU 1920×1080, Windows GPU 1280×720 각각 **2,170 assertion 호출**, 실패 0. 합계 6,510 호출.
- 독립 named 시나리오 그룹 **22개**(9 Matrix + keyboard + EXP state + note state + rapid/stale + actual past-Case context + 8 Source/stage 조합). 문맥별 반복을 포함한 scenario 호출 **52개/환경**. 2,170은 독립 시나리오 수가 아니다. inherited Navigation/Modal assertions도 포함한다.
- GPU fixture마다 unique capture 20개: 6 direct transitions, note restore, 실제 제품 Navigation 및 3 Source 종류. 1920/1280 R/N 화면과 편집 메모/Source Archive를 직접 이미지 열람했다.
- 최종 유효한 최신 **84 process slots**, GPU 7 / headless 77. 유효 실행 호출은 초기 통과 Navigation 재실행을 포함해 85회. 최종 slots의 총 **441,830 assertion 호출**. 단순 import/check-only에는 assertion 수를 붙이지 않았다.
- 예상 warning 19개(active 2 / closure 13 / ordering 4)는 기존 controlled negative probes. 최종 오류/파싱 오류/GDScript 오류/예상 밖 warning 0.

초기 실패 2회:
1. 신규 fixture `scenarios`가 부모 fixture와 중복되어 파싱 실패. QA 변수명을 `utility_scenarios`로 수정했다. 제품 파싱 오류는 아니었다.
2. 기존 Acceptance 사본이 Drawer-only 범위를 기대해 R/N의 Tab이 Rail로 이동하는 2개 검사 실패. 현재 Drawer + 활성 Rail만 허용하도록 기대 scope를 수정했다. 배경 업무 제외·Modal trap·owner equality 검사는 유지했다.

실제 제품 Journey는 authored resources와 실제 Main을 사용한 Case01→Case02→TEMP Mandatory01(Option C)→Case03 경로 **1종을 신규 fixture에서 3환경 실행**했다. 실제 Case02의 과거 Case01 Archive 선택 후 R/N current-Case 전환도 이 여정에 포함된다. 별도 기존 product fixture의 7 journey를 headless 재검증했고 기존 Acceptance A/C 두 journey를 3환경 재검증했다. 이것은 새 Story route를 구현했다는 의미가 아니다.

Controlled fixtures는 복제한 Campaign/Case의 긴 목록·본문·메모, Side interrupt checkpoint, Failure candidate/credit, stale receipt를 명시적으로 준비한 테스트이다. 제품 데이터는 바꾸지 않았다. 실제 GUI 입력은 Godot root.push_input(InputEventMouseMotion/MouseButton/Key)로 전달하며 제품 Button signal을 직접 emit해 전환을 가장하지 않았다. stale/defensive Handler 호출은 별도 negative probe다. 에디터 F5 키를 실제 누른 검증은 아니며 설정된 Main의 명령행 실행을 확인했다.

## 12. 기존 회귀 / Git / 증거 보호

- Step62: Side 15 journeys / 6,231 checks, guards 1,211 checks, 신규·Navigation fixture의 exact work resume 포함.
- Step63: authored 7 product journeys / 1,840 checks, 신규 실제 Campaign 순서 및 잘못된 응답 후 Case03 유지.
- Step64: UI 154, dynamic/long/stale 886, Modal keyboard 6 checks headless 통과.
- Step65: Acceptance 586 checks × headless/native1920/native1280; 키보드·Modal·Scroll·Drawer cache 통과.
- Step66: Navigation 766 checks × 같은 3환경; Profile/CCTV/EXP/CONT direct navigation/review/Archive A/Esc/BACK/Source/long scroll/recheck/busy guard 유지.
- 기존 Campaign, bounded/mixed source, typed facts, active/cleanup/closure, snapshot/ordering/pacing gate 회귀 통과. fact query의 411,594 반복 assertion을 독립 사용자 시나리오로 계산하지 않았다.

`metrics_summary.json`, 각 환경 JSON, raw log, native PNG, Step66 baseline 대비 `delta_*.patch`, `change_audit.json`에 기록했다. 기존 검증 파일 **62,362개**는 최종 SHA-256 재검사에서 모두 동일하며 수정/삭제 0이다(새 preparation helper 1개를 포함한 hash ledger는 62,363개). 제품/문서 baseline은 별도로 비교한다.

최종 HEAD/branch/upstream 유지, staged 0, commit/push 0. `git diff --check` 통과. README 기존 byte prefix와 이전 Step66 보고서 및 Theme/Shell/Experiment 변경을 보존했다. 최종 git status의 modified 6개(이전 5개 + ResearchLogView), untracked 보고서 2개(이전 Step66 + 신규 Step66.1)는 기존 작업을 포함한 상태다. 삭제 0. CRLF/LF 정규화 안내는 Git text 정책이며 whitespace 오류가 아니다.

## 13. 남은 문제 / 다음 확인 지점

Archive 재열기 시 과거 Case/Entry/Scroll 선택 복원은 미구현이며 초기 List 정책이다. 기존 completed Scripted terminal projection, Step53 prepared Pending P2, Step54 atomic rollback limitation, Step62 restore failure developer retry, Hypothesis getter P3는 이번 수정으로 해결했다고 주장하지 않는다.

Save/Load, Ending, Mandatory02/03, 최종 assets/문구/테마, 새 Gameplay 규칙은 추가하지 않았다. 다음 사용자 확인은 같은 업무에서 A→R→N→A를 클릭하고 N에 미저장 메모를 쓴 뒤 Archive 왕복, Tab/ShiftTab 전환, 사건 Source Archive의 Response 복귀를 확인하는 지점이다.
