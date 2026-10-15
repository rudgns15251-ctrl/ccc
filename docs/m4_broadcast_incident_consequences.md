# M4 — 다중 비상방송·사고 피해·사고보고서

## 실행

Godot **4.7.1**, Windows, 1920×1080 논리 UI / 기본 창 1280×720. 기존 F5 Main과 M2 F6 경로는 그대로다.

- 에디터에서 `scenes/playtests/m4_playtest.tscn`을 열고 **F6**.
- Windows 테스트 빌드: `builds/m4/CAP_M4.exe` (약 108.7 MB, PCK 포함). 로컬 생성물이며 Git 제외 경로다.
- Export preset: **Windows M4 Playtest**. `m4_playtest` 기능으로 같은 Main의 M4 Scene을 시작한다.

M4는 M2 박막낭의 관찰·격리 데이터를 별도로 복제한 **TEMP / NON-CANON** Campaign이다. Profile·CCTV에서 단서를 읽고 실험 후 **따뜻하고 건조한 합성재 공간 또는 침수 공간**을 제출한다. 다음 Case들에서 CCTV·실험·격리 업무를 계속하면 기존 지연 판정 → 환경 교란 → Major Incident가 발생한다. 발생 시점은 기존 기회 수와 읽기 경계를 따른다. 올바른 격리는 기존과 같이 SUCCESS 경로다.

탈출 사건 → 경로 선택 → 접촉 행동 선택 → 방송문 검토 → 지시 수정/송출 → 최종 확인 → 사고 대응 보고서 → 업무 복귀. 업무 복귀 후 **보관(A) → 사고보고서**에서 완료된 기록을 다시 읽는다. 마지막 테스트 Case 이후의 Campaign 콘텐츠를 추가한 작업은 아니다.

## 데이터와 확정 경계

`EmergencyBroadcastData.questions`가 비어 있으면 기존 `prompt_text/options` 단일 선택 흐름을 사용한다. 기존 단일 방송 Resource는 수정하지 않았다.

다중 방송은 `BroadcastQuestionData(question_id, prompt_text, options)`와 `BroadcastOutcomeData(answers, option_id, result_id, display_text)`를 사용한다. 질문 선택지는 기존 `BroadcastOptionData`에 선택적 `instruction_text`를 더했다. Outcome은 같은 타입의 결과 조회를 재사용하며, 그 `option_id`는 **개별 답변이 아닌 조합 식별자**다. `display_text`는 경고문과 선택된 지시문을 합친 실제 방송문과 일치해야 한다.

2~3개 질문, 방송 내 질문/선택지/조합 ID 유일성, 모든 가능한 조합(최대 64개), 누락·중복 매핑과 결과 참조를 검증한다. 미응답 상태에서는 검토·송출이 차단된다. 질문 이동·선택 변경·미리보기는 화면의 임시 값이며 결과를 기록하지 않는다.

최종 Modal 승인에서만 `IncidentResponseState.try_confirm_multi()`가 다음을 한 번에 소유한다.

- 기존 정확한 IncidentSource, incident/broadcast/조합/result ID
- `broadcast_details.answers`: 질문 ID → 확정 답변 ID
- `transmitted_text`: 번역 전 원문 방송문
- `consequences`: authored 피해 관찰의 복사본

송출 후에는 수정할 수 없다. **송출만으로 COMPLETED가 되지 않으며**, 결과 화면을 확인해야 기존 완료/복귀 경계가 실행된다. Source Archive 왕복은 출처가 일치하는 임시 답변·질문 위치·미리보기·스크롤 또는 확정 잠금을 복원한다.

## TEMP 결과 조합

방송 `TEMP_M4_BROADCAST_EVAC`의 질문은 `ROUTE`, `CONTACT`다. 아래 답변 ID에는 `TEMP_M4_ANSWER_`, 결과 ID에는 `TEMP_M4_RESULT_` 접두사가 붙는다.

| 경로 / 접촉 | 조합·결과 번호 | 확인된 직원 사망 / 부상 | 시설 피해 |
|---|---:|---|---|
| GROUND 정비 우회로 / AVOID 만지거나 적시지 않음 | 0 | 0 / 0 | 점검한 우회로에서 추가 피해 없음 |
| GROUND / WET 물을 묻히고 손으로 옮김 | 1 | 0 / 1 | 미확인 |
| SHORT 합성재 통로 / AVOID | 2 | 미확인 / 2 | 환기구 덮개 손상 |
| SHORT / WET | 3 | 1 / 3 | 덮개 손상·인접 보급 통로로 막편 확산 |

