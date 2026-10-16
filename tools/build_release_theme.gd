extends SceneTree

# Builds the release "Instrument Steel" theme (docs/ui_release/art_direction_v1.md).
# Run twice from the project root, importing in between:
#   godot --headless --path . --script res://tools/build_release_theme.gd -- textures
#   godot --headless --path . --editor --import --quit
#   godot --headless --path . --script res://tools/build_release_theme.gd -- theme
# Textures are generated here (no third-party art) and stay replaceable PNGs.
const TEX_DIR := "res://assets/ui/release/"
const FONT_DIR := "res://assets/fonts/release/"
const BASE_PATH := "res://resources/ui/temp_industrial_theme.tres"
const OUT_PATH := "res://resources/ui/release_instrument_steel_theme.tres"

const STEEL := Color("3b423b")
const STEEL_DARK := Color("2f352f")
const WELL := Color("262b26")
const SHADOW := Color("1b1f1b")
const EDGE := Color("4f584f")
const HIGHLIGHT := Color("566056")
const CRT := Color("0c140e")
const BEZEL := Color("0b0d0b")
const PAPER := Color("e6dfcc")
const PAPER_EDGE := Color("b9b09a")
const INK := Color("2a2620")
const INK_MUTED := Color("6b6352")
const TEXT := Color("e4e6dc")
const TEXT_MUTED := Color("aab2a5")
const TEXT_DISABLED := Color("7d857a")
const AMBER := Color("c9a24b")
const AMBER_LIGHT := Color("e0bd6a")
const AMBER_DARK := Color("8a6c2a")
const AMBER_INK := Color("1b1a14")
const ALARM := Color("b8432f")
const ALARM_LIGHT := Color("d86a54")
const ALARM_DARK := Color("6e2418")
const ALARM_BG := Color("3a1d17")
const PHOSPHOR := Color("9fd4a3")

var rng := RandomNumberGenerator.new()

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var mode: String = args[0] if not args.is_empty() else ""
	if mode == "textures":
		_build_textures()
	elif mode == "theme":
		_build_theme()
	else:
		push_error("build_release_theme: pass -- textures or -- theme")
	quit()

# ---------- textures ----------

func _noise(img: Image, base: Color, amount: float, from: Rect2i) -> void:
	for y in range(from.position.y, from.end.y):
		for x in range(from.position.x, from.end.x):
			var n: float = (rng.randf() - 0.5) * amount
			img.set_pixel(x, y, Color(base.r + n, base.g + n, base.b + n, base.a))

func _hline(img: Image, y: int, color: Color) -> void:
	for x in img.get_width(): img.set_pixel(x, y, color)

func _vline(img: Image, x: int, color: Color) -> void:
	for y in img.get_height(): img.set_pixel(x, y, color)

func _save(img: Image, name: String) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(TEX_DIR))
	img.save_png(ProjectSettings.globalize_path(TEX_DIR + name))
	print("TEXTURE ", name)

