extends Node

# Styling and local media only. Never advances work or writes gameplay/save owners.
const BASE: Theme = preload("res://resources/ui/temp_industrial_theme.tres")
const MAUSE: Theme = preload("res://assets/third_party/m4_5/mause_os/styles_only.tres")
const VHS: Theme = preload("res://assets/third_party/m4_5/vhs_ui_free/themes/camcorder.tres")
const REC: Texture2D = preload("res://assets/third_party/m4_5/vhs_ui_free/icons/rec.png")
const CORNER: Texture2D = preload("res://assets/third_party/m4_5/vhs_ui_free/icons/corner.png")
const SNOW: Shader = preload("res://assets/third_party/m4_5/vhs_ui_free/shaders/snow.gdshader")
const RETRO_DIR: String = "res://assets/local_only/m4_5/retro_screen_fx_lite/"
const TITLES: Array[String] = ["원본", "MAUSE OS", "VHS UI", "MAUSE + CRT", "MAUSE + VHS FX"]
const SFX: Array[AudioStream] = [preload("res://assets/third_party/m4_5/analog_horror_sfx_free/alert_beeps.ogg"),preload("res://assets/third_party/m4_5/analog_horror_sfx_free/vhs_play.ogg"),preload("res://assets/third_party/m4_5/analog_horror_sfx_free/channel_change_01.ogg")]

var game: Control
var variant: int = 0
var sound_enabled: bool = false
var menu: MenuButton
var player: AudioStreamPlayer
var themes: Array[Theme] = []
var _heard: Dictionary = {}

func configure(main: Control, initial: int) -> void:
	game = main
	themes.assign([BASE, _adapt(MAUSE), _adapt(VHS)])
	menu = MenuButton.new();menu.name = "AssetComparisonMenu"
	menu.custom_minimum_size = Vector2(220,48)
	menu.tooltip_text = "M4.5 비교 시안 — 기본 프로젝트에는 적용되지 않습니다."
	game.get_node("%Facility").get_parent().add_child(menu)
	var popup: PopupMenu = menu.get_popup()
	for index: int in range(TITLES.size()):
		popup.add_radio_check_item(TITLES[index],index)
		popup.set_item_disabled(index,not is_available(index))
	popup.add_separator()
	popup.add_check_item("효과음 사용 (기본 꺼짐)",10)
	popup.add_item("경고음 미리듣기",11)
	popup.add_item("송출음 미리듣기",12)
	popup.add_item("채널음 미리듣기",13)
	popup.id_pressed.connect(_on_menu)
	player = AudioStreamPlayer.new();player.name = "ComparisonAudio"
	player.volume_db = -22.0;player.max_polyphony = 1
	add_child(player)
	set_variant(initial)

func is_available(index: int) -> bool:
	return index in range(3) or index in [3,4] and FileAccess.file_exists(RETRO_DIR+("crt.gdshader" if index==3 else "vhs.gdshader"))

func _adapt(source: Theme) -> Theme:
	var result: Theme = BASE.duplicate(true)
	# Preserve Korean typography, Control sizes and all Paper* type variations.
	for type: StringName in source.get_type_list():
		for key: StringName in source.get_stylebox_list(type): result.set_stylebox(key,type,source.get_stylebox(key,type).duplicate(true))
		for key: StringName in source.get_color_list(type): result.set_color(key,type,source.get_color(key,type))
		for key: StringName in source.get_icon_list(type): result.set_icon(key,type,source.get_icon(key,type))
	for type: StringName in BASE.get_type_list():
		if String(type).begins_with("Paper"):
			result.set_color("font_shadow_color",type,Color.TRANSPARENT)
	for type: StringName in [&"Button",&"CheckBox",&"CheckButton"]:
		result.set_color("font_disabled_color",type,Color(0.56,0.58,0.59))
	for state: StringName in [&"normal",&"hover",&"pressed",&"disabled",&"focus"]:
		var style: StyleBox = result.get_stylebox(state,"Button")
		style.content_margin_left = 12;style.content_margin_right = 12
		style.content_margin_top = 8;style.content_margin_bottom = 8
	# CAP's semantic variants use the chosen pack's state styles, not stale green fills.
	for type: StringName in [&"PrimaryButton",&"NavButton",&"CurrentNavButton",&"ActiveRailButton"]:
		for state: StringName in [&"normal",&"hover",&"pressed",&"disabled",&"focus"]:
			var chosen: StringName = &"hover" if type in [&"PrimaryButton",&"CurrentNavButton",&"ActiveRailButton"] and state in [&"normal",&"disabled"] else state
			result.set_stylebox(state,type,result.get_stylebox(chosen,"Button"))
		if type != &"NavButton":
			# Highlighted styles use the pack's hover ink (VHS yellow needs dark text).
			result.set_color("font_color",type,source.get_color("font_hover_color","Button"))
			result.set_color("font_focus_color",type,source.get_color("font_hover_color","Button"))
			result.set_color("font_disabled_color",type,source.get_color("font_hover_color","Button"))
		else: result.set_color("font_disabled_color",type,Color(0.56,0.58,0.59))
	# Existing disabled/selected experiment rows must remain distinguishable and legible.
	for type: StringName in [&"SelectedCandidateCheckBox",&"CompletedCandidateCheckBox"]:
		for state: StringName in [&"normal",&"pressed",&"hover",&"disabled",&"hover_pressed"]:
			result.set_stylebox(state,type,result.get_stylebox("hover","Button"))
		result.set_color("font_color",type,source.get_color("font_hover_color","Button"))
		result.set_color("font_disabled_color",type,source.get_color("font_hover_color","Button"))
		result.set_color("checkbox_checked_color",type,source.get_color("font_hover_color","Button"))
	if source==MAUSE:
		result.set_color("checkbox_unchecked_color","CheckBox",Color(0.65,0.67,0.68))
		result.set_color("checkbox_checked_color","CheckBox",Color.WHITE)
		# MAUSE has Panel styling, but no PanelContainer entry. Keep CAP's exact
		# content margins when applying that surface to the fixed Shell sections.
		for type: StringName in [&"Panel",&"PanelContainer",&"BackgroundPanel",&"RailPanel",&"SystemPanel"]:
			var style: StyleBox = source.get_stylebox("panel","Panel").duplicate(true)
			var original: StyleBox = BASE.get_stylebox("panel",type)
			style.content_margin_left = original.content_margin_left
			style.content_margin_top = original.content_margin_top
			style.content_margin_right = original.content_margin_right
			style.content_margin_bottom = original.content_margin_bottom
			result.set_stylebox("panel",type,style)
	else:
		# VHS's outline-only panel is transparent. Use its opaque ScreenPanel
		# surface for content/modal panels so underlying orders never show through.
		var panel: StyleBoxFlat = source.get_stylebox("panel","ScreenPanel").duplicate(true)
		panel.set_border_width_all(1);panel.border_color = source.get_color("font_color","Button")
		var original: StyleBox = BASE.get_stylebox("panel","PanelContainer")
		panel.content_margin_left = original.content_margin_left
		panel.content_margin_right = original.content_margin_right
		panel.content_margin_top = original.content_margin_top
		panel.content_margin_bottom = original.content_margin_bottom
		result.set_stylebox("panel","PanelContainer",panel)
	return result

