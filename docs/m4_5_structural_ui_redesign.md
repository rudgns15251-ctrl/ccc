# M4.5 — FACILITY CONTROL 구조 재설계

2026-10-16. 기존 5개 스킨 비교와 별도로 **레이아웃이 다른 독립 시안 1개**를 구현했다. 기본 F5 UI는 변경하지 않았고 최종 채택·커밋·푸시는 하지 않았다.

## 실행

Godot 4.7.1에서 [`scenes/playtests/m4_5_structural_comparison.tscn`](../scenes/playtests/m4_5_structural_comparison.tscn)을 열고 **F6**으로 실행한다. 기본 선택은 새 구조이며 Profile에서 시작한다. 상단 `UI / FACILITY CONTROL` 메뉴에서 **원본 구조 / 구조 시안**을 같은 플레이 상태에서 전환한다.

기존 `m4_5_ui_comparison.tscn`의 5개 스킨 비교 메뉴는 그대로 유지했다. 기존 Main, M2/M3, M4 실행 경로와 프로젝트 해상도·Stretch도 유지한다. 이번 새 Scene에 들어가지 않고 F5만 누르면 이전 화면이 나온다.

## 전후 비교

[동일 해상도 비교 뷰어](screenshots/m4_5_structural/index.html)를 로컬 브라우저로 열면 화면·해상도를 선택해 나란히 볼 수 있다. GitHub에서는 HTML 소스가 표시되므로 아래 PNG 링크를 사용한다. 원본 캡처 48장과 [검증 요약 JSON](screenshots/m4_5_structural/verification.json)을 보관했다.

| 화면 | 1280×720 원본 / 신규 | 1920×1080 원본 / 신규 |
|---|---|---|
| 공통 GameShell / Profile | [원본](screenshots/m4_5_structural/profile_original_1280.png) / [신규](screenshots/m4_5_structural/profile_new_1280.png) | [원본](screenshots/m4_5_structural/profile_original_1920.png) / [신규](screenshots/m4_5_structural/profile_new_1920.png) |
| CCTV | [원본](screenshots/m4_5_structural/cctv_original_1280.png) / [신규](screenshots/m4_5_structural/cctv_new_1280.png) | [원본](screenshots/m4_5_structural/cctv_original_1920.png) / [신규](screenshots/m4_5_structural/cctv_new_1920.png) |
| 방송 질문 | [원본](screenshots/m4_5_structural/question_1_original_1280.png) / [신규](screenshots/m4_5_structural/question_1_new_1280.png) | [원본](screenshots/m4_5_structural/question_1_original_1920.png) / [신규](screenshots/m4_5_structural/question_1_new_1920.png) |
| 방송문 검토 | [원본](screenshots/m4_5_structural/preview_original_1280.png) / [신규](screenshots/m4_5_structural/preview_new_1280.png) | [원본](screenshots/m4_5_structural/preview_original_1920.png) / [신규](screenshots/m4_5_structural/preview_new_1920.png) |
| 전송 승인 | [원본](screenshots/m4_5_structural/confirm_original_1280.png) / [신규](screenshots/m4_5_structural/confirm_new_1280.png) | [원본](screenshots/m4_5_structural/confirm_original_1920.png) / [신규](screenshots/m4_5_structural/confirm_new_1920.png) |
| 사고보고서 | [원본](screenshots/m4_5_structural/accident_report_original_1280.png) / [신규](screenshots/m4_5_structural/accident_report_new_1280.png) | [원본](screenshots/m4_5_structural/accident_report_original_1920.png) / [신규](screenshots/m4_5_structural/accident_report_new_1920.png) |

각 쌍은 같은 View 인스턴스에서 기존 Control을 원래 부모로 되돌리거나 새 레이아웃에 배치해 촬영했다. 전환 전후 소유 상태의 동등성을 확인했다. 확인 Modal은 소유 상태를 바꾸지 않는 취소를 거쳐 같은 초안으로 다시 열었다. 캡처에 별도 이미지 편집·합성·후보 UI 이미지 생성은 사용하지 않았다.

## 구조와 정보 계층의 실제 변경

