# CAP 프로젝트 현황 (2026-10-16 기준)

> 이 문서는 한 시점의 요약입니다. 작업별 상세 기록은 [DEVELOPMENT_CONTINUITY.md](DEVELOPMENT_CONTINUITY.md)에 있습니다. 실제 동작의 기준은 언제나 현재 로컬 작업 트리와 Godot 실행 결과입니다.
> 표기: **[사실]** 파일·실행으로 확인한 것 / **[APPROVED]** 사용자 확정 / **[DRAFT]** 후보 / **[UNDECIDED]** 미정 / **[판단]** 제 의견.

---

## 1. Git 상태

| 항목 | 값 |
|---|---|
| 현재 브랜치 | `master` (작업 브랜치 `ui-release-theme`와 같은 커밋) |
| HEAD | `ea40822` Add QA fixes, result report panel, CC0 materials, console frame and sounds |
| 원격 `origin/main` | `aae16a2`(M5-B T04). **로컬이 3커밋 앞서 있음, 푸시 안 함** |
| 이번 세션의 커밋 | `45b9143`(출시 Theme 1차·T04 추론 재조정·인계 문서) → `3f87c73`(UI 패스: 가독성·소리·아이콘·타이틀·설정·일시정지·크레딧) → `ea40822`(QA 수정·결과 보고서 패널·CC0 재질·콘솔 프레임·소리) |

**미커밋 변경 (커밋 대상 후보)**
- `CLAUDE.md`: 출시 범위·이야기·Case 1 승인 기록.
- `docs/DEVELOPMENT_CONTINUITY.md`: 최근 작업 기록.
- `export_presets.cfg`: 출시 프리뷰 preset 추가.
- `project.godot`: `run/main_scene.release_preview` 한 줄(F5 기본 Scene은 그대로).
- `docs/release_roadmap.md`, `docs/story/decision_brief_v1.md`, 이 문서(신규).

**커밋에서 계속 제외할 것 (사용자 지시 또는 CAP와 무관)**
- 사용자 지시로 제외: `README.md`(개인 편집), T04 입력 ZIP과 추출 폴더(`.gdignore` 포함), `설치_안내.md`, `CLAUDE_FIRST_SESSION_PROMPT.txt`.
- CAP와 무관해서 제외: `anki_project/`, `source/`, `output/`, `requirements.txt`. 이 세션이 만든 파일이 아닙니다. **프로젝트 폴더 밖으로 옮기는 것을 권장**합니다. `output/`은 Godot가 `cards.csv`를 리소스로 가져오고 있습니다.

**로컬 전용 (Git 제외, 백업 권장)**
- `builds/release_preview/CAP_Preview.exe`(138MB) + `licenses/` + README.
- `.godot/verification/`: 여정 검사 스크립트와 캡처. `journey.gd`에 결과 패널 검사를 추가했습니다.

---

## 2. 최신 구현 [사실]

### 핵심 시스템 (이전 단계에서 구현, 유지)
- Profile → CCTV → 실험(횟수 제한) → 격리 승인 → 지연 판정 → (실패 시) 환경 경고 → 사고 → 다중 질문 비상방송 → 사고보고서 → 원래 업무로 정확히 복귀.
- SUCCESS / 탈출 없는 FAILURE / 실제 탈출을 구분합니다. 사망·부상은 UNKNOWN과 0명을 구분합니다.
- 연구 기록·보관함·메모, Story Record 슬롯(6/3/3), Campaign별 수동 저장(v1, 서명 검사).

### 출시용 UI (T04 F6 프리뷰에만 적용, F5는 기존 화면)
- **구조:** FACILITY CONTROL **[APPROVED 기준 구조]**.
- **Theme** `resources/ui/release_instrument_steel_theme.tres`. `tools/build_release_theme.gd`로 재생성합니다.
  - 동봉 글꼴: IBM Plex Sans KR / Mono, 나눔고딕코딩(OFL).
  - CC0 재질(Poly Haven, ambientCG)을 톤 매핑한 강판·음각 홈·CRT·종이·경보 띠, 콘솔 프레임.
  - 720p 기준 글자 크기와 줄 간격, 슬라이더·드롭다운·배지·헤더 버튼 스타일.
