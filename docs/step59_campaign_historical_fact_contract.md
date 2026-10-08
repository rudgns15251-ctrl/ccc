# Step59 — Campaign Historical Facts + Story Condition Contract Design

**DESIGN ONLY · CAMPAIGN HISTORICAL FACT CONTRACT · NO STORY CONTENT · NO ECONOMY / QUOTA / SETTLEMENT · NO PRODUCT GAMEPLAY CODE CHANGE**

2026-10-07. [추천] **대안 A: 기존 owner를 읽는 typed read-only query 계층**을 다음 구현 단계로 선택한다. 현재 Resolution/Response/Archive/Progress가 Campaign session 안에서 계속 살아 있으므로 같은 결과를 복사하는 CampaignHistoryState는 지금 필요하지 않다. Runtime 교체로 잃는 정보는 실제 Story 요구가 확인된 항목만 별도 보존한다. [추천] ACTIVE Scripted의 developer terminal block은 유지한다.

문서의 `[확정]`은 현재 코드 또는 사용자 지시, `[추천]`은 후속 구현 계약, `[미정]`은 실제 Story/Ending 자료가 필요한 결정이다. 제안한 type·method·path·terminal category는 설계 이름이며 현재 API/파일로 존재한다고 가정하지 않는다. 이 문서에서 새 runtime State/Condition/Flag/Save/Ending을 구현하지 않았다.

## 1. Current Repo Facts

[확정] HEAD `6e8f167f699a3a95c91fee8668ae99d03e5d4db9`, branch `master`, upstream `origin/main`, staged0. 시작 시 tracked modified7개, untracked15개가 있는 Step55~58 누적 작업이다. 실제 비생성142파일, GDScript48개, Scene15개, authored `.tres`4개. Main2239행/121함수, IncidentResponseState64행/9함수. 전체 파일 목록과 적용 지침을 조사했고 repository/상위 경로에 AGENTS.md는 발견하지 않았다.

[확정] product TEST_CAMPAIGN_01은 typed CASE01→02→03, Scripted product entry0이다. 마지막 Case03은 Outcome0/confirmed Pending/No next이며 Ending은 없다. scripted bundle와 mixed Journey는 Step58의 ignored in-memory verification fixture이다. project.godot은1920×1080 reference,1280×720 window,canvas_items,GL Compatibility,configured Main을 유지한다. Autoload 없음.

[확정] CampaignData/Entry/ScriptedIncidentData, Progress, IncidentSource/Response, Resolution/Pending, Runtime, Archive/Hypothesis, Candidate, Record/recipient/builder/Snapshot/Main, Scene/Resource/settings와 Step56~58 Report/README를 조사했다. 별도 현재 본편 기획서/실행계획서는 repo와 이번 첨부에서 확인되지 않았다. 따라서 Story/Ending 규칙을 새로 창작하지 않는다.

[확정] 기존 `CampaignHistoryState`, `CaseResultState`, `StoryFactState`, `StoryFlagState`, `ConditionData`는 없다. public developer closure/cleanup은 product의 정의 및 내부 호출만 있고 View/Scene에서 player 종료로 호출하는 경로는 없다. forced termination의 실제 Story trigger는 **프로젝트 내에서 확인되지 않음**이다. `_event_presentation_credit`는 사건 표시 gate boolean이며 경제 Credit가 아니다.

[확정] Step58의73processes/10591assertions는 이전 단계의 증거다. Step59 새 Godot 실행/파싱/GPU/게임플레이 assertion 집계로 재사용하지 않았다. 이번에는 정적 source 조사·SHA-256·Git 보호 검사만 수행한다.

## 2. Historical Truth vs Story Flag

[확정] Historical Gameplay Fact는 실제 승인된 Gameplay action/판정의 결과이고, Explicit Story Flag는 기존 Gameplay owner에서 유도할 수 없는 명시적 서사 상태다. 동일 generic Dictionary에 섞지 않는다. Resolution FAILURE를 CASE01_FAILED=true로 재저장하면 두 truth source의 drift가 생긴다.

[추천] `Resolution.result`, `Response.status/confirmed IDs`, `Archive membership`, `Progress completed IDs`에서 query 가능한 사실은 해당 owner가 canonical authority이다. authored Outcome/Option/Research가 존재한다는 사실은 실제 판정/선택/발견의 증거가 아니다. Pending은 실제 제출이며 outcome UNKNOWN과 구분한다. entry 완료도 그 Case의 모든 deferred 사고 대응 완료를 뜻하지 않는다.

[미정] 문서 열람/NPC 대화/서사 선택/route 활성화는 콘텐츠가 요구할 때만 explicit flag 후보다. 이미 실제 노출이나 entry 완료로 유도 가능하면 새 flag가 필요하지 않다. 단순 문서 방문은 이해·읽기 완료와 같지 않으므로 해당 의미/producer를 author가 정해야 한다. bool-only 여부도 아직 확정하지 않는다.

## 3. Existing State Lifetime Audit

[확정] Main._ready에서 session owners를 생성하고 `_dispatch_campaign_entry`는 current Case/Runtime를 비우거나 새 Runtime만 만든다. Case handoff는 hidden prepare→Archive merge→Progress advance→dispatch 순서다. Scripted ack는 Response complete→Progress advance→dispatch이다. 완료 Response는 session State에 남고 matching Case Candidate만 정상 응답 완료 때 제거한다.

| owner | 현재 Case 동안 | handoff /Scripted 완료 뒤 | Campaign session /terminal cleanup 전 | cleanup 후 | 향후 Save 필요 |
| --- | --- | --- | --- | --- | --- |
| ContainmentResolutionState | 승인된 room/result/incident만 monotonic 기록 | 계속 유지 | Main session까지 | records/order reset | [추천] 이미 확정된 Resolution IDs/enum 필요 |
| PendingContainmentState | confirmed submission 보관 | prepare 성공이면 제거; 미해결은 유지 | 해결/cleanup 전까지 | rooms/order reset | [추천] mid-Campaign Save면 미해결 제출 필요 |
| IncidentResponseState | ACTIVE1/confirm/complete | ACTIVE/COMPLETED IDs 계속 유지 | 모든 발생 record 유지 | records/active key reset | [추천] completed 및 active phase/confirmed IDs 필요; UI draft는 별도 정책 |
| ResearchArchiveState | 이미 merge된 발견만 보관 | handoff Research merge 후 유지 | Campaign 동안 query 가능 | discoveries/order reset | [추천] durable 발견 IDs 필요 |
| WorkingHypothesisState | 가설 자유 수정/삭제 가능 | notes/counters 유지 | Main session까지 | notes/counters reset | [미정] 메모 보존 UX에 필요, Story truth와 별개 |
| CampaignProgressState | sole cursor/completed IDs/intent | 계속 유지/완료 목록 증가 | Main session까지 | campaign ID/entry IDs/cursor/completed/intent reset | [추천] 진행 재개에 필요 |
| CaseRuntimeState | 실제 실행/관찰/선택/발견/조건 | Main이 old Runtime 참조 해제; 다음 CASE는 새 객체, Scripted는 null | 현재 CASE의 Runtime만 canonical | 현재 Runtime reset 후 null | [미정] current activity 재개에 필요; past activity는 Story 요구 때만 |
| FailureEventCandidateState | 현재/과거 실제 Failure 후보 | 계속 유지; matching response 완료면 제거 | readiness mechanism, 영구 history 아님 | candidates/order reset | [추천] mid-Campaign 재개면 현존 후보 필요, Ending truth로 승격0 |
| RunDispositionRecord/State | 명시 developer terminal에만 별도 생성/commit | Case마다 live update 아님 | caller가 recipient lifetime 관리 | recipient owned record/receipt는 남음 | [확정] 현재 Save 구현 없음; Campaign DB 대체 불가 |

[확정] old Runtime 외부 RefCounted alias가 살아 있을 수는 있으나 Main이 그 객체를 과거 history authority로 유지하지 않는다. 전체 session owners도 Main을 free하면 외부 owner가 없는 경우 소멸한다. query 계층이 alias를 잡는다고 cleanup을 막는 것은 아니다. 현재 reset은 동일 객체를 비우므로 이후 empty를 역사적 false로 해석하면 안 된다.

### Fact lifetime matrix

[확정] 아래는 현재 정상 product flow 기준이다. `K`=해당 source에 실제 known fact가 생긴 경우 유지, `미확정`=발생/승인 전 또는 미해결, `소실`=Main에서 더 이상 과거 authority 없음. `Ending 전`은 미래 owner를 유지할 경우의 추천이며 현재 Ending 구현은 없다.

| fact | current Case | Case handoff 후 | Scripted 완료 후 | later Case | Ending 직전 | developer cleanup 후 |
| --- | --- | --- | --- | --- | --- | --- |
| 과거 SUCCESS/FAILURE +room | Resolution 승인 후 K | K | K | K | [추천] K 유지 | 소실 |
| 현재 Pending room /outcome | room K,outcome 미확정 | 성공 prepare 후 Resolution으로 이전; 미해결은 Pending | 기존 미해결 있으면 그대로 | 해결 전 Pending | [추천] unresolved 명시 | 소실 |
| 과거 executed experiments/조건 노출 | current Runtime K | 소실 | 소실 | 소실 | [미정] 필요 IDs만 capture해야 함 | 소실 |
| 실제 normal Case Response 발생/선택/완료 | Response phase별 K | K | K | K | [추천] K 유지 | 소실 |
| Scripted Response 선택/완료 | Scripted active 전 미확정 | 이후 Scripted 발생 시 기록 | COMPLETED K | K | [추천] K 유지 | 소실; 현재 Case recipient에 누락 |
| 발견 Research | current Runtime 또는 이미 Archive | merge된 ID K | Archive K | Archive K | [추천] Archive K 유지 | 소실 |
| 자유 Hypothesis | mutable note | notes 유지 | notes 유지 | notes 유지 | [미정] 별도 UX 자료 | 소실 |
| completed entry IDs | 완료 전 미확정/현재 false | accepted handoff 때 추가 | accepted ack 때 추가 | K | [추천] K 유지 | 소실 |
| Candidate readiness | 해당 시점 mechanic | 남거나 정상 완료 시 제거 | 기존 후보 변화0 | 상황에 따라 변화/제거 | [미정] unresolved 의미만 검토 | 소실 |
| 실제 피해/사망/시설 손상/explicit flags | canonical owner 없음 | 없음 | 없음 | 없음 | 미지원/미정 | 없음 |

