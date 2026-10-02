class_name CaseRuntimeState
extends RefCounted

var case_id: String = ""
var _experiment_execution_history: Array[String] = []
var _confirmed_containment_room_id: String = ""


func _init(case_identifier: String = "") -> void:
	reset(case_identifier)


func reset(case_identifier: String = "") -> void:
	case_id = case_identifier
	_experiment_execution_history.clear()
	_confirmed_containment_room_id = ""


func try_record_experiment_execution(experiment_id: String, limit: int) -> bool:
	if experiment_id.strip_edges().is_empty():
		push_warning("CaseRuntimeState: cannot record an empty experiment_id.")
		return false
	if limit < 0:
		push_warning("CaseRuntimeState: experiment_limit is negative; treating it as zero.")
		return false
	if not can_execute_experiment(experiment_id, limit):
		return false
	_experiment_execution_history.append(experiment_id)
	return true


func has_executed_experiment(experiment_id: String) -> bool:
	return _experiment_execution_history.has(experiment_id)


func get_remaining_experiment_count(limit: int) -> int:
	return maxi(maxi(limit, 0) - get_experiment_execution_count(), 0)


func can_execute_experiment(experiment_id: String, limit: int) -> bool:
	return not experiment_id.strip_edges().is_empty() and not has_executed_experiment(experiment_id) and get_remaining_experiment_count(limit) > 0


func get_experiment_execution_history() -> Array[String]:
	return _experiment_execution_history.duplicate()


func get_experiment_execution_count() -> int:
	return _experiment_execution_history.size()


func try_confirm_containment_room(room_id: String) -> bool:
	if room_id.strip_edges().is_empty() or has_confirmed_containment():
		return false
	_confirmed_containment_room_id = room_id
	return true


func has_confirmed_containment() -> bool:
	return not _confirmed_containment_room_id.is_empty()


func get_confirmed_containment_room_id() -> String:
	return _confirmed_containment_room_id
