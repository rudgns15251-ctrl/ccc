# CAP — 개발 기반과 Case 흐름 UI 프로토타입

Godot **4.7.1 Standard**, GDScript, Windows PC용 2D UI 프로젝트입니다.
6개 임시 화면의 이동 흐름과 테스트 Resource의 PROFILE / CCTV / EXPERIMENT 표시를 구현했습니다.
실제 게임 시스템과 최종 디자인은 아직 구현하지 않았습니다.

## 실행

1. Godot 4.7.1에서 이 폴더의 `project.godot`를 가져오거나 엽니다.
2. `scenes/main/main.tscn`을 연 뒤 **F6**으로 해당 Scene을 실행하거나, **F5**로 프로젝트를 실행합니다.
3. **PROFILE**에서 시작합니다. 버튼으로 **CCTV → EXPERIMENT → CONTAINMENT → MONITORING → RESULT** 순서로 이동합니다.
   PROFILE에는 테스트 Resource의 subject_name, classification, basic_description이 표시됩니다.
   CCTV에는 camera_id, observation_text가 표시됩니다.
   EXPERIMENT에는 available_experiments 배열의 이름과 설명이 동적 목록으로 표시됩니다.
4. RESULT의 **Restart: PROFILE** 버튼으로 흐름을 반복합니다.
5. 창 크기를 변경하면 UI 비율을 유지하면서 확대/축소되고 창 크기 문구가 갱신됩니다.

각 View Scene을 따로 F6 실행하면 해당 임시 화면만 표시됩니다. 다음 화면의
선택은 Main이 담당하므로 전체 흐름 검증에는 Main의 F6 또는 프로젝트 F5를 사용합니다.
PROFILE / CCTV를 단독 실행하면 상위 계층이 데이터를 전달하지 않았으므로 명확한
누락 경고와 `Profile data unavailable` / `CCTV data unavailable`이 표시됩니다.
버튼의 진행 요청 기능은 유지됩니다.
EXPERIMENT를 단독 실행하면 빈 목록 경고와 `No experiments available`이 표시됩니다.

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
│       └── test_case_01.tres # CaseData와 내장 ProfileData / CCTVData / ExperimentData 3개
├── scenes/
│   ├── main/
│   │   └── main.tscn       # 기존 기반 UI와 ViewHost
│   └── views/
│       ├── profile_view.tscn
│       ├── cctv_view.tscn
│       ├── experiment_view.tscn
│       ├── containment_view.tscn
│       ├── monitoring_view.tscn
│       └── result_view.tscn
└── scripts/
    ├── data/
    │   ├── case_data.gd
    │   ├── case_data.gd.uid
    │   ├── cctv_data.gd
    │   ├── cctv_data.gd.uid
    │   ├── experiment_data.gd
    │   ├── experiment_data.gd.uid
    │   ├── profile_data.gd
    │   └── profile_data.gd.uid
    ├── main/
    │   ├── main.gd         # 창 크기 표시와 현재 View 전환
    │   └── main.gd.uid
    └── views/
        ├── flow_view.gd    # 버튼 입력을 진행 요청 signal로 전달
        ├── flow_view.gd.uid
        ├── cctv_view.gd    # 전달받은 CCTVData 표시
        ├── cctv_view.gd.uid
        ├── experiment_view.gd # 전달받은 ExperimentData 배열을 동적 목록으로 표시
        ├── experiment_view.gd.uid
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
                ├── Description
                ├── ExperimentScroll / ExperimentList (EXPERIMENT만, 동적 항목)
                └── NextButton
