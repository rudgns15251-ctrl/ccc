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
const ResearchLogView = preload("res://scripts/views/research_log_view.gd")
const ArchiveListView = preload("res://scripts/views/research_archive_list_view.gd")
const ArchiveDetailView = preload("res://scripts/views/research_archive_detail_view.gd")
const DisturbanceNotice = preload("res://scripts/views/environmental_disturbance_notice.gd")
const EnvironmentConditions = preload("res://scripts/views/environment_conditions_view.gd")
const DISTURBANCE_NOTICE_SCENE = preload("res://scenes/views/environmental_disturbance_notice.tscn")
# Temporary opportunity count range for this vertical slice, not final balance.
const PROTOTYPE_DISTURBANCE_THRESHOLD := Vector2i(2, 4)

enum Stage { PROFILE, CCTV, EXPERIMENT, CONTAINMENT, MONITORING, RESULT, INCIDENT, BROADCAST, INCIDENT_RESULT, RESEARCH_LOG, RESEARCH_ARCHIVE_LIST, RESEARCH_ARCHIVE_DETAIL }

const RESEARCH_LOG_STAGES: Array[int] = [Stage.PROFILE, Stage.CCTV, Stage.EXPERIMENT, Stage.CONTAINMENT, Stage.INCIDENT, Stage.BROADCAST, Stage.INCIDENT_RESULT, Stage.RESULT]

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
	preload("res://scenes/views/research_log_view.tscn"),
	preload("res://scenes/views/research_archive_list_view.tscn"),
	preload("res://scenes/views/research_archive_detail_view.tscn"),
]

@export var current_case: CaseData
@export var case_sequence: Array[CaseData] = []

var case_runtime: CaseRuntimeState
var research_archive: ResearchArchiveState
var working_hypotheses: WorkingHypothesisState
var pending_containment: PendingContainmentState
var containment_resolutions: ContainmentResolutionState
var failure_candidates: FailureEventCandidateState

@onready var window_size_label: Label = %WindowSize
@onready var view_host: Control = %ViewHost

var _current_stage: int = Stage.PROFILE
var _current_view: FlowView
var _research_log_return_stage: int = -1
var _archive_detail_case_id: String = ""
var _cctv_review_return_stage: int = -1
var _case_index: int = -1
var _processed_opportunities: Dictionary[String, bool] = {}
var _event_rng := RandomNumberGenerator.new()
var _disturbance_notice: DisturbanceNotice
var _focus_before_notice: Control
var _view_process_mode_before_notice: Node.ProcessMode


func _ready() -> void:
	get_viewport().size_changed.connect(_update_window_size)
	_update_window_size()
	if not case_sequence.is_empty():
		_case_index = 0
		current_case = case_sequence[_case_index]
	_validate_case()
	case_runtime = CaseRuntimeState.new(current_case.case_id if current_case != null else "")
	research_archive = ResearchArchiveState.new()
	working_hypotheses = WorkingHypothesisState.new()
	pending_containment = PendingContainmentState.new()
	containment_resolutions = ContainmentResolutionState.new()
	failure_candidates = FailureEventCandidateState.new()
	_event_rng.randomize()
	_show_view(Stage.PROFILE)


func _update_window_size() -> void:
	var window_size: Vector2i = get_window().size
	window_size_label.text = "Window: %d × %d" % [window_size.x, window_size.y]


func _show_view(stage: int, discover_displayed_source: bool = true) -> void:
	if is_instance_valid(_disturbance_notice):
		return
	if is_instance_valid(_current_view):
		view_host.remove_child(_current_view)
		_current_view.queue_free()

	_current_stage = stage
	_current_view = VIEW_SCENES[stage].instantiate()
	view_host.custom_minimum_size.y = 360
	var displayed_source: Resource
	_current_view.research_log_requested.connect(_on_research_log_requested.bind(_current_view, stage))
	if stage not in [Stage.RESEARCH_LOG, Stage.RESEARCH_ARCHIVE_LIST, Stage.RESEARCH_ARCHIVE_DETAIL]:
		_current_view.advance_requested.connect(_on_advance_requested.bind(_current_view))
	if stage == Stage.PROFILE:
		var profile_view: ProfileView = _current_view as ProfileView
		profile_view.setup(current_case.profile_data if current_case != null else null)
		displayed_source = current_case.profile_data if current_case != null else null
	elif stage == Stage.CCTV:
		var cctv_view: CCTVView = _current_view as CCTVView
		cctv_view.setup(current_case.cctv_data if current_case != null else null)
		if _cctv_review_return_stage >= 0:
			cctv_view.get_node("%NextButton").text = "Back: " + Stage.keys()[_cctv_review_return_stage]
		displayed_source = current_case.cctv_data if current_case != null else null
	elif stage == Stage.EXPERIMENT:
		var experiment_view: ExperimentView = _current_view as ExperimentView
		experiment_view.experiment_execution_requested.connect(_on_experiment_execution_requested.bind(experiment_view))
		experiment_view.cctv_review_requested.connect(_on_cctv_review_requested.bind(experiment_view, stage))
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
		containment_view.cctv_review_requested.connect(_on_cctv_review_requested.bind(containment_view, stage))
		containment_view.setup(
			current_case.available_containment_rooms if current_case != null else [],
			case_runtime.get_confirmed_containment_room_id()
		)
		var has_next: bool = _has_next_test_case()
		containment_view.configure_next_action("Next: CASE" if has_next else "No next test case configured", has_next)
	elif stage == Stage.MONITORING:
		var monitoring_view: MonitoringView = _current_view as MonitoringView
		monitoring_view.monitoring_playback_completed.connect(_on_monitoring_playback_completed.bind(monitoring_view))
		monitoring_view.setup(_get_monitoring_outcome(), case_runtime.get_monitoring_result())
	elif stage == Stage.INCIDENT:
		var incident_view: IncidentView = _current_view as IncidentView
		var incident: IncidentData = _get_current_incident_data()
		var broadcast: EmergencyBroadcastData = _get_current_emergency_broadcast() if incident != null else null
		incident_view.setup(incident, _has_valid_broadcast_options(broadcast))
		displayed_source = incident
	elif stage == Stage.BROADCAST:
		var broadcast_view: BroadcastView = _current_view as BroadcastView
		var broadcast: EmergencyBroadcastData = _get_current_emergency_broadcast()
		broadcast_view.broadcast_confirmation_requested.connect(_on_broadcast_confirmation_requested.bind(broadcast_view))
		broadcast_view.setup(
			broadcast,
			case_runtime.get_confirmed_broadcast_id(),
			case_runtime.get_confirmed_broadcast_option_id()
		)
		displayed_source = broadcast
	elif stage == Stage.INCIDENT_RESULT:
		var incident_result_view: IncidentResultView = _current_view as IncidentResultView
		var incident_result: IncidentResultData = _get_current_incident_result()
		incident_result_view.setup(incident_result)
		displayed_source = incident_result
	elif stage == Stage.RESULT:
		var result_view: ResultView = _current_view as ResultView
		result_view.setup(_build_result_summary())
	elif stage == Stage.RESEARCH_LOG:
		var research_log_view: ResearchLogView = _current_view as ResearchLogView
		view_host.custom_minimum_size.y = 660
		research_log_view.advance_requested.connect(_on_research_log_back_requested.bind(research_log_view))
		research_log_view.archive_requested.connect(_on_research_archive_requested.bind(research_log_view))
		research_log_view.hypothesis_add_requested.connect(_on_hypothesis_add_requested.bind(research_log_view))
		research_log_view.hypothesis_update_requested.connect(_on_hypothesis_update_requested.bind(research_log_view))
		research_log_view.hypothesis_remove_requested.connect(_on_hypothesis_remove_requested.bind(research_log_view))
		research_log_view.setup(_build_research_log_snapshot())
	elif stage == Stage.RESEARCH_ARCHIVE_LIST:
		var archive_list: ArchiveListView = _current_view as ArchiveListView
		view_host.custom_minimum_size.y = 660
		archive_list.case_requested.connect(_on_archive_case_requested.bind(archive_list))
		archive_list.advance_requested.connect(_on_archive_list_back_requested.bind(archive_list))
		archive_list.setup(_build_archive_list_snapshot())
	elif stage == Stage.RESEARCH_ARCHIVE_DETAIL:
		var archive_detail: ArchiveDetailView = _current_view as ArchiveDetailView
		view_host.custom_minimum_size.y = 660
		archive_detail.advance_requested.connect(_on_archive_detail_back_requested.bind(archive_detail))
		archive_detail.setup(_build_archive_detail_snapshot(_archive_detail_case_id))
	_refresh_current_environment_conditions()
	_refresh_cctv_condition_observations()
	view_host.add_child(_current_view)
	if discover_displayed_source and displayed_source != null:
		_discover_displayed_research_entry(_current_view, stage, displayed_source)
	if discover_displayed_source and stage == Stage.CCTV:
		_try_process_failure_event_opportunity(_current_view, "cctv:entry")
	elif discover_displayed_source and stage == Stage.CONTAINMENT:
		_try_process_failure_event_opportunity(_current_view, "containment:entry")
	if stage == Stage.CCTV:
		_discover_cctv_condition_observations(_current_view as CCTVView)


