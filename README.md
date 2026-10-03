# CAP — 개발 기반과 Case 흐름 UI 프로토타입

Godot **4.7.1 Standard**, GDScript, Windows PC용 2D UI 프로젝트입니다.
9개 정규 화면의 명시적 이동 흐름과 RESULT에서 여는 Research Log 보조 화면을 구현했습니다.
EXPERIMENT 목록에서 하나를 선택하고 즉시 테스트 결과 텍스트를 표시할 수 있습니다.
각 Experiment ID는 Case당 한 번만 실행할 수 있고 CaseData.experiment_limit을 소비합니다.
Main이 소유하는 메모리 CaseRuntimeState가 중복과 제한을 검증한 뒤 승인한 실행만 기록합니다.
CONTAINMENT는 후보 Resource 배열의 이름·설명을 표시하고 하나를 임시 선택할 수 있습니다.
선택은 View 안에만 유지하며 Confirm Containment로 확정한 Room ID는 CaseRuntimeState에 기록합니다.
확정 이후에만 MONITORING으로 진행합니다. Room 자체에 정답 필드를 두지 않습니다.
MONITORING은 확정 Room ID에 맞는 Outcome을 time_offset에 따라 순차 재생하고 관찰 기록을 누적합니다. 모든 유효 Stage가 공개된 뒤 Main/Runtime이 결과를 확정합니다. SUCCESS는 RESULT로, FAILURE는 ID로 찾은 IncidentData를 INCIDENT에, 연결된 EmergencyBroadcastData와 단일 선택 Option 목록을 BROADCAST에 표시합니다. Confirm Broadcast가 승인되어 두 ID를 Runtime에 기록한 뒤 INCIDENT_RESULT에서 해당 결과 콘텐츠를 표시하고 RESULT로 진행합니다.
RESULT는 Main이 전달한 표시용 snapshot으로 Case, 확정 결과/Room, 실제 실행 순서의 Experiment와 사용 수를 읽기 전용으로 요약합니다. FAILURE에는 현재 Incident/Broadcast/확정 Option/IncidentResult도 표시하며 SUCCESS에는 없음/해당 없음으로 표시합니다.
RESEARCH LOG는 현재 Case의 Profile/CCTV, 실제 실행한 Experiment의 설명·결과, 확정 Room, 완료된 Monitoring 관찰, FAILURE의 확정 응답·결과를 카테고리별로 읽기만 합니다. 영구 기록은 없습니다.
실제 게임 시스템과 최종 디자인은 아직 구현하지 않았습니다.

## 실행