| 영역 | 원본 | 신규 구조 |
|---|---|---|
| Shell | 왼쪽 세로 단계 / 오른쪽 약어 Utility Rail | 상단 가로 업무 키 4개 / 하단 전체 이름을 표시한 기록·메모·저장 도구 |
| 운영 정보 | 긴 상단 한 줄에 분산 | 시설·현재 단계·대상 식별을 묶은 장비 명판. 실제 제공된 환경 조건은 별도 경고 띠 |
| 자료 확보 | 세로 단계 Rail 아래 긴 버튼 | 상단 실제 자료 확보 버튼. 짧은 상태 표기와 실제 자료 제목 tooltip |
| CCTV | 일반 HBox의 영상 / 텍스트 | 카메라 명판을 모니터 프레임 안에 통합. 큰 영상과 오른쪽 독립 관찰 패널, 별도 하단 조작부 |
| 방송 작성 | 고정 좌우 패널과 공통 버튼 | 사건·중단 업무 맥락을 왼쪽에, 질문·진행 수·선택·이전/다음을 오른쪽 작성 장치에 집중 |
| 방송 검토 | 기존 선택 영역에 미리보기 텍스트 표시 | 작성 패널을 숨기고 넓은 송출문 + 별도 선택 지시 요약으로 재분할. 수정·송출을 하단 승인 조작부에 배치 |
| 전송 승인 | 작은 단일 문장 확인 창 | 넓은 종이형 전송 원고 + 독립 승인 영역. 취소 / 원고 스크롤 / 전송 확정의 Focus 순환 |
| 송출 후 | 기존 View의 버튼 상태 변경 | 실제 확정 상태에 따라 잠금 명시. 수정·재송출은 기존 로직대로 숨기고 사고보고서 진행만 제공 |

신규 CCTV의 실제 영상 사각형은 논리 해상도에서 **1188×537**, 전체 작업 폭 1880의 **63.2%**이다. 원본의 영상 폭 960보다 약 **24% 넓다**. 프레임까지 포함한 비중과 실제 영상 비중을 구분했다. 가로 Shell 때문에 전체 작업 영역도 1688에서 1880으로 넓어졌다. 동작 중 환경 알림이 추가되면 세로 공간은 줄어들고 관찰 정보는 스크롤된다.

회색 금속 면·어두운 관찰 패널·황갈색 업무 선택을 사용하고, 적갈색은 실제 환경 이상/방송·승인 영역에 제한했다. 장식용 가짜 수치·배터리·녹화 버튼·PTZ·다중 카메라·연결 상태는 추가하지 않았다. 소련/초기 러시아 산업 장비라는 방향은 기능별 분할과 제한된 색에 반영했으며, 실제 장비의 고증 완료를 뜻하지 않는다.

Profile은 기존 종이 문서, 사진 연결, 데이터, 글자 크기·색과 스크롤을 유지했다. 새 Shell에서 중앙 작업 폭만 넓어지며 CRT 화면으로 교체하지 않았다. Experiment/Containment/IncidentResult도 기존 View를 새 Shell 안에서 실행한다.

## Scene과 코드 책임

```text
scenes/playtests/m4_5_structural_comparison.tscn
scripts/main/m4_5_structural_comparison.gd
scripts/presentation/facility_control.gd
scenes/ui/facility_control/
  shell.tscn
  cctv.tscn
  broadcast.tscn
  confirmation.tscn
```

네 레이아웃은 실제 Godot Control Scene이다. Slot에 기존 Control을 연결하므로 레이아웃 Scene만 편집기에서 열면 콘텐츠가 비어 있을 수 있다. 전체 작동 화면은 비교 Scene을 F6으로 실행해 확인한다.

런타임 배치는 다음과 같다. 괄호의 Control은 새로 만든 게임 상태가 아니라 기존 View의 같은 노드이다.

```text
GameShell
  FacilityControl / Console
    Identification: (Facility, Stage, Subject, CollectRecord), 비교 메뉴
    Navigation: (PROFILE, CCTV, EXPERIMENT, CONTAINMENT)
    Alerts: (Environment)
    WorkSlot: (Workspace / ViewHost / 현재 View)
    Records: (Research, Archive, Hypothesis, Save, Load)
    StatusSlot: (SystemStatus)
  DrawerLayer / OverlayLayer / ModalLayer — 원래 레이어 유지

CCTVView / SurveillanceConsole
  Equipment
    Monitor / Stack: (ScreenTitle, CameraTab, FeedModes, CameraImage)
    Information: (ObservationHeading, ConditionObservationScroll, EnvironmentConditions)
  Controls: (Actions)

BroadcastView / BroadcastConsole
  Identification / Steps
  QuestionLayout: (Transmission), (OrdersHeading, 진행 수, OptionScroll, 질문 이동)
  PreviewLayout: (같은 OptionScroll), 선택 지시 요약, (같은 Transmission)
  Controls: (같은 Actions: Source Archive, 검토, 수정, 송출, 보고서)
```

`facility_control.gd`는 기존 부모·순서·표현 속성을 기억해 되돌리는 코드와 이 시안의 배치·표현만 담당한다. 현재 방송 초안·확정 상태를 읽어 작성/검토 패널을 전환하며 답변·결과·대응 완료를 직접 기록하지 않는다. 요약에는 실제 질문과 선택한 지시만 표시하고 결과 데이터는 읽어 미리 보여주지 않는다.

