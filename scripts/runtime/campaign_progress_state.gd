class_name CampaignProgressState
extends RefCounted

var _campaign_id: String = ""
var _entry_ids: Array[String] = []
var _current_entry_index: int = -1
var _completed_entry_ids: Array[String] = []
var _transition: Dictionary = {}


func configure(campaign_id: String, entry_ids: Array[String]) -> bool:
	if _current_entry_index != -1 or campaign_id.strip_edges().is_empty() or entry_ids.is_empty(): return false
	var unique: Array[String] = []
	for id: String in entry_ids:
		if id.strip_edges().is_empty() or unique.has(id): return false
		unique.append(id)
	_campaign_id = campaign_id
	_entry_ids = unique
	_current_entry_index = 0
	return true


func get_campaign_id() -> String:
	return _campaign_id


func get_current_entry_id() -> String:
	return _entry_ids[_current_entry_index] if _current_entry_index >= 0 and _current_entry_index < _entry_ids.size() else ""


func get_next_entry_id() -> String:
	return _entry_ids[_current_entry_index + 1] if _current_entry_index >= 0 and _current_entry_index + 1 < _entry_ids.size() else ""


func get_completed_entry_ids() -> Array[String]:
	return _completed_entry_ids.duplicate()


func bind_transition(target_id: String) -> bool:
	var current_id: String = get_current_entry_id()
	if current_id.is_empty() or target_id.is_empty() or target_id != get_next_entry_id(): return false
	if not _transition.is_empty(): return _transition.source_entry_id == current_id and _transition.target_entry_id == target_id
	_transition = {"source_entry_id": current_id, "target_entry_id": target_id, "failure_offer_consumed": false}
	return true


func consume_failure_offer() -> bool:
	if _transition.is_empty() or _transition.source_entry_id != get_current_entry_id() or _transition.target_entry_id != get_next_entry_id() or _transition.failure_offer_consumed: return false
	_transition.failure_offer_consumed = true
	return true


func get_transition() -> Dictionary:
	return _transition.duplicate(true)


func can_complete_current(entry_id: String) -> bool:
	return not entry_id.is_empty() and entry_id == get_current_entry_id() and not _completed_entry_ids.has(entry_id)


func try_complete_and_advance(entry_id: String) -> bool:
	if not can_complete_current(entry_id): return false
	_completed_entry_ids.append(entry_id)
	_current_entry_index += 1
	_transition.clear()
	return true


func reset() -> void:
	_campaign_id = ""
	_entry_ids.clear()
	_current_entry_index = -1
	_completed_entry_ids.clear()
	_transition.clear()
