extends SceneTree

# Authors the TEMP Case 02 playtest Resources from the user-supplied SC-01 sheet (2026-10-19).
# Run: godot --headless --path . --script res://tools/build_case_02.gd
# TEMP / DRAFT / NON-CANON. Notes on choices the sheet leaves open are in docs/story/case_02_sc01_notes_v1.md.

const CASE_ID := "TEMP_CASE_02"
const IMG := "res://assets/temp/case02/generated/"

var data: CaseData

func _initialize() -> void:
	data = CaseData.new()
	data.case_id = CASE_ID
	data.display_name = "[임시·초안·비정사] SUBJECT SC-01"
	data.grouped_research_entries = true
	data.experiment_limit = 3

	var profile := ProfileData.new()
	profile.profile_id = "PROFILE_SC01"
	profile.subject_name = data.display_name
	profile.classification = "임시 분류 / 감각-압력 불안정 / 정식 세계관 미편입"
	profile.basic_description = "[TEMP / DRAFT / NON-CANON]\n\n" + _profile_text()
	profile.subject_texture = load("res://assets/temp/case02/sc01_master_reference.png")
	data.profile_data = profile

	var cctv := CCTVData.new()
	cctv.camera_id = "CAM_SC01_TEXT_OBSERVATION"
	cctv.camera_label = "CAM SC01-01 · 표준 격리실 상부"
	cctv.observation_text = "[TEMP / DRAFT / NON-CANON] SC-01 관찰 기록. 화면의 장면은 사용자 제공 외형 이미지를 표준 격리실에 합성한 임시 이미지이며 실제 감시 영상이 아니다. 열화상은 미제공이다. 판단 근거는 아래 텍스트 관찰이다.\n\n00:00 — 방 한가운데 웅크린 채 양손으로 머리를 누른다. 상체를 약간 숙이고 눈은 뜬 채 고정, 미세한 흔들림만 있다.\n02:40 — 방 내부 팬이 작동한 직후 손 압박이 강해지고 경부가 길게 늘어난다. 상부 환기구 방향을 바라보며 눈이 더 크게 드러나고 입이 벌어진다. 불규칙한 체위 변경이 두세 번 있다.\n04:20 — 실내 가습 장치가 작동 중이다. 습도가 올라가도 머리 압박과 환기구 주시에는 변화가 없다.