비교용 Main 확장은 기존 Main 초기화·View 전환을 호출한 뒤 표현 코드를 연결한다. Main, Runtime, Research, Response, Campaign, SaveCodec 소유자를 추가로 생성하지 않는다. 새 범용 UI 프레임워크나 전역 Singleton도 없다.

### 기존 파일에 필요한 최소 수정

- `scripts/views/flow_view.gd`: 이동된 Control의 Focus를 기존 검증 경로로 기록하고, 복원 시 그 경로에 대응하는 노드를 찾는 연결 9줄. 비교 시안의 metadata가 없는 원본은 기존 동작을 사용한다.
- `translations/ko.po`, `translations/en.po`: 구조 시안에 필요한 13개 표기 추가. 기존 영어·한국어 항목 보존.
- `docs/README.md`: 이 보고서 링크 추가.

`Main._on_work_focus_changed`와 방송 초안 복원은 비교 전용 하위 스크립트에서 연결한다. 저장 JSON의 Focus 경로는 원래 경로를 유지하고, Source Archive 복귀 때는 레이아웃·deferred focus가 정리된 뒤 기존 방송 스크롤을 복원한다. 저장 버전·데이터 타입·게임 규칙은 바꾸지 않았다.

## 에셋과 재배포

[기존 라이선스 검토](m4_5_ui_asset_comparison.md)와 [manifest](../assets/third_party/m4_5/manifest.json)를 재사용한다. 추가 다운로드·유료 구매는 없었다.

- MAUSE의 StyleBox를 복제해 이 시안의 버튼·장비 면에 맞게 색·여백·테두리를 조정했다. 새 폰트를 반입하지 않았다.
- VHS UI Free의 선택 아이콘, CCTV 영역 효과와 기존 표현 코드를 재사용했다. 가짜 녹화 상태는 표시하지 않는다.
- Retro가 로컬에 있으면 CCTV 효과 선택 시 격리된 CRT를 사용한다. 없으면 기존 VHS snow shader로 대체한다. 두 경우 모두 영상 바깥 글·버튼에 적용하지 않는다.
- 실제 영상 자료가 없는 현재 임시 화면의 가독성을 위해 효과는 **기본 꺼짐**이다. 비교 메뉴에서 켤 수 있으며 [720p 효과 캡처](screenshots/m4_5_structural/cctv_fx_1280.png) / [1080p 효과 캡처](screenshots/m4_5_structural/cctv_fx_1920.png)를 별도로 보관했다.
- Analog Horror SFX의 기존 송출음을 재사용한다. 비교 메뉴에서 명시적으로 켠 경우 실제 송출 확정에만 연결하며 기본은 꺼짐, -22 dB이다.
- `assets/local_only/` 제외 정책을 유지했다. 제한된 shader 원본을 새 공개 파일에 복제하거나 내장하지 않았다.

## 검증

환경: Windows, Godot **4.7.1.stable.official.a13da4feb**, Compatibility, RX 6800. 기존 하네스를 확장해 실제 입력 경로를 재사용했으며 새로운 전체 검증 프레임워크는 만들지 않았다.

- import 및 전체 **70개 제품 GDScript** 검사, 기본 F5 Main headless 시작 통과.
- 새 Scene의 GPU 대표 경로를 **1280×720 / 1920×1080**에서 실행해 각각 **432개 검사**, headless **375개 검사**를 통과했다. 같은 상태의 전후 화면을 저장하고 한 실행 중 창 크기 1920↔1280 변경도 확인했다.
- Profile 긴 문서 끝까지 스크롤, 실제 마우스 휠 입력, CCTV 관찰 스크롤·한국어 줄바꿈, 실제 버튼 조작 영역과 Shell 경계 확인.
- 긴 방송문은 검증용으로 기존 원고를 반복한 뒤 PageDown으로 스크롤되는지 확인했다. 검사 후 실제 authored 원고로 복원했으며 반복 원고는 콘텐츠나 비교 캡처에 포함하지 않았다.
- 마우스 선택, Space 응답, Tab/Shift+Tab 확인 창 Focus, Enter 확정, Esc 취소 검사. 비교 메뉴도 실제 마우스로 열고 키보드로 원본/신규를 전환했다.
- Research drawer 왕복 Focus, Hypothesis 임시 메모, 정상 Archive 왕복의 같은 View, Stage Navigation의 기존 Focus 경로 복원 확인.
- 실제 격리 확정 후 저장·불러오기와 payload 동등성 확인. 단순 값 비교만 하지 않고 확인 창 종료·복원 완료 상태도 검사했다.
- M4 박막낭 실패 → 다음 Case 업무 → 환경 이상 → Major Incident → 다중 질문 응답 → 방송문 검토 → 취소·수정·최종 송출 → 잠금 → Source Archive 왕복 → 사고보고서 → acknowledgement → 원래 Runtime·단계 복귀를 실행했다.
- 확정 전 결과 미발견, 송출 후 임의 재확정 거부, 사고보고서 acknowledgement 전 미완료, 복귀 뒤 기존 실패 기록 유지, 완료 사고 기록·Story/Research 탭 구분 검사.
- 기존 원본 M4 대표 경로, 실제 M3 저장 파일 호환 불러오기, 기존 원본/M2 경로 회귀 검사 통과.
- 제한 Retro 파일을 제거한 공개 복제본의 import·실행·VHS fallback·원본/구조 전환 통과.

