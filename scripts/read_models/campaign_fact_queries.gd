class_name CampaignFactQueries
extends RefCounted

# Read model only: no historical facts are cached here. Values describe the
# owners at query time; retained values do not become live authority later.
enum Availability { KNOWN, UNKNOWN, INVALID, UNSUPPORTED, SOURCE_RELEASED }

class BooleanFactQuery extends RefCounted:
	var availability: Availability
	var reason: String
	var campaign_id: String
	var entry_id: String
	var interrupt_id: String
	var definition_id: String
	var phase: String
	var subject_id: String
	var value: bool
	func _init(meta: Dictionary, answer: bool = false) -> void:
		availability = meta.availability
		reason = meta.reason
		campaign_id = meta.campaign_id
		entry_id = meta.entry_id
		interrupt_id = meta.get("interrupt_id", "")
		definition_id = meta.definition_id
		phase = meta.phase
		subject_id = meta.subject_id
		value = answer

class IdentifierFactQuery extends RefCounted:
	var availability: Availability
	var reason: String
	var campaign_id: String
	var entry_id: String
	var interrupt_id: String
	var definition_id: String
	var phase: String
	var subject_id: String
	var value: String
	func _init(meta: Dictionary, answer: String = "") -> void:
		availability = meta.availability
		reason = meta.reason
		campaign_id = meta.campaign_id
		entry_id = meta.entry_id
		interrupt_id = meta.get("interrupt_id", "")
		definition_id = meta.definition_id
		phase = meta.phase
		subject_id = meta.subject_id
		value = answer

class CaseResolutionQuery extends RefCounted:
	var availability: Availability
	var reason: String
	var campaign_id: String
	var entry_id: String
	var interrupt_id: String
	var definition_id: String
	var phase: String
	var subject_id: String
	var value: MonitoringOutcomeData.Result
	func _init(meta: Dictionary, answer: MonitoringOutcomeData.Result = MonitoringOutcomeData.Result.UNDEFINED) -> void:
		availability = meta.availability
		reason = meta.reason
		campaign_id = meta.campaign_id
		entry_id = meta.entry_id
		interrupt_id = meta.get("interrupt_id", "")
		definition_id = meta.definition_id
		phase = meta.phase
		subject_id = meta.subject_id
		value = answer

var _campaign_id: String = ""
var _campaign: CampaignData
var _progress: CampaignProgressState
var _resolutions: ContainmentResolutionState
var _pending: PendingContainmentState
var _responses: IncidentResponseState
var _archive: ResearchArchiveState
var _runtime: CaseRuntimeState
var _runtime_entry_id: String = ""
var _runtime_definition_id: String = ""
var _context_error: String = ""
var _released: bool = false

# One construction binds one session. There is deliberately no rebind/reset API.
func _init(campaign: CampaignData, progress: CampaignProgressState, resolutions: ContainmentResolutionState, pending: PendingContainmentState, responses: IncidentResponseState, archive: ResearchArchiveState) -> void:
	_campaign = campaign
	_campaign_id = campaign.campaign_id if campaign != null else ""
	_progress = progress
	_resolutions = resolutions
	_pending = pending
	_responses = responses
	_archive = archive


func set_current_runtime(entry_id: String, definition_id: String, runtime: CaseRuntimeState) -> bool:
	clear_current_runtime()
	if _released: return false
	var entry: CampaignEntryData = _campaign.get_entry(entry_id) if _campaign != null else null
	if not _scope_error().is_empty() or entry == null or entry.entry_kind != CampaignEntryData.EntryKind.CASE or entry.case_data == null or _progress.get_current_entry_id() != entry_id or entry.case_data.case_id != definition_id or runtime == null or runtime.case_id != definition_id:
		_context_error = "INVALID_RUNTIME_CONTEXT"
		return false
	_runtime_entry_id = entry_id
	_runtime_definition_id = definition_id
	_runtime = runtime
	return true


func clear_current_runtime() -> void:
	_runtime = null
	_runtime_entry_id = ""
	_runtime_definition_id = ""
	_context_error = ""


