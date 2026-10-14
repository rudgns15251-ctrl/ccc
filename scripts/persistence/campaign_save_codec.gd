class_name CampaignSaveCodec
extends RefCounted

# Stable work boundaries only; this is separate from developer RunDisposition.
static func capture(game: Node) -> Dictionary:
	var archives: Array = []
	for id: String in game.research_archive.get_archived_case_ids():
		archives.append({"case_id": id, "entries": game.research_archive.get_discovered_entry_ids(id)})
	var pending: Array = []
	for id: String in game.pending_containment.get_pending_case_ids():
		pending.append({"case_id": id, "room_id": game.pending_containment.get_pending_room_id(id)})
	var resolutions: Array = []
	for id: String in game.containment_resolutions.get_resolved_case_ids(): resolutions.append(game.containment_resolutions.get_resolution(id))
	var candidates: Array = []
	for id: String in game.failure_candidates.get_candidate_case_ids(): candidates.append(game.failure_candidates.get_candidate(id))
	var runtime: CaseRuntimeState = game.case_runtime
	var conditions: Dictionary = {}
	for id: String in runtime.get_experiment_execution_history(): conditions[id] = runtime.get_experiment_condition_observation_ids(id)
	var view_state: Dictionary = game.get("_current_view").capture_work_state()
	view_state.focus_path = "" # Save/Load controls are outside the work View.
	return {"campaign_id": game.campaign_data.campaign_id, "entry_id": game.campaign_progress.get_current_entry_id(), "completed": game.campaign_progress.get_completed_entry_ids(), "stage": "PROFILE" if game.get("_current_stage") == 0 else "CONTAINMENT", "runtime": {"case_id": runtime.case_id, "experiments": runtime.get_experiment_execution_history(), "conditions": conditions, "room_id": runtime.get_confirmed_containment_room_id(), "discoveries": runtime.get_discovered_research_entry_ids(), "sources": runtime.get_observed_research_sources(), "disturbances": runtime.get_applied_disturbances()}, "pending": pending, "resolutions": resolutions, "candidates": candidates, "responses": game.incident_responses.get_responses(), "archives": archives, "hypotheses": game.working_hypotheses.get_save_data(), "stories": game.story_collection.get_collected_ids(), "rng": {"seed": str(game.get("_event_rng").seed), "state": str(game.get("_event_rng").state)}, "pacing": {"processed": game.get("_processed_opportunities").keys(), "tokens": game.get("_completed_research_tokens").keys(), "credit": game.get("_event_presentation_credit")}, "view": view_state}

static func signature(campaign: CampaignData, records: Array[StoryRecordData]) -> String:
	var data: Array = [campaign.campaign_id]
	for entry: CampaignEntryData in campaign.entries:
		var row: Array = [entry.entry_id, entry.entry_kind]
		if entry.entry_kind == CampaignEntryData.EntryKind.CASE:
			var item: CaseData = entry.case_data
			row.append([item.case_id, item.experiment_limit, _ids(item.available_experiments,"experiment_id"), _ids(item.available_containment_rooms,"room_id"), item.containment_outcomes.map(func(o: MonitoringOutcomeData) -> Array: return [o.room_id, o.final_result, o.incident_id]), _ids(item.research_entries,"entry_id")])
		else: row.append(_bundle_signature(entry.scripted_incident_data))
		data.append(row)
	for occurrence: ScriptedInterruptOccurrenceData in campaign.scripted_interrupts:
		data.append([occurrence.interrupt_id, occurrence.target_entry_id, occurrence.checkpoint_kind, occurrence.stage_id, occurrence.action_id, _bundle_signature(occurrence.scripted_incident_data)])
	for record: StoryRecordData in records: data.append([record.record_id, record.kind, record.discovery_entry_id, record.discovery_stage])
	return JSON.stringify(data).sha256_text()

