class_name DeveloperRunDispositionBuilder
extends RefCounted

# Pure projection. Resources are lookup inputs only; this helper owns no State.
const SNAPSHOT = preload("res://scripts/read_models/test_sequence_disposition_snapshot.gd")


static func unique_content(items: Array, field: String, id: String) -> Resource:
	var found: Resource = null
	if id.strip_edges().is_empty(): return null
	for item: Resource in items:
		if item != null and item.get(field) == id:
			if found != null: return null
			found = item
	return found


static func find_case(sequence: Array[CaseData], id: String) -> CaseData:
	return unique_content(sequence, "case_id", id) as CaseData


static func classify_pending(pending: Dictionary, facts: Dictionary, sequence: Array[CaseData]) -> Dictionary:
	var resolutions: Array[Dictionary] = []
	var candidates: Array[Dictionary] = []
	resolutions.assign(facts.resolutions)
	candidates.assign(facts.candidates)
	return SNAPSHOT._pending_entry(pending, resolutions, candidates, func(id: String) -> CaseData: return find_case(sequence, id), unique_content)


static func completed_for(source_id: String, incident_id: String, responses: Array) -> bool:
	for response: Dictionary in responses:
		if response.source_case_id == source_id and response.incident_id == incident_id and response.status == IncidentResponseState.Status.COMPLETED:
			return true
	return false


static func matches_active(row: Dictionary, facts: Dictionary) -> bool:
	var active: Dictionary = facts.get("active_response_facts", {})
	return not active.is_empty() and not active.has("reference_issue") and row.source_case_id == active.get("source_case_id", "") and row.incident_id == active.get("incident_id", "")


static func source_issue(facts: Dictionary, mapping: Dictionary) -> String:
	for category: String in ["pending", "resolutions", "candidates", "responses", "archives", "notes"]:
		for row: Dictionary in facts[category]:
			var id: String = row.get("case_id", row.get("source_case_id", ""))
			if not mapping.has(id): return "UNMAPPED_SOURCE::" + category + "::" + id
	for resolution: Dictionary in facts.resolutions:
		var candidate: Dictionary = {}
		for value: Dictionary in facts.candidates:
			if value.source_case_id == resolution.case_id: candidate = value
		var completed: bool = completed_for(resolution.case_id, resolution.incident_id, facts.responses)
		if resolution.result == MonitoringOutcomeData.Result.SUCCESS:
			if not candidate.is_empty() or not resolution.incident_id.is_empty(): return "SUCCESS_WITH_EVENT::" + resolution.case_id
		elif resolution.result == MonitoringOutcomeData.Result.FAILURE:
			if candidate.is_empty() and not completed: return "FAILURE_WITHOUT_EVENT_EVIDENCE::" + resolution.case_id
			if not candidate.is_empty() and candidate.incident_id != resolution.incident_id: return "MISMATCHED_CANDIDATE::" + resolution.case_id
		else: return "INVALID_RESOLUTION_RESULT::" + resolution.case_id
	for candidate: Dictionary in facts.candidates:
		var matching: bool = false
		for resolution: Dictionary in facts.resolutions:
			if resolution.case_id == candidate.source_case_id and resolution.result == MonitoringOutcomeData.Result.FAILURE and resolution.incident_id == candidate.incident_id: matching = true
		if not matching: return "CANDIDATE_WITHOUT_FAILURE::" + candidate.source_case_id
		if candidate.major_incident_triggered and not completed_for(candidate.source_case_id, candidate.incident_id, facts.responses) and not matches_active(candidate, facts): return "TRIGGERED_WITHOUT_RESPONSE::" + candidate.source_case_id
	for response: Dictionary in facts.responses:
		var matching: bool = false
		for resolution: Dictionary in facts.resolutions:
			if resolution.case_id == response.source_case_id and resolution.result == MonitoringOutcomeData.Result.FAILURE and resolution.incident_id == response.incident_id: matching = true
		if not matching: return "RESPONSE_WITHOUT_FAILURE::" + response.source_case_id
		if response.status == IncidentResponseState.Status.ACTIVE:
			var active_candidate: bool = false
			for candidate: Dictionary in facts.candidates:
				if matches_active(candidate, facts) and candidate.major_incident_triggered: active_candidate = true
			if not matches_active(response, facts) or not active_candidate: return "ACTIVE_RESPONSE_WITHOUT_MATCHING_CANDIDATE::" + response.source_case_id
	for pending: Dictionary in facts.pending:
		for resolution: Dictionary in facts.resolutions:
			if resolution.case_id == pending.case_id and resolution.room_id != pending.confirmed_room_id: return "CONFLICTING_PENDING_ROOM::" + pending.case_id
	return ""


static func entry(mapping: Dictionary, id: String, domain: String, kind: String, facts: Dictionary) -> Dictionary:
	return {"source_case_definition_id": id, "source_case_instance_id": mapping[id], "identity_domain": domain, "entry_kind": kind, "actual_facts": facts.duplicate(true)}


