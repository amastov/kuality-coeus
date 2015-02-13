class CreditAllocation < BasePage

  RESPONSIBILITY = 0
  FINANCIAL = 1
  
  document_buttons
  new_error_messages

  element(:splits_table) { |b| b.table(class: 'table table-condensed credit-allocation') }
  p_value(:line_number_of) { |name, b| b.span(text: name).id[/(?<=line)\d+/] }

  p_element(:responsibility) { |name, b| b.text_field(name: "creditSplitListItems[#{b.line_number_of name}].creditSplits[#{RESPONSIBILITY}].credit") }
  p_element(:financial) { |name, b| b.text_field(name: "creditSplitListItems[#{b.line_number_of name}].creditSplits[#{FINANCIAL}].credit") }

  p_element(:unit_responsibility) { |name, unit, b| b.search_target_rows(name).find{ |row| row.text.include? unit }.text_field(name: /creditSplits\[#{RESPONSIBILITY}\].credit/) }
  p_element(:unit_financial) { |name, unit, b| b.search_target_rows(name).find{ |row| row.text.include? unit }.text_field(name: /creditSplits\[#{FINANCIAL}\].credit/) }

  p_value(:search_target_rows) { |name, b| b.splits_table.rows[b.line_number_of(name).to_i..-1]}

end