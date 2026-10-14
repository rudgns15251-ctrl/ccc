class_name ProfileData
extends Resource

@export var profile_id: String = ""
@export var subject_name: String = ""
@export var classification: String = ""
@export_multiline var basic_description: String = ""

@export_group("Presentation")
@export var subject_texture: Texture2D
@export_multiline var past_observations: String = ""
@export_multiline var researcher_notes: String = ""