func _build_textures() -> void:
	rng.seed = 41  # deterministic output
	var s := 48
	# Painted steel: hammertone noise, raised edge.
	var steel := Image.create_empty(s, s, false, Image.FORMAT_RGBA8)
	_noise(steel, STEEL, 0.035, Rect2i(0, 0, s, s))
	_hline(steel, 0, HIGHLIGHT); _vline(steel, 0, HIGHLIGHT)
	_hline(steel, s - 1, SHADOW); _hline(steel, s - 2, SHADOW); _vline(steel, s - 1, SHADOW)
	_save(steel, "steel_panel.png")
	# Darker steel for the whole-screen background.
	var back := Image.create_empty(s, s, false, Image.FORMAT_RGBA8)
	_noise(back, STEEL_DARK, 0.03, Rect2i(0, 0, s, s))
	_save(back, "steel_background.png")
	# Recessed well: shadow on top, light lip at the bottom.
	var well := Image.create_empty(s, s, false, Image.FORMAT_RGBA8)
	_noise(well, WELL, 0.025, Rect2i(0, 0, s, s))
	_hline(well, 0, SHADOW); _hline(well, 1, SHADOW); _vline(well, 0, SHADOW)
	_hline(well, s - 1, EDGE); _vline(well, s - 1, EDGE)
	_save(well, "well_panel.png")
	# CRT: black bezel, thin outline, faint scanlines on the glass.
	var crt := Image.create_empty(s, s, false, Image.FORMAT_RGBA8)
	crt.fill(BEZEL)
	for y in range(7, s - 7):
		for x in range(7, s - 7):
			crt.set_pixel(x, y, CRT.darkened(0.3) if y % 3 == 0 else CRT)
	for i in s:
		crt.set_pixel(i, 0, EDGE); crt.set_pixel(i, s - 1, EDGE); crt.set_pixel(0, i, EDGE); crt.set_pixel(s - 1, i, EDGE)
	_save(crt, "crt_panel.png")
	# Report paper: warm fibre noise and a printed edge.
	var paper := Image.create_empty(64, 64, false, Image.FORMAT_RGBA8)
	_noise(paper, PAPER, 0.03, Rect2i(0, 0, 64, 64))
	for i in 64:
		paper.set_pixel(i, 0, PAPER_EDGE); paper.set_pixel(i, 63, PAPER_EDGE); paper.set_pixel(0, i, PAPER_EDGE); paper.set_pixel(63, i, PAPER_EDGE)
	_save(paper, "paper_panel.png")
	# Alarm band: dark red with red rails, used only for incidents and transmission.
	var alarm := Image.create_empty(s, s, false, Image.FORMAT_RGBA8)
	_noise(alarm, ALARM_BG, 0.02, Rect2i(0, 0, s, s))
	for row in [0, 1, s - 2, s - 1]: _hline(alarm, row, ALARM)
	_save(alarm, "alarm_panel.png")
	# Check / radio lamps (24 px): unlit well vs lit amber.
	for lit in [false, true]:
		for radio in [false, true]:
			var icon := Image.create_empty(24, 24, false, Image.FORMAT_RGBA8)
			icon.fill(Color(0, 0, 0, 0))
			for y in 24:
				for x in 24:
					var inside: bool = Vector2(x - 11.5, y - 11.5).length() <= 10.5 if radio else (x >= 2 and x <= 21 and y >= 2 and y <= 21)
					var core: bool = Vector2(x - 11.5, y - 11.5).length() <= 5.5 if radio else (x >= 7 and x <= 16 and y >= 7 and y <= 16)
					if inside: icon.set_pixel(x, y, SHADOW)
					if inside and core: icon.set_pixel(x, y, AMBER_LIGHT if lit else WELL)
			_save(icon, "%s_%s.png" % ["radio" if radio else "check", "on" if lit else "off"])

# ---------- theme ----------

func _tex(name: String, margin: int, content: float, tile: bool = true) -> StyleBoxTexture:
	var box := StyleBoxTexture.new()
	box.texture = load(TEX_DIR + name)
	box.texture_margin_left = margin; box.texture_margin_right = margin
	box.texture_margin_top = margin; box.texture_margin_bottom = margin
	if tile:
		box.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_TILE
		box.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_TILE
	box.content_margin_left = content; box.content_margin_right = content
	box.content_margin_top = content; box.content_margin_bottom = content
	return box

func _key(bg: Color, border: Color, lip: Color, pressed: bool = false) -> StyleBoxFlat:
	# A physical key: raised keys carry a dark lip below (drawn as an offset shadow,
	# since StyleBoxFlat has a single border colour); a pressed key sits flush.
	var box := StyleBoxFlat.new()
	box.bg_color = bg
	box.border_color = lip if pressed else border
	box.set_border_width_all(1)
	box.anti_aliasing = false
	box.content_margin_left = 16; box.content_margin_right = 16
	box.content_margin_top = 10; box.content_margin_bottom = 10
	if not pressed:
		box.shadow_color = lip
		box.shadow_size = 1
		box.shadow_offset = Vector2(0, 2)
	return box

func _flat(bg: Color, border: Color, width: int = 1) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = bg
	box.border_color = border
	box.set_border_width_all(width)
	box.anti_aliasing = false
	return box

