# 게임 언어와 번역

기본 게임 언어는 한국어입니다. 영어 원문과 게임 데이터·식별자는 보존했습니다. 버튼, 안내, 대상 정보, 관찰·실험·격리 설명, 사건 대응, 연구 기록과 보관함에 한국어 번역을 적용했습니다. 직접 작성한 메모와 기술 식별자는 번역하지 않습니다.

## 파일과 책임

| 파일 | 역할 |
| --- | --- |
| `translations/en.po` | 원래 영어 문구. `msgid`와 영어 `msgstr` 보존 |
| `translations/ko.po` | 같은 `msgid`에 대응하는 한국어 `msgstr` |
| `project.godot` | 번역 파일 등록, 기본 한국어, 영어 fallback |
| `scripts/ui/game_text.gd` | 숫자·상태·콘텐츠가 조합된 문구의 표시와 언어 변경 시 갱신 |
| `scripts/main/main.gd`, `scripts/views/flow_view.gd` | 현재 화면의 문구 갱신, 보관함에서 복귀하는 화면의 문구 갱신 |
| `resources/ui/temp_industrial_theme.tres` | Windows 맑은 고딕 우선 사용 |

Godot의 [PO 번역 파일](https://docs.godotengine.org/en/latest/tutorials/i18n/localization_using_gettext.html)을 사용합니다. 짧은 예시는 다음과 같습니다.

```po
msgid "OPEN CCTV"
msgstr "관찰 영상 보기"
```

일반 Label·Button에는 영어 원문을 넣어 Godot의 자동 번역으로 표시합니다. 숫자나 선택 상태가 섞인 문구는 원문과 인수를 보존하는 `GameText`를 사용합니다.

```gdscript
GameText.set_text(remaining_label, "Experiments Remaining: %d / %d", [remaining, limit])
```

현재 CCTV·실험의 읽기 판정은 원문을 비교합니다. 해당 Label의 `.text`와 Resource 원문을 임의로 한국어로 바꾸면 안 됩니다. 화면에 그려지는 번역과 판정용 원문을 구분하고, 메모는 자동 번역을 끕니다.

## 언어 변경과 추가

향후 언어 선택 UI에서는 다음 API를 호출하면 됩니다. 현재는 설정 메뉴와 언어 선택 저장 기능을 추가하지 않았습니다.

```gdscript
TranslationServer.set_locale("ko") # 한국어
TranslationServer.set_locale("en") # 기존 영어
```

언어 변경은 표시만 갱신합니다. 게임 흐름을 다시 실행하거나 Runtime·View를 교체하지 않습니다. 번역 후 텍스트 높이가 달라지면 스크롤은 새 범위 안으로 조정될 수 있습니다.

새 언어는 영어 PO를 복사하고 헤더의 `Language`와 각 `msgstr`를 바꾼 뒤, 프로젝트 설정의 **국제화 → 로케일 → 번역** 목록에 등록합니다. 같은 원문 `msgid`를 사용하며 `%s`, `%d` 등의 개수와 순서를 유지합니다. 새 콘텐츠를 추가하거나 영어 문구를 수정할 때는 모든 언어의 PO 항목도 갱신해야 합니다.

현재 [프로젝트 설정](https://docs.godotengine.org/en/latest/classes/class_projectsettings.html)의 `internationalization/locale/test="ko"`로 한국어를 고정합니다. OS 언어를 자동으로 따르는 출시 정책을 도입할 때는 이 고정값을 해제하고, 저장한 언어 또는 OS 언어를 시작 시 적용하세요. 시스템 폰트는 개발 PC 기준이므로, 배포 시에는 지원 언어를 포함하는 라이선스 확인된 폰트를 함께 제공하는 것이 좋습니다.

## 이번 검증

- Godot 4.7.1에서 새 캐시 import, 제품 GDScript 전체 검사, Main 시작 검사.
- 한국어·영어 PO의 모든 번역 항목, printf 인수 형식과 원문 보존 검사.
- 실제 3개 Case·필수 사건·Mid-Case 사건·실패 경로와 기존 회귀 검사.
- 1920×1080, 1280×720, 1600×900 GPU 실행에서 한국어 글꼴과 UI 확인.
- 실행 중 언어 변경: 실험 선택·결과, 격리 선택·확정, 대응 지시·확정 창, 연구 기록 필터·선택, 작성 중 메모, 보관함과 업무 복귀 상태 보존 확인.

기존 1920×1080 기준, 초기 창 1280×720, `canvas_items`, Compatibility 설정과 Case·Campaign·사건 Resource는 유지했습니다. 기본 import·파싱·시작 검사는 [공개 검사](../tools/verify_project.ps1)로 재현할 수 있습니다. 이번 상세 검증 자료는 Git 제외 경로인 `.godot/verification/localization/`에 보관했습니다.
