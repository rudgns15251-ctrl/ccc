# CAP — Claude Code 프로젝트 규칙

> 2026-10-16 인수인계 초안. 프로젝트 루트의 `CLAUDE.md`로 배치. 실제 코드·사용자 최신 지시가 우선한다.
> 상세: `docs/CLAUDE_HANDOFF_2026-10-16.md`; 진행 로그: `docs/DEVELOPMENT_CONTINUITY.md`.

## 목적과 개발 방향
- CAP는 **Windows / Godot 4.7.1 Standard / GDScript / 2D Control 중심** 생체연구시설 관찰·추론·격리 공포게임이다. Compatibility 렌더러, 논리 1920×1080, 기본 창 1280×720, `canvas_items`, 한국어 중심.
- 시대 분위기: 소련 말기~러시아 초기의 실제 운영 중인 낡은 산업 연구시설. 약 90~120분 본편이 장기 목표이지 검증된 플레이타임이 아니다. **[APPROVED 2026-10-16]**
- 출시 범위: 정식 9개 Case + 기록 없는 숨겨진 개체 1을 **모두 출시**(약 90~120분 목표). 같은 날 앞서 정했던 '1차 4~5 Case·60분'은 이 결정으로 대체됨. 각 개체의 세부 설정은 이후 작성.
- 이야기 기준안: 팀 스토리 기획안 PDF(2026-10-11 수정본, `docs/story/team_story_plan_analysis_v1.md`). 플레이어는 봉인 직전 마지막 파견 직원이고 비상방송은 업무 콘솔의 일부. 크리처는 변이한 주민, 기록 12개(일기 6·명단 3·테이프 3), 엔딩 5종(고발·은폐·침묵·잔류·진엔딩, 판정식 DRAFT). 10번째 개체의 정체는 모호하게 유지. 실험·격리실은 각각 약 10개 규모(세부 UNDECIDED). 배경 연도는 뒤로 미룸 [UNDECIDED]. **[APPROVED 2026-10-16]**
- Case 1: **PDF의 빛 민감 개체**(빛에 피부 손상, 정답 암실, 튜토리얼). 기존 시선 반응 개체안은 04~09 후보로 보관. 세부는 DRAFT.
- 핵심 경험: **Profile → CCTV → Experiment(제한 실행) → Containment(승인) → 뒤늦은 결과**, 실패/실제 탈출 시 사건·직원 생존용 비상방송·사고 기록, Research/Archive/Hypothesis 재열람.
- 최우선은 **실제 플레이 가능한 게임 콘텐츠와 UI·이미지·사운드 통합**이다. 새 Harness, 테스트 프레임워크, 대규모 상태 관리자, 새 Autoload, 범용 이벤트버스, 대규모 Main 리팩터링은 구체적 필요 없이는 만들지 않는다.
- 시스템을 새로 설계하기 전에 실제 `scripts/`, `scenes/`, `resources/`, `docs/architecture.md`와 최신 보고서를 읽는다.

## Source of Truth와 설정 승인
- 실제 동작의 진실은 **현재 로컬 working tree**와 Godot 실행 결과이다. GitHub, 오래된 README, 과거 단계 보고서가 로컬 미커밋 변경을 대신하지 못한다.
- 기획 설정 우선순위: **사용자가 명시적으로 확정한 최신 결정** > 사용자가 제공한 임시/후보 입력 자료 > 보고서의 작성·검증 사실 > 오래된 제안. [APPROVED] / [DRAFT] / [TEMP NON-CANON] / [UNDECIDED] 구분.
- **T04는 TEMP/DRAFT/NON-CANON**. 원본의 두 머리·네 팔·두 다리·단일 체간/고유 얼굴·머리 돌기·검은 마른 피부 유지. 1991년 날짜, 신원/기원, 설비 결함, 실제 사상자, 본편 편입은 자동 확정 금지.
- 기존 M2/M4 박막낭, M5-A 시각 테스트 이미지, M5-B T04 테스트 콘텐츠를 정식 9개 Case로 임의 전환 금지. 최종 엔딩, 기록 없는 10번째 개체 설정, 직원 수/사망 수, 시설 봉인 이후 운영 방식 역시 임의 확정 금지.
- 새로운 이미지·실험 데이터는 **교체 가능한 Resource 참조** 사용. 파일명/해상도/구도에 Gameplay를 강하게 결합하지 않는다. 미제공 이미지를 증거처럼 위조하지 않는다.