func _on_cctv_review_requested(view: FlowView, source_stage: int) -> void:
	if source_stage != _current_stage or source_stage not in [Stage.EXPERIMENT, Stage.CONTAINMENT] or not _is_active_view(view) or not view.is_visible_in_tree() or not _has_current_case_runtime() or case_runtime.get_applied_disturbances().is_empty():
		return
	_cctv_review_return_stage = source_stage
	_show_view(Stage.CCTV, false)


func _on_research_log_requested(view: FlowView, source_stage: int) -> void:
	if not RESEARCH_LOG_STAGES.has(_current_stage) or source_stage != _current_stage or not _is_active_view(view):
		return
	if _current_stage == Stage.RESULT and not case_runtime.has_monitoring_result():
		return
	_research_log_return_stage = _current_stage
	_show_view(Stage.RESEARCH_LOG)


func _on_research_log_back_requested(research_log_view: ResearchLogView) -> void:
	if _current_stage != Stage.RESEARCH_LOG or not _is_active_view(research_log_view):
		return
	if not RESEARCH_LOG_STAGES.has(_research_log_return_stage):
		push_warning("Main: Research Log return stage is invalid: %d." % _research_log_return_stage)
		return
	var return_stage: int = _research_log_return_stage
	_research_log_return_stage = -1
	_show_view(return_stage, false)


func _build_research_log_snapshot() -> ResearchLogView.Snapshot:
	var snapshot := ResearchLogView.Snapshot.new()
	var source_stage: int = _research_log_return_stage if _current_stage == Stage.RESEARCH_LOG else _current_stage
	if source_stage == Stage.CCTV and _cctv_review_return_stage in [Stage.EXPERIMENT, Stage.CONTAINMENT]:
		source_stage = _cctv_review_return_stage
	if not RESEARCH_LOG_STAGES.has(source_stage):
		push_warning("Main: Research Log snapshot source stage is invalid: %d." % source_stage)
		return _order_research_log_snapshot(snapshot)
	var summary: ResultView.Summary = _build_result_summary()
	var research_entries: Array[ResearchEntryData] = _get_valid_research_entries()
	snapshot.case_id = summary.case_id
	snapshot.case_display_name = summary.case_display_name
	if _has_current_case_runtime() and working_hypotheses != null:
		snapshot.hypotheses = working_hypotheses.get_hypotheses(snapshot.case_id)
		snapshot.hypothesis_max_length = WorkingHypothesisState.MAX_TEXT_LENGTH
	_append_disturbance_observations(snapshot, research_entries)
	_append_cctv_condition_observations(snapshot, research_entries)
	var profile: ProfileData = current_case.profile_data if current_case != null else null
	if profile != null:
		_append_source_research_entry(snapshot, research_entries, ResearchEntryData.SourceKind.PROFILE, "PROFILE", profile.profile_id, profile.subject_name, "Classification: %s\n%s" % [profile.classification, profile.basic_description])
	else:
		_append_unavailable_research_entry(snapshot, "PROFILE", "", "Profile")
	if source_stage == Stage.PROFILE:
		return _order_research_log_snapshot(snapshot)
	var cctv: CCTVData = current_case.cctv_data if current_case != null else null
	if cctv != null:
		_append_source_research_entry(snapshot, research_entries, ResearchEntryData.SourceKind.CCTV, "OBSERVATION", cctv.camera_id, "CCTV Observation", cctv.observation_text)
	else:
		_append_unavailable_research_entry(snapshot, "OBSERVATION", "", "CCTV Observation")
	if source_stage == Stage.CCTV:
		return _order_research_log_snapshot(snapshot)
	for index in range(summary.experiment_ids.size()):
		var id: String = summary.experiment_ids[index]
		var experiment: ExperimentData = summary.experiments[index] if index < summary.experiments.size() else null
		if experiment != null:
			_append_source_research_entry(snapshot, research_entries, ResearchEntryData.SourceKind.EXPERIMENT, "EXPERIMENT", id, experiment.display_name, "%s\nResult: %s" % [experiment.description, experiment.result_text])
		else:
			_append_unavailable_research_entry(snapshot, "EXPERIMENT", id, "Executed Experiment")
		_append_experiment_condition_observations(snapshot, research_entries, id)
	if source_stage == Stage.EXPERIMENT:
		return _order_research_log_snapshot(snapshot)
	if not summary.room_id.strip_edges().is_empty():
		if summary.room != null:
			_append_source_research_entry(snapshot, research_entries, ResearchEntryData.SourceKind.CONTAINMENT, "CONTAINMENT", summary.room_id, summary.room.display_name, summary.room.description)
		else:
			_append_unavailable_research_entry(snapshot, "CONTAINMENT", summary.room_id, "Confirmed Containment")
	if source_stage == Stage.CONTAINMENT:
		return _order_research_log_snapshot(snapshot)
	snapshot.monitoring_result = summary.monitoring_result
	var outcome: MonitoringOutcomeData
	if snapshot.monitoring_result == MonitoringOutcomeData.Result.SUCCESS or snapshot.monitoring_result == MonitoringOutcomeData.Result.FAILURE:
		outcome = _get_monitoring_outcome()
		if outcome != null:
			for index in range(outcome.stages.size()):
				var stage: MonitoringStageData = outcome.stages[index]
				if stage != null:
					_append_research_entry(snapshot, "OBSERVATION", outcome.room_id, "Monitoring [%ds]" % stage.time_offset, stage.observation_text)
				else:
					_append_unavailable_research_entry(snapshot, "OBSERVATION", outcome.room_id, "Monitoring stage %d" % (index + 1))
		else:
			_append_unavailable_research_entry(snapshot, "OBSERVATION", summary.room_id, "Monitoring Observations")
	if snapshot.monitoring_result == MonitoringOutcomeData.Result.FAILURE:
		if summary.incident != null:
			_append_source_research_entry(snapshot, research_entries, ResearchEntryData.SourceKind.INCIDENT, "INCIDENT", summary.incident.incident_id, summary.incident.display_name, summary.incident.description)
		else:
			_append_unavailable_research_entry(snapshot, "INCIDENT", outcome.incident_id if outcome != null else "", "Incident")
		if source_stage == Stage.INCIDENT:
			return _order_research_log_snapshot(snapshot)
		if summary.broadcast != null:
			_append_source_research_entry(snapshot, research_entries, ResearchEntryData.SourceKind.BROADCAST, "INCIDENT", summary.broadcast.broadcast_id, summary.broadcast.display_name, summary.broadcast.prompt_text)
		else:
			var broadcast_id: String = summary.incident.broadcast_id if summary.incident != null else case_runtime.get_confirmed_broadcast_id()
			_append_unavailable_research_entry(snapshot, "INCIDENT", broadcast_id, "Emergency Broadcast")
		if case_runtime.has_confirmed_broadcast_option():
			if summary.option != null:
				_append_source_research_entry(snapshot, research_entries, ResearchEntryData.SourceKind.BROADCAST_OPTION, "INCIDENT", summary.option.option_id, "Selected Response", summary.option.display_text)
			else:
				_append_unavailable_research_entry(snapshot, "INCIDENT", case_runtime.get_confirmed_broadcast_option_id(), "Selected Response")
			if source_stage != Stage.BROADCAST:
				if summary.incident_result != null:
					_append_source_research_entry(snapshot, research_entries, ResearchEntryData.SourceKind.INCIDENT_RESULT, "INCIDENT", summary.incident_result.result_id, summary.incident_result.display_name, summary.incident_result.description)
				else:
					_append_unavailable_research_entry(snapshot, "INCIDENT", summary.option.result_id if summary.option != null else "", "Incident Result")
	return _order_research_log_snapshot(snapshot)


