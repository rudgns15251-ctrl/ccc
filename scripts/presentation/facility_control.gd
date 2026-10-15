extends Node

# The records below hold original Control parents/properties for reversible layout
# changes. They are not campaign, research, response, or save state.
const BASE: Theme = preload("res://resources/ui/temp_industrial_theme.tres")
const ASSETS = preload("res://scripts/presentation/ui_asset_comparison.gd")
const SHELL = preload("res://scenes/ui/facility_control/shell.tscn")
const CCTV_LAYOUT = preload("res://scenes/ui/facility_control/cctv.tscn")
const BROADCAST_LAYOUT = preload("res://scenes/ui/facility_control/broadcast.tscn")
const CONFIRM_LAYOUT = preload("res://scenes/ui/facility_control/confirmation.tscn")
const CCTV_SCRIPT = preload("res://scripts/views/cctv_view.gd")
const BROADCAST_SCRIPT = preload("res://scripts/views/broadcast_view.gd")
const RESULT_SCRIPT = preload("res://scripts/views/incident_result_view.gd")
var game: Control
var enabled: bool = false
var effects_enabled: bool = false
var menu: MenuButton
var media: Node
var theme: Theme
var shell: Dictionary = {}
var views: Dictionary = {}

func configure(main: Control, initial: bool) -> void:
	game = main
	theme = _make_theme()
	media = ASSETS.new()
	add_child(media)
	media.game = game
	media.player = AudioStreamPlayer.new()
	media.player.volume_db = -22
	media.add_child(media.player)
	menu = MenuButton.new()
	menu.name = "StructureComparisonMenu"
	menu.text = "UI / 원본 구조"
	menu.custom_minimum_size = Vector2(300, 60)
	game.get_node("%Facility").get_parent().add_child(menu)
	menu.get_popup().add_radio_check_item("원본 구조", 0)
	menu.get_popup().add_radio_check_item("FACILITY CONTROL / 구조 시안", 1)
	menu.get_popup().add_separator()
	menu.get_popup().add_check_item("CCTV 영상 효과", 2)
	menu.get_popup().set_item_checked(3, false)
	menu.get_popup().add_check_item("송출 효과음 (기본 꺼짐)", 3)
	menu.get_popup().id_pressed.connect(_menu_selected)
	set_enabled(initial)

func _menu_selected(id: int) -> void:
	if _blocked(): return
	if id in [0, 1]: set_enabled(id == 1)
	elif id == 2:
		effects_enabled = not effects_enabled
		menu.get_popup().set_item_checked(3, effects_enabled)
		_refresh_media()
	elif id == 3:
		media.sound_enabled = not media.sound_enabled
		menu.get_popup().set_item_checked(4, media.sound_enabled)
		if not media.sound_enabled: media.player.stop()

func _blocked() -> bool:
	var view: Control = game.get("_current_view")
	return view == null or view.has_open_confirmation() or game.get("_persistence_busy") or game.get("_navigation_busy") or is_instance_valid(game.get("_disturbance_notice")) or is_instance_valid(game.get("_drawer_view"))

func _record(layout: Control) -> Dictionary:
	return {"layout": layout, "routes": [], "properties": [], "tags": []}

func _change(record: Dictionary, node: Object, property: String, value: Variant) -> void:
	for saved: Dictionary in record.properties:
		if saved.node == node and saved.property == property:
			node.set(property, value)
			return
	record.properties.append({"node": node, "property": property, "value": node.get(property)})
	node.set(property, value)

func _put(record: Dictionary, control: Control, target: Node, expand: bool = false) -> void:
	var recorded: bool = false
	for route: Dictionary in record.routes:
		if route.node == control: recorded = true;break
	if not recorded: record.routes.append({"node": control, "parent": control.get_parent(), "index": control.get_index()})
	if control.get_parent() != target: control.reparent(target, false)
	_change(record, control, "custom_minimum_size", Vector2.ZERO)
	_change(record, control, "size_flags_horizontal", Control.SIZE_EXPAND_FILL)
	_change(record, control, "size_flags_vertical", Control.SIZE_EXPAND_FILL if expand else Control.SIZE_FILL)

