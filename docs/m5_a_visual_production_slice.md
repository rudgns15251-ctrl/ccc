# M5-A — Visual Production Vertical Slice

2026-10-16. 사용자 제공 이미지 3장을 기존 M4 콘텐츠와 FACILITY CONTROL 구조에 통합했다. **최종 UI·개체 디자인으로 채택한 상태는 아니다.** 기존 F5와 M2/M3/M4/M4.5 진입점은 보존했다.

## 실행과 비교

Godot 4.7.1에서 [`scenes/playtests/m5_a_visual_playtest.tscn`](../scenes/playtests/m5_a_visual_playtest.tscn)을 열고 **F6**을 누른다. 상단 `UI / FACILITY CONTROL` 메뉴에서 같은 플레이 상태로 원본 구조와 새 구조를 전환할 수 있다. CCTV 영상 효과와 조작·실험·경고·송출 효과음은 별도 선택이며 **기본 꺼짐**이다. F5는 기존 Main을 실행한다.

[화면 비교 뷰어](screenshots/m5_a/index.html)는 로컬 브라우저에서 화면·해상도를 선택하는 용도다. GitHub에서는 아래 PNG를 직접 확인한다. 각 원본/신규 쌍에도 **같은 이미지·같은 콘텐츠**를 연결했으므로 배치 차이를 비교할 수 있다. 자산이 없었던 이전 단계는 [M4.5 캡처](m4_5_structural_ui_redesign.md)에서 별도로 확인한다.

| 화면 | 1280×720 원본 / 신규 | 1920×1080 원본 / 신규 |
|---|---|---|
| Profile·Shell | [원본](screenshots/m5_a/profile_original_1280.png) / [신규](screenshots/m5_a/profile_new_1280.png) | [원본](screenshots/m5_a/profile_original_1920.png) / [신규](screenshots/m5_a/profile_new_1920.png) |
| CCTV | [원본](screenshots/m5_a/cctv_original_1280.png) / [신규](screenshots/m5_a/cctv_new_1280.png) | [원본](screenshots/m5_a/cctv_original_1920.png) / [신규](screenshots/m5_a/cctv_new_1920.png) |
| Experiment | [원본](screenshots/m5_a/experiment_original_1280.png) / [신규](screenshots/m5_a/experiment_new_1280.png) | [원본](screenshots/m5_a/experiment_original_1920.png) / [신규](screenshots/m5_a/experiment_new_1920.png) |
| Containment | [원본](screenshots/m5_a/containment_original_1280.png) / [신규](screenshots/m5_a/containment_new_1280.png) | [원본](screenshots/m5_a/containment_original_1920.png) / [신규](screenshots/m5_a/containment_new_1920.png) |
| Incident | [원본](screenshots/m5_a/incident_original_1280.png) / [신규](screenshots/m5_a/incident_new_1280.png) | [원본](screenshots/m5_a/incident_original_1920.png) / [신규](screenshots/m5_a/incident_new_1920.png) |
| 방송문 검토 | [원본](screenshots/m5_a/preview_original_1280.png) / [신규](screenshots/m5_a/preview_new_1280.png) | [원본](screenshots/m5_a/preview_original_1920.png) / [신규](screenshots/m5_a/preview_new_1920.png) |
| 전송 승인 | [원본](screenshots/m5_a/confirm_original_1280.png) / [신규](screenshots/m5_a/confirm_new_1280.png) | [원본](screenshots/m5_a/confirm_original_1920.png) / [신규](screenshots/m5_a/confirm_new_1920.png) |
| 사고보고서 | [원본](screenshots/m5_a/accident_report_original_1280.png) / [신규](screenshots/m5_a/accident_report_new_1280.png) | [원본](screenshots/m5_a/accident_report_original_1920.png) / [신규](screenshots/m5_a/accident_report_new_1920.png) |

추가 캡처: [실험 선택·실행 전](screenshots/m5_a/experiment_selected_new_1280.png), [환경 알림](screenshots/m5_a/environment_notice_1280.png), [CCTV 효과 켬](screenshots/m5_a/cctv_fx_1280.png), [긴 종이 문서](screenshots/m5_a/profile_end_1280.png). 모든 PNG는 실제 GPU 실행 결과이며 편집·합성·리사이즈하지 않았다.

## 저장소 조사와 보호 범위

시작 HEAD는 `b1cdf94`였다. 기본 Main, Profile 종이 문서, CCTV 이미지 슬롯, Experiment 결과 슬롯, Containment 후보·선택 상세, M4 다중 방송 및 사고보고서가 실제 존재했다. `assets/third_party/m4_5/`에 선별된 무료 UI·음향과 출처가 있었고 제한된 Retro 원본은 `assets/local_only/`로 Git 제외되어 있었다.

