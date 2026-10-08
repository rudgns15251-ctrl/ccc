extends VBoxContainer

# Display values only. Main derives these from the current Runtime's applied IDs.
class Condition extends RefCounted:
	var disturbance_id: String
	var display_name: String
	var condition_change_text: String

	func _init(id: String, title: String, condition_text: String) -> void:
		disturbance_id = id
		display_name = title
		condition_change_text = condition_text


class Summary extends RefCounted:
	var entries: Array[Condition] = []


var _entries: Array[Condition] = []


func set_summary(summary: Summary) -> void:
	_entries.clear()
	if summary != null:
		for entry: Condition in summary.entries:
			if entry != null:
				_entries.append(Condition.new(entry.disturbance_id, entry.display_name, entry.condition_change_text))
	if is_node_ready():
		_display_conditions()


func _ready() -> void:
	_display_conditions()


func _display_conditions() -> void:
	var list: VBoxContainer = %ConditionList
	for item: Node in list.get_children():
		list.remove_child(item)
		item.queue_free()
	visible = not _entries.is_empty()
	for entry: Condition in _entries:
		var label := Label.new()
		label.text = "%s\n%s" % [entry.display_name, entry.condition_change_text]
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		list.add_child(label)
