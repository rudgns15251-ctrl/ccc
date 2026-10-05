class_name FailureEventCandidateState
extends RefCounted

var _candidates: Dictionary[String, Dictionary] = {}
var _case_order: Array[String] = []


func try_add_candidate(source_case_id: String, incident_id: String, opportunity_threshold: int, major_trigger_threshold: int = 3) -> bool:
	if source_case_id.strip_edges().is_empty() or incident_id.strip_edges().is_empty() or opportunity_threshold < 1 or major_trigger_threshold < 1 or has_candidate(source_case_id):
		return false
	_candidates[source_case_id] = {"source_case_id": source_case_id, "incident_id": incident_id, "opportunity_threshold": opportunity_threshold, "opportunities_seen": 0, "disturbance_triggered": false, "major_opportunity_count": 0, "major_trigger_threshold": major_trigger_threshold, "major_incident_triggered": false}
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


# Called BEFORE this action applies a new disturbance, so that action cannot
# contribute to its own escalation. Main owns safe boundary/deduplication checks.
func advance_major_opportunity(current_case_id: String) -> Array[String]:
	var ready: Array[String] = []
	for source_case_id: String in _case_order:
		var candidate: Dictionary = _candidates[source_case_id]
		if source_case_id == current_case_id or not candidate.disturbance_triggered or candidate.major_incident_triggered:
			continue
		candidate.major_opportunity_count = mini(candidate.major_opportunity_count + 1, candidate.major_trigger_threshold)
		if candidate.major_opportunity_count >= candidate.major_trigger_threshold:
			ready.append(source_case_id)
	return ready


func try_mark_major_triggered(source_case_id: String) -> bool:
	if not has_candidate(source_case_id):
		return false
	var candidate: Dictionary = _candidates[source_case_id]
	if not candidate.disturbance_triggered or candidate.major_incident_triggered or candidate.major_opportunity_count < candidate.major_trigger_threshold:
		return false
	candidate.major_incident_triggered = true
	return true


func remove_completed_candidate(source_case_id: String, incident_id: String) -> bool:
	if not has_candidate(source_case_id):
		return false
	var candidate: Dictionary = _candidates[source_case_id]
	if candidate.incident_id != incident_id or not candidate.major_incident_triggered:
		return false
	_candidates.erase(source_case_id)
	_case_order.erase(source_case_id)
	return true
