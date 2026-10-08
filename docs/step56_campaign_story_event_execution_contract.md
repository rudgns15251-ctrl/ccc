# Step56 — Campaign Story/Event Execution Contract Design

2026-10-07 · **DESIGN ONLY / NOT IMPLEMENTED**.

현재 Case-only CampaignData를 Story Campaign으로 확장하기 위한 entry identity, 실행 책임, Scripted Incident 재사용, progression/history/ordering/Ending 입력 계약을 제안한다. 제품 code/Scene/Resource/schema/State 변경0. 이번 문서의 미래 타입·필드·method·상태 이름은 **설계 후보**이며 현재 존재하는 API가 아니다.

표기: **[확정]** 현재 사용자 지시 또는 실제 코드 사실. **[추천]** 다음 구현의 권장 계약이며 사용자 확정과는 다르다. **[미정]** 실제 Story/콘텐츠 또는 후속 검증이 필요한 결정.

## 1. Current Source of Truth

[확정] 현재 명시 지시→현재 기획/실행계획→실제 Repo→Step55 구현/보고서→과거 대화→AI 제안 순이다. 이 게임은 Story Campaign Game이다. 반복 Run 보상, 경제/Credit/Quota/Settlement/영구 화폐/로그라이트 Meta Progression을 전제하지 않는다. `_event_presentation_credit`는 기존 사건 표시 허용 boolean이며 경제 Credit와 무관하다.

[확정] 요청서의 Intro/Case/Mandatory/Reassessment/Final/Ending 순서는 후보다. 저장소에는 별도의 원본 게임 기획서/실행계획서가 없고 이번 첨부에도 실제 본편 줄거리가 없다. 실제 인물/사건/조직/Case04/Ending은 창작·확정하지 않는다. Step39의 과거 Case02 Outcome 설명보다 현재 .tres를 우선한다. 현재 Case02에는 Outcome이 있고 Case03은 Outcome0이다.

[확정] 허용 변경은 이 문서 및 README append뿐이다. stage/commit/push 없음. 새 Godot gameplay 검증은 실시하지 않는다. Step55의64process/9680assertion은 **과거 결과**이고 Step56의 새 결과가 아니다.

## 2. Current Repo Facts

[확정] 시작 HEAD `6e8f167f699a3a95c91fee8668ae99d03e5d4db9`, local `master`→`origin/main`, staged0. 아래 Step55 미커밋 변경을 보존한다.

```text
 M README.md
 M scenes/main/main.tscn
 M scripts/main/main.gd
?? docs/step55_campaign_case_sequence_foundation.md
?? resources/campaigns/test_campaign_01.tres
?? scripts/data/campaign_data.gd
?? scripts/data/campaign_data.gd.uid
```

[확정] 비생성131파일, 제품 GDScript44/Scene15/Resource4(Case3+Campaign1), Main2099행/111함수. project1920×1080/초기1280×720/canvas_items/GL Compatibility, configured Main `scenes/main/main.tscn`, Autoload0. 저장소 및 상위 경로에 AGENTS.md 없음. `.godot/verification/step56/baseline.json`과 `repo-inspection.json`에 현재 파일·해시·Git·함수 위치를 기록했다.

| 실제 경로 / 확인 위치 | 현재 사실 |
| --- | --- |
| `scripts/data/campaign_data.gd:1`, `resources/campaigns/test_campaign_01.tres:1` | campaign_id/display_name/Array[CaseData], TEST_CAMPAIGN_01 / Case01→02→03, null/blank/duplicate 검사 |
| `scenes/main/main.tscn:1`, `scripts/main/main.gd:46`, `:87` | Campaign 주입. _ready 검증 후 배열 duplicate, current_case/index/Runtime/6session States 초기화 |
| `scripts/main/main.gd:827`, `:900`, `:960`, `:1321` | 단일 View signal routing; next Case/hidden resolution/Archive merge/fresh Runtime handoff. Case03 no-next는 Campaign 완료가 아님 |
| `scripts/runtime/incident_response_state.gd:1` | key=JSON([source_case_id,incident_id]); ACTIVE/COMPLETED, confirmed option/result IDs, 동시에 active1개 |
| `scripts/main/main.gd:1505`, `:1542`, `:1568`, `:1662` | source Case lookup/Failure Resolution·Candidate 검증; Runtime/Case object ID·return Stage로 중단 업무 binding. Resume 뒤 matching Candidate 제거 |
| `scripts/main/main.gd:448`, `:462`, `:478`, `:1693` | Archive case_id→정확히 하나의 CaseData. normal Response Source Archive는 과거 source Case detail로 직접 진입 |
| `scripts/runtime/research_archive_state.gd:1` | case_id별 발견 authored research_entry_id와 순서만 보존; 전체 Case 결과/실험 이력 아님 |
| `scripts/runtime/working_hypothesis_state.gd:1` | Case별 hypothesis_id/text, 사용자 추론 메모. 실제 정답 authority 아님 |
| `scripts/main/main.gd:908`, `scripts/read_models/test_sequence_disposition_snapshot.gd:1` | developer read-only Snapshot. Campaign/Ending 완료 authority 아님 |
| `scripts/main/main.gd:998`, `:1204`, `:1038`, `scripts/read_models/developer_run_disposition_builder.gd:1` | developer assignment/last Case·Runtime boundary/receipt/cleanup. builder Response는 matching Failure/Candidate 전제 |
| `scripts/data/incident_data.gd`, `emergency_broadcast_data.gd`, `broadcast_option_data.gd`, `incident_result_data.gd` | 현재 authored Incident/Broadcast/option/result, ID link 중심 |
| `scenes/views/result_view.tscn`, `scripts/views/result_view.gd` | legacy Case/Monitoring summary; Campaign Ending 아님. incident_result_view/IncidentResultData는 별도 |

[확정] Campaign progress/Story flag/Ending/Story Event 실행 State·Data·Scene는 없다. size_flags는 Control layout이며 Story flag가 아니다. casualty/damage/completion_time의 structured 기록도 없다. .tres의 damage 서술은 authored 설명이며 피해 기록으로 파싱하지 않는다.

[확정] README/Step39/Step49~55, 현재 Campaign/Case/Incident Data, Main routing·handoff·no-next·interrupt/archive, Runtime/Resolution/Candidate/Response/Archive/Hypothesis/recipient/Builder/Snapshot과 설정을 조사했다. 과거 권고보다 현재 지시를 우선한다.

## 3. Campaign vs Case vs Story Event responsibilities

| 대상 | 책임 계약 | 완료/authority | 담당하지 않는 것 |
| --- | --- | --- | --- |
| [확정] CampaignData | 어떤 authored 콘텐츠가 어떤 순서로 존재하는가 | 현재 Case 배열 정의·검증만 | 진행 결과/flags/history mutation |
| [추천] progression | 현재 entry·완료 entry·허용된 다음 전환 | validated entry completion 승인 | 콘텐츠/Case 판정/전체 역사 복제 |
| [확정/추천] Case | Profile→CCTV→Experiment→Research→Containment | 실제 submission/hidden resolution과 승인된 handoff | Story 작성/모든 past event 강제 완료 |
| [추천] Story Event | 명시 sequence 항목인 서사 단계 | entry context의 명시 completion | 실패 조작/시간 기반 시작 |
| [추천] Scripted/Mandatory Incident | 정해진 시점의 Broadcast 대응 | source-bound Response 완료→entry 완료 | Candidate readiness 조작 |
| [추천] Final Incident | 마지막 대응 단계 | actual response 완료+final entry acknowledgement | Ending 분기/즉시 cleanup |
| [추천] Ending | 허용된 실제 역사로 승인된 결말 제시 | 별도 Ending 완료 acknowledgement | 결과/피해/발견을 역으로 생성 |
| [확정/추천] Horror presentation event | 시각/텍스트/음향 anomaly | presentation 자체 lifecycle | entry 완료/Outcome/history 직접 변경 |

[추천] 최소 Event 책임은 명시 acknowledgement를 갖는 문서/메시지형 서사와 기존 Incident 대응형 서사다. Reassessment는 실제 요구에 따라 어느 쪽일 수도 있다. Mandatory/Final은 trigger 위치·종료 역할이며 반드시 각각 새 enum/class여야 하는 것은 아니다. 전체 Event enum을 지금 확정하거나 빈 handler를 만들지 않는다.