static func build(context: Dictionary, facts: Dictionary, sequence: Array[CaseData], boundary: String) -> Dictionary:
	var mapping: Dictionary = context.case_assignments
	var issue: String = source_issue(facts, mapping)
	if not issue.is_empty(): return {"issue": issue, "data": {}}
	var data: Dictionary = {"run_instance_id": context.run_instance_id, "boundary_type": boundary, "historical_facts": [], "obligations": [], "discoveries": [], "hypotheses": []}
	for resolution: Dictionary in facts.resolutions:
		var actual: Dictionary = resolution.duplicate(true)
		actual["result"] = "SUCCESS" if resolution.result == MonitoringOutcomeData.Result.SUCCESS else "FAILURE"
		if resolution.case_id == facts.current_case_id: actual["current_runtime"] = facts.runtime.duplicate(true)
		data.historical_facts.append(entry(mapping, resolution.case_id, "RESOLUTION", "RESOLUTION_FACT", actual))
	for pending: Dictionary in facts.pending:
		var classified: Dictionary = classify_pending(pending, facts, sequence)
		if classified.classification == "RESOLVABLE_PENDING" or classified.reference_issue == "ALREADY_RESOLVED_PENDING": return {"issue": "PENDING_NOT_PREPARED::" + pending.case_id, "data": {}}
		var kind: String = "UNRESOLVED_SUBMISSION" if classified.classification == "UNRESOLVED_SUBMISSION" else "INVALID_UNRESOLVED_REFERENCE"
		var actual: Dictionary = {"confirmed_room_id": pending.confirmed_room_id, "result": "UNKNOWN", "reference_issue": classified.reference_issue}
		if pending.case_id == facts.current_case_id: actual["current_runtime"] = facts.runtime.duplicate(true)
		data.obligations.append(entry(mapping, pending.case_id, "SUBMISSION", kind, actual))
	for response: Dictionary in facts.responses:
		if response.status == IncidentResponseState.Status.ACTIVE:
			if boundary != "FORCED_RUN_END" or not matches_active(response, facts): return {"issue": "ACTIVE_RESPONSE_NOT_FORCED", "data": {}}
			continue
		if response.status != IncidentResponseState.Status.COMPLETED: return {"issue": "INVALID_RESPONSE_STATUS", "data": {}}
		var actual: Dictionary = response.duplicate(true)
		actual["result_displayed"] = "UNKNOWN"
		var value: Dictionary = entry(mapping, response.source_case_id, "EVENT", "COMPLETED_RESPONSE_FACT", actual)
		value["incident_id"] = response.incident_id
		value["phase"] = "COMPLETED"
		data.historical_facts.append(value)
	for index: int in range(facts.candidates.size()):
		var candidate: Dictionary = facts.candidates[index]
		if completed_for(candidate.source_case_id, candidate.incident_id, facts.responses): continue
		if matches_active(candidate, facts):
			var actual: Dictionary = facts.active_response_facts.duplicate(true)
			actual["candidate"] = candidate.duplicate(true)
			var interrupted: Dictionary = entry(mapping, candidate.source_case_id, "EVENT", "INTERRUPTED_RESPONSE", actual)
			interrupted["incident_id"] = candidate.incident_id
			interrupted["phase"] = "ACTIVE_RESPONSE"
			interrupted["created_order"] = index
			data.obligations.append(interrupted)
			continue
		var resolutions: Array[Dictionary] = []
		resolutions.assign(facts.resolutions)
		var classified: Dictionary = SNAPSHOT._candidate_entry(candidate, index, resolutions, {}, func(id: String) -> CaseData: return find_case(sequence, id), unique_content)
		var kind: String = "UNMANIFESTED_FAILURE_OBLIGATION"
		if classified.phase == "DISTURBED_NOT_READY": kind = "DISTURBED_UNRESPONDED"
		elif classified.phase == "MAJOR_READY": kind = "READY_BUT_UNRESPONDED_OBLIGATION"
		if not classified.reference_issue.is_empty(): kind = "INVALID_UNRESOLVED_REFERENCE"
		var value: Dictionary = entry(mapping, candidate.source_case_id, "EVENT", kind, classified)
		value["incident_id"] = candidate.incident_id
		value["phase"] = classified.phase
		value["created_order"] = index
		data.obligations.append(value)
	for source: CaseData in sequence:
		var ids: Array[String] = []
		for archived: Dictionary in facts.archives:
			if archived.case_id == source.case_id: ids.assign(archived.entry_ids)
		if source.case_id == facts.current_case_id:
			for id: String in facts.runtime.discovered_entry_ids:
				if not ids.has(id): ids.append(id)
		for id: String in ids:
			var value: Dictionary = entry(mapping, source.case_id, "DISCOVERY", "RESEARCH_DISCOVERY", {"entry_id": id})
			value["entry_id"] = id
			data.discoveries.append(value)
		for notes: Dictionary in facts.notes:
			if notes.case_id != source.case_id: continue
			for note: Dictionary in notes.hypotheses:
				var value: Dictionary = entry(mapping, source.case_id, "HYPOTHESIS", "WORKING_HYPOTHESIS", note)
				value["hypothesis_id"] = note.hypothesis_id
				data.hypotheses.append(value)
	return {"issue": "", "data": data}
