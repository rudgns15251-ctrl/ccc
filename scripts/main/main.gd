extends Control

const FlowView = preload("res://scripts/views/flow_view.gd")
const ProfileView = preload("res://scripts/views/profile_view.gd")
const CCTVView = preload("res://scripts/views/cctv_view.gd")
const ExperimentView = preload("res://scripts/views/experiment_view.gd")
const ContainmentView = preload("res://scripts/views/containment_view.gd")
const MonitoringView = preload("res://scripts/views/monitoring_view.gd")

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
		experiment_view.experiment_execution_requested.connect(_on_experiment_execution_requested.bind(experiment_view))
		var limit: int = current_case.experiment_limit if current_case != null else 0
		experiment_view.setup(
			current_case.available_experiments if current_case != null else [],
			case_runtime.get_experiment_execution_history(),
			case_runtime.get_remaining_experiment_count(limit),
			limit
		)
	elif stage == Stage.CONTAINMENT:
		var containment_view: ContainmentView = _current_view as ContainmentView
		containment_view.containment_confirmation_requested.connect(_on_containment_confirmation_requested.bind(containment_view))
		containment_view.setup(
			current_case.available_containment_rooms if current_case != null else [],
			case_runtime.get_confirmed_containment_room_id()
		)
	elif stage == Stage.MONITORING:
		var monitoring_view: MonitoringView = _current_view as MonitoringView
		monitoring_view.monitoring_playback_completed.connect(_on_monitoring_playback_completed.bind(monitoring_view))
		monitoring_view.setup(_get_monitoring_outcome(), case_runtime.get_monitoring_result())
	view_host.add_child(_current_view)


func _get_monitoring_outcome() -> MonitoringOutcomeData:
	var room_id: String = case_runtime.get_confirmed_containment_room_id()
	if room_id.strip_edges().is_empty():
		push_warning("Main: no confirmed containment room for Monitoring.")
		return null
	if current_case == null:
		push_warning("Main: current_case is missing for Monitoring.")
		return null
	if current_case.containment_outcomes.is_empty():
		push_warning("Main: containment_outcomes is empty for room %s." % room_id)
		return null
	for index in range(current_case.containment_outcomes.size()):
		var outcome: MonitoringOutcomeData = current_case.containment_outcomes[index]
		if outcome == null:
			push_warning("Main: MonitoringOutcomeData at index %d is missing." % index)
			continue
		if outcome.room_id.strip_edges().is_empty():
			push_warning("Main: MonitoringOutcomeData.room_id at index %d is empty." % index)
			continue
		if outcome.room_id == room_id:
			return outcome
	push_warning("Main: no MonitoringOutcomeData for confirmed room %s." % room_id)
	return null


func _on_advance_requested() -> void:
	if _current_stage == Stage.CONTAINMENT and not case_runtime.has_confirmed_containment():
		return
	if _current_stage == Stage.MONITORING and (not case_runtime.has_monitoring_result() or _current_view.next_button.disabled):
		return
	_show_view((_current_stage + 1) % VIEW_SCENES.size())


func _on_monitoring_playback_completed(monitoring_view: MonitoringView) -> void:
	if monitoring_view != _current_view or _current_stage != Stage.MONITORING:
		return
	if current_case == null:
		push_warning("Main: current_case is missing for Monitoring result.")
		return
	var room_id: String = case_runtime.get_confirmed_containment_room_id()
	if room_id.strip_edges().is_empty():
		push_warning("Main: no confirmed containment room for Monitoring result.")
		return
	var outcome: MonitoringOutcomeData = _get_monitoring_outcome()
	if outcome == null:
		return
	if outcome.room_id != room_id:
		push_warning("Main: Monitoring Outcome room_id does not match the confirmed room.")
		return
	if not monitoring_view.has_completed_playback(outcome):
		push_warning("Main: Monitoring playback is incomplete or belongs to a different Outcome.")
		return
	if outcome.final_result != MonitoringOutcomeData.Result.SUCCESS and outcome.final_result != MonitoringOutcomeData.Result.FAILURE:
		push_warning("Main: Monitoring final_result is undefined or unsupported.")
		return
	if case_runtime.has_monitoring_result():
		return
	if not case_runtime.try_set_monitoring_result(outcome.final_result):
		push_warning("Main: Monitoring result could not be recorded.")
		return
	monitoring_view.apply_monitoring_result(case_runtime.get_monitoring_result())


func _on_experiment_execution_requested(experiment_id: String, experiment_view: ExperimentView) -> void:
	if experiment_view != _current_view:
		return
	var limit: int = current_case.experiment_limit if current_case != null else 0
	var approved: bool = case_runtime.try_record_experiment_execution(experiment_id, limit)
	experiment_view.show_execution_result(experiment_id, approved)
	experiment_view.update_execution_state(
		case_runtime.get_experiment_execution_history(),
		case_runtime.get_remaining_experiment_count(limit),
		limit
	)


func _on_containment_confirmation_requested(room_id: String, containment_view: ContainmentView) -> void:
	if containment_view != _current_view:
		return
	if current_case != null and not room_id.strip_edges().is_empty():
		for room: ContainmentData in current_case.available_containment_rooms:
			if room != null and room.room_id == room_id:
				case_runtime.try_confirm_containment_room(room_id)
				break
	containment_view.update_confirmation_state(case_runtime.get_confirmed_containment_room_id())


func _validate_case() -> void:
	if current_case == null:
		push_warning("Main: current_case is not assigned. Select a CaseData Resource in the Inspector.")
		return
	if current_case.case_id.strip_edges().is_empty():
		push_warning("Main: current_case.case_id is empty.")
	if current_case.display_name.strip_edges().is_empty():
		push_warning("Main: current_case.display_name is empty.")
	if current_case.experiment_limit < 0:
		push_warning("Main: current_case.experiment_limit is negative; treating it as zero.")