06:10 — 조용한 상태가 이어지자 천천히 벽면으로 이동해 측두부와 어깨를 벽에 밀착한다. 흔들림을 억제하듯 기대어 정지한다.\n09:30 — 조도가 올라가자 눈을 감지 못하고 시선이 고정된다. 움직임은 줄었지만 안정이 아니라 경직으로 보인다."
	cctv.feed_texture = load(IMG + "case02_cctv_anchor_temp.png")
	data.cctv_data = cctv

	var experiments: Array = [
		["LIGHT_LOW", "조도 감소 시험", "실내 조명을 저조도로 낮추고 60초 관찰한다. 소리·기류·진동은 바꾸지 않는다.", "안구 고정과 경부 긴장이 약간 줄었고 호흡이 완만해졌다. 눈의 노출이 조금 줄었으나 머리 압박 행동은 그대로 유지되었다.", "case02_exp_light_temp.png"],
		["AIRFLOW_HIGH", "공조 기류 증가 시험", "환기량과 공조 풍량을 올리고 30초 관찰한다. 조명과 소리는 바꾸지 않는다.", "즉시 불안정 반응이 나타났다. 머리 압박이 강해지고 시선이 상부로 고정되더니 급격한 보행이 이어졌다. 환기구 방향 확인과 벽 접촉이 늘었다.", "case02_exp_air_temp.png"],
		["VIBRO_LOW", "저주파 진동 시험", "바닥을 통한 약한 반복 진동을 20초 가한다. 소리 크기는 올리지 않는다.", "소리 크기와 무관하게 반응이 급증했다. 웅크림이 무너지고 비정상적인 도약 준비 자세가 나타났다. 발과 손의 접지점이 불안정해지고 머리를 강하게 눌렀다.", "case02_exp_vibro_temp.png"],
		["SOUNDPROOF", "반향 감소 시험", "실내 반향을 억제하고 외부 소음을 차단한 채 90초 관찰한다.", "단독으로는 완전히 안정되지 않았으나 이동 빈도가 줄었다. 벽 접촉 뒤 장시간 정지했고 근본적인 압박 행동은 남았다.", "case02_exp_soundproof_temp.png"],
		["TEMP_LOW", "저온 시험", "실내 온도를 약 12°C까지 낮추고 90초 관찰한다. 조명·기류·소리는 바꾸지 않는다.", "근육 긴장과 경직이 늘어났다. 머리 압박은 유지되었고 움직임은 줄었지만 안정이 아니라 굳은 상태였다. 손발 끝이 가늘게 떨렸다.", "case02_exp_temp_temp.png"],
	]
	for row: Array in experiments:
		var experiment := ExperimentData.new()
		experiment.experiment_id = "EXP_SC01_" + row[0]
		experiment.display_name = row[1]
		experiment.description = "[임시 실험 / 원격 절차]\n실행 전 안내: " + row[2]
		experiment.result_text = "[실행 기록 / TEMP]\n" + row[3]
		experiment.result_texture = load(IMG + row[4])
		data.available_experiments.append(experiment)

	var rooms: Array = [
		["STD", "ROOM A · 표준 격리실", "조도: 중간 / 방음: 없음 / 기류: 표준 / 온도: 약 22°C / 습도: 45%", "INC_SC01_VENT_SHAFT"],
		["LOWLIGHT_HUMID", "ROOM B · 저조도 습윤실", "조도: 낮음 / 방음: 약함 / 기류: 표준 / 온도: 약 21°C / 습도: 70%", "INC_SC01_VENT_SHAFT"],
		["SOUND_DAMP_LOW_AIR", "ROOM C · 방음 고정실", "조도: 중간 / 방음: 강함 / 기류: 낮음 / 온도: 약 22°C / 습도: 45%", ""],
		["COLD_DAMP_LOW_AIR", "ROOM D · 저온 억제실", "조도: 낮음 / 방음: 강함 / 기류: 낮음 / 온도: 약 12°C / 습도: 40%", "NONE"],
	]
	for row: Array in rooms:
		var room := ContainmentData.new()
		room.room_id = "ROOM_SC01_" + row[0]
		room.display_name = row[1]
		room.description = row[2]
		data.available_containment_rooms.append(room)
		var outcome := MonitoringOutcomeData.new()
		outcome.room_id = room.room_id
		var correct: bool = row[3] == ""
		outcome.final_result = MonitoringOutcomeData.Result.SUCCESS if correct else MonitoringOutcomeData.Result.FAILURE
		# The sheet sends A and B to the vent-shaft escape; D (wrong, untested cause) only deteriorates.
		outcome.incident_id = "" if correct or row[3] == "NONE" else row[3]
		outcome.failure_without_incident = row[3] == "NONE"
		data.containment_outcomes.append(outcome)

	var disturbance := EnvironmentalDisturbanceData.new()
	disturbance.disturbance_id = "DIST_SC01_VENT"
	disturbance.display_name = "[임시·초안] SC-01 격리실 공조 이상"
	disturbance.notice_text = "[TEMP / DRAFT / NON-CANON]\nPHASE 1 — 머리 압박이 강해지고 입 개방이 커졌다. 천장과 환기구를 확인하는 빈도가 늘었다.\n\nPHASE 2 — 벽 접촉이 반복되고 한쪽 다리에 체중을 과하게 싣는 도약 준비 자세가 보였다. 문 주변과 배기구 주변을 탐색한다.\n\nPHASE 3 — 금속 패널 충돌음이 들리고 CCTV 프레임이 흔들렸다. 공조 상태 경고가 발생했다. 아직 격리 이탈은 확인되지 않았다. 다음 업무 관찰 중 후속 확인을 기다린다."
	disturbance.condition_change_text = "SC-01 격리실의 공조·구조 진동 증가. 현재 업무 중인 다른 대상의 조건이 바뀌었다는 관찰 근거는 없다."
	var incident := IncidentData.new()
	incident.incident_id = "INC_SC01_VENT_SHAFT"
	incident.display_name = "[임시·초안] SC-01 격리 이탈 확인"
	incident.description = "PHASE 4 — 실제 격리 이탈 확인. 배기 덕트 보호망과 상부 설비를 반복해서 타격하던 SC-01이 접힌 자세를 풀며 상부 환기 통로 인근 보수 구역으로 이동했다. 넓은 공간으로 돌진하지 않고 벽면과 파이프를 따라 이동하며 주기적으로 머리를 눌러 정지한다.\n\n진동이 강한 설비 근처에서 다시 격해진다. 사람은 냄새가 아니라 발소리·설비 진동·금속 울림으로 찾는다. 위협을 감지하면 직선 추격보다 도약 후 압착에 가까운 충돌 행동을 보이며, 긴 사지로 모서리 너머를 먼저 짚고 몸을 끌어온다.\n\n위험 자극은 뛰는 발걸음, 금속 난간 진동, 작동 중인 휴대 장비다. 유지보수 인원의 피해 규모는 조사 중이다."
	incident.broadcast_id = "BROADCAST_SC01_EVACUATION"
	incident.environmental_disturbance = disturbance
	data.incidents.append(incident)

	var broadcast := EmergencyBroadcastData.new()
	broadcast.broadcast_id = incident.broadcast_id
	broadcast.display_name = "[임시] SC-01 직원 대피 방송"
	broadcast.prompt_text = "실제 격리 이탈이 확인되었다. 상부 설비 구역의 유지보수 직원과 인접 구역에 전달할 지시를 작성한다. 선택은 현장 피해를 확인한 결과가 아니다."
	broadcast.warning_text = "[TEMP / DRAFT / NON-CANON] 상부 유지보수 구역에 알린다. 대상 SC-01의 격리 이탈이 확인되었다. 다음 지시에 따라 행동하라. 인명 피해는 조사 중이다."
	var questions: Array = [
		["BQ_SC01_EVACUATION", "상부 설비 구역에 탈출 개체가 확인되었다. 같은 구역에 있는 유지보수 직원에게 어떤 행동을 우선하도록 지시할 것인가?", [
			["큰 소리로 구조 요청하며 빠르게 계단을 내려간다.", "큰 소리로 구조를 요청하며 빠르게 계단을 내려가라."],
			["벽면에 밀착해 움직임을 줄이고, 가능한 한 진동이 적은 경로로 후퇴한다.", "상부 유지보수 구역 직원은 즉시 이동 속도를 줄이고 벽면에 밀착하십시오. 금속 구조물 접촉과 고속 이동을 피한 채 저진동 경로로 후퇴하십시오."],
			["손전등을 비추어 시야를 확보한 뒤 개체를 주시하며 이동한다.", "손전등으로 시야를 확보하고 개체를 주시하며 이동하라."],
			["금속 배관을 두드려 개체를 반대 방향으로 유도한다.", "금속 배관을 두드려 개체를 반대 방향으로 유도하라."],
		]],
		["BQ_SC01_FACILITY", "개체가 공조 구역 쪽으로 이동 중이다. 인접 직원과 시설에는 어떤 조치를 지시할 것인가?", [
			["인접 공조기를 최대 출력으로 가동한다.", "인접 공조기를 최대 출력으로 가동하라."],
			["복도 조명을 최대로 올린다.", "복도 조명을 최대로 올려라."],
			["해당 구역의 공조 풍량을 낮추고 출입문을 닫은 채 소음 발생을 최소화한다.", "인접 구역 공조 출력을 낮추고 불필요한 음향 경보를 중지하십시오. 출입문을 폐쇄한 상태로 자극을 최소화하십시오."],
			["비상 경보음을 계속 유지한다.", "비상 경보음을 계속 유지하라."],
		]],
	]
	for row: Array in questions:
		var question := BroadcastQuestionData.new()
		question.question_id = row[0]
		question.prompt_text = row[1]
		for i: int in range(4):
			var option := BroadcastOptionData.new()
			option.option_id = question.question_id + "_" + str(i)
			option.display_text = row[2][i][0]
			option.instruction_text = row[2][i][1]
			question.options.append(option)
		broadcast.questions.append(question)
	for first: int in range(4):
		for second: int in range(4):
			var index: int = first * 4 + second
			var result := IncidentResultData.new()
			result.result_id = "RESULT_SC01_" + str(index)
			result.display_name = "[임시·초안] SC-01 사고 후속 보고"
			var assessment: String
			if first == 1 and second == 2:
				assessment = "직원들이 이동 속도를 줄이고 벽면에 밀착해 저진동 경로로 후퇴했고 공조 출력과 경보음이 낮아져 개체의 반응이 완만해졌다. 최종 인명 피해는 확인되지 않았다."
			elif first == 1 or second == 2:
				assessment = "일부 지시는 진동·기류 자극을 줄이는 방향이었으나 다른 지시가 고속 이동, 광자극, 금속 접촉 또는 기류·경보 자극을 남겼다. 직원 일부의 충돌 노출 여부를 조사해야 한다."
			else:
				assessment = "고속 이동, 광자극, 금속 접촉, 기류 증가 또는 경보 유지 지시가 개체의 반응을 키웠다. 접근 구역 확대와 피해 가능성에 대한 추가 조사가 필요하다."
			result.description = "[TEMP / DRAFT / NON-CANON]\n사고 원인: 부적절한 격리 환경에서의 지속적 기류·구조진동 노출과 상부 환기 설비 접촉.\n\n대응 검토: " + assessment + "\n\n송출한 지시:\n" + broadcast.questions[0].options[first].instruction_text + "\n" + broadcast.questions[1].options[second].instruction_text + "\n\n조치 상태: 보고 완료 / 후속 점검 대기. 원래 격리 실패는 방송 대응과 별개의 이력으로 유지한다."
			result.facility_damage = "배기 덕트 보호망과 상부 설비 손상 확인. 추가 손상 범위는 조사 중. 공조 구역 폐쇄 검토."
			result.additional_observation = assessment + " 사망·부상 인원은 UNKNOWN이며 0명으로 단정하지 않는다."
			data.incident_results.append(result)
			var outcome := BroadcastOutcomeData.new()
			outcome.option_id = "SC01_COMBINATION_" + str(index)
			outcome.answers[broadcast.questions[0].question_id] = broadcast.questions[0].options[first].option_id
			outcome.answers[broadcast.questions[1].question_id] = broadcast.questions[1].options[second].option_id
			outcome.display_text = broadcast.compose(outcome.answers)
			outcome.result_id = result.result_id
			broadcast.outcomes.append(outcome)
	data.emergency_broadcasts.append(broadcast)

	_add(0, "RL_SC01_PROFILE_01", profile.profile_id, "정중 두개 파열과 자기 압박", "SC-01은 정중 두개 파열과 자기 압박 행동을 보인다.")
	_add(0, "RL_SC01_PROFILE_02", profile.profile_id, "공조 환경에서의 악화", "공조 작동 환경에서 상태 악화 기록이 있다.")
	_add(0, "RL_SC01_PROFILE_03", profile.profile_id, "가습 환경 시험 기록", "가습 환경에서도 두부 압박과 환기구 주시는 줄지 않았다는 이전 기록이 있다.")
	_add(1, "RL_SC01_CCTV_01", cctv.camera_id, "환기구 주시", "환기구 방향을 주시하는 행동이 확인되었다.")
	_add(1, "RL_SC01_CCTV_02", cctv.camera_id, "벽면 밀착", "벽면에 밀착하는 행동이 반복된다.")
	_add(1, "RL_SC01_CCTV_03", cctv.camera_id, "가습 환경 관찰", "가습 장치 작동 중에도 환기구 주시와 머리 압박은 달라지지 않았다.")
	_add(2, "RL_SC01_EXP_LIGHT_LOW", "EXP_SC01_LIGHT_LOW", "조도 감소 시험", "저조도는 시각 긴장만 완화했고 자기 압박 행동은 지속되었다.")
	_add(2, "RL_SC01_EXP_AIRFLOW_HIGH", "EXP_SC01_AIRFLOW_HIGH", "공조 기류 증가 시험", "공조 기류 상승 후 불안정 반응이 빠르게 증가했다.")
	_add(2, "RL_SC01_EXP_VIBRO_LOW", "EXP_SC01_VIBRO_LOW", "저주파 진동 시험", "저강도 구조진동만으로도 강한 반응이 유발되었다. 청각 단독 자극보다 영향이 크다.")
	_add(2, "RL_SC01_EXP_SOUNDPROOF", "EXP_SC01_SOUNDPROOF", "반향 감소 시험", "반향 감소 시 운동성은 줄지만 근본적인 압박 행동은 남아 있다.")
	_add(2, "RL_SC01_EXP_TEMP_LOW", "EXP_SC01_TEMP_LOW", "저온 시험", "저온에서 근육 긴장과 경직이 증가했다. 자극은 줄었으나 안정화로 보기 어렵다.")
	_add(11, "RL_SC01_CONTAINMENT_SUCCESS", "ROOM_SC01_SOUND_DAMP_LOW_AIR", "격리 환경 안정", "SC-01은 저기류·방음 환경에서 두부 압박 행동이 점차 완만해지고 장시간 정지 상태를 유지했다. 벽면 고정 뒤 불규칙한 체위 변경이 멈췄다.")
	_add(11, "RL_SC01_CONTAINMENT_FAIL_STD", "ROOM_SC01_STD", "격리 환경 부적합: 기류·진동 노출", "표준 격리실의 기본 공조와 반향이 유지되어 SC-01의 머리 압박과 환기구 확인 빈도가 증가했다.")
	_add(11, "RL_SC01_CONTAINMENT_FAIL_HUMID", "ROOM_SC01_LOWLIGHT_HUMID", "격리 환경 부적합: 기류 문제 잔존", "저조도·습윤 환경은 시각과 피부 긴장만 완화했다. 핵심 기류 문제가 남아 불안정화가 진행되었다.")
	_add(11, "RL_SC01_CONTAINMENT_FAIL_COLD", "ROOM_SC01_COLD_DAMP_LOW_AIR", "격리 환경 부적합: 저온 경직", "자극은 줄었으나 저온 환경에서 근육 긴장과 경직이 증가했다. 탈출은 없다.")
	_add(4, "RL_SC01_INCIDENT_01", incident.incident_id, "격리 이탈 후 이동", "부적절한 격리 환경에서 구조물 충돌과 상부 통로 이동이 확인되었다. 벽면과 파이프를 따라 이동하며 진동이 강한 설비 근처에서 다시 격해진다.")
	_add(5, "RL_SC01_BROADCAST_01", broadcast.broadcast_id, "현장 위험 자극", "뛰는 발걸음, 금속 난간 진동, 작동 중인 휴대 장비는 현장 위험을 키운다.")
	_add(6, "RL_SC01_BROADCAST_02", broadcast.questions[1].options[2].option_id, "저자극 대응", "벽면 밀착과 저진동 경로 후퇴, 공조 출력 저감이 직접 대면보다 위험을 줄인다.")

	var broadcast_error: String = broadcast.get_validation_error(data.incident_results)
	assert(broadcast_error.is_empty(), broadcast_error)
	assert(ResourceSaver.save(data, "res://resources/cases/temp_case_02.tres") == OK)

	var campaign := CampaignData.new()
	campaign.campaign_id = "TEMP_CASE01_PLAYTEST"
	campaign.display_name = "임시 케이스 1·2 테스트 / TEMP"
	var order: Array = [
		["CASE01_ENTRY", "res://resources/cases/temp_case_01.tres"],
		["CASE02_ENTRY", "res://resources/cases/temp_case_02.tres"],
		["CASE01_NEXT_T04", "res://resources/cases/temp_t04_case.tres"],
		["CASE01_FOLLOWUP_01", "res://resources/cases/test_case_01.tres"],
		["CASE01_FOLLOWUP_02", "res://resources/cases/test_case_02.tres"],
		["CASE01_FOLLOWUP_03", "res://resources/cases/test_case_03.tres"],
	]
	for row: Array in order:
		var entry := CampaignEntryData.new()
		entry.entry_id = row[0]
		entry.case_data = load(row[1])
		campaign.entries.append(entry)
	var error: String = campaign.get_validation_error()
	assert(error.is_empty(), error)
	assert(ResourceSaver.save(campaign, "res://resources/campaigns/temp_case01_playtest.tres") == OK)
	print("PASS: Case 02 (SC-01) authored; 5 experiments (limit 3), 4 rooms, 16 broadcast outcomes, ", data.research_entries.size(), " research entries; campaign of ", order.size(), " entries")
	quit()