func _undo(record: Dictionary) -> void:
	var routes: Array = record.routes.duplicate()
	routes.reverse()
	for route: Dictionary in routes:
		if is_instance_valid(route.node) and is_instance_valid(route.parent):
			route.node.reparent(route.parent, false)
			route.parent.move_child(route.node, mini(route.index, route.parent.get_child_count()-1))
	for saved: Dictionary in record.properties:
		if is_instance_valid(saved.node): saved.node.set(saved.property, saved.value)
	for control: Variant in record.tags:
		if is_instance_valid(control): control.remove_meta("work_focus_path")
	if is_instance_valid(record.layout):
		record.layout.get_parent().remove_child(record.layout)
		record.layout.queue_free()

func set_enabled(value: bool) -> void:
	if value == enabled and not shell.is_empty(): return
	var focused: Control = game.get_viewport().gui_get_focus_owner()
	# Restore even detached work Views held by Main's Archive route.
	for record: Dictionary in views.values():
		if is_instance_valid(record.view.get_ref()):
			media.variant = 0
			if record.view.get_ref().get_script() == CCTV_SCRIPT: media._decorate_cctv(record.view.get_ref())
			if record.view.get_ref().get_script() == BROADCAST_SCRIPT: media._decorate_broadcast(record.view.get_ref())
			_undo(record)
	views.clear()
	if not shell.is_empty(): _undo(shell);shell.clear()
	enabled = value
	game.theme = theme if enabled else BASE
	menu.text = "UI / FACILITY CONTROL" if enabled else "UI / 원본 구조"
	menu.get_popup().set_item_checked(0, not enabled)
	menu.get_popup().set_item_checked(1, enabled)
	if enabled: _build_shell()
	decorate_view(game.get("_current_view"))
	game._refresh_shell()
	if is_instance_valid(focused) and focused.is_inside_tree() and focused.is_visible_in_tree(): focused.grab_focus.call_deferred()

func _build_shell() -> void:
	var layout: Control = SHELL.instantiate()
	game.game_shell.add_child(layout)
	# GUI hit testing follows tree order, not only z_index. Keep existing
	# drawers, disturbance notices and modal layers above the new chassis.
	game.game_shell.move_child(layout, game.get_node("%DrawerLayer").get_index())
	shell = _record(layout)
	_change(shell, game.get_node("%Frame"), "visible", false)
	for name: String in ["Facility", "Stage"]: _put(shell, game.get_node("%"+name), layout.get_node("Console/Identification/Row/FacilitySlot"))
	_put(shell, game.get_node("%Subject"), layout.get_node("Console/Identification/Row/SubjectSlot"))
	_put(shell, menu, layout.get_node("Console/Identification/Row/ComparisonSlot"))
	for name: String in ["PROFILE", "CCTV", "EXPERIMENT", "CONTAINMENT"]:
		var button: Button = game.get_node("%"+name)
		_put(shell, button, layout.get_node("Console/Navigation"))
		_change(shell, button, "custom_minimum_size", Vector2(0, 64))
	_put(shell, game.get_node("%Environment"), layout.get_node("Console/Alerts/AlertSlot"))
	_put(shell, game.get_node("%Workspace"), layout.get_node("Console/WorkSlot"), true)
	for name: String in ["Research", "Archive", "Hypothesis", "Save", "Load"]:
		var button: Button = game.get_node("%"+name)
		_put(shell, button, layout.get_node("Console/Records/Stack/Tools"))
		_change(shell, button, "custom_minimum_size", Vector2(0, 60))
		_change(shell, button, "theme_override_font_sizes/font_size", 22)
	_put(shell, game.get_node("%CollectRecord"), layout.get_node("Console/Identification/Row/CollectionSlot"))
	_put(shell, game.get_node("%SystemStatus"), layout.get_node("Console/StatusSlot"))

func decorate_view(view: Control) -> void:
	if not enabled or view == null or views.has(view.get_instance_id()): return
	var source: Script = view.get_script()
	if source not in [CCTV_SCRIPT, BROADCAST_SCRIPT]: return
	var layout: Control = (CCTV_LAYOUT if source == CCTV_SCRIPT else BROADCAST_LAYOUT).instantiate()
	view.add_child(layout)
	var record: Dictionary = _record(layout)
	record.view = weakref(view)
	for node: Node in view.find_children("*", "Control", true, false):
		if not layout.is_ancestor_of(node):
			node.set_meta("work_focus_path", String(view.get_path_to(node)))
			record.tags.append(node)
	_change(record, view.get_node("%Margin"), "visible", false)
	views[view.get_instance_id()] = record
	if source == CCTV_SCRIPT: _build_cctv(view, record)
	else: _build_broadcast(view, record)
	_refresh_media()

