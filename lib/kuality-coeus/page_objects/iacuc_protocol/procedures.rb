class IACUCProcedures < KCProtocol
  element(:procedures_tab_div) { |b| b.frm.div(id: 'tab-ProcedureDetails-div') }
  p_action(:select_procedure_tab) { |tab, b| b.procedures_tab_div.button(value: tab).when_present.click; b.loading }

  element(:procedures_table) { |b| b.frm.table(id: 'included-categories-table') }
  p_element(:category) { |name, b| b.procedures_table.tr.checkbox(name: "iacucProtocolProceduresHelper.allProcedures[#{CATEGORIES.index(name)}].procedureSelected") }

  p_element(:select_species_for_category) { |category, b| b.frm.select(name: "document.protocolList[0].iacucProtocolStudyGroupBeans[#{CATEGORIES.index(category)}].protocolSpeciesAndGroups") }

  p_value(:species_list_for_category) { |category, b| b.noko.select(name: "document.protocolList[0].iacucProtocolStudyGroupBeans[#{CATEGORIES.index(category)}].protocolSpeciesAndGroups").options.map { |opts| opts.text } }

  p_action(:add_species_to_category) { |category, b| b.frm.button(name: /^methodToCall.addProtocolStudyGroup.line#{CATEGORIES.index(category)}.anchor/).click; b.loading }

  # FIXME: This stuff shouldn't be hard-coded, but the Page HTML doesn't really give us any choice.
  # When possible, please get the HTML changed to be more helpful. For example, give tags to the checkboxes that correspond to the item.
  # the order of objects in this array correspond to the line index on the page.
  # If there are fails try checking the order of the list
  CATEGORIES = ['Analgesics', 'Anesthesia', 'Paralytics',
                'Survival', 'Multiple Major Survival',
                'Non-survival', 'Medical Device Testing',
                'Food/water restriction (not prior to surgery)',
                'Chemical Method', 'Physical Method',
                'Radioactive isotopes', 'Irradiation', 'Aversive Stimuli',
                'Antibody Production', 'Immunization',
                'Blood sampling', 'Nutritional studies',
                'Physical restraint', 'Chemical restraint']

end

class IACUCProceduresPersonnel < IACUCProcedures
  undefine :personnel
  value(:personnel) { |b| b.noko.table(id: 'procedure-personnel-table').ths(class: 'infoline').map { |th| onespace(th.parent.div(align: 'left').text) } }
  p_action(:edit_procedures) { |person_name, b| b.frm.td(text: b.frm.div(text: "#{person_name}").parent.text).parent.link(id: 'editProcedureLink').click }
end

#assign/edit procedures modal
class IACUCProceduresPersonnelDialogue < IACUCProceduresPersonnel
  undefine :save

  element(:all_procedures) { |b| b.frm.div(class: 'fancybox-wrap fancybox-desktop fancybox-type-inline fancybox-opened').checkbox(class: 'checkBoxSelectAll') }
  element(:all_group) { |b| b.frm.div(class: 'fancybox-wrap fancybox-desktop fancybox-type-inline fancybox-opened').checkbox(class: 'checkBoxAllGroup') }
  p_element(:procedure) { |procedure_name, b| b.frm.div(class: 'fancybox-wrap fancybox-desktop fancybox-type-inline fancybox-opened').td(text: /#{procedure_name}$/).checkbox }
  element(:qualifications) { |b| b.frm.div(class: 'fancybox-inner').textarea(title: 'Qualifications') }
  action(:save) { |b| b.frm.div(class: 'fancybox-wrap fancybox-desktop fancybox-type-inline fancybox-opened').button(id: 'onProcedureEdit').click; b.loading }
end

class IACUCProceduresLocation < IACUCProcedures
  element(:type) { |b| b.frm.select(name: 'iacucProtocolProceduresHelper.newIacucProtocolStudyGroupLocation.locationTypeCode') }
  value(:type_list) { |b| b.noko.select(name: 'iacucProtocolProceduresHelper.newIacucProtocolStudyGroupLocation.locationTypeCode').options.map {|opt| opt.text }.tap(&:shift)  }
  element(:name) { |b| b.frm.select(name: 'iacucProtocolProceduresHelper.newIacucProtocolStudyGroupLocation.locationId') }

  # This returns an array of the location names. Purpose is for when 2 or more unique location names are needed
  # We will create and array of names, then delete the used name before sampling the array for the pick method
  value(:name_array) { |b| b.noko.select(name: 'iacucProtocolProceduresHelper.newIacucProtocolStudyGroupLocation.locationId').options.map {|oh| oh.text } }

  element(:room) { |b| b.frm.text_field(name: 'iacucProtocolProceduresHelper.newIacucProtocolStudyGroupLocation.locationRoom') }
  element(:description) { |b| b.frm.textarea(name: 'iacucProtocolProceduresHelper.newIacucProtocolStudyGroupLocation.studyGroupLocationDescription') }

  action(:add_location) { |b| b.frm.button(name: 'methodToCall.addProcedureLocation.document.protocolList[0].iacucProtocolStudyGroupBeans[].iacucProtocolStudyGroupDetailBeans[].line').click; b.loading }

  # When Location line item is added there is an info line that must be used to identify the edit procedures button
  # because there are no html tags or index numbers for those elements.
  element(:info_line) {|line_number='1',b| b.frm.table(id: 'procedureLocationsTableId').th(class: 'infoline', text: "#{line_number.to_s}") }
  action(:edit_procedures) { |index, b| b.frm.link(id: 'editProcedureLink', index: index).click }

  action(:delete) { |index,b| b.frm.button(name: /^methodToCall.deleteProcedureLocation.line#{index}/).click; b.loading }

  element(:table) { |b| b.frm.table(id: 'procedureLocationsTableId') }

  #Methods for Locations already added
  p_element(:edit_type) { |index, b| b.frm.select(name: "document.protocolList[0].iacucProtocolStudyGroupLocations[#{index}].locationTypeCode") }
  p_element(:edit_name) { |index, b| b.frm.select(name: "document.protocolList[0].iacucProtocolStudyGroupLocations[#{index}].locationId") }
  p_element(:edit_room) { |index, b| b.frm.text_field(name: "document.protocolList[0].iacucProtocolStudyGroupLocations[#{index}].locationRoom") }
  p_element(:edit_description) { |index, b| b.frm.textarea(name: "document.protocolList[0].iacucProtocolStudyGroupLocations[#{index}].studyGroupLocationDescription") }
end

class IACUCProceduresSummary < IACUCProcedures
  undefine :custom_data, :personnel
  value(:custom_data) { |b| b.noko.div(align: 'left', index: 1).text }
  value(:personnel) { |b| b.noko.div(align: 'left', index: 2).text }
  value(:locations) { |b| b.noko.div(align: 'left', index: 3).text }

  p_action(:view_qualification) { |full_name, b| b.frm.div(text: /#{full_name}/).link(id: 'viewQualificationsLink').click}
  # qualification dialog
  value(:qualification_dialog) { |b| b.noko.div(class: 'fancybox-inner').text }
end