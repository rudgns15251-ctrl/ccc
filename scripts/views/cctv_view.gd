extends "res://scripts/views/flow_view.gd"

@onready var camera_id_label: Label = %CameraId
@onready var observation_label: Label = %Description

var _cctv_data: CCTVData


func setup(cctv_data: CCTVData) -> void:
	_cctv_data = cctv_data
	if is_node_ready():
		_display_cctv()


func _ready() -> void:
	super._ready()
	_display_cctv()


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
