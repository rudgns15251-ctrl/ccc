# M5-B — T04 Temporary Playable Case

2026-10-16. 사용자 T04 자료로 별도 플레이 가능한 임시 Case를 구현했다. **TEMP / DRAFT / NON-CANON**이며 기본 F5·정식 Case·스토리 12개·엔딩에는 편입하지 않았다.

## 실행

Godot **4.7.1**에서 [`scenes/playtests/t04_playtest.tscn`](../scenes/playtests/t04_playtest.tscn)을 열고 **F6**을 누른다. 기존 FACILITY CONTROL 비교 UI를 사용한다. 원본 구조 전환과 선택형 음향·영상 효과도 유지하며 최종 UI 채택을 의미하지 않는다.

로컬 Windows x64 테스트 빌드는 `builds/m5_b/CAP_T04_M5B.exe`이다. 빌드 폴더의 `licenses/`를 함께 보관한다. `/builds/`는 Git 제외이며 실행 파일은 저장소에 추가하지 않았다. 제한된 Retro 원본을 제외한 별도 복제본에서 내보냈다. 원본 `project.godot`·export preset의 기본 실행 경로를 바꾸지 않았다.

전체 흐름은 **Profile → CCTV → 실험 최대 3회 → 격리 승인 → 후속 업무 → 지연 결과/필요한 사건 → 방송 → 사고보고서 → 원래 업무 복귀**다. 이후에도 기록 보관함에서 T04의 발견 기록을 읽을 수 있다.

| 경로 | 선택·실행 결과 |
|---|---|
| A: 안정화 | ROOM C → 후속 업무의 CCTV 확인 → 지연 SUCCESS. 탈출·방송 없음 |
| B: 비탈출 실패 | ROOM A → 같은 후속 관찰 경계 → 지연 FAILURE. Candidate·탈출·방송 없음. 재격리 절차는 만들지 않음 |
| C: 대표 사고 | ROOM B → 후속 업무의 의미 있는 관찰·실험 → 환경 경고 → 별도 다음 읽기 경계의 실제 Incident → 2문항 방송 → 사고보고서 확인 → 같은 Runtime·업무 단계로 복귀 |

ROOM C는 **낮고 일정한 조도 + 높은 내부 흡음 + 외부 소음 차단**이다. ROOM B는 어둡지만 금속 반향이 남는다. 일반적인 단발 반응과 장기 부적합, 격리 실패와 실제 탈출을 구분한다.

방송은 Q01/Q02 모두 option ID `_2`가 자극을 줄이고 차단 구역으로 후퇴하는 지시다. M5-B.2 이후 표시 순서는 Q01 두 번째, Q02 네 번째다. 4×4 전체 조합에 결과가 있으며, 사망·부상은 모든 조합에서 UNKNOWN이다. 적절한 방송도 최초 격리 실패를 성공으로 바꾸지 않는다. 이 문단은 개발 확인용 공략이며 게임은 승인 전에 정답을 표시하지 않는다.

## 조사한 기존 상태와 입력 자료

- HEAD `122ffb137edcd007424fbda0d11edabfe41c0052`, `master` → `origin/main`, 원격 `rudgns15251-ctrl/ccc`를 확인했다.
- `project.godot`, 기본 Main, M2~M5-A Scene/Resource/Script, 종이 Profile, 실험 제한, 지연 스케줄러, 다중 방송, Research/Archive와 저장 계약을 실제 코드로 조사했다. Autoload·전역 Theme를 새로 만들지 않았다.
- 시작 시 README의 사용자 편집과 T04 입력 ZIP·추출 폴더가 미커밋 상태였다. 기존 527개 파일을 해시·사본으로 로컬 보관했다.
- 지정된 네 입력 파일은 루트의 추출 폴더 안에서 찾았다. 표준 `assets/temp/t04/`, `docs/content_drafts/t04/` 위치로 바이트 그대로 복사했다. ZIP·원래 추출 폴더와 사용자 README는 보존했다.