[확정] Story Event와 Horror presentation을 하나의 EventData로 합치지 않는다. Story completion과 CCTV replacement/audio glitch/redaction은 별개다. 추후 Story가 cue를 요청할 수는 있지만 cue 완료가 Campaign 완료 권한을 갖지 않는다. 이번 presentation 구현0.

## 4. Campaign sequence representation alternatives

[추천] 다음은 설계 평가다. 새 Resource 타입의 Godot parser/Inspector 실행 검증은 하지 않았다. 현재 CaseData/CampaignData의 typed Resource pattern을 기반으로 한다.

| 기준 | A 공통 typed entry | B Array[Resource] 유형 검사 | C parallel kind/ID 배열 | D Case+before/after event slots |
| --- | --- | --- | --- | --- |
| type safety | typed payload+kind 일치 검증 | 모든 위치 runtime switch | join 불일치 위험 | slot과 사건 타입 별도 검증 |
| authored usability | ID/종류/참조 한 항목 | 기존 Resource 직접 연결 쉬움, occurrence 구분 약함 | 두 배열 동시 편집 | 연속 Event/Intro/Ending 복잡 |
| Godot Inspector | 공통 Array+typed 참조, 빈 필드 관리 필요 | 잘못된 Resource 유형 가능 | 위치 동기화 수동 | slot/Case 여러 편집 지점 |
| validation | entry unique/exactly-one payload/link | 유형별 검사+occurrence ID 추가 | length/index/kind/lookup join | 앞/뒤 순서·중복 trigger·anchor |
| Save identity | campaign+entry ID | wrapper 없이 definition ID만으로 부족 | stable slot ID 별도 필요 | Case 앞/뒤 anchor 외 slot ID 필요 |
| Case repeatability | occurrence 분리 가능, State migration 별도 | definition ID 충돌 | 별도 occurrence map | 재등장 Case의 slot 출처 모호 |
| Event extensibility | 실제 kind 점진 추가, 순서 하나 | types switch 증가 | resolver/discriminator 확대 | Event→Event/Final→Ending 불편 |
| migration cost | 세 wrapper+Campaign array 이관 | 초기 작음, identity 계약 추가 | resolver/serial join | 초기는 작음, mixed 확장 때 재이관 |
| Main complexity | entry dispatch/completion | 유형 분기 퍼질 위험 | ID join 책임 증가 | 두 cursor/순서 authority 위험 |
| regression risk | 중간, Case-only부터 격리 가능 | 중간, permissive 타입/identity 변경 | 높음, silent join mismatch | 초기 낮음, 이후 ordering 복잡 |

[추천] **A의 최소 변형: 공통 concrete typed wrapper `CampaignEntryData` 하나.** 추상 Base+Case/Story/Ending subclass 계층을 미리 만들지 않는다. entry_id와 실제 지원 kind에 맞는 typed payload 참조를 하나만 갖는 disjoint 계약이다. 빈/복수/mismatched payload는 startup validation failure. CaseData는 계속 read-only 정의 Resource다.

[추천] Step57은 CASE wrapper만 구현하고 CampaignData source를 `entries: Array[CampaignEntryData]`로 명시 이관한다. 기존 case_sequence와 entries 두 authored source를 병행하거나 silent fallback하지 않는다. Main.case_sequence는 기존 API 호환 **derived Case projection**으로 유지 가능. prototype3 entry는 같은 Case reference/순서, Story placeholder0.

[미정] Story/Ending payload의 실제 field/API는 책임 구현 때 확정한다. 이름은 후보이며 현재 존재하지 않는다. Step58에서 Incident content bundle 하나를 추가하는 정도가 시작점이다. 전체 Event framework 구현 승인이 아니다.

## 5. Recommended entry identity model

[추천] definition와 Campaign 내 occurrence assignment를 분리한다. campaign_id 안 entry_id는 nonempty/unique/stable이며 reorder해도 유지한다. CaseData.case_id는 definition이다. 첫 구현은 duplicate case_id를 계속 거절한다. wrapper만으로 repeated Case 지원을 주장하지 않는다.

| identity | 현재/후보 의미 | scope·계약 |
| --- | --- | --- |
| campaign_id | [확정] authored Campaign 정의 | TEST_CAMPAIGN_01, run_id 아님 |
| campaign_entry_id | [추천] 콘텐츠 한 번의 등장 | (campaign_id,entry_id), index로 생성하지 않음 |
| case_id | [확정] CaseData definition | 현재 State key; 반복 전에 assignment key 이관 |
| event_id | [추천] Event definition | 두 entry가 동일 정의 참조 가능, 완료 key로 단독 사용0 |
| incident_id | [확정] 대응 콘텐츠 ID | 현재 Case/미래 source content scope 내 unique |
| broadcast/option/result_id | [확정] actual 승인 link | bound Response scope, draft는 확정 fact 아님 |
| research_entry_id | [확정] ResearchEntryData.entry_id | 현재 case_id+entry_id discovery, 정의/발견 분리 |
| hypothesis_id | [확정] HYP_### 사용자 메모 | Case마다 counter, case_id 없이 global key 사용0 |
| developer run_instance_id | [확정] caller 기술 lifecycle | final Record/receipt key, Campaign ID 아님 |
| campaign session identity | [추천] 실행 인스턴스 scope | 현재 State 객체 scope, Save/callback의 stable session key 필요성 검토 |

[추천] runtime index는 lookup convenience만 담당한다. 반복 Case에는 Pending/Resolution/Candidate/Response/Archive/Hypothesis 모두 occurrence scope가 필요하다. Archive definition와 어느 assignment에서 발견했는지 구분하고 자동 union 정책은 실제 반복 콘텐츠 후 결정한다. 일부 State만 rekey해서 duplicate를 허용하지 않는다.

[추천] 완료는 (session,entry_id)에 한 번만 수락한다. callback은 current entry·executor·Runtime/session binding을 검사한다. .tres UID/path/get_instance_id는 Save identity가 아니다. object ID guard는 현재 프로세스 stale 참조 검사에만 사용한다.

## 6. Scripted Incident source identity problem

[확정] source_case_id는 UI label만이 아니다. key·콘텐츠 lookup·Failure·Candidate·Archive·terminal builder까지 같은 Case를 전제한다. `_try_start_major_incident`는 matching Failure Resolution/disturbed-ready Candidate/현재 연구 Stage/표시 허용/same Runtime interrupt context를 요구한다. Scripted 사건에는 Failure/source Case가 없을 수 있다.

| 대안 | 장점 | 위험/비용 | 판정 |
| --- | --- | --- | --- |
| fake Case/Failure/Candidate | 기존 함수에 끼워 맞추기 쉬움 | 거짓 역사/fairness/closure/Archive 왜곡 | [확정] 금지 |
| generalized source identity | 공통 Response/UI 재사용, provenance 명확 | State key/resolver/archive/builder 동반 이관 | [추천] 선택 |
| dedicated Campaign event source만 | entry/event provenance 명확 | parallel record이면 중복 authority | [추천] 공통 모델의 source kind로 사용 |
| standalone parallel Incident path | failure 코드 격리 | Confirm/Result/Archive/stale/terminal 이중 구현 | [추천] 초기 권장 아님 |

[추천] 공통 계약은 origin kind+source occurrence ID+definition ID. 개념 CASE_ASSIGNMENT=entry_id+case_id, CAMPAIGN_ENTRY=entry_id+event_id. 실제 enum/field명은 후속 확정. response key는 session 안(origin kind,source entry ID,incident_id). case_id에 event_id 문자열을 대신 넣는 방식 금지.

[추천] event_id만 source로 쓰면 재등장이 충돌한다. **Campaign entry occurrence**를 source로 하고 event_id는 content lookup에 쓴다. kind 없는 string namespace 합치기0.

## 7. Existing Incident/Broadcast reuse plan

[추천] 기존 leaf `IncidentData → broadcast_id → EmergencyBroadcastData.options → option.result_id → IncidentResultData`를 재사용한다. 작은 Event content scope가 이를 묶으며 CaseData를 Event container로 복제하지 않는다. scope 안 IDs unique/link를 검증하고 누락/중복/사용 불가 option은 시작 전 명시 validation failure.