```

화면 이름과 버튼 이름은 해당 `.tscn`에 있습니다. PROFILE / CCTV / EXPERIMENT의 콘텐츠는 Resource에
있고 나머지 화면은 임시 문구를 사용합니다. Main에는 콘텐츠 문자열을 하드코딩하지 않았습니다.
모든 View는 Control 기반 독립 Scene입니다. 다른 3개 View는 기존 `flow_view.gd`를
그대로 사용하며, Profile / CCTV / Experiment 전용 Script는 이 Script를 한 단계 상속해 진행 기능을 재사용합니다.
별도의 Scene 상속이나 추상 Base Class 계층은 없습니다.

`NextButton.pressed → advance_requested → Main._on_advance_requested() → 다음 View`로
진행합니다. [Godot signal](https://docs.godotengine.org/en/4.7/getting_started/step_by_step/signals.html)을
사용하며 개별 View는 Main이나 다른 View를 참조하지 않습니다.

`main.gd`는 `Stage` enum, 이에 대응하는 6개 PackedScene 목록, 현재 단계와
현재 View 참조, Inspector에서 지정한 `current_case`를 보유합니다. 전환 시 이전 View를 ViewHost에서 제거한 뒤
`queue_free()`하고 다음 View 하나를 추가합니다. RESULT 다음은 PROFILE입니다.
기존 창 크기 표시 함수와 연결은 보존했습니다.

`flow_view.gd`는 버튼 signal 연결, 버튼의 초기 키보드 포커스, 진행 요청
signal 전송만 담당합니다. 다음 단계 결정, 데이터 처리, 결과 판정을 하지 않습니다.

## 테스트 Resource와 데이터 전달

[Godot Resource](https://docs.godotengine.org/en/4.7/tutorials/scripting/resources.html)를
데이터 컨테이너로 사용합니다. 네 클래스는 `class_name`과 typed export 필드만 정의합니다.

| 파일 | 책임 / 필드 |
| --- | --- |
| `scripts/data/case_data.gd` | CaseData: case_id, display_name, profile_data, cctv_data, available_experiments: Array[ExperimentData] |
| `scripts/data/profile_data.gd` | ProfileData: profile_id, subject_name, classification, basic_description |
| `scripts/data/cctv_data.gd` | CCTVData: camera_id, observation_text만 정의 |
| `scripts/data/experiment_data.gd` | ExperimentData: experiment_id, display_name, description만 정의 |
| `resources/cases/test_case_01.tres` | TEST_CASE_01 / TEST CASE 01, 내장 ProfileData / CCTVData / ExperimentData 3개, 검증용 표시 문구 |
| `scenes/main/main.tscn` | 테스트 Case Resource를 Main.current_case에 연결 |
| `scripts/main/main.gd` | PROFILE / CCTV / EXPERIMENT 생성 시 해당 데이터를 전달, Case 미지정/빈 ID·이름 경고 |
| `scripts/views/profile_view.gd` | setup(ProfileData), 3개 표시 필드 반영, 누락/빈 필드 경고와 대체 문구 |
| `scenes/views/profile_view.tscn` | 제목·데이터 Label·기존 진행 버튼 레이아웃 |
| `scripts/views/cctv_view.gd` | setup(CCTVData), 두 필드 표시, 누락/빈 필드 경고와 대체 문구 |
| `scenes/views/cctv_view.tscn` | 제목·CameraId·Description·기존 진행 버튼 레이아웃 |
| `scripts/views/experiment_view.gd` | setup(Array[ExperimentData]), 목록 생성/정리, 빈 배열·null 항목·빈 필드 경고 |
| `scenes/views/experiment_view.tscn` | 제목·목록 상태·ScrollContainer / VBoxContainer·기존 진행 버튼 |
| `scripts/views/flow_view.gd` | 기존 진행 기능만 담당, 이번 단계 수정 없음 |

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
ExperimentList에 이름 / 설명 Label 묶음을 배열 길이만큼 생성
```

Main은 View를 트리에 추가하기 전에 `setup()`을 호출합니다. 세 전용 View는 데이터를
보관하고 `_ready()`에서 기본 진행 기능의 `super._ready()`를 호출한 뒤 표시합니다.
트리에 들어간 후 `setup()`을 다시 호출하는 경우에도 표시를 갱신하도록 했습니다.
세 View는 특정 `.tres` 경로를 알거나 로드하지 않으며, 데이터를 수정하지 않습니다.
순환 후 View를 새로 만들 때에도 동일한 Case의 데이터를 다시 전달합니다.

