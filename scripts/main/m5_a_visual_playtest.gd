extends "res://scripts/main/m4_5_structural_comparison.gd"

# TEMP visual assets are presentation references, never containment evidence.
@export var environment_reference: Texture2D

func _create_facility_control() -> Node:
	return preload("res://scripts/presentation/visual_production.gd").new()