func release_sources() -> void:
	_released = true
	clear_current_runtime()
	_campaign = null
	_progress = null
	_resolutions = null
	_pending = null
	_responses = null
	_archive = null


func was_entry_completed(entry_id: String) -> BooleanFactQuery:
	var meta: Dictionary = _entry_meta(entry_id)
	if meta.availability != Availability.KNOWN: return BooleanFactQuery.new(meta)
	var completed: bool = _progress.get_completed_entry_ids().has(entry_id)
	meta.phase = "COMPLETED" if completed else "NOT_COMPLETED"
	return BooleanFactQuery.new(meta, completed)


func get_case_resolution(entry_id: String) -> CaseResolutionQuery:
	var meta: Dictionary = _case_meta(entry_id)
	if meta.availability != Availability.KNOWN: return CaseResolutionQuery.new(meta)
	var data: CaseData = _campaign.get_entry(entry_id).case_data
	var record: Dictionary = _resolutions.get_resolution(data.case_id)
	if not record.is_empty():
		meta.phase = "RESOLVED"
		return CaseResolutionQuery.new(meta, record.result)
	var reason: String = "NOT_RESOLVED"
	if _pending.has_pending(data.case_id):
		reason = "SUBMITTED_UNRESOLVED"
		var has_outcome: bool = false
		for outcome: MonitoringOutcomeData in data.containment_outcomes:
			if outcome != null and outcome.room_id == _pending.get_pending_room_id(data.case_id): has_outcome = true
		if not has_outcome: reason = "MISSING_OUTCOME"
		meta.phase = "SUBMITTED"
	return CaseResolutionQuery.new(_unavailable(meta, Availability.UNKNOWN, reason))


func get_case_room(entry_id: String) -> IdentifierFactQuery:
	var meta: Dictionary = _case_meta(entry_id)
	if meta.availability != Availability.KNOWN: return IdentifierFactQuery.new(meta)
	var record: Dictionary = _resolutions.get_resolution(meta.definition_id)
	if not record.is_empty():
		meta.phase = "RESOLVED"
		return IdentifierFactQuery.new(meta, record.room_id)
	if _pending.has_pending(meta.definition_id):
		meta.phase = "SUBMITTED"
		return IdentifierFactQuery.new(meta, _pending.get_pending_room_id(meta.definition_id))
	return IdentifierFactQuery.new(_unavailable(meta, Availability.UNKNOWN, "NOT_SUBMITTED"))


func was_response_completed(entry_id: String, incident_id: String) -> BooleanFactQuery:
	var context: Dictionary = _response_context(entry_id, incident_id)
	var meta: Dictionary = context.meta
	return BooleanFactQuery.new(meta, meta.availability == Availability.KNOWN and meta.phase == "COMPLETED")


func get_confirmed_option(entry_id: String, incident_id: String) -> IdentifierFactQuery:
	return _response_identifier(entry_id, incident_id, "confirmed_option_id")


func get_incident_result(entry_id: String, incident_id: String) -> IdentifierFactQuery:
	return _response_identifier(entry_id, incident_id, "incident_result_id")


func was_interrupt_response_completed(interrupt_id: String, incident_id: String) -> BooleanFactQuery:
	var context: Dictionary = _interrupt_response_context(interrupt_id, incident_id)
	var meta: Dictionary = context.meta
	return BooleanFactQuery.new(meta, meta.availability == Availability.KNOWN and meta.phase == "COMPLETED")


func get_interrupt_confirmed_option(interrupt_id: String, incident_id: String) -> IdentifierFactQuery:
	return _identifier_from_context(_interrupt_response_context(interrupt_id, incident_id), "confirmed_option_id")


func get_interrupt_incident_result(interrupt_id: String, incident_id: String) -> IdentifierFactQuery:
	return _identifier_from_context(_interrupt_response_context(interrupt_id, incident_id), "incident_result_id")