func _can_edit_hypotheses(case_id: String, view: ResearchLogView) -> bool:
	return _current_stage == Stage.RESEARCH_LOG and _is_active_view(view) and view.is_visible_in_tree() and _has_current_case_runtime() and working_hypotheses != null and case_id == current_case.case_id and view.get_hypothesis_case_id() == case_id


func _on_hypothesis_add_requested(case_id: String, text: String, view: ResearchLogView) -> void:
	if not _can_edit_hypotheses(case_id, view):
		return
	var approved: bool = not working_hypotheses.add_hypothesis(case_id, text).is_empty()
	view.show_hypothesis_request_result(approved, working_hypotheses.get_hypotheses(case_id))


func _on_hypothesis_update_requested(case_id: String, id: String, text: String, view: ResearchLogView) -> void:
	if not _can_edit_hypotheses(case_id, view):
		return
	var approved: bool = working_hypotheses.update_hypothesis(case_id, id, text)
	view.show_hypothesis_request_result(approved, working_hypotheses.get_hypotheses(case_id))


func _on_hypothesis_remove_requested(case_id: String, id: String, view: ResearchLogView) -> void:
	if not _can_edit_hypotheses(case_id, view):
		return
	var approved: bool = working_hypotheses.remove_hypothesis(case_id, id)
	view.show_hypothesis_request_result(approved, working_hypotheses.get_hypotheses(case_id), id)


func _on_research_archive_requested(view: ResearchLogView) -> void:
	if _current_stage != Stage.RESEARCH_LOG or not _is_active_view(view) or not view.is_visible_in_tree() or not _has_current_case_runtime() or not RESEARCH_LOG_STAGES.has(_research_log_return_stage) or view.get_hypothesis_case_id() != current_case.case_id:
		return
	_show_view(Stage.RESEARCH_ARCHIVE_LIST, false)


func _on_archive_case_requested(case_id: String, view: ArchiveListView) -> void:
	if _current_stage != Stage.RESEARCH_ARCHIVE_LIST or not _is_active_view(view) or not view.is_visible_in_tree() or research_archive == null or not research_archive.get_archived_case_ids().has(case_id):
		return
	if _find_archive_case(case_id) == null:
		return
	_archive_detail_case_id = case_id
	_show_view(Stage.RESEARCH_ARCHIVE_DETAIL, false)


func _on_archive_list_back_requested(view: ArchiveListView) -> void:
	if _current_stage != Stage.RESEARCH_ARCHIVE_LIST or not _is_active_view(view) or not view.is_visible_in_tree() or not RESEARCH_LOG_STAGES.has(_research_log_return_stage):
		return
	_archive_detail_case_id = ""
	_show_view(Stage.RESEARCH_LOG, false)


func _on_archive_detail_back_requested(view: ArchiveDetailView) -> void:
	if _current_stage != Stage.RESEARCH_ARCHIVE_DETAIL or not _is_active_view(view) or not view.is_visible_in_tree():
		return
	_archive_detail_case_id = ""
	_show_view(Stage.RESEARCH_ARCHIVE_LIST, false)


func _find_archive_case(case_id: String) -> CaseData:
	var matches: Array[CaseData] = []
	for data: CaseData in case_sequence:
		if data != null and data.case_id == case_id:
			matches.append(data)
	# Single-Case debug/standalone Main has no configured sequence.
	if case_sequence.is_empty() and current_case != null and current_case.case_id == case_id:
		matches.append(current_case)
	if case_id.strip_edges().is_empty() or matches.size() != 1:
		push_warning("Main: Archive CaseData mapping unavailable or duplicate for case_id %s." % case_id)
		return null
	return matches[0]


