extends Control

signal dismissed

var _title: String = ""
var _notice: String = ""
var _condition: String = ""
var _observation: String = ""


func setup(disturbance: EnvironmentalDisturbanceData, reaction: CaseDisturbanceReactionData) -> void:
	_title = disturbance.display_name
	_notice = disturbance.notice_text
	_condition = disturbance.condition_change_text
	_observation = reaction.observation_text if reaction != null else ""


func _ready() -> void:
	%DisturbanceTitle.text = _title
	%NoticeText.text = _notice
	%ConditionChange.text = _condition
	%ObservationTitle.visible = not _observation.is_empty()
	%ObservationText.visible = not _observation.is_empty()
	%ObservationText.text = _observation
	%DismissButton.pressed.connect(_on_dismiss_pressed)
	%DismissButton.grab_focus()


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		get_viewport().set_input_as_handled()
		if event.is_action_pressed("ui_accept") and not event.is_echo():
			_on_dismiss_pressed()


func _on_dismiss_pressed() -> void:
	dismissed.emit()
