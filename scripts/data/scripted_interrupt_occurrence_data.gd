class_name ScriptedInterruptOccurrenceData
extends Resource

enum CheckpointKind { STAGE_PRESENTED, ACTION_ACCEPTED }
const WORK_STAGES: Array[String] = ["PROFILE", "CCTV", "EXPERIMENT", "CONTAINMENT"]
const EXPERIMENT_RESULT_READ: String = "EXPERIMENT_RESULT_READ"

@export var interrupt_id: String = ""
@export var target_entry_id: String = ""
@export var scripted_incident_data: ScriptedIncidentData
@export var checkpoint_kind: CheckpointKind = CheckpointKind.STAGE_PRESENTED
@export var stage_id: String = "PROFILE"
@export var action_id: String = ""


func get_validation_error() -> String:
	if interrupt_id.strip_edges().is_empty(): return "interrupt_id is empty."
	if target_entry_id.strip_edges().is_empty(): return "target_entry_id is empty."
	if scripted_incident_data == null: return "ScriptedIncidentData is missing."
	var error: String = scripted_incident_data.get_validation_error()
	if not error.is_empty(): return error
	if checkpoint_kind not in [CheckpointKind.STAGE_PRESENTED, CheckpointKind.ACTION_ACCEPTED]: return "Unsupported checkpoint kind."
	if stage_id not in WORK_STAGES: return "Unsupported work stage_id."
	if checkpoint_kind == CheckpointKind.STAGE_PRESENTED:
		if not action_id.is_empty(): return "STAGE_PRESENTED cannot have an action_id."
	elif stage_id != "EXPERIMENT" or action_id != EXPERIMENT_RESULT_READ:
		return "Unsupported ACTION_ACCEPTED stage/action."
	return ""


func checkpoint_key() -> String:
	return JSON.stringify([target_entry_id, checkpoint_kind, stage_id, action_id])


func matches_checkpoint(entry_id: String, kind: int, stage: String, action: String) -> bool:
	return target_entry_id == entry_id and checkpoint_kind == kind and stage_id == stage and action_id == action


func get_source() -> IncidentSource:
	return IncidentSource.new(IncidentSource.OriginKind.CAMPAIGN_INTERRUPT, interrupt_id, scripted_incident_data.event_id) if scripted_incident_data != null else null