func _set_button(theme: Theme, type: String, bg: Color, border: Color, lip: Color, hover: Color, pressed_bg: Color, text: Color) -> void:
	theme.set_stylebox("normal", type, _key(bg, border, lip))
	theme.set_stylebox("hover", type, _key(hover, border.lightened(0.1), lip))
	theme.set_stylebox("pressed", type, _key(pressed_bg, lip, lip, true))
	theme.set_stylebox("hover_pressed", type, _key(pressed_bg, lip, lip, true))
	var disabled := _flat(Color("2a302a"), Color("343a34"))
	disabled.content_margin_left = 16; disabled.content_margin_right = 16
	disabled.content_margin_top = 10; disabled.content_margin_bottom = 10
	theme.set_stylebox("disabled", type, disabled)
	var focus := _flat(Color(0, 0, 0, 0), AMBER_LIGHT, 2)
	focus.draw_center = false
	focus.expand_margin_left = 2; focus.expand_margin_right = 2; focus.expand_margin_top = 2; focus.expand_margin_bottom = 2
	theme.set_stylebox("focus", type, focus)
	for key in ["font_color", "font_focus_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color"]:
		theme.set_color(key, type, text)
	theme.set_color("font_disabled_color", type, TEXT_DISABLED)

func _build_theme() -> void:
	var theme: Theme = (load(BASE_PATH) as Theme).duplicate(true)
	var sans: FontFile = load(FONT_DIR + "IBMPlexSansKR-Regular.ttf")
	var sans_medium: FontFile = load(FONT_DIR + "IBMPlexSansKR-Medium.ttf")
	var sans_semibold: FontFile = load(FONT_DIR + "IBMPlexSansKR-SemiBold.ttf")
	var mono := FontVariation.new()
	mono.base_font = load(FONT_DIR + "IBMPlexMono-Medium.ttf")
	var typewriter: FontFile = load(FONT_DIR + "NanumGothicCoding-Regular.ttf")
	var typewriter_bold: FontFile = load(FONT_DIR + "NanumGothicCoding-Bold.ttf")
	# Mono has no Hangul: fall back to the sans for Korean in instrument text.
	mono.fallbacks = [sans]
	theme.default_font = sans
	theme.default_font_size = 22

	# Panels — role equals material.
	var variations := {"BackgroundPanel": "Panel", "ChassisPanel": "PanelContainer", "InstrumentPanel": "PanelContainer", "TranscriptPanel": "PanelContainer", "MonitorBezel": "PanelContainer", "TransmitButton": "Button", "InstrumentLabel": "Label"}
	for type: String in variations: theme.set_type_variation(type, variations[type])
	theme.set_stylebox("panel", "Panel", _tex("steel_panel.png", 4, 12))
	theme.set_stylebox("panel", "PanelContainer", _tex("well_panel.png", 4, 12))
	theme.set_stylebox("panel", "BackgroundPanel", _tex("steel_background.png", 0, 0))
	theme.set_stylebox("panel", "ChassisPanel", _tex("steel_panel.png", 4, 14))
	theme.set_stylebox("panel", "RailPanel", _tex("steel_panel.png", 4, 12))
	theme.set_stylebox("panel", "SystemPanel", _tex("well_panel.png", 4, 10))
	theme.set_stylebox("panel", "InstrumentPanel", _tex("crt_panel.png", 8, 16))
	theme.set_stylebox("panel", "TranscriptPanel", _tex("crt_panel.png", 8, 16))
	theme.set_stylebox("panel", "MonitorBezel", _tex("crt_panel.png", 8, 14))
	theme.set_stylebox("panel", "PaperDocumentPanel", _tex("paper_panel.png", 2, 28))
	theme.set_stylebox("panel", "WarningPanel", _tex("alarm_panel.png", 3, 12))
	theme.set_stylebox("panel", "EmergencyPanel", _tex("alarm_panel.png", 3, 14))
	var backdrop := _flat(Color(0.03, 0.04, 0.03, 0.82), Color(0, 0, 0, 0), 0)
	theme.set_stylebox("panel", "ModalBackdropPanel", backdrop)
	var tooltip := _flat(WELL, EDGE)
	tooltip.content_margin_left = 10; tooltip.content_margin_right = 10; tooltip.content_margin_top = 6; tooltip.content_margin_bottom = 6
	theme.set_stylebox("panel", "TooltipPanel", tooltip)
	theme.set_color("font_color", "TooltipLabel", TEXT)
	theme.set_font_size("font_size", "TooltipLabel", 18)

	# Keys.
	for type in ["Button", "NavButton", "OptionButton", "CheckButton"]:
		_set_button(theme, type, Color("444c44"), Color("5a645a"), SHADOW, Color("4e574e"), Color("3a413a"), TEXT)
	theme.set_font("font", "Button", sans_medium)
	for type in ["PrimaryButton", "CurrentNavButton", "ActiveRailButton"]:
		_set_button(theme, type, AMBER, AMBER_LIGHT, AMBER_DARK, Color("d6b05a"), Color("b38f3f"), AMBER_INK)
	# The current work key is a disabled button that must still read as lit.
	theme.set_stylebox("disabled", "CurrentNavButton", _key(AMBER, AMBER_LIGHT, AMBER_DARK))
	theme.set_color("font_disabled_color", "CurrentNavButton", AMBER_INK)
	theme.set_font("font", "PrimaryButton", sans_semibold)
	theme.set_font("font", "CurrentNavButton", sans_semibold)
	_set_button(theme, "TransmitButton", ALARM, ALARM_LIGHT, ALARM_DARK, Color("c9503a"), Color("9c3726"), Color("fff4ee"))
	theme.set_font("font", "TransmitButton", sans_semibold)

	# One TEMP BUILD badge replaces the repeated per-screen temporary notices.
	theme.set_type_variation("TempBadgeButton", "Button")
	var badge := _flat(Color(0, 0, 0, 0), AMBER, 1)
	badge.content_margin_left = 12; badge.content_margin_right = 12; badge.content_margin_top = 4; badge.content_margin_bottom = 4
	for state in ["normal", "hover", "pressed", "hover_pressed", "disabled", "focus"]:
		theme.set_stylebox(state, "TempBadgeButton", badge)
	for key in ["font_color", "font_focus_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color", "font_disabled_color"]:
		theme.set_color(key, "TempBadgeButton", AMBER)
	theme.set_font("font", "TempBadgeButton", mono)
	theme.set_font_size("font_size", "TempBadgeButton", 16)

	# Check boxes become indicator lamps on keys.
	for type: String in ["CheckBox", "SelectedCandidateCheckBox", "CompletedCandidateCheckBox"]:
		var base_on: bool = type != "CheckBox"
		_set_button(theme, type, Color("4a3f22") if base_on else Color("3a413a"), AMBER if base_on else Color("5a645a"), SHADOW, Color("554826") if base_on else Color("444c44"), Color("4a3f22"), Color("f2e6c4") if base_on else TEXT)
	theme.set_color("font_disabled_color", "CompletedCandidateCheckBox", Color("f2e6c4"))
	theme.set_stylebox("disabled", "CompletedCandidateCheckBox", _key(Color("4a3f22"), AMBER, SHADOW))
	var lamps := {"checked": "check_on", "unchecked": "check_off", "checked_disabled": "check_on", "unchecked_disabled": "check_off", "radio_checked": "radio_on", "radio_unchecked": "radio_off", "radio_checked_disabled": "radio_on", "radio_unchecked_disabled": "radio_off"}
	for icon: String in lamps: theme.set_icon(icon, "CheckBox", load(TEX_DIR + lamps[icon] + ".png"))
	theme.set_constant("h_separation", "CheckBox", 12)

	# Text entry sits in a recessed well.
	for type in ["LineEdit", "TextEdit"]:
		var field := _flat(Color("1f241f"), EDGE)
		field.content_margin_left = 12; field.content_margin_right = 12; field.content_margin_top = 8; field.content_margin_bottom = 8
		var focus := field.duplicate(); focus.border_color = AMBER_LIGHT; focus.set_border_width_all(2)
		theme.set_stylebox("normal", type, field)
		theme.set_stylebox("focus", type, focus)
		theme.set_stylebox("read_only", type, field)
		theme.set_color("font_color", type, TEXT)
		theme.set_color("caret_color", type, AMBER_LIGHT)
		theme.set_color("selection_color", type, Color(0.79, 0.64, 0.29, 0.35))

	# Scroll bars: thin rails, amber when dragged.
	for type in ["VScrollBar", "HScrollBar"]:
		var rail := _flat(Color("1f241f"), Color(0, 0, 0, 0), 0)
		rail.content_margin_left = 5; rail.content_margin_right = 5; rail.content_margin_top = 5; rail.content_margin_bottom = 5
		theme.set_stylebox("scroll", type, rail)
		theme.set_stylebox("scroll_focus", type, rail)
		theme.set_stylebox("grabber", type, _flat(Color("5a645a"), Color(0, 0, 0, 0), 0))
		theme.set_stylebox("grabber_highlight", type, _flat(Color("6b766b"), Color(0, 0, 0, 0), 0))
		theme.set_stylebox("grabber_pressed", type, _flat(AMBER, Color(0, 0, 0, 0), 0))

	# Scroll bar for documents on paper: printed rule instead of a steel rail.
	theme.set_type_variation("PaperVScrollBar", "VScrollBar")
	var paper_rail := _flat(Color("d6ceb8"), Color(0, 0, 0, 0), 0)
	paper_rail.content_margin_left = 4; paper_rail.content_margin_right = 4; paper_rail.content_margin_top = 4; paper_rail.content_margin_bottom = 4
	theme.set_stylebox("scroll", "PaperVScrollBar", paper_rail)
	theme.set_stylebox("scroll_focus", "PaperVScrollBar", paper_rail)
	theme.set_stylebox("grabber", "PaperVScrollBar", _flat(Color("a39a86"), Color(0, 0, 0, 0), 0))
	theme.set_stylebox("grabber_highlight", "PaperVScrollBar", _flat(INK_MUTED, Color(0, 0, 0, 0), 0))
	theme.set_stylebox("grabber_pressed", "PaperVScrollBar", _flat(INK, Color(0, 0, 0, 0), 0))

	# Labels.
	theme.set_color("font_color", "Label", TEXT)
	theme.set_constant("line_spacing", "Label", 4)
	theme.set_color("font_color", "MutedLabel", TEXT_MUTED)
	theme.set_font("font", "TitleLabel", sans_semibold)
	theme.set_font_size("font_size", "TitleLabel", 28)
	theme.set_font("font", "HeadingLabel", sans_semibold)
	theme.set_font_size("font_size", "HeadingLabel", 24)
	theme.set_color("font_color", "WarningLabel", Color("e9b8ab"))
	theme.set_font("font", "InstrumentLabel", mono)
	theme.set_color("font_color", "InstrumentLabel", Color("c9b27a"))
	theme.set_font_size("font_size", "InstrumentLabel", 18)
	# Paper documents use the typewriter face and ink colours.
	for type in ["PaperBodyLabel", "PaperSectionLabel", "PaperMetadataLabel"]:
		theme.set_font("font", type, typewriter)
	theme.set_font("font", "PaperHeadingLabel", typewriter_bold)
	theme.set_font("font", "PaperSectionLabel", typewriter_bold)
	theme.set_color("font_color", "PaperBodyLabel", INK)
	theme.set_color("font_color", "PaperMetadataLabel", INK_MUTED)
	theme.set_constant("line_spacing", "PaperBodyLabel", 8)
	var rule := StyleBoxLine.new()
	rule.color = INK
	rule.thickness = 2
	theme.set_stylebox("separator", "PaperSeparator", rule)
	theme.set_constant("separation", "PaperSeparator", 14)
	theme.set_color("default_color", "RichTextLabel", TEXT)
	theme.set_font("normal_font", "RichTextLabel", sans)
	theme.set_font("bold_font", "RichTextLabel", sans_semibold)
	theme.set_font("mono_font", "RichTextLabel", mono)

	var err := ResourceSaver.save(theme, OUT_PATH)
	print("THEME ", OUT_PATH, " err=", err)
