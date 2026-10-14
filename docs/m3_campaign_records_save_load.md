# M3 — Campaign Records & Safe Save/Load

## 실제 구현

Godot 4.7.1 / Windows / GDScript. 실제 Main·Step71·M2와 기존 Campaign/Runtime/Archive/Response/RunDisposition 소유권을 조사했다. 새 전역 Manager 없이 **스토리 자료 수집 + 기존 Archive 열람 + Campaign별 수동 저장 1개**를 연결했다.

- 자료: 고유 ID, 종류(일기/주민 명단/교육 영상), authored 콘텐츠 Resource 참조, 발견 여부, 중복 방지, 열람 권한.
- 수집 owner는 Case Research와 별도다. `get_collection_summary()`로 수집 상태의 복사본을 읽을 수 있으나 Ending은 구현하지 않았다.
- 6/3/3개, 총 12개 구성은 controlled fixture로 고유성·발견·열람 가능·파일 보존/복원을 검사했다. 공식 자료 12개를 임의로 작성하지 않았다.

## 실제 플레이 자료·진입

[m2_playtest.tscn](../scenes/playtests/m2_playtest.tscn)을 열고 **F6**, 또는 로컬 `builds/m3/CAP_M3.exe`를 실행한다. 기존 F5 Campaign 순서는 보존했다.

M2에만 `[TEMP / NON-CANON]` 자료 3개를 배치했다. 대상 정보에서 일기 검증 조각, CCTV에서 주민 명단 검증 조각, 격리 화면에서 교육 전사문을 **왼쪽 자료 확보 버튼**으로 발견한다. 보관함(A) → **스토리 자료** 탭 → 발견한 항목을 선택해 읽는다. 미발견 자료는 목록에 표시하지 않으며 수집·열람은 실험 횟수·사건 기회·연구 발견을 증가시키지 않는다. 기존 공식 테스트 Campaign에는 자료나 발견 장소를 추가하지 않았다.