## 4. Fact Ownership Matrix

| fact | current authoritative owner | future Story query source | copy 필요? /이유 |
| --- | --- | --- | --- |
| Campaign entry completed | Progress completed IDs | Campaign-scoped query→Progress | [추천] 없음. 결과나 성공 여부를 복제하지 않음 |
| Case SUCCESS/FAILURE | Resolution.get_resolution(case_id) | entry→unique Case mapping→Resolution | [추천] 없음. Pending/Runtime Monitoring/authoring 결과로 대체0 |
| selected Room | resolved이면 Resolution.room_id; unresolved이면 Pending confirmed room; current Runtime agreement | phase를 붙여 조회 | [추천] session 유지 동안 없음. 선택 확정≠판정 확정 |
| executed Experiment | current Runtime execution IDs/조건 노출 IDs | current 전용 query; past는 현재 미지원 | [미정] Story가 필요하면 Runtime retirement 직전 필요한 IDs만 |
| actual Case Failure Incident | Response record 시작/phase; Candidate는 예정/readiness | CASE origin+entry+incident의 Response | [추천] 없음. 실패 판정/후보 등록만으로 실제 Major 발생 추측0 |
| Case Response option/result | source-aware Response confirmed IDs/status | occurrence query→Response | [추천] 없음. legacy DEBUG_RUNTIME selection은 normal Campaign history로 자동 승격0 |
| Scripted Response option/result | CAMPAIGN_ENTRY Response confirmed IDs/status | occurrence query→Response | [추천] 없음. COMPLETED와 active link 구분 |
| Research discovery | current Runtime discovery와 merge된 Archive | completed source는 Archive; current는 Runtime/Archive union read | [추천] 별도 중복 history 없음 |
| Hypothesis | WorkingHypothesisState | 메모 읽기 표면, canonical condition 밖 | [확정] Story fact copy0 |
| explicit Story flag | 현재 없음 | 실제 flag producer가 생긴 뒤 별도 typed declared State | [미정] owner/값/초기값/쓰기 시점이 승인돼야 함 |
| Candidate phase | FailureEventCandidateState | live diagnostics 및 실제 unresolved 여부의 제한 query | [추천] exact readiness/D/M/credit를 Ending condition으로 노출하지 않음 |

## 5. History Architecture Alternatives

[추천] 아래 이름으로 비교한다. 프롬프트의 초기 후보 C/D와 마지막 matrix의 C/D 배열 순서가 달라서 문자보다 대안 이름을 기준으로 판단했다.

| 평가 | A 기존 owners query | B small CampaignHistoryState | C Progress에 history 추가 | D separate Case/Event history |
| --- | --- | --- | --- | --- |
| truth /duplication | 기존 truth1개, copy0 | owner와 copy의 동시 authority 위험; retirement transfer면 해결 | completion과 outcome의 이중 truth 위험 | source 및 history가 늘고 drift 위험 |
| lifetime | 현재 session 동안 충분; transient gap 명시 | owner retirement 이후 필요한 fact만 유지 가능 | Progress reset에 history도 사라짐 | 각각 lifetime/cleanup 일치 필요 |
| cleanup | Ending 전에 금지 또는 detached final input 먼저 | history 자체 cleanup 분리 필요; 자동 생존 아님 | 기존 cleanup이 같이 삭제 | 두 source receipt/cleanup 책임 증가 |
| Story query | 작은 typed facade로 한 entry identity 모델 | lookup 단순, capture 정확성 필요 | surface 단순하지만 큰 책임 | caller가 두 query를 조합 |
| Ending | 살아 있는 owners→필요 immutable-ish projection | 좁은 historical input에 적합 | cursor owner에 Ending 결합 | 합성 read model 별도 필요 |
| Save | 기존 source serialization을 설계해야 함 | 작은 historical IDs는 저장 쉬우나 active state를 대체 못함 | 큰 mixed schema/versioning 비용 | 두 schema/migration 필요 |
| repeated Event | 현재 source_entry_id로 가능 | occurrence key면 가능 | occurrence key 요구 | Event State key occurrence 필요 |
| repeated Case future | owner Case-ID migration 선행 필요 | entry key여도 기존 owner가 지원해야 함 | history key 변경만으로 해결 불가 | Case State key/mapping migration 필요 |
| Main complexity | bind/context 갱신/invalidating만 | verified capture/once/retry orchestration 추가 | Progress에 outcome 작성이 추가 | capture/update/cleanup 두 배 |
| implementation cost | 현재 가장 작음 | 지금은 중복 capture 비용, 필요가 생기면 정당화 | 책임 분리 후 재이행 비용 큼 | 현재 규모에 불필요 |
| 추천 | **현재 선택** | owner 소실+실제 소비자 필요 때만 | 제외 | 현재 제외 |

## 6. Recommended Ownership Model

[추천] A를 선택한다. 미래 `CampaignFactQueries`라는 작은 RefCounted read model은 **query adapter**이지 새 mutable truth State/Manager가 아니다. CampaignData와 검증된 동일 session owners에 bind하고 entry ID를 scope에 맞는 State key로 해석한다. Main은 construction/dispatch/cleanup invalidation만 orchestration하며 History Dictionary를 저장하지 않는다. Story/Ending이 Main private fields를 탐색하지 않는다.

[확정] 현재 Main/session은 단일 Campaign이다. Response/Resolution/Archive row에는 campaign_id가 모두 직접 들어 있는 것은 아니며 State의 allocation scope로 암묵적으로 구분한다. [추천] adapter는 campaign_id와 source lifecycle을 명시적으로 bind하고 다른 Campaign에 같은 State set을 재사용/rebind하지 않는다. source release/cleanup 뒤에는 query result가 SOURCE_RELEASED여야 하며 empty=false로 반환하지 않는다. 이것은 후속 구현 요건이고 현재 facade/invalidation API는 없다.

[추천] Runtime 정보가 필요한 query는 Main이 dispatch 때 현재 entry/Runtime context를 교체해 주고 adapter는 old Runtime를 역사적 store로 잡아 두지 않는다. current Research query는 verified current entry의 Runtime discovery와 Archive를 읽어 union하며 State를 write/merge하지 않는다. past query는 Archive만 읽는다.

[추천] 별도 History State가 필요한 충분조건은 **원 owner가 사라진다 + 이후 승인된 Story/Ending/내보내기 소비자가 그 fact를 필요로 한다**이다. 단순 Save가 예정됐다는 이유로 live owner를 모두 복사하지 않는다. 필요해지면 B의 small record만 추가하거나 해당 owner의 lifetime를 Campaign으로 연장하는 비용을 다시 비교한다. 두 저장소가 동시에 독립 truth로 쓰이지 않게 live→retired authority 전환을 명시한다.

[추천] 조건부 B 최소 record 후보(구현0): CaseResolutionRecord는 campaign_id/entry_id/case_id/실제 resolution status/room_id와 FAILURE의 source incident_id만; ResponseCompletionRecord는 campaign_id/origin_kind/entry_id/definition_id/incident_id/broadcast_id/confirmed_option_id/result_id/COMPLETED만. 이미 살아 있는 Resolution/Response를 위해 이 copy를 지금 추가하지 않는다. transient CaseActivityRecord는 실제 필요 executed IDs/observation IDs만 별도로, 전체 Runtime dump/CaseResultData.tres/피해/시간/Research/가설 copy0.

## 7. Case Historical Contract

[확정] SUCCESS/FAILURE의 authority는 hidden Resolution의 실제 승인이다. `_try_resolve_pending_without_handoff`가 valid Room에 유일 Outcome을 확인하고 Resolution을 기록하며, FAILURE이면 Candidate 삽입까지 prepare 성공이 필요하다. Resolution은 기록됐지만 Candidate 추가가 실패하면 Pending도 남는 기존 부분 실패 seam이 있다. Progress 완료를 outcome의 대체 증거로 사용하지 않는다.

[추천] Case query key는 bound campaign_id+entry_id, Case ID는 definition validation 값이다. 현재 unique Case-ID 제한 안에서 entry→case_id mapping 후 existing getter를 사용한다. record의 room이 실제 scope Room인지와 Pending/Runtime/Resolution의 충돌을 확인한다. 같은 Room residue라도 historical outcome이 이미 있으면 다시 판정하지 않고 lifecycle preparation issue로 구분한다. authoring Outcome을 query 시 계산해서 outcome을 만들어내지 않는다.

[추천] Query 결과는 SUCCESS/FAILURE 또는 UNKNOWN 이유를 가진다. 유효 Pending은 selected Room known이면서 Resolution UNKNOWN일 수 있다. Case03 Outcome0는 UNKNOWN/MISSING_OUTCOME이지 SUCCESS/FAILURE가 아니다. confirmed room과 resolution 여부를 분리한다. 기존 Monitoring playback 결과는 debug/runtime display일 수 있어 canonical historical Resolution로 사용하지 않는다.

[미정] 과거 Experiment X 수행 여부가 실제 Story를 바꾸는 요구는 확인되지 않았다. 따라서 모든 execution history를 복사하지 않는다. 필요한 경우 actual try_record_experiment_execution 승인 IDs만 Runtime retirement 전에 capture하고, available_experiments/discovered Research로 executed를 역추정하지 않는다. 노출된 condition도 당시 실제 IDs만 저장한다.

[추천] B가 필요해질 경우 `record_case_resolution(verified_record)` 같은 typed one-time API를 사용한다. 승인된 Resolution을 source owner에서 읽는 것만 허용하고 같은 occurrence+동일 payload는 ALREADY_RECORDED, 다른 payload는 CONFLICT이며 최초 기록을 보존한다. Resolution 이후 prepare/entry completion 실패는 outcome 자체와 progression 실패를 구분한다. generic set_fact나 후속 callback에 의한 overwrite0. handoff가 history transfer를 필요로 한다면 transfer acknowledgement 전에 old source retirement/entry advance를 하면 안 된다.

