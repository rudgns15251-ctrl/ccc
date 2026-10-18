extends "res://scripts/presentation/visual_production.gd"

# Release "Instrument Steel" theme preview (docs/ui_release/art_direction_v1.md); built by tools/build_release_theme.gd.
const RELEASE_THEME: Theme = preload("res://resources/ui/release_instrument_steel_theme.tres")
const ARCHIVE_LIST_SCRIPT = preload("res://scripts/views/research_archive_list_view.gd")
const ARCHIVE_DETAIL_SCRIPT = preload("res://scripts/views/research_archive_detail_view.gd")
const INCIDENT_SCRIPT = preload("res://scripts/views/incident_view.gd")
var _drawer_dim: Panel
# Chrome-only prefix such as "[임시·초안·비정사] " — the TEMP BUILD badge carries that status instead.
var _temp_prefix := RegEx.create_from_string("^\\[(?:임시|TEMP)[^\\]]*\\]\\s*")
var _badge: Button
var _notices: PackedStringArray = []
const LAMPS := {
	"current": preload("res://assets/ui/release/lamp_current.png"),
	"ready": preload("res://assets/ui/release/lamp_ready.png"),
	"off": preload("res://assets/ui/release/lamp_off.png"),
}
const WORK_KEYS := ["PROFILE", "CCTV", "EXPERIMENT", "CONTAINMENT"]
const FADE_SECONDS := 0.16
# Tabler Icons (MIT), recoloured white and tinted by the theme; see assets/ui/release/README.md.
const LOCK_ICON: Texture2D = preload("res://assets/ui/release/icons/icon_lock.svg")
const TOOL_ICONS := {
	"Research": preload("res://assets/ui/release/icons/icon_research.svg"),
	"Archive": preload("res://assets/ui/release/icons/icon_archive.svg"),
	"Hypothesis": preload("res://assets/ui/release/icons/icon_hypothesis.svg"),
	"Save": preload("res://assets/ui/release/icons/icon_save.svg"),
	"Load": preload("res://assets/ui/release/icons/icon_load.svg"),
}
# Mechanical UI clicks chosen from "87 Clickety Clips" (CC0).
const SFX := {
	"key": [preload("res://assets/ui/release/sfx/ui_key_a.wav"), preload("res://assets/ui/release/sfx/ui_key_b.wav")],
	"select": [preload("res://assets/ui/release/sfx/ui_select.wav")],
	"soft": [preload("res://assets/ui/release/sfx/ui_soft.wav")],
	"latch": [preload("res://assets/ui/release/sfx/ui_latch.wav")],
	"transmit": [preload("res://assets/ui/release/sfx/ui_transmit.wav")],
}
const SFX_VOLUME_DB := -9.0
# Event sounds and room ambience from BigSoundBank (CC0), cut by tools/build_release_sfx.gd.
const EVENT_SFX := {
	"doc_page": [preload("res://assets/ui/release/sfx/doc_page_a.wav"), preload("res://assets/ui/release/sfx/doc_page_b.wav")],
	"report_open": [preload("res://assets/ui/release/sfx/report_open.wav")],
	"switch_heavy": [preload("res://assets/ui/release/sfx/switch_heavy.wav")],
	"mic_on": [preload("res://assets/ui/release/sfx/mic_on.wav")],
	"radio_burst": [preload("res://assets/ui/release/sfx/radio_burst.wav")],
	"radio_static": [preload("res://assets/ui/release/sfx/radio_static.wav")],
	"radio_start": [preload("res://assets/ui/release/sfx/radio_start.wav")],
	"crt_switch": [preload("res://assets/ui/release/sfx/crt_switch.wav")],
	"alarm_warning": [preload("res://assets/ui/release/sfx/alarm_warning.wav")],
	"alarm_buzzer": [preload("res://assets/ui/release/sfx/alarm_buzzer.wav")],
	"metal_scrape": [preload("res://assets/ui/release/sfx/metal_scrape.wav")],
}
const AMBIENCE := [
	[preload("res://assets/ui/release/sfx/amb_vent.wav"), 0.0],
	[preload("res://assets/ui/release/sfx/amb_neon.wav"), -6.0],
]
const EVENT_VOLUME_DB := -4.0
var _event_players: Array[AudioStreamPlayer] = []
var _event_next: int = 0
var _ambience: Array[AudioStreamPlayer] = []


# Headless runs (CI, checks) use a dummy audio driver that never releases playbacks; stay silent there.
var _silent: bool = DisplayServer.get_name() == "headless"


func play_event(kind: String, delay: float = 0.0) -> void:
	if _silent: return
	if not enabled or not EVENT_SFX.has(kind) or _event_players.is_empty(): return
	if delay > 0.0:
		get_tree().create_timer(delay).timeout.connect(play_event.bind(kind))
		return
	var bank: Array = EVENT_SFX[kind]
	var player: AudioStreamPlayer = _event_players[_event_next]
	_event_next = (_event_next + 1) % _event_players.size()
	player.stream = bank[_sfx_rng.randi() % bank.size()]
	player.pitch_scale = _sfx_rng.randf_range(0.98, 1.02)
	player.play()


func _exit_tree() -> void:
	# Release the per-session looping stream copies so nothing outlives the scene.
	for player: AudioStreamPlayer in _ambience:
		if is_instance_valid(player):
			player.stop()
			player.stream = null
	_ambience.clear()


