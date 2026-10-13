# Step70 — Research Document Profile UI Pilot

> 개발 이력: 이 문서는 해당 단계 작성 당시의 설계·구현·검증 기록입니다. 현재 구조는 [코드 구조 안내](architecture.md)를 참고하세요. `.godot/verification/` 자료는 Git에 포함되지 않는 로컬 자료이며, 공개 검사 방법은 [검증 안내](verification.md)에 있습니다.

기존 Profile의 오른쪽 설명 영역을 Godot-native 종이 연구기록 뷰어로 변경했다. 실제 이름·분류·본문만 표시하며 데이터 소유권, 발견 규칙, 업무 전환, 사건 처리는 기존 구현을 사용한다. TEMP UI 파일럿이며 최종 디자인 확정이 아니다.

## 1. Repository Baseline

실제 저장소를 먼저 조사했다. 작업 시작 시 비생성 파일 169개, 제품 GDScript 53개, Scene 17개, authored Resource 7개가 있었다. `project.godot`, 실제 Main/Profile Scene·Script, GameShell, Theme, ProfileData, Case01/02/03, Campaign, Step62 memento, Step66 navigation snapshot 및 Git 상태를 확인했다.

HEAD는 `742d8e5fc971a6c7e81ac11bee14cabc4ac14d66`, branch는 `master`, upstream은 `origin/main`이었다. remote는 `https://github.com/rudgns15251-ctrl/ccc.git`이다. staged 파일은 없었다.

작업 전부터 존재한 미커밋 Step69 변경:

- modified: `README.md`, `resources/campaigns/test_campaign_01.tres`
- untracked: `docs/step69_first_authored_midcase_incident.md`, `resources/incidents/temp_midcase_incident_01.tres`

이 파일들을 보존했다. Step70 시작 시 파일 해시와 원본은 `.godot/verification/step70/baseline.json`, `before/`에 보관했다. 이전 verification 파일 66,016개도 SHA-256 기준 변경·삭제 0이다. 증거는 `old_evidence_hashes.json`, `old_evidence_preserved.json`에 있다.

## 2. Actual Profile Data Audit

`scripts/data/profile_data.gd`의 실제 필드는 `profile_id`, `subject_name`, `classification`, `basic_description`이다. 화면에는 기존과 같이 마지막 세 필드를 사용한다. `profile_id`는 기존 식별/검증 값이며 새 Document ID로 표시하지 않는다. 사진·저자·날짜·개정·보안 등급·부서 필드는 없다.

| 실제 Resource | Profile ID | 이름 | 분류 |
| --- | --- | --- | --- |
| `resources/cases/test_case_01.tres` | `TEST_PROFILE_01` | TEST SUBJECT | TEST CLASSIFICATION |
| `resources/cases/test_case_02.tres` | `TEST_CASE02_PROFILE_01` | TEST SUBJECT CASE 02 | TEST CLASSIFICATION CASE 02 |
| `resources/cases/test_case_03.tres` | `TEST_CASE03_PROFILE_01` | TEST SUBJECT CASE 03 | TEST CLASSIFICATION CASE 03 |

각 `basic_description`은 아래 7절의 원문 그대로다. 세 Case Resource는 작업 시작 해시와 동일하다.

## 3. Existing View Contract

Profile은 `FlowView`를 상속하며 `setup(ProfileData)`로 입력을 받는다. `advance_requested`, `research_log_requested`, Main이 제공하는 input guard, `_ready()`의 기존 CTA focus를 그대로 사용한다. 추가 Script·owner·signal·Autoload는 없다.

유지한 실제 경로:

```text
Margin/Content/Actions/NextButton
Margin/Content/Actions/OpenResearchLogButton
Margin/Content/Workspace/Document/DocumentScroll
Margin/Content/Workspace/Document/DocumentScroll/DocumentBody/Description
```

Step62의 PROFILE `capture_work_state()`/`restore_work_state()` 계약은 기존 `focus_path` 한 필드이며 Actions 경로가 유효하다. 이 API나 validator를 확장하지 않았다. Step66은 이와 별도로 모든 ScrollContainer의 상대 NodePath/수직 위치를 저장하므로 기존 DocumentScroll과 새 IdentityScroll을 자동으로 처리한다.

