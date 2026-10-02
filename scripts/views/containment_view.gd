extends "res://scripts/views/flow_view.gd"

@onready var description_label: Label = %Description
@onready var room_list: VBoxContainer = %RoomList
@onready var room_scroll: ScrollContainer = %RoomScroll

var _rooms: Array[ContainmentData] = []


func setup(rooms: Array[ContainmentData]) -> void:
	_rooms = rooms
	if is_node_ready():
		_display_rooms()


func _ready() -> void:
	super._ready()
	_display_rooms()


func _display_rooms() -> void:
	for item: Node in room_list.get_children():
		room_list.remove_child(item)
		item.queue_free()
	room_scroll.scroll_vertical = 0
	if _rooms.is_empty():
		push_warning("ContainmentView.setup(): available_containment_rooms is empty.")
		description_label.text = "No containment rooms available"
		return

	description_label.text = "Available containment rooms: %d" % _rooms.size()
	for index in range(_rooms.size()):
		var room: ContainmentData = _rooms[index]
		if room == null:
			push_warning("ContainmentView: ContainmentData at index %d is missing." % index)
			_append_item("[Missing ContainmentData]", "No ContainmentData was provided for item %d." % (index + 1))
			continue
		if room.room_id.strip_edges().is_empty():
			push_warning("ContainmentView: room_id at index %d is empty." % index)
		_append_item(
			_text_or_placeholder(room.display_name, "display_name", index),
			_text_or_placeholder(room.description, "description", index)
		)


func _append_item(display_name: String, description: String) -> void:
	var item := VBoxContainer.new()
	item.add_theme_constant_override("separation", 2)
	var name_label := Label.new()
	name_label.text = display_name
	name_label.add_theme_font_size_override("font_size", 20)
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	item.add_child(name_label)
	var item_description := Label.new()
	item_description.text = description
	item_description.add_theme_font_size_override("font_size", 18)
	item_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	item.add_child(item_description)
	room_list.add_child(item)


func _text_or_placeholder(value: String, field_name: String, index: int) -> String:
	if value.strip_edges().is_empty():
		push_warning("ContainmentView: %s at index %d is empty." % [field_name, index])
		return "[Missing %s]" % field_name
	return value
