class KeyPersonnel < BasePage

  document_buttons
  
  buttons 'Add Personnel'

  new_error_messages

  p_element(:section_of) { |name, b| b.h4(text: /#{name}/).parent.parent }

  # Details

  p_element(:user_name_of) { |name, b| b.section_of(name).text_field(name: /userName/) }
  p_element(:home_unit_of) { |name, b| b.section_of(name).text_field(name: /homeUnit/) }
  p_element(:era_commons_name_of) { |name, b| b.section_of(name).text_field(name: /eraCommonsUserName/) }

  # Unit Details

  # This method makes an Array containing Hashes with :name and :number keys...
  # FIXME: This method will NOT WORK if, by some odd chance, the person has more
  # than 10 units. This is such an unlikely scenario, however, that we are not
  # coding for it.
  p_value(:units_of) { |name, b|
    units= []
    b.section_of(name).table().rows[1..-1].each{ |row| units << {name: row.td.text, number: row.td(index: 1).text} }
    units
  }

  p_value(:lead_unit_of) { |name, b| b.section_of(name).table.row(text: /Lead Unit - Cannot delete/).td(index: 1).text }

  # Person Certification
  [:certify_info_true,
      :potential_for_conflict,
      :submitted_financial_disclosures,
      :lobbying_activities,
      :excluded_from_transactions,
      :familiar_with_pla
  ].each_with_index do |methd, index|
    p_action(methd) { |name, value, b| b.section_of(name).radio(name: /questionnaireHelper.answerHeaders\[\d+\].questions\[#{index}\].answers\[\d+\].answer/, value: value).set }
  end

  # TODO: Genericize and move this method...
  def self.tabs(*tab_text)
    tab_text.each do |text|
      p_action("#{damballa(text)}_of") { |name, b| b.section_of(name).link(text: text).click; b.loading }
    end
  end

  tabs 'Details', 'Organization', 'Extended Details', 'Degrees', 'Unit Details', 'Person Training Details', 'Proposal Person Certification'

end