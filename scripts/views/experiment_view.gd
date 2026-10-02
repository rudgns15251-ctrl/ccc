extends "res://scripts/views/flow_view.gd"

signal experiment_executed(experiment_id: String)

@onready var description_label: Label = %Description
@onready var experiment_list: VBoxContainer = %ExperimentList
@onready var experiment_scroll: ScrollContainer = %ExperimentScroll
@onready var run_button: Button = %RunButton
@onready var result_label: Label = %ResultText

var _experiments: Array[ExperimentData] = []
var _selected_experiment_index: int = -1
var _selection_group: ButtonGroup


func setup(experiments: Array[ExperimentData]) -> void:
	_experiments = experiments
	_selected_experiment_index = -1
	if is_node_ready():
		_display_experiments()


func _ready() -> void:
	super._ready()
	run_button.pressed.connect(_on_run_experiment_pressed)
	_display_experiments()


func _display_experiments() -> void:
	_selected_experiment_index = -1
	run_button.disabled = true
	_reset_result()
	_selection_group = ButtonGroup.new()
	_selection_group.allow_unpress = false
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
			_append_item("[Missing ExperimentData]", "No ExperimentData was provided for item %d." % (index + 1), index, false)
			continue
		if experiment.experiment_id.strip_edges().is_empty():
			push_warning("ExperimentView: experiment_id at index %d is empty." % index)
		_append_item(
			_text_or_placeholder(experiment.display_name, "display_name", index),
			_text_or_placeholder(experiment.description, "description", index),
			index
		)


func _append_item(display_name: String, description: String, index: int, selectable: bool = true) -> void:
	var item := VBoxContainer.new()
	item.add_theme_constant_override("separation", 2)
	var select_button := CheckBox.new()
	select_button.text = display_name
	select_button.add_theme_font_size_override("font_size", 18)
	select_button.button_group = _selection_group
	select_button.disabled = not selectable
	select_button.pressed.connect(_on_experiment_selected.bind(index))
	item.add_child(select_button)
	var item_description := Label.new()
	item_description.text = description
	item_description.add_theme_font_size_override("font_size", 18)
	item_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	item.add_child(item_description)
	experiment_list.add_child(item)


func _on_experiment_selected(index: int) -> void:
	if _selected_experiment_index != index:
		_reset_result()
	_selected_experiment_index = index
	run_button.disabled = _get_selected_experiment() == null


func _get_selected_experiment() -> ExperimentData:
	if _selected_experiment_index < 0 or _selected_experiment_index >= _experiments.size():
		return null
	return _experiments[_selected_experiment_index]


func _on_run_experiment_pressed() -> void:
	var experiment: ExperimentData = _get_selected_experiment()
	if experiment == null:
		run_button.disabled = true
		_reset_result()
		push_warning("ExperimentView: no valid Experiment is selected.")
		return
	if experiment.experiment_id.strip_edges().is_empty():
		_reset_result()
		push_warning("ExperimentView: cannot execute an Experiment with an empty experiment_id.")
		return
	result_label.text = _text_or_placeholder(experiment.result_text, "result_text", _selected_experiment_index)
	experiment_executed.emit(experiment.experiment_id)


func _reset_result() -> void:
	result_label.text = "No experiment has been executed."


func _text_or_placeholder(value: String, field_name: String, index: int) -> String:
	if value.strip_edges().is_empty():
		push_warning("ExperimentView: %s at index %d is empty." % [field_name, index])
		return "[Missing %s]" % field_name
	return value
