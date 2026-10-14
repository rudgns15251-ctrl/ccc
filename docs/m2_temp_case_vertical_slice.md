# M2 — TEMP Case Vertical Slice

## 1. 실제 Repository 상태

Godot 4.7.1 Standard / GDScript / Windows / Compatibility. Main과 Step62~71의 업무·기록·사건·복귀 구현을 실제 파일에서 확인했다. 기존 기본 Campaign은 Case01 → Case02 → Mandatory → Case03이며 Case03 첫 Experiment에 Side 사건이 있다. Autoload는 없다.

시작 HEAD `53b1956`, branch `master`, upstream `origin/main`, staged 없음. Step71의 미커밋 UI·문서·번역·Export 변경이 이미 있었다. 이를 보존하고 M2 시작 시점의 190개 파일을 별도로 비교했다. README의 기존 외부 프로젝트 Git 명령과 작업 중 입력된 `ㅁ`도 수정하지 않았다.

## 2. 신규 TEMP Case 개요

**[TEMP / NON-CANON] 박막낭 / Lamellar Sac**, `TEMP_M2_CASE_01`. 약 70cm의 은회색 접힌 막주머니, 짙은 세로 이음선과 가는 건조 섬유를 가진다. 눈·입은 확인되지 않았다. 정전기를 띤 절연 재료에 반응하고, 접지와 적당한 습도를 함께 유지하면 안정된다. 직접 물을 대면 별도의 이동 가능한 막편이 떨어진다. 공식 9개 Case나 비밀 10번째 개체에 편입하지 않는다.

## 3. 플레이어의 추론 흐름

과거 기록의 **따뜻하고 습한 환경 선호** 가설 → CCTV에서 사람·온기와 운반 재료의 반응을 구분 → 3개 중 2개 실험으로 전기적 연결·습도·직접 적심 비교 → 격리함 선택·승인 → 다음 업무 인계에서 지연 판정. 오답이면 후속 관찰·실험 등 기존 조건에 따라 환경 알림 → 탈출 사건 → 직원 대피 방송 → 대응 관찰 → 업무 복귀.

실험 조합을 강제하지 않는다. 접지+습도 조합은 두 안정 조건을 직접 확인한다. 접지+적심 조합은 과거의 습도 61% 회수 기록으로 보완하고, 습도+적심 조합은 CCTV의 접지 전후 비교로 보완한다. 목표 10~15분은 **사람이 읽고 판단하는 플레이테스트 목표**이며 이번 자동 검사로 달성했다고 주장하지 않는다.

## 4. Profile 콘텐츠

기본 외형 / 과거 관찰 사실 / 연구자 해석을 분리했다. 접지 트레이·습도 61% 회수, 따뜻한 금속 도구의 접촉 효과, 직접 물방울과 기류에 따른 막편 탈락을 기록한다. 온도·전도성·접촉이 섞인 과거 관찰의 한계를 명시하고 정확한 격리함 이름이나 정답 판정은 공개하지 않는다.

## 5. CCTV 콘텐츠

20℃·습도 35%의 단일 카메라 기록. 마찰된 합성수지 슬리브를 따라가지만 사람이 물러나도 반응하며, 따뜻한 절연 금속 모형은 이를 재현하지 않는다. 접지선 연결 시 몸체 확장이 멎어도 건조 조건의 가는 섬유 반응은 남는다. 대피 판단에 필요한 정비 우회로·합성수지 통로의 바닥과 기류 조건도 관찰한다. 실제 영상·열화상은 미적용이다.

## 6. Experiment 목록과 결과

기존 제한 **3개 후보 중 2회**, 선택과 실행을 구분하고 실행한 결과만 Research에 공개한다.

| 실험 | 통제·비교 | 실제 결과 |
| --- | --- | --- |
| 전기적 연결 | 동일 금속·20℃·습도 35%, 절연/접지 | 접지가 몸체 확장을 멈추지만 건조한 섬유 반응은 남음 |
| 물 접촉 없는 습도 | 접지·20℃, 습도 35%/63% | 63%에서 섬유 상승도 멎고 다시 건조해지면 재개 |
| 습한 공기와 직접 적심 | 접지·20℃·습도 63%, 공기/물방울 | 물방울에 막편이 떨어짐; 습한 공기는 같은 탈락을 일으키지 않음 |