[추천] 최초 bundle은 event_id+Incident Resource+해당 Broadcast/Result 집합 정도. Story effects/피해/Flags/Ending selector0. IncidentData.environmental_disturbance를 scripted 사건이 참조한다고 failure disturbance를 자동 실행하지 않는다. 환경 효과가 필요하면 별도 effect/ownership 계약이 필요하다.

| 대상 | 최소 변경 seam |
| --- | --- |
| ResponseState | one ACTIVE/confirm once/COMPLETED 재사용, generalized key 및 origin validation 필요 |
| Main lookup | Case scope/Event scope resolver의 작은 내부 seam, global Manager/registry0 |
|3 대응 View | setup(Resource)/selection/confirm/advance signals 재사용, State/cursor 직접 변경0 |
| FlowView context | SOURCE CASE/RESUME WORK Case 전용 필드 분리, 없는 interrupted Case 생성0 |
| return policy | RESUME_CASE는 원래 Runtime/Stage, ADVANCE_CAMPAIGN_ENTRY는 entry 완료 승인 |
| Archive | Event 전체 List→Detail→List→같은 Response, draft/confirmed lock 보존 |
| Snapshot/closure/builder | 현재 Case-only 조건으로 Event Response는 invalid. source별 validation 확장 별도 필요 |

[추천] confirmed option/result ID는 State truth다. 표시만으로 COMPLETED 처리0. same view/stage/source의 승인 Result 실제 제시→사용자 acknowledgement→try_complete 성공→entry completion 한번. 실패/중복은 source/cursor 보존. 현재 API가 이를 지원한다고 주장0.

[확정/추천] scripted entry Candidate 생성/소비0. Case failure 정상 완료에서만 matching Candidate 제거. 두 origin에 무조건 candidate removal 호출0. active1개, nested Response stack0.

## 8. Failure Incident vs Campaign Incident separation

| 항목 | Failure-driven | Campaign Scripted/Mandatory/Final |
| --- | --- | --- |
| trigger owner | actual Resolution→Candidate + safe checkpoint | progression current entry |
| 발생 전제 | Failure/D2~4/M1/ordering/read gate | authored entry/prerequisite validated |
| source | 과거 Case assignment | Event entry occurrence |
| content | 과거 Case Resource scope | Event scope의 기존 leaf Resource |
| 완료 후 | same current Case Runtime/Stage | entry 완료→다음 entry |
| Candidate | matching complete/remove | 기존 후보 변경/삭제0 |
| 경제/Severity | 없음 | 없음 |

[확정] Mandatory는 성공 플레이어에게도 주어지는 이야기 단계이며 failure punishment가 아니다. Scripted는 authored trigger, Mandatory는 진행 의무다. Random/idle seconds/실패 확률 trigger0. 실제 위치/선택/결과는 [미정].

## 9. Campaign transition / interruption ordering

[추천] **D: entry 종류의 명시 interruptibility + transition당 bounded arbitration**. 숫자 priority/Severity queue/시간 scheduler0. CASE는 기존 연구 checkpoint interruption, Campaign Scripted/Mandatory/Final은 NON_INTERRUPTIBLE. 일반 Story 문서의 interruptible field는 실제 요구 전 추가0.

| 후보 | 이점 | 위험 | 선택 |
| --- | --- | --- | --- |
| A 항상 Failure 먼저 | 과거 실패 침입 유지 | 새 actionable을 계속 골라 Story 지연 | bounded1회만 활용 |
| B 항상 Campaign 먼저 | Story 순서 보장 | Case checkpoint 실패 의미 축소 | 시작한 Story entry 내부 원칙 |
| C pending 전부 drain | queue가 비어 보임 | read pacing 훼손/강제 완료/긴 연쇄 | 제외 |
| D entry/boundary rule | 연구 경험과 Story 진행 제한 보장 | transition binding 필요 | 추천 |

[추천] CASE 연구 중 Step47 oldest actionable/Step48 meaningful-read/표시 허용은 유지한다. advance 요청은 interaction·confirmed submission·binding을 검사한다. 이미 active Response/Notice라면 정상 완료/닫기를 먼저 요구하고 concurrent transition0.

[추천] 유효 Case Next 요청에 transition intent를 한번 binding하고 failure offer 기회를 **최대1회** 둔다. 기존 gate로 actionable한 oldest 과거 후보 하나(Dismissable Disturbance 또는 Major)를 제시할 수 있다. gate 닫힘/후보 없음이면 prepare 진행. offer를 소비한 intent는 Resume/Archive/추가 Next로 새 offer를 반복하지 않는다. intent 중 추가 연구 opportunity/RNG/read token으로 drain하지 않는다. Resume/Dismiss 뒤 기존 Case/Runtime과 사용자 Next 확인을 유지할 수 있지만 same intent offer budget은 복구하지 않는다.

[추천] 이후 submission 재검증→hidden resolution/필요 history 보존→entry completion 수락→next entry 시작. 새 current Case Failure Candidate는 동일 transition에서 즉시 연쇄 실행0. Scripted 시작은 failure 표시 allowance와 별개이고 Story action은 read credit 충전/소비0. 기존 boolean으로 Mandatory 발동을 결정하지 않는다.

[추천] Story ACTIVE 동안 Case opportunity/candidate RNG 증분0, nested Response0. 이전 Candidate는 순서/사실 그대로 보존, 자동 success/complete/remove0. Story/Archive 행동은 failure opportunity 아님. 다음 Case의 실제 읽기 checkpoint에서 previous ready를 다루고, next Case가 없으면 unresolved terminal fact로 보존한다. Ending 전 강제 drain0.

[추천] Story starvation 방지: 유효 transition당 offer≤1 후 Story 우선권. Failure starvation 방지: next eligible Case checkpoint에서 oldest actionable 유지, Story가 후보를 삭제하지 않음. **모든 후보가 Ending 전에 반드시 화면에 표시되는 보장은 하지 않는다.** player 미완료/invalid content는 legitimate block이고 timer 강제 진행0. intent cancel/restart UI·Save 정책은 [미정], 초기 구현하지 않는다.

| scenario | 추천 동작 | authority / 보존 |
| --- | --- | --- |
| A 완료+past 없음+next Case | prepare→entry 완료→fresh Case | Resolution/history→progression, idle trigger0 |
| B 완료+old Major ready+next Case | gate 허용이면 same intent1회 대응→Resume/revalidate/Next→next Case | Failure selector/Response; 새 후보 drain0 |
| C 완료+Mandatory next | Case 준비/완료 승인→Scripted | progression, Candidate 필요0 |
| D 완료+old Major+Mandatory | gate 허용 old response≤1 후 Mandatory; gate 닫히면 Mandatory 먼저 | 후보 보존, Story 무한 지연0 |
| E Campaign Incident active+old ready | active 완료까지 보존/대기 | bound Response/progression; counter 증분0 |
| F Event 완료+next Case | once completion→fresh Case, old 후보는 next read checkpoint | completion은 failure opportunity 아님 |
| G Final 완료+Ending | Response COMPLETED→Final entry 완료→Ending 입력→제시 | history+progression, drain/cleanup0 |

[확정] 위는 미래 추천이다. 현재 product에는 transition intent/Scripted/Case entry 완료 marker가 없다. 현재 Next/Resume/Next와 D2~4/M1 변경0.

## 10. Case completion → Campaign entry advancement contract

[추천] **Confirm ≠ Case entry completion ≠ 모든 past 사고 완료.** 기본 precondition은 valid submission+successful prepare. current Case/entry/Runtime/View binding, 실제 Case Room, Pending=Runtime confirmed Room, active response/overlay 완료, 유일 authored Outcome/result 검증이 필요하다.

[추천] SUCCESS/FAILURE 모두 진행 가능한 실제 판정. FAILURE이면 matching Candidate 저장까지 prepare 성공해야 한다. same submission retry는 재판정/재추첨하지 않는 idempotent completion. prepare 실패는 entry 완료/next 시작0. 현재 prepare는 cross-State transaction이 아니므로 future retry는 이미 쓴 Resolution/pending residue를 검증해야 한다. 성공을 추측해 cursor부터 이동0.

[추천] 완료 직전 발견 Research를 merge하고 필요한 transient fact를 Runtime 해제 전에 이전한다. 모든 prepare/history acknowledgement 후 progression이 completed/current entry를 한번 전환한다. view 재생성/Archive 복귀/중복 버튼이 완료를 재수락하지 않는다. next는 검증한 실제 entry만 dispatch.

