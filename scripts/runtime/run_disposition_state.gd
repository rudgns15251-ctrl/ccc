class_name RunDispositionState
extends RefCounted

# Independent in-memory recipient. No gameplay lookup, closure or cleanup.
const RECORD = preload("res://scripts/runtime/run_disposition_record.gd")
const CATEGORIES: Array[String] = ["historical_facts", "obligations", "discoveries", "hypotheses"]
const BOUNDARIES: Array[String] = ["VOLUNTARY_RUN_END", "FORCED_RUN_END"]
const OBLIGATION_KINDS: Array[String] = ["UNMANIFESTED_FAILURE_OBLIGATION", "DISTURBED_UNRESPONDED", "READY_BUT_UNRESPONDED_OBLIGATION", "INTERRUPTED_RESPONSE", "INVALID_UNRESOLVED_REFERENCE"]

# Each value contains BOTH the detached record and its receipt. One publication.
var _committed: Dictionary[String, Dictionary] = {}


func try_commit(record: RunDispositionRecord) -> Dictionary:
	if record == null:
		return _result("INVALID", "", {}, "Record is null.")
	if not record.get_input_issue().is_empty():
		return _result("INVALID", "", {}, record.get_input_issue())
	# Treat even a caller-owned Record as untrusted; own an independent safe copy.
	var staged: RunDispositionRecord = RECORD.new(record.to_dictionary())
	if not staged.get_input_issue().is_empty():
		return _result("INVALID", "", {}, staged.get_input_issue())
	var data: Dictionary = staged.to_dictionary()
	var run_id: String = data.get("run_instance_id", "") if data.get("run_instance_id") is String else ""
	var issue: String = _validation_issue(data)
	if not issue.is_empty():
		return _result("INVALID", run_id, {}, issue)
	if _committed.has(run_id):
		var existing: Dictionary = _committed[run_id]
		if RECORD.values_equal(existing.record, data):
			return _result("ALREADY_COMMITTED", run_id, existing.receipt)
		return _result("CONFLICT", run_id, existing.receipt, "Run already has a different terminal record.")
	var receipt: Dictionary = {"run_instance_id": run_id, "receipt_id": "RUN_DISPOSITION_RECEIPT::" + run_id}
	# Commit point: no await, callbacks, signals, or partial category publication.
	_committed[run_id] = {"record": data, "receipt": receipt}
	return _result("COMMITTED", run_id, receipt)


func has_committed_run(run_id: String) -> bool:
	return _committed.has(run_id)


func get_committed_record(run_id: String) -> Dictionary:
	return _committed[run_id].record.duplicate(true) if _committed.has(run_id) else {}


func get_commit_receipt(run_id: String) -> Dictionary:
	return _committed[run_id].receipt.duplicate(true) if _committed.has(run_id) else {}


func get_committed_run_count() -> int:
	return _committed.size()


static func _result(status: String, run_id: String, receipt: Dictionary, issue: String = "") -> Dictionary:
	return {"status": status, "run_instance_id": run_id, "receipt": receipt.duplicate(true), "reference_issue": issue}


static func _is_id(value: Variant) -> bool:
	return value is String and not value.is_empty() and value == value.strip_edges()


static func _validation_issue(data: Dictionary) -> String:
	if data.size() != 6 or not _is_id(data.get("run_instance_id")):
		return "Expected six envelope fields and a nonblank Run ID."
	if not data.get("boundary_type") is String or not BOUNDARIES.has(data.boundary_type):
		return "Unknown final Run boundary."
	var seen: Dictionary = {}
	var definitions: Dictionary = {}
	var submissions: Dictionary = {}
	var resolutions: Dictionary = {}
	for category: String in CATEGORIES:
		if not data.get(category) is Array:
			return "Category must be an Array: " + category
		for value: Variant in data[category]:
			if not value is Dictionary:
				return "Entry must be a Dictionary: " + category
			var entry: Dictionary = value
			var issue: String = _entry_issue(entry, category)
			if not issue.is_empty():
				return issue
			var assignment: String = entry.source_case_instance_id
			if definitions.has(assignment) and definitions[assignment] != entry.source_case_definition_id:
				return "Assignment refers to different Case definitions."
			definitions[assignment] = entry.source_case_definition_id
			var domain: String = entry.identity_domain
			var key_parts: Array = [data.run_instance_id, assignment, domain]
			match domain:
				"EVENT": key_parts.append(entry.incident_id)
				"DISCOVERY": key_parts.append(entry.entry_id)
				"HYPOTHESIS": key_parts.append(entry.hypothesis_id)
			var key: String = JSON.stringify(key_parts)
			if seen.has(key):
				return "Duplicate typed identity: " + key
			seen[key] = true
			if domain == "SUBMISSION": submissions[assignment] = true
			if domain == "RESOLUTION": resolutions[assignment] = true
	for assignment: String in submissions:
		if resolutions.has(assignment):
			return "Assignment is both unresolved submission and resolved."
	return ""


static func _entry_issue(entry: Dictionary, category: String) -> String:
	for field: String in ["identity_domain", "source_case_definition_id", "source_case_instance_id", "entry_kind"]:
		if not _is_id(entry.get(field)):
			return "Missing or invalid entry identity: " + field
	if not entry.get("actual_facts") is Dictionary:
		return "actual_facts must be a primitive Dictionary."
	var domain: String = entry.identity_domain
	var kind: String = entry.entry_kind
	var extra_id: String = ""
	match category:
		"historical_facts":
			if not (domain == "RESOLUTION" and kind == "RESOLUTION_FACT" or domain == "EVENT" and kind == "COMPLETED_RESPONSE_FACT"):
				return "Invalid historical identity/kind."
		"obligations":
			if not (domain == "SUBMISSION" and kind in ["UNRESOLVED_SUBMISSION", "INVALID_UNRESOLVED_REFERENCE"] or domain == "EVENT" and OBLIGATION_KINDS.has(kind)):
				return "Invalid obligation identity/kind."
		"discoveries":
			if domain != "DISCOVERY" or kind != "RESEARCH_DISCOVERY":
				return "Invalid discovery identity/kind."
		"hypotheses":
			if domain != "HYPOTHESIS" or kind != "WORKING_HYPOTHESIS":
				return "Invalid hypothesis identity/kind."
	match domain:
		"EVENT": extra_id = "incident_id"
		"DISCOVERY": extra_id = "entry_id"
		"HYPOTHESIS": extra_id = "hypothesis_id"
	if not extra_id.is_empty() and not _is_id(entry.get(extra_id)):
		return "Missing identity field: " + extra_id
	var fields: Array[String] = ["identity_domain", "source_case_definition_id", "source_case_instance_id", "entry_kind", "actual_facts", "phase"]
	if not extra_id.is_empty(): fields.append(extra_id)
	if domain == "EVENT": fields.append("created_order")
	for field: String in entry:
		if not fields.has(field):
			return "Unexpected entry field: " + field
	if entry.has("phase") and not _is_id(entry.phase):
		return "phase must be a nonblank String."
	if entry.has("created_order") and (not entry.created_order is int or entry.created_order < 0):
		return "created_order must be a nonnegative relative integer."
	return ""
