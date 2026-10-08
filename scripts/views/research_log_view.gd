extends "res://scripts/views/flow_view.gd"

signal hypothesis_add_requested(case_id: String, text: String)
signal hypothesis_update_requested(case_id: String, hypothesis_id: String, text: String)
signal hypothesis_remove_requested(case_id: String, hypothesis_id: String)
signal archive_requested

class Entry extends RefCounted:
	var category: String
	var source_id: String
	var title: String
	var body_text: String
	var source_kind: int = -1

	func _init(entry_category: String, entry_source_id: String, entry_title: String, entry_body_text: String, entry_source_kind: int = -1) -> void:
		category = entry_category
		source_id = entry_source_id
		title = entry_title
		body_text = entry_body_text
		source_kind = entry_source_kind


class Snapshot extends RefCounted:
	var case_id: String = ""
	var case_display_name: String = ""
	var monitoring_result: MonitoringOutcomeData.Result = MonitoringOutcomeData.Result.UNDEFINED
	var entries: Array[Entry] = []
	var hypotheses: Array[Dictionary] = []
	var hypothesis_max_length: int = 0


@onready var case_label: Label = %Description
@onready var result_label: Label = %MonitoringResult
@onready var entry_scroll: ScrollContainer = %EntryScroll
@onready var entry_list: VBoxContainer = %EntryList

var _drawer_mode: String = "LEGACY"
var _selected_entry: int = -1
var _snapshot: Snapshot
var _hypothesis_case_id: String = ""
var _hypothesis_records: Array[Dictionary] = []
var _hypothesis_max_length: int = 0
var _editing_hypothesis_id: String = ""


func setup(snapshot: Snapshot) -> void:
	_snapshot = snapshot
	if is_node_ready():
		_display_snapshot()


func _ready() -> void:
	super._ready()
	%OpenArchiveButton.pressed.connect(func() -> void: archive_requested.emit())
	%HypothesisInput.text_changed.connect(_update_hypothesis_input)
	%SaveHypothesisButton.pressed.connect(_on_save_hypothesis_pressed)
	%CancelHypothesisButton.pressed.connect(_cancel_hypothesis_edit)
	%CategoryFilter.item_selected.connect(_on_category_selected)
	_display_snapshot()


func _display_snapshot() -> void:
	_hypothesis_case_id = _snapshot.case_id if _snapshot != null else ""
	_hypothesis_max_length = _snapshot.hypothesis_max_length if _snapshot != null else 0
	_hypothesis_records.clear()
	if _snapshot != null:
		_hypothesis_records = _snapshot.hypotheses.duplicate(true)
	_cancel_hypothesis_edit()
	_display_hypotheses()
	entry_scroll.scroll_vertical = 0
	for item: Node in entry_list.get_children():
		entry_list.remove_child(item)
		item.queue_free()
	case_label.text = "Case: [Unavailable]"
	result_label.text = "Monitoring Result: UNDEFINED"
	result_label.visible = false
	if _snapshot == null:
		push_warning("ResearchLogView.setup(): snapshot is missing.")
		return
	case_label.text = _snapshot.case_display_name
	if _snapshot.monitoring_result == MonitoringOutcomeData.Result.SUCCESS:
		result_label.visible = true
		result_label.text = "Monitoring Result: SUCCESS"
	elif _snapshot.monitoring_result == MonitoringOutcomeData.Result.FAILURE:
		result_label.visible = true
		result_label.text = "Monitoring Result: FAILURE"
	%CategoryFilter.clear()
	%CategoryFilter.add_item("ALL RECORDED CATEGORIES")
	var categories: Array[String] = []
	for entry: Entry in _snapshot.entries:
		if entry != null and not categories.has(entry.category): categories.append(entry.category)
	for category: String in categories: %CategoryFilter.add_item(category)
	_render_entries()
	configure_drawer_mode(_drawer_mode)