## 8. Scripted Incident Historical Contract

[확정] Response State의 origin/source_entry_id/source_definition_id/incident_id/broadcast_id/confirmed_option_id/incident_result_id/status로 현재 이후 Story의 완료 선택 query에 필요한 작은 핵심값이 있다. 실제 normal flow에서 Main이 source/option/result linkage를 검증해 Confirm하고, 동일 Result View의 acknowledgement에서 try_complete 후 Progress 완료를 수락한다.

[추천] CASE와 CAMPAIGN_ENTRY를 공통 Response query 모델로 읽는다. bound CampaignData의 **지정된 과거 entry**를 조회해 origin/definition을 유도하고 canonical tuple로 record를 찾는다. Main._bound_scripted_entry는 현재 active entry 전용이므로 historical resolver로 재사용하지 않는다. event_id만 query하거나 현재 active Response를 모든 Event의 결과로 사용하는 것은 금지한다. 같은 Event definition을 두 entry가 쓰면 각각 option/result를 구분한다.

| 단계 | 확인된 사실 | historical completion/Story 결과 조건 |
| --- | --- | --- |
| 로컬 draft | 아직 State confirmation 없음 | [확정] confirmed/completed로 기록0 |
| ACTIVE, confirmed | 실제 approved option/result link는 K | [추천] 진단 query에 phase=ACTIVE_CONFIRMED; completed 결과 조건은 아직 UNKNOWN/DEFERRED |
| Result View 표시 | 승인된 Result Resource를 현재 View에 설정 | [확정] 독립 persistent drawn/read/result_displayed field 없음. 사람의 이해/눈으로 읽음을 주장0 |
| 실제 Result ack→COMPLETED | State COMPLETED와 승인 IDs | [추천] 완료 선택/result의 canonical historical fact |
| Scripted entry completed | Progress completed ID | [추천] Scripted COMPLETED record와 일치 검사. ID alone에서 option 추측0 |

[추천] 이미 record에 완료 IDs가 있으므로 새로운 copy/capture hook은 A에서 필요 없다. typed `get_confirmed_option`/`get_incident_result`는 phase를 반환하고 Story의 completed 결과 조건은 COMPLETED만 수락한다. State의 저수준 try_complete는 화면을 검증하지 않으므로 product Main의 승인 경로와 외부 developer fixture를 혼동하지 않는다. completion으로 사람의 실제 읽기/감정/피해를 추측하지 않는다.

[추천] B가 필요하면 `record_scripted_response_completion(verified_record)`는 actual COMPLETED 이후, next dispatch 전에 once capture한다. record+Progress completed entry 불일치/confirmed link 누락은 INVALID_SOURCE이며 completion을 위조해서 보충하지 않는다. 동일 occurrence replay callback은 duplicate0, 다른 payload overwrite0. Case Failure도 같은 response completion record 형식을 사용할 수 있으나 해당 Case entry는 사고가 나중에 완료될 때 이미 completed일 수 있다.

## 9. Research / Hypothesis Contract

[확정] Archive에는 실제 merge된 authored discovery IDs만 있고 outcome/response choice/모든 실행 이력이 없다. current Runtime에서만 발견된 ID는 handoff/기존 Result merge 또는 Case Response discovery merge 전까지 Archive에 없을 수 있다. 따라서 Archive absence가 곧 current Case 미발견을 뜻하지 않는다.

[추천] 과거/completed Case discovery는 Archive.has_discovered_entry(case_id,research_id)를 query한다. current entry는 Runtime discovery와 Archive의 read-only union을 사용하고 query가 merge/unlock/credit/opportunity를 만들지 않는다. IDs가 유효하지만 아직 안 본 것은 KNOWN(false,as-of-now); source 소실/지원 없는 provenance/invalid ID는 false가 아니다. source material의 authored 존재 여부와 발견 여부를 분리한다. Scripted 자체 non-Case Research provenance는 현재 없으며 fake Case ID로 Archive에 넣지 않는다.

[확정] Hypothesis는 플레이어 자유 메모이고 객관적 정답/실제 발견/선택/Story flag의 증거가 아니다. [추천] Ending의 canonical truth query에서 제외한다. player에게 메모를 보여주는 UX snapshot과 사실 조건은 별도다. [미정] 메모 저장·Ending 화면 표시 여부는 사용자의 UX 요구가 필요하며 텍스트를 자동 분석해 route를 정하지 않는다.

## 10. Typed Query Surface

[추천] 다음 signature/type들은 **후속 설계 제안이며 현재 repo에 존재하지 않는다**. adapter는 한 campaign_id와 검증된 owner lifetime에 bind한다. 외부 함수는 readonly/detached result만 반환한다. 구현 경로 후보 `scripts/read_models/campaign_fact_queries.gd`도 이번에 생성하지 않았다. 새 State/Autoload/Manager/EventBus 없음.

| 제안 signature | return 후보 | authoritative source /의미 |
| --- | --- | --- |
| was_entry_completed(entry_id: String) | BooleanFactQuery | Progress completed membership, cursor 위치로 추측0 |
| get_case_resolution(entry_id: String) | CaseResolutionQuery | CASE mapping→Resolution; UNKNOWN와 result enum 분리 |
| get_case_room(entry_id: String) | IdentifierFactQuery | Resolution.room 또는 Pending room; phase=RESOLVED/SUBMITTED, current Runtime와 agreement |
| was_response_completed(entry_id: String,incident_id: String) | BooleanFactQuery | 두 origin 공통 canonical tuple; status==COMPLETED만 |
| get_confirmed_option(entry_id: String,incident_id: String) | IdentifierFactQuery | approved confirmed_option_id와 phase |
| get_incident_result(entry_id: String,incident_id: String) | IdentifierFactQuery | approved incident_result_id와 phase; result display와 동일시0 |
| was_research_discovered(case_id: String,research_id: String) | BooleanFactQuery | 프롬프트 호환 이름. 현재 unique Case→entry mapping 검증 뒤 Archive/current Runtime union |
| was_entry_research_discovered(case_entry_id: String,research_id: String) | BooleanFactQuery | [추천] 장기 선호 occurrence 명시 API. future repeated Case migration 전에 필요 |

[추천] getter type3개는 작은 value result 후보다. BooleanFactQuery는 bool, IdentifierFactQuery는 stable ID, CaseResolutionQuery는 SUCCESS/FAILURE enum과 resolution phase를 가진다. 공통 metadata는 availability/reason/campaign_id/source entry/definition/phase만, Resource/Node/Callable/full State dump는 없다. GDScript generic 문법이나 실제 새 enum/class가 구현됐다고 가정하지 않는다.

[추천] Availability 의미: KNOWN(실제 확인된 값), UNKNOWN(미확정/필요 history 미보존), INVALID(없는 ID/범위·link·source 충돌), UNSUPPORTED(정의하지 않은 provenance/질의), SOURCE_RELEASED(정리된 owner). 구현 때 필요한 최소 형태로 표현하되 unknown에 value=false나 SUCCESS를 넣지 않는다.

[추천] 유효 ID와 살아 있는 완전한 source에서 **현재까지 실제 action이 없음**이 확인되면 `was_entry_completed/was_response_completed/was_research_discovered`는 KNOWN(false)+phase NOT_STARTED/NOT_COMPLETED/NOT_DISCOVERED를 반환할 수 있다. 이는 미래에도 영원히 안 일어난다는 의미가 아니다. 미확정 resolution/option, reset 후 absence, 보존하지 않은 과거 실험, 누락된 link는 UNKNOWN/INVALID/RELEASED이며 false가 아니다. 별도 `get_*`가 미확정인 값에 빈 ID를 성공 결과로 주지 않는다.

[추천] adapter는 조건 조회 과정에서 try_resolve/try_confirm/try_complete/merge/reset/RNG/credit/opportunity를 호출하지 않는다. 반환된 value를 바꿔도 source가 바뀌지 않아야 한다. 현재 lifecycle covers which Campaign인지 알 수 없는 State injection은 유효 binding으로 받지 않는다. cleanup 이후 비워진 동일 State를 새 Campaign의 이전 truth로 사용하지 않는다.

## 11. Future Story Condition Contract

[추천] 최초 authored 조건이 정해진 뒤 필요한 단일 종류 또는 flat all-of만 구현한다. 아래는 조회 구조 후보이며 실제 Story 분기·정답·대사·flag ID·ConditionData enum은 생성하지 않는다. `evaluate("...")` interpreter, arbitrary Callable/expression, generic string→Variant blackboard는 제외한다.

| 구조 후보 | existing query | copy history? | explicit flag? | 현재 지원/설계 |
| --- | --- | --- | --- | --- |
| ENTRY_COMPLETED | Progress membership | 없음 | 없음 | [확정] owner 있음, typed facade 미구현 |
| CASE_RESOLUTION | Resolution outcome | 없음 | 없음 | [추천] KNOWN outcome만 MATCH/NO_MATCH |
| CASE_ROOM | phase-aware room query | 없음 | 없음 | [추천] SUBMITTED 허용 조건과 resolved 조건을 구분 |
| RESPONSE_COMPLETED | common origin tuple/status | 없음 | 없음 | [추천] 실제 completed status만 |
| RESPONSE_OPTION /RESULT | confirmed ID+COMPLETED phase | 없음 | 없음 | [추천] completed 결과 condition 기본; draft/active link를 final로 수락0 |
| RESEARCH_DISCOVERED | Archive/current Runtime query | 없음 | 없음 | [추천] actual discovery only |
| 과거 Experiment 실행 | 현재 Runtime만 있음 | 실제 요구 때 minimal IDs | 없음 | [확정] past query 지금 미지원 |
| EXPLICIT_STORY_FLAG | 현재 owner 없음 | Gameplay 복제0 | 실제 author-approved flag | [미정] 의미·producer·initial value·primitive type |
| Hypothesis 텍스트 | 메모 API는 존재 | 없음 | 자동 flag0 | [추천] canonical 조건 미지원 |
| exact Candidate readiness /D·M /credit | mechanic owner는 있음 | 없음 | 없음 | [추천] hidden mechanic 직접 Story/Ending 조건에서 제외 |
| 피해/사망/시설 상태 | canonical source 없음 | 만들지 않음 | 위장 flag0 | [확정] 미지원; 서술을 숫자/사실로 변환0 |

