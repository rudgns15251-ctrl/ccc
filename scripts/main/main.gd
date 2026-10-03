extends Control

const FlowView = preload("res://scripts/views/flow_view.gd")
const ProfileView = preload("res://scripts/views/profile_view.gd")
const CCTVView = preload("res://scripts/views/cctv_view.gd")
const ExperimentView = preload("res://scripts/views/experiment_view.gd")
const ContainmentView = preload("res://scripts/views/containment_view.gd")
const MonitoringView = preload("res://scripts/views/monitoring_view.gd")
const IncidentView = preload("res://scripts/views/incident_view.gd")
const BroadcastView = preload("res://scripts/views/broadcast_view.gd")
const IncidentResultView = preload("res://scripts/views/incident_result_view.gd")
const ResultView = preload("res://scripts/views/result_view.gd")

enum Stage { PROFILE, CCTV, EXPERIMENT, CONTAINMENT, MONITORING, RESULT, INCIDENT, BROADCAST, INCIDENT_RESULT }

const VIEW_SCENES: Array[PackedScene] = [
	preload("res://scenes/views/profile_view.tscn"),
	preload("res://scenes/views/cctv_view.tscn"),
	preload("res://scenes/views/experiment_view.tscn"),
	preload("res://scenes/views/containment_view.tscn"),
	preload("res://scenes/views/monitoring_view.tscn"),
	preload("res://scenes/views/result_view.tscn"),
	preload("res://scenes/views/incident_view.tscn"),
	preload("res://scenes/views/broadcast_view.tscn"),
	preload("res://scenes/views/incident_result_view.tscn"),
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
	_current_view.advance_requested.connect(_on_advance_requested.bind(_current_view))
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
	elif stage == Stage.INCIDENT:
		var incident_view: IncidentView = _current_view as IncidentView
		var incident: IncidentData = _get_current_incident_data()
		var broadcast: EmergencyBroadcastData = _get_current_emergency_broadcast() if incident != null else null
		incident_view.setup(incident, _has_valid_broadcast_options(broadcast))
	elif stage == Stage.BROADCAST:
		var broadcast_view: BroadcastView = _current_view as BroadcastView
		broadcast_view.broadcast_confirmation_requested.connect(_on_broadcast_confirmation_requested.bind(broadcast_view))
		broadcast_view.setup(
			_get_current_emergency_broadcast(),
			case_runtime.get_confirmed_broadcast_id(),
			case_runtime.get_confirmed_broadcast_option_id()
		)
	elif stage == Stage.INCIDENT_RESULT:
		var incident_result_view: IncidentResultView = _current_view as IncidentResultView
		incident_result_view.setup(_get_current_incident_result())
	elif stage == Stage.RESULT:
		var result_view: ResultView = _current_view as ResultView
		result_view.setup(_build_result_summary())
	view_host.add_child(_current_view)


func _build_result_summary() -> ResultView.Summary:
	var summary := ResultView.Summary.new()
	summary.case_id = case_runtime.case_id
	summary.monitoring_result = case_runtime.get_monitoring_result()
	summary.room_id = case_runtime.get_confirmed_containment_room_id()
	summary.experiment_ids = case_runtime.get_experiment_execution_history()
	if current_case != null:
		summary.case_display_name = current_case.display_name
		summary.experiment_limit = current_case.experiment_limit
		for room: ContainmentData in current_case.available_containment_rooms:
			if room != null and not summary.room_id.strip_edges().is_empty() and room.room_id == summary.room_id:
				summary.room = room
				break
		for id: String in summary.experiment_ids:
			var match_experiment: ExperimentData
			for experiment: ExperimentData in current_case.available_experiments:
				if experiment != null and experiment.experiment_id == id:
					match_experiment = experiment
					break
			summary.experiments.append(match_experiment)
	if summary.monitoring_result == MonitoringOutcomeData.Result.FAILURE:
		summary.incident = _get_current_incident_data()
		summary.broadcast = _get_current_emergency_broadcast()
		summary.option = _get_current_confirmed_broadcast_option()
		summary.incident_result = _get_current_incident_result()
	return summary


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


func _get_current_incident_data() -> IncidentData:
	if case_runtime.get_monitoring_result() != MonitoringOutcomeData.Result.FAILURE:
		return null
	if current_case == null:
		push_warning("Main: current_case is missing for Incident.")
		return null
	if not case_runtime.has_confirmed_containment():
		push_warning("Main: no confirmed containment room for Incident.")
		return null
	var outcome: MonitoringOutcomeData = _get_monitoring_outcome()
	if outcome == null:
		return null
	if outcome.room_id != case_runtime.get_confirmed_containment_room_id():
		push_warning("Main: Incident Outcome room_id does not match the confirmed room.")
		return null
	if outcome.final_result != MonitoringOutcomeData.Result.FAILURE:
		push_warning("Main: Incident Outcome final_result is not FAILURE.")
		return null
	if outcome.incident_id.strip_edges().is_empty():
		push_warning("Main: Incident Outcome incident_id is empty.")
		return null
	if current_case.incidents.is_empty():
		push_warning("Main: incidents is empty for Incident %s." % outcome.incident_id)
		return null
	for index in range(current_case.incidents.size()):
		var incident: IncidentData = current_case.incidents[index]
		if incident == null:
			push_warning("Main: IncidentData at index %d is missing." % index)
			continue
		if incident.incident_id.strip_edges().is_empty():
			push_warning("Main: IncidentData.incident_id at index %d is empty." % index)
			continue
		if incident.incident_id == outcome.incident_id:
			return incident
	push_warning("Main: no IncidentData for incident_id %s." % outcome.incident_id)
	return null


func _get_current_emergency_broadcast() -> EmergencyBroadcastData:
	if case_runtime.get_monitoring_result() != MonitoringOutcomeData.Result.FAILURE:
		return null
	if current_case == null:
		push_warning("Main: current_case is missing for Broadcast.")
		return null
	var incident: IncidentData = _get_current_incident_data()
	if incident == null:
		return null
	if incident.broadcast_id.strip_edges().is_empty():
		push_warning("Main: IncidentData.broadcast_id is empty.")
		return null
	if current_case.emergency_broadcasts.is_empty():
		push_warning("Main: emergency_broadcasts is empty for Broadcast %s." % incident.broadcast_id)
		return null
	for index in range(current_case.emergency_broadcasts.size()):
		var broadcast: EmergencyBroadcastData = current_case.emergency_broadcasts[index]
		if broadcast == null:
			push_warning("Main: EmergencyBroadcastData at index %d is missing." % index)
			continue
		if broadcast.broadcast_id.strip_edges().is_empty():
			push_warning("Main: EmergencyBroadcastData.broadcast_id at index %d is empty." % index)
			continue
		if broadcast.broadcast_id == incident.broadcast_id:
			if not _has_valid_broadcast_options(broadcast):
				push_warning("Main: Broadcast %s has no valid options." % broadcast.broadcast_id)
			return broadcast
	push_warning("Main: no EmergencyBroadcastData for broadcast_id %s." % incident.broadcast_id)
	return null


func _has_valid_broadcast_options(broadcast: EmergencyBroadcastData) -> bool:
	if broadcast == null or broadcast.broadcast_id.strip_edges().is_empty():
		return false
	for option: BroadcastOptionData in broadcast.options:
		if option != null and not option.option_id.strip_edges().is_empty():
			return true
	return false


func _get_broadcast_option(broadcast: EmergencyBroadcastData, option_id: String) -> BroadcastOptionData:
	if broadcast == null or broadcast.broadcast_id.strip_edges().is_empty() or option_id.strip_edges().is_empty():
		return null
	for option: BroadcastOptionData in broadcast.options:
		if option != null and not option.option_id.strip_edges().is_empty() and option.option_id == option_id:
			return option
	return null


func _has_current_broadcast_confirmation(broadcast: EmergencyBroadcastData) -> bool:
	return case_runtime.has_confirmed_broadcast_option() and broadcast != null and broadcast.broadcast_id == case_runtime.get_confirmed_broadcast_id() and _get_broadcast_option(broadcast, case_runtime.get_confirmed_broadcast_option_id()) != null


func _get_current_confirmed_broadcast_option() -> BroadcastOptionData:
	var broadcast: EmergencyBroadcastData = _get_current_emergency_broadcast()
	if not _has_current_broadcast_confirmation(broadcast):
		return null
	return _get_broadcast_option(broadcast, case_runtime.get_confirmed_broadcast_option_id())


func _get_incident_result_for_option(option: BroadcastOptionData) -> IncidentResultData:
	if option == null:
		return null
	if current_case == null:
		push_warning("Main: current_case is missing for Incident Result.")
		return null
	if option.result_id.strip_edges().is_empty():
		push_warning("Main: BroadcastOptionData.result_id is empty for option %s." % option.option_id)
		return null
	if current_case.incident_results.is_empty():
		push_warning("Main: incident_results is empty for result %s." % option.result_id)
		return null
	for index in range(current_case.incident_results.size()):
		var incident_result: IncidentResultData = current_case.incident_results[index]
		if incident_result == null:
			push_warning("Main: IncidentResultData at index %d is missing." % index)
			continue
		if incident_result.result_id.strip_edges().is_empty():
			push_warning("Main: IncidentResultData.result_id at index %d is empty." % index)
			continue
		if incident_result.result_id == option.result_id:
			return incident_result
	push_warning("Main: no IncidentResultData for result_id %s." % option.result_id)
	return null


func _get_current_incident_result() -> IncidentResultData:
	return _get_incident_result_for_option(_get_current_confirmed_broadcast_option())


func _on_broadcast_confirmation_requested(broadcast_id: String, option_id: String, broadcast_view: BroadcastView) -> void:
	if _current_stage != Stage.BROADCAST or not _is_active_view(broadcast_view):
		return
	var broadcast: EmergencyBroadcastData = _get_current_emergency_broadcast()
	if not case_runtime.has_confirmed_broadcast_option() and broadcast != null and broadcast.broadcast_id == broadcast_id:
		var option: BroadcastOptionData = _get_broadcast_option(broadcast, option_id)
		if _get_incident_result_for_option(option) != null:
			case_runtime.try_confirm_broadcast_option(broadcast_id, option_id)
	broadcast_view.update_confirmation_state(case_runtime.get_confirmed_broadcast_id(), case_runtime.get_confirmed_broadcast_option_id())


func _is_active_view(view: FlowView) -> bool:
	return is_instance_valid(view) and view == _current_view and view.is_inside_tree() and not view.is_queued_for_deletion()


func _on_advance_requested(view: FlowView) -> void:
	if not _is_active_view(view):
		return
	if _current_stage == Stage.CONTAINMENT and not case_runtime.has_confirmed_containment():
		return
	if _current_stage == Stage.INCIDENT and not _has_valid_broadcast_options(_get_current_emergency_broadcast()):
		return
	if (_current_stage == Stage.BROADCAST or _current_stage == Stage.INCIDENT_RESULT) and _get_current_incident_result() == null:
		return
	var next_stage: int = _get_next_stage(_current_stage)
	if next_stage != -1:
		_show_view(next_stage)


func _get_next_stage(stage: int) -> int:
	match stage:
		Stage.PROFILE:
			return Stage.CCTV
		Stage.CCTV:
			return Stage.EXPERIMENT
		Stage.EXPERIMENT:
			return Stage.CONTAINMENT
		Stage.CONTAINMENT:
			return Stage.MONITORING
		Stage.MONITORING:
			match case_runtime.get_monitoring_result():
				MonitoringOutcomeData.Result.SUCCESS:
					return Stage.RESULT
				MonitoringOutcomeData.Result.FAILURE:
					return Stage.INCIDENT
		Stage.INCIDENT:
			return Stage.BROADCAST
		Stage.BROADCAST:
			return Stage.INCIDENT_RESULT
		Stage.INCIDENT_RESULT:
			return Stage.RESULT
		Stage.RESULT:
			return Stage.PROFILE
	return -1


func _on_monitoring_playback_completed(monitoring_view: MonitoringView) -> void:
	if _current_stage != Stage.MONITORING or not _is_active_view(monitoring_view):
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
	if not _is_active_view(experiment_view):
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
	if not _is_active_view(containment_view):
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
