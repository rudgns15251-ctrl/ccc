class_name IncidentResponseState
extends RefCounted

enum Status { ACTIVE, COMPLETED }

# A single source-aware authority. No Case-only key fallback or Resource storage.
var _responses: Dictionary[String, Dictionary] = {}
var _active_key: String = ""


func _key(source: IncidentSource, incident_id: String) -> String:
	return JSON.stringify([source.origin_kind, source.source_occurrence_id, incident_id])


func has_response(source: IncidentSource, incident_id: String) -> bool:
	return source != null and source.is_valid() and _responses.has(_key(source, incident_id))


func _project(record: Dictionary) -> Dictionary:
	var result: Dictionary = record.duplicate(true)
	if result.get("origin_kind", -1) in [IncidentSource.OriginKind.CASE, IncidentSource.OriginKind.CAMPAIGN_ENTRY]:
		result["source_entry_id"] = result.get("source_occurrence_id", "")
	# Case-only inspection compatibility: derived, never a second key authority.
	if result.get("origin_kind", -1) == IncidentSource.OriginKind.CASE:
		result["source_case_id"] = result.source_definition_id
	return result


func get_active_response() -> Dictionary:
	return _project(_responses.get(_active_key, {}))


func get_responses() -> Array[Dictionary]:
	var records: Array[Dictionary] = []
	for record: Dictionary in _responses.values(): records.append(_project(record))
	return records


func try_begin(source: IncidentSource, incident_id: String, broadcast_id: String) -> bool:
	if source == null or not source.is_valid() or not _active_key.is_empty() or incident_id.strip_edges().is_empty() or broadcast_id.strip_edges().is_empty() or has_response(source, incident_id): return false
	_active_key = _key(source, incident_id)
	var record: Dictionary = source.to_dictionary()
	record.merge({"incident_id": incident_id, "broadcast_id": broadcast_id, "confirmed_option_id": "", "incident_result_id": "", "status": Status.ACTIVE})
	_responses[_active_key] = record
	return true


func try_confirm(source: IncidentSource, incident_id: String, broadcast_id: String, option_id: String, result_id: String) -> bool:
	var response: Dictionary = _responses.get(_active_key, {})
	if source == null or not source.matches(response) or response.get("incident_id", "") != incident_id or response.get("broadcast_id", "") != broadcast_id or not response.get("confirmed_option_id", "").is_empty() or option_id.strip_edges().is_empty() or result_id.strip_edges().is_empty(): return false
	response.confirmed_option_id = option_id
	response.incident_result_id = result_id
	return true


func try_complete(source: IncidentSource, incident_id: String) -> bool:
	var response: Dictionary = _responses.get(_active_key, {})
	if source == null or not source.matches(response) or response.get("incident_id", "") != incident_id or response.get("confirmed_option_id", "").is_empty() or response.get("incident_result_id", "").is_empty(): return false
	response.status = Status.COMPLETED
	_active_key = ""
	return true


func reset() -> void:
	_responses.clear()
	_active_key = ""

# All snapshots belong to the same response and commit at the same boundary.
func try_confirm_multi(source: IncidentSource, incident_id: String, broadcast: EmergencyBroadcastData, answers: Dictionary, result: IncidentResultData) -> bool:
	if broadcast == null or not broadcast.is_multi_question() or result == null or not result.valid_consequences(): return false
	var outcome: BroadcastOutcomeData = broadcast.find_outcome(answers)
	if outcome == null or outcome.result_id != result.result_id: return false
	if not try_confirm(source, incident_id, broadcast.broadcast_id, outcome.option_id, result.result_id): return false
	_responses[_active_key]["broadcast_details"] = {"answers": answers.duplicate(true), "transmitted_text": broadcast.compose(answers), "consequences": result.consequences()}
	return true

static func valid_details(row: Dictionary, broadcast: EmergencyBroadcastData, result: IncidentResultData) -> bool:
	if not broadcast.is_multi_question(): return not row.has("broadcast_details")
	var details: Variant = row.get("broadcast_details")
	if not details is Dictionary or details.size() != 3 or not details.get("answers") is Dictionary or not details.get("transmitted_text") is String or not details.get("consequences") is Dictionary: return false
	var outcome: BroadcastOutcomeData = broadcast.find_outcome(details.answers)
	return outcome != null and outcome.option_id == row.get("confirmed_option_id") and outcome.result_id == row.get("incident_result_id") and result != null and result.result_id == outcome.result_id and details.transmitted_text == broadcast.compose(details.answers) and details.consequences == result.consequences()
