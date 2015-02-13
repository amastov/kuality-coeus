class KeyPersonnel < BasePage

  document_buttons

  buttons 'Add Personnel'

  new_error_messages

  p_element(:section_of) { |name, b| b.section(data_full_name: name) }

  # Details

  p_value(:user_name_of) { |name, b| b.section_of(name).div(data_label: 'User Name').text }
  p_element(:era_commons_name_of) { |name, b| b.section_of(name).text_field(name: /eraCommonsUserName/) }
  p_value(:role_of) { |name, b| b.section_of(name).div(data_label: 'Proposal Person Role Id').text }
  p_element(:key_person_role_of) { |name, b| b.section_of(name).text_field(name: /projectRole/) }

  action(:expand_all_personnel) { |b| b.spans(class: 'icon-caret-right').each{|xpand| xpand.click unless xpand.style=='display: none;'; b.loading} }

  # Organization

  p_value(:home_unit_of) { |name, b| b.section_of(name).div(data_label: 'Home Unit').text }

  # Unit Details

  # This method makes an Array containing Hashes with :name and :number keys...
  # FIXME: This method will NOT WORK if, by some odd chance, the person has more
  # than 10 units. This is such an unlikely scenario, however, that we are not
  # coding for it.
  p_value(:units_of) { |name, b|
    units= []
    begin
      b.section_of(name).table.rows[1..-1].each{ |row| units << {name: row.td.text, number: row.td(index: 1).text} }
    rescue Watir::Exception::UnknownObjectException
      # do nothing
    end
    units
  }

  p_value(:lead_unit_of) { |name, b| b.section_of(name).table.row(text: /Lead Unit - Cannot delete/).td(index: 1).text }

  # Person Certification
  Personnel::CERTIFICATION_QUESTIONS.each_with_index do |methd, index|
    p_action(methd) { |name, value, b| b.section_of(name).radio(name: /questionnaireHelper.answerHeaders\[\d+\].questions\[#{index}\].answers\[\d+\].answer/, value: value).set }
  end

  # TODO: Genericize and move this method...
  def self.tabs(*tab_text)
    tab_text.each do |text|
      p_action("#{damballa(text)}_of") { |name, b| b.section_of(name).link(text: text).click; b.loading }
    end
  end

  action(:last_page) { |b|
    if b.last_link.present?
      b.last_link.click
      #FIXME!
      sleep 4
    end
  }
  element(:last_link) { |b| b.link(text: 'Last') }

  tabs 'Details', 'Organization', 'Extended Details', 'Degrees', 'Unit Details', 'Person Training Details', 'Proposal Person Certification'

end