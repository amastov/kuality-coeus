class BudgetPersonnel < BasePage

  document_buttons
  buttons 'Add Personnel', 'Sync from Proposal'

  # Returns an Array. Each element in the Array corresponds to a data row in the
  # Personnel table. The key/value pairs of each Hash is Column=>Cell Contents.
  value(:project_personnel_info) { |b|
    b.personnel_rows.map { |row|
      {
          person:           row.td.text[/^.*(?=\s\()/],
          role:             row.td(index: 1).text[/^.*(?=\s\()/],
          job_code:         row.td(index: 1).span.text[/(?<=\()\w+/],
          appointment_type: row.td(index: 2).text.strip,
          base_salary:      row.td(index: 3).text.strip
      }
    }
  }

  value(:added_personnel) { |b| b.personnel_rows.map { |tr| names << tr[0].text[/.+(?=\s\()/] } }
  p_value(:proposal_role_of) { |name, b| b.person_row(name).td(index: 0).span.text[/\w+/] }
  p_value(:salary_of) { |name, b| b.person_row(name).td(index: 3).text.strip }
  alias_method :base_salary_of, :salary_of
  p_value(:job_code_of) { |name, b| b.person_row(name).td(index: 1).span.text[/\w+/] }
  p_value(:appointment_type_of) { |name, b| b.person_row(name).td(index: 2).text.strip }

  p_action(:details_of) { |name, b| b.person_row(name).button(text: 'Details').click; b.loading }

  private

  p_element(:person_row) { |name, b| b.personnel_table.row(text: /#{name}/) }
  element(:personnel_table) { |b| b.div(class: 'dataTables_wrapper').tbody }
  element(:personnel_rows) { |b| b.no_frame_noko.div(class: 'dataTables_wrapper').tbody.trs(class: /(even|odd)/) }

end