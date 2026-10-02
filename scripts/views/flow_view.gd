extends Control

signal advance_requested

@onready var next_button: Button = %NextButton


func _ready() -> void:
	next_button.pressed.connect(_on_next_button_pressed)
	next_button.grab_focus()


func _on_next_button_pressed() -> void:
	advance_requested.emit()
