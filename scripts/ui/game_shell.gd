extends Control

# Presentation only: all enabled flags and text arrive from Main's real owners.
signal research_requested
signal archive_requested
signal hypothesis_requested
var _runtime_id: int = -1
var _visited: Array[int] = []

func _ready() -> void:
	%Research.pressed.connect(func() -> void:
		if not %Research.disabled: research_requested.emit())
	%Archive.pressed.connect(func() -> void:
		if not %Archive.disabled: archive_requested.emit())
	%Hypothesis.pressed.connect(func() -> void:
		if not %Hypothesis.disabled: hypothesis_requested.emit())

func display(subject: String, stage: String, environment: String, work_stage: int, tools: bool, archive: bool, hypothesis: bool, status: String, runtime_id: int) -> void:
	%Subject.text = subject
	%Stage.text = stage
	%Environment.text = environment
	%SystemStatus.text = status
	%Research.disabled = not tools
	%Archive.disabled = not archive
	%Hypothesis.disabled = not hypothesis
	if _runtime_id != runtime_id:
		_runtime_id = runtime_id
		_visited.clear()
	if work_stage >= 0 and not _visited.has(work_stage): _visited.append(work_stage)
	var stages: Array[String] = ["PROFILE", "CCTV", "EXPERIMENT", "CONTAINMENT"]
	for index: int in range(stages.size()):
		var button: Button = get_node("%" + stages[index])
		# Indicators cannot introduce free back-navigation.
		button.disabled = true
		button.theme_type_variation = "CurrentNavButton" if index == work_stage else "NavButton"
		button.text = stages[index] + "\n" + ("CURRENT" if index == work_stage else "VISITED" if _visited.has(index) or index < work_stage else "AVAILABLE" if index == work_stage + 1 else "LOCKED") if work_stage >= 0 else stages[index] + "\nLOCKED"

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