SubjectName/Classification은 IdentityScroll 안으로 이동했지만 기존 `%SubjectName`, `%Classification` 이름을 유지했다. 이 Label 경로는 기존 memento focus 대상이 아니다. 문서 제목도 문서 스크롤 안으로 옮겼으며 focus/상태 계약에는 사용되지 않는다.

## 4. Final Layout

```text
Main / 기존 GameShell / ViewHost
└── ProfileView
    └── Margin/Content
        ├── ScreenTitle
        ├── Workspace (HBoxContainer)
        │   ├── Identity (VBoxContainer, 520 logical px)
        │   │   ├── SubjectImage / 기존 TEMP Placeholder
        │   │   └── IdentityScroll / IdentityDetails
        │   │       ├── SubjectName
        │   │       └── Classification
        │   └── Document (PanelContainer, PaperDocumentPanel)
        │       └── DocumentScroll / DocumentBody
        │           ├── DocumentHeading: RESEARCH RECORD
        │           ├── DocumentSubject
        │           ├── DocumentClassification
        │           ├── DocumentSeparator
        │           └── Description
        └── Actions / 기존 고정 CTA
```

GameShell의 Header 72px, Navigation 176px, Utility Rail 56px, System Bar 40px를 유지한다. Main Scene 자체는 변경하지 않았다. Profile의 기존 24px Margin, Workspace/Actions 분리, 좌측 520px 폭과 우측 확장 배치를 유지했다. 문서 32px 안쪽 여백과 20px 문서 요소 간격은 해당 paper 영역에만 적용된다.

## 5. Identification Panel

실제 이름과 분류를 표시한다. 기존 `SUBJECT RECORD / TEMP IMAGE PLACEHOLDER` 텍스트를 유지하며 새 이미지를 만들거나 내려받지 않았다. 실제 입력에는 이미지 필드가 없으므로 원본 이미지 종횡비 처리 API를 새로 만들지 않았다.

긴 이름/분류가 VBox 최소 높이를 키워 Actions를 화면 밖으로 밀어내지 않도록 IdentityDetails를 독립 ScrollContainer에 넣었다. SubjectImage 최소 높이는 224px, IdentityScroll 최소 높이는 160px이며 남은 높이를 나눠 쓴다. 좌측 폭 520px은 유지한다. 실제 짧은 이름에서는 불필요한 scrollbar가 나타나지 않는다.

## 6. Paper Document Theme

기존 `resources/ui/temp_industrial_theme.tres`에 두 StyleBoxFlat과 다섯 Theme Variation만 추가했다. 기존 dark theme 정의·기본 폰트 크기·기존 variation은 유지했다.

| Variation | 타입 / 적용 |
| --- | --- |
| PaperDocumentPanel | PanelContainer / #D8D5C8 종이, 1px 테두리, 32px padding |
| PaperBodyLabel | Label / #252823 본문, line spacing 6 |
| PaperHeadingLabel | PaperBodyLabel 상속 / 30px 제목 |
| PaperMetadataLabel | Label / #595F55, 18px 일반 제목·분류 |
| PaperSeparator | HSeparator / #929487 |

Godot-native Label/StyleBoxFlat이며 텍스트를 이미지로 굽지 않았다. 기본 엔진 폰트와 기존 dark 버튼 focus style을 사용한다. 본문/metadata 대 종이색의 sRGB 명암비는 각각 10.15:1 / 4.47:1이며 `final_audit.json`에 계산값을 기록했다. 실제 GPU에서도 본문·분류·CTA의 읽기 가능 여부를 확인했다. 접근성 표준 인증을 주장하는 결과는 아니다.

## 7. Source-backed Document Content

RESEARCH RECORD는 일반 UI 제목이다. 문서 이름과 분류는 기존 화면에서 표시한 실제 Profile 필드를 반복한다. `_display_document_header()`는 Label 텍스트를 복사할 뿐 Resource를 수정하지 않는다. 기존 결측 데이터 경고/placeholder 처리도 유지했다.

본문 원문:

