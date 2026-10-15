# M4.5 — 공식 무료 UI 에셋 비교

2026-10-15. 공식 무료 파일 4종을 확보해 독립 비교 Scene에 연결했다. RELAY는 공개 무료 샘플을 확인하지 못해 제외했다. **최종 디자인 채택, 결제, 커밋, 푸시는 하지 않았다.**

## 실행과 화면 비교

- Godot 4.7.1에서 `scenes/playtests/m4_5_ui_comparison.tscn`을 열고 **F6**.
- 우측 상단 **UI 비교**에서 원본 / MAUSE OS / VHS UI / MAUSE + CRT / MAUSE + VHS FX 중 선택한다. 기본값은 원본이다.
- 효과음은 같은 메뉴에서 명시적으로 켠 뒤 미리들을 수 있다. 기본은 꺼짐, 비교용 재생 음량은 -22 dB이다. 실제 방송 확정 시 송출음을 한 번 재생한다.
- 방송 진입은 [M4 플레이테스트 경로](m4_broadcast_incident_consequences.md)를 사용한다. 이 Scene도 기존 M4 캠페인을 실행한다.
- **F5 기본 Main, M2·M4 Scene, 프로젝트 해상도·Stretch·번역·저장 계약은 이번 작업에서 바꾸지 않았다.**

[원본 / 신규 UI 비교 뷰어](screenshots/m4_5/index.html) — 로컬 브라우저에서 열면 화면·시안·해상도를 선택해 나란히 볼 수 있다. GitHub에서는 HTML 소스가 표시되므로 아래 PNG 링크를 이용한다.

| 화면 | 기존 | MAUSE | VHS |
|---|---|---|---|
| Profile 720p | [원본](screenshots/m4_5/profile_0_1280.png) | [MAUSE](screenshots/m4_5/profile_1_1280.png) | [VHS](screenshots/m4_5/profile_2_1280.png) |
| CCTV 720p | [원본](screenshots/m4_5/cctv_0_1280.png) | [MAUSE](screenshots/m4_5/cctv_1_1280.png) | [VHS](screenshots/m4_5/cctv_2_1280.png) |
| 방송 검토 720p | [원본](screenshots/m4_5/broadcast_preview_0_1280.png) | [MAUSE](screenshots/m4_5/broadcast_preview_1_1280.png) | [VHS](screenshots/m4_5/broadcast_preview_2_1280.png) |
| 방송 확인 720p | [원본](screenshots/m4_5/broadcast_confirm_0_1280.png) | [MAUSE](screenshots/m4_5/broadcast_confirm_1_1280.png) | [VHS](screenshots/m4_5/broadcast_confirm_2_1280.png) |
| Profile 1080p | [원본](screenshots/m4_5/profile_0_1920.png) | [MAUSE](screenshots/m4_5/profile_1_1920.png) | [VHS](screenshots/m4_5/profile_2_1920.png) |
| CCTV 1080p | [원본](screenshots/m4_5/cctv_0_1920.png) | [MAUSE](screenshots/m4_5/cctv_1_1920.png) | [VHS](screenshots/m4_5/cctv_2_1920.png) |
| 방송 검토 1080p | [원본](screenshots/m4_5/broadcast_preview_0_1920.png) | [MAUSE](screenshots/m4_5/broadcast_preview_1_1920.png) | [VHS](screenshots/m4_5/broadcast_preview_2_1920.png) |
| 방송 확인 1080p | [원본](screenshots/m4_5/broadcast_confirm_0_1920.png) | [MAUSE](screenshots/m4_5/broadcast_confirm_1_1920.png) | [VHS](screenshots/m4_5/broadcast_confirm_2_1920.png) |

영상 전용 효과: **CRT** [720p](screenshots/m4_5/cctv_3_1280.png) / [1080p](screenshots/m4_5/cctv_3_1920.png), **VHS Lite** [720p](screenshots/m4_5/cctv_4_1280.png) / [1080p](screenshots/m4_5/cctv_4_1920.png). 질문 화면을 포함한 총 34개 캡처를 비교 뷰어에 보관했다. 촬영 후 리사이즈·합성·보정하지 않았다.

## 확보 및 라이선스 검토

