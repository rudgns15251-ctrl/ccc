extends "res://scripts/main/main.gd"

# Read-only playtest feedback. Main's existing owners still decide all outcomes.
const M2_CASE_ID := "TEMP_M2_CASE_01"


func _refresh_shell() -> void:
	super._refresh_shell()
	if not is_node_ready() or not is_inside_tree() or _developer_terminal.mode != TerminalMode.NONE:
		return
	var status_label: Label = game_shell.get_node_or_null("%SystemStatus") as Label
	if status_label == null:
		return
	var status: String = "M2 research / observations and interpretations are distinct"
	if pending_containment.has_pending(M2_CASE_ID):
		status = "M2 submission recorded / outcome awaits next work handoff"
	elif containment_resolutions.has_resolution(M2_CASE_ID):
		var resolution: Dictionary = containment_resolutions.get_resolution(M2_CASE_ID)
		status = "M2 submission archived / check later observations and Archive"
		if resolution.result == MonitoringOutcomeData.Result.SUCCESS:
			if _current_stage in [Stage.RESEARCH_ARCHIVE_LIST, Stage.RESEARCH_ARCHIVE_DETAIL]:
				status = "M2 recorded observation: stable containment / no escape report"
		else:
			var candidate: Dictionary = failure_candidates.get_candidate(M2_CASE_ID)
			if candidate.get("disturbance_triggered", false) or incident_responses.has_response(_case_response_source(M2_CASE_ID), "TEMP_M2_INCIDENT_ESCAPE"):
				status = "M2 enclosure leakage observed / evacuation does not rewrite the first failure"
	GameText.set_text(status_label, "%s / %s", [_persistent_status(), status])
