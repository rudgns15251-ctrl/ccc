extends VBoxContainer

# Presentation-only draft. IncidentResponseState commits after the final modal.
var host: Control
var data: EmergencyBroadcastData
var answers: Dictionary = {}
var question_index: int = 0
var preview: bool = false
var locked: bool = false
var progress: Label
var question_title: Label
var choices: VBoxContainer
var navigation: HBoxContainer
var previous: Button
var following: Button
var preview_text: Label
var review: Button
var edit: Button

func initialize(view: Control, broadcast: EmergencyBroadcastData) -> void:
	host = view;data = broadcast
	host.option_scroll.focus_mode = Control.FOCUS_ALL
	name = "MultiQuestion"
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_theme_constant_override("separation", 20)
	progress = _label("QuestionProgress");progress.theme_type_variation = "HeadingLabel"
	question_title = _label("QuestionTitle")
	choices = VBoxContainer.new();choices.name = "QuestionChoices";add_child(choices)
	navigation = HBoxContainer.new();navigation.name = "QuestionNavigation";add_child(navigation)
	previous = _button("PreviousQuestion", "Previous question", navigation, func() -> void: _move(-1))
	following = _button("NextQuestion", "Next question", navigation, func() -> void: _move(1))
	preview_text = _label("BroadcastPreview")
	review = _button("ReviewBroadcast", "Review broadcast", host.confirm_button.get_parent(), _review)
	host.confirm_button.get_parent().move_child(review, host.confirm_button.get_index())
	edit = _button("EditBroadcast", "Edit instructions", host.confirm_button.get_parent(), _edit)
	host.confirm_button.get_parent().move_child(edit, host.confirm_button.get_index())
	refresh();focus_current.call_deferred()

func _label(id: String) -> Label:
	var label := Label.new();label.name = id
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(label);return label

func _button(id: String, text: String, parent: Node, callback: Callable) -> Button:
	var button := Button.new();button.name = id;button.text = text
	button.custom_minimum_size = Vector2(0,48)
	button.pressed.connect(func() -> void:
		if host._allows_local_input() and not locked: callback.call())
	parent.add_child(button);return button

func _move(delta: int) -> void:
	question_index = clampi(question_index + delta,0,data.questions.size()-1)
	refresh();choices.get_child(0).grab_focus()

func _review() -> void:
	if not data.valid_answers(answers): return
	preview = true;refresh();host.confirm_button.grab_focus()
	host.option_scroll.scroll_vertical = 0

func _edit() -> void:
	preview = false;refresh();previous.grab_focus()
	host.option_scroll.scroll_vertical = 0

func refresh() -> void:
	var option_id: String = host._confirmed_option_id
	locked = host._has_confirmation_snapshot()
	if locked:
		for outcome: BroadcastOutcomeData in data.outcomes:
			if outcome.option_id == option_id: answers = outcome.answers.duplicate(true)
		preview = true
	var complete: bool = data.valid_answers(answers)
	GameText.set_text(progress, "Answered %d / %d — unanswered: %d", [answers.size(),data.questions.size(),data.questions.size()-answers.size()])
	question_title.visible = not preview
	choices.visible = not preview;navigation.visible = not preview
	preview_text.visible = preview
	host.get_node("%OrdersHeading").text = "Broadcast preview" if preview else "Response questions"
	if preview: preview_text.text = data.compose(answers,true)
	previous.disabled = locked or question_index == 0
	following.disabled = locked or question_index == data.questions.size()-1
	review.visible = not preview;review.disabled = locked or not complete
	edit.visible = preview and not locked
	host.confirm_button.text = "Transmit broadcast"
	host.confirm_button.visible = preview and not locked
	host.confirm_button.disabled = locked or not complete
	host.next_button.visible = locked
	host.next_button.disabled = not host._has_matching_confirmation()
	if preview:
		if locked and not host.next_button.disabled: host.next_button.grab_focus.call_deferred()
		return
	var question: BroadcastQuestionData = data.questions[question_index]
	GameText.set_text(question_title, "Question %d / %d\n%s", [question_index+1,data.questions.size(),question.prompt_text])
	for child: Node in choices.get_children(): choices.remove_child(child);child.queue_free()
	var group := ButtonGroup.new()
	for option: BroadcastOptionData in question.options:
		var button := CheckBox.new();button.name = option.option_id
		button.text = option.display_text;button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.custom_minimum_size.y = 64;button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.button_group = group
		button.set_pressed_no_signal(answers.get(question.question_id, "") == option.option_id)
		button.disabled = locked
		button.pressed.connect(func() -> void:
			if locked or not host._allows_local_input() or not button.is_inside_tree(): return
			answers[question.question_id] = option.option_id
			GameText.set_text(progress, "Answered %d / %d — unanswered: %d", [answers.size(),data.questions.size(),data.questions.size()-answers.size()])
			review.disabled = not data.valid_answers(answers))
		choices.add_child(button)

func confirm() -> void:
	if locked or not preview or not data.valid_answers(answers): return
	var snapshot: Dictionary = answers.duplicate(true)
	host.open_confirmation("TRANSMIT EMERGENCY ORDERS", data.compose(snapshot,true), "TRANSMIT", Vector2(900,620), func() -> void:
		if not locked and preview and answers == snapshot and host._broadcast_data == data:
			host.multi_confirmation_requested.emit(data.broadcast_id,snapshot))

func capture_draft() -> Dictionary:
	return {"answers":answers.duplicate(true),"question":question_index,"preview":preview,"scroll":host.option_scroll.scroll_vertical}

func restore_draft(draft: Dictionary) -> bool:
	if locked or draft.size() != 4 or not draft.get("answers") is Dictionary or not draft.get("question") is int or not draft.get("preview") is bool or not draft.get("scroll") is int: return false
	if not data.valid_answers(draft.answers,false) or draft.question < 0 or draft.question >= data.questions.size() or draft.preview and not data.valid_answers(draft.answers): return false
	answers = draft.answers.duplicate(true);question_index = draft.question;preview = draft.preview
	refresh();focus_current.call_deferred();host.option_scroll.set_deferred("scroll_vertical",maxi(0,draft.scroll))
	return true

func focus_current() -> void:
	if not is_inside_tree() or is_queued_for_deletion(): return
	if locked:
		if not host.next_button.disabled: host.next_button.grab_focus()
	elif preview: host.confirm_button.grab_focus()
	elif choices.get_child_count() > 0: choices.get_child(0).grab_focus()