func was_entry_research_discovered(entry_id: String, research_id: String) -> BooleanFactQuery:
	var meta: Dictionary = _entry_meta(entry_id, research_id)
	if meta.availability != Availability.KNOWN: return BooleanFactQuery.new(meta)
	var entry: CampaignEntryData = _campaign.get_entry(entry_id)
	if entry.entry_kind != CampaignEntryData.EntryKind.CASE:
		return BooleanFactQuery.new(_unavailable(meta, Availability.UNSUPPORTED, "SCRIPTED_RESEARCH_UNSUPPORTED"))
	var matches: int = 0
	for research: ResearchEntryData in entry.case_data.research_entries:
		if research != null and research.entry_id == research_id: matches += 1
	if research_id.is_empty() or matches != 1:
		return BooleanFactQuery.new(_unavailable(meta, Availability.INVALID, "INVALID_RESEARCH_ID"))
	var found: bool = _archive.has_discovered_entry(meta.definition_id, research_id)
	if _progress.get_current_entry_id() == entry_id:
		var error: String = _runtime_error(entry_id, meta.definition_id)
		if not error.is_empty(): return BooleanFactQuery.new(_unavailable(meta, Availability.INVALID, error))
		if _runtime == null: return BooleanFactQuery.new(_unavailable(meta, Availability.UNKNOWN, "CURRENT_RUNTIME_UNAVAILABLE"))
		found = found or _runtime.has_discovered_research_entry(research_id)
	meta.phase = "DISCOVERED" if found else "NOT_DISCOVERED"
	return BooleanFactQuery.new(meta, found)


func _scope_error() -> String:
	if _campaign == null or _progress == null or _resolutions == null or _pending == null or _responses == null or _archive == null: return "SOURCE_UNAVAILABLE"
	if _campaign_id.is_empty() or _campaign.campaign_id != _campaign_id or _progress.get_campaign_id() != _campaign_id: return "CAMPAIGN_SCOPE_MISMATCH"
	if not _campaign.get_validation_error().is_empty(): return "INVALID_CAMPAIGN_DEFINITION"
	return ""


func _entry_meta(entry_id: String, subject_id: String = "") -> Dictionary:
	var meta: Dictionary = {"availability": Availability.KNOWN, "reason": "KNOWN", "campaign_id": _campaign_id, "entry_id": entry_id, "definition_id": "", "phase": "", "subject_id": subject_id}
	if _released: return _unavailable(meta, Availability.SOURCE_RELEASED, "SOURCE_RELEASED")
	var error: String = _scope_error()
	if not error.is_empty(): return _unavailable(meta, Availability.INVALID, error)
	var entry: CampaignEntryData = _campaign.get_entry(entry_id)
	if entry == null: return _unavailable(meta, Availability.INVALID, "INVALID_ENTRY_ID")
	meta.definition_id = entry.case_data.case_id if entry.entry_kind == CampaignEntryData.EntryKind.CASE else entry.scripted_incident_data.event_id
	return meta


func _runtime_error(entry_id: String, definition_id: String) -> String:
	if not _context_error.is_empty(): return _context_error
	if _runtime != null and (_runtime_entry_id != _progress.get_current_entry_id() or _runtime.case_id != _runtime_definition_id): return "INVALID_RUNTIME_CONTEXT"
	if _runtime != null and entry_id == _progress.get_current_entry_id() and (_runtime_entry_id != entry_id or _runtime_definition_id != definition_id): return "INVALID_RUNTIME_CONTEXT"
	return ""


