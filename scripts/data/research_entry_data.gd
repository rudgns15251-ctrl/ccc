class_name ResearchEntryData
extends Resource

enum SourceKind { PROFILE, CCTV, EXPERIMENT, CONTAINMENT, INCIDENT, BROADCAST, BROADCAST_OPTION, INCIDENT_RESULT, DISTURBANCE_REACTION, CCTV_CONDITION_OBSERVATION }

@export var entry_id: String = ""
@export var source_kind: SourceKind = SourceKind.PROFILE
@export var source_id: String = ""
@export var title: String = ""
@export_multiline var body_text: String = ""
