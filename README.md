# CAP

연구시설의 대상을 관찰·실험하고 격리 결정을 내리는 **Windows PC용 2D UI 게임 프로토타입**입니다. 현재 3개 테스트 Case와 사건 대응·업무 복귀 흐름을 구현했습니다.

- **개발 환경:** Godot 4.7.1 Standard · GDScript · Compatibility 렌더러
- **UI:** 기준 1920×1080, 초기 창 1280×720, `canvas_items` 스케일링

## 실행

1. Godot 4.7.1에서 [project.godot](project.godot)를 가져와 엽니다.
2. **F5**로 프로젝트를 실행합니다. 시작 Scene은 [main.tscn](scenes/main/main.tscn)입니다.
3. Case01의 PROFILE에서 시작해 화면의 버튼으로 진행합니다.

M2/M3 임시 개체·자료 수집은 [m2_playtest.tscn](scenes/playtests/m2_playtest.tscn)을 열고 **F6**으로 실행합니다. Windows 테스트 빌드의 로컬 경로는 `builds/m3/CAP_M3.exe`입니다.

## 플레이 흐름

각 Case의 기본 업무는 다음 순서로 진행합니다.

```text
PROFILE → CCTV → EXPERIMENT → CONTAINMENT
```

- 대상을 확인하고 관찰 정보를 읽은 뒤, 횟수 제한 내에서 실험을 실행하고 격리 공간을 선택·확정합니다.
- 테스트 Campaign 순서: **Case01 → Case02 → 임시 필수 사건 → Case03**.
- Case03의 첫 EXPERIMENT 진입에서 임시 Mid-Case 사건이 발생합니다. **INCIDENT → BROADCAST → RESULT → RESUME WORK**로 대응한 뒤 같은 Case의 중단된 업무에 복귀합니다.
- 격리 결정에 따른 시설 조건 변화와 지연 사건도 포함되어 있습니다. 이전 업무 화면은 Review로 다시 확인할 수 있습니다.

## 화면과 기록 도구

| 버튼 | 역할 |
| --- | --- |
| 왼쪽 PROFILE / CCTV / EXPERIMENT / CONTAINMENT | 접근 가능한 업무 화면으로 이동하거나 이전 화면 재열람 |
| **R — Research Log** | 현재 Case에서 확보한 관찰·연구 기록 확인 |
| **A — Research Archive** | 보관된 Case별 Research와 메모 조회 |
| **N — Working Hypothesis** | 현재 Case에 대한 추론 메모 작성·수정·삭제 |
| **저장 / 불러오기** | 안정된 대상 정보·격리 화면에서 저장, 확인 후 마지막 저장 복원 |

사건 대응 중에는 R이 사건 출처 기록 화면으로 연결됩니다.

## 프로젝트 구조

```text
scenes/      Main, 업무 화면, 공용 UI Scene
scripts/     화면 전환, View, 데이터 타입, 런타임 상태, 읽기 모델
resources/   Case, Campaign, 사건 콘텐츠, 임시 Theme
assets/      게임 에셋용 폴더
docs/        단계별 설계·구현·검증 보고서
```

## 현재 개발 범위

- 콘텐츠·이미지 Placeholder·Industrial Theme·Profile 종이 문서 UI는 개발 확인용입니다.
- Campaign별 수동 저장 1개를 지원합니다. 진행·연구·메모·완료 사건·실패 후보·수집 자료를 `user://campaign_saves/`에 보존합니다. 사건·실험·전환 중 저장은 지원하지 않습니다.
- 보관함의 **스토리 자료** 탭은 발견한 자료만 표시합니다. M2 환경의 자료 3개는 비정사 검증용이며 원본 교육 영상은 아직 없습니다.
- 마지막 Case 이후의 최종 Campaign 완료·Ending은 구현하지 않았습니다. 기존 Monitoring/Result 재생 경로는 개발 검증용입니다.
- Godot 4.7.1에서 프로젝트·스크립트 검사와 1920×1080 / 1280×720 GPU 검증을 수행했습니다. 세부 결과와 남은 과제는 아래 보고서에 있습니다.

## 개발 문서

- [M3 자료 수집·안전한 저장/복원](docs/m3_campaign_records_save_load.md)
- [개발 문서 안내·개발 방식·이력](docs/README.md)
- [코드 구조와 주요 흐름](docs/architecture.md)
- [실행과 검증 방법](docs/verification.md)
