extends "res://scripts/views/flow_view.gd"

const EnvironmentConditions = preload("res://scripts/views/environment_conditions_view.gd")

signal containment_confirmation_requested(room_id: String)
signal cctv_review_requested

@onready var description_label: Label = %Description
@onready var room_list: VBoxContainer = %RoomList
@onready var room_scroll: ScrollContainer = %RoomScroll
@onready var confirm_button: Button = %ConfirmButton

var _rooms: Array[ContainmentData] = []
var _selected_room_index: int = -1
var _selection_group: ButtonGroup
var _confirmed_room_id: String = ""
var _next_action_text: String = "Next: CASE"
var _can_advance: bool = true


func setup(rooms: Array[ContainmentData], confirmed_room_id: String = "") -> void:
	_rooms = rooms
	_confirmed_room_id = confirmed_room_id
	_selected_room_index = -1
	if is_node_ready():
		_display_rooms()


func _ready() -> void:
	super._ready()
	%RecheckCCTVButton.pressed.connect(cctv_review_requested.emit)
	confirm_button.pressed.connect(_on_confirm_containment_pressed)
	_display_rooms()


func configure_next_action(text: String, can_advance: bool) -> void:
	_next_action_text = text
	_can_advance = can_advance
	if is_node_ready():
		_update_confirmation_ui()


func _display_rooms() -> void:
	_selected_room_index = -1
	_selection_group = ButtonGroup.new()
	_selection_group.allow_unpress = false
	for item: Node in room_list.get_children():
		room_list.remove_child(item)
		item.queue_free()
	room_scroll.scroll_vertical = 0
	_update_confirmation_ui()
	if _rooms.is_empty():
		push_warning("ContainmentView.setup(): available_containment_rooms is empty.")
		description_label.text = "No containment rooms available"
		return

	description_label.text = "Available containment rooms: %d" % _rooms.size()
	for index in range(_rooms.size()):
		var room: ContainmentData = _rooms[index]
		if room == null:
			push_warning("ContainmentView: ContainmentData at index %d is missing." % index)
			_append_item("[Missing ContainmentData]", "No ContainmentData was provided for item %d." % (index + 1), index, false)
			continue
		if room.room_id.strip_edges().is_empty():
			push_warning("ContainmentView: room_id at index %d is empty." % index)
		_append_item(
			_text_or_placeholder(room.display_name, "display_name", index),
			_text_or_placeholder(room.description, "description", index),
			index,
			not room.room_id.strip_edges().is_empty()
		)
	_update_confirmation_ui()


func _append_item(display_name: String, description: String, index: int, selectable: bool = true) -> void:
	var item := VBoxContainer.new()
	item.name = "Room%d" % index
	item.add_theme_constant_override("separation", 2)
	var select_button := CheckBox.new()
	select_button.name = "Select"
	select_button.text = display_name
	select_button.button_group = _selection_group
	select_button.disabled = not selectable
	select_button.pressed.connect(_on_room_selected.bind(index))
	item.add_child(select_button)
	var item_description := Label.new()
	item_description.text = description
	item_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	item.add_child(item_description)
	room_list.add_child(item)


func _on_room_selected(index: int) -> void:
	if not _allows_local_input(): return
	if not _confirmed_room_id.is_empty():
		return
	if index < 0 or index >= _rooms.size():
		return
	var room: ContainmentData = _rooms[index]
	if room == null or room.room_id.strip_edges().is_empty():
		return
	_selected_room_index = index
	_update_confirmation_ui()


func _get_selected_room() -> ContainmentData:
	if _selected_room_index < 0 or _selected_room_index >= _rooms.size():
		return null
	return _rooms[_selected_room_index]


