class_name RunDispositionRecord
extends RefCounted

# Detached values only. Public APIs never expose the stored containers.
# GDScript does not enforce private fields; the recipient takes its own copy.
const MAX_CONTAINER_DEPTH: int = 64

var _data: Dictionary = {}
var _input_issue: String = ""


func _init(value: Variant = {}) -> void:
	if not value is Dictionary:
		_input_issue = "Record envelope must be a Dictionary."
		return
	_input_issue = _primitive_issue(value, [])
	if _input_issue.is_empty():
		# Validation precedes copying: duplicate(true) cannot safely copy cycles.
		_data = _normalized_copy(value)


func to_dictionary() -> Dictionary:
	return _data.duplicate(true)


func get_input_issue() -> String:
	return _input_issue


static func values_equal(left: Variant, right: Variant) -> bool:
	# Both values must already be validated acyclic primitives. Array order matters;
	# Dictionary insertion order does not. Numeric types are compared explicitly.
	if typeof(left) != typeof(right):
		return false
	if left is Dictionary:
		if left.size() != right.size():
			return false
		for key: String in left:
			if not right.has(key) or not values_equal(left[key], right[key]):
				return false
		return true
	if left is Array:
		if left.size() != right.size():
			return false
		for index: int in range(left.size()):
			if not values_equal(left[index], right[index]):
				return false
		return true
	return left == right


static func _primitive_issue(value: Variant, ancestors: Array) -> String:
	match typeof(value):
		TYPE_NIL, TYPE_BOOL, TYPE_INT, TYPE_STRING:
			return ""
		TYPE_FLOAT:
			return "" if is_finite(value) else "Non-finite float is not supported."
		TYPE_ARRAY, TYPE_DICTIONARY:
			if ancestors.size() >= MAX_CONTAINER_DEPTH:
				return "Container nesting exceeds %d." % MAX_CONTAINER_DEPTH
			for ancestor: Variant in ancestors:
				if is_same(ancestor, value):
					return "Cyclic container is not supported."
			ancestors.append(value)
			if value is Dictionary:
				for key: Variant in value:
					# GDScript's dictionary.dot assignment can create StringName keys.
					if not key is String and not key is StringName:
						ancestors.pop_back()
						return "Dictionary keys must be Strings or StringNames."
					var issue: String = _primitive_issue(value[key], ancestors)
					if not issue.is_empty():
						ancestors.pop_back()
						return issue
			else:
				for child: Variant in value:
					var issue: String = _primitive_issue(child, ancestors)
					if not issue.is_empty():
						ancestors.pop_back()
						return issue
			ancestors.pop_back()
			return ""
		_:
			return "Unsupported value type: %s." % type_string(typeof(value))


static func _normalized_copy(value: Variant) -> Variant:
	if value is Dictionary:
		var result: Dictionary = {}
		var keys: Array[String] = []
		for key: Variant in value:
			keys.append(String(key))
		keys.sort()
		for key: String in keys:
			result[key] = _normalized_copy(value[key])
		return result
	if value is Array:
		var result: Array = []
		for child: Variant in value:
			result.append(_normalized_copy(child))
		return result
	return value