func _start_ambience() -> void:
	if _silent: return
	for pair: Array in AMBIENCE:
		var stream: AudioStreamWAV = (pair[0] as AudioStreamWAV).duplicate()
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = int(stream.get_length() * stream.mix_rate)
		var player := AudioStreamPlayer.new()
		player.stream = stream
		player.volume_db = pair[1]
		add_child(player)
		player.play(_sfx_rng.randf_range(0.0, stream.get_length() * 0.8))
		_ambience.append(player)
var _sfx_players: Array[AudioStreamPlayer] = []
var _sfx_next: int = 0
var _sfx_rng := RandomNumberGenerator.new()


const PAUSE_MENU: PackedScene = preload("res://scenes/release/pause_menu.tscn")
const RESULT_NOTICE: PackedScene = preload("res://scenes/release/result_notice.tscn")
var _result: Control


func show_containment_result(report: Dictionary) -> void:
	if not enabled or _result == null: return
	_result.show_report(report)
	play_event("report_open")
const TOOL_FONT_SIZE := 25
var _settings: Dictionary = ReleaseSettings.load_values()
var _pause: Control
var _menu_button: Button


func configure(main: Control, initial: bool) -> void:
	ReleaseSettings.apply_audio(_settings)
	# Players exist before the first screen is decorated, so its arrival sound plays.
	for index: int in 4:
		var player := AudioStreamPlayer.new()
		add_child(player)
		_sfx_players.append(player)
	for index: int in 3:
		var player := AudioStreamPlayer.new()
		player.volume_db = EVENT_VOLUME_DB
		add_child(player)
		_event_players.append(player)
	_apply_ui_volume()
	super.configure(main, initial)
	_start_ambience()
	for node: Node in game.find_children("*", "BaseButton", true, false): _attach_click(node)
	get_tree().node_added.connect(_on_node_added)
	var layer := CanvasLayer.new()
	layer.layer = 64
	add_child(layer)
	_pause = PAUSE_MENU.instantiate()
	_pause.theme = theme
	layer.add_child(_pause)
	_pause.settings_changed.connect(_on_settings_changed)
	_result = RESULT_NOTICE.instantiate()
	_result.theme = theme
	layer.add_child(_result)
	_result.archive_requested.connect(func() -> void: game.get_node("%Archive").pressed.emit.call_deferred())
	_pause.resumed.connect(func() -> void: if is_instance_valid(_menu_button) and _menu_button.is_visible_in_tree(): _menu_button.grab_focus())
	if ReleaseSettings.continue_requested:
		ReleaseSettings.continue_requested = false
		_continue_saved.call_deferred()


# Title "Continue": the normal Main load path, without the in-game replace confirmation
# (nothing has been played yet in this session).
func _continue_saved() -> void:
	for frame: int in 3: await get_tree().process_frame
	var prepared: Dictionary = game.prepare_saved_game()
	if prepared.error.is_empty(): game._apply_saved_game(prepared)


func _on_settings_changed(values: Dictionary) -> void:
	var rescale: bool = values.text_size != _settings.text_size
	_settings = values.duplicate()
	_apply_ui_volume()
	if not rescale: return
	theme = _make_theme()
	_pause.theme = theme
	_result.theme = theme
	if enabled:
		game.theme = theme
		for name: String in TOOL_ICONS: _change(shell, game.get_node("%" + name), "theme_override_font_sizes/font_size", roundi(TOOL_FONT_SIZE * ReleaseSettings.text_scale(_settings)))


func _apply_ui_volume() -> void:
	for player: AudioStreamPlayer in _sfx_players: player.volume_db = SFX_VOLUME_DB + ReleaseSettings.volume_db(_settings.ui_volume)


func open_pause() -> void:
	if enabled and not _pause.is_open() and not _result.is_open() and not _blocked() and game.get("_current_stage") not in [MAIN_STAGE_ARCHIVE_LIST, MAIN_STAGE_ARCHIVE_DETAIL]:
		_pause.open()


func _unhandled_key_input(event: InputEvent) -> void:
	if not enabled or _pause.is_open() or _result.is_open() or not event.is_action_pressed("ui_cancel") or event.is_echo(): return
	if _blocked() or game.get("_current_stage") in [MAIN_STAGE_ARCHIVE_LIST, MAIN_STAGE_ARCHIVE_DETAIL]: return
	get_viewport().set_input_as_handled()
	_pause.open()


func _on_node_added(node: Node) -> void:
	if node is BaseButton and is_instance_valid(game) and game.is_ancestor_of(node): _attach_click(node)


func _attach_click(button: BaseButton) -> void:
	if button.has_meta("release_click"): return
	button.set_meta("release_click", true)
	button.button_down.connect(_on_button_down.bind(button))


# Physical keys sound on press-down; the sound follows the key's role (presentation only).
func _on_button_down(button: BaseButton) -> void:
	if _silent: return
	if not enabled or not is_instance_valid(button): return
	var variation: String = String(button.theme_type_variation)
	var kind: String = "key"
	if variation == "TransmitButton": kind = "transmit"
	elif variation in ["PrimaryButton", "CurrentNavButton", "ActiveRailButton"]: kind = "latch"
	elif button is CheckBox or button is CheckButton: kind = "select"
	elif variation == "TempBadgeButton": kind = "soft"
	var bank: Array = SFX[kind]
	var player: AudioStreamPlayer = _sfx_players[_sfx_next]
	_sfx_next = (_sfx_next + 1) % _sfx_players.size()
	player.stream = bank[_sfx_rng.randi() % bank.size()]
	player.pitch_scale = _sfx_rng.randf_range(0.97, 1.03)
	player.play()
	if kind == "transmit": play_event("radio_static", 0.3)

