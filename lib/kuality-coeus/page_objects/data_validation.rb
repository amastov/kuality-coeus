class DataValidation < BasePage

  expected_element :close_button

  element(:turn_on) { |b| b.button(text: 'Turn On').when_present.click; b.button(text: 'Turn On').wait_while_present }

  new_error_messages

  element(:data_section) { |b| b.section(id: /DataValidationSection/) }
  element(:errors_list) { |b| b.data_section.table }

  value(:validation_errors_and_warnings) { |b| errs = []; b.errors_list.rows.each{ |row| errs << row[2].text }; errs }

  element(:close_button) { |b| b.data_section.button(text: 'Close') }

end