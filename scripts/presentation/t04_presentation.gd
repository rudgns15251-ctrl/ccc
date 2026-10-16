extends "res://scripts/presentation/visual_production.gd"

# Release "Instrument Steel" theme preview (docs/ui_release/art_direction_v1.md); built by tools/build_release_theme.gd.
const RELEASE_THEME: Theme = preload("res://resources/ui/release_instrument_steel_theme.tres")
const ARCHIVE_LIST_SCRIPT = preload("res://scripts/views/research_archive_list_view.gd")
const ARCHIVE_DETAIL_SCRIPT = preload("res://scripts/views/research_archive_detail_view.gd")
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
var _sfx_players: Array[AudioStreamPlayer] = []
var _sfx_next: int = 0
var _sfx_rng := RandomNumberGenerator.new()


const PAUSE_MENU: PackedScene = preload("res://scenes/release/pause_menu.tscn")
const TOOL_FONT_SIZE := 25
var _settings: Dictionary = ReleaseSettings.load_values()
var _pause: Control
var _menu_button: Button


func configure(main: Control, initial: bool) -> void:
	ReleaseSettings.apply_audio(_settings)
	super.configure(main, initial)
	for index: int in 4:
		var player := AudioStreamPlayer.new()
		add_child(player)
		_sfx_players.append(player)
	_apply_ui_volume()
	for node: Node in game.find_children("*", "BaseButton", true, false): _attach_click(node)
	get_tree().node_added.connect(_on_node_added)
	var layer := CanvasLayer.new()
	layer.layer = 64
	add_child(layer)
	_pause = PAUSE_MENU.instantiate()
	_pause.theme = theme
	layer.add_child(_pause)
	_pause.settings_changed.connect(_on_settings_changed)
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
	if enabled:
		game.theme = theme
		for name: String in TOOL_ICONS: _change(shell, game.get_node("%" + name), "theme_override_font_sizes/font_size", roundi(TOOL_FONT_SIZE * ReleaseSettings.text_scale(_settings)))


func _apply_ui_volume() -> void:
	for player: AudioStreamPlayer in _sfx_players: player.volume_db = SFX_VOLUME_DB + ReleaseSettings.volume_db(_settings.ui_volume)


func open_pause() -> void:
	if enabled and not _pause.is_open() and not _blocked() and game.get("_current_stage") not in [MAIN_STAGE_ARCHIVE_LIST, MAIN_STAGE_ARCHIVE_DETAIL]:
		_pause.open()


func _unhandled_key_input(event: InputEvent) -> void:
	if not enabled or _pause.is_open() or not event.is_action_pressed("ui_cancel") or event.is_echo(): return
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

const MAIN_STAGE_INCIDENT := 6  # Main.Stage.INCIDENT
const MAIN_STAGE_BROADCAST := 7  # Main.Stage.BROADCAST
const MAIN_STAGE_INCIDENT_RESULT := 8  # Main.Stage.INCIDENT_RESULT
const MAIN_STAGE_ARCHIVE_LIST := 10  # Main.Stage.RESEARCH_ARCHIVE_LIST
const MAIN_STAGE_ARCHIVE_DETAIL := 11  # Main.Stage.RESEARCH_ARCHIVE_DETAIL

func _make_theme() -> Theme:
	return ReleaseSettings.scaled_theme(RELEASE_THEME, ReleaseSettings.text_scale(_settings))


func _build_shell() -> void:
	super._build_shell()
	# Release chrome: the structure-comparison menu is a development control.
	_change(shell, menu, "visible", false)
	for name: String in ["Research", "Archive", "Hypothesis", "Save", "Load"]:
		var tool: Button = game.get_node("%" + name)
		_change(shell, tool, "theme_override_font_sizes/font_size", roundi(TOOL_FONT_SIZE * ReleaseSettings.text_scale(_settings)))
		_change(shell, tool, "icon", TOOL_ICONS[name])
		_change(shell, tool, "icon_alignment", HORIZONTAL_ALIGNMENT_LEFT)
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
	if fresh: _fade_in(view)


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
		_fade_in(notice)
	var view: Control = game.get("_current_view")
	if view != null and view.get_script() == CONTAINMENT_SCRIPT:
		_highlight_comparison(view)
	_merge_conditions_into_band(view)


# 720p space: the shell's alert band and a work screen's "current facility conditions" block
# repeat the same heading. Keep one — the band — and append the block's detail line to it.
# During incident / broadcast / report the broadcast banner already carries the context.
func _merge_conditions_into_band(view: Control) -> void:
	var alerts: Control = shell.layout.get_node("Console/Alerts")
	if game.get("_current_stage") in [MAIN_STAGE_INCIDENT, MAIN_STAGE_BROADCAST, MAIN_STAGE_INCIDENT_RESULT]:
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
	if view != null and view.get_script() == RESULT_SCRIPT:
		_strip(view.get_node("%DisplayName"))
		_strip(view.get_node("%ResponseContext"), true)
	if view != null and view.get_script() in [ARCHIVE_LIST_SCRIPT, ARCHIVE_DETAIL_SCRIPT]:
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
