extends "res://scripts/views/flow_view.gd"

signal case_requested(case_id: String)
var _case_summaries: Array = []

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
	_display_cases()


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
	%Description.text = _snapshot.display_name
	for entry: ResearchEntry in _snapshot.research_entries:
		if entry == null:
			continue
		var button := Button.new()
		button.text = entry.category + " / " + entry.title
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.custom_minimum_size.y = 48
		button.pressed.connect(func() -> void:
			if _allows_local_input():
				%EntryTitle.text = entry.title
				%EntryBody.text = entry.body_text
				%DetailScroll.scroll_vertical = 0)
		%ResearchList.add_child(button)
	for record: Dictionary in _snapshot.hypotheses:
		var button := Button.new()
		button.text = "WORKING NOTE"
		button.custom_minimum_size.y = 48
		button.pressed.connect(func() -> void:
			if _allows_local_input():
				%EntryTitle.text = "WORKING NOTE"
				%EntryBody.text = record.text)
		%HypothesisList.add_child(button)


func _append_text(list: VBoxContainer, text: String) -> void:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_child(label)

func set_case_summaries(summaries: Array) -> void:
	_case_summaries = summaries
	if is_node_ready(): _display_cases()

func _display_cases() -> void:
	for child: Node in %CaseList.get_children():
		%CaseList.remove_child(child)
		child.queue_free()
	for summary: RefCounted in _case_summaries:
		var button := Button.new()
		button.text = summary.display_name
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.disabled = not summary.available or summary.case_id == _snapshot.case_id
		button.custom_minimum_size.y = 48
		button.pressed.connect(func() -> void:
			if _allows_local_input(): case_requested.emit(summary.case_id))
		%CaseList.add_child(button)
