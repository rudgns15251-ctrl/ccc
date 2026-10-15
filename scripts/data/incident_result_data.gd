class_name IncidentResultData
extends Resource

@export var result_id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""

# -1 / empty text means unknown; zero is an explicitly authored observation.
@export_range(-1, 100000) var staff_deaths: int = -1
@export_range(-1, 100000) var staff_injuries: int = -1
@export_multiline var facility_damage: String = ""
@export_multiline var additional_observation: String = ""

func valid_consequences() -> bool:
	return staff_deaths >= -1 and staff_deaths <= 100000 and staff_injuries >= -1 and staff_injuries <= 100000

func consequences() -> Dictionary:
	return {"staff_deaths": staff_deaths, "staff_injuries": staff_injuries, "facility_damage": facility_damage, "additional_observation": additional_observation}
