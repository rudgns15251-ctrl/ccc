class_name ExperimentData
extends Resource

@export var experiment_id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export_multiline var result_text: String = ""

@export_group("Presentation")
@export var result_texture: Texture2D
