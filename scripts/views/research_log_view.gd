extends "res://scripts/views/flow_view.gd"

signal hypothesis_add_requested(case_id: String, text: String)
signal hypothesis_update_requested(case_id: String, hypothesis_id: String, text: String)
signal hypothesis_remove_requested(case_id: String, hypothesis_id: String)

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
	%HypothesisInput.text_changed.connect(_update_hypothesis_input)
	%SaveHypothesisButton.pressed.connect(_on_save_hypothesis_pressed)
	%CancelHypothesisButton.pressed.connect(_cancel_hypothesis_edit)
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
	case_label.text = "Case: %s (%s)" % [_snapshot.case_display_name, _snapshot.case_id]
	if _snapshot.monitoring_result == MonitoringOutcomeData.Result.SUCCESS:
		result_label.visible = true
		result_label.text = "Monitoring Result: SUCCESS"
	elif _snapshot.monitoring_result == MonitoringOutcomeData.Result.FAILURE:
		result_label.visible = true
		result_label.text = "Monitoring Result: FAILURE"
	for entry: Entry in _snapshot.entries:
		if entry == null:
			push_warning("ResearchLogView: entry is missing.")
			continue
		var item := VBoxContainer.new()
		item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		item.add_theme_constant_override("separation", 2)
		_append_label(item, "[%s]" % entry.category, 18)
		_append_label(item, entry.title, 20)
		_append_label(item, "Source ID: " + (entry.source_id if not entry.source_id.is_empty() else "[Unavailable]"), 16)
		_append_label(item, entry.body_text, 18)
		entry_list.add_child(item)


func _append_label(item: VBoxContainer, text: String, font_size: int) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
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
		_append_label(item, record.hypothesis_id, 18)
		_append_label(item, record.text, 18)
		var actions := HBoxContainer.new()
		for action: String in ["Edit", "Delete"]:
			var button := Button.new()
			button.text = action
			button.custom_minimum_size = Vector2(100, 36)
			button.disabled = _hypothesis_case_id.strip_edges().is_empty() or _hypothesis_max_length <= 0
			if action == "Edit":
				button.pressed.connect(_on_hypothesis_edit_pressed.bind(record.hypothesis_id))
			else:
				button.pressed.connect(_on_hypothesis_delete_pressed.bind(record.hypothesis_id))
			actions.add_child(button)
		item.add_child(actions)
		%HypothesisList.add_child(item)


func _update_hypothesis_input() -> void:
	var text: String = %HypothesisInput.text.strip_edges()
	%HypothesisInput.editable = not _hypothesis_case_id.strip_edges().is_empty() and _hypothesis_max_length > 0
	%SaveHypothesisButton.disabled = not %HypothesisInput.editable or text.is_empty() or text.length() > _hypothesis_max_length
	%SaveHypothesisButton.text = "Add Hypothesis" if _editing_hypothesis_id.is_empty() else "Update Hypothesis"
	%CancelHypothesisButton.visible = not _editing_hypothesis_id.is_empty()
	%HypothesisStatus.text = "%d / %d characters (trimmed)." % [text.length(), _hypothesis_max_length]
	if text.length() > _hypothesis_max_length:
		%HypothesisStatus.text += " Too long; note will not be saved."


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
