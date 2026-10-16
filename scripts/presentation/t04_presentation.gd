extends "res://scripts/presentation/visual_production.gd"

# Reuse the accepted comparison layout, with honest T04-specific asset labels.
func _note(record: Dictionary, parent: Node, text: String, first: bool = false) -> void:
	match text:
		"TEMP / REPLACEABLE — visual stand-in, not the authored creature or evidence.":
			text = "T04 사용자 제공 Master / 임시·초안·비정사 / 교체 가능. 사진만으로 절대 신장을 검증하지 않음." if game.current_case.case_id == "TEMP_T04_CASE" else "후속 업무용 기존 임시 사례 / 대상 사진 미제공"
		"VISUAL TEST DOCUMENT / existing research rules unchanged":
			text = "임시 연구 문서 / 정식 설정 승인 전"
		"TEMP / REPLACEABLE — static reference; observations determine decisions.":
			text = "CCTV 장면 미제공 / 판단 근거는 실제 관찰문. 전신 Master를 CCTV 증거로 사용하지 않음." if game.current_case.cctv_data.feed_texture == null else "임시 감시 이미지 / 관찰 기록과 함께 검토"
		"Experiment-specific result image not supplied. Text is the execution record.":
			text = "증거 이미지가 없는 실험은 텍스트로 표시 / 결과는 실제 실행 후 공개"
		"TEMP environment reference / shared illustration, not a candidate configuration.":
			text = "격리 후보별 환경 이미지 미제공 / 각 후보의 조도·외부 차음·내부 흡음은 설명으로 비교" if game.environment_reference == null else "공통 공간 참고 이미지 / 후보별 실제 조건은 설명으로 비교"
	super._note(record, parent, text, first)


func decorate_view(view: Control) -> void:
	super.decorate_view(view)
	if enabled and view != null and view.get_script() == CONTAINMENT_SCRIPT:
		for node: Node in view.find_children("*", "TextureRect", true, false):
			if node.texture == null:
				node.visible = false