모두 이 임시 사건에 작성한 국소적 관찰이다. 시설 전체 직원 수나 피해 계산 공식이 아니다. 숫자 **-1은 미확인**, **0은 명시적으로 확인된 0명**이다. 시설 피해·추가 관찰의 빈 문자열도 미확인이다. 기존 단일 방송 결과는 기본값이 미확인이며 임의로 0명으로 바꾸지 않는다.

대피 지시의 근거는 기존 Profile의 물방울·막편 기록과 CCTV의 접지·합성재·환기구 관찰에 있다. 선택하지 않은 실험이 필수 단서가 되지 않는다. 적절한 대피로도 **최초 격리 FAILURE는 보존**되며 재확보나 새 수용 위치를 확정하지 않는다.

## 보고서·기록

현재 결과 화면은 송출 지시, 실제 결과 설명, 확인된 인명·시설 피해와 추가 관찰을 보여준다. 보고서 확인 전에는 대응이 ACTIVE다. Archive 사고보고서 목록은 **COMPLETED 응답만** 사용하며, ACTIVE 사건의 Source Archive에서는 이 탭을 잠근다. `IncidentReports`는 읽기 전용 투영이며 별도 결과 State나 피해 합계를 만들지 않는다.

CASE / CAMPAIGN_ENTRY / CAMPAIGN_INTERRUPT 출처를 보존한다. 순차·Side 사건에 가짜 Case 실패를 만들지 않는다. 기존 Step68 Historical Facts 필드와 순차/Side 8필드 기록은 유지한다. 새 상세 피해는 같은 출처·incident ID의 ResponseState에서 조회한다.

Research는 확정한 두 답변과 실제 표시된 결과만 추가한다. 미선택 답변·다른 결과·미실행 실험은 발견하지 않는다. Case Research, Story Records, 사고보고서는 별도 탭이다. Story 수집 상한 6/3/3과 기존 자료는 그대로이며, M4에는 기존 수집 샘플의 별도 TEMP 참조 3개만 둔다. 새 공식 스토리를 작성하지 않았다.

## Save/Load

JSON **version 1을 유지**하고 다중 방송 응답에만 선택적 상세 필드를 추가했다. 기존 단일 방송 Campaign에는 서명용 행을 추가하지 않아 기존 authored signature가 동일하다. M4 서명에는 질문·지시문·조합·결과·피해 정의를 포함한다. M4는 별도 Campaign 슬롯을 사용한다.

기존 Profile/Containment의 안정된 저장 경계와 ACTIVE 저장 금지를 유지한다. Load는 authored 조합·원문·피해·출처·진행 순서를 대조하고, 검증된 임시 소유자들을 만든 뒤 Main에 적용한다. `CampaignSaveStore`의 2 MiB 제한, checksum, 임시 파일/백업, JSON 전용 읽기는 수정하지 않았다.

실제 이전 M3 `TEST_CAMPAIGN_01` version 1 파일을 복사한 격리 프로필에서 서명 일치·UI Load·완료 Mandatory/Side 이력 보존을 확인했다. 원본 두 M3 슬롯은 바이트 비교로 보존을 확인했다. 신규 M4 저장은 별도 프로세스에서 원래 payload와 동일하게 복원했으며, **0명과 미확인 사망 결과를 각각** 검사했다. 완료 방송 재발생과 피해 중복은 없었다.

## 검증

