class AddPersonnel < BasePage

  element(:employee) { |b| b.radio(name: 'addKeyPersonHelper.lineType', value: 'E') }
  element(:non_employee) { |b| b.radio(name: 'addKeyPersonHelper.lineType', value: 'N') }

  element(:last_name) { |b| b.text_field(name: "addKeyPersonHelper.lookupFieldValues['lastName']") }

  element(:results_table) { |b| b.div(data_parent: 'PropDev-PersonnelPage-Wizard').table }

  value(:returned_full_names) { |b| names=[]; b.results_table.rows.each{ |row| names << row[0].text }; names[1..-1] }

  element(:checkboxes) { |b| b.results_table.checkboxes }
  element(:radios) { |b| b.results_table.radios }

  p_action(:check_person) { |person, b| b.results_table.row(text: /#{person}/).checkbox.set }
  p_action(:select_person) { |person, b| b.results_table.row(text: /#{person}/).radio.set }

  element(:paginate_buttons) { |b| b.links(class: /paginate_button/) }
  
  action(:first) { |b| b.page('First').click }
  action(:previous) { |b| b.page('Previous').click }
  p_action(:page) { |page, b| b.link(text: page).click }

  p_action(:set_role) { |role, b|
    raise 'Bad role parameter. Must be PI, COI, or KP' unless %w{PI COI KP}.include? role
    b.radio(name: "addKeyPersonHelper.parameterMap['personRole']", value: role).set
  }

  element(:key_person_role) { |b| b.text_field(name: "addKeyPersonHelper.parameterMap['keyPersonProjectRole']") }
  
  buttons 'Go back', 'Search', 'Add Person'
  action(:continue) { |b| b.button(text: 'Continue...').click; b.loading }

end