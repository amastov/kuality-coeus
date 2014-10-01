class CreditAllocation < BasePage

  RECOGNITION = 0
  RESPONSIBILITY = 1
  SPACE = 2
  FINANCIAL = 3
  
  document_buttons

  element(:splits_table) { |b| b.table(class: 'table table-condensed credit-allocation') }
  p_value(:line_number_of) { |name, b| b.span(text: name).id[/(?<=line)\d+/] }

  p_element(:recognition) { |name, b| b.text_field(name: "creditSplitListItems[#{b.line_number_of name}].creditSplits[#{RECOGNITION}].credit") }
  p_element(:responsibility) { |name, b| b.text_field(name: "creditSplitListItems[#{b.line_number_of name}].creditSplits[#{RESPONSIBILITY}].credit") }
  p_element(:space) { |name, b| b.text_field(name: "creditSplitListItems[#{b.line_number_of name}].creditSplits[#{SPACE}].credit") }
  p_element(:financial) { |name, b| b.text_field(name: "creditSplitListItems[#{b.line_number_of name}].creditSplits[#{FINANCIAL}].credit") }

end