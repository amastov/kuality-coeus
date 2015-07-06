class AuthExceptionReport < BasePage

  tiny_buttons

  value(:error_message) { |b| b.noko.table(class: 'container2').row[1].text }

end