class_name CampaignSaveStore
extends RefCounted

const VERSION: int = 1
const DIRECTORY: String = "user://campaign_saves"
const MAX_BYTES: int = 2097152

static func path_for(campaign_id: String) -> String:
	return DIRECTORY + "/" + campaign_id.sha256_text().substr(0, 24) + ".json"

static func exists(campaign_id: String) -> bool:
	var path: String = path_for(campaign_id)
	return FileAccess.file_exists(path) or FileAccess.file_exists(path + ".bak")

# JSON only: no object deserialization, Resource paths, or executable data.
static func read(campaign_id: String) -> Dictionary:
	var path: String = path_for(campaign_id)
	if not FileAccess.file_exists(path): path += ".bak"
	if not FileAccess.file_exists(path): return {"error": "NO_SAVE"}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null or file.get_length() > MAX_BYTES: return {"error": "READ_FAILED"}
	var text: String = file.get_as_text()
	file.close()
	var parser := JSON.new()
	if parser.parse(text) != OK: return {"error": "INVALID_JSON"}
	var envelope: Variant = _normalize(parser.data)
	if not envelope is Dictionary or envelope.size() != 4 or envelope.get("version") != VERSION or not envelope.get("payload") is Dictionary or not envelope.get("signature") is String or not envelope.get("checksum") is String: return {"error": "INVALID_FORMAT"}
	if JSON.stringify(envelope.payload).sha256_text() != envelope.checksum: return {"error": "CHECKSUM_MISMATCH"}
	return {"error": "", "payload": envelope.payload, "signature": envelope.signature, "backup": path.ends_with(".bak")}

static func write(campaign_id: String, payload: Dictionary, signature: String) -> String:
	if DirAccess.make_dir_recursive_absolute(DIRECTORY) != OK: return "WRITE_FAILED"
	var path: String = path_for(campaign_id)
	var temp: String = path + ".tmp"
	var envelope: Dictionary = {"version": VERSION, "payload": payload, "signature": signature, "checksum": JSON.stringify(payload).sha256_text()}
	var text: String = JSON.stringify(envelope, "\t")
	if text.to_utf8_buffer().size() > MAX_BYTES: return "SAVE_TOO_LARGE"
	var file := FileAccess.open(temp, FileAccess.WRITE)
	if file == null: return "WRITE_FAILED"
	file.store_string(text)
	file.flush()
	var error: Error = file.get_error()
	file.close()
	if error != OK or FileAccess.get_sha256(temp) != text.sha256_text(): return "WRITE_FAILED"
	# Publish only after the new file is complete. A missing primary after a crash
	# can recover the previous whole file; a corrupt primary is explicitly rejected.
	if FileAccess.file_exists(path):
		if FileAccess.file_exists(path + ".bak") and DirAccess.remove_absolute(path + ".bak") != OK: return "WRITE_FAILED"
		if DirAccess.rename_absolute(path, path + ".bak") != OK: return "WRITE_FAILED"
	if DirAccess.rename_absolute(temp, path) != OK:
		if FileAccess.file_exists(path + ".bak"): DirAccess.rename_absolute(path + ".bak", path)
		return "WRITE_FAILED"
	return ""

static func _normalize(value: Variant, depth: int = 0) -> Variant:
	if depth > 20: return null
	if value is float:
		if not is_finite(value) or value != floor(value) or abs(value) > 1000000: return null
		return int(value)
	if value is Array:
		var result: Array = []
		for item: Variant in value: result.append(_normalize(item, depth + 1))
		return result
	if value is Dictionary:
		var result: Dictionary = {}
		for key: String in value: result[key] = _normalize(value[key], depth + 1)
		return result
	return value
