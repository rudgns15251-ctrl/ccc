extends "res://scripts/views/flow_view.gd"

const EnvironmentConditions = preload("res://scripts/views/environment_conditions_view.gd")

class ConditionObservation extends RefCounted:
	var observation_id: String
	var display_name: String
	var observation_text: String

	func _init(id: String, title: String, text: String) -> void:
		observation_id = id
		display_name = title
		observation_text = text


class ConditionSnapshot extends RefCounted:
	var entries: Array[ConditionObservation] = []

@onready var camera_id_label: Label = %CameraId
@onready var observation_label: Label = %Description

var _cctv_data: CCTVData
var _condition_observations: Array[ConditionObservation] = []
var _displayed_observation_ids: Array[String] = []


func setup(cctv_data: CCTVData) -> void:
	_cctv_data = cctv_data
	if is_node_ready():
		_display_cctv()


func _ready() -> void:
	super._ready()
	_display_cctv()
	_display_condition_observations()


func _display_cctv() -> void:
	if _cctv_data == null:
		push_warning("CCTVView.setup(): CCTVData is missing.")
		camera_id_label.text = "CCTV data unavailable"
		observation_label.text = "No CCTVData was provided to this View."
		return

	camera_id_label.text = _text_or_placeholder(_cctv_data.camera_id, "camera_id")
	observation_label.text = _text_or_placeholder(_cctv_data.observation_text, "observation_text")


func _text_or_placeholder(value: String, field_name: String) -> String:
	if value.strip_edges().is_empty():
		push_warning("CCTVView: %s is empty." % field_name)
		return "[Missing %s]" % field_name
	return value


func set_environment_conditions(summary: EnvironmentConditions.Summary) -> void:
	var conditions: EnvironmentConditions = get_node("%EnvironmentConditions")
	conditions.set_summary(summary)


func set_condition_observations(snapshot: ConditionSnapshot) -> void:
	_condition_observations.clear()
	if snapshot != null:
		for entry: ConditionObservation in snapshot.entries:
			_condition_observations.append(ConditionObservation.new(entry.observation_id, entry.display_name, entry.observation_text))
	if is_node_ready():
		_display_condition_observations()


func _display_condition_observations() -> void:
	var list: VBoxContainer = %ConditionObservationList
	_displayed_observation_ids.clear()
	for item: Node in list.get_children():
		list.remove_child(item)
		item.queue_free()
	%ConditionObservationSection.visible = not _condition_observations.is_empty()
	for entry: ConditionObservation in _condition_observations:
		var label := Label.new()
		label.text = "%s\n%s" % [entry.display_name, entry.observation_text]
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.add_theme_font_size_override("font_size", 20)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		list.add_child(label)
		_displayed_observation_ids.append(entry.observation_id)


func get_displayed_condition_observation_ids() -> Array[String]:
	if not is_node_ready() or not is_visible_in_tree() or not %ConditionObservationSection.is_visible_in_tree():
		return []
	return _displayed_observation_ids.duplicate()


func is_displaying_cctv(cctv_data: CCTVData) -> bool:
	return is_node_ready() and _cctv_data != null and _cctv_data == cctv_data and camera_id_label.text == cctv_data.camera_id
