class_name WorkingHypothesisState
extends RefCounted

# Prototype UI safety limit, not gameplay balance. Reject; never truncate.
const MAX_TEXT_LENGTH: int = 500

var _records_by_case: Dictionary[String, Array] = {}
var _next_id_by_case: Dictionary[String, int] = {}


func add_hypothesis(case_id: String, text: String) -> String:
	var cleaned: String = text.strip_edges()
	if case_id.strip_edges().is_empty() or cleaned.is_empty() or cleaned.length() > MAX_TEXT_LENGTH:
		return ""
	var sequence: int = _next_id_by_case.get(case_id, 1)
	var id: String = "HYP_%03d" % sequence
	_next_id_by_case[case_id] = sequence + 1
	if not _records_by_case.has(case_id):
		_records_by_case[case_id] = []
	_records_by_case[case_id].append({"hypothesis_id": id, "text": cleaned})
	return id


func update_hypothesis(case_id: String, hypothesis_id: String, text: String) -> bool:
	var cleaned: String = text.strip_edges()
	if case_id.strip_edges().is_empty() or cleaned.is_empty() or cleaned.length() > MAX_TEXT_LENGTH:
		return false
	for record: Dictionary in _records_by_case.get(case_id, []):
		if record.hypothesis_id == hypothesis_id:
			record.text = cleaned
			return true
	return false


func remove_hypothesis(case_id: String, hypothesis_id: String) -> bool:
	if case_id.strip_edges().is_empty():
		return false
	var records: Array = _records_by_case.get(case_id, [])
	for index in range(records.size()):
		if records[index].hypothesis_id == hypothesis_id:
			records.remove_at(index)
			return true
	return false


func get_hypotheses(case_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for record: Dictionary in _records_by_case.get(case_id, []):
		result.append(record.duplicate(true))
	return result


func clear_case(case_id: String) -> void:
	_records_by_case.erase(case_id)
	# Keep counters for the entire session, including explicit clear operations.


func clear_all() -> void:
	_records_by_case.clear()