func _build_cctv(view: Control, record: Dictionary) -> void:
	var layout: Control = record.layout
	_change(record, view.get_node("%Placeholder"), "text", "No footage assigned\nTemporary observation area")
	_change(record, view.get_node("%Placeholder"), "horizontal_alignment", HORIZONTAL_ALIGNMENT_CENTER)
	_put(record, view.get_node("%ScreenTitle"), layout.get_node("Equipment/Monitor/Stack/Identification/TitleSlot"))
	_put(record, view.get_node("%CameraTab"), layout.get_node("Equipment/Monitor/Stack/Identification/CameraSlot"))
	_put(record, view.get_node("%FeedModes"), layout.get_node("Equipment/Monitor/Stack/ModeSlot"))
	_put(record, view.get_node("%CameraImage"), layout.get_node("Equipment/Monitor/Stack/VideoSlot"), true)
	_put(record, view.get_node("%ObservationHeading"), layout.get_node("Equipment/Information/Stack/HeadingSlot"))
	_put(record, view.get_node("%ConditionObservationScroll"), layout.get_node("Equipment/Information/Stack/ObservationSlot"), true)
	_put(record, view.get_node("%EnvironmentConditions"), layout.get_node("Equipment/Information/Stack/EnvironmentSlot"))
	_put(record, view.get_node("%Actions"), layout.get_node("Controls/ActionSlot"))
	_change(record, view.get_node("%Spacer"), "size_flags_horizontal", Control.SIZE_FILL)

func _build_broadcast(view: Control, record: Dictionary) -> void:
	var layout: Control = record.layout
	_put(record, view.get_node("%ScreenTitle"), layout.get_node("Identification/Row/TitleSlot"))
	_put(record, view.get_node("%Transmission"), layout.get_node("QuestionLayout/Context/ContextSlot"), true)
	_put(record, view.get_node("%OrdersHeading"), layout.get_node("QuestionLayout/Selection/Stack/HeadingSlot"))
	_put(record, view.option_scroll, layout.get_node("QuestionLayout/Selection/Stack/QuestionScrollSlot"), true)
	_connect_scroll_keys(view.option_scroll)
	_connect_scroll_keys(layout.get_node("PreviewLayout/Receipt/Stack/SummaryScroll"))
	_put(record, view.get_node("%Actions"), layout.get_node("Controls/ActionSlot"))
	if view.multi != null:
		_put(record, view.multi.progress, layout.get_node("QuestionLayout/Selection/Stack/ProgressSlot"))
		_put(record, view.multi.navigation, layout.get_node("QuestionLayout/Selection/Stack/QuestionNavigationSlot"))
	if not view.has_meta("facility_confirmation_connected"):
		view.set_meta("facility_confirmation_connected", true)
		view.confirmation_changed.connect(func() -> void:
			if enabled and view.has_open_confirmation(): _build_confirmation(view.get("_confirmation")))
	_sync_broadcast(view, record)

func _sync_broadcast(view: Control, record: Dictionary) -> void:
	var multi: Node = view.multi
	var preview: bool = multi.preview if multi != null else view._has_confirmation_snapshot()
	var locked: bool = multi.locked if multi != null else view._has_confirmation_snapshot()
	var layout: Control = record.layout
	layout.get_node("QuestionLayout").visible = not preview
	layout.get_node("PreviewLayout").visible = preview
	layout.get_node("Controls").theme_type_variation = "EmergencyPanel" if preview and not locked else "ChassisPanel"
	GameText.set_text(layout.get_node("Identification/Row/State"), "TRANSMISSION LOCKED" if locked else "REVIEW BEFORE TRANSMISSION" if preview else "PREPARING INSTRUCTIONS")
	for index: int in range(3):
		layout.get_node("Steps").get_child(index).modulate = Color(1, 0.85, 0.5) if index == (2 if locked or view.has_open_confirmation() else 1 if preview else 0) else Color(0.55, 0.60, 0.56)
	var slot: Node = layout.get_node("PreviewLayout/Transcript/Stack/PreviewScrollSlot" if preview else "QuestionLayout/Selection/Stack/QuestionScrollSlot")
	if view.option_scroll.get_parent() != slot: _put(record, view.option_scroll, slot, true)
	var context_slot: Node = layout.get_node("PreviewLayout/Receipt/Stack/SummaryScroll/Summary/SourceSlot" if preview else "QuestionLayout/Context/ContextSlot")
	if view.get_node("%Transmission").get_parent() != context_slot: _put(record, view.get_node("%Transmission"), context_slot, not preview)
	var summary := PackedStringArray()
	if multi != null:
		for question: BroadcastQuestionData in multi.data.questions:
			for option: BroadcastOptionData in question.options:
				if multi.answers.get(question.question_id, "") == option.option_id:
					summary.append(GameText.translate_value(question.prompt_text)+"\n"+GameText.translate_value(option.display_text))
	layout.get_node("PreviewLayout/Receipt/Stack/SummaryScroll/Summary/Answers").text = "\n\n".join(summary)
	var icon: CanvasItem = view.get_node("%OrdersHeading").get_node_or_null("AssetBroadcastIcon")
	if icon != null: icon.visible = locked

