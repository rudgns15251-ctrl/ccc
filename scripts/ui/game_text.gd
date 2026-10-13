class_name GameText
extends RefCounted

# Presentation bindings only. Arguments retain their original text/IDs so a
# locale change can redraw formatted text without replaying gameplay actions.
const BINDING_META := "game_text_binding"

static func set_text(control: Control, source: String, arguments: Array = [], property: String = "text") -> void:
	control.set_meta(BINDING_META, {"source": source, "arguments": arguments.duplicate(), "property": property})
	_refresh(control)


static func refresh_tree(node: Node) -> void:
	if node is Control and node.has_meta(BINDING_META):
		_refresh(node)
	for child: Node in node.get_children():
		refresh_tree(child)


static func _refresh(control: Control) -> void:
	var binding: Dictionary = control.get_meta(BINDING_META)
	var translated: String = translate_value(binding.source)
	var values: Array = []
	for value: Variant in binding.arguments:
		values.append(translate_value(value) if value is String else value)
	if not values.is_empty():
		translated = translated % values
	control.set(binding.property, translated)


static func translate_value(source: String) -> String:
	var translated: String = TranslationServer.translate(source)
	if translated != source:
		return translated
	# Dialogs and facility summaries join existing independently authored fields.
	for separator: String in ["\n", " / "]:
		if source.contains(separator):
			var parts := PackedStringArray()
			for part: String in source.split(separator):
				parts.append(translate_value(part))
			return separator.join(parts)
	return source
