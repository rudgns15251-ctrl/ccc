class_name ScriptedIncidentData
extends Resource

@export var event_id: String = ""
@export var incident_data: IncidentData
@export var emergency_broadcasts: Array[EmergencyBroadcastData] = []
@export var incident_results: Array[IncidentResultData] = []


# Definition scope only. No Case content, effects, or runtime progression.
func get_validation_error() -> String:
	if event_id.strip_edges().is_empty(): return "event_id is empty."
	if incident_data == null or incident_data.incident_id.strip_edges().is_empty(): return "IncidentData/incident_id is missing."
	if incident_data.display_name.strip_edges().is_empty() or incident_data.description.strip_edges().is_empty(): return "Incident display content is empty."
	var broadcast_ids: Array[String] = []
	var result_ids: Array[String] = []
	for result: IncidentResultData in incident_results:
		if result == null or result.result_id.strip_edges().is_empty() or result_ids.has(result.result_id): return "Missing/duplicate result_id."
		if result.display_name.strip_edges().is_empty() or result.description.strip_edges().is_empty(): return "Result display content is empty."
		result_ids.append(result.result_id)
	for broadcast: EmergencyBroadcastData in emergency_broadcasts:
		if broadcast == null or broadcast.broadcast_id.strip_edges().is_empty() or broadcast_ids.has(broadcast.broadcast_id): return "Missing/duplicate broadcast_id."
		if broadcast.display_name.strip_edges().is_empty() or broadcast.prompt_text.strip_edges().is_empty() or broadcast.options.is_empty(): return "Broadcast content/options is empty."
		broadcast_ids.append(broadcast.broadcast_id)
		var option_ids: Array[String] = []
		for option: BroadcastOptionData in broadcast.options:
			if option == null or option.option_id.strip_edges().is_empty() or option_ids.has(option.option_id): return "Missing/duplicate option_id."
			if option.display_text.strip_edges().is_empty() or not result_ids.has(option.result_id): return "Invalid option text/result link."
			option_ids.append(option.option_id)
	if not broadcast_ids.has(incident_data.broadcast_id): return "Incident broadcast link is unavailable."
	return ""


func get_broadcast(id: String) -> EmergencyBroadcastData:
	for data: EmergencyBroadcastData in emergency_broadcasts:
		if data != null and data.broadcast_id == id: return data
	return null


func get_result(id: String) -> IncidentResultData:
	for data: IncidentResultData in incident_results:
		if data != null and data.result_id == id: return data
	return null