## 7. Containment 후보와 정답 근거

| 후보 | 구성 | 지연 판정·근거 |
| --- | --- | --- |
| 따뜻한 건조 수지 격리함 | 따뜻한 조명, 습도 30~35%, 절연 수지, 송풍 | FAILURE. 온기 가설에 치우치고 대전 재료·건조 반응을 방치 |
| **도전성 습공기 격리함** | **접지, 습도 60~65%, 물방울 없음**, 20℃, 약한 기류·포집망 | **SUCCESS**. 몸체와 섬유 반응을 함께 억제하고 직접 적심을 피함 |
| 포화 습도 침수 격리함 | 습도 90~95%, 직접 물 접촉, 절연 아크릴 | FAILURE. 습한 공기와 액체를 혼동하며 막편 탈락·전기적 연결 문제를 남김 |

승인 시 Pending만 기록한다. 다음 Case로 인계할 때 기존 Resolution owner가 판정한다. M2 전용 하단 문구는 이 사실을 읽어 표시하며 상태를 소유하지 않는다. 정답의 안정 관찰은 인계 후 Archive에서 확인할 수 있다.

## 8. Research 발견

Profile 1, CCTV 1, 실험 3, 격리함 3, Incident 1, Broadcast 1, 승인 Option 3, 대응 Result 3의 **16개 authored 기록**을 작성했다. 전부 처음부터 공개하지 않는다. 실제 노출·실행·승인·결과 표시에 따라 기존 발견 규칙을 사용한다. Profile의 세 문서 영역은 기존 단일 Profile 발견 항목에 묶인다. 현재 Research Log, 사용자 Hypothesis, 인계 후 Archive가 연결되며 미실행 실험과 미승인 대피 선택지는 발견 사실이 되지 않는다.

## 9. Incident / Failure 호환

오답 격리함은 `TEMP_M2_INCIDENT_ESCAPE`의 후속 후보가 된다. 기존 2~4회 의미 있는 업무 기회·읽기 경계와 이후 Major 조건을 유지했다. 일반 Next 반복이나 기록 열람으로 시간을 대체하지 않는다. 시설의 부유 막편 알림은 새 개체 행동을 임의로 만들어내지 않는다.

새 방송은 **직원 대피**다. 접지 바닥·약한 기류의 우회로, 합성수지·환기구·맨손·직접 적심 회피를 지시하는 선택이 합리적이다. 짧고 따뜻한 수지 통로를 택하거나 물로 적셔 환기구 쪽으로 이동하면 관찰된 위험이 지속·증가한다. 반응에 따른 관찰 문구를 기록하되 피해 인원·재확보 성공·민간인 존재를 새로 확정하지 않는다. 좋은 대피 대응도 최초 격리 FAILURE를 SUCCESS로 바꾸지 않는다. Step63/69의 기존 TEMP 설비 대응 사건은 보존했다.

## 10. 플레이테스트 진입 방법

- 에디터: [m2_playtest.tscn](../scenes/playtests/m2_playtest.tscn)을 열고 **F6**. 기존 Main을 상속하며 같은 업무 View·실제 owner를 사용한다.
- 기본 **F5**: 기존 3-Case Campaign 그대로 시작한다.
- Windows: `builds/m2/CAP_M2.exe` 직접 실행. M2에서 시작하며 PCK가 EXE에 포함된다. 빌드는 Git 제외 대상이다.
- 재생성: 설치된 4.7.1 Windows 템플릿으로 `--export-debug "Windows M2 Playtest" builds/m2/CAP_M2.exe`.

별도 Campaign은 **M2 → 기존 Case01 → Case02 → Mandatory → Case03 + 기존 Side**다. 결과와 지연 사건을 보려면 격리 승인 후 다음 업무로 인계하고 후속 관찰·실험을 진행한다. M2 성공 후에 발생하는 기존 테스트 Case의 사건은 M2 실패를 의미하지 않는다. 마지막 테스트 Case 이후의 엔딩·반복 시작 기능은 이번 작업에 포함하지 않았다.