[추천] 기본 완료는 실제 판정 완료다. Outcome 없는 Pending을 UNKNOWN→SUCCESS로 바꾸거나 완료 처리0. 실제 Story가 미해결 제출 후 진행을 요구하면 별도 explicit submission-only policy/UNKNOWN history 계약을 사용자 승인 후 추가한다. Step57 prototype Case03 Outcome0/final Pending/no-next 그대로, Event/Ending 연결0.

[추천] 대기 past Candidate는 current 완료의 blocking dependency가 아니다. 수행 중 Response는 끝나야 하지만 queue 전부 drain0. 마지막 Case 존재만으로 Campaign 완료/Ending/cleanup0.

[추천] non-Incident Event는 실제 본문이 표시된 same entry에서 명시 acknowledgement를 수락할 때 완료한다. optional 자료/Back은 completion 아님. video/training은 실제 매체가 주어질 때 재생완료/skip 정책 확정. 범용 completion interpreter/framework0.

## 11. Historical facts / Case result persistence analysis

[확정] State는 Main session까지이고 disk persistence0. handoff는 Runtime을 교체하지만 session6 State는 남긴다. cleanup은 모두 reset. caller가 old Runtime을 붙잡을 수는 있어도 Main은 historical authority로 유지하지 않는다.

| 사실 후보 | 현재 source | handoff 후 / gap | 추천 |
| --- | --- | --- | --- |
| selected room | Pending/Resolution.room_id | Pending resolve 뒤 제거, Resolution 잔존 | 기존 source query, duplicate flag0 |
| containment outcome | Resolution.result | session 유지, cleanup에서 삭제 | UNKNOWN 구분, 재판정0 |
| experiments used | Runtime execution history | fresh Runtime 뒤 Main history에서 소실 | Story 필요 시 entry별 실제 승인 IDs 최소 보존 |
| condition/exposure | Runtime condition IDs/observed sources | Archive에 전체 이력 자동 저장 아님 | 필요 facts만 transfer, authored→executed 추론0 |
| Incident 예정/ready | Candidate | completion 시 제거 가능 | 실제 발생과 다른 query |
| actual 대응 | Response ACTIVE/COMPLETED/confirmed IDs | completed session 유지, exposure flags 없음 | occurred/confirmed/completed 구분, displayed UNKNOWN |
| emergency result | Response.result_id + scoped Result | ID/description, 숫자 피해 schema 아님 | 확정 ID query, text→피해 계산0 |
| authored Research 발견 | Runtime→Archive discovery IDs | merge된 것만 유지 | 미발견 전체 Research 노출0 |
| Hypothesis | Case notes | session 유지, mutable 사용자 추론 | 객관적 facts/정답 아님 |
| casualties/facility damage | structured source 없음 | authored 서술≠actual 피해 | 실제 필요 시 승인된 effect owner |
| completion time | structured 기록 없음 | wall-clock 완료 기록0 | 필요성/의미 [미정], timer 사건과 연결0 |

[추천] ResearchArchive만으로 Campaign history는 **불충분**하다. 기존 Resolution/Response를 read-only fact facade로 query하고 Runtime 교체 시 사라지는 실제 필요 정보만 최소 보존한다. progression에 Room/Outcome/Response/Research 전체를 복제하지 않는다.

[추천] 전체 CampaignHistoryState/CaseOutcomeHistory/CaseResult store를 지금 만들 근거0. Story가 실제 수행/관찰을 소비하면 작은 **Case activity history**가 그 gap만 소유한다. key=entry occurrence, value=필요 executed IDs/observed facts. 각 기존 State가 계속 truth owner이고 SUCCESS flag 이중 저장0. 실제 요구 없으면 이 State도 유예; Step59는 query/transient gap부터 판단.

[확정/추천] RunDispositionRecord는 final boundary ownership snapshot. 매 Case commit은 terminal freeze/cleanup을 반복하므로 progress store로 사용0. current Runtime만 일부 포착하며 과거 실험 이력 복원0. 책임 인수/detached record 패턴만 terminal에 재사용 가능. active Campaign query는 실제 살아 있는 State에서 한다.

## 12. Campaign flags analysis

| 대안 | 장점 | 위험 | 추천 |
| --- | --- | --- | --- |
| generic string bool | 간단 | typo/미정의/Case fact 모순/hidden coupling | 기본 구조 제외 |
| typed story facts | 의미/value/producer 명확 | 요구 없는 enum/schema 과잉 | 실제 사실에만 |
| derived existing query | 기존 truth, 중복0 | missing/UNKNOWN/visibility 처리 | Gameplay condition 기본 |
| hybrid 최소 explicit flags | query 불가능한 Story outcome만 | producer/scope/validation 필요 | 추천 |

[추천] 성공=Resolution, actual incident=Response, discovered=Archive query. CASE01_FAILED 복제0. STORY_EVENT_COMPLETED도 completed_entry_ids로 유도되면 flag0. 문서 실제 읽음도 이미 exposure가 기록되면 query. 기존으로 유도 불가한 서사 선택/권한만 explicit fact. 인물 피해/생사는 Victim/effect 계약 없이 string flag로 만들지 않는다.

[추천] bool만 요구하면 declared ID→bool로 좁히고 producer/초기값/쓰기 시점/허용 effect 검증. count/enum/ID는 해당 query 결과 타입 condition만 추가. generic Variant blackboard/임의 expression/함수 문자열 호출/scripting language0.

[추천] condition 개념=typed query kind+stable source entry/definition ID+해당 expected value. Resolution 결과/confirmed option/discovery membership/completed entry membership은 형식 예시이지 본편 조건 창작이 아니다. 최초 flat all-of/단일 condition, OR/nesting 등은 실제 요구 후. missing/UNKNOWN를 false와 혼동0: 아직 fact 미확정이면 BLOCKED/UNRESOLVED, link invalid면 developer error. Mandatory를 false로 silently skip0. 분기/optional entry 조건 absent 정책은 실제 Story 전 [미정].

## 13. Research Archive reuse

[확정] 현재 source Case detail 및 살아 있는 current CaseRuntime interrupt context를 요구한다. scripted response에는 `_on_source_archive_requested` 그대로 사용 불가. fake Case ID로 우회0.

| 후보 | 의미/위험 | 추천 |
| --- | --- | --- |
| 전체 발견 Archive | player가 확보한 자료 선택, 답 추천 없음 | 기본 |
| related_case_ids | 서사상 참조 범위, 필터가 답을 알려줄 수 있음 | content 정당화 시 optional 표시, 전체 접근 유지 |
| related_research_entry_ids | clue 연결 쉬움, 정답 shortlist/미발견 해금 위험 | 초기 기본 아님, discovery 검증 없이 노출0 |

[추천] Event source와 Archive 선택 Case는 독립. read-only List/Detail, bound Response underlying stage/draft/confirmed lock 보존. Back은 같은 Event로 복귀; cursor/flag/선택승인/Case 기회/RNG/completion token 변경0. source hint가 없어도 전체 List 정상.

[추천] mixed entry의 Case definition/occurrence mapping을 구분하고 repeated Case는 아직 거절. Event 자체 새 Research를 Case Archive에 강제 삽입0; non-Case discovery provenance는 별도. Step58 최초는 기존 Case Archive 조회만으로 제한 가능.

## 14. Mandatory Incident fairness

[확정] 모든 격리 성공 플레이어도 풀 수 있어야 한다. failure 전용 disturbance/incident/result discovery와 Hypothesis 작성은 필수 정답 조건 불가.

[추천] 실제 authoring 때 정보 목록과 **어떤 무실패 경로에서 언제 접근 가능한지**를 함께 작성한다. 앞서 접근 가능한 Profile/CCTV/기본 Experiment/독립 문서로 핵심 판단 가능. optional 정보를 읽었다고 가정0. clue가 optional experiment에만 있다면 무실패 경로에서도 재조회 가능한 기본 자료를 별도 승인하거나 접근을 보장해야 한다. 미발견 자료를 읽었다고 자동 표시0.