| 대상·공식 배포처 | 실제 확보 / 선택한 내용 | 라이선스 근거·공개 저장소 처리 | Godot 호환성 |
|---|---|---|---|
| [MAUSE OS](https://bokx.itch.io/mause-os-minimalist-ui-theme-for-godot) | `Sifi Minimalist Theme.tres`, 6,559,022 B. 실제 StyleBox 77개·색상만 추출 | 공식 페이지의 code MIT / assets CC BY 4.0 선언. 출처·변경 사항·라이선스 동봉. 내장 폰트·캐시 텍스처·아이콘은 출처/이식성 불확실성 때문에 제외 | 추출 Theme를 4.7.1 Compatibility에서 실제 실행 |
| [RELAY Observatory UI](https://formandsignal.itch.io/relay-observatory-ui) | **미확보**. 공식 작성자 목록까지 확인했으나 무료 샘플 링크가 없고 유료 `$12` ZIP만 표시 | 파일별 라이선스 검증 불가. 유료 파일을 요청하거나 가져오지 않음 | 공식 설명의 Godot 4.6.3 Linux Compatibility 표기는 있으나 직접 검증하지 못함 |
| [VHS UI Free](https://heyheythere.itch.io/vhs-ui-free) | `vhs-ui-free-assets.zip`. Theme 의존 PNG 29개, corner/rec 아이콘 2개, snow shader | **동봉 LICENSE: CC BY 4.0**. 경로·폰트 지정 변경 기록과 저작자 표시 유지. PNG·shader 원본 바이트 유지. 유료 VHS UI와 별개 | 배포처 4.3–4.7 설명, 4.7.1 Compatibility에서 실행. ASCII 폰트는 제외하고 기존 한국어 폰트 유지 |
| [Retro Screen FX Lite](https://inkharbor.itch.io/retro-screen-fx-lite) | `retro-screen-fx-lite.zip`, 30,939 B. CRT/VHS shader·공통 include·LICENSE만 선택 | **동봉 별도 라이선스:** 자체 게임 내 사용·수정·배포 허용, 독립 에셋/템플릿/재사용 소스 재배포 제한. 보수적으로 원본 전부 `assets/local_only/`에 두고 Git 제외 | 배포처 4.4+ 설명, 4.7.1 Compatibility에서 실제 두 효과 실행. 화면 복사 대신 영상 전용 ViewportTexture를 입력하도록 실행 시 변환 |
| [Analog Horror SFX Free](https://heyheythere.itch.io/analog-horror-sfx-free) | `analog-horror-sfx-free-assets.zip`, 13,841,469 B. `alert_beeps`, `vhs_play`, `channel_change_01` 원본 OGG 3개 | **동봉 LICENSE: CC BY 4.0**. 파일·음량 데이터 변환 없음. 원본 라이선스·출처 유지 | Godot OGG import·길이·재생 상태 확인. 사람의 청취 평가는 미실시 |

MAUSE의 라이선스는 단일 `.tres`에 동봉된 문서가 아니라 공식 페이지 선언에 근거한다. 아트와 코드 경계가 애매한 추출분에는 MIT 고지와 CC BY 4.0 표시를 모두 보관했다. 외부 에셋의 저작권/보증을 CAP 자체 코드의 라이선스로 대체하지 않는다. 제작자가 AI 보조 제작을 명시한 VHS·Retro·SFX의 해당 사실도 보존한다. MAUSE 페이지의 NoAI 표기를 학습 허가로 해석하지 않았다.

SFX 웹 설명의 파일 크기·WAV 규격과 실제 ZIP이 달랐다. 다운로드 ZIP의 실제 WAV는 48 kHz / 24 bit이며, 선택한 OGG는 그대로 사용했다. 검토는 실제 파일과 동봉 라이선스를 우선했다.

모든 다운로드 원본 SHA-256과 공개 반입 파일별 크기·해시는 [manifest.json](../assets/third_party/m4_5/manifest.json), 출처는 [CREDITS.md](../assets/third_party/m4_5/CREDITS.md)에 있다. 일회성 다운로드 토큰·로그인 정보는 문서나 소스에 포함하지 않았다.

### 확보하지 못한 파일 / 사용자 제공 요청 목록

**RELAY Free Sample**: 작성자가 제공한 정확한 무료 배포 URL 또는 샘플 ZIP과 동봉 라이선스가 필요하다. 현재 유료 전체판이 무료 샘플과 같은 것이라고 가정하지 않았다. 현재 작업을 위해 구매가 필수인 것은 아니다.

### 제한 파일이 없는 환경

공개 복제본에는 Retro 원본이 없으므로 CRT/VHS Lite 두 메뉴 항목만 비활성화된다. 원본·MAUSE·VHS UI는 실행된다. 유료 구매나 로그인 우회가 필요하지 않다.

Retro를 로컬에서 비교하려면 공식 무료 ZIP을 받아 다음 네 파일을 직접 배치한다. 전체 addon을 활성화할 필요는 없다.

```text
assets/local_only/m4_5/retro_screen_fx_lite/
  crt.gdshader
  vhs.gdshader
  rsfx_common.gdshaderinc
  LICENSE.txt
```

이 폴더는 `.gitignore`로 제외한다. Git 제외는 실행 파일에 넣어도 된다는 배포 계약과 별개이며, 프로젝트 원본 공유 시에도 제외해야 한다. 라이선스가 변경되면 새 파일을 반입하기 전에 다시 확인한다.

## 검사와 적용 구조

작업 시작 시 Git 상태와 저장소 파일을 조사하고, 기존 파일 **265개**의 SHA-256 및 사본을 로컬 검증 폴더에 보관했다. 이전 M4 미커밋 코드와 README 수정이 이미 있었다. 이번 작업의 기준은 해당 작업 트리이며, HEAD와의 전체 diff를 이번 작업만으로 계산하지 않았다.

다운로드는 공식 무료 버튼/공개 무료 다운로드 흐름으로 확보했다. 원본을 `.godot/verification/m4_5/acquisition/downloads/`에 격리하고 ZIP 경로 탈출·링크·실행 파일·크기, 텍스트 코드와 리소스 의존성을 검사했다. Retro 42개, VHS 76개, SFX 67개 항목을 조사했다. 이는 정적 검사이며 완전한 악성코드 탐지 보증은 아니다.

두 UI 패키지의 데모/업셀 코드에 외부 URL을 여는 기능이 있어 해당 스크립트와 plugin 전체를 반입·실행하지 않았다. 외부 GDScript 실행은 **0개**이다. MAUSE 원본에는 내장 스크립트가 없음을 확인했다.

| 추가 파일/폴더 | 책임 |
|---|---|
| `scenes/playtests/m4_5_ui_comparison.tscn` | 기존 M4를 상속하는 독립 F6 비교 Scene |
| `scripts/main/m4_5_ui_comparison.gd` | 기존 Main 실행 후 비교 어댑터 설치, 기존 View 전환 후 시각 요소 갱신 |
| `scripts/presentation/ui_asset_comparison.gd` | 비교 메뉴, 하나의 합성 Theme, CCTV 영역 효과, 장식 아이콘, 명시적 효과음 재생 |
| `assets/third_party/m4_5/` | 공개 가능한 선별 리소스·라이선스·출처·해시 |
| `assets/local_only/m4_5/` | Git 제외된 Retro 검토 파일 |
| `docs/screenshots/m4_5/` | 무가공 캡처·비교 HTML·측정 JSON |

기존 파일 수정은 `.gitignore`의 제한 에셋 제외 규칙과 `docs/README.md`의 보고서 링크 한 줄뿐이다. **Main/GameShell/View 원본 코드, 기존 Scene, project.godot, README.md, export 설정 등은 시작 시점 바이트를 유지한다.** 신규 `.uid`·이미지/OGG `.import` 파일은 Godot가 생성한 리소스 메타데이터이다.

테마는 원본을 복제해 색상·StyleBox·아이콘을 선택적으로 매핑한다. Main에 활성 Theme는 항상 하나이며 프로젝트 전역 Theme는 바꾸지 않는다. 종이 문서 배경·글자색·한국어 폰트·크기와 Shell 치수를 보존한다. MAUSE/VHS의 전 패키지 기능을 이식한 것이 아니라 해당 게임에 맞춘 시안이다.

CCTV는 기존 `%FeedTexture`·`%Placeholder`를 재사용한다. Retro 선택 동안 영상만 SubViewport로 렌더하고 텍스처를 shader에 전달한다. 원본으로 돌아오면 원래 부모로 복원한다. 관찰 기록·버튼·종이 문서는 shader 대상이 아니다. Broadcast는 기존 질문/선택/미리보기/확정/잠금/결과 로직을 그대로 사용하며 장식 아이콘과 확정 송출음만 추가한다. 실제 시간·배터리·가짜 카메라 상태는 추가하지 않았다.

## 실행 및 검증 결과

Windows / Godot **4.7.1.stable.official.a13da4feb** / Compatibility / AMD Radeon RX 6800.

- 공개 기본 검사: editor import, **68개 제품 GDScript check-only**, 기존 기본 Main headless 실행 통과.
- 비교 Scene: headless **283개**, GPU **1920×1080 322개 / 1280×720 322개** 검사 통과. 최종 실행의 파싱·스크립트·엔진 오류/경고 0.
- 실제 버튼 입력으로 Profile→CCTV→실험→잘못된 격리→다음 Case 업무→Notice→Incident→다중 Broadcast→송출 확인→결과→중단 업무 복원 경로 검사.
- Theme 전환 시 View 인스턴스, canonical 소유 상태, 방송 초안·확정 잠금 유지. modal 취소는 순수 취소, 확정은 기존 소유자를 통해 처리. 저장 payload의 기존 codec 준비 검증 통과.
- 한 실행 중 1920↔1280 크기 변경, Shell 경계·내용 영역 검사 통과. 별도로 두 해상도의 Profile/CCTV/방송 질문·검토·확인 창 캡처 확인.
- 비교 메뉴를 실제 마우스 입력으로 열고 키보드로 MAUSE·VHS·원본을 선택하는 연결도 GPU 실행에서 확인.
- 효과음 기본 꺼짐, opt-in 후 3개 파일 디코딩·재생 상태와 실제 방송 확정 시 송출음 확인. 전체 오디오 버스·기존 저장 데이터 변경 없음.
- Retro가 없는 공개 복제본에서 import·비교 Scene 실행 및 제한 메뉴 비활성화 검사 통과. 별도 새 캐시 복제본도 import·실행 통과.
- 기존 265개 파일의 삭제 0. 시작 시점 대비 위 두 문서/제외 규칙 외 기존 파일 바이트 변경 없음. `git diff --check` 통과. 커밋·스테이징·push 없음.

로컬 상세 로그·검사 fixture는 `.godot/verification/m4_5/`에 있으며 Git에는 포함하지 않는다. 공개 기본 검사는 기존 `tools/verify_project.ps1`로 재현할 수 있다. 화면 경로와 비교 Scene은 공개 리소스로 직접 재현 가능하며 Retro만 위 로컬 반입이 필요하다.

### 발견한 문제와 보정

1. MAUSE 패널 기본 여백이 Shell 높이를 바꿨다 → CAP 원래 여백을 해당 StyleBox에 적용.
2. VHS 강조 배경에서 밝은 문자가 흐려졌다 → 강조 상태의 글자색을 패키지의 어두운 hover 색으로 매핑.
3. VHS 글자 그림자가 종이 문서의 한국어를 두껍게 만들었다 → Paper 변형의 그림자만 투명화.
4. VHS outline 패널은 확인 창 뒤 내용을 비췄다 → 패키지의 불투명 ScreenPanel 바탕을 사용하고 기존 콘텐츠 여백 유지.
5. Compatibility의 screen-copy 효과를 전환하면 영상 밖 캔버스가 사라지는 현상이 있었다 → 명시적 ViewportTexture 입력으로 격리. 후속 흰 영상은 shader sampler 미연결이 원인이어서 직접 연결. 최종 두 효과 모두 정상 표시.
6. 첫 공개 복제본의 최초 headless import가 메시지 없이 `0xC0000005`로 종료된 사례 1회가 있었다. 같은 복제본 재실행, 제품 기본 검사, 별도 새 캐시 복제본 import·실행은 성공했다. 재현되지 않아 엔진/환경 원인을 확정하지 않았으며 최초 실패 로그를 보존했다.

### 성능

동일 CCTV 임시 화면, 시안별 35프레임 준비 후 150프레임 측정. VSync 끔. CPU는 프레임 설정 + 측정 Viewport CPU 합, GPU는 Viewport GPU 시간 합의 중앙값(ms). 별도 영상 Viewport를 누락하지 않았다. [원시 측정값](screenshots/m4_5/measurements.json)에 프레임 P95·VRAM·draw call도 보관했다.

| 시안 | 720p CPU / GPU ms | 1080p CPU / GPU ms | 1080p draw call | 1080p VRAM MiB |
|---|---:|---:|---:|---:|
| 원본 | 0.15 / 0.16 | 0.20 / 0.25 | 225 | 26.21 |
| MAUSE | 0.16 / 0.16 | 0.19 / 0.25 | 217 | 26.12 |
| VHS UI | 0.30 / 0.21 | 0.45 / 0.34 | 528 | 26.28 |
| MAUSE + CRT | 0.17 / 0.30 | 0.25 / 0.47 | 223 | 37.59 |
| MAUSE + VHS Lite | 0.18 / 0.31 | 0.22 / 0.47 | 222 | 37.59 |

VHS UI의 텍스처 StyleBox는 draw call이 증가하고, Retro는 추가 Viewport로 약 11.4 MiB의 VRAM이 증가했다. 이 장비의 측정 렌더 시간은 작지만 전체 프레임 P95는 데스크톱 창/합성/동기화의 영향을 받아 약 8–15 ms로 변동했다. 이를 일정한 FPS 보장이나 저사양 성능 결과로 해석하지 않는다.

현재 CameraImage는 기존 임시 영상 영역이며 실제 영상·열화상 에셋이 없다. 효과의 영역 격리·shader 동작은 확인했으나 움직이는 실영상의 잔상·디테일 손실·멀미·장시간 가독성은 평가하지 못했다. 효과음도 사용자가 직접 듣고 최종 음량을 결정해야 한다.

## 디자인 장단점과 추천

| 시안 | 장점 | 단점 / 채택 전 확인 |
|---|---|---|
| 기존 Industrial | 업무 단계·기록·종이 문서가 자연스럽게 이어지고 기존 기능 검증 기반 유지 | 장식과 시각적 개성이 적음 |
| MAUSE | 단순한 흑/적 대비, 가벼운 StyleBox 구성, 상태 강조가 명확 | 항상 붉은 강조가 비상 상태와 혼동될 수 있음. 기본 검정 면적이 넓음 |
| VHS UI | camcorder 아이콘·픽셀 테두리·황색 강조가 CCTV 성격과 어울림 | 전체 업무 Shell 적용 시 다소 게임 HUD처럼 보임. 글자 대비·투명 패널 보정이 필요했고 draw call 증가 |
| CRT Lite | CCTV에 제한하면 기록 읽기를 방해하지 않고 질감을 더함 | 추가 Viewport 비용, 글자/영상 디테일 손실 가능, raw 소스 공개 제한 |
| VHS Lite | 영상의 잡음·tracking 느낌을 빠르게 비교 가능 | 어두운 임시 화면에서는 시각적 이점 판단이 제한적. 장시간 사용/실영상 검토 필요 |
| SFX Free | 짧은 경고·송출 피드백을 무료로 시험 가능 | 최종 방송의 의미·다른 소리와 구별되는지 청취 검토 필요 |

**우선 추천:** 전체 Shell은 기존 UI를 유지한 채 MAUSE를 비교 후보로 두고, VHS의 corner/rec 장식과 약한 영상 효과를 CCTV에 한정해 검토한다. 붉은색을 일반 선택과 비상에 동시에 사용할지는 별도 디자인 결정이 필요하다. 실제 영상과 사용자 청취 테스트 전에는 유료판 구매를 서두를 이유가 없다. RELAY는 무료 샘플·허용 범위를 확보한 후에만 구매 후보로 비교한다.

어느 시안도 전체 UI의 최종 디자인으로 확정하지 않았다.