Source of Truth와 추가 DRAFT 문장·충돌 처리의 상세는 [콘텐츠 검토](content_drafts/t04/t04_implementation_review.md)에 정리했다. 원본 [Profile/Research](content_drafts/t04/t04_profile_research_draft.md), [v0.2](content_drafts/t04/t04_gameplay_v0_2.txt), [입력 README](content_drafts/t04/README.md)는 수정하지 않았다.

## 콘텐츠와 Resource

| 결과물 | 연결 |
|---|---|
| 독립 Case | [`temp_t04_case.tres`](../resources/cases/temp_t04_case.tres), ID `TEMP_T04_CASE` |
| 독립 Campaign·저장 | [`temp_t04_playtest.tres`](../resources/campaigns/temp_t04_playtest.tres), ID `TEMP_T04_M5B_PLAYTEST` |
| Profile | 제공 전문과 실제 Master Texture. 문서 ID·검열·작성자·날짜는 TEMP 원문 표기로 유지 |
| CCTV | 저자극 정지/말단 탐색, 음향·이동광, 복합 협응 저하, 접촉 증가, 방음·흡음 차이를 텍스트 관찰로 제공 |
| 실험 5종 | ECHO, LIGHT, COMBINED, LOWSTIM, AIR. 실행 전 안내·실행 결과·개별 연구기록, 최대 3회, 중복 차단 |
| 격리 3종 | STANDARD, METALLIC, LOWSTIM. 공개 조건 비교와 별도 숨은 Outcome |
| 지연 사건 | `INC_T04_01`, PHASE 1~3 설비 경고 후 PHASE 4 복도 이탈 확인 |
| 방송·결과 | 2문항·각 4선택·16개 완전한 조합. 기존 원고 검토·수정·확인·송출 잠금·acknowledgement |
| Research | 제공 RL ID 23개와 Archive 문서 3개, 총 26개 authored 항목. 실제 출처·실행·결과 경계에서만 등록 |
| Archive | 01 초동 확보, 02 초기 오판, 03 실제 COMBINED 후 정정. 04 미확정 행정 요약/05 기원 단서는 미연결 |

Campaign은 T04 뒤에 기존 `test_case_01/02/03`을 둔다. 지연 사건이 다음 업무 중 발생하도록 기존 M4 구조를 재사용한 것이다. 새로운 T04 변종이나 본편 Case를 만든 것은 아니다.

## 최소 계약 보완과 Script 책임

조사 당시 격리 FAILURE는 반드시 Incident ID와 Candidate를 요구했다. 같은 출처의 authored Research도 하나만 허용했다. ROOM A와 제공된 23개 문장을 정직하게 구현하기 위해 다음 범위로 보완했다.

| 파일 | 변경 이유 |
|---|---|
| `scripts/data/monitoring_outcome_data.gd` | 명시적 `failure_without_incident`와 판별 함수. 기본 false |
| `scripts/runtime/containment_resolution_state.gd` | 위 opt-in을 검증한 호출만 비탈출 FAILURE로 기록. 기존 빈 Incident 실패 호출은 계속 거부 |
| `scripts/main/main.gd` | 비탈출 실패에 Candidate를 만들지 않음. 허용된 같은 출처의 여러 Research를 발견·표시·응답 Archive에 병합 |
| `scripts/data/case_data.gd` | `grouped_research_entries`는 T04만 true. 기존 중복 출처 검증은 기본값 false로 보존 |
| `scripts/data/research_entry_data.gd` | 기존 enum 번호를 유지하고 끝에 `CONTAINMENT_RESULT` 추가. 승인 시의 공개 조건과 지연 결과 기록을 분리 |
| `scripts/persistence/campaign_save_codec.gd` | authored 비탈출 실패 복원과 Candidate 기대 목록 처리, 선택하지 않은 방의 결과 기록 거부. 기존 저장 schema/version 유지 |
| `scripts/read_models/campaign_fact_queries.gd` | 비탈출 FAILURE도 실제 authored 결과로 조회 |
| `scripts/read_models/test_sequence_disposition_snapshot.gd`, `developer_run_disposition_builder.gd` | 명시적 비탈출 결과를 가짜 사건 의무로 분류하지 않도록 출처 확인 |
| `scripts/main/t04_playtest.gd` | 별도 진입점, 후속 관찰/경고에서 T04 결과 Research 공개, 기존 저장 피드백을 보존한 상태 안내, 긴 T04 경고 패널 |
| `scripts/presentation/t04_presentation.gd` | M5-A 배치를 재사용하면서 T04 자료/미제공 이미지 표기, 빈 공통 공간 이미지 숨김 |

