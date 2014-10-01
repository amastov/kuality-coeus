class DataValidation < BasePage

  expected_element :close_button

  element(:turn_on) { |b| b.button(text: 'Turn On').when_present.click; sleep 2; b.loading }

  new_error_messages

  element(:data_section) { |b| b.section(id: /DataValidationSection/) }

  value(:validation_errors_and_warnings) { |b| errs = []; b.data_section.table.rows.each{ |row| errs << row[2].text }; errs }

  element(:close_button) { |b| b.data_section.button(text: 'Close') }

end