const MAIN_STAGE_INCIDENT := 6  # Main.Stage.INCIDENT
const MAIN_STAGE_BROADCAST := 7  # Main.Stage.BROADCAST
const MAIN_STAGE_INCIDENT_RESULT := 8  # Main.Stage.INCIDENT_RESULT
const MAIN_STAGE_CONTAINMENT := 3  # Main.Stage.CONTAINMENT
const MAIN_STAGE_ARCHIVE_LIST := 10  # Main.Stage.RESEARCH_ARCHIVE_LIST
const MAIN_STAGE_ARCHIVE_DETAIL := 11  # Main.Stage.RESEARCH_ARCHIVE_DETAIL

func _make_theme() -> Theme:
	return ReleaseSettings.scaled_theme(RELEASE_THEME, ReleaseSettings.text_scale(_settings))


func _build_shell() -> void:
	super._build_shell()
	# Release chrome: the structure-comparison menu is a development control.
	_change(shell, menu, "visible", false)
	# Console frame around the whole workstation, drawn in the shell's existing edge margin.
	var frame := Panel.new()
	frame.name = "ConsoleFrame"
	frame.theme_type_variation = "ConsoleFramePanel"
	frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shell.layout.get_parent().add_child(frame)
	shell.layout.get_parent().move_child(frame, shell.layout.get_index())
	shell.extra_nodes = shell.get("extra_nodes", []) + [frame]
	for side: Array in [["left", 26], ["right", 26], ["top", 24], ["bottom", 22]]:
		_change(shell, shell.layout, "theme_override_constants/margin_" + side[0], side[1])
	for name: String in ["Research", "Archive", "Hypothesis", "Save", "Load"]:
		var tool: Button = game.get_node("%" + name)
		_change(shell, tool, "theme_override_font_sizes/font_size", roundi(TOOL_FONT_SIZE * ReleaseSettings.text_scale(_settings)))
		_change(shell, tool, "icon", TOOL_ICONS[name])
		_change(shell, tool, "icon_alignment", HORIZONTAL_ALIGNMENT_LEFT)
	# Long stage captions such as "비상 방송 / 중단된 …" need the room the subject slot has to spare.
	_change(shell, shell.layout.get_node("Console/Identification/Row/FacilitySlot"), "custom_minimum_size", Vector2(640, 0))
	var stage: Label = game.get_node("%Stage")
	_change(shell, stage, "autowrap_mode", TextServer.AUTOWRAP_OFF)
	_change(shell, stage, "text_overrun_behavior", TextServer.OVERRUN_TRIM_ELLIPSIS)
	_change(shell, stage, "clip_text", true)
	for name: String in WORK_KEYS:
		var key: Button = game.get_node("%" + name)
		_change(shell, key, "icon_alignment", HORIZONTAL_ALIGNMENT_LEFT)
		_change(shell, key, "expand_icon", false)
		# Lamps carry their own colour; keep them untinted.
		for state: String in ["icon_normal_color", "icon_hover_color", "icon_pressed_color", "icon_focus_color", "icon_hover_pressed_color"]:
			_change(shell, key, "theme_override_colors/" + state, Color.WHITE)
	_badge = Button.new()
	_badge.name = "TempBuildBadge"
	_badge.text = "TEMP BUILD"
	_badge.theme_type_variation = "TempBadgeButton"
	_badge.focus_mode = Control.FOCUS_NONE
	_badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var slot: Node = shell.layout.get_node("Console/Identification/Row/ComparisonSlot")
	slot.add_child(_badge)
	slot.move_child(_badge, 0)
	_update_badge()
	# Pause is also reachable without the keyboard.
	_menu_button = Button.new()
	_menu_button.name = "PauseMenuButton"
	_menu_button.text = "메뉴"
	_menu_button.tooltip_text = "일시정지 (Esc)"
	_menu_button.theme_type_variation = "HeaderButton"
	_menu_button.custom_minimum_size = Vector2(110, 0)
	_menu_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_menu_button.pressed.connect(open_pause)
	slot.add_child(_menu_button)


# Notices are honest about temporary content; in the release preview they are listed
# once in the badge tooltip instead of being repeated on every screen.
func _note(_record: Dictionary, _parent: Node, text: String, _first: bool = false) -> void:
	match text:
		"TEMP / REPLACEABLE — visual stand-in, not the authored creature or evidence.":
			text = "T04 사용자 제공 Master / 임시·초안·비정사 / 교체 가능. 사진만으로 절대 신장을 검증하지 않음." if game.current_case.case_id == "TEMP_T04_CASE" else "후속 업무용 기존 임시 사례 / 대상 사진 미제공"
		"VISUAL TEST DOCUMENT / existing research rules unchanged":
			text = "임시 연구 문서 / 정식 설정 승인 전"
		"TEMP / REPLACEABLE — static reference; observations determine decisions.":
			if game.current_case.cctv_data.feed_texture == null:
				text = "CCTV 장면 미제공 / 판단 근거는 실제 관찰문. 전신 Master를 CCTV 증거로 사용하지 않음."
			elif game.current_case.case_id == "TEMP_T04_CASE":
				text = "TEMP 합성 장면(Master + 표준 격리실) / 실제 감시 영상 아님 · 판단 근거는 관찰문"
			else:
				text = "임시 감시 이미지 / 관찰 기록과 함께 검토"
		"Experiment-specific result image not supplied. Text is the execution record.":
			text = "실행한 실험에만 TEMP 합성 프레임 표시 / 실제 실험 사진 아님 · 결과 판단은 실행 기록" if game.current_case.case_id == "TEMP_T04_CASE" else "증거 이미지가 없는 실험은 텍스트로 표시 / 결과는 실제 실행 후 공개"
		"TEMP environment reference / shared illustration, not a candidate configuration.":
			text = "격리 후보별 환경 이미지 미제공 / 각 후보의 조도·외부 차음·내부 잔향은 설명으로 비교" if game.environment_reference == null else "공통 공간 참고 이미지 / 후보별 실제 조건은 설명으로 비교"
	if not _notices.has(text):
		_notices.append(text)
		_update_badge()


