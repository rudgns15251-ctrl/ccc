class_name CampaignData
extends Resource

@export var campaign_id: String = ""
@export var display_name: String = ""
@export var entries: Array[CampaignEntryData] = []
# Side occurrences never participate in the authored sequence cursor.
@export var scripted_interrupts: Array[ScriptedInterruptOccurrenceData] = []


# Authored order only. Validate every entry before any Case starts.
func get_validation_error() -> String:
	if campaign_id.strip_edges().is_empty():
		return "campaign_id is empty."
	if entries.is_empty():
		return "entries is empty."
	var entry_ids: Array[String] = []
	var case_ids: Array[String] = []
	for index: int in range(entries.size()):
		var entry: CampaignEntryData = entries[index]
		if entry == null:
			return "Campaign entry at index %d is missing." % index
		var entry_error: String = entry.get_validation_error()
		if not entry_error.is_empty():
			return "Campaign entry at index %d (%s): %s" % [index, entry.entry_id, entry_error]
		if entry_ids.has(entry.entry_id):
			return "Duplicate entry_id at index %d: %s." % [index, entry.entry_id]
		# Existing runtime States still use case_id as an assignment key.
		if entry.entry_kind == CampaignEntryData.EntryKind.CASE and case_ids.has(entry.case_data.case_id):
			return "Duplicate CaseData.case_id at index %d (%s): %s." % [index, entry.entry_id, entry.case_data.case_id]
		entry_ids.append(entry.entry_id)
		if entry.entry_kind == CampaignEntryData.EntryKind.CASE: case_ids.append(entry.case_data.case_id)
	var interrupt_ids: Array[String] = []
	var checkpoints: Array[String] = []
	for index: int in range(scripted_interrupts.size()):
		var occurrence: ScriptedInterruptOccurrenceData = scripted_interrupts[index]
		if occurrence == null: return "Scripted interrupt at index %d is missing." % index
		var error: String = occurrence.get_validation_error()
		if not error.is_empty(): return "Scripted interrupt at index %d: %s" % [index, error]
		if entry_ids.has(occurrence.interrupt_id) or interrupt_ids.has(occurrence.interrupt_id): return "Duplicate authored occurrence ID: " + occurrence.interrupt_id
		var target: CampaignEntryData = get_entry(occurrence.target_entry_id)
		if target == null or target.entry_kind != CampaignEntryData.EntryKind.CASE: return "Interrupt target must be an existing CASE entry."
		if checkpoints.has(occurrence.checkpoint_key()): return "Duplicate interrupt checkpoint: " + occurrence.checkpoint_key()
		interrupt_ids.append(occurrence.interrupt_id)
		checkpoints.append(occurrence.checkpoint_key())
	return ""


func get_entry(id: String) -> CampaignEntryData:
	for entry: CampaignEntryData in entries:
		if entry != null and entry.entry_id == id: return entry
	return null


# Unique CASE definition IDs remain required; this is not repeated-Case support.
func get_case_entry(case_id: String) -> CampaignEntryData:
	var found: CampaignEntryData = null
	for entry: CampaignEntryData in entries:
		if entry != null and entry.entry_kind == CampaignEntryData.EntryKind.CASE and entry.case_data != null and entry.case_data.case_id == case_id:
			if found != null: return null
			found = entry
	return found


func get_interrupt(id: String) -> ScriptedInterruptOccurrenceData:
	for occurrence: ScriptedInterruptOccurrenceData in scripted_interrupts:
		if occurrence != null and occurrence.interrupt_id == id: return occurrence
	return null


func get_interrupt_at_checkpoint(entry_id: String, kind: int, stage: String, action: String = "") -> ScriptedInterruptOccurrenceData:
	for occurrence: ScriptedInterruptOccurrenceData in scripted_interrupts:
		if occurrence != null and occurrence.matches_checkpoint(entry_id, kind, stage, action): return occurrence
	return null