func _build_archive_list_snapshot() -> ArchiveListView.Snapshot:
	var snapshot := ArchiveListView.Snapshot.new()
	if research_archive == null:
		return snapshot
	for case_id: String in research_archive.get_archived_case_ids():
		var item := ArchiveListView.CaseSummary.new()
		item.case_id = case_id
		var data: CaseData = _find_archive_case(case_id)
		item.available = data != null
		item.display_name = data.display_name if data != null else "[Unavailable]"
		item.research_count = research_archive.get_discovered_entry_ids(case_id).size()
		item.hypothesis_count = working_hypotheses.get_hypotheses(case_id).size() if working_hypotheses != null else 0
		snapshot.cases.append(item)
	return snapshot


func _build_archive_detail_snapshot(case_id: String) -> ArchiveDetailView.Snapshot:
	var snapshot := ArchiveDetailView.Snapshot.new()
	snapshot.case_id = case_id
	if research_archive == null or not research_archive.get_archived_case_ids().has(case_id):
		return snapshot
	var data: CaseData = _find_archive_case(case_id)
	snapshot.display_name = data.display_name if data != null else "[Unavailable]"
	var valid_entries: Array[ResearchEntryData] = []
	if data != null:
		valid_entries = _get_valid_research_entries(data)
	for entry_id: String in research_archive.get_discovered_entry_ids(case_id):
		var row := ArchiveDetailView.ResearchEntry.new()
		row.entry_id = entry_id
		row.title = "[Unavailable Research Entry]"
		for entry: ResearchEntryData in valid_entries:
			if entry.entry_id == entry_id:
				row.category = _research_category(entry.source_kind)
				row.source_id = entry.source_id
				row.title = entry.title
				row.body_text = entry.body_text
				break
		if row.category.is_empty():
			push_warning("Main: Archive ResearchEntry unavailable for %s/%s." % [case_id, entry_id])
		snapshot.research_entries.append(row)
	if working_hypotheses != null:
		snapshot.hypotheses = working_hypotheses.get_hypotheses(case_id)
	return snapshot


func _research_category(source_kind: int) -> String:
	match source_kind:
		ResearchEntryData.SourceKind.PROFILE:
			return "PROFILE"
		ResearchEntryData.SourceKind.CCTV, ResearchEntryData.SourceKind.DISTURBANCE_REACTION, ResearchEntryData.SourceKind.CCTV_CONDITION_OBSERVATION:
			return "OBSERVATION"
		ResearchEntryData.SourceKind.EXPERIMENT, ResearchEntryData.SourceKind.EXPERIMENT_CONDITION_OBSERVATION:
			return "EXPERIMENT"
		ResearchEntryData.SourceKind.CONTAINMENT:
			return "CONTAINMENT"
		ResearchEntryData.SourceKind.INCIDENT, ResearchEntryData.SourceKind.BROADCAST, ResearchEntryData.SourceKind.BROADCAST_OPTION, ResearchEntryData.SourceKind.INCIDENT_RESULT:
			return "INCIDENT"
	return ""


func _get_valid_research_entries(case_data: CaseData = null) -> Array[ResearchEntryData]:
	var valid_entries: Array[ResearchEntryData] = []
	var source_case: CaseData = case_data if case_data != null else current_case
	if source_case == null:
		return valid_entries
	var id_counts: Dictionary[String, int] = {}
	var source_counts: Dictionary[String, int] = {}
	for entry: ResearchEntryData in source_case.research_entries:
		if entry == null:
			continue
		if not entry.entry_id.strip_edges().is_empty():
			id_counts[entry.entry_id] = id_counts.get(entry.entry_id, 0) + 1
		if ResearchEntryData.SourceKind.values().has(entry.source_kind) and not entry.source_id.strip_edges().is_empty():
			var key: String = "%d:%s" % [entry.source_kind, entry.source_id]
			source_counts[key] = source_counts.get(key, 0) + 1
	for entry: ResearchEntryData in source_case.research_entries:
		if entry == null:
			push_warning("Main: ResearchEntryData is missing; using derived text.")
			continue
		var valid: bool = not entry.entry_id.strip_edges().is_empty() and not entry.source_id.strip_edges().is_empty() and ResearchEntryData.SourceKind.values().has(entry.source_kind)
		if not valid:
			push_warning("Main: ResearchEntryData has an invalid entry_id, source_id or source_kind; using derived text.")
		if id_counts.get(entry.entry_id, 0) > 1:
			push_warning("Main: duplicate ResearchEntryData.entry_id %s; using derived text." % entry.entry_id)
			valid = false
		if source_counts.get("%d:%s" % [entry.source_kind, entry.source_id], 0) > 1:
			push_warning("Main: duplicate ResearchEntryData source mapping %d/%s; using derived text." % [entry.source_kind, entry.source_id])
			valid = false
		if valid:
			valid_entries.append(entry)
	return valid_entries


func _find_research_entry(entries: Array[ResearchEntryData], source_kind: int, source_id: String) -> ResearchEntryData:
	for entry: ResearchEntryData in entries:
		if entry.source_kind == source_kind and entry.source_id == source_id:
			return entry
	return null


func _append_source_research_entry(snapshot: ResearchLogView.Snapshot, entries: Array[ResearchEntryData], source_kind: int, category: String, source_id: String, title: String, body_text: String) -> void:
	var authored: ResearchEntryData = _find_research_entry(entries, source_kind, source_id)
	if authored != null and (not _has_current_case_runtime() or not case_runtime.has_discovered_research_entry(authored.entry_id)):
		authored = null
	_append_research_entry(snapshot, _research_category(source_kind) if authored != null else category, source_id, authored.title if authored != null else title, authored.body_text if authored != null else body_text, source_kind)


func _has_current_case_runtime() -> bool:
	return current_case != null and case_runtime != null and not current_case.case_id.strip_edges().is_empty() and not current_case.display_name.strip_edges().is_empty() and case_runtime.case_id == current_case.case_id


func _try_discover_research_entry(source_kind: int, source_id: String) -> bool:
	if not _has_current_case_runtime() or source_id.strip_edges().is_empty():
		return false
	case_runtime.try_observe_research_source(source_kind, source_id)
	var authored: ResearchEntryData = _find_research_entry(_get_valid_research_entries(), source_kind, source_id)
	return authored != null and case_runtime.try_discover_research_entry(authored.entry_id)


