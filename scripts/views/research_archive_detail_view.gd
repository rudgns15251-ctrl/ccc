extends "res://scripts/views/flow_view.gd"

class ResearchEntry extends RefCounted:
	var entry_id: String = ""
	var category: String = ""
	var source_id: String = ""
	var title: String = ""
	var body_text: String = ""

class Snapshot extends RefCounted:
	var case_id: String = ""
	var display_name: String = "[Unavailable]"
	var research_entries: Array[ResearchEntry] = []
	var hypotheses: Array[Dictionary] = []

var _snapshot: Snapshot


func setup(snapshot: Snapshot) -> void:
	_snapshot = snapshot
	if is_node_ready():
		_display_snapshot()


func _ready() -> void:
	super._ready()
	_display_snapshot()


func _display_snapshot() -> void:
	for list: VBoxContainer in [%ResearchList, %HypothesisList]:
		for child: Node in list.get_children():
			list.remove_child(child)
			child.queue_free()
	%ResearchScroll.scroll_vertical = 0
	%HypothesisScroll.scroll_vertical = 0
	%Description.text = "Case: [Unavailable]"
	%ResearchEmpty.visible = _snapshot == null or _snapshot.research_entries.is_empty()
	%HypothesisEmpty.visible = _snapshot == null or _snapshot.hypotheses.is_empty()
	if _snapshot == null:
		return
	%Description.text = "Case: %s (%s)" % [_snapshot.display_name, _snapshot.case_id]
	for entry: ResearchEntry in _snapshot.research_entries:
		if entry == null:
			continue
		_append_text(%ResearchList, ("[%s]\n" % entry.category if not entry.category.is_empty() else "") + "%s\nEntry ID: %s\n%s" % [entry.title, entry.entry_id, entry.body_text])
	for record: Dictionary in _snapshot.hypotheses:
		_append_text(%HypothesisList, "%s\n%s" % [record.hypothesis_id, record.text])


func _append_text(list: VBoxContainer, text: String) -> void:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 18)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_child(label)
