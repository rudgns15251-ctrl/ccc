extends Control

signal advance_requested
signal research_log_requested

@onready var next_button: Button = %NextButton
@onready var research_log_button: Button = get_node_or_null("%OpenResearchLogButton") as Button

var _response_context: Dictionary = {}
var _input_guard: Callable


func set_input_guard(guard: Callable) -> void:
	_input_guard = guard


func _allows_local_input() -> bool:
	return _input_guard.is_null() or (_input_guard.is_valid() and _input_guard.call())


func _ready() -> void:
	next_button.pressed.connect(_on_next_button_pressed)
	if research_log_button != null:
		research_log_button.pressed.connect(_on_research_log_button_pressed)
	next_button.grab_focus()
	_display_response_context()


func _on_next_button_pressed() -> void:
	if not _allows_local_input(): return
	advance_requested.emit()


func _on_research_log_button_pressed() -> void:
	if not _allows_local_input(): return
	if research_log_button != null and not research_log_button.disabled:
		research_log_requested.emit()


func set_response_context(context: Dictionary) -> void:
	_response_context = context.duplicate()
	if is_node_ready():
		_display_response_context()


func _display_response_context() -> void:
	var label: Label = get_node_or_null("%ResponseContext") as Label
	if label == null:
		return
	label.visible = false
	label.text = ""
	for key: String in ["source_case_id", "source_case_display_name", "interrupted_case_id", "interrupted_case_display_name", "return_stage"]:
		if not _response_context.get(key, "") is String or _response_context.get(key, "").strip_edges().is_empty():
			return
	var heading: String = "RESUME WORK" if _response_context.get("resume", false) else "CURRENT WORK INTERRUPTED"
	label.text = "SOURCE CASE\n%s (%s)\n%s\n%s (%s) - %s" % [_response_context.source_case_display_name, _response_context.source_case_id, heading, _response_context.interrupted_case_display_name, _response_context.interrupted_case_id, _response_context.return_stage]
	label.visible = true
