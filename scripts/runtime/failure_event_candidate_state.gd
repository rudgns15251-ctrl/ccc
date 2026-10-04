class_name FailureEventCandidateState
extends RefCounted

var _candidates: Dictionary[String, Dictionary] = {}
var _case_order: Array[String] = []


func try_add_candidate(source_case_id: String, incident_id: String, opportunity_threshold: int) -> bool:
	if source_case_id.strip_edges().is_empty() or incident_id.strip_edges().is_empty() or opportunity_threshold < 1 or has_candidate(source_case_id):
		return false
	_candidates[source_case_id] = {"source_case_id": source_case_id, "incident_id": incident_id, "opportunity_threshold": opportunity_threshold, "opportunities_seen": 0, "disturbance_triggered": false}
	_case_order.append(source_case_id)
	return true


func has_candidate(source_case_id: String) -> bool:
	return _candidates.has(source_case_id)


func get_candidate(source_case_id: String) -> Dictionary:
	return _candidates.get(source_case_id, {}).duplicate(true)


func get_candidate_case_ids() -> Array[String]:
	return _case_order.duplicate()


func advance_opportunity(current_case_id: String) -> Array[String]:
	var ready: Array[String] = []
	for source_case_id: String in _case_order:
		var candidate: Dictionary = _candidates[source_case_id]
		if source_case_id == current_case_id or candidate.disturbance_triggered:
			continue
		candidate.opportunities_seen = mini(candidate.opportunities_seen + 1, candidate.opportunity_threshold)
		if candidate.opportunities_seen >= candidate.opportunity_threshold:
			ready.append(source_case_id)
	return ready


func try_mark_disturbance_triggered(source_case_id: String) -> bool:
	if not has_candidate(source_case_id):
		return false
	var candidate: Dictionary = _candidates[source_case_id]
	if candidate.disturbance_triggered or candidate.opportunities_seen < candidate.opportunity_threshold:
		return false
	candidate.disturbance_triggered = true
	return true


func reset() -> void:
	_candidates.clear()
	_case_order.clear()