| Case | 표시한 authored Description |
| --- | --- |
| Case01 | `TEST: metal-support pump cycles preceded strikes; no talk link.` |
| Case02 | `TEST: wall-contact loss precedes searching; no damage recorded.` |
| Case03 | `TEST: follows contrasting floor strips; short pauses occur at gaps.` |

입력이 하나의 Description이므로 하나의 본문으로 표시했다. 관찰/평가/사고 등의 새 Section이나 문장을 생성하지 않았다. 기존 문자열의 공백·줄바꿈도 그대로 전달한다.

## 8. Hidden Information Audit

새 바인딩은 subject_name/classification 두 필드뿐이다. Profile Script는 Experiment/Research/Containment/Incident/Campaign 데이터에 접근하지 않는다. Profile에 새 Document ID, Author, Date, Revision, Security Clearance, Accident ID, Facility Department, 기관명 등을 표시하지 않는다.

테스트에서 Profile 하위 모든 Label 텍스트를 실제 세 필드와 기존 TEMP placeholder, PROFILE, RESEARCH RECORD로 allowlist 검사했다. 미실행 Experiment result와의 잘못된 바인딩도 검사했다. 따라서 새 Profile UI를 통해 미발견 Research, 정답 Room, 미래 Incident 또는 Step69 사건 원인을 사전 공개하는 새 경로는 없다. 기존 authored Profile/CCTV 힌트 자체는 유지한다. 기존 Profile 진입의 발견 처리는 Main의 기존 규칙이고, Review·Scroll·Utility 왕복에서는 새 discovery가 생기지 않았다.

## 9. Short/Long Text

같은 Profile Scene에 네 가지 controlled Profile 복제본을 넣었다. 제품 Resource는 변경하지 않았다.

| Fixture | 입력 | 실제 수직 scroll (logical px) |
| --- | --- | --- |
| short | 짧은 본문 1줄 | Document 0 / Identity 0 |
| normal | 반복 문단 12줄, 끝 newline 포함 split 13 | Document 0 / Identity 0 |
| long | 실제 내용 120줄, 끝 newline 포함 split 121 | Document 1096 / Identity 0 |
| long_metadata | 이름 1170자·분류 1240자, 짧은 본문 | Document 911 / Identity 460 |

세 실행 환경에서 같은 결과를 얻었다. 휠 입력으로 nonzero scroll을 만들고 복귀 후 값 일치를 검사했다. Horizontal scroll은 disabled이며 실제 body/IdentityDetails 폭이 viewport 폭을 넘지 않는다. Header/CTA 겹침 0을 geometry assertion과 GPU 화면으로 확인했다. 본문과 metadata는 줄바꿈되어 독립 스크롤로 끝까지 읽을 수 있다. CTA는 양쪽 scroll 밖에 고정된다.

## 10. Scroll/Focus/Navigation

실제 Viewport에 MouseMotion/MouseButton/Key 이벤트를 전달했다. OS의 물리 마우스 자동화나 Button signal만으로 대체한 검사는 아니다. Focus는 지원되는 Actions/NextButton 경로를 기준으로 검증했다.

네 controlled 길이 fixture 각각에서:

- Profile → CCTV 직접 Nav로 기존 첫 진입/발견 동작 수행
- CCTV/Experiment/Containment → Profile Review 시 canonical Stage 유지, presented Stage만 PROFILE
- Profile Review → 현재 업무 Nav 복귀
- Archive → Hypothesis → Research → Escape로 같은 held Profile과 두 scroll 위치 복귀
- 현재 업무의 Profile Review → Archive → Profile 직접 Nav 복귀
- View 재생성 후 기존 Step66 snapshot으로 두 scroll, CTA focus, Runtime identity 보존
- Review/Utility/휠 사용 전후 owner·Campaign cursor·discovery·처리 기록 비교

Step62 PROFILE memento는 **focus-only**다. 임의로 Profile에서 Side interrupt를 구성했을 때 nonzero 문서 scroll을 그 memento가 보존한다고 주장하지 않는다. 실제 Step69 Side checkpoint는 EXPERIMENT이므로 해당 업무의 기존 exact resume 계약을 검증했다. 정상 Profile Navigation은 기존 Step66의 별도 scroll snapshot으로 nonzero 위치를 복원한다.