[추천] condition evaluation은 known comparison에 MATCH/NO_MATCH, 미확정에 DEFERRED, link/scope 오류에 INVALID, 지원 없는 query에 UNSUPPORTED를 구분한다. 필수 entry를 UNKNOWN 때문에 false로 silent skip하지 않는다. 아직 진행하지 않은 source의 negative completion predicate로 미래 Story를 조기 발동하지 않도록 authored checkpoint/prerequisite도 명시해야 한다. 조건 만족 시 언제 entry를 제시할지는 historical query와 별도 progression 계약이다.

[미정] 어떤 과거 Case 결과/Option/Research가 어떤 Story·Mandatory·Ending을 바꾸는지, NOT/OR/중첩 조건/조건이 영원히 미확정일 때의 처리, flags의 bool/count/enum/ID 타입은 실제 자료가 필요하다. 첫 요구 전 future enum/FlagState를 선구현하지 않는다.

## 12. CampaignProgressState Boundary

[확정] cursor/completed entry IDs/transition intent/bounded offer budget을 소유한다. completion은 **진행 수락 사실**이며 outcome/room/choice/research 사실은 각 owner에 있다. CASE FAILURE도 entry는 완료될 수 있고, delayed Response는 이후 Case에서 완료될 수 있다. developer prepare가 Resolution을 만들더라도 Progress entry 완료를 자동 생성하는 경로는 아니다.

[추천] Progress에 full Case result, Response history, Research, Hypothesis, Save metadata를 넣지 않는다. query adapter는 Progress membership만 읽고 outcome은 source owner를 읽는다. completion와 outcome을 함께 보고 싶으면 detached read model에서 합성한다. Main의 getter `_case_index`는 derived CASE ordinal이고 historical key나 별도 cursor로 저장하지 않는다.

## 13. Terminal / RunDisposition Relationship

[확정] RunDispositionRecord는 detached primitive terminal payload이고 RunDispositionState는 caller-owned immutable-ish recipient/receipt authority이다. live Campaign database, Case마다 save/commit하는 storage가 아니다. 현재 envelope6필드와 source_case_definition_id/source_case_instance_id 중심 entry validation, Case historical_facts/obligations/discoveries/hypotheses를 사용한다. source_case_instance_id는 developer가 설정한 논리 assignment ID이며 Campaign entry_id나 Godot object ID와 동일하다고 가정하지 않는다.

[확정] Main._developer_source_facts와 Snapshot은 `_case_response_records`로 CASE만 전달하고 builder는 직접 non-Case response를 받으면 UNSUPPORTED_CAMPAIGN_RESPONSE_HISTORY다. Scripted COMPLETED는 session에는 남지만 현재 terminal recipient에 보존되지 않는다. 기존 completed Case response에도 result_displayed=UNKNOWN projection이 있고 실제 눈으로 읽음을 기록하는 schema는 없다.

[추천] **live facts/query→필요한 detached final projection→recipient commit→cleanup** 순서로 분리한다. RunDispositionRecord 안에 먼저 facts를 넣고 매번 역조회하지 않는다. 모든 Case/Scripted/Archive/Progress를 거대한 generic dump에 넣는 것 대신 Ending 소비자에 필요한 작은 typed projection만 만든다. 현재 developer API를 그대로 Campaign final snapshot builder로 호출하지 않는다.

### Terminal matrix

| source 상태 | 현재 disposition/cleanup | Campaign/Story 계약 |
| --- | --- | --- |
| CASE entry completed/Resolution known | [확정] 기존 Case-oriented final boundary에서 resolution historical fact; 언제든 mid-Campaign commit 가능한 API가 아님 | [추천] live Resolution query. 모든 delayed Response 완료로 추측0 |
| CASE unresolved Pending | [확정] Case03 Outcome0는 unresolved submission/UNKNOWN; valid developer prepare 외에 판정 위조0 | [미정] 실제 Ending에서 의미. 선택 Room은 known/outcome unknown |
| CASE active failure Response | [확정] voluntary는 response-only waiting,forced는 기존 interrupted obligation/freeze 정책; 기존 P2 제한 있음 | [추천] 실제 source-aware response query; chapter 종료와 혼동0 |
| SCRIPTED completed | [확정] State COMPLETED+Progress marker. 다음 CASE의 기존 closure에는 통합 누락 | [추천] future historical fact projection, obligation으로 분류0 |
| SCRIPTED active | [확정] UNSUPPORTED_ACTIVE_CAMPAIGN_RESPONSE block, recipient/freeze mutation0 | [추천] 현재 유지. draft/confirmed/완료 phase 구분 |
| Campaign final /Ending | [확정] player trigger/Ending/새 final kind 없음. developer final Case boundary≠Campaign final | [추천] author-approved final prerequisite 후 필요한 input snapshot을 먼저 생성; 그전 cleanup0 |

[확정] `_developer_source_valid`와 TestSequence snapshot의 끝 판정은 CASE-only projection의 마지막 Case 중심이다. mixed Campaign에서 마지막 CASE 뒤에 Scripted entry가 있을 가능성을 완전한 Campaign final 판정으로 처리하는 계약은 없다. Stage.RESULT/No next/Case03 확인만으로 Ending을 실행하지 않는다.

### Scripted completed terminal projection 후보

[추천] 후속 terminal/export 요구가 생기면 `historical_facts`의 **COMPLETED_SCRIPTED_RESPONSE_FACT** 후보로 분류한다. stable key는 campaign_id+origin_kind+source_entry_id+incident_id, definition/event_id는 검증값이다. actual payload는 broadcast_id/confirmed_option_id/incident_result_id/status=COMPLETED이며 fake Case assignment/FAILURE/result=SUCCESS/새 obligation을 만들지 않는다. Case-origin completed response도 origin을 가진 동일 response 사실 모델로 조회하되 기존 developer Case record 호환을 별도로 정의해야 한다.

[확정] 위 row는 현재 RunDispositionState의 Case identity/domain/허용 field 검증에 통과하지 않는다. [추천] 이 projection을 실제 recipient로 받으려면 builder→Record/schema validation→recipient identity/duplicate rules→receipt/source proof→cleanup coverage 검증을 함께 좁게 변경해야 한다. 단순 row append로 지원됐다고 주장하지 않는다. campaign_id를 envelope에 둘지 entry scope에 둘지와 기존 Case assignment ID 연결은 migration 설계 대상이며 이번에 version framework를 구현0이다.

[추천] 현재 developer receipt는 그 Case-oriented payload에 대해서만 성공을 보장한다. Completed Scripted 누락을 가진 receipt를 **전체 Campaign facts 보존 증명**으로 쓰면 안 된다. Step59는 이 gap의 정책을 정의했으며 구현 상태는 계속 OPEN이다.

## 14. ACTIVE Scripted Terminal Decision

[추천] **A: 현재 explicit block 유지**를 선택한다. 실제 Story Campaign에서 Scripted response 도중 임의 player Run 종료/forced 종료를 만드는 trigger가 확인되지 않았다. 기술적 완성도를 위해 INTERRUPTED_CAMPAIGN_RESPONSE obligation·강제 aborted history를 추가할 근거가 없다. 경제/Quota/Settlement/반복 Run 보상은 이유로 사용하지 않는다.

[확정] current status는 UNSUPPORTED_ACTIVE_CAMPAIGN_RESPONSE이고 State/View/cursor/recipient/proof/freeze를 바꾸지 않는다. Save/앱 종료/메뉴 이동은 developer terminal closure와 다른 미래 요구이며 자동 forced closure로 치환하지 않는다. 기존 developer API는 test fixture 종료/ownership·freeze·cleanup 검증용이다. 실제 Campaign final snapshot이나 Save/export helper/폐기된 prototype이라고 확정할 repo 근거는 없다.

[미정] author가 실제 Scripted 도중 Campaign 강제 종료를 승인하면 원인/화면/완료 의미/유지할 draft·confirmed 값/다음 진행/Ending 조건을 먼저 정의한다. 그때 generalized terminal support B의 비용을 다시 평가한다. 지금은 active block을 해결해야 할 기능 결손으로 억지 구현하지 않는다.

## 15. Cleanup Relationship

[확정] 현재 verified cleanup은 receipt/source identity/preflight를 검사한 후 Resolution/Response/Archive/Hypothesis/Candidate/Pending/Runtime/Progress를 reset하고 CLEANED_NO_RUN으로 간다. recipient Record/receipt와 authored Resource는 보존한다. 이 작업은 현재 developer lifecycle이며 chapter handoff에서 자동 호출되지 않는다.

[추천] player Campaign Start→여러 Case/Event→Final→Ending까지 소비할 historical owners를 유지한다. **chapter나 segment라는 이유만으로 Step54 cleanup을 호출하지 않는다.** 실제 Ending이 필요한 facts를 읽거나 별도 final recipient가 필수값을 인수한 뒤에만 source release를 허용한다. 현재 Case recipient는 Scripted/Progress 전체 history를 보존하지 않으므로 미래 Campaign final의 완전한 인수자로 사용할 수 없다.

[추천] query facade release hook은 verified cleanup preflight가 성공하고 reset이 시작될 때 invalidation한다. preflight 실패는 source lifetime를 바꾸지 않는다. partial reset 실패 후에는 mixed source를 valid false facts로 query하지 않고 SOURCE_RELEASED/UNAVAILABLE와 frozen retry 정책을 유지한다. 이 invalidation hook은 현재 없으며 후속 구현 대상이다. Main free/source 교체에도 동일 lifetime 경계를 적용한다.

[추천] 정말 segment owner를 폐기해야 한다면 필요한 fact와 Archive/Progress/explicit flags의 lifetime를 먼저 열거해 별도 Campaign owner 유지 또는 minimal retired record 인수를 결정한다. 보존 acknowledgement 전에 source reset0. 이 조건이 충족될 때만 B history가 정당화된다. 새 State를 하나 만든 것만으로 기존 cleanup에서 자동 생존한다고 가정하지 않는다.

