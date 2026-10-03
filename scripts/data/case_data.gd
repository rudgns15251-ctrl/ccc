class_name CaseData
extends Resource

@export var case_id: String = ""
@export var display_name: String = ""
@export var profile_data: ProfileData
@export var cctv_data: CCTVData
@export var available_experiments: Array[ExperimentData] = []
@export var experiment_limit: int = 0
@export var available_containment_rooms: Array[ContainmentData] = []
@export var containment_outcomes: Array[MonitoringOutcomeData] = []
@export var incidents: Array[IncidentData] = []