## 기존 코드의 불변 계약
- 기존 Main이 요청·확정·상태 변경을 조율하고 View는 표시/임시 선택/Signal을 처리한다. 이미 존재하는 Runtime, Resource, Research, SaveCodec, Incident owner를 재사용한다.
- Experiment 결과·Research는 **실제 실행/읽기 경계 후에만 공개**. 모든 결과와 정답을 미리 노출하지 않는다. 실험을 했다는 이유만으로 임의의 탈출 패널티를 만들지 않는다.
- 격리 판정은 **지연되어 플레이어에게 전달**된다. `SUCCESS`, `FAILURE`, `실제 탈출`은 서로 다른 사실이다. M5-B ROOM A는 명시적 `failure_without_incident`로 탈출 없이 실패하며, ROOM B만 탈출한다.
- **실험 단계 재개 [APPROVED 2026-10-18]:** 격리 결정이 기록되기 전에는 남은 실험 기회가 있으면 격리 화면에서 실험 화면으로 돌아와 계속 실험할 수 있다(실험 단계가 다시 활성 업무 단계가 된다). 격리를 확정하거나 실험 기회가 0이면 실험 화면은 읽기 전용 재열람이다. 실험 결과 공개 경계와 Research 규칙은 그대로다.
- 비상방송은 **실제 탈출 이후** 직원·민간인의 **대피/생존 지침**을 전달한다. 시설 제어 조작을 대신하는 UI가 아니다. M4 복수 질문→원고 미리보기→수정/확인→최종 송출→잠금→사고 결과 확인과 업무 복귀를 보존한다.
- 사망자 `UNKNOWN`과 **확인된 0명**을 구분한다. 적절한 방송으로 과거 격리 실패를 성공으로 고쳐 쓰지 않는다.
- Campaign의 `CASE`, `CAMPAIGN_ENTRY`, `CAMPAIGN_INTERRUPT`, 지연 Incident 출처·우선순위·Read Boundary·중단 업무의 **정확한 Runtime/Focus/Scroll 복귀**를 보존한다.
- Research Log, Research Archive, Working Hypothesis, Story Records(목표 6+3+3), Accident Reports, Historical Facts는 별개 의미/출처를 유지한다.
- M3/M4 Save 파일 **역호환**, Campaign별 별도 슬롯/검증, 안전한 저장 단계만 허용, 실제 재시작 후 복원 경계를 유지한다. 기존 세이브 데이터 삭제·마이그레이션 금지(명시 승인 없이는).

## UI, 자산, 라이선스
- 기본 **F5 기존 Main**을 사용자 승인 없이 변경하지 않는다. M4.5 FACILITY CONTROL과 M5-A/M5-B는 비교/플레이테스트 F6 시안이며 **최종 채택 아님**.
- Profile 종이 문서는 유지. CCTV는 실영상 중심, 실험·격리는 비교 가능하게, 방송은 작성/검토/송출을 분리. 한글 가독성·720p 버튼 접근·Tab/Focus/Scroll을 보존.
- MAUSE, VHS UI, Analog Horror SFX 등 외부 애셋은 출처·원본 라이선스를 따르며 관련 Credits/manifest를 유지. `assets/local_only/`와 `builds/`, `.godot/`은 Git 제외. 제한된 Retro 원본을 공개 저장소에 올리지 않는다.
- 실제 영상/열화상·T04 실험별·사고 이미지 대부분은 미제공 상태다. Placeholder와 사실 기반 관찰 텍스트를 유지; 실제 콘텐츠가 생긴 후 시각 디자인을 평가한다.

## Git/로컬 작업 보호
- 시작할 때 `git status --short`, `git branch -vv`, `git log -1 --oneline`, `git diff --stat`, untracked 목록을 확인하고 **로컬 작업 트리**를 우선한다.
- 인수인계 시점 GitHub `main`은 `122ffb1`(M5-A)이고, **M5-B는 로컬 미커밋이었다**. 세션 시작마다 재확인한다. GitHub만 클론하여 M5-B가 있다고 가정하지 않는다.
- 기존 README 개인 수정, T04 원본 입력 ZIP/원문/원본 이미지, 모든 Scene/Resource/애셋/저장 데이터를 보존한다.
- 사용자가 명시적으로 승인하지 않으면 `git add`, `git commit`, `git push`, `git reset`, `git clean`, `git checkout`으로 작업트리를 덮는 행위, 일괄 포맷팅과 대량 삭제를 하지 않는다. 복원 위험 명령은 반드시 사전 동의.
- 외부 명령과 다운로드는 권한·라이선스·위험을 확인한다. 검사 실패를 숨기지 않는다. 불필요한 영구 의존성을 추가하지 않는다.

## 확인 및 결과 보고
- `docs/verification.md`의 `tools/verify_project.ps1`를 실제 Godot 실행 경로에 맞춰 사용; Godot 4.7.1 import, GDScript check-only, 기본 Main smoke 확인.
- 변경된 콘텐츠는 실제 F6 Playtest와 1280×720/1920×1080 GPU, 마우스/키보드, 긴 한국어 문서, Archive 왕복, 실험 횟수, 지연 결과, 실제 탈출 후 방송, 저장·재시작을 관련 범위에서 확인한다.
- 자동 검사 횟수를 사람의 플레이타임·몰입·UX 검증으로 주장하지 않는다. 테스트 불가능한 것은 명확히 표시한다.
- 매 완료 시 **변경 파일/기능·미검증/문제·이미지/라이선스·시나리오 DRAFT와 APPROVED·Git 상태·다음 하나의 우선 작업**을 `docs/DEVELOPMENT_CONTINUITY.md`에 갱신하고 사용자에게 요약한다.
- 매 세션 첫 시작 시 상세 인계 문서를 읽고, 현재 코드·문서와 비교한 차이부터 보고한다. 새로운 기술 프레임워크보다 실제 콘텐츠·완성도 작업을 우선한다.
