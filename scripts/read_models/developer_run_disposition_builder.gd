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
		if response.get("origin_kind", IncidentSource.OriginKind.CASE) == IncidentSource.OriginKind.CASE and response.get("source_case_id", "") == source_id and response.incident_id == incident_id and response.status == IncidentResponseState.Status.COMPLETED:
			return true
	return false


static func matches_active(row: Dictionary, facts: Dictionary) -> bool:
	var active: Dictionary = facts.get("active_response_facts", {})
	return not active.is_empty() and not active.has("reference_issue") and row.source_case_id == active.get("source_case_id", "") and row.incident_id == active.get("incident_id", "")


# All raw responses must belong to an authored occurrence; never silently filter.
static func classify_response_records(records: Array, campaign: CampaignData) -> Dictionary:
	var result: Dictionary = {"issue": "", "responses": [], "scripted_responses": []}
	if campaign == null or not campaign.get_validation_error().is_empty():
		result.issue = "INVALID_RESPONSE_CAMPAIGN"
		return result
	var seen: Dictionary = {}
	for value: Variant in records:
		if not value is Dictionary:
			result.issue = "INVALID_RESPONSE_RECORD"
			return result
		var row: Dictionary = value
		if not _response_has_primitive_shape(row):
			result.issue = "INVALID_RESPONSE_PRIMITIVE_SHAPE"
			return result
		if not row.get("status") is int or row.status not in [IncidentResponseState.Status.ACTIVE, IncidentResponseState.Status.COMPLETED] or not row.get("confirmed_option_id") is String or not row.get("incident_result_id") is String:
			result.issue = "INVALID_RESPONSE_STATUS_OR_FACT_TYPE"
			return result
		for field: String in ["source_occurrence_id", "source_definition_id", "incident_id", "broadcast_id"]:
			if not _is_id(row.get(field)):
				result.issue = "INVALID_RESPONSE_ID::" + field
				return result
		if not row.get("origin_kind") is int or row.origin_kind not in [IncidentSource.OriginKind.CASE, IncidentSource.OriginKind.CAMPAIGN_ENTRY, IncidentSource.OriginKind.CAMPAIGN_INTERRUPT]:
			result.issue = "INVALID_RESPONSE_ORIGIN"
			return result
		var source := IncidentSource.new(row.origin_kind, row.source_occurrence_id, row.source_definition_id)
		if not source.matches(row):
			result.issue = "INVALID_RESPONSE_SOURCE_ALIAS"
			return result
		var key: String = JSON.stringify([row.origin_kind, row.source_occurrence_id, row.incident_id])
		if seen.has(key):
			result.issue = "DUPLICATE_RESPONSE_SOURCE"
			return result
		seen[key] = true
		if row.origin_kind == IncidentSource.OriginKind.CASE:
			var authored: CampaignEntryData = campaign.get_entry(row.source_occurrence_id)
			if authored == null or authored.entry_kind != CampaignEntryData.EntryKind.CASE or authored.case_data.case_id != row.source_definition_id or row.get("source_case_id") != authored.case_data.case_id:
				result.issue = "INVALID_CASE_RESPONSE_SOURCE"
				return result
			var broadcast: EmergencyBroadcastData = unique_content(authored.case_data.emergency_broadcasts,"broadcast_id",row.broadcast_id)
			if broadcast != null and not row.confirmed_option_id.is_empty() and not IncidentResponseState.valid_details(row,broadcast,unique_content(authored.case_data.incident_results,"result_id",row.incident_result_id)):
				result.issue = "INVALID_CASE_BROADCAST_DETAILS"
				return result
			if row.confirmed_option_id.is_empty() and row.has("broadcast_details"):
				result.issue = "UNCONFIRMED_BROADCAST_DETAILS"
				return result
			result.responses.append(row.duplicate(true))
		else:
			result.scripted_responses.append(row.duplicate(true))
	return result


static func _response_has_primitive_shape(row: Dictionary) -> bool:
	var fields: Array[String] = ["origin_kind", "source_occurrence_id", "source_definition_id", "incident_id", "broadcast_id", "confirmed_option_id", "incident_result_id", "status", "source_entry_id", "source_case_id", "broadcast_details"]
	for key: Variant in row:
		if not key is String or not fields.has(key): return false
		if key == "broadcast_details":
			if not row[key] is Dictionary: return false
		elif key in ["origin_kind", "status"]:
			if not row[key] is int: return false
		elif not row[key] is String: return false
	return true