func set_variant(index: int) -> bool:
	if index < 0 or index >= TITLES.size() or not is_available(index): return false
	variant = index
	game.theme = themes[2 if index==2 else 1 if index>0 else 0]
	game.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST if index==2 else CanvasItem.TEXTURE_FILTER_PARENT_NODE
	menu.text = "UI 비교: "+TITLES[index]
	for i: int in range(5): menu.get_popup().set_item_checked(i,i==index)
	decorate_current_view()
	return true

func _on_menu(id: int) -> void:
	var view: Control = game.get("_current_view")
	if view == null or view.has_open_confirmation() or game.get("_persistence_busy"): return
	if id < 5: set_variant(id)
	elif id==10:
		sound_enabled = not sound_enabled
		menu.get_popup().set_item_checked(menu.get_popup().get_item_index(10),sound_enabled)
		if not sound_enabled: player.stop()
	elif id in [11,12,13]: audition(id-11)

func audition(index: int) -> void:
	if not sound_enabled or index < 0 or index >= SFX.size(): return
	player.stream = SFX[index];player.play()

func decorate_current_view() -> void:
	var view: Control = game.get("_current_view")
	if view==null or not view.is_node_ready(): return
	if view.get_script()==preload("res://scripts/views/cctv_view.gd"):
		_decorate_cctv(view)
	if view.get_script()==preload("res://scripts/views/broadcast_view.gd"):
		_decorate_broadcast(view)

func _icon(parent: Control, texture: Texture2D, id: String) -> TextureRect:
	var icon := TextureRect.new();icon.name = id;icon.texture = texture
	icon.custom_minimum_size = Vector2(32,32);icon.size = Vector2(32,32)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE;icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE;icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	parent.add_child(icon);return icon

func _decorate_broadcast(view: Control) -> void:
	var title: Label = view.get_node("%OrdersHeading")
	var icon: TextureRect = title.get_node_or_null("AssetBroadcastIcon") as TextureRect
	if icon==null:
		icon = _icon(title,REC,"AssetBroadcastIcon")
		icon.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
		icon.offset_left = -32;icon.offset_bottom = 32
	icon.visible = variant>0
	if not view.has_meta("asset_audio_connected"):
		view.set_meta("asset_audio_connected",true)
		view.multi_confirmation_requested.connect(func(_id: String,_answers: Dictionary) -> void: _transmitted(view))
		view.broadcast_confirmation_requested.connect(func(_id: String,_option: String) -> void: _transmitted(view))

func _transmitted(view: Control) -> void:
	if not sound_enabled or game.get("_current_view")!=view: return
	var response: Dictionary = game.incident_responses.get_active_response()
	if response.get("confirmed_option_id", "").is_empty(): return
	var key: String = JSON.stringify([response.origin_kind,response.source_occurrence_id,response.incident_id])
	if _heard.has(key): return
	_heard[key] = true;audition(1)

