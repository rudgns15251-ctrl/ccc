# 실행과 검증

## 필요한 환경

- Windows PC, PowerShell, Godot 4.7.1 Standard
- 저장소를 내려받은 폴더에서 실행
- 아래 `$GodotPath`에 본인이 설치한 Godot console 실행 파일 경로 지정

## 기본 명령행 검사

```powershell
$GodotPath = 'C:\Tools\Godot\Godot_v4.7.1-stable_win64_console.exe'
.\tools\verify_project.ps1 -GodotPath $GodotPath
```

경로는 예시입니다. 스크립트는 엔진 버전을 확인하고 editor import, 제품 GDScript 전체 check-only, configured Main headless 실행을 차례로 검사합니다. 종료 코드와 오류 로그를 확인하며 실패하면 중단합니다. 결과는 Git 제외 경로인 `.godot/verification/public_smoke/<실행 시각>/`에 저장됩니다.

이 검사는 기본 import·파싱·시작 여부를 확인합니다. 클릭, 화면 전환, 사건 복귀, 장시간 상태 변화 또는 GPU 배치 전체를 자동 검증하는 suite는 아닙니다.

공개 스크립트를 추가할 때 실제 프로젝트에서 import·GDScript 53개·Main 시작 검사 55건을 통과했습니다. 별도 임시 프로젝트로 GDScript 파싱 오류와 종료 코드 0의 런타임 ERROR가 실패로 처리되는 것도 확인했습니다. 게임 코드·Scene·Resource·프로젝트 설정은 이 문서 정리에서 변경하지 않았습니다.

## 화면에서 확인할 흐름

Godot에서 `project.godot`를 열고 F5로 실행합니다.

1. Case01 PROFILE에서 시작하는지, CCTV로 이동할 수 있는지 확인합니다.
2. EXPERIMENT에서 실험을 선택·실행하고 결과와 사용 횟수를 확인합니다.
3. CONTAINMENT에서 공간을 선택·확정하고 다음 Case로 진행합니다.
4. Case02 이후 필수 사건의 Broadcast 선택·확정·Result 확인을 거쳐 Case03으로 진입합니다.
5. Case03의 첫 EXPERIMENT 진입에서 Mid-Case 사건을 처리한 뒤 RESUME WORK로 같은 업무에 돌아오는지 확인합니다.
6. 업무 중 R/A/N과 이전 화면 Review를 열고 돌아왔을 때 진행·기록이 유지되는지 확인합니다.
7. 1280×720와 1920×1080에서 Header·문서·CTA의 잘림과 겹침을 확인합니다.

환경 교란과 지연 사건은 이전 격리 결정·행동에 따라 경로가 달라집니다. 이 목록은 기본 수동 점검이며 모든 조합을 포함하지 않습니다. 마지막 Case의 다음 진행은 아직 구현되지 않은 테스트 시퀀스 경계입니다.

## 과거 보고서의 검증 자료

Step 보고서는 작성 당시 실행 결과와 실패·수정 내역을 기록한 개발 이력입니다. 이후 코드 변경이 있으므로 현재 전체 기능의 보증으로 해석하지 않습니다.

보고서에 나오는 `.godot/verification/step*/`의 runner, 로그, JSON, GPU PNG는 개발 환경에 보관한 자료입니다. `.gitignore` 정책상 **GitHub 저장소에는 포함되지 않습니다.** 따라서 저장소만 clone해서 과거 suite를 그대로 실행하거나 해당 PNG 링크를 열 수는 없습니다. 보고서의 관련 경로는 로컬 자료 식별용으로 유지했습니다.

과거 수십만 assertion 집계에는 같은 Query의 반복 호출이 포함됩니다. assertion 호출 수, 서로 다른 시나리오 수, 프로세스 실행 수, GPU 캡처 수는 다른 지표입니다. 자동 검사 통과와 사람이 느끼는 재미·공포·UX 평가는 별도로 판단해야 합니다.

공개된 기본 검사 스크립트는 [verify_project.ps1](../tools/verify_project.ps1)입니다. 과거 상세 회귀 suite를 공개하거나 다른 환경에서 재현하려면 테스트 의존성과 실행 절차를 별도로 정리해야 합니다.