[확정] Step54는 cross-State exception transaction/atomic rollback 보장이 아니다. silent reset failure는 partial cleanup 가능, verified committed proof/recipient 안전과 frozen/idempotent explicit retry를 유지한다. Step53 active+resolvable/residue Pending OPEN P2는 그대로다. 이번 문서는 이 제한을 수정하거나 해결 완료로 표시하지 않는다.

## 16. Ending Input Boundary

[추천] Ending은 `CampaignFactQueries`에서 **author가 요구한 known facts만** build한 immutable-ish `CampaignOutcomeSnapshot`을 받는다. 대안 이름 CampaignHistorySnapshot도 가능하나 history store와 혼동을 줄이기 위해 OutcomeSnapshot을 선호한다. 후보 이름/파일은 현재 없다. detached primitives와 getter copy로 외부 mutation이 owner를 바꾸지 않게 한다. Settlement/RunResult/보상 계산기가 아니다.

[추천] 최소 후보는 campaign_id/completed entry IDs/필요 Case outcomes와 selected room/필요 completed Scripted option·result/필요 discovered Research/실제 승인된 explicit flags다. full State/runtime/candidate/RNG/tokens/Hypothesis dump0. Final trigger와 snapshot builder는 query 계층과 별도, snapshot 조회가 Case를 hidden prepare하거나 unresolved를 success로 바꾸지 않는다.

[미정] 실제 Ending이 hidden Resolution을 논리 입력으로 쓸지는 author가 정한다. query 가능하다고 player에게 모든 hidden 진단값을 표시하는 것은 아니다. unresolved Incident·미해결 제출·actual 피해/사망/시설 손상 조건은 승인된 규칙/실제 owner가 필요하다. 현재 그런 effect owner는 없고 Result description을 casualty fact로 파싱하지 않는다. Hypothesis를 Ending truth로 자동 해석0.

[추천] required query에 UNKNOWN/INVALID/UNSUPPORTED/RELEASED가 있으면 불완전 입력으로 Ending을 확정하지 않는다. optional unknown을 어떻게 표시/무시할지와 Final after-last-entry 정책은 실제 자료로 정한다. generic Ending interpreter/score/경제적 정산을 만들지 않는다.

## 17. Save Identity Requirements

[확정] Save/Load/serialization/새 version framework를 구현하지 않았다. 다음은 future persistent identity 설계 제약이다.

| logical identity | scope /보존 의미 |
| --- | --- |
| campaign_id | authored Campaign definition. 다른 Campaign의 동일 entry 문자열과 구분 |
| entry_id | Campaign 안의 실행 occurrence. 배열 index/current ordinal/파일명 대체 불가 |
| case_id /event_id | definition ID. entry occurrence와 별도 검증 |
| origin_kind+entry_id+incident_id | Response identity. bound campaign_id와 함께 save scope 구성 |
| broadcast_id+option_id+result_id | 해당 response content scope의 승인 연결. option ID만 전역 lookup0 |
| research_entry_id | Case definition scope의 discovery ID. future repeated Case는 occurrence provenance 정책 필요 |
| current Progress/phase/Pending/active response | mid-Campaign 재개에 필요한 live 상태. historical 결과만으로 복원 못함 |

[추천] Godot get_instance_id/Node path/Callable/Resource object ID는 persistent key로 사용0. `.tres` 경로나 UID는 loading lookup hint일 수 있으나 primary story identity는 stable authored ID다. Save 때 content 이동/삭제/reorder와 ID migration 검증을 정의한다. schema_version/content revision은 실제 Save 설계 시 필요한 최소 필드만; 지금 framework를 추가하지 않는다.

[미정] Campaign replay/new game는 현재 미구현이다. 여러 playthrough를 한 저장영역에 함께 보관할 때만 stable logical playthrough/slot scope가 필요한지 판단한다. campaign_id를 단일 세션 ID로 오해하거나 반복 Run reward/meta progression로 확장하지 않는다.

## 18. Repeated Case/Event Future Compatibility

[확정] 같은 Event definition을 다른 entry_id 두 개로 실행하는 것은 Step58 source-aware State가 지원하고 이전 mixed native/headless fixture에서 검증됐다. Step59가 새 repeated 실행 검증을 수행한 것은 아니다. historical query도 event_id가 아닌 entry_id+incident scope로 구분한다.

[확정] 반복 Case는 여전히 CampaignData에서 duplicate case_id를 거절한다. Resolution/Pending/Candidate/Archive/Hypothesis/Runtime key가 Case definition ID 중심이라 query adapter의 entry key만으로 지원을 선언할 수 없다.

[추천] future repeated Case를 요구하면 runtime assignment/Resolution/Pending/Candidate/Research/notes/response/Save mapping의 occurrence identity를 먼저 migration한다. Research를 definition 전체 합집합으로 공유할지 occurrence별 보존할지도 정한다. historical contract는 entry_id를 사용해 그 미래를 막지 않지만 실제 migration 전에는 ambiguous legacy Case-ID query를 INVALID/UNSUPPORTED로 거절한다. 한 authored entry를 루프로 재실행하는 무한 occurrence 모델은 이번 설계에 포함하지 않는다.

### ordering

[확정] Campaign authored order와 actual deferred Incident 발생 순서는 다를 수 있다. Response dictionary의 insertion order와 Candidate registration order가 전 State 공통의 승인된 historical event timeline인 것은 아니다. 기존 source ID와 status로 occurrence/result membership을 확인할 수 있지만 글로벌 timestamp/occurrence ordinal은 없다.

[추천] 현재 조건에는 authored entry ID와 정확한 response key만 사용한다. actual 사건 순서가 필요한 Story 자료가 없으므로 별도 global order를 선기록하지 않는다. [미정] 실제 before/after event 조건이 요구되면 validated start/ack 의미를 먼저 정하고 monotonic occurrence ordinal 정도만 검토한다. wall-clock timestamp/time trigger는 도입0.

## 19. Implementation Sequence

[추천] **Step60 최소 범위=A query foundation+source lifetime guard**. 실제 Story/Mandatory/Final/Ending/Save content 없이 구현 가능하다.

1. 작은 Campaign-scoped read-only adapter와 최소3가지 value result 후보를 정한다. 기존 State getter를 읽고 entry/definition/origin/link validation과 UNKNOWN/released policy를 구현한다. owner의 내부 Dictionary를 직접 읽는 API 대신 현재 public getters를 사용한다. 이름/파일은 Step60에서 실제 repo convention에 맞게 결정한다.
2. entry completion/Case resolution/Room/Case·Scripted response completed/option/result/Research query만 제공한다. 원값 저장/copy/flags/condition enum/expression language0. past experiments는 UNSUPPORTED 또는 UNKNOWN(HISTORY_NOT_CAPTURED)로 명시하고 새 history를 만들지 않는다.
3. Main은 초기 bind/current Runtime context 갱신/verified source release invalidation만 연결한다. Progress outcome 저장0, typed live query를 terminal recipient 대신 사용한다.
4. static+fresh Godot 검증에서 mixed completed Scripted를 later Case에서 query, 동일 Event 두 occurrences, Case room/resolution 차이, active/draft/result link phase, Case03 unresolved, current discovery-before-merge, invalid/cross-Campaign binding, readonly source mutation0, reset/release 후 false 위장0, 기존 source/terminal regressions를 확인한다. 이는 **다음 Step의 acceptance 계획이며 이번 실행 결과가 아니다**.
5. terminal Scripted completed projection은 실제 final/export 인수 요구가 정해졌을 때 별도 작은 단계로 수행한다. Record/State validation까지 함께 검증한다. query-only Step60으로 terminal gap이 해결됐다고 선언하지 않는다.
6. 첫 authored Story 조건을 받은 뒤 필요한 조건 종류만, Mandatory는 정보 접근/선택/결과 자료를 받은 뒤, Ending은 입력 요건을 받은 뒤, Save는 live progress/owner 책임이 안정된 뒤 구현한다.

[추천] Story가 transient Experiment 사실을 필요로 한다면 위 Step60과 혼합해 모든 Runtime를 복사하지 말고 별도 minimal activity capture 범위를 승인한다. 새 History State가 불필요하다는 결론은 현재 audited lifetime와 현재 소비자 요구 기준이며 미래 cleanup/Segment 요구를 영구 금지하는 것이 아니다.

## 20. Required User Story Materials

[확정] ownership/identity/query shape/복제 금지/cleanup 및 terminal projection 관계를 설계하는 데 실제 Story 자료는 필요 없다. 이번 설계는 그 부분까지 완료했다.

| 필요 시점 | 필요한 자료 /결정 |
| --- | --- |
| 첫 Story 조건 | 어떤 과거 entry의 어떤 known fact를 어느 checkpoint에서 읽는지, 필요한 phase, unknown/missing 처리 |
| 실제 Scripted/Mandatory | stable entry/event/incident/option/result IDs와 문구/연결, 삽입 순서, 승인된 실제 선택·결과, no-failure 경로 정보 접근 |
| explicit flags | 유도 불가한 서사 의미, declared ID/primitive type/초기값/유일 producer/쓰기·수정 시점 |
| actual forced termination | 실제 원인/trigger/화면/active response 완료 또는 중단 의미/Ending 관계 |
| Ending | 필요한 Case outcomes/선택/Research/Flags, unresolved 취급, hidden fact의 표시 경계, final prerequisite |
| transient history | 어떤 과거 실험/관찰을 왜 later Story에서 읽어야 하는지와 최소 ID 목록 |
| Save/replay | 저장·재개 checkpoint, active/draft 정책, single/multiple Campaign scope, ID/content migration 및 UX |

[미정] 실제 인물·사건·문서·정답·피해·분기·Ending을 임의로 채우지 않는다. 조건 구조 예시를 실제 확정 Story로 취급하지 않는다.

## 21. Open Decisions

