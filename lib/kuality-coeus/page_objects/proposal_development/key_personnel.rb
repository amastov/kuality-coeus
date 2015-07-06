class KeyPersonnel < BasePage

  document_buttons
  new_error_messages

  buttons 'Add Personnel'

  action(:employee_search) { |b| b.frm.button(name: 'methodToCall.performLookup.(!!org.kuali.kra.bo.KcPerson!!).(((personId:newPersonId))).((``)).((<>)).(([])).((**)).((^^)).((&&)).((//)).((~~)).(::::;;::::).anchor').click }
  action(:non_employee_search) { |b| b.frm.button(name: 'methodToCall.performLookup.(!!org.kuali.kra.bo.NonOrganizationalRolodex!!).(((rolodexId:newRolodexId))).((``)).((<>)).(([])).((**)).((^^)).((&&)).((//)).((~~)).(::::;;::::).anchor').click }
  element(:proposal_role) { |b| b.frm.select(id: 'newProposalPerson.proposalPersonRoleId') }
  element(:key_person_role) { |b| b.frm.text_field(id: 'newProposalPerson.projectRole') }
  action(:add_person) { |b| b.frm.button(name: 'methodToCall.insertProposalPerson').click }
  action(:clear) { |b| b.frm.button(name: 'methodToCall.clearProposalPerson').click }

  value(:person_name) { |b| b.frm.table(class: 'grid')[0][1].text }

  # Use to check if there are errors present or not...
  element(:add_person_errors_div) { |b| b.frm.div(class: 'annotate-container').div(class: 'left-errmsg-tab').div }

  p_element(:section_of) { |name, b| b.section(data_full_name: name) }
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
    begin
      b.section_of(name).table.rows[1..-1].map{ |row| {name: row.td.text, number: row.td(index: 1).text} }
    rescue Watir::Exception::UnknownObjectException
      []
    end
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