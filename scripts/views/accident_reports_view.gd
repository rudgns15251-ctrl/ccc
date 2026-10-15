extends VBoxContainer

static func mount_archive(view: Control, reports: Array[Dictionary], allowed: bool) -> void:
	var workspace: Control = view.get_node("%Workspace")
	var parent: Node = workspace.get_parent()
	var tabs: HBoxContainer = parent.get_node("ArchiveTabs")
	var button := Button.new();button.name = "AccidentTab";button.text = "Accident Reports"
	button.custom_minimum_size.y = 48;button.disabled = not allowed;tabs.add_child(button)
	var panel := VBoxContainer.new();panel.name = "AccidentReports";panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.hide();parent.add_child(panel);parent.move_child(panel,parent.get_child_count()-2)
	var title := Label.new();title.text = "Completed incidents only";title.theme_type_variation = "HeadingLabel";panel.add_child(title)
	var layout := HBoxContainer.new();layout.size_flags_vertical = Control.SIZE_EXPAND_FILL;panel.add_child(layout)
	var list_scroll := ScrollContainer.new();list_scroll.custom_minimum_size.x = 380;list_scroll.follow_focus = true;list_scroll.focus_mode = Control.FOCUS_ALL
	list_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED;layout.add_child(list_scroll)
	var list := VBoxContainer.new();list.name = "AccidentList";list.size_flags_horizontal = Control.SIZE_EXPAND_FILL;list_scroll.add_child(list)
	var scroll := ScrollContainer.new();scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL;scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL;scroll.follow_focus = true;scroll.focus_mode = Control.FOCUS_ALL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED;layout.add_child(scroll)
	var body := Label.new();body.name = "AccidentBody";body.text = "Select a completed incident."
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART;body.size_flags_horizontal = Control.SIZE_EXPAND_FILL;scroll.add_child(body)
	for report: Dictionary in reports:
		var item := Button.new();item.text = report.title;item.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART;item.custom_minimum_size.y = 64
		list.add_child(item)
		item.pressed.connect(func() -> void:
			if view._allows_local_input(): body.text = report.body;scroll.scroll_vertical = 0)
	if reports.is_empty():
		var empty := Label.new();empty.text = "No completed incident reports.";empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART;list.add_child(empty)
	button.pressed.connect(func() -> void:
		if not button.disabled and view._allows_local_input():
			workspace.hide();parent.get_node("StoryRecords").hide();parent.get_node("StoryRecords")._video.stop();panel.show())
	for tab: Button in tabs.get_children():
		if tab != button:
			tab.pressed.connect(func() -> void:
				if view._allows_local_input() and not tab.disabled: panel.hide())