| 수준 | 결정 /상태 |
| --- | --- |
| [확정] | 현재 canonical owners/lifetime, Step58 completed Scripted terminal 누락과 ACTIVE block, design-only 변경, 경제0/실제 Story0 |
| [추천] | A readonly typed query adapter, Progress 책임 유지, query-first, source release guard, 최소 future final snapshot, ACTIVE block 유지 |
| [미정] | 실제 어떤 facts를 소비할 Story/Ending, 과거 실험 보존, explicit flag 타입, actual event ordinal 필요, unresolved/피해 의미, Campaign final trigger |
| [미정] | player Segment 수명/Save/replay/정식 Campaign instance scope. 현재 developer cleanup을 chapter 정책으로 확정0 |
| [추천] [미정] | completed Scripted를 미래 historical_facts로 export, 정확한 generalized terminal envelope/migration은 소비자 요구 후. 구현 gap OPEN |

## 22. P0-P3

[확정] 이번 단계는 설계/정적 조사만이므로 새 gameplay 검증으로 P0/P1 부재를 입증했다고 주장하지 않는다. 조사 범위에서 이 문서 작업을 막는 새 P0/P1은 발견하지 않았다.

| 수준 | 발견 /다음 책임 |
| --- | --- |
| P0 | [확정] 새 설계 blocker 발견0. 제품 코드 변경0 |
| P1 | [확정] 새 확인된 product regression 발견0. [추천] 미래 Ending 이전 source cleanup/data loss를 설계대로 차단해야 함 |
| P2 | [확정] Step53 ACTIVE+resolvable/residue Pending 제한 OPEN. Scripted completed terminal projection 및 player Campaign final 계약 구현 OPEN; Step59로 fixed가 아님 |
| P3 | [확정] Hypothesis private-key enumeration seam, 큰 Main 책임 유지. [추천] 새 query를 Main에 확대 저장하지 않음 |

[확정] Step54 partial reset/cross-State atomicity 제한 및 frozen retry 정책 유지. [추천] query readonly와 lifecycle invalidation은 보안적으로 private field 직접 조작을 막는 장치가 아니며 정상 product 경로의 truth 계약이다.

## 23. 핵심 질문 15개에 대한 결론

| 질문 | 답 |
| --- | --- |
| 과거 Case SUCCESS/FAILURE는 어디? | [추천] entry mapping→ContainmentResolutionState. outcome UNKNOWN을 유지 |
| selected Room은 어디? | [추천] Resolution 또는 Pending phase-aware query, current Runtime agreement |
| 모든 과거 Experiment가 필요한가? | [미정] 실제 Story 요구 없음. 전부 copy0, 필요 IDs만 retirement capture |
| Research는 Archive 직접 query? | [추천] 과거는 Archive, current 미merge는 Runtime union. 중복 history0 |
| Scripted Option/Result는 어디? | [추천] source-aware IncidentResponseState의 정확한 occurrence/status/confirmed IDs |
| completed IDs와 fact의 차이는? | [확정] 진행 수락 여부 vs어떻게 판정·선택·대응했는가 |
| owner가 계속 살면 copy 필요한가? | [추천] 현재 audited 결과/응답/Archive에는 필요 없음 |
| owner가 사라지면 무엇을 copy? | [추천] 실제 소비자가 요구한 IDs/enum 및 occurrence, confirmed value만 인수 |
| 큰 CaseResult object 필요한가? | [추천] 필요 없음. 큰 full dump/Resource 결과 object0 |
| Flag가 필요한 경우는? | [미정] 기존 source로 유도 불가한 실제 서사 상태와 producer가 있을 때 |
| gameplay boolean 복제 왜 금지? | [확정] two truths drift. canonical owner query로 해결 |
| Ending은 무엇을 읽나? | [추천] readonly typed query가 만든 필요한 immutable-ish OutcomeSnapshot |
| Save identity는? | [추천] campaign/entry occurrence/definition 및 scoped incident·broadcast·option·result·Research IDs |
| RunDisposition을 History로 재사용? | [추천] live database로 사용0. final projection recipient만 |
| completed Scripted terminal에 넣나? | [추천] 필요하면 historical fact로. obligation0/fake Case0, 실제 schema integration은 후속 |

## 24. 실제 source 근거와 정적 보호 결과

[확정] 아래 API/함수는 실제 repo에 존재하며 `source-inventory.json`과 `lifetime-source-proof.json`에서 signature/위치/본문을 보관했다. 앞의 제안 query API와 구분한다.

| 실제 source | 근거 /위치 |
| --- | --- |
| `scripts/data/campaign_data.gd:10` | `get_validation_error` |
| `scripts/data/campaign_data.gd:34` | `get_entry` |
| `scripts/data/campaign_data.gd:41` | `get_case_entry` |
| `scripts/data/campaign_entry_data.gd:14` | `get_validation_error` |
| `scripts/data/scripted_incident_data.gd:11` | `get_validation_error` |
| `scripts/data/scripted_incident_data.gd:34` | `get_broadcast` |
| `scripts/data/scripted_incident_data.gd:40` | `get_result` |
| `scripts/runtime/campaign_progress_state.gd:23` | `get_current_entry_id` |
| `scripts/runtime/campaign_progress_state.gd:31` | `get_completed_entry_ids` |
| `scripts/runtime/campaign_progress_state.gd:57` | `try_complete_and_advance` |
| `scripts/runtime/campaign_progress_state.gd:65` | `reset` |
| `scripts/runtime/incident_source.gd:22` | `to_dictionary` |
| `scripts/runtime/incident_source.gd:26` | `matches` |
| `scripts/runtime/incident_response_state.gd:11` | `_key` |
| `scripts/runtime/incident_response_state.gd:31` | `get_responses` |
| `scripts/runtime/incident_response_state.gd:46` | `try_confirm` |
| `scripts/runtime/incident_response_state.gd:54` | `try_complete` |
| `scripts/runtime/incident_response_state.gd:62` | `reset` |
| `scripts/runtime/containment_resolution_state.gd:8` | `try_record_resolution` |
| `scripts/runtime/containment_resolution_state.gd:24` | `get_resolution` |
| `scripts/runtime/containment_resolution_state.gd:32` | `reset` |
| `scripts/runtime/pending_containment_state.gd:9` | `try_add_pending` |
| `scripts/runtime/pending_containment_state.gd:21` | `get_pending_room_id` |
| `scripts/runtime/pending_containment_state.gd:37` | `reset` |
| `scripts/runtime/case_runtime_state.gd:22` | `reset` |
| `scripts/runtime/case_runtime_state.gd:35` | `try_record_experiment_execution` |
| `scripts/runtime/case_runtime_state.gd:65` | `get_experiment_execution_history` |
| `scripts/runtime/case_runtime_state.gd:142` | `get_discovered_research_entry_ids` |
| `scripts/runtime/research_archive_state.gd:8` | `merge_case_discoveries` |
| `scripts/runtime/research_archive_state.gd:22` | `has_discovered_entry` |
| `scripts/runtime/research_archive_state.gd:36` | `reset` |
| `scripts/runtime/working_hypothesis_state.gd:46` | `get_hypotheses` |
| `scripts/runtime/working_hypothesis_state.gd:58` | `clear_all` |
| `scripts/runtime/working_hypothesis_state.gd:63` | `reset` |
| `scripts/runtime/failure_event_candidate_state.gd:8` | `try_add_candidate` |
| `scripts/runtime/failure_event_candidate_state.gd:20` | `get_candidate` |
| `scripts/runtime/failure_event_candidate_state.gd:79` | `remove_completed_candidate` |
| `scripts/runtime/failure_event_candidate_state.gd:50` | `reset` |
| `scripts/runtime/run_disposition_record.gd:12` | `_init` |
| `scripts/runtime/run_disposition_record.gd:22` | `to_dictionary` |
| `scripts/runtime/run_disposition_state.gd:14` | `try_commit` |
| `scripts/runtime/run_disposition_state.gd:43` | `get_committed_record` |
| `scripts/runtime/run_disposition_state.gd:63` | `_validation_issue` |
| `scripts/runtime/run_disposition_state.gd:104` | `_entry_issue` |
| `scripts/read_models/developer_run_disposition_builder.gd:42` | `source_issue` |
| `scripts/read_models/developer_run_disposition_builder.gd:86` | `build` |
| `scripts/read_models/test_sequence_disposition_snapshot.gd:19` | `build` |
| `scripts/main/main.gd:98` | `_ready` |
| `scripts/main/main.gd:912` | `_merge_current_case_discoveries` |
| `scripts/main/main.gd:1003` | `_handoff_to_next_case` |
| `scripts/main/main.gd:1365` | `_try_resolve_pending_without_handoff` |
| `scripts/main/main.gd:1715` | `_advance_response` |
| `scripts/main/main.gd:2202` | `_case_response_records` |
| `scripts/main/main.gd:2209` | `_dispatch_campaign_entry` |
| `scripts/main/main.gd:1058` | `developer_commit_run_disposition` |
| `scripts/main/main.gd:1091` | `_cleanup_verified_source` |
| `scripts/main/main.gd:1274` | `_developer_source_facts` |
| `scripts/main/main.gd:1248` | `_developer_source_valid` |
| `scripts/main/main.gd:947` | `build_test_sequence_disposition_snapshot` |

[확정] static scan은 GDScript48/Scene15/Resource4/project의 file/function inventory와 terminal call-site, current source lifetime를 조사했다. Godot를 새로 실행하지 않았으며 static 비교 수를 gameplay assertion 수라고 부르지 않는다. 기존 Step58 Report/certification의73/10591은 과거 실행 증거만 참고했다.

[확정] Step59 시작142개 비생성파일의 SHA-256를 baseline에 기록했다. README 제외141개(제품118파일 포함), 기존 verification54987개 hash가 종료 전 동일이다. README 원본437959 bytes prefix를 보존하며 이번 설계 상태만 append한다. 새 doc1개/README append1개/제품 변경0/삭제0. HEAD/branch/upstream/staged 보존,누적 Git diff와 이번 baseline diff를 구분하고 git diff --check를 확인했다.

[확정] static baseline/inventory/hash-preservation/final-audit 및 README append diff만 ignored `.godot/verification/step59/`에 보관했다. 기존 evidence를 수정하거나 덮지 않았다. 이 generated 조사 자료는 제품 코드/문서의 Git 변경 수에 포함하지 않는다.