func _discover_displayed_research_entry(view: FlowView, stage: int, source: Resource) -> void:
	if stage != _current_stage or not _is_active_view(view) or not view.is_visible_in_tree() or not _has_current_case_runtime():
		return
	match stage:
		Stage.PROFILE:
			var profile: ProfileData = source as ProfileData
			if view is ProfileView and profile != null and profile == current_case.profile_data and not profile.subject_name.strip_edges().is_empty() and not profile.classification.strip_edges().is_empty() and not profile.basic_description.strip_edges().is_empty():
				_try_discover_research_entry(ResearchEntryData.SourceKind.PROFILE, profile.profile_id)
		Stage.CCTV:
			var cctv: CCTVData = source as CCTVData
			if view is CCTVView and cctv != null and cctv == current_case.cctv_data and not cctv.observation_text.strip_edges().is_empty():
				_try_discover_research_entry(ResearchEntryData.SourceKind.CCTV, cctv.camera_id)
		Stage.INCIDENT:
			var incident: IncidentData = source as IncidentData
			if view is IncidentView and incident != null and current_case.incidents.has(incident) and case_runtime.get_monitoring_result() == MonitoringOutcomeData.Result.FAILURE and not incident.display_name.strip_edges().is_empty() and not incident.description.strip_edges().is_empty():
				_try_discover_research_entry(ResearchEntryData.SourceKind.INCIDENT, incident.incident_id)
		Stage.BROADCAST:
			var broadcast: EmergencyBroadcastData = source as EmergencyBroadcastData
			if view is BroadcastView and broadcast != null and current_case.emergency_broadcasts.has(broadcast) and case_runtime.get_monitoring_result() == MonitoringOutcomeData.Result.FAILURE and not broadcast.display_name.strip_edges().is_empty() and not broadcast.prompt_text.strip_edges().is_empty() and _has_valid_broadcast_options(broadcast):
				_try_discover_research_entry(ResearchEntryData.SourceKind.BROADCAST, broadcast.broadcast_id)
		Stage.INCIDENT_RESULT:
			var incident_result: IncidentResultData = source as IncidentResultData
			if view is IncidentResultView and incident_result != null and current_case.incident_results.has(incident_result) and case_runtime.get_monitoring_result() == MonitoringOutcomeData.Result.FAILURE and case_runtime.has_confirmed_broadcast_option() and not incident_result.display_name.strip_edges().is_empty() and not incident_result.description.strip_edges().is_empty():
				_try_discover_research_entry(ResearchEntryData.SourceKind.INCIDENT_RESULT, incident_result.result_id)


func _append_research_entry(snapshot: ResearchLogView.Snapshot, category: String, source_id: String, title: String, body_text: String, source_kind: int = -1) -> void:
	snapshot.entries.append(ResearchLogView.Entry.new(category, source_id, title, body_text, source_kind))


func _append_unavailable_research_entry(snapshot: ResearchLogView.Snapshot, category: String, source_id: String, title: String) -> void:
	push_warning("Main: Research Log %s is unavailable for source ID %s." % [title, source_id])
	_append_research_entry(snapshot, category, source_id, title, "[Unavailable]")


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
	if _current_stage != Stage.BROADCAST or not _is_active_view(broadcast_view) or not _has_current_case_runtime():
		return
	var broadcast: EmergencyBroadcastData = _get_current_emergency_broadcast()
	if not case_runtime.has_confirmed_broadcast_option() and broadcast != null and broadcast.broadcast_id == broadcast_id:
		var option: BroadcastOptionData = _get_broadcast_option(broadcast, option_id)
		if _get_incident_result_for_option(option) != null:
			if case_runtime.try_confirm_broadcast_option(broadcast_id, option_id):
				_try_discover_research_entry(ResearchEntryData.SourceKind.BROADCAST_OPTION, option_id)
	broadcast_view.update_confirmation_state(case_runtime.get_confirmed_broadcast_id(), case_runtime.get_confirmed_broadcast_option_id())


func _is_active_view(view: FlowView) -> bool:
	return not is_instance_valid(_disturbance_notice) and is_instance_valid(view) and view == _current_view and view.is_inside_tree() and not view.is_queued_for_deletion()


func _on_advance_requested(view: FlowView) -> void:
	if not _is_active_view(view):
		return
	if _current_stage == Stage.CCTV and _cctv_review_return_stage in [Stage.EXPERIMENT, Stage.CONTAINMENT]:
		var return_stage: int = _cctv_review_return_stage
		_cctv_review_return_stage = -1
		_show_view(return_stage, false)
		return
	if _current_stage == Stage.CONTAINMENT:
		_handoff_to_next_case()
		return
	if _current_stage == Stage.INCIDENT and not _has_valid_broadcast_options(_get_current_emergency_broadcast()):
		return
	if (_current_stage == Stage.BROADCAST or _current_stage == Stage.INCIDENT_RESULT) and _get_current_incident_result() == null:
		return
	var next_stage: int = _get_next_stage(_current_stage)
	if next_stage != -1:
		_show_view(next_stage)
		if next_stage == Stage.RESULT:
			_archive_case_discoveries()


func _archive_case_discoveries() -> void:
	if not _has_current_case_runtime():
		push_warning("Main: Research Archive requires matching current Case and Runtime case_id.")
		return
	if _current_stage != Stage.RESULT or not case_runtime.has_monitoring_result():
		return
	_merge_current_case_discoveries()


func _merge_current_case_discoveries() -> void:
	var valid_ids: Array[String] = []
	for entry: ResearchEntryData in _get_valid_research_entries():
		valid_ids.append(entry.entry_id)
	var discoveries: Array[String] = []
	for entry_id: String in case_runtime.get_discovered_research_entry_ids():
		if valid_ids.has(entry_id):
			discoveries.append(entry_id)
		else:
			push_warning("Main: Research Archive rejected invalid discovered entry_id %s." % entry_id)
	research_archive.merge_case_discoveries(current_case.case_id, discoveries)


func _has_next_test_case() -> bool:
	if _case_index < 0 or _case_index + 1 >= case_sequence.size() or case_sequence[_case_index] != current_case:
		return false
	var next_case: CaseData = case_sequence[_case_index + 1]
	return next_case != null and not next_case.case_id.strip_edges().is_empty() and not next_case.display_name.strip_edges().is_empty() and next_case.case_id != current_case.case_id and not pending_containment.has_pending(next_case.case_id) and not containment_resolutions.has_resolution(next_case.case_id)


func _handoff_to_next_case() -> void:
	if _current_stage != Stage.CONTAINMENT or not _is_active_view(_current_view):
		return
	if not _has_current_case_runtime() or not case_runtime.has_confirmed_containment() or not pending_containment.has_pending(current_case.case_id) or pending_containment.get_pending_room_id(current_case.case_id) != case_runtime.get_confirmed_containment_room_id():
		push_warning("Main: Case handoff requires a matching current Case, Runtime and Pending containment decision.")
		return
	var valid_room: bool = false
	for room: ContainmentData in current_case.available_containment_rooms:
		if room != null and room.room_id == case_runtime.get_confirmed_containment_room_id():
			valid_room = true
			break
	if not valid_room:
		push_warning("Main: Case handoff requires a confirmed Room belonging to the current Case.")
		return
	if not _has_next_test_case():
		push_warning("Main: No next test case configured; retaining current Runtime, Pending and Research.")
		return
	if not _try_resolve_current_pending():
		return
	_merge_current_case_discoveries()
	_case_index += 1
	current_case = case_sequence[_case_index]
	case_runtime = CaseRuntimeState.new(current_case.case_id)
	_research_log_return_stage = -1
	_cctv_review_return_stage = -1
	_processed_opportunities.clear()
	_show_view(Stage.PROFILE)