func restore_broadcast_scroll(view: Control, scroll: int) -> void:
	# Main already restored the authoritative draft. Wait for reparented Control
	# minimum sizes and deferred focus before restoring its existing pixel scroll.
	await get_tree().process_frame
	await get_tree().process_frame
	if is_instance_valid(view) and game.get("_current_view") == view and view.multi != null and not view.multi.locked:
		view.option_scroll.scroll_vertical = scroll

func _connect_scroll_keys(scroll: ScrollContainer) -> void:
	if scroll.has_meta("facility_scroll_keys"): return
	scroll.set_meta("facility_scroll_keys", true)
	scroll.gui_input.connect(_scroll_keys.bind(scroll))

func _scroll_keys(event: InputEvent, scroll: ScrollContainer) -> void:
	if not enabled or not event is InputEventKey or not event.pressed or game.get_viewport().gui_get_focus_owner() != scroll: return
	var movement: int = 0
	match event.keycode:
		KEY_PAGEDOWN: movement = maxi(1, int(scroll.size.y * 0.8))
		KEY_PAGEUP: movement = -maxi(1, int(scroll.size.y * 0.8))
		KEY_DOWN: movement = 40
		KEY_UP: movement = -40
		KEY_HOME: movement = -int(scroll.get_v_scroll_bar().max_value)
		KEY_END: movement = int(scroll.get_v_scroll_bar().max_value)
		_: return
	scroll.scroll_vertical += movement
	scroll.accept_event()

func _build_confirmation(modal: Control) -> void:
	if modal.has_meta("facility_authorization"): return
	modal.set_meta("facility_authorization", true)
	var panel: PanelContainer = modal.get_node("%Panel")
	panel.custom_minimum_size = Vector2(1320, 760)
	var layout: Control = CONFIRM_LAYOUT.instantiate()
	panel.add_child(layout)
	var old: Control = modal.get_node("%Content")
	old.visible = false
	for pair: Array in [["Title", "TitleSlot"], ["BodyScroll", "Body/Transcript/MessageSlot"], ["DecisionNotice", "Body/Approval/NoticeSlot"], ["Actions", "Body/Approval/ActionSlot"]]:
		var control: Control = modal.get_node("%"+pair[0])
		control.reparent(layout.get_node(pair[1]), false)
		control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if pair[0] == "BodyScroll": control.size_flags_vertical = Control.SIZE_EXPAND_FILL
	modal.get_node("%Message").theme_type_variation = "PaperBodyLabel"
	modal.get_node("%Confirm").theme_type_variation = "TransmitButton"
	var body: ScrollContainer = modal.get_node("%BodyScroll")
	body.focus_mode = Control.FOCUS_ALL
	_connect_scroll_keys(body)
	var cycle: Array[Control] = [modal.get_node("%Cancel"), body, modal.get_node("%Confirm")]
	for index: int in range(cycle.size()):
		cycle[index].focus_next = cycle[index].get_path_to(cycle[(index+1)%cycle.size()])
		cycle[index].focus_previous = cycle[index].get_path_to(cycle[(index+cycle.size()-1)%cycle.size()])
	modal.get_node("%Cancel").grab_focus()

func _refresh_media() -> void:
	var view: Control = game.get("_current_view")
	if view == null: return
	media.variant = (3 if media.is_available(3) else 2) if enabled and effects_enabled else 0
	if view.get_script() == CCTV_SCRIPT: media._decorate_cctv(view)
	if view.get_script() == BROADCAST_SCRIPT: media._decorate_broadcast(view)