- **화면 개선:** 업무 키 상태 표시등과 자물쇠 아이콘, 기록 도구 아이콘(Tabler, MIT), TEMP BUILD 배지 하나로 임시 안내 통합, 격리 비교표, 실험 목록 정리와 남은 횟수 표시등, 사고 화면 빈 이미지 틀 제거, 확인창 확대, 연구 기록 서랍(목록·상세 좌우), 경고·서랍 뒤 흐림, 종이 사고보고서, 방송 화면 비율 조정, 시설 조건을 경보 띠에 통합, 내부 ID 대신 한국어 제목·카메라 표시명.
- **지연 결과 보고서 패널:** 격리실 A/C의 판정을 처음 공개할 때 종이 보고서로 전달합니다(판정·저장 변경 없음).
- **메뉴:** 타이틀(이어하기·새 근무·설정·크레딧·종료, 새 F6 진입점), 설정(전체 음량·조작음·글자 크기, `user://release_settings.cfg`), 일시정지(Esc·메뉴 버튼), 크레딧(전체 라이선스 표기).
- **소리:**
  - 기계식 클릭(87 Clickety Clips, CC0).
  - 이벤트음과 환경 루프(BigSoundBank, CC0)를 `tools/build_release_sfx.gd`로 가공했습니다: 화면 진입, 경고, 사고, 송출, 보고서, 운영실 환기·형광등.
  - headless 실행에서는 소리를 내지 않습니다.
- **빌드:** export preset "Windows Release Preview"(타이틀에서 시작). 제한된 Retro 원본, 원본 소리·재질, 문서는 제외됩니다.

### 콘텐츠
- T04 임시 사례 [TEMP/DRAFT/NON-CANON]: M5-B.2 추론 재조정(측정값 비교, 실험 수치, 절충형 방송 오답, 선택별 사고 기록), 합성 임시 이미지 6장.
- M2 박막낭 임시 사례, F5 개발용 테스트 Case 3개.

### 검증 상태
- `tools/verify_project.ps1` PASS(80 scripts).
- T04 세 경로를 1280과 1920 GPU 창에서, 글자 '보통'과 '크게'로 실행했습니다. 메뉴 흐름 14항목, 플레이테스트 Scene 5개 시작, EXE headless·창 실행 모두 통과.
- 유일한 실패는 옛 기대값 `honest_cctv`(CCTV 이미지가 없을 것으로 기대한 검사, M5-B.1에서 의도적으로 바뀜)입니다.
- **사람이 직접 한 플레이 평가는 아직 0회입니다.**

---

## 3. 기획 — 확정과 미정

### 확정 [APPROVED]
| 항목 | 내용 | 결정일 |
|---|---|---|
| 출시 범위 | 정식 9개 Case + 기록 없는 숨겨진 개체 1을 **모두 출시**(약 90~120분 목표). 앞서 정한 '1차 4~5 Case·60분'은 대체됨 | 2026-10-16 |
| 이야기 방향 | **C. 결합안**: 공석이 된 연구원 자리를 이어받았고 야간 비상방송 책임도 맡음. 전임자 일지(진실)와 직원 명단·방송(대가)이 축 | 2026-10-16 |
| Case 1 | **시선 반응 개체**: 감시 조명·카메라 표시등에 반응, 적외선 감시가 정답 방향(콘셉트만) | 2026-10-16 |
| UI 기준 구조 | FACILITY CONTROL | 2026-10-16 |
| T04 처리 | 개체·실험·격리실은 임시 사항으로 두고 넘어감 | 2026-10-16 |
| 시대·톤 | 소련 말기~러시아 초기의 낡은 생체연구시설 | 인계 시점 |

### 후보 [DRAFT]
- Case 1 세부 초안: 외형 방향, CCTV 단서, 실험 3종, 격리 후보 3개, 사고와 방송 방향([docs/story/decision_brief_v1.md](story/decision_brief_v1.md) 2장).
- T04를 Case 2~3으로 정식 승격하는 안(승격 여부는 미정).
- 설계 평가 보고서의 공포 연출안·UI 개선안 중 미적용 항목([docs/design_review/](design_review/)).

