extends "res://scripts/views/flow_view.gd"

@onready var result_id_label: Label = %ResultId
@onready var display_name_label: Label = %DisplayName
@onready var description_label: Label = %Description

var _incident_result_data: IncidentResultData


func setup(incident_result_data: IncidentResultData) -> void:
	_incident_result_data = incident_result_data
	if is_node_ready():
		_display_incident_result()


func _ready() -> void:
	super._ready()
	_display_incident_result()


func _display_incident_result() -> void:
	next_button.disabled = true
	if _incident_result_data == null:
		push_warning("IncidentResultView.setup(): IncidentResultData is missing.")
		result_id_label.text = ""
		display_name_label.text = "Incident result data unavailable"
		description_label.text = "No IncidentResultData was provided to this View."
		return
	if _incident_result_data.result_id.strip_edges().is_empty():
		push_warning("IncidentResultView: result_id is empty.")
		result_id_label.text = "ID: [Missing result_id]"
		display_name_label.text = "Incident result data unavailable"
		description_label.text = "IncidentResultData has no valid result_id."
		return

	result_id_label.text = "ID: " + _incident_result_data.result_id
	display_name_label.text = _text_or_placeholder(_incident_result_data.display_name, "display_name")
	description_label.text = _text_or_placeholder(_incident_result_data.description, "description")
	next_button.disabled = false
	next_button.grab_focus()


func _on_next_button_pressed() -> void:
	if not next_button.disabled and _incident_result_data != null and not _incident_result_data.result_id.strip_edges().is_empty():
		super._on_next_button_pressed()


func _text_or_placeholder(value: String, field_name: String) -> String:
	if value.strip_edges().is_empty():
		push_warning("IncidentResultView: %s is empty." % field_name)
		return "[Missing %s]" % field_name
	return value
