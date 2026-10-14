class_name StoryCollectionState
extends RefCounted

const CAPACITIES: Array[int] = [6, 3, 3]
var _catalog: Dictionary[String, StoryRecordData] = {}
var _collected: Array[String] = []

func configure(records: Array[StoryRecordData]) -> bool:
	var catalog: Dictionary[String, StoryRecordData] = {}
	var counts: Array[int] = [0, 0, 0]
	for item: StoryRecordData in records:
		if item == null or item.record_id.strip_edges().is_empty() or catalog.has(item.record_id) or item.title.strip_edges().is_empty() or not StoryRecordData.Kind.values().has(item.kind): return false
		if item.discovery_entry_id.is_empty() and not item.discovery_stage.is_empty() or not item.discovery_entry_id.is_empty() and item.discovery_stage not in ["PROFILE", "CCTV", "EXPERIMENT", "CONTAINMENT"]: return false
		if item.discovery_entry_id.is_empty() and not item.discovery_stage.is_empty() or not item.discovery_entry_id.is_empty() and item.discovery_stage not in ["PROFILE", "CCTV", "EXPERIMENT", "CONTAINMENT"]: return false
		counts[item.kind] += 1
		if counts[item.kind] > CAPACITIES[item.kind]: return false
		catalog[item.record_id] = item
	_catalog = catalog
	_collected.clear()
	return true

func try_discover(id: String) -> bool:
	if not _catalog.has(id) or not _catalog[id].is_readable() or _collected.has(id): return false
	_collected.append(id)
	return true

func has_collected(id: String) -> bool:
	return _collected.has(id)

func can_read(id: String) -> bool:
	return _collected.has(id) and _catalog.has(id) and _catalog[id].is_readable()

func get_collected_ids() -> Array[String]:
	return _collected.duplicate()

func get_collection_summary() -> Dictionary:
	var counts: Array[int] = [0, 0, 0]
	for id: String in _collected: counts[_catalog[id].kind] += 1
	return {"total": _collected.size(), "by_kind": counts, "capacities": CAPACITIES.duplicate()}

func reset() -> void:
	_collected.clear()