새 Manager·Singleton·피해 계산기·범용 State Machine은 없다. 새 Main은 기존 Runtime/Research/Response/Save 소유자를 재사용한다. 실제 음향·복합 실험을 했다는 이유로 탈출 페널티를 주지 않는다.

T04 결과 공개는 후속 CCTV/경고의 실제 표시 경계에 연결했다. 기존 스케줄러는 전역 시간 대신 수락된 관찰·실험 및 읽기 경계를 사용한다. PHASE 1~3은 한 경고 안의 순차 텍스트이며 다섯 단계의 새 실시간 시뮬레이션·Animation을 구현했다고 주장하지 않는다. PHASE 4는 실제 `IncidentResponseState`와 출처를 가진 사건이다.

## 실제 실행·저장 검증

[최종 검증 요약](screenshots/m5_b/verification.json)에 각 실행 결과·자료 해시를 보관했다. 상세 로그와 기존 QA 도구 확장은 `.godot/verification/m5_b/`에 로컬 보관한다.

- Godot **4.7.1.stable.official.a13da4feb**, import와 **74개 GDScript check-only**, 기본 F5 Main headless 시작 통과.
- 1280×720·1920×1080에서 실제 GPU 창과 마우스/키보드 입력으로 세 경로 실행. 긴 Profile 문서·실험 목록·후보 설명·방송 원고·사고보고서 스크롤과 핵심 버튼 경계 확인.
- 세 실험 선택 **10조합** 모두 실제 실행·ROOM C 판정 확인. AIR+LIGHT+LOWSTIM도 포함. 미선택 실험 Research 비공개, 동일 실험/4번째 실행 거부, 중복 Research 등록 없음.
- 방송 **16조합** 전체 실행, 실제 송출 원고·결과 ID·UNKNOWN 인명 피해, 확정 전 비공개·확정 후 변경 거부, acknowledgement 전 미완료, 업무 Runtime·상태 복원 확인.
- 환경 경고 확인과 방송 Source Archive 왕복 뒤 실제 Focus 복원 검사 통과. 방송 초안과 송출 잠금도 왕복 후 유지.
- **프로세스 1:** Profile·CCTV·3개 실험·ROOM B 승인·Pending 저장 후 종료. **프로세스 2:** 새 Main에서 UI로 불러와 payload 동등성 확인 → 자연스러운 지연 사건·방송 완료 → 후속 업무의 안전 경계에서 저장 후 종료. **프로세스 3:** 다시 불러와 완료 대응/Archive 유지와 사건 재실행 없음 확인.
- 실험을 1회·2회만 수행한 이력도 같은 세 프로세스 절차로 추가 검증했다. 남은 실험을 강제로 소비시키지 않고 승인·저장·복원할 수 있다.
- ROOM A/C의 후속 결과·저장 복원 준비 검사, historical room/result 조회와 Pending 분류 확인. ACTIVE Incident 저장은 계속 금지.
- 기존 원본 M2, M3 실제 저장 파일 호환성, M4 네 가지 결과, F5 authored Campaign, M4.5 구조 비교, M5-A 이미지 테스트 회귀 통과.
- 제한 Retro 원본 없는 새 복제본 import/시작, Windows x64 export, 실제 EXE의 headless/GPU 시작 통과. 내장 PCK를 별도 경로에서 열어 T04 Texture·5실험·16조합 데이터와 화면을 추가 검사했다. EXE 전체 경로를 사람 손으로 끝까지 플레이한 검증은 수행하지 않았다.

