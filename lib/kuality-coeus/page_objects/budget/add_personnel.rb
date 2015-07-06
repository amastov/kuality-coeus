class AddProjectPersonnel < Dialogs

  buttons 'Search', 'Cancel', 'Add Selected Personnel', 'Add TBN Personnel to Budget'

  element(:dialog_header) { |b| b.h4(id: 'PropBudget-ProjectPersonnelPage-Wizard_header') }

  element(:search_for) { |b| b.select(name: 'addProjectPersonnelHelper.lineType') }
  element(:user_name) { |b| b.text_field(name: %|addProjectPersonnelHelper.lookupFieldValues['principalName']|) }
  element(:last_name) { |b| b.text_field(name: %|addProjectPersonnelHelper.lookupFieldValues['lastName']|) }
  element(:first_name) { |b| b.text_field(name: %|addProjectPersonnelHelper.lookupFieldValues['firstName']|) }

  p_action(:check_person) { |name, b| b.tr(text: /#{name}/).checkbox.set }

  element(:results_table) { |b| b.div(data_parent: 'PropBudget-ProjectPersonnelPage-Wizard').table }

  value(:returned_full_names) { |b| b.results_table.rows.map{ |row| row[1].text }.tap(&:shift) }

  p_action(:select_person) { |person, b| b.results_table.row(text: /#{person}/).checkbox.set }

  # To Be Named items...

  value(:person_categories) { |b| b.to_be_named_table.tbody.trs.map { |tr| tr[0].text } }
  p_element(:quantity) { |category, b| b.to_be_named_table.tr(text: /#{category}/).text_field }

  element(:to_be_named_table) { |b| b.table(id: 'u1t17vx1_layout') }

end