func _case_meta(entry_id: String) -> Dictionary:
	var meta: Dictionary = _entry_meta(entry_id)
	if meta.availability != Availability.KNOWN: return meta
	var entry: CampaignEntryData = _campaign.get_entry(entry_id)
	if entry.entry_kind != CampaignEntryData.EntryKind.CASE: return _unavailable(meta, Availability.INVALID, "INVALID_QUERY_SCOPE")
	var error: String = _runtime_error(entry_id, meta.definition_id)
	if not error.is_empty(): return _unavailable(meta, Availability.INVALID, error)
	var record: Dictionary = _resolutions.get_resolution(meta.definition_id)
	var pending_room: String = _pending.get_pending_room_id(meta.definition_id)
	var resolved_room: String = record.get("room_id", "")
	for room_id: String in [pending_room, resolved_room]:
		if not room_id.is_empty():
			var matches: int = 0
			for room: ContainmentData in entry.case_data.available_containment_rooms:
				if room != null and room.room_id == room_id: matches += 1
			if matches != 1: return _unavailable(meta, Availability.INVALID, "INVALID_ROOM_LINK")
	if not record.is_empty():
		if resolved_room.is_empty() or record.get("case_id", "") != meta.definition_id or record.get("result", -1) not in [MonitoringOutcomeData.Result.SUCCESS, MonitoringOutcomeData.Result.FAILURE]: return _unavailable(meta, Availability.INVALID, "INVALID_RESOLUTION_LINK")
		if record.result == MonitoringOutcomeData.Result.FAILURE:
			var incidents: int = 0
			for incident: IncidentData in entry.case_data.incidents:
				if incident != null and incident.incident_id == record.get("incident_id", ""): incidents += 1
			if incidents != 1: return _unavailable(meta, Availability.INVALID, "INVALID_INCIDENT_ID")
		elif not record.get("incident_id", "").is_empty(): return _unavailable(meta, Availability.INVALID, "INVALID_RESOLUTION_LINK")
	if _pending.has_pending(meta.definition_id) and pending_room.is_empty(): return _unavailable(meta, Availability.INVALID, "INVALID_ROOM_LINK")
	if not pending_room.is_empty() and not resolved_room.is_empty() and pending_room != resolved_room: return _unavailable(meta, Availability.INVALID, "SOURCE_CONFLICT")
	if _runtime != null and _runtime_entry_id == entry_id and (not pending_room.is_empty() or not resolved_room.is_empty()):
		var confirmed: String = _runtime.get_confirmed_containment_room_id()
		if confirmed != (resolved_room if not resolved_room.is_empty() else pending_room): return _unavailable(meta, Availability.INVALID, "SOURCE_CONFLICT")
	return meta


func _unavailable(meta: Dictionary, availability: Availability, reason: String) -> Dictionary:
	meta.availability = availability
	meta.reason = reason
	return meta


func _response_identifier(entry_id: String, incident_id: String, key: String) -> IdentifierFactQuery:
	return _identifier_from_context(_response_context(entry_id, incident_id), key)


func _identifier_from_context(context: Dictionary, key: String) -> IdentifierFactQuery:
	var meta: Dictionary = context.meta
	if meta.availability != Availability.KNOWN: return IdentifierFactQuery.new(meta)
	if context.record.is_empty(): return IdentifierFactQuery.new(_unavailable(meta, Availability.UNKNOWN, "NOT_STARTED"))
	if context.record.confirmed_option_id.is_empty(): return IdentifierFactQuery.new(_unavailable(meta, Availability.UNKNOWN, "NOT_CONFIRMED"))
	return IdentifierFactQuery.new(meta, context.record[key])


func _response_context(entry_id: String, incident_id: String) -> Dictionary:
	var meta: Dictionary = _entry_meta(entry_id, incident_id)
	var context: Dictionary = {"meta": meta, "record": {}}
	if meta.availability != Availability.KNOWN: return context
	var entry: CampaignEntryData = _campaign.get_entry(entry_id)
	var origin: int = IncidentSource.OriginKind.CASE if entry.entry_kind == CampaignEntryData.EntryKind.CASE else IncidentSource.OriginKind.CAMPAIGN_ENTRY
	var incidents: Array[IncidentData] = []
	var broadcasts: Array[EmergencyBroadcastData] = []
	var results: Array[IncidentResultData] = []
	if origin == IncidentSource.OriginKind.CASE:
		incidents = entry.case_data.incidents
		broadcasts = entry.case_data.emergency_broadcasts
		results = entry.case_data.incident_results
	else:
		incidents.append(entry.scripted_incident_data.incident_data)
		broadcasts = entry.scripted_incident_data.emergency_broadcasts
		results = entry.scripted_incident_data.incident_results
	return _resolve_response(meta, IncidentSource.new(origin, entry_id, meta.definition_id), incident_id, incidents, broadcasts, results)


