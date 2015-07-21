class AddProjectPersonnel < Dialogs

  buttons 'Search', 'Cancel', 'Add Selected Personnel', 'Add TBN Personnel to Budget'

  element(:dialog_header) { |b| b.h4(id: 'PropBudget-ProjectPersonnelPage-Wizard_header') }

  element(:search_for) { |b| b.select(name: 'addProjectPersonnelHelper.lineType') }
  element(:user_name) { |b| b.text_field(name: %|addProjectPersonnelHelper.lookupFieldValues['principalName']|) }
  element(:last_name) { |b| b.text_field(name: %|addProjectPersonnelHelper.lookupFieldValues['lastName']|) }
  element(:first_name) { |b| b.text_field(name: %|addProjectPersonnelHelper.lookupFieldValues['firstName']|) }

  element(:results_table) { |b| b.div(data_parent: 'PropBudget-ProjectPersonnelPage-Wizard').table }
  element(:noko_results) { |b| b.no_frame_noko.div(data_parent: 'PropBudget-ProjectPersonnelPage-Wizard').table }

  value(:returned_full_names) { |b| b.noko_results.rows.map{ |row| row[1].text }.tap(&:shift) }

  p_action(:select_person) { |person, b| b.checkbox(id: b.noko_results.row(text: /#{person}/).checkbox.id).set }
  alias_method :check_person, :select_person

  # To Be Named items...

  value(:person_categories) { |b| b.noko_tbn_table.tbody.trs.map { |tr| tr[0].text } }
  p_element(:quantity) { |category, b| b.text_field(name: b.noko_tbn_table.tr(text: /#{category}/).text_field.name) }

  element(:to_be_named_table) { |b| b.table(id: 'u1t17vx1_layout') }
  element(:noko_tbn_table) { |b| b.no_frame_noko.table(id: 'u1t17vx1_layout') }

end