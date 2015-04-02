class IACUCProcedures < KCProtocol
  element(:procedures_tab_div) { |b| b.frm.div(id: 'tab-ProcedureDetails-div') }
  p_action(:select_procedure_tab) { |tab, b| b.procedures_tab_div.button(value: tab).when_present.click; b.loading }

  element(:procedures_table) { |b| b.frm.table(id: 'included-categories-table') }
  p_element(:category) { |index, b| b.procedures_table.tr.checkbox(name: "iacucProtocolProceduresHelper.allProcedures[#{index}].procedureSelected") }

  p_element(:select_species) { |index, b| b.frm.select(name: "document.protocolList[0].iacucProtocolStudyGroupBeans[#{index}].protocolSpeciesAndGroups") }
  p_action(:add_species) { |index, b| b.frm.button(name: /^methodToCall.addProtocolStudyGroup.line#{index}.anchor/).click; b.loading }
end

class IACUCProceduresPersonnel < IACUCProcedures
  # p_value(:find_personnel_line_number) { |person_name, b| b.frm.div(text: "#{person_name}").parent.text }
  p_action(:edit_procedures) { |person_name, b| b.frm.td(text: b.frm.div(text: "#{person_name}").parent.text).parent.link(id: 'editProcedureLink').click }
end

class IACUCProceduresPersonnelDialogue < IACUCProceduresPersonnel
  #assign/edit procedures modal
  undefine :save

  element(:all_procedures) { |b| b.frm.div(class: 'fancybox-wrap fancybox-desktop fancybox-type-inline fancybox-opened').checkbox(class: 'checkBoxSelectAll') }
  element(:all_group) { |b| b.frm.div(class: 'fancybox-wrap fancybox-desktop fancybox-type-inline fancybox-opened').checkbox(class: 'checkBoxAllGroup') }
  p_action(:procedure) { |procedure_name, b| b.frm.div(class: 'fancybox-wrap fancybox-desktop fancybox-type-inline fancybox-opened').td(text: /#{procedure_name}$/).checkbox.set }
  element(:qualifications) { |b| b.frm.div(class: 'fancybox-inner').textarea(title: 'Qualifications') }
  action(:save) { |b| b.frm.div(class: 'fancybox-wrap fancybox-desktop fancybox-type-inline fancybox-opened').button(id: 'onProcedureEdit').click; b.loading }
end

class IACUCProceduresLocation < IACUCProcedures
  element(:location_type) { |b| b.frm.select(name: 'iacucProtocolProceduresHelper.newIacucProtocolStudyGroupLocation.locationTypeCode') }
  element(:location_name) { |b| b.frm.select(name: 'iacucProtocolProceduresHelper.newIacucProtocolStudyGroupLocation.locationId') }

  # This returns an array of the location names. Purpose is for when 2 or more unique location names are needed
  # We will create and array of names, then delete the used name before sampling the array for the pick method
  value(:location_name_array) { |arr, b| b.frm.select(name: 'iacucProtocolProceduresHelper.newIacucProtocolStudyGroupLocation.locationId').options.each {|oh| arr << oh.text } }

  element(:location_room) { |b| b.frm.text_field(name: 'iacucProtocolProceduresHelper.newIacucProtocolStudyGroupLocation.locationRoom') }
  element(:location_description) { |b| b.frm.textarea(name: 'iacucProtocolProceduresHelper.newIacucProtocolStudyGroupLocation.studyGroupLocationDescription') }

  p_action(:add_location) { |index_list=0, b| b.frm.button(name: "methodToCall.addProcedureLocation.document.protocolList[#{index_list}].iacucProtocolStudyGroupBeans[].iacucProtocolStudyGroupDetailBeans[].line").click; b.loading }

  # When Location line item is added there is an info line that must be used to identify the edit procedures button
  # because there are no html tags or index numbers for those elements.
  element(:info_line) {|line_number='1',b| b.frm.table(id: 'procedureLocationsTableId').th(class: 'infoline', text: "#{line_number.to_s}") }
  value(:info_line_number) { |room_num, b| b.frm.text_field(title: 'Room', value: "#{room_num}").parent.parent.parent.th.text }
  action(:location_edit_procedures) { |info_line_number, b| b.frm.th(text: "#{info_line_number}").parent.link(id: 'editProcedureLink').click }

  # action(:location_delete_old_way) { |info_line_number, b| b.frm.th(text: "#{info_line_number}").parent.button(name: /^methodToCall.deleteProcedureLocation.line/).click; b.loading }
  action(:location_delete) { |index,b| b.frm.button(name: /^methodToCall.deleteProcedureLocation.line#{index}/).click; b.loading }

  element(:location_table) { |b| b.frm.table(id: 'procedureLocationsTableId') }

  #Location Added
  p_element(:location_type_added) { |index, b| b.frm.select(name: "document.protocolList[0].iacucProtocolStudyGroupLocations[#{index}].locationTypeCode") }
  p_element(:location_name_added) { |index, b| b.frm.select(name: "document.protocolList[0].iacucProtocolStudyGroupLocations[#{index}].locationId") }
  p_element(:location_room_added) { |index, b| b.frm.text_field(name: "document.protocolList[0].iacucProtocolStudyGroupLocations[#{index}].locationRoom") }
  p_element(:location_description_added) { |index, b| b.frm.textarea(name: "document.protocolList[0].iacucProtocolStudyGroupLocations[#{index}].studyGroupLocationDescription") }
end

class IACUCProceduresSummary < IACUCProcedures
  value(:summary_custom_data) { |b| b.frm.div(align: 'left', index: 1).text }
  value(:summary_personnel) { |b| b.frm.div(align: 'left', index: 2).text }
  value(:summary_locations) { |b| b.frm.div(align: 'left', index: 3).text }

  p_action(:view_qualification) { |full_name, b| b.frm.div(text: /#{full_name}/).link(id: 'viewQualificationsLink').click}
  # qualification dialog
  value(:qualification_dialog) { |b| b.frm.div(class: 'fancybox-inner').text }
end