func _update_badge() -> void:
	if not is_instance_valid(_badge): return
	var lines := PackedStringArray(["임시·초안·비정사 빌드 — 정식 설정 아님", "콘텐츠의 [임시] 표기와 아래 항목은 교체 예정입니다."])
	for notice: String in _notices: lines.append("· " + notice)
	_badge.tooltip_text = "\n".join(lines)


func decorate_view(view: Control) -> void:
	var fresh: bool = view != null and not views.has(view.get_instance_id())
	super.decorate_view(view)
	if not enabled or view == null: return
	if view.get_script() == CONTAINMENT_SCRIPT:
		for node: Node in view.find_children("*", "TextureRect", true, false):
			if node.texture == null:
				node.visible = false
	if fresh and view.get_script() == PROFILE_SCRIPT and views.has(view.get_instance_id()):
		_change(views[view.get_instance_id()], view.get_node("%DocumentScroll").get_v_scroll_bar(), "theme_type_variation", &"PaperVScrollBar")
	if fresh and view.get_script() == RESULT_SCRIPT:
		_build_paper_report(view)
	if fresh and view.get_script() == CONTAINMENT_SCRIPT and views.has(view.get_instance_id()):
		_build_comparison(view, views[view.get_instance_id()])
		_add_reopen_note(view, views[view.get_instance_id()])
	if fresh and view.get_script() == EXPERIMENT_SCRIPT and views.has(view.get_instance_id()):
		_polish_experiment(view, views[view.get_instance_id()])
		_merge_experiment_monitor(view, views[view.get_instance_id()])
	if fresh and view.get_script() == CCTV_SCRIPT and views.has(view.get_instance_id()):
		_add_experiment_preview(views[view.get_instance_id()])
	if fresh and view.get_script() == BROADCAST_SCRIPT and views.has(view.get_instance_id()):
		# Wider situation column; the step row repeats the banner's status, so it gives its height back.
		var record: Dictionary = views[view.get_instance_id()]
		_change(record, record.layout.get_node("QuestionLayout/Context"), "custom_minimum_size", Vector2(600, 0))
		_change(record, record.layout.get_node("Steps"), "visible", false)
		# The question screen needs the height for all four options: the banner already says "emergency broadcast"
		# and the progress line works as the heading, so the duplicate heading is dropped and spacing tightened.
		_change(record, view.get_node("%OrdersHeading"), "visible", false)
		_change(record, record.layout.get_node("QuestionLayout/Selection/Stack"), "theme_override_constants/separation", 8)
	if fresh and view.get_script() == INCIDENT_SCRIPT:
		# No incident artwork exists yet: drop the empty image frame so the report text gets the space.
		var record: Dictionary = _record(null)
		record.view = weakref(view)
		views[view.get_instance_id()] = record
		_change(record, view.get_node("Margin/Content/Workspace/Report/IncidentImage"), "visible", false)
	if fresh: _fade_in(view)
	if fresh: _view_sound(view)


# Each screen arrives with the sound of its equipment (presentation only).
func _view_sound(view: Control) -> void:
	match view.get_script():
		PROFILE_SCRIPT: play_event("doc_page")
		CCTV_SCRIPT: play_event("crt_switch")
		INCIDENT_SCRIPT:
			play_event("alarm_buzzer")
			play_event("radio_burst", 0.6)
		BROADCAST_SCRIPT: play_event("radio_start")
		RESULT_SCRIPT: play_event("report_open")
		ARCHIVE_LIST_SCRIPT: play_event("doc_page")


# QA pass 1: red is reserved for alarms/transmission, the list no longer repeats the detail
# panel's text, and the remaining-run count reads as a row of indicator lamps.
func _polish_experiment(view: Control, record: Dictionary) -> void:
	_change(record, view.get_node("%RunButton"), "theme_type_variation", &"PrimaryButton")
	for item: Node in (view.get("experiment_list") as Node).get_children():
		for label: Node in item.get_children():
			if label is Label: _change(record, label, "visible", false)
	var remaining: Label = view.get_node("%RemainingCount")
	_change(record, remaining, "horizontal_alignment", HORIZONTAL_ALIGNMENT_RIGHT)
	var lamps := HBoxContainer.new()
	lamps.size_flags_horizontal = Control.SIZE_SHRINK_END
	lamps.name = "RemainingLamps"
	lamps.add_theme_constant_override("separation", 8)
	lamps.alignment = BoxContainer.ALIGNMENT_CENTER
	remaining.get_parent().add_child(lamps)
	remaining.get_parent().move_child(lamps, remaining.get_index() + 1)
	record.extra_nodes = record.get("extra_nodes", []) + [lamps]
	record.counter_lamps = lamps


