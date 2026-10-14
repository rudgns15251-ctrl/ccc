extends VBoxContainer

var _catalog: Array[StoryRecordData] = []
var _collection: StoryCollectionState
var _guard: Callable
var _body: Label
var _title: Label
var _video: VideoStreamPlayer
var _play: Button

static func mount_archive(view: Control, catalog: Array[StoryRecordData], collection: StoryCollectionState, allowed: bool) -> void:
	var workspace: Control = view.get_node("%Workspace")
	var parent: Node = workspace.get_parent()
	var tabs := HBoxContainer.new()
	tabs.name = "ArchiveTabs"
	var research := Button.new()
	research.name = "ResearchTab"
	research.text = "Case Research"
	research.custom_minimum_size = Vector2(180, 48)
	var story := Button.new()
	story.name = "StoryTab"
	story.text = "Campaign Records"
	story.custom_minimum_size = Vector2(200, 48)
	story.disabled = not allowed
	tabs.add_child(research);tabs.add_child(story)
	parent.add_child(tabs);parent.move_child(tabs, 1)
	var panel := preload("res://scripts/views/story_records_view.gd").new()
	panel.name = "StoryRecords"
	panel._catalog = catalog
	panel._collection = collection
	panel._guard = Callable(view, "_allows_local_input")
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.visible = false
	parent.add_child(panel);parent.move_child(panel, parent.get_child_count()-2)
	story.pressed.connect(func() -> void:
		if not story.disabled and panel._guard.call():
			workspace.hide();panel.show())
	research.pressed.connect(func() -> void:
		if panel._guard.call():
			panel._video.stop();panel.hide();workspace.show())

func _ready() -> void:
	var heading := Label.new()
	heading.text = "Campaign Records / discovered materials only"
	heading.theme_type_variation = "HeadingLabel"
	add_child(heading)
	var layout := HBoxContainer.new()
	layout.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_theme_constant_override("separation", 24)
	add_child(layout)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size.x = 360
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	layout.add_child(scroll)
	var list := VBoxContainer.new()
	list.name = "RecordList"
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	for item: StoryRecordData in _catalog:
		if not _collection.can_read(item.record_id): continue
		var button := Button.new()
		button.name = item.record_id
		GameText.set_text(button, "%s / %s", [["Diary", "Resident List", "Training Video"][item.kind], item.title])
		button.custom_minimum_size.y = 56
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.pressed.connect(func() -> void:
			if _guard.call(): _read(item))
		list.add_child(button)
	if list.get_child_count() == 0:
		var empty := Label.new()
		empty.text = "No story materials discovered."
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		list.add_child(empty)
	var detail := VBoxContainer.new()
	detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.add_child(detail)
	_title = Label.new();_title.name = "RecordTitle"
	_title.text = "Select a discovered material."
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_title.theme_type_variation = "HeadingLabel"
	detail.add_child(_title)
	_video = VideoStreamPlayer.new();_video.name = "RecordVideo"
	_video.expand = true
	_video.custom_minimum_size = Vector2(0, 300)
	_video.hide();detail.add_child(_video)
	_play = Button.new();_play.text = "Play / Pause Video"
	_play.custom_minimum_size.y = 48
	_play.hide();detail.add_child(_play)
	_play.pressed.connect(func() -> void:
		if _guard.call() and _video.stream != null:
			if _video.is_playing(): _video.paused = not _video.paused
			else: _video.paused = false;_video.play())
	var body_scroll := ScrollContainer.new()
	body_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	detail.add_child(body_scroll)
	_body = Label.new();_body.name = "RecordBody"
	_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_scroll.add_child(_body)

func _read(item: StoryRecordData) -> void:
	if not _collection.can_read(item.record_id): return
	_title.text = item.title
	GameText.set_text(_body, "%s", [item.content.text])
	_video.stop();_video.stream = item.content.video
	_video.visible = item.kind == StoryRecordData.Kind.TRAINING_VIDEO and item.content.video != null
	_play.visible = _video.visible
	if item.kind == StoryRecordData.Kind.TRAINING_VIDEO and item.content.video == null:
		GameText.set_text(_body, "%s\n\n%s", ["Video media is not supplied. Verification transcript only.", item.content.text])
