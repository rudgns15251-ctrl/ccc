extends "res://scripts/presentation/facility_control.gd"

const PROFILE_SCRIPT = preload("res://scripts/views/profile_view.gd")
const EXPERIMENT_SCRIPT = preload("res://scripts/views/experiment_view.gd")
const CONTAINMENT_SCRIPT = preload("res://scripts/views/containment_view.gd")
var _bound_views: Dictionary = {}
var _last_view: int = 0
var _last_executions: int = 0
var _last_runtime: int = 0
var _last_notice: int = 0

func configure(main: Control, initial: bool) -> void:
	super.configure(main, initial)
	menu.get_popup().set_item_text(4, "조작·실험·경고·송출 효과음 (기본 꺼짐)")

func decorate_view(view: Control) -> void:
	super.decorate_view(view)
	if not enabled or view == null or views.has(view.get_instance_id()) and view.get_script() not in [CCTV_SCRIPT, BROADCAST_SCRIPT]: return
	var script: Script = view.get_script()
	if script in [CCTV_SCRIPT, BROADCAST_SCRIPT]:
		if script == CCTV_SCRIPT:
			var record: Dictionary=views[view.get_instance_id()]
			if not record.has("asset_notice"):
				record.asset_notice=true
				_note(record, record.layout, "TEMP / REPLACEABLE — static reference; observations determine decisions.")
		return
	if script not in [PROFILE_SCRIPT,EXPERIMENT_SCRIPT,CONTAINMENT_SCRIPT]: return
	# Authored layout uses the same controls and authoritative callbacks.
	var layout: Control = preload("res://scenes/ui/facility_control/production_workbench.tscn").instantiate()
	view.add_child(layout)
	var record: Dictionary = _record(layout)
	record.view = weakref(view)
	for node: Node in view.find_children("*", "Control", true, false):
		if not layout.is_ancestor_of(node):
			node.set_meta("work_focus_path", String(view.get_path_to(node)))
			record.tags.append(node)
	views[view.get_instance_id()]=record
	if script == PROFILE_SCRIPT:
		# Keep the paper document and identity tree intact, with a taller portrait.
		layout.visible=false
		_change(record, view.get_node("%IdentityScroll"), "size_flags_vertical", Control.SIZE_FILL)
		_change(record, view.get_node("%IdentityScroll"), "custom_minimum_size", Vector2(0,100))
		# Name/classification remain on the paper document; remove the duplicate
		# identity block so the full-body portrait has useful vertical space.
		_change(record, view.get_node("%IdentityScroll"), "visible", false)
		_change(record, view.get_node("%SubjectImage"), "theme_type_variation", "MonitorBezel")
		_note(record, view.get_node("%Identity"), "TEMP / REPLACEABLE — visual stand-in, not the authored creature or evidence.")
		_note(record, view.get_node("%DocumentBody"), "VISUAL TEST DOCUMENT / existing research rules unchanged",true)
	else:
		_change(record, view.get_node("%Margin"), "visible", false)
		_put(record,view.get_node("%ScreenTitle"),layout.get_node("Header"))
		_put(record,view.get_node("%Actions"),layout.get_node("Controls/Actions"))
		_put(record,view.get_node("%EnvironmentConditions"),layout.get_node("Environment"))
		_put(record,view.get_node("%RecheckCCTVButton"),layout.get_node("Review"))
		if script==EXPERIMENT_SCRIPT:
			_put(record,view.get_node("%RemainingCount"),layout.get_node("Header"))
			_put(record,view.get_node("%Catalog"),layout.get_node("Body/Left/Stack"),true)
			_put(record,view.get_node("%Execution"),layout.get_node("Body/Right/Stack"),true)
			_note(record,view.get_node("%ResultBody"),"Experiment-specific result image not supplied. Text is the execution record.")
			_change(record,view.get_node("%RunButton"),"theme_type_variation","TransmitButton")
		else:
			for name: String in ["Description","CandidateHeading","ComparisonHint","RoomScroll"]:
				_put(record,view.get_node("%"+name),layout.get_node("Body/Left/Stack"),name=="RoomScroll")
			var image:=TextureRect.new()
			image.texture=game.environment_reference
			image.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
			image.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			image.custom_minimum_size=Vector2(0,280)
			image.mouse_filter=Control.MOUSE_FILTER_IGNORE
			layout.get_node("Body/Right/Stack").add_child(image)
			_note(record,layout.get_node("Body/Right/Stack"),"TEMP environment reference / shared illustration, not a candidate configuration.")
			for name: String in ["SelectionStatus","RoomDetailScroll"]:
				_put(record,view.get_node("%"+name),layout.get_node("Body/Right/Stack"),name=="RoomDetailScroll")
	_bind_buttons(view)

