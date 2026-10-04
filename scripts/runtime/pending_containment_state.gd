class_name PendingContainmentState
extends RefCounted

# Gameplay submissions only. Prototype Monitoring playback does not resolve them.
var _rooms_by_case: Dictionary[String, String] = {}
var _case_order: Array[String] = []


func try_add_pending(case_id: String, room_id: String) -> bool:
	if case_id.strip_edges().is_empty() or room_id.strip_edges().is_empty() or has_pending(case_id):
		return false
	_rooms_by_case[case_id] = room_id
	_case_order.append(case_id)
	return true


func has_pending(case_id: String) -> bool:
	return _rooms_by_case.has(case_id)


func get_pending_room_id(case_id: String) -> String:
	return _rooms_by_case.get(case_id, "")


func get_pending_case_ids() -> Array[String]:
	return _case_order.duplicate()


func remove_pending(case_id: String) -> bool:
	if not has_pending(case_id):
		return false
	_rooms_by_case.erase(case_id)
	_case_order.erase(case_id)
	return true


func reset() -> void:
	_rooms_by_case.clear()
	_case_order.clear()
