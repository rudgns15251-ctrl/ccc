extends "res://scripts/main/m5_a_visual_playtest.gd"

# Playtest entry for the TEMP preview cases (T04 and Case 01). The campaign, not this script, decides which
# cases run; every tracked case below gets its delayed containment result revealed the same way.
const T04: CaseData = preload("res://resources/cases/temp_t04_case.tres")
const CASE01: CaseData = preload("res://resources/cases/temp_case_01.tres")
const TRACKED: Array[CaseData] = [CASE01, T04]
const LABELS := {"TEMP_T04_CASE": "T04", "TEMP_CASE_01": "01"}
const INITIAL_HINTS := {
	"TEMP_T04_CASE": "초기 관찰: 직립 정지와 팔끝의 미세 움직임. 초기 정지만으로 장기 결과를 판단하지 않는다.",
	"TEMP_CASE_01": "초기 관찰: 확인 시점의 상태는 안정적으로 보인다. 장기 결과는 이후 업무 중 후속 관찰로 확인된다.",
}

func _create_facility_control() -> Node:
	return preload("res://scripts/presentation/t04_presentation.gd").new()


func _show_view(stage: int, discover_displayed_source: bool = true, restoring_work: bool = false, presentation_only: bool = false) -> void:
	super._show_view(stage, discover_displayed_source, restoring_work, presentation_only)
	# Non-escape results are confirmed only at the next work observation, never on approval.
	if stage == Stage.CCTV and case_runtime != null:
		_reveal_resolutions.call_deferred(false)


func _try_present_candidate_disturbance(source_case_id: String) -> bool:
	var presented: bool = super._try_present_candidate_disturbance(source_case_id)
	if presented:
		for tracked: CaseData in TRACKED:
			if tracked.case_id == source_case_id:
				_reveal_resolutions(true, tracked)
	return presented


func _show_disturbance_notice(disturbance: EnvironmentalDisturbanceData, reaction: CaseDisturbanceReactionData) -> void:
	super._show_disturbance_notice(disturbance, reaction)
	if disturbance.disturbance_id != "DIST_T04_STRUCTURE" or not is_instance_valid(_disturbance_notice):
		return
	# T04's chronological text needs a reading panel, not an 88px status strip.
	var banner: Control = _disturbance_notice.get_node("%Banner")
	banner.anchor_left = 0.1
	banner.anchor_right = 0.9
	banner.anchor_top = 0.2
	banner.anchor_bottom = 0.8
	banner.offset_left = 0
	banner.offset_right = 0
	banner.offset_top = 0
	banner.offset_bottom = 0
	_disturbance_notice.get_node("%DismissButton").size_flags_vertical = Control.SIZE_SHRINK_END


func _reveal_resolutions(breach_warning: bool, only: CaseData = null) -> void:
	if not is_inside_tree() or containment_resolutions == null:
		return
	for tracked: CaseData in TRACKED:
		if tracked == current_case or (only != null and tracked != only):
			continue
		_reveal_resolution(tracked, breach_warning)


func _reveal_resolution(tracked: CaseData, breach_warning: bool) -> void:
	var resolution: Dictionary = containment_resolutions.get_resolution(tracked.case_id)
	if resolution.is_empty():
		return
	if not resolution.incident_id.is_empty() and not breach_warning:
		return
	var ids: Array[String] = []
	var bodies := PackedStringArray()
	for entry: ResearchEntryData in tracked.research_entries:
		if entry.source_kind == ResearchEntryData.SourceKind.CONTAINMENT_RESULT and entry.source_id == resolution.room_id:
			ids.append(entry.entry_id)
			bodies.append(entry.body_text)
	var fresh: bool = ids.any(func(id: String) -> bool: return not research_archive.has_discovered_entry(tracked.case_id, id))
	research_archive.merge_case_discoveries(tracked.case_id, ids)
	_refresh_shell()
	# Non-escape results reach the player as a report the first time they are revealed (not after a reload).
	# An escape is delivered by its own warning notice and incident.
	if fresh and not breach_warning and facility_control != null and facility_control.has_method("show_containment_result"):
		var room_name: String = resolution.room_id
		for room: ContainmentData in tracked.available_containment_rooms:
			if room.room_id == resolution.room_id: room_name = room.display_name
		var success: bool = resolution.result == MonitoringOutcomeData.Result.SUCCESS
		facility_control.show_containment_result({
			"kicker": "후속 관찰 보고 · 대상 %s" % LABELS.get(tracked.case_id, tracked.case_id),
			"verdict": "장기 격리 안정 확인" if success else "격리 환경 부적합 확인 · 탈출 없음",
			"success": success,
			"room": "승인한 격리: " + room_name,
			"body": "\n\n".join(bodies),
		})


func _refresh_shell() -> void:
	super._refresh_shell()
	if not is_inside_tree() or research_archive == null or containment_resolutions == null:
		return
	# Main also refreshes while its child Scenes are leaving the tree.
	if not is_instance_valid(game_shell):
		return
	var status: Control = game_shell.get_node_or_null("%SystemStatus")
	if status == null:
		return
	for tracked: CaseData in TRACKED:
		for entry: ResearchEntryData in tracked.research_entries:
			if entry.source_kind == ResearchEntryData.SourceKind.CONTAINMENT_RESULT and research_archive.has_discovered_entry(tracked.case_id, entry.entry_id):
				var result: int = containment_resolutions.get_resolution(tracked.case_id).get("result", 0)
				GameText.set_text(status, "%s · %s 후속 관찰: %s · 기록 보관함에서 확인", [status.text, LABELS.get(tracked.case_id, tracked.case_id), "안정화 확인" if result == MonitoringOutcomeData.Result.SUCCESS else "격리 부적합 확인"])
				return


func _on_containment_confirmation_requested(room_id: String, containment_view: ContainmentView) -> void:
	super._on_containment_confirmation_requested(room_id, containment_view)
	if current_case != null and INITIAL_HINTS.has(current_case.case_id) and case_runtime.has_confirmed_containment():
		var status: Label = containment_view.get_node("%SelectionStatus")
		# Translate the view's status key first; appending to the raw key would show it untranslated.
		status.text = status.tr(status.text) + "\n" + INITIAL_HINTS[current_case.case_id]
