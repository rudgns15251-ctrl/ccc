class_name ResearchArchiveState
extends RefCounted

var _entries_by_case: Dictionary[String, Array] = {}
var _case_order: Array[String] = []


func merge_case_discoveries(case_id: String, entry_ids: Array[String]) -> void:
	if case_id.strip_edges().is_empty():
		return
	for entry_id: String in entry_ids:
		if entry_id.strip_edges().is_empty():
			continue
		if not _entries_by_case.has(case_id):
			var entries: Array[String] = []
			_entries_by_case[case_id] = entries
			_case_order.append(case_id)
		if not _entries_by_case[case_id].has(entry_id):
			_entries_by_case[case_id].append(entry_id)


func has_discovered_entry(case_id: String, entry_id: String) -> bool:
	return _entries_by_case.has(case_id) and _entries_by_case[case_id].has(entry_id)


func get_discovered_entry_ids(case_id: String) -> Array[String]:
	if not _entries_by_case.has(case_id):
		return []
	return _entries_by_case[case_id].duplicate()


func get_archived_case_ids() -> Array[String]:
	return _case_order.duplicate()


func reset() -> void:
	_entries_by_case.clear()
	_case_order.clear()