static func _bundle_signature(bundle: ScriptedIncidentData) -> Array:
	return [bundle.event_id, bundle.incident_data.incident_id, bundle.incident_data.broadcast_id, bundle.emergency_broadcasts.map(func(b: EmergencyBroadcastData) -> Array: return [b.broadcast_id, b.options.map(func(o: BroadcastOptionData) -> Array: return [o.option_id, o.result_id])])]

# Every owner is reconstructed in isolation. Main is untouched on any rejection.
static func prepare(p: Dictionary, campaign: CampaignData, records: Array[StoryRecordData]) -> Dictionary:
	if not _fields(p,{"campaign_id":TYPE_STRING,"entry_id":TYPE_STRING,"completed":TYPE_ARRAY,"stage":TYPE_STRING,"runtime":TYPE_DICTIONARY,"pending":TYPE_ARRAY,"resolutions":TYPE_ARRAY,"candidates":TYPE_ARRAY,"responses":TYPE_ARRAY,"archives":TYPE_ARRAY,"hypotheses":TYPE_DICTIONARY,"stories":TYPE_ARRAY,"rng":TYPE_DICTIONARY,"pacing":TYPE_DICTIONARY,"view":TYPE_DICTIONARY}): return _bad("FORMAT")
	if not campaign.get_validation_error().is_empty() or p.campaign_id != campaign.campaign_id or p.stage not in ["PROFILE","CONTAINMENT"]: return _bad("CAMPAIGN_OR_BOUNDARY")
	var current: CampaignEntryData = campaign.get_entry(p.entry_id)
	if current == null or current.entry_kind != CampaignEntryData.EntryKind.CASE: return _bad("ENTRY")
	var index: int = campaign.entries.find(current)
	var completed: Array = campaign.entries.slice(0,index).map(func(e: CampaignEntryData) -> String: return e.entry_id)
	if p.completed != completed: return _bad("PROGRESS_ORDER")
	var visited: Array[String] = []
	var completed_cases: Array[String] = []
	for entry: CampaignEntryData in campaign.entries.slice(0,index+1):
		if entry.entry_kind == CampaignEntryData.EntryKind.CASE:
			visited.append(entry.case_data.case_id)
			if entry != current: completed_cases.append(entry.case_data.case_id)
	var progress := CampaignProgressState.new()
	var entry_ids: Array[String] = [];entry_ids.assign(campaign.entries.map(func(e: CampaignEntryData) -> String: return e.entry_id))
	if not progress.configure(campaign.campaign_id,entry_ids): return _bad("PROGRESS")
	for id: String in completed:
		if not progress.try_complete_and_advance(id): return _bad("PROGRESS")
	var resolved := ContainmentResolutionState.new()
	if p.resolutions.size() != completed_cases.size(): return _bad("MISSING_RESOLUTION")
	for i: int in range(p.resolutions.size()):
		var row: Variant = p.resolutions[i]
		if not _fields(row,{"case_id":TYPE_STRING,"room_id":TYPE_STRING,"result":TYPE_INT,"incident_id":TYPE_STRING}) or row.case_id != completed_cases[i]: return _bad("RESOLUTION_ORDER")
		var data: CaseData = campaign.get_case_entry(row.case_id).case_data
		var outcome: MonitoringOutcomeData = _unique(data.containment_outcomes,"room_id",row.room_id)
		if _unique(data.available_containment_rooms,"room_id",row.room_id) == null or outcome == null or outcome.final_result != row.result or outcome.incident_id != row.incident_id or not resolved.try_record_resolution(row.case_id,row.room_id,row.result,row.incident_id): return _bad("RESOLUTION")
	var responses := IncidentResponseState.new()
	var response_keys: Array[String] = []
	for row: Variant in p.responses:
		var schema: Dictionary = {"origin_kind":TYPE_INT,"source_occurrence_id":TYPE_STRING,"source_definition_id":TYPE_STRING,"incident_id":TYPE_STRING,"broadcast_id":TYPE_STRING,"confirmed_option_id":TYPE_STRING,"incident_result_id":TYPE_STRING,"status":TYPE_INT}
		if row is Dictionary and row.get("origin_kind") in [0,1]: schema.source_entry_id = TYPE_STRING
		if row is Dictionary and row.get("origin_kind") == 0: schema.source_case_id = TYPE_STRING
		if not _fields(row,schema) or row.status != IncidentResponseState.Status.COMPLETED: return _bad("ACTIVE_OR_INVALID_RESPONSE")
		var source: IncidentSource = IncidentSource.from_record(row)
		var scope: Resource = null
		if source.origin_kind == IncidentSource.OriginKind.CASE:
			var entry: CampaignEntryData = campaign.get_case_entry(source.source_definition_id)
			if entry == null or not completed_cases.has(entry.case_data.case_id) or source.source_occurrence_id != entry.entry_id or row.source_case_id != entry.case_data.case_id: return _bad("CASE_RESPONSE_SOURCE")
			var resolution: Dictionary = resolved.get_resolution(entry.case_data.case_id)
			if resolution.result != 2 or resolution.incident_id != row.incident_id: return _bad("CASE_RESPONSE_RESOLUTION")
			scope = entry.case_data
		elif source.origin_kind == IncidentSource.OriginKind.CAMPAIGN_ENTRY:
			var entry: CampaignEntryData = campaign.get_entry(source.source_occurrence_id)
			if entry == null or entry.entry_kind != CampaignEntryData.EntryKind.SCRIPTED_INCIDENT or not completed.has(entry.entry_id) or entry.scripted_incident_data.event_id != source.source_definition_id: return _bad("SEQUENTIAL_RESPONSE_SOURCE")
			scope = entry.scripted_incident_data
		elif source.origin_kind == IncidentSource.OriginKind.CAMPAIGN_INTERRUPT:
			var occurrence: ScriptedInterruptOccurrenceData = campaign.get_interrupt(source.source_occurrence_id)
			if occurrence == null or occurrence.scripted_incident_data.event_id != source.source_definition_id: return _bad("SIDE_RESPONSE_SOURCE")
			var target: CampaignEntryData = campaign.get_entry(occurrence.target_entry_id)
			if not visited.has(target.case_data.case_id) or target == current and p.stage != "CONTAINMENT": return _bad("SIDE_NOT_REACHED")
			scope = occurrence.scripted_incident_data
		else: return _bad("RESPONSE_SOURCE")
		var incident: IncidentData = _unique(scope.incidents,"incident_id",row.incident_id) if scope is CaseData else scope.incident_data
		var broadcast: EmergencyBroadcastData = _unique(scope.emergency_broadcasts,"broadcast_id",row.broadcast_id)
		if incident == null or incident.incident_id != row.incident_id or incident.broadcast_id != row.broadcast_id or broadcast == null: return _bad("BROADCAST")
		var option: BroadcastOptionData = _unique(broadcast.options,"option_id",row.confirmed_option_id)
		if option == null or option.result_id != row.incident_result_id or _unique(scope.incident_results,"result_id",row.incident_result_id) == null: return _bad("RESPONSE_RESULT")
		if not responses.try_begin(source,row.incident_id,row.broadcast_id) or not responses.try_confirm(source,row.incident_id,row.broadcast_id,row.confirmed_option_id,row.incident_result_id) or not responses.try_complete(source,row.incident_id): return _bad("DUPLICATE_RESPONSE")
		response_keys.append(JSON.stringify([source.origin_kind,source.source_occurrence_id,row.incident_id]))
	for entry: CampaignEntryData in campaign.entries.slice(0,index):
		if entry.entry_kind == CampaignEntryData.EntryKind.SCRIPTED_INCIDENT and not responses.has_response(IncidentSource.new(1,entry.entry_id,entry.scripted_incident_data.event_id),entry.scripted_incident_data.incident_data.incident_id): return _bad("MISSING_COMPLETED_SCRIPTED")
	for occurrence: ScriptedInterruptOccurrenceData in campaign.scripted_interrupts:
		var target: CampaignEntryData = campaign.get_entry(occurrence.target_entry_id)
		if occurrence.checkpoint_kind == ScriptedInterruptOccurrenceData.CheckpointKind.STAGE_PRESENTED and (completed.has(target.entry_id) or target == current and p.stage == "CONTAINMENT"):
			if not responses.has_response(occurrence.get_source(),occurrence.scripted_incident_data.incident_data.incident_id): return _bad("MISSING_COMPLETED_SIDE")
	var candidates := FailureEventCandidateState.new()
	var candidate_ids: Array[String] = []
	for row: Variant in p.candidates:
		if not _fields(row,{"source_case_id":TYPE_STRING,"incident_id":TYPE_STRING,"opportunity_threshold":TYPE_INT,"opportunities_seen":TYPE_INT,"disturbance_triggered":TYPE_BOOL,"major_opportunity_count":TYPE_INT,"major_trigger_threshold":TYPE_INT,"major_incident_triggered":TYPE_BOOL}): return _bad("CANDIDATE_FORMAT")
		var resolution: Dictionary = resolved.get_resolution(row.source_case_id)
		if resolution.is_empty() or resolution.result != 2 or row.incident_id != resolution.incident_id or candidate_ids.has(row.source_case_id) or row.opportunity_threshold < 2 or row.opportunity_threshold > 4 or row.opportunities_seen < 0 or row.opportunities_seen > row.opportunity_threshold or row.major_trigger_threshold != 1 or row.major_opportunity_count < 0 or row.major_opportunity_count > 1 or row.major_incident_triggered: return _bad("CANDIDATE")
		if row.disturbance_triggered and row.opportunities_seen != row.opportunity_threshold or not row.disturbance_triggered and row.major_opportunity_count != 0: return _bad("CANDIDATE_PHASE")
		var source: IncidentSource = IncidentSource.new(0,campaign.get_case_entry(row.source_case_id).entry_id,row.source_case_id)
		if responses.has_response(source,row.incident_id): return _bad("COMPLETED_CANDIDATE")
		candidate_ids.append(row.source_case_id)
	# Registration order determines the oldest actionable event.
	var expected_candidates: Array[String] = []
	for id: String in completed_cases:
		var resolution: Dictionary = resolved.get_resolution(id)
		if resolution.result == 2 and not responses.has_response(IncidentSource.new(0,campaign.get_case_entry(id).entry_id,id),resolution.incident_id): expected_candidates.append(id)
	if candidate_ids != expected_candidates: return _bad("CANDIDATE_ORDER_OR_MISSING")
	candidates.restore_validated_save_data(p.candidates)
	var data: CaseData = current.case_data
	var rt: Variant = p.runtime
	if not _fields(rt,{"case_id":TYPE_STRING,"experiments":TYPE_ARRAY,"conditions":TYPE_DICTIONARY,"room_id":TYPE_STRING,"discoveries":TYPE_ARRAY,"sources":TYPE_ARRAY,"disturbances":TYPE_ARRAY}) or rt.case_id != data.case_id or not _strings(rt.experiments) or rt.experiments.size() > data.experiment_limit or rt.conditions.size() != rt.experiments.size(): return _bad("RUNTIME")
	var runtime := CaseRuntimeState.new(data.case_id)
	var disturbance_ids: Array[String] = []
	for row: Variant in rt.disturbances:
		if not _fields(row,{"disturbance_id":TYPE_STRING,"reaction_id":TYPE_STRING}) or disturbance_ids.has(row.disturbance_id): return _bad("DISTURBANCE")
		var found: bool = false
		for id: String in completed_cases:
			var resolution: Dictionary = resolved.get_resolution(id)
			if resolution.result != 2: continue
			var incident: IncidentData = _unique(campaign.get_case_entry(id).case_data.incidents,"incident_id",resolution.incident_id)
			if incident != null and incident.environmental_disturbance != null and incident.environmental_disturbance.disturbance_id == row.disturbance_id:
				var candidate: Dictionary = candidates.get_candidate(id)
				found = candidate.get("disturbance_triggered",false) or responses.has_response(IncidentSource.new(0,campaign.get_case_entry(id).entry_id,id),resolution.incident_id)
		var reaction: CaseDisturbanceReactionData = _unique(data.disturbance_reactions,"disturbance_id",row.disturbance_id)
		if not found or row.reaction_id != (reaction.reaction_id if reaction != null else "") or not runtime.try_apply_disturbance(row.disturbance_id,row.reaction_id): return _bad("DISTURBANCE_SOURCE")
		disturbance_ids.append(row.disturbance_id)
	for id: String in rt.experiments:
		if _unique(data.available_experiments,"experiment_id",id) == null or not rt.conditions.has(id) or not _strings(rt.conditions[id]): return _bad("EXPERIMENT")
		var conditions: Array[String] = [];conditions.assign(rt.conditions[id])
		for observed: String in conditions:
			var item: ExperimentConditionObservationData = _unique(data.experiment_condition_observations,"observation_id",observed)
			if item == null or item.experiment_id != id or not disturbance_ids.has(item.disturbance_id): return _bad("EXPERIMENT_CONDITION")
		if not runtime.try_record_experiment_execution(id,data.experiment_limit,conditions): return _bad("EXPERIMENT_LIMIT")
	if not rt.room_id.is_empty():
		if p.stage != "CONTAINMENT" or _unique(data.available_containment_rooms,"room_id",rt.room_id) == null or not runtime.try_confirm_containment_room(rt.room_id): return _bad("ROOM")
	var pending := PendingContainmentState.new()
	if p.pending.size() != (0 if rt.room_id.is_empty() else 1): return _bad("PENDING")
	for row: Variant in p.pending:
		if not _fields(row,{"case_id":TYPE_STRING,"room_id":TYPE_STRING}) or row.case_id != data.case_id or row.room_id != rt.room_id or not pending.try_add_pending(row.case_id,row.room_id): return _bad("PENDING_SOURCE")
	var source_keys: Array[String] = []
	for row: Variant in rt.sources:
		if not _fields(row,{"source_kind":TYPE_INT,"source_id":TYPE_STRING}) or not _runtime_source_valid(data,runtime,row.source_kind,row.source_id): return _bad("RESEARCH_SOURCE")
		var key: String = JSON.stringify([row.source_kind,row.source_id])
		if source_keys.has(key) or not runtime.try_observe_research_source(row.source_kind,row.source_id): return _bad("DUPLICATE_SOURCE")
		source_keys.append(key)
	var expected_discoveries: Array[String] = []
	for row: Dictionary in rt.sources:
		for entry: ResearchEntryData in data.research_entries:
			if entry.source_kind == row.source_kind and entry.source_id == row.source_id: expected_discoveries.append(entry.entry_id)
	if not _strings(rt.discoveries) or rt.discoveries != expected_discoveries: return _bad("RESEARCH_DISCOVERIES")
	for id: String in rt.discoveries: runtime.try_discover_research_entry(id)
	if data.profile_data != null and not runtime.has_observed_research_source(0,data.profile_data.profile_id): return _bad("MISSING_PROFILE")
	if p.stage == "PROFILE" and (not rt.experiments.is_empty() or not rt.room_id.is_empty() or rt.sources.size() != 1 or not rt.disturbances.is_empty()): return _bad("PROFILE_PHASE")
	if p.stage == "CONTAINMENT" and data.cctv_data != null and not runtime.has_observed_research_source(1,data.cctv_data.camera_id): return _bad("MISSING_CCTV")
	for id: String in rt.experiments:
		if not runtime.has_observed_research_source(2,id): return _bad("MISSING_EXPERIMENT_RESEARCH")
	if not rt.room_id.is_empty() and not runtime.has_observed_research_source(3,rt.room_id): return _bad("MISSING_ROOM_RESEARCH")
	var archive := ResearchArchiveState.new()
	var archive_ids: Array[String] = []
	for row: Variant in p.archives:
		if not _fields(row,{"case_id":TYPE_STRING,"entries":TYPE_ARRAY}) or not completed_cases.has(row.case_id) or archive_ids.has(row.case_id) or not _strings(row.entries) or row.entries.is_empty(): return _bad("ARCHIVE")
		var source_data: CaseData = campaign.get_case_entry(row.case_id).case_data
		for id: String in row.entries:
			if _unique(source_data.research_entries,"entry_id",id) == null: return _bad("ARCHIVE_RESEARCH_ID")
		var entries: Array[String] = [];entries.assign(row.entries)
		archive.merge_case_discoveries(row.case_id,entries);archive_ids.append(row.case_id)
	for id: String in completed_cases:
		var source_data: CaseData = campaign.get_case_entry(id).case_data
		if not source_data.research_entries.is_empty() and not archive_ids.has(id): return _bad("MISSING_ARCHIVE")
	var hypotheses := WorkingHypothesisState.new()
	if not _valid_hypotheses(p.hypotheses,visited): return _bad("HYPOTHESES")
	hypotheses.restore_validated_save_data(p.hypotheses)
	var stories := StoryCollectionState.new()
	if not stories.configure(records) or not _strings(p.stories): return _bad("STORY_CATALOG")
	for id: String in p.stories:
		var item: StoryRecordData = _unique(records,"record_id",id)
		if item == null or not item.discovery_entry_id.is_empty() and not (completed.has(item.discovery_entry_id) or item.discovery_entry_id == current.entry_id and (item.discovery_stage == "PROFILE" or p.stage == "CONTAINMENT")) or not stories.try_discover(id): return _bad("STORY_DISCOVERY")
	if not _fields(p.rng,{"seed":TYPE_STRING,"state":TYPE_STRING}) or not _int64(p.rng.seed) or not _int64(p.rng.state): return _bad("RNG")
	if not _fields(p.pacing,{"processed":TYPE_ARRAY,"tokens":TYPE_ARRAY,"credit":TYPE_BOOL}) or not _strings(p.pacing.processed) or not _strings(p.pacing.tokens): return _bad("PACING")
	var expected_processed: Array[String] = []
	if p.stage == "CONTAINMENT":
		expected_processed.append("cctv:entry")
		for id: String in rt.experiments: expected_processed.append("experiment:"+id)
		expected_processed.append("containment:entry")
	if p.pacing.processed != expected_processed: return _bad("OPPORTUNITY_ACCOUNTING")
	for token: String in p.pacing.tokens:
		var tuple: Variant = JSON.parse_string(token)
		if not tuple is Array or tuple.size() != 3 or not tuple[0] is String or not visited.has(tuple[0]) or not tuple[1] is String or not tuple[2] is String: return _bad("CREDIT_TOKEN")
		if token != JSON.stringify(tuple): return _bad("NONCANONICAL_TOKEN")
		var source_data: CaseData = campaign.get_case_entry(tuple[0]).case_data
		if tuple[1] == "cctv":
			if source_data.cctv_data == null or source_data.cctv_data.camera_id != tuple[2]: return _bad("CCTV_TOKEN")
		elif tuple[1] == "experiment":
			if _unique(source_data.available_experiments,"experiment_id",tuple[2]) == null or tuple[0] == data.case_id and not runtime.has_executed_experiment(tuple[2]): return _bad("EXPERIMENT_TOKEN")
		elif tuple[1] == "containment":
			if tuple[2] != (runtime.get_confirmed_containment_room_id() if tuple[0] == data.case_id else resolved.get_resolution(tuple[0]).room_id): return _bad("ROOM_TOKEN")
		else: return _bad("CREDIT_KIND")
	for id: String in completed_cases + ([data.case_id] if not rt.room_id.is_empty() else []):
		var room_id: String = rt.room_id if id == data.case_id else resolved.get_resolution(id).room_id
		if not p.pacing.tokens.has(JSON.stringify([id,"containment",room_id])): return _bad("MISSING_ROOM_CREDIT_TOKEN")
	var view_error: String = InterruptedWorkViewState.get_validation_error(p.stage,p.view,data,runtime,pending,resolved)
	if not view_error.is_empty(): return _bad("VIEW_"+view_error)
	return {"error":"", "progress":progress,"runtime":runtime,"pending":pending,"resolutions":resolved,"candidates":candidates,"responses":responses,"archive":archive,"hypotheses":hypotheses,"stories":stories,"payload":p.duplicate(true)}

