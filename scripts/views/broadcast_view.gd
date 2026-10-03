extends "res://scripts/views/flow_view.gd"

@onready var broadcast_id_label: Label = %BroadcastId
@onready var display_name_label: Label = %DisplayName
@onready var prompt_label: Label = %Description
@onready var option_list: VBoxContainer = %OptionList
@onready var option_scroll: ScrollContainer = %OptionScroll

var _broadcast_data: EmergencyBroadcastData


func setup(broadcast_data: EmergencyBroadcastData) -> void:
	_broadcast_data = broadcast_data
	if is_node_ready():
		_display_broadcast()


func _ready() -> void:
	super._ready()
	_display_broadcast()


func _display_broadcast() -> void:
	next_button.disabled = true
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
		_append_option(option_id, _text_or_placeholder(option.display_text, "display_text at index %d" % index))
	if not _has_valid_options():
		push_warning("BroadcastView: no valid BroadcastOptionData is available.")
		prompt_label.text = "Broadcast data unavailable"
		return
	next_button.disabled = false
	next_button.grab_focus()


func _has_valid_options() -> bool:
	if _broadcast_data == null or _broadcast_data.broadcast_id.strip_edges().is_empty():
		return false
	for option: BroadcastOptionData in _broadcast_data.options:
		if option != null and not option.option_id.strip_edges().is_empty():
			return true
	return false


func _on_next_button_pressed() -> void:
	if not next_button.disabled and _has_valid_options():
		super._on_next_button_pressed()


func _append_option(option_id: String, display_text: String) -> void:
	var item := Label.new()
	item.text = "%s: %s" % [option_id, display_text]
	item.add_theme_font_size_override("font_size", 18)
	item.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	option_list.add_child(item)


func _text_or_placeholder(value: String, field_name: String) -> String:
	if value.strip_edges().is_empty():
		push_warning("BroadcastView: %s is empty." % field_name)
		return "[Missing %s]" % field_name
	return value
