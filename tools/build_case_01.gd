extends SceneTree

# Authors the TEMP Case 01 playtest Resources (docs/story/case_01_draft_v1.md, 2026-10-18 decisions).
# Run: godot --headless --path . --script res://tools/build_case_01.gd
# Everything here is TEMP / DRAFT / NON-CANON; images are replaceable placeholders.

const CASE_ID := "TEMP_CASE_01"
const IMG := "res://assets/temp/case01/generated/"

var data: CaseData

func _initialize() -> void:
	data = CaseData.new()
	data.case_id = CASE_ID
	data.display_name = "[임시·초안·비정사] SUBJECT 01"
	data.experiment_limit = 2

	var profile := ProfileData.new()
	profile.profile_id = "PROFILE_01"
	profile.subject_name = data.display_name
	profile.classification = "임시 분류 / 광민감 변이형 / 정식 세계관 미편입"
	profile.basic_description = "[TEMP / DRAFT / NON-CANON]\n\n" + _profile_text()
	data.profile_data = profile

	var cctv := CCTVData.new()
	cctv.camera_id = "CAM_01_TEXT_OBSERVATION"
	cctv.camera_label = "CAM 01-01 · 임시 격리실"
	cctv.observation_text = "[TEMP / DRAFT / NON-CANON] 01 관찰 기록. 화면의 장면은 표준 격리실 이미지에 위치 표지만 얹은 임시 이미지이며 대상 사진이 아니다. 열화상은 미제공이다. 판단 근거는 아래 텍스트 관찰이다.\n\n00:00 — 방 구석 그늘에 웅크린 채 정지. 천장 조명 아래로 나오지 않는다.\n03:10 — 바닥의 밝은 구역을 돌아서 이동한다.\n07:40 — 같은 자세. 손으로 눈 위를 가린다."
	cctv.feed_texture = load(IMG + "case01_cctv_anchor_temp.png")
	data.cctv_data = cctv

	var experiments: Array = [
		["LIGHT", "조명", "격리실 조명을 켜고 일정 시간 유지한 뒤 끈다. 소리와 온도는 바꾸지 않는다.", "조명이 켜지자 즉시 몸을 웅크리고 팔로 얼굴을 가렸다. 노출 후 손등이 붉어지고 물집이 올라왔다(영상 일부는 모자이크 처리). 조명을 끈 뒤 자세가 천천히 풀렸다.", "case01_exp_light_temp.png"],
		["SOUND", "경보음", "경보음을 짧게 울린다. 조명과 온도는 바꾸지 않는다.", "고개를 한 번 돌렸을 뿐 자세와 피부에 큰 변화는 없었다. 경보음에 대한 반응은 제한적이었다.", "case01_exp_sound_temp.png"],
		["TEMP", "온도", "실온을 단계적으로 낮췄다가 복구한다. 조명과 소리는 바꾸지 않는다.", "약간 움츠러들었으나 자세와 피부에 변화는 없었다. 온도 변화 자체는 주요 불안정 요인으로 보이지 않는다.", "case01_exp_temp_temp.png"],
	]
	for row: Array in experiments:
		var experiment := ExperimentData.new()
		experiment.experiment_id = "EXP_01_" + row[0]
		experiment.display_name = row[1]
		experiment.description = "[임시 실험 / 원격 절차]\n실행 전 안내: " + row[2]
		experiment.result_text = "[실행 기록 / TEMP]\n" + row[3]
		experiment.result_texture = load(IMG + row[4])
		data.available_experiments.append(experiment)

	# Candidate order is deliberately not "correct answer first".
	var rooms: Array = [
		["QUIET", "후보 A · 방음실", "조도: 일반(점검 시 밝음) / 외부 차음: 강화(약 55dB 감쇠) / 실내 온도: 약 21°C / 감시: 영상 / 기류: 표준", false],
		["DARK", "후보 B · 암실", "조도: 광원 완전 차단 / 외부 차음: 보통(약 35dB 감쇠) / 실내 온도: 약 21°C / 감시: 적외선 카메라로 유지 / 기류: 표준", true],
		["COLD", "후보 C · 냉각실", "조도: 일반(점검 시 밝음) / 외부 차음: 보통(약 35dB 감쇠) / 실내 온도: 약 5°C / 감시: 영상 / 기류: 표준", false],
	]
	for row: Array in rooms:
		var room := ContainmentData.new()
		room.room_id = "ROOM_01_" + row[0]
		room.display_name = row[1]
		room.description = row[2]
		data.available_containment_rooms.append(room)
		var outcome := MonitoringOutcomeData.new()
		outcome.room_id = room.room_id
		outcome.final_result = MonitoringOutcomeData.Result.SUCCESS if row[3] else MonitoringOutcomeData.Result.FAILURE
		# Case 01 is the tutorial: a wrong room worsens the subject, it never escapes.
		outcome.failure_without_incident = not row[3]
		data.containment_outcomes.append(outcome)

	_add(0, "RL_01_PROFILE_01", profile.profile_id, "프로필 요약", "01은 강한 조명에 노출되면 피부가 붉어지고 물집이 생긴다고 기록되어 있다. 반복 노출 시 회복이 느려진다.")
	_add(1, "RL_01_CCTV_01", cctv.camera_id, "관찰 요약", "01은 그늘에 웅크려 조명 아래로 나오지 않고, 눈과 손등을 가린다.")
	_add(2, "RL_01_EXP_LIGHT", "EXP_01_LIGHT", "조명 실험", "강한 조명 노출 시 즉각적인 회피와 피부 반응이 확인되었다.")
	_add(2, "RL_01_EXP_SOUND", "EXP_01_SOUND", "경보음 실험", "경보음에 대한 반응은 제한적이었다.")
	_add(2, "RL_01_EXP_TEMP", "EXP_01_TEMP", "온도 실험", "온도 변화는 주요 불안정 요인으로 보이지 않는다.")
	_add(11, "RL_01_CONTAINMENT_SUCCESS", "ROOM_01_DARK", "격리 환경 안정", "01은 광원이 완전히 차단된 환경에서 안정 상태를 유지했다. 피부 반응은 더 진행되지 않았다. 감시는 적외선 카메라로 유지되었다.")
	_add(11, "RL_01_CONTAINMENT_FAIL_QUIET", "ROOM_01_QUIET", "격리 환경 부적합: 피부 손상 누적", "01의 피부 손상이 누적되어 상태가 악화되었다. 외부 소리를 차단했으나 일반 조도가 유지되었다. 탈출은 없다.")
	_add(11, "RL_01_CONTAINMENT_FAIL_COLD", "ROOM_01_COLD", "격리 환경 부적합: 피부 손상 누적", "01의 피부 손상이 누적되어 상태가 악화되었다. 낮은 온도는 상태를 개선하지 못했고 일반 조도가 유지되었다. 탈출은 없다.")

	assert(ResourceSaver.save(data, "res://resources/cases/temp_case_01.tres") == OK)

	var campaign := CampaignData.new()
	campaign.campaign_id = "TEMP_CASE01_PLAYTEST"
	campaign.display_name = "임시 케이스 1 테스트 / TEMP"
	var order: Array = [
		["CASE01_ENTRY", "res://resources/cases/temp_case_01.tres"],
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
	print("PASS: Case 01 authored; 3 experiments (limit 2), 3 rooms, 8 research entries; campaign of ", order.size(), " entries")
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
	return "PROFILE DOCUMENT — SUBJECT 01\nDOCUMENT ID: ██-01-███\nSUBJECT ID: 01\nCLASSIFICATION: HUMANOID MUTANT / PHOTOSENSITIVE VARIANT\nSECURITY LEVEL: LEVEL 1\nDATE: ████.██.██\nAUTHOR: ██████\nSTATUS: HOLDING / OBSERVATION ACTIVE\n\n1) 개체 기본 정보\n- 접종일: ████.██.██ (검열). 접종 후 외형 변화가 점진적으로 진행됨.\n- 연령대: 성인. 성별 기록은 삭제됨.\n- 신장 약 170cm 전후, 마른 체형.\n- 피부는 얇고 창백하며 전신에 오래된 화상 같은 흔적이 있다. 눈꺼풀과 손등의 손상이 두드러진다.\n\n2) 일반 행동 기록\n- 밝은 곳을 피해 구석이나 구조물 그늘에 앉는다. 이동은 느리고 조용하다.\n- 공격 기록 없음. 접근한 직원에게 얼굴을 돌리거나 팔로 얼굴을 가린다.\n- 말을 하지는 않으나 짧은 숨소리와 낮은 소리를 낸다.\n\n3) 피부 반응 기록\n- 직사 조명에 노출되면 수 분 안에 붉어지고 물집이 생긴다.\n- 조명 해제 후 일부 회복하지만 반복 노출 시 회복 속도가 느려진다.\n\n4) 관리 권고(초안)\n- 격리실은 조도 최소화를 권장한다. 정확한 기준은 추가 관찰 후 확정한다.\n- 정기 검진 시 조명 사용 시간을 기록한다.\n\n5) 비고\n- 개체 번호 외의 식별 정보는 이송 시 분리·보관되었다. 해당 문서는 열람 불가.\nAUTHORIZED COPIES ONLY"