func _try_resolve_current_pending() -> bool:
	var case_id: String = current_case.case_id
	var room_id: String = pending_containment.get_pending_room_id(case_id)
	if containment_resolutions.has_resolution(case_id):
		push_warning("Main: hidden containment resolution already exists; retaining Pending.")
		return false
	var matches: Array[MonitoringOutcomeData] = []
	for outcome: MonitoringOutcomeData in current_case.containment_outcomes:
		if outcome != null and outcome.room_id == room_id:
			matches.append(outcome)
	if matches.size() != 1:
		push_warning("Main: hidden resolution requires one matching Outcome; retaining Pending.")
		return false
	var outcome: MonitoringOutcomeData = matches[0]
	var result: MonitoringOutcomeData.Result = outcome.final_result
	var incident_id: String = outcome.incident_id if result == MonitoringOutcomeData.Result.FAILURE else ""
	if result != MonitoringOutcomeData.Result.SUCCESS and result != MonitoringOutcomeData.Result.FAILURE or (result == MonitoringOutcomeData.Result.FAILURE and (incident_id.strip_edges().is_empty() or failure_candidates.has_candidate(case_id))):
		push_warning("Main: invalid hidden resolution or existing failure candidate; retaining Pending.")
		return false
	if not containment_resolutions.try_record_resolution(case_id, room_id, result, incident_id):
		return false
	if result == MonitoringOutcomeData.Result.FAILURE:
		failure_candidates.try_add_candidate(case_id, incident_id, _event_rng.randi_range(PROTOTYPE_DISTURBANCE_THRESHOLD.x, PROTOTYPE_DISTURBANCE_THRESHOLD.y))
	pending_containment.remove_pending(case_id)
	return true


func _try_process_failure_event_opportunity(view: FlowView, key: String) -> void:
	if not _is_active_view(view) or not view.is_visible_in_tree() or not _has_current_case_runtime() or _case_index < 0 or _case_index >= case_sequence.size() or case_sequence[_case_index] != current_case or _processed_opportunities.has(key):
		return
	var eligible: bool = (_current_stage == Stage.CCTV and key == "cctv:entry") or (_current_stage == Stage.CONTAINMENT and key == "containment:entry")
	if _current_stage == Stage.EXPERIMENT and key.begins_with("experiment:"):
		var experiment_id: String = key.trim_prefix("experiment:")
		eligible = case_runtime.has_executed_experiment(experiment_id)
	if not eligible:
		return
	_processed_opportunities[key] = true
	for source_case_id: String in failure_candidates.advance_opportunity(current_case.case_id):
		var candidate: Dictionary = failure_candidates.get_candidate(source_case_id)
		var resolution: Dictionary = containment_resolutions.get_resolution(source_case_id)
		if resolution.get("result", MonitoringOutcomeData.Result.UNDEFINED) != MonitoringOutcomeData.Result.FAILURE or resolution.get("incident_id", "") != candidate.incident_id:
			push_warning("Main: failure candidate does not match hidden resolution; retaining candidate.")
			continue
		var source_case: CaseData = _find_failure_source_case(source_case_id)
		if source_case == null:
			continue
		var incidents: Array[IncidentData] = []
		for incident: IncidentData in source_case.incidents:
			if incident != null and incident.incident_id == candidate.incident_id:
				incidents.append(incident)
		var disturbance: EnvironmentalDisturbanceData = incidents[0].environmental_disturbance if incidents.size() == 1 else null
		if disturbance == null or disturbance.disturbance_id.strip_edges().is_empty() or disturbance.display_name.strip_edges().is_empty() or disturbance.notice_text.strip_edges().is_empty() or disturbance.condition_change_text.strip_edges().is_empty():
			push_warning("Main: failure candidate has no unique valid environmental disturbance; retaining candidate.")
			continue
		var reaction: CaseDisturbanceReactionData = _find_disturbance_reaction(disturbance.disturbance_id)
		if not case_runtime.try_apply_disturbance(disturbance.disturbance_id, reaction.reaction_id if reaction != null else ""):
			continue
		failure_candidates.try_mark_disturbance_triggered(source_case_id)
		_refresh_current_environment_conditions()
		_show_disturbance_notice(disturbance, reaction)
		if reaction != null:
			_try_discover_research_entry(ResearchEntryData.SourceKind.DISTURBANCE_REACTION, reaction.reaction_id)
		break


func _refresh_current_environment_conditions() -> void:
	if _current_view is CCTVView or _current_view is ExperimentView or _current_view is ContainmentView:
		var summary: EnvironmentConditions.Summary = _build_environment_summary()
		if _current_view is ExperimentView:
			view_host.custom_minimum_size.y = 580 if not summary.entries.is_empty() else 400
		else:
			view_host.custom_minimum_size.y = (500 if _current_view is CCTVView else 550) if not summary.entries.is_empty() else 360
		_current_view.set_environment_conditions(summary)


func _build_environment_summary() -> EnvironmentConditions.Summary:
	var summary := EnvironmentConditions.Summary.new()
	if not _has_current_case_runtime():
		return summary
	var displayed_ids: Array[String] = []
	for record: Dictionary in case_runtime.get_applied_disturbances():
		var id: String = record.disturbance_id
		if displayed_ids.has(id):
			continue
		displayed_ids.append(id)
		var data: EnvironmentalDisturbanceData = _find_environment_condition_data(id)
		summary.entries.append(EnvironmentConditions.Condition.new(
			id, data.display_name if data != null else "[Unavailable]",
			data.condition_change_text if data != null else "[Unavailable]"
		))
	return summary


func _get_active_cctv_condition_observations() -> Array[CCTVConditionObservationData]:
	var result: Array[CCTVConditionObservationData] = []
	if not _has_current_case_runtime() or current_case.cctv_data == null or current_case.cctv_data.camera_id.strip_edges().is_empty():
		return result
	var observations: Array[CCTVConditionObservationData] = current_case.cctv_condition_observations
	var id_counts: Dictionary[String, int] = {}
	for data: CCTVConditionObservationData in observations:
		if data != null:
			id_counts[data.observation_id] = id_counts.get(data.observation_id, 0) + 1
	var applied_ids: Array[String] = []
	for record: Dictionary in case_runtime.get_applied_disturbances():
		if applied_ids.has(record.disturbance_id):
			continue
		applied_ids.append(record.disturbance_id)
		var matches: Array[CCTVConditionObservationData] = []
		for data: CCTVConditionObservationData in observations:
			if data != null and data.cctv_id == current_case.cctv_data.camera_id and data.disturbance_id == record.disturbance_id:
				matches.append(data)
		# This prototype authors one combined observation per CCTV/condition pair.
		if matches.size() > 1:
			push_warning("Main: duplicate CCTV condition mapping %s/%s; omitting observations." % [current_case.cctv_data.camera_id, record.disturbance_id])
			continue
		if matches.is_empty():
			continue
		var data: CCTVConditionObservationData = matches[0]
		if data.observation_id.strip_edges().is_empty() or data.disturbance_id.strip_edges().is_empty() or id_counts.get(data.observation_id, 0) != 1 or data.display_name.strip_edges().is_empty() or data.observation_text.strip_edges().is_empty():
			push_warning("Main: invalid CCTV condition observation ID/content; omitting observation.")
			continue
		result.append(data)
	return result


