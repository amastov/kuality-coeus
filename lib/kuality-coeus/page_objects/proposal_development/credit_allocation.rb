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

#For the old U
class CombinedCreditSplit < BasePage

  RECOGNITION = 0
  RESPONSIBILITY = 1
  SPACE = 2
  FINANCIAL = 3

  global_buttons

  element(:splits_table) { |b| b.frm.div(id: 'tab-ProjectPersonnel:CombinedCreditSplit-div').table }

  p_element(:table_row_by_name_old) { |name, b| b.splits_table.tr(text: name) }
  p_value(:find_correct_unit_name) { |number, b| b.splits_table.td(text: /^#{number}/).text }

  action(:set_credit_split_values) {|value='100', b| b.frm.div(id: 'tab-ProjectPersonnel:CombinedCreditSplit-div').text_fields.each {|x| x.set "#{value}" } }

  p_element(:unit_recognition) { |name, unit, b| b.search_target_rows(name).find{ |row| row.text.include? unit }.text_field(name: /creditSplits\[#{RECOGNITION}\].credit/) }
  p_element(:unit_responsibility) { |name, unit, b| b.search_target_rows(name).find{ |row| row.text.include? unit }.text_field(name: /creditSplits\[#{RESPONSIBILITY}\].credit/) }
  p_element(:unit_space) { |name, unit, b| b.search_target_rows(name).find{ |row| row.text.include? unit }.text_field(name: /creditSplits\[#{SPACE}\].credit/) }
  p_element(:unit_financial) { |name, unit, b| b.search_target_rows(name).find{ |row| row.text.include? unit }.text_field(name: /creditSplits\[#{FINANCIAL}\].credit/) }

  p_value(:line_number_of) { |name, b| b.splits_table.td(text: name).id[/(?<=line)\d+/] }

  p_value(:search_target_rows) { |name, b| b.splits_table.rows[b.line_number_of(name).to_i..-1]}

  action(:recalculate_splits) { |b| b.frm.button(name: 'methodToCall.recalculateCreditSplit').click; b.loading }
end