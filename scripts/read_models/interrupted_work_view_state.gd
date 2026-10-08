class_name InterruptedWorkViewState
extends RefCounted

# Small validation helper for the four real Views, not a serializer or owner.
# Only primitive UI state is retained. Canonical runtime facts are read, never
# reconstructed from these values. Main owns response/resume lifetime.
static func get_validation_error(stage_id: String, state: Dictionary, data: CaseData, runtime: CaseRuntimeState, pending: PendingContainmentState, resolutions: ContainmentResolutionState) -> String:
	if data == null or runtime == null or runtime.case_id != data.case_id: return "WORK_RUNTIME_MISMATCH"
	var fields: Dictionary = {"focus_path": TYPE_STRING}
	match stage_id:
		"PROFILE": pass
		"CCTV": fields["condition_scroll"] = TYPE_INT
		"EXPERIMENT": fields.merge({"selected_experiment_id": TYPE_STRING, "displayed_result_id": TYPE_STRING, "experiment_scroll": TYPE_INT, "result_scroll": TYPE_INT})
		"CONTAINMENT": fields.merge({"selected_room_id": TYPE_STRING, "confirmed_room_id": TYPE_STRING, "room_scroll": TYPE_INT})
		_: return "UNSUPPORTED_WORK_STAGE"
	if state.size() != fields.size(): return "INVALID_WORK_FIELDS"
	for key: String in fields:
		if not state.has(key) or typeof(state[key]) != fields[key]: return "INVALID_WORK_FIELD_" + key
		if fields[key] == TYPE_INT and state[key] < 0: return "INVALID_WORK_SCROLL"
	if not _valid_focus(stage_id, state.focus_path, data): return "INVALID_WORK_FOCUS"
	if stage_id == "EXPERIMENT":
		var selected: String = state.selected_experiment_id
		var displayed: String = state.displayed_result_id
		if not selected.is_empty() and not displayed.is_empty(): return "SELECTION_RESULT_CONFLICT"
		for id: String in [selected, displayed]:
			if not id.is_empty():
				var count: int = 0
				for item: ExperimentData in data.available_experiments:
					if item != null and item.experiment_id == id: count += 1
				if count != 1: return "INVALID_WORK_EXPERIMENT"
		if not selected.is_empty() and (runtime.has_executed_experiment(selected) or runtime.get_remaining_experiment_count(data.experiment_limit) <= 0): return "INVALID_EXPERIMENT_DRAFT"
		if not displayed.is_empty():
			if not runtime.has_executed_experiment(displayed): return "UNRECORDED_EXPERIMENT_RESULT"
			for id: String in runtime.get_experiment_condition_observation_ids(displayed):
				var count: int = 0
				for observation: ExperimentConditionObservationData in data.experiment_condition_observations:
					if observation != null and observation.observation_id == id and observation.experiment_id == displayed: count += 1
				if count != 1: return "INVALID_RECORDED_OBSERVATION"
	if stage_id == "CONTAINMENT":
		var confirmed: String = runtime.get_confirmed_containment_room_id()
		if state.confirmed_room_id != confirmed or not confirmed.is_empty() and not state.selected_room_id.is_empty(): return "ROOM_SOURCE_CONFLICT"
		for id: String in [state.selected_room_id, confirmed]:
			if not id.is_empty():
				var count: int = 0
				for room: ContainmentData in data.available_containment_rooms:
					if room != null and room.room_id == id: count += 1
				if count != 1: return "INVALID_WORK_ROOM"
		var submitted: String = pending.get_pending_room_id(data.case_id)
		var resolved: String = resolutions.get_resolution(data.case_id).get("room_id", "")
		if not submitted.is_empty() and submitted != confirmed or not resolved.is_empty() and resolved != confirmed: return "ROOM_SOURCE_CONFLICT"
		if not confirmed.is_empty() and submitted.is_empty() and resolved.is_empty(): return "ROOM_OWNER_UNAVAILABLE"
	return ""


static func _valid_focus(stage_id: String, path: String, data: CaseData) -> bool:
	if path.is_empty(): return true
	var actions: Array[String] = ["NextButton", "OpenResearchLogButton"]
	if stage_id in ["EXPERIMENT", "CONTAINMENT"]: actions.append("RecheckCCTVButton")
	if stage_id == "EXPERIMENT": actions.append("RunButton")
	if stage_id == "CONTAINMENT": actions.append("ConfirmButton")
	for name: String in actions:
		if path == ("Margin/Content/RecheckCCTVButton" if name == "RecheckCCTVButton" else "Margin/Content/Actions/RunButton" if name == "RunButton" else "Margin/Content/Actions/" + name): return true
	if stage_id == "EXPERIMENT":
		for index: int in range(data.available_experiments.size()):
			if path == "Margin/Content/Workspace/Catalog/ExperimentScroll/ExperimentList/Experiment%d/Select" % index: return true
	if stage_id == "CONTAINMENT":
		for index: int in range(data.available_containment_rooms.size()):
			if path == "Margin/Content/RoomScroll/RoomList/Room%d/Select" % index: return true
	return false