func _refresh_cctv_condition_observations() -> void:
	if not _current_view is CCTVView or is_instance_valid(_disturbance_notice):
		return
	var snapshot := CCTVView.ConditionSnapshot.new()
	for data: CCTVConditionObservationData in _get_active_cctv_condition_observations():
		snapshot.entries.append(CCTVView.ConditionObservation.new(data.observation_id, data.display_name, data.observation_text))
	(_current_view as CCTVView).set_condition_observations(snapshot)
	if not snapshot.entries.is_empty():
		view_host.custom_minimum_size.y = 660


func _discover_cctv_condition_observations(view: CCTVView) -> void:
	if _current_stage != Stage.CCTV or not _is_active_view(view) or not view.is_visible_in_tree() or not _has_current_case_runtime():
		return
	if current_case.cctv_data == null or not view.is_displaying_cctv(current_case.cctv_data):
		return
	var displayed_ids: Array[String] = view.get_displayed_condition_observation_ids()
	for data: CCTVConditionObservationData in _get_active_cctv_condition_observations():
		if displayed_ids.has(data.observation_id) and not case_runtime.has_observed_research_source(ResearchEntryData.SourceKind.CCTV_CONDITION_OBSERVATION, data.observation_id):
			_try_discover_research_entry(ResearchEntryData.SourceKind.CCTV_CONDITION_OBSERVATION, data.observation_id)


func _append_cctv_condition_observations(snapshot: ResearchLogView.Snapshot, entries: Array[ResearchEntryData]) -> void:
	if not _has_current_case_runtime():
		return
	for data: CCTVConditionObservationData in _get_active_cctv_condition_observations():
		if case_runtime.has_observed_research_source(ResearchEntryData.SourceKind.CCTV_CONDITION_OBSERVATION, data.observation_id):
			_append_source_research_entry(snapshot, entries, ResearchEntryData.SourceKind.CCTV_CONDITION_OBSERVATION, "OBSERVATION", data.observation_id, data.display_name, data.observation_text)


func _order_research_log_snapshot(snapshot: ResearchLogView.Snapshot) -> ResearchLogView.Snapshot:
	if not _has_current_case_runtime():
		return snapshot
	var history: Array[Dictionary] = case_runtime.get_observed_research_sources()
	var has_condition_observation: bool = false
	for record: Dictionary in history:
		if record.source_kind in [ResearchEntryData.SourceKind.CCTV_CONDITION_OBSERVATION, ResearchEntryData.SourceKind.EXPERIMENT_CONDITION_OBSERVATION]:
			has_condition_observation = true
	if not has_condition_observation:
		return snapshot
	var ordered: Array[ResearchLogView.Entry] = []
	for record: Dictionary in history:
		for entry: ResearchLogView.Entry in snapshot.entries:
			if entry.source_kind == record.source_kind and entry.source_id == record.source_id:
				ordered.append(entry)
	for entry: ResearchLogView.Entry in snapshot.entries:
		if not ordered.has(entry):
			ordered.append(entry)
	snapshot.entries = ordered
	return snapshot


func _find_environment_condition_data(disturbance_id: String) -> EnvironmentalDisturbanceData:
	var cases: Array[CaseData] = case_sequence.duplicate()
	if current_case != null and not cases.has(current_case):
		cases.append(current_case)
	var found: EnvironmentalDisturbanceData
	for data: CaseData in cases:
		if data == null:
			continue
		for incident: IncidentData in data.incidents:
			var candidate: EnvironmentalDisturbanceData = incident.environmental_disturbance if incident != null else null
			if candidate == null or candidate.disturbance_id != disturbance_id:
				continue
			# Identical authored definitions may be reused by multiple Incidents/Cases.
			if candidate.display_name.strip_edges().is_empty() or candidate.condition_change_text.strip_edges().is_empty() or (found != null and (found.display_name != candidate.display_name or found.condition_change_text != candidate.condition_change_text)):
				push_warning("Main: active environment definition is invalid or conflicting for %s; displaying [Unavailable]." % disturbance_id)
				return null
			found = candidate
	if found == null:
		push_warning("Main: active environment definition is missing for %s; displaying [Unavailable]." % disturbance_id)
	return found


func _find_failure_source_case(case_id: String) -> CaseData:
	var matches: Array[CaseData] = []
	for data: CaseData in case_sequence:
		if data != null and data.case_id == case_id:
			matches.append(data)
	if matches.size() == 1:
		return matches[0]
	push_warning("Main: failure source Case is missing or ambiguous; retaining candidate.")
	return null


func _find_disturbance_reaction(disturbance_id: String) -> CaseDisturbanceReactionData:
	var matches: Array[CaseDisturbanceReactionData] = []
	for reaction: CaseDisturbanceReactionData in current_case.disturbance_reactions:
		if reaction != null and reaction.disturbance_id == disturbance_id:
			matches.append(reaction)
	if matches.is_empty():
		return null
	if matches.size() != 1:
		push_warning("Main: ambiguous disturbance reaction; omitting creature observation.")
		return null
	var reaction: CaseDisturbanceReactionData = matches[0]
	var id_count: int = 0
	for other: CaseDisturbanceReactionData in current_case.disturbance_reactions:
		if other != null and other.reaction_id == reaction.reaction_id:
			id_count += 1
	if id_count != 1 or reaction.reaction_id.strip_edges().is_empty() or reaction.display_name.strip_edges().is_empty() or reaction.observation_text.strip_edges().is_empty():
		push_warning("Main: invalid disturbance reaction; omitting creature observation.")
		return null
	return reaction


func _append_disturbance_observations(snapshot: ResearchLogView.Snapshot, entries: Array[ResearchEntryData]) -> void:
	if not _has_current_case_runtime():
		return
	for record: Dictionary in case_runtime.get_applied_disturbances():
		if record.reaction_id.is_empty():
			continue
		var reaction: CaseDisturbanceReactionData = _find_disturbance_reaction(record.disturbance_id)
		if reaction != null and reaction.reaction_id == record.reaction_id:
			_append_source_research_entry(snapshot, entries, ResearchEntryData.SourceKind.DISTURBANCE_REACTION, "OBSERVATION", reaction.reaction_id, reaction.display_name, reaction.observation_text)


func _show_disturbance_notice(disturbance: EnvironmentalDisturbanceData, reaction: CaseDisturbanceReactionData) -> void:
	_focus_before_notice = get_viewport().gui_get_focus_owner()
	_view_process_mode_before_notice = view_host.process_mode
	view_host.process_mode = Node.PROCESS_MODE_DISABLED
	_disturbance_notice = DISTURBANCE_NOTICE_SCENE.instantiate()
	_disturbance_notice.setup(disturbance, reaction)
	_disturbance_notice.dismissed.connect(_on_disturbance_dismissed.bind(_disturbance_notice))
	add_child(_disturbance_notice)


