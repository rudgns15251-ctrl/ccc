extends "res://scripts/views/flow_view.gd"

signal case_requested(case_id: String)

class CaseSummary extends RefCounted:
	var case_id: String = ""
	var display_name: String = ""
	var research_count: int = 0
	var hypothesis_count: int = 0
	var available: bool = false

class Snapshot extends RefCounted:
	var cases: Array[CaseSummary] = []

var _snapshot: Snapshot


func setup(snapshot: Snapshot) -> void:
	_snapshot = snapshot
	if is_node_ready():
		_display_snapshot()


func _ready() -> void:
	super._ready()
	_display_snapshot()


func _display_snapshot() -> void:
	%CaseScroll.scroll_vertical = 0
	for child: Node in %CaseList.get_children():
		%CaseList.remove_child(child)
		child.queue_free()
	%EmptyState.visible = _snapshot == null or _snapshot.cases.is_empty()
	if _snapshot == null:
		return
	for item: CaseSummary in _snapshot.cases:
		if item == null:
			continue
		var row := VBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var label := Label.new()
		label.text = "%s (%s)\nResearch: %d\nHypotheses: %d" % [item.display_name, item.case_id, item.research_count, item.hypothesis_count]
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_font_size_override("font_size", 20)
		row.add_child(label)
		var button := Button.new()
		button.text = "Open" if item.available else "Unavailable"
		button.custom_minimum_size = Vector2(120, 36)
		button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		button.disabled = not item.available or item.case_id.strip_edges().is_empty()
		button.pressed.connect(func() -> void: case_requested.emit(item.case_id))
		row.add_child(button)
		%CaseList.add_child(row)
