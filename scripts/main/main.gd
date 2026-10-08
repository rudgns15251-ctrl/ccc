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
const DeveloperDispositionBuilder = preload("res://scripts/read_models/developer_run_disposition_builder.gd")
const DISTURBANCE_NOTICE_SCENE = preload("res://scenes/views/environmental_disturbance_notice.tscn")
# Temporary opportunity count range for this vertical slice, not final balance.
const PROTOTYPE_DISTURBANCE_THRESHOLD := Vector2i(2, 4)
# TEMPORARY/PROTOTYPE: one later eligible action, not final balance.
const PROTOTYPE_MAJOR_THRESHOLD: int = 1
enum IncidentRoute { DEBUG_RUNTIME, NORMAL_INTERRUPT, SCRIPTED_CAMPAIGN, SCRIPTED_INTERRUPT }
enum TerminalMode { NONE, VOLUNTARY_RESPONSE_ONLY, VOLUNTARY_AWAITING_COMMIT, FORCED_PREPARING, COMMITTED_FROZEN, TERMINAL_ERROR_FROZEN, CLEANED_NO_RUN }

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

@export var campaign_data: CampaignData

var current_case: CaseData
# Derived navigation Array from Campaign entries; authored references stay read-only.
var case_sequence: Array[CaseData] = []

var case_runtime: CaseRuntimeState
var research_archive: ResearchArchiveState
var working_hypotheses: WorkingHypothesisState
var pending_containment: PendingContainmentState
var containment_resolutions: ContainmentResolutionState
var failure_candidates: FailureEventCandidateState
var incident_responses: IncidentResponseState
var _incident_route: IncidentRoute = IncidentRoute.DEBUG_RUNTIME
var _interrupt_context: Dictionary = {}
var _source_archive_return_stage: int = -1
# Presentation intent only; completion remains in IncidentResponseState.
var _side_due: Dictionary = {}
var _side_restore_pending: bool = false
var _side_resume_error: String = ""

@onready var window_size_label: Label = %WindowSize
@onready var view_host: Control = %ViewHost
@onready var game_shell: Control = $GameShell
var _drawer_view: ResearchLogView
var _drawer_panel: PanelContainer
var _drawer_kind: String = ""
var _drawer_cache: Dictionary = {}
var _drawer_runtime_id: int = 0
var _drawer_focus: Control
var _utility_work_view: FlowView
var _utility_focus: Control
var _utility_work_stage: int = -1
var _utility_research_display: Dictionary = {}

var _current_stage: int = Stage.PROFILE
var _current_view: FlowView
var _research_log_return_stage: int = -1
var _archive_detail_case_id: String = ""
var _cctv_review_return_stage: int = -1
# Compatibility Case ordinal, derived from the sole Campaign cursor.
var _case_index: int:
	get:
		var entry: CampaignEntryData = _current_campaign_entry()
		if entry == null or entry.entry_kind != CampaignEntryData.EntryKind.CASE: return -1
		var ordinal: int = 0
		for item: CampaignEntryData in campaign_data.entries:
			if item == entry: return ordinal
			if item.entry_kind == CampaignEntryData.EntryKind.CASE: ordinal += 1
		return -1

var _campaign_fact_queries: CampaignFactQueries
var campaign_progress: CampaignProgressState
var _processed_opportunities: Dictionary[String, bool] = {}
var _event_rng := RandomNumberGenerator.new()
var _disturbance_notice: DisturbanceNotice
var _focus_before_notice: Control
var _view_process_mode_before_notice: Node.ProcessMode
var _event_presentation_credit: bool = true
var _completed_research_tokens: Dictionary[String, bool] = {}
var _research_display: Dictionary = {}
# Explicit developer/test integration only. No recipient is created or owned here.
var _developer_closure_context: Dictionary = {}
var _developer_closure_busy: bool = false
var _developer_recipient_id: int = 0
var _developer_terminal: Dictionary = {"mode": TerminalMode.NONE, "boundary_type": "", "source_case_id": "", "incident_id": "", "receipt": {}}


func _ready() -> void:
	game_shell.research_requested.connect(_shell_research_requested)
	game_shell.archive_requested.connect(_shell_archive_requested)
	game_shell.hypothesis_requested.connect(_open_drawer.bind("HYPOTHESIS"))
	get_viewport().size_changed.connect(_update_window_size)
	_update_window_size()
	# Fail before creating any Gameplay State or View; no direct-Case fallback.
	current_case = null
	case_sequence.clear()
	if campaign_data == null:
		push_error("Main: CampaignData is not assigned; initialization stopped.")
		return
	var campaign_error: String = campaign_data.get_validation_error()
	if not campaign_error.is_empty():
		push_error("Main: invalid CampaignData: " + campaign_error + " Initialization stopped.")
		return
	var entry_ids: Array[String] = []
	for entry: CampaignEntryData in campaign_data.entries:
		entry_ids.append(entry.entry_id)
		if entry.entry_kind == CampaignEntryData.EntryKind.CASE: case_sequence.append(entry.case_data)
	campaign_progress = CampaignProgressState.new()
	if not campaign_progress.configure(campaign_data.campaign_id, entry_ids):
		push_error("Main: Campaign progression initialization failed.")
		return
	research_archive = ResearchArchiveState.new()
	working_hypotheses = WorkingHypothesisState.new()
	pending_containment = PendingContainmentState.new()
	containment_resolutions = ContainmentResolutionState.new()
	failure_candidates = FailureEventCandidateState.new()
	incident_responses = IncidentResponseState.new()
	_campaign_fact_queries = CampaignFactQueries.new(campaign_data, campaign_progress, containment_resolutions, pending_containment, incident_responses, research_archive)
	_event_rng.randomize()
	_dispatch_campaign_entry()


func get_campaign_fact_queries() -> CampaignFactQueries:
	return _campaign_fact_queries


func _exit_tree() -> void:
	_dispose_auxiliary_ui()
	if _campaign_fact_queries != null: _campaign_fact_queries.release_sources()
	_side_due.clear()
	_interrupt_context.clear()
	_side_restore_pending = false
	_side_resume_error = ""
	_source_archive_return_stage = -1


func _update_window_size() -> void:
	var window_size: Vector2i = get_window().size
	window_size_label.text = "Window: %d × %d" % [window_size.x, window_size.y]