전용 Export feature `m2_playtest`에만 Main Scene 설정을 override한다. 에디터 기본 실행 설정에는 적용되지 않는다. [Godot 공식 feature tags 안내](https://docs.godotengine.org/en/stable/tutorials/export/feature_tags.html).

## 11. 실제 Gameplay 검증

Godot **4.7.1.stable.official.a13da4feb** 사용. 기존 로컬 검사와 입력 도우미를 재사용했으며 새 검증 프레임워크를 제품에 추가하지 않았다.

| 검사 | 결과 |
| --- | --- |
| 공개 `tools/verify_project.ps1` | Import, 제품 GDScript 55개, 기본 Main 시작 통과 |
| M2 실제 Main | 실험 조합 3개 정답 경로 + 두 오답 격리함/대피 선택 3개 = 6경로 통과 |
| Headless / GPU 1920 / GPU 1280 | 각 6경로 통과, 최종 파싱·Script·실행 오류 없음 |
| 기존 제품 회귀 | 원본 Campaign 7경로, Mandatory·Side 응답/복귀·완료 이력·기존 개발용 종료 API 보존 확인 |
| Windows 독립 패키지 | M2 feature/진입, 실제 실험·Pending·인계·SUCCESS 통과. 문서·도구·QA 패키지 제외 확인 |
| 실제 Windows EXE | Headless와 GPU 실행 exit 0, 오류 없음. 약 108.6MB |

실제 제품 Scene·Resource를 사용하고 Godot GUI 입력을 전달했다. 물리 마우스로 사람의 재미·가독성을 평가한 테스트는 아니다. 실패 경로의 난수 seed 고정과 부정 검사의 복제 Resource는 **QA 한정**이다. 후보·판정·credit을 주입하거나 제품 Threshold를 낮추지 않았다. 기존 회귀 검사의 개발용 종료 호출도 M2 제품 흐름에 엔딩을 추가한 것이 아니다.

초기 제작 중 새 TRES 내부 ID 충돌, 종료 중 하단 Label 접근 오류를 수정했다. 검사 자체의 현재 Runtime/보관 Archive 혼동과 CASE Source Archive 직접 진입 가정도 수정했다. 실패 로그는 로컬에 보존했고 마지막 성공 실행으로 별도 확인했다. 로그·fixture: `.godot/verification/m2/` 및 `public_smoke/`—Git/빌드 제외.

## 12. 두 해상도 UI 결과

1920×1080 / 1280×720의 GPU 화면에서 한국어 줄바꿈, 문서·목록 스크롤, 실행·승인 버튼, 확인 모달, Drawer·Archive·사건 출처 표시를 확인했다. 기준 해상도·`canvas_items` 설정은 유지했다. 실행 중 1920×1080 → 1000×800 → 원래 크기로 변경해도 논리 배치·같은 View·소유 상태가 유지되는 검사도 통과했다.

실제 화면은 [screenshots/m2](screenshots/m2)에 두 해상도로 보관했다. [Profile 1280](screenshots/m2/profile_1280.png), [CCTV 1920](screenshots/m2/cctv_1920.png), [실험 1280](screenshots/m2/experiment_1280.png), [격리 1920](screenshots/m2/containment_1920.png), [정답 Archive 1280](screenshots/m2/archive_1280.png), [대피 방송 1280](screenshots/m2/broadcast_1280.png), [대응 결과 1920](screenshots/m2/response_result_1920.png).

## 13. 이미지·사운드 추가 제작 목록

현재 `assets/`에는 사용 가능한 개체 이미지·영상·Audio가 없다. Texture 슬롯과 기존 Placeholder를 사용한다. 기능 흐름은 플레이할 수 있지만 시각·음향 콘텐츠가 완성된 것은 아니다.

| 우선순위 | 필요한 자산·적용 위치 |
| --- | --- |
| 후속 시각 제작 필수 | 박막낭 Master Reference: 70cm 접힌 은회색 자루·세로 이음선·섬유, 펼침/접힘/분리 막편의 동일 디자인 기준. 제작 전 외형 승인 |
| 후속 시각 제작 필수 | Profile 사진 → `subject_texture`, 단일 CCTV 구도 → `feed_texture`. 접지 트레이·슬리브·모형을 관찰 문구와 일치시킴 |
| 선택 | 실험 3종의 결과 비교 이미지 → 각 `result_texture`; 부유 막편·복도 탈출 사건 이미지. 미실행 결과를 노출하지 않음 |
| 선택 | CCTV 잡음, 장치 조작, 시설 경보·사건 경고, 방송 송출음. 권한·파일을 확보한 후 기존 Scene에 작은 AudioStreamPlayer로 연결 검토 |
| 이번 개체에 불필요 | 열화상. 열이 핵심 검증 수단이 아니며 동일 구도의 실제 자료 없이 필터로 대체하지 않음 |

외부 자산 다운로드·최종 개체 이미지 생성·새 AudioManager는 수행하지 않았다. 소리만 들어야 얻는 필수 단서는 없다.

## 14. 변경 파일

M2 신규: `resources/cases/temp_m2_case_01.tres`, `resources/campaigns/temp_m2_playtest.tres`, `scenes/playtests/m2_playtest.tscn`, `scripts/main/m2_playtest.gd`·UID, 이 보고서와 `docs/screenshots/m2/`.

M2 수정: `project.godot`에 전용 feature Main override 1줄, `export_presets.cfg`에 preset 1 추가(기존 preset 0 보존), `translations/en.po`·`ko.po`에 73개 메시지 추가, `docs/README.md`에 보고서 링크 1줄. 영어 원문과 자연스러운 한국어 번역을 함께 유지한다.

Main 원본 Script/Scene, Runtime, 기존 Case·Campaign·Incident·Theme·View, 기존 Step71 변경·화면 증거는 M2 시작본과 동일하다. `git diff --check`와 시작본 비교로 변경 범위를 확인했다. 작업 중 생긴 README의 `ㅁ`은 M2 작성 변경에 포함하지 않는다. 스테이징·커밋·푸시는 수행하지 않는다.

## 15. 미완성 사항

실제 개체 이미지·영상·소리, 사람의 10~15분 플레이타임·재미·추론 난이도 평가는 남아 있다. 전용 성공/종료 Scene, 마지막 Case 이후 엔딩, Save/Load, 재확보 관리, 피해·경제·생명유지 수치, 공식 Case 확정, 3D·새 셰이더·실시간 Monitoring은 추가하지 않았다. 실패 방송은 기존 텍스트 대응 선택 구조이며 실제 경로 이동 게임이나 피해 시뮬레이션이 아니다.

## 16. 향후 M3 개발 준비사항

먼저 M2를 정답·오답으로 직접 플레이해 각 실험 조합의 납득 가능성, 문서 길이와 클릭 흐름을 평가한다. 시각 제작을 시작하려면 외형 기준·이미지 권한·관찰 구도를 승인하고 슬롯에 연결한다. 기본 Campaign 편입과 최종 플레이 시간은 그 피드백 후 결정한다.

아래는 향후 고려 항목이며 이번 M2에서 신규 구현하지 않았다. 기존 기반이 있는 항목도 최종 정책 확정을 의미하지 않는다.

| 향후 항목 | 다음 단계 선행 조건 |
| --- | --- |
| 전임자 일기 6장 / 주민 명단 3장 / 교육 영상 3편 | 사용자 콘텐츠·발견 순서 승인 |
| 기록에 없는 10번째 개체 | 정체·정식 편입 여부 사용자 결정 |
| 봉인 후 전력·생명유지·기록 | 운영 방식·수치 범위 사용자 결정 |
| 탈출 방송 | M2의 직원 대피 선택을 평가한 뒤 최종 대상·노출 정책 결정 |
| 최초 격리 실패 / 이후 재확보 구분 | 별도 재확보 모델·기록 정책 사용자 결정; 초기 실패 유지 |
| 공식 Case04~09 | 공식 개체·추론 구조 승인 |
| 실제 열화상 분포 | 동일 구도의 실제 자산·관측 의미 확보 |
| 사건 발생 구조 | 현재 지연·Scripted 기반을 바탕으로 최종 pacing 결정 |
| 진엔딩 순서 | 사용자 시나리오·분기 승인 |
| 전임자 공개 | 정체와 공개 조건 사용자 결정 |
| 1991년 날짜·시설 기록 정합성 | 시작 날짜·공식 연표 확정 후 검토 |
