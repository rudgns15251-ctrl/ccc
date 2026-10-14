# Step71 — Playable Case UI 통합

기존 Main과 실제 테스트 Campaign에서 대상 정보 → 관찰 영상 → 실험·결과 → 격리 후보 비교·승인 → 사건 대응을 플레이할 수 있도록 네 업무 화면을 개선했다. 종이 문서 Profile, 공통 GameShell, 한국어·영어 번역, 기존 업무 규칙을 유지했다.

## 구현과 콘텐츠 연결

Godot에서 `resources/cases/test_case_01.tres` / `test_case_02.tres` / `test_case_03.tres`를 열고, Inspector의 아래 하위 Resource에 실제 제공받은 콘텐츠를 연결한다. 이미지는 먼저 `assets/`에 추가·import한 뒤 Texture 슬롯에 지정한다.

| Resource / 필드 | 표시와 빈 값 처리 |
| --- | --- |
| `CaseData.profile_data` → `ProfileData.subject_texture` | 개체 사진. 없으면 기존 Placeholder |
| `ProfileData.past_observations` | 종이 문서의 과거 관찰 사실. 공백이면 섹션 숨김 |
| `ProfileData.researcher_notes` | 연구자 소견. 공백이면 섹션 숨김 |
| `CaseData.cctv_data` → `CCTVData.feed_texture` | 실제 일반 카메라 이미지. 없으면 Placeholder |
| `CCTVData.thermal_texture` | 제공된 실제 열화상 이미지. 없으면 모드 버튼 숨김 |
| `CaseData.available_experiments[i]` → `ExperimentData.result_texture` | 실행 이력에 있는 현재 결과에만 이미지 표시. 없으면 텍스트만 표시 |
| `CaseData.available_containment_rooms[i]` → 기존 `ContainmentData.description` | 후보별 실제 환경 설명과 선택 상세. 수치·정답 필드 추가 없음 |

