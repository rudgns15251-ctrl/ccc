extends Control

# Delayed containment result, delivered as a filed paper report at the next read boundary
# (the follow-up work's CCTV screen). Presentation only: the result is already recorded.
signal closed
signal archive_requested

const STAMP_SUCCESS := Color("2f5b3a")
const STAMP_FAILURE := Color("9b2f24")


func _ready() -> void:
	visible = false
	%CloseButton.pressed.connect(close)
	%ArchiveButton.pressed.connect(func() -> void:
		close()
		archive_requested.emit())


# report: {kicker, verdict, success, room, body}
func show_report(report: Dictionary) -> void:
	%Kicker.text = report.kicker
	%Verdict.text = report.verdict
	%Verdict.add_theme_color_override("font_color", STAMP_SUCCESS if report.success else STAMP_FAILURE)
	%Stamp.text = "안정" if report.success else "부적합"
	%Stamp.add_theme_color_override("font_color", STAMP_SUCCESS if report.success else STAMP_FAILURE)
	%Room.text = report.room
	%Body.text = report.body
	visible = true
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.2)
	%CloseButton.grab_focus()


func close() -> void:
	if not visible: return
	visible = false
	closed.emit()


func is_open() -> bool:
	return visible


func _process(_delta: float) -> void:
	if not visible: return
	var focused: Control = get_viewport().gui_get_focus_owner()
	if focused == null or not is_ancestor_of(focused): %CloseButton.grab_focus()


func _unhandled_key_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel") and not event.is_echo():
		get_viewport().set_input_as_handled()
		close()
