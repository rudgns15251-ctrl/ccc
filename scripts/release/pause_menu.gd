extends Control

# Pause overlay for the release preview. The game has no real-time simulation, so pausing
# only covers the screen and blocks input beneath it; no campaign state is touched.
signal resumed
signal settings_changed(values: Dictionary)

const TITLE_SCENE := "res://scenes/release/title_screen.tscn"
const CASE1_TITLE_SCENE := "res://scenes/release/title_case1.tscn"
var _pending: String = ""


func _ready() -> void:
	visible = false
	%ResumeButton.pressed.connect(close)
	%SettingsButton.pressed.connect(func() -> void:
		%Menu.visible = false
		%SettingsPanel.open())
	%TitleButton.pressed.connect(_ask.bind("title"))
	%QuitButton.pressed.connect(_ask.bind("quit"))
	%ConfirmButton.pressed.connect(_confirm)
	%CancelButton.pressed.connect(_cancel_question)
	%SettingsPanel.values_changed.connect(func(values: Dictionary) -> void: settings_changed.emit(values))
	%SettingsPanel.closed.connect(func() -> void:
		%Menu.visible = true
		%SettingsButton.grab_focus())


func open() -> void:
	visible = true
	_cancel_question()
	%SettingsPanel.visible = false
	%Menu.visible = true
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.12)
	%ResumeButton.grab_focus()


func _process(_delta: float) -> void:
	# Keep keyboard focus inside the overlay while it is shown.
	if not visible: return
	var owner_control: Control = get_viewport().gui_get_focus_owner()
	if owner_control == null or not is_ancestor_of(owner_control):
		(%CancelButton if %Confirm.visible else %ResumeButton if %Menu.visible else %SettingsPanel.get_node("%CloseButton")).grab_focus()


func close() -> void:
	visible = false
	resumed.emit()


func is_open() -> bool:
	return visible


# Leaving discards unsaved progress, so it asks once more (Cancel has focus).
func _ask(action: String) -> void:
	_pending = action
	%Question.text = "저장하지 않은 진행은 사라집니다. 타이틀로 돌아갈까요?" if action == "title" else "저장하지 않은 진행은 사라집니다. 게임을 종료할까요?"
	%Buttons.visible = false
	%Confirm.visible = true
	%CancelButton.grab_focus()


func _cancel_question() -> void:
	_pending = ""
	%Buttons.visible = true
	%Confirm.visible = false
	if visible: %ResumeButton.grab_focus()


func _confirm() -> void:
	if _pending == "title": get_tree().change_scene_to_file(CASE1_TITLE_SCENE if OS.has_feature("case1_preview") else TITLE_SCENE)
	elif _pending == "quit": get_tree().quit()


func _unhandled_key_input(event: InputEvent) -> void:
	if not visible or not event.is_action_pressed("ui_cancel") or event.is_echo(): return
	get_viewport().set_input_as_handled()
	if %SettingsPanel.visible: return
	if not _pending.is_empty(): _cancel_question()
	else: close()