func _note(record: Dictionary, parent: Node, text: String, first: bool=false) -> void:
	var label:=Label.new()
	label.name="TemporaryAssetNotice"
	label.text=GameText.translate_value(text)
	label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	label.theme_type_variation="InstrumentLabel"
	if parent.name=="DocumentBody":label.theme_type_variation="PaperMetadataLabel"
	parent.add_child(label)
	if first:parent.move_child(label,0)
	# Parent may be an original Control. Clean up only this added label on undo.
	if not record.has("extra_nodes"):record.extra_nodes=[]
	record.extra_nodes.append(label)

func _undo(record: Dictionary) -> void:
	# Moving several ancestor/descendant Controls back in one operation can
	# temporarily invalidate PackedScene ownership. Restore it after all routes.
	var owners: Array[Dictionary]=[]
	for route: Dictionary in record.routes:
		if not is_instance_valid(route.node):continue
		var branch: Array[Node]=[route.node]
		branch.append_array(route.node.find_children("*","",true,false))
		for node: Node in branch:
			if node.owner!=null:
				owners.append({"node":node,"owner":node.owner})
				node.owner=null
	for node: Variant in record.get("extra_nodes",[]):
		if is_instance_valid(node):node.get_parent().remove_child(node);node.queue_free()
	super._undo(record)
	for saved: Dictionary in owners:
		if is_instance_valid(saved.node) and is_instance_valid(saved.owner) and saved.owner.is_ancestor_of(saved.node):saved.node.owner=saved.owner

func _bind_buttons(view: Control) -> void:
	if _bound_views.has(view.get_instance_id()): return
	_bound_views[view.get_instance_id()]=weakref(view)
	for button: Node in view.find_children("*","BaseButton",true,false):
		button.pressed.connect(func() -> void:
			if media.sound_enabled and enabled and not button.disabled:media.audition(2))

func _process(delta: float) -> void:
	super._process(delta)
	if game==null:return
	var view: Control=game.get("_current_view")
	if view!=null and view.get_instance_id()!=_last_view:
		_last_view=view.get_instance_id()
		if enabled:
			_bind_buttons(view)
			if media.sound_enabled and view.get_script()==CCTV_SCRIPT:media.audition(1)
	var count: int=game.case_runtime.get_experiment_execution_history().size() if game.case_runtime!=null else 0
	var runtime_id: int=game.case_runtime.get_instance_id() if game.case_runtime!=null else 0
	if runtime_id!=_last_runtime:
		# Restored history and a new Case are not new experiment executions.
		_last_runtime=runtime_id
		_last_executions=count
	if count!=_last_executions:
		if media.sound_enabled and enabled and count>_last_executions:media.audition(0)
		_last_executions=count
	var notice: Node=game.get("_disturbance_notice")
	var notice_id: int=notice.get_instance_id() if is_instance_valid(notice) else 0
	if notice_id!=_last_notice:
		_last_notice=notice_id
		if notice_id!=0 and enabled and media.sound_enabled:media.audition(0)
