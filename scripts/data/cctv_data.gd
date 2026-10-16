class_name CCTVData
extends Resource

@export var camera_id: String = ""
@export_multiline var observation_text: String = ""
# Player-facing camera name; camera_id stays the stable Research/source key.
@export var camera_label: String = ""


func get_display_name() -> String:
	return camera_label if not camera_label.strip_edges().is_empty() else camera_id

@export_group("Presentation")
@export var feed_texture: Texture2D
@export var thermal_texture: Texture2D