func _decorate_cctv(view: Control) -> void:
	var frame: PanelContainer = view.get_node("%CameraImage")
	var overlay: Control = view.get_node_or_null("AssetFeedOverlay") as Control
	if overlay==null:
		overlay = Control.new();overlay.name = "AssetFeedOverlay"
		overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		view.add_child(overlay)
		for index: int in range(4):
			var corner: TextureRect = _icon(overlay,CORNER,"Corner"+str(index))
			corner.flip_h = index%2==1;corner.flip_v = index>=2
			corner.set_anchors_and_offsets_preset([Control.PRESET_TOP_LEFT,Control.PRESET_TOP_RIGHT,Control.PRESET_BOTTOM_LEFT,Control.PRESET_BOTTOM_RIGHT][index])
			if index%2==1: corner.offset_left = -32;corner.offset_right = 0
			if index>=2: corner.offset_top = -32;corner.offset_bottom = 0
		var align: Callable = func() -> void:
			if is_instance_valid(overlay) and frame.is_inside_tree(): overlay.position = view.get_global_transform().affine_inverse()*frame.global_position;overlay.size = frame.size
		frame.resized.connect(align);frame.item_rect_changed.connect(align);align.call_deferred()
	overlay.visible = variant>0
	var holder: SubViewportContainer = frame.get_node_or_null("AssetFeedViewport") as SubViewportContainer
	if variant in [3,4]:
		if holder==null:
			var original: Array[Node] = frame.get_children()
			holder = SubViewportContainer.new();holder.name = "AssetFeedViewport"
			holder.stretch = true;holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
			frame.add_child(holder)
			var viewport := SubViewport.new();viewport.name = "IsolatedFeed"
			viewport.disable_3d = true;viewport.gui_disable_input = true;viewport.transparent_bg = true
			viewport.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE
			holder.add_child(viewport)
			var surface := MarginContainer.new();surface.name = "OriginalFeedContent"
			viewport.add_child(surface);surface.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			for child: Node in original:
				if not String(child.name).begins_with("Asset"): child.reparent(surface,false)
			# Explicit viewport texture input avoids a screen-copy pass affecting other
			# Compatibility canvases. The restricted shader source stays local-only.
			holder.self_modulate.a = 0.0
			var output := TextureRect.new();output.name = "AssetRetroOutput"
			output.mouse_filter = Control.MOUSE_FILTER_IGNORE
			output.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			output.texture = viewport.get_texture()
			frame.add_child(output)
		var output: TextureRect = frame.get_node("AssetRetroOutput")
		var material := ShaderMaterial.new()
		material.shader = _local_texture_shader("crt.gdshader" if variant==3 else "vhs.gdshader")
		material.set_shader_parameter("screen_tex",output.texture)
		material.set_shader_parameter("amount",0.35)
		material.set_shader_parameter("noise_amount",0.008)
		if variant==3:
			material.set_shader_parameter("curvature",0.08);material.set_shader_parameter("zoom",1.01)
			material.set_shader_parameter("scanline_strength",0.12);material.set_shader_parameter("mask_strength",0.08)
			material.set_shader_parameter("glow_amount",0.08);material.set_shader_parameter("flicker_amount",0.0)
		else:
			material.set_shader_parameter("wobble_amount",0.35);material.set_shader_parameter("tracking_amount",0.02)
		output.material = material
		holder.get_node("IsolatedFeed/OriginalFeedContent").theme = game.theme
	elif holder!=null:
		var surface: Control = holder.get_node("IsolatedFeed/OriginalFeedContent")
		for child: Node in surface.get_children(): child.reparent(frame,false)
		frame.remove_child(holder);holder.queue_free()
		var output: Node = frame.get_node("AssetRetroOutput")
		frame.remove_child(output);output.queue_free()
	var snow: ColorRect = frame.get_node_or_null("AssetSnow") as ColorRect
	if variant==2 and snow==null:
		snow = ColorRect.new();snow.name = "AssetSnow";snow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var material := ShaderMaterial.new();material.shader = SNOW
		material.set_shader_parameter("amount",0.035);material.set_shader_parameter("roll",0.0)
		snow.material = material;frame.add_child(snow)
	if snow!=null: snow.visible = variant==2

func _local_texture_shader(filename: String) -> Shader:
	# Modification permitted for own games. No upstream source is embedded here.
	var source: String = FileAccess.get_file_as_string(RETRO_DIR+filename)
	var common: String = FileAccess.get_file_as_string(RETRO_DIR+"rsfx_common.gdshaderinc")
	source = source.replace('#include "rsfx_common.gdshaderinc"',common)
	source = source.replace("hint_screen_texture, ","")
	source = source.replace("SCREEN_UV","UV").replace("SCREEN_PIXEL_SIZE","TEXTURE_PIXEL_SIZE")
	source = source.replace("FRAGCOORD.xy","(UV / TEXTURE_PIXEL_SIZE)")
	source = source.replace("FRAGCOORD.x","(UV.x / TEXTURE_PIXEL_SIZE.x)").replace("FRAGCOORD.y","(UV.y / TEXTURE_PIXEL_SIZE.y)")
	var shader := Shader.new();shader.code = source
	return shader
