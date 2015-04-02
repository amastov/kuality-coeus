class SpeciesGroups < KCProtocol

  element(:group) { |b| b.frm.text_field(name: 'iacucProtocolSpeciesHelper.newIacucProtocolSpecies.speciesGroup') }
  element(:species) { |b| b.frm.select(name: 'iacucProtocolSpeciesHelper.newIacucProtocolSpecies.speciesCode') }
  element(:strain) { |b| b.frm.text_field(name: 'iacucProtocolSpeciesHelper.newIacucProtocolSpecies.strain') }
  element(:pain_category) { |b| b.frm.select(name: 'iacucProtocolSpeciesHelper.newIacucProtocolSpecies.painCategoryCode') }
  element(:usda_covered) { |b| b.frm.checkbox(name: 'iacucProtocolSpeciesHelper.newIacucProtocolSpecies.usdaCovered') }
  element(:count_type) { |b| b.frm.select(name: 'iacucProtocolSpeciesHelper.newIacucProtocolSpecies.speciesCountCode') }
  element(:count) { |b| b.frm.text_field(name: 'iacucProtocolSpeciesHelper.newIacucProtocolSpecies.speciesCount') }
  element(:procedure_summary) { |b| b.frm.textarea(name: 'iacucProtocolSpeciesHelper.newIacucProtocolSpecies.procedureSummary') }

  action(:add_species) { |b| b.frm.button(name: 'methodToCall.addProtocolSpecies.anchorSpeciesGroups').click; b.loading}

  #After adding a group
  #first added species index number starts at Zero
  p_element(:group_added) { |index, b| b.frm.text_field(name: "document.protocolList[0].iacucProtocolSpeciesList[#{index}].speciesGroup") }
  p_value(:group_added_value) {|index, b| b.group_added(index).value }

  #These select lists, need special handling for finding the selected option '<select_list>.selected_options.first.text'
  p_element(:species_added) { |index, b| b.frm.select(name: "document.protocolList[0].iacucProtocolSpeciesList[#{index}].speciesCode") }
  p_value(:species_added_value) { |index, b| b.species_added(index).selected_options.first.text }
  # p_value(:species_added_value) { |index, b| b.frm.select(name: "document.protocolList[0].iacucProtocolSpeciesList[#{index}].speciesCode").selected_options.first.text }

  p_element(:strain_added) { |index, b| b.frm.text_field(name: "document.protocolList[0].iacucProtocolSpeciesList[#{index}].strain") }

  p_element(:pain_category_added) { |index, b| b.frm.select(name: "document.protocolList[0].iacucProtocolSpeciesList[#{index}].painCategoryCode") }
  p_value(:pain_category_added_value) { |index, b| b.frm.select(name: "document.protocolList[0].iacucProtocolSpeciesList[#{index}].painCategoryCode").selected_options.first.text }

  p_element(:usda_covered_added) { |index, b| b.frm.checkbox(name: "document.protocolList[0].iacucProtocolSpeciesList[#{index}].usdaCovered") }

  p_element(:count_type_added) { |index, b| b.frm.select(name: "document.protocolList[0].iacucProtocolSpeciesList[#{index}].speciesCountCode") }
  p_value(:count_type_added_value) { |index, b| b.frm.select(name: "document.protocolList[0].iacucProtocolSpeciesList[#{index}].speciesCountCode").selected_options.first.text }

  p_element(:count_added) { |index, b| b.frm.text_field(name: "document.protocolList[0].iacucProtocolSpeciesList[#{index}].speciesCount") }
  p_value(:count_added_value) { |index, b| b.count_added(index).value }

  p_element(:procedure_summary_added) { |index, b| b.frm.textarea(name: "document.protocolList[0].iacucProtocolSpeciesList[#{index}].procedureSummary") }

  #first added species index line item starts at 1
  p_action(:delete) { |index, b| b.frm.button(name: "methodToCall.deleteProtocolSpecies.line#{index}.anchor0.validate0").click }

end