1. Godot 4.7.1에서 이 폴더의 `project.godot`를 가져오거나 엽니다.
2. `scenes/main/main.tscn`을 연 뒤 **F6**으로 해당 Scene을 실행하거나, **F5**로 프로젝트를 실행합니다.
3. **PROFILE**에서 시작합니다. 버튼으로 **CCTV → EXPERIMENT → CONTAINMENT → MONITORING** 순서로 이동합니다. 이후 SUCCESS는 RESULT, FAILURE는 INCIDENT → BROADCAST → INCIDENT_RESULT → RESULT입니다.
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
   초기 상태에는 선택이 없고 Confirm과 **Next: MONITORING**이 비활성화됩니다.
   Room을 선택한 뒤 **Confirm Containment**를 누르면 현재 Case 후보를 검증하고 한 번만 확정합니다.
   확정된 후보는 **[Confirmed]**로 표시되며 후보 변경과 재확정은 불가능합니다.
   확정 후 **Next: MONITORING**으로 진행합니다. 재진입하면 Runtime의 확정 상태를 복원합니다.
   MONITORING에는 확정 Room ID와 전체 Stage 개수가 표시됩니다. 테스트 기록은 진입 직후, 10초 후, 20초 후 하나씩 누적됩니다.
   미래 Stage 내용과 최종 결과는 미리 공개하지 않습니다. 마지막 Stage 후 Main이 해당 Case/Room Outcome의 결과를 검증합니다.
   Runtime에 결과를 한 번 기록한 뒤 **Monitoring Result: SUCCESS / FAILURE**를 표시하고 **Next: RESULT**를 활성화합니다.
   확정 결과가 있는 같은 Case 재진입에서는 전체 기록과 결과를 즉시 복원하며 Timer를 시작하지 않습니다.
   결과가 없는 재진입은 처음부터 재생합니다. 데이터 누락·미정의 결과·기록 실패는 경고와 함께 Next를 차단합니다.
   Monitoring의 기존 **Next: RESULT** 버튼은 진행 요청만 보냅니다. Main이 Runtime 결과에 따라 다음 화면을 결정합니다.
   FAILURE의 INCIDENT는 현재 Case에서 ID로 검색한 incident_id / display_name / description을 표시합니다. Room01은 TEST_INCIDENT_01, Room03은 TEST_INCIDENT_03입니다. 유효 Incident와 연결된 Broadcast/Option이 있어야 Next: BROADCAST를 활성화합니다. 누락 시 경고와 대체 문구 또는 진행 차단을 적용합니다.
   BROADCAST는 broadcast_id / display_name / prompt_text와 options의 ID·문구를 Label로 표시합니다. 각 문구 옆 CheckBox로 하나를 임시 선택할 수 있고 재클릭해도 선택을 유지합니다. 처음에는 Confirm과 Next가 비활성화됩니다. 유효 Option을 선택하면 **Confirm Broadcast**만 활성화됩니다. Confirm 시 Main이 현재 Case/FAILURE/Incident/Broadcast와 Option ID, Option.result_id에 대응하는 실제 IncidentResultData까지 다시 확인하고 최초 ID 쌍만 Runtime에 기록합니다. 확정 항목은 **[Confirmed]**, 모든 Option과 Confirm은 disabled, **Next: INCIDENT RESULT**는 활성화됩니다. 같은 Broadcast 재진입은 이 상태를 복원합니다. 다른 Broadcast 또는 잘못된 snapshot은 경고와 함께 진행을 차단합니다. 연결된 결과가 없으면 Confirm을 거부하고 미확정 Next를 비활성 상태로 유지합니다. 피해/점수 판정은 없습니다.
   INCIDENT_RESULT에는 확정 Option의 result_id로 검색한 결과 ID/이름/설명을 표시합니다. 정상 데이터에서 Next: RESULT가 활성화됩니다. 누락 데이터는 경고/대체 문구와 진행 차단을 적용합니다. 다른 결과를 대신 표시하지 않습니다.
4. RESULT에서 Case ID/이름, **SUCCESS / FAILURE**, 확정 Room ID/이름, 실행 순서의 Experiment ID/이름, **Experiment Usage**를 확인합니다. FAILURE에는 연결된 Incident/Broadcast/확정 Option/IncidentResult의 ID와 이름·문구를 표시합니다. SUCCESS에는 Incident 없음, 나머지 실패 항목 해당 없음으로 표시합니다. 이력이 길어지면 요약 영역을 스크롤합니다.
   **Open Research Log**로 현재 Case의 확인된 정보를 열람하고 **Back to Result**로 동일 요약에 돌아옵니다. 이 이동은 Runtime과 Resource를 변경하지 않습니다.
   **Restart: PROFILE** 버튼으로 흐름을 반복합니다.
   이 버튼은 화면 흐름만 다시 시작합니다. 같은 Case의 실행 이력, 격리 확정, Monitoring 결과, Broadcast 확정 ID 쌍은 유지됩니다. Runtime.reset()은 이 상태를 모두 초기화합니다.
5. 창 크기를 변경하면 UI 비율을 유지하면서 확대/축소되고 창 크기 문구가 갱신됩니다.

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
│       └── test_case_01.tres # 기존 콘텐츠와 Outcome3개 / Stage9개 / Incident2개 / Broadcast2개 / Option6개 / IncidentResult6개
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
│       └── research_log_view.tscn # RESULT에서 여는 보조 화면, 동적 Entry 목록과 Back
└── scripts/
    ├── data/
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
    │   ├── profile_data.gd
    │   └── profile_data.gd.uid
    ├── main/
    │   ├── main.gd         # 창 크기 표시, View 전환, Runtime 연결, 격리 후보 검증/진행 보호
    │   └── main.gd.uid
    ├── runtime/
    │   ├── case_runtime_state.gd # 메모리 Case ID, 실행 이력, 격리 ID, Monitoring 결과, Broadcast 확정 ID 쌍
    │   └── case_runtime_state.gd.uid
    └── views/
        ├── broadcast_view.gd # 동적 Option/임시 선택/확정 요청, 확정 snapshot 복원과 UI 잠금
        ├── broadcast_view.gd.uid
        ├── flow_view.gd    # 버튼 입력을 진행 요청 signal로 전달
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
        ├── research_log_view.gd # 표시용 Snapshot/Entry, 동적 읽기 전용 목록
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
                ├── Actions / ConfirmButton / NextButton (CONTAINMENT, BROADCAST)
                ├── StageScroll / StageList (MONITORING만, 동적 시간/관찰 Label)
                ├── SummaryScroll / SummaryColumns (RESULT만)
                │   ├── Common: Case / FinalResult / Containment / Usage / 동적 ExperimentList
                │   └── FailureDetails: Incident / Broadcast / 확정 Option / IncidentResult
                ├── Actions / OpenResearchLogButton / NextButton (RESULT)
                ├── MonitoringResult / EntryScroll / EntryList (RESEARCH LOG)
                └── NextButton (나머지 View)
