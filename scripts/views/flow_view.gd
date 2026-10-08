extends Control

signal advance_requested
signal research_log_requested
signal confirmation_changed

const CONFIRMATION_SCENE = preload("res://scenes/ui/confirmation_modal.tscn")
var _confirmation: Control
var _confirmation_focus: Control

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
	if _response_context.get("origin_kind", -1) == IncidentSource.OriginKind.CAMPAIGN_INTERRUPT:
		if _response_context.get("source_occurrence_id", "").is_empty() or _response_context.get("event_id", "").is_empty(): return
		label.text = "CAMPAIGN EVENT\nRESUME WORK\n%s - %s" % [_response_context.get("interrupted_case_display_name", ""), _response_context.get("return_stage", "")]
		label.visible = true
		return
	if _response_context.get("origin_kind", -1) == IncidentSource.OriginKind.CAMPAIGN_ENTRY:
		if _response_context.get("source_entry_id", "").is_empty() or _response_context.get("event_id", "").is_empty(): return
		label.text = "FACILITY EVENT / CAMPAIGN EVENT\nCONTINUE CAMPAIGN after response acknowledgement"
		label.visible = true
		return
	for key: String in ["source_case_id", "source_case_display_name", "interrupted_case_id", "interrupted_case_display_name", "return_stage"]:
		if not _response_context.get(key, "") is String or _response_context.get(key, "").strip_edges().is_empty():
			return
	var heading: String = "RESUME WORK" if _response_context.get("resume", false) else "CURRENT WORK INTERRUPTED"
	label.text = "SOURCE CASE\n%s\n%s\n%s - %s" % [_response_context.source_case_display_name, heading, _response_context.interrupted_case_display_name, _response_context.return_stage]
	label.visible = true


func capture_work_state() -> Dictionary:
	var focused: Control = get_viewport().gui_get_focus_owner()
	return {"focus_path": String(get_path_to(focused)) if focused != null and is_ancestor_of(focused) else ""}


func restore_work_state(state: Dictionary) -> bool:
	return restore_work_focus(state)


func restore_work_focus(state: Dictionary) -> bool:
	var path: String = state.get("focus_path", "")
	if path.is_empty():
		var focused: Control = get_viewport().gui_get_focus_owner()
		if focused != null and is_ancestor_of(focused): focused.release_focus()
		return true
	var control: Control = get_node_or_null(NodePath(path)) as Control
	if control == null or not is_ancestor_of(control) or not control.is_visible_in_tree() or control.focus_mode == Control.FOCUS_NONE: return false
	control.grab_focus()
	return get_viewport().gui_get_focus_owner() == control

func has_open_confirmation() -> bool:
	return is_instance_valid(_confirmation)

func open_confirmation(title: String, message: String, action: String, dimensions: Vector2, apply: Callable) -> void:
	if has_open_confirmation() or not _allows_local_input() or not is_inside_tree() or is_queued_for_deletion(): return
	_confirmation_focus = get_viewport().gui_get_focus_owner()
	_confirmation = CONFIRMATION_SCENE.instantiate()
	_confirmation.setup(title, message, action, dimensions)
	var modal: Control = _confirmation
	modal.cancelled.connect(close_confirmation)
	modal.confirmed.connect(func() -> void:
		if not is_instance_valid(modal) or modal != _confirmation or not is_inside_tree() or is_queued_for_deletion(): return
		close_confirmation()
		if _allows_local_input() and apply.is_valid(): apply.call())
	var layer: Node = get_tree().current_scene.get_node_or_null("%ModalLayer") if get_tree().current_scene != null else null
	(layer if layer != null else self).add_child(modal)
	confirmation_changed.emit()

func close_confirmation() -> void:
	if is_instance_valid(_confirmation):
		_confirmation.get_parent().remove_child(_confirmation)
		_confirmation.queue_free()
	_confirmation = null
	if is_instance_valid(_confirmation_focus) and _confirmation_focus.is_inside_tree() and _confirmation_focus.is_visible_in_tree(): _confirmation_focus.grab_focus()
	_confirmation_focus = null
	confirmation_changed.emit()

func _exit_tree() -> void:
	if is_instance_valid(_confirmation): _confirmation.queue_free()
	_confirmation = null
