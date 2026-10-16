extends "res://scripts/presentation/visual_production.gd"

# Release "Instrument Steel" theme preview (docs/ui_release/art_direction_v1.md); built by tools/build_release_theme.gd.
const RELEASE_THEME: Theme = preload("res://resources/ui/release_instrument_steel_theme.tres")
const ARCHIVE_LIST_SCRIPT = preload("res://scripts/views/research_archive_list_view.gd")
const ARCHIVE_DETAIL_SCRIPT = preload("res://scripts/views/research_archive_detail_view.gd")
# Chrome-only prefix such as "[임시·초안·비정사] " — the TEMP BUILD badge carries that status instead.
var _temp_prefix := RegEx.create_from_string("^\\[(?:임시|TEMP)[^\\]]*\\]\\s*")
var _badge: Button
var _notices: PackedStringArray = []

func _make_theme() -> Theme:
	return RELEASE_THEME.duplicate(true)


func _build_shell() -> void:
	super._build_shell()
	_badge = Button.new()
	_badge.name = "TempBuildBadge"
	_badge.text = "TEMP BUILD"
	_badge.theme_type_variation = "TempBadgeButton"
	_badge.focus_mode = Control.FOCUS_NONE
	_badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var slot: Node = shell.layout.get_node("Console/Identification/Row/ComparisonSlot")
	slot.add_child(_badge)
	slot.move_child(_badge, 0)
	_update_badge()


# Notices are honest about temporary content; in the release preview they are listed
# once in the badge tooltip instead of being repeated on every screen.
func _note(_record: Dictionary, _parent: Node, text: String, _first: bool = false) -> void:
	match text:
		"TEMP / REPLACEABLE — visual stand-in, not the authored creature or evidence.":
			text = "T04 사용자 제공 Master / 임시·초안·비정사 / 교체 가능. 사진만으로 절대 신장을 검증하지 않음." if game.current_case.case_id == "TEMP_T04_CASE" else "후속 업무용 기존 임시 사례 / 대상 사진 미제공"
		"VISUAL TEST DOCUMENT / existing research rules unchanged":
			text = "임시 연구 문서 / 정식 설정 승인 전"
		"TEMP / REPLACEABLE — static reference; observations determine decisions.":
			if game.current_case.cctv_data.feed_texture == null:
				text = "CCTV 장면 미제공 / 판단 근거는 실제 관찰문. 전신 Master를 CCTV 증거로 사용하지 않음."
			elif game.current_case.case_id == "TEMP_T04_CASE":
				text = "TEMP 합성 장면(Master + 표준 격리실) / 실제 감시 영상 아님 · 판단 근거는 관찰문"
			else:
				text = "임시 감시 이미지 / 관찰 기록과 함께 검토"
		"Experiment-specific result image not supplied. Text is the execution record.":
			text = "실행한 실험에만 TEMP 합성 프레임 표시 / 실제 실험 사진 아님 · 결과 판단은 실행 기록" if game.current_case.case_id == "TEMP_T04_CASE" else "증거 이미지가 없는 실험은 텍스트로 표시 / 결과는 실제 실행 후 공개"
		"TEMP environment reference / shared illustration, not a candidate configuration.":
			text = "격리 후보별 환경 이미지 미제공 / 각 후보의 조도·외부 차음·내부 잔향은 설명으로 비교" if game.environment_reference == null else "공통 공간 참고 이미지 / 후보별 실제 조건은 설명으로 비교"
	if not _notices.has(text):
		_notices.append(text)
		_update_badge()


func _update_badge() -> void:
	if not is_instance_valid(_badge): return
	var lines := PackedStringArray(["임시·초안·비정사 빌드 — 정식 설정 아님", "콘텐츠의 [임시] 표기와 아래 항목은 교체 예정입니다."])
	for notice: String in _notices: lines.append("· " + notice)
	_badge.tooltip_text = "\n".join(lines)


func decorate_view(view: Control) -> void:
	var fresh: bool = view != null and not views.has(view.get_instance_id())
	super.decorate_view(view)
	if not enabled or view == null: return
	if view.get_script() == CONTAINMENT_SCRIPT:
		for node: Node in view.find_children("*", "TextureRect", true, false):
			if node.texture == null:
				node.visible = false
	if fresh and view.get_script() == PROFILE_SCRIPT and views.has(view.get_instance_id()):
		_change(views[view.get_instance_id()], view.get_node("%DocumentScroll").get_v_scroll_bar(), "theme_type_variation", &"PaperVScrollBar")
	if fresh and view.get_script() == RESULT_SCRIPT:
		_build_paper_report(view)


# The incident report reads as a filed paper document (art direction: paper = basis of judgement).
# Reversible like the other layouts: the paper panel is the record's layout and is removed on undo.
func _build_paper_report(view: Control) -> void:
	var report: Control = view.get_node("Margin/Content/Workspace/Report")
	var paper := PanelContainer.new()
	paper.name = "PaperReport"
	paper.theme_type_variation = "PaperDocumentPanel"
	paper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	paper.size_flags_vertical = Control.SIZE_EXPAND_FILL
	paper.size_flags_stretch_ratio = report.size_flags_stretch_ratio
	var workspace: Node = report.get_parent()
	workspace.add_child(paper)
	workspace.move_child(paper, report.get_index())
	var record: Dictionary = _record(paper)
	record.view = weakref(view)
	views[view.get_instance_id()] = record
	_put(record, report, paper, true)
	var styles := {"ResultId": "PaperMetadataLabel", "DisplayName": "PaperHeadingLabel", "SelectedOrders": "PaperMetadataLabel", "Description": "PaperBodyLabel", "ReportDetails": "PaperBodyLabel"}
	for name: String in styles:
		_change(record, report.get_node("%" + name), "theme_type_variation", StringName(styles[name]))
	_change(record, report.get_node("%ReportScroll").get_v_scroll_bar(), "theme_type_variation", &"PaperVScrollBar")


func _process(delta: float) -> void:
	super._process(delta)
	if game == null or not enabled: return
	for name: String in ["Subject", "Environment"]:
		_strip(game.get_node("%" + name))
	var view: Control = game.get("_current_view")
	if view != null and view.get_script() == RESULT_SCRIPT:
		_strip(view.get_node("%DisplayName"))
		_strip(view.get_node("%ResponseContext"), true)
	if view != null and view.get_script() in [ARCHIVE_LIST_SCRIPT, ARCHIVE_DETAIL_SCRIPT]:
		for node: Node in view.find_children("*", "Label", true, false): _strip(node)
		var cases: Node = view.get_node_or_null("%CaseList")
		if cases == null: return
		for button: Node in cases.find_children("*", "Button", true, false):
			_strip(button)
			# The selected case is a disabled button; show it lit like the current work key.
			if not button.has_meta("release_base_variation"): button.set_meta("release_base_variation", button.theme_type_variation)
			var lit: StringName = &"CurrentNavButton" if button.disabled else button.get_meta("release_base_variation")
			if button.theme_type_variation != lit: button.theme_type_variation = lit


func _strip(control: Control, every_line: bool = false) -> void:
	var text: String = control.get("text")
	if text.is_empty(): return
	var stripped: String = _temp_prefix.sub(text, "")
	if every_line:
		var lines: PackedStringArray = text.split("\n")
		for index: int in lines.size(): lines[index] = _temp_prefix.sub(lines[index], "")
		stripped = "\n".join(lines)
	if stripped != text: control.set("text", stripped)