이전 FACILITY CONTROL 구조 작업과 사용자 README 수정이 미커밋 상태였다. M5-A 시작 시 기존 447개 파일의 해시·사본을 로컬 보관했다. 기본 `project.godot`, Main, 기존 Case, Runtime·Research·저장 코드와 기존 자산을 덮어쓰지 않았다. README의 별도 사용자 편집은 수정하거나 이번 커밋에 포함하지 않는다. 이전 구조 작업은 이번 사용자의 커밋·푸시 요청에 포함한다.

프로젝트 설정은 1920×1080 viewport, 초기 창 1280×720, `canvas_items` stretch, GL Compatibility, 한국어 기본값을 유지한다. Autoload나 전역 Theme, 새 게임 상태 시스템은 추가하지 않았다.

## 실제 자산과 교체 방법

[자산 목록·해시](../assets/temp/m5_a/manifest.json)와 [이용 승인 기록](../assets/temp/m5_a/README.md)에 세 원본을 구분했다. 새 외부 자산은 다운로드하지 않았다.

| 사용자 제공 자산 | 실제 연결 | 현재 한계 |
|---|---|---|
| 1. Creature master | 새 Case의 `ProfileData.subject_texture` | 전신 대역. 기존 박막낭 문서와 외형이 다르므로 정식 외형·증거로 해석하지 않도록 안내 |
| 2. Environment master | 새 Playtest의 `environment_reference` | 모든 격리 후보의 공통 공간 참고. 후보별 습도·접지·재질을 묘사하는 이미지가 아님 |
| 3. CCTV reference | 새 Case의 `CCTVData.feed_texture` | 정지 참고 이미지. 관찰문 시간대의 실제 움직임이나 열화상 영상이 아님 |

**박막낭의 연구 내용·정답·사고 피해는 M4 데이터 그대로다.** 이미지 외형에 맞춰 설명·사건·정답을 바꾸지 않았다. 화면의 TEMP 안내는 이 불일치를 알린다. 최종 정식 Case에는 문서와 일치하는 이미지를 별도로 준비해야 한다.

교체할 때는 `resources/cases/temp_m5_a_visual_case.tres`를 Inspector로 열어 Profile / CCTV의 위 Texture 참조를 바꾸거나, `m5_a_visual_playtest.tscn` 루트의 `environment_reference`를 교체한다. 새 파일의 경로·크기·종횡비가 달라도 Gameplay 코드 수정은 필요 없다. `TextureRect`는 전체 형상을 유지하는 `KEEP_ASPECT_CENTERED`를 사용한다.

실험별 이미지가 준비되면 기존 `ExperimentData.result_texture`에 연결하면 된다. 현재는 세 실험 모두 null이며 미제공 안내와 원래 결과 텍스트를 표시한다. Incident·환경 알림에는 적절한 이미지가 없어 기존 Placeholder/텍스트를 유지했다. 제공된 초상화를 실험 결과나 사건 이미지로 중복 사용하지 않았다.

## 디자인과 코드 책임

| 영역 | 적용 내용 |
|---|---|
| GameShell | 기존 구조 시안의 운영 명판, 가로 업무 단계, 하단 전체 이름의 기록·저장 키. 단일 Theme에서 일반 선택과 붉은 경고 상태 구분 |
| Profile | 종이 문서·스크롤·정보 순서 유지. 중복 신원 패널을 숨겨 전신 이미지 공간 확보, 어두운 프레임과 임시 자산 안내. 실재하지 않는 기밀 등급·검열 사실은 창작하지 않음 |
| CCTV | 실제 영상 중심의 모니터 프레임, 카메라 식별과 관찰 기록 분리. CRT/VHS는 이미지 영역만 선택 적용하며 버튼·기록에는 적용하지 않음 |
| Experiment | 왼쪽 실험 목록/완료 표기, 오른쪽 선택 설명/실제 결과 기록. 남은 횟수와 실행·다음 버튼은 기존 데이터 및 잠금 사용 |
| Containment | 왼쪽 후보별 조건 비교, 오른쪽 공통 환경 참고와 선택 상세. 확정 전/후 상태와 기존 승인 동작 유지 |
| Broadcast | M4.5의 질문 작성 → 송출문 검토 → 최종 승인 구조 재사용. 기존 답변과 확정된 원고만 표시 |
| 사고보고서 | 기존 실제 피해·근거·확인 후 업무 복귀 유지. 경고 영역과 연구 문서의 색·정보 계층을 맞춤 |