func configure_drawer_mode(mode: String) -> void:
	_drawer_mode = mode
	if not is_node_ready(): return
	get_node("Margin/Content/ResearchRegion").visible = mode in ["RESEARCH", "LEGACY"]
	get_node("Margin/Content/Notebook").visible = mode in ["HYPOTHESIS", "LEGACY"]
	%ScreenTitle.text = "RESEARCH LOG" if mode == "RESEARCH" else "WORKING HYPOTHESIS"
	_refresh_drawer_focus.call_deferred()

func _on_category_selected(_index: int) -> void:
	_render_entries()

func _render_entries() -> void:
	for item: Node in entry_list.get_children():
		entry_list.remove_child(item)
		item.queue_free()
	if _snapshot == null: return
	var category: String = %CategoryFilter.get_item_text(%CategoryFilter.selected) if %CategoryFilter.selected > 0 else ""
	for index: int in range(_snapshot.entries.size()):
		var entry: Entry = _snapshot.entries[index]
		if entry == null or not category.is_empty() and entry.category != category: continue
		var button := Button.new()
		button.text = entry.category + " / " + entry.title
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.custom_minimum_size.y = 48
		button.pressed.connect(_select_entry.bind(index))
		entry_list.add_child(button)
	_refresh_drawer_focus.call_deferred()

func _select_entry(index: int) -> void:
	if not _allows_local_input() or _snapshot == null or index < 0 or index >= _snapshot.entries.size(): return
	_selected_entry = index
	var entry: Entry = _snapshot.entries[index]
	%EntryTitle.text = entry.title
	%EntryBody.text = entry.body_text
	%EntryDetailScroll.scroll_vertical = 0

func capture_drawer_state() -> Dictionary:
	return {"draft": %HypothesisInput.text, "editing": _editing_hypothesis_id, "selected_entry": _selected_entry, "category": %CategoryFilter.selected, "list_scroll": %EntryScroll.scroll_vertical, "detail_scroll": %EntryDetailScroll.scroll_vertical, "note_scroll": %HypothesisScroll.scroll_vertical}

func restore_drawer_state(state: Dictionary) -> void:
	if state.is_empty(): return
	_editing_hypothesis_id = state.get("editing", "")
	%HypothesisInput.text = state.get("draft", "")
	_update_hypothesis_input()
	var category: int = state.get("category", 0)
	if category >= 0 and category < %CategoryFilter.item_count: %CategoryFilter.select(category)
	_render_entries()
	_select_entry(state.get("selected_entry", -1))
	%EntryScroll.scroll_vertical = state.get("list_scroll", 0)
	%EntryDetailScroll.scroll_vertical = state.get("detail_scroll", 0)
	%HypothesisScroll.scroll_vertical = state.get("note_scroll", 0)


func _append_label(item: VBoxContainer, text: String, _font_size: int) -> void:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item.add_child(label)


func get_hypothesis_case_id() -> String:
	return _hypothesis_case_id


func _display_hypotheses() -> void:
	for item: Node in %HypothesisList.get_children():
		%HypothesisList.remove_child(item)
		item.queue_free()
	%HypothesisEmpty.visible = _hypothesis_records.is_empty()
	for record: Dictionary in _hypothesis_records:
		var item := VBoxContainer.new()
		item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_append_label(item, "WORKING NOTE", 18)
		_append_label(item, record.text, 18)
		var actions := HBoxContainer.new()
		for action: String in ["Edit", "Delete"]:
			var button := Button.new()
			button.text = action
			button.custom_minimum_size = Vector2(100, 48)
			button.disabled = _hypothesis_case_id.strip_edges().is_empty() or _hypothesis_max_length <= 0
			if action == "Edit":
				button.pressed.connect(_on_hypothesis_edit_pressed.bind(record.hypothesis_id))
			else:
				button.pressed.connect(_on_hypothesis_delete_pressed.bind(record.hypothesis_id))
			actions.add_child(button)
		item.add_child(actions)
		%HypothesisList.add_child(item)
	_refresh_drawer_focus.call_deferred()