## 11. Step69 Compatibility

현재 실제 제품 Main과 `resources/campaigns/test_campaign_01.tres`를 사용했다.

```text
CASE01 실제 제출 → CASE02 실제 제출
→ TEMP Mandatory Incident01 → 응답 완료
→ CASE03 Profile → CCTV → 첫 Experiment 진입
→ TEMP_INTERRUPT_MIDCASE_01
→ Incident → Broadcast → Result → RESUME WORK
→ 동일 CASE03 Experiment → 정상 작업/Containment
```

기존 Step69 suite의 독립 경로 7개를 headless로 통과했다. A/B/C/D 응답, Case01/02 실패 조합과 optional Experiment 0 조건을 포함한다. 추가 Profile suite에서는 A 정상, C 정상, A 두 Case 실패 경로 3개를 headless/1920 GPU/1280 GPU 각각 실행했다. 최종 실제 제품 journey 실행은 총 16회이며, 서로 다른 제품 경로는 7개다.

첫 Experiment의 canonical 화면과 due 상태를 관찰한 뒤 Side 응답을 처리했다. Source Archive 왕복, 모달 Cancel/TRANSMIT, stale source 거부, 동일 Runtime/업무 memento 복원, 재발생 0, 복귀 후 Experiment 실행과 Containment 진행을 확인했다. Profile Review/Utility 사용으로 Side 발생 시점·Campaign cursor·발견 상태가 바뀌지 않았다.

`profile_after_side_resume` screenshot은 실제 Side가 Experiment로 복귀한 다음 Containment까지 정상 진행하고 Profile을 Review한 화면이다. 이때 canonical은 CONTAINMENT이며 presented는 PROFILE이다. 즉 Side의 복귀 대상을 Profile로 바꾼 것이 아니다. 같은 실행의 `ui_69_*_resumed_*`는 즉시 Experiment 복귀 화면이다.

Step69 Campaign schedule, 신규 incident Resource, 이전 Step69 보고서 모두 baseline과 byte-identical이다.

## 12. Step68 Historical Facts Regression

복사한 기존 regression fixture를 Step70 namespace에서 실행했다. Step68 Historical suite는 12 scenario, negative case 96개, assertion call 1617개를 통과했다. 이 suite의 legacy campaign carrier는 기존 회귀 조건을 보존하기 위한 것으로 실제 제품 Campaign 검증과 구분한다.

실제 제품 Side journey에서도 완료 Mandatory/Side 행 두 개가 각 source occurrence로 구분되어 recipient에 남는지, 확정 Option/Result와 Campaign scope가 맞는지, 반복 closure가 ALREADY_COMMITTED인지, cleanup 후 recipient 기록이 유지되고 source가 SOURCE_RELEASED인지 검사했다. Profile UI는 이 historical owner/builder/query에 접근하지 않는다.

## 13. Archive Reuse Plan

이번에는 Archive Scene/Script를 변경하지 않았다. Paper Theme Variation은 presentation 이름으로 분리되어 있으므로 이후 실제 과거 Profile 조회 화면에 적용할 수 있다. 그 단계에서 Archive가 이미 보유한 source-backed 읽기 전용 데이터를 전달하고 discovery/Runtime 재구성 없이 표시하는 경계를 먼저 정해야 한다.

현재 ProfileView는 기존 live ProfileData 입력을 그대로 사용한다. 아직 범용 Document Framework나 Archive 전용 adapter를 만들지 않았다. Research Log/Working Note 전체를 종이 UI로 바꾸지 않는다.

## 14. Incident Result Reuse Plan

Incident Result Scene/Script는 변경하지 않았다. 이후 실제 Result title/body/확정 response context에 Paper variations를 적용하는 작은 pilot은 가능하다. 그때 사건 source identity, Result read boundary, RESUME WORK 및 terminal 계약을 별도로 검증해야 한다. 현재 없는 날짜·문서번호·사고평가를 추가하는 근거로 이 Theme을 사용하지 않는다.

