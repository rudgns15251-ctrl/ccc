class_name EmergencyBroadcastData
extends Resource

@export var broadcast_id: String = ""
@export var display_name: String = ""
@export_multiline var prompt_text: String = ""
@export var options: Array[BroadcastOptionData] = []

# Empty questions retain the original single-choice contract.
@export var questions: Array[BroadcastQuestionData] = []
@export var outcomes: Array[BroadcastOutcomeData] = []
@export_multiline var warning_text: String = ""

func is_multi_question() -> bool:
	return not questions.is_empty()

func get_response_options() -> Array[BroadcastOptionData]:
	if not is_multi_question(): return options
	var result: Array[BroadcastOptionData] = []
	result.assign(outcomes)
	return result

func valid_answers(answers: Dictionary, complete: bool = true) -> bool:
	if complete and answers.size() != questions.size(): return false
	for key: Variant in answers:
		if not key is String or not answers[key] is String: return false
		var found: bool = false
		for question: BroadcastQuestionData in questions:
			if question == null or question.question_id != key: continue
			for option: BroadcastOptionData in question.options:
				if option != null and option.option_id == answers[key]: found = true
		if not found: return false
	return true

func compose(answers: Dictionary, translated: bool = false) -> String:
	if not valid_answers(answers): return ""
	var lines: PackedStringArray = [tr(warning_text) if translated else warning_text]
	for question: BroadcastQuestionData in questions:
		for option: BroadcastOptionData in question.options:
			if option.option_id == answers[question.question_id]:
				lines.append(tr(option.instruction_text) if translated else option.instruction_text)
	return "\n\n".join(lines)

func find_outcome(answers: Dictionary) -> BroadcastOutcomeData:
	if not valid_answers(answers): return null
	var found: BroadcastOutcomeData
	for outcome: BroadcastOutcomeData in outcomes:
		if outcome != null and outcome.answers == answers:
			if found != null: return null
			found = outcome
	return found

func get_validation_error(results: Array) -> String:
	if broadcast_id.strip_edges().is_empty(): return "Missing broadcast identity."
	if not is_multi_question(): return ""
	if not options.is_empty() or questions.size() < 2 or questions.size() > 3 or warning_text.strip_edges().is_empty(): return "Invalid multi-question structure."
	var ids: Array[String] = []
	var option_ids: Array[String] = []
	var combinations: int = 1
	for question: BroadcastQuestionData in questions:
		if question == null or question.question_id.is_empty() or ids.has(question.question_id) or question.prompt_text.strip_edges().is_empty() or question.options.size() < 2: return "Invalid question."
		ids.append(question.question_id)
		combinations *= question.options.size()
		for option: BroadcastOptionData in question.options:
			if option == null or option.option_id.is_empty() or option_ids.has(option.option_id) or option.display_text.strip_edges().is_empty() or option.instruction_text.strip_edges().is_empty(): return "Invalid question option."
			option_ids.append(option.option_id)
	if combinations > 64 or outcomes.size() != combinations: return "Missing or excessive combinations."
	var outcome_ids: Array[String] = []
	for outcome: BroadcastOutcomeData in outcomes:
		if outcome == null or outcome.option_id.is_empty() or outcome_ids.has(outcome.option_id) or option_ids.has(outcome.option_id) or find_outcome(outcome.answers) != outcome or outcome.display_text != compose(outcome.answers): return "Duplicate or invalid combination."
		outcome_ids.append(outcome.option_id)
		var matches: int = 0
		for result: IncidentResultData in results:
			if result != null and result.result_id == outcome.result_id and result.valid_consequences(): matches += 1
		if matches != 1: return "Invalid result link."
	return ""
