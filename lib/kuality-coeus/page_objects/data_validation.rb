class DataValidation < BasePage

  element(:turn_on) { |b| b.button(text: 'Turn On').when_present.click; b.button(text: 'Turn On').wait_while_present }

  new_error_messages

  element(:data_validation_div) { |b| b.div(id: 'u14cozfk') }
  element(:errors_list) { |b| b.data_validation_div.table }
  element(:close_button) { |b| b.data_validation_div.button(text: 'Close') }

  #Error section
  action(:expand_all_error_sections) { |b| b.data_validation_div.buttons(title: 'show').each {|btn| btn.click }  }
  value(:validation_errors_and_warnings) { |b| b.expand_all_error_sections; b.data_validation_div.tds.collect {|txt| txt.text } }

end

class AwardDataValidation < BasePage

  validation_elements

end