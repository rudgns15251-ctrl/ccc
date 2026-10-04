extends "res://scripts/views/flow_view.gd"

# Prototype/debug resolution playback only. Final gameplay uses progression units,
# not this real-time Timer; delayed resolution timing has not been decided.
signal monitoring_playback_completed

@onready var room_id_label: Label = %RoomId
@onready var description_label: Label = %Description
@onready var stage_list: VBoxContainer = %StageList
@onready var stage_scroll: ScrollContainer = %StageScroll
@onready var playback_timer: Timer = %PlaybackTimer

var _outcome: MonitoringOutcomeData
var _current_stage_index: int = 0
var _previous_time_offset: int = 0
var _playback_active: bool = false
var _playback_completed: bool = false
var _finalized_result: MonitoringOutcomeData.Result = MonitoringOutcomeData.Result.UNDEFINED


func setup(outcome: MonitoringOutcomeData, finalized_result: MonitoringOutcomeData.Result = MonitoringOutcomeData.Result.UNDEFINED) -> void:
	_outcome = outcome
	_finalized_result = finalized_result
	if finalized_result != MonitoringOutcomeData.Result.UNDEFINED and finalized_result != MonitoringOutcomeData.Result.SUCCESS and finalized_result != MonitoringOutcomeData.Result.FAILURE:
		push_warning("MonitoringView.setup(): unsupported finalized_result; ignoring snapshot.")
		_finalized_result = MonitoringOutcomeData.Result.UNDEFINED
	_current_stage_index = 0
	_previous_time_offset = 0
	_playback_active = false
	_playback_completed = false
	if is_node_ready():
		_display_outcome()


func _ready() -> void:
	super._ready()
	playback_timer.timeout.connect(_on_playback_timeout)
	_display_outcome()


func _exit_tree() -> void:
	_playback_active = false
	_playback_completed = false
	if is_node_ready():
		playback_timer.stop()
		next_button.disabled = true


func _display_outcome() -> void:
	playback_timer.stop()
	next_button.disabled = true
	for item: Node in stage_list.get_children():
		stage_list.remove_child(item)
		item.queue_free()
	stage_scroll.scroll_vertical = 0
	if _outcome == null:
		push_warning("MonitoringView.setup(): MonitoringOutcomeData is missing.")
		room_id_label.text = "ROOM: unavailable"
		description_label.text = "Monitoring data unavailable"
		return
	if _outcome.room_id.strip_edges().is_empty():
		push_warning("MonitoringView: room_id is empty.")
		room_id_label.text = "ROOM: [Missing room_id]"
	else:
		room_id_label.text = "ROOM: " + _outcome.room_id
	description_label.text = "Monitoring stages: %d" % _outcome.stages.size()
	if _outcome.stages.is_empty():
		push_warning("MonitoringView: stages is empty.")
		description_label.text = "Monitoring data unavailable"
		return
	var has_valid_stage: bool = false
	for stage: MonitoringStageData in _outcome.stages:
		if stage != null:
			has_valid_stage = true
			break
	if not has_valid_stage:
		for index in range(_outcome.stages.size()):
			push_warning("MonitoringView: MonitoringStageData at index %d is missing." % index)
		description_label.text = "Monitoring data unavailable"
		return
	if is_inside_tree():
		_playback_active = true
		_schedule_next_stage()


func _schedule_next_stage() -> void:
	while _playback_active and _current_stage_index < _outcome.stages.size():
		var stage: MonitoringStageData = _outcome.stages[_current_stage_index]
		if stage == null:
			var index: int = _current_stage_index
			push_warning("MonitoringView: MonitoringStageData at index %d is missing." % index)
			_current_stage_index += 1
			continue
		if stage.time_offset < 0:
			push_warning("MonitoringView: time_offset at index %d is negative." % _current_stage_index)
		if _current_stage_index > 0 and stage.time_offset < _previous_time_offset:
			push_warning("MonitoringView: time_offset at index %d goes backwards." % _current_stage_index)
		var delay: int = maxi(stage.time_offset - _previous_time_offset, 0)
		if delay > 0 and _finalized_result == MonitoringOutcomeData.Result.UNDEFINED:
			playback_timer.start(float(delay))
			return
		_reveal_current_stage()
	if _playback_active:
		playback_timer.stop()
		_playback_active = false
		_playback_completed = true
		description_label.text = "Monitoring sequence complete"
		if _finalized_result != MonitoringOutcomeData.Result.UNDEFINED:
			apply_monitoring_result(_finalized_result)
		else:
			monitoring_playback_completed.emit()


func has_completed_playback(outcome: MonitoringOutcomeData) -> bool:
	return is_inside_tree() and _playback_completed and _outcome == outcome


func apply_monitoring_result(result: MonitoringOutcomeData.Result) -> void:
	if not is_inside_tree() or not _playback_completed:
		return
	if result != MonitoringOutcomeData.Result.SUCCESS and result != MonitoringOutcomeData.Result.FAILURE:
		return
	if _finalized_result != MonitoringOutcomeData.Result.UNDEFINED and _finalized_result != result:
		return
	_finalized_result = result
	description_label.text = "Monitoring Result: " + ("SUCCESS" if result == MonitoringOutcomeData.Result.SUCCESS else "FAILURE")
	next_button.disabled = false
	next_button.grab_focus()


func _on_playback_timeout() -> void:
	if not _playback_active or not is_inside_tree():
		return
	_reveal_current_stage()
	_schedule_next_stage()


func _reveal_current_stage() -> void:
	var stage: MonitoringStageData = _outcome.stages[_current_stage_index]
	var observation: String = stage.observation_text
	if observation.strip_edges().is_empty():
		push_warning("MonitoringView: observation_text at index %d is empty." % _current_stage_index)
		observation = "[Missing observation_text]"
	_append_item("[%ds]" % stage.time_offset, observation)
	_previous_time_offset = stage.time_offset
	_current_stage_index += 1


func _on_next_button_pressed() -> void:
	if _playback_completed and _finalized_result != MonitoringOutcomeData.Result.UNDEFINED:
		super._on_next_button_pressed()


func _append_item(time_text: String, observation: String) -> void:
	var item := VBoxContainer.new()
	item.add_theme_constant_override("separation", 2)
	var time_label := Label.new()
	time_label.text = time_text
	time_label.add_theme_font_size_override("font_size", 18)
	item.add_child(time_label)
	var observation_label := Label.new()
	observation_label.text = observation
	observation_label.add_theme_font_size_override("font_size", 18)
	observation_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	item.add_child(observation_label)
	stage_list.add_child(item)