사진은 [TextureRect의 비율 유지·중앙 표시](https://docs.godotengine.org/en/latest/classes/class_texturerect.html)를 사용하며 자르거나 늘리지 않는다. Profile 문서, 관찰·실험 결과, 격리 목록·상세는 스크롤로 읽는다. 기존 `basic_description`은 그대로 표시한다. 작성자·날짜·보안 등급·사고 이력을 자동으로 만들지 않는다.

CCTV는 기존 한 개의 `CCTVData`를 유지하며 카메라 식별자를 표시한다. 일반/열화상은 같은 카메라의 표시 모드이며 별도 Research source나 새 단서를 자동 생성하지 않는다. 새 문서 필드와 사진 표시도 기존 연구 발견 규칙을 바꾸지 않는다. 새 영어 문구는 [번역 안내](localization.md)에 따라 PO에 추가한다.

## 실제 플레이에서 달라진 점

- 실험 목록은 선택·실행 완료 상태를 강조하고, 상세 설명·실행 버튼·남은 횟수를 구분한다. 새 실험 선택 시 이전 결과 사진을 지우며, 실행한 결과는 Review에서도 다시 표시한다.
- 격리는 후보 구성과 현재 선택을 구분한다. 기존 승인 Modal에서 내용을 재확인하고, 승인 후에도 구성 설명을 유지하면서 선택을 잠근다. 성공 여부는 미리 공개하지 않는다.
- Profile 문서 스크롤, CCTV 모드, 격리 상세 스크롤을 UI 복귀 상태에 포함했다. 긴 격리 설명은 복귀 레이아웃 계산 전에 준비해 스크롤을 정확히 복원한다. Runtime과 지연 판정은 재생성하지 않는다.
- 선택 항목은 마우스를 올린 상태에서도 강조가 유지된다. Main 변경은 격리 선택의 복귀 준비 6줄이며, 공통 Shell·환경 조건 View·사건·이력 시스템은 다시 작성하지 않았다.

## 변경 파일

- `scripts/data/{profile,cctv,experiment}_data.gd`: 선택적 표시 필드.
- `scenes/views/{profile,cctv,experiment,containment}_view.tscn`와 대응 View Script: 사진·문서·선택·결과 표시.
- `scripts/read_models/interrupted_work_view_state.gd`, `scripts/main/main.gd`: 표시 상태 검증과 복귀 준비.
- `resources/ui/temp_industrial_theme.tres`, `translations/{en,ko}.po`: 선택 강조와 새 UI 문구.
- `export_presets.cfg`: 로컬 템플릿을 쓰는 Windows 테스트 export.
- 이 보고서·문서 안내·아래 스크린샷. 스크린샷 폴더의 `.gdignore`로 문서 이미지를 게임 자산과 구분한다.

Case01~03·Campaign·사건 Resource, 모든 Runtime Script, Main Scene·GameShell·환경 조건 View는 작업 시작 파일과 동일하다. 작업 전부터 있던 README와 `project.godot` 로컬 변경도 그대로 보존했다. stage·commit·push는 하지 않았다.

## 실행 검증

Godot **4.7.1**에서 변경 파일 import, 제품 GDScript 전체 check-only, Configured Main headless·native 실행을 통과했다. 기존 검증 도구와 Journey 검사를 재사용했으며 별도 Harness를 만들거나 반복 Fact Query suite를 실행하지 않았다.

실제 제품 Campaign의 Case01·02, TEMP Mandatory Incident → Broadcast → Result → Continue, Case03 첫 실험 진입 → TEMP Mid-Case Incident → Broadcast → Result → 동일 Runtime 실험 복귀 → 격리 승인까지 확인했다. 실제 실험 실행과 지연 실패·환경 이상·Major 대응 경로도 검사했다. Navigation, Utility Rail, Source Archive 경계, Side 복귀, 완료 사건 Historical Facts 핵심 회귀를 통과했다.

QA 전용 복제 데이터와 크기·모서리 표시용 Texture로 사진 없음/가로/세로, 긴 문서·관찰·결과·격리 설명, 일반/열화상 전환, 실행 전 결과 이미지 숨김, 실행 횟수 제한, Review, 승인 취소·잠금, 네 화면의 focus/scroll exact resume를 검사했다. 이 데이터와 이미지는 제품 Resource나 빌드에 포함하지 않았다. 상세 로컬 증거는 `.godot/verification/step71/`에 보관했다.

두 해상도의 실제 Main GPU Journey를 통과하고 글꼴·사진 비율·선택 상태·고정 버튼·스크롤을 화면으로 확인했다. 아래는 **기존 Case01 제품 데이터**의 최종 캡처이며, QA용 이미지·문서는 들어 있지 않다.

| 화면 | 1920×1080 | 1280×720 |
| --- | --- | --- |
| 대상 정보 | [보기](screenshots/step71/profile_1920.png) | [보기](screenshots/step71/profile_1280.png) |
| 관찰 영상 | [보기](screenshots/step71/cctv_1920.png) | [보기](screenshots/step71/cctv_1280.png) |
| 실험 결과 | [보기](screenshots/step71/experiment_1920.png) | [보기](screenshots/step71/experiment_1280.png) |
| 격리 비교 | [보기](screenshots/step71/containment_1920.png) | [보기](screenshots/step71/containment_1280.png) |

기존 로컬 4.7.1 Windows Template로 **`builds/step71/CAP.exe`**를 생성했다. 실행 파일의 기본 Main을 headless·native로 시작/종료했고, 프로젝트 폴더와 분리한 내장 pack 검사에서 한국어·Case01 실험 실행과 QA/문서 제외를 확인했다. 전체 Campaign Journey는 Godot 프로젝트에서 검증했다. 빌드는 Git 제외 경로다. Godot의 `Windows Test` preset으로 다시 만들 수 있다.

## 아직 필요한 것

실제 개체 사진·카메라/열화상 사진·실험 결과 이미지와 추가 연구문서는 제공되지 않아 현재 제품에는 기존 Placeholder와 원문이 남아 있다. **콘텐츠 입력·표시 기능은 완료했고 최종 자산 적용은 미완료**다. 정상 자산과 authored 문서를 확보한 뒤 위 슬롯에 연결하고, 그 콘텐츠의 번역·가독성·판단 근거를 플레이 검토하면 된다.

다중 카메라 Gameplay, 새로운 연구 발견 규칙, 사운드, Save/Load, Ending, 최종 콘텐츠는 추가하지 않았다.