func _process(_delta: float) -> void:
	if game == null: return
	menu.disabled = _blocked()
	if not enabled: return
	var layout: Control = shell.layout
	layout.get_node("Console/Alerts").visible = not game.get_node("%Environment").text.is_empty()
	layout.get_node("Console/Identification/Row/CollectionSlot").visible = game.get_node("%CollectRecord").visible
	var collect: Button = game.get_node("%CollectRecord")
	if collect.visible:
		var binding: Dictionary = collect.get_meta(GameText.BINDING_META, {})
		var source: String = binding.get("source", "")
		if not source.is_empty():
			_change(shell, collect, "tooltip_text", GameText.translate_value(source) % [GameText.translate_value(binding.arguments[0])])
			_change(shell, collect, "text", GameText.translate_value("Collected record" if source.begins_with("Collected:") else "Collect record"))
	var labels: Dictionary = {"Research": "RESEARCH LOG", "Archive": "RESEARCH ARCHIVE", "Hypothesis": "WORKING HYPOTHESIS", "Save": "Save progress", "Load": "Load saved progress"}
	for name: String in labels: _change(shell, game.get_node("%"+name), "text", GameText.translate_value(labels[name]))
	var drawer: Control = game.get("_drawer_panel")
	if is_instance_valid(drawer):
		drawer.offset_left = -756;drawer.offset_right = -20;drawer.offset_top = 180;drawer.offset_bottom = -180
	for id: int in views.keys():
		var record: Dictionary = views[id]
		var view: Control = record.view.get_ref()
		if view == null: views.erase(id);continue
		if view.get_script() == BROADCAST_SCRIPT: _sync_broadcast(view, record)
	var active: Control = game.get("_current_view")
	if active != null: decorate_view(active)

func _surface(color: Color, margin: float = 16) -> StyleBoxFlat:
	var box: StyleBoxFlat = ASSETS.MAUSE.get_stylebox("normal", "Button").duplicate(true)
	box.bg_color = color
	box.set_border_width_all(2)
	box.border_color = color.lightened(0.2)
	box.set_corner_radius_all(2)
	box.content_margin_left = margin;box.content_margin_right = margin
	box.content_margin_top = margin;box.content_margin_bottom = margin
	return box

func _make_theme() -> Theme:
	var result: Theme = BASE.duplicate(true)
	var surfaces: Dictionary = {"BackgroundPanel": Color("1a201e"), "ChassisPanel": Color("424a43"), "InstrumentPanel": Color("0d1b18"), "TranscriptPanel": Color("101d19"), "MonitorBezel": Color("343d36")}
	for type: String in surfaces:
		result.set_type_variation(type, "Panel" if type == "BackgroundPanel" else "PanelContainer")
		result.set_stylebox("panel", type, _surface(surfaces[type], 22 if type == "MonitorBezel" else 12))
	result.set_stylebox("panel", "EmergencyPanel", _surface(Color("5c3028")))
	result.set_stylebox("panel", "PanelContainer", _surface(Color("222c26")))
	result.set_type_variation("InstrumentLabel", "Label")
	result.set_color("font_color", "InstrumentLabel", Color("c6b884"))
	result.set_font_size("font_size", "InstrumentLabel", 20)
	result.set_font_size("font_size", "TitleLabel", 26)
	result.set_color("font_color", "Label", Color("e0e5d5"))
	result.set_color("font_color", "MutedLabel", Color("b0bba8"))
	for type: String in ["Button", "PrimaryButton", "NavButton", "CurrentNavButton", "ActiveRailButton", "TransmitButton"]:
		if type == "TransmitButton": result.set_type_variation(type, "Button")
		var primary: bool = type in ["PrimaryButton", "CurrentNavButton", "ActiveRailButton"]
		for state: String in ["normal", "hover", "pressed", "disabled", "focus"]:
			var color := Color("b8aa77") if primary else Color("485248")
			if type == "TransmitButton": color = Color("b56746")
			if state == "hover": color = color.lightened(0.15)
			if state == "pressed": color = color.darkened(0.18)
			if state == "disabled" and not primary: color = Color("29332c")
			var box: StyleBoxFlat = _surface(color, 14)
			if state == "focus":
				box.bg_color = Color.TRANSPARENT;box.border_color = Color("e9dba0")
			result.set_stylebox(state, type, box)
		for key: String in ["font_color", "font_focus_color", "font_hover_color", "font_pressed_color"]:
			result.set_color(key, type, Color("15231c") if primary else Color("eff0df"))
		result.set_color("font_disabled_color", type, Color("15231c") if primary else Color("a4b0a4"))
	for icon: StringName in ASSETS.VHS.get_icon_list("CheckBox"):
		result.set_icon(icon, "CheckBox", ASSETS.VHS.get_icon(icon, "CheckBox"))
	return result
