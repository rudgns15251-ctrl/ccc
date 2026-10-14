extends Control

# Presentation only: all enabled flags and text arrive from Main's real owners.
signal navigation_requested(stage: int)
signal research_requested
signal archive_requested
signal hypothesis_requested
signal save_requested
signal load_requested
signal collect_record_requested

func _ready() -> void:
	%Save.pressed.connect(func() -> void:
		if not %Save.disabled: save_requested.emit())
	%Load.pressed.connect(func() -> void:
		if not %Load.disabled: load_requested.emit())
	%CollectRecord.pressed.connect(func() -> void:
		if not %CollectRecord.disabled: collect_record_requested.emit())
	for index: int in range(4):
		var button: Button = get_node("%" + ["PROFILE", "CCTV", "EXPERIMENT", "CONTAINMENT"][index])
		button.pressed.connect(func() -> void:
			if not button.disabled: navigation_requested.emit(index))
	%Research.pressed.connect(func() -> void:
		if not %Research.disabled: research_requested.emit())
	%Archive.pressed.connect(func() -> void:
		if not %Archive.disabled: archive_requested.emit())
	%Hypothesis.pressed.connect(func() -> void:
		if not %Hypothesis.disabled: hypothesis_requested.emit())

func display(subject: String, stage: String, environment: String, work_stage: int, tools: bool, archive: bool, hypothesis: bool, status: String, runtime_id: int) -> void:
	GameText.set_text(%Subject, "%s", [subject])
	GameText.set_text(%Stage, "%s", [stage])
	GameText.set_text(%Environment, "%s", [environment])
	GameText.set_text(%SystemStatus, "%s", [status])
	%Research.disabled = not tools
	%Archive.disabled = not archive
	%Hypothesis.disabled = not hypothesis

func add_drawer(view: Control, kind: String) -> PanelContainer:
	var panel: PanelContainer = preload("res://scenes/ui/utility_drawer.tscn").instantiate()
	if kind == "HYPOTHESIS": panel.offset_left = panel.offset_right - 560
	panel.add_child(view)
	%DrawerLayer.add_child(panel)
	return panel


func show_active_utility(kind: String) -> void:
	for name: String in ["Research", "Archive", "Hypothesis"]:
		var button: Button = get_node("%" + name)
		var active: bool = kind == ("RESEARCH" if name == "Research" else "ARCHIVE" if name == "Archive" else "HYPOTHESIS")
		button.theme_type_variation = "ActiveRailButton" if active else "Button"


func display_navigation(presented: int, canonical: int, unlocked: Array, enabled: bool) -> void:
	var stages: Array[String] = ["PROFILE", "CCTV", "EXPERIMENT", "CONTAINMENT"]
	for index: int in range(stages.size()):
		var button: Button = get_node("%" + stages[index])
		var known: bool = unlocked.has(index) or index == canonical
		var allowed: bool = enabled and canonical >= 0 and (known or index == canonical + 1 and canonical < 3)
		button.disabled = not allowed
		button.theme_type_variation = "CurrentNavButton" if index == presented else "NavButton"
		var status: String = "CURRENT" if index == presented else "REVIEW" if known and index != canonical else "UNLOCKED" if known else "AVAILABLE" if allowed else "LOCKED"
		GameText.set_text(button, "%s\n%s", [stages[index], status])