## 25. 요청한 종료 보고 144개 항목

| 번호 | 요청 항목 | 확정 /추천 /미정 |
| ---: | --- | --- |
| 1 | 작업 전 Git 상태 | [확정] 시작 시 tracked modified7/untracked15/staged0의 Step55~58 누적 변경. 위 Current Repo Facts와 기준 Git 목록 참조. |
| 2 | HEAD | [확정] 6e8f167f699a3a95c91fee8668ae99d03e5d4db9 그대로. |
| 3 | branch/upstream | [확정] master /origin/main 그대로. |
| 4 | 기존 변경 보호 | [확정] 제품118파일과 README 제외 기존141파일 byte 동일, 기존 verification54987개 SHA-256 동일. 기존 미커밋 rollback0. |
| 5 | 현재 CampaignProgressState 책임 | [확정] cursor/completed entry IDs/bound transition/max1 failure offer. outcome 저장 owner 아님. |
| 6 | current cursor | [확정] CampaignProgressState._current_entry_index sole cursor. Main._case_index derived CASE ordinal. |
| 7 | completed entry IDs | [확정] try_complete_and_advance가 accepted entry ID를 한 번 저장. 어떻게 완료했는지 저장하지 않음. |
| 8 | current Case Resolution owner | [확정] ContainmentResolutionState. approved SUCCESS/FAILURE/room/incident IDs. |
| 9 | CaseRuntime lifetime | [확정] 현재 CASE 동안. dispatch는 old Runtime Main 참조를 해제하고 CASE에 새 객체,Scripted에 null. |
| 10 | experiment history lifetime | [확정] Runtime handoff 뒤 canonical past query에서 소실. [미정] 실제 Story 필요 시 최소 capture. |
| 11 | Research Archive lifetime | [확정] Main session/cleanup 전까지 merge된 발견 보존. chapter에서 자동 reset 안 함. |
| 12 | Hypothesis lifetime | [확정] session notes/counters 유지, mutable 자유 메모. cleanup reset. canonical truth 아님. |
| 13 | Response history lifetime | [확정] source-aware ACTIVE/COMPLETED record는 session 유지, reset 삭제. |
| 14 | Scripted completed record lifetime | [확정] 이후 Case에서도 IDs/status 남음. terminal recipient는 현재 Scripted completed를 제외. |
| 15 | developer cleanup effect | [확정] 모든 source owner/reset 및 current Case/Runtime/View release. recipient/authored만 유지. |
| 16 | derived gameplay fact 정의 | [확정] 실제 승인된 gameplay 판정·선택·발견·진행에서 유도되는 사실. |
| 17 | explicit Story flag 정의 | [확정] 기존 gameplay source로 유도 불가한 author-defined 서사 상태. 구현0. |
| 18 | duplicate flag 문제 | [확정] CASE01_FAILED bool 복제는 owner와 drift/two truths 유발. |
| 19 | query-first 정책 | [추천] 살아 있는 canonical owner를 typed readonly query adapter로 읽음. |
| 20 | history-copy 필요 조건 | [추천] 원 owner 소실+실제 later Story/Ending 소비자 필요 때만 최소 transfer/copy. |
| 21 | Case SUCCESS source | [추천] entry mapping→Resolution.result SUCCESS. authored/Monitoring/result text로 추측0. |
| 22 | Case FAILURE source | [추천] entry mapping→Resolution.result FAILURE. Candidate absence를 success로 해석0. |
| 23 | selected Room source | [추천] resolved Room은 Resolution,submitted Room은 Pending/current Runtime agreement. phase 명시. |
| 24 | experiment source | [확정] current Runtime actual execution IDs. past는 미지원. [미정] 필요한 IDs만 retirement capture. |
| 25 | Case Incident source | [추천] CASE-origin Response 시작/phase가 실제 normal Major 발생 evidence. Resolution incident_id/Candidate는 예정 정보. |
| 26 | Case option source | [추천] CASE entry+incident tuple의 Response.confirmed_option_id. |
| 27 | Case result source | [추천] 같은 Response.incident_result_id와 phase. COMPLETED final 선택 condition 기본. |
| 28 | Scripted completed source | [추천] CAMPAIGN_ENTRY tuple,status=COMPLETED +matching Progress completion. |
| 29 | Scripted option source | [추천] 지정 entry의 approved confirmed_option_id. event_id-only query0. |
| 30 | Scripted result source | [추천] 지정 entry의 approved incident_result_id. link/표시/ack 구분. |
| 31 | Research source | [추천] past Archive;current Runtime+Archive read union. 새 duplicated discovery history0. |
| 32 | Hypothesis source | [확정] WorkingHypothesisState. player text만,Story/Ending fact로 승격0. |
| 33 | entry completion source | [확정] CampaignProgressState completed membership. |
| 34 | candidate source | [확정] FailureEventCandidateState live readiness; completed Response 때 matching 후보 제거. 영구 history 아님. |
| 35 | alternative A | [추천] A existing-owner typed read query. 현재 선택. |
| 36 | alternative B | [추천] B small CampaignHistoryState는 원 owner retirement+실제 소비자 조건부 대안. 지금 구현0. |
| 37 | alternative C | [추천] separate Case/Event history는 두 capture/lifetime/schema 비용. 현재 제외. 후보 문자 혼동보다 이름 우선. |
| 38 | alternative D | [추천] Progress history 확장은 책임/복제 위험. 현재 제외. |
| 39 | recommended history model | [추천] A query-first +conditional minimal activity/retired facts. 새 mutable history State 없음. |
| 40 | recommendation reason | [확정] [추천] 핵심 owners가 session 유지; duplicate capture보다 narrow adapter가 작은 비용·truth 명확성. |
| 41 | new State 필요 여부 | [추천] 현재 outcome/Response/Archive HistoryState 필요 없음. 실제 transient Story 요구 때만 재평가. |
| 42 | State 책임 | [추천] adapter는 scope/typed query/unknown/lifetime guard. 조건부 B는 승인된 retired fact만,full dump0. |
| 43 | ProgressState 확장 여부 | [추천] outcome history 확장0. cursor/completion/transition 유지. |
| 44 | Main history storage 여부 | [추천] Main History Dictionary0. bind/dispatch/release orchestration만. |
| 45 | Manager 여부 | [확정] [추천] Manager 생성0. |
| 46 | Autoload 여부 | [확정] [추천] Singleton/Autoload0. |
| 47 | EventBus 여부 | [확정] [추천] EventBus0. |
| 48 | primitive IDs | [추천] detached stable String IDs/bool/enum-int/필요 ID arrays. 값 record는 runtime value,authored .tres 아님. |
| 49 | Resource reference policy | [추천] long-lived fact에 authored Resource instance 저장0. query resolver의 lookup 입력만. |
| 50 | Node/Callable policy | [추천] historical payload Node/Callable 저장0. facade context도 current owner만,private Main 탐색0. |
| 51 | campaign_id | [추천] authored Campaign definition scope. 현재 records에는 암묵 session scope, facade에 explicit bind. |
| 52 | entry_id | [추천] execution occurrence identity 핵심, bound Campaign 안에서 고유. |
| 53 | case_id | [확정] [추천] Case definition ID. entry와 별도. current Case owners는 unique definition 제한. |
| 54 | event_id | [확정] [추천] Event definition ID. 여러 entry reuse 가능하므로 단독 historical key0. |
| 55 | incident_id | [추천] source content scope Incident ID. origin+entry+incident와 campaign context로 구분. |
| 56 | option_id | [추천] approved Broadcast scope Option ID. draft 제외. |
| 57 | result_id | [추천] approved Option→Result ID. completed/active link phase 포함. |
| 58 | Research ID | [추천] Case-scoped research_entry_id. Campaign entry_id와 이름/의미 구분, actual membership만. |
| 59 | occurrence ordering | [확정] [추천] authored order와 actual deferred event order 구분. 현재 membership에 별도 ordinal 불필요. |
| 60 | timestamp 여부 | [확정] timestamp 없음/추가0. [미정] actual-order 요구 시 monotonic ordinal 정도만 검토. |
| 61 | unknown handling | [추천] UNKNOWN/INVALID/UNSUPPORTED/SOURCE_RELEASED와 KNOWN(false,as-of-now)를 분리. 미확정/소실을 false로 추측0. |
| 62 | unresolved Pending | [확정] [추천] selected room known/outcome unknown. Outcome0를 SUCCESS/FAILURE로 위조0. |
| 63 | draft Option | [확정] [추천] View/local return context. canonical confirmed/completed history 아님. |
| 64 | confirmed Option | [확정] [추천] approved IDs는 State source. ACTIVE_CONFIRMED와 COMPLETED phase 구분. |
| 65 | Result link | [확정] [추천] confirmed link K와 Result display/ack를 구분. independent persistent read/drawn field 없음. |
| 66 | actual Scripted completion | [확정] [추천] Main의 approved actual Result acknowledgement→Response COMPLETED. 사람의 이해/읽기 완료 주장0. |
| 67 | append-once | [추천] A에서는 새 append 없음. B를 필요로 하면 verified source read/동일 occurrence once capture. |
| 68 | overwrite 여부 | [추천] canonical completed result overwrite0. duplicate same payload는 ALREADY_RECORDED,different payload CONFLICT. |
| 69 | duplicate callback | [확정] [추천] Step58 once response/Progress/stale View 보호 유지. future history도 source/occurrence once 검사. |
| 70 | Case history API | [추천] 기본 get_case_resolution/get_case_room. 조건부 B의 record_case_resolution(verified value)는 현재 미구현. |
| 71 | Scripted history API | [추천] shared response query. B가 필요하면 record_scripted_response_completion(verified COMPLETED)는 actual ack 뒤. |
| 72 | generic set_fact 여부 | [확정] [추천] generic set_fact 없음/추천0. |
| 73 | read-only query | [추천] typed detached readonly value. query가 prepare/merge/RNG/credit/State mutation0. |
| 74 | was_entry_completed | [추천] BooleanFactQuery 후보,Progress membership. 현재 method 없음. |
| 75 | get_case_resolution | [추천] CaseResolutionQuery 후보, entry→Resolution. 현재 facade method 없음. |
| 76 | get_case_room | [추천] IdentifierFactQuery 후보, resolved/submitted phase-aware Room. |
| 77 | was_response_completed | [추천] BooleanFactQuery 후보, CASE/CAMPAIGN 공통 source tuple.status==COMPLETED. |
| 78 | get_confirmed_option | [추천] IdentifierFactQuery 후보, 실제 approved option+phase. |
| 79 | get_incident_result | [추천] IdentifierFactQuery 후보,approved result link+phase. completed condition은 completed만. |
| 80 | was_research_discovered | [추천] current unique Case-ID compatibility mapping+Runtime/Archive. occurrence-explicit 장기 API도 제안. |
| 81 | Story condition 종류 | [추천] [미정] ENTRY/CASE/RESPONSE/RESEARCH/explicit flag 후보 matrix. 최초 실제 조건에 필요한 것만. |
| 82 | generic expression 여부 | [확정] [추천] generic expression/interpreter0. |
| 83 | explicit flag State 필요성 | [미정] 기존 query로 유도 불가한 실제 narrative action이 있을 때 별도 declared typed flag State. |
| 84 | generic string flag 여부 | [추천] generic string→Variant flag dictionary를 truth database로 사용0. |
| 85 | boolean-only 여부 | [미정] boolean-only 미확정. 실제 flag 의미/producer/primitive value 요구에 따라 좁게. |
| 86 | CampaignProgressState 경계 | [추천] Progress는 cursor/completion/intent만. Read model에서 outcome 합성. |
| 87 | completed entry와 outcome 차이 | [확정] 완료 marker는 진행 수락,Success/Failure/Room/응답 결과와 별도. |
| 88 | RunDisposition 역할 | [확정] developer terminal ownership snapshot과 caller-owned receipt/Record recipient. |
| 89 | RunDisposition을 live history로 사용 여부 | [추천] live Campaign history로 사용0. source query가 먼저,terminal은 projection. |
| 90 | terminal snapshot | [추천] 소비자가 필요한 detached final facts만. 현재 Case schema에 scripted row를 append할 수 없음. |
| 91 | Scripted completed terminal fact | [추천] future historical_facts/COMPLETED_SCRIPTED_RESPONSE_FACT, fake Case/Failure/obligation0. schema integration 미구현. |
| 92 | Scripted active terminal | [확정] 현재 UNSUPPORTED_ACTIVE_CAMPAIGN_RESPONSE. [추천] explicit block 유지. |
| 93 | active block 유지 여부 | [추천] 유지(A). 실제 player forced trigger가 확인되지 않아 generalized obligation 도입 근거 없음. |
| 94 | forced termination 실제 Story 의미 | [미정] 현재 Story Campaign에서 actual forced ending cause 확인되지 않음. 기술적완성/경제 이유로 발명0. |
| 95 | 프로젝트에서 확인 여부 | [확정] 프로젝트 내에서 확인되지 않음. product View/Scene player 종료 call site0. |
| 96 | cleanup relationship | [추천] Ending/필수 recipient capture 전 cleanup0;chapter 자동 reset0. |
| 97 | Campaign history lifetime | [추천] Start→Cases/Events→Final→Ending까지 필요한 owners 유지. player Segment 정책 미정. |
| 98 | developer cleanup lifetime | [확정] 현재 test/developer source release/no-run. Campaign 역사 lifetime과 동일시0. |
| 99 | Ending input | [추천] readonly queries→author-required CampaignOutcomeSnapshot,Main private lookup0. |
| 100 | Ending hidden fact 여부 | [미정] hidden Resolution 사용/노출의 Story 규칙 필요. query 가능과player 정보 노출은 별도. |
| 101 | Hypothesis Ending 사용 여부 | [추천] canonical Ending truth 사용0. 표시/Save UX는 별도 미정. |
| 102 | unresolved Incident Ending 여부 | [미정] 실제 unresolved Incident Ending 반영 규칙 없음. |
| 103 | damage/casualty fact 여부 | [확정] canonical damage/casualty owner 없음. text→fact/schema 선생성0. |
| 104 | Campaign snapshot 후보 | [추천] CampaignOutcomeSnapshot 선호;CampaignHistorySnapshot 후보. 모두 미구현. |
| 105 | Settlement와 차이 | [확정] [추천] Ending input/read projection이지 재화/보상/Settlement 계산0. |
| 106 | Save stable identity | [추천] campaign/entry/definition/source/incident/broadcast/option/result/research IDs와 phase. |
| 107 | instance ID 사용 여부 | [추천] engine instance ID persistent identity0. developer assignment logical ID와도 혼동0. |
| 108 | Resource path 사용 여부 | [추천] stable authored IDs 우선,Resource path/UID는 loading hint이지 primary Story identity 아님. |
| 109 | repeated Case compatibility | [확정] 반복 Case 미지원. [추천] entry ID 설계가 future migration을 막지 않으나 owner migration 선행. |
| 110 | repeated Event compatibility | [확정] [추천] 다른 entry의 같은 Event definition 구분 가능. 현재 source-aware State를 query. |
| 111 | fact ownership matrix | [확정] [추천] §4 owner/source/copy 이유 표. |
| 112 | lifetime matrix | [확정] [추천] §3 State 및 fact lifetime matrix. cleanup 후 원 fact 소실 명시. |
| 113 | condition matrix | [추천] [미정] §11 typed source/copy/flag/unsupported matrix. Story 내용0. |
| 114 | terminal matrix | [확정] [추천] §13 Case/unresolved/active/scripted/final matrix. |
| 115 | Step60 scope | [추천] A narrow readonly facade+typed result+source release guard+fresh acceptance. 새 HistoryState/Story content0. |
| 116 | Story material 필요 여부 | [확정] 이번 ownership 설계에는 필요 없음. [미정] actual fact-consuming condition에는 필요. |
| 117 | Mandatory content 필요 여부 | [미정] 실제 Mandatory 콘텐츠와 정보 접근/선택/결과 자료는 후속에 필요. |
| 118 | Ending material 필요 여부 | [미정] actual Ending required inputs/unknown/unresolved/final policy 자료 필요. |
| 119 | Save implementation 여부 | [확정] Save/Load 미구현. 설계 identity만. |
| 120 | product code 변경 | [확정] 제품118파일 byte 변경0. |
| 121 | Scene 변경 | [확정] Scene15개 byte 변경0. |
| 122 | Resource 변경 | [확정] authored .tres4개 및 Resource class schema byte 변경0. |
| 123 | State 변경 | [확정] runtime State 변경/신규 구현0. |
| 124 | Main 변경 | [확정] Main2239행/121함수 그대로. byte 변경0. |
| 125 | README | [확정] 원본437959 byte prefix 보존 후 DESIGN ONLY status append. |
| 126 | report | [확정] docs/step59_campaign_historical_fact_contract.md 신규1개. |
| 127 | Godot new gameplay run 여부 | [확정] Godot 새 gameplay 실행0. design-only라 재검증 필수 아님. |
| 128 | previous test reuse 여부 | [확정] Step58의73/10591은 이전 증거로만 참고. Step59 새 검사로 재집계0. |
| 129 | hash preservation | [확정] README 제외141파일,제품118파일,이전 evidence54987개 SHA-256 동일. README prefix 동일. |
| 130 | git diff --check | [확정] git diff --check exit0. 누적 diff와 Step59 baseline 비교 둘 다 확인. |
| 131 | staged | [확정] 0. 시작/종료 cached diff 동일. |
| 132 | commit/push | [확정] 하지 않음. HEAD/branch/upstream 동일. |
| 133 | P0 | [확정] 새 설계 blocker P0 발견0. 새 gameplay assertion으로 보장 주장0. |
| 134 | P1 | [확정] 조사에서 새 확인된 product regression P1 발견0. 미래 premature cleanup 방지 필요. |
| 135 | P2 | [확정] Step53 P2와 Scripted terminal/Campaign final 구현 gap OPEN. 이번은 설계 확정만. |
| 136 | P3 | [확정] [추천] Hypothesis getter seam/큰 Main 유지. readonly adapter로 후속 책임 비대화 방지. |
| 137 | Step53 existing P2 | [확정] active+resolvable/residue Pending OPEN P2 그대로. 해결 완료0. |
| 138 | Step54 cleanup limitation | [확정] cross-State atomic rollback 불보장/partial reset 가능,committed proof/frozen explicit retry 유지. |
| 139 | Scripted terminal gap status | [확정] completed Scripted final recipient 통합 미구현. [추천] historical projection 계약 정의,구현 OPEN. |
| 140 | fixed decisions | [확정] 현재 owners/lifetime/identity/current terminal gap,design-only/경제0/Story0. |
| 141 | recommendations | [추천] A query-first,Progress 분리,unknown/liveness,ACTIVE block 유지,needed final snapshot. |
| 142 | undecided items | [미정] 실제 소비 facts/실험 capture/flag 타입/actual ordering/unresolved/피해/Ending/Save/Segment policy. |
| 143 | final recommendation | [추천] Step60 최소 typed live query foundation. History copy/Story/terminal schema 확대는 별도 실제 요구 이후. |
| 144 | next Step readiness | [추천] 구조 구현 준비됨. 첫 Story/Mandatory/Ending 입력 규칙은 사용자 자료를 받은 뒤 추가. |

## 26. 최종 권고

[추천] 다음 최소 작업은 **기존 authoritative owners를 읽는 Campaign-scoped typed query와 source lifetime guard**다. 새 HistoryState는 현재 필요하지 않다. 실제 later Story가 사라지는 Runtime 정보를 요구하거나 owner retirement를 도입할 때만 필요한 최소 historical record를 보존한다. Scripted completed 선택은 source-aware Response State에서 entry occurrence로 읽고, terminal은 필요할 때 그 사실의 final projection을 받는다.

[확정] 제품의 실제 Story/Mandatory/Final/Ending/Story flags/Save/경제는 이번에 추가되지 않았다. commit/push/stage도 하지 않았다. Scripted terminal gap은 설계 책임을 정의했으나 구현 OPEN이며, ACTIVE Scripted는 현재 block 유지 권고다.
