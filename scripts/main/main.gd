extends Control

const FlowView = preload("res://scripts/views/flow_view.gd")
const ProfileView = preload("res://scripts/views/profile_view.gd")
const CCTVView = preload("res://scripts/views/cctv_view.gd")
const ExperimentView = preload("res://scripts/views/experiment_view.gd")

enum Stage { PROFILE, CCTV, EXPERIMENT, CONTAINMENT, MONITORING, RESULT }

const VIEW_SCENES: Array[PackedScene] = [
	preload("res://scenes/views/profile_view.tscn"),
	preload("res://scenes/views/cctv_view.tscn"),
	preload("res://scenes/views/experiment_view.tscn"),
	preload("res://scenes/views/containment_view.tscn"),
	preload("res://scenes/views/monitoring_view.tscn"),
	preload("res://scenes/views/result_view.tscn"),
]

@export var current_case: CaseData

var case_runtime: CaseRuntimeState

@onready var window_size_label: Label = %WindowSize
@onready var view_host: Control = %ViewHost

var _current_stage: int = Stage.PROFILE
var _current_view: FlowView


func _ready() -> void:
	get_viewport().size_changed.connect(_update_window_size)
	_update_window_size()
	_validate_case()
	case_runtime = CaseRuntimeState.new(current_case.case_id if current_case != null else "")
	_show_view(Stage.PROFILE)


func _update_window_size() -> void:
	var window_size: Vector2i = get_window().size
	window_size_label.text = "Window: %d × %d" % [window_size.x, window_size.y]


func _show_view(stage: int) -> void:
	if is_instance_valid(_current_view):
		view_host.remove_child(_current_view)
		_current_view.queue_free()

	_current_stage = stage
	_current_view = VIEW_SCENES[stage].instantiate()
	_current_view.advance_requested.connect(_on_advance_requested)
	if stage == Stage.PROFILE:
		var profile_view: ProfileView = _current_view as ProfileView
		profile_view.setup(current_case.profile_data if current_case != null else null)
	elif stage == Stage.CCTV:
		var cctv_view: CCTVView = _current_view as CCTVView
		cctv_view.setup(current_case.cctv_data if current_case != null else null)
	elif stage == Stage.EXPERIMENT:
		var experiment_view: ExperimentView = _current_view as ExperimentView
		experiment_view.experiment_executed.connect(_on_experiment_executed)
		experiment_view.setup(current_case.available_experiments if current_case != null else [])
	view_host.add_child(_current_view)


func _on_advance_requested() -> void:
	_show_view((_current_stage + 1) % VIEW_SCENES.size())


func _on_experiment_executed(experiment_id: String) -> void:
	case_runtime.record_experiment_execution(experiment_id)


func _validate_case() -> void:
	if current_case == null:
		push_warning("Main: current_case is not assigned. Select a CaseData Resource in the Inspector.")
		return
	if current_case.case_id.strip_edges().is_empty():
		push_warning("Main: current_case.case_id is empty.")
	if current_case.display_name.strip_edges().is_empty():
		push_warning("Main: current_case.display_name is empty.")