## 15. GPU Review Screens

GPU backend는 실제 Windows Godot 4.7.1 / Compatibility OpenGL / AMD Radeon RX 6800이다. 1920×1080와 1280×720 두 크기에서 viewport 캡처를 저장했다. 각 35 capture calls, 중복 공용 Source Archive 파일을 제외한 33개 PNG다. 각 실행의 `profile_Windows_*.json`에 전체 screenshot 목록이 있다.

아래 경로는 모두 `.godot/verification/step70/regression/` 아래이며 `W`를 `1920` 또는 `1280`으로 바꾼다.

| 요구 화면 | PNG |
| --- | --- |
| Case01 Profile | `ui_70_case01_profile_W.png` |
| Case02 Profile | `ui_70_case02_profile_W.png` |
| Case03 Profile | `ui_70_case03_profile_W.png` |
| Long Document | `ui_70_long_document_W.png` |
| Profile Review | `ui_70_profile_review_long_W.png` |
| Profile after Archive | `ui_70_profile_after_archive_long_W.png` |
| Profile after Side Resume | `ui_70_profile_after_side_resume_W.png` |
| Long names/classification | `ui_70_long_metadata_document_W.png` |

두 contact sheet는 `.godot/verification/step70/contact_sheet_1920.png`, `contact_sheet_1280.png`다. 실제 Case01/02/03, 긴 본문, Review, Archive, Side 이후 Review, 긴 metadata 여덟 장씩을 시각 검토했다. 대표 원본도 직접 확인했다. 별도 `metrics.json`에는 필수 대표 이미지의 실제 pixel size가 있다. 이 이미지들은 제품 asset이 아닌 ignored QA 증거다.

## 16. Test Results

Godot `4.7.1.stable.official.a13da4feb`에서 최종 **74 process slots**를 통과했다: headless 71, native 3. 모든 제품 GDScript 53개 check-only, 빈 cache의 fresh editor import, 실제 repository editor import, configured Main headless/native 실행을 포함한다. native Main은 configured 1280 window이며 전용 Profile suite는 GPU 두 해상도다. F5의 configured Main 경로를 CLI 실행했고 에디터에서 F5 키를 자동으로 누른 검사는 아니다.

| 검사 | 결과 / assertion calls |
| --- | --- |
| Fresh import / repository import / GDScript 53 / Main 2 | 57 process slots, 정상 |
| Profile pilot headless | 1461, 3 실제 journey + 4 controlled text fixture |
| Profile pilot native 1920 | 1461, 같은 실제 input 검사 |
| Profile pilot native 1280 | 1461, 같은 실제 input 검사 |
| Step69 실제 제품 추가 headless | 2195, 독립 journey 7 |
| Step62 exact resume / guards / invalid schedule | 6231 / 1211 / 42 |
| Step63 mandatory product regression | 1840, 7 journey |
| Step66 Navigation / Step66.1 Utility | 766 / 2170 |
| Step68 Historical | 1617 |
| 기존 Step58 mixed/bounded / Step60 Query | 162 / 174 / 411594 |
| 기존 Step52/53/54 closure/active/cleanup | 460 / 708 / 1130 |

Profile suite는 source_exact/no_metadata/hidden_information/geometry/horizontal_overflow/paper_style/scroll_input/archive_utility/nav_scroll/side_review/resource_unchanged 그룹을 모두 통과했다. 기존 회귀에는 Shell/Modal과 scroll/focus assertions도 포함된다. 검사는 `.godot/verification/step70/run.py`, 로그는 같은 폴더, 각 실행 원본은 immutable `attempts/`, 실행 ledger는 `invocations.jsonl`에 보관한다.

정상 제품 경로의 parse error / script error / ERROR / WARNING는 0이다. Invalid schedule negative fixture의 의도된 ERROR 20개와 legacy active/closure의 예상 WARNING 2+13개는 별도 expectation으로 검사했다. 모든 최종 process exit는 0이다.

