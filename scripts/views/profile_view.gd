extends "res://scripts/views/flow_view.gd"

@onready var subject_name_label: Label = %SubjectName
@onready var classification_label: Label = %Classification
@onready var description_label: Label = %Description
@onready var document_subject_label: Label = %DocumentSubject
@onready var document_classification_label: Label = %DocumentClassification

var _profile_data: ProfileData


func setup(profile_data: ProfileData) -> void:
	_profile_data = profile_data
	if is_node_ready():
		_display_profile()


func _ready() -> void:
	super._ready()
	_display_profile()


func _display_profile() -> void:
	%SubjectTexture.texture = _profile_data.subject_texture if _profile_data != null else null
	%SubjectTexture.visible = %SubjectTexture.texture != null
	%Placeholder.visible = not %SubjectTexture.visible
	_display_optional_section(%PastObservationsSection, %PastObservations, _profile_data.past_observations if _profile_data != null else "")
	_display_optional_section(%ResearcherNotesSection, %ResearcherNotes, _profile_data.researcher_notes if _profile_data != null else "")
	if _profile_data == null:
		push_warning("ProfileView.setup(): ProfileData is missing.")
		subject_name_label.text = "Profile data unavailable"
		classification_label.text = ""
		description_label.text = "No ProfileData was provided to this View."
		_display_document_header()
		return

	if _profile_data.profile_id.strip_edges().is_empty():
		push_warning("ProfileView: profile_id is empty.")
	subject_name_label.text = _text_or_placeholder(_profile_data.subject_name, "subject_name")
	classification_label.text = _text_or_placeholder(_profile_data.classification, "classification")
	description_label.text = _text_or_placeholder(_profile_data.basic_description, "basic_description")
	_display_document_header()


# Presentation only: repeat the existing Profile fields without new metadata.
func _display_document_header() -> void:
	document_subject_label.text = subject_name_label.text
	document_classification_label.text = classification_label.text


func _text_or_placeholder(value: String, field_name: String) -> String:
	if value.strip_edges().is_empty():
		push_warning("ProfileView: %s is empty." % field_name)
		return "[Missing %s]" % field_name
	return value


func _display_optional_section(section: Control, body: Label, text: String) -> void:
	section.visible = not text.strip_edges().is_empty()
	body.text = text


func capture_work_state() -> Dictionary:
	var state: Dictionary = super.capture_work_state()
	state.merge({"document_scroll": %DocumentScroll.scroll_vertical, "identity_scroll": %IdentityScroll.scroll_vertical})
	return state


func restore_work_state(state: Dictionary) -> bool:
	%DocumentScroll.scroll_vertical = state.document_scroll
	%IdentityScroll.scroll_vertical = state.identity_scroll
	return restore_work_focus(state)