static func _runtime_source_valid(data: CaseData, runtime: CaseRuntimeState, kind: int, id: String) -> bool:
	match kind:
		0: return data.profile_data != null and data.profile_data.profile_id == id
		1: return data.cctv_data != null and data.cctv_data.camera_id == id
		2: return runtime.has_executed_experiment(id)
		3: return not id.is_empty() and runtime.get_confirmed_containment_room_id() == id
		8:
			for row: Dictionary in runtime.get_applied_disturbances():
				if row.reaction_id == id and not id.is_empty(): return true
		9:
			var item: CCTVConditionObservationData = _unique(data.cctv_condition_observations,"observation_id",id)
			if item == null: return false
			for row: Dictionary in runtime.get_applied_disturbances():
				if row.disturbance_id == item.disturbance_id: return true
		10:
			for exp_id: String in runtime.get_experiment_execution_history():
				if runtime.get_experiment_condition_observation_ids(exp_id).has(id): return true
	return false

static func _valid_hypotheses(data: Dictionary, visited: Array[String]) -> bool:
	if not _fields(data,{"records":TYPE_DICTIONARY,"counters":TYPE_DICTIONARY}): return false
	for id: Variant in data.counters:
		if not id is String or not visited.has(id) or not data.counters[id] is int or data.counters[id] < 1 or data.counters[id] > 10000: return false
	for id: Variant in data.records:
		if not id is String or not visited.has(id) or not data.counters.has(id) or not data.records[id] is Array or data.records[id].size() > 1000: return false
		var unique: Array[String] = []
		for row: Variant in data.records[id]:
			if not _fields(row,{"hypothesis_id":TYPE_STRING,"text":TYPE_STRING}) or unique.has(row.hypothesis_id) or row.text.is_empty() or row.text != row.text.strip_edges() or row.text.length() > WorkingHypothesisState.MAX_TEXT_LENGTH or not row.hypothesis_id.begins_with("HYP_"): return false
			var sequence: String = row.hypothesis_id.trim_prefix("HYP_")
			if sequence.length() > 5 or not sequence.is_valid_int(): return false
			var seq: int = sequence.to_int()
			if seq < 1 or row.hypothesis_id != "HYP_%03d" % seq or seq >= data.counters[id]: return false
			unique.append(row.hypothesis_id)
	return true

static func _fields(value: Variant, schema: Dictionary) -> bool:
	if not value is Dictionary or value.size() != schema.size(): return false
	for key: String in schema:
		if not value.has(key) or typeof(value[key]) != schema[key]: return false
	return true

static func _strings(value: Variant) -> bool:
	if not value is Array or value.size() > 4096: return false
	var unique: Array[String] = []
	for id: Variant in value:
		if not id is String or id.is_empty() or id.length() > 1000 or unique.has(id): return false
		unique.append(id)
	return true

static func _unique(items: Array, field: String, id: String) -> Resource:
	var found: Resource = null
	for item: Resource in items:
		if item != null and item.get(field) == id:
			if found != null: return null
			found = item
	return found

static func _ids(items: Array, field: String) -> Array:
	return items.map(func(item: Resource) -> String: return str(item.get(field)))

static func _int64(value: String) -> bool:
	if not value.is_valid_int(): return false
	var digits: String = value.trim_prefix("-")
	if digits.length() > 19: return false
	var limit: String = "9223372036854775808" if value.begins_with("-") else "9223372036854775807"
	if digits.length() == 19 and digits > limit: return false
	return str(value.to_int()) == value

static func _bad(error: String) -> Dictionary:
	return {"error":error}