func _show_view(stage: int, discover_displayed_source: bool = true, restoring_work: bool = false) -> void:
	if not (_terminal_action_allowed("archive") or _terminal_action_allowed("resume")): return
	if _developer_terminal.mode == TerminalMode.VOLUNTARY_RESPONSE_ONLY:
		var response: Dictionary = incident_responses.get_active_response()
		var allowed: bool = (_terminal_action_allowed("resume") and stage in [Stage.CCTV, Stage.EXPERIMENT, Stage.CONTAINMENT]) or (stage == Stage.RESEARCH_ARCHIVE_DETAIL and _current_stage in [Stage.INCIDENT, Stage.BROADCAST, Stage.INCIDENT_RESULT]) or (_current_stage == Stage.RESEARCH_ARCHIVE_DETAIL and stage == _source_archive_return_stage) or (_current_stage == Stage.INCIDENT and stage == Stage.BROADCAST) or (_current_stage == Stage.BROADCAST and stage == Stage.INCIDENT_RESULT and not response.get("incident_result_id", "").is_empty())
		if not allowed: return
	if is_instance_valid(_disturbance_notice):
		return
	_close_drawer(false)
	# Keep the last research Runtime identity across read-only/response overlays.
	# The view_id still prevents this receipt from counting as a newly drawn View.
	if stage in [Stage.PROFILE, Stage.CCTV, Stage.EXPERIMENT, Stage.CONTAINMENT]:
		_research_display.clear()
	if stage not in [Stage.BROADCAST, Stage.RESEARCH_ARCHIVE_LIST, Stage.RESEARCH_ARCHIVE_DETAIL]:
		_interrupt_context.erase("broadcast_draft")
	if is_instance_valid(_current_view):
		view_host.remove_child(_current_view)
		_current_view.queue_free()

	_current_stage = stage
	_current_view = VIEW_SCENES[stage].instantiate()
	var displayed_source: Resource
	_current_view.confirmation_changed.connect(_on_confirmation_changed)
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
		containment_view.configure_next_action(("Next: SCRIPTED INCIDENT" if _next_campaign_entry().entry_kind == CampaignEntryData.EntryKind.SCRIPTED_INCIDENT else "Next: CASE") if has_next else "No next test case configured", has_next)
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
		var confirmed_broadcast_id: String = case_runtime.get_confirmed_broadcast_id() if case_runtime != null else ""
		var confirmed_option_id: String = case_runtime.get_confirmed_broadcast_option_id() if case_runtime != null else ""
		if _is_response_route():
			var response: Dictionary = incident_responses.get_active_response()
			confirmed_option_id = response.get("confirmed_option_id", "")
			confirmed_broadcast_id = response.get("broadcast_id", "") if not confirmed_option_id.is_empty() else ""
		broadcast_view.setup(
			broadcast,
			confirmed_broadcast_id,
			confirmed_option_id
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
		research_log_view.advance_requested.connect(_on_research_log_back_requested.bind(research_log_view))
		research_log_view.archive_requested.connect(_on_research_archive_requested.bind(research_log_view))
		research_log_view.hypothesis_add_requested.connect(_on_hypothesis_add_requested.bind(research_log_view))
		research_log_view.hypothesis_update_requested.connect(_on_hypothesis_update_requested.bind(research_log_view))
		research_log_view.hypothesis_remove_requested.connect(_on_hypothesis_remove_requested.bind(research_log_view))
		research_log_view.setup(_build_research_log_snapshot())
	elif stage == Stage.RESEARCH_ARCHIVE_LIST:
		var archive_list: ArchiveListView = _current_view as ArchiveListView
		archive_list.case_requested.connect(_on_archive_case_requested.bind(archive_list))
		archive_list.advance_requested.connect(_on_archive_list_back_requested.bind(archive_list))
		archive_list.setup(_build_archive_list_snapshot())
	elif stage == Stage.RESEARCH_ARCHIVE_DETAIL:
		var archive_detail: ArchiveDetailView = _current_view as ArchiveDetailView
		archive_detail.advance_requested.connect(_on_archive_detail_back_requested.bind(archive_detail))
		archive_detail.setup(_build_archive_detail_snapshot(_archive_detail_case_id))
		var case_summaries: Array = _build_archive_list_snapshot().cases
		if _is_normal_interrupt():
			case_summaries = case_summaries.filter(func(item: RefCounted) -> bool: return item.case_id == _archive_detail_case_id)
		archive_detail.set_case_summaries(case_summaries)
		archive_detail.case_requested.connect(_on_archive_case_requested.bind(archive_detail))
	_refresh_current_environment_conditions()
	_refresh_cctv_condition_observations()
	if _is_side_interrupt():
		_current_view.set_meta("interrupt_response_binding", incident_responses.get_active_response())
	_current_view.set_input_guard(_accept_view_action.bind(_current_view, "archive"))
	_current_view.set_meta("campaign_entry_id", campaign_progress.get_current_entry_id())
	view_host.add_child(_current_view)
	if stage in [Stage.PROFILE, Stage.CCTV, Stage.EXPERIMENT, Stage.CONTAINMENT]:
		_mark_research_display(_current_view)
	if _is_response_route() and stage in [Stage.INCIDENT, Stage.BROADCAST, Stage.INCIDENT_RESULT]:
		var context: Dictionary = _build_response_display_context()
		context["resume"] = stage == Stage.INCIDENT_RESULT
		_current_view.set_response_context(context)
		_current_view.research_log_button.text = "SOURCE ARCHIVE"
		_current_view.research_log_button.visible = true
		if stage == Stage.INCIDENT:
			_current_view.get_node("%ScreenTitle").text = "SCRIPTED CAMPAIGN INCIDENT" if _is_scripted_response() or _is_side_interrupt() else "MAJOR CONTAINMENT INCIDENT"
		elif stage == Stage.INCIDENT_RESULT:
			_current_view.next_button.text = "CONTINUE CAMPAIGN" if _is_scripted_response() else "RESUME WORK"
			var orders: BroadcastOptionData = _get_current_confirmed_broadcast_option()
			_current_view.get_node("%SelectedOrders").text = "TRANSMITTED ORDERS\n" + orders.display_text if orders != null else ""
		if context.is_empty():
			_current_view.next_button.disabled = true
		if stage == Stage.BROADCAST:
			_restore_response_broadcast_draft(_current_view as BroadcastView)
		_discover_response_research(stage, displayed_source)
	if discover_displayed_source and displayed_source != null:
		_discover_displayed_research_entry(_current_view, stage, displayed_source)
	if stage == Stage.CCTV and not restoring_work:
		_discover_cctv_condition_observations(_current_view as CCTVView)
	# Account the accepted work once before choosing a presentation. A matching
	# Story checkpoint suppresses only the old event presentation, not counters.
	var occurrence: ScriptedInterruptOccurrenceData = _side_checkpoint_at(ScriptedInterruptOccurrenceData.CheckpointKind.STAGE_PRESENTED, "") if discover_displayed_source else null
	if discover_displayed_source and stage == Stage.CCTV:
		_try_process_failure_event_opportunity(_current_view, "cctv:entry", occurrence == null)
	elif discover_displayed_source and stage == Stage.CONTAINMENT:
		_try_process_failure_event_opportunity(_current_view, "containment:entry", occurrence == null)
	if occurrence != null and _latch_side_checkpoint(occurrence, _current_view):
		_present_due_side_after_draw(_current_view)

	_refresh_shell()


func _on_cctv_review_requested(view: FlowView, source_stage: int) -> void:
	if source_stage != _current_stage or source_stage not in [Stage.EXPERIMENT, Stage.CONTAINMENT] or not _accept_view_action(view) or not view.is_visible_in_tree() or not _has_current_case_runtime() or case_runtime.get_applied_disturbances().is_empty():
		return
	_cctv_review_return_stage = source_stage
	_show_view(Stage.CCTV, false)


func _on_research_log_requested(view: FlowView, source_stage: int) -> void:
	if _is_response_route():
		_on_source_archive_requested(view, source_stage)
		return
	if not RESEARCH_LOG_STAGES.has(_current_stage) or source_stage != _current_stage or not _accept_view_action(view):
		return
	if _current_stage == Stage.RESULT and not case_runtime.has_monitoring_result():
		return
	_open_drawer("RESEARCH")


func _on_research_log_back_requested(research_log_view: ResearchLogView) -> void:
	if _current_stage != Stage.RESEARCH_LOG or not _accept_view_action(research_log_view):
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
	return not _is_response_route() and ((_current_stage == Stage.RESEARCH_LOG and _accept_view_action(view)) or (_drawer_kind == "HYPOTHESIS" and _accept_drawer_action(view))) and view.is_visible_in_tree() and _has_current_case_runtime() and working_hypotheses != null and case_id == current_case.case_id and view.get_hypothesis_case_id() == case_id


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
	if view == _drawer_view and _accept_drawer_action(view):
		_shell_archive_requested()
		return
	if _is_normal_interrupt():
		return
	if _current_stage != Stage.RESEARCH_LOG or not _accept_view_action(view) or not view.is_visible_in_tree() or not _has_current_case_runtime() or not RESEARCH_LOG_STAGES.has(_research_log_return_stage) or view.get_hypothesis_case_id() != current_case.case_id:
		return
	_show_view(Stage.RESEARCH_ARCHIVE_LIST, false)


func _on_archive_case_requested(case_id: String, view: FlowView) -> void:
	if _is_normal_interrupt() or (_is_scripted_response() and not _has_response_context()):
		return
	if _current_stage not in [Stage.RESEARCH_ARCHIVE_LIST, Stage.RESEARCH_ARCHIVE_DETAIL] or not _accept_view_action(view) or not view.is_visible_in_tree() or research_archive == null or not research_archive.get_archived_case_ids().has(case_id):
		return
	if _find_archive_case(case_id) == null:
		return
	_archive_detail_case_id = case_id
	_show_view(Stage.RESEARCH_ARCHIVE_DETAIL, false)


func _on_archive_list_back_requested(view: ArchiveListView) -> void:
	if is_instance_valid(_utility_work_view) and _current_stage == Stage.RESEARCH_ARCHIVE_LIST and _accept_view_action(view, "archive"):
		_restore_utility_work()
		return
	if _is_scripted_response() or _is_side_interrupt():
		if _current_stage == Stage.RESEARCH_ARCHIVE_LIST and _accept_view_action(view, "archive") and _has_response_context() and _source_archive_return_stage in [Stage.INCIDENT, Stage.BROADCAST, Stage.INCIDENT_RESULT]:
			var response_stage: int = _source_archive_return_stage
			_show_view(response_stage, false)
			_source_archive_return_stage = -1
			_archive_detail_case_id = ""
		return
	if _is_normal_interrupt():
		return
	if _current_stage != Stage.RESEARCH_ARCHIVE_LIST or not _accept_view_action(view) or not view.is_visible_in_tree() or not RESEARCH_LOG_STAGES.has(_research_log_return_stage):
		return
	_archive_detail_case_id = ""
	_show_view(Stage.RESEARCH_LOG, false)


func _on_archive_detail_back_requested(view: ArchiveDetailView) -> void:
	if _current_stage != Stage.RESEARCH_ARCHIVE_DETAIL or not _accept_view_action(view, "archive") or not view.is_visible_in_tree():
		return
	if _is_scripted_response() or _is_side_interrupt():
		if _has_response_context() and view.get("_snapshot").case_id == _archive_detail_case_id:
			_archive_detail_case_id = ""
			_show_view(Stage.RESEARCH_ARCHIVE_LIST, false)
		return
	if _is_normal_interrupt():
		if not _has_interrupt_context() or _source_archive_return_stage not in [Stage.INCIDENT, Stage.BROADCAST, Stage.INCIDENT_RESULT] or _archive_detail_case_id != incident_responses.get_active_response().get("source_case_id", "") or view.get("_snapshot").case_id != _archive_detail_case_id:
			return
		var return_stage: int = _source_archive_return_stage
		_show_view(return_stage, false)
		_source_archive_return_stage = -1
		_archive_detail_case_id = ""
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
	if not _terminal_action_allowed(): return false
	if not _has_current_case_runtime() or source_id.strip_edges().is_empty():
		return false
	case_runtime.try_observe_research_source(source_kind, source_id)
	var authored: ResearchEntryData = _find_research_entry(_get_valid_research_entries(), source_kind, source_id)
	return authored != null and case_runtime.try_discover_research_entry(authored.entry_id)


func _discover_displayed_research_entry(view: FlowView, stage: int, source: Resource) -> void:
	if _is_side_interrupt(): return
	if _is_normal_interrupt() and stage in [Stage.INCIDENT, Stage.BROADCAST, Stage.INCIDENT_RESULT]:
		return
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
	if _is_response_route():
		return _response_incident()
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
	if _is_response_route():
		return _response_broadcast()
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
	if _is_response_route():
		return _response_option()
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
	if _is_response_route():
		return _response_result()
	return _get_incident_result_for_option(_get_current_confirmed_broadcast_option())


func _on_broadcast_confirmation_requested(broadcast_id: String, option_id: String, broadcast_view: BroadcastView) -> void:
	if _current_stage != Stage.BROADCAST or not _accept_view_action(broadcast_view, "response"):
		return
	if _is_response_route():
		_confirm_response_option(broadcast_id, option_id, broadcast_view)
		return
	if not _has_current_case_runtime(): return
	var broadcast: EmergencyBroadcastData = _get_current_emergency_broadcast()
	if not case_runtime.has_confirmed_broadcast_option() and broadcast != null and broadcast.broadcast_id == broadcast_id:
		var option: BroadcastOptionData = _get_broadcast_option(broadcast, option_id)
		if _get_incident_result_for_option(option) != null:
			if case_runtime.try_confirm_broadcast_option(broadcast_id, option_id):
				_try_discover_research_entry(ResearchEntryData.SourceKind.BROADCAST_OPTION, option_id)
	broadcast_view.update_confirmation_state(case_runtime.get_confirmed_broadcast_id(), case_runtime.get_confirmed_broadcast_option_id())


func _is_active_view(view: FlowView) -> bool:
	return not _developer_closure_busy and not is_instance_valid(_drawer_view) and not (is_instance_valid(_current_view) and _current_view.has_open_confirmation()) and not is_instance_valid(_disturbance_notice) and is_instance_valid(view) and view == _current_view and view.is_inside_tree() and not view.is_queued_for_deletion()


func _on_advance_requested(view: FlowView) -> void:
	if not _accept_view_action(view, "response"):
		return
	if _is_response_route() and _current_stage in [Stage.INCIDENT, Stage.BROADCAST, Stage.INCIDENT_RESULT]:
		_advance_response(view)
		return
	if not _side_due.is_empty():
		_try_present_side_interrupt()
		return
	if not _has_unique_case_sequence():
		return
	if _current_stage in [Stage.CCTV, Stage.EXPERIMENT, Stage.CONTAINMENT] and (not view.is_visible_in_tree() or _research_display.get("runtime_id", 0) != case_runtime.get_instance_id()):
		return
	if _is_normal_interrupt() and _current_stage in [Stage.INCIDENT, Stage.BROADCAST, Stage.INCIDENT_RESULT]:
		_advance_response(view)
		return
	if _current_stage == Stage.CCTV and _cctv_review_return_stage in [Stage.EXPERIMENT, Stage.CONTAINMENT]:
		var return_stage: int = _cctv_review_return_stage
		_cctv_review_return_stage = -1
		_show_view(return_stage, false)
		return
	if _current_stage in [Stage.CCTV, Stage.EXPERIMENT] and _has_failure_event_context(view) and campaign_progress.get_transition().is_empty():
		var source_id: String = _displayed_research_source_id(view)
		if not source_id.is_empty():
			if not _has_drawn_research_display(view):
				return
			_grant_event_presentation_credit("cctv" if _current_stage == Stage.CCTV else "experiment", source_id)
			if _current_stage == Stage.EXPERIMENT:
				var occurrence: ScriptedInterruptOccurrenceData = _side_checkpoint_at(ScriptedInterruptOccurrenceData.CheckpointKind.ACTION_ACCEPTED, ScriptedInterruptOccurrenceData.EXPERIMENT_RESULT_READ)
				if occurrence != null and _latch_side_checkpoint(occurrence, view):
					_try_present_side_interrupt()
					return
			if _try_present_ready_failure_event(view, true):
				return
	if _current_stage == Stage.CONTAINMENT:
		var target: CampaignEntryData = _next_campaign_entry()
		if target != null and target.entry_kind == CampaignEntryData.EntryKind.SCRIPTED_INCIDENT:
			if view.next_button.disabled or not _has_next_test_case() or not case_runtime.has_confirmed_containment() or pending_containment.get_pending_room_id(current_case.case_id) != case_runtime.get_confirmed_containment_room_id(): return
			if not campaign_progress.bind_transition(target.entry_id): return
			if campaign_progress.consume_failure_offer() and _try_present_ready_failure_event(view): return
			_handoff_to_next_case()
			return
		if not view.next_button.disabled and _has_next_test_case() and case_runtime.has_confirmed_containment() and pending_containment.get_pending_room_id(current_case.case_id) == case_runtime.get_confirmed_containment_room_id() and _try_present_ready_failure_event(view):
			return
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
	if not _terminal_action_allowed(): return
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


func _has_unique_case_sequence() -> bool:
	if case_sequence.is_empty():
		return false
	var ids: Array[String] = []
	for data: CaseData in case_sequence:
		if data == null or data.case_id.strip_edges().is_empty() or ids.has(data.case_id):
			return false
		ids.append(data.case_id)
	return true


func _has_next_test_case() -> bool:
	if not _has_unique_case_sequence() or not _has_current_case_runtime() or _case_index < 0 or _case_index >= case_sequence.size() or case_sequence[_case_index] != current_case: return false
	var entry: CampaignEntryData = _current_campaign_entry()
	var target: CampaignEntryData = _next_campaign_entry()
	if entry == null or entry.case_data != current_case or target == null or not target.get_validation_error().is_empty(): return false
	if target.entry_kind == CampaignEntryData.EntryKind.SCRIPTED_INCIDENT: return true
	var next_case: CaseData = target.case_data
	return not next_case.display_name.strip_edges().is_empty() and next_case.case_id != current_case.case_id and not pending_containment.has_pending(next_case.case_id) and not containment_resolutions.has_resolution(next_case.case_id)


func build_test_sequence_disposition_snapshot() -> TestSequenceDispositionSnapshot:
	# Explicit developer API, including controlled mid-sequence/response probes.
	# Never invoked by Next, Confirm, handoff, or a player-facing View.
	var current_id: String = current_case.case_id if current_case != null else ""
	var sequence_valid: bool = not case_sequence.is_empty() and _has_unique_case_sequence()
	var current_valid: bool = sequence_valid and _has_current_case_runtime() and _case_index >= 0 and _case_index < case_sequence.size() and case_sequence[_case_index] == current_case
	var states_available: bool = pending_containment != null and containment_resolutions != null and failure_candidates != null and incident_responses != null and research_archive != null and working_hypotheses != null
	var facts: Dictionary = {"boundary_valid": current_valid and states_available, "boundary_status": "INVALID_BOUNDARY", "current_case_id": current_id, "current_case_status": "INVALID_CURRENT_CASE", "runtime_instance_id": case_runtime.get_instance_id() if case_runtime != null else 0, "current_view_stage": Stage.keys()[_current_stage], "active_response": {}, "archived_cases": [], "hypotheses_by_case": [], "current_research_count": 0, "current_observed_source_count": 0, "current_hypothesis_count": 0}
	var pending: Array[Dictionary] = []
	var resolutions: Array[Dictionary] = []
	var candidates: Array[Dictionary] = []
	var responses: Array[Dictionary] = []
	var side_boundary: String = _side_boundary_status()
	if not side_boundary.is_empty():
		facts.boundary_valid = false
		facts.boundary_status = side_boundary
		return TestSequenceDispositionSnapshot.build(facts, pending, resolutions, candidates, responses, _find_failure_source_case, _unique_response_content)
	# Missing initialization produces an explicit invalid observation, not fallback.
	if not states_available:
		return TestSequenceDispositionSnapshot.build(facts, pending, resolutions, candidates, responses, _find_failure_source_case, _unique_response_content)
	for id: String in pending_containment.get_pending_case_ids():
		pending.append({"case_id": id, "confirmed_room_id": pending_containment.get_pending_room_id(id)})
	for id: String in containment_resolutions.get_resolved_case_ids():
		resolutions.append(containment_resolutions.get_resolution(id))
	for id: String in failure_candidates.get_candidate_case_ids():
		candidates.append(failure_candidates.get_candidate(id))
	responses = _case_response_records()
	var active: Dictionary = incident_responses.get_active_response()
	if _is_scripted_response():
		active = {}
		facts.boundary_status = "UNSUPPORTED_CAMPAIGN_ENTRY"
	if not active.is_empty():
		var response_stage: int = _source_archive_return_stage if _current_stage == Stage.RESEARCH_ARCHIVE_DETAIL and _source_archive_return_stage != -1 else _current_stage
		active["response_stage"] = Stage.keys()[response_stage]
		active["context_valid"] = _is_normal_interrupt() and _has_interrupt_context()
		active["incident_result_displayed"] = false
		if active.context_valid and response_stage == Stage.INCIDENT_RESULT:
			var result: IncidentResultData = _response_result()
			active.incident_result_displayed = result != null and (_current_stage == Stage.RESEARCH_ARCHIVE_DETAIL or _current_view.get("_incident_result_data") == result)
		facts.active_response = active
	for id: String in research_archive.get_archived_case_ids():
		facts.archived_cases.append({"case_id": id, "discovered_entry_count": research_archive.get_discovered_entry_ids(id).size()})
	var hypothesis_case_ids: Array[String] = []
	for data: CaseData in case_sequence:
		if data != null and not hypothesis_case_ids.has(data.case_id):
			hypothesis_case_ids.append(data.case_id)
	if not current_id.is_empty() and not hypothesis_case_ids.has(current_id):
		hypothesis_case_ids.append(current_id)
	for id: String in hypothesis_case_ids:
		facts.hypotheses_by_case.append({"case_id": id, "count": working_hypotheses.get_hypotheses(id).size()})
	if current_valid:
		facts.current_research_count = case_runtime.get_discovered_research_entry_ids().size()
		facts.current_observed_source_count = case_runtime.get_observed_research_sources().size()
		facts.current_hypothesis_count = working_hypotheses.get_hypotheses(current_id).size()
		facts.current_case_status = "SUBMITTED_PENDING" if pending_containment.has_pending(current_id) else "RESOLVED" if containment_resolutions.has_resolution(current_id) else "RESEARCH_IN_PROGRESS"
		facts.boundary_status = "NOT_AT_TEST_SEQUENCE_END"
		if _case_index == case_sequence.size() - 1 and case_runtime.has_confirmed_containment() and pending_containment.get_pending_room_id(current_id) == case_runtime.get_confirmed_containment_room_id():
			facts.boundary_status = "AT_TEST_SEQUENCE_END"
	return TestSequenceDispositionSnapshot.build(facts, pending, resolutions, candidates, responses, _find_failure_source_case, _unique_response_content)


func _handoff_to_next_case() -> void:
	if not _side_due.is_empty() or _side_restore_pending or _is_side_interrupt(): return
	if not _terminal_action_allowed(): return
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
	var entry: CampaignEntryData = _current_campaign_entry()
	if not campaign_progress.try_complete_and_advance(entry.entry_id): return
	_dispatch_campaign_entry()


func _try_resolve_current_pending() -> bool:
	return _try_resolve_pending_without_handoff(current_case)


# DEVELOPER CLOSURE API ONLY. Caller allocates explicit assignment IDs once and
# retains the injected recipient beyond Main's lifetime. No gameplay call site.
# A committed receipt owns the final record. Source callbacks are then frozen;
# physical cleanup and player Run End remain separate follow-up responsibilities.
func configure_developer_run_identity(run_id: String, assignments: Dictionary) -> Dictionary:
	if _developer_terminal.mode == TerminalMode.CLEANED_NO_RUN:
		return _developer_closure_result("INVALID_PRECONDITION", "Cleaned Main cannot configure another Run.")
	if _developer_closure_busy or not _has_unique_case_sequence() or run_id.is_empty() or run_id != run_id.strip_edges():
		return _developer_closure_result("INVALID_PRECONDITION", "Invalid developer identity configuration.")
	if assignments.size() != case_sequence.size():
		return _developer_closure_result("INVALID_PRECONDITION", "Every configured Case requires exactly one assignment.")
	var used: Array[String] = []
	for source: CaseData in case_sequence:
		var value: Variant = assignments.get(source.case_id)
		if not value is String or value.is_empty() or value != value.strip_edges() or used.has(value):
			return _developer_closure_result("INVALID_PRECONDITION", "Missing, blank or duplicate assignment: " + source.case_id)
		used.append(value)
	var context: Dictionary = {"run_instance_id": run_id, "case_assignments": assignments.duplicate(true), "sequence_ids": _developer_sequence_ids(), "state_ids": _developer_session_state_ids()}
	if context.state_ids.has(0): return _developer_closure_result("INVALID_PRECONDITION", "Main has not initialized its States.")
	if not _developer_closure_context.is_empty():
		return _developer_closure_result("ALREADY_CONFIGURED" if RunDispositionRecord.values_equal(context, _developer_closure_context) else "INVALID_PRECONDITION", "Developer context is bound once per Main session.")
	_developer_closure_context = context
	return _developer_closure_result("CONFIGURED")


func developer_commit_run_disposition(boundary_type: String, recipient: RunDispositionState) -> Dictionary:
	var side_boundary: String = _side_boundary_status()
	if not side_boundary.is_empty():
		var blocked: Dictionary = _developer_closure_result(side_boundary, "Campaign interrupt terminal integration is not implemented.")
		blocked["terminal_mode"] = TerminalMode.keys()[_developer_terminal.mode]
		return blocked
	if _is_scripted_response() and not incident_responses.get_active_response().is_empty():
		var blocked: Dictionary = _developer_closure_result("UNSUPPORTED_ACTIVE_CAMPAIGN_RESPONSE", "Campaign response terminal integration is not implemented.")
		blocked["terminal_mode"] = TerminalMode.keys()[_developer_terminal.mode]
		return blocked
	if _developer_terminal.mode == TerminalMode.CLEANED_NO_RUN:
		return _developer_closure_result("INVALID_PRECONDITION", "Cleaned source cannot prepare another disposition.")
	if _developer_closure_busy:
		return _developer_closure_result("INVALID_PRECONDITION", "Closure prepare is already running.")
	_developer_closure_busy = true
	var result: Dictionary = _prepare_and_commit_developer_disposition(boundary_type, recipient)
	if result.status in ["COMMITTED", "ALREADY_COMMITTED"]:
		_developer_terminal.mode = TerminalMode.COMMITTED_FROZEN
		_developer_terminal.receipt = result.receipt.duplicate(true)
	elif result.status != "WAITING_ACTIVE_RESPONSE" and result.status != "INVALID_PRECONDITION" and _developer_terminal.mode in [TerminalMode.FORCED_PREPARING, TerminalMode.VOLUNTARY_AWAITING_COMMIT, TerminalMode.VOLUNTARY_RESPONSE_ONLY]:
		_developer_terminal.mode = TerminalMode.TERMINAL_ERROR_FROZEN
	result["terminal_mode"] = TerminalMode.keys()[_developer_terminal.mode]
	_developer_closure_busy = false
	return result


# DEVELOPER CLEANUP / NO-RUN BOUNDARY ONLY. No automatic commit call site.
# Recipient remains caller-owned; keep only its instance ID and primitive proof.
func developer_cleanup_committed_run(recipient: RunDispositionState) -> Dictionary:
	if _developer_closure_busy:
		return _developer_closure_result("INVALID_PRECONDITION", "Closure/cleanup is already running.")
	_developer_closure_busy = true
	var result: Dictionary = _cleanup_verified_source(recipient)
	result["terminal_mode"] = TerminalMode.keys()[_developer_terminal.mode]
	_developer_closure_busy = false
	return result


func _cleanup_verified_source(recipient: RunDispositionState) -> Dictionary:
	if not _side_boundary_status().is_empty(): return _developer_closure_result("INVALID_PRECONDITION", "Campaign interrupt is not at a verified cleanup boundary.")
	var mode: int = _developer_terminal.mode
	if recipient == null or recipient.get_instance_id() != _developer_recipient_id or mode not in [TerminalMode.COMMITTED_FROZEN, TerminalMode.CLEANED_NO_RUN]:
		return _developer_closure_result("INVALID_PRECONDITION", "Cleanup requires the bound recipient and verified committed source.")
	if mode == TerminalMode.COMMITTED_FROZEN and _developer_closure_context.is_empty():
		return _developer_closure_result("INVALID_PRECONDITION", "Missing configured source identity.")
	var proof: Dictionary = _developer_terminal.receipt
	var run_id: String = _developer_closure_context.get("run_instance_id", proof.get("run_instance_id", ""))
	if run_id.is_empty() or not _developer_receipt_valid(run_id, proof) or not recipient.has_committed_run(run_id) or recipient.get_commit_receipt(run_id) != proof:
		return _developer_closure_result("RECEIPT_MISMATCH", "Missing or mismatched recipient receipt.")
	var record: Dictionary = recipient.get_committed_record(run_id)
	if record.is_empty() or record.get("run_instance_id", "") != run_id or record.get("boundary_type", "") != _developer_terminal.boundary_type:
		return _developer_closure_result("RECEIPT_MISMATCH", "Committed Record identity/boundary differs from terminal proof.")
	for category: String in RunDispositionState.CATEGORIES:
		if not record.get(category) is Array:
			return _developer_closure_result("RECEIPT_MISMATCH", "Committed Record category unavailable: " + category)
	# No source re-projection, semantic rebuild, try_commit, or RNG operation.
	if mode == TerminalMode.CLEANED_NO_RUN:
		return _developer_closure_result("ALREADY_CLEANED" if _cleaned_source_is_empty() else "SOURCE_CLEANUP_ERROR", "", proof)
	# Preflight before any destructive operation. Partial-error retry retains the
	# configured State identity and verified proof, even after Runtime release.
	for state: RefCounted in [pending_containment, containment_resolutions, failure_candidates, incident_responses, research_archive, working_hypotheses, campaign_progress]:
		if state == null or not state.has_method("reset"):
			return _developer_closure_result("SOURCE_CLEANUP_ERROR", "Required source State/reset is unavailable.", proof)
	if _developer_closure_context.state_ids != _developer_session_state_ids() or _developer_closure_context.sequence_ids != _developer_sequence_ids() or not is_instance_valid(view_host):
		return _developer_closure_result("SOURCE_CLEANUP_ERROR", "Source identity or ViewHost changed.", proof)
	for child: Node in view_host.get_children():
		if child != _current_view:
			return _developer_closure_result("SOURCE_CLEANUP_ERROR", "Unexpected ViewHost child; source retained.", proof)
	if is_instance_valid(_current_view) and _current_view.get_parent() != view_host or is_instance_valid(_disturbance_notice) and _disturbance_notice.get_parent() != self:
		return _developer_closure_result("SOURCE_CLEANUP_ERROR", "Source View/notice parent changed.", proof)
	# Verified preflight passed. Release before any destructive source operation.
	_dispose_auxiliary_ui()
	if _campaign_fact_queries != null: _campaign_fact_queries.release_sources()
	if is_instance_valid(_current_view):
		view_host.remove_child(_current_view)
		_current_view.queue_free()
	_current_view = null
	if is_instance_valid(_disturbance_notice):
		remove_child(_disturbance_notice)
		_disturbance_notice.queue_free()
	_disturbance_notice = null
	_focus_before_notice = null
	view_host.process_mode = Node.PROCESS_MODE_INHERIT
	_view_process_mode_before_notice = Node.PROCESS_MODE_INHERIT
	_interrupt_context.clear()
	_side_due.clear()
	_side_restore_pending = false
	_side_resume_error = ""
	_incident_route = IncidentRoute.DEBUG_RUNTIME
	_source_archive_return_stage = -1
	_research_log_return_stage = -1
	_archive_detail_case_id = ""
	_cctv_review_return_stage = -1
	_research_display.clear()
	_processed_opportunities.clear()
	_completed_research_tokens.clear()
	_event_presentation_credit = false
	pending_containment.reset()
	containment_resolutions.reset()
	failure_candidates.reset()
	incident_responses.reset()
	research_archive.reset()
	working_hypotheses.reset()
	if case_runtime != null: case_runtime.reset()
	case_runtime = null
	current_case = null
	campaign_progress.reset()
	# Keep last valid Stage for safe array indexing. Mode is lifecycle authority.
	if not _cleaned_source_is_empty():
		return _developer_closure_result("SOURCE_CLEANUP_ERROR", "Source reset postcondition failed; committed source stays frozen for explicit retry.", proof)
	_developer_closure_context.clear()
	_developer_terminal = {"mode": TerminalMode.CLEANED_NO_RUN, "boundary_type": record.boundary_type, "receipt": proof.duplicate(true)}
	_refresh_shell()
	return _developer_closure_result("CLEANED", "", proof)


func _cleaned_source_is_empty() -> bool:
	return (
		campaign_progress != null and campaign_progress.get_current_entry_id().is_empty() and campaign_progress.get_completed_entry_ids().is_empty() and campaign_progress.get_transition().is_empty()
		and pending_containment != null and containment_resolutions != null and failure_candidates != null
		and incident_responses != null and research_archive != null and working_hypotheses != null
		and pending_containment.get_pending_case_ids().is_empty() and containment_resolutions.get_resolved_case_ids().is_empty()
		and failure_candidates.get_candidate_case_ids().is_empty() and incident_responses.get_responses().is_empty()
		and incident_responses.get_active_response().is_empty() and research_archive.get_archived_case_ids().is_empty()
		and working_hypotheses.get("_records_by_case").is_empty() and working_hypotheses.get("_next_id_by_case").is_empty()
		and case_runtime == null and current_case == null and _case_index == -1
		and not is_instance_valid(_current_view) and is_instance_valid(view_host) and view_host.get_child_count() == 0
		and not is_instance_valid(_disturbance_notice) and not is_instance_valid(_focus_before_notice)
		and _side_due.is_empty() and not _side_restore_pending and _side_resume_error.is_empty()
		and _interrupt_context.is_empty() and _source_archive_return_stage == -1 and _research_log_return_stage == -1
		and _archive_detail_case_id.is_empty() and _cctv_review_return_stage == -1 and _research_display.is_empty()
		and _processed_opportunities.is_empty() and _completed_research_tokens.is_empty() and not _event_presentation_credit
	)


func _prepare_and_commit_developer_disposition(boundary: String, recipient: RunDispositionState) -> Dictionary:
	if recipient == null or _developer_closure_context.is_empty() or boundary not in RunDispositionState.BOUNDARIES:
		return _developer_closure_result("INVALID_PRECONDITION", "Requires configured identity, recipient and final boundary.")
	if _developer_recipient_id != 0 and _developer_recipient_id != recipient.get_instance_id():
		return _developer_closure_result("INVALID_PRECONDITION", "This source session is bound to a different recipient.")
	if _developer_terminal.boundary_type == "FORCED_RUN_END" and boundary == "VOLUNTARY_RUN_END" and _developer_terminal.mode != TerminalMode.COMMITTED_FROZEN:
		return _developer_closure_result("INVALID_PRECONDITION", "Forced terminal intent cannot be downgraded.")
	var run_id: String = _developer_closure_context.run_instance_id
	# Receipt authority first, before any Pending mutation or RNG draw.
	if recipient.has_committed_run(run_id):
		var existing: Dictionary = recipient.get_committed_record(run_id)
		var receipt: Dictionary = recipient.get_commit_receipt(run_id)
		if not _developer_receipt_valid(run_id, receipt): return _developer_closure_result("RECIPIENT_INVALID", "Invalid existing receipt.")
		if not _developer_source_valid(): return _developer_closure_result("INVALID_SOURCE_STATE", "Committed source identity changed.", receipt)
		if _developer_terminal.mode == TerminalMode.NONE:
			_developer_recipient_id = recipient.get_instance_id()
			_begin_developer_terminal_intent(boundary, {})
		if existing.boundary_type != boundary: return _developer_closure_result("RECIPIENT_CONFLICT", "Run already committed with another boundary.", receipt)
		var projected: Dictionary = DeveloperDispositionBuilder.build(_developer_closure_context, _developer_source_facts(), case_sequence, boundary)
		if not projected.issue.is_empty() or not RunDispositionRecord.values_equal(projected.data, existing):
			return _developer_closure_result("INVALID_SOURCE_STATE", "COMMITTED_SOURCE_MISMATCH::" + projected.issue, receipt)
		_developer_recipient_id = recipient.get_instance_id()
		return _developer_closure_result("ALREADY_COMMITTED", "", receipt)
	if not _developer_source_valid(): return _developer_closure_result("INVALID_PRECONDITION", "Not a valid final configured test boundary/source identity.")
	if not incident_responses.get_active_response().is_empty() and not _is_normal_interrupt():
		return _developer_closure_result("INVALID_SOURCE_STATE", "DEBUG_RESPONSE_ROUTE_UNSUPPORTED")
	_developer_recipient_id = recipient.get_instance_id()
	_begin_developer_terminal_intent(boundary, incident_responses.get_active_response())
	var identities: Array = _developer_live_identity()
	var facts: Dictionary = _developer_source_facts()
	var active_facts: Dictionary = facts.active_response_facts
	if active_facts.has("reference_issue"): return _developer_closure_result("INVALID_SOURCE_STATE", active_facts.reference_issue)
	var issue: String = DeveloperDispositionBuilder.source_issue(facts, _developer_closure_context.case_assignments)
	if not issue.is_empty(): return _developer_closure_result("INVALID_SOURCE_STATE", issue)
	if not active_facts.is_empty() and boundary == "VOLUNTARY_RUN_END":
		return _developer_closure_result("WAITING_ACTIVE_RESPONSE", "Complete only the current response, then explicitly retry with this recipient.")
	for pending: Dictionary in facts.pending:
		# Forced ACTIVE closure is a read-only projection of the live source. The
		# current authored final Case has no Outcome; unprepared resolvable/residue
		# Pending in a changed developer fixture requires a separate prepare first.
		if not active_facts.is_empty():
			var classification: Dictionary = DeveloperDispositionBuilder.classify_pending(pending, facts, case_sequence)
			if containment_resolutions.has_resolution(pending.case_id) or classification.classification == "RESOLVABLE_PENDING":
				return _developer_closure_result("INVALID_SOURCE_STATE", "ACTIVE_FORCE_REQUIRES_PREPARED_PENDING")
			continue
		if containment_resolutions.has_resolution(pending.case_id):
			# Integrity and same-Room agreement were checked above. No rejudge/RNG.
			pending_containment.remove_pending(pending.case_id)
			continue
		var classified: Dictionary = DeveloperDispositionBuilder.classify_pending(pending, facts, case_sequence)
		if classified.classification == "RESOLVABLE_PENDING":
			if not _try_resolve_pending_without_handoff(DeveloperDispositionBuilder.find_case(case_sequence, pending.case_id), true):
				return _developer_closure_result("INVALID_SOURCE_STATE", "Hidden resolution subtransaction failed; Pending retained.")
	var prepared: Dictionary = _developer_source_facts()
	var built: Dictionary = DeveloperDispositionBuilder.build(_developer_closure_context, prepared, case_sequence, boundary)
	if not built.issue.is_empty(): return _developer_closure_result("INVALID_SOURCE_STATE", built.issue)
	var record := RunDispositionRecord.new(built.data)
	if not record.get_input_issue().is_empty(): return _developer_closure_result("INVALID_SOURCE_STATE", record.get_input_issue())
	# Re-read direct State identity/content, never trust the earlier plan or Snapshot.
	if not _developer_source_valid() or identities != _developer_live_identity() or not RunDispositionRecord.values_equal(prepared, _developer_source_facts()):
		return _developer_closure_result("INVALID_SOURCE_STATE", "Source changed during synchronous prepare.")
	var committed: Dictionary = recipient.try_commit(record)
	if committed.status == "CONFLICT": return _developer_closure_result("RECIPIENT_CONFLICT", committed.reference_issue, committed.receipt)
	if committed.status not in ["COMMITTED", "ALREADY_COMMITTED"]: return _developer_closure_result("RECIPIENT_INVALID", committed.reference_issue)
	if committed.run_instance_id != run_id or not _developer_receipt_valid(run_id, committed.receipt) or not RunDispositionRecord.values_equal(committed.receipt, recipient.get_commit_receipt(run_id)) or not RunDispositionRecord.values_equal(built.data, recipient.get_committed_record(run_id)):
		return _developer_closure_result("RECIPIENT_INVALID", "Recipient failed record/receipt acknowledgement.")
	return _developer_closure_result(committed.status, "", committed.receipt)


func _developer_source_valid() -> bool:
	if _developer_closure_context.is_empty() or not _has_unique_case_sequence() or _developer_closure_context.sequence_ids != _developer_sequence_ids() or _developer_closure_context.state_ids != _developer_session_state_ids(): return false
	if not _has_current_case_runtime() or _case_index != case_sequence.size() - 1 or current_case != case_sequence[_case_index] or not case_runtime.has_confirmed_containment(): return false
	if not is_instance_valid(_current_view) or _current_view.is_queued_for_deletion() or _research_display.get("runtime_id", 0) != case_runtime.get_instance_id(): return false
	var room: String = case_runtime.get_confirmed_containment_room_id()
	if pending_containment.has_pending(current_case.case_id): return pending_containment.get_pending_room_id(current_case.case_id) == room
	# Prepare may already have resolved the final Pending on a failed commit attempt.
	return containment_resolutions.has_resolution(current_case.case_id) and containment_resolutions.get_resolution(current_case.case_id).room_id == room


func _developer_sequence_ids() -> Array:
	var ids: Array = []
	for source: CaseData in case_sequence: ids.append([source.case_id, source.get_instance_id()])
	return ids


func _developer_session_state_ids() -> Array:
	var ids: Array = []
	for state: RefCounted in [pending_containment, containment_resolutions, failure_candidates, incident_responses, research_archive, working_hypotheses, campaign_progress]: ids.append(state.get_instance_id() if state != null else 0)
	return ids


func _developer_live_identity() -> Array:
	return [campaign_progress.get_current_entry_id(), campaign_progress.get_completed_entry_ids(), _developer_sequence_ids(), _developer_session_state_ids(), case_runtime.get_instance_id(), current_case.get_instance_id(), _case_index, _current_stage, _current_view.get_instance_id()]


func _developer_source_facts() -> Dictionary:
	var facts: Dictionary = {"current_case_id": current_case.case_id, "pending": [], "resolutions": [], "candidates": [], "responses": _case_response_records(), "archives": [], "notes": []}
	for id: String in pending_containment.get_pending_case_ids(): facts.pending.append({"case_id": id, "confirmed_room_id": pending_containment.get_pending_room_id(id)})
	for id: String in containment_resolutions.get_resolved_case_ids(): facts.resolutions.append(containment_resolutions.get_resolution(id))
	for id: String in failure_candidates.get_candidate_case_ids(): facts.candidates.append(failure_candidates.get_candidate(id))
	for id: String in research_archive.get_archived_case_ids(): facts.archives.append({"case_id": id, "entry_ids": research_archive.get_discovered_entry_ids(id)})
	# State has no enumeration getter. Read keys only; obtain detached records with
	# the existing getter, including foreign-source diagnostics rather than omission.
	for id: String in working_hypotheses.get("_records_by_case"): facts.notes.append({"case_id": id, "hypotheses": working_hypotheses.get_hypotheses(id)})
	var conditions: Dictionary = {}
	for id: String in case_runtime.get_experiment_execution_history(): conditions[id] = case_runtime.get_experiment_condition_observation_ids(id)
	facts["runtime"] = {"case_id": case_runtime.case_id, "confirmed_room_id": case_runtime.get_confirmed_containment_room_id(), "discovered_entry_ids": case_runtime.get_discovered_research_entry_ids(), "observed_sources": case_runtime.get_observed_research_sources(), "experiment_history": case_runtime.get_experiment_execution_history(), "experiment_condition_observations": conditions, "applied_disturbances": case_runtime.get_applied_disturbances()}
	facts["active_response_facts"] = _developer_active_response_facts()
	return facts


func _developer_closure_result(status: String, issue: String = "", receipt: Dictionary = {}) -> Dictionary:
	return {"status": status, "run_instance_id": _developer_closure_context.get("run_instance_id", _developer_terminal.receipt.get("run_instance_id", "")), "receipt": receipt.duplicate(true), "reference_issue": issue}


func _developer_receipt_valid(run_id: String, receipt: Dictionary) -> bool:
	return receipt == {"run_instance_id": run_id, "receipt_id": "RUN_DISPOSITION_RECEIPT::" + run_id}


func _begin_developer_terminal_intent(boundary: String, active: Dictionary) -> void:
	_developer_terminal.boundary_type = boundary
	if not active.is_empty():
		_developer_terminal.source_case_id = active.source_case_id
		_developer_terminal.incident_id = active.incident_id
	_developer_terminal.mode = TerminalMode.FORCED_PREPARING if boundary == "FORCED_RUN_END" else (TerminalMode.VOLUNTARY_RESPONSE_ONLY if not active.is_empty() else TerminalMode.VOLUNTARY_AWAITING_COMMIT)


func _terminal_action_allowed(action: String = "gameplay") -> bool:
	if _developer_terminal.mode == TerminalMode.NONE: return true
	# Resume restores the interrupted View only after actual completion. It is
	# followed synchronously by AWAITING_COMMIT, never a fresh opportunity.
	if _developer_terminal.mode == TerminalMode.VOLUNTARY_RESPONSE_ONLY and action == "resume":
		return _current_stage == Stage.INCIDENT_RESULT and DeveloperDispositionBuilder.completed_for(_developer_terminal.source_case_id, _developer_terminal.incident_id, incident_responses.get_responses())
	if _developer_terminal.mode != TerminalMode.VOLUNTARY_RESPONSE_ONLY or action not in ["response", "archive"] or not _is_normal_interrupt(): return false
	var active: Dictionary = incident_responses.get_active_response()
	if active.is_empty() or active.source_case_id != _developer_terminal.source_case_id or active.incident_id != _developer_terminal.incident_id or not _has_interrupt_context(): return false
	if action == "archive" and _current_stage in [Stage.RESEARCH_ARCHIVE_LIST, Stage.RESEARCH_ARCHIVE_DETAIL]:
		return _source_archive_return_stage in [Stage.INCIDENT, Stage.BROADCAST, Stage.INCIDENT_RESULT] and _archive_detail_case_id == active.source_case_id
	return _current_stage in [Stage.INCIDENT, Stage.BROADCAST, Stage.INCIDENT_RESULT]


func _accept_view_action(view: FlowView, action: String = "gameplay") -> bool:
	if _side_restore_pending: return false
	if not _side_due.is_empty() and action != "response": return false
	if _is_side_interrupt():
		if _bound_side_interrupt() == null: return false
		var active: Dictionary = incident_responses.get_active_response()
		var binding: Dictionary = view.get_meta("interrupt_response_binding", {}) if is_instance_valid(view) else {}
		if not IncidentSource.from_record(active).matches(binding) or binding.get("incident_id", "") != active.get("incident_id", "") or binding.get("broadcast_id", "") != active.get("broadcast_id", "") or binding.get("incident_result_id", "") != active.get("incident_result_id", ""): return false
	return _is_active_view(view) and _terminal_action_allowed(action) and campaign_progress != null and view.get_meta("campaign_entry_id", "") == campaign_progress.get_current_entry_id()


func _developer_active_response_facts() -> Dictionary:
	var active: Dictionary = incident_responses.get_active_response()
	var active_count: int = 0
	for response: Dictionary in incident_responses.get_responses():
		if response.status == IncidentResponseState.Status.ACTIVE: active_count += 1
	if active_count == 0: return {}
	if active_count != 1 or active.is_empty() or not _is_normal_interrupt() or not _has_interrupt_context(): return {"reference_issue": "INVALID_ACTIVE_RESPONSE_CONTEXT"}
	var candidate: Dictionary = failure_candidates.get_candidate(active.source_case_id)
	var resolution: Dictionary = containment_resolutions.get_resolution(active.source_case_id)
	if candidate.get("incident_id", "") != active.incident_id or not candidate.get("major_incident_triggered", false) or not candidate.get("disturbance_triggered", false) or resolution.get("result", 0) != MonitoringOutcomeData.Result.FAILURE or resolution.get("incident_id", "") != active.incident_id:
		return {"reference_issue": "ACTIVE_RESPONSE_CANDIDATE_MISMATCH"}
	var source: CaseData = DeveloperDispositionBuilder.find_case(case_sequence, active.source_case_id)
	var incident: IncidentData = DeveloperDispositionBuilder.unique_content(source.incidents, "incident_id", active.incident_id) as IncidentData if source != null else null
	var broadcast: EmergencyBroadcastData = DeveloperDispositionBuilder.unique_content(source.emergency_broadcasts, "broadcast_id", active.broadcast_id) as EmergencyBroadcastData if incident != null and incident.broadcast_id == active.broadcast_id else null
	if broadcast == null: return {"reference_issue": "INVALID_ACTIVE_INCIDENT_BROADCAST_LINK"}
	var result: IncidentResultData = null
	if not active.confirmed_option_id.is_empty():
		var option: BroadcastOptionData = DeveloperDispositionBuilder.unique_content(broadcast.options, "option_id", active.confirmed_option_id) as BroadcastOptionData
		result = DeveloperDispositionBuilder.unique_content(source.incident_results, "result_id", active.incident_result_id) as IncidentResultData if option != null and option.result_id == active.incident_result_id else null
		if result == null: return {"reference_issue": "INVALID_ACTIVE_CONFIRMED_RESULT_LINK"}
	elif not active.incident_result_id.is_empty(): return {"reference_issue": "UNCONFIRMED_ACTIVE_RESULT_ID"}
	var stage: int = _current_stage
	var overlay: bool = stage in [Stage.RESEARCH_ARCHIVE_LIST, Stage.RESEARCH_ARCHIVE_DETAIL]
	if overlay:
		stage = _source_archive_return_stage
		if _archive_detail_case_id != active.source_case_id: return {"reference_issue": "INVALID_ACTIVE_ARCHIVE_SOURCE"}
	if stage not in [Stage.INCIDENT, Stage.BROADCAST, Stage.INCIDENT_RESULT]: return {"reference_issue": "INVALID_ACTIVE_RESPONSE_STAGE"}
	if stage == Stage.INCIDENT_RESULT and result == null: return {"reference_issue": "RESULT_STAGE_WITHOUT_CONFIRMED_RESULT"}
	var stage_index: int = [Stage.INCIDENT, Stage.BROADCAST, Stage.INCIDENT_RESULT].find(stage)
	var known_display: bool = overlay or (is_instance_valid(_current_view) and _current_view.is_visible_in_tree() and _current_view.get_script() == [IncidentView, BroadcastView, IncidentResultView][stage_index] and _current_view.get(["_incident_data", "_broadcast_data", "_incident_result_data"][stage_index]) == [incident, broadcast, result][stage_index])
	var facts: Dictionary = active.duplicate(true)
	facts["interrupted_case_id"] = current_case.case_id
	facts["response_stage"] = Stage.keys()[stage]
	facts["incident_presented"] = true if known_display else "UNKNOWN"
	facts["broadcast_presented"] = (stage != Stage.INCIDENT) if known_display else "UNKNOWN"
	facts["result_displayed"] = (stage == Stage.INCIDENT_RESULT) if known_display else "UNKNOWN"
	if active.confirmed_option_id.is_empty(): facts.confirmed_option_id = null
	if active.incident_result_id.is_empty(): facts.incident_result_id = null
	return facts


func _try_resolve_pending_without_handoff(source: CaseData, closure_prepare: bool = false) -> bool:
	if not _terminal_action_allowed() and not (closure_prepare and _developer_closure_busy and _developer_terminal.mode in [TerminalMode.VOLUNTARY_AWAITING_COMMIT, TerminalMode.FORCED_PREPARING]): return false
	var case_id: String = source.case_id
	var room_id: String = pending_containment.get_pending_room_id(case_id)
	if containment_resolutions.has_resolution(case_id):
		push_warning("Main: hidden containment resolution already exists; retaining Pending.")
		return false
	var matches: Array[MonitoringOutcomeData] = []
	for outcome: MonitoringOutcomeData in source.containment_outcomes:
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
	if result == MonitoringOutcomeData.Result.FAILURE and _unique_response_content(source.incidents, "incident_id", incident_id) == null:
		push_warning("Main: hidden FAILURE requires a unique Incident; retaining Pending.")
		return false
	if not containment_resolutions.try_record_resolution(case_id, room_id, result, incident_id):
		return false
	if result == MonitoringOutcomeData.Result.FAILURE:
		if not failure_candidates.try_add_candidate(case_id, incident_id, _event_rng.randi_range(PROTOTYPE_DISTURBANCE_THRESHOLD.x, PROTOTYPE_DISTURBANCE_THRESHOLD.y), PROTOTYPE_MAJOR_THRESHOLD):
			# No cross-State transaction API: retain the monotonic Resolution AND
			# Pending on insertion failure; never pretend a full prepare succeeded.
			return false
	pending_containment.remove_pending(case_id)
	return true


func _try_process_failure_event_opportunity(view: FlowView, key: String, present_event: bool = true) -> void:
	if not campaign_progress.get_transition().is_empty(): return
	if _is_normal_interrupt() or not incident_responses.get_active_response().is_empty():
		return
	if not _accept_view_action(view) or not view.is_visible_in_tree() or not _has_current_case_runtime() or _case_index < 0 or _case_index >= case_sequence.size() or case_sequence[_case_index] != current_case or _processed_opportunities.has(key):
		return
	var eligible: bool = (_current_stage == Stage.CCTV and key == "cctv:entry") or (_current_stage == Stage.CONTAINMENT and key == "containment:entry")
	if _current_stage == Stage.EXPERIMENT and key.begins_with("experiment:"):
		var experiment_id: String = key.trim_prefix("experiment:")
		eligible = case_runtime.has_executed_experiment(experiment_id)
	if not eligible:
		return
	_processed_opportunities[key] = true
	# Advance Major counters first: this action cannot escalate its own new notice.
	failure_candidates.advance_major_opportunity(current_case.case_id)
	failure_candidates.advance_opportunity(current_case.case_id)
	# New information draws first. Next checkpoints never advance these counters.
	if present_event and _current_stage == Stage.CONTAINMENT:
		_try_present_ready_failure_event(view)


func _has_failure_event_context(view: FlowView) -> bool:
	return _accept_view_action(view) and view.is_visible_in_tree() and _has_current_case_runtime() and _research_display.get("runtime_id", 0) == case_runtime.get_instance_id() and _has_unique_case_sequence() and _case_index >= 0 and _case_index < case_sequence.size() and case_sequence[_case_index] == current_case and not _is_normal_interrupt() and incident_responses.get_active_response().is_empty()


func _mark_research_display(view: FlowView) -> void:
	_research_display = {"view_id": view.get_instance_id(), "runtime_id": case_runtime.get_instance_id(), "process_frame": Engine.get_process_frames(), "draw_frame": Engine.get_frames_drawn()}


func _has_drawn_research_display(view: FlowView) -> bool:
	return _research_display.get("view_id", 0) == view.get_instance_id() and _research_display.get("runtime_id", 0) == case_runtime.get_instance_id() and Engine.get_process_frames() > _research_display.process_frame and (DisplayServer.get_name() == "headless" or Engine.get_frames_drawn() > _research_display.draw_frame)


func _displayed_research_source_id(view: FlowView) -> String:
	if _current_stage == Stage.CCTV and view is CCTVView:
		var cctv: CCTVData = current_case.cctv_data
		if cctv != null and not cctv.camera_id.strip_edges().is_empty() and not cctv.observation_text.strip_edges().is_empty() and (view as CCTVView).is_displaying_cctv(cctv) and (view as CCTVView).observation_label.is_visible_in_tree() and (view as CCTVView).observation_label.text == cctv.observation_text:
			return cctv.camera_id
	elif _current_stage == Stage.EXPERIMENT and view is ExperimentView:
		var id: String = (view as ExperimentView).get_displayed_result_id()
		var matches: Array[ExperimentData] = []
		for experiment: ExperimentData in current_case.available_experiments:
			if experiment != null and experiment.experiment_id == id:
				matches.append(experiment)
		if not id.is_empty() and matches.size() == 1 and case_runtime.has_executed_experiment(id) and (view as ExperimentView).is_displaying_execution_result(matches[0]):
			return id
	return ""


func _grant_event_presentation_credit(kind: String, source_id: String) -> void:
	if not _terminal_action_allowed() or not _has_current_case_runtime() or _is_scripted_response() or not campaign_progress.get_transition().is_empty(): return
	# JSON tuple avoids collisions between Case/local IDs; credit saturates at OPEN.
	var token: String = JSON.stringify([current_case.case_id, kind, source_id])
	if not _completed_research_tokens.has(token):
		_completed_research_tokens[token] = true
		_event_presentation_credit = true


func _try_present_ready_failure_event(view: FlowView, allow_experiment: bool = false) -> bool:
	if not _side_due.is_empty() or _is_side_interrupt() or not _event_presentation_credit or not _has_failure_event_context(view) or (_current_stage not in [Stage.CCTV, Stage.CONTAINMENT] and not (_current_stage == Stage.EXPERIMENT and allow_experiment)):
		return false
	var disturbances: Array[String] = []
	var majors: Array[String] = []
	for id: String in failure_candidates.get_candidate_case_ids():
		if id == current_case.case_id:
			continue
		var candidate: Dictionary = failure_candidates.get_candidate(id)
		if not candidate.disturbance_triggered and candidate.opportunities_seen >= candidate.opportunity_threshold:
			disturbances.append(id)
		elif candidate.disturbance_triggered and not candidate.major_incident_triggered and candidate.major_opportunity_count >= candidate.major_trigger_threshold:
			majors.append(id)
	return _try_present_oldest_actionable_event(disturbances, majors, allow_experiment)


func _try_present_oldest_actionable_event(disturbance_ready: Array[String], major_ready: Array[String], allow_experiment: bool = false) -> bool:
	if not _terminal_action_allowed(): return false
	if not _event_presentation_credit:
		return false
	# Registration order is the source of truth, independent of event type/Case ID.
	# A non-presentable older candidate does not block a later actionable one.
	for source_case_id: String in failure_candidates.get_candidate_case_ids():
		var candidate: Dictionary = failure_candidates.get_candidate(source_case_id)
		if incident_responses.has_response(_case_response_source(source_case_id), candidate.incident_id):
			continue
		if disturbance_ready.has(source_case_id) and _try_present_candidate_disturbance(source_case_id):
			return true
		# EXP permits Major only at the caller's explicit result-read Next boundary.
		if (_current_stage in [Stage.CCTV, Stage.CONTAINMENT] or (_current_stage == Stage.EXPERIMENT and allow_experiment)) and major_ready.has(source_case_id) and _try_start_major_incident(source_case_id):
			return true
	return false


func _try_present_candidate_disturbance(source_case_id: String) -> bool:
	if not _terminal_action_allowed() or not _has_current_case_runtime() or not incident_responses.get_active_response().is_empty(): return false
	if not _event_presentation_credit:
		return false
	var candidate: Dictionary = failure_candidates.get_candidate(source_case_id)
	var resolution: Dictionary = containment_resolutions.get_resolution(source_case_id)
	if candidate.is_empty() or candidate.disturbance_triggered or candidate.opportunities_seen < candidate.opportunity_threshold:
		return false
	if resolution.get("result", MonitoringOutcomeData.Result.UNDEFINED) != MonitoringOutcomeData.Result.FAILURE or resolution.get("incident_id", "") != candidate.incident_id:
		push_warning("Main: failure candidate does not match hidden resolution; retaining candidate.")
		return false
	var source_case: CaseData = _find_failure_source_case(source_case_id)
	if source_case == null:
		return false
	var incidents: Array[IncidentData] = []
	for incident: IncidentData in source_case.incidents:
		if incident != null and incident.incident_id == candidate.incident_id:
			incidents.append(incident)
	var disturbance: EnvironmentalDisturbanceData = incidents[0].environmental_disturbance if incidents.size() == 1 else null
	if disturbance == null or disturbance.disturbance_id.strip_edges().is_empty() or disturbance.display_name.strip_edges().is_empty() or disturbance.notice_text.strip_edges().is_empty() or disturbance.condition_change_text.strip_edges().is_empty():
		push_warning("Main: failure candidate has no unique valid environmental disturbance; retaining candidate.")
		return false
	var reaction: CaseDisturbanceReactionData = _find_disturbance_reaction(disturbance.disturbance_id)
	if not case_runtime.try_apply_disturbance(disturbance.disturbance_id, reaction.reaction_id if reaction != null else ""):
		return false
	failure_candidates.try_mark_disturbance_triggered(source_case_id)
	_refresh_current_environment_conditions()
	_show_disturbance_notice(disturbance, reaction)
	_event_presentation_credit = false
	if reaction != null:
		_try_discover_research_entry(ResearchEntryData.SourceKind.DISTURBANCE_REACTION, reaction.reaction_id)
	return true


func _refresh_current_environment_conditions() -> void:
	if _current_view is CCTVView or _current_view is ExperimentView or _current_view is ContainmentView:
		var summary: EnvironmentConditions.Summary = _build_environment_summary()
		_current_view.set_environment_conditions(summary)


func _is_normal_interrupt() -> bool:
	return _incident_route == IncidentRoute.NORMAL_INTERRUPT


func _unique_response_content(items: Array, id_field: String, id: String) -> Resource:
	var matches: Array[Resource] = []
	for item: Resource in items:
		if item != null and item.get(id_field) == id:
			matches.append(item)
	if id.strip_edges().is_empty() or matches.size() != 1:
		push_warning("Main: response content missing or ambiguous for %s/%s; retaining response/candidate." % [id_field, id])
		return null
	return matches[0]


func _response_source_case() -> CaseData:
	var response: Dictionary = incident_responses.get_active_response()
	if response.get("origin_kind", -1) != IncidentSource.OriginKind.CASE: return null
	var source: IncidentSource = _case_response_source(response.source_definition_id)
	return _find_failure_source_case(response.source_definition_id) if source != null and source.matches(response) else null


func _response_incident() -> IncidentData:
	var scope: Resource = _response_content_scope()
	if scope is ScriptedIncidentData:
		var incident: IncidentData = (scope as ScriptedIncidentData).incident_data
		return incident if incident.incident_id == incident_responses.get_active_response().incident_id else null
	return _unique_response_content(scope.get("incidents"), "incident_id", incident_responses.get_active_response().incident_id) as IncidentData if scope != null else null


func _response_broadcast() -> EmergencyBroadcastData:
	var source: Resource = _response_content_scope()
	var incident: IncidentData = _response_incident()
	if source == null or incident == null or incident.broadcast_id != incident_responses.get_active_response().broadcast_id:
		return null
	return _unique_response_content(source.get("emergency_broadcasts"), "broadcast_id", incident.broadcast_id) as EmergencyBroadcastData


func _response_option(option_id: String = "") -> BroadcastOptionData:
	var broadcast: EmergencyBroadcastData = _response_broadcast()
	var id: String = option_id if not option_id.is_empty() else incident_responses.get_active_response().get("confirmed_option_id", "")
	if broadcast == null or id.is_empty():
		return null
	return _unique_response_content(broadcast.options, "option_id", id) as BroadcastOptionData


func _response_result(option: BroadcastOptionData = null) -> IncidentResultData:
	var source: Resource = _response_content_scope()
	var selected: BroadcastOptionData = option if option != null else _response_option()
	if source == null or selected == null:
		return null
	if option == null and selected.result_id != incident_responses.get_active_response().get("incident_result_id", ""):
		push_warning("Main: confirmed response result link changed; retaining response.")
		return null
	return _unique_response_content(source.get("incident_results"), "result_id", selected.result_id) as IncidentResultData


func _has_interrupt_context() -> bool:
	if _is_side_interrupt(): return _bound_side_interrupt() != null
	return _has_current_case_runtime() and _interrupt_context.get("interrupted_case_id", "") == current_case.case_id and _interrupt_context.get("runtime_instance_id", -1) == case_runtime.get_instance_id() and _interrupt_context.get("case_instance_id", -1) == current_case.get_instance_id() and _interrupt_context.get("return_stage", -1) in [Stage.CCTV, Stage.EXPERIMENT, Stage.CONTAINMENT]


func _build_response_display_context() -> Dictionary:
	if _is_side_interrupt():
		var occurrence: ScriptedInterruptOccurrenceData = _bound_side_interrupt()
		return {"origin_kind": IncidentSource.OriginKind.CAMPAIGN_INTERRUPT, "source_occurrence_id": occurrence.interrupt_id, "event_id": occurrence.scripted_incident_data.event_id, "interrupted_case_id": current_case.case_id, "interrupted_case_display_name": current_case.display_name, "return_stage": Stage.keys()[_interrupt_context.return_stage], "return_policy": "RESUME_INTERRUPTED_CASE"} if occurrence != null else {}
	if _is_scripted_response():
		var entry: CampaignEntryData = _bound_scripted_entry()
		return {"origin_kind": IncidentSource.OriginKind.CAMPAIGN_ENTRY, "source_entry_id": entry.entry_id, "event_id": entry.scripted_incident_data.event_id, "return_policy": "ADVANCE_CAMPAIGN_ENTRY"} if entry != null else {}
	if not _is_normal_interrupt() or not _has_interrupt_context():
		return {}
	var source: CaseData = _response_source_case()
	if source == null or source.display_name.strip_edges().is_empty():
		return {}
	return {"source_case_id": source.case_id, "source_case_display_name": source.display_name, "interrupted_case_id": current_case.case_id, "interrupted_case_display_name": current_case.display_name, "return_stage": Stage.keys()[_interrupt_context.return_stage]}


func _restore_response_broadcast_draft(view: BroadcastView) -> void:
	var draft: Dictionary = _interrupt_context.get("broadcast_draft", {}).duplicate()
	_interrupt_context.erase("broadcast_draft")
	if draft.is_empty() or not _is_response_route() or _current_stage != Stage.BROADCAST or not _has_response_context() or not _accept_view_action(view, "response"):
		return
	var response: Dictionary = incident_responses.get_active_response()
	if not response.get("confirmed_option_id", "").is_empty() or not IncidentSource.from_record(response).matches(draft) or draft.get("incident_id", "") != response.get("incident_id", "") or draft.get("broadcast_id", "") != response.get("broadcast_id", ""):
		return
	var option: BroadcastOptionData = _response_option(draft.get("option_id", ""))
	if option != null and _response_result(option) != null:
		view.restore_unconfirmed_option(option.option_id)


func _try_start_major_incident(source_case_id: String) -> bool:
	if not _terminal_action_allowed(): return false
	if not _side_due.is_empty() or _is_side_interrupt() or not _event_presentation_credit or _is_normal_interrupt() or not incident_responses.get_active_response().is_empty() or _current_stage not in [Stage.CCTV, Stage.EXPERIMENT, Stage.CONTAINMENT] or not _is_active_view(_current_view):
		return false
	var candidate: Dictionary = failure_candidates.get_candidate(source_case_id)
	var resolution: Dictionary = containment_resolutions.get_resolution(source_case_id)
	if candidate.is_empty() or not candidate.disturbance_triggered or candidate.major_incident_triggered or candidate.major_opportunity_count < candidate.major_trigger_threshold or resolution.get("result", MonitoringOutcomeData.Result.UNDEFINED) != MonitoringOutcomeData.Result.FAILURE or resolution.get("incident_id", "") != candidate.incident_id or incident_responses.has_response(_case_response_source(source_case_id), candidate.incident_id):
		return false
	var source: CaseData = _find_failure_source_case(source_case_id)
	if source == null:
		return false
	var incident: IncidentData = _unique_response_content(source.incidents, "incident_id", candidate.incident_id) as IncidentData
	if incident == null or incident.display_name.strip_edges().is_empty() or incident.description.strip_edges().is_empty():
		push_warning("Main: Major Incident has no valid display content; retaining candidate.")
		return false
	var broadcast: EmergencyBroadcastData = _unique_response_content(source.emergency_broadcasts, "broadcast_id", incident.broadcast_id) as EmergencyBroadcastData
	if broadcast == null or broadcast.display_name.strip_edges().is_empty() or broadcast.prompt_text.strip_edges().is_empty():
		push_warning("Main: Major Incident has no valid Broadcast; retaining candidate.")
		return false
	var usable: bool = false
	for option: BroadcastOptionData in broadcast.options:
		if option == null or option.option_id.strip_edges().is_empty() or option.display_text.strip_edges().is_empty():
			continue
		if _unique_response_content(broadcast.options, "option_id", option.option_id) != option:
			continue
		var result: IncidentResultData = _unique_response_content(source.incident_results, "result_id", option.result_id) as IncidentResultData
		if result != null and not result.display_name.strip_edges().is_empty() and not result.description.strip_edges().is_empty():
			usable = true
	if not usable:
		push_warning("Main: Major Incident has no usable response chain; retaining candidate.")
		return false
	if not incident_responses.try_begin(_case_response_source(source_case_id), incident.incident_id, broadcast.broadcast_id):
		return false
	failure_candidates.try_mark_major_triggered(source_case_id)
	_interrupt_context = {"interrupted_case_id": current_case.case_id, "return_stage": _current_stage, "runtime_instance_id": case_runtime.get_instance_id(), "case_instance_id": current_case.get_instance_id()}
	_incident_route = IncidentRoute.NORMAL_INTERRUPT
	_show_view(Stage.INCIDENT)
	_event_presentation_credit = false
	return true


func _merge_response_research(source_kind: int, source_id: String) -> void:
	if not _terminal_action_allowed("response"): return
	if _developer_terminal.mode == TerminalMode.VOLUNTARY_RESPONSE_ONLY:
		var active: Dictionary = incident_responses.get_active_response()
		var actual: Dictionary = {
			ResearchEntryData.SourceKind.INCIDENT: [Stage.INCIDENT, active.incident_id],
			ResearchEntryData.SourceKind.BROADCAST: [Stage.BROADCAST, active.broadcast_id],
			ResearchEntryData.SourceKind.BROADCAST_OPTION: [Stage.BROADCAST, active.confirmed_option_id],
			ResearchEntryData.SourceKind.INCIDENT_RESULT: [Stage.INCIDENT_RESULT, active.incident_result_id],
		}
		if not actual.has(source_kind) or actual[source_kind] != [_current_stage, source_id] or source_id.is_empty(): return
	var source: CaseData = _response_source_case()
	if source == null:
		return
	var entry: ResearchEntryData = _find_research_entry(_get_valid_research_entries(source), source_kind, source_id)
	if entry != null:
		var ids: Array[String] = [entry.entry_id]
		research_archive.merge_case_discoveries(source.case_id, ids)


func _discover_response_research(stage: int, source: Resource) -> void:
	if not _has_interrupt_context() or not _is_active_view(_current_view) or not _current_view.is_visible_in_tree():
		return
	match stage:
		Stage.INCIDENT:
			if source != null and source == _response_incident() and not _current_view.next_button.disabled:
				_merge_response_research(ResearchEntryData.SourceKind.INCIDENT, (source as IncidentData).incident_id)
		Stage.BROADCAST:
			if source != null and source == _response_broadcast() and _has_valid_broadcast_options(source as EmergencyBroadcastData):
				_merge_response_research(ResearchEntryData.SourceKind.BROADCAST, (source as EmergencyBroadcastData).broadcast_id)
		Stage.INCIDENT_RESULT:
			if source != null and source == _response_result() and not _current_view.next_button.disabled:
				_merge_response_research(ResearchEntryData.SourceKind.INCIDENT_RESULT, (source as IncidentResultData).result_id)


func _confirm_response_option(broadcast_id: String, option_id: String, view: BroadcastView) -> void:
	if not _accept_view_action(view, "response"): return
	if not _has_response_context() or not view.is_visible_in_tree():
		return
	var response: Dictionary = incident_responses.get_active_response()
	var broadcast: EmergencyBroadcastData = _response_broadcast()
	if response.is_empty() or broadcast == null or broadcast.broadcast_id != broadcast_id or view.get("_broadcast_data") != broadcast:
		return
	if response.confirmed_option_id.is_empty():
		var option: BroadcastOptionData = _response_option(option_id)
		var result: IncidentResultData = _response_result(option) if option != null else null
		if result != null and not option.display_text.strip_edges().is_empty() and not result.display_name.strip_edges().is_empty() and not result.description.strip_edges().is_empty():
			if incident_responses.try_confirm(IncidentSource.from_record(response), response.incident_id, broadcast_id, option_id, result.result_id):
				_merge_response_research(ResearchEntryData.SourceKind.BROADCAST_OPTION, option_id)
	response = incident_responses.get_active_response()
	if _is_side_interrupt(): view.set_meta("interrupt_response_binding", response)
	view.update_confirmation_state(response.broadcast_id if not response.confirmed_option_id.is_empty() else "", response.confirmed_option_id)


func _advance_response(view: FlowView) -> void:
	if not _accept_view_action(view, "response"): return
	if not _has_response_context() or not view.is_visible_in_tree() or view.next_button.disabled:
		return
	match _current_stage:
		Stage.INCIDENT:
			if view.get("_incident_data") == _response_incident() and _response_broadcast() != null:
				_show_view(Stage.BROADCAST)
		Stage.BROADCAST:
			if view.get("_broadcast_data") == _response_broadcast() and _response_result() != null:
				_show_view(Stage.INCIDENT_RESULT)
		Stage.INCIDENT_RESULT:
			var response: Dictionary = incident_responses.get_active_response()
			var result: IncidentResultData = _response_result()
			if _is_side_interrupt():
				if result == null or view.get("_incident_result_data") != result or result.result_id != response.get("incident_result_id", ""): return
				_resume_side_work(response)
				return
			if _is_scripted_response():
				var entry: CampaignEntryData = _bound_scripted_entry()
				if entry == null or result == null or view.get("_incident_result_data") != result or result.result_id != response.get("incident_result_id", "") or not campaign_progress.can_complete_current(entry.entry_id): return
				if not incident_responses.try_complete(IncidentSource.from_record(response), response.incident_id): return
				if not campaign_progress.try_complete_and_advance(entry.entry_id): return
				_interrupt_context.clear()
				_source_archive_return_stage = -1
				_incident_route = IncidentRoute.DEBUG_RUNTIME
				_dispatch_campaign_entry()
				return
			var candidate: Dictionary = failure_candidates.get_candidate(response.get("source_case_id", ""))
			if result == null or view.get("_incident_result_data") != result or result.result_id != response.get("incident_result_id", "") or candidate.get("incident_id", "") != response.get("incident_id", "") or not candidate.get("major_incident_triggered", false):
				return
			if not incident_responses.try_complete(IncidentSource.from_record(response), response.incident_id):
				return
			failure_candidates.remove_completed_candidate(response.source_case_id, response.incident_id)
			var return_stage: int = _interrupt_context.return_stage
			_interrupt_context.clear()
			_source_archive_return_stage = -1
			_incident_route = IncidentRoute.DEBUG_RUNTIME
			_show_view(return_stage, false)
			if return_stage == Stage.EXPERIMENT:
				_restore_interrupted_experiment_result(_current_view as ExperimentView)
			if _developer_terminal.mode == TerminalMode.VOLUNTARY_RESPONSE_ONLY:
				_developer_terminal.mode = TerminalMode.VOLUNTARY_AWAITING_COMMIT


func _on_source_archive_requested(view: FlowView, source_stage: int) -> void:
	if not _is_response_route() or not _has_response_context() or source_stage != _current_stage or source_stage not in [Stage.INCIDENT, Stage.BROADCAST, Stage.INCIDENT_RESULT] or not _accept_view_action(view, "archive") or not view.is_visible_in_tree():
		return
	var source: CaseData = _response_source_case()
	if not (_is_scripted_response() or _is_side_interrupt()) and (source == null or not research_archive.get_archived_case_ids().has(source.case_id)):
		return
	_interrupt_context.erase("broadcast_draft")
	if view is BroadcastView and incident_responses.get_active_response().confirmed_option_id.is_empty() and view.get("_broadcast_data") == _response_broadcast():
		var option_id: String = (view as BroadcastView).get_unconfirmed_option_id()
		var option: BroadcastOptionData = _response_option(option_id) if not option_id.is_empty() else null
		if option != null and _response_result(option) != null:
			var response: Dictionary = incident_responses.get_active_response()
			var draft: Dictionary = IncidentSource.from_record(response).to_dictionary()
			draft.merge({"incident_id": response.incident_id, "broadcast_id": response.broadcast_id, "option_id": option_id})
			_interrupt_context["broadcast_draft"] = draft
	_source_archive_return_stage = source_stage
	_archive_detail_case_id = source.case_id if source != null else ""
	_show_view(Stage.RESEARCH_ARCHIVE_LIST if _is_scripted_response() or _is_side_interrupt() else Stage.RESEARCH_ARCHIVE_DETAIL, false)


func _restore_interrupted_experiment_result(view: ExperimentView) -> void:
	if _developer_terminal.mode not in [TerminalMode.NONE, TerminalMode.VOLUNTARY_RESPONSE_ONLY] or not _is_active_view(view): return
	var history: Array[String] = case_runtime.get_experiment_execution_history()
	if history.is_empty():
		return
	var id: String = history[-1]
	view.restore_recorded_result(id, _recorded_experiment_conditions(id))
	_mark_research_display(view)


func _recorded_experiment_conditions(id: String) -> ExperimentView.ConditionSnapshot:
	var snapshot := ExperimentView.ConditionSnapshot.new()
	for observation_id: String in case_runtime.get_experiment_condition_observation_ids(id):
		var data: ExperimentConditionObservationData = _unique_response_content(current_case.experiment_condition_observations, "observation_id", observation_id) as ExperimentConditionObservationData
		if data == null or data.experiment_id != id:
			continue
		var condition: EnvironmentalDisturbanceData = _find_environment_condition_data(data.disturbance_id)
		snapshot.entries.append(ExperimentView.ConditionObservation.new(data.observation_id, data.display_name, data.observation_text, condition.display_name if condition != null else "[Unavailable]", condition.condition_change_text if condition != null else "[Unavailable]"))
	return snapshot


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


func _discover_cctv_condition_observations(view: CCTVView) -> void:
	if not _terminal_action_allowed(): return
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
	_close_drawer(false)
	if not _terminal_action_allowed(): return
	_focus_before_notice = get_viewport().gui_get_focus_owner()
	_view_process_mode_before_notice = view_host.process_mode
	view_host.process_mode = Node.PROCESS_MODE_DISABLED
	_disturbance_notice = DISTURBANCE_NOTICE_SCENE.instantiate()
	_disturbance_notice.setup(disturbance, reaction)
	_disturbance_notice.dismissed.connect(_on_disturbance_dismissed.bind(_disturbance_notice))
	add_child(_disturbance_notice)
	_refresh_shell()


func _on_disturbance_dismissed(notice: DisturbanceNotice) -> void:
	if _developer_closure_busy or not _terminal_action_allowed(): return
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
	if not _side_due.is_empty(): _present_due_side_after_draw(_current_view)
	_refresh_shell()


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
	if _current_stage != Stage.MONITORING or not _accept_view_action(monitoring_view):
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
	if _current_stage != Stage.EXPERIMENT or not _accept_view_action(experiment_view) or not experiment_view.is_visible_in_tree() or not _has_current_case_runtime():
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
		if _research_display.get("runtime_id", 0) == case_runtime.get_instance_id() and experiment_view.get_displayed_result_id() == experiment_id:
			_mark_research_display(experiment_view)
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
	if _current_stage != Stage.CONTAINMENT or not _accept_view_action(containment_view) or not _has_current_case_runtime():
		return
	if not containment_view.is_visible_in_tree() or _research_display.get("runtime_id", 0) != case_runtime.get_instance_id():
		return
	if current_case != null and not room_id.strip_edges().is_empty():
		for room: ContainmentData in current_case.available_containment_rooms:
			if room != null and room.room_id == room_id:
				if case_runtime.try_confirm_containment_room(room_id):
					# Submission survives Runtime reset; debug playback does not resolve it.
					pending_containment.try_add_pending(current_case.case_id, case_runtime.get_confirmed_containment_room_id())
					_try_discover_research_entry(ResearchEntryData.SourceKind.CONTAINMENT, room_id)
					if _has_failure_event_context(containment_view):
						_grant_event_presentation_credit("containment", room_id)
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
func _current_campaign_entry() -> CampaignEntryData:
	return campaign_data.get_entry(campaign_progress.get_current_entry_id()) if campaign_data != null and campaign_progress != null else null


func _next_campaign_entry() -> CampaignEntryData:
	return campaign_data.get_entry(campaign_progress.get_next_entry_id()) if campaign_data != null and campaign_progress != null else null


func _case_response_source(case_id: String) -> IncidentSource:
	var entry: CampaignEntryData = campaign_data.get_case_entry(case_id) if campaign_data != null else null
	return IncidentSource.new(IncidentSource.OriginKind.CASE, entry.entry_id, case_id) if entry != null else null


func _is_scripted_response() -> bool:
	return _incident_route == IncidentRoute.SCRIPTED_CAMPAIGN


func _is_response_route() -> bool:
	return _is_normal_interrupt() or _is_scripted_response() or _is_side_interrupt()


func _bound_scripted_entry() -> CampaignEntryData:
	var entry: CampaignEntryData = _current_campaign_entry()
	if entry == null or entry.entry_kind != CampaignEntryData.EntryKind.SCRIPTED_INCIDENT or current_case != null or case_runtime != null or not entry.get_validation_error().is_empty(): return null
	var source := IncidentSource.new(IncidentSource.OriginKind.CAMPAIGN_ENTRY, entry.entry_id, entry.scripted_incident_data.event_id)
	return entry if source.matches(incident_responses.get_active_response()) and _interrupt_context.get("source_occurrence_id", "") == entry.entry_id and _interrupt_context.get("event_id", "") == source.source_definition_id else null


func _has_response_context() -> bool:
	if _is_side_interrupt(): return _bound_side_interrupt() != null
	return _has_interrupt_context() if _is_normal_interrupt() else (_is_scripted_response() and _bound_scripted_entry() != null)


func _response_content_scope() -> Resource:
	if _is_side_interrupt():
		var occurrence: ScriptedInterruptOccurrenceData = _bound_side_interrupt()
		return occurrence.scripted_incident_data if occurrence != null else null
	if _is_scripted_response():
		var entry: CampaignEntryData = _bound_scripted_entry()
		return entry.scripted_incident_data if entry != null else null
	return _response_source_case()


func _case_response_records() -> Array[Dictionary]:
	var records: Array[Dictionary] = []
	for response: Dictionary in incident_responses.get_responses():
		if response.origin_kind == IncidentSource.OriginKind.CASE: records.append(response)
	return records


func _dispatch_campaign_entry() -> void:
	if not _terminal_action_allowed(): return
	if _campaign_fact_queries != null: _campaign_fact_queries.clear_current_runtime()
	current_case = null
	case_runtime = null
	_research_log_return_stage = -1
	_cctv_review_return_stage = -1
	_archive_detail_case_id = ""
	_processed_opportunities.clear()
	_research_display.clear()
	var entry: CampaignEntryData = _current_campaign_entry()
	if entry == null:
		# Last scripted test entry may complete, but there is no Ending dispatch.
		if is_instance_valid(_current_view):
			_current_view.next_button.disabled = true
			_current_view.next_button.text = "No next Campaign entry configured"
			if _current_view.research_log_button != null: _current_view.research_log_button.disabled = true
		return
	if entry.entry_kind == CampaignEntryData.EntryKind.CASE:
		current_case = entry.case_data
		_validate_case()
		case_runtime = CaseRuntimeState.new(current_case.case_id)
		_campaign_fact_queries.set_current_runtime(entry.entry_id, current_case.case_id, case_runtime)
		_show_view(Stage.PROFILE)
		return
	var data: ScriptedIncidentData = entry.scripted_incident_data
	var source := IncidentSource.new(IncidentSource.OriginKind.CAMPAIGN_ENTRY, entry.entry_id, data.event_id)
	if not incident_responses.try_begin(source, data.incident_data.incident_id, data.incident_data.broadcast_id):
		push_error("Main: Campaign response could not start for entry " + entry.entry_id)
		return
	_interrupt_context = {"source_occurrence_id": entry.entry_id, "event_id": data.event_id}
	_incident_route = IncidentRoute.SCRIPTED_CAMPAIGN
	_show_view(Stage.INCIDENT)


func _is_side_interrupt() -> bool:
	return _incident_route == IncidentRoute.SCRIPTED_INTERRUPT


func _side_boundary_status() -> String:
	if _side_restore_pending: return "UNSUPPORTED_INTERRUPT_RESUME_PENDING"
	if incident_responses != null and incident_responses.get_active_response().get("origin_kind", -1) == IncidentSource.OriginKind.CAMPAIGN_INTERRUPT: return "UNSUPPORTED_ACTIVE_CAMPAIGN_RESPONSE"
	if not _side_due.is_empty(): return "UNSUPPORTED_DUE_CAMPAIGN_INTERRUPT"
	if _is_side_interrupt(): return "UNSUPPORTED_INTERRUPT_CONTEXT"
	return ""


func _side_checkpoint_at(kind: int, action: String) -> ScriptedInterruptOccurrenceData:
	if campaign_data == null or campaign_progress == null or _current_stage not in [Stage.PROFILE, Stage.CCTV, Stage.EXPERIMENT, Stage.CONTAINMENT] or not campaign_data.get_validation_error().is_empty(): return null
	var occurrence: ScriptedInterruptOccurrenceData = campaign_data.get_interrupt_at_checkpoint(campaign_progress.get_current_entry_id(), kind, Stage.keys()[_current_stage], action)
	if occurrence == null or incident_responses.has_response(occurrence.get_source(), occurrence.scripted_incident_data.incident_data.incident_id): return null
	return occurrence


func _latch_side_checkpoint(occurrence: ScriptedInterruptOccurrenceData, view: FlowView) -> bool:
	# A notice may disable input after a reached checkpoint; retain its intent.
	# No progression, history, failure credit or completed-occurrence set lives here.
	if occurrence == null or campaign_data == null or not campaign_data.get_validation_error().is_empty() or campaign_data.get_interrupt(occurrence.interrupt_id) != occurrence or _developer_terminal.mode != TerminalMode.NONE or _developer_closure_busy or _side_restore_pending: return false
	var entry: CampaignEntryData = _current_campaign_entry()
	if entry == null or entry.entry_kind != CampaignEntryData.EntryKind.CASE or entry.entry_id != occurrence.target_entry_id or entry.case_data != current_case or not _has_current_case_runtime() or Stage.keys()[_current_stage] != occurrence.stage_id: return false
	if not is_instance_valid(view) or view != _current_view or not view.is_inside_tree() or view.is_queued_for_deletion() or not view.is_visible_in_tree(): return false
	if occurrence.checkpoint_kind == ScriptedInterruptOccurrenceData.CheckpointKind.ACTION_ACCEPTED and (not _has_drawn_research_display(view) or _displayed_research_source_id(view).is_empty() or occurrence.action_id != ScriptedInterruptOccurrenceData.EXPERIMENT_RESULT_READ): return false
	if incident_responses.has_response(occurrence.get_source(), occurrence.scripted_incident_data.incident_data.incident_id): return false
	var intent: Dictionary = {"interrupt_id": occurrence.interrupt_id, "target_entry_id": entry.entry_id, "checkpoint_key": occurrence.checkpoint_key(), "view_id": view.get_instance_id(), "runtime_instance_id": case_runtime.get_instance_id(), "case_instance_id": current_case.get_instance_id(), "action_source_id": _displayed_research_source_id(view) if occurrence.checkpoint_kind == ScriptedInterruptOccurrenceData.CheckpointKind.ACTION_ACCEPTED else ""}
	if not _side_due.is_empty(): return _side_due == intent
	_side_due = intent
	return true


func _present_due_side_after_draw(view: FlowView) -> void:
	# Setup/add_child precede this checkpoint. Yield for actual state/layout/draw.
	await get_tree().process_frame
	await get_tree().process_frame
	if DisplayServer.get_name() != "headless": await RenderingServer.frame_post_draw
	if not is_inside_tree() or not is_instance_valid(view) or view != _current_view or view.is_queued_for_deletion(): return
	_try_present_side_interrupt()


func _try_present_side_interrupt() -> bool:
	if not _side_due.is_empty() and is_instance_valid(_drawer_view): _close_drawer()
	if _side_due.is_empty() or _developer_terminal.mode != TerminalMode.NONE or _developer_closure_busy or _side_restore_pending or _is_response_route() or not _interrupt_context.is_empty() or not _is_active_view(_current_view) or not incident_responses.get_active_response().is_empty(): return false
	if campaign_data == null or not campaign_data.get_validation_error().is_empty() or not _has_current_case_runtime(): return false
	var occurrence: ScriptedInterruptOccurrenceData = campaign_data.get_interrupt(_side_due.get("interrupt_id", ""))
	var entry: CampaignEntryData = _current_campaign_entry()
	if occurrence == null or entry == null or entry.entry_kind != CampaignEntryData.EntryKind.CASE or entry.entry_id != occurrence.target_entry_id or entry.entry_id != _side_due.get("target_entry_id", "") or entry.case_data != current_case or occurrence.checkpoint_key() != _side_due.get("checkpoint_key", "") or occurrence.stage_id != Stage.keys()[_current_stage]: return false
	if _side_due.get("view_id", 0) != _current_view.get_instance_id() or _side_due.get("runtime_instance_id", 0) != case_runtime.get_instance_id() or _side_due.get("case_instance_id", 0) != current_case.get_instance_id() or not _has_drawn_research_display(_current_view): return false
	if occurrence.checkpoint_kind == ScriptedInterruptOccurrenceData.CheckpointKind.ACTION_ACCEPTED and (_side_due.get("action_source_id", "").is_empty() or _side_due.action_source_id != _displayed_research_source_id(_current_view)): return false
	var state: Dictionary = _current_view.capture_work_state()
	if not InterruptedWorkViewState.get_validation_error(occurrence.stage_id, state, current_case, case_runtime, pending_containment, containment_resolutions).is_empty(): return false
	var source: IncidentSource = occurrence.get_source()
	var incident: IncidentData = occurrence.scripted_incident_data.incident_data
	if incident_responses.has_response(source, incident.incident_id): return false
	var context: Dictionary = source.to_dictionary()
	context.merge({"interrupted_entry_id": entry.entry_id, "interrupted_case_id": current_case.case_id, "return_stage": _current_stage, "runtime_instance_id": case_runtime.get_instance_id(), "case_instance_id": current_case.get_instance_id(), "incident_id": incident.incident_id, "return_policy": "RESUME_INTERRUPTED_CASE", "work_view_state": state.duplicate(true), "cctv_review_return_stage": _cctv_review_return_stage})
	if not incident_responses.try_begin(source, incident.incident_id, incident.broadcast_id): return false
	_interrupt_context = context
	_side_due.clear()
	_side_resume_error = ""
	_incident_route = IncidentRoute.SCRIPTED_INTERRUPT
	_show_view(Stage.INCIDENT, false)
	return true


func _bound_side_interrupt(allow_completed: bool = false) -> ScriptedInterruptOccurrenceData:
	if not _is_side_interrupt() or campaign_data == null or campaign_progress == null or not campaign_data.get_validation_error().is_empty() or not _has_current_case_runtime(): return null
	var occurrence: ScriptedInterruptOccurrenceData = campaign_data.get_interrupt(_interrupt_context.get("source_occurrence_id", ""))
	var entry: CampaignEntryData = _current_campaign_entry()
	if occurrence == null or entry == null or entry.entry_kind != CampaignEntryData.EntryKind.CASE or entry.entry_id != occurrence.target_entry_id or entry.case_data != current_case or _interrupt_context.get("interrupted_entry_id", "") != entry.entry_id or _interrupt_context.get("interrupted_case_id", "") != current_case.case_id or _interrupt_context.get("runtime_instance_id", 0) != case_runtime.get_instance_id() or _interrupt_context.get("case_instance_id", 0) != current_case.get_instance_id() or _interrupt_context.get("return_policy", "") != "RESUME_INTERRUPTED_CASE" or _interrupt_context.get("return_stage", -1) not in [Stage.PROFILE, Stage.CCTV, Stage.EXPERIMENT, Stage.CONTAINMENT]: return null
	if Stage.keys()[_interrupt_context.return_stage] != occurrence.stage_id: return null
	var source: IncidentSource = occurrence.get_source()
	var incident: IncidentData = occurrence.scripted_incident_data.incident_data
	if not source.matches(_interrupt_context) or _interrupt_context.get("incident_id", "") != incident.incident_id: return null
	for record: Dictionary in incident_responses.get_responses():
		if source.matches(record) and record.get("incident_id", "") == incident.incident_id and record.get("broadcast_id", "") == incident.broadcast_id and record.get("status", -1) == (IncidentResponseState.Status.COMPLETED if allow_completed else IncidentResponseState.Status.ACTIVE): return occurrence
	return null


func _resume_side_work(response: Dictionary) -> void:
	var occurrence: ScriptedInterruptOccurrenceData = _bound_side_interrupt()
	if occurrence == null or _developer_terminal.mode != TerminalMode.NONE or _developer_closure_busy or _side_restore_pending: return
	var stage_id: String = Stage.keys()[_interrupt_context.return_stage]
	var error: String = InterruptedWorkViewState.get_validation_error(stage_id, _interrupt_context.get("work_view_state", {}), current_case, case_runtime, pending_containment, containment_resolutions)
	if not error.is_empty():
		_side_resume_error = error
		return
	if _interrupt_context.get("cctv_review_return_stage", -2) not in [-1, Stage.EXPERIMENT, Stage.CONTAINMENT]:
		_side_resume_error = "INVALID_CCTV_REVIEW_RETURN"
		return
	if not occurrence.get_source().matches(response) or response.get("incident_result_id", "").is_empty(): return
	if not incident_responses.try_complete(occurrence.get_source(), response.incident_id): return
	_side_restore_pending = true
	_restore_side_work()


func _restore_side_work() -> void:
	# Also supports an explicit developer retry of retained resume-pending state.
	# Completion and UI restoration are not an atomic cross-object transaction.
	if not _side_restore_pending or _bound_side_interrupt(true) == null or _developer_terminal.mode != TerminalMode.NONE or _developer_closure_busy: return
	var state: Dictionary = _interrupt_context.work_view_state.duplicate(true)
	var stage: int = _interrupt_context.return_stage
	var error: String = InterruptedWorkViewState.get_validation_error(Stage.keys()[stage], state, current_case, case_runtime, pending_containment, containment_resolutions)
	if not error.is_empty():
		_side_resume_error = error
		return
	_cctv_review_return_stage = _interrupt_context.cctv_review_return_stage
	_show_view(stage, false, true)
	var restored: FlowView = _current_view
	if stage == Stage.EXPERIMENT and not (restored as ExperimentView).restore_work_result(state, _recorded_experiment_conditions(state.displayed_result_id)):
		_side_resume_error = "EXPERIMENT_RESULT_RESTORE_FAILED"
		return
	# Containers recalculate scroll ranges after layout. Keep all input closed.
	await get_tree().process_frame
	await get_tree().process_frame
	if DisplayServer.get_name() != "headless": await RenderingServer.frame_post_draw
	if not is_inside_tree(): return
	if not is_instance_valid(restored) or restored != _current_view or restored.is_queued_for_deletion() or _bound_side_interrupt(true) == null:
		_side_resume_error = "RESTORED_VIEW_OR_SOURCE_UNAVAILABLE"
		return
	if not restored.restore_work_state(state) or restored.capture_work_state() != state:
		_side_resume_error = "WORK_VIEW_RESTORE_FAILED"
		return
	_interrupt_context.clear()
	_source_archive_return_stage = -1
	_archive_detail_case_id = ""
	_side_restore_pending = false
	_side_resume_error = ""
	_incident_route = IncidentRoute.DEBUG_RUNTIME
	# No Next replay, checkpoint, discovery, opportunity, credit or event drain.
	_refresh_shell()

# Shell / auxiliary UI wiring only. These paths do not count gameplay opportunities.
func _refresh_shell() -> void:
	if not is_node_ready() or not is_inside_tree() or not game_shell.is_inside_tree(): return
	var stage: String = Stage.keys()[_current_stage].replace("_", " ")
	var work_stage: int = _current_stage if _current_stage <= Stage.CONTAINMENT else -1
	var runtime_id: int = case_runtime.get_instance_id() if case_runtime != null else 0
	if _drawer_runtime_id != runtime_id:
		_drawer_cache.clear()
		_drawer_runtime_id = runtime_id
	var subject: String = current_case.display_name if _has_current_case_runtime() else "FACILITY EVENT"
	if _developer_terminal.mode == TerminalMode.CLEANED_NO_RUN:
		subject = "NO ACTIVE RUN"
		stage = "NO ACTIVE RUN"
	if _current_stage in [Stage.RESEARCH_ARCHIVE_LIST, Stage.RESEARCH_ARCHIVE_DETAIL]:
		stage = "UTILITY / ARCHIVE"
	elif _is_side_interrupt() or _is_normal_interrupt():
		stage += " / PAUSED " + Stage.keys()[_interrupt_context.get("return_stage", Stage.PROFILE)]
	var environment: String = ""
	for condition: EnvironmentConditions.Condition in _build_environment_summary().entries:
		environment += (" / " if not environment.is_empty() else "") + condition.display_name
	var blocked: bool = _developer_closure_busy or is_instance_valid(_disturbance_notice) or _side_restore_pending or not _side_due.is_empty() or is_instance_valid(_current_view) and _current_view.has_open_confirmation() or not _terminal_action_allowed("archive")
	var work: bool = _current_stage <= Stage.CONTAINMENT and _has_current_case_runtime() and not _is_response_route()
	var response: bool = _is_response_route() and _current_stage in [Stage.INCIDENT, Stage.BROADCAST, Stage.INCIDENT_RESULT] and _has_response_context()
	var tool: bool = not blocked and (work or response)
	var status: String = "SESSION MEMORY / NO PERSISTENT SAVE"
	if _has_current_case_runtime() and case_runtime.has_confirmed_containment(): status += " / CONTAINMENT DECISION RECORDED"
	game_shell.display(subject, stage, environment, work_stage if work else -1, tool, tool, not blocked and work, status, runtime_id)
	game_shell.show_active_utility(_drawer_kind if is_instance_valid(_drawer_view) else "ARCHIVE" if _current_stage in [Stage.RESEARCH_ARCHIVE_LIST, Stage.RESEARCH_ARCHIVE_DETAIL] else "")

func _shell_research_requested() -> void:
	if is_instance_valid(_drawer_view):
		if _drawer_kind == "RESEARCH":
			_close_drawer()
			return
		_close_drawer()
	if is_instance_valid(_current_view): _on_research_log_requested(_current_view, _current_stage)

func _accept_drawer_action(view: ResearchLogView) -> bool:
	return view == _drawer_view and is_instance_valid(view) and view.is_inside_tree() and not view.is_queued_for_deletion() and _drawer_runtime_id == (case_runtime.get_instance_id() if case_runtime != null else 0) and _has_current_case_runtime() and not _is_response_route() and not _developer_closure_busy and not is_instance_valid(_disturbance_notice) and _side_due.is_empty() and _terminal_action_allowed("archive")

func _open_drawer(kind: String) -> void:
	if is_instance_valid(_drawer_view):
		var same: bool = _drawer_kind == kind
		_close_drawer()
		if same: return
	if _current_stage > Stage.CONTAINMENT or not _has_current_case_runtime() or _is_response_route() or not _accept_view_action(_current_view, "archive"): return
	if _drawer_runtime_id != case_runtime.get_instance_id(): _drawer_cache.clear()
	_drawer_runtime_id = case_runtime.get_instance_id()
	_drawer_focus = get_viewport().gui_get_focus_owner()
	_drawer_kind = kind
	_drawer_view = VIEW_SCENES[Stage.RESEARCH_LOG].instantiate()
	_drawer_view.configure_drawer_mode(kind)
	_drawer_view.setup(_build_research_log_snapshot())
	var drawer: ResearchLogView = _drawer_view
	drawer.set_input_guard(_accept_drawer_action.bind(drawer))
	drawer.advance_requested.connect(func() -> void:
		if _accept_drawer_action(drawer): _close_drawer())
	drawer.archive_requested.connect(_on_research_archive_requested.bind(drawer))
	drawer.hypothesis_add_requested.connect(_on_hypothesis_add_requested.bind(drawer))
	drawer.hypothesis_update_requested.connect(_on_hypothesis_update_requested.bind(drawer))
	drawer.hypothesis_remove_requested.connect(_on_hypothesis_remove_requested.bind(drawer))
	_drawer_panel = game_shell.add_drawer(drawer, kind)
	drawer.restore_drawer_state(_drawer_cache.get(kind, {}))
	_refresh_shell()

func _close_drawer(restore_focus: bool = true) -> void:
	if is_instance_valid(_drawer_view) and _drawer_view.is_node_ready(): _drawer_cache[_drawer_kind] = _drawer_view.capture_drawer_state()
	_drawer_view = null
	_drawer_kind = ""
	if is_instance_valid(_drawer_panel):
		_drawer_panel.get_parent().remove_child(_drawer_panel)
		_drawer_panel.queue_free()
	_drawer_panel = null
	if restore_focus and is_instance_valid(_drawer_focus) and _drawer_focus.is_inside_tree() and _drawer_focus.is_visible_in_tree(): _drawer_focus.grab_focus()
	_drawer_focus = null
	_refresh_shell()

func _shell_archive_requested() -> void:
	_close_drawer()
	if _is_response_route():
		_on_source_archive_requested(_current_view, _current_stage)
		return
	if _current_stage > Stage.CONTAINMENT or not _accept_view_action(_current_view, "archive") or not _has_current_case_runtime(): return
	_utility_focus = get_viewport().gui_get_focus_owner()
	_utility_work_view = _current_view
	_utility_work_stage = _current_stage
	_utility_research_display = _research_display.duplicate(true)
	_research_log_return_stage = _current_stage
	view_host.remove_child(_current_view)
	_current_view = null
	_show_view(Stage.RESEARCH_ARCHIVE_LIST, false)

func _restore_utility_work() -> void:
	if not is_instance_valid(_utility_work_view): return
	view_host.remove_child(_current_view)
	_current_view.queue_free()
	_current_view = _utility_work_view
	_current_stage = _utility_work_stage
	_utility_work_view = null
	_utility_work_stage = -1
	_research_display = _utility_research_display.duplicate(true)
	_utility_research_display.clear()
	view_host.add_child(_current_view)
	if is_instance_valid(_utility_focus) and _utility_focus.is_inside_tree() and _utility_focus.is_visible_in_tree(): _utility_focus.grab_focus()
	_utility_focus = null
	_refresh_shell()

func _on_confirmation_changed() -> void:
	_refresh_shell()
	if not _side_due.is_empty() and is_instance_valid(_current_view) and not _current_view.has_open_confirmation(): _present_due_side_after_draw(_current_view)

func _dispose_auxiliary_ui() -> void:
	_close_drawer(false)
	_drawer_cache.clear()
	_drawer_runtime_id = 0
	if is_instance_valid(_utility_work_view): _utility_work_view.free()
	_utility_work_view = null
	_utility_work_stage = -1
	_utility_research_display.clear()
