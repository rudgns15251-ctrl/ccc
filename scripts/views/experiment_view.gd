extends "res://scripts/views/flow_view.gd"

@onready var description_label: Label = %Description
@onready var experiment_list: VBoxContainer = %ExperimentList
@onready var experiment_scroll: ScrollContainer = %ExperimentScroll

var _experiments: Array[ExperimentData] = []


func setup(experiments: Array[ExperimentData]) -> void:
	_experiments = experiments
	if is_node_ready():
		_display_experiments()


func _ready() -> void:
	super._ready()
	_display_experiments()


func _display_experiments() -> void:
	for item: Node in experiment_list.get_children():
		experiment_list.remove_child(item)
		item.queue_free()
	experiment_scroll.scroll_vertical = 0
	if _experiments.is_empty():
		push_warning("ExperimentView.setup(): available_experiments is empty.")
		description_label.text = "No experiments available"
		return

	description_label.text = "Available experiments: %d" % _experiments.size()
	for index in range(_experiments.size()):
		var experiment: ExperimentData = _experiments[index]
		if experiment == null:
			push_warning("ExperimentView: ExperimentData at index %d is missing." % index)
			_append_item("[Missing ExperimentData]", "No ExperimentData was provided for item %d." % (index + 1))
			continue
		if experiment.experiment_id.strip_edges().is_empty():
			push_warning("ExperimentView: experiment_id at index %d is empty." % index)
		_append_item(
			_text_or_placeholder(experiment.display_name, "display_name", index),
			_text_or_placeholder(experiment.description, "description", index)
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
	experiment_list.add_child(item)


func _text_or_placeholder(value: String, field_name: String, index: int) -> String:
	if value.strip_edges().is_empty():
		push_warning("ExperimentView: %s at index %d is empty." % [field_name, index])
		return "[Missing %s]" % field_name
	return value