func _update_hypothesis_input() -> void:
	var text: String = %HypothesisInput.text.strip_edges()
	%HypothesisInput.editable = not _hypothesis_case_id.strip_edges().is_empty() and _hypothesis_max_length > 0
	%SaveHypothesisButton.disabled = not %HypothesisInput.editable or text.is_empty() or text.length() > _hypothesis_max_length
	%SaveHypothesisButton.text = "Add Hypothesis" if _editing_hypothesis_id.is_empty() else "Update Hypothesis"
	%CancelHypothesisButton.visible = not _editing_hypothesis_id.is_empty()
	%HypothesisStatus.text = "%d / %d characters (trimmed)." % [text.length(), _hypothesis_max_length]
	if text.length() > _hypothesis_max_length:
		%HypothesisStatus.text += " Too long; note will not be saved."
	_refresh_drawer_focus.call_deferred()


func _on_save_hypothesis_pressed() -> void:
	_update_hypothesis_input()
	if %SaveHypothesisButton.disabled:
		return
	if _editing_hypothesis_id.is_empty():
		hypothesis_add_requested.emit(_hypothesis_case_id, %HypothesisInput.text)
	else:
		hypothesis_update_requested.emit(_hypothesis_case_id, _editing_hypothesis_id, %HypothesisInput.text)


func _on_hypothesis_edit_pressed(id: String) -> void:
	for record: Dictionary in _hypothesis_records:
		if record.hypothesis_id == id:
			_editing_hypothesis_id = id
			%HypothesisInput.text = record.text
			_update_hypothesis_input()
			%HypothesisInput.grab_focus()
			return


func _on_hypothesis_delete_pressed(id: String) -> void:
	hypothesis_remove_requested.emit(_hypothesis_case_id, id)


func _cancel_hypothesis_edit() -> void:
	_editing_hypothesis_id = ""
	%HypothesisInput.text = ""
	_update_hypothesis_input()


func show_hypothesis_request_result(approved: bool, records: Array[Dictionary], removed_id: String = "") -> void:
	if not approved:
		%HypothesisStatus.text = "Note was not saved. Check input or reopen the notebook."
		return
	_hypothesis_records = records.duplicate(true)
	if removed_id.is_empty() or removed_id == _editing_hypothesis_id:
		_cancel_hypothesis_edit()
	_display_hypotheses()

func _input(event: InputEvent) -> void:
	if _drawer_mode in ["RESEARCH", "HYPOTHESIS"] and event.is_action_pressed("ui_cancel") and _allows_local_input():
		get_viewport().set_input_as_handled()
		advance_requested.emit()
	elif _drawer_mode == "HYPOTHESIS" and event is InputEventKey and (event.is_action_pressed("ui_focus_next") or event.is_action_pressed("ui_focus_prev")):
		if get_viewport().gui_get_focus_owner() != %HypothesisInput or not _allows_local_input(): return
		var path: NodePath = %HypothesisInput.focus_previous if event.is_action_pressed("ui_focus_prev") else %HypothesisInput.focus_next
		var target: Control = %HypothesisInput.get_node_or_null(path) as Control
		if target != null:
			get_viewport().set_input_as_handled()
			target.grab_focus()


# Local presentation loop: hidden/disabled/generated controls are re-evaluated.
func _refresh_drawer_focus() -> void:
	if _drawer_mode == "LEGACY" or not is_inside_tree() or is_queued_for_deletion(): return
	var controls: Array[Control] = []
	for node: Node in find_children("*", "Control", true, false):
		var control: Control = node as Control
		if control.focus_mode == Control.FOCUS_NONE or not control.is_visible_in_tree(): continue
		if control is BaseButton and control.disabled: continue
		controls.append(control)
	for index: int in range(controls.size()):
		controls[index].focus_next = controls[index].get_path_to(controls[(index + 1) % controls.size()])
		controls[index].focus_previous = controls[index].get_path_to(controls[(index - 1 + controls.size()) % controls.size()])
	var focused: Control = get_viewport().gui_get_focus_owner()
	if not controls.is_empty() and (focused == null or not controls.has(focused)):
		controls[0].grab_focus()
