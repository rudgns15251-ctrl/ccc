extends "res://scripts/views/flow_view.gd"

signal broadcast_confirmation_requested(broadcast_id: String, option_id: String)

@onready var broadcast_id_label: Label = %BroadcastId
@onready var display_name_label: Label = %DisplayName
@onready var prompt_label: Label = %Description
@onready var option_list: VBoxContainer = %OptionList
@onready var option_scroll: ScrollContainer = %OptionScroll
@onready var confirm_button: Button = %ConfirmButton

var _broadcast_data: EmergencyBroadcastData
var _selected_option_index: int = -1
var _selection_group: ButtonGroup
var _confirmed_broadcast_id: String = ""
var _confirmed_option_id: String = ""


func setup(broadcast_data: EmergencyBroadcastData, confirmed_broadcast_id: String = "", confirmed_option_id: String = "") -> void:
	_broadcast_data = broadcast_data
	_confirmed_broadcast_id = confirmed_broadcast_id
	_confirmed_option_id = confirmed_option_id
	_selected_option_index = -1
	if is_node_ready():
		_display_broadcast()


func _ready() -> void:
	super._ready()
	confirm_button.pressed.connect(_on_confirm_broadcast_pressed)
	_display_broadcast()


func _display_broadcast() -> void:
	_selected_option_index = -1
	_selection_group = ButtonGroup.new()
	_selection_group.allow_unpress = false
	next_button.disabled = true
	confirm_button.disabled = true
	for item: Node in option_list.get_children():
		option_list.remove_child(item)
		item.queue_free()
	option_scroll.scroll_vertical = 0
	if _broadcast_data == null:
		push_warning("BroadcastView.setup(): EmergencyBroadcastData is missing.")
		broadcast_id_label.text = ""
		display_name_label.text = "Broadcast data unavailable"
		prompt_label.text = "No EmergencyBroadcastData was provided to this View."
		return
	if _broadcast_data.broadcast_id.strip_edges().is_empty():
		push_warning("BroadcastView: broadcast_id is empty.")
		broadcast_id_label.text = "ID: [Missing broadcast_id]"
		display_name_label.text = "Broadcast data unavailable"
		prompt_label.text = "EmergencyBroadcastData has no valid broadcast_id."
		return

	broadcast_id_label.text = "ID: " + _broadcast_data.broadcast_id
	display_name_label.text = _text_or_placeholder(_broadcast_data.display_name, "display_name")
	prompt_label.text = _text_or_placeholder(_broadcast_data.prompt_text, "prompt_text")
	if _broadcast_data.options.is_empty():
		push_warning("BroadcastView: options is empty.")
		prompt_label.text = "Broadcast data unavailable"
		return
	for index in range(_broadcast_data.options.size()):
		var option: BroadcastOptionData = _broadcast_data.options[index]
		if option == null:
			push_warning("BroadcastView: BroadcastOptionData at index %d is missing." % index)
			continue
		var option_id: String = option.option_id
		if option_id.strip_edges().is_empty():
			push_warning("BroadcastView: option_id at index %d is empty." % index)
			option_id = "[Missing option_id]"
		_append_option(option_id, _text_or_placeholder(option.display_text, "display_text at index %d" % index), index, not option.option_id.strip_edges().is_empty())
	if not _has_valid_options():
		push_warning("BroadcastView: no valid BroadcastOptionData is available.")
		prompt_label.text = "Broadcast data unavailable"
		return
	_update_confirmation_ui()


func _has_valid_options() -> bool:
	if _broadcast_data == null or _broadcast_data.broadcast_id.strip_edges().is_empty():
		return false
	for option: BroadcastOptionData in _broadcast_data.options:
		if option != null and not option.option_id.strip_edges().is_empty():
			return true
	return false


func _on_next_button_pressed() -> void:
	if not next_button.disabled and _has_matching_confirmation():
		super._on_next_button_pressed()


func _append_option(option_id: String, display_text: String, index: int, selectable: bool) -> void:
	var item := HBoxContainer.new()
	item.set_meta("option_index", index)
	var select_button := CheckBox.new()
	select_button.button_group = _selection_group
	select_button.disabled = not selectable
	select_button.pressed.connect(_on_option_selected.bind(index, select_button))
	item.add_child(select_button)
	var text_label := Label.new()
	text_label.text = "%s: %s" % [option_id, display_text]
	text_label.add_theme_font_size_override("font_size", 18)
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item.add_child(text_label)
	option_list.add_child(item)


