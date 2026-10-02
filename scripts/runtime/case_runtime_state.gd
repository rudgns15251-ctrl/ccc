class_name CaseRuntimeState
extends RefCounted

var case_id: String = ""
var _experiment_execution_history: Array[String] = []


func _init(case_identifier: String = "") -> void:
	reset(case_identifier)


func reset(case_identifier: String = "") -> void:
	case_id = case_identifier
	_experiment_execution_history.clear()


func record_experiment_execution(experiment_id: String) -> bool:
	if experiment_id.strip_edges().is_empty():
		push_warning("CaseRuntimeState: cannot record an empty experiment_id.")
		return false
	_experiment_execution_history.append(experiment_id)
	return true


func get_experiment_execution_history() -> Array[String]:
	return _experiment_execution_history.duplicate()


func get_experiment_execution_count() -> int:
	return _experiment_execution_history.size()