func _add(kind: int, id: String, source: String, title: String, text: String) -> void:
	var entry := ResearchEntryData.new()
	entry.entry_id = id
	entry.source_kind = kind
	entry.source_id = source
	entry.title = title
	entry.body_text = "[TEMP / DRAFT / NON-CANON]\n" + text
	data.research_entries.append(entry)


func _profile_text() -> String:
	return "PROFILE DOCUMENT — SUBJECT SC-01\nDOCUMENT ID: PR-SC-01\nSUBJECT ID: SC-01\nCLASSIFICATION: Humanoid / Sensory-Pressure Instability\nACCESS: LEVEL 2\nDATE: 1991.01.14\nAUTHOR: Dr. █████\n\n외형 설명\n피험체는 비정상적으로 연장된 상·하지와 심각한 체중 저하 양상을 보인다. 두개 정중선에 개방성 균열이 존재하며, 안정 시에도 양손으로 측두 및 두정부를 압박하는 자세를 유지한다. 안구는 지속적으로 노출된 상태이며, 광자극 또는 설비 작동음 이후 돌출 정도가 증가하는 경향이 확인되었다.\n\n확보 및 검진 기록\n초기 관찰 단계에서 피험체는 밀집된 소음 환경보다, 환기 설비가 지속적으로 작동하는 공간에서 더 빠른 불안정 반응을 보였다. 피험체는 청각 자극 자체보다 공간 내 진동 및 공기 흐름 변화에 민감할 가능성이 있다.\n\n관찰 사실\n- 머리 압박 행동은 대부분의 시간 동안 유지된다.\n- 벽체 또는 바닥면에 신체 일부를 밀착하는 행동이 반복된다.\n- 정적인 공간에서는 장시간 움직이지 않는다.\n- 공조 설비 가동 이후 입 개방, 경부 신전, 안구 고정, 급격한 체위 변경이 증가한다.\n\n이전 연구자 소견\n피험체의 이상행동은 단순 청각 과민이 아니라, 두개 내 압력 조절 실패 또는 진동 전도 과민성과 연관된 것으로 보인다. 직접적인 물리 구속은 일시적으로만 효과가 있었으며, 장기적으로는 환경 자극 조절이 더 유효했다. 피부 건조 완화를 위해 가습 환경(습도 약 70%)을 시험한 기간에도 머리 압박과 환기구 주시 행동은 줄지 않았다.\n\n사고 기록 요약\n격리 이전 임시 관찰실에서 환기 장치 점검 중 돌발 충돌 행동 발생. 피험체는 벽면 상부 구조물에 반복적으로 머리를 접촉한 후, 배기 덕트 방향으로 비정상적 도약 시도.\n\n수정 이력 / 검열\n- 피험자 확보 장소 █████\n- 전담 연구원 이름 █████"
