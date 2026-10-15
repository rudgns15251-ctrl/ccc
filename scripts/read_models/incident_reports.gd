class_name IncidentReports
extends RefCounted

static func consequence_text(result: IncidentResultData) -> String:
	var unknown: String = TranslationServer.translate("Unconfirmed / not recorded")
	var deaths: String = str(result.staff_deaths) if result.staff_deaths >= 0 else unknown
	var injuries: String = str(result.staff_injuries) if result.staff_injuries >= 0 else unknown
	return TranslationServer.translate("Confirmed staff deaths: %s\nConfirmed staff injuries: %s\nFacility damage: %s\nAdditional observation: %s") % [deaths,injuries,GameText.translate_value(result.facility_damage) if not result.facility_damage.is_empty() else unknown,GameText.translate_value(result.additional_observation) if not result.additional_observation.is_empty() else unknown]

static func completed(campaign: CampaignData, records: Array[Dictionary]) -> Array[Dictionary]:
	var reports: Array[Dictionary] = []
	for row: Dictionary in records:
		if row.get("status") != IncidentResponseState.Status.COMPLETED: continue
		var scope: Resource
		if row.origin_kind == IncidentSource.OriginKind.CASE:
			var entry: CampaignEntryData = campaign.get_entry(row.source_occurrence_id)
			if entry == null or entry.case_data == null or entry.case_data.case_id != row.source_definition_id: continue
			scope = entry.case_data
		elif row.origin_kind == IncidentSource.OriginKind.CAMPAIGN_ENTRY:
			var entry: CampaignEntryData = campaign.get_entry(row.source_occurrence_id)
			if entry == null: continue
			scope = entry.scripted_incident_data
		elif row.origin_kind == IncidentSource.OriginKind.CAMPAIGN_INTERRUPT:
			var occurrence: ScriptedInterruptOccurrenceData = campaign.get_interrupt(row.source_occurrence_id)
			if occurrence == null: continue
			scope = occurrence.scripted_incident_data
		if scope == null: continue
		if scope is ScriptedIncidentData and scope.event_id != row.source_definition_id: continue
		var incident: IncidentData = DeveloperRunDispositionBuilder.unique_content(scope.incidents,"incident_id",row.incident_id) if scope is CaseData else scope.incident_data
		var broadcast: EmergencyBroadcastData = DeveloperRunDispositionBuilder.unique_content(scope.emergency_broadcasts,"broadcast_id",row.broadcast_id)
		var result: IncidentResultData = DeveloperRunDispositionBuilder.unique_content(scope.incident_results,"result_id",row.incident_result_id)
		if incident == null or broadcast == null or result == null or incident.incident_id != row.incident_id or incident.broadcast_id != broadcast.broadcast_id: continue
		var option: BroadcastOptionData = DeveloperRunDispositionBuilder.unique_content(broadcast.get_response_options(),"option_id",row.confirmed_option_id)
		if option == null or option.result_id != result.result_id or not IncidentResponseState.valid_details(row,broadcast,result): continue
		var source: String = ["CASE","CAMPAIGN_ENTRY","CAMPAIGN_INTERRUPT"][row.origin_kind]
		var body: String = "%s\n%s / %s\n%s\n\n%s\n%s\n\n%s\n%s\n\n%s" % [TranslationServer.translate("Incident source"),source,row.source_occurrence_id,row.source_definition_id,TranslationServer.translate("Transmitted broadcast"),GameText.translate_value(option.display_text),TranslationServer.translate("Observed response result"),GameText.translate_value(result.description),consequence_text(result)]
		reports.append({"title":incident.display_name,"body":body,"response":row.duplicate(true)})
	return reports