자동 실행·검사 소요시간을 사람의 플레이타임으로 제시하지 않는다. 현재 자료로 모든 실험 조합에서 추론 근거가 제공되는지 검토했지만 체감 난이도와 재미는 사용자 플레이 평가가 필요하다.

## 실제 화면

[화면 모음](screenshots/m5_b/index.html)에서 경로·단계·해상도를 선택할 수 있다. 각 PNG는 GPU Viewport 원본 캡처이며 합성·보정·리사이즈하지 않았다.

| 화면 | 1280×720 | 1920×1080 |
|---|---|---|
| Profile / Master | [720p](screenshots/m5_b/room_c_profile_1280.png) | [1080p](screenshots/m5_b/room_c_profile_1920.png) |
| CCTV 미제공·관찰문 | [720p](screenshots/m5_b/room_c_cctv_1280.png) | [1080p](screenshots/m5_b/room_c_cctv_1920.png) |
| 실험 결과 | [720p](screenshots/m5_b/room_c_experiment_1280.png) | [1080p](screenshots/m5_b/room_c_experiment_1920.png) |
| 격리 비교·승인 전 | [720p](screenshots/m5_b/room_c_containment_choices_1280.png) | [1080p](screenshots/m5_b/room_c_containment_choices_1920.png) |
| A 비탈출 실패 기록 | [720p](screenshots/m5_b/room_a_archive_1280.png) | [1080p](screenshots/m5_b/room_a_archive_1920.png) |
| C 안정화 기록 | [720p](screenshots/m5_b/room_c_archive_1280.png) | [1080p](screenshots/m5_b/room_c_archive_1920.png) |
| B 지연 환경 경고 | [720p](screenshots/m5_b/room_b_environment_notice_1280.png) | [1080p](screenshots/m5_b/room_b_environment_notice_1920.png) |
| B 실제 Incident | [720p](screenshots/m5_b/room_b_incident_1280.png) | [1080p](screenshots/m5_b/room_b_incident_1920.png) |
| 방송문 검토 | [720p](screenshots/m5_b/room_b_preview_1280.png) | [1080p](screenshots/m5_b/room_b_preview_1920.png) |
| 최종 확인 | [720p](screenshots/m5_b/room_b_confirm_1280.png) | [1080p](screenshots/m5_b/room_b_confirm_1920.png) |
| 사고보고서·UNKNOWN | [720p](screenshots/m5_b/room_b_report_end_1280.png) | [1080p](screenshots/m5_b/room_b_report_end_1920.png) |
| 정확한 업무 복귀 | [720p](screenshots/m5_b/room_b_resume_1280.png) | [1080p](screenshots/m5_b/room_b_resume_1920.png) |

## 발견한 문제와 해결

1. 기존 FAILURE→Incident 필수 계약으로 ROOM A를 정직하게 표현할 수 없었다. 기본 동작을 유지하는 authored opt-in과 저장/Fact 분류를 추가했다.
2. 여러 Research를 같은 Profile/CCTV 출처에 연결하면 중복 매핑으로 거부됐다. T04만 그룹 출처를 허용하고 실제 source exposure에서 해당 ID들을 함께 등록한다.
3. 긴 PHASE 경고가 기존 88px 띠에서 거의 보이지 않았다. T04 경고만 큰 읽기 패널로 확장하고 기존 스크롤·확인·Focus 동작을 보존했다.
4. UI 종료 중 상태 Label이 먼저 해제될 수 있었다. T04 후속 상태 표시에 수명 검사를 추가했다. 저장/불러오기 피드백도 기존 문장과 함께 보존했다.
5. Windows 텍스트 처리로 여러 줄 Resource의 CRLF가 원고 비교와 달라지는 문제가 발견됐다. 새 T04 Resource를 프로젝트 규칙인 LF로 보존하고 16조합 유효성·실제 전송·빌드를 재검사했다.

최종 검증 실행은 파싱·Script 오류와 예상하지 않은 경고가 없다. 초기 실패 시도도 로컬 로그에 남겨 두었다.

## 미완성·승인 대기