func _on_option_selected(index: int, button: CheckBox) -> void:
	if not _allows_local_input(): return
	if not is_inside_tree() or is_queued_for_deletion():
		return
	if _has_confirmation_snapshot():
		return
	if button.button_group != _selection_group or button.disabled or not button.is_inside_tree() or button.is_queued_for_deletion():
		return
	if _broadcast_data == null or _broadcast_data.broadcast_id.strip_edges().is_empty() or index < 0 or index >= _broadcast_data.options.size():
		return
	var option: BroadcastOptionData = _broadcast_data.options[index]
	if option == null or option.option_id.strip_edges().is_empty():
		return
	_selected_option_index = index
	_update_confirmation_ui()


func _get_option(index: int) -> BroadcastOptionData:
	if _broadcast_data == null or index < 0 or index >= _broadcast_data.options.size():
		return null
	return _broadcast_data.options[index]


func _has_confirmation_snapshot() -> bool:
	return not _confirmed_broadcast_id.is_empty() or not _confirmed_option_id.is_empty()


func _has_matching_confirmation() -> bool:
	if _broadcast_data == null or _broadcast_data.broadcast_id.strip_edges().is_empty() or _confirmed_broadcast_id != _broadcast_data.broadcast_id or _confirmed_option_id.strip_edges().is_empty():
		return false
	for option: BroadcastOptionData in _broadcast_data.options:
		if option != null and not option.option_id.strip_edges().is_empty() and option.option_id == _confirmed_option_id:
			return true
	return false


func _on_confirm_broadcast_pressed() -> void:
	if not _allows_local_input(): return
	if confirm_button.disabled or _has_confirmation_snapshot():
		return
	var option: BroadcastOptionData = _get_option(_selected_option_index)
	if _broadcast_data == null or _broadcast_data.broadcast_id.strip_edges().is_empty() or option == null or option.option_id.strip_edges().is_empty():
		return
	broadcast_confirmation_requested.emit(_broadcast_data.broadcast_id, option.option_id)


func update_confirmation_state(confirmed_broadcast_id: String, confirmed_option_id: String) -> void:
	if _confirmed_broadcast_id != confirmed_broadcast_id or _confirmed_option_id != confirmed_option_id:
		_selected_option_index = -1
	_confirmed_broadcast_id = confirmed_broadcast_id
	_confirmed_option_id = confirmed_option_id
	if is_node_ready():
		_update_confirmation_ui()


func _update_confirmation_ui() -> void:
	var has_snapshot: bool = _has_confirmation_snapshot()
	var confirmed: bool = _has_matching_confirmation()
	if has_snapshot and not confirmed:
		push_warning("BroadcastView: confirmation snapshot does not match the current Broadcast/Option.")
	var selected_option: BroadcastOptionData = _get_option(_selected_option_index)
	if selected_option == null or selected_option.option_id.strip_edges().is_empty():
		_selected_option_index = -1
	var confirmed_shown: bool = false
	for item: Node in option_list.get_children():
		var index: int = item.get_meta("option_index")
		var option: BroadcastOptionData = _get_option(index)
		var button: CheckBox = item.get_child(0) as CheckBox
		var text_label: Label = item.get_child(1) as Label
		var valid: bool = option != null and not option.option_id.strip_edges().is_empty()
		var is_confirmed: bool = confirmed and valid and option.option_id == _confirmed_option_id and not confirmed_shown
		if is_confirmed:
			confirmed_shown = true
		button.disabled = has_snapshot or not valid
		button.set_pressed_no_signal(is_confirmed if has_snapshot else valid and index == _selected_option_index)
		text_label.text = text_label.text.trim_suffix(" [Confirmed]")
		if is_confirmed:
			text_label.text += " [Confirmed]"
	confirm_button.disabled = has_snapshot or _broadcast_data == null or _broadcast_data.broadcast_id.strip_edges().is_empty() or _selected_option_index == -1
	next_button.disabled = not confirmed
	if confirmed:
		next_button.grab_focus()


func get_unconfirmed_option_id() -> String:
	if not is_inside_tree() or is_queued_for_deletion() or _has_confirmation_snapshot():
		return ""
	var option: BroadcastOptionData = _get_option(_selected_option_index)
	return option.option_id if option != null else ""


func restore_unconfirmed_option(option_id: String) -> bool:
	if not is_inside_tree() or is_queued_for_deletion() or _has_confirmation_snapshot() or _broadcast_data == null or option_id.strip_edges().is_empty():
		return false
	var matching_index: int = -1
	for index: int in range(_broadcast_data.options.size()):
		var option: BroadcastOptionData = _broadcast_data.options[index]
		if option != null and option.option_id == option_id:
			if matching_index >= 0 or option.display_text.strip_edges().is_empty():
				return false
			matching_index = index
	if matching_index < 0:
		return false
	_selected_option_index = matching_index
	_update_confirmation_ui()
	return true


func _text_or_placeholder(value: String, field_name: String) -> String:
	if value.strip_edges().is_empty():
		push_warning("BroadcastView: %s is empty." % field_name)
		return "[Missing %s]" % field_name
	return value
