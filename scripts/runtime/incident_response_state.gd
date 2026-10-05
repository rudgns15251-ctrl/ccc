class_name IncidentResponseState
extends RefCounted

enum Status { ACTIVE, COMPLETED }

# Session records contain identifiers and status only; never authored Resources.
var _responses: Dictionary[String, Dictionary] = {}
var _active_key: String = ""


func _key(source_case_id: String, incident_id: String) -> String:
	return JSON.stringify([source_case_id, incident_id])


func has_response(source_case_id: String, incident_id: String) -> bool:
	return _responses.has(_key(source_case_id, incident_id))


func get_active_response() -> Dictionary:
	return _responses.get(_active_key, {}).duplicate(true)


func get_responses() -> Array[Dictionary]:
	var records: Array[Dictionary] = []
	for record: Dictionary in _responses.values():
		records.append(record.duplicate(true))
	return records


func try_begin(source_case_id: String, incident_id: String, broadcast_id: String) -> bool:
	if not _active_key.is_empty() or source_case_id.strip_edges().is_empty() or incident_id.strip_edges().is_empty() or broadcast_id.strip_edges().is_empty() or has_response(source_case_id, incident_id):
		return false
	_active_key = _key(source_case_id, incident_id)
	_responses[_active_key] = {"source_case_id": source_case_id, "incident_id": incident_id, "broadcast_id": broadcast_id, "confirmed_option_id": "", "incident_result_id": "", "status": Status.ACTIVE}
	return true


func try_confirm(source_case_id: String, incident_id: String, broadcast_id: String, option_id: String, result_id: String) -> bool:
	var response: Dictionary = _responses.get(_active_key, {})
	if response.is_empty() or response.source_case_id != source_case_id or response.incident_id != incident_id or response.broadcast_id != broadcast_id or not response.confirmed_option_id.is_empty() or option_id.strip_edges().is_empty() or result_id.strip_edges().is_empty():
		return false
	response.confirmed_option_id = option_id
	response.incident_result_id = result_id
	return true


func try_complete(source_case_id: String, incident_id: String) -> bool:
	var response: Dictionary = _responses.get(_active_key, {})
	if response.is_empty() or response.source_case_id != source_case_id or response.incident_id != incident_id or response.confirmed_option_id.is_empty() or response.incident_result_id.is_empty():
		return false
	response.status = Status.COMPLETED
	_active_key = ""
	return true


func reset() -> void:
	_responses.clear()
	_active_key = ""
