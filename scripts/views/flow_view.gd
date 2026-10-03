extends Control

signal advance_requested
signal research_log_requested

@onready var next_button: Button = %NextButton
@onready var research_log_button: Button = get_node_or_null("%OpenResearchLogButton") as Button


func _ready() -> void:
	next_button.pressed.connect(_on_next_button_pressed)
	if research_log_button != null:
		research_log_button.pressed.connect(_on_research_log_button_pressed)
	next_button.grab_focus()


func _on_next_button_pressed() -> void:
	advance_requested.emit()


func _on_research_log_button_pressed() -> void:
	if research_log_button != null and not research_log_button.disabled:
		research_log_requested.emit()