- 공개 `tools/verify_project.ps1`: import, 제품 **GDScript 66개** check-only, 기본 Main 시작 통과.
- 실제 M4 Main 클릭 경로의 **4조합**, 질문 순서·마우스/키보드 선택·수정·미응답 차단·미리보기·Modal 취소/확정·잠금·Source Archive·결과 확인·정확한 업무 복귀 통과.
- 실제 Campaign 기존 **7경로**, M2 기존 **6경로**, M3 저장/복원 6모드와 무결성 검사 통과. 기존 검사에 필요한 자료 수집 저장을 먼저 생성해 무결성 검사를 재실행했다.
- 별도의 통제 Resource를 실제 Main에 연결해 다중 방송의 순차/Side 출처·복귀·Historical Facts·저장 준비를 확인. 3질문/8조합 데이터와 긴 미리보기·확인 Modal·보고서 스크롤도 확인.
- 조작한 답변·조합·결과·피해·원문·출처·진행 순서·ACTIVE 기록·미발견 Research 거부. 거부 시 현재 소유자들은 유지.
- GPU **1920×1080 / 1280×720**: 실제 질문·미리보기·Confirm·보고서·Archive·업무 복귀 확인. 기준 해상도·Stretch·GameShell 치수 유지.
- Windows debug Export 성공. **EXE 자체는 headless/GPU 시작 검사**, 전체 자동 플레이와 새 프로세스 복원은 동일한 Godot 4.7.1의 `--main-pack`으로 내보낸 패키지를 읽어 검사했다. Export 템플릿은 외부 `--script` 실행을 지원하지 않기 때문에 두 범위를 구분한다.
- 최종 대상 검사에 SCRIPT ERROR/파싱 오류/런타임 ERROR 없음. 구현 중 발견한 Resource 참조·포커스 변수 오류는 수정 후 재검증했다. `git diff --check` 통과. 커밋·푸시는 하지 않았다.

상세 runner·로그·프로세스 결과는 로컬 `.godot/verification/m4/`, 공개 기본 검사 로그는 `.godot/verification/public_smoke/20261015_101613_747/`에 보관한다. 이 로컬 자료는 Git에 포함되지 않으며 자동 검사는 재미·공포감의 사용자 평가를 대신하지 않는다.

대표 화면: [질문 1920](screenshots/m4/question_1_1920.png) · [미리보기 1920](screenshots/m4/preview_1920.png) · [확인 1920](screenshots/m4/confirm_1920.png) · [보고서 1920](screenshots/m4/accident_report_1920.png) / [질문 1280](screenshots/m4/question_1_1280.png) · [미리보기 1280](screenshots/m4/preview_1280.png) · [확인 1280](screenshots/m4/confirm_1280.png) · [보고서 1280](screenshots/m4/accident_report_1280.png).

## 변경 파일

새 파일:

- `scripts/data/broadcast_question_data.gd`, `broadcast_outcome_data.gd`: 질문과 authored 조합 정의.
- `scripts/views/multi_broadcast_view.gd`: 임시 질문·검토 UI. `accident_reports_view.gd`: 완료 보고서 Archive 탭.
- `scripts/read_models/incident_reports.gd`: 읽기 전용 사고보고서. 위 5개 Script의 Godot 생성 `.uid` 포함.
- `resources/cases/temp_m4_case_01.tres`, `resources/campaigns/temp_m4_playtest.tres`, `scenes/playtests/m4_playtest.tscn`.
- `resources/story_records/temp_m4_{diary,resident_list,training_video}_01.tres`.
- 이 보고서와 `docs/screenshots/m4/`의 대표 PNG 8개.

기존 수정 파일:

- `scripts/data/{emergency_broadcast_data,broadcast_option_data,incident_result_data,scripted_incident_data}.gd`: 선택적 데이터·검증.
- `scripts/runtime/incident_response_state.gd`, `scripts/main/main.gd`: 기존 소유권·화면 전환에 다중 송출/출처 임시값/보고서 연결.
- `scripts/persistence/campaign_save_codec.gd`: 선택적 상세 저장·authored 검증·서명 확장.
- `scripts/read_models/{campaign_fact_queries,developer_run_disposition_builder}.gd`: 공통 조합 조회와 기존 이력 필드 보호.
- `scripts/views/{broadcast_view,incident_result_view}.gd`, `scenes/views/incident_result_view.tscn`: UI 연결·스크롤·고정 CTA.
- `translations/{en,ko}.po`: 새 문구의 원문·한국어. `project.godot`, `export_presets.cfg`: M4 진입/빌드만 추가. `docs/README.md`: 보고서 링크.

작업 시작은 `master` / `origin/main`, HEAD `64db89f580a798668f0cc4f4c8df1fbc1738cdcb`. 당시 별도로 수정되어 있던 **README.md는 바이트 그대로 보존**했다. 기존 파일 삭제, 기본 Main Scene 재작성, M2 Resource/Campaign 수정, M2/M3 빌드 교체는 없다.

남은 정식 제작 결정: 개체별 질문·대피 문구와 결과, 피해 수치의 공식 기준, 재확보/봉쇄 이후 처리, 시설 규모와 정식 스토리. 현재 M4에 알려진 미해결 실행 오류는 없으며, 이 임시 결과를 정식 세계관으로 확정하지 않았다.