교육 영상은 **실제 영상 파일이 없는 검증용 전사문**이다. 승인된 `VideoStream` 참조를 2D `VideoStreamPlayer`에서 재생/일시 정지하는 슬롯을 마련했지만, 실제 원본 영상 재생은 이번에 검증하지 못했다. 영상 다운로드·임의 공식 영상 제작은 하지 않았다. [Godot VideoStreamPlayer 문서](https://docs.godotengine.org/en/latest/classes/class_videostreamplayer.html).

## 저장 가능한 지점과 UI

오른쪽 **저장(S)** / **불러오기(L)** 버튼. 저장할 수 없는 이유는 비활성 버튼의 Tooltip과 하단 상태로 표시한다. 자동 저장은 없다. 확보한 자료·메모를 유지하려면 직접 저장해야 한다.

| 지점 | 지원 |
| --- | --- |
| 현재 업무의 안정된 Profile | 저장 가능: 초기/다음 Case의 정상 Runtime이 생성된 상태 |
| 현재 업무의 안정된 Containment | 저장 가능: 기존 관찰·실험과 전환을 마친 상태. 미승인 선택 또는 승인·Pending 잠금을 함께 보존 |
| CCTV / Experiment | 저장 불가. 현재 처리 상태에서 격리 화면까지 진행한 뒤 저장 |
| Incident ACTIVE / Side due·resume pending / 지연 알림 / 확인창 / 전환 | 저장·불러오기 불가. 대응·복귀·전환을 마쳐야 함 |
| Drawer / Archive / 과거 화면 Review | 닫고 현재 업무로 돌아와야 함 |
| 개발용 terminal transaction / Monitoring·Result debug / no-run | 저장·불러오기 불가 |

불러오기는 안정된 현재 업무 화면에서 가능하며 **현재 미저장 진행을 교체한다는 확인창**을 사용한다. 취소하면 현재 상태를 유지한다. 마지막 Case 이후의 플레이어용 종료·새 게임 메뉴는 이번 범위에 없다.

## 파일과 무결성

`user://campaign_saves/<Campaign ID의 해시>.json`, version 1. 일반 Windows 프로젝트의 `user://`는 Godot의 프로젝트 사용자 데이터 경로다. 개발 검사에서는 별도 AppData를 사용해 사용자의 실제 슬롯을 건드리지 않았다.

진행 ID·정확한 완료 순서, 현재 Runtime의 실행 이력/조건 관찰/잠금/연구 발견/환경 조건, Pending, 지연 Resolution, Failure Candidate 순서·카운터, 완료된 세 종류 Response, Research Archive, 사용자 메모·ID 카운터, 수집 자료, pacing 기회/토큰/credit, 난수 seed/state와 현재 화면 상태를 보존한다. 난수 64비트 값은 문자열로 저장해 JSON 수치 정밀도 손실을 피한다.

JSON·checksum·크기 제한·authored 구조 signature를 사용한다. ID/종류/순서/중복/조건 조합/결과 매핑을 **현재 authored Resource**와 대조한다. 저장 데이터의 Script·Resource 경로·실행 코드는 로드하지 않는다. 새 owner들을 격리 구성한 뒤 성공할 때만 Main을 교체한다. 손상·버전 불일치·정의 변경은 거부한다. checksum은 손상 검사용이며 보안 서명이나 치트 방지 기능은 아니다.

새 파일을 `.tmp`에 완전히 쓰고 확인한 후 기존 파일을 `.bak`으로 옮겨 게시한다. 게시 실패 시 이전 파일을 복구하며, 게시 도중 종료돼 primary가 없다면 전체 backup을 읽을 수 있다. 손상된 primary를 자동으로 덮어쓰지 않는다. 동시 다중 프로세스 저장, 여러 수동 슬롯과 버전 migration은 지원하지 않는다.

## 실제 종료·재시작·복원 결과

기존 입력 도우미와 명령행 runner를 재사용했다. 자료 ID만 만든 API 테스트와 실제 Main UI 검사를 구분했다.

| 검증 | 결과 |
| --- | --- |
| M2 실제 UI 수집·읽기·저장 → 프로세스 종료 → 새 프로세스 Load | 통과. 전체 지원 canonical payload가 같고 2회 실험·승인 잠금·Pending·자료 3개·메모가 보존됨 |
| Load 확인 취소 | 현재 진행 동일. 손상된 파일은 확인창 이전에 거부 |
| 복원한 M2 승인 → 실제 다음 업무 인계 | 기존 지연 SUCCESS가 한 번만 확정됨 |
| M2 오답 후보 저장·종료·복원 → 정상 후속 업무 | 자연 발생 알림·Major·대피·동일 Runtime 복귀 통과. 최초 FAILURE 유지 |
| 기존 Campaign의 Mandatory + Step69 Side 완료 뒤 저장·재시작 | 이력·후보·기록·메모·진행 동일. 완료 Side 조회 및 과거 Experiment Review에서 사건 재발 없음 |
| 잘못된 형식·ID·중복·순서·ACTIVE 조합·큰 난수·경로 삽입 | 안전한 거부, 현재 owner 변경 없음. 12개 자료 검사는 controlled fixture |
| 기존 M2 6경로 / 제품 Campaign 7경로 | 정답·오답·지연 사건·Mandatory·Side exact resume·historical facts·개발용 종료 회귀 통과 |
| 공개 기본 검사 | Import·제품 GDScript 61개·기본 Main 시작 통과 |
| 1920×1080 / 1280×720 GPU | 실제 수집·Archive·저장·새 프로세스 복원 통과 |
| Windows 독립 내장 패키지 | 실제 저장·다른 프로세스 Load·인계 통과. 실제 EXE headless/GPU 시작 exit 0, 오류 없음 |

실제 Windows 테스트 빌드: `builds/m3/CAP_M3.exe`(약 108.7MB, PCK 내장, Git 제외). Export preset `Windows M3 Playtest`. `.godot/verification/m3/`와 `public_smoke/`에 로컬 결과·실패 시도도 보관했으며 검증 fixture와 문서는 패키지에 포함하지 않았다. GPU 입력은 Godot에 전달한 자동 입력이며 사람의 재미·사용성 평가와 구분한다.

## 기존 Gameplay와 생명주기

기존 Main의 지연 판정·후보·환경 변화·실험 제한·승인·Scripted 전환을 그대로 사용한다. Load는 사건·기회·발견을 다시 발생시키는 진입 함수를 호출하지 않는다. 이전 Fact Query source는 release하고 새 owner에 다시 묶는다. 수집 상태도 검증된 개발용 source cleanup에서 비운다. 디스크 저장은 별도이며 RunDisposition을 플레이어 파일로 재사용하거나 새 종료 시스템을 추가하지 않았다.

초기 검사에서 한국어 불러오기 버튼이 Rail 폭을 늘린 문제(줄바꿈), 복원 Runtime의 Review 권한 연결 누락, 큰 정수 변환 시 엔진 오류를 수정했다. 현재 화면 선택·승인과 스크롤은 복원하지만 **과거 Review 화면의 임시 선택·스크롤은 기본값**으로 돌아간다. Gameplay 이력·횟수·잠금은 유지한다.

[스토리 자료 1280](screenshots/m3/story_archive_1280.png) · [저장된 격리 1920](screenshots/m3/saved_containment_1920.png). 두 해상도의 화면 4장을 [screenshots/m3](screenshots/m3)에 보관했다.

## 미확정·남은 범위

정식 문서 12개의 내용·장소·날짜·전임자·진상과 Ending은 미확정이다. 원본 영상·최종 자산, 사용자 직접 플레이 평가, 다른 authored 버전의 Save migration, 모든 순간의 저장, 여러 슬롯, 동시 실행 충돌 처리는 남아 있다. Save/Load UI가 활성화된 지원 지점을 넘어 복원을 보장한다고 주장하지 않는다.

## 변경 파일

신규: `story_record_data.gd`, `story_record_content.gd`, `story_collection_state.gd`, `story_records_view.gd`, `scripts/persistence/campaign_save_codec.gd`·`campaign_save_store.gd`와 각 UID, TEMP 자료 `.tres` 3개, 이 보고서·스크린샷.

M3 수정: Main Script/Scene·GameShell(버튼/IO 연결), M2 Script/Scene(실제 저장 상태·자료 참조), Candidate/Hypothesis(검증된 owner 복원), 영어·한국어 PO, Export preset, README·문서 목록. M3 시작의 220개 파일을 별도 비교해 기존 Case/Campaign/Incident/나머지 View/Theme와 Step71·M2 증거를 보존했다. 사전 미커밋 Step71/M2는 M3 실행에 필요한 기반이므로 함께 커밋 대상이다.

README의 별도 붙여넣기 명령과 입력 문자는 로컬에 보존하고 커밋에서는 제외한다. GitHub README에는 실제 실행·수집·저장 안내만 반영한다. 사용자의 이번 요청으로 커밋·푸시를 수행하며, 결과를 확인한 뒤 컴퓨터 종료를 진행한다.