func _update_experiment_lamps(view: Control) -> void:
	var record: Dictionary = views.get(view.get_instance_id(), {})
	if not record.has("counter_lamps") or not is_instance_valid(record.counter_lamps): return
	var lamps: HBoxContainer = record.counter_lamps
	var limit: int = view.get("_experiment_limit")
	var left: int = view.get("_remaining_count")
	while lamps.get_child_count() < limit:
		var lamp := TextureRect.new()
		lamp.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		lamps.add_child(lamp)
	for index: int in lamps.get_child_count():
		var lamp: TextureRect = lamps.get_child(index)
		lamp.visible = index < limit
		lamp.texture = LAMPS.ready if index < left else LAMPS.off


# Screens arrive with a short fade instead of an instant swap (presentation only; state and focus are untouched).
func _fade_in(control: Control) -> void:
	control.modulate.a = 0.0
	control.create_tween().tween_property(control, "modulate:a", 1.0, FADE_SECONDS)


# Candidate rooms authored as "항목: 값 / 항목: 값" become a side-by-side comparison table,
# so the empty right-hand panel shows the decision data before any room is chosen.
func _build_comparison(view: Control, record: Dictionary) -> void:
	var rooms: Array = view.get("_rooms")
	var parsed: Array[Dictionary] = []
	var keys: PackedStringArray = []
	for room: ContainmentData in rooms:
		var fields: Dictionary = {}
		for segment: String in GameText.translate_value(room.description).split(" / "):
			var colon: int = segment.find(": ")
			if colon < 0: continue
			var key: String = segment.substr(0, colon).strip_edges()
			var value: String = segment.substr(colon + 2).strip_edges()
			var tail: int = value.find(". ")
			var extra: String = value.substr(tail + 2) if tail >= 0 else ""
			fields[key] = value.substr(0, tail) if tail >= 0 else value
			var extra_colon: int = extra.find(": ")
			if extra_colon >= 0: fields[extra.substr(0, extra_colon)] = extra.substr(extra_colon + 2).trim_suffix(".")
		if fields.size() < 3: return
		parsed.append(fields)
		for key: String in fields:
			if not keys.has(key): keys.append(key)
	var grid := GridContainer.new()
	grid.name = "ComparisonTable"
	grid.columns = rooms.size() + 1
	grid.add_theme_constant_override("h_separation", 22)
	grid.add_theme_constant_override("v_separation", 12)
	var columns: Array = []
	for index: int in rooms.size(): columns.append([])
	grid.add_child(Label.new())
	for index: int in rooms.size():
		var head := Label.new()
		head.text = GameText.translate_value(rooms[index].display_name).replace(" · ", "\n")
		head.theme_type_variation = "HeadingLabel"
		head.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_child(head)
		columns[index].append(head)
	for key: String in keys:
		var name := Label.new()
		name.text = key
		name.theme_type_variation = "MutedLabel"
		grid.add_child(name)
		for index: int in rooms.size():
			var cell := Label.new()
			cell.text = parsed[index].get(key, "—")
			cell.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			grid.add_child(cell)
			columns[index].append(cell)
	# Inside the existing detail scroll: the right panel keeps its height, so the command bar stays on screen.
	var body: Node = view.get_node("%RoomDetailScroll").get_node("RoomDetailBody")
	body.add_child(grid)
	body.move_child(grid, 0)
	record.extra_nodes = record.get("extra_nodes", []) + [grid]
	record.comparison_columns = columns
	# The table now carries the values, so the selection list keeps only the room keys.
	for item: Node in (view.get("room_list") as Node).get_children():
		for label: Node in item.get_children():
			if label is Label: _change(record, label, "visible", false)


func _highlight_comparison(view: Control) -> void:
	var record: Dictionary = views.get(view.get_instance_id(), {})
	if not record.has("comparison_columns"): return
	var selected: int = view.get("_selected_room_index")
	var confirmed: String = view.get("_confirmed_room_id")
	var rooms: Array = view.get("_rooms")
	for index: int in rooms.size():
		var lit: bool = index == selected or (not confirmed.is_empty() and rooms[index].room_id == confirmed)
		for cell: Label in record.comparison_columns[index]:
			if lit: cell.add_theme_color_override("font_color", Color("e0bd6a"))
			else: cell.remove_theme_color_override("font_color")


# The incident report reads as a filed paper document (art direction: paper = basis of judgement).
# Reversible like the other layouts: the paper panel is the record's layout and is removed on undo.
func _build_paper_report(view: Control) -> void:
	var report: Control = view.get_node("Margin/Content/Workspace/Report")
	var paper := PanelContainer.new()
	paper.name = "PaperReport"
	paper.theme_type_variation = "PaperDocumentPanel"
	paper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	paper.size_flags_vertical = Control.SIZE_EXPAND_FILL
	paper.size_flags_stretch_ratio = report.size_flags_stretch_ratio
	var workspace: Node = report.get_parent()
	workspace.add_child(paper)
	workspace.move_child(paper, report.get_index())
	var record: Dictionary = _record(paper)
	record.view = weakref(view)
	views[view.get_instance_id()] = record
	_put(record, report, paper, true)
	var styles := {"ResultId": "PaperMetadataLabel", "DisplayName": "PaperHeadingLabel", "SelectedOrders": "PaperMetadataLabel", "Description": "PaperBodyLabel", "ReportDetails": "PaperBodyLabel"}
	for name: String in styles:
		_change(record, report.get_node("%" + name), "theme_type_variation", StringName(styles[name]))
	_change(record, report.get_node("%ReportScroll").get_v_scroll_bar(), "theme_type_variation", &"PaperVScrollBar")


