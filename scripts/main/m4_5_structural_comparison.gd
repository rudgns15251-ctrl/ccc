extends "res://scripts/main/main.gd"

# This entry point changes presentation only. Main remains the sole gameplay owner.
@export var structural_design: bool = true
var facility_control: Node

func _ready() -> void:
	super._ready()
	facility_control = _create_facility_control()
	add_child(facility_control)
	facility_control.configure(self, structural_design)

func _create_facility_control() -> Node:
	return preload("res://scripts/presentation/facility_control.gd").new()

func _show_view(stage: int, discover_displayed_source: bool = true, restoring_work: bool = false, presentation_only: bool = false) -> void:
	super._show_view(stage, discover_displayed_source, restoring_work, presentation_only)
	if is_instance_valid(facility_control): facility_control.decorate_view(_current_view)

func _on_work_focus_changed(control: Control) -> void:
	super._on_work_focus_changed(control)
	if control != null and is_instance_valid(_current_view) and _presented_work_stage >= 0 and _current_view.is_ancestor_of(control) and control.has_meta("work_focus_path"):
		_work_focus[_presented_work_stage] = control.get_meta("work_focus_path")

func _restore_response_broadcast_draft(view: BroadcastView) -> void:
	var draft: Dictionary = _interrupt_context.get("broadcast_draft", {}).duplicate()
	super._restore_response_broadcast_draft(view)
	if is_instance_valid(facility_control) and facility_control.enabled and not draft.is_empty() and view.multi != null:
		facility_control.restore_broadcast_scroll(view, draft.get("multi", {}).get("scroll", 0))