전체 Godot 호출은 76회다. 최초 Profile headless 실패 두 번은 QA 휠 입력의 release 누락으로 GUI mouse capture가 남은 결과였다. 같은 테스트에서 press/release를 완성한 뒤 통과했고 해당 실패 원본도 남겨 두었다. Product Main/Runtime을 고치거나 disabled 버튼 signal로 우회하지 않았다. 동기 Query hook에 비동기 screenshot을 넣었던 fixture도 awaited click hook으로 옮겨 호출 계약을 유지했다.

최종 assertion 합계는 434683 calls이며 process 분류와 함께 `final_audit.json`에 있다. 반복 Query 411594회를 서로 다른 gameplay scenario로 계산하지 않는다. PNG contact sheet 생성 중 Python 기본 cp949 읽기 오류는 QA helper의 JSON UTF-8 명시로 해결했다.

## 17. Files Changed

Step70 시작 상태와 비교한 변경은 아래 네 기존 파일과 새 보고서 하나다.

| 파일 | 범위 / 이유 |
| --- | --- |
| `scenes/views/profile_view.tscn` | 종이 문서 Panel/머리말, 긴 Identity scroll; 고정 Actions 경로 유지 |
| `scripts/views/profile_view.gd` | 실제 이름·분류를 문서 머리말에 표시하는 presentation binding |
| `resources/ui/temp_industrial_theme.tres` | paper 전용 StyleBoxFlat/variation 추가 |
| `README.md` | 이전 전체 내용을 byte-prefix로 보존하고 Step70 안내만 append |
| `docs/step70_profile_paper_document_ui_pilot.md` | 신규 19절 보고서 |

제품 코드·Scene·Resource 변경은 첫 세 파일이다. 새 제품 Scene/Script/Resource는 없다. Main/Runtime/Case/Campaign/Archive/Incident Result/project settings/기존 UID는 baseline과 동일하다. 신규 framework/manager/Autoload는 0이다.

최종 Git 상태는 modified 5개, untracked 3개, staged 0, deleted 0이다. 이것에는 기존 Step69 modified Campaign 및 두 untracked 파일이 포함된다. Campaign이 `git diff`에 보여도 Step70에서 변경한 것은 아니다. 총 저장소 비생성 파일은 170개가 된다.

`git status --short`, `git diff`, `git diff --stat`, `git diff --check`, HEAD/branch/staged 및 작업 시작 해시 비교를 수행했다. `git diff --check` exit 0이다. Git의 기존 CRLF→LF 안내는 기록되며 실제 기존 파일을 일괄 줄바꿈 변환하지 않았다. 전체 diff는 `.godot/verification/step70/git_diff.txt`, 변경 whitelist 결과는 `final_audit.json`에 있다.

## 18. Known Gaps

- Step53 Prepared Pending P2, Step54 Cross-State Atomic Rollback, Step62 Failed Restore Developer Retry, Hypothesis Getter P3는 기존 OPEN으로 유지한다.
- PROFILE Side memento의 focus-only 제한을 확장하지 않았다. 정상 Navigation scroll 복원과 구분한다.
- 현재 Case의 authored Profile 본문은 짧다. 120줄/긴 metadata는 복제 controlled fixture이며 최종 콘텐츠 추가가 아니다.
- TEMP image/native font/종이 단색 배경을 사용한다. 최종 이미지·폰트·문서 디자인은 확정하지 않았다.
- Archive/Incident Result의 paper presentation 재사용은 계획만 적었으며 실제 적용하지 않았다.
- Save/Load, Ending, 최종 Story/Assets, 새 gameplay/Research 규칙·사건·경제·audio/shader를 추가하지 않았다.

## 19. Next Step Recommendation

먼저 실제 세 Case의 짧은 문서와 길이가 늘어날 문서에 대한 읽기 편의성을 사용자 검토한다. 이후 Archive의 실제 과거 Profile 조회 한 화면을 paper variation으로 시험 적용하는 것이 적절하다. 데이터를 읽는 owner/query 경계는 기존 계약을 유지하고 변경 화면에 한정해 검증한다. Incident Result는 별도 단계에서 source/context/read boundary/RESUME 회귀와 함께 검토한다. 전체 Shell 재설계나 범용 문서 시스템은 현재 규모에서 필요하지 않다.
