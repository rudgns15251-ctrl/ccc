class_name MonitoringOutcomeData
extends Resource

enum Result { UNDEFINED, SUCCESS, FAILURE }

@export var room_id: String = ""
@export var stages: Array[MonitoringStageData] = []
@export var final_result: Result = Result.UNDEFINED
@export var incident_id: String = ""
# Explicit authored non-escape failure. Existing outcomes remain incident-driven.
@export var failure_without_incident: bool = false

func is_non_escape_failure() -> bool:
	return final_result == Result.FAILURE and failure_without_incident and incident_id.is_empty()
