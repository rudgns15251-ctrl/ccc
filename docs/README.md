# 개발 문서

처음 읽는 경우 다음 순서로 살펴보세요.

1. [프로젝트 소개·실행·플레이 흐름](../README.md)
2. [코드 구조와 주요 흐름](architecture.md) — 기능별 파일과 데이터 소유권
3. [실행과 검증](verification.md) — 공개된 기본 검사와 수동 점검 방법

## 개발 방식

이 프로젝트는 기획·기능 요구사항을 바탕으로 **AI 코딩 도구를 활용해 구현, 명령행 검증, 문서 초안 작성**을 진행했습니다. 아래 보고서는 그 개발 과정의 기록입니다. 자동 검사 결과와 실제 플레이의 재미·사용성 평가는 구분합니다.

## 개발 이력

Step 보고서의 설계·코드 위치·수치는 해당 단계 작성 당시의 상태입니다. 후속 단계에서 정책이 바뀌거나 해결된 문제도 있으므로 현재 구현을 읽을 때는 위 구조 안내를 먼저 참고하세요. 원래 점검 번호와 기술 결과는 유지하고, 작업 전달에만 필요한 문구는 정리했습니다.

보고서에 참조된 `.godot/verification/` 자료는 로컬 보관 자료이며 GitHub에는 포함되지 않습니다. 공개 저장소에서 재현할 수 있는 검사 범위는 [검증 안내](verification.md)에 명시했습니다.

### UI와 업무 Navigation

- [Step64 — GameShell·임시 Industrial Theme](step64_ui_ux_structural_rebuild.md)
- [Step65 — UI 안정화·레이아웃 검증](step65_ui_ux_acceptance_and_stabilization.md)
- [Step66 — 직접 Navigation·Archive 복귀](step66_navigation_interaction_ux_rework.md)
- [Step66.1 — Utility Rail 직접 전환](step66_1_utility_rail_direct_switching.md)
- [Step70 — Profile 종이 문서 UI](step70_profile_paper_document_ui_pilot.md)

### Campaign과 사건 대응

- [Step55 — 데이터 기반 Case 순서](step55_campaign_case_sequence_foundation.md)
- [Step56 — Campaign 사건 실행 계약 설계](step56_campaign_story_event_execution_contract.md)
- [Step57 — 타입이 있는 Campaign 항목](step57_typed_campaign_entry_foundation.md)
- [Step58 — 순차 사건·출처별 대응](step58_scripted_campaign_incident_foundation.md)
- [Step59 — Campaign 사실 조회 계약 설계](step59_campaign_historical_fact_contract.md)
- [Step60 — 사실 조회·출처 수명 검증](step60_campaign_fact_query_foundation.md)
- [Step61 — Mid-Case 중단 계약 설계](step61_scripted_mid_case_interrupt_contract.md)
- [Step62 — Mid-Case 중단·업무 복원](step62_scripted_mid_case_interrupt_foundation.md)
- [Step63 — 임시 필수 사건 통합](step63_temporary_mandatory_incident_01.md)
- [Step67 — 완료 사건 이력 계약 설계](step67_scripted_terminal_fact_contract_design.md)
- [Step68 — 완료 사건 이력 보존](step68_scripted_historical_fact_preservation.md)
- [Step69 — 실제 Mid-Case 사건 연결](step69_first_authored_midcase_incident.md)

### Case 흐름과 사건 페이싱

- [Step38 — Core Loop 구조·UX 점검](step38_core_loop_audit.md)
- [Step39 — 판단 근거 콘텐츠 정비](step39_case_evidence.md)
- [Step40 — 지연 Major Incident 대응](step40_major_incident_interrupt.md)
- [Step41 — 사건 페이싱·대응 UX 점검](step41_major_incident_pacing_audit.md)
- [Step42 — 대응 콘텐츠·맥락·읽기 경계](step42_major_incident_response_read_boundary.md)
- [Step43 — 3-Case 흐름·Case 간 지연 사건](step43_cross_case_deferred_incident.md)
- [Step44 — 3-Case 페이싱·UX 점검](step44_three_case_event_pacing_audit.md)
- [Step45 — 마지막 시퀀스의 사건 정책 설계](step45_final_sequence_event_policy.md)
- [Step46 — 시퀀스 경계 상태 조회](step46_test_sequence_boundary_disposition.md)
- [Step47 — 표시 가능한 사건의 순서](step47_oldest_actionable_event_ordering.md)
- [Step48 — 연구 진행·읽기 경계 페이싱](step48_meaningful_research_pacing_gate.md)
- [Step49 — 사건 예측 가능성·Threshold 점검](step49_major_predictability_threshold_audit.md)

### 개발용 종료 기록과 상태 정리

- [Step50 — 종료 기록의 책임 계약 설계](step50_final_run_disposition_responsibility_contract.md)
- [Step51 — 메모리 종료 기록·소유권](step51_run_disposition_ownership_state.md)
- [Step52 — 개발용 종료 API·상태 준비](step52_developer_closure_integration.md)
- [Step53 — 대응 중 종료·출처 동결](step53_active_termination_and_terminal_freeze.md)
- [Step54 — 검증된 출처 정리·No-Run 경계](step54_verified_source_cleanup_no_run_boundary.md)