[추천] Archive는 실제 discovery만. 미발견 문서가 필수이면 실제 Story가 제공할 문서/설명 전달 계약과 exposure 기록이 필요하다. core clue의 availability와 actual read를 구분한다. 안 읽어서 실패는 가능하지만 성공 경로에서 애초 불가한 clue로 정답을 강제하지 않는다.

[추천] acceptance: no-failure/minimum viable research, past-failure variants, optional clue 없는 route, Archive 복귀 state, author-approved inference. history는 문구/context/피해 변형 가능하나 core solvability invariant. 실제 정답/피해/대사 [미정]. 자동 VHS/glitch0.

## 15. Final Incident boundary

[추천] 기존 content/UI/confirm/one ACTIVE를 공유하며 Campaign trigger/Ending으로 이동하는 점이 다르다. source=Event entry, Candidate 아님. Final을 forced Run End와 동일시0.

[추천] actual Response 완료→Final entry 완료→Ending 입력 확보→Ending 제시→Ending ack→Campaign terminal ownership→필요 시 verified cleanup. ACTIVE인데 Ending으로 넘기거나 COMPLETED 조작0. branch/effect/disposition/잔여 obligation 표현은 후속 승인.

[확정/추천] Step50~54 recipient/receipt/verified transfer/freeze/explicit cleanup/stale 방어는 책임 패턴으로 활용 가능하지만 **현재 API drop-in 재사용 불가**. `_developer_source_valid`는 last Case/confirmed Room/Runtime, builder는 matching Failure/Candidate를 요구한다. Ending은 CaseRuntime 없을 수 있고 Scripted Response는 Failure가 없다. generalized validation+Campaign terminal 입력 계약 선행. 대규모 Run rename 권장0.

[추천] history를 cleanup 전 확보하고 terminal owner acknowledgement 후 해제한다. 마지막 Case/Final 도달만으로 developer cleanup 자동 호출0. leftover Candidate/UNKNOWN은 unresolved fact로 남긴다. 전부 완료가 Ending 자동 전제 아님. 실제 표현/승계 owner는 [미정], silently delete0.

## 16. Ending input contract

[추천] 승인된 fact query의 detached read-only snapshot만 입력한다.

| 입력 | 근거 | 금지/unknown |
| --- | --- | --- |
| completed entries/boundary | actual progression | authored 순서를 실행했다고 추정0 |
| outcome/Room | Resolution/Pending | UNKNOWN→SUCCESS/FAILURE 조작0 |
| Incident 결과 | actual generalized Response | ready≠occurred, exposure UNKNOWN 유지 |
| Research discovery | Archive/승인된 discovery history | authored 미발견 본문·사실 전체 순회0 |
| explicit story facts | declared producer의 actual effect/choice | 임의 string 조건0 |
| 선택된 activity history | 요구 승인 후 보존한 executed/exposure | 사라진 Runtime을 definition으로 복원0 |

[추천] actual Resolution이 아직 player에게 보이지 않아도 실제 판정일 수 있다. 승인된 Ending 규칙은 이를 참조 가능하나 player-facing 정보/노출은 따로 검증한다. **hidden authored Research 존재**는 discovery 입력이 아니다. 숨겨진 clue를 해금한 척하거나 피해/경제 score/Quota/Credit를 만들어 계산0. Hypothesis를 공식 사실로 승격0.

[미정] 단일/복수 Ending, branching/대사/실패 영향/Final과 인과 모두 미정. 거대한 다중 branch framework0. Ending이 원본 State를 수정하거나 결과를 역생성0.

## 17. Save identity requirements

[확정] Save 구현0. [추천] 최소 persistent identity는 campaign_id/current campaign_entry_id/completed entry IDs와 Case/Event definition ID다. schema/content version과 실행 session scope를 검토한다. 저장 payload는 Save 단계에서 확정.

[추천] Incident continuation이면 source kind/entry/incident/broadcast/confirmed option/result/status·return policy/underlying stage가 필요하다. object ID/NodePath/.tres UID/배열 index만으로 재시작 binding을 복구할 수 없다. stable IDs로 콘텐츠를 validate한 뒤 객체를 새로 생성하고 process-local guard를 다시 binding한다.

[추천] 각 owner의 Pending/Resolution/Candidate readiness/order/discovery/notes/승인된 activity/explicit facts를 보존한다. read gate/transition intent까지 저장할지 safe checkpoint Save만 허용할지는 [미정]. current entry 삭제/link 변경은 명시 incompatible/migration이지 nearest index 이동이 아니다. index는 복원 후 convenience로 재계산.

## 18. Main responsibility / future State responsibility

| owner | authored/runtime | lifetime | owns | does not own |
| --- | --- | --- | --- | --- |
| [확정] CampaignData | authored | content lifetime | 정의/순서/reference | 진행/완료/flags |
| [추천] progression | runtime 작은 RefCounted 후보 | Campaign execution | current/completed entries/validated transition, 필요한 explicit facts | 전체 Case 결과/판정/Save serializer |
| [확정] CaseRuntimeState | runtime | current Case, interrupt 중 동일 instance | 실행/확정/관찰/조건 | 과거 Case truth |
| [확정] ContainmentResolutionState | runtime | session→미래 Campaign duration | 실제 판정/Room/Failure link | Research/피해/Story trigger |
| [확정] FailureEventCandidateState | runtime | session→미래 Campaign duration | readiness/order/unresponded obligations | Mandatory/실제 발생 확정 |
| [확정/추천] IncidentResponseState | runtime | session→미래 Campaign duration | bound active/confirmed/completed | authored content/다음 route |
| [확정] ResearchArchiveState | runtime | session→미래 Campaign duration | 발견 IDs/Case order | 정답/전체 outcome/실험 이력 |
| [확정] WorkingHypothesisState | runtime | session→미래 Campaign duration | 사용자 notes/counters | 공식 facts/Story 조건 truth |
| [확정] RunDispositionState | caller-owned runtime | Main 파괴 후 생존 가능 | final Record/receipt | active cursor/매Case 자동 commit |
| [추천] 필요한 activity history | conditional runtime 후보 | Campaign duration | Runtime 전 필요한 actual activities transfer | 기존 판정/Response/Archive 중복 |

[추천] Main은 validation→entry dispatch→executor completion request 검증→progression 승인→next route 조정. View는 completion 요청만, outcome/effect는 해당 State/executor, progression은 재판정0. dedicated 작은 State가 유일 progress owner이며 Main의 임의 Dictionary와 중복하지 않는다. Manager/Singleton이 아니다.

[추천] Step57 CASE-only migration에는 새 progress State를 필수로 만들지 않아도 된다. entry mapping은 authored projection, 기존 Case cursor 하나. **Scripted start/complete를 넣는 Step58**에서 필요하면 current_entry_id/completed_entry_ids/once-bound transition의 작은 RefCounted State를 도입한다. explicit flags는 실제 요구 전0.

[추천] entry route 외 독립 executor lifecycle/effect가 다수 생겨 validation/completion이 중복되는 구체적 시점에만 executor seam 분리. 줄 수만으로 CampaignManager/EventManager/IncidentManager 추가0. Main에 content/history/effect/Save details 하드코딩0.

## 19. Implementation sequence

| 후보 단계 | 최소 추천 | 제외 / 완료 기준 |
| --- | --- | --- |
| Step57 | concrete typed entry+CASE-only3 migration, stable entry validation/projection/mapping | Event payload/실행/Flags/Ending/Save0, duplicate Case 계속 금지. Case03 no-next·Step46~54 회귀 유지 |
| Step58 | Scripted bundle/route+generalized source/Response+필요한 작은 progression authority, 기존 View/전체 Case Archive | 실제 Story 창작0. 승인된 TEST content를 명시 fixture로만 사용. source 없는 route/confirm/once complete/Back/draft/stale/terminal 지원 범위 검증 |
| Step59 | 승인된 Story query/소실 Runtime history 최소 보존/필요 typed condition | whole CaseResult/blackboard0. Runtime 해제 전 transfer, UNKNOWN 처리/중복 truth 금지 |
| Step60 후보 | 사용자 actual Mandatory content + 무실패 정보 fairness | 위치/목적/정보/판단/결과 자료 선행, 효과/피해/분기는 별도 승인 |
| 후속 미정 | 승인된 Reassessment/Final/Ending/Save | 순서/Ending 개수 미정, 반복 Run/경제 단계 없음 |

