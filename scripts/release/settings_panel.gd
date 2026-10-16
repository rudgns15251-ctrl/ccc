extends PanelContainer

# Settings panel shared by the title screen and the pause menu.
signal values_changed(values: Dictionary)
signal closed

const SIZE_ORDER := ["small", "normal", "large"]
var values: Dictionary = {}


func _ready() -> void:
	values = ReleaseSettings.load_values()
	%MasterSlider.value = values.master_volume * 100.0
	%UiSlider.value = values.ui_volume * 100.0
	%TextSize.selected = SIZE_ORDER.find(values.text_size)
	_refresh_labels()
	%MasterSlider.value_changed.connect(func(v: float) -> void: _store("master_volume", v / 100.0))
	%UiSlider.value_changed.connect(func(v: float) -> void: _store("ui_volume", v / 100.0))
	%TextSize.item_selected.connect(func(i: int) -> void: _store("text_size", SIZE_ORDER[i]))
	%CloseButton.pressed.connect(_close)


func open() -> void:
	visible = true
	%MasterSlider.grab_focus()


func _store(key: String, value: Variant) -> void:
	values[key] = value
	ReleaseSettings.save_values(values)
	ReleaseSettings.apply_audio(values)
	_refresh_labels()
	values_changed.emit(values)


func _refresh_labels() -> void:
	%MasterValue.text = "%d%%" % roundi(values.master_volume * 100.0)
	%UiValue.text = "%d%%" % roundi(values.ui_volume * 100.0)


func _close() -> void:
	visible = false
	closed.emit()


func _unhandled_key_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel") and not event.is_echo():
		get_viewport().set_input_as_handled()
		_close()