```

화면 이름과 버튼 이름은 해당 `.tscn`에 있습니다. PROFILE / CCTV / EXPERIMENT / CONTAINMENT / MONITORING 콘텐츠는 Resource에
있습니다. INCIDENT, BROADCAST, INCIDENT_RESULT도 Case Resource의 데이터를 표시하고 RESULT는 확정된 Runtime과 현재 Case에서 파생한 snapshot을 표시합니다. Main에는 콘텐츠 문자열을 하드코딩하지 않았습니다.
모든 View는 Control 기반 독립 Scene입니다. Profile / CCTV / Experiment / Containment / Monitoring / Incident / Broadcast / IncidentResult / Result / ResearchLog 전용 Script는 기존 `flow_view.gd`를 한 단계 상속해 버튼 요청 기능을 재사용합니다.
별도의 Scene 상속이나 추상 Base Class 계층은 없습니다.

`NextButton.pressed → advance_requested → Main._on_advance_requested() → 다음 View`로
진행합니다. [Godot signal](https://docs.godotengine.org/en/4.7/getting_started/step_by_step/signals.html)을
사용하며 개별 View는 Main이나 다른 View를 참조하지 않습니다.

`main.gd`는 `Stage` enum, 이에 대응하는 10개 PackedScene 목록, 현재 단계와
현재 View 참조, Inspector에서 지정한 `current_case`를 보유합니다. 전환 시 이전 View를 ViewHost에서 제거한 뒤
`queue_free()`하고 다음 View 하나를 추가합니다. RESULT 다음은 PROFILE입니다.
Stage enum은 PROFILE=0, CCTV=1, EXPERIMENT=2, CONTAINMENT=3, MONITORING=4,
RESULT=5, INCIDENT=6, BROADCAST=7, INCIDENT_RESULT=8, RESEARCH_LOG=9입니다. 새 Stage를 배열 끝에 추가해 기존 인덱스를 보존했습니다.
_get_next_stage(stage)의 match가 다음 Stage를 명시적으로 반환하고, -1이면 전환하지 않습니다.
RESEARCH_LOG는 이 정규 Route에 포함되지 않아 -1을 반환합니다. RESULT의 research_log_requested와 Log의 advance_requested는 Main의 전용 Open/Back handler에 연결하며, Stage와 활성 View를 확인한 뒤 명시적으로 RESULT ↔ RESEARCH_LOG만 이동합니다.
진행 signal에는 발신 View를 bind합니다. 현재 View와 다른 객체, Tree 밖 객체,
queue_free 예정 객체의 요청은 무시해 이전 Monitoring / Incident / Broadcast / IncidentResult의 중복 전환을 차단합니다.
Main._is_active_view()가 이 생명주기 검사를 공통으로 수행하며 화면 진행, Experiment 실행,
Containment/Broadcast 확정, Monitoring 완료, Research Log Open/Back 요청 모두 같은 검사를 통과해야 합니다.
Route는 Runtime.get_monitoring_result()만 사용하며 표시 문구나 View 내부 bool을 읽지 않습니다.
INCIDENT는 기존 FlowView를 사용하는 Control → CenterContainer → VBoxContainer에
제목, 이름, ID, 설명, NextButton을 둡니다. Incident Scene의 기존 구성을 보존했습니다. Broadcast Scene의 기존 Actions/ConfirmButton/NextButton을 유지하고 Next 문구만 바꿨습니다. Runtime의 기존 Broadcast/Option 확정 ID 문자열 두 개를 유지하며 별도 Result 필드는 추가하지 않았습니다.
기존 창 크기 표시 함수와 연결은 보존했습니다.
Main._ready()에서 현재 Case ID로 CaseRuntimeState를 한 번 생성합니다.
일반 View 전환, RESULT → PROFILE, ExperimentView.setup()은 런타임 상태를 초기화하지 않습니다.
Containment → Monitoring은 Runtime에 확정된 Room이 있어야 진행됩니다.
View 버튼 disabled 상태뿐 아니라 Main의 진행 요청 처리에서도 확정 여부를 검사합니다.

`flow_view.gd`는 버튼 signal 연결, 버튼의 초기 키보드 포커스, 진행 요청
signal 전송만 담당합니다. 다음 단계 결정, 데이터 처리, 결과 판정을 하지 않습니다.

## 테스트 Resource와 데이터 전달

[Godot Resource](https://docs.godotengine.org/en/4.7/tutorials/scripting/resources.html)를
데이터 컨테이너로 사용합니다. 열한 콘텐츠 클래스는 `class_name`과 typed export 필드로 콘텐츠를 정의합니다. MonitoringOutcomeData에는 최종 결과 enum도 있습니다.

| 파일 | 책임 / 필드 |
| --- | --- |
| `scripts/data/case_data.gd` | CaseData: 기존 필드, containment_outcomes: Array[MonitoringOutcomeData], incidents: Array[IncidentData], emergency_broadcasts: Array[EmergencyBroadcastData], incident_results: Array[IncidentResultData] |
| `scripts/data/profile_data.gd` | ProfileData: profile_id, subject_name, classification, basic_description |
| `scripts/data/cctv_data.gd` | CCTVData: camera_id, observation_text만 정의 |
| `scripts/data/experiment_data.gd` | ExperimentData: experiment_id, display_name, description, result_text만 정의 |
| `scripts/data/containment_data.gd` | ContainmentData: room_id, display_name, description만 정의 |
| `scripts/data/monitoring_stage_data.gd` | MonitoringStageData: time_offset: int(초), observation_text: String |
| `scripts/data/monitoring_outcome_data.gd` | MonitoringOutcomeData: Result enum(UNDEFINED/SUCCESS/FAILURE), room_id, stages, final_result, incident_id |
| `scripts/data/incident_data.gd` | IncidentData: incident_id, display_name, description, broadcast_id |
| `scripts/data/broadcast_option_data.gd` | BroadcastOptionData: option_id: String, display_text: String, result_id: String |
| `scripts/data/incident_result_data.gd` | IncidentResultData: result_id: String, display_name: String, description: String |
| `scripts/data/emergency_broadcast_data.gd` | EmergencyBroadcastData: broadcast_id: String, display_name: String, prompt_text: String, options: Array[BroadcastOptionData] |
| `resources/cases/test_case_01.tres` | 기존 테스트 콘텐츠, Room별 Outcome 3개와 각 Stage 3개(0/10/20초), 검증용 문구, Room01/03 FAILURE·Room02 SUCCESS, Incident01/03 → Broadcast01/03 ID 연결, 각각 Option3개와 result_id로 연결한 개발용 IncidentResult6개 |
| `scenes/main/main.tscn` | 테스트 Case Resource를 Main.current_case에 연결 |
| `scripts/main/main.gd` | 데이터 전달/전환, CaseRuntimeState 소유, 실행 승인, 격리 후보 검증/진행 차단, Monitoring 완료 시 Outcome 재검증과 결과 기록, Incident/Broadcast ID 검색과 현재 데이터/유효 Option/Result 연결 재검증 |
| `scripts/runtime/case_runtime_state.gd` | RefCounted 메모리 객체, Case ID/실행 이력, 중복·제한 검증, 격리 ID/Monitoring 결과/Broadcast ID 쌍 한 번 확정·조회/reset |
| `scripts/views/profile_view.gd` | setup(ProfileData), 3개 표시 필드 반영, 누락/빈 필드 경고와 대체 문구 |
| `scenes/views/profile_view.tscn` | 제목·데이터 Label·기존 진행 버튼 레이아웃 |
| `scripts/views/cctv_view.gd` | setup(CCTVData), 두 필드 표시, 누락/빈 필드 경고와 대체 문구 |
| `scenes/views/cctv_view.tscn` | 제목·CameraId·Description·기존 진행 버튼 레이아웃 |
| `scripts/views/experiment_view.gd` | 목록/선택, experiment_execution_requested(ID), 승인 후 결과와 전달된 실행 상태 표시 |
| `scenes/views/experiment_view.tscn` | 제목·목록·RemainingCount·RunButton·결과 영역·기존 진행 버튼 |
| `scripts/views/containment_view.gd` | setup(rooms, confirmed_room_id), 후보/선택/확정 요청, snapshot 표시, 누락 처리 |
| `scenes/views/containment_view.tscn` | 기존 제목·개수·목록, Actions의 Confirm Containment / Next: MONITORING |
| `scripts/views/monitoring_view.gd` | setup(outcome, finalized_result), Timer 순차 공개/완료 signal, 결과 적용/재진입 복원/Next 보호 |
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
| `scenes/views/research_log_view.tscn` | Control/Center/VBox, 제목·Case·MonitoringResult·EntryScroll/EntryList·Back to Result |
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
reset()은 기존 Case ID 정책을 유지하면서 실험 이력/확정 Room/Monitoring 결과/Broadcast 확정 ID 쌍을 모두 초기화합니다.
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
Main은 `CaseRuntimeState.try_record_experiment_execution(ID, limit)`으로 승인과 기록을 요청합니다.
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
UID 파일은 Git 보존 대상입니다. 23단계까지 `c9b3074`에 커밋·push되어 있으며 이번 24단계 변경은 미커밋 상태입니다.

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
현재 Research Log는 RESULT에서 열람하는 읽기 전용 파생 표시입니다. 진행률·영구 기록은 없으며 테스트 limit 2는 최종 게임 밸런스가 아닙니다.
Containment 확장은 `containment_view.gd`의 선택 처리에서 시작할 수 있습니다.
확정 ID 조회와 현재 Resource → Main → View.setup 경계에서 다음 요구사항을 확장할 수 있습니다.
Monitoring 확장은 MonitoringStageData/MonitoringOutcomeData와 MonitoringView.setup 및 재생 완료 경계에서 시작할 수 있습니다.
다음 단계 요구사항이 정해지면 이 경계에만 필요한 동작을 추가합니다. Stage 재생 완료와 Runtime 결과 확정은 별개이며 이후 Route는 Main._get_next_stage()에서 결정합니다. Incident 표시 확장은 IncidentData → Main의 ID 검색 → IncidentView.setup() 경계에서 시작할 수 있습니다. Broadcast 확장은 EmergencyBroadcastData/OptionData → Main의 ID 검색 → BroadcastView.setup() / confirmation signal → Runtime ID 쌍 경계에서 시작합니다. 피해/점수와 이벤트 트리거 등은 다음 요구사항이 있을 때 추가합니다.

Broadcast Option 선택은 View 내부의 임시 상태이며, 현재 단계에서는 명시적 확정과 Runtime ID 쌍 기록이 Next의 필수 조건입니다. 다음 단계에서는 두 확정 ID와 현재 Case의 Resource 조회 경계에서 요구된 기능만 추가할 수 있습니다.

Incident Result 표시는 BroadcastOptionData.result_id → Main의 ID 검색 → IncidentResultView.setup() 경계에서 확장할 수 있습니다. 별도의 Runtime Result 상태 없이 기존 확정 쌍에서 파생합니다.
Case Result 표시는 기존 Runtime 조회 → Main._build_result_summary() → ResultView.setup(Summary) 경계에서 확장할 수 있습니다. 현재는 읽기 전용 표시이며, 저장 결과/다음 Case/피해·점수 요구사항은 구현하지 않았습니다.
Research Log 표시는 Main._build_research_log_snapshot() → ResearchLogView.setup(Snapshot) 경계에서 확장할 수 있습니다. 정식 기록 문구가 기존 콘텐츠와 달라져야 할 요구가 생기면 별도 Resource를 검토하고, 진행 중 열람은 Timer 정책을 먼저 정합니다. 영구/다중 Case 기록은 별도 요구가 있을 때 설계합니다.