추가 종이 노이즈나 가짜 계기·시계·배터리·관측 수치는 만들지 않았다. 질감보다 긴 한글 문서와 실제 데이터를 우선했다. 기존 폰트와 Paper 변형을 유지했다.

```text
scenes/playtests/m5_a_visual_playtest.tscn     독립 F6 진입점·Campaign·환경 Texture
scripts/main/m5_a_visual_playtest.gd          기존 구조 시안의 표현 객체만 교체
scripts/presentation/visual_production.gd     이미지 안내·실험/격리 배치·선택형 음향
scenes/ui/facility_control/production_workbench.tscn   실험·격리의 두 작업 패널
resources/campaigns/temp_m5_a_visual_playtest.tres     기존 M4 순서·독립 저장 namespace
resources/cases/temp_m5_a_visual_case.tres    기존 M4 내용 + Profile/CCTV Texture
assets/temp/m5_a/                            세 원본·승인 기록·해시
```

기존 구조 시안 Main에 표현 객체 생성 함수 하나를 두어 M5-A만 확장했다. `visual_production.gd`는 기존 Control과 callback을 이동·복원하며 새로운 Runtime을 소유하지 않는다. 새 범용 UI 프레임워크·판정 로직을 만들지 않았다. 기본 Main에는 연결하지 않았다.

기존 파일의 M5-A 변경은 구조 시안의 위 생성 연결, ko/en 번역 5개, 문서 색인 링크다. 이전 구조 단계에 필요했던 `flow_view.gd`의 Focus 경로 연결과 번역 13개도 함께 커밋되며 [이전 보고서](m4_5_structural_ui_redesign.md)에 이유가 있다.

## 소리·효과와 라이선스

기존 Analog Horror SFX Free의 `channel_change_01.ogg`를 버튼 조작, `vhs_play.ogg`를 CCTV 전환·실제 방송 확정, `alert_beeps.ogg`를 실험 실행 기록 증가·환경 알림 표시 때 사용한다. 같은 비교용 Player의 **-22 dB**, 기본 꺼짐을 유지하며 끄면 즉시 정지한다. 게임 전체 Audio bus나 저장 설정은 바꾸지 않는다.