static func _is_id(value: Variant) -> bool:
	return value is String and not value.is_empty() and value == value.strip_edges()


# Read-only projection, including status/link checks for ACTIVE rows (no history).
# Optional Campaign input keeps legacy Case-only fixture callers compatible.
static func project_completed_scripted_responses(facts: Dictionary, campaign: CampaignData = null) -> Dictionary:
	var rejected: Dictionary = {"issue": "INVALID_SCRIPTED_SOURCE", "rows": []}
	if not facts.get("scripted_responses", []) is Array: return rejected
	var responses: Array = facts.get("scripted_responses", [])
	if not facts.has("scripted_responses") and campaign == null: return {"issue": "", "rows": []}
	if campaign == null or not campaign.get_validation_error().is_empty():
		rejected.issue = "INVALID_SCRIPTED_CAMPAIGN"
		return rejected
	# No Scripted source exists to project: preserve legacy Case-only fixture scope.
	if responses.is_empty(): return {"issue": "", "rows": []}
	var scope: Variant = facts.get("campaign_scope")
	if not scope is Dictionary or scope.size() != 3 or not _is_id(scope.get("campaign_id")) or scope.campaign_id != campaign.campaign_id or not scope.get("current_entry_id") is String or not scope.get("completed_entry_ids") is Array:
		rejected.issue = "INVALID_SCRIPTED_CAMPAIGN_SCOPE"
		return rejected
	var completed: Array = scope.completed_entry_ids
	if completed.size() > campaign.entries.size(): return rejected
	for index: int in range(completed.size()):
		if not _is_id(completed[index]) or completed[index] != campaign.entries[index].entry_id: return rejected
	var expected_current: String = campaign.entries[completed.size()].entry_id if completed.size() < campaign.entries.size() else ""
	if scope.current_entry_id != expected_current: return rejected
	var rows: Array[Dictionary] = []
	var seen: Dictionary = {}
	for value: Variant in responses:
		if not value is Dictionary: return rejected
		var response: Dictionary = value
		if not _response_has_primitive_shape(response): return rejected
		for field: String in ["source_occurrence_id", "source_definition_id", "incident_id", "broadcast_id"]:
			if not _is_id(response.get(field)): return rejected
		if not response.get("origin_kind") is int or response.origin_kind not in [IncidentSource.OriginKind.CAMPAIGN_ENTRY, IncidentSource.OriginKind.CAMPAIGN_INTERRUPT]: return rejected
		var source := IncidentSource.new(response.origin_kind, response.source_occurrence_id, response.source_definition_id)
		if not source.matches(response) or response.has("source_case_id"): return rejected
		var occurrence_key: String = JSON.stringify([source.origin_kind, source.source_occurrence_id])
		if seen.has(occurrence_key):
			rejected.issue = "DUPLICATE_SCRIPTED_OCCURRENCE"
			return rejected
		seen[occurrence_key] = true
		var definition: ScriptedIncidentData
		if source.origin_kind == IncidentSource.OriginKind.CAMPAIGN_ENTRY:
			var authored: CampaignEntryData = campaign.get_entry(source.source_occurrence_id)
			if authored == null or authored.entry_kind != CampaignEntryData.EntryKind.SCRIPTED_INCIDENT: return rejected
			definition = authored.scripted_incident_data
		else:
			var occurrence: ScriptedInterruptOccurrenceData = campaign.get_interrupt(source.source_occurrence_id)
			if occurrence == null: return rejected
			var host: CampaignEntryData = campaign.get_entry(occurrence.target_entry_id)
			if host == null or host.entry_kind != CampaignEntryData.EntryKind.CASE or host.case_data == null or not _is_id(host.case_data.case_id): return rejected
			# A reached host may still be current/uncompleted after exact work resume.
			if occurrence.target_entry_id != scope.current_entry_id and not completed.has(occurrence.target_entry_id): return rejected
			definition = occurrence.scripted_incident_data
		if definition == null or not definition.get_validation_error().is_empty() or definition.event_id != source.source_definition_id or definition.incident_data.incident_id != response.incident_id or definition.incident_data.broadcast_id != response.broadcast_id: return rejected
		var broadcast: EmergencyBroadcastData = unique_content(definition.emergency_broadcasts, "broadcast_id", response.broadcast_id) as EmergencyBroadcastData
		if broadcast == null: return rejected
		if not response.get("status") is int or response.status not in [IncidentResponseState.Status.ACTIVE, IncidentResponseState.Status.COMPLETED]: return rejected
		if not response.get("confirmed_option_id") is String or not response.get("incident_result_id") is String: return rejected
		var option_id: String = response.confirmed_option_id
		var result_id: String = response.incident_result_id
		if option_id.is_empty() and response.has("broadcast_details"): return rejected
		if not option_id.is_empty() or not result_id.is_empty() or response.status == IncidentResponseState.Status.COMPLETED:
			if not _is_id(option_id) or not _is_id(result_id): return rejected
			var option: BroadcastOptionData = unique_content(broadcast.get_response_options(), "option_id", option_id) as BroadcastOptionData
			if option == null or option.result_id != result_id or unique_content(definition.incident_results, "result_id", result_id) == null: return rejected
		if not option_id.is_empty() and not IncidentResponseState.valid_details(response, broadcast, unique_content(definition.incident_results, "result_id", result_id)): return rejected
		if source.origin_kind == IncidentSource.OriginKind.CAMPAIGN_ENTRY:
			if response.status == IncidentResponseState.Status.COMPLETED:
				if not completed.has(source.source_occurrence_id): return rejected
			elif completed.has(source.source_occurrence_id) or scope.current_entry_id != source.source_occurrence_id: return rejected
		if response.status != IncidentResponseState.Status.COMPLETED: continue
		rows.append({"identity_domain": "SCRIPTED_EVENT", "entry_kind": "COMPLETED_SCRIPTED_RESPONSE_FACT", "origin_kind": source.origin_kind, "source_occurrence_id": source.source_occurrence_id, "source_definition_id": source.source_definition_id, "incident_id": response.incident_id, "phase": "COMPLETED", "actual_facts": {"broadcast_id": response.broadcast_id, "confirmed_option_id": option_id, "incident_result_id": result_id}})
	rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if a.origin_kind != b.origin_kind: return a.origin_kind < b.origin_kind
		if a.source_occurrence_id != b.source_occurrence_id: return a.source_occurrence_id < b.source_occurrence_id
		return a.incident_id < b.incident_id)
	return {"issue": "", "rows": rows}


