class_name ReleaseSettings
extends RefCounted

# Player options for the release front end (title, settings, pause). Stored apart from
# campaign saves; no Autoload — callers load, apply and save explicitly.
const PATH := "user://release_settings.cfg"
const TEXT_SCALES := {"small": 0.9, "normal": 1.0, "large": 1.15}
const DEFAULTS := {"master_volume": 0.8, "ui_volume": 0.8, "text_size": "normal"}

# Set by the title screen's Continue before the playtest scene starts.
static var continue_requested: bool = false


static func load_values() -> Dictionary:
	var values: Dictionary = DEFAULTS.duplicate()
	var file := ConfigFile.new()
	if file.load(PATH) == OK:
		values.master_volume = clampf(float(file.get_value("audio", "master_volume", values.master_volume)), 0.0, 1.0)
		values.ui_volume = clampf(float(file.get_value("audio", "ui_volume", values.ui_volume)), 0.0, 1.0)
		var size: String = str(file.get_value("display", "text_size", values.text_size))
		values.text_size = size if TEXT_SCALES.has(size) else DEFAULTS.text_size
	return values


static func save_values(values: Dictionary) -> void:
	var file := ConfigFile.new()
	file.set_value("audio", "master_volume", values.master_volume)
	file.set_value("audio", "ui_volume", values.ui_volume)
	file.set_value("display", "text_size", values.text_size)
	file.save(PATH)


static func volume_db(linear: float) -> float:
	return -80.0 if linear <= 0.001 else linear_to_db(linear)


static func apply_audio(values: Dictionary) -> void:
	AudioServer.set_bus_volume_db(0, volume_db(values.master_volume))
	AudioServer.set_bus_mute(0, values.master_volume <= 0.001)


static func text_scale(values: Dictionary) -> float:
	return TEXT_SCALES.get(values.text_size, 1.0)


# A copy of the theme with every font size multiplied; the base theme is never modified.
static func scaled_theme(base: Theme, scale: float) -> Theme:
	var theme: Theme = base.duplicate(true)
	theme.default_font_size = roundi(base.default_font_size * scale)
	for type: StringName in base.get_font_size_type_list():
		for name: StringName in base.get_font_size_list(type):
			theme.set_font_size(name, type, roundi(base.get_font_size(name, type) * scale))
	return theme
