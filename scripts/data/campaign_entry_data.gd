class_name CampaignEntryData
extends Resource

enum EntryKind { CASE, SCRIPTED_INCIDENT }

@export var entry_id: String = ""
@export var entry_kind: EntryKind = EntryKind.CASE
@export var case_data: CaseData
@export var scripted_incident_data: ScriptedIncidentData


# Authored occurrence identity, separate from the Case definition ID.
# Validation never changes the entry or its payload.
func get_validation_error() -> String:
	if entry_id.strip_edges().is_empty():
		return "entry_id is empty."
	match entry_kind:
		EntryKind.CASE:
			if case_data == null or scripted_incident_data != null: return "CASE requires only CaseData payload."
			if case_data.case_id.strip_edges().is_empty(): return "CaseData.case_id is empty."
		EntryKind.SCRIPTED_INCIDENT:
			if case_data != null or scripted_incident_data == null: return "SCRIPTED_INCIDENT requires only scripted payload."
			return scripted_incident_data.get_validation_error()
		_: return "Unsupported entry_kind: %d." % entry_kind
	return ""
