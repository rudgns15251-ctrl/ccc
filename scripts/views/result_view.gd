extends "res://scripts/views/flow_view.gd"

class Summary extends RefCounted:
	var case_id: String = ""
	var case_display_name: String = ""
	var monitoring_result: MonitoringOutcomeData.Result = MonitoringOutcomeData.Result.UNDEFINED
	var room_id: String = ""
	var room: ContainmentData
	var experiment_ids: Array[String] = []
	var experiments: Array[ExperimentData] = []
	var experiment_limit: int = 0
	var incident: IncidentData
	var broadcast: EmergencyBroadcastData
	var option: BroadcastOptionData
	var incident_result: IncidentResultData


@onready var case_label: Label = %Description
@onready var final_result_label: Label = %FinalResult
@onready var containment_label: Label = %Containment
@onready var usage_label: Label = %ExperimentUsage
@onready var experiment_empty_label: Label = %ExperimentEmpty
@onready var experiment_list: VBoxContainer = %ExperimentList
@onready var summary_scroll: ScrollContainer = %SummaryScroll
@onready var incident_label: Label = %IncidentInfo
@onready var broadcast_label: Label = %BroadcastInfo
@onready var option_label: Label = %ResponseInfo
@onready var incident_result_label: Label = %IncidentResultInfo

var _summary: Summary


func setup(summary: Summary) -> void:
	_summary = summary
	if is_node_ready():
		_display_summary()


func _ready() -> void:
	super._ready()
	_display_summary()


func _display_summary() -> void:
	next_button.disabled = true
	summary_scroll.scroll_vertical = 0
	for item: Node in experiment_list.get_children():
		experiment_list.remove_child(item)
		item.queue_free()
	experiment_empty_label.visible = true
	case_label.text = "Case: [Unavailable]"
	final_result_label.text = "Final Result: [Unavailable]"
	containment_label.text = "Containment: None"
	usage_label.text = "Experiment Usage: 0 / 0"
	incident_label.text = "Incident: [Unavailable]"
	broadcast_label.text = "Emergency Broadcast: [Unavailable]"
	option_label.text = "Selected Response: [Unavailable]"
	incident_result_label.text = "Incident Result: [Unavailable]"
	if _summary == null:
		push_warning("ResultView.setup(): summary is missing.")
		return

	case_label.text = "Case: " + _entry_text(_summary.case_id, _summary.case_display_name, "Case")
	if _summary.monitoring_result == MonitoringOutcomeData.Result.SUCCESS:
		final_result_label.text = "Final Result: SUCCESS"
		incident_label.text = "Incident: None (not occurred)"
		broadcast_label.text = "Emergency Broadcast: Not applicable"
		option_label.text = "Selected Response: Not applicable"
		incident_result_label.text = "Incident Result: Not applicable"
	elif _summary.monitoring_result == MonitoringOutcomeData.Result.FAILURE:
		final_result_label.text = "Final Result: FAILURE"
		_display_failure_details()
	else:
		push_warning("ResultView: monitoring result is undefined or unsupported.")

	if _summary.room_id.strip_edges().is_empty():
		push_warning("ResultView: confirmed containment room ID is missing.")
	elif _summary.room == null or _summary.room.room_id != _summary.room_id:
		push_warning("ResultView: ContainmentData is unavailable for room %s." % _summary.room_id)
		containment_label.text = "Containment: %s [Unavailable]" % _summary.room_id
	else:
		containment_label.text = "Containment: " + _entry_text(_summary.room_id, _summary.room.display_name, "Containment")

	if _summary.experiment_limit < 0:
		push_warning("ResultView: experiment_limit is negative; displaying zero.")
	usage_label.text = "Experiment Usage: %d / %d" % [_summary.experiment_ids.size(), maxi(_summary.experiment_limit, 0)]
	experiment_empty_label.visible = _summary.experiment_ids.is_empty()
	for index in range(_summary.experiment_ids.size()):
		var id: String = _summary.experiment_ids[index]
		var experiment: ExperimentData = _summary.experiments[index] if index < _summary.experiments.size() else null
		var item := Label.new()
		item.add_theme_font_size_override("font_size", 18)
		item.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if id.strip_edges().is_empty():
			push_warning("ResultView: executed experiment ID at index %d is empty." % index)
			item.text = "[Unavailable experiment ID]"
		elif experiment == null or experiment.experiment_id != id:
			push_warning("ResultView: ExperimentData is unavailable for executed ID %s." % id)
			item.text = id + " [Unavailable]"
		else:
			item.text = _entry_text(id, experiment.display_name, "Experiment")
		experiment_list.add_child(item)

	next_button.disabled = _summary.monitoring_result != MonitoringOutcomeData.Result.SUCCESS and _summary.monitoring_result != MonitoringOutcomeData.Result.FAILURE
	if not next_button.disabled:
		next_button.grab_focus()


func _display_failure_details() -> void:
	if _summary.incident == null:
		push_warning("ResultView: FAILURE IncidentData is unavailable.")
	else:
		incident_label.text = "Incident: " + _entry_text(_summary.incident.incident_id, _summary.incident.display_name, "Incident")
	if _summary.broadcast == null:
		push_warning("ResultView: FAILURE EmergencyBroadcastData is unavailable.")
	else:
		broadcast_label.text = "Emergency Broadcast: " + _entry_text(_summary.broadcast.broadcast_id, _summary.broadcast.display_name, "Broadcast")
	if _summary.option == null:
		push_warning("ResultView: FAILURE confirmed BroadcastOptionData is unavailable.")
	else:
		option_label.text = "Selected Response: " + _entry_text(_summary.option.option_id, _summary.option.display_text, "Broadcast Option")
	if _summary.incident_result == null:
		push_warning("ResultView: FAILURE IncidentResultData is unavailable.")
	else:
		incident_result_label.text = "Incident Result: " + _entry_text(_summary.incident_result.result_id, _summary.incident_result.display_name, "Incident Result")


func _on_next_button_pressed() -> void:
	if not next_button.disabled:
		super._on_next_button_pressed()


func _entry_text(id: String, display_name: String, field_name: String) -> String:
	if id.strip_edges().is_empty():
		push_warning("ResultView: %s ID is missing." % field_name)
		return "[Unavailable]"
	if display_name.strip_edges().is_empty():
		push_warning("ResultView: %s display name/text is missing." % field_name)
		return id + " [Missing display name/text]"
	return "%s (%s)" % [display_name, id]