func _on_disturbance_dismissed(notice: DisturbanceNotice) -> void:
	if not is_instance_valid(notice) or notice != _disturbance_notice or not notice.is_inside_tree() or notice.is_queued_for_deletion():
		return
	remove_child(notice)
	notice.queue_free()
	_disturbance_notice = null
	view_host.process_mode = _view_process_mode_before_notice
	if is_instance_valid(_focus_before_notice) and _focus_before_notice.is_inside_tree():
		_focus_before_notice.grab_focus()
	_focus_before_notice = null
	_refresh_cctv_condition_observations()
	if _current_view is CCTVView:
		_discover_cctv_condition_observations(_current_view as CCTVView)


func _get_next_stage(stage: int) -> int:
	match stage:
		Stage.PROFILE:
			return Stage.CCTV
		Stage.CCTV:
			return Stage.EXPERIMENT
		Stage.EXPERIMENT:
			return Stage.CONTAINMENT
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
	if _current_stage != Stage.EXPERIMENT or not _is_active_view(experiment_view) or not experiment_view.is_visible_in_tree() or not _has_current_case_runtime():
		return
	var source: ExperimentData
	for experiment: ExperimentData in current_case.available_experiments:
		if experiment != null and not experiment_id.strip_edges().is_empty() and experiment.experiment_id == experiment_id:
			source = experiment
			break
	var limit: int = current_case.experiment_limit
	# Freeze the display values before recording, discovery and this action's opportunity.
	# The existing ID-only approval API remains compatible; additional observations
	# require the actual selected Resource to be displayed in this active View.
	var snapshot := ExperimentView.ConditionSnapshot.new()
	var condition_ids: Array[String] = []
	if source != null and case_runtime.can_execute_experiment(experiment_id, limit) and experiment_view.is_displaying_selected_experiment(source):
		for data: ExperimentConditionObservationData in _get_active_experiment_condition_observations(experiment_id):
			var condition: EnvironmentalDisturbanceData = _find_environment_condition_data(data.disturbance_id)
			snapshot.entries.append(ExperimentView.ConditionObservation.new(data.observation_id, data.display_name, data.observation_text, condition.display_name if condition != null else "[Unavailable]", condition.condition_change_text if condition != null else "[Unavailable]"))
			condition_ids.append(data.observation_id)
	var approved: bool = source != null and case_runtime.try_record_experiment_execution(experiment_id, limit, condition_ids)
	var displayed_ids: Array[String] = experiment_view.show_execution_result(experiment_id, approved, snapshot)
	if approved:
		_try_discover_research_entry(ResearchEntryData.SourceKind.EXPERIMENT, experiment_id)
		for id: String in displayed_ids:
			_try_discover_research_entry(ResearchEntryData.SourceKind.EXPERIMENT_CONDITION_OBSERVATION, id)
	experiment_view.update_execution_state(
		case_runtime.get_experiment_execution_history(),
		case_runtime.get_remaining_experiment_count(limit),
		limit
	)
	if approved:
		_try_process_failure_event_opportunity(experiment_view, "experiment:" + experiment_id)


func _get_active_experiment_condition_observations(experiment_id: String) -> Array[ExperimentConditionObservationData]:
	var result: Array[ExperimentConditionObservationData] = []
	if not _has_current_case_runtime():
		return result
	var experiment_count: int = 0
	for experiment: ExperimentData in current_case.available_experiments:
		if experiment != null and experiment.experiment_id == experiment_id:
			experiment_count += 1
	if experiment_count != 1:
		push_warning("Main: Experiment condition observation requires a unique Experiment ID; omitting observations.")
		return result
	var observations: Array[ExperimentConditionObservationData] = current_case.experiment_condition_observations
	var id_counts: Dictionary[String, int] = {}
	for data: ExperimentConditionObservationData in observations:
		if data != null:
			id_counts[data.observation_id] = id_counts.get(data.observation_id, 0) + 1
	var applied_ids: Array[String] = []
	for record: Dictionary in case_runtime.get_applied_disturbances():
		if applied_ids.has(record.disturbance_id):
			continue
		applied_ids.append(record.disturbance_id)
		var matches: Array[ExperimentConditionObservationData] = []
		for data: ExperimentConditionObservationData in observations:
			if data != null and data.experiment_id == experiment_id and data.disturbance_id == record.disturbance_id:
				matches.append(data)
		if matches.size() > 1:
			push_warning("Main: duplicate Experiment condition mapping %s/%s; omitting observations." % [experiment_id, record.disturbance_id])
			continue
		if matches.is_empty():
			continue
		var data: ExperimentConditionObservationData = matches[0]
		if data.observation_id.strip_edges().is_empty() or data.disturbance_id.strip_edges().is_empty() or id_counts.get(data.observation_id, 0) != 1 or data.display_name.strip_edges().is_empty() or data.observation_text.strip_edges().is_empty():
			push_warning("Main: invalid Experiment condition observation ID/content; omitting observation.")
			continue
		result.append(data)
	return result


func _append_experiment_condition_observations(snapshot: ResearchLogView.Snapshot, entries: Array[ResearchEntryData], experiment_id: String) -> void:
	if not _has_current_case_runtime():
		return
	# Read execution IDs, never the currently active environment.
	for id: String in case_runtime.get_experiment_condition_observation_ids(experiment_id):
		if not case_runtime.has_observed_research_source(ResearchEntryData.SourceKind.EXPERIMENT_CONDITION_OBSERVATION, id):
			continue
		var matches: Array[ExperimentConditionObservationData] = []
		for data: ExperimentConditionObservationData in current_case.experiment_condition_observations:
			if data != null and data.observation_id == id:
				matches.append(data)
		if matches.size() != 1 or matches[0].experiment_id != experiment_id:
			push_warning("Main: recorded Experiment condition observation is missing or ambiguous; omitting observation.")
			continue
		var data: ExperimentConditionObservationData = matches[0]
		_append_source_research_entry(snapshot, entries, ResearchEntryData.SourceKind.EXPERIMENT_CONDITION_OBSERVATION, "EXPERIMENT", id, "Condition Observation: " + data.display_name, data.observation_text)
		if not snapshot.entries[-1].title.begins_with("Condition Observation:"):
			snapshot.entries[-1].title = "Condition Observation: " + snapshot.entries[-1].title


func _on_containment_confirmation_requested(room_id: String, containment_view: ContainmentView) -> void:
	if _current_stage != Stage.CONTAINMENT or not _is_active_view(containment_view) or not _has_current_case_runtime():
		return
	if current_case != null and not room_id.strip_edges().is_empty():
		for room: ContainmentData in current_case.available_containment_rooms:
			if room != null and room.room_id == room_id:
				if case_runtime.try_confirm_containment_room(room_id):
					# Submission survives Runtime reset; debug playback does not resolve it.
					pending_containment.try_add_pending(current_case.case_id, case_runtime.get_confirmed_containment_room_id())
					_try_discover_research_entry(ResearchEntryData.SourceKind.CONTAINMENT, room_id)
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
