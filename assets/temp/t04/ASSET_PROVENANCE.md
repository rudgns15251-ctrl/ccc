# T04 Master — 임시 자산

사용자가 제공한 M5-B 입력 묶음의 `t04_master_reference.png`를 바이트 변경 없이 반입했다. SHA-256·크기는 [manifest.json](manifest.json)에 기록했다. 생성·편집·크롭·좌우 반전·재합성하지 않았다.

- 상태: **TEMP / DRAFT / NON-CANON / REPLACEABLE**
- 용도: `temp_t04_case.tres`의 `ProfileData.subject_texture`
- 유지: 단일 체간·흉곽·골반, 두 두부, 네 긴 상지, 두 하지, 암색의 마른 조직, 웃는 얼굴/확대 안구 얼굴, 가지형 돌기와 긴 손가락
- 245~260cm는 제공된 문서의 추정 설정이다. 이미지에는 척도가 없어 사진으로 검증하지 않았다.
- Master 원본 자체는 CCTV·실험·격리 후보·사건 사진으로 사용하지 않는다. 실제 장면 촬영본은 여전히 미제공이다.
- 교체: Godot Inspector에서 위 Texture 참조만 바꾼다. 이미지 경로·크기는 판정 로직의 입력이 아니다.

## TEMP 합성 프레임 (`generated/`, 2026-10-16 M5-B.1)

사용자 요청("임시 이미지 제작 및 사용")에 따라 승인된 두 원본만으로 합성했다. 외부 이미지·생성형 이미지 서비스는 사용하지 않았다.

- 원본: 위 T04 Master + `assets/temp/m5_a/environment/temp_environment_reference.png`(M5-A 표준 격리실, sha256 `e19991…9549`)
- 생성: [`tools/t04_temp_composite.ps1`](../../../tools/t04_temp_composite.ps1) — 테두리에 연결된 배경과 무채색 배경 조각만 제거, Master 비례·형태 무변형 축소, 흑백 CCTV 톤·노이즈·주사선, 고정 시드
- 모든 프레임에 `TEMP COMPOSITE / NOT EVIDENCE` 표기. 포즈는 Master 그대로이며 실험별 차이는 조명 처리(이동광 반점·점멸 밴딩·저조도)와 OSD 표기뿐이다. 개체 반응을 그림으로 묘사하지 않았고 판단 근거는 기존 텍스트다.
- 연결: `CCTVData.feed_texture` 1장, `ExperimentData.result_texture` 5장(실행한 실험만 표시). 열화상·격리 후보·사건 이미지는 연결하지 않았다.
- 정식 이미지가 준비되면 같은 슬롯에서 교체하고 이 합성본은 삭제해도 된다.

이 기록은 사용자 제공 자료의 프로젝트 내 사용 지시를 기록한 것이다. 별도의 공개 자산 라이선스나 제3자 권리 확인을 선언하지 않는다. 원본 입력 ZIP·추출 폴더는 그대로 보존했다.
