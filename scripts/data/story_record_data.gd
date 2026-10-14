class_name StoryRecordData
extends Resource

enum Kind { DIARY, RESIDENT_LIST, TRAINING_VIDEO }
@export var record_id: String = ""
@export var kind: Kind = Kind.DIARY
@export var title: String = ""
@export var content: StoryRecordContent
# Authored offers only. Empty checkpoint means no in-game discovery location yet.
@export var discovery_entry_id: String = ""
@export var discovery_stage: String = ""

func is_readable() -> bool:
	return content != null and (not content.text.strip_edges().is_empty() or content.video != null)