func _on_confirm_containment_pressed() -> void:
	if not _allows_local_input(): return
	if not _confirmed_room_id.is_empty():
		return
	var room: ContainmentData = _get_selected_room()
	if room == null or room.room_id.strip_edges().is_empty():
		confirm_button.disabled = true
		return
	var id: String = room.room_id
	var data: ContainmentData = room
	open_confirmation("AUTHORIZE CONTAINMENT", room.display_name + "\n\n" + room.description + _confirmation_conditions(), "AUTHORIZE", Vector2(640, 360), func() -> void:
		if _confirmed_room_id.is_empty() and _get_selected_room() == data and data.room_id == id:
			containment_confirmation_requested.emit(id))


func update_confirmation_state(confirmed_room_id: String) -> void:
	if _confirmed_room_id != confirmed_room_id:
		_selected_room_index = -1
	_confirmed_room_id = confirmed_room_id
	if is_node_ready():
		if _confirmed_room_id.is_empty() and _selected_room_index == -1:
			var selected_button: BaseButton = _selection_group.get_pressed_button()
			if selected_button != null:
				_selection_group.allow_unpress = true
				selected_button.set_pressed_no_signal(false)
				_selection_group.allow_unpress = false
		_update_confirmation_ui()


func _update_confirmation_ui() -> void:
	var confirmed: bool = not _confirmed_room_id.is_empty()
	for index in range(room_list.get_child_count()):
		var button: CheckBox = room_list.get_child(index).get_child(0) as CheckBox
		var room: ContainmentData = _rooms[index] if index < _rooms.size() else null
		button.disabled = confirmed or room == null or room.room_id.strip_edges().is_empty()
		if room != null:
			button.text = room.display_name if not room.display_name.strip_edges().is_empty() else "[Missing display_name]"
			if confirmed and room.room_id == _confirmed_room_id:
				button.text += " [Confirmed]"
				button.set_pressed_no_signal(true)
	var selected_room: ContainmentData = _get_selected_room()
	%RoomDetail.text = selected_room.display_name + "\n" + selected_room.description if selected_room != null else "Decision recorded." if confirmed else "SELECT A ROOM"
	confirm_button.disabled = confirmed or selected_room == null or selected_room.room_id.strip_edges().is_empty()
	next_button.text = _next_action_text
	confirm_button.visible = not confirmed
	next_button.visible = confirmed
	next_button.disabled = not confirmed or not _can_advance


func _text_or_placeholder(value: String, field_name: String, index: int) -> String:
	if value.strip_edges().is_empty():
		push_warning("ContainmentView: %s at index %d is empty." % [field_name, index])
		return "[Missing %s]" % field_name
	return value


func set_environment_conditions(summary: EnvironmentConditions.Summary) -> void:
	var conditions: EnvironmentConditions = get_node("%EnvironmentConditions")
	conditions.set_summary(summary)
	%RecheckCCTVButton.visible = summary != null and not summary.entries.is_empty()


func capture_work_state() -> Dictionary:
	var state: Dictionary = super.capture_work_state()
	var selected: ContainmentData = _get_selected_room()
	state.merge({"selected_room_id": selected.room_id if selected != null and _confirmed_room_id.is_empty() else "", "confirmed_room_id": _confirmed_room_id, "room_scroll": room_scroll.scroll_vertical})
	return state


func restore_work_state(state: Dictionary) -> bool:
	if state.confirmed_room_id != _confirmed_room_id or not _confirmed_room_id.is_empty() and not state.selected_room_id.is_empty(): return false
	_selected_room_index = -1
	for index: int in range(_rooms.size()):
		if _rooms[index] != null and _rooms[index].room_id == state.selected_room_id:
			_selected_room_index = index
			(room_list.get_child(index).get_child(0) as CheckBox).set_pressed_no_signal(true)
	_update_confirmation_ui()
	room_scroll.scroll_vertical = state.room_scroll
	return restore_work_focus(state)

func _confirmation_conditions() -> String:
	var text: String = ""
	for entry: EnvironmentConditions.Condition in %EnvironmentConditions.get("_entries"):
		text += "\n\n" + entry.display_name + "\n" + entry.condition_change_text
	return text
