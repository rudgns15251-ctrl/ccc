extends "res://scripts/main/main.gd"

# Only this F6 comparison scene installs the visual adapter. Main remains unchanged.
@export_range(0, 4) var comparison_variant: int = 0
var asset_comparison: Node

func _ready() -> void:
	super._ready()
	asset_comparison = preload("res://scripts/presentation/ui_asset_comparison.gd").new()
	add_child(asset_comparison)
	asset_comparison.configure(self, comparison_variant)

func _show_view(stage: int, discover_displayed_source: bool = true, restoring_work: bool = false, presentation_only: bool = false) -> void:
	super._show_view(stage, discover_displayed_source, restoring_work, presentation_only)
	if is_instance_valid(asset_comparison): asset_comparison.decorate_current_view()