func _process(delta: float) -> void:
	super._process(delta)
	if game == null or not enabled: return
	for name: String in ["Subject", "Environment"]:
		_strip(game.get_node("%" + name))
	# A sentence that ends in a full stop reads as a doubled mark before the " · " separator; drop that stop.
	var status: Label = game.get_node("%SystemStatus")
	if status.text.contains(". · "): status.text = status.text.replace(". · ", " · ")
	# Work-key status lamps: lit amber = current work, green = available, dark = locked.
	for name: String in WORK_KEYS:
		var key: Button = game.get_node("%" + name)
		var state: String = "current" if key.theme_type_variation == &"CurrentNavButton" else "off" if key.disabled else "ready"
		# Locked keys show a dimmed lock instead of an unlit lamp; the current key is disabled but lit.
		var icon: Texture2D = LOCK_ICON if state == "off" else LAMPS[state]
		if key.icon != icon: _change(shell, key, "icon", icon)
		var disabled_tint: Color = Color("7d857a") if state == "off" else Color.WHITE
		if key.get_theme_color("icon_disabled_color") != disabled_tint: _change(shell, key, "theme_override_colors/icon_disabled_color", disabled_tint)
	var notice: Control = game.get("_disturbance_notice")
	if is_instance_valid(notice) and not notice.has_meta("release_faded"):
		notice.set_meta("release_faded", true)
		play_event("alarm_warning")
		play_event("metal_scrape", 0.9)
		# Dim the work screen behind the warning so its text does not compete with the notice.
		notice.add_child(_make_dim(0.75))
		notice.move_child(notice.get_child(notice.get_child_count() - 1), 0)
		_fade_in(notice)
	# Rail wording: with spare chances the Experiment key reopens work instead of showing a read-only copy.
	var experiment_key: Button = game.get_node("%EXPERIMENT")
	var spare: int = _reopen_chances()
	if spare > 0 and not experiment_key.disabled and game.get("_presented_work_stage") != 2:
		var caption: String = "실험\n재개 가능 · %d회 남음" % spare
		if experiment_key.text != caption: experiment_key.text = caption
	var containment_key: Button = game.get_node("%CONTAINMENT")
	if game.get("_current_stage") == 2 and game.get("_presented_work_stage") == 2 and (game.get("_work_screens") as Dictionary).has(3) and not containment_key.disabled:
		if containment_key.text != "격리\n이어서 진행": containment_key.text = "격리\n이어서 진행"
	_polish_drawer()
	var view: Control = game.get("_current_view")
	if view != null and view.get_script() == CONTAINMENT_SCRIPT:
		_highlight_comparison(view)
		_update_reopen_note(view)
	if view != null and view.get_script() == EXPERIMENT_SCRIPT:
		_update_experiment_lamps(view)
		_update_merged_monitor(view)
	if view != null and view.has_method("has_open_confirmation") and view.has_open_confirmation():
		_polish_confirmation(view.get("_confirmation"))
	_merge_conditions_into_band(view)
	_polish_records(view)


# 720p space: the shell's alert band and a work screen's "current facility conditions" block


# While no containment decision exists, spare experiment chances stay usable: the Experiment key reopens the
# experiments (Main: _can_reopen_experiments). These notes only explain that; they never change state.
func _reopen_chances() -> int:
	if game.get("_current_stage") != MAIN_STAGE_CONTAINMENT or game.case_runtime == null or game.current_case == null: return 0
	if not game.call("_can_reopen_experiments"): return 0
	return game.case_runtime.get_remaining_experiment_count(game.current_case.experiment_limit)


func _add_reopen_note(view: Control, record: Dictionary) -> void:
	var hint: Label = view.get_node("%ComparisonHint")
	var note := Label.new()
	note.name = "ReopenExperimentNote"
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.theme_type_variation = &"InstrumentLabel"
	note.visible = false
	hint.get_parent().add_child(note)
	hint.get_parent().move_child(note, hint.get_index() + 1)
	record.extra_nodes = record.get("extra_nodes", []) + [note]
	record.reopen_note = note


func _update_reopen_note(view: Control) -> void:
	var record: Dictionary = views.get(view.get_instance_id(), {})
	if not record.has("reopen_note") or not is_instance_valid(record.reopen_note): return
	var left: int = _reopen_chances()
	var note: Label = record.reopen_note
	note.visible = left > 0
	if left > 0:
		note.text = "실험 기회가 %d회 남았습니다. 격리를 확정하기 전에는 '실험' 키로 돌아가 계속 실험할 수 있고, 확정하면 남은 기회는 사라집니다." % left
# repeat the same heading. Keep one — the band — and append the block's detail line to it.
# During incident / broadcast / report the broadcast banner already carries the context.
func _merge_conditions_into_band(view: Control) -> void:
	var alerts: Control = shell.layout.get_node("Console/Alerts")
	var response: bool = game.get("_current_stage") in [MAIN_STAGE_INCIDENT, MAIN_STAGE_BROADCAST, MAIN_STAGE_INCIDENT_RESULT]
	# The four work keys are all locked during an incident; hiding them returns their height to the report and the options.
	shell.layout.get_node("Console/Navigation").visible = not response
	if response:
		alerts.visible = false
		return
	if view == null or not views.has(view.get_instance_id()): return
	var conditions: Control = view.get_node_or_null("%EnvironmentConditions")
	if conditions == null: return
	var details := PackedStringArray()
	for label: Node in conditions.find_children("*", "Label", true, false):
		var lines: PackedStringArray = (label as Label).text.split("\n")
		if lines.size() > 1 and not lines[1].strip_edges().is_empty(): details.append(lines[1].strip_edges())
	if conditions.visible: _change(views[view.get_instance_id()], conditions, "visible", false)
	var band: Label = game.get_node("%Environment")
	if not details.is_empty() and not band.text.is_empty() and not band.text.contains(details[0]):
		band.text = band.text + " — " + " ".join(details)


