class_name CCTVData
extends Resource

@export var camera_id: String = ""
@export_multiline var observation_text: String = ""

@export_group("Presentation")
@export var feed_texture: Texture2D
@export var thermal_texture: Texture2D
