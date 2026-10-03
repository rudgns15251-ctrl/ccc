extends "res://scripts/views/flow_view.gd"

@onready var incident_id_label: Label = %IncidentId
@onready var display_name_label: Label = %DisplayName
@onready var description_label: Label = %Description

var _incident_data: IncidentData
var _can_advance: bool = false


func setup(incident_data: IncidentData, can_advance: bool = false) -> void:
	_incident_data = incident_data
	_can_advance = can_advance
	if is_node_ready():
		_display_incident()


func _ready() -> void:
	super._ready()
	_display_incident()


func _display_incident() -> void:
	next_button.disabled = true
	if _incident_data == null:
		push_warning("IncidentView.setup(): IncidentData is missing.")
		incident_id_label.text = ""
		display_name_label.text = "Incident data unavailable"
		description_label.text = "No IncidentData was provided to this View."
		return
	if _incident_data.incident_id.strip_edges().is_empty():
		push_warning("IncidentView: incident_id is empty.")
		incident_id_label.text = "ID: [Missing incident_id]"
		display_name_label.text = "Incident data unavailable"
		description_label.text = "IncidentData has no valid incident_id."
		return

	incident_id_label.text = "ID: " + _incident_data.incident_id
	display_name_label.text = _text_or_placeholder(_incident_data.display_name, "display_name")
	description_label.text = _text_or_placeholder(_incident_data.description, "description")
	next_button.disabled = not _can_advance
	if _can_advance:
		next_button.grab_focus()


func _on_next_button_pressed() -> void:
	if _can_advance and _incident_data != null and not _incident_data.incident_id.strip_edges().is_empty() and not next_button.disabled:
		super._on_next_button_pressed()


func _text_or_placeholder(value: String, field_name: String) -> String:
	if value.strip_edges().is_empty():
		push_warning("IncidentView: %s is empty." % field_name)
		return "[Missing %s]" % field_name
	return value
