class UnrecoveredFandA < BasePage

  document_buttons

  element(:add_unrecovered_f_a) { |b| b.button(text: 'Add Unrecovered F&A').click; b.span(text: 'Add Line').wait_until_present }
  p_element(:fiscal_year) { |number, b| b.target_row(number).text_field(name: /fiscalYear$/) }
  p_element(:applicable_rate) { |number, b| b.target_row(number).text_field(name: /applicableRate$/) }
  p_element(:campus) { |number, b| b.target_row(number).select(name: /onCampusFlag$/) }
  p_element(:fa_source_account) { |number, b| b.target_row(number).text_field(name: /sourceAccount$/) }
  p_element(:fa_amount) { |number, b| b.target_row(number).text_field(name: /amount$/) }

  value(:total_allocated) { |b| b.div(data_label: 'Total Allocated').p(data_role:'totalValue').text }
  value(:total_unallocated) { |b| b.div(data_label: 'Total Unallocated').p(data_role:'totalValue').text }

  private

  element(:fna_rows) { |b| b.section(id: 'PropBudget-UnrecoveredFandAPage-Group').table.tbody.rows }
  p_element(:target_row) { |item, b| b.fna_rows.find{ |row| row.p(class: 'uif-message').text==item } }

end