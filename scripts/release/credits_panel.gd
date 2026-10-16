extends PanelContainer

# In-game credits and license notices for everything bundled in the release preview.
# Keep in sync with assets/fonts/release/CREDITS.md, assets/ui/release/README.md and
# assets/third_party/m4_5/CREDITS.md.
signal closed

const SECTIONS := [
	["CAP", "TEMP BUILD · T04 임시 사례 프리뷰. 정식 설정이 아닌 개발 중 빌드입니다."],
	["글꼴", "IBM Plex Sans KR, IBM Plex Mono — © 2017 IBM Corp. (Reserved Font Name \"Plex\"), SIL Open Font License 1.1\n나눔고딕코딩 — © 2010 NHN Corporation (Reserved Font Name \"Nanum\"), SIL Open Font License 1.1"],
	["아이콘", "Tabler Icons — © Paweł Kuna, MIT License"],
	["효과음", "\"87 Clickety Clips\" — OwlishMedia, CC0 1.0\n\"Analog Horror SFX Free\" — heyheythere, CC BY 4.0"],
	["UI 자료", "\"VHS UI Free\" — heyheythere, CC BY 4.0\n\"MAUSE OS Minimalist UI Theme\" — Bokx's Game Asset Store, 코드 MIT / 자료 CC BY 4.0"],
	["임시 이미지", "프로젝트 제공 참고 이미지(T04 Master, 표준 격리실)와 이를 합성한 임시 화면. 정식 자료로 교체 예정."],
	["엔진", "Godot Engine — MIT License. © 2014-present Godot Engine contributors, © 2007-2014 Juan Linietsky, Ariel Manzur."],
]


func _ready() -> void:
	var list: VBoxContainer = %Entries
	for section: Array in SECTIONS:
		var heading := Label.new()
		heading.text = section[0]
		heading.theme_type_variation = "HeadingLabel"
		list.add_child(heading)
		var body := Label.new()
		body.text = section[1]
		body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		list.add_child(body)
	var engine := Label.new()
	engine.text = "Godot Engine 라이선스 전문\n\n" + Engine.get_license_text()
	engine.theme_type_variation = "MutedLabel"
	engine.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	list.add_child(engine)
	%CloseButton.pressed.connect(_close)


func open() -> void:
	visible = true
	%Scroll.scroll_vertical = 0
	%CloseButton.grab_focus()


func _close() -> void:
	visible = false
	closed.emit()


func _unhandled_key_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel") and not event.is_echo():
		get_viewport().set_input_as_handled()
		_close()
