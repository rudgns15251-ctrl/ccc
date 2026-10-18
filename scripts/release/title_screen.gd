extends Control

# Release title screen (TEMP preview front end). Starts or continues the T04 playtest
# campaign; continuing reuses the campaign's existing save slot through Main.
const RELEASE_THEME: Theme = preload("res://resources/ui/release_instrument_steel_theme.tres")
@export_file("*.tscn") var game_scene: String = "res://scenes/playtests/t04_playtest.tscn"
@export var campaign: CampaignData = preload("res://resources/campaigns/temp_t04_playtest.tres")
const CLICK: AudioStream = preload("res://assets/ui/release/sfx/ui_key_a.wav")
const LATCH: AudioStream = preload("res://assets/ui/release/sfx/ui_latch.wav")

var _values: Dictionary = {}
@onready var _settings: Control = %SettingsPanel
@onready var _player: AudioStreamPlayer = %ClickPlayer


func _ready() -> void:
	_values = ReleaseSettings.load_values()
	ReleaseSettings.apply_audio(_values)
	_apply_text_size()
	var has_save: bool = CampaignSaveStore.read(campaign.campaign_id).error.is_empty()
	%ContinueButton.disabled = not has_save
	%ContinueButton.tooltip_text = "" if has_save else "저장된 진행이 없습니다."
	%NewButton.pressed.connect(_start.bind(false))
	%ContinueButton.pressed.connect(_start.bind(true))
	%SettingsButton.pressed.connect(_open_settings)
	%CreditsButton.pressed.connect(func() -> void:
		%Menu.visible = false
		%CreditsPanel.open())
	%CreditsPanel.closed.connect(func() -> void:
		%Menu.visible = true
		%CreditsButton.grab_focus())
	%QuitButton.pressed.connect(func() -> void: get_tree().quit())
	_settings.values_changed.connect(func(values: Dictionary) -> void:
		_values = values
		_apply_text_size()
		_player.volume_db = -9.0 + ReleaseSettings.volume_db(values.ui_volume))
	_settings.closed.connect(func() -> void:
		%Menu.visible = true
		%SettingsButton.grab_focus())
	for button: BaseButton in find_children("*", "BaseButton", true, false):
		button.button_down.connect(_click.bind(button))
	_player.volume_db = -9.0 + ReleaseSettings.volume_db(_values.ui_volume)
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.4)
	(%ContinueButton if has_save else %NewButton).grab_focus()


func _apply_text_size() -> void:
	theme = ReleaseSettings.scaled_theme(RELEASE_THEME, ReleaseSettings.text_scale(_values))


func _click(button: BaseButton) -> void:
	_player.stream = LATCH if button.theme_type_variation == &"PrimaryButton" else CLICK
	_player.play()


func _open_settings() -> void:
	%Menu.visible = false
	_settings.open()


func _start(continuing: bool) -> void:
	ReleaseSettings.continue_requested = continuing
	for button: BaseButton in find_children("*", "BaseButton", true, false): button.disabled = true
	var fade := create_tween()
	fade.tween_property(self, "modulate:a", 0.0, 0.3)
	fade.tween_callback(func() -> void: get_tree().change_scene_to_file(game_scene))