[추천] Case03 Outcome0을 임의 바꿔 Event를 붙이지 않는다. standalone Event source/completion과 유효 handoff를 갖는 controlled clone transition 검증을 분리한다. 제품 final Pending은 그대로. builder에 새 source를 넣을 때 Case-only terminal 관찰 보존과 origin별 validation은 별도 시험. unsupported를 fake Failure로 통과시키지 않는다.

## 20. Required user Story materials

[확정] 구조 설계/Step57에는 캐릭터/대사/Ending/이미지/음향 불필요. [미정] actual content 전 rough outline, Mandatory 목적/위치/과거 정보/판단/변화 자료가 필요하다. 미정은 [미정]으로 제출 가능하며 AI가 대신 채우지 않는다.

[미정] Ending 전 단일/복수, 반영할 사실, 실패해도 끝나는지, Final과 관계가 필요하다. 지금 자료를 승인처럼 요구하며 설계 작업을 중단하지 않는다. 문서 마지막에 자료 요구를 분류했다.

## 21. Open decisions

| 분류 | 상태 |
| --- | --- |
| [확정] 보호 | DESIGN ONLY, Step55/gameplay/settings 유지, fake Case/Failure 금지, 경제0, authored≠progress |
| [추천] 구조 | shallow typed entry, definition/assignment 분리, CASE-only 우선, duplicate Case 아직 금지 |
| [추천] 실행 | source kind+occurrence, leaf/Response/UI 재사용, terminal validator gap 별도, active1개 |
| [추천] ordering | 기존 Case gate, transition offer≤1, 시작한 Scripted atomic, 후보 보존 |
| [추천] history/flags | 기존 query+필요 transient gap+최소 explicit typed facts |
| [미정] actual Story | Mandatory 내용/정확한 위치, Case04 이후, Reassessment/Final/Ending 내용·개수 |
| [미정] extensions | repeated Case/submission-only completion/피해·Facility·Victim/실제 flags |
| [미정] lifecycle/Save | Ending ack/terminal Record/obligations owner/Save checkpoint·migration·branches |

[확정] 피해→Personnel/Victim record→later Archive→Final/Ending 가능성만 반영한다. 실제 numeric 피해/인물생사/Victim State는 없다. 향후 effect owner와 narrative exposure/Archive owner를 구분하고 실제 자료 후 확정한다. IncidentResult 서술을 flag/피해로 파싱0.

## 22. Risks / P0-P3

| 등급 | 현재 / 미래 위험 | 처리 |
| --- | --- | --- |
| P0 | 문서 변경에서 신규 제품 P0 발견 없음 | byte 변경0, 전체 gameplay 재인증 주장0 |
| P1 | future Response만 rekey하면 Archive/Snapshot/Builder/return context의 Case 의존 충돌 | Step58 source별 inventory/regression, fake Case 금지 |
| P2 | 기존 Active+resolvable/same-Room residue Pending OPEN | ACTIVE_FORCE_REQUIRES_PREPARED_PENDING/error freeze 유지, 해결0 |
| P2 | Step54 cleanup는 cross-State transaction/일반 exception rollback 아님 | partial reset 가능, verified frozen/same-recipient retry 유지 |
| P2 | last Case Runtime로 Ending closure/cleanup하면 history 손실 | 입력/ownership acknowledgement 먼저, 별도 source final validator |
| P2 | drain/nested response로 Story starvation/pacing 훼손 | bounded transition/atomic entry/source ownership |
| P3 | existing Hypothesis private key enumeration/getter seam/Main 증가 | 기존 보존, 이번 getter/Manager refactor0 |
| P3 | wrapper 빈 payload UX/serialized migration | 후속 실제 Godot parser/Inspector/identity fixture 필요 |

[확정] Step56 검증은 static inspection/hash/Git 보호. 새 Godot process0/gameplay assertions0. 제품 hash 시작 대비 동일, Main2099행/111함수 유지. Step56 변경=README append1+본 문서 신규1, deleted0/staged0/HEAD·branch·upstream 유지. 기존 Step55의3modified/4new를 Step56 변경량으로 오인하지 않는다. git diff --check PASS, 최종 기록 `.godot/verification/step56/final-integrity.json`.

### 요청한130개 종료 보고 항목

