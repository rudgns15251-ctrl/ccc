extends "res://scripts/main/m5_a_visual_playtest.gd"

const T04: CaseData = preload("res://resources/cases/temp_t04_case.tres")

func _create_facility_control() -> Node:
	return preload("res://scripts/presentation/t04_presentation.gd").new()


func _show_view(stage: int, discover_displayed_source: bool = true, restoring_work: bool = false, presentation_only: bool = false) -> void:
	super._show_view(stage, discover_displayed_source, restoring_work, presentation_only)
	# A/C are confirmed only at the next work observation, never on approval.
	if stage == Stage.CCTV and current_case != T04 and case_runtime != null:
		_reveal_t04_resolution.call_deferred(false)


func _try_present_candidate_disturbance(source_case_id: String) -> bool:
	var presented: bool = super._try_present_candidate_disturbance(source_case_id)
	if presented and source_case_id == T04.case_id:
		_reveal_t04_resolution(true)
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


func _reveal_t04_resolution(breach_warning: bool) -> void:
	if not is_inside_tree() or containment_resolutions == null or current_case == T04:
		return
	var resolution: Dictionary = containment_resolutions.get_resolution(T04.case_id)
	if resolution.is_empty():
		return
	if not resolution.incident_id.is_empty() and not breach_warning:
		return
	var ids: Array[String] = []
	for entry: ResearchEntryData in T04.research_entries:
		if entry.source_kind == ResearchEntryData.SourceKind.CONTAINMENT_RESULT and entry.source_id == resolution.room_id:
			ids.append(entry.entry_id)
	research_archive.merge_case_discoveries(T04.case_id, ids)
	_refresh_shell()


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
	for entry: ResearchEntryData in T04.research_entries:
		if entry.source_kind == ResearchEntryData.SourceKind.CONTAINMENT_RESULT and research_archive.has_discovered_entry(T04.case_id, entry.entry_id):
			var result: int = containment_resolutions.get_resolution(T04.case_id).get("result", 0)
			GameText.set_text(status, "%s · T04 후속 관찰: %s · 기록 보관함에서 확인", [status.text, "안정화 확인" if result == MonitoringOutcomeData.Result.SUCCESS else "격리 부적합 확인"])
			return


func _on_containment_confirmation_requested(room_id: String, containment_view: ContainmentView) -> void:
	super._on_containment_confirmation_requested(room_id, containment_view)
	if current_case == T04 and case_runtime.has_confirmed_containment():
		var status: Label = containment_view.get_node("%SelectionStatus")
		status.text += "\n초기 관찰: 직립 정지와 팔끝의 미세 움직임. 초기 정지만으로 장기 결과를 판단하지 않는다."