func _interrupt_response_context(interrupt_id: String, incident_id: String) -> Dictionary:
	var meta: Dictionary = {"availability": Availability.KNOWN, "reason": "KNOWN", "campaign_id": _campaign_id, "entry_id": "", "interrupt_id": interrupt_id, "definition_id": "", "phase": "", "subject_id": incident_id}
	if _released: return {"meta": _unavailable(meta, Availability.SOURCE_RELEASED, "SOURCE_RELEASED"), "record": {}}
	var error: String = _scope_error()
	if not error.is_empty(): return {"meta": _unavailable(meta, Availability.INVALID, error), "record": {}}
	var occurrence: ScriptedInterruptOccurrenceData = _campaign.get_interrupt(interrupt_id)
	if occurrence == null: return {"meta": _unavailable(meta, Availability.INVALID, "INVALID_INTERRUPT_ID"), "record": {}}
	var bundle: ScriptedIncidentData = occurrence.scripted_incident_data
	meta.definition_id = bundle.event_id
	var incidents: Array[IncidentData] = [bundle.incident_data]
	return _resolve_response(meta, occurrence.get_source(), incident_id, incidents, bundle.emergency_broadcasts, bundle.incident_results)


func _resolve_response(meta: Dictionary, source: IncidentSource, incident_id: String, incidents: Array[IncidentData], broadcasts: Array[EmergencyBroadcastData], results: Array[IncidentResultData]) -> Dictionary:
	var context: Dictionary = {"meta": meta, "record": {}}
	var incident: IncidentData
	var matches: int = 0
	for item: IncidentData in incidents:
		if item != null and item.incident_id == incident_id:
			incident = item
			matches += 1
	if incident_id.is_empty() or matches != 1:
		_unavailable(meta, Availability.INVALID, "INVALID_INCIDENT_ID")
		return context
	var broadcast: EmergencyBroadcastData
	matches = 0
	for item: EmergencyBroadcastData in broadcasts:
		if item != null and item.broadcast_id == incident.broadcast_id:
			broadcast = item
			matches += 1
	if incident.broadcast_id.is_empty() or matches != 1:
		_unavailable(meta, Availability.INVALID, "BROKEN_BROADCAST_LINK")
		return context
	for record: Dictionary in _responses.get_responses():
		if record.get("origin_kind", -1) != source.origin_kind or record.get("source_occurrence_id", record.get("source_entry_id", "")) != source.source_occurrence_id or record.get("incident_id", "") != incident_id: continue
		if not context.record.is_empty() or not source.matches(record) or record.get("broadcast_id", "") != broadcast.broadcast_id:
			_unavailable(meta, Availability.INVALID, "RESPONSE_SOURCE_MISMATCH")
			return context
		context.record = record
	var record: Dictionary = context.record
	if record.is_empty():
		meta.phase = "NOT_STARTED"
		return context
	if record.get("status", -1) not in [IncidentResponseState.Status.ACTIVE, IncidentResponseState.Status.COMPLETED]:
		_unavailable(meta, Availability.INVALID, "INVALID_RESPONSE_STATUS")
		return context
	var option_id: String = record.get("confirmed_option_id", "")
	var result_id: String = record.get("incident_result_id", "")
	if option_id.is_empty() != result_id.is_empty() or record.status == IncidentResponseState.Status.COMPLETED and option_id.is_empty():
		_unavailable(meta, Availability.INVALID, "BROKEN_APPROVED_LINK")
		return context
	if not option_id.is_empty():
		var option: BroadcastOptionData
		matches = 0
		for item: BroadcastOptionData in broadcast.options:
			if item != null and item.option_id == option_id:
				option = item
				matches += 1
		if matches != 1 or option.result_id != result_id:
			_unavailable(meta, Availability.INVALID, "BROKEN_APPROVED_LINK")
			return context
		matches = 0
		for item: IncidentResultData in results:
			if item != null and item.result_id == result_id: matches += 1
		if matches != 1:
			_unavailable(meta, Availability.INVALID, "BROKEN_APPROVED_LINK")
			return context
	meta.phase = "COMPLETED" if record.status == IncidentResponseState.Status.COMPLETED else ("ACTIVE_CONFIRMED" if not option_id.is_empty() else "ACTIVE")
	return context