| 번호 | 항목 | 결과 |
| ---: | --- | --- |
| 1 | 작업 전 Git 상태 | [확정] Step55 누적 modified3/untracked4, staged0. README/Main/Scene 및 CampaignData/.uid/.tres/Step55 보고서를 보호. |
| 2 | HEAD | [확정] 6e8f167f699a3a95c91fee8668ae99d03e5d4db9 유지. |
| 3 | branch/upstream | [확정] master→origin/main. 기존 branch/upstream 그대로. |
| 4 | 실제 CampaignData | [확정] campaign_id/display_name/case_sequence:Array[CaseData]. null/blank/empty/duplicate validation. |
| 5 | 실제 Case sequence 구조 | [확정] TEST_CAMPAIGN_01→실제 Case01→02→03. authored 배열을 Main이 shallow duplicate한 navigation projection. |
| 6 | 현재 Main routing | [확정] Main View signal→Stage routing. Case handoff는 prepare/Archive merge/+1 index/fresh Runtime/PROFILE. Case03 no-next. |
| 7 | 현재 Incident source identity | [확정] actual Failure Resolution+Candidate의 source_case_id로 CaseData 안 Incident/Broadcast/Result 조회. |
| 8 | 현재 Response identity | [확정] JSON([source_case_id,incident_id]) key. Status ACTIVE/COMPLETED, active1개. 현재 Campaign entry source 지원0. |
| 9 | 현재 Archive lookup identity | [확정] Archive는 case_id→CaseData unique lookup, discoveries=(case_id,research_entry_id). Source Archive=source Case detail. |
| 10 | 현재 historical State lifetime | [확정] Main session 동안 Resolution/completed Response/Archive/Hypothesis 잔존. Runtime은 Case별 교체, cleanup은 전체 reset. |
| 11 | CampaignData 책임 | [확정] authored 콘텐츠/순서. runtime index/결과/flags mutation 금지. |
| 12 | Campaign progression 책임 | [추천] current/completed entry 및 validated transition sole authority. 판정/history 전체 복제0. |
| 13 | Case 책임 | [확정/추천] 기존 연구/선택/격리 loop와 actual prepare. Case 완료는 전체 past 사건 처리와 별개. |
| 14 | Story Event 책임 | [추천] 명시 authored entry 실행과 source-bound completion. 실제 내용 [미정]. |
| 15 | Horror Event와 차이 | [확정/추천] Story=progression 단위; Horror=화면 anomaly. one EventData로 통합0, 이번둘다구현0. |
| 16 | Mandatory Incident 책임 | [확정/추천] 성공 플레이어도 겪는 Campaign 단계, Failure punishment/Random Candidate 아님. |
| 17 | Final Incident 책임 | [추천] same 대응 UI/승인, 완료 후 Ending route. actual Final 내용/위치 [미정]. |
| 18 | Ending 책임 | [추천] 허용된 실제 historical facts를 read-only로 읽어 승인된 결말 제시. count/branch/content [미정]. |
| 19 | sequence alternative A | [추천] A 공통 typed wrapper: identity/type validation/ordered entry 하나. concrete Resource1개, subclass hierarchy0. |
| 20 | sequence alternative B | [추천] B generic Resource: 연결은 쉬우나 runtime type switch/occurrence identity/validation 누락 위험. |
| 21 | sequence alternative C | [추천] C parallel arrays/IDs: join mismatch/lookup 부담. D side-slots는 초기 쉬우나 연속 Event/Ending/두cursor 복잡. |
| 22 | 추천 sequence model | [추천] A 최소 concrete typed CampaignEntryData wrapper. CASE부터 실제 payload1개 검증; 미래 Event subtype는 필요할 때. |
| 23 | 추천 이유 | [추천] authored entry identity+typed payload를 한 위치에서 검증하고 기존 leaf Data를 재사용할 수 있음. |
| 24 | migration cost | [추천] Step57 세 Case wrapper/Campaign array 이관. 기존 Main.case_sequence는 derived projection. two authored sources/fallback0. |
| 25 | CampaignEntry identity | [추천] campaign 내 nonempty/unique/stable entry occurrence ID. order/index/definition와 별개. |
| 26 | Case definition identity | [확정] CaseData.case_id는 콘텐츠 정의. 현재 States는 이를 assignment key처럼 쓰므로 반복 전에 rekey 필요. |
| 27 | repeated Case 문제 | [추천] wrapper 도입 후도 duplicate case_id 거절. Pending/Resolution/Candidate/Response/Archive/Hypothesis 모두 occurrence migration 전 반복 금지. |
| 28 | Save identity | [추천] campaign/entry/definition ID+schema/content version/session scope. Save 구현0. |
| 29 | generic index 사용 여부 | [추천] index는 runtime convenience만. persistent key/history authority로 단독 사용0. |
| 30 | Event ID | [추천] event_id는 Event definition, source/completion key는 그 Campaign entry occurrence. enum/name 미확정. |
| 31 | Scripted Incident source 문제 | [확정] source_case_id/Failure/Runtime guard/Archive/Builder 때문에 Case 없는 Event를 기존 함수에 그대로 연결 불가. |
| 32 | fake Case 여부 | [확정] fake Case00/fake Failure/Candidate/containment FAILURE 조작 전부금지. |
| 33 | generalized source 후보 | [추천] origin kind+source occurrence+content definition. Case assignment와 Campaign entry source를 공통 모델로 분리. |
| 34 | recommended source model | [추천] generalized source envelope에 campaign event entry를 하나의 kind로 사용. event_id-only key/parallel history 제외. |
| 35 | IncidentData 재사용 | [추천] IncidentData leaf 그대로, 별도 작은 Event scope에서 resolve. environmental_disturbance 자동 실행0. |
| 36 | Broadcast 재사용 | [추천] EmergencyBroadcastData/options/confirmed selection UI 재사용; Source binding validation은 다음 단계. |
| 37 | IncidentResult 재사용 | [추천] IncidentResultData/Result View 재사용. description≠structured 피해 effect. |
| 38 | ResponseState 재사용 | [추천] one ACTIVE/confirm once/COMPLETED 의미 유지하며 origin-aware key validation 최소 확장 필요. |
| 39 | View 재사용 | [추천]3 기존 response View 및 signals 재사용. FlowView Case-specific context/return policy seam은 수정 필요, 이번변경0. |
| 40 | Failure Candidate 사용 여부 | [확정/추천] 실제 failure-driven 경로만 Candidate 소유·완료후 matching remove. Story trigger owner 아님. |
| 41 | Scripted Candidate 여부 | [확정] Scripted Candidate 생성0. 가짜 failure readiness/Resolution0. |
| 42 | Mandatory Incident trigger | [추천] validated current Campaign entry. skip/발동 실제 위치 [미정]. |
| 43 | random trigger 여부 | [확정] Mandatory/Story는 random trigger 없음. 기존 Failure D2~4/M1은 유지. |
| 44 | real-time trigger 여부 | [확정] idle timer/random seconds Story 시작 금지. |
| 45 | Campaign trigger | [추천] 실제 sequence advancement+prerequisite validation. authored order를 runtime 실행 사실로 오인0. |
| 46 | Case completion definition | [추천] valid confirmed submission→successful prepare/history ack→once entry completion. SUCCESS/FAILURE 모두 진행 가능. |
| 47 | Pending 관계 | [추천] Pending만으로 완료0. Outcome 없는 UNKNOWN을 판정/완료로 조작0. submission-only 정책은 별도 승인 필요. |
| 48 | unresolved failure Candidate 관계 | [추천] waiting Candidate는 Case 완료의 blocking dependency 아님. 모든 사건 drain0. |
| 49 | old Major ready 관계 | [추천] transition intent당 기존 gate로 oldest actionable past offer 최대1회, 후보 잔존. new current candidate 즉시 chain0. |
| 50 | Campaign transition checkpoint | [추천] source-bound advance intent/offer budget/prepare/transfer/once completion의 safe checkpoint. 현재구현0. |
| 51 | Story Event starvation | [추천] 한 intent offer≤1 후 Campaign 우선. Archive/Resume/Next로 budget 복구0, mandatory 무한지연 방지. |
| 52 | Failure event starvation | [추천] next eligible Case checkpoint의 oldest actionable 유지. 끝까지 모든 후보 표시 보장0, Ending에서는 unresolved 사실로 보존. |
| 53 | ordering case A | [추천] A prepare→완료→fresh next Case, timer trigger0. |
| 54 | ordering case B | [추천] B gate 허용 old Major1회→normal Resume/revalidate/Next→next Case, drain0. |
| 55 | ordering case C | [추천] C Case 완료 승인→Mandatory entry. Candidate 필요0. |
| 56 | ordering case D | [추천] D gate 열림 old1회 후 Mandatory, 닫힘이면 Mandatory부터. 후보 삭제/자동완료0. |
| 57 | ordering case E | [추천] E current Campaign ACTIVE 우선, old 후보 대기/기회증분0/nested Response0. |
| 58 | ordering case F | [추천] F actual Event completion once→fresh next Case, old 후보는 next 연구 read checkpoint. |
| 59 | ordering case G | [추천] G actual Final Response completion→Final entry 완료→Ending 입력/제시. cleanup/drain 자동호출0. |
| 60 | Campaign Event interruptibility | [추천] 초기 scripted/mandatory/final NON_INTERRUPTIBLE. Case는 기존 research checkpoint. 문서 event 정책은 실제 요구 후. |
| 61 | numeric priority 여부 | [확정/추천] numeric priority framework 없음, 명시 boundary rule만. |
| 62 | Severity 여부 | [확정/추천] Severity system 없음. P0-P3는 설계 위험 보고 등급이며 gameplay Severity가 아님. |
| 63 | historical Resolution lifetime | [확정] ResolutionState는 handoff 후 session 동안 남고 source cleanup에서 reset. 미래 Campaign duration으로 소유권 유지 필요. |
| 64 | Runtime lifetime | [확정] current CaseRuntime은 fresh 교체, interrupt는 동일 instance. 과거 execution/관찰 history를 Main이 보존하지 않음. |
| 65 | completed Response lifetime | [확정] completed Response는 session 잔존, reset/cleanup에서 삭제. 별도 durable displayed flag 없음. |
| 66 | Archive lifetime | [확정] 발견 authored IDs/Case order session 유지; disk Save0, cleanup에서 reset. |
| 67 | Hypothesis lifetime | [확정] 사용자 notes/counter session 유지. clear_all은counter유지, whole reset은해제. 공식truth 아님. |
| 68 | disposition applicability | [확정/추천] final ownership record 성격. active history/per-Case commit로 남용0, boundary 인수 패턴만 후속재사용. |
| 69 | new history State 필요성 | [추천] 필요 transient activity history만. existing query로 충분한 Room/Outcome/Response/Research는 새 history 복제0. |
| 70 | CaseResult 필요성 | [추천] 전체 CaseResult 지금필요없음. casualties/damage/time structuredsource없음, actual 요구/effect contract 후 최소추가. |
| 71 | duplicate data risk | [추천] CASE_FAILED flag/whole outcome mirror/Main raw dictionary는 duplicate authority 위험. 원래owner query. |
| 72 | Campaign flags 필요성 | [추천] 모든 Gameplay flag 필요없음. existingquery로 불가능한 actual Story choice/access만 최소explicit. |
| 73 | derived facts | [추천] Resolution/Response/discovery/completed entry 쿼리. UNKNOWN/missing은 false·성공으로 조작0. |
| 74 | explicit story flags | [추천] declared typed producer/scope/default/write조건. event completed도 progress에서 유도되면 별도flag0. actualID 미정. |
| 75 | generic string flags 위험 | [추천] typo/undefined/hidden coupling/모순 위험, generic blackboard 기본 채택0. |
| 76 | condition representation | [추천] typed query kind+stable source+그query expected value, 초기단일/flat all-of. absent/invalid 진단, Mandatory silentlyskip0. |
| 77 | expression interpreter 여부 | [확정/추천] 임의 expression interpreter/scripting language/Variant blackboard0. |
| 78 | Research Archive reuse | [추천] 전체 발견 Archive 접근 기본, actual source/doc filtering과 draft/confirmed/return context 보존. |
| 79 | source Case 없는 Archive | [추천] source Case 없는 Event는 List→Detail→List→같은Response. fake Case context0, cursor/기회변경0. |
| 80 | related Case hint 여부 | [추천] 관련 Case는 콘텐츠상 정당화될때 optional 표시, 전체접근보존. 정답 shortlist/미발견 해금0. |
| 81 | Mandatory Incident fairness | [확정/추천] 핵심판단정보는 무실패경로에서 접근가능. availability≠actualread, 성공경로/optionalclue없이 검증. |
| 82 | failure-dependent essential clue 여부 | [확정] failure-dependent clue를 Mandatory 정답 필수로 쓰지않음. |
| 83 | successful-player solvability | [확정/추천] 모든격리성공 플레이어도 기본정보로 해결가능. pastFailure는 optional문구/context변형만. |
| 84 | Event completion contract | [추천] bound entry/executor의 실제 completion ack를 progression이 once승인. Back/표시만/duplicate로 완료0. |
| 85 | scripted Incident completion | [추천] IncidentResult 실제제시/확정result binding→사용자ack→Response COMPLETED→entry완료. Candidate조건없음. |
| 86 | non-Incident Event completion | [추천] 실제표시된 문서/메시지의 explicitack; video/skip은 매체요구후. genericframework0. |
| 87 | Final Incident completion | [추천] actual Response completion+Final entry ack. inactive/UNKNOWN을 완료로 꾸미지않음. |
| 88 | Ending input | [추천] completedentries/실제outcomes/confirmed response/discoveries/declared storyfacts/필요activity snapshot. |
| 89 | Ending hidden fact 접근 여부 | [추천] recorded Resolution은 승인규칙에서 참조가능, playerexposure는 별도검증. hidden authored Research는 discovery로 읽지않음. |
| 90 | Ending branch status | [미정] Ending branching UNDECIDED, 거대한모델미구현. |
| 91 | Ending count status | [미정] 단일/복수 개수 UNDECIDED. |
| 92 | final boundary | [추천] Final→Ending input/ack→terminalowner acknowledgement→필요cleanup. currentCaseend와같지않음. |
| 93 | Step50~54 future reuse | [추천] receipt/ownership/freeze/verifiedcleanup 패턴가능. currentlastCase/Failure validator 때문에 drop-in사용불가, rename권장0. |
| 94 | Save implementation 여부 | [확정] Save 구현0. stable identity/compatibility 요구만 설계. |
| 95 | stable IDs | [추천] campaign/entry/definition/response/research/note scoped IDs, session/version; objectIDs/paths 아님. |
| 96 | index persistence 여부 | [추천] index-only persistence 금지, stableentrylookup후 convenience재계산. |
| 97 | Main future responsibility | [추천] validation/dispatch/completionrequest검증/progress승인/next routing. content/history/effect/serializer소유0. |
| 98 | CampaignManager 필요 여부 | [확정/추천] 현재추가0. 구체적인 독립lifecycle책임중복시 분리검토, 줄수만으로추가0. |
| 99 | EventManager 필요 여부 | [확정/추천] 현재추가0, global EventManager/EventBus framework권장0. |
| 100 | Campaign progression State 후보 | [추천] 작은RefCounted soleprogressowner를 Scripted start/complete단계에 검토. current/completed/boundtransition만. |
| 101 | authored/runtime separation | [확정/추천] authored=what exists/order; runtime=what happened. Resource에progress쓰지않음. |
| 102 | CampaignData mutation 여부 | [확정] 이번CampaignData/.tres byte동일, schema/array/runtimemutation0. |
| 103 | product code 변경 | [확정] 제품code변경0. ignored 조사script는static보호용. |
| 104 | Scene 변경 | [확정] Scene변경0, Step55미커밋Scene까지현재bytes보존. |
| 105 | Resource 변경 | [확정] Resource변경/추가0, 기존3Case+TESTCampaign보존. |
| 106 | State 변경 | [확정] State변경/추가0, Flags/History/Progress후보미구현. |
| 107 | Main 변경 | [확정] Mainbyte동일2099행/111함수, 기존미커밋작업보존. |
| 108 | README 변경 | [확정] 기존README전체byteprefix보존, Step56설계상태짧게append. |
| 109 | report 생성 | [확정] docs/step56_campaign_story_event_execution_contract.md 신규,22필수섹션+130보고답변+자료분류. |
| 110 | Godot new run 여부 | [확정] Step56새Godot실행0, design-only/static검사. |
| 111 | previous test reuse 여부 | [확정] Step55결과는historical만, Step56검증으로재집계하지않음. |
| 112 | product hash preservation | [확정] 시작131파일중README만append, 나머지130동일SHA256. 제품Script/Scene/Resource/project/UID동일. |
| 113 | git diff --check | [확정] PASS. Step56delta와누적Step55diff분리확인. |
| 114 | staged | [확정]0, index변경없음. |
| 115 | commit/push | [확정]0, HEAD/branch/upstream보존. |
| 116 | P0 | [확정] 문서작업에서신규제품P0발견없음, runtime재인증주장0. |
| 117 | P1 | [추천] future source를Response만확장하면 Archive/Builder/guard충돌가능. 이관시P1위험이며새현재bug보고아님. |
| 118 | P2 | [확정/추천] 기존ActivePending제약/cleanuppartial한계보존. futurehistory손실/ordering위험은계약으로제한. |
| 119 | P3 | [확정/추천] 기존Hypothesiskeyenumerationseam/Main증가P3보존, typedwrapperInspector후속검증필요. |
| 120 | Step53 existing P2 | [확정] Step53 ACTIVE_FORCE_REQUIRES_PREPARED_PENDING/errorfreeze OPEN P2 유지, 해결안구현0. |
| 121 | Step54 cleanup limitation | [확정] Step54cross-Statetransaction/예외rollback아님, partialreset/frozenexplicitretry 유지. |
| 122 | fixed decisions | [확정] design-only/기존source보호/경제0/fakeCase금지/StoryvsHorror분리/실제내용미확정. |
| 123 | recommendations | [추천] typedentry/occurrence/sourcegeneralization/boundedtransition/query+minimalhistory/explicitfacts. |
| 124 | undecided items | [미정] actualMandatory위치/내용/Case04이후/Reassessment/Final/Ending수/flags/피해/Savecheckpoint. |
| 125 | Step57 recommended scope | [추천] CASE-onlytypedentryfoundation+3Case migration+validation/compatprojection. Event실행/State과잉0. |
| 126 | Step58 candidate | [추천] Scriptedbundle/source-awareResponse/Archive/onceprogress최소구현, actualStory창작0. |
| 127 | Step59 candidate | [추천] 승인Story가요구하는existingfactquery/transientgap/필요typedcondition만. |
| 128 | Story material required | [미정] actualcontent전roughoutline/Mandatory목적·위치·정보·판단·변화. Ending전개수/조건/실패/Final관계. |
| 129 | Story material not required yet | [확정] Step57구조에는캐릭터/대사/Ending문구/사진/사운드불필요. optional기획자료는별도. |
| 130 | final recommendation | [추천] Case-onlytypedentrymigration부터작게진행, actualStory확정전placeholder사건/Ending/Run경제초기화0. |

### 다음 구현에 필요한 사용자 자료

**NOT NEEDED YET** — Step57 구조 구현에는 실제 캐릭터 이름, 사건 대사, Ending 문구, 사진, 사운드가 필요하지 않다. 지금 추가 Story 자료 없이 Case-only entry migration을 준비할 수 있다.

**NEEDED BEFORE ACTUAL CONTENT** — 실제 Story 구현 전에 rough Campaign outline이 필요하다(미확정은 [미정] 허용). Mandatory Incident의 목적·발동 위치·활용할 과거 Research·플레이어 판단·결과가 바꾸는 것을 제공해야 한다. Ending 전에 단일/복수 여부·반영할 과거 사실·실패해도 끝나는지·Final Incident와의 관계가 필요하다. Case04 이후/인물 피해/Facility 변화는 사용자가 승인할 실제 내용이며 AI가 채우지 않는다.

**OPTIONAL** — 기존 기획서/실행계획서 원본, 정보 접근표, 관련 문서 목록, 원하는 분위기/화면 참고는 후속 계약을 좁히는 데 도움된다. 실제 이미지/음향/최종 디자인은 구조 구현의 prerequisite가 아니다.