ExperimentView는 배열 순서대로 `VBoxContainer`와 이름/설명 Label 두 개를 생성합니다.
항목은 표시만 필요하므로 별도 Component Scene이나 Script를 추가하지 않았습니다.
목록을 다시 표시하기 전에 이전 항목을 컨테이너에서 제거하고 해제하므로 반복 `setup()`에도
중복되지 않습니다. 기본 세 항목은 스크롤 없이 보이며, 네 번째 항목부터는 스크롤로 확인합니다.
이 스크롤은 목록 확인용이고 선택/실행 상태는 없습니다. 진행 버튼은 스크롤 영역 밖에 있습니다.

테스트 Resource 교체는 `main.tscn`의 **Main**을 선택하고 Inspector의
**Current Case (`current_case`)**에 다른 CaseData Resource를 지정한 뒤 Scene을 저장합니다.
GDScript에는 테스트 Resource 경로가 없으므로 Script를 수정할 필요가 없습니다.

표시 값만 바꾸려면 `test_case_01.tres`를 열고 내장 `profile_data`의
`subject_name`, `classification`, `basic_description`을 편집해 저장한 뒤 게임을 다시 실행합니다.
같은 Resource의 내장 `cctv_data`에서 `camera_id`, `observation_text`도 편집할 수 있습니다.
`available_experiments` 배열에서는 ExperimentData의 이름/설명을 편집하거나 항목을 추가·제거합니다.
각 항목의 필드는 experiment_id, display_name, description뿐이며 기본 테스트 데이터는 세 개입니다.
Resource를 실행 중 자동 갱신하는 기능은 추가하지 않았습니다.

데이터가 null이면 경고와 대체 문구를 표시합니다. 빈 문자열 또는 공백만 있는 값은
필드 이름이 포함된 경고와 `[Missing 필드명]`으로 표시하며, 진행 버튼은 계속 동작합니다.
`case_id`, `display_name`, `profile_id`가 비어 있을 때도 해당 필드 경고를 출력합니다.
별도 Content Validator 시스템은 없습니다.
Experiment 배열이 비면 `No experiments available`을 표시합니다. null 항목은 해당 위치에
누락 대체 항목을 표시하고, 빈 experiment_id는 경고만 출력합니다. 이름/설명이 비면
해당 Label에 `[Missing display_name]` / `[Missing description]`을 표시합니다.

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
UID 파일은 Git 보존 대상이며 최초 커밋은 아직 만들지 않았습니다.

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

현재 구현은 임시 Main UI, 창 크기 표시, 6개 View의 순차 이동과 테스트 Resource의
PROFILE / CCTV 텍스트와 EXPERIMENT 동적 목록 표시뿐입니다. 테스트 Case는 시스템 검증용이며 정식 세계관/크리쳐가 아닙니다.
CCTV 이미지·영상·상태 변화·환경 수치, Experiment 선택·제한·실행·결과·수행 기록, Containment 데이터·판정,
Monitoring 상태 변화, Success/Failure, Campaign, Case 로직,
Containment, Monitoring, Incident, Broadcast, Research Log,
Save/Load, Settings, Horror Event, 검열·이미지 시스템, CRT/Shader, Audio, Animation,
GameState Singleton, CaseManager, CampaignManager, 최종 UI/폰트/에셋은 구현하지 않았습니다.

다음 단계에서는 이번 CaseData → 화면별 Resource → View.setup() 경계를 유지하면서
필요한 표시 항목을 한 가지씩 검증할 수 있습니다. 다른 화면의 데이터가 실제로 필요해지면 해당 화면용
Resource와 표시 Script만 추가하는 지점이 적합합니다. 아직 사용하지 않는 필드나
게임 시스템은 미리 만들지 않습니다.
Experiment 표시 확장은 `experiment_data.gd`와 `experiment_view.gd`에서 시작할 수 있습니다.
선택/실행 동작은 별도 다음 단계의 요구사항이 정해졌을 때 추가합니다.