func _make_dim(alpha: float) -> Panel:
	var dim := Panel.new()
	dim.name = "ReleaseDim"
	dim.theme_type_variation = "ModalBackdropPanel"
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dim.modulate.a = alpha
	return dim


# Research / memo drawer: wider, taller list, and a light dim behind it (visual only; input unchanged).
func _polish_drawer() -> void:
	var drawer: Control = game.get("_drawer_panel")
	if not is_instance_valid(drawer):
		if is_instance_valid(_drawer_dim): _drawer_dim.queue_free()
		return
	drawer.offset_left = -1120; drawer.offset_right = -20; drawer.offset_top = 150; drawer.offset_bottom = -120
	if not is_instance_valid(_drawer_dim):
		_drawer_dim = _make_dim(0.55)
		drawer.get_parent().add_child(_drawer_dim)
		drawer.get_parent().move_child(_drawer_dim, drawer.get_index())
		_fade_in(drawer)
	var log_view: Node = game.get("_drawer_view")
	if is_instance_valid(log_view) and not log_view.has_meta("release_drawer"):
		log_view.set_meta("release_drawer", true)
		# Wide drawer: list and selected record side by side, like a dossier (the drawer is rebuilt on each open).
		var entries: Control = log_view.get_node_or_null("%EntryScroll")
		var detail: Control = log_view.get_node_or_null("%EntryDetailScroll")
		if entries != null and detail != null and entries.get_parent() == detail.get_parent():
			var row := HBoxContainer.new()
			row.name = "ReleaseDossierRow"
			row.size_flags_vertical = Control.SIZE_EXPAND_FILL
			row.add_theme_constant_override("separation", 18)
			entries.get_parent().add_child(row)
			entries.get_parent().move_child(row, entries.get_index())
			for pair: Array in [[entries, 1.0], [detail, 1.3]]:
				var scroll: Control = pair[0]
				scroll.reparent(row, false)
				scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				scroll.size_flags_stretch_ratio = pair[1]
				scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
				scroll.custom_minimum_size.y = 320


# Decision dialogs (e.g. containment approval) get room to show what is being approved.
func _polish_confirmation(modal: Control) -> void:
	if not is_instance_valid(modal) or modal.has_meta("facility_authorization") or modal.has_meta("release_modal"): return
	modal.set_meta("release_modal", true)
	modal.get_node("%Panel").custom_minimum_size = Vector2(1100, 0)
	modal.get_node("%BodyScroll").custom_minimum_size = Vector2(0, 320)
	_fade_in(modal)


# Chrome-only "[임시…]" prefixes on the report and Archive, and the lit selected Archive case.
func _polish_records(view: Control) -> void:
	if view == null: return
	if view.get_script() == INCIDENT_SCRIPT:
		_strip(view.get_node("%DisplayName"))
		_strip(view.get_node("%ResponseContext"), true)
	if view.get_script() == BROADCAST_SCRIPT:
		# Situation column only; the transmission preview must stay identical to the composed script.
		for node: Node in view.get_node("%Transmission").find_children("*", "Label", true, false): _strip(node, true)
	if view.get_script() == RESULT_SCRIPT:
		_strip(view.get_node("%DisplayName"))
		_strip(view.get_node("%ResponseContext"), true)
	if view.get_script() in [ARCHIVE_LIST_SCRIPT, ARCHIVE_DETAIL_SCRIPT]:
		for node: Node in view.find_children("*", "Label", true, false): _strip(node)
		var cases: Node = view.get_node_or_null("%CaseList")
		if cases == null: return
		for button: Node in cases.find_children("*", "Button", true, false):
			_strip(button)
			# The selected case is a disabled button; show it lit like the current work key.
			if not button.has_meta("release_base_variation"): button.set_meta("release_base_variation", button.theme_type_variation)
			var lit: StringName = &"SelectedListButton" if button.disabled else button.get_meta("release_base_variation")
			if button.theme_type_variation != lit: button.theme_type_variation = lit


func _strip(control: Control, every_line: bool = false) -> void:
	var text: String = control.get("text")
	if text.is_empty(): return
	var stripped: String = _temp_prefix.sub(text, "")
	if every_line:
		var lines: PackedStringArray = text.split("\n")
		for index: int in lines.size(): lines[index] = _temp_prefix.sub(lines[index], "")
		stripped = "\n".join(lines)
	if stripped != text: control.set("text", stripped)


# ── CCTV · EXPERIMENT shared composition (prototype; presentation only) ───────────────
# Both work screens use the same column order — monitor | experiment list | text — so the
# experiment panel is a locked preview beside the CCTV and becomes active on the next stage.
# Main still owns both stages; every state, signal and Research boundary is unchanged.
const MONITOR_RATIO := 1.7
const LIST_RATIO := 0.85
const TEXT_RATIO := 1.1
const MERGED_FLASH_SECONDS := 0.55


