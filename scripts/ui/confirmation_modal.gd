extends Control

signal confirmed
signal cancelled
var _resolved: bool = false
var _title: String
var _message: String
var _action: String
var _dimensions: Vector2

func setup(title: String, message: String, action: String, dimensions: Vector2) -> void:
	_title = title
	_message = message
	_action = action
	_dimensions = dimensions

func _ready() -> void:
	%Title.text = _title
	%Message.text = _message
	%Confirm.text = _action
	%Panel.custom_minimum_size = _dimensions
	%Confirm.pressed.connect(_confirm)
	%Cancel.pressed.connect(_cancel)
	%Cancel.grab_focus()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_action_pressed("ui_cancel") and not event.is_echo():
		get_viewport().set_input_as_handled()
		_cancel()

func _confirm() -> void:
	if _resolved or not is_inside_tree() or is_queued_for_deletion(): return
	_resolved = true
	confirmed.emit()

func _cancel() -> void:
	if _resolved or not is_inside_tree() or is_queued_for_deletion(): return
	_resolved = true
	cancelled.emit()
