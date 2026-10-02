extends "res://scripts/views/flow_view.gd"

@onready var subject_name_label: Label = %SubjectName
@onready var classification_label: Label = %Classification
@onready var description_label: Label = %Description

var _profile_data: ProfileData


func setup(profile_data: ProfileData) -> void:
	_profile_data = profile_data
	if is_node_ready():
		_display_profile()


func _ready() -> void:
	super._ready()
	_display_profile()


func _display_profile() -> void:
	if _profile_data == null:
		push_warning("ProfileView.setup(): ProfileData is missing.")
		subject_name_label.text = "Profile data unavailable"
		classification_label.text = ""
		description_label.text = "No ProfileData was provided to this View."
		return

	if _profile_data.profile_id.strip_edges().is_empty():
		push_warning("ProfileView: profile_id is empty.")
	subject_name_label.text = _text_or_placeholder(_profile_data.subject_name, "subject_name")
	classification_label.text = _text_or_placeholder(_profile_data.classification, "classification")
	description_label.text = _text_or_placeholder(_profile_data.basic_description, "basic_description")


func _text_or_placeholder(value: String, field_name: String) -> String:
	if value.strip_edges().is_empty():
		push_warning("ProfileView: %s is empty." % field_name)
		return "[Missing %s]" % field_name
	return value
