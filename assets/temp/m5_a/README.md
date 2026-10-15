# M5-A 임시 시각 자산

사용자가 직접 제공하고 CAP 프로젝트 적용 및 커밋·푸시를 요청한 PNG 원본 세 장이다. 크기 변경, 크롭, 합성 없이 반입했다. 역할·해상도·SHA-256은 [manifest.json](manifest.json)에 기록했다.

| 기준 자산 | 사용 위치 | 교체 참조 |
|---|---|---|
| Creature reference | Profile 전신 이미지 | `resources/cases/temp_m5_a_visual_case.tres` → `ProfileData.subject_texture` |
| Environment reference | Containment 공통 공간 참고 | `scenes/playtests/m5_a_visual_playtest.tscn` → `environment_reference` |
| CCTV reference | CCTV 정지 참고 이미지 | 같은 Case → `CCTVData.feed_texture` |

모두 **TEMP / REPLACEABLE**이다. 개체·공간 기준은 별개이며, 파일명·크기·외형을 게임 판정에서 읽지 않는다. 원본의 종횡비와 전체 형상을 유지한다. 제공되지 않은 실험 결과·열화상·사건 이미지는 대체 제작하지 않았다.

이 이미지의 외형은 기존 박막낭 설명과 다르다. 현재는 이미지가 들어간 UI를 평가하는 대역이며, 박막낭의 정식 외형이나 격리 정답 단서가 아니다. CCTV도 기록된 시간대의 실제 동작을 재현하는 영상이 아니다.

이 기록은 사용자의 프로젝트 내 이용 승인에 대한 기록이다. 이미지의 제3자 권리나 독립 자산으로서의 재배포 라이선스를 새로 선언하지 않는다. 프로젝트의 외부 UI·음향 라이선스와도 구분한다.