실제 확보한 T04 시각 자산은 **Profile의 Master 1장**이다. [원본 출처·교체 안내](../assets/temp/t04/ASSET_PROVENANCE.md)에 해시와 용도를 기록했다. 전신을 자르거나 늘리지 않고 기존 aspect-preserving TextureRect로 표시한다.

미제공: 전용 Profile 촬영본, CCTV Anchor·열화상, 실험별 결과 5종, 후보별 공간 사진, ROOM B 사고 장면과 보고서 증거 이미지. 이미지 없는 장면은 Placeholder/텍스트이며 다른 개체 이미지나 가짜 증거를 만들지 않았다.

**M5-B.2 (2026-10-16) 갱신:** 사용자 승인으로 T04의 정보 전달 방식을 재조정했다. 설정, ID, 판정, Research·Archive·Profile 원문은 바꾸지 않았다.
- CCTV에서 정답을 직접 말하는 문장을 제거했다.
- 격리 후보를 측정값(조도, 외부 차음 dB, 내부 잔향 시간)으로 표기하고 ROOM C를 "흡음 패널 격리실"로 이름을 바꿨다.
- 실험 결과에 수치를 넣었다.
- 방송 오답을 절충형으로 재작성하고 표시 순서를 바꿨다.
- 16개 사고 결과에 선택별 현장 기록을 추가했다(피해는 계속 UNKNOWN).

상세: [M5-B.2 초안·적용 기록](content_drafts/t04/t04_m5b2_revision_draft.md), 화면: [screenshots/m5_b2](screenshots/m5_b2).

**M5-B.1 (2026-10-16) 갱신:** 사용자 요청으로 Master와 M5-A 표준 격리실만 합성한 **TEMP 합성 프레임 6장**(CCTV 1장, 실험 5장)을 기존 `feed_texture`/`result_texture`에 연결했다. 모든 프레임에 `TEMP COMPOSITE / NOT EVIDENCE`를 표기하며 실제 촬영·실험 증거가 아니다. 출처와 생성 방법은 [ASSET_PROVENANCE](../assets/temp/t04/ASSET_PROVENANCE.md), 화면은 [screenshots/m5_b1](screenshots/m5_b1)에 있다. 열화상·후보별 공간·ROOM B 사고 이미지는 여전히 미제공이다.

Profile/CCTV/Experiment 이미지는 기존 `subject_texture/feed_texture/result_texture` 참조로 교체한다. 공통 공간 참고는 Playtest의 `environment_reference`에 연결할 수 있다. 현재 ContainmentData에는 후보별 Texture 필드가 없으므로 후보별 사진 선택 기능은 아직 추가하지 않았다.

승인 대기: T04 정식 편입, 문서의 역사·생리 가설, ROOM B의 시설 결함, 방송 문구와 실제 피해 규모, ARCHIVE 04/05, Q03 구조 시나리오, 최종 UI 디자인. ROOM A 재확보·재격리와 새 Save 경계·Ending은 구현하지 않았다. 새 사운드도 확보하지 않았으며 기존 M5-A 선택형 음향을 재사용한다.

## 변경 범위·Git

추가: T04 Case/Campaign, F6 Scene, 전용 Main/표현 Script·UID, 사용자 자료의 표준 경로 사본, 이미지 provenance/manifest, 콘텐츠 검토·본 보고서·캡처·검증 요약. 수정: 위 계약 보완 Script 9개와 `docs/README.md`의 링크.

`git diff --check`와 기존 파일 해시 비교로 범위를 검사했다. 기존 `project.godot`, 기본 Main Scene, M2~M5-A Scene/Resource/이미지·공개 스크린샷·외부 라이선스, export preset, 사용자 README와 원본 입력은 보존했다. Main Script에는 위 필요한 분기·Research 연결만 수정했다. 상세 변경 파일은 [검증 요약](screenshots/m5_b/verification.json)에 있다.

이번 요청에 따라 **git add/commit/push/reset은 수행하지 않았다.** 다음 작업 지점은 T04를 직접 플레이하며 문서량·반향 단서·방송 지시를 평가하고, 승인된 CCTV/실험 증거 이미지를 기존 Resource 슬롯에 연결하는 것이다.
