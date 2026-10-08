class_name IncidentSource
extends RefCounted

enum OriginKind { CASE, CAMPAIGN_ENTRY, CAMPAIGN_INTERRUPT }

var origin_kind: int
var source_occurrence_id: String
var source_definition_id: String
# Derived compatibility for existing sequence/Case callers only. No setter or
# second stored authority; a side occurrence is never a fake sequence entry.
var source_entry_id: String:
	get: return source_occurrence_id if origin_kind in [OriginKind.CASE, OriginKind.CAMPAIGN_ENTRY] else ""


func _init(kind: int = -1, occurrence_id: String = "", definition_id: String = "") -> void:
	origin_kind = kind
	source_occurrence_id = occurrence_id
	source_definition_id = definition_id


func is_valid() -> bool:
	return origin_kind in [OriginKind.CASE, OriginKind.CAMPAIGN_ENTRY, OriginKind.CAMPAIGN_INTERRUPT] and not source_occurrence_id.strip_edges().is_empty() and not source_definition_id.strip_edges().is_empty()


func to_dictionary() -> Dictionary:
	return {"origin_kind": origin_kind, "source_occurrence_id": source_occurrence_id, "source_definition_id": source_definition_id}


func matches(record: Dictionary) -> bool:
	var other: IncidentSource = from_record(record)
	return is_valid() and other.is_valid() and other.origin_kind == origin_kind and other.source_occurrence_id == source_occurrence_id and other.source_definition_id == source_definition_id


static func from_record(record: Dictionary) -> IncidentSource:
	if typeof(record.get("origin_kind", -1)) != TYPE_INT or typeof(record.get("source_definition_id", "")) != TYPE_STRING or typeof(record.get("source_occurrence_id", "")) != TYPE_STRING or typeof(record.get("source_entry_id", "")) != TYPE_STRING: return IncidentSource.new()
	var kind: int = record.get("origin_kind", -1)
	var occurrence: String = record.get("source_occurrence_id", "")
	if record.has("source_entry_id"):
		var legacy: String = record.get("source_entry_id", "")
		if kind == OriginKind.CAMPAIGN_INTERRUPT or (record.has("source_occurrence_id") and legacy != occurrence): return IncidentSource.new()
		if not record.has("source_occurrence_id"): occurrence = legacy
	return IncidentSource.new(kind, occurrence, record.get("source_definition_id", ""))