최종 상세 결과 수치는 위 검증 JSON에 기록한다. 상세 로그·기존 하네스 확장 코드는 `.godot/verification/m4_5_structural/`에 로컬 보관한다. 공개 저장소에는 비교 Scene·실제 캡처·보고서와 기존 `tools/verify_project.ps1` 검사가 포함된다. 이 검사들은 플레이의 재미나 전체 장비의 역사적 고증을 보증하지 않는다.

### 발견한 문제와 해결

1. 제목의 자동 줄바꿈 때문에 CCTV 상단이 과도하게 커짐 → 제목 슬롯 최소 폭을 지정하고 카메라 식별 영역을 모니터 안에 통합.
2. 새 Shell이 Modal보다 뒤의 트리 순서에서 입력을 가로챔 → Drawer/Overlay/Modal 앞에 Shell을 배치. z_index만으로 입력 순서를 처리하지 않음.
3. 레이아웃 이동으로 저장용 Focus 경로가 바뀜 → 기존 경로 metadata 연결과 비교용 Focus 기록 정규화.
4. 질문 교체로 해제된 Control이 원복 목록에 남음 → 유효성을 검사한 뒤 표현 정보만 복원.
5. Source Archive 복귀 시 방송의 8px 스크롤이 0으로 바뀜 → 기존 Main이 보관한 multi draft의 스크롤을 레이아웃 배치 후 복원.
6. 긴 방송문에서 PageUp/PageDown이 동작하지 않음 → 비교 UI의 Focus된 스크롤 영역에 키 처리를 추가하고 확인 창의 원고도 Focus 순환에 포함.

## 평가와 채택 전 권장사항

**달라진 점:** 전체 화면에서 세로 Rail이 사라지고 가로 업무 키·기록 도구·중앙 작업 장치가 분리됐다. CCTV 영상은 더 넓고, 방송 작성·검토·승인은 서로 다른 분할과 조작 구성을 사용한다. 색상만 바꾼 시안과 구조적으로 구별된다.

**사용성:** 기록 도구의 약어를 전체 명칭으로 바꿔 의미가 명확해졌다. 실제 자료 확보 제목은 tooltip으로 확인한다. 넓어진 영상과 독립 관찰 스크롤은 영상/문서의 역할을 나누지만, 720p에서 긴 관찰문은 스크롤이 필요하다. 확인 창은 전송 원고와 승인 조작을 분리하고 취소를 초기 Focus로 유지한다.

**남은 검토:** 실제 CCTV 영상·열화상 Texture가 없어 움직이는 영상의 정보량과 CRT 가독성은 평가하지 못했다. 카메라 입력 상태를 가정하지 않고 임시 영역으로 표시했으며 열화상 모드는 기존 규칙대로 숨긴다. 장시간 사용과 사용자 관찰 테스트, 긴 사건 제목·추가 질문 수에서의 가독성, 환경 알림이 많아질 때 공간 배분은 채택 전에 확인해야 한다. 새 시안의 별도 저사양 성능 벤치마크는 수행하지 않았다.

**추가 구매는 필요하지 않다.** 다음 판단 지점은 새 구조의 사용성 확인과 실제 영상 자료 연결이다. 사용자가 승인하기 전에는 이 시안을 기본 F5 UI로 적용하지 않는다.

## 원본과 Git 보호

시작 시 HEAD는 M4/M4.5가 포함된 `b1cdf94`였고 미커밋 변경은 사용자 README뿐이었다. 기존 파일 387개의 해시·사본을 보관했다. README를 포함해 기존 제품 Scene, `project.godot`, 기존 M4.5 비교 코드·에셋·라이선스 파일의 바이트를 유지했다. 위에 명시한 Focus 연결·새 번역·문서 링크만 기존 파일에서 수정했다.

최종 `git diff --check`를 수행했으며, 이번 작업에서 `git add/commit/push/reset`은 하지 않았다.
