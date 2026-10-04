class_name CaseRuntimeState
extends RefCounted

var case_id: String = ""
var _experiment_execution_history: Array[String] = []
var _confirmed_containment_room_id: String = ""
var _monitoring_result: MonitoringOutcomeData.Result = MonitoringOutcomeData.Result.UNDEFINED
var _confirmed_broadcast_id: String = ""
var _confirmed_broadcast_option_id: String = ""
var _discovered_research_entry_ids: Array[String] = []
var _applied_disturbances: Array[Dictionary] = []
# Actual source exposure order, including fallback sources without authored entry IDs.
var _observed_research_sources: Array[Dictionary] = []


func _init(case_identifier: String = "") -> void:
	reset(case_identifier)


func reset(case_identifier: String = "") -> void:
	case_id = case_identifier
	_experiment_execution_history.clear()
	_confirmed_containment_room_id = ""
	_monitoring_result = MonitoringOutcomeData.Result.UNDEFINED
	_confirmed_broadcast_id = ""
	_confirmed_broadcast_option_id = ""
	_discovered_research_entry_ids.clear()
	_applied_disturbances.clear()
	_observed_research_sources.clear()


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


func has_monitoring_result() -> bool:
	return _monitoring_result != MonitoringOutcomeData.Result.UNDEFINED


func get_monitoring_result() -> MonitoringOutcomeData.Result:
	return _monitoring_result


func try_set_monitoring_result(result: MonitoringOutcomeData.Result) -> bool:
	if result != MonitoringOutcomeData.Result.SUCCESS and result != MonitoringOutcomeData.Result.FAILURE:
		return false
	if has_monitoring_result():
		return false
	_monitoring_result = result
	return true


func try_confirm_broadcast_option(broadcast_id: String, option_id: String) -> bool:
	if broadcast_id.strip_edges().is_empty() or option_id.strip_edges().is_empty() or has_confirmed_broadcast_option():
		return false
	_confirmed_broadcast_id = broadcast_id
	_confirmed_broadcast_option_id = option_id
	return true


func has_confirmed_broadcast_option() -> bool:
	return not _confirmed_broadcast_id.is_empty() and not _confirmed_broadcast_option_id.is_empty()


func get_confirmed_broadcast_id() -> String:
	return _confirmed_broadcast_id


func get_confirmed_broadcast_option_id() -> String:
	return _confirmed_broadcast_option_id


func try_discover_research_entry(entry_id: String) -> bool:
	if entry_id.strip_edges().is_empty() or has_discovered_research_entry(entry_id):
		return false
	_discovered_research_entry_ids.append(entry_id)
	return true


func has_discovered_research_entry(entry_id: String) -> bool:
	return _discovered_research_entry_ids.has(entry_id)


func get_discovered_research_entry_ids() -> Array[String]:
	return _discovered_research_entry_ids.duplicate()


func try_apply_disturbance(disturbance_id: String, reaction_id: String = "") -> bool:
	if disturbance_id.strip_edges().is_empty():
		return false
	for record: Dictionary in _applied_disturbances:
		if record.disturbance_id == disturbance_id and record.reaction_id == reaction_id:
			return false
	_applied_disturbances.append({"disturbance_id": disturbance_id, "reaction_id": reaction_id})
	return true


func get_applied_disturbances() -> Array[Dictionary]:
	return _applied_disturbances.duplicate(true)


func try_observe_research_source(source_kind: int, source_id: String) -> bool:
	if not ResearchEntryData.SourceKind.values().has(source_kind) or source_id.strip_edges().is_empty() or has_observed_research_source(source_kind, source_id):
		return false
	_observed_research_sources.append({"source_kind": source_kind, "source_id": source_id})
	return true


func has_observed_research_source(source_kind: int, source_id: String) -> bool:
	for record: Dictionary in _observed_research_sources:
		if record.source_kind == source_kind and record.source_id == source_id:
			return true
	return false


func get_observed_research_sources() -> Array[Dictionary]:
	return _observed_research_sources.duplicate(true)
