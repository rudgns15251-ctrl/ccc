extends "res://scripts/views/flow_view.gd"

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


@onready var case_label: Label = %Description
@onready var result_label: Label = %MonitoringResult
@onready var entry_scroll: ScrollContainer = %EntryScroll
@onready var entry_list: VBoxContainer = %EntryList

var _snapshot: Snapshot


func setup(snapshot: Snapshot) -> void:
	_snapshot = snapshot
	if is_node_ready():
		_display_snapshot()


func _ready() -> void:
	super._ready()
	_display_snapshot()


func _display_snapshot() -> void:
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
