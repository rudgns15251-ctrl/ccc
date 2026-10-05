class_name TestSequenceDispositionSnapshot
extends RefCounted

# Developer inspection only. Copies of facts, never a closure or gameplay owner.
# All output values are identifiers/primitives; authored Resources are lookup inputs only.
const BOUNDARY_KIND: String = "TEST_SEQUENCE_END"

var _facts: Dictionary = {}


func _init(facts: Dictionary = {}) -> void:
	_facts = facts.duplicate(true)


func to_dictionary() -> Dictionary:
	return _facts.duplicate(true)


static func build(facts: Dictionary, pending: Array[Dictionary], resolutions: Array[Dictionary], candidates: Array[Dictionary], responses: Array[Dictionary], lookup_case: Callable, lookup_content: Callable) -> TestSequenceDispositionSnapshot:
	var projected: Dictionary = facts.duplicate(true)
	projected["boundary_kind"] = BOUNDARY_KIND
	projected["pending_submissions"] = []
	projected["resolutions"] = resolutions.duplicate(true)
	projected["unresolved_candidates"] = []
	projected["completed_responses"] = []
	for record: Dictionary in pending:
		projected.pending_submissions.append(_pending_entry(record, resolutions, candidates, lookup_case, lookup_content))
	for record: Dictionary in responses:
		if record.status == IncidentResponseState.Status.COMPLETED:
			var completed: Dictionary = record.duplicate(true)
			completed["phase"] = "COMPLETED"
			projected.completed_responses.append(completed)
	for index: int in range(candidates.size()):
		var record: Dictionary = candidates[index]
		# Completion is evidenced by the response record, never inferred from absence
		# of candidates or reconstructed from a hidden FAILURE resolution.
		if _has_completed_response(record, responses):
			continue
		projected.unresolved_candidates.append(_candidate_entry(record, index, resolutions, projected.active_response, lookup_case, lookup_content))
	return TestSequenceDispositionSnapshot.new(projected)


static func _pending_entry(record: Dictionary, resolutions: Array[Dictionary], candidates: Array[Dictionary], lookup_case: Callable, lookup_content: Callable) -> Dictionary:
	var entry: Dictionary = record.duplicate(true)
	entry["has_valid_outcome"] = false
	entry["classification"] = "INVALID_SUBMISSION_REFERENCE"
	entry["reference_issue"] = "UNAVAILABLE_CASE"
	var source: CaseData = lookup_case.call(record.case_id) as CaseData
	if source == null:
		return entry
	var room: ContainmentData = lookup_content.call(source.available_containment_rooms, "room_id", record.confirmed_room_id) as ContainmentData
	if room == null:
		entry.reference_issue = "UNAVAILABLE_OR_AMBIGUOUS_ROOM"
		return entry
	var has_match: bool = false
	for outcome: MonitoringOutcomeData in source.containment_outcomes:
		if outcome != null and outcome.room_id == record.confirmed_room_id:
			has_match = true
	if not has_match:
		entry.classification = "UNRESOLVED_SUBMISSION"
		entry.reference_issue = "MISSING_OUTCOME"
		return entry
	var outcome: MonitoringOutcomeData = lookup_content.call(source.containment_outcomes, "room_id", record.confirmed_room_id) as MonitoringOutcomeData
	if outcome == null:
		entry.reference_issue = "AMBIGUOUS_OUTCOME"
		return entry
	if outcome.final_result not in [MonitoringOutcomeData.Result.SUCCESS, MonitoringOutcomeData.Result.FAILURE]:
		entry.reference_issue = "UNDEFINED_OUTCOME_RESULT"
		return entry
	if outcome.final_result == MonitoringOutcomeData.Result.FAILURE:
		var incident: IncidentData = lookup_content.call(source.incidents, "incident_id", outcome.incident_id) as IncidentData
		if incident == null:
			entry.reference_issue = "UNAVAILABLE_OR_AMBIGUOUS_INCIDENT"
			return entry
	entry.has_valid_outcome = true
	for resolution: Dictionary in resolutions:
		if resolution.case_id == record.case_id:
			entry.reference_issue = "ALREADY_RESOLVED_PENDING"
			return entry
	if outcome.final_result == MonitoringOutcomeData.Result.FAILURE:
		for candidate: Dictionary in candidates:
			if candidate.source_case_id == record.case_id:
				entry.reference_issue = "EXISTING_FAILURE_CANDIDATE"
				return entry
	entry.classification = "RESOLVABLE_PENDING"
	entry.reference_issue = ""
	# No prospective SUCCESS/FAILURE value: a valid submission remains unjudged.
	return entry


static func _candidate_entry(record: Dictionary, index: int, resolutions: Array[Dictionary], active_response: Dictionary, lookup_case: Callable, lookup_content: Callable) -> Dictionary:
	var entry: Dictionary = record.duplicate(true)
	# Relative creation order from the existing State list, not a new persisted counter.
	entry["created_order"] = index
	entry["major_ready"] = record.disturbance_triggered and record.major_opportunity_count >= record.major_trigger_threshold
	entry["phase"] = "UNDISTURBED"
	entry["classification"] = "UNRESOLVED_EVENT"
	entry["reference_issue"] = ""
	if record.disturbance_triggered:
		entry.phase = "MAJOR_READY" if entry.major_ready else "DISTURBED_NOT_READY"
	if not active_response.is_empty() and active_response.source_case_id == record.source_case_id and active_response.incident_id == record.incident_id:
		entry.phase = "ACTIVE_RESPONSE"
	var source: CaseData = lookup_case.call(record.source_case_id) as CaseData
	if source == null:
		entry.reference_issue = "UNAVAILABLE_OR_AMBIGUOUS_SOURCE"
	elif lookup_content.call(source.incidents, "incident_id", record.incident_id) == null:
		entry.reference_issue = "UNAVAILABLE_OR_AMBIGUOUS_INCIDENT"
	else:
		var matching_resolution: bool = false
		for resolution: Dictionary in resolutions:
			if resolution.case_id == record.source_case_id and resolution.result == MonitoringOutcomeData.Result.FAILURE and resolution.incident_id == record.incident_id:
				matching_resolution = true
		if not matching_resolution:
			entry.reference_issue = "MISMATCHED_FAILURE_RESOLUTION"
		elif record.major_incident_triggered and entry.phase != "ACTIVE_RESPONSE":
			entry.reference_issue = "TRIGGERED_WITHOUT_ACTIVE_RESPONSE"
	if not entry.reference_issue.is_empty():
		entry.classification = "INVALID_UNRESOLVED_EVENT"
	return entry


static func _has_completed_response(candidate: Dictionary, responses: Array[Dictionary]) -> bool:
	for response: Dictionary in responses:
		if response.status == IncidentResponseState.Status.COMPLETED and response.source_case_id == candidate.source_case_id and response.incident_id == candidate.incident_id:
			return true
	return false