static func source_issue(facts: Dictionary, mapping: Dictionary, campaign: CampaignData = null) -> String:
	if not facts.get("response_source_issue", "").is_empty(): return facts.response_source_issue
	var scripted: Dictionary = project_completed_scripted_responses(facts, campaign)
	if not scripted.issue.is_empty(): return scripted.issue
	for response: Dictionary in facts.responses:
		if response.get("origin_kind", IncidentSource.OriginKind.CASE) != IncidentSource.OriginKind.CASE: return "UNSUPPORTED_CAMPAIGN_RESPONSE_HISTORY"
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
			var non_escape: bool = false
			var authored: CampaignEntryData = campaign.get_case_entry(resolution.case_id) if campaign != null else null
			if authored != null:
				var outcome: MonitoringOutcomeData = unique_content(authored.case_data.containment_outcomes, "room_id", resolution.room_id) as MonitoringOutcomeData
				non_escape = outcome != null and outcome.is_non_escape_failure() and resolution.incident_id.is_empty() and candidate.is_empty() and not completed
			if candidate.is_empty() and not completed and not non_escape: return "FAILURE_WITHOUT_EVENT_EVIDENCE::" + resolution.case_id
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


static func build(context: Dictionary, facts: Dictionary, sequence: Array[CaseData], boundary: String, campaign: CampaignData = null) -> Dictionary:
	var mapping: Dictionary = context.case_assignments
	var issue: String = source_issue(facts, mapping, campaign)
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
		actual.erase("broadcast_details") # Historical schema stays stable; details remain source-keyed in ResponseState.
		actual["result_displayed"] = "UNKNOWN"
		var value: Dictionary = entry(mapping, response.source_case_id, "EVENT", "COMPLETED_RESPONSE_FACT", actual)
		value["incident_id"] = response.incident_id
		value["phase"] = "COMPLETED"
		data.historical_facts.append(value)
	# Preserve existing Case row order; append only the canonical Scripted block.
	data.historical_facts.append_array(project_completed_scripted_responses(facts, campaign).rows)
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
