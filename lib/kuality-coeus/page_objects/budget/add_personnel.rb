class AddProjectPersonnel < Dialogs

  buttons 'Search', 'Cancel', 'Add Selected Personnel'

  element(:dialog_header) { |b| b.h4(id: 'PropBudget-ProjectPersonnelPage-Wizard_header') }

  element(:search_for) { |b| b.select(name: 'addProjectPersonnelHelper.lineType') }
  element(:user_name) { |b| b.text_field(name: %|addProjectPersonnelHelper.lookupFieldValues['principalName']|) }
  element(:last_name) { |b| b.text_field(name: %|addProjectPersonnelHelper.lookupFieldValues['lastName']|) }
  element(:first_name) { |b| b.text_field(name: %|addProjectPersonnelHelper.lookupFieldValues['firstName']|) }

  p_action(:check_person) { |name, b| b.tr(text: /#{name}/).checkbox.set }

  element(:results_table) { |b| b.div(data_parent: 'PropBudget-ProjectPersonnelPage-Wizard').table }

  value(:returned_full_names) { |b| names=[]; b.results_table.rows.each{ |row| names << row[1].text }; names[1..-1] }

  p_action(:select_person) { |person, b| b.results_table.row(text: /#{person}/).checkbox.set }

end