MAUSE의 선택된 StyleBox와 VHS UI의 영상용 자산, 기존 한국어 폰트를 재사용했다. CC BY/MIT 출처·라이선스 파일은 그대로 보존했다. 로컬 Retro는 기존 이용 범위와 Git 제외를 유지하고, 공개 복제본에는 VHS snow 대체 효과가 작동한다. 세 사용자 이미지의 프로젝트 이용 승인은 외부 패키지 라이선스와 구분한다. 자세한 기존 권리 근거는 [M4.5 라이선스 표](m4_5_ui_asset_comparison.md#확보-및-라이선스-검토)에 있다.

OGG 디코딩·재생 연결·끄기 동작은 검사했다. 실제 스피커 청취에 의한 음색·장시간 피로도 평가는 수행하지 못했다. 전용 메뉴 클릭음·실험 장치음·방송 송출음으로 최종 음향을 교체할지는 사용자 청취 후 결정한다.

### 짧은 성능 측정

로컬 AMD Radeon RX 6800 / OpenGL Compatibility에서 실제 CCTV 이미지와 동일 콘텐츠를 각 상태 150프레임씩 측정했다. CPU/GPU 값은 root와 영상용 SubViewport의 렌더 시간 중앙값 합계이며 전체 게임 CPU 비용은 아니다.

| 해상도·상태 | Viewport CPU / GPU 중앙값 (ms) | 보고된 video memory (MiB) |
|---|---|---|
| 720p 원본 | 0.109 / 0.075 | 32.70 |
| 720p FACILITY CONTROL | 0.176 / 0.085 | 32.75 |
| 720p + 로컬 CRT | 0.218 / 0.393 | 36.86 |
| 1080p 원본 | 0.237 / 0.291 | 42.20 |
| 1080p FACILITY CONTROL | 0.246 / 0.318 | 42.24 |
| 1080p + 로컬 CRT | 0.270 / 0.452 | 46.35 |

이 세션의 전체 프레임 간격 P95는 7.26–7.41ms였다. 창 합성·동기화·데스크톱 환경의 영향을 받으므로 일정한 FPS나 저사양 성능을 보장하지 않는다. 영상 효과는 약 4.1MiB의 추가 메모리와 렌더 비용이 있었으며 기본 꺼짐이다. 공개 복제본의 VHS 대체 효과는 실행 호환성을 검증했지만 별도 성능 수치로 이 표에 섞지 않았다.

## 실행 검증과 발견한 문제

[공개 검증 요약](screenshots/m5_a/verification.json)에 실행별 결과와 측정 자료를 기록했다. 상세 로그와 기존 플레이테스트 확장은 `.godot/verification/m5_a/`에 로컬 보관하며 제품용 하네스를 새 시스템으로 추가하지 않았다.

- Godot **4.7.1.stable.official.a13da4feb**에서 import, **72개 GDScript** check-only, 설정된 기본 Main headless 실행 통과.
- 두 해상도에서 실제 GPU 창, 마우스/키보드 입력, Profile → CCTV → 실험 2회 → 격리 승인 → 지연 환경 알림 → Major Incident → 방송 질문/검토/취소/확정 → 사고보고서 → 원래 업무 복귀 실행.
- 원본/신규 전환에서 같은 View·Runtime·초안·잠금 보존, 한 번에 한 View, 핵심 버튼 경계, 1920↔1280 resize, 긴 한글 종이 문서/방송 원고 스크롤 확인.
- 격리 확정 뒤 실제 저장/불러오기와 payload 일치, 9종 손상 데이터 거부, Research/Archive 왕복과 Focus·방송 초안 보존 확인.
- 별도로 올바른 격리 후보 2의 SUCCESS 경로, 세 실제 Texture 연결·비율, 효과 기본 꺼짐, OGG 디코딩·재생/정지 검사 통과.
- 새 Case를 기존 M4 Case와 재귀 비교해 **두 Texture 이외 Gameplay 데이터가 동일**함을 확인. Campaign도 별도 저장 ID와 그 Texture를 제외한 항목·순서·사건 내용이 동일함을 확인.
- 기존 원본 M4 네 가지 응답 결과, M3 실제 저장 파일 호환 불러오기, 원본 M2 경로 회귀 통과. 제한 Retro 파일 없는 새 공개 복제본 import·실행·효과 fallback 통과.

발견·해결한 문제: 실험 화면에서 조상/자식 Control을 함께 원래 위치로 복원할 때 Godot Scene owner 경고가 발생했다. 표현 복원 중의 owner를 잠시 해제하고 원래 트리 복원 후 되돌리도록 수정했다. 최종 GPU 실행은 오류·경고 0건이다. Profile 초기에 전신 이미지가 작고 임시 표기가 종이 위에서 흐려 보여 중복 신원 영역과 표기 대비를 조정했다.

## 화면 평가와 남은 제작

720p에서 Profile 전신 약 **222×296 px**, CCTV 전체 이미지 약 **414×311 px**를 확인했다. 1080p에서는 같은 비율로 확대된다. 4:3 공간 이미지를 넓은 모니터에 넣으므로 좌우 여백이 생긴다. 개체를 확대하려고 방이나 팔다리를 자르지는 않았다. 관찰 기록은 별도 스크롤이며 영상 위에 문서·조작 버튼이 겹치지 않는다. 긴 한글 문서는 스크롤이 필요하다.

새 디자인은 업무·기록·경고의 위치가 일관되고 실험/격리 정보를 양쪽에서 비교할 수 있다. 반면 720p에서 격리 후보의 긴 설명과 참고 이미지는 작아질 수 있다. CCTV 정지 이미지와 관찰문 내용의 불일치도 최종 게임의 몰입을 제한한다. **현재 결과는 실제 이미지가 연결된 플레이 가능한 비교본이며, 완성된 최종 연구시설 게임이라고 평가하지 않는다.** 자동 검사와 캡처 검토는 사용자 플레이 평가를 대체하지 않는다.

다음에 필요한 자산은 문서와 일치하는 정식 개체 Profile, 행동별 CCTV 프레임/영상, 실제 열화상, 세 실험별 결과 이미지, 후보별 실제 환경 구성 이미지, 환경 이상·Incident·사고 결과 이미지, 전용 클릭/장치/경고/송출 음향이다. 현재 제공된 세 장으로 이 부분을 완성한 것처럼 표시하지 않는다.

사용자 결정이 필요한 지점은 FACILITY CONTROL 구조의 최종 채택, 4:3 영상의 여백/크기 선호, 공유 환경 참고의 유지 여부, 문서 정보량, 효과·음향 강도다. 승인 전까지 기본 F5는 유지한다. 추가 구매보다 **기존 문서의 관찰·실험·격리 근거와 일치하는 자산 세트**를 준비하는 것이 다음 본편 Case 제작의 우선순위다.