### 미정 [UNDECIDED]
- 전임자의 존재 방식, 사라진 이유, 일지의 신뢰도.
- 결말(종류와 조건), 숨겨진 개체의 정체와 등장 방식.
- Case 2~9의 개체와 순서, 강제 사건 배치.
- Story Record 12개(일기 6 · 주민 명단 3 · 교육 영상 3)의 내용과 발견 위치.
- 직원 수·피해 수치 규칙, 시설 봉인 이후 운영 방식.
- 출시 UI를 F5 본편 진입점으로 옮기는 시점(기본 F5 변경 승인 필요).
- 키 아트·콘텐츠 이미지의 외주 여부와 예산.

---

## 4. 남은 문제

### 출시를 막는 큰 공백
1. **정식 콘텐츠 0개**: 9+1 Case, Story Record 12개, 엔딩 모두 미작성.
2. **사람의 플레이 검증 0회**: 추론의 재미, 난이도, UI 이해도가 확인되지 않음.
3. **본편 진입점**: F5는 아직 개발용 테스트 Campaign이고 출시 UI는 T04 프리뷰에만 있음.
4. **콘텐츠 이미지**: 정식 개체·CCTV·실험·사고 이미지가 없음(정식 Case 확정 후 제작).

### 작은 문제와 기술 부채
- 도장 소리 없음(가공 또는 녹음 필요). Sonniss 번들은 봇 확인 때문에 직접 다운로드가 필요함.
- 소리 음량 균형과 반복 피로도는 귀로 듣는 평가가 필요함.
- 콘솔 프레임이 720p에서 얇아 장소감 효과가 은은함.
- 해상도·창 모드·키 설정 화면 없음.
- `main.gd` `_restore_navigation_screen`이 조기 return하면 `_navigation_busy`가 남는 문제(미수정, 경미).
- 로컬 여정 검사의 옛 기대값 `honest_cctv` 갱신 필요. `--mode=all`은 실제 사용자 폴더에 T04 저장을 쓰므로 실행 후 정리가 필요함.
- 프로젝트 폴더 안의 무관한 폴더(`anki_project/`, `source/`, `output/`).

---

## 5. 다음 작업

| 순서 | 작업 | 누가 |
|---|---|---|
| 1 | **9+1 Campaign 골격 초안**: Case 배치, 난이도 곡선, 강제 사건, Story Record 12개 위치, 전임자 공개 순서(미정 설정은 후보로 표시) | Claude 초안 → 사용자 결정 |
| 2 | **Case 1(시선 반응 개체) 정식 문서 초안**: Profile, CCTV, 실험, 격리, 지연 결과, 사고·방송, Research, 이미지 제작 시트 | Claude 초안 → 사용자 확정 |
| 3 | `CAP_Preview.exe` 직접 플레이와 피드백(README의 5가지 질문) | 사용자 |
| 4 | Case 1 데이터 구현과 출시 UI의 F5 이전(F5 변경 승인 후) | Claude |
| 5 | Case 1~3 → 중간 프리뷰 빌드와 플레이 검증 → Case 4~9 → 숨겨진 개체·엔딩 | 함께 |
| 6 | 출시 준비: 키 아트, 스토어, 해상도·키 설정, 외부 테스트 | 함께 |

**[판단]** 지금 가장 효과가 큰 일은 1·2번(골격과 Case 1 문서)과 3번(직접 플레이)을 병행하는 것입니다.

---

## 6. 주요 문서
- 인계·규칙: [CLAUDE.md](../CLAUDE.md), [CLAUDE_HANDOFF_2026-10-16.md](CLAUDE_HANDOFF_2026-10-16.md)
- 작업 로그: [DEVELOPMENT_CONTINUITY.md](DEVELOPMENT_CONTINUITY.md)
- 출시 로드맵: [release_roadmap.md](release_roadmap.md)
- 결정 자료: [story/decision_brief_v1.md](story/decision_brief_v1.md)
- 설계 평가: [design_review/2026-10-16_independent_design_review.md](design_review/2026-10-16_independent_design_review.md)
- UI: [ui_release/art_direction_v1.md](ui_release/art_direction_v1.md), [ui_release/qa_pass_1.md](ui_release/qa_pass_1.md), [ui_release/asset_acquisition_plan.md](ui_release/asset_acquisition_plan.md)
- 에셋 출처: `assets/fonts/release/CREDITS.md`, `assets/ui/release/README.md`, `assets/third_party/release_ui/CREDITS.md`