func _merge_experiment_monitor(view: Control, record: Dictionary) -> void:
	var body: Control = record.layout.get_node("Body")
	var cctv: CCTVData = game.current_case.cctv_data if game.current_case != null else null
	var monitor := PanelContainer.new()
	monitor.name = "MergedMonitor"
	monitor.theme_type_variation = &"MonitorBezel"
	monitor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	monitor.size_flags_stretch_ratio = MONITOR_RATIO
	body.add_child(monitor)
	body.move_child(monitor, 0)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 10)
	monitor.add_child(stack)

	var head := HBoxContainer.new()
	stack.add_child(head)
	var camera := Label.new()
	camera.text = cctv.get_display_name() if cctv != null else "CAMERA"
	camera.theme_type_variation = &"InstrumentLabel"
	camera.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(camera)
	var osd := Label.new()
	osd.text = "LIVE / 기본 상태"
	osd.theme_type_variation = &"MutedLabel"
	head.add_child(osd)

	var slot := MarginContainer.new()
	slot.name = "VideoSlot"
	slot.size_flags_vertical = Control.SIZE_EXPAND_FILL
	slot.custom_minimum_size = Vector2(0, 200)
	stack.add_child(slot)
	var base := TextureRect.new()
	base.name = "BaselineFeed"
	base.texture = cctv.feed_texture if cctv != null else null
	base.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	base.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(base)
	if base.texture == null:
		var missing := Label.new()
		missing.text = "CCTV 장면 미제공\n관찰문을 근거로 판단"
		missing.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		missing.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		slot.add_child(missing)
	# The authoritative result image now plays inside the monitor; it hides itself until a run.
	var image: TextureRect = view.get_node("%ResultImage")
	_put(record, image, slot, true)
	_change(record, image, "expand_mode", TextureRect.EXPAND_IGNORE_SIZE)
	_change(record, image, "stretch_mode", TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	var flash := ColorRect.new()
	flash.name = "SignalFlash"
	flash.color = Color(0.86, 0.92, 0.88, 0.0)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(flash)

	# The baseline observation text stays on the CCTV stage; here the monitor keeps the same size so the
	# frame swap reads as the same picture changing.

	_change(record, record.layout.get_node("Body/Left"), "size_flags_stretch_ratio", LIST_RATIO)
	_change(record, record.layout.get_node("Body/Right"), "size_flags_stretch_ratio", TEXT_RATIO)
	record.extra_nodes = record.get("extra_nodes", []) + [monitor]
	record.merged = {"osd": osd, "flash": flash, "last": "", "primed": false}


func _update_merged_monitor(view: Control) -> void:
	var record: Dictionary = views.get(view.get_instance_id(), {})
	if not record.has("merged") or not is_instance_valid(record.merged.osd): return
	var merged: Dictionary = record.merged
	var image: TextureRect = view.get_node("%ResultImage")
	var result_id: String = view.get_displayed_result_id() if image.visible and image.texture != null else ""
	var name: String = (view.get_node("%SelectedName") as Label).text
	merged.osd.text = ("실험 결과 / " + name) if not result_id.is_empty() else "LIVE / 기본 상태"
	if merged.last == result_id: return
	merged.last = result_id
	# A restored or freshly drawn screen shows its state without a signal flash.
	if not merged.primed:
		merged.primed = true
		return
	var flash: ColorRect = merged.flash
	flash.color = Color(0.86, 0.92, 0.88, 0.75)
	flash.create_tween().tween_property(flash, "color:a", 0.0, MERGED_FLASH_SECONDS)
	play_event("crt_switch")


# CCTV stage: the experiment list sits beside the monitor, locked until observation is confirmed.
func _add_experiment_preview(record: Dictionary) -> void:
	var equipment: Control = record.layout.get_node("Equipment")
	var monitor: Control = equipment.get_node("Monitor")
	var current: CaseData = game.current_case
	var unlocked: bool = (game.get("_work_screens") as Dictionary).has(2)
	_change(record, monitor, "size_flags_stretch_ratio", MONITOR_RATIO)
	_change(record, equipment.get_node("Information"), "size_flags_stretch_ratio", TEXT_RATIO)
	var panel := PanelContainer.new()
	panel.name = "ExperimentPreview"
	panel.theme_type_variation = &"ChassisPanel"
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_stretch_ratio = LIST_RATIO
	equipment.add_child(panel)
	equipment.move_child(panel, monitor.get_index() + 1)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 12)
	panel.add_child(stack)
	var heading := Label.new()
	heading.text = "실험"
	heading.theme_type_variation = &"InstrumentLabel"
	stack.add_child(heading)
	var status := Label.new()
	status.text = "관찰 기록을 확인한 뒤 '다음'에서 개시합니다." if not unlocked else "개방됨 — 실험 단계에서 실행합니다."
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.theme_type_variation = &"MutedLabel"
	stack.add_child(status)
	var experiments: Array = current.available_experiments if current != null else []
	for experiment: ExperimentData in experiments:
		if experiment == null: continue
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		row.modulate = Color(1, 1, 1, 0.55 if not unlocked else 0.9)
		var icon := TextureRect.new()
		icon.texture = LOCK_ICON if not unlocked else LAMPS.ready
		icon.custom_minimum_size = Vector2(28, 28)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		row.add_child(icon)
		var label := Label.new()
		label.text = experiment.display_name
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(label)
		stack.add_child(row)
	var limit := Label.new()
	limit.text = "최대 %d회 · 결과는 실행한 뒤에만 공개됩니다." % (current.experiment_limit if current != null else 0)
	limit.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	limit.theme_type_variation = &"MutedLabel"
	stack.add_child(limit)
	record.extra_nodes = record.get("extra_nodes", []) + [panel]
