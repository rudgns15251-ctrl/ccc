class_name ContainmentResolutionState
extends RefCounted

var _resolutions: Dictionary[String, Dictionary] = {}
var _case_order: Array[String] = []


func try_record_resolution(case_id: String, room_id: String, result: MonitoringOutcomeData.Result, incident_id: String = "") -> bool:
	if case_id.strip_edges().is_empty() or room_id.strip_edges().is_empty() or has_resolution(case_id):
		return false
	if result != MonitoringOutcomeData.Result.SUCCESS and result != MonitoringOutcomeData.Result.FAILURE:
		return false
	if (result == MonitoringOutcomeData.Result.FAILURE and incident_id.strip_edges().is_empty()) or (result == MonitoringOutcomeData.Result.SUCCESS and not incident_id.is_empty()):
		return false
	_resolutions[case_id] = {"case_id": case_id, "room_id": room_id, "result": result, "incident_id": incident_id}
	_case_order.append(case_id)
	return true


func has_resolution(case_id: String) -> bool:
	return _resolutions.has(case_id)


func get_resolution(case_id: String) -> Dictionary:
	return _resolutions.get(case_id, {}).duplicate(true)


func get_resolved_case_ids() -> Array[String]:
	return _case_order.duplicate()


func reset() -> void:
	_resolutions.clear()
	_case_order.clear()
