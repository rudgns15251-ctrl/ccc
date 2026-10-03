class_name MonitoringOutcomeData
extends Resource

enum Result { UNDEFINED, SUCCESS, FAILURE }

@export var room_id: String = ""
@export var stages: Array[MonitoringStageData] = []
@export var final_result: Result = Result.UNDEFINED
