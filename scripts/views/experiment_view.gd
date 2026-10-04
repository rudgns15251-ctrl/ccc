extends "res://scripts/views/flow_view.gd"

const EnvironmentConditions = preload("res://scripts/views/environment_conditions_view.gd")

signal experiment_execution_requested(experiment_id: String)
signal cctv_review_requested

@onready var description_label: Label = %Description
@onready var experiment_list: VBoxContainer = %ExperimentList
@onready var experiment_scroll: ScrollContainer = %ExperimentScroll
@onready var run_button: Button = %RunButton
@onready var result_label: Label = %ResultText
@onready var remaining_label: Label = %RemainingCount

var _experiments: Array[ExperimentData] = []
var _selected_experiment_index: int = -1
var _selection_group: ButtonGroup
var _executed_ids: Array[String] = []
var _remaining_count: int = 0
var _experiment_limit: int = 0


func setup(experiments: Array[ExperimentData], executed_ids: Array[String] = [], remaining_count: int = 0, experiment_limit: int = 0) -> void:
	_experiments = experiments
	_executed_ids = executed_ids.duplicate()
	_remaining_count = maxi(remaining_count, 0)
	_experiment_limit = maxi(experiment_limit, 0)
	_selected_experiment_index = -1
	if is_node_ready():
		_display_experiments()


func _ready() -> void:
	super._ready()
	%RecheckCCTVButton.pressed.connect(cctv_review_requested.emit)
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
	_update_execution_ui()
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
	_update_execution_ui()


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
	if not _can_select_experiment(index):
		return
	if _selected_experiment_index != index:
		_reset_result()
	_selected_experiment_index = index
	run_button.disabled = false


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
	experiment_execution_requested.emit(experiment.experiment_id)


func show_execution_result(experiment_id: String, approved: bool) -> void:
	var experiment: ExperimentData = _get_selected_experiment()
	if approved and experiment != null and experiment.experiment_id == experiment_id:
		result_label.text = _text_or_placeholder(experiment.result_text, "result_text", _selected_experiment_index)


func update_execution_state(executed_ids: Array[String], remaining_count: int, experiment_limit: int) -> void:
	_executed_ids = executed_ids.duplicate()
	_remaining_count = maxi(remaining_count, 0)
	_experiment_limit = maxi(experiment_limit, 0)
	if is_node_ready():
		_update_execution_ui()


func _can_select_experiment(index: int) -> bool:
	if index < 0 or index >= _experiments.size():
		return false
	var experiment: ExperimentData = _experiments[index]
	return experiment != null and not experiment.experiment_id.strip_edges().is_empty() and not _executed_ids.has(experiment.experiment_id) and _remaining_count > 0


func _update_execution_ui() -> void:
	remaining_label.text = "Experiments Remaining: %d / %d" % [_remaining_count, _experiment_limit]
	for index in range(experiment_list.get_child_count()):
		var button: CheckBox = experiment_list.get_child(index).get_child(0) as CheckBox
		var experiment: ExperimentData = _experiments[index]
		button.disabled = not _can_select_experiment(index)
		if experiment != null:
			button.text = experiment.display_name if not experiment.display_name.strip_edges().is_empty() else "[Missing display_name]"
			if _executed_ids.has(experiment.experiment_id):
				button.text += " [Executed]"
	if not _can_select_experiment(_selected_experiment_index):
		_selected_experiment_index = -1
		var selected_button: BaseButton = _selection_group.get_pressed_button()
		if selected_button != null:
			_selection_group.allow_unpress = true
			selected_button.set_pressed_no_signal(false)
			_selection_group.allow_unpress = false
	run_button.disabled = not _can_select_experiment(_selected_experiment_index)


func _reset_result() -> void:
	result_label.text = "No experiment has been executed."


func _text_or_placeholder(value: String, field_name: String, index: int) -> String:
	if value.strip_edges().is_empty():
		push_warning("ExperimentView: %s at index %d is empty." % [field_name, index])
		return "[Missing %s]" % field_name
	return value


func set_environment_conditions(summary: EnvironmentConditions.Summary) -> void:
	var conditions: EnvironmentConditions = get_node("%EnvironmentConditions")
	conditions.set_summary(summary)
	%RecheckCCTVButton.visible = summary != null and not summary.entries.is_